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

unit SCAPI;

{$MODE Delphi}

interface

uses Windows,Classes,Contnrs,SysUtils, Forms, ShellApi,
     SCCommon,SCWin32,SCLocStrings,SCAPICommon,SCBaseList,SCWorkThreadList,
       SCWorkThread,SCCopyThread,SCLocEngine;

type
  EAPIError=class(Exception);
  EAPIAlreadyRunning=class(EAPIError);

  TAPI=class(TThread)
  private
    FSemaphore:THandle;
    FMutex:THandle;
    FFileMapping:THandle;
    FClientEvent:THandle;
    FAPIEvent:THandle;
    FFileMappingStream:TFileMappingStream;
    FShutdown:Boolean;
    FHandleList:TObjectList; //TODO: le systиme actuel oщ le handle est l'index d'item leake un peu de mйmoire
                             //      en effet, on ne peut pas faire de Delete() sur la liste sinon les handles se dйcalent ...
                             //      (on mets l'item а nil, ce qui leake 4 octets par handle libйrй)
    FLastError:TApiError;
    FEnabled:Boolean;

    function CheckHandle(AHandle:THandle;AClass:TClass):Boolean;

    // Fonctions de l'API

    procedure APIObjectFree(AHandle:Integer);
    function APIGetLastError:TApiError;
    function APIErrorMessage(AError:TApiError):WideString;
    function APIObjectExists(AHandle:Integer):Boolean;
    function APIGetLocString(ALocStringID:Integer):WideString;

    function APINewBaseList:Integer;
    procedure APIBaselistAddItem(ABaseListHandle:Integer;AItemName:WideString);

    function APIIsEnabled:Boolean;
    function APIProcessBaseList(ABaseListHandle:Integer;AOperation:Integer;ADestDir:WideString):Integer;
    function APIIsSameVolumeMove(ABaseListHandle:Integer;ADestDir:WideString):Boolean;

    function APINewCopy(AIsMove:Boolean):Integer;
    procedure APICopyAddBaseList(ACopyHandle,ABaseListHandle:Integer;AMode:TBaselistAddMode;ADestDir:WideString);

  protected
    procedure Execute;override;
  public
    constructor Create;
    destructor Destroy;override;

    procedure RemoveHandle(AObject:TObject);

    property Enabled:Boolean read FEnabled write FEnabled; 
  end;

  { CPluginLoader }

  CPluginLoader = class
  private
    m_ImportantDll: TStringList;
    m_SecondDll: TStringList;

    function  GetPluginPath: string;
  protected
    function Is64BitWindows: Boolean;
    function CheckExistsDll(): boolean;
    function RegisterShellExtDll(const dllPath: string; const bRegister: boolean; const quiet: boolean): boolean;
  public
    CorrectlyLoaded: TStringList;
    AllDllIsImportant: boolean;
    Debug: boolean;
    ChangeOfArchDetected: boolean;

    constructor Create;
    destructor Destroy; override;

    procedure SetEnabled(const needBeRegistred: boolean);

    property PluginPath: string read GetPluginPath;
  end;

var
  API:TAPI=nil;

implementation

uses Math, Process;

{ CPluginLoader }


function CPluginLoader.GetPluginPath: string;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

function CPluginLoader.Is64BitWindows: Boolean;
var
  IsWow64Process: function(hProcess: THandle; out Wow64Process: Bool): Bool; stdcall;
  Wow64Process: Bool;
begin
  {$IF Defined(CPU64)}
  Result := True; // x64 app starts only on Win64
  {$ELSEIF Defined(CPU16)}
  Result := False; // Win64 doesn`t suppert x16 apps
  {$ELSE}
  // x32 apps can work on x32 and x64 Windows, so then ...
  IsWow64Process := GetProcAddress(GetModuleHandle(Kernel32), 'IsWow64Process');

  Wow64Process := False;
  if Assigned(IsWow64Process) then
    Wow64Process := IsWow64Process(GetCurrentProcess, Wow64Process) and Wow64Process;

  Result := Wow64Process;
  {$IFEND}
end;

