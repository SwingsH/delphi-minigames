unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXDraws, Buttons, StdCtrls, DXClass;

type
  TForm1 = class(TForm)
    DXDraw1: TDXDraw;
    Button1: TButton;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    DXTimer1: TDXTimer;
    Label1: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure EveStageCurRealease(Sender: TObject);
    procedure DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TickTime(Sender: TObject; LagCount: Integer);
    procedure BTNPlantTreeOnclick(Sender: TObject);
    procedure BTNPlantAppleTreeOnclick(Sender: TObject);
    procedure BTNMoveTreeOnclick(Sender: TObject);
    procedure BTNKillTreeOnclick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetDXCoordinate : TPoint ;
    function GetCenterCoordOfTree( P : TPoint ) : TPoint ;
    function GetNearestTree( P : TPoint ) : Integer ;
    function GetPointsDistance( P_1 :TPoint ; P_2 :TPoint ) : Integer ;

    procedure showMessage( MSG: String ) ;
    procedure EvePlantOnrelease( StrTreeType:String ; P:TPoint ) ;
    procedure EvePlantKillOnrelease ;
    procedure DrawBackground ;
    procedure DrawTrees ;
    procedure DrawAllTrees ;
    procedure DrawOneTree( P : TPoint ;  IsAppleTree : Boolean ) ;
    procedure DrawOneApple( X : Integer ; Y : Integer ) ;
    procedure DrawText( X: Integer ; Y : Integer ; Content: String ; MyColor : TColor );
    procedure DrawStage ;
    function CreateLabel( X : Integer ; Y : Integer ; Content : String ):TLabel ;
    procedure RenewMovingTreeCoord ;
    function RecordAddTree( P : TPoint ; IsAppleTree : Boolean ):Integer ;
    procedure RecordDeleteTree( Index : Integer );
    procedure RecordSortAllTree ;
  end;

  { Object of Tree }
  TTreeRecord = Record
    TreeID : Integer ;
    TreeName : String ;
    TreePoint : TPoint ;
    IsAppleTree : Boolean ;
  end;

  { Point of Object of Tree .1 }
  PTreeRecord = ^TTreeRecord ;

  { Array of Object of Tree .2 }
  ArrayTreeRecord = array of TTreeRecord ;

const
  IMGPATHBG : String = 'Grass.bmp' ;
  IMGPATHTREE : String = 'tree.bmp' ;
  IMGPATHAPPLE : String = 'apple.bmp' ;
  IMGWIDTH_TREE : Integer = 129 ;
  IMGHEIGHT_TREE : Integer = 122 ;

  CURPLANT : Integer = -16 ; //crHandPoint
  CURMOVE : Integer = -21 ;
  CURDEL : Integer = -13 ;
  CURDEFAULT : Integer = 0 ;

  MODE_NONE = 0 ;
  MODE_PLANTTREE = 1 ; // "種植普通Tree"
  MODE_PLANTAPPLETREE = 2 ;  // "種植蘋果Tree"
  MODE_MOVETREE = 3 ;  // "想移動的Tree選取中"
  MODE_MOVING = 4 ; //"Tree移動中"
  MODE_KILLTREE = 5 ; // "想砍的Tree選取中"

  MSG_NONE = '' ;
  MSG_PLANTTREE = '請選擇種植地！';
  MSG_PLANTAPPLETREE = '請選擇種植地！' ;
  MSG_MOVETREE = '請選擇要移動的樹       ' ;
  MSG_MOVING = '請選擇移動地點       ' ;
  MSG_KILLTREE = '請選擇要砍的樹~' ;

  //Coordinate of TDXDraw1
  DX_X = 24 ;
  DX_Y = 72 ;
