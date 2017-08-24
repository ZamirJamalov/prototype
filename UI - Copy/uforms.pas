unit uforms;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, FORMS, Controls, Graphics, Dialogs, StdCtrls;

type

  { TxFORMS }

  TxFORMS = class(TForm)
    btnor: TButton;
    cmbforms: TComboBox;
    cmbtype: TComboBox;
    edformname: TEdit;
    edname: TEdit;
    eddefaultname: TEdit;
    edlabelcaption: TEdit;
    edfontsize: TEdit;
    edfontcolor: TEdit;
    edbkgcolor: TEdit;
    edenabled: TEdit;
    eddsproc: TEdit;
    edrequired: TEdit;
    edupdvisible: TEdit;
    edupdenabled: TEdit;
    edvisible: TEdit;
    edtop: TEdit;
    edwidth: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure btnorClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  xFORMS: TxFORMS;
  v_or :boolean;
implementation

{$R *.lfm}

{ TxFORMS }

procedure TxFORMS.btnorClick(Sender: TObject);
begin
  if v_or=false then begin
     btnor.Caption:='Select form name';
     cmbforms.Visible:=false;
     edformname.Visible:=true;
     v_or := true;
  end else begin
     btnor.Caption:='New form name';
     cmbforms.Visible:=true;
     edformname.Visible:=false;
     v_or := false;
  end;


end;

end.