function CPluginLoader.CheckExistsDll: boolean;
begin
  //detect if it's 64Bits OS or not
  if(Is64BitWindows) then
  begin
    m_ImportantDll.Add('SCShellExt64.dll');
    m_SecondDll.Add('SCShellExt.dll');
  end
  else
  begin
    m_ImportantDll.Add('SCShellExt.dll');
    m_SecondDll.Add('SCShellExt64.dll');
  end;

  Result := (m_ImportantDll.Count > 0) or (m_SecondDll.Count > 0);
end;


function CPluginLoader.RegisterShellExtDll(const dllPath: string;
  const bRegister: boolean; const quiet: boolean): boolean;
var
  arguments: TStringList;
  i, res: integer;
  argumentsString: string;
  ok: boolean;
  temp: TStringList;
  process: TProcess;
  sei:TSHELLEXECUTEINFOA;
begin
  arguments := TStringList.Create;
  if(not Debug) then
    arguments.Add('/s');
  if(not bRegister) then
    arguments.Add('/u');
  arguments.Add(dllPath);

  argumentsString := '';
  for i := 0 to arguments.Count-1 do
  begin
    if(Length(argumentsString) = 0) then
      argumentsString := argumentsString + arguments[i]
      else if(i = arguments.Count-1) then
        argumentsString := argumentsString + ' "' + arguments[i] + '"'
        else argumentsString := argumentsString + ' ' + arguments[i];
  end;
  arguments.Free;
  arguments := nil;
  res := SysUtils.ExecuteProcess('regsvr32', argumentsString, []);

  ok := res = 0;

  {$IF Not Defined(CPU64)}
  if((res = 999) and not changeOfArchDetected) then//code of wrong arch for the dll
  begin
    changeOfArchDetected := true;
    temp := m_ImportantDll;
    m_SecondDll := m_ImportantDll;
    m_ImportantDll := temp;
    Result := false;
    exit;
  end;
  {$IFEND}
  if(res = 5) then
  begin
    if(not quiet or (not bRegister and (correctlyLoaded.IndexOf(dllPath) <> -1))) then
    begin
      //regsvr32 with elevated privilege
      //ULTRACOPIER_DEBUGCONSOLE(Ultracopier::DebugLevel_Notice,"try it in win32");
      // try with regsvr32, win32 because for admin dialog
      //ok := boolean(ShellExecute(Application.MainForm.Handle, PChar('regsvr32.exe'), PChar('runas'), PChar(''), PChar(''), 0));
      FillChar(sei, SizeOf(sei), 0);
      sei.cbSize:=SizeOf(sei);
      sei.Wnd := Application.MainForm.Handle;
      sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
      sei.lpVerb := 'runas';
      sei.lpFile := PAnsiChar('regsvr32');
      sei.lpParameters:=PAnsiChar(argumentsString);
      sei.nShow:=SW_SHOWNORMAL;
      ok := ShellExecuteExA(@sei);
    end;
  end;
  if (correctlyLoaded.IndexOf(dllPath) <> -1) then
    correctlyLoaded.Delete(correctlyLoaded.IndexOf(dllPath));
  Result := ok;
end;

constructor CPluginLoader.Create;
begin
  m_ImportantDll := TStringList.Create;
  m_SecondDll := TStringList.Create;
  CorrectlyLoaded := TStringList.Create;
end;

destructor CPluginLoader.Destroy;
begin
  m_ImportantDll.Free;
  m_SecondDll.Free;
  CorrectlyLoaded.Free;
  inherited Destroy;
end;

procedure CPluginLoader.SetEnabled(const needBeRegistred: boolean);
var
  oneHaveFound: boolean;
  index: integer;

  importantDll_is_loaded, secondDll_is_loaded, importantDll_have_bug, secondDll_have_bug: boolean;
  importantDll_count, secondDll_count: integer;
