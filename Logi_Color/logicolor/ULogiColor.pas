unit ULogiColor;

interface

uses Windows,Graphics,Types,SysUtils,classes;

type
 TBloc=record Count,color:byte; end;
 TLine=array of byte;
 TCompactLine=array of TBloc;
 TCase=record x,y:integer;c:byte; end;

// une case = 0..n pour une couleur (0=vide ou inconnue)
// une case = $FF pour un marqueur (qui veut dire vide mais dans on sais qu'elle est vide)

type
 TLogiColor=class
  private
   FSize:TPoint;
   FColor:array of TColor;
   FPenColor:array of TColor;
   FOriginal:TLine;
   FFind:TLine;
   Function GetOriginal(x,y:integer):byte;
   Procedure SetOriginal(x,y:integer;Value:byte);
   Function GetFind(x,y:integer):byte;
   Procedure SetFind(x,y:integer;Value:byte);
   Function GetOriginalRow(Row:integer):TLine;
   Function GetOriginalCol(Col:integer):TLine;
   Function GetFindRow(Row:integer):TLine;
   Function GetFindCol(Col:integer):TLine;
   function GetColor(index:integer):tcolor;
   function GetPenColor(index:integer):tcolor;
   function GetColorCount:integer;
   procedure SetWidth(value:integer);
   procedure SetHeight(value:integer);
   procedure SetColorCount(value:integer);
   procedure SetColor(index:integer;Value:TColor);
   procedure SetPenColor(index:integer;Value:TColor);
   function FindPossible(line:TcompactLine;Contrainte:TLine;PossibleColor:array of TCompactLine):TLine;
  protected
  public
   Property Original[X, Y: Integer]:byte read GetOriginal write SetOriginal;
   Property Find[X, Y: Integer]:byte read GetFind write SetFind;
   Property OriginalRow[Row:integer]:TLine read GetOriginalRow;
   Property OriginalCol[Col:integer]:TLine read GetOriginalCol;
   Property FindRow[Row:integer]:TLine read GetFindRow;
   Property FindCol[Col:integer]:TLine read GetFindCol;
   Property Width:integer read FSize.x write SetWidth;
   Property Height:integer read FSize.y write SetHeight;
   property Color[index:integer]:TColor read GetColor write SetColor;
   property ColorCount:integer read GetColorCount write SetColorCount;
   property PenColor[index:integer]:TColor read GetPenColor write SetPenColor;
   procedure LoadFromFile(s:string);
   procedure SaveToFile(s:string);
   constructor create;
   destructor Destroy;
   function FindIsOk:boolean;
   function FindNextPossible:TCase;
   Procedure EraseFind;
   Procedure EraseOriginal;
  end;


Function Compact(line:tline):TCompactLine;

implementation


Function Compact(line:TLine):TCompactLine;
var
 i,count,color,pos:integer;
begin
 setlength(result,high(line)+1);
 if length(result)=0 then exit;
 color:=line[0];
 count:=1;
 pos:=0;
 for i:=1 to high(line) do
  begin
   if line[i]<>color then
    begin
     if (color<>0) and (color<>$FF) then
      begin
       result[pos].Count:=count;
       result[pos].color:=color;
       inc(pos);
      end;
     color:=line[i];
     count:=0;
    end;
   inc(count);
  end;
 if (color<>0) and (color<>$FF) then
  begin
   result[pos].Count:=count;
   result[pos].color:=color;
   inc(pos);
  end;
 setlength(result,pos);
end;



constructor TLogiColor.create;
begin
 inherited;
 setlength(FColor,2);
 setlength(FPenColor,2);
 FColor[0]:=clwhite;
 FColor[1]:=clblack;
 FPenColor[0]:=ClBlack;
 FPenColor[1]:=clwhite;
 FSize:=point(0,0);
 setlength(FOriginal,0);
 setlength(FFind,0);
end;

destructor TLogiColor.Destroy;
begin
 inherited;
 setlength(foriginal,0);
 setlength(ffind,0);
 setlength(fcolor,0);
end;

// retourne la case (x,y) de foriginal
Function TLogiColor.GetOriginal(x,y:integer):byte;
begin
 if (x>=0) and (y>=0) and (x<FSize.x) and (y<FSize.y) then
  result:=FOriginal[x+y*FSize.x];
end;

// défini la case (x,y) de foriginal
Procedure TLogiColor.SetOriginal(x,y:integer;Value:byte);
begin
 if (x>=0) and (y>=0) and (x<FSize.x) and (y<FSize.y) then
  FOriginal[x+y*FSize.x]:=Value;
