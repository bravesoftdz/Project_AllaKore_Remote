﻿{


  This source has created by Maickonn Richard.
  Any questions, contact-me: senjaxus@gmail.com

  My Github: https://www.github.com/Senjaxus

  Join our Facebook group: https://www.facebook.com/groups/1202680153082328/

  Are totally free!


}

{$R ResFile.res}
unit Form_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, System.Win.ScktComp, Vcl.AppEvnts, Vcl.ComCtrls, Winapi.MMSystem,
  Registry, Vcl.Menus, Vcl.Mask, Clipbrd, sndkey32, StreamManager, zLibEx;

type
  //TAkSocket = class()

  TThread_Connection_Main = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Desktop = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Keyboard = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Files = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  Tfrm_Main = class(TForm)
    TopBackground_Image: TImage;
    Logo_Image: TImage;
    Title1_Label: TLabel;
    Title2_Label: TLabel;
    GroupBox1: TGroupBox;
    background_label_Image: TImage;
    YourID_Label: TLabel;
    YourPassword_Label: TLabel;
    background_label_Image2: TImage;
    YourID_Edit: TEdit;
    YourPassword_Edit: TEdit;
    background_label_Image3: TImage;
    TargetID_Label: TLabel;
    Connect_BitBtn: TBitBtn;
    Status_Image: TImage;
    Status_Label: TLabel;
    Bevel1: TBevel;
    Image1: TImage;
    Image2: TImage;
    Reconnect_Timer: TTimer;
    Image3: TImage;
    Main_Socket: TClientSocket;
    Desktop_Socket: TClientSocket;
    ApplicationEvents1: TApplicationEvents;
    Keyboard_Socket: TClientSocket;
    Files_Socket: TClientSocket;
    Timeout_Timer: TTimer;
    About_BitBtn: TBitBtn;
    TargetID_MaskEdit: TMaskEdit;
    Clipboard_Timer: TTimer;
    procedure Connect_BitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Reconnect_TimerTimer(Sender: TObject);
    procedure Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Keyboard_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Keyboard_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TargetID_EditKeyPress(Sender: TObject; var Key: Char);
    procedure Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timeout_TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure About_BitBtnClick(Sender: TObject);
    procedure TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
    procedure Clipboard_TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    MyID                  : string;
    MyPassword            : string;
    MyPing                : Integer;
    Viewer                : Boolean;
    ResolutionTargetWidth : Integer;
    ResolutionTargetHeight: Integer;

    Thread_Connection_Main    : TThread_Connection_Main;
    Thread_Connection_Desktop : TThread_Connection_Desktop;
    Thread_Connection_Keyboard: TThread_Connection_Keyboard;
    Thread_Connection_Files   : TThread_Connection_Files;

    procedure ClearConnection;
    procedure SetOffline;
    procedure SetOnline;
    procedure Reconnect;
    procedure ReconnectSecundarySockets;
    procedure CloseSockets;
    { Public declarations }
  end;

var
  frm_Main        : Tfrm_Main;
  ResolutionWidth : Integer;
  ResolutionHeight: Integer;
  Timeout         : Integer;
  OldWallpaper    : string;
  OldClipboardText: string;
  Accessed        : Boolean;

const
  Host              = 'mp009'; // Host of Sockets  (Insert the IP Address or DNS of your Server)
  Port              = 3898;        // Port of Sockets
  ConnectionTimeout = 60;          // Timeout of connection (in secound)
  ProcessingSlack   = 2;           // Processing slack for Sleep Commands

implementation

{$R *.dfm}

uses
  Form_Password, Form_RemoteScreen, Form_Chat, Form_ShareFiles;

constructor TThread_Connection_Main.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Desktop.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  Accessed        := False;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Keyboard.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Files.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

// Get current Version
function GetAppVersionStr: string;
var
  Exe         : string;
  Size, Handle: DWORD;
  Buffer      : TBytes;
  FixedPtr    : PVSFixedFileInfo;
begin
  Exe  := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
    LongRec(FixedPtr.dwFileVersionMS).Lo,                                // minor
    LongRec(FixedPtr.dwFileVersionLS).Hi,                                // release
    LongRec(FixedPtr.dwFileVersionLS).Lo])                               // build
end;

function GetWallpaperDirectory: string;
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg         := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Result := Reg.ReadString('Wallpaper');
  finally
    FreeAndNil(Reg);
  end;
end;

procedure ChangeWallpaper(Directory: string);
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg         := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Reg.WriteString('Wallpaper', Directory);
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, nil, SPIF_SENDWININICHANGE);
  finally
    FreeAndNil(Reg);
  end;
end;

