unit LLK;
(*連連看的機制*)

interface
uses
  Types;
const

  LLKMaxStage = 5;      //好眼力難度調低，關卡增加
  LLKEffT = 30;          //效果時間
  LLKEff1Slot = 5;       //效果積分加倍
  LLKCol = 16;
  LLKRow = 12;
  LLKColRow = 192;//192 = 16 * 12

  iCol = 16;
  iRow = 12;
type
  RLKK_GR = array [1..LLKColRow] of integer;       //牌組

  TLLKUnit = class
  private
    _XGR:array[0..1] of Byte;
    _YGR:array[0..1] of Byte;
   // _TGR : array [1..LLKColRow] of Byte;                   //盤面
    Ort:word;
    STick,PTick:DWord;
    Role:integer;
    LLKStage : Byte;
    TempPoint:TPoint;
    Function XThrough(x,y:integer;add:boolean):boolean;
    Function YThrough(x,y:integer;add:boolean):Boolean;
    Function X1_Link_X2(x,y1,y2:integer):boolean;
    Function Y1_Link_Y2(y,x1,x2:integer):boolean;
    Function LineX(x,y1,y2:integer):Boolean;
    Function LineY(y,x1,x2:integer):Boolean;
    Function OneCorner(x1,y1,x2,y2:integer):Boolean;
    Function TwoCorner(x1,y1,x2,y2:integer):Boolean;
  public
    _TGR : RLKK_GR;                   //盤面
    Road:RLKK_GR;
    RoadPos:integer;
    RoadNum:integer;
    Constructor Create;
    Destructor Destroy;override;
    procedure Clean(op:boolean=false);
    procedure Init(st:Byte);
    Function PairGrid(X,Y:integer):boolean;
    Function IsLink():Boolean;overload;
    Function IsLink(n1,n2:Byte):Byte;overload;
    Function IsLink(n1, n2: Byte ; aDontKillTile : Boolean ):Byte; overload;
    Function ClearByHamer(n1,n2:Byte):Byte;
    Function FindPair():Boolean;
    Procedure ReShuffle();
    Function Filter(N:Byte;var num:byte):Boolean;
    Function TransShfLLK():String;
    property ShfLLk : String Read TransShfLLk;
    property LStage : Byte Read LLKStage write LLKStage;
    property Obs: Word read Ort;

  end;

  function GetXY(i:byte):TPoint;
var
  LLKUnit: TLLKUnit;
implementation

function GetXY(i:byte):TPoint;
var
  pt:TPoint;
begin
  pt.x:=(i-1) mod LLKCol ;
  pt.y:=(i-1) div LLKCol;
  Result:=pt;
end;

{ TLLKUnit }

procedure TLLKUnit.Clean(op: boolean);
begin
  fillchar(_XGR,2,255);
  fillchar(_YGR,2,255);
  fillchar(_TGR,LLKcol*LLKRow,0);
  PTick:=0;
  STick := 0;
  Role := 0;
//  sc :=0;
  Ort:= (LLKCol-2) * (LLKRow-2);
  if op then
    LLKStage :=1;
end;

function TLLKUnit.ClearByHamer(n1, n2: Byte): Byte;     //只要判斷花色對就好
begin
  result := 1;  //  unspecified failure
  if n1 = n2 then exit;
  if n1*n2 = 0 then exit;
  if _TGR[n1]*_TGR[n2] = 0 then  exit;
  if _TGR[n1] <> _TGR[n2] then   exit;

  result := 2;
  _TGR[n2] := 0;
  _TGR[n1] := 0;
  dec(Ort,2);
  if Ort = 0 then
    result := 3;
end;

constructor TLLKUnit.Create;
begin
  inherited;
  Clean(true);
end;

destructor TLLKUnit.Destroy;
begin

  inherited;
end;

function TLLKUnit.Filter(N: Byte; var num: byte): Boolean;
var i:Byte;
begin
  result := false;
  num := 0;
  for i:= 1 to LLKColRow do
  begin
    if _TGR[i] =N then
    begin
      _TGR[i]:=0;
      inc(num);
      if Ort > 0 then
      dec(Ort,1);
    end;
  end;
end;