end;

// retourne la case (x,y) de ffind
Function TLogiColor.GetFind(x,y:integer):byte;
begin
 if (x>=0) and (y>=0) and (x<FSize.x) and (y<FSize.y) then
  result:=FFind[x+y*FSize.x];
end;

// defini la case (x,y) de ffind
Procedure TLogiColor.SetFind(x,y:integer;Value:byte);
begin
 if (x>=0) and (y>=0) and (x<FSize.x) and (y<FSize.y) then
  FFind[x+y*FSize.x]:=Value;
end;

// extrait la ligne row du tableau FOriginal
Function TLogiColor.GetOriginalRow(Row:integer):TLine;
var
 i:integer;
begin
 setlength(result,0);
 if (row<0) or (row>=FSize.Y) then exit;
 setlength(result,fsize.X);
 for i:=0 to fsize.x-1 do
  result[i]:=Foriginal[fsize.x*row+i];
end;

// extrait la ligne row du tableau FFind
Function TLogiColor.GetFindRow(Row:integer):TLine;
var
 i:integer;
begin
 setlength(result,0);
 if (row<0) or (row>=FSize.Y) then exit;
 setlength(result,fsize.X);
 for i:=0 to fsize.x-1 do
  result[i]:=ffind[fsize.x*row+i];
end;

// extrait la colonne col du tableau FOriginal
Function TLogiColor.GetOriginalCol(col:integer):TLine;
var
 i:integer;
begin
 setlength(result,0);
 if (col<0) or (col>=FSize.x) then exit;
 setlength(result,fsize.y);
 for i:=0 to fsize.Y-1 do result[i]:=fOriginal[fsize.x*i+col];
end;

// extrait la colonne col du tableau FFind
Function TLogiColor.GetFindCol(col:integer):TLine;
var
 i:integer;
begin
 setlength(result,0);
 if (col<0) or (col>=FSize.x) then exit;
 setlength(result,fsize.y);
 for i:=0 to fsize.Y-1 do result[i]:=ffind[fsize.x*i+col];
end;


Procedure TLogiColor.LoadFromFile(s:string);
var
 f:integer;
 l:byte;
 key:string;
begin
 f:=FileOpen(s,fmopenread);
 if f=-1 then exit;
 key:='LogiColor';
 fileread(f,key[1],9);
 if key='LogiColor' then
  begin
   fileread(f,fsize,sizeof(tpoint));
   setlength(FOriginal,fsize.X*fsize.Y);
   setlength(FFind,fsize.X*fsize.Y);
   fileread(f,FOriginal[0],fsize.X*fsize.Y);
   fillchar(ffind[0],fsize.X*fsize.Y,0);
   fileread(f,l,1);
   setlength(FColor,l);
   setlength(FPenColor,l);
   fileread(f,FColor[0],sizeof(TColor)*l);
   fileread(f,FPenColor[0],sizeof(TColor)*l);
  end;
 fileclose(f);
end;

Procedure TLogiColor.SaveToFile(s:string);
var
 f:integer;
 l:byte;
 key:string;
begin
 f:=FileOpen(s,fmcreate);
 if f=-1 then f:=filecreate(s);
 if f=-1 then exit;
 key:='LogiColor';
 filewrite(f,key[1],9);
 filewrite(f,fsize,sizeof(tpoint));
 filewrite(f,FOriginal[0],fsize.X*fsize.Y);
 l:=length(FColor);
 filewrite(f,l,1);
 filewrite(f,FColor[0],sizeof(TColor)*l);
 l:=length(FPenColor);
 filewrite(f,FPenColor[0],sizeof(TColor)*l);
 fileclose(f);
end;

function TLogiColor.GetColor(index:integer):tcolor;
begin
 result:=clwhite;
 if index=$FF then result:=FColor[0];
 if (index<0) or (index>=length(FColor)) then exit;
 result:=FColor[index];
end;

function TLogiColor.GetPenColor(index:integer):tcolor;
begin
 result:=clwhite;
 if index=$FF then result:=FPenColor[0];
 if (index<0) or (index>=length(FPenColor)) then exit;
 result:=FPenColor[index];
end;

function TLogiColor.GetColorCount:integer;
begin
 result:=length(fcolor);
end;


// compare fFind et FOriginal
function TLogiColor.FindIsOk:boolean;
var
 i:integer;
begin
 result:=false;
 for i:=0 to FSize.X*FSize.Y-1 do
  if ((FFind[i]=$FF) and (FOriginal[i]<>0)) or
     ((FFind[i]<>$FF) and (FFind[i]<>FOriginal[i])) then exit;
 result:=true;
