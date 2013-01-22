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

unit ScTrackBar;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, CommCtrl, LCLType;

type
  TScTrackBar = class(TTrackBar)
  private
    { Déclarations privées }
  protected
    { Déclarations protégées }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Déclarations publiques }
  published
    { Déclarations publiées }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SC Team', [TScTrackBar]);
end;

{ TScTrackBar }

procedure TScTrackBar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not TBS_ENABLESELRANGE;
end;

end.
