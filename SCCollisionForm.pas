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

unit SCCollisionForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  ExtCtrls, SCCopier,SCCommon,
  SCFileNameLabel, Menus,  ScPopupButton,SCLocEngine;

type
  TCollisionForm = class(TForm)
    imIcon: TImage;
    llCollisionText1: TLabel;
    llSourceTitle: TLabel;
    llDestiationTitle: TLabel;
    llCollisionText2: TLabel;
    llSourceData: TLabel;
    llDestinationData: TLabel;
    llFileName: TSCFileNameLabel;
    btCancel: TScPopupButton;
    btSkip: TScPopupButton;
    btOverwrite: TScPopupButton;
    btResume: TScPopupButton;
    btRename: TScPopupButton;
    pmSkip: TPopupMenu;
    pmResume: TPopupMenu;
    pmOverwrite: TPopupMenu;
    pmRename: TPopupMenu;
    Skip1: TMenuItem;
    Alwaysskip1: TMenuItem;
    Resume1: TMenuItem;
    Alwaysresume1: TMenuItem;
    Overwrite1: TMenuItem;
    Overwtiteisdifferent1: TMenuItem;
    Alwaysoverwrite1: TMenuItem;
    Alwaysoverwriteifdifferent1: TMenuItem;
    Rename1: TMenuItem;
    Renameoldfile1: TMenuItem;
    Customrename1: TMenuItem;
    Alwaysrename1: TMenuItem;
    Alwaysrenameoldfile1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btSkipClick(Sender: TObject; ItemIndex: Integer);
    procedure btResumeClick(Sender: TObject; ItemIndex: Integer);
    procedure btOverwriteClick(Sender: TObject; ItemIndex: Integer);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btRenameClick(Sender: TObject; ItemIndex: Integer);
  private
    { Dйclarations privйes }
    procedure DisableButtons;
  public
    { Dйclarations publiques }
    Action:TCollisionAction;
    SameForNext:Boolean;
    FileName:WideString;
    CustomRename:Boolean;
  end;

var
  CollisionForm: TCollisionForm;

implementation

{$R *.lfm}

uses SCCollisionRenameForm, DateUtils,SCMainForm;

procedure TCollisionForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btOverwrite.Enabled:=False;
  btResume.Enabled:=False;
  btSkip.Enabled:=False;
  btRename.Enabled:=False;
end;

procedure TCollisionForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);

  //HACK: ne pas mettre directement la fenкtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeToolWin;

  // empйcher le resize vertical
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;

  Action:=claNone;
  SameForNext:=False;
  FileName:='';
  CustomRename:=False;
end;

procedure TCollisionForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=False;
  Action:=claCancel;
  DisableButtons;
end;

procedure TCollisionForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=claCancel;
  DisableButtons;
end;

procedure TCollisionForm.btSkipClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=claSkip;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCollisionForm.btResumeClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=claResume;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCollisionForm.btOverwriteClick(Sender: TObject;
  ItemIndex: Integer);
begin
  case ItemIndex of
    0:
    begin
      Action:=claOverwrite;
      SameForNext:=False;
    end;
    1:
    begin
      Action:=claOverwriteIfDifferent;
      SameForNext:=False;
    end;
    2:
    begin
      Action:=claOverwrite;
      SameForNext:=True;
    end;
    3:
    begin
      Action:=claOverwriteIfDifferent;
      SameForNext:=True;
    end;
  end;
  DisableButtons;
end;

procedure TCollisionForm.btRenameClick(Sender: TObject;
  ItemIndex: Integer);
  procedure DoCustomRename;
  begin
    try
      CollisionRenameForm:=TCollisionRenameForm.Create(Self);

      with CollisionRenameForm do
      begin
        llOriginalName.Caption:=FileName;
        edNewName.Text:=FileName;

        CollisionRenameForm.ShowModal;
        if CollisionRenameForm.ModalResult=mrOk then
        begin
          CustomRename:=True;

          FileName:=edNewName.Text;

          if rbRenameNew.Checked then
            Self.Action:=claRenameNew
          else
            Self.Action:=claRenameOld;

        end;
      end;
    finally
      CollisionRenameForm.Free;
    end;
  end;
begin
  case ItemIndex of
    0:
    begin
      Action:=claRenameNew;
      SameForNext:=False;
    end;
    1:
    begin
      Action:=claRenameOld;
      SameForNext:=False;
    end;
    2:
    begin
      DoCustomRename;
    end;
    3:
    begin
      Action:=claRenameNew;
      SameForNext:=True;
    end;
    4:
    begin
      Action:=claRenameOld;
      SameForNext:=True;
    end;
  end;
  if ItemIndex<>2 then DisableButtons;
end;

end.
