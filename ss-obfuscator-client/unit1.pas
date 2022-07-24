unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, IniPropStorage, ExtCtrls, Process, IniFiles, DefaultTranslator;

type

  { TMainForm }

  TMainForm = class(TForm)
    AutoStartBox: TCheckBox;
    ClearBox: TCheckBox;
    ServerEdit: TEdit;
    ServerPortEdit: TEdit;
    PasswordEdit: TEdit;
    LocalPortEdit: TEdit;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LogMemo: TMemo;
    Shape1: TShape;
    StartBtn: TSpeedButton;
    StaticText1: TStaticText;
    StopBtn: TSpeedButton;
    procedure AutoStartBoxChange(Sender: TObject);
    procedure ClearBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure StartProcess(command: string);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

uses start_trd, portscan_trd;

{$R *.lfm}

{ TMainForm }


//Общая процедура запуска команд (асинхронная)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    //  ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

//Проверка чекбокса ClearBox (очистка кеш/cookies)
function CheckClear: boolean;
begin
  if FileExists(GetUserDir + '.config/ss-obfuscator-client/clear') then
    Result := True
  else
    Result := False;
end;

//Проверка чекбокса AutoStart
function CheckAutoStart: boolean;
var
  S: ansistring;
begin
  RunCommand('/bin/bash', ['-c',
    '[[ -n $(systemctl --user is-enabled ss-obfuscator-client | grep "enabled") ]] && echo "yes"'],
    S);

  if Trim(S) = 'yes' then
    Result := True
  else
    Result := False;
end;

//Start
procedure TMainForm.StartBtnClick(Sender: TObject);
var
  S: TStringList;
  INI: TIniFile;
begin
  try
    //Быстрая очистка вывода перед стартом
    LogMemo.Clear;

    //Создаём client.json
    S := TStringList.Create;
    S.Add('{');
    S.Add('    "server":"' + ServerEdit.Text + '",');
    S.Add('    "server_port":' + ServerPortEdit.Text + ',');
    S.Add('    "local_port":' + LocalPortEdit.Text + ',');
    S.Add('    "password":"' + PasswordEdit.Text + '",');
    S.Add('    "timeout":120,');
    S.Add('    "method":"chacha20-ietf-poly1305",');
    S.Add('    "fast_open":true,');
    S.Add('    "plugin":"xray-plugin",');
    //S.Add('    "plugin_opts":"mode=grpc",'); (Google могут заблокировать)
    S.Add('    "nameserver":"1.1.1.1,8.8.4.4",');
    S.Add('    "reuse_port":true');
    S.Add('}');
    S.SaveToFile(GetUserDir + '.config/ss-obfuscator-client/client.json');

    //Запоминаем настройки только по нажатию Start
    INI := TINIFile.Create(GetUserDir +
      '.config/ss-obfuscator-client/ss-obfuscator-client.ini');
    INI.WriteString('settings', 'server', ServerEdit.Text);
    INI.WriteString('settings', 'server_port', ServerPortEdit.Text);
    INI.WriteString('settings', 'password', PasswordEdit.Text);
    INI.WriteString('settings', 'local_port', LocalPortEdit.Text);

    //Запускаем сервис
    StartProcess('systemctl --user restart ss-obfuscator-client.service');
  finally
    S.Free;
    INI.Free;
  end;
end;

//Стоп
procedure TMainForm.StopBtnClick(Sender: TObject);
begin
  StartProcess('systemctl --user stop ss-obfuscator-client.service');
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  INI: TIniFile;
begin
  try
    MainForm.Caption := Application.Title;

    //Создаём каталоги настроек
    if not DirectoryExists(GetUserDir + '.config') then MkDir(GetUserDir + '.config');
    if not DirectoryExists(GetUserDir + '.config/ss-obfuscator-client') then
      MkDir(GetUserDir + '.config/ss-obfuscator-client');

    //Для настроек по нажатию Start (server, server_port, password и local_port)
    INI := TINIFile.Create(GetUserDir +
      '.config/ss-obfuscator-client/ss-obfuscator-client.ini');

    //Для сохранения настроек формы и др.
    IniPropStorage1.IniFileName := INI.FileName;

    //Начитываем настройки из ss-obfuscator-client.ini или дефолтные
    if FileExists(GetUserDir +
      '.config/ss-obfuscator-client/ss-obfuscator-client.ini') then
    begin
      ServerEdit.Text := INI.ReadString('settings', 'server', '192.168.0.77');
      ServerPortEdit.Text := INI.ReadString('settings', 'server_port', '443');
      PasswordEdit.Text := INI.ReadString('settings', 'password',
        '6v5mTMPy2nQvRY9GXZsRkrqLk2guR6Z0i4f9mupi1B9pj51A5W');
      LocalPortEdit.Text := INI.ReadString('settings', 'local_port', '1080');
    end;
  finally
    INI.Free;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;
end;

//Автостарт
procedure TMainForm.AutoStartBoxChange(Sender: TObject);
var
  S: ansistring;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  if not AutoStartBox.Checked then
    RunCommand('/bin/bash', ['-c',
      'systemctl --user disable ss-obfuscator-client.service'], S)
  else
    RunCommand('/bin/bash', ['-c',
      'systemctl --user enable ss-obfuscator-client.service'], S);
  Screen.Cursor := crDefault;
end;

//Файл-флаг автоочистки кеша и кукисов
procedure TMainForm.ClearBoxChange(Sender: TObject);
var
  S: ansistring;
begin
  if not ClearBox.Checked then
    RunCommand('/bin/bash', ['-c', 'rm -f ~/.config/ss-obfuscator-client/clear'], S)
  else
    RunCommand('/bin/bash', ['-c', 'touch ~/.config/ss-obfuscator-client/clear'], S);
end;

//MainForm, запуск потоков
procedure TMainForm.FormShow(Sender: TObject);
var
  FShowLogTRD, FPortScanThread: TThread;
begin
  IniPropStorage1.Restore;

  ClearBox.Checked := CheckClear;
  AutoStartBox.Checked := CheckAutoStart;

  //Запуск потока проверки состояния локального порта
  FPortScanThread := PortScan.Create(False);
  FPortScanThread.Priority := tpNormal;

  //Запуск поток непрерывного чтения лога
  FShowLogTRD := ShowLogTRD.Create(False);
  FShowLogTRD.Priority := tpNormal;
end;

end.