var
  Form1 : TForm1;
  ControlMode : Integer = MODE_NONE ;
  MySecond : Integer = 0 ;
  Record_TreeList : TList ;  // 儲存全部的 Tree Data

  TotalTree : Integer ;
  TotalTree_Apple : Integer ;
  TotalTree_Normal : Integer ;
  CountTree_Apple : Integer ;
  CountTree_Normal : Integer ;
  MovingID : Integer ;
  DeletedID : Integer ;

  LabelTotalTree : TLabel ;
  LabelTotalAppleTree : TLabel ;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Record_TreeList := TList.Create;
  TotalTree := 0 ;
  TotalTree_Apple := 0 ;
  TotalTree_Normal := 0 ;
  CountTree_Apple := 0 ;
  CountTree_Normal := 0 ;
  MovingID := -1 ;
  
  LabelTotalTree := CreateLabel( 510 ,15 , '1.' ) ;
  LabelTotalAppleTree := CreateLabel( 510 ,35 , '2.' ) ;
  DrawStage ;
end;

procedure TForm1.showMessage( MSG : String );
begin
  Label1.Caption := MSG ;
end;

{------------ Button Event Functions  --------------}

procedure TForm1.BTNPlantTreeOnclick(Sender: TObject);
begin
  ControlMode := MODE_PLANTTREE ;
  Screen.Cursor := TCursor( CURPLANT );
  showMessage( MSG_PLANTTREE + ' [普通樹]         ') ;
end;

procedure TForm1.BTNPlantAppleTreeOnclick(Sender: TObject);
begin
  ControlMode := MODE_PLANTAPPLETREE ;
  Screen.Cursor := TCursor( CURPLANT );
  showMessage( MSG_PLANTAPPLETREE + ' [蘋果樹]          ' ) ;
end;

procedure TForm1.BTNMoveTreeOnclick(Sender: TObject);
begin
  ControlMode := MODE_MOVETREE ;
  Screen.Cursor := TCursor( CURMOVE );
  showMessage( MSG_MOVETREE);
end;

procedure TForm1.BTNKillTreeOnclick(Sender: TObject);
begin
  ControlMode := MODE_KILLTREE ;
  Screen.Cursor := TCursor( CURDEL );
  showMessage( MSG_KILLTREE );
end;

{------------------------------------------------------}
procedure TForm1.EveStageCurRealease(Sender: TObject);
var
  P: TPoint ;
  TreeID : Integer ;
begin
  case ControlMode of

    MODE_NONE :
    begin
      P := GetDXCoordinate();
      showMessage( 'X座標:'+IntToStr( P.X ) + ', Y座標'+IntToStr( P.Y ) + '             ' );
    end;

    MODE_PLANTTREE :
    begin
      P := GetDXCoordinate;
      RecordAddTree( P , False);    // EvePlantOnrelease( 'Tree' , P ); // 種樹了
    end;

    MODE_PLANTAPPLETREE :
    begin
      P := GetDXCoordinate;
      RecordAddTree( P , True );
    end;

    MODE_MOVETREE :
    begin
      P := GetDXCoordinate();
      MovingID := GetNearestTree( P ) ;
      
      if MovingID <> -1 then      // <> -1 則有點選到樹, 狀態更改為 "移動中"
      begin
        ControlMode := MODE_MOVING ;
        showMessage( MSG_MOVING ) ;
      end;
    end;

    MODE_MOVING :
    begin
      ControlMode := MODE_MOVETREE ;  // 將樹放下, 狀態更改為 "next選取移動樹"
      MovingID := -1 ;   // 將樹放下, 移動樹 ID改為 "無"
      showMessage( MSG_MOVETREE ) ;
    end;

    MODE_KILLTREE :
    begin
      P := GetDXCoordinate;
      TreeID := GetNearestTree( P ) ;

      if TreeID <> -1 then      // <> -1 則有點選到樹, "執行砍樹"
        RecordDeleteTree( TreeID );
    end;

  else
  end;
end;

procedure TForm1.EvePlantOnrelease( StrTreeType:String ; P:TPoint ) ;
var
  MySurface : TDirectDrawSurface ;
