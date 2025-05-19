unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, StdCtrls, Spin, ExtCtrls,Windows;

type
  Arraio = array [0..10000000] of byte;
  Pupixel = ^Arraio;
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    BrowseButton: TSpeedButton;
    Label3: TLabel;
    ProgressBar1: TProgressBar;
    Label4: TLabel;
    ProgressBar2: TProgressBar;
    Label6: TLabel;
    ProgressBar4: TProgressBar;
    Label7: TLabel;
    ProgressBar5: TProgressBar;
    Memo1: TMemo;
    RisX: TLabel;
    RisY: TLabel;
    SpinEdit1: TSpinEdit;
    Label8: TLabel;
    ConvertButton: TSpeedButton;
    Image1: TImage;
    Label1: TLabel;
    Label9: TLabel;
    DataButton: TSpeedButton;
    Stretching: TCheckBox;
    procedure BrowseButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DataButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
 avg:INTEGER;
 Procedure LoadPDSImage(LX,LY:integer;FileOrig:string);
 Procedure SavePDSImage(FileOrig,FileDest:string);
 Procedure CalculateAverage(var Min,Max,AVERAGE:integer);
 Procedure RemoveCCDNoise;

  end;

var
  SeekPosition:integer;
  Form1: TForm1;
  MinValue,MaxValue,lx,ly:integer;
  I:pupixel;
  LINEA:ARRAY[0..10000] OF INTEGER;
implementation

{$R *.lfm}


Procedure TForm1.CalculateAverage(var Min,Max,AVERAGE:integer);
 // Store in the array LINEA the avg value for each vertical line.
 // Store in AVERAGE the avg value of the entire image.
 // Store in Min,Max the Minimum and Maximum value found.
 var SUM2,O,V:integer;
     X:byte;
     sum:EXTENDED;
 begin
  SUM:=0;
  Min:=255;Max:=0;
  for O:=0 to LX-1 do
   begin
    ProgressBar2.Position:=100*O div (LX-1);
    SUM2:=0;
    for V:=0 to LY-1 do
     begin
     X:=i[O+v*LX];
     sum:=sum+x;
     INC(SUM2,X);
     if (X>Max) then
      Max:=X
     else
     if (X<Min) then
      Min:=X
     end;
     LINEA[O]:=SUM2*256 DIV LY;
   end;

  SUM:=SUM / (lx*ly);
  AVERAGE:=TRUNC(sum);
  ProgressBar2.Position:=0;
 end;


Procedure TForm1.RemoveCCDNoise;
  var v,o:integer;
      SumOffs,NumSum:integer;
      NN,AVG2:INTEGER;
      Stretch:BOOLEAN;

 begin
 Stretch:=Form1.Stretching.Checked;

 FOR O:=0 TO LX-1 DO
  BEGIN
   ProgressBar4.Position:=100*O div (LX-1);

   // CALCULATE AVG VALUE OF THE ADIACENT LINES
   SumOffs:=LINEA[O];
   AVG2:=0;NN:=0;
   FOR V:=-SpinEdit1.Value TO SpinEdit1.Value DO
    BEGIN
     IF ((O+v)>=0) AND ((O+V)<LX) and (V<>0) THEN
      BEGIN
      inc(AVG2,LINEA[O+v]);INC(NN);
      END;
    END;
    AVG2:=AVG2 div nn;

   // Cosmetic filter
   FOR V:=0 TO Ly-1 DO
    BEGIN
      NumSum:=i[O+v*LX]*Avg2 div SumOffs;
      if Stretch then
       NUMSUM:=(NumSum-MinValue)*256 div (MaxValue-MinValue);
      IF (NUMSUM<0) THEN NUMSUM:=0
       ELSE
        IF (NUMSUM>255) THEN
         NUMSUM:=255;
      i[O+v*LX]:=NUMSUM;
    END;

  END;
   ProgressBar4.Position:=0;
 end;


Procedure TForm1.SavePDSImage(FileOrig,FileDest:string);
     var X,Y:integer;
     B:array[0..1078] of integer;
     F:file;
     begin
      AssignFile(F,FileOrig);
      Reset(F,1);
      BlockRead(F,B,1078,X);
      CloseFile(F);
      AssignFile(F,FileDest);
      Rewrite(F,1);
      BlockWrite(F,B,1078);
      Seek(F,18);
      BlockWrite(F,LX,4);
      BlockWrite(F,LY,4);
      Seek(F,1078+LX-310);
       for Y:=0 to Ly-1 do
        begin
        ProgressBar5.Position:=100*Y div (Ly-1);
        BlockWrite(F,I^[(Ly-Y-1)*Lx],LX);
       end;
     CloseFile(F);
     ProgressBar5.Position:=0;
    end;

