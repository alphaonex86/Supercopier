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

unit SCLocEngine;

{$MODE Delphi}

interface
uses
  Windows,Messages,Classes,Forms,Controls,Graphics,
  SCCommon,SCPopupButton,SCWin32,IniFiles, stdctrls, menus, dialogs, buttons;

type
  TLocEngine=class
  private
    LangIni:TMemIniFile;
    Strings:TStringList;

    procedure ReadHeader;
    procedure WriteHeader;
    procedure ReadStrings;
    function GetComponentText(Component:TComponent):WideString;
    procedure SetComponentText(Component:TComponent;Text:WideString);
  public
    IsUTF8:Boolean;
    UIFont:String;

    constructor Create;
    destructor Destroy;override;

    procedure LoadLanguageFile(LangFile:WideString);
    procedure TranslateForm(Form:TForm);
    procedure TranslateString(Id:Integer;var S:WideString);
    procedure AddForm(Form:TForm);
    procedure UpdateFile;
  end;

const
  LANG_SUBDIR:WideString='.\Languages\';
  LANG_EXT:WideString='.lng';
  HEADER_SECTION='-Header-'; // le '-' est interdit dans les noms de form
  STRINGS_SECTION='-Strings-';
  CAPTION_VALUE='-Caption-';
  DEFAULT_LANGUAGE='English (default)';
  TMP_LANGFILE_NAME='SC2Lang.lng';
  DEFAULT_UI_FONT='MS Sans Serif';

var
  LocEngine:TLocEngine=nil;
  
implementation

uses ComCtrls,SysUtils,TypInfo;

constructor TLocEngine.Create;
begin
  LangIni:=nil;
  Strings:=TStringList.Create;
end;

destructor TLocEngine.Destroy;
begin
  Strings.Free;
  LangIni.Free;
end;

procedure TLocEngine.LoadLanguageFile(LangFile:WideString);
var TmpLangFile:String;
begin
  if Assigned(LangIni) then LangIni.Free;

  TmpLangFile:=LangFile;
  if WideString(TmpLangFile)<>LangFile then // le nom de fichier est-il passй 'sans pertes' en ansi?
  begin
    //HACK: TMemIniFile ne supporte pas unicode, je crйe donc une version temporaire
    //      du fichier de langues ne contenant que des caractиres ansi dans le nom
    TmpLangFile:=SCWin32.GetTempPath+TMP_LANGFILE_NAME;
    SCWin32.CopyFile(PWideChar(LangFile),PWideChar(WideString(TmpLangFile)),False);
  end;

  LangIni:=TMemIniFile.Create(TmpLangFile);
  ReadHeader;
  ReadStrings;
end;

procedure TLocEngine.ReadHeader;
begin
  if not Assigned(LangIni) then exit;

  IsUTF8:=LangIni.ReadBool(HEADER_SECTION,'IsUTF8',False);
  UIFont:=LangIni.ReadString(HEADER_SECTION,'UIFont',DEFAULT_UI_FONT);
  dbgln(UIFont);
end;

procedure TLocEngine.WriteHeader;
begin
  if not Assigned(LangIni) then exit;

  LangIni.WriteBool(HEADER_SECTION,'IsUTF8',IsUTF8);
end;

procedure TLocEngine.ReadStrings;
var i:Integer;
    S:String;
