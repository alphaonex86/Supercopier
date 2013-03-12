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

unit SCConfigForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,  ComCtrls,  StdCtrls,
    SCProgessBar,SCLocEngine, ScTrackBar;

type

  { TConfigForm }

  TConfigForm = class(TForm)
    lvSections: TListView;
    pcSections: TPageControl;
    tsStartup: TTabSheet;
    tsCWDefaults: TTabSheet;
    tsAdvanced: TTabSheet;
    btCancel: TButton;
    btOk: TButton;
    tsUI: TTabSheet;
    tsLog: TTabSheet;
    tsCopy: TTabSheet;
    gbCopyEnd: TGroupBox;
    llCopyEnd: TLabel;
    cbCopyEnd: TComboBox;
    gbSpeedLimit: TGroupBox;
    gbCollisions: TGroupBox;
    llCollisions: TLabel;
    cbCollisions: TComboBox;
    gbCopyErrors: TGroupBox;
    llCopyErrors: TLabel;
    cbCopyError: TComboBox;
    gbStartup: TGroupBox;
    chStartWithWindows: TCheckBox;
    chActivateOnStart: TCheckBox;
    gbTaskbar: TGroupBox;
    chTrayIcon: TCheckBox;
    gbCWAppearance: TGroupBox;
    chCWSavePosition: TCheckBox;
    chCWSaveSize: TCheckBox;
    chCWStartMinimized: TCheckBox;
    gbSizeUnit: TGroupBox;
    llSizeUnit: TLabel;
    cbSizeUnit: TComboBox;
    gbCLHandling: TGroupBox;
    llCLHandling: TLabel;
    cbCLHandling: TComboBox;
    chCLHandlingConfirm: TCheckBox;
    llCLHandlingInfo: TLabel;
    gbAttributes: TGroupBox;
    chSaveAttributesOnCopy: TCheckBox;
    chSaveAttributesOnMove: TCheckBox;
    gbDeleting: TGroupBox;
    chDeleteUnfinishedCopies: TCheckBox;
    chDontDeleteOnCopyError: TCheckBox;
    gbRenaming: TGroupBox;
    llRenameOld: TLabel;
    llRenameNew: TLabel;
    edRenameOldPattern: TEdit;
    edRenameNewPattern: TEdit;
    gbErrorLog: TGroupBox;
    llErrorLogAutoSaveMode: TLabel;
    cbErrorLogAutoSaveMode: TComboBox;
    chErrorLogAutoSave: TCheckBox;
    edErrorLogFileName: TEdit;
    btELFNBrowse: TButton;
    llErrorLogFileName: TLabel;
    llRetryInterval: TLabel;
    edCopyErrorRetry: TEdit;
    llRetryIntervalUnit: TLabel;
    gbPriority: TGroupBox;
    llPriority: TLabel;
    cbPriority: TComboBox;
    gbAdvanced: TGroupBox;
    llCopyBufferSize: TLabel;
    edCopyBufferSize: TEdit;
    llCopyBufferSizeUnit: TLabel;
    llCopyWindowUpdateInterval: TLabel;
    edCopyWindowUpdateInterval: TEdit;
    llCopyWindowUpdateIntervalUnit: TLabel;
    llCopySpeedAveragingInterval: TLabel;
    edCopySpeedAveragingInterval: TEdit;
    llCopySpeedAveragingIntervalUnit: TLabel;
    llCopyThrottleInterval: TLabel;
    edCopyThrottleInterval: TEdit;
    llCopyThrottleIntervalUnit: TLabel;
    chFastFreeSpaceCheck: TCheckBox;
    gbProgressrar: TGroupBox;
    btProgressFG1: TButton;
    bgProgressFG2: TButton;
    btProgressBG1: TButton;
    btProgressBG2: TButton;
    llProgressFG: TLabel;
    llProgressBG: TLabel;
    cbMinimize: TComboBox;
    //gbConfigLocation: TGroupBox;
    //llConfigLocation: TLabel;
    //cbConfigLocation: TComboBox;
    odLog: TOpenDialog;
    odProcesses: TOpenDialog;
    llProgressBorder: TLabel;
    ggProgress: TSCProgessBar;
    cdProgress: TColorDialog;
    btRenamingHelp: TButton;
    btAdvancedHelp: TButton;
    llMinimizedEventHandling: TLabel;
    cbMinimizedEventHandling: TComboBox;
    btApply: TButton;
    btProgressBorder: TButton;
    btProgressOutline: TButton;
    btProgressText: TButton;
    llProgressText: TLabel;
    tsLanguage: TTabSheet;
    gbLanguage: TGroupBox;
    llLanguage: TLabel;
    cbLanguage: TComboBox;
    llLanguageInfo: TLabel;
    chCopyResumeNoAgeVerification: TCheckBox;
    llAttributesAndSecurityForCopies: TLabel;
    llAttributesAndSecurityForMoves: TLabel;
    chSaveSecurityOnCopy: TCheckBox;
    chSaveSecurityOnMove: TCheckBox;
    llCustomSpeedLimit: TLabel;
    chSpeedLimit: TCheckBox;
    tbSpeedLimit: TScTrackBar;
    edCustomSpeedLimit: TEdit;
    llSpeedLimit: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvSectionsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure chSpeedLimitClick(Sender: TObject);
    procedure chDeleteUnfinishedCopiesClick(Sender: TObject);
    procedure chErrorLogAutoSaveClick(Sender: TObject);
    procedure cbErrorLogAutoSaveModeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btRenamingHelpClick(Sender: TObject);
    procedure btELFNBrowseClick(Sender: TObject);
    procedure NumbersOnly(Sender: TObject; var Key: Char);
    procedure FileNameOnly(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure btProgressFG1Click(Sender: TObject);
    procedure bgProgressFG2Click(Sender: TObject);
    procedure btProgressBG1Click(Sender: TObject);
    procedure btProgressBG2Click(Sender: TObject);
    procedure btProgressBorderClick(Sender: TObject);
    procedure btAdvancedHelpClick(Sender: TObject);
    procedure cbMinimizeClick(Sender: TObject);
    procedure btApplyClick(Sender: TObject);
    procedure btProgressTextClick(Sender: TObject);
    procedure btProgressOutlineClick(Sender: TObject);
    procedure pcSectionsChange(Sender: TObject);
    procedure tbSpeedLimitChange(Sender: TObject);
  private
    { Private declarations }

    procedure UpdateControlsState;
    procedure GetConfig;
    procedure UpdateConfig;
  public
    { Public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.lfm}

uses SCConfig,SCWin32,SCLocStrings, Math, SCCommon, SCMainForm,
  StrUtils;

//******************************************************************************
// UpdateControlsState : fixe l'йtat d'activation des controles
//******************************************************************************
procedure TConfigForm.UpdateControlsState;
var IsCustom:Boolean;
begin
  tbSpeedLimit.Enabled:=chSpeedLimit.Checked;
  edCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llCustomSpeedLimit.Enabled:=chSpeedLimit.Checked;
  llSpeedLimit.Enabled:=chSpeedLimit.Checked;

  IsCustom:=tbSpeedLimit.Position=0;
  edCustomSpeedLimit.Visible:=IsCustom;
  llCustomSpeedLimit.Visible:=IsCustom;
  llSpeedLimit.Visible:=not IsCustom;
  if not IsCustom then llSpeedLimit.Caption:=SizeToString(IndexToSpeedLimit(tbSpeedLimit.Position)*1024);

  chDontDeleteOnCopyError.Enabled:=chDeleteUnfinishedCopies.Checked;
  cbErrorLogAutoSaveMode.Enabled:=chErrorLogAutoSave.Checked;
  edErrorLogFileName.Enabled:=chErrorLogAutoSave.Checked;
  btELFNBrowse.Enabled:=chErrorLogAutoSave.Checked and (cbErrorLogAutoSaveMode.ItemIndex=2);
  //btRemoveProcess.Enabled:=lvHandledProcesses.Items.Count>0;
end;

//******************************************************************************
// GetConfig : charge la configuration dans la fenкtre
//******************************************************************************
procedure TConfigForm.GetConfig;
var i:Integer;
    ProcList:TStringList;
    FindData:TWin32FindDataW;
    FindHandle:THandle;
    FileName:WideString;
begin
  with Config.Values do
  begin
    //tsLanguage
    cbLanguage.Items.Add(DEFAULT_LANGUAGE);
    FindHandle:=SCWin32.FindFirstFile(PWideChar(ExtractFilePath(Application.ExeName)+LANG_SUBDIR+'*.lng'),FindData);
    if FindHandle<>INVALID_HANDLE_VALUE then
    begin
      repeat
        if (WideString(FindData.cFileName)<>'.') and (WideString(FindData.cFileName)<>'..') then
        begin
          FileName:=FindData.cFileName;
          FileName:=LeftStr(FileName,Pos('.',FileName)-1);
          cbLanguage.Items.Add(FileName);
        end;
      until not SCWin32.FindNextFile(FindHandle,FindData);

      Windows.FindClose(FindHandle);
    end;
    cbLanguage.ItemIndex:=cbLanguage.Items.IndexOf(Language);
    if cbLanguage.ItemIndex=-1 then cbLanguage.ItemIndex:=0;
    //tsStartup
    chStartWithWindows.Checked:=StartWithWindows;
    chActivateOnStart.Checked:=ActivateOnStart;
    //tsUI
    chTrayIcon.Checked:=TrayIcon;
    cbMinimize.ItemIndex:=IfThen(MinimizeToTray,0,1);
    cbMinimizedEventHandling.ItemIndex:=Integer(MinimizedEventHandling);
    chCWStartMinimized.Checked:=CopyWindowStartMinimized;
    chCWSaveSize.Checked:=CopyWindowSaveSize;
    chCWSavePosition.Checked:=CopyWindowSavePosition;
    cbSizeUnit.ItemIndex:=Integer(SizeUnit);
    ggProgress.BackColor1:=ProgressBackgroundColor1;
    ggProgress.BackColor2:=ProgressBackgroundColor2;
    ggProgress.FrontColor1:=ProgressForegroundColor1;
    ggProgress.FrontColor2:=ProgressForegroundColor2;
    ggProgress.BorderColor:=ProgressBorderColor;
    ggProgress.FontTxt.Color:=ProgressTextColor;
    ggProgress.FontProgress.Color:=ProgressTextColor;
    ggProgress.FontProgressColor:=ProgressOutlineColor;
    ggProgress.FontTxtColor:=ProgressOutlineColor;
    //tsCWDefaults
    with DefaultCopyWindowConfig do
    begin
      cbCopyEnd.ItemIndex:=Integer(CopyEndAction);
      chSpeedLimit.Checked:=ThrottleEnabled;
      edCustomSpeedLimit.Text:=IntToStr(ThrottleSpeedLimit);
      tbSpeedLimit.Position:=SpeedLimitToIndex(ThrottleSpeedLimit);
      cbCollisions.ItemIndex:=Integer(CollisionAction);
      cbCopyError.ItemIndex:=Integer(CopyErrorAction);
    end;
    edCopyErrorRetry.Text:=IntToStr(CopyErrorRetryInterval);
    //tsCopy
    cbCLHandling.ItemIndex:=Integer(CopyListHandlingMode);
    chCLHandlingConfirm.Checked:=CopyListHandlingConfirm;
    chSaveAttributesOnCopy.Checked:=SaveAttributesOnCopy;
    chSaveSecurityOnCopy.Checked:=SaveSecurityOnCopy;
    chSaveAttributesOnMove.Checked:=SaveAttributesOnMove;
    chSaveSecurityOnMove.Checked:=SaveSecurityOnMove;
    chDeleteUnfinishedCopies.Checked:=DeleteUnfinishedCopies;
    chDontDeleteOnCopyError.Checked:=DontDeleteOnCopyError;
    edRenameOldPattern.Text:=RenameOldPattern;
    edRenameNewPattern.Text:=RenameNewPattern;
    //tsLog
    chErrorLogAutoSave.Checked:=ErrorLogAutoSave;
    cbErrorLogAutoSaveMode.ItemIndex:=Integer(ErrorLogAutoSaveMode);
    edErrorLogFileName.Text:=ErrorLogFileName;
    //tsAdvanced
    case Priority of
      IDLE_PRIORITY_CLASS: cbPriority.ItemIndex:=0;
      NORMAL_PRIORITY_CLASS: cbPriority.ItemIndex:=1;
      HIGH_PRIORITY_CLASS: cbPriority.ItemIndex:=2;
    end;
//    cbConfigLocation.ItemIndex:=Integer(ConfigLocation);
    edCopyBufferSize.Text:=IntToStr(CopyBufferSize);
    edCopyWindowUpdateInterval.Text:=IntToStr(CopyWindowUpdateInterval);
    edCopySpeedAveragingInterval.Text:=IntToStr(CopySpeedAveragingInterval);
    edCopyThrottleInterval.Text:=IntToStr(CopyThrottleInterval);
    chFastFreeSpaceCheck.Checked:=FastFreeSpaceCheck;
    chCopyResumeNoAgeVerification.Checked:=CopyResumeNoAgeVerification;
  end;
end;

//******************************************************************************
// UpdateConfig : mets а jour la configuration
//******************************************************************************
procedure TConfigForm.UpdateConfig;
var i:Integer;
begin
  with Config.Values do
  begin
    //tsLanguage
    Language:=cbLanguage.Text;
    //tsStartup
    StartWithWindows:=chStartWithWindows.Checked;
    ActivateOnStart:=chActivateOnStart.Checked;
    //tsUI
    TrayIcon:=chTrayIcon.Checked;
    MinimizeToTray:=cbMinimize.ItemIndex=0;
    MinimizedEventHandling:=TMinimizedEventHandling(cbMinimizedEventHandling.ItemIndex);
    CopyWindowStartMinimized:=chCWStartMinimized.Checked;
    CopyWindowSaveSize:=chCWSaveSize.Checked;
    CopyWindowSavePosition:=chCWSavePosition.Checked;
    SizeUnit:=TSizeUnit(cbSizeUnit.ItemIndex);
    ProgressBackgroundColor1:=ggProgress.BackColor1;
    ProgressBackgroundColor2:=ggProgress.BackColor2;
    ProgressForegroundColor1:=ggProgress.FrontColor1;
    ProgressForegroundColor2:=ggProgress.FrontColor2;
    ProgressBorderColor:=ggProgress.BorderColor;
    ProgressTextColor:=ggProgress.FontTxt.Color;
    ProgressOutlineColor:=ggProgress.FontTxtColor;
    //tsCWDefaults
    with DefaultCopyWindowConfig do
    begin
      CopyEndAction:=TCopyWindowCopyEndAction(cbCopyEnd.ItemIndex);
      ThrottleEnabled:=chSpeedLimit.Checked;

      if tbSpeedLimit.Position=0 then
        ThrottleSpeedLimit:=StrToIntDef(edCustomSpeedLimit.Text,CONFIG_DEFAULT_VALUES.DefaultCopyWindowConfig.ThrottleSpeedLimit)
      else
        ThrottleSpeedLimit:=IndexToSpeedLimit(tbSpeedLimit.Position);

      CollisionAction:=TCollisionAction(cbCollisions.ItemIndex);
      CopyErrorAction:=TCopyErrorAction(cbCopyError.ItemIndex);
    end;
    CopyErrorRetryInterval:=StrToIntDef(edCopyErrorRetry.Text,CONFIG_DEFAULT_VALUES.CopyErrorRetryInterval);
    //tsCopy
    CopyListHandlingMode:=TCopyListHandlingMode(cbCLHandling.ItemIndex);
    CopyListHandlingConfirm:=chCLHandlingConfirm.Checked;
    SaveAttributesOnCopy:=chSaveAttributesOnCopy.Checked;
    SaveSecurityOnCopy:=chSaveSecurityOnCopy.Checked;
    SaveAttributesOnMove:=chSaveAttributesOnMove.Checked;
    SaveSecurityOnMove:=chSaveSecurityOnMove.Checked;
    DeleteUnfinishedCopies:=chDeleteUnfinishedCopies.Checked;
    DontDeleteOnCopyError:=chDontDeleteOnCopyError.Checked;
    RenameOldPattern:=edRenameOldPattern.Text;
    RenameNewPattern:=edRenameNewPattern.Text;
    //tsLog
    ErrorLogAutoSave:=chErrorLogAutoSave.Checked;
    ErrorLogAutoSaveMode:=TErrorLogAutoSaveMode(cbErrorLogAutoSaveMode.ItemIndex);
    ErrorLogFileName:=edErrorLogFileName.Text;
    //tsAdvanced
    case cbPriority.ItemIndex of
      0: Priority:=IDLE_PRIORITY_CLASS;
      1: Priority:=NORMAL_PRIORITY_CLASS;
      2: Priority:=HIGH_PRIORITY_CLASS;
    end;
//    ConfigLocation:=TConfigLocation(cbConfigLocation.ItemIndex);
    CopyBufferSize:=StrToIntDef(edCopyBufferSize.Text,CONFIG_DEFAULT_VALUES.CopyBufferSize);
    CopyWindowUpdateInterval:=StrToIntDef(edCopyWindowUpdateInterval.Text,CONFIG_DEFAULT_VALUES.CopyWindowUpdateInterval);
    CopySpeedAveragingInterval:=StrToIntDef(edCopySpeedAveragingInterval.Text,CONFIG_DEFAULT_VALUES.CopySpeedAveragingInterval);
    CopyThrottleInterval:=StrToIntDef(edCopyThrottleInterval.Text,CONFIG_DEFAULT_VALUES.CopyThrottleInterval);
    FastFreeSpaceCheck:=chFastFreeSpaceCheck.Checked;
    CopyResumeNoAgeVerification:=chCopyResumeNoAgeVerification.Checked;
  end;
end;

procedure TConfigForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  lvSections.OnChange:=nil; //HACK: empиche l'erreur Win32 #87 de se dйclencher sur Windows 7
  CanClose:=False;
  Hide;
  Release;
  ConfigForm:=nil;
end;

procedure TConfigForm.lvSectionsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  pcSections.ActivePageIndex:=Item.Index;
end;

procedure TConfigForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TConfigForm.btOkClick(Sender: TObject);
begin
  btApply.Click;
  Close;
end;

procedure TConfigForm.btApplyClick(Sender: TObject);
begin
  UpdateConfig;
  CloseConfig;
  OpenConfig;
  ApplyConfig;
  lvSectionsChange(nil,lvSections.ItemFocused,ctState); // la localisation change la page active
  ggProgress.TimeRemaining:=WideFormat(lsRemaining,['00:00:00']);
end;

procedure TConfigForm.chSpeedLimitClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.tbSpeedLimitChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.chDeleteUnfinishedCopiesClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.chErrorLogAutoSaveClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.cbErrorLogAutoSaveModeChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.cbMinimizeClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  GetConfig;
  UpdateControlsState;

  LocEngine.TranslateForm(Self);

  ggProgress.TimeRemaining:=WideFormat(lsRemaining,['00:00:00']);
end;

procedure TConfigForm.btRenamingHelpClick(Sender: TObject);
begin
  MessageBox(Handle,lsRenamingHelpText,lsRenamingHelpCaption,0);
end;

procedure TConfigForm.btELFNBrowseClick(Sender: TObject);
begin
  FixParentBugs;

  if odLog.Execute then
  begin
    edErrorLogFileName.Text:=odLog.FileName;
  end;
end;

procedure TConfigForm.NumbersOnly(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) and (Key>#31) then Key:=#0; // autoriser seulement les chiffres et les caractиres de contrфle
end;

procedure TConfigForm.FileNameOnly(Sender: TObject; var Key: Char);
begin
  if Key in ['/','?','*','"','<','>','|'] then Key:=#0; //caractиres interdits dans un nom de fichier
end;

procedure TConfigForm.FormShow(Sender: TObject);
begin
  lvSections.Items[0].Focused:=True;
  lvSections.Items[0].Selected:=True;
end;

procedure TConfigForm.btProgressFG1Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FrontColor1;
  if cdProgress.Execute then ggProgress.FrontColor1:=cdProgress.Color;
end;

procedure TConfigForm.bgProgressFG2Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FrontColor2;
  if cdProgress.Execute then ggProgress.FrontColor2:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBG1Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BackColor1;
  if cdProgress.Execute then ggProgress.BackColor1:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBG2Click(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BackColor2;
  if cdProgress.Execute then ggProgress.BackColor2:=cdProgress.Color;
end;

procedure TConfigForm.btProgressBorderClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.BorderColor;
  if cdProgress.Execute then ggProgress.BorderColor:=cdProgress.Color;
end;

procedure TConfigForm.btAdvancedHelpClick(Sender: TObject);
begin
  MessageBox(Handle,lsAdvancedHelpText,lsAdvancedHelpCaption,0);
end;

procedure TConfigForm.btProgressTextClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FontTxt.Color;
  if cdProgress.Execute then
  begin
    ggProgress.FontTxt.Color:=cdProgress.Color;
    ggProgress.FontProgress.Color:=cdProgress.Color;
    ggProgress.Refresh;
  end;
end;

procedure TConfigForm.btProgressOutlineClick(Sender: TObject);
begin
  FixParentBugs;

  cdProgress.Color:=ggProgress.FontTxtColor;
  if cdProgress.Execute then
  begin
    ggProgress.FontTxtColor:=cdProgress.Color;
    ggProgress.FontProgressColor:=cdProgress.Color;
    ggProgress.Refresh;
  end;
end;

procedure TConfigForm.pcSectionsChange(Sender: TObject);
begin

end;

end.
