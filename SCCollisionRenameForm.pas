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

unit SCCollisionRenameForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  ScPopupButton,SCLocEngine;

type
  TCollisionRenameForm = class(TForm)
    rbRenameNew: TRadioButton;
    rbRenameOld: TRadioButton;
    llOriginalNameTitle: TLabel;
    llOriginalName: TLabel;
    llNewNameTitle: TLabel;
    edNewName: TEdit;
    btCancel: TScPopupButton;
    btRename: TScPopupButton;
    procedure edNewNameKeyPress(Sender: TObject; var Key: Char);
    procedure edNewNameChange(Sender: TObject);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btRenameClick(Sender: TObject; ItemIndex: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Dйclarations privйes }
  public
    { Dйclarations publiques }
  end;

var
  CollisionRenameForm: TCollisionRenameForm;

implementation

{$R *.lfm}

uses SCCommon,SCLocStrings,SCWin32;

procedure TCollisionRenameForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);
end;

procedure TCollisionRenameForm.edNewNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in ['\','/',':','?','*','"','<','>','|'] then Key:=#0; //caractиres interdits dans un nom de fichier
end;

procedure TCollisionRenameForm.edNewNameChange(Sender: TObject);
begin
  btRename.Enabled:=TrimRight(edNewName.Text)<>llOriginalName.Caption;
end;

procedure TCollisionRenameForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  ModalResult:=mrCancel;
end;

procedure TCollisionRenameForm.btRenameClick(Sender: TObject;
  ItemIndex: Integer);
begin
  ModalResult:=mrOk;
end;

end.
