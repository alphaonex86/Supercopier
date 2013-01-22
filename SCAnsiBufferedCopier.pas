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

unit SCAnsiBufferedCopier;

{$MODE Delphi}

interface
uses
  Windows,Messages,SCCopier,SysUtils;
  
type
  TAnsiBufferedCopier=class(TCopier)
  private
    Buffer:array of byte;
  protected
    procedure SetBufferSize(Value:cardinal);override;
  public
    function DoCopy:Boolean;override;
  end;

implementation

uses SCCommon,SCLocStrings,SCWin32;

//******************************************************************************
//******************************************************************************
//******************************************************************************
// TAnsiBufferedCopier: descendant de TCopier, copie bufferisйe simple en mode
//                      ansi (Pour Win9x)
//******************************************************************************
//******************************************************************************
//******************************************************************************

//******************************************************************************
// SetBufferSize: fixe la taille du buffer de copie
//******************************************************************************
procedure TAnsiBufferedCopier.SetBufferSize(Value:cardinal);
begin
  if Value<>FBufferSize then
  begin
    SetLength(Buffer,Value);
    FBufferSize:=Value;
  end;
end;

//******************************************************************************
// DoCopy: renvoie false si la copie йchoue
//******************************************************************************
function TAnsiBufferedCopier.DoCopy:boolean;
var HSrc,HDest:THandle;
    SourceFile,DestFile:String;
    BytesRead,BytesWritten:Cardinal;
    ContinueCopy:Boolean;
    LastError:Cardinal;
begin
  Assert(Assigned(OnCopyProgress),'OnCopyProgress not assigned');

  Result:=True;
  with CurrentCopy do
  begin
    CopiedSize:=0;
    SkippedSize:=0;
    SourceFile:=FileItem.SrcFullName;
    DestFile:=FileItem.DestFullName;

    Inc(FileItem.CopyTryCount);

    try
      HSrc:=INVALID_HANDLE_VALUE;
      HDest:=INVALID_HANDLE_VALUE;
      try
        // on ouvre le fichier source
        HSrc:=SysUtils.FileCreate(pchar(SourceFile)); { *Converted from CreateFile*  }
        RaiseCopyErrorIfNot(HSrc<>INVALID_HANDLE_VALUE);

        // effacer les attributs du fichier de destination pour pouvoir l'ouvrir en йcriture
        FileItem.DestClearAttributes;

        // on ouvre le fichier de destination
        if NextAction<>cpaRetry then // doit-on reprendre le transfert?
        begin
          HDest:=FileCreate(pchar(DestFile)); { *Converted from CreateFile*  }
        end
        else
        begin
          HDest:=FileCreate(pchar(DestFile)); { *Converted from CreateFile*  }

          // on se positionne a la fin du fichier de destination
          SetFilePointer(HDest,0,FILE_END);

          SkippedSize:=FileItem.DestSize;
          Self.SkippedSize:=Self.SkippedSize+SkippedSize;
          // et on se mets a la position correspondante dans le fichier source
          SetFilePointer(HSrc,SkippedSize,FILE_BEGIN);
        end;
        RaiseCopyErrorIfNot(HDest<>INVALID_HANDLE_VALUE);

        // on donne sa taille finale au fichier de destination (pour йviter la fragmentation)
        RaiseCopyErrorIfNot(SetFileSize(HDest,FileItem.SrcSize));

        // boucle principale de copie
        repeat
          RaiseCopyErrorIfNot(FileRead(HSrc, Buffer[0],BufferSize) <> -1);
          RaiseCopyErrorIfNot(WriteFile(HDest,Buffer[0],BytesRead,BytesWritten,nil));
          CopiedSize:=CopiedSize+BytesWritten;
          Self.CopiedSize:=Self.CopiedSize+BytesWritten;

          ContinueCopy:=OnCopyProgress;
        until ((CopiedSize+SkippedSize)>=FileItem.SrcSize) or (not ContinueCopy);

        // copie de la date de modif
        CopyFileAge(HSrc,HDest);
      finally
        LastError:=GetLastError;

        // on dйclare la position courrante dans le fichier destination comme fin de fichier
        SetEndOfFile(HDest);

        // fermeture des handles si ouverts
        FileClose(HSrc); { *Converted from CloseHandle*  }
        FileClose(HDest); { *Converted from CloseHandle*  }

        SetLastError(LastError); // ne pas polluer le code d'erreur

        NextAction:=cpaNextFile;
      end;
    except
      on E:ECopyError do
      begin
        Result:=False;

        CopyError;
      end;
    end;
  end;
end;

end.
