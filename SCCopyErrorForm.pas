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

unit SCCopyErrorForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  ExtCtrls, SCCopier,SCCommon,
  SCFileNameLabel, ScPopupButton, Menus, SCLocEngine;

type
  TCopyErrorForm = class(TForm)
    imIcon: TImage;
    llCopyErrorText3: TLabel;
    llCopyErrorText1: TLabel;
    llCopyErrorText2: TLabel;
    mmErrorText: TMemo;
    llFileName: TSCFileNameLabel;
    pmRetry: TPopupMenu;
    Retry1: TMenuItem;
    Alwaysretry1: TMenuItem;
    btRetry: TScPopupButton;
    btEndOfList: TScPopupButton;
    pmEndOfList: TPopupMenu;
    pmSkip: TPopupMenu;
    Skip1: TMenuItem;
    Alwaysskip1: TMenuItem;
    btSkip: TScPopupButton;
    btCancel: TScPopupButton;
    Endoflist1: TMenuItem;
    Alwaysputtoendoflist1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btCancelClick(Sender: TObject; ItemIndex: Integer);
    procedure btSkipClick(Sender: TObject; ItemIndex: Integer);
    procedure btEndOfListClick(Sender: TObject; ItemIndex: Integer);
    procedure btRetryClick(Sender: TObject; ItemIndex: Integer);
  private
    { Dйclarations privйes }
    procedure DisableButtons;
  public
    { Dйclarations publiques }
    Action:TCopyErrorAction;
    SameForNext:Boolean;
  end;

var
  CopyErrorForm: TCopyErrorForm;

implementation

{$R *.lfm}

procedure TCopyErrorForm.DisableButtons;
begin
  btCancel.Enabled:=False;
  btSkip.Enabled:=False;
  btRetry.Enabled:=False;
  btEndOfList.Enabled:=False;
end;

procedure TCopyErrorForm.FormCreate(Sender: TObject);
begin
  LocEngine.TranslateForm(Self);

  //HACK: ne pas mettre directement la fenкtre en resizeable pour que
  //      la gestion des grandes polices puisse la redimentionner
  BorderStyle:=bsSizeToolWin;

  // empйcher le resize vertical
  Constraints.MaxHeight:=Height;
  Constraints.MinHeight:=Height;

  Action:=ceaNone;
  SameForNext:=False;
end;

procedure TCopyErrorForm.btCancelClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=ceaCancel;
  DisableButtons;
end;

procedure TCopyErrorForm.btSkipClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=ceaSkip;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCopyErrorForm.btEndOfListClick(Sender: TObject;
  ItemIndex: Integer);
begin
  Action:=ceaEndOfList;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

procedure TCopyErrorForm.btRetryClick(Sender: TObject; ItemIndex: Integer);
begin
  Action:=ceaRetry;
  SameForNext:=ItemIndex=1;
  DisableButtons;
end;

end.