procedure Tfrm_Main.About_BitBtnClick(Sender: TObject);
begin
  MessageBox(0, 'This software has created by Maickonn Richard and source code are free!' + #13 + #13'Any questions, contact-me: senjaxus@gmail.com' + #13#13 + 'My Github: https://www.github.com/Senjaxus', 'About AllaKore Remote', MB_ICONASTERISK + MB_TOPMOST);
end;

procedure Tfrm_Main.ClearConnection;
begin
  frm_Main.ResolutionTargetWidth  := 986;
  frm_Main.ResolutionTargetHeight := 600;

  with frm_RemoteScreen do
  begin
    MouseIcon_Image.Picture.Assign(MouseIcon_unchecked_Image.Picture);
    KeyboardIcon_Image.Picture.Assign(KeyboardIcon_unchecked_Image.Picture);
    ResizeIcon_Image.Picture.Assign(ResizeIcon_checked_Image.Picture);

    MouseRemote_CheckBox.Checked    := False;
    KeyboardRemote_CheckBox.Checked := False;
    Resize_CheckBox.Checked         := true;
    CaptureKeys_Timer.Enabled       := False;

    Screen_Image.Picture.Assign(ScreenStart_Image.Picture);

    Width  := 986;
    Height := 646;

  end;

  with frm_ShareFiles do
  begin
    Download_BitBtn.Enabled       := true;
    Upload_BitBtn.Enabled         := true;
    Download_ProgressBar.Position := 0;
    Upload_ProgressBar.Position   := 0;
    SizeDownload_Label.Caption    := 'Size: 0 B / 0 B';
    SizeUpload_Label.Caption      := 'Size: 0 B / 0 B';

    Directory_Edit.Text := 'C:\';
    ShareFiles_ListView.Items.Clear;

    if (Visible) then
      Close;
  end;

  with frm_Chat do
  begin
    Width  := 230;
    Height := 340;

    Left := Screen.WorkAreaWidth - Width;
    Top  := Screen.WorkAreaHeight - Height;

    Chat_RichEdit.Clear;
    YourText_Edit.Clear;
    Chat_RichEdit.SelStart            := Chat_RichEdit.GetTextLen;
    Chat_RichEdit.SelAttributes.Style := [fsBold];
    Chat_RichEdit.SelAttributes.Color := clWhite;
    Chat_RichEdit.SelText             := 'AllaKore Remote - Chat' + #13 + #13;

    FirstMessage      := true;
    LastMessageAreYou := False;

    if (Visible) then
      Close;
  end;

end;

procedure Tfrm_Main.Clipboard_TimerTimer(Sender: TObject);
begin
  try
    Clipboard.Open;

    if (Clipboard.HasFormat(CF_TEXT)) then
    begin
      if not(OldClipboardText = Clipboard.AsText) then
      begin
        OldClipboardText := Clipboard.AsText;
        Main_Socket.Socket.SendText(AnsiString('<|REDIRECT|><|CLIPBOARD|>' + Clipboard.AsText + '<|END|>'));
      end;
    end;

  finally
    Clipboard.Close;
  end;

end;

// Return size (B, KB, MB or GB)
function GetSize(bytes: Int64): string;
begin
  if bytes < 1024 then
    Result := IntToStr(bytes) + ' B'
  else if bytes < 1048576 then
    Result := FloatToStrF(bytes / 1024, ffFixed, 10, 1) + ' KB'
  else if bytes < 1073741824 then
    Result := FloatToStrF(bytes / 1048576, ffFixed, 10, 1) + ' MB'
  else if bytes > 1073741824 then
    Result := FloatToStrF(bytes / 1073741824, ffFixed, 10, 1) + ' GB';
end;

// Function to List Folders
function ListFolders(Directory: string): string;
var
  FileName  : string;
  Filelist  : string;
  Dirlist   : string;
  Searchrec : TWin32FindData;
  FindHandle: THandle;
  ReturnStr : string;
begin
  ReturnStr := '';

  FindHandle := FindFirstFile(PChar(Directory + '*.*'), Searchrec);
  try
    if FindHandle <> INVALID_HANDLE_VALUE then
      repeat
        FileName := Searchrec.cFileName;
        if (FileName = '.') then
          Continue;
        if ((Searchrec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        begin
          Dirlist := Dirlist + (FileName + #13);
        end
        else
        begin
          Filelist := Filelist + (FileName + #13);
        end;
      until FindNextFile(FindHandle, Searchrec) = False;
  finally
    Winapi.Windows.FindClose(FindHandle);
  end;
  ReturnStr := (Dirlist);
  Result    := ReturnStr;
end;

// Function to List Files
function ListFiles(FileName, Ext: string): string;
var
  SearchFile: TSearchRec;
  FindResult: Integer;
  Arc       : TStrings;
begin
  Arc        := TStringList.Create;
  {$WARN SYMBOL_PLATFORM OFF}
  FindResult := FindFirst(FileName + Ext, faArchive, SearchFile);
  {$WARN SYMBOL_PLATFORM ON}
  try
    while FindResult = 0 do
    begin
      Application.ProcessMessages;
      Arc.Add(SearchFile.Name);
      FindResult := FindNext(SearchFile);
    end;
  finally
    FindClose(SearchFile)
  end;
  Result := Arc.Text;
end;

procedure Tfrm_Main.Reconnect;
begin

  if not Main_Socket.Active then
    Main_Socket.Active := true;

end;

procedure Tfrm_Main.ReconnectSecundarySockets;
begin
  Viewer := False;

  Thread_Connection_Desktop.Socket  := nil;
  Thread_Connection_Keyboard.Socket := nil;
  Thread_Connection_Files.Socket    := nil;

  Desktop_Socket.Socket.Close;
  Keyboard_Socket.Socket.Close;
  Files_Socket.Socket.Close;

  Desktop_Socket.Active  := true;
  Keyboard_Socket.Active := true;
  Files_Socket.Active    := true;
end;

procedure Tfrm_Main.CloseSockets;
begin

  Main_Socket.Close;
  Desktop_Socket.Close;
  Keyboard_Socket.Close;
  Files_Socket.Close;

  Viewer := False;

  // Restore Wallpaper
  if Accessed then
  begin
    Accessed := False;
    ChangeWallpaper(OldWallpaper);
  end;

  // Show main form and repaint
  if not Visible then
  begin
    Show;
    Repaint;
  end;

  ClearConnection;
end;

procedure Tfrm_Main.SetOffline;
begin

  YourID_Edit.Text    := 'Offline';
  YourID_Edit.Enabled := False;

  YourPassword_Edit.Text    := 'Offline';
  YourPassword_Edit.Enabled := False;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := False;

  Connect_BitBtn.Enabled := False;

  Timeout_Timer.Enabled   := False;
  Clipboard_Timer.Enabled := False;

end;

procedure SetConnected;
begin
  with frm_Main do
  begin
    YourID_Edit.Text    := 'Receiving...';
    YourID_Edit.Enabled := False;

    YourPassword_Edit.Text    := 'Receiving...';
    YourPassword_Edit.Enabled := False;

    TargetID_MaskEdit.Clear;
    TargetID_MaskEdit.Enabled := False;

    Connect_BitBtn.Enabled := False;
  end;
end;

procedure Tfrm_Main.SetOnline;
begin

  YourID_Edit.Text    := MyID;
  YourID_Edit.Enabled := true;

  YourPassword_Edit.Text    := MyPassword;
  YourPassword_Edit.Enabled := true;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := true;

  Connect_BitBtn.Enabled := true;

end;

// Compress Stream with zLib
function CompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
var
  InputStream    : TMemoryStream;
  OutputStream   : TMemoryStream;
  inbuffer       : Pointer;
  outbuffer      : Pointer;
  count, outcount: longint;
begin
  Result := False;

  InputStream  := nil;
  OutputStream := nil;
  inbuffer     := nil;
  outbuffer    := nil;

  if not assigned(SrcStream) then
    Exit;

  count := 0;
  try
    InputStream  := TMemoryStream.Create;
    OutputStream := TMemoryStream.Create;
    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    zcompress(inbuffer, count, outbuffer, outcount, zcDefault);
    OutputStream.Write(outbuffer^, outcount);
    SrcStream.Clear;
    SrcStream.LoadFromStream(OutputStream);
    Result := true;
  finally
    FreeAndNil(InputStream);
    FreeAndNil(OutputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

// Decompress Stream with zLib
function DeCompressStreamWithZLib(SrcStream: TMemoryStream): Boolean;
var
  InputStream : TMemoryStream;
  OutputStream: TMemoryStream;
  inbuffer    : Pointer;
  outbuffer   : Pointer;
  count       : longint;
  outcount    : longint;
begin
  Result := False;
  count := 0;
  InputStream  := nil;
  OutputStream := nil;
  inbuffer     := nil;
  outbuffer    := nil;

  if not assigned(SrcStream) then
    Exit;

  try
    try
      InputStream  := TMemoryStream.Create;
      OutputStream := TMemoryStream.Create;

      InputStream.LoadFromStream(SrcStream);
      count := InputStream.Size;
      getmem(inbuffer, count);
      InputStream.ReadBuffer(inbuffer^, count);
      zdecompress(inbuffer, count, outbuffer, outcount);
      OutputStream.Write(outbuffer^, outcount);
      SrcStream.Clear;
      SrcStream.LoadFromStream(OutputStream);
      Result := true;
    except
      Result := False;
    end;
  finally
    FreeAndNil(InputStream);
    FreeAndNil(OutputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

function MemoryStreamToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure Tfrm_Main.Connect_BitBtnClick(Sender: TObject);
begin
  if not(TargetID_MaskEdit.Text = '   -   -   ') then
  begin
    if (TargetID_MaskEdit.Text = MyID) then
      MessageBox(0, 'You can not connect with yourself!', 'AllaKore Remote', MB_ICONASTERISK + MB_TOPMOST)
    else
    begin
      Main_Socket.Socket.SendText(AnsiString('<|FINDID|>' + TargetID_MaskEdit.Text + '<|END|>'));
      TargetID_MaskEdit.Enabled := False;
      Connect_BitBtn.Enabled    := False;
      Status_Image.Picture.Assign(Image1.Picture);
      Status_Label.Caption := 'Finding the ID...';
    end;
  end;
end;

procedure Tfrm_Main.Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  // If connected, then send MyID for identification on Server
  Socket.SendText(AnsiString('<|DESKTOPSOCKET|>' + MyID + '<|END|>'));
  Thread_Connection_Desktop := TThread_Connection_Desktop.Create(Socket);

end;

procedure Tfrm_Main.Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Socket.SendText(AnsiString('<|FILESSOCKET|>' + MyID + '<|END|>'));
  Thread_Connection_Files := TThread_Connection_Files.Create(Socket);
end;

procedure Tfrm_Main.Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Restore Wallpaper
  if Accessed then
    ChangeWallpaper(OldWallpaper);
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
var
  _Host: AnsiString;
  _Port: Integer;
begin
  // Insert version on Caption of the Form
  Caption := Caption + ' - ' + GetAppVersionStr;

  // Reads two exe params - host and port. If not supplied uses constants. to use: client.exe HOST PORT, for ex. AllaKore_Remote_Client.exe 192.168.16.201 3398
  if (ParamStr(1) <> '') then
    _Host := AnsiString(ParamStr(1))
  else
    _Host := Host;

  if (ParamStr(2) <> '') then
    _Port := StrToIntDef(ParamStr(2), Port)
  else
    _Port := Port;

  // Define Host, Port and Timeout of Sockets
  Main_Socket.Host := String(_Host);
  Main_Socket.Port := _Port;

  Desktop_Socket.Host := String(_Host);
  Desktop_Socket.Port := _Port;

  Keyboard_Socket.Host := String(_Host);
  Keyboard_Socket.Port := _Port;

  Files_Socket.Host := String(_Host);
  Files_Socket.Port := _Port;
  //
  ResolutionTargetWidth  := 986;
  ResolutionTargetHeight := 600;

  MyPing := 256;

  SetOffline;
  Reconnect;
end;

procedure Tfrm_Main.Keyboard_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Socket.SendText(AnsiString('<|KEYBOARDSOCKET|>' + MyID + '<|END|>'));
  Thread_Connection_Keyboard := TThread_Connection_Keyboard.Create(Socket);
end;

procedure Tfrm_Main.Keyboard_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin

  Status_Image.Picture.Assign(Image3.Picture);
  Status_Label.Caption := 'You are connected!';

  Timeout := 0;

  Timeout_Timer.Enabled := true;

  Socket.SendText(AnsiString('<|MAINSOCKET|>'));

  Thread_Connection_Main := TThread_Connection_Main.Create(Socket);

end;

procedure Tfrm_Main.Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  Status_Image.Picture.Assign(Image1.Picture);
  Status_Label.Caption := 'Connecting to Server...';
end;

procedure Tfrm_Main.Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if (frm_RemoteScreen.Visible) then
    frm_RemoteScreen.Close;

  SetOffline;

  Status_Image.Picture.Assign(Image2.Picture);
  Status_Label.Caption := 'Failed connect to Server.';

  CloseSockets;
end;

procedure Tfrm_Main.Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;

  if (frm_RemoteScreen.Visible) then
    frm_RemoteScreen.Close;

  SetOffline;

  Status_Image.Picture.Assign(Image2.Picture);
  Status_Label.Caption := 'Failed connect to Server.';

  CloseSockets;
end;

procedure Tfrm_Main.TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Connect_BitBtn.Click;
    Key := #0;
  end
end;

procedure Tfrm_Main.Reconnect_TimerTimer(Sender: TObject);
begin
  // Reconnect Sockets
  Reconnect;
end;

procedure Tfrm_Main.TargetID_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Connect_BitBtn.Click;
    Key := #0;
  end
end;

procedure Tfrm_Main.Timeout_TimerTimer(Sender: TObject);
begin
  if (Timeout > ConnectionTimeout) then
  begin
    if (frm_RemoteScreen.Visible) then
      frm_RemoteScreen.Close
    else
    begin
      frm_Main.SetOffline;
      frm_Main.CloseSockets;
      frm_Main.Reconnect;
    end;
  end;
  Inc(Timeout);
end;

// Connection are Main
procedure TThread_Connection_Main.Execute;
var
  Buffer         : string;
  BufferTemp     : string;
  Extension      : string;
  i              : Integer;
  Position       : Integer;
  MousePosX      : Integer;
  MousePosY      : Integer;
  FoldersAndFiles: TStringList;
  L              : TListItem;
  FileToUpload   : TFileStream;

begin
  inherited;

  FoldersAndFiles := nil;

  while Socket.Connected do
  begin

    Sleep(ProcessingSlack); // Avoids using 100% CPU

    try
      if Socket.ReceiveLength < 1 then
        Continue;

      Buffer := String(Socket.ReceiveText);

      // Received data, then resets the timeout
      Timeout := 0;

      // If receive ID, are Online
      Position := Pos('<|ID|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 5);

        Position      := Pos('<|>', BufferTemp);
        frm_Main.MyID := Copy(BufferTemp, 1, Position - 1);
        Delete(BufferTemp, 1, Position + 2);

        frm_Main.MyPassword := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        Synchronize(frm_Main.SetOnline);

        // If this Socket are connected, then connect the Desktop Socket, Keyboard Socket, File Download Socket and File Upload Socket
        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              Desktop_Socket.Active := true;
              Keyboard_Socket.Active := true;
              Files_Socket.Active := true;

              TargetID_MaskEdit.SetFocus;
            end;
          end);
      end;

      // Ping
      if Buffer.Contains('<|PING|>') then
      begin
        Socket.SendText(AnsiString('<|PONG|>'));
      end;

      Position := Pos('<|SETPING|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 10);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        frm_Main.MyPing := StrToInt(BufferTemp);
      end;

      // Warns access and remove Wallpaper
      if Buffer.Contains('<|ACCESSING|>') then
      begin
        OldWallpaper := GetWallpaperDirectory;
        ChangeWallpaper('');

        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              TargetID_MaskEdit.Enabled := False;
              Connect_BitBtn.Enabled := False;
              Status_Image.Picture.Assign(frm_Main.Image3.Picture);
              Status_Label.Caption := 'Connected support!';
            end;
          end);
        Accessed := true;
      end;

      if Buffer.Contains('<|IDEXISTS!REQUESTPASSWORD|>') then
      begin
        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              frm_Main.Status_Label.Caption := 'Waiting for authentication...';
              frm_Password.ShowModal;
            end;
          end);
      end;

      if Buffer.Contains('<|IDNOTEXISTS|>') then
      begin
        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              Status_Image.Picture.Assign(frm_Main.Image2.Picture);
              Status_Label.Caption := 'ID does nor exists.';
              TargetID_MaskEdit.Enabled := true;
              Connect_BitBtn.Enabled := true;
              TargetID_MaskEdit.SetFocus;
            end;
          end);
      end;

      if Buffer.Contains('<|ACCESSDENIED|>') then
      begin
        Synchronize(
          procedure
          begin

            with frm_Main do
            begin
              Status_Image.Picture.Assign(Image2.Picture);
              Status_Label.Caption := 'Wrong password!';
              TargetID_MaskEdit.Enabled := true;
              Connect_BitBtn.Enabled := true;
              TargetID_MaskEdit.SetFocus;
            end;
          end);
      end;

      if Buffer.Contains('<|ACCESSBUSY|>') then
      begin
        Synchronize(
          procedure
          begin

            with frm_Main do
            begin
              Status_Image.Picture.Assign(Image2.Picture);
              Status_Label.Caption := 'PC is Busy!';
              TargetID_MaskEdit.Enabled := true;
              Connect_BitBtn.Enabled := true;
              TargetID_MaskEdit.SetFocus;
            end;
          end);
      end;

      if Buffer.Contains('<|ACCESSGRANTED|>') then
      begin
        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              Status_Image.Picture.Assign(Image3.Picture);
              Status_Label.Caption := 'Access granted!';
              Viewer := true;

              Clipboard_Timer.Enabled := true;

              ClearConnection;
              frm_RemoteScreen.Show;
              Hide;
              Socket.SendText(AnsiString('<|RELATION|>' + MyID + '<|>' + TargetID_MaskEdit.Text + '<|END|>'));
            end;
          end);
      end;

      if Buffer.Contains('<|DISCONNECTED|>') then
      begin
        Synchronize(
          procedure
          begin
            with frm_Main do
            begin
              frm_RemoteScreen.Hide;
              frm_ShareFiles.Hide;
              frm_Chat.Hide;

              if Accessed then
                ChangeWallpaper(OldWallpaper);

              ReconnectSecundarySockets;

              Show;

              SetOnline;

              Status_Image.Picture.Assign(Image2.Picture);
              Status_Label.Caption := 'Lost connection to PC!';
              FlashWindow(Handle, true);

            end;
          end);
      end;

      { Redirected commands }

      // Desktop Remote
      Position := Pos('<|RESOLUTION|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 13);

        Position                       := Pos('<|>', BufferTemp);
        frm_Main.ResolutionTargetWidth := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        frm_Main.ResolutionTargetHeight := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));
      end;

      Position := Pos('<|SETMOUSEPOS|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 14);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
      end;

      Position := Pos('<|SETMOUSELEFTCLICKDOWN|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 24);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
      end;

      Position := Pos('<|SETMOUSELEFTCLICKUP|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 22);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;

      Position := Pos('<|SETMOUSERIGHTCLICKDOWN|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 25);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
      end;

      Position := Pos('<|SETMOUSERIGHTCLICKUP|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 23);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;

      Position := Pos('<|SETMOUSEMIDDLEDOWN|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 21);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
      end;

      Position := Pos('<|SETMOUSEMIDDLEUP|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 19);

        Position  := Pos('<|>', BufferTemp);
        MousePosX := StrToInt(Copy(BufferTemp, 1, Position - 1));

        Delete(BufferTemp, 1, Position + 2);

        MousePosY := StrToInt(Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1));

        SetCursorPos(MousePosX, MousePosY);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
      end;

      if Buffer.Contains('<|SETMOUSEDOUBLECLICK|>') then
      begin
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        Sleep(10);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;

      Position := Pos('<|WHEELMOUSE|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 13);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
        Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(StrToInt(BufferTemp)), 0);
      end;

      // Clipboard Remote
      Position := Pos('<|CLIPBOARD|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 12);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        try
          Clipboard.Open;
          Clipboard.AsText := BufferTemp;
        finally
          Clipboard.Close;
        end;
      end;

      // Chat
      Position := Pos('<|CHAT|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 7);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        Synchronize(
          procedure
          begin
            with frm_Chat do
            begin
              if (FirstMessage) then
              begin
                LastMessageAreYou := False;
                Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                Chat_RichEdit.SelAttributes.Style := [fsBold];
                Chat_RichEdit.SelAttributes.Color := clGreen;
                Chat_RichEdit.SelText := #13 + #13 + 'He say:';
                FirstMessage := False;
              end;

              if (LastMessageAreYou) then
              begin
                LastMessageAreYou := False;
                Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                Chat_RichEdit.SelAttributes.Style := [fsBold];
                Chat_RichEdit.SelAttributes.Color := clGreen;
                Chat_RichEdit.SelText := #13 + #13 + 'He say:' + #13;

                Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                Chat_RichEdit.SelAttributes.Color := clWhite;
                Chat_RichEdit.SelText := '   •   ' + BufferTemp;
              end
              else
              begin
                Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                Chat_RichEdit.SelAttributes.Style := [];
                Chat_RichEdit.SelAttributes.Color := clWhite;
                Chat_RichEdit.SelText := #13 + '   •   ' + BufferTemp;
              end;

              SendMessage(Chat_RichEdit.Handle, WM_VSCROLL, SB_BOTTOM, 0);

              if not(Visible) then
              begin
                PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                Show;
              end;

              if not(Active) then
              begin
                PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                FlashWindow(frm_Main.Handle, true);
                FlashWindow(frm_Chat.Handle, true);
              end;
            end;
          end);
      end;

      // Share Files
      // Request Folder List
      Position := Pos('<|GETFOLDERS|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 13);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        Socket.SendText(AnsiString('<|REDIRECT|><|FOLDERLIST|>' + ListFolders(BufferTemp) + '<|ENDFOLDERLIST|>'));
      end;

      // Request Files List
      Position := Pos('<|GETFILES|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 11);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        Socket.SendText(AnsiString('<|REDIRECT|><|FILESLIST|>' + ListFiles(BufferTemp, '*.*') + '<|ENDFILESLIST|>'));
      end;

      // Receive Folder List
      Position := Pos('<|FOLDERLIST|>', Buffer);
      if Position > 0 then
      begin

        while Socket.Connected do
        begin
          if Buffer.Contains('<|ENDFOLDERLIST|>') then
            break;

          if Socket.ReceiveLength > 0 then
            Buffer := Buffer + String(Socket.ReceiveText);

          Sleep(ProcessingSlack);
        end;

        BufferTemp := Buffer;
        Delete(BufferTemp, 1, Position + 13);

        FoldersAndFiles      := TStringList.Create;
        FoldersAndFiles.Text := Copy(BufferTemp, 1, Pos('<|ENDFOLDERLIST|>', BufferTemp) - 1);
        FoldersAndFiles.Sort;

        Synchronize(
          procedure
          begin
            frm_ShareFiles.ShareFiles_ListView.Clear;
          end);

        for i := 0 to FoldersAndFiles.count - 1 do
        begin
          Synchronize(
            procedure
            begin
              L := frm_ShareFiles.ShareFiles_ListView.Items.Add;
              if (FoldersAndFiles.Strings[i] = '..') then
              begin
                L.Caption := 'Return';
                L.ImageIndex := 0;
              end
              else
              begin
                L.Caption := FoldersAndFiles.Strings[i];
                L.ImageIndex := 1;
              end;
              frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
            end);

          Sleep(5); // Effect
        end;
        FreeAndNil(FoldersAndFiles);

        Socket.SendText(AnsiString('<|REDIRECT|><|GETFILES|>' + frm_ShareFiles.Directory_Edit.Text + '<|END|>'));
      end;

      // Receive Files List
      Position := Pos('<|FILESLIST|>', Buffer);
      if Position > 0 then
      begin

        while Socket.Connected do
        begin
          if Buffer.Contains('<|ENDFILESLIST|>') then
            break;

          if Socket.ReceiveLength > 0 then
            Buffer := Buffer + String(Socket.ReceiveText);

          Sleep(ProcessingSlack);
        end;

        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 12);

        FoldersAndFiles      := TStringList.Create;
        FoldersAndFiles.Text := Copy(BufferTemp, 1, Pos('<|ENDFILESLIST|>', BufferTemp) - 1);
        FoldersAndFiles.Sort;

        for i := 0 to FoldersAndFiles.count - 1 do
        begin
          Synchronize(
            procedure
            begin
              L := frm_ShareFiles.ShareFiles_ListView.Items.Add;
              L.Caption := FoldersAndFiles.Strings[i];
              Extension := LowerCase(ExtractFileExt(L.Caption));
              if (Extension = '.exe') then
                L.ImageIndex := 3
              else if (Extension = '.txt') then
                L.ImageIndex := 4
              else if (Extension = '.rar') then
                L.ImageIndex := 5
              else if (Extension = '.mp3') then
                L.ImageIndex := 6
              else if (Extension = '.zip') then
                L.ImageIndex := 7
              else if (Extension = '.jpg') then
                L.ImageIndex := 8
              else if (Extension = '.bat') then
                L.ImageIndex := 9
              else if (Extension = '.xml') then
                L.ImageIndex := 10
              else if (Extension = '.sql') then
                L.ImageIndex := 11
              else if (Extension = '.html') then
                L.ImageIndex := 12
              else if (Extension = '.xls') then
                L.ImageIndex := 13
              else if (Extension = '.png') then
                L.ImageIndex := 14
              else if (Extension = '.doc') then
                L.ImageIndex := 15
              else if (Extension = '.docx') then
                L.ImageIndex := 15
              else if (Extension = '.pdf') then
                L.ImageIndex := 16
              else if (Extension = '.dll') then
                L.ImageIndex := 17
              else
                L.ImageIndex := 2;

              frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
            end);

          Sleep(5); // Effect
        end;
        FreeAndNil(FoldersAndFiles);

        Synchronize(
          procedure
          begin
            frm_ShareFiles.Directory_Edit.Enabled := true;
            frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
          end);

      end;

      Position := Pos('<|UPLOADPROGRESS|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 17);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        Synchronize(
          procedure
          begin
            frm_ShareFiles.Upload_ProgressBar.Position := StrToInt(BufferTemp);
            frm_ShareFiles.SizeUpload_Label.Caption := 'Size: ' + GetSize(frm_ShareFiles.Upload_ProgressBar.Position) + ' / ' + GetSize(frm_ShareFiles.Upload_ProgressBar.Max);
          end);
      end;

      if Buffer.Contains('<|UPLOADCOMPLETE|>') then
      begin
        Synchronize(
          procedure
          begin
            with frm_ShareFiles do
            begin
              Upload_ProgressBar.Position := 0;
              Upload_BitBtn.Enabled := true;
              Directory_Edit.Enabled := False;
              frm_ShareFiles.SizeUpload_Label.Caption := 'Size: 0 B / 0 B';
            end;
          end);

        frm_Main.Main_Socket.Socket.SendText(AnsiString('<|REDIRECT|><|GETFOLDERS|>' + frm_ShareFiles.Directory_Edit.Text + '<|END|>'));

        Synchronize(
          procedure
          begin
            MessageBox(0, 'File sent!', 'AllaKore Remote - Share Files', MB_ICONASTERISK + MB_TOPMOST);
          end);
      end;

      Position := Pos('<|DOWNLOADFILE|>', Buffer);
      if Position > 0 then
      begin
        BufferTemp := Buffer;

        Delete(BufferTemp, 1, Position + 15);

        BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

        FileToUpload := TFileStream.Create(BufferTemp, fmOpenRead);
        frm_Main.Files_Socket.Socket.SendText(AnsiString('<|SIZE|>' + IntToStr(FileToUpload.Size) + '<|END|>'));
        frm_Main.Files_Socket.Socket.SendStream(FileToUpload);
      end;

    except
    end;

  end;
end;

procedure TThread_Connection_Keyboard.Execute;
var
  Buffer: string;
begin

  try

    while Socket.Connected do
    begin

      Sleep(ProcessingSlack); // Avoids using 100% CPU

      if Socket.ReceiveLength < 1 then
        Continue;

      Buffer := String(Socket.ReceiveText);

      // Combo Keys
      if Buffer.Contains('<|ALTDOWN|>') then
      begin
        Buffer := StringReplace(Buffer, '<|ALTDOWN|>', '', [rfReplaceAll]);
        keybd_event(18, 0, 0, 0);
      end;

      if Buffer.Contains('<|ALTUP|>') then
      begin
        Buffer := StringReplace(Buffer, '<|ALTUP|>', '', [rfReplaceAll]);
        keybd_event(18, 0, KEYEVENTF_KEYUP, 0);
      end;

      if Buffer.Contains('<|CTRLDOWN|>') then
      begin
        Buffer := StringReplace(Buffer, '<|CTRLDOWN|>', '', [rfReplaceAll]);
        keybd_event(17, 0, 0, 0);
      end;

      if Buffer.Contains('<|CTRLUP|>') then
      begin
        Buffer := StringReplace(Buffer, '<|CTRLUP|>', '', [rfReplaceAll]);
        keybd_event(17, 0, KEYEVENTF_KEYUP, 0);
      end;

      if Buffer.Contains('<|SHIFTDOWN|>') then
      begin
        Buffer := StringReplace(Buffer, '<|SHIFTDOWN|>', '', [rfReplaceAll]);
        keybd_event(16, 0, 0, 0);
      end;

      if Buffer.Contains('<|SHIFTUP|>') then
      begin
        Buffer := StringReplace(Buffer, '<|SHIFTUP|>', '', [rfReplaceAll]);
        keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
      end;

      if Buffer.Contains('?') then
      begin
        if GetKeyState(VK_SHIFT) < 0 then
        begin
          keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
          SendKeys(PWideChar(Buffer), False);
          keybd_event(16, 0, 0, 0);
        end;

      end
      else
        SendKeys(PWideChar(Buffer), False);

    end;

  except
  end;

end;

// Connection of Desktop screens
procedure TThread_Connection_Desktop.Execute;
var
  Position    : Integer;
  Buffer      : string;
  TempBuffer  : string;
  MyFirstBmp  : TMemoryStream;
  PackStream  : TMemoryStream;
  MyTempStream: TMemoryStream;
  UnPackStream: TMemoryStream;
  MyCompareBmp: TMemoryStream;
  MySecondBmp : TMemoryStream;

begin
  inherited;

  MyFirstBmp   := TMemoryStream.Create;
  UnPackStream := TMemoryStream.Create;
  MyTempStream := TMemoryStream.Create;
  MySecondBmp  := TMemoryStream.Create;
  MyCompareBmp := TMemoryStream.Create;
  PackStream   := TMemoryStream.Create;

  try

    while true do
    begin

      Sleep(ProcessingSlack); // Avoids using 100% CPU

      if not Socket.Connected then
        break;

      if Socket.ReceiveLength < 1 then
        Continue;

      try

        Buffer := Buffer + String(Socket.ReceiveText); // Accommodates in memory all images that are being received and not processed. This helps in smoothing and mapping so that changes in the wrong places do not occur.

        Position := Pos('<|GETFULLSCREENSHOT|>', Buffer);
        if Position > 0 then
        begin

          Delete(Buffer, 1, Position + 20);

          ResolutionWidth  := Screen.Width;
          ResolutionHeight := Screen.Height;

          frm_Main.Main_Socket.Socket.SendText(AnsiString('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Width) + '<|>' + IntToStr(Screen.Height) + '<|END|>'));

          MyFirstBmp.Clear;
          UnPackStream.Clear;
          MyTempStream.Clear;
          MySecondBmp.Clear;
          MyCompareBmp.Clear;
          PackStream.Clear;

          Synchronize(
            procedure
            begin
              GetScreenToMemoryStream(true, MyFirstBmp);
            end);

          MyFirstBmp.Position := 0;
          PackStream.LoadFromStream(MyFirstBmp);

          CompressStreamWithZLib(PackStream);

          PackStream.Position := 0;

          Socket.SendText(AnsiString('<|IMAGE|>' + MemoryStreamToString(PackStream) + '<|END|>'));

          while Socket.Connected do
          begin

            with frm_Main do
            begin

              // Streaming Images is relative to ping. This reduces CPU consumption.
              if MyPing > 60 then
                Sleep(MyPing div 2)
              else
                Sleep(30);
              //

            end;

            Synchronize(
              procedure
              begin
                GetScreenToMemoryStream(true, MySecondBmp);
              end);

            CompareStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

            MyCompareBmp.Position := 0;
            PackStream.LoadFromStream(MyCompareBmp);

            CompressStreamWithZLib(PackStream);

            PackStream.Position := 0;

            while Socket.SendText(AnsiString('<|IMAGE|>' + MemoryStreamToString(PackStream) + '<|END|>')) < 0 do
              Sleep(ProcessingSlack);

          end;

        end;

        if Buffer.Contains('<|GETPARTSCREENSHOT|>') then // Deprecated
        begin

          Synchronize(
            procedure
            begin
              GetScreenToMemoryStream(true, MySecondBmp);
            end);

          CompareStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

          MyCompareBmp.Position := 0;
          PackStream.LoadFromStream(MyCompareBmp);

          CompressStreamWithZLib(PackStream);

          PackStream.Position := 0;

          while Socket.SendText(AnsiString('<|IMAGE|>' + MemoryStreamToString(PackStream) + '<|END|>')) < 0 do
            Sleep(ProcessingSlack);

        end;

        // Processes all Buffer that is in memory.
        while Buffer.Contains('<|END|>') do
        begin

          try

            Delete(Buffer, 1, Pos('<|IMAGE|>', Buffer) + 8);

            Position   := Pos('<|END|>', Buffer);
            TempBuffer := Copy(Buffer, 1, Position - 1);
            MyTempStream.Write(AnsiString(TempBuffer)[1], Length(TempBuffer));
            Delete(Buffer, 1, Position + 6); // Clears the memory of the image that was processed.

            MyTempStream.Position := 0;
            UnPackStream.LoadFromStream(MyTempStream);

            DeCompressStreamWithZLib(UnPackStream);

            if (MyFirstBmp.Size = 0) then
            begin

              MyFirstBmp.LoadFromStream(UnPackStream);
              MyFirstBmp.Position := 0;

              Synchronize(
                procedure
                begin
                  frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(MyFirstBmp);

                  if (frm_RemoteScreen.Resize_CheckBox.Checked) then
                    ResizeBmp(frm_RemoteScreen.Screen_Image.Picture.Bitmap, frm_RemoteScreen.Screen_Image.Width, frm_RemoteScreen.Screen_Image.Height);

                  frm_RemoteScreen.Caption := 'AllaKore Remote (Ping: ' + IntToStr(frm_Main.MyPing) + ' ms)';
                end);

            end
            else
            begin

              MyCompareBmp.Clear;
              MySecondBmp.Clear;

              MyCompareBmp.LoadFromStream(UnPackStream);
              ResumeStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

              Synchronize(
                procedure
                begin
                  frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(MySecondBmp);

                  if (frm_RemoteScreen.Resize_CheckBox.Checked) then
                    ResizeBmp(frm_RemoteScreen.Screen_Image.Picture.Bitmap, frm_RemoteScreen.Screen_Image.Width, frm_RemoteScreen.Screen_Image.Height);

                  frm_RemoteScreen.Caption := 'AllaKore Remote (Ping: ' + IntToStr(frm_Main.MyPing) + ' ms)';
                end);
            end;

            UnPackStream.Clear;
            MyTempStream.Clear;
            MySecondBmp.Clear;
            MyCompareBmp.Clear;
            PackStream.Clear;

          except

          end;

        end;

      except
        On E: Exception do
        begin

        end;

      end;

    end;

  finally

    FreeAndNil(MyFirstBmp);
    FreeAndNil(UnPackStream);
    FreeAndNil(MyTempStream);
    FreeAndNil(MySecondBmp);
    FreeAndNil(MyCompareBmp);
    FreeAndNil(PackStream);

  end;

end;

// Connection of Share Files
procedure TThread_Connection_Files.Execute;
var
  Position     : Integer;
  FileSize     : Int64;
  ReceivingFile: Boolean;
  Buffer       : string;
  BufferTemp   : string;
  FileStream   : TFileStream;
begin
  inherited;

  ReceivingFile := False;
  FileStream    := nil;

  try

    while Socket.Connected do
    begin

      Sleep(ProcessingSlack); // Avoids using 100% CPU

      try
        if Socket.ReceiveLength < 1 then
          Continue;

        Buffer := String(Socket.ReceiveText);

        if not(ReceivingFile) then
        begin

          Position := Pos('<|DIRECTORYTOSAVE|>', Buffer);
          if Position > 0 then
          begin
            BufferTemp := Buffer;

            Delete(BufferTemp, 1, Position + 18);

            Position   := Pos('<|>', BufferTemp);
            BufferTemp := Copy(BufferTemp, 1, Position - 1);

            frm_ShareFiles.DirectoryToSaveFile := BufferTemp;
          end;

          Position := Pos('<|SIZE|>', Buffer);
          if Position > 0 then
          begin
            BufferTemp := Buffer;

            Delete(BufferTemp, 1, Position + 7);

            BufferTemp := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

            FileSize   := StrToInt(BufferTemp);
            FileStream := TFileStream.Create(frm_ShareFiles.DirectoryToSaveFile + '.tmp', fmCreate or fmOpenReadWrite);

            if (frm_Main.Viewer) then
              Synchronize(
                procedure
                begin
                  frm_ShareFiles.Download_ProgressBar.Max := FileSize;
                  frm_ShareFiles.Download_ProgressBar.Position := 0;
                  frm_ShareFiles.SizeDownload_Label.Caption := 'Size: ' + GetSize(FileStream.Size) + ' / ' + GetSize(FileSize);
                end);

            Delete(Buffer, 1, Pos('<|END|>', Buffer) + 6);
            ReceivingFile := true;
          end;
        end;

        if (Length(Buffer) > 0) and (ReceivingFile) then
        begin
          FileStream.Write(AnsiString(Buffer)[1], Length(Buffer));

          if (frm_Main.Viewer) then
            Synchronize(
              procedure
              begin
                frm_ShareFiles.Download_ProgressBar.Position := FileStream.Size;
                frm_ShareFiles.SizeDownload_Label.Caption := 'Size: ' + GetSize(FileStream.Size) + ' / ' + GetSize(FileSize);
              end)

          else
          begin
            while frm_Main.Main_Socket.Socket.SendText(AnsiString('<|REDIRECT|><|UPLOADPROGRESS|>' + IntToStr(FileStream.Size) + '<|END|>')) < 0 do
              Sleep(ProcessingSlack);
          end;

          if (FileStream.Size = FileSize) then
          begin
            FreeAndNil(FileStream);

            if (FileExists(frm_ShareFiles.DirectoryToSaveFile)) then
              DeleteFile(frm_ShareFiles.DirectoryToSaveFile);

            RenameFile(frm_ShareFiles.DirectoryToSaveFile + '.tmp', frm_ShareFiles.DirectoryToSaveFile);

            if not(frm_Main.Viewer) then
              frm_Main.Main_Socket.Socket.SendText(AnsiString('<|REDIRECT|><|UPLOADCOMPLETE|>'))
            else
              Synchronize(
                procedure
                begin
                  frm_ShareFiles.Download_ProgressBar.Position := 0;
                  frm_ShareFiles.Download_BitBtn.Enabled := true;
                  frm_ShareFiles.SizeDownload_Label.Caption := 'Size: 0 B / 0 B';
                  MessageBox(0, 'Download complete!', 'AllaKore Remote - Share Files', MB_ICONASTERISK + MB_TOPMOST);
                end);

            ReceivingFile := False;
          end;

        end;

      except

      end;

    end;

  finally
    FreeAndNil(FileStream);
  end;

end;

end.
