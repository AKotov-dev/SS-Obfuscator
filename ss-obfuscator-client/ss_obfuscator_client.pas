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
  portscan_trd { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='SS-Obfuscator-Client v0.3.2 (xray-plugin v1.8.24)';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
