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
    Panel4: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    OpenGrid: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorSelect(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
  private
    { Déclarations privées }
    MousePos:TPoint;
    LogiColor:TLogiColor;
    SelColor:integer;
    TailleCase:integer;
    GridRect:trect;  // rectangle englobant la grille totale
    ColBlocsRect:TRect;  // rectangle englobant tous les blocs du haut (colonnes)
    RowBlocsRect:TRect; // rectangle englobant tous les blocs de gauche (lignes)
    Colblocs:array of TCompactLine;
    Rowblocs:array of TCompactLine;
    procedure CreateGrid;
    procedure DrawCase(x,y:integer;c1:integer;c2:tcolor);
    procedure ConvertXYtoGrid(var x,y:integer);
    procedure DrawRowCode(row:integer);
    procedure DrawColCode(Col:integer);
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

// crée le dessin et les blocs
procedure TForm1.CreateGrid;
var
 maxBloc:integer;
 i,j,n:integer;
 r:trect;
 s:string;
 pan:tpanel;
begin
 // calcul la taille de la grille
 r.TopLeft:=point(0,0);
 r.Right:=LogiColor.Width*TailleCase+LogiColor.Width div 5;
 r.bottom:=LogiColor.Height*TailleCase+LogiColor.Height div 5;
 GridRect:=r;

 // calcul la taille de TopBlocs
 Setlength(Colblocs,LogiColor.Width);
 for i:=0 to LogiColor.Width-1 do
   Colblocs[i]:=Compact(LogiColor.OriginalCol[i]);
 maxBloc:=0;
 for i:=0 to LogiColor.Width-1 do
  if length(Colblocs[i])>maxBloc then maxBloc:=length(Colblocs[i]);
 ColBlocsRect:=rect(0,0,GridRect.Right,maxbloc*TailleCase);

 // calcul la taille de LeftBlocs
 Setlength(Rowblocs,LogiColor.Height);
 for i:=0 to LogiColor.Height-1 do
   Rowblocs[i]:=Compact(LogiColor.OriginalRow[i]);
 maxBloc:=0;
 for i:=0 to LogiColor.Height-1 do
  if length(Rowblocs[i])>maxBloc then maxBloc:=length(Rowblocs[i]);
 RowBlocsRect:=rect(0,0,maxbloc*TailleCase,GridRect.Bottom);

 // décale chaque bloc à sa place
 offsetrect(GridRect,RowBlocsRect.Right,ColBlocsRect.Bottom);
 offsetrect(RowBlocsRect,0,ColBlocsRect.Bottom);
 offsetrect(ColBlocsRect,RowBlocsRect.Right,0);
 
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
   DrawCase(i,j,LogiColor.Find[i,j],clblack);

 //dessine les blocs du haut et de gauche
 image1.Canvas.Font.Height:=TailleCase*18 div 20;

 for i:=0 to LogiColor.Width-1 do
  begin
   n:=high(Colblocs[i])+1;
   for j:=0 to n-1 do
    begin
     s:=inttostr(Colblocs[i][j].Count);
     r.Left:=ColBlocsRect.Left+i*TailleCase+i div 5+1;
     r.Top:=ColBlocsRect.Bottom-(n-j)*TailleCase+1;
     r.Right:=r.Left+TailleCase-2;
     r.Bottom:=r.Top+TailleCase-2;
     image1.Canvas.Brush.color:=LogiColor.Color[Colblocs[i][j].color];
     image1.Canvas.TextRect(r,r.Left+(TailleCase-2-image1.Canvas.TextWidth(s)) div 2,r.top,s);
    end;
  end;

 for i:=0 to LogiColor.height-1 do
  begin
   n:=high(Rowblocs[i])+1;
   for j:=0 to n-1 do
    begin
     s:=inttostr(Rowblocs[i][j].Count);
     r.Left:=RowBlocsRect.right-(n-j)*TailleCase+1;
     r.top:=RowBlocsRect.top+i*TailleCase+i div 5+1;
     r.Right:=r.Left+TailleCase-2;
     r.Bottom:=r.Top+TailleCase-2;
     image1.Canvas.Brush.color:=LogiColor.Color[Rowblocs[i][j].color];
     image1.Canvas.TextRect(r,r.Left+(TailleCase-2-image1.Canvas.TextWidth(s)) div 2,r.top,s);
    end;
  end;


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
   pan.Top:=(i+1)*40+8;
   pan.Left:=8;
   pan.OnClick:=ColorSelect;

   if i=1 then
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
 line:=Compact(LogiColor.FindRow[row]);

 imagerow.Canvas.Brush.Color:=clbtnface;
 imagerow.Canvas.FillRect(imagerow.ClientRect);
 imagerow.Canvas.Font.Height:=TailleCode*18 div 20;
 n:=length(Rowblocs[row]);
 for i:=0 to n-1 do
    begin
     s:=inttostr(Rowblocs[row][i].Count);
     r.Left:=ImageRow.Width-(n-i)*TailleCode+1;
     r.top:=0;
     r.Right:=r.Left+TailleCode;
     r.Bottom:=TailleCode;
     imagerow.Canvas.Brush.color:=LogiColor.Color[Rowblocs[Row][i].color];
     imagerow.Canvas.TextRect(r,r.Left+(TailleCode-2-imageRow.Canvas.TextWidth(s)) div 2,r.top,s);
    end;

 n:=length(line);
 for i:=0 to n-1 do
    begin
     s:=inttostr(line[i].Count);
     r.Left:=ImageRow.Width-(n-i)*TailleCode+1;
     r.top:=TailleCode+1;
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
 line:=Compact(LogiColor.FindCol[Col]);

 imageCol.Canvas.Brush.Color:=clbtnface;
 imageCol.Canvas.FillRect(imageCol.ClientRect);
 imageCol.Canvas.Font.Height:=TailleCode*18 div 20;
 n:=length(Colblocs[Col]);
 for i:=0 to n-1 do
    begin
     s:=inttostr(Colblocs[Col][i].Count);
     r.Left:=0;
     r.top:=ImageCol.Height-(n-i)*TailleCode+1;
     r.Right:=r.Left+TailleCode;
     r.Bottom:=r.Top+TailleCode;
     imageCol.Canvas.Brush.color:=LogiColor.Color[Colblocs[Col][i].color];
     imageCol.Canvas.TextRect(r,r.Left+(TailleCode-2-imageCol.Canvas.TextWidth(s)) div 2,r.top,s);
    end;

 n:=length(line);
 for i:=0 to n-1 do
    begin
     s:=inttostr(Line[i].Count);
     r.Left:=TailleCode;
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
 SelColor:=1;
 MousePos:=point(-1,-1);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not ptinrect(gridrect,point(x,y)) then exit;
 ConvertXYtoGrid(x,y);

 //dessine les petites cases
 DrawCase(mousepos.X,mousepos.Y,LogiColor.Find[mousepos.X,mousepos.Y],clblack);
 DrawCase(x,y,-1,clwhite);
 DrawRowCode(y);
 DrawColCode(x);
 mousepos:=point(x,y);

 if (ssleft in Shift) or (ssright in shift) then
  begin
   if ssshift in shift then logicolor.Find[x,y]:=$FF
    else
   if ssleft in shift then logicolor.Find[x,y]:=SelColor
    else
   logicolor.Find[x,y]:=0;
  end;

 if logicolor.FindIsOk then
  MessageBox(handle,'Bravo, la grille est complète','Information',0);
end;


procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not ptinrect(gridrect,point(x,y)) then exit;
 ConvertXYtoGrid(x,y);
 if ssshift in shift then logicolor.Find[x,y]:=$FF
 else
 if button=mbLeft then logicolor.Find[x,y]:=SelColor
                  else logicolor.Find[x,y]:=0;

 if logicolor.FindIsOk then
  MessageBox(handle,'Bravo, la grille est complète','Information',0);
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

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if key in ['0'..'9'] then
  begin
   SelColor:=byte(key)-48;
   tpanel(panelcolor.Components[SelColor]).onclick(panelcolor.Components[SelColor]);
  end;

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
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
 LogiColor.eraseFind;
 CreateGrid;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
 if not opengrid.Execute then exit;
 LogiColor.LoadFromFile(opengrid.FileName);
 CreateGrid;
end;

end.