begin
  if(not CheckExistsDll()) then exit;//stop because not dll found into the folder
  //importantDll -> string list, launch UAC is needed
  //secondDll -> string list, never launch UAC

  oneHaveFound := false;
  index := 0;
  while(index < m_ImportantDll.Count) do
  begin
    if(FileExists(pluginPath + m_ImportantDll[index])) then
    begin
      oneHaveFound := true;
      break;
    end;
    inc(index);
  end;

  if(not oneHaveFound) then
  begin
    index := 0;
    while(index < m_SecondDll.Count) do
    begin
      if(FileExists(pluginPath + m_SecondDll[index])) then
      begin
        oneHaveFound := true;
        break;
      end;
      inc(index);
    end
  end;

  importantDll_is_loaded := false;
  secondDll_is_loaded := false;
  importantDll_have_bug := false;
  secondDll_have_bug := false;
  importantDll_count := 0;
  secondDll_count := 0;

  index := 0;
  while(index < m_ImportantDll.Count) do
  begin
    if(not RegisterShellExtDll(pluginPath + m_ImportantDll[index], needBeRegistred, false)) then
        importantDll_have_bug := true
    else
    begin
      if(needBeRegistred) then
        correctlyLoaded.Add(m_ImportantDll[index]);
      importantDll_is_loaded := true;
    end;
    inc(importantDll_count);
    inc(index);
  end;

  index := 0;
  while(index < m_SecondDll.Count) do
  begin
    if(not RegisterShellExtDll(pluginPath + m_SecondDll[index], needBeRegistred,
        not ((needBeRegistred and allDllIsImportant) or (not needBeRegistred and (correctlyLoaded.IndexOf(m_SecondDll[index]) <> -1))))) then
      secondDll_have_bug := true
      else
      begin
        if(needBeRegistred) then
          correctlyLoaded.Add(m_SecondDll[index]);
	secondDll_is_loaded := true;
      end;
    inc(secondDll_count);
    inc(index);
  end;

  if(not needBeRegistred) then
    correctlyLoaded.clear();
end;

{ TAPI }

procedure TAPI.APIBaselistAddItem(ABaseListHandle: Integer;
  AItemName: WideString);
var Item:TBaseItem;
begin
  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  Item:=TBaseItem.Create;
  Item.SrcName:=AItemName;
  Item.IsDirectory:=DirectoryExists(AItemName);

  (FHandleList[ABaseListHandle] as TBaseList).Add(Item);

  FLastError:=aeNone;
end;

procedure TAPI.APICopyAddBaseList(ACopyHandle, ABaseListHandle: Integer;
  AMode: TBaselistAddMode; ADestDir: WideString);
begin
  if not CheckHandle(ACopyHandle,TCopyThread) or not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  (FHandleList[ACopyHandle] as TCopyThread).AddBaseList(FHandleList[ABaseListHandle] as TBaseList,AMode,ADestDir);

  FLastError:=aeNone;
end;

function TAPI.APIErrorMessage(AError: TApiError): WideString;
begin
  Result:='';
  if (AError>=Low(TApiError)) and (AError<=High(TApiError)) then
    Result:=SC2_API_ERRORS_NAMES[AError];
end;

function TAPI.APIGetLastError: TApiError;
begin
  Result:=FLastError;
end;

function TAPI.APIGetLocString(ALocStringID: Integer): WideString;
begin
  Result:='';
  FLastError:=aeBadLocStringId;

  if (ALocStringID>=Low(LOC_STRINGS_ARRAY)) and (ALocStringID<=High(LOC_STRINGS_ARRAY)) then
  begin
    Result:=LOC_STRINGS_ARRAY[ALocStringID]^;
    FLastError:=aeNone;
  end;
end;

function TAPI.APIIsEnabled: Boolean;
begin
  Result:=FEnabled;
end;

function TAPI.APIIsSameVolumeMove(ABaseListHandle: Integer;
  ADestDir: WideString): Boolean;
var GuessedSrcDir:WideString;
    BaseList:TBaseList;
begin
  Result:=False;

  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  BaseList:=FHandleList[ABaseListHandle] as TBaseList;

  if BaseList.Count=0 then
  begin
    FLastError:=aeEmptyBaseList;
    Exit;
  end;

  GuessedSrcDir:=ExtractFilePath(BaseList[0].SrcName);
  Result:=SameVolume(GuessedSrcDir,ADestDir);

  FLastError:=aeNone;
end;

