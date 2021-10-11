unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls, ExtCtrls,math,ULogiColor, Menus, Buttons;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ImageRow: TImage;
    Panel3: TPanel;
    ImageCol: TImage;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    PanelColor: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    OpenGrid: TOpenDialog;
    BitBtn7: TBitBtn;
    SaveGrid: TSaveDialog;
    ColorDialog1: TColorDialog;
    GroupBox1: TGroupBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    SpinEdit3: TSpinEdit;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorSelect(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Montreruncoupspossible1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
    MousePos:TPoint;
    LogiColor:TLogiColor;
    SelColor:integer;
    TailleCase:integer;
    GridRect:trect;  // rectangle englobant la grille totale
    procedure CreateGrid;
    procedure DrawCase(x,y:integer;c1:integer;c2:tcolor);
    procedure ConvertXYtoGrid(var x,y:integer);
    procedure DrawRowCode(row:integer);
    procedure DrawColCode(Col:integer);
    procedure CreatePanel;
  public
    { Déclarations publiques }
  end;


const
 TailleCode=25;

var
  Form1: TForm1;


implementation

{$R *.dfm}
procedure TForm1.ConvertXYtoGrid(var x,y:integer);
begin
 x:=(x-gridrect.Left)*5 div (taillecase*5+1);
 y:=(y-gridrect.Top)*5 div (taillecase*5+1);
end;

procedure TForm1.CreatePanel;
var
 i:integer;
 pan:tpanel;
begin
 // crée les panels pour la selection des couleurs
 while PanelColor.ComponentCount>0 do PanelColor.Components[0].Free;
 for i:=0 to LogiColor.ColorCount-1 do
  begin
   pan:=tpanel.Create(panelColor);
   pan.Name:='color'+inttostr(i);
   pan.Caption:=inttostr(i);
   pan.Parent:=PanelColor;
   pan.Width:=33;
   pan.Height:=33;
   pan.Tag:=i;
   pan.Color:=LogiColor.Color[i];
   pan.Font.Color:=LogiColor.PenColor[i];
   pan.Top:=i*40+8;
   pan.Left:=8;
   pan.OnClick:=ColorSelect;
   if i=Selcolor then
    begin
     pan.BevelOuter:=bvLowered;
     pan.BevelInner:=bvLowered;
    end
   else
    begin
     pan.BevelOuter:=bvRaised;
     pan.BevelInner:=bvRaised;
    end;
  end;
end;

// crée le dessin et les blocs
procedure TForm1.CreateGrid;
var
 maxBloc:integer;
 i,j,n:integer;
 r:trect;
 s:string;
begin
 // calcul la taille de la grille
 r.TopLeft:=point(0,0);
 r.Right:=LogiColor.Width*TailleCase+LogiColor.Width div 5;
 r.bottom:=LogiColor.Height*TailleCase+LogiColor.Height div 5;
 GridRect:=r;

 //création de l'image

 // mis à la bonne dimension
 image1.Canvas.Brush.Color:=clbtnface;
 image1.Width:=GridRect.Right;
 image1.Height:=GridRect.Bottom;
 image1.Picture.Bitmap.Width:=GridRect.Right;
 image1.Picture.Bitmap.Height:=GridRect.Bottom;

 image1.Canvas.FillRect(image1.ClientRect);
 //dessine les petites cases
 image1.Canvas.Brush.Color:=clwhite;
 image1.Canvas.pen.Color:=clblack;
 for j:=0 to LogiColor.Height-1 do
  for i:=0 to LogiColor.Width-1 do
   DrawCase(i,j,LogiColor.Original[i,j],clblack);
end;

procedure TForm1.DrawCase(x,y:integer;c1:integer;c2:tcolor);
var
 r:trect;
 c:tcolor;
begin
 if (x<0) or (y<0) or (x>=logicolor.Width) or (y>=logicolor.Height) then exit;
 r.Left:=GridRect.Left+x*TailleCase+(x div 5);
 r.Top:=GridRect.Top+y*TailleCase+(y div 5);
 r.right:=r.Left+TailleCase+1;
 r.Bottom:=r.Top+TailleCase+1;
 if c1<0 then c:=LogiColor.Color[SelColor] else c:=LogiColor.Color[c1];
 image1.canvas.brush.color:=c;
 image1.canvas.pen.color:=c2;
 image1.Canvas.Rectangle(r);
 if c1<0 then
  begin
   image1.Canvas.Pen.Color:=$FFFFFF-c;
   image1.Canvas.Ellipse(r);
  end;
  if c1=$FF then
  begin
   image1.Canvas.Pen.Color:=clblack;
   r.Left:=r.Left+TailleCase div 2-2;
   r.Top:=r.Top+TailleCase div 2-2;
   r.right:=r.Left+5;
   r.Bottom:=r.Top+5;
   image1.Canvas.Ellipse(r);
  end;
end;

procedure TForm1.DrawRowCode(row:integer);
var
 i,n:integer;
 line:TCompactLine;
 r:trect;
 s:string;
begin
 line:=Compact(LogiColor.OriginalRow[row]);
 imagerow.Canvas.Brush.Color:=clbtnface;
 imagerow.Canvas.FillRect(imagerow.ClientRect);
 imagerow.Canvas.Font.Height:=TailleCode*18 div 20;
 n:=length(line);
 for i:=0 to n-1 do
    begin
     s:=inttostr(line[i].Count);
     r.Left:=ImageRow.Width-(n-i)*TailleCode+1;
     r.top:=TailleCode div 2;
     r.Right:=r.Left+TailleCode;
     r.Bottom:=r.top+TailleCode;
     imagerow.Canvas.Brush.color:=LogiColor.Color[line[i].color];
     imagerow.Canvas.TextRect(r,r.Left+(TailleCode-2-imageRow.Canvas.TextWidth(s)) div 2,r.top,s);
    end;
end;

procedure TForm1.DrawColCode(Col:integer);
var
 i,n:integer;
 line:TCompactLine;
 r:trect;
 s:string;
begin
 line:=Compact(LogiColor.OriginalCol[Col]);

 imageCol.Canvas.Brush.Color:=clbtnface;
 imageCol.Canvas.FillRect(imageCol.ClientRect);
 imageCol.Canvas.Font.Height:=TailleCode*18 div 20;

 n:=length(line);
 for i:=0 to n-1 do
    begin
     s:=inttostr(Line[i].Count);
     r.Left:=TailleCode div 2;
     r.top:=ImageCol.Height-(n-i)*TailleCode+1;
     r.Right:=r.Left+TailleCode;
     r.Bottom:=r.Top+TailleCode;
     imageCol.Canvas.Brush.color:=LogiColor.Color[Line[i].color];
     imageCol.Canvas.TextRect(r,r.Left+(TailleCode-2-imageCol.Canvas.TextWidth(s)) div 2,r.top,s);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 LogiColor:=TLogiColor.create;
 image1.Canvas.Font.Name:='Courier New';
 image1.Canvas.Font.color:=clwhite;
 imageRow.Canvas.Font.Name:='Courier New';
 imageRow.Canvas.Font.color:=clwhite;
 imageCol.Canvas.Font.Name:='Courier New';
 imageCol.Canvas.Font.color:=clwhite;
 TailleCase:=20;
 creategrid;
 CreatePanel;
 SelColor:=1;
 MousePos:=point(-1,-1);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not ptinrect(gridrect,point(x,y)) then exit;
 ConvertXYtoGrid(x,y);

 //dessine les petites cases
 DrawCase(mousepos.X,mousepos.Y,LogiColor.Original[mousepos.X,mousepos.Y],clblack);
 DrawCase(x,y,-1,clwhite);
 DrawRowCode(y);
 DrawColCode(x);
 mousepos:=point(x,y);

 if ssleft in shift then logicolor.Original[x,y]:=SelColor
  else
 if ssright in shift then logicolor.Original[x,y]:=0;
end;


procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not ptinrect(gridrect,point(x,y)) then exit;
 ConvertXYtoGrid(x,y);

 if button=mbLeft then logicolor.Original[x,y]:=SelColor
                  else logicolor.Original[x,y]:=0;
 DrawRowCode(y);
 DrawColCode(x);
end;

procedure TForm1.ColorSelect(Sender: TObject);
var
 i:integer;
begin
 Selcolor:=TPanel(sender).Tag;
 for i:=0 to PanelColor.ComponentCount-1 do
 if TPanel(PanelColor.Components[i]).tag=Selcolor then
  begin
   TPanel(PanelColor.Components[i]).BevelOuter:=bvLowered;
   TPanel(PanelColor.Components[i]).BevelInner:=bvLowered;
  end
 else
  begin
   TPanel(PanelColor.Components[i]).BevelOuter:=bvRaised;
   TPanel(PanelColor.Components[i]).BevelInner:=bvRaised;
  end;

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
 c:tcase;
 i,j:integer;
begin
 if MessageBox(handle,'Cette Commande peut être très longue sur '
 +'des images couleurs de grande taille. '+
 'L''exécuter quand même ?','Attention',MB_YESNO)<>mrYes then exit;

 // efface la grille
 for j:=0 to Logicolor.Height-1 do
 for i:=0 to Logicolor.Width-1 do
 DrawCase(i,j,0,clblack);
 logicolor.EraseFind;
 c:=logicolor.FindNextPossible;
 while c.x<>-1 do
  begin
   logicolor.Find[c.x,c.y]:=c.c;
   DrawCase(c.x,c.y,c.c,clblack);
   image1.Update;
   c:=logicolor.FindNextPossible;
  end;
 image1.Update; 
 if logicolor.FindIsOk then
 MessageBox(handle,'Grille Valide','Information',0)
 else
 MessageBox(handle,'Grille non Valide. Plusieurs Solutions sont possibles','Information',0);
 CreateGrid;
end;

procedure TForm1.Montreruncoupspossible1Click(Sender: TObject);
var
 c:tcase;
begin
 c:=logicolor.FindNextPossible;
 if c.x=-1 then exit;
 logicolor.Find[c.x,c.y]:=c.c;
 DrawCase(c.x,c.y,c.c,clblack);
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
 TailleCase:=TailleCase-1;
 if TailleCase<10 then TailleCase:=10;
 CreateGrid;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
 TailleCase:=TailleCase+1;
 if TailleCase>40 then TailleCase:=40;
 CreateGrid;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
 close;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
 LogiColor.EraseOriginal;
 CreateGrid;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
 if not opengrid.Execute then exit;
 LogiColor.LoadFromFile(opengrid.FileName);
 CreateGrid;
end;

procedure TForm1.BitBtn7Click(Sender: TObject);
begin
 if not SaveGrid.Execute then exit;
 LogiColor.SaveToFile(SaveGrid.FileName);
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
var
 taille:integer;
begin
 try
 LogiColor.Width:=Spinedit1.Value;
 LogiColor.Height:=Spinedit2.Value;
 CreateGrid;
 except
 end;
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
begin

 LogiColor.ColorCount:=SpinEdit3.Value;
 CreatePanel;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 c1,c2:tcolor;
 i:integer;
begin
 Colordialog1.Color:=Logicolor.Color[SelColor];
 if not Colordialog1.Execute then exit;
 c1:=Colordialog1.Color;
 Colordialog1.Color:=Logicolor.PenColor[SelColor];
 if not Colordialog1.Execute then exit;
 c2:=Colordialog1.Color;
 Logicolor.Color[SelColor]:=c1;
 Logicolor.PenColor[SelColor]:=c2;

 for i:=0 to PanelColor.ComponentCount-1 do
  if PanelColor.Components[i].Name='color'+Inttostr(SelColor) then
   begin
    TPanel(PanelColor.Components[i]).Color:=c1;
    TPanel(PanelColor.Components[i]).Font.Color:=c2;
   end;
end;

end.

