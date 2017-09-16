unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
 var
    s:String;
begin
 s:='{"session_key":"68713E814138229E16B2493D73DE07A2","method_name":"zamir.ui_menu_pkg.upd","TFORM":"ui_menu","root_id":["2"],"id":["3"],"form_name":["users"],"form_caption":["users"],"schema_name":["zamir"],"crud":["Y"],"external_form":["N"],"caption":["1əüı"]}';
  WITH TFPHttpClient.Create(nil) DO
    TRY

      s := Post('http://localhost:8089/WebApplication1/NewServlet?myparam=' + s);

    finally
      Memo1.Text:=s;
    end;

end;

end.