begin
  MySurface := TDirectDrawSurface.Create(DXDraw1.DDraw);
  MySurface.LoadFromFile( IMGPATHTREE );
  MySurface.TransparentColor := MySurface.Pixels[0, 0];
  showMessage( 'X座標:'+IntToStr( P.X ) + ', Y座標'+IntToStr( P.Y ) );
  DXDraw1.Surface.Draw( P.X - (IMGWIDTH_TREE DIV 2 ), P.Y - IMGHEIGHT_TREE , MySurface);
  DXDraw1.Flip();
end;

procedure TForm1.EvePlantKillOnrelease;
begin
  //
end;

{------------ Coordinate Functions  --------------}
function TForm1.GetDXCoordinate: TPoint;
var
  P : TPoint ;
begin
  GetCursorPos(P);
  P := ScreenToClient (P);
  P.X := P.X - DX_X ;
  P.Y := P.Y - DX_Y ;
  Result := P ;
end;

function TForm1.GetNearestTree( P : TPoint ): Integer;
var
  PTree : PTreeRecord ;
  PTree1 : PTreeRecord ;
  i : Integer ;
  CurTreeID : Integer ;
  Dis1 : Integer ;
  Dis2 : Integer ;
begin
  CurTreeID := -1 ; // Default set to No target
  for i:= 0 to Record_TreeList.Count -1 do
  begin
    PTree := Record_TreeList.Items[i] ;

    { no tree }
    if CurTreeID = -1 then
    begin
      if( abs(P.X - PTree.TreePoint.X ) < (IMGWIDTH_TREE DIV 2 ) ) AND
      ( (P.Y - PTree.TreePoint.Y < 0 ) AND ( P.Y - PTree.TreePoint.Y > -IMGHEIGHT_TREE) ) then
      begin
        CurTreeID := i ;
      end
    { have compared tree }
    end
    else
    begin
      PTree1 :=  Record_TreeList.Items[ CurTreeID ] ;
      Dis1 := GetPointsDistance( GetCenterCoordOfTree( PTree1.TreePoint ) , P) ;
      Dis2 := GetPointsDistance( GetCenterCoordOfTree( PTree.TreePoint ) , P ) ;
      //showMessage( '哪棵樹較為接近? ' + IntToStr( CurTreeID ) + ':' + IntToStr( Dis1 ) + ' _ ' + IntToStr( i ) + ':' + IntToStr( Dis2 )   );
      if Dis2 < Dis1 then // 發現更接近滑鼠的Tree then , 更新 moveing 候選 TreeID
        CurTreeID := i ;
    end;
  end;

  Result := CurTreeID ;
end;

function TForm1.GetPointsDistance( P_1: TPoint ; P_2: TPoint): Integer;
begin
     Result := Sqr( abs( P_1.X - P_2.X) ) + Sqr( abs( P_1.Y - P_2.Y) ) ;
end;

function TForm1.GetCenterCoordOfTree( P : TPoint ) : TPoint;
begin
   P.Y := P.Y - ( IMGHEIGHT_TREE DIV 2 ) ;
   Result := P ;
end;

procedure TForm1.DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    // 此例可直接取得 DXDraw 之相對 Mouse Cordinate
end;

{------------------- Draw Functions --------------------}

procedure TForm1.DrawStage;
begin
  //DX畫布初始化
  DXDraw1.Initialize ;
  DrawBackground;
  DXDraw1.Flip();
end;

procedure TForm1.DrawBackground;
var
  MySurface : TDirectDrawSurface ;
begin
  MySurface := TDirectDrawSurface.Create(DXDraw1.DDraw);   // 建立TDirectDrawSurface物件.refference to DXDraw
  MySurface.LoadFromFile( IMGPATHBG );
  DXDraw1.Surface.Draw( 0, 0, MySurface);    // Surface.Draw( x , y , TDirectDrawSurface obj )
  DXDraw1.Surface.Draw( 480, -10, MySurface);    // Repeat BG pic
end;

procedure TForm1.DrawTrees;
var
  MySurface : TDirectDrawSurface ;
  PTree : PTreeRecord ;
