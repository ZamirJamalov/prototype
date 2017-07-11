unit uthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
    TMyThread = class(TThread)
    private
      fStatusText : string;

    protected
      procedure Execute; override;
    public
      P:procedure of object;
      Constructor Create(CreateSuspended : boolean);

    end;


implementation
  constructor TMyThread.Create(CreateSuspended : boolean);
  begin
    FreeOnTerminate := True;
    inherited Create(CreateSuspended);
  end;

  procedure TMyThread.Execute;
  begin
      Synchronize(P);
  end;
end.

