unit uSelfDialogBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfDialogBox }

  TfDialogBox = class(TForm)
    btnYes: TButton;
    btnNo: TButton;
    Label1: TLabel;
    procedure btnYesClick(Sender: TObject);
  private
    { private declarations }
    function yesClicked:boolean;
  public
    { public declarations }
    property isYesClicked : boolean read yesClicked;
    procedure showDialog(p_label :string);
  end;

var
  fDialogBox: TfDialogBox;
  v_yesClicked :boolean;
implementation

{$R *.lfm}

{ TfDialogBox }

procedure TfDialogBox.btnYesClick(Sender: TObject);
begin
   v_yesClicked :=true;
   close;
end;

function TfDialogBox.yesClicked: boolean;
begin
  result :=  v_yesClicked ;
end;

procedure TfDialogBox.showDialog(p_label: string);
begin
  Label1.Caption:=p_label;
  Visible:=true;
end;

end.