end;



function TLogiColor.FindPossible(line:TcompactLine;Contrainte:TLine;PossibleColor:array of TCompactLine):TLine;
// Attention, ici $FF représente une case vide dont on est sure dans Contraine
// mais une case qui est incertaine dans result

// Line : la ligne compacté à trouver
// Contrainte : les cases déjà touvées
// PossibleColor : les lignes dans l'autre sens pour voir si les couleurs sont compatibles
var
 i,j,l,pos:integer;
 BlankStart:tline;
 BlankLength:tline;
 possible:tline;
 NBlank:integer;
 MaxLength:integer;
 ispossible:boolean;
 ColorOk:boolean;
 FirstSolution:boolean;

 function ToLong:boolean;
 var
  l,i:integer;
 begin
  l:=0;
  for i:=0 to high(line) do l:=l+line[i].Count;
  for i:=0 to NBlank-1 do l:=l+BlankLength[i];
  result:=l<=MaxLength;
 end;

 Function AddBlank:boolean;
 var
  PosInBL:integer;
 begin
  PosInBL:=0;
  result:=False;
  inc(BlankLength[PosInBL]);
  while not ToLong do
   begin
    BlankLength[PosInBL]:=BlankStart[PosInBL];
    inc(PosInBL);
    if PosInBL>=NBlank then exit;
    inc(BlankLength[PosInBL]);
   end;
  result:=true;
 end;

begin
 MaxLength:=length(Contrainte);
 setlength(result,MaxLength);
 fillchar(result[0],MaxLength,$FF);

 // y-a-t'il quelque chose à trouver sur cette ligne ?
 ispossible:=false;
 for i:=0 to MaxLength-1 do
   if Contrainte[i]=0 then ispossible:=true;
 // non on sort direct...
 if not ispossible then exit;


 // compte le nombre de vide et rempli le tableau BlankStart
 //un vide entre chaque Bloc + un vide au début + un vide à la fin (qu'on n'utilise pas)
 NBlank:=length(line);
 if NBlank=0 then exit;
 setlength(BlankStart,NBlank);
 setlength(BlankLength,NBlank);
 // entre deux blocs de même couleur, il y a au minimum une case blanche
 // entre deux blocs de couleur différente, il peut ne rien avoir
 for i:=1 to NBlank-1 do
  if line[i-1].color=line[i].color then BlankStart[i]:=1 else BlankStart[i]:=0;
 BlankStart[0]:=0;

 // on commence avec les espaces vides minimums, on est sure que ToLong=True
 move(BlankStart[0],BlankLength[0],NBlank);

 // on teste toutes les posibilités
 setlength(possible,MaxLength);
 FirstSolution:=true;
 Repeat
   // on rempli le tableau possible
   i:=0;
   pos:=0;
   while (i<NBlank) do
    begin
     for j:=0 to BlankLength[i]-1 do possible[pos+j]:=0;
     pos:=pos+BlankLength[i];
     for j:=0 to line[i].Count-1 do possible[pos+j]:=line[i].color;
     pos:=pos+line[i].Count;
     inc(i);
    end;

   while pos<MaxLength do begin possible[pos]:=0; inc(pos); end;

   // on compare avec contrainte pour voir si on garde cette possibilité
   ispossible:=true;
   for i:=0 to MaxLength-1 do
    begin
     // si contrainte avec $FF, il dois y avoir un blanc dans possible
     if (contrainte[i]=$FF) and (possible[i]<>0) then ispossible:=false;
     // sinon, si il y a une couleur quelconque, on doit avoir la même dans possible
     if (contrainte[i]<>$FF) and (contrainte[i]<>0) and (contrainte[i]<>possible[i]) then ispossible:=false;
     //verification de la place des couleurs (a ne faire que si il y a plus de 2 couleurs
     // Ne verifie que pour les cases non trouvées
     if (contrainte[i]=0) and (possible[i]<>0) then
     if length(FColor)>2 then
      begin
       ColorOk:=false;
       for j:=0 to high(PossibleColor[i]) do
        if PossibleColor[i][j].color=possible[i] then ColorOk:=true;
       if not ColorOk then ispossible:=false;
      end;
     if not ispossible then break;
    end;

   // on compare avec result pour voir les zones communes
   if ispossible then
    begin
     // ispossible=est-ce qu'il y a encore une posibilité quelque part
     // ou est-ce qu'il n'y a que des cases inconnues ??
     ispossible:=false;
     if FirstSolution then
      begin
       move(possible[0],result[0],MaxLength);
       FirstSolution:=false;
       ispossible:=true;
      end
     else
       for i:=0 to MaxLength-1 do
        begin
         // si c'est pas bon, on donne $FF à la case
         if possible[i]<>result[i] then result[i]:=$FF;
         if result[i]<>$FF then ispossible:=true;
        end;
     // non, il n'y a que des cases incertaines, on sort direct...
     if not ispossible then exit;
    end;
  until not AddBlank;

 for i:=0 to MaxLength-1 do if contrainte[i]<>0 then result[i]:=$FF;
