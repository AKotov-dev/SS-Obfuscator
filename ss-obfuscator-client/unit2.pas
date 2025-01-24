unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileUtil, ExtCtrls,
  AsyncProcess, Base64;

type

  { TQRForm }

  TQRForm = class(TForm)
    GetQR: TAsyncProcess;
    Image1: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  QRForm: TQRForm;

implementation

uses unit1;

  {$R *.lfm}

  { TQRForm }

procedure TQRForm.FormShow(Sender: TObject);
var
  S: string;
begin
  Image1.Picture := nil;

  S := 'ss://' + EncodeStringBase64('chacha20-ietf-poly1305:' +
    MainForm.PasswordEdit.Text) + '@' + MainForm.ServerEdit.Text +
    ':' + MainForm.ServerPortEdit.Text + '/?plugin=xray%2Dplugin%3Bmode%3Dgrpc';

  //Получаем текст URL
  GetQR.Parameters.Clear;
  GetQR.Parameters.Add('-c');
  GetQR.Parameters.Add(
    'qrencode "' + S + '" -o ~/.config/ss-obfuscator-client/qr.xpm --margin=4 --type=XPM');

  //Получаем картинку
  GetQR.Execute;

  //Выводим картинку
  if FileExists(GetUserDir + '.config/ss-obfuscator-client/qr.xpm') then
    Image1.Picture.LoadFromFile(GetUserDir + '.config/ss-obfuscator-client/qr.xpm');
end;

procedure TQRForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DeleteFile(GetUserDir + '.config/ss-obfuscator-client/qr.xpm');
end;

end.