Procedure TForm1.LoadPDSImage(LX,LY:integer;FileOrig:string);
     var
     v:byte;
     C,X,Y,LastY,RappoX:integer;
     B:array [0..16384] of byte;
     F:file;
     Bm:Graphics.TBitmap;
     Rappo:double;
     begin
     Rappo:=Memo1.Height / Ly;
     RappoX:=Trunc(Rappo*Lx);
     Memo1.Visible:=False;
     LastY:=-1;
     Bm:=Graphics.TBitmap.Create; Bm.Width:=LX; Bm.Height:=2;

     AssignFile(F,FileOrig);
     Reset(F,1);
     GetMem(I,LX*LY);
     Seek(F,SeekPosition);
       for Y:=0 to Ly-1 do
        begin
        ProgressBar1.Position:=100*Y div (Ly-1);
        BlockRead(F,I^[(Ly-Y-1)*Lx],LX,X);

        if (LastY<>Trunc(Y*rappo)) then
        begin
         // Display a Scanline
         C:=0;
         For X:=0 to Lx-1 do
          begin
           v:=I[(Ly-Y-1)*Lx+X];
           B[C]:=v; inc(C); B[C]:=v; inc(C); B[C]:=v; inc(C);
          end;
          SetBitmapBits(Bm.Handle,lx*3,@B);
          SetStretchBltMode(Form1.Canvas.Handle,HALFTONE);
          StretchBlt(Form1.Canvas.Handle,Memo1.Left,Memo1.Top+LastY,RappoX-1,Trunc(Y*rappo)-LastY,
          Bm.Canvas.Handle,0,0,Lx-1,1,SRCCOPY);
          LastY:=Trunc(y*rappo);
         end;

       end;
     CloseFile(F);
     Bm.Free;
     ProgressBar1.Position:=0;
    end;

function ReadLnFromStream(Stream: TFileStream): string;
var
  Ch: Char;
  Line: string;
begin
  Line := '';
  while Stream.Read(Ch, 1) = 1 do
  begin
    if (Ch = #10) then // Fine riga trovata
      Break;
    if (Ch <> #13) then // Ignora il ritorno a capo
      Line := Line + Ch;
  end;
  Result := Line;
end;

procedure TForm1.BrowseButtonClick(Sender: TObject);
var F:TFileStream;
    BF:File;
S:string;
n:integer;
begin
if (OpenDialog1.Execute) then
 begin
  Edit1.Text:=OpenDialog1.FileName;
  if ( UpperCase(ExtractFileExt(OpenDialog1.FileName))='.IMQ') then
   begin
   WinExec(pchar(ExtractFileDir(ParamStr(0))+'\READMOC.EXE '+OpenDialog1.FileName+' '+
   Copy(OpenDialog1.FileName,1,length(OpenDialog1.FileName)-4)+'.IMG'),SW_MAXIMIZE);
   Edit1.Text:=Copy(OpenDialog1.FileName,1,length(OpenDialog1.FileName)-4)+'.IMG';
   Application.MessageBox('Press OK to continue.','',MB_OK);
   end;

  if ( UpperCase(ExtractFileExt(Edit1.Text))='.IMG') then
  begin
   F:= TFileStream.Create(Edit1.Text, fmOpenRead);
   S:='';n:=0;
   Memo1.Clear();
   while (S<>'END') and (F.Position<>F.Size) and (n<80) do
    begin
     inc(n);
     S := ReadLnFromStream(F);
     Memo1.Lines.Add(Trim(S));
    end;
   SeekPosition:=F.Position-10;
   FreeAndNil(F);
   RisX.Caption:=Copy(Memo1.Lines[Memo1.Lines.IndexOfName('LINES ')],8,10);
   RisY.Caption:=Copy(Memo1.Lines[Memo1.Lines.IndexOfName('LINE_SAMPLES ')],15,10);
   LY:=StrToIntDef(RisX.Caption,0);
   LX:=StrToIntDef(RisY.Caption,0);
  end
   else
  if ( UpperCase(ExtractFileExt(OpenDialog1.FileName))='.BMP') then
  begin
   Memo1.Clear();
   AssignFile(BF,Edit1.Text);
   Reset(BF,1);
   Seek(BF,18);
   BlockRead(BF,Lx,4);
   BlockRead(BF,Ly,4);
   CloseFile(Bf);
   if (Lx<=0) or (Lx>30000) or (Ly<=0) or (Ly>30000) then
    begin
     Lx:=0;Ly:=0;
    end
     else
    begin
    RisX.Caption:=IntToStr(Lx);
    RisY.Caption:=IntToStr(Ly);
    Memo1.Lines.Add('Loading BMP File ...');
    Memo1.Lines.Add('');
    Memo1.Lines.Add(Edit1.Text);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('LINES ='+IntToStr(LY));
    Memo1.Lines.Add('COLS  ='+IntToStr(LX));
    SeekPosition:=1078;
    end;

  end;

  if (Lx=0) or (Ly=0) then
   Begin
    Application.MessageBox('Not able to decode file.','',MB_OK);
    SeekPosition:=-1;
   end
   else
  LoadPDSImage(Lx,Ly,Edit1.Text);
 end;
end;

procedure TForm1.Button1Click(Sender: TObject);

begin
 if (Lx=0) or (Ly=0) or (SeekPosition=-1) then
  begin
  Application.MessageBox('Image not selected','',MB_OK);
  exit;
  end;
 LoadPDSImage(Lx,Ly,Edit1.text);
 SavePDSImage(ExtractFileDir(ParamStr(0))+'\Head.bmp',COPY(EDIT1.TEXT,1,LENGTH(EDIT1.TEXT)-3)+'orig.BMP');
 CalculateAverage(MinValue,MaxValue,avg);
 RemoveCCDNoise;
 SavePDSImage(ExtractFileDir(ParamStr(0))+'\Head.bmp',COPY(EDIT1.TEXT,1,LENGTH(EDIT1.TEXT)-3)+'BMP');
 FreeMem(I);
end;

procedure TForm1.DataButtonClick(Sender: TObject);
begin
Memo1.Visible:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//if GetDeviceCaps(0,COLORRES)<>24 then
// Application.MessageBox('This programs works better using a 16M(24bit) colors graphic mode.',
// pchar(IntToStr(GetDeviceCaps(0,COLORRES))),MB_OK);
end;

initialization
SeekPosition:=-1;
I:=NIL;
end.
