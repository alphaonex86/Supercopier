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

unit SCFileNameLabel;

interface

uses
  Windows,SysUtils, Classes, Controls, StdCtrls;

type
  TSCFileNameLabel = class(TLabel)
  private
    { Déclarations privées }
    FMinimizedName:String;
    procedure UpdateMinimizedName;
  protected
    { Déclarations protégées }
    function  GetLabelText: string; override;
    function GetCaption:String;
    procedure SetCaption(Value:String);
    procedure Resize;override;
  public
    { Déclarations publiques }
  published
    { Déclarations publiées }
    property Caption: String read GetCaption write SetCaption; // le Setter du compo TNT est en private, donc je redéclare la prop Caption
  end;

procedure Register;

implementation

uses StrUtils;

procedure Register;
begin
  RegisterComponents('SC Team', [TSCFileNameLabel]);
end;

procedure TSCFileNameLabel.UpdateMinimizedName;
  procedure CutFirstDirectory(var S: WideString);
  var
    Root: Boolean;
    P: Integer;
  begin
    if S = '\' then
      S := ''
    else
    begin
      if S[1] = '\' then
      begin
        Root := True;
        Delete(S, 1, 1);
      end
      else
        Root := False;
      if S[1] = '.' then
        Delete(S, 1, 4);
      P := Pos('\',S);
      if P <> 0 then
      begin
        Delete(S, 1, P);
        S := '...\' + S;
      end
      else
        S := '';
      if Root then
        S := '\' + S;
    end;
  end;

var
  Drive: WideString;
  Dir: WideString;
  Name: WideString;
begin
  FMinimizedName := Caption;
  Dir := ExtractFilePath(FMinimizedName);
  Name := ExtractFileName(FMinimizedName);

  if (Length(Dir) >= 2) and (Dir[2] = ':') then
  begin
    Drive := Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive := '';
  while ((Dir <> '') or (Drive <> '')) and (Canvas.TextWidth(FMinimizedName) > Width) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then
      Drive := ''
    else
      CutFirstDirectory(Dir);
    FMinimizedName := Drive + Dir + Name;
  end;
end;

function TSCFileNameLabel.GetCaption:String;
begin
  Result:=inherited Caption;
end;

procedure TSCFileNameLabel.SetCaption(Value:String);
begin
  inherited Caption:=Value;

  UpdateMinimizedName;
end;

procedure TSCFileNameLabel.Resize;
begin
  inherited;

  UpdateMinimizedName;
end;

function TSCFileNameLabel.GetLabelText: string;
begin
  Result := FMinimizedName;;
end;


end.