function TLLKUnit.FindPair: Boolean;
var found:boolean;
    i,j:Byte;
begin
  result := false;
  _XGR[0] := 0;
  _YGR[0] := 0;
  _XGR[1] := 0;
  _YGR[1] := 0;

  for i:= 1 to LLKColRow do
  begin
    if(result) then break;
    if _TGR[i] =0 then continue;

    for j:= i+1 to LLKColRow do
    begin
      if ((_TGR[j] <> 0) and (_TGR[i]=_TGR[j])) then
      begin
        _XGR[0] := (i-1) mod LLKCol;
        _YGR[0] := (i-1) div LLKCol;
        _XGR[1] := (j-1) mod LLKCol;
        _YGR[1] := (j-1) div LLKCol;

        if IsLink() then
        begin
          result := true;
          _TGR[j] := 0;
          _TGR[i] := 0;
          dec(Ort,2);
          exit;
        end;
      end;
    end;
  end;
end;

procedure TLLKUnit.Init(st: Byte);
const
  BasixSet : array[1..LLKMAxStage,1..3] of byte =  //(花色,列數/2,行數/2), 1/4塊盤面大小
    ((4,2,2),(7,3,3),(9,5,4),(18,6,5),(18,2,2));
var
  i,j,c:Byte;
  _GR : array of Byte;
  ABlockSize : byte;
  Colors : byte;
  tCol,tRow,start:byte;
  start_pos : array[1..4] of byte;
begin
  if not (st in [1..LLKMaxStage]) then st := LLKMaxStage;
  LLKStage := st;
  Colors := BasixSet[LLKStage,1]; //花色數
  tCol := BasixSet[LLKStage,2];   //區塊-行
  tRow := BasixSet[LLKStage,3];   //區塊-列
  ABlockSize := tCol*tRow;        //一個區塊大小,1/4盤面
  setlength(_GR,ABlockSize);      //區塊_GR
  Ort :=  ABlockSize*4;

  for i := 0 to ABlockSize-1 do
    _GR[i] := (i mod Colors)+1;

  for i:=0 to ABlockSize-1 do//_GR打散
  begin
    j := random(i);
    c:=_GR[j];
    _GR[j]:=_GR[i];
    _GR[i] := c;
  end;
  //複製開始點
  start_pos[4] := LLKCol*(LLKRow+1) div 2 + 1;  //右下(中心)
  start_pos[3] := start_pos[4] - tcol;          //左下
  start_pos[2] := start_pos[4] - trow*LLKCol;   //右上
  start_pos[1] := start_pos[2] - tcol;          //左上

  start := 0;
  for i:= 0 to tRow-1 do
  begin
    for j := 0 to tCol-1 do
    begin
      _TGR[start_pos[1]+i*LLKCol+j] := _GR[start];
      _TGR[start_pos[2]+i*LLKCol+j] := _GR[start];
      _TGR[start_pos[3]+i*LLKCol+j] := _GR[start];
      _TGR[start_pos[4]+i*LLKCol+j] := _GR[start];
      inc(start);
    end;
  end;

  start := LLKColRow-start_pos[1]+1;
  for i:= start_pos[1] to LLKColRow do//_TGR打散 18*12->16*12,
  begin
    if _TGR[i] = 0 then continue;
    j := start_pos[1] + random(start);
    c := _TGR[j];
    if c =0 then continue;
    _TGR[j]:=_TGR[i];
    _TGR[i] := c;
  end;
  
  fillchar(_XGR,2,255);
  fillchar(_YGR,2,255);

end;

function TLLKUnit.IsLink: Boolean;
begin
  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

  result := false;
  if _XGR[0] = _XGR[1] then
    if X1_Link_X2(_XGR[0],_YGR[0],_YGR[1]) then
    begin
      result :=true;
      exit;
    end;

  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

  if _YGR[0] = _YGR[1] then
    if Y1_Link_Y2(_YGR[0],_XGR[0],_XGR[1]) then
    begin
      result := true;
      exit;
    end;

  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

  if OneCorner(_XGR[0],_YGR[0],_XGR[1],_YGR[1]) then
  begin
    result := true;
    exit;
  end;

  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

  if TwoCorner(_XGR[0],_YGR[0],_XGR[1],_YGR[1])  then
  begin
    result := true;
    exit;
  end;
