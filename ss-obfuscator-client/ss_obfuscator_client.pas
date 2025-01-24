program ss_obfuscator_client;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
   {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
   {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  start_trd,
  portscan_trd, Unit2;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='SS-Obfuscator-Client v0.3.3 (xray-plugin v1.8.24)';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TQRForm, QRForm);
  Application.Run;
end.
