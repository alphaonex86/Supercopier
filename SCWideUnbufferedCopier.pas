{
    This file is part of SuperCopier.

    SuperCopier is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    SuperCopier is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
}

unit SCWideUnbufferedCopier;

{$MODE Delphi}

interface
uses
  Windows,Messages,SCCopier;

const
  MAX_WAITING_IO=16; // nombre max d'I/O en attente

  READ_ENDING_EVENT=0;
  WRITE_ENDING_EVENT=1;
  WORK_EVENT=2;
  READ_ENDING_EVENT_NAME='SC2 Read ending';
  WRITE_ENDING_EVENT_NAME='SC2 Write ending';
  WORK_EVENT_NAME='SC2 Work';

  ENABLE_32K_CHARS_PATH='\\?\';
type
  TWideUnbufferedCopier=class(TCopier)
  private
    SrcOvr,DestOvr:TOverlapped;
    Events:array[0..2] of THandle;
    Buffer:PByte;
    FullBufferSize:Cardinal;
  protected
    procedure SetBufferSize(Value:cardinal);override;
  public
    constructor Create;
    destructor Destroy;override;

    function DoCopy:Boolean;override;
  end;

implementation

uses SCCommon,SCLocStrings,SCWin32,SysUtils,Math;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TWideUnbufferedCopier: descendant de TCopier, copie non bufferisйe asynchrone
//                        gйrant l'unicode
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// Create
//******************************************************************************
constructor TWideUnbufferedCopier.Create;
  // MakeUnique: ajoute un identifiant unique de Copier а S
  function MakeUnique(S:String):String;
  begin
    Result:=S+IntToStr(Cardinal(Self));
  end;
begin
  inherited;
  FBufferSize:=0;

  // crйer les йvиnements pour le copier
  Events[READ_ENDING_EVENT]:=Windows.CreateEvent(nil,True,False,PChar(MakeUnique(READ_ENDING_EVENT_NAME)));
  Events[WRITE_ENDING_EVENT]:=Windows.CreateEvent(nil,True,False,PChar(MakeUnique(WRITE_ENDING_EVENT_NAME)));
  Events[WORK_EVENT]:=Windows.CreateEvent(nil,True,False,PChar(MakeUnique(WORK_EVENT_NAME)));

  if (Events[READ_ENDING_EVENT]=INVALID_HANDLE_VALUE) or
     (Events[WRITE_ENDING_EVENT]=INVALID_HANDLE_VALUE) or
     (Events[WORK_EVENT]=INVALID_HANDLE_VALUE) then
  begin
    raise Exception.Create('Failed to create copy events');
  end;

  // associer les йvиnements aux structures Overlapped
  SrcOvr.hEvent:=Events[READ_ENDING_EVENT];
  DestOvr.hEvent:=Events[WRITE_ENDING_EVENT];
end;

//******************************************************************************
// Destroy
//******************************************************************************
destructor TWideUnbufferedCopier.Destroy;
begin
  SetBufferSize(0);

  // dйtruire les йvиnements
  FileClose(Events[READ_ENDING_EVENT]); { *Converted from CloseHandle*  }
  FileClose(Events[WRITE_ENDING_EVENT]); { *Converted from CloseHandle*  }
  FileClose(Events[WORK_EVENT]); { *Converted from CloseHandle*  }

  inherited;
end;

//******************************************************************************
// SetBufferSize: fixe la taille du buffer de copie
//******************************************************************************
procedure TWideUnbufferedCopier.SetBufferSize(Value:cardinal);
begin
  if Value<>FBufferSize then
  begin
    FBufferSize:=Value;
    FullBufferSize:=FBufferSize*MAX_WAITING_IO;
    VirtualFree(Buffer,0,MEM_RELEASE); // on libиre le prйcйdent buffer allouй
    Buffer:=VirtualAlloc(nil,FullBufferSize,MEM_COMMIT,PAGE_READWRITE);
  end;
end;

//******************************************************************************
// DoCopy: renvoie false si la copie йchoue
//******************************************************************************
function TWideUnbufferedCopier.DoCopy:boolean;
  function OnlyFullChunks(Size:Int64):Int64;
  begin
    Result:=Size-Size mod FBufferSize;
  end;
var HSrc,HDest,HBufferedDest:THandle;
    SourceFile,DestFile:WideString;
    ReadPending,WritePending,ReadEnd,WriteEnd:Boolean;
    BytesProcessed,UsedBuffer:Cardinal;
    Ok,ContinueCopy:Boolean;
    ReadPos,WritePos:Int64;
    ReadPosRec:Int64Rec absolute ReadPos;
    WritePosRec:Int64Rec absolute WritePos;
    LastError:Cardinal;
    SourceIsNetwork,DestIsNetwork:Boolean;