end;

function TLLKUnit.IsLink(n1, n2: Byte): Byte;
begin
  result := 1;  //  unspecified failure
  if n1 = n2 then exit;
  if n1*n2 = 0 then exit;

  if _TGR[n1]*_TGR[n2] = 0 then
  begin
    result := 0;
    exit;
  end;
  if _TGR[n1] <> _TGR[n2] then
  begin
    result := 0;
    exit;
  end;

  _XGR[0] := (n1-1) mod LLKCol;
  _YGR[0] := (n1-1) div LLKCol;
  _XGR[1] := (n2-1) mod LLKCol;
  _YGR[1] := (n2-1) div LLKCol;

  if IsLink() then
  begin
    result := 2;
    _TGR[n2] := 0;
    _TGR[n1] := 0;
    dec(Ort,2);
    if Ort = 0 then
      result := 4;
  end else
    result := 0;
end;

function TLLKUnit.IsLink(n1, n2: Byte ; aDontKillTile : Boolean ): Byte;
begin
  result := 1;  //  unspecified failure
  if n1 = n2 then exit;
  if n1*n2 = 0 then exit;

  if _TGR[n1]*_TGR[n2] = 0 then
  begin
    result := 0;
    exit;
  end;
  if _TGR[n1] <> _TGR[n2] then
  begin
    result := 0;
    exit;
  end;

  _XGR[0] := (n1-1) mod LLKCol;
  _YGR[0] := (n1-1) div LLKCol;
  _XGR[1] := (n2-1) mod LLKCol;
  _YGR[1] := (n2-1) div LLKCol;

  if IsLink() then
  begin
    result := 2;
    dec(Ort,2);
    if Ort = 0 then
      result := 4;
  end else
    result := 0;
end;


function TLLKUnit.LineX(x, y1, y2: integer): Boolean;
var i:Byte;
begin
  result := false;
  if (y1> y2) then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  for i:= y1 to y2 do
  begin
    TempPoint:=GetXY(i*LLKCol+x+1);
    if _TGR[i*LLKCol+x+1] > 0 then exit;
    Dec(RoadNum);
    _TGR[i*LLKCol+x+1]:=RoadNum;
    Road[RoadPos]:=i*LLKCol+x+1;
    Inc(RoadPos);
  end;
  result := true;

end;

function TLLKUnit.LineY(y, x1, x2: integer): Boolean;
var i:Byte;
begin
  result := false;
  if (x1> x2) then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;

  for i:= x1 to x2 do
  begin
    TempPoint:=GetXY(y*LLKCol+i+1);
    if _TGR[y*LLKCol+i+1] >0 then exit;
    Dec(RoadNum);
    _TGR[y*LLKCol+i+1]:=RoadNum;
    Road[RoadPos]:=y*LLKCol+i+1;
    Inc(RoadPos);    
  end;
  result := true;

end;

function TLLKUnit.OneCorner(x1, y1, x2, y2: integer): Boolean;
var
  c:byte;
  tempPos:integer;
  tempRoad:RLKK_GR;
begin
  tempPos:=RoadPos;
  tempRoad:=Road;
  result := false;

  if(x1>x2) then
  begin
    c:=x1;
    x1:=x2;
    x2:=c;
    c:=y1;
    y1:=y2;
    y2:=c;
  end;

  if(y2<y1) then
  begin
    if( LineY(y1,x1+1,x2)and LineX(x2,y1,y2+1)) then
    begin
      result := true;
      exit;
    end;

    RoadPos:=tempPos;
    Road:=tempRoad;

    if(LineY(y2,x2-1,x1) and LineX(x1,y2,y1-1)) then
    begin
      result := true;
      exit;
    end;
    RoadPos:=tempPos;
    Road:=tempRoad;
    result := false;
  end
  else begin
    if(LineY(y1,x1+1,x2) and LineX(x2,y1,y2-1)) then
    begin
      result := true;
      exit;
    end;

    RoadPos:=tempPos;
    Road:=tempRoad;

    if(LineY(y2,x2-1,x1) and LineX(x1,y2,y1+1)) then
    begin
      result := true;
      exit;
    end;
    RoadPos:=tempPos;
    Road:=tempRoad;
    result := false;
  end;

