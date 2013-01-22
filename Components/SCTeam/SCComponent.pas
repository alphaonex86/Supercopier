{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit SCComponent;

interface

uses
  SCProgessBar, SCFileNameLabel, ScTrackBar, ScPopupButton, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('SCProgessBar', @SCProgessBar.Register);
  RegisterUnit('SCFileNameLabel', @SCFileNameLabel.Register);
  RegisterUnit('ScTrackBar', @ScTrackBar.Register);
  RegisterUnit('ScPopupButton', @ScPopupButton.Register);
end;

initialization
  RegisterPackage('SCComponent', @Register);
end.