begin
  Assert(Assigned(OnCopyProgress),'OnCopyProgress not assigned');

  Result:=True;
  with CurrentCopy do
  begin
    ContinueCopy:=True;
    CopiedSize:=0;
    SkippedSize:=0;
    UsedBuffer:=0;
    ReadPending:=False;
    WritePending:=False;
    ReadEnd:=False;
    WriteEnd:=False;
    ReadPos:=0;
    WritePos:=0;

    SourceFile:=FileItem.SrcFullName;
    DestFile:=FileItem.DestFullName;

    SourceIsNetwork:=PathIsNetworkPath(PWideChar(SourceFile));
    DestIsNetwork:=PathIsNetworkPath(PWideChar(DestFile));

    // gйrer les chemins de plus de MAX_PATH caractиres
    if not PathIsUNC(PWideChar(SourceFile)) then SourceFile:=ENABLE_32K_CHARS_PATH+SourceFile;
    if not PathIsUNC(PWideChar(DestFile)) then DestFile:=ENABLE_32K_CHARS_PATH+DestFile;

    Inc(FileItem.CopyTryCount);

    try
      HSrc:=INVALID_HANDLE_VALUE;
      HDest:=INVALID_HANDLE_VALUE;
      HBufferedDest:=INVALID_HANDLE_VALUE;
      try
        // on ouvre le fichier source
        HSrc:=Windows.CreateFileW(PWideChar(SourceFile),
                            GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE,
                            nil,
                            OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED
                            or IfThen(SourceIsNetwork,0,FILE_FLAG_NO_BUFFERING),
                            0);
        RaiseCopyErrorIfNot(HSrc<>INVALID_HANDLE_VALUE);

        // effacer les attributs du fichier de destination pour pouvoir l'ouvrir en йcriture
        FileItem.DestClearAttributes;

        // on ouvre le fichier de destination
        if NextAction<>cpaRetry then // doit-on reprendre le transfert?
        begin
          HDest:=CreateFileW(PWideChar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ or FILE_SHARE_WRITE,
                              nil,
                              CREATE_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED
                              or IfThen(DestIsNetwork,0,FILE_FLAG_NO_BUFFERING),
                              0);
          RaiseCopyErrorIfNot(HDest<>INVALID_HANDLE_VALUE);

          // on ouvre un handle sur le fichier de destination en bufferisй pour pouvoir
          // fixer le fichier а la bonne taille (en non bufferisй, on ne peut copier
          // que des blocs de taille multiple de celle d'une page mйmoire)
          HBufferedDest:=CreateFileW(PWideChar(DestFile),
                                      GENERIC_WRITE,
                                      FILE_SHARE_READ or FILE_SHARE_WRITE,
                                      nil,
                                      CREATE_ALWAYS,
                                      FILE_ATTRIBUTE_NORMAL,
                                      0);
          RaiseCopyErrorIfNot(HBufferedDest<>INVALID_HANDLE_VALUE);
        end
        else
        begin
          HDest:=CreateFileW(PWideChar(DestFile),
                              GENERIC_WRITE,
                              FILE_SHARE_READ or FILE_SHARE_WRITE,
                              nil,
                              OPEN_ALWAYS,
                              FILE_ATTRIBUTE_NORMAL or FILE_FLAG_NO_BUFFERING or FILE_FLAG_OVERLAPPED,
                              0);
          RaiseCopyErrorIfNot(HDest<>INVALID_HANDLE_VALUE);

          HBufferedDest:=CreateFileW(PWideChar(DestFile),
                                      GENERIC_WRITE,
                                      FILE_SHARE_READ or FILE_SHARE_WRITE,
                                      nil,
                                      OPEN_ALWAYS,
                                      FILE_ATTRIBUTE_NORMAL,
                                      0);
          RaiseCopyErrorIfNot(HBufferedDest<>INVALID_HANDLE_VALUE);

          SkippedSize:=OnlyFullChunks(FileItem.DestSize);
          Self.SkippedSize:=Self.SkippedSize+SkippedSize;
        end;

        // on aggrandit fichier de destination a au moins sa taille finale
        // (pour йviter la fragmentation et pour que l'overlapped fonctionne correctement)
        RaiseCopyErrorIfNot(SetFileSize(HDest,OnlyFullChunks(FileItem.SrcSize)+FBufferSize));


        // on amorce le systиme
        ReadPos:=SkippedSize;
        WritePos:=SkippedSize;
        SetEvent(Events[WORK_EVENT]);

        if FileItem.SrcSize>0 then // aucun traitemeant a faire pour les fichiers vides
        begin
          while not (ReadEnd and WriteEnd) and ContinueCopy  do
          begin
            // on attends qu'un йvиnement se produise
            case WaitForMultipleObjects(Length(Events),@Events[0],False,INFINITE) of
              WAIT_OBJECT_0+READ_ENDING_EVENT:
              begin
                ResetEvent(Events[READ_ENDING_EVENT]);
                ReadPending:=False;
                RaiseCopyErrorIfNot(GetOverlappedResult(HSrc,SrcOvr,BytesProcessed,True));
                ReadPos:=ReadPos+BytesProcessed;
                UsedBuffer:=UsedBuffer+BytesProcessed;
                ReadEnd:=ReadPos>=FileItem.SrcSize;

                // on lance la lecture suivante
                SetEvent(Events[WORK_EVENT]);
              end;
              WAIT_OBJECT_0+WRITE_ENDING_EVENT:
              begin
                ResetEvent(Events[WRITE_ENDING_EVENT]);
                WritePending:=False;
                RaiseCopyErrorIfNot(GetOverlappedResult(HDest,DestOvr,BytesProcessed,True));
                WritePos:=WritePos+BytesProcessed;
                UsedBuffer:=UsedBuffer-BytesProcessed;
                WriteEnd:=WritePos>=FileItem.SrcSize;

                // on lance l'йcriture suivante
                SetEvent(Events[WORK_EVENT]);

                // des donnйes ont йtйs йcrites -> on dйclenche l'evenement de progression
                  // ne pas compter le dйpassement de la taille du fichier
                if WriteEnd then BytesProcessed:=BytesProcessed-(WritePos-FileItem.SrcSize);
                CopiedSize:=CopiedSize+BytesProcessed;
                Self.CopiedSize:=Self.CopiedSize+BytesProcessed;
                ContinueCopy:=OnCopyProgress;
              end;
              WAIT_OBJECT_0+WORK_EVENT:
              begin
                ResetEvent(Events[WORK_EVENT]);

                // on lance une lecture si il n'y en a pas en cours et si le buffer n'est pas plein
                if not ReadEnd and not ReadPending and (FullBufferSize-UsedBuffer>=FBufferSize) then
                begin
                  SrcOvr.Offset:=ReadPosRec.Lo;
                  SrcOvr.OffsetHigh:=ReadPosRec.Hi;

                  // on vйrifie que l'on est pas en buffer overflow
                  if (Abs((WritePos-ReadPos) mod FullBufferSize)>FBufferSize) or not WritePending then
                  begin
                    Ok := Windows.ReadFile(HSrc, Pointer(Cardinal(Buffer)+SrcOvr.Offset mod FullBufferSize)^, FBufferSize, BytesProcessed, @SrcOvr);
                    ReadPending:=GetLastError=ERROR_IO_PENDING;
                    RaiseCopyErrorIfNot(Ok or ReadPending);
                    if not ReadPending then SetEvent(Events[READ_ENDING_EVENT]); // si l'i/o est synchrone, on dйclenche l'evenement a la main
                  end;
                end;

                // on lance une йcriture si il n'y en a pas en cours et si il y a au moins un bloc de lu
                if not WriteEnd and not WritePending and ((UsedBuffer>=FBufferSize) or ReadEnd) then
                begin
                  DestOvr.Offset:=WritePosRec.Lo;
                  DestOvr.OffsetHigh:=WritePosRec.Hi;

                  // on vйrifie que l'on est pas en buffer overflow
                  if (Abs((WritePos-ReadPos) mod FullBufferSize)>FBufferSize) or not ReadPending then
                  begin
                    Ok:=WriteFile(HDest,Pointer(Cardinal(Buffer)+DestOvr.Offset mod FullBufferSize)^,FBufferSize,BytesProcessed,@DestOvr);
                    WritePending:=GetLastError=ERROR_IO_PENDING;
                    RaiseCopyErrorIfNot(Ok or WritePending);
                    if not WritePending then SetEvent(Events[WRITE_ENDING_EVENT]); // si l'i/o est synchrone, on dйclenche l'evenement a la main
                  end;
                end;
              end;
            end;
          end;
        end;

        // on fixe le fichier а la bonne taille en utilisant le handle bufferisй
        RaiseCopyErrorIfNot(SetFileSize(HBufferedDest,FileItem.SrcSize));

        // copie de la date de modif
        CopyFileAge(HSrc,HDest);
        CopyFileAge(HSrc,HBufferedDest);
      finally
        LastError:=GetLastError;

        // on dйclare la position courrante dans le fichier destination comme fin de fichier
        SetFileSize(HBufferedDest,CopiedSize+SkippedSize); //TODO: ajouter gestion des erreurs !!!

        // fermeture des handles si ouverts
        FileClose(HSrc); { *Converted from CloseHandle*  }
        FileClose(HDest); { *Converted from CloseHandle*  }
        FileClose(HBufferedDest); { *Converted from CloseHandle*  }

        SetLastError(LastError); // ne pas polluer le code d'erreur

        NextAction:=cpaNextFile;
      end;
    except
      on E:ECopyError do
      begin
        dbgln(GetLastError);
        Result:=False;
        CopyError;
      end;
    end;
  end;
end;

end.