begin
  // Have tree and New tree
  if ( Record_TreeList.Count > 0 ) AND ( TotalTree <> Record_TreeList.Count) then
  begin
    MySurface := TDirectDrawSurface.Create( DXDraw1.DDraw );
    MySurface.LoadFromFile( IMGPATHTREE );
    MySurface.TransparentColor := MySurface.Pixels[0, 0];
    PTree := Record_TreeList.Items[ Record_TreeList.Count -1 ] ;
    DXDraw1.Surface.Draw( PTree.TreePoint.X - (IMGWIDTH_TREE DIV 2 ),
      PTree.TreePoint.Y - IMGHEIGHT_TREE , MySurface );
    // showMessage( IntToStr( Record_TreeList.Count-1 ) + '_'+ IntToStr( PTree.TreePoint.X )   ) ;
    DXDraw1.Flip();
    TotalTree := Record_TreeList.Count ; // Upfate total tree 
  end;
end;

procedure TForm1.DrawAllTrees;
var
  PTree : PTreeRecord ;
  i : Integer ;
begin
    DrawBackground;
    for i := 0 to Record_TreeList.Count-1 do
    begin
      PTree := Record_TreeList.Items[i] ;

      if PTree.IsAppleTree = True then
      begin
        DrawOneTree( PTree.TreePoint , PTree.IsAppleTree );
        DrawText( PTree.TreePoint.X - 40 , PTree.TreePoint.Y , PTree.TreeName , clYellow ) ; // 建立 Label
      end
      else if PTree.IsAppleTree = False then
      begin
        DrawOneTree( PTree.TreePoint , PTree.IsAppleTree );
        DrawText( PTree.TreePoint.X - 40 , PTree.TreePoint.Y , PTree.TreeName , clWhite ) ; // 建立 Label
      end;
    end;
    DXDraw1.Flip();
end;

procedure TForm1.DrawOneApple( X : Integer ; Y : Integer );
var
  MySurface : TDirectDrawSurface ;
begin
  MySurface := TDirectDrawSurface.Create( DXDraw1.DDraw );
  MySurface.LoadFromFile( IMGPATHAPPLE );
  MySurface.TransparentColor := MySurface.Pixels[0,0] ;
  DXDraw1.Surface.Draw( X , Y , MySurface ) ;
end;

procedure TForm1.DrawOneTree( P: TPoint ; IsAppleTree : Boolean );
var
  MySurface : TDirectDrawSurface ;
begin
  MySurface := TDirectDrawSurface.Create( DXDraw1.DDraw );
  MySurface.LoadFromFile( IMGPATHTREE );
  MySurface.TransparentColor := MySurface.Pixels[0,0] ;
  DXDraw1.Surface.Draw( P.X - (IMGWIDTH_TREE DIV 2 ) , P.Y - IMGHEIGHT_TREE, MySurface ) ;

  if IsAppleTree = True then 
  DrawOneApple( P.X - 35 , P.Y - 60 );
end;


function TForm1.CreateLabel( X: Integer ; Y: Integer ; Content: String): TLabel ;
var
  MyLabel:TLabel;
begin
  MyLabel := TLabel.Create( Self );
  MyLabel.Parent := self;
  MyLabel.Left := X;
  MyLabel.Top := Y ;
  MyLabel.Width := 150;
  MyLabel.Height := 15;
  MyLabel.Visible := True ;
  MyLabel.Caption := Content ;
  Result := MyLabel ;
end;

procedure TForm1.DrawText( X: Integer ; Y : Integer ; Content: String ; MyColor:TColor );
begin
  DXDraw1.Surface.Canvas.Brush.Style := bsFDiagonal;
  DXDraw1.Surface.Canvas.Font.Color := MyColor ;
  DXDraw1.Surface.Canvas.TextOut( X , Y , Content );
  DXDraw1.Surface.Canvas.Release;
end;
{------------------- Draw Functions End --------------------}

{------------------- Record Functions --------------------}

function TForm1.RecordAddTree( P: TPoint ; IsAppleTree :Boolean): Integer;
var
  Rec : PTreeRecord ;
