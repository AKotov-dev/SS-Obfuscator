unit portscan_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process, Graphics;

type
  PortScan = class(TThread)
  private

    { Private declarations }
  protected
  var
    ResultStr: TStringList;

    procedure Execute; override;
    procedure ShowStatus;

  end;

implementation

uses unit1;

{ TRD }

procedure PortScan.Execute;
var
  ScanProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении

  while not Terminated do
    try
      ResultStr := TStringList.Create;

      ScanProcess := TProcess.Create(nil);

      ScanProcess.Executable := '/bin/bash';
      ScanProcess.Parameters.Add('-c');
      ScanProcess.Options := [poUsePipes, poWaitOnExit]; // poStderrToOutPut,

      ScanProcess.Parameters.Add(
       { '[[ $(fping ' + MainForm.ServerEdit.Text + ') ]] && [[ $(ss -ltn | grep 127.0.0.1:' +
        MainForm.LocalPortEdit.Text + ') ]] && echo "yes"');}

        //Проверка порта удаленного сервера и локального порта клиента
        '[[ $(nmap ' + MainForm.ServerEdit.Text + ' -p ' +
        MainForm.ServerPortEdit.Text +
        ' | grep open) ]] && [[ $(ss -ltn | grep 127.0.0.1:' +
        MainForm.LocalPortEdit.Text + ') ]] && echo "yes"');

      ScanProcess.Execute;

      ResultStr.LoadFromStream(ScanProcess.Output);
      Synchronize(@ShowStatus);

      Sleep(1000);
    finally
      ResultStr.Free;
      ScanProcess.Free;
    end;
end;

//Отображение статуса
procedure PortScan.ShowStatus;
begin
  with MainForm do
  begin
    if ResultStr.Count <> 0 then
    begin
      Shape1.Brush.Color := clLime;
      ServerEdit.Enabled := False;
      ServerPortEdit.Enabled := False;
      PasswordEdit.Enabled := False;
      LocalPortEdit.Enabled := False;
    end
    else
    begin
      Shape1.Brush.Color := clYellow;
      ServerEdit.Enabled := True;
      ServerPortEdit.Enabled := True;
      PasswordEdit.Enabled := True;
      LocalPortEdit.Enabled := True;
    end;

    Shape1.Repaint;
  end;
end;

end.
