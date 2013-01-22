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

unit SCMainForm;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics,  Forms,
  Dialogs, StdCtrls,filectrl, Controls,
  ComCtrls, {XPMan,} Menus, ImgList,   ExtCtrls,
  Buttons, SCConfigShared,SCLocEngine,SCAPI, Windows;

const
  CANCEL_TIMEOUT=5000; //ms

type

  { TMainForm }

  TMainForm = class(TForm)
//    XPManifest: TXPManifest;
    Systray: TTrayIcon;//TTScSystray;
    pmSystray: TPopupMenu;
    miActivate: TMenuItem;
    N1: TMenuItem;
    miConfig: TMenuItem;
    miAbout: TMenuItem;
    miExit: TMenuItem;
    N2: TMenuItem;
    miNewThread: TMenuItem;
    miNewCopyThread: TMenuItem;
    miNewMoveThread: TMenuItem;
    miThreadList: TMenuItem;
    miNoThreadList: TMenuItem;
    miDeactivate: TMenuItem;
    miCancelAll: TMenuItem;
    miCancelThread: TMenuItem;
    ilGlobal: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miConfigClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miNewCopyThreadClick(Sender: TObject);
    procedure miNewMoveThreadClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miThreadListClick(Sender: TObject);
    procedure miActivateClick(Sender: TObject);
    procedure miCancelAllClick(Sender: TObject);
    procedure miCancelThreadClick(Sender: TObject);
    procedure SystrayBallonClick(Sender: TObject);
  private
    { Dйclarations privйes }
    procedure UpdateSystrayIcon;
    procedure OpenDialog(var AMsg:TMessage); message WM_OPENDIALOG;
  public
    { Dйclarations publiques }
    NotificationSourceForm:TForm;
    NotificationSourceThread:TThread;
  end;

var
  MainForm: TMainForm;

implementation
uses SCConfig,SCCommon,SCWin32,SCCopyThread,SCBaseList,SCFileList,SCDirList,SCWorkThreadList,
  SCConfigForm,SCAboutForm,SCLocStrings,SCCopyForm, Math;
{$R *.lfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Windows.SetParent(Handle,THANDLE(-3{HWND_MESSAGE})); // cacher la form
  Caption:=SC2_MAINFORM_CAPTION;

  WorkThreadList:=TWorkThreadList.Create;

  LocEngine:=TLocEngine.Create;

  OpenConfig;
  ApplyConfig;

  Systray.Hint:='SuperCopier';
  UpdateSystrayIcon;

  try
    API:=TAPI.Create;
  except
    on E:EAPIAlreadyRunning do
    begin
      SCWin32.MessageBox(Handle,WideFormat(lsAlreadyRunningText,[E.Message]),lsAlreadyRunningCaption,MB_OK or MB_ICONERROR);
      Application.Terminate;
      Exit;
    end;
  end;

  API.Enabled:=Config.Values.ActivateOnStart;

  miActivate.Visible:=not API.Enabled;
  miDeactivate.Visible:=API.Enabled;

  UpdateSystrayIcon;

  NotificationSourceForm:=nil;

  LocEngine.TranslateForm(Self);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;

  API.Free;

  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);
  WorkThreadList.Free;

  CloseConfig;

  LocEngine.Free;
end;

procedure TMainForm.miConfigClick(Sender: TObject);
begin
  if Assigned(ConfigForm) then
  begin
    ConfigForm.BringToFront;
  end
  else
  begin
    Application.CreateForm(TConfigForm,ConfigForm);
    ConfigForm.Show;
  end;
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  if Assigned(AboutForm) then
  begin
    AboutForm.BringToFront;
  end
  else
  begin
    Application.CreateForm(TAboutForm,AboutForm);
    AboutForm.Show;
  end;
end;

procedure TMainForm.miNewCopyThreadClick(Sender: TObject);
begin
  WorkThreadList.CreateEmptyCopyThread(False);
