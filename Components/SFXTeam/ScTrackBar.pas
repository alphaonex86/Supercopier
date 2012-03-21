{
    This file is part of SuperCopier2.

    SuperCopier2 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    SuperCopier2 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
}

unit ScTrackBar;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, TntComCtrls,CommCtrl;

type
  TScTrackBar = class(TTntTrackBar)
  private
    { Déclarations privées }
  protected
    { Déclarations protégées }
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    { Déclarations publiques }
  published
    { Déclarations publiées }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SFX Team', [TScTrackBar]);
end;

{ TScTrackBar }

procedure TScTrackBar.CreateWindowHandle(const Params: TCreateParams);
var NewParams:TCreateParams;
begin
  NewParams:=Params;
  NewParams.Style:=NewParams.Style-TBS_ENABLESELRANGE;
  inherited CreateWindowHandle(NewParams);
end;

end.