begin
  new(Rec);  //memory allocation
  Rec^.TreePoint := P ;
  Rec^.IsAppleTree :=  IsAppleTree ;

  if IsAppleTree = True then
  begin
    TotalTree_Apple := TotalTree_Apple + 1 ;
    CountTree_Apple := CountTree_Apple + 1 ;
    Rec.TreeName := '第 ' + IntToStr( CountTree_Apple ) + ' 顆 [蘋果樹]' ;
  end
  else
  begin
    TotalTree_Normal := TotalTree_Normal + 1 ;
    CountTree_Normal := CountTree_Normal + 1 ;
    Rec.TreeName := '第 ' + IntToStr( CountTree_Normal ) + ' 顆 [普通樹]' ;
  end;

  Record_TreeList.Add( Rec );
  TotalTree := Record_TreeList.Count ;

  showMessage( '新增了一顆樹, 座標為 X:' + IntToStr(P.X)+ ' Y:' +
    IntToStr(P.Y) + ',  目前有 '+ IntToStr( TotalTree )+ ' 顆樹    ' ) ;

  Result := TotalTree ;
end;

procedure TForm1.RecordDeleteTree( Index : Integer );
var
  Rec : PTreeRecord ;
begin
  Rec := Record_TreeList.Items[ Index ]; //Get the TreeRecord By Index
  showMessage( MSG_KILLTREE + ' 你砍了一顆樹，位於 X:' + IntToStr( Rec.TreePoint.X ) + ' Y:' + IntToStr( Rec.TreePoint.Y) + '              ' ) ;

  if Rec.IsAppleTree = True then
    TotalTree_Apple := TotalTree_Apple - 1
  else
    TotalTree_Normal := TotalTree_Normal - 1 ;
    
  TotalTree := TotalTree -1 ;
  
  Dispose(Rec);
  Record_TreeList.Delete( Index );

end;
 
procedure TForm1.RecordSortAllTree;
var
  RecTemp : PTreeRecord ;
  PTree1 : PTreeRecord ;
  PTree2 : PTreeRecord ;
  i : Integer ;
  j : Integer ;
  FlagMoved : Boolean ;
begin
  // 兩顆樹以上才需要排序
  if TotalTree > 1 then
    for i := Record_TreeList.Count-1 downto 1 do
    begin
      FlagMoved := False ;
      for j := 1 to i do
      begin
        PTree1 := Record_TreeList.Items[j-1] ;
        PTree2 := Record_TreeList.Items[j] ;
        if PTree1.TreePoint.Y > PTree2.TreePoint.Y then
        begin
          FlagMoved := True ;
          RecTemp := Record_TreeList[j-1] ;
          Record_TreeList[j-1] := Record_TreeList[j] ;
          Record_TreeList[j] := RecTemp ;
          
          {如果對調的是移動中的樹, 需要改變 MovingID}
          if j = MovingID then
            MovingID := j-1
          else if j-1 = MovingID then
            MovingID := j
        end;
      end;
      if FlagMoved = False then
        break ;
    end;
end;

procedure TForm1.RenewMovingTreeCoord;
var PTree : PTreeRecord ;
var P : TPoint ;
begin
  if MovingID <> -1 then
  begin
    PTree := Record_TreeList.Items[ MovingID ] ;
    P := GetDXCoordinate ;
    PTree^.TreePoint := P ;
  end;
  DXDraw1.Flip();
end;

{------------------- Record Functions End --------------------}

{------------------- Tick Functions --------------------}
procedure TForm1.TickTime(Sender: TObject; LagCount: Integer);
begin
  RecordSortAllTree ;
  if ControlMode = MODE_MOVING then
  begin
    RenewMovingTreeCoord ;
  end;

  DrawAllTrees;

  LabelTotalTree.Caption := '[普通樹] 共 ' + IntToStr( TotalTree_Normal ) + ' 棵     ' ;
  LabelTotalAppleTree.Caption := '[蘋果樹] 共 ' + IntToStr( TotalTree_Apple ) + ' 棵     ' ;
end;

end.