end;

procedure TMainForm.miNewMoveThreadClick(Sender: TObject);
begin
  WorkThreadList.CreateEmptyCopyThread(True);
end;

procedure TMainForm.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.miThreadListClick(Sender: TObject);
var i:Integer;
    MenuItem,CancelSubItem:TMenuItem;
begin
  for i:=0 to WorkThreadList.Count-1 do
  begin
    MenuItem:=TMenuItem.Create(pmSystray);
    MenuItem.Caption:=WorkThreadList[i].DisplayName;
    MenuItem.ImageIndex:=miThreadList.ImageIndex;
    MenuItem.Tag:=i;
    miThreadList.Add(MenuItem);

    CancelSubItem:=TMenuItem.Create(pmSystray);
    CancelSubItem.Caption:=miCancelThread.Caption;
    CancelSubItem.OnClick:=miCancelThread.OnClick;
    CancelSubItem.ImageIndex:=miCancelThread.ImageIndex;
    CancelSubItem.Tag:=i;
    MenuItem.Add(CancelSubItem);
  end;

  // enlever les anciens items
  while miThreadList.Count>(WorkThreadList.Count+1) do miThreadList.Delete(1);
end;

procedure TMainForm.miActivateClick(Sender: TObject);
begin
  API.Enabled:=not API.Enabled;

  miActivate.Visible:=not API.Enabled;
  miDeactivate.Visible:=API.Enabled;

  UpdateSystrayIcon;
end;

procedure TMainForm.miCancelAllClick(Sender: TObject);
begin
  WorkThreadList.CancelAllAndWaitTermination(CANCEL_TIMEOUT);
end;

procedure TMainForm.miCancelThreadClick(Sender: TObject);
begin
  WorkThreadList[(Sender as TMenuItem).Tag].Cancel;
end;

procedure TMainForm.SystrayBallonClick(Sender: TObject);
begin
  if (WorkThreadList.IndexOf(NotificationSourceThread)<>-1) and (NotificationSourceForm is TCopyForm) then
  begin
    (NotificationSourceForm as TCopyForm).Minimized:=False;
  end;
end;

//******************************************************************************
// UpdateSystrayIcon: change l'icфne du systray en fonction de l'йtat d'activation
//******************************************************************************
procedure TMainForm.UpdateSystrayIcon;
var
    Idx:Integer;
    Bmp: graphics.TBitmap;
    PluginLoader: CPluginLoader;
begin
  Bmp := graphics.TBitmap.Create;
  try
    if Assigned(API) and API.Enabled then Idx:=28 else Idx:=29;
    PluginLoader := CPluginLoader.Create();
    PluginLoader.SetEnabled(Assigned(API) and API.Enabled);
    PluginLoader.Free;
    PluginLoader := nil;
    ilGlobal.GetBitmap(Idx, Bmp);
    Systray.Icon.Assign(Bmp);
    Systray.Show;
  finally
    Bmp.Free;
  end;
end;

//******************************************************************************
// OpenDialog: gиre les messages envoyйs par SC2Config
//******************************************************************************
procedure TMainForm.OpenDialog(var AMsg:TMessage);
var APoint: TPoint;
begin
  case AMsg.WParam of
    OD_CONFIG:
    begin
      miConfig.Click;
    end;
    OD_ABOUT:
    begin
      miAbout.Click;
    end;
    OD_QUIT:
    begin
      miExit.Click;
    end;
    OD_ONOFF:
    begin
      miActivate.Click;
    end;
    OD_SHOWMENU:
    begin
      GetCursorPos(APoint);
      Application.ProcessMessages;
      SetForegroundWindow(Handle);

      pmSystray.PopupComponent := Self;
      pmSystray.Popup(APoint.X, APoint.Y);

      PostMessage(Handle, WM_NULL, 0, 0);
    end;
  end;
end;

end.








































