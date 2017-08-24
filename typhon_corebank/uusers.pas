UNIT uusers;

{$mode objfpc}{$H+}

INTERFACE

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

TYPE

  { Tfrmusers }

  Tfrmusers = CLASS(TForm)
    id: TLabeledEdit;
    session_: TLabeledEdit;
    login: TLabeledEdit;
    password: TLabeledEdit;
    wrong_attempt_count: TLabeledEdit;
    blocked_time: TLabeledEdit;
    email: TLabeledEdit;
    mob_phone: TLabeledEdit;
    logon_time: TLabeledEdit;
    PROCEDURE FormCreate(Sender: TObject);
  private

  public

  END;

var
  frmusers: Tfrmusers;

implementation

{$R *.frm}



{ Tfrmusers }

PROCEDURE Tfrmusers.FormCreate(Sender: TObject);
BEGIN
  RegisterClass(Tfrmusers);
end;

END.

