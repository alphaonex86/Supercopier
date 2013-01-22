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

unit SCAboutForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellApi,SCLocEngine,lclintf;

const
  COSTAB_LENGTH=2048;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    llName: TLabel;
    llStaffTitle: TLabel;
    llStaff1: TLabel;
    llURL: TLabel;
    btOk: TButton;
    llThanksTitle: TLabel;
    llThanks1: TLabel;
    llStaff2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imLogoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btOkClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure llURLClick(Sender: TObject);
  private
    { Dйclarations privйes }
  public
    { Dйclarations publiques }
		//LogoBmp:TBitmap;

		//procedure DrawLogo(Sender:TObject;var Done:Boolean);
  end;

var
  AboutForm: TAboutForm;

	// donnйes pour l'effet
	//CosTab:array[0..COSTAB_LENGTH-1] of Byte;

implementation

{$R *.lfm}

procedure TAboutForm.FormCreate(Sender: TObject);
var i:integer;
begin
  LocEngine.TranslateForm(Self);

	//imLogo.Picture.Bitmap.PixelFormat:=pf32bit;

  // copie de l'image dans une autre
	//LogoBmp:=TBitmap.Create;
	//LogoBmp.Width:=256;
	//LogoBmp.Height:=256;
	//LogoBmp.Canvas.Draw(0,0,imLogo.Picture.Bitmap);
	//LogoBmp.PixelFormat:=pf32bit;

	// on prйcalcule une petite table de cosinus
	//for i:=0 to COSTAB_LENGTH-1 do CosTab[i]:=Round((Cos(i*2*Pi/COSTAB_LENGTH)+1)*255/2);

end;

procedure TAboutForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Release;
  AboutForm:=nil;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
	Application.OnIdle:=nil;
//	LogoBmp.Free;
end;

procedure TAboutForm.imLogoClick(Sender: TObject);
begin
//  Application.OnIdle:=DrawLogo;
end;

procedure TAboutForm.btOkClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.Label1Click(Sender: TObject);
begin

end;

procedure TAboutForm.llURLClick(Sender: TObject);
begin
   OpenDocument(PChar(String(llURL.Caption))); { *Converted from ShellExecute*  }
end;

end.