function TAPI.APINewBaseList: Integer;
begin
  Result:=FHandleList.Add(TBaseList.Create);

  FLastError:=aeNone;
end;

function TAPI.APINewCopy(AIsMove: Boolean): Integer;
begin
  Result:=FHandleList.Add(TCopyThread.Create(AIsMove));

  FLastError:=aeNone;
end;

function TAPI.APIObjectExists(AHandle: Integer): Boolean;
begin
  Result:=CheckHandle(AHandle,TObject);

  FLastError:=aeNone;
end;

procedure TAPI.APIObjectFree(AHandle: Integer);
begin
  if not CheckHandle(AHandle,TObject) then Exit;

  FHandleList[AHandle].Free;
  FHandleList[AHandle]:=nil;

  FLastError:=aeNone;
end;

function TAPI.APIProcessBaseList(ABaseListHandle: Integer; AOperation: Integer;
  ADestDir: WideString): Integer;
var WorkThread:TWorkThread;
begin
  Result:=SC2_API_INVALID_HANDLE;
  if not CheckHandle(ABaseListHandle,TBaseList) then Exit;

  WorkThread:=WorkThreadList.ProcessBaseList(FHandleList[ABaseListHandle] as TBaseList,AOperation,ADestDir);
  if WorkThread=nil then
    Result:=SC2_API_INVALID_HANDLE
  else
  begin
    Result:=FHandleList.IndexOf(WorkThread);
    if Result=SC2_API_INVALID_HANDLE then
      Result:=FHandleList.Add(WorkThread);
  end;

  FLastError:=aeNone;
end;

function TAPI.CheckHandle(AHandle: THandle;AClass:TClass): Boolean;
begin
  Result:=InRange(AHandle,0,FHandleList.Count-1) and (FHandleList[AHandle]<>nil);
  if not Result then
    FLastError:=aeBadHandle
  else
  begin
    Result:=FHandleList[AHandle] is AClass;
    if not Result then
      FLastError:=aeWrongHandleType;
  end;
end;

constructor TAPI.Create;
var
    Error:Integer;
begin
  inherited Create(True);
  FSemaphore:=0;
  FMutex:=0;
  FFileMapping:=0;
  FClientEvent:=0;
  FAPIEvent:=0;
  FFileMappingStream:=nil;

  // Sйmaphore
  FSemaphore:=SCWin32.CreateSemaphore(nil,0,MaxInt,PWideChar(SessionUniqueAPIIdentifier(SC2_API_SEMAPHORE_ID)));
  Error:=GetLastError;
  if (Error=ERROR_ALREADY_EXISTS) or (Error=ERROR_ACCESS_DENIED) then
    raise EAPIAlreadyRunning.Create(lsAPIAlreadyRunning);
  if FSemaphore=0 then
    raise EAPIError.Create(lsAPINoSemaphore);

  // Mutex
  FMutex:=SCWin32.CreateMutex(nil,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_MUTEX_ID)));
  if FMutex=0 then
    raise EAPIError.Create(lsAPINoMutex);

  // File mapping
  FFileMapping:=SCWin32.CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SC2_API_FILEMAPPING_SIZE,PWideChar(SessionUniqueAPIIdentifier(SC2_API_FILEMAPPING_ID)));
  if FFileMapping=0 then
    raise EAPIError.Create(lsAPINoFileMapping);

  // Client event
  FClientEvent:=SCWin32.CreateEvent(nil,False,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_CLIENTEVENT_ID)));
  if FClientEvent=0 then
    raise EAPIError.Create(lsAPINoEvent);

  // API event
  FAPIEvent:=SCWin32.CreateEvent(nil,False,False,PWideChar(SessionUniqueAPIIdentifier(SC2_API_APIEVENT_ID)));
  if FAPIEvent=0 then
    raise EAPIError.Create(lsAPINoEvent);

  FFileMappingStream:=TFileMappingStream.Create(FFileMapping,SC2_API_FILEMAPPING_SIZE);

  FShutdown:=False;
  FreeOnTerminate:=False;

  FHandleList:=TObjectList.Create(False);
  FLastError:=aeNone;

  FEnabled:=False;

  Resume;
end;