end;

function TLLKUnit.PairGrid(X, Y: integer): boolean;
begin
  result := false;
end;

procedure TLLKUnit.ReShuffle;
var fd:array [1..LLKColRow] of Byte;
    i,c,cc,ff: byte;
begin
  fillchar(fd,sizeof(Road),0);

  c :=0 ;
  for i:= 1 to LLKColRow do
  begin
    if _TGR[i] =0 then continue;
    inc(c);
    fd[c]:=_TGR[i];
  end;
  for i:= 1 to c do
  begin
    cc := Random(i)+1;
    ff := fd[cc];
    fd[cc] := fd[i];
    fd[i] := ff;
  end;
  c :=0;
  for i:= 1 to LLKColRow do
  begin
    if _TGR[i] =0 then continue;
    inc(c);
    _TGR[i]:=fd[c];
  end;
end;

function TLLKUnit.TransShfLLK: String;
begin

end;

function TLLKUnit.TwoCorner(x1, y1, x2, y2: integer): Boolean;
var c:Byte;
begin
  result := false;
  if(x1>x2) then
  begin
    c:=x1;
    x1:=x2;
    x2:=c;
    c:=y1;
    y1:=y2;
    y2:=c;
  end;

{  if(XThrough(x1+1,y1,TRUE) and XThrough(x2+1,y2,TRUE)) then
  begin
    result := true;
    exit;
  end;

  if(XThrough(x1-1,y1,FALSE) and XThrough(x2-1,y2,FALSE))then
  begin
    result := true;
    exit;
  end;
  if(YThrough(x1,y1-1,FALSE) and YThrough(x2,y2-1,FALSE)) then
  begin
    result := true;
    exit;
  end;

	//下通
  if(YThrough(x1,y1+1,TRUE) and YThrough(x2,y2+1,TRUE)) then
  begin
    result := true;
    exit;
  end;
}
  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

  //右
  if x1 < LLKCol then
  for c:=x1+1 to LLKCol-1 do
  begin
    TempPoint:=GetXY(y1*LLKCol+c+1);
    if(_TGR[y1*LLKCol+c+1]> 0) then break;
    Dec(RoadNum);
    _TGR[y1*LLKCol+c+1]:=RoadNum;
    Road[RoadPos]:=y1*LLKCol+c+1;
    Inc(RoadPos);    
    if(OneCorner(c,y1,x2,y2)) then
    begin
      result := true;
      exit;
    end;
  end;
	//左
    if x1 <> 0 then
    for c := x1-1 downto 0 do
    begin
      TempPoint:=GetXY(y1*LLKCol+c+1);
      if( _TGR[y1*LLKCol+c+1]> 0) then break;
      Dec(RoadNum);
      _TGR[y1*LLKCol+c+1]:=RoadNum;
      Road[RoadPos]:=y1*LLKCol+c+1;
      Inc(RoadPos);
      if(OneCorner(c,y1,x2,y2))then
      begin
        result := true;
        exit;
      end;
    end;

  RoadPos:=1;
  fillchar(Road,sizeof(Road),0);

	  //上
    if y1 <> 0 then
    for c := y1-1 downto 0 do
    begin
      TempPoint:=GetXY(c*LLKCol+x1+1);
      if(_TGR[c*LLKCol+x1+1]) >0 then break;
      Dec(RoadNum);
      _TGR[c*LLKCol+x1+1]:=RoadNum;
      Road[RoadPos]:=c*LLKCol+x1+1;
      Inc(RoadPos);
      if(OneCorner(x1,c,x2,y2)) then
      begin
        result := true;
        exit;
      end;
    end;

    RoadPos:=1;
    fillchar(Road,sizeof(Road),0);
  	//下
    if y1 < LLKRow then
    for c:= y1+1 to LLKRow-1 do
    begin
      TempPoint:=GetXY(c*LLKCol+x1+1);
      if(_TGR[c*LLKCol+x1+1]>0) then break;
      Dec(RoadNum);
      _TGR[c*LLKCol+x1+1]:=RoadNum;
      Road[RoadPos]:=c*LLKCol+x1+1;
      Inc(RoadPos);
      if(OneCorner(x1,c,x2,y2)) then
      begin
        result := true;
        exit;
      end;
    end;