end;



// cherche une case qui est sure en prenant ffind comme contrainte
function TLogiColor.FindNextPossible:TCase;
var
 i,j:integer;
 line:tcompactline;
 contrainte:tline;
 possible:tline;
 possibleColor:array of TCompactLine;
begin
 result.x:=-1;
 result.y:=-1;
 result.c:=0;
 //cherche parmi les lignes
 //précalcul les couleurs possible pour chaque colonnes
 setlength(possibleColor,fsize.x);
 for i:=0 to FSize.x-1 do
  begin
   contrainte:=GetFindCol(i);
   possible:=GetOriginalCol(i);
   for j:=0 to fsize.y-1 do
    if (contrainte[j]<>0) and (contrainte[j]=possible[j]) then possible[j]:=0;
   possibleColor[i]:=Compact(possible);
  end;

 for i:=0 to fsize.y-1 do
  begin
   // récup la ligne compactée i
   line:=compact(GetOriginalRow(i));
   //récup la contraite
   contrainte:=GetFindRow(i);
   possible:=FindPossible(line,contrainte,PossibleColor);
   for j:=0 to fsize.x-1 do
   if possible[j]<>$FF then // si on a autre chose que $FF, c'est une case sure
    begin
     result.x:=j;
     result.y:=i;
     result.c:=possible[j];
     // si la case est un vide, on lui donne le marqueur $FF
     if result.c=0 then result.c:=$FF;
     exit;
    end;
  end;

 //cherche parmi les colonnes
 //précalcul les couleurs possible pour chaque colonnes
 setlength(possibleColor,fsize.y);
 for i:=0 to FSize.y-1 do
  begin
   contrainte:=GetFindRow(i);
   possible:=GetOriginalRow(i);
   for j:=0 to fsize.x-1 do
    if (contrainte[j]<>0) and (contrainte[j]=possible[j]) then possible[j]:=0;
   possibleColor[i]:=Compact(possible);
  end;

 for i:=0 to fsize.x-1 do
  begin
   // récup la ligne compactée i
   line:=compact(GetOriginalCol(i));
   //récup la contraite
   contrainte:=GetFindCol(i);
   possible:=FindPossible(line,contrainte,PossibleColor);
   for j:=0 to fsize.y-1 do
   if possible[j]<>$FF then // si on a autre chose que $FF, c'est une case sure
    begin
     result.x:=i;
     result.y:=j;
     result.c:=possible[j];
     if result.c=0 then result.c:=$FF;
     exit;
    end;
  end;
end;


Procedure TLogiColor.EraseFind;
begin
 fillchar(ffind[0],fsize.x*fsize.y,0);
end;

Procedure TLogiColor.EraseOriginal;
begin
 fillchar(FOriginal[0],fsize.x*fsize.y,0);
end;


procedure TLogiColor.SetWidth(value:integer);
begin
 FSize.x:=Value;
 setlength(FOriginal,fsize.x*fsize.y);
 setlength(FFind,fsize.x*fsize.y);
 fillchar(FOriginal[0],fsize.x*fsize.y,0);
 fillchar(ffind[0],fsize.x*fsize.y,0);
end;

procedure TLogiColor.SetHeight;
begin
 FSize.y:=Value;
 setlength(FOriginal,fsize.x*fsize.y);
 setlength(FFind,fsize.x*fsize.y);
 fillchar(FOriginal[0],fsize.x*fsize.y,0);
 fillchar(ffind[0],fsize.x*fsize.y,0);
end;

procedure TLogiColor.SetColorCount(value:integer);
begin
 SetLength(FColor,Value);
 SetLength(FPenColor,Value);
end;

procedure TLogiColor.SetColor(index:integer;Value:TColor);
begin
 if (index<0) or (index>=length(FColor)) then exit;
 FColor[index]:=Value;
end;

procedure TLogiColor.SetPenColor(index:integer;Value:TColor);
begin
 if (index<0) or (index>=length(FColor)) then exit;
 FPenColor[index]:=Value;
end;

end.