destructor TAPI.Destroy;
begin
  if FMutex<>0 then
  begin
    // simuler un йvиnement d'un client pour pouvoir fermer la thread
    WaitForSingleObject(FMutex,INFINITE);
    try
      FFileMappingStream.Seek(0,soFromBeginning);
      FFileMappingStream.WriteInteger(Integer(afNone));

      FShutdown:=True;
      SetEvent(FClientEvent);
      WaitForSingleObject(FAPIEvent,INFINITE);

      WaitFor;
    finally
      ReleaseMutex(FMutex);
    end;
  end;

  FHandleList.Free;
  FFileMappingStream.Free;
  FileClose(FAPIEvent); { *Converted from CloseHandle*  }
  FileClose(FClientEvent); { *Converted from CloseHandle*  }
  FileClose(FFileMapping); { *Converted from CloseHandle*  }
  FileClose(FMutex); { *Converted from CloseHandle*  }
  FileClose(FSemaphore); { *Converted from CloseHandle*  }
  inherited;
end;

procedure TAPI.Execute;
var ApiFunction:TApiFunction;
    s:WideString;
    i,j,k:Integer;
    b:boolean;
begin
  dbgln('API thread starting');

  while not FShutdown do
  begin
    WaitForSingleObject(FClientEvent,INFINITE);
    try
      try
        with FFileMappingStream do
        begin
          Seek(0,soBeginning);
          ApiFunction:=TApiFunction(ReadInteger);

          dbgln('Received API call #'+IntToStr(Ord(ApiFunction)));

          // /!\ ne pas appeler plusieurs fois Read... dans les paramиtres d'une fonction, car Delphi evalue les params de droite а gauche !!!
          case ApiFunction of
            afObjectFree:
              APIObjectFree(ReadInteger);
            afGetLastError:
            begin
              Seek(0,soBeginning);
              WriteInteger(Ord(APIGetLastError));
            end;
            afErrorMessage:
            begin
              s:=APIErrorMessage(TApiError(ReadInteger));
              Seek(0,soBeginning);
              WriteWideString(s);
            end;
            afObjectExists:
            begin
              b:=APIObjectExists(ReadInteger);
              Seek(0,soBeginning);
              WriteInteger(Ord(b));
            end;
            afGetLocString:
            begin
              s:=APIGetLocString(ReadInteger);
              Seek(0,soBeginning);
              WriteWideString(s);
            end;
            afNewBaseList:
            begin
              Seek(0,soBeginning);
              WriteInteger(APINewBaseList);
            end;
            afBaselistAddItem:
            begin
              i:=ReadInteger;
              APIBaselistAddItem(i,ReadWideString);
            end;
            afIsEnabled:
            begin
              Seek(0,soBeginning);
              WriteInteger(Ord(APIIsEnabled));
            end;
            afProcessBaseList:
            begin
              i:=ReadInteger;
              j:=ReadInteger;
              i:=APIProcessBaseList(i,j,ReadWideString);
              Seek(0,soBeginning);
              WriteInteger(i);
            end;
            afIsSameVolumeMove:
            begin
              i:=ReadInteger;
              b:=APIIsSameVolumeMove(i,ReadWideString);
              Seek(0,soBeginning);
              WriteInteger(Ord(b));
            end;
            afNewCopy:
            begin
              i:=APINewCopy(ReadInteger<>0);
              Seek(0,soBeginning);
              WriteInteger(i);
            end;
            afCopyAddBaseList:
            begin
              i:=ReadInteger;
              j:=ReadInteger;
              k:=ReadInteger;
              APICopyAddBaseList(i,j,TBaseListAddMode(k),ReadWideString);
            end;
          end;
        end;
      finally
        SetEvent(FAPIEvent);
      end;
    except // ne pas laisser les exceptions tuer l'API
      on E:Exception do dbgln('API Exception: '+E.Message);
    end;
  end;

  dbgln('API thread ending');
end;

procedure TAPI.RemoveHandle(AObject: TObject);
var Idx:Integer;
begin
  Idx:=FHandleList.IndexOf(AObject);
  if Idx<>-1 then
    FHandleList[Idx]:=nil;
end;

end.