end;

function TLLKUnit.X1_Link_X2(x, y1, y2: integer): boolean;
var i:byte;
begin
  result := false;
  if (y1 > y2 ) then
  begin
    i := y1 ;
    y1 := y2;
    y2 := i;
  end;
  for i:= y1+1 to y2 do
  begin
    if i = y2 then
    begin
      result := true;
      exit;
    end;
    TempPoint:=GetXY(i*LLKCol+x+1);
    if _TGR[i*LLKCol+x+1] > 0 then break;
    Dec(RoadNum);
    _TGR[i*LLKCol+x+1]:=RoadNum;
    Road[RoadPos]:=i*LLKCol+x+1;
    Inc(RoadPos);    
  end;

{  if XThrough(x-1,y1,false) and
     XThrough(x-1,y2,false) then
  begin
    result := true;
    exit;
  end;

  if XThrough(x+1,y1,true) and
    XThrough(x+1,y2,true) then
  begin
    result := true;
    exit;
  end;
}  
end;

function TLLKUnit.XThrough(x, y: integer; add: boolean): boolean;
var i : Byte;
begin
  result := false;
  if (add) then
  begin
    for i:= x to iCol do
    begin
      TempPoint:=GetXY(y*LLKCol+i+1);
      if _TGR[y*LLKCol+i+1]>0 then exit;
      Dec(RoadNum);
      _TGR[y*LLKCol+i+1]:=RoadNum;
      Road[RoadPos]:=y*LLKCol+i+1;
      Inc(RoadPos);
    end;
  end else begin
    if x >=0 then
    for i := 0 to x do
    begin
      TempPoint:=GetXY(y*LLKCol+i+1);
      if _TGR[y*LLKCol+i+1] > 0 then exit;
      Dec(RoadNum);
      _TGR[y*LLKCol+i+1]:=RoadNum;
      Road[RoadPos]:=y*LLKCol+i+1;
      Inc(RoadPos);
    end;
  end;
  result := true;
end;

function TLLKUnit.Y1_Link_Y2(y, x1, x2: integer): boolean;
var i:byte;
begin
  result := false;
  if (x1 > x2 ) then
  begin
    i := x1 ;
    x1 := x2;
    x2 := i;
  end;
  for i:= x1+1 to x2 do
  begin
    if i = x2 then
    begin
      result := true;
      exit;
    end;
    TempPoint:=GetXY(y*LLKCol+i+1);
    if _TGR[y*LLKCol+i+1] > 0 then break;
    Dec(RoadNum);
    _TGR[y*LLKCol+i+1]:=RoadNum;
    Road[RoadPos]:=y*LLKCol+i+1;
    Inc(RoadPos);    
  end;

{  if YThrough(x1,y-1,false) and
    YThrough(x2,y-1,false) then
  begin
    result := true;
    exit;
  end;

  if YThrough(x1,y+1,true) and
    YThrough(x2,y+1,true) then
  begin
    result := true;
    exit;
  end;
}
end;

function TLLKUnit.YThrough(x, y: integer; add: boolean): Boolean;
var i:byte;
begin
  result := false;
  if (add) then
  begin
    for i:= y to iRow do
    begin
      TempPoint:=GetXY(i*LLKCol+x+1);
      if _TGR[i*LLKCol+x+1]>0 then exit;
      Dec(RoadNum);
      _TGR[i*LLKCol+x+1]:=RoadNum;
      Road[RoadPos]:=i*LLKCol+x+1;
      Inc(RoadPos);
    end;
  end else begin
    if y >=0 then
    for i := 0 to y do
    begin
      TempPoint:=GetXY(i*LLKCol+x+1);
      if _TGR[i*LLKCol+x+1] > 0 then exit;
      Dec(RoadNum);
      _TGR[i*LLKCol+x+1]:=RoadNum;
      Road[RoadPos]:=i*LLKCol+x+1;
      Inc(RoadPos);
    end;
  end;
  result := true;

end;

end.