begin
  if not Assigned(LangIni) then exit;

  Strings.Clear;
  i:=1;
  while LangIni.ValueExists(STRINGS_SECTION,IntToStr(I)) do
  begin
    S:=LangIni.ReadString(STRINGS_SECTION,IntToStr(I),'');
    S:=StringReplace(S,'|',#13#10,[rfReplaceAll]);
    if IsUTF8 then
      Strings.Add(UTF8Decode(S))
    else
      Strings.Add(S);

    Inc(i);
  end;
end;

procedure TLocEngine.TranslateForm(Form:TForm);
var i:Integer;
    Name,Text:WideString;
    FormName:WideString;
begin
  if not Assigned(LangIni) then exit;

  FormName:=Form.ClassName;
  // rйtrocompat anciens fichiers de langage
  if not LangIni.SectionExists(FormName) and (Length(FormName)>0) and (FormName[1]='T') then
    FormName:=Copy(FormName,2,Maxint);

  if IsUTF8 then
    Form.Caption:=UTF8Decode(LangIni.ReadString(FormName,CAPTION_VALUE,Form.Caption))
  else
    Form.Caption:=LangIni.ReadString(FormName,CAPTION_VALUE,Form.Caption);

  Form.Font.Name:=UIFont;

  for i:=0 to Form.ComponentCount-1 do
  begin
    Name:=Form.Components[i].Name;
    Text:=LangIni.ReadString(FormName,Form.Components[i].Name,'');
    if Text<>'' then
    begin
      if IsUTF8 then
        SetComponentText(Form.Components[i],UTF8Decode(Text))
      else
        SetComponentText(Form.Components[i],Text);
    end;
  end;
end;

procedure TLocEngine.AddForm(Form:TForm);
var i:Integer;
    Name,Text:WideString;
    StrText:String;
begin
  if not Assigned(LangIni) then exit;

  if IsUTF8 then
    LangIni.WriteString(Form.ClassName,CAPTION_VALUE,UTF8Encode(Form.Caption))
  else
    LangIni.WriteString(Form.ClassName,CAPTION_VALUE,Form.Caption);

  for i:=0 to Form.ComponentCount-1 do
  begin
    Name:=Form.Components[i].Name;
    Text:=GetComponentText(Form.Components[i]);
    if Text<>'' then
    begin
      if IsUTF8 then
        StrText:=UTF8Encode(Text)
      else
        StrText:=Text;                                 

      LangIni.WriteString(Form.ClassName,Name,StrText);
    end;
  end;
end;

procedure TLocEngine.UpdateFile;
begin
  if not Assigned(LangIni) then exit;

  WriteHeader;
  LangIni.UpdateFile;
end;

procedure TLocEngine.TranslateString(Id:Integer;var S:WideString);
begin
  if Id<=Strings.Count then S:=Strings[Id-1];
end;

function TLocEngine.GetComponentText(Component:TComponent):WideString;
  function Get_Button:WideString;
  begin
    Result:=(Component as TButton).Caption;
  end;

  function Get_Label:WideString;
  begin
    Result:=(Component as TLabel).Caption;
  end;

  function Get_Edit:WideString;
  begin
    Result:=(Component as TEdit).Text;
  end;

  function Get_ComboBox:WideString;
  begin
    Result:=(Component as TComboBox).Items.CommaText;
  end;

  function Get_CheckBox:WideString;
  begin
    Result:=(Component as TCheckBox).Caption;
  end;

  function Get_ListView:WideString;
  var i:Integer;
      SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      with (Component as TListView) do
      begin
        SL.Clear;

        // colonnes
        for i:=0 to Columns.Count-1 do
          SL.Add(Columns[i].Caption);

        // items
        for i:=0 to Items.Count-1 do
          SL.Add(Items[i].Caption);

        Result:=SL.CommaText;
      end;
    finally
      SL.Free;
    end;
  end;

  function Get_GroupBox:WideString;
  begin
    Result:=(Component as TGroupBox).Caption;
  end;

  function Get_TabSheet:WideString;
  begin
    Result:=(Component as TTabSheet).Caption;
  end;

  function Get_MenuItem:WideString;
  begin
    Result:=(Component as TMenuItem).Caption;
  end;

  function Get_OpenDialog:WideString;
  begin
    Result:=(Component as TOpenDialog).Filter;
  end;

  function Get_SpeedButton:WideString;
  var SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      SL.Add((Component as TSpeedButton).Caption);
      SL.Add((Component as TSpeedButton).Hint);
      Result:=SL.CommaText;
    finally
      SL.Free;
    end;
  end;

  function Get_SCPopupButton:WideString;
  var SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      SL.Add((Component as TScPopupButton).Caption);
      SL.Add((Component as TScPopupButton).Hint);
      Result:=SL.CommaText;
    finally
      SL.Free;
    end;
  end;

  function Get_RadioButton:WideString;
  begin
    Result:=(Component as TRadioButton).Caption;
  end;

begin
  Result:='';
  if Component is TButton then
    Result:=Get_Button
  else if Component is TLabel then
    Result:=Get_Label
  else if Component is TEdit then
    Result:=Get_Edit
  else if Component is TComboBox then
    Result:=Get_ComboBox
  else if Component is TCheckBox then
    Result:=Get_CheckBox
  else if Component is TListView then
    Result:=Get_ListView
  else if Component is TGroupBox then
    Result:=Get_GroupBox
  else if Component is TTabSheet then
    Result:=Get_TabSheet
  else if Component is TMenuItem then
    Result:=Get_MenuItem
  else if Component is TOpenDialog then
    Result:=Get_OpenDialog
  else if Component is TSpeedButton then
    Result:=Get_SpeedButton
  else if Component is TScPopupButton then
    Result:=Get_SCPopupButton
  else if Component is TRadioButton then
    Result:=Get_RadioButton;
end;

procedure TLocEngine.SetComponentText(Component:TComponent;Text:WideString);
  procedure Set_Button;
  begin
    (Component as TButton).Caption:=Text;
  end;

  procedure Set_Label;
  begin
    (Component as TLabel).Caption:=Text;
  end;

  procedure Set_Edit;
  begin
    (Component as TEdit).Text:=Text;
  end;

  procedure Set_ComboBox;
  var Idx:Integer;
  begin
    Idx:=(Component as TComboBox).ItemIndex;
    (Component as TComboBox).Items.CommaText:=Text;
    if Idx<(Component as TComboBox).Items.Count then
      (Component as TComboBox).ItemIndex:=Idx;
  end;

  procedure Set_CheckBox;
  begin
    (Component as TCheckBox).Caption:=Text;
  end;

  procedure Set_ListView;
  var i:Integer;
      SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      with (Component as TListView) do
      begin
        SL.CommaText:=Text;

        Items.BeginUpdate;

        // colonnes
        for i:=0 to Columns.Count-1 do
          Columns[i].Caption:=SL[i];

        // items
        for i:=0 to Items.Count-1 do
          Items[i].Caption:=SL[i+Columns.Count];

        Items.EndUpdate;
      end;
    finally
      SL.Free;
    end;
  end;

  procedure Set_GroupBox;
  begin
    (Component as TGroupBox).Caption:=Text;
  end;

  procedure Set_TabSheet;
  begin
    (Component as TTabSheet).Caption:=Text;
  end;

  procedure Set_MenuItem;
  begin
    (Component as TMenuItem).Caption:=Text;
  end;

  procedure Set_OpenDialog;
  begin
    (Component as TOpenDialog).Filter:=Text;
  end;

  procedure Set_SpeedButton;
  var SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      SL.CommaText:=Text;
      (Component as TSpeedButton).Caption:=SL[0];
      (Component as TSpeedButton).Hint:=SL[1];
    finally
      SL.Free;
    end;
  end;

  procedure Set_SCPopupButton;
  var SL:TStringList;
  begin
    SL:=TStringList.Create;
    try
      SL.CommaText:=Text;
      (Component as TScPopupButton).Caption:=SL[0];
      (Component as TScPopupButton).Hint:=SL[1];
    finally
      SL.Free;
    end;
  end;

  procedure Set_RadioButton;
  begin
    (Component as TRadioButton).Caption:=Text;
  end;

begin
  if Component is TButton then
    Set_Button
  else if Component is TLabel then
    Set_Label
  else if Component is TEdit then
    Set_Edit
  else if Component is TComboBox then
    Set_ComboBox
  else if Component is TCheckBox then
    Set_CheckBox
  else if Component is TListView then
    Set_ListView
  else if Component is TGroupBox then
    Set_GroupBox
  else if Component is TTabSheet then
    Set_TabSheet
  else if Component is TMenuItem then
    Set_MenuItem
  else if Component is TOpenDialog then
    Set_OpenDialog
  else if Component is TSpeedButton then
    Set_SpeedButton
  else if Component is TScPopupButton then
    Set_SCPopupButton
  else if Component is TRadioButton then
    Set_RadioButton;
end;

end.
