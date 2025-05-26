unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXDraws, DXClass, Image, LLK, AStar, StdCtrls;

type
  TTileType = Record
    ID : Integer ; //編號
    Image : String ; //圖示
    Description : String ;//類型說明
  end;

  TResultEffect = class( TObject )
  private
  public                               
    FLLKID_1 : Integer ;
    FLLKID_2 : Integer ;
    FTileImage_1 : TAnimatedImage ;
    FTileImage_2 : TAnimatedImage ;
    FRoadLight : array of TAnimatedImage ;
    FTimeToLive : Integer ;
    FIfKillTile : Boolean ;
    procedure SetLightStatus( aStatus : Integer );
    procedure AddLightImage( aLightImage : TAnimatedImage ) ;
    function IsDead : Boolean ; // 判斷線條是否已消失
    procedure DrawLights ; // 繪出所有線條燈
    procedure Hide2Tile ;
    procedure SetKillTile( aIfKill : Boolean );
    constructor Create( aFLLKID_1 , aFLLKID_2 : Integer ;
                        aTileImage_1 , aTileImage_2 : TAnimatedImage ) ;
    destructor Destroy ; override ;
  end;
  
  TMainForm = class(TForm)
    MainDXDraw: TDXDraw;
    MainDXTimer: TDXTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DrawText( X: Integer ; Y : Integer ;
                        aContent: String ; aColor:TColor );
    procedure MainDXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure MainDXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MainDXDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MainDXDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LLKUnite : TLLKUnit ;
    FCursorX : Integer ;
    FCursorY : Integer ;
    FActiveData : TActiveData ;
    FPresentMouseoverID : Integer ;
    FPresentMousedownID : Integer ;
    FMousedownTileID_1 : Integer ;
    FMousedownTileID_2 : Integer ;
    FAnimatedImages : array of TAnimatedImage ;
    FTileImages : array of TAnimatedImage ;
    FTileIDLLKIDMapping : array of Integer ; // Tile ID(index) & LLK ID(value) 的對應表
    FLLKIDTileIDMapping : array of Integer ; // LLK ID(value) & Tile ID(index) 的對應表
    FResultEffect : array[0..128] of TResultEffect ;
    FRE_Index : Integer ;
    FPathFinder : TAStart;
    FScore : Integer ; // 目前真實得分
    FScoreCount : Integer ; // 目前跑動數字的得分
    FEnableTileNum : Integer ;//目前關卡格子總數
    FColumn : Integer ; // 目前關卡的欄位數
    FRow : Integer ; // 目前關卡的列位數
    FStage : Integer ;
    FPlayerDead : Boolean ;
    FPlayerPass : Boolean ;
    FKillTileNum : Integer ;
    { 數字的圖片讀取器 }
    FNumberSurface : array[0..2] of TDirectDrawSurface ;
    
    procedure Init ;
    procedure DrawAllSets ;
    procedure ActionFindPath( LLKID_1 : Integer ; LLKID_2 : Integer ) ;
    procedure ActionAllButtonMouseup ;
    procedure CalcuLLKPathLine( LLKID_1 : Integer ; LLKID_2 : Integer ;
                                aInvisibleTile : Boolean ) ; // 設定路徑的線條
    procedure DrawNumberGraphic( X, Y: Integer; aNumber: Integer ;
                                 aStyle: String ; aAlign: String );
    function InArray( aSearchArray : array of Integer ; aValue : Integer ):Boolean ;
    procedure LLKShuffle ;
    procedure LLKCheckDeadAndPass( aHintRoad : Boolean ) ;
    function GetEffect( aIndex ) : TResultEffect ;  // or nil
    procedure AddEffect( aEffect : TResultEffect ) ;
    procedure DeleteEffect ; // Delete front effect
  end;

const

  CFG_TileSection_X = -37 ;
  CFG_TileSection_Y = 80 ;
  CFG_Tile_Width = 36 ;
  CFG_Tile_Height = 108 ;
  CFG_Tile_ShiftWidth = 36 ;
  CFG_Tile_ShiftHeight = 36 ;
  CFG_Light_Width = 12 ;
  CFG_Light_Height = 24 ;
  CFG_Light_ShiftWidth = 12 ;
  CFG_Light_ShiftHeight = 12 ;
  CFG_MaxColumn = 16 ;
  CFG_MaxRow = 12 ;
  CFG_TotalTileNum = CFG_MaxColumn * CFG_MaxRow ;  //所有方塊總數,含空缺格子
  CFG_ImagType_BG = 0 ;
  CFG_SCORE_WEIGHT = 10 ;
  CFG_STAGE_SET : array[ 1..5 , 1..3 ] of Byte =  //(花色,列數/2,行數/2), 1/4塊盤面大小
    ((4,2,2),(7,3,3),(9,5,4),(18,6,5),(18,2,2));
  CFG_MaxStage = 5 ;
  
  BUTTONTYPE_TILE = 1 ;
  BUTTONTYPE_RESTART = 2 ;

  { 動態圖片資產,區塊種類 }
  CFG_TileTypes : array[1..18] of TTileType = (
    ( ID : 1 ; Image : 'pic/Btn_Fruit09.bmp' ; Description : '蘋果' ),
    ( ID : 2 ; Image : 'pic/Btn_Fruit08.bmp' ; Description : '西瓜' ),
    ( ID : 3 ; Image : 'pic/Btn_Fruit07.bmp' ; Description : '星星' ),
    ( ID : 4 ; Image : 'pic/Btn_Fruit06.bmp' ; Description : '幸運七' ),
    ( ID : 5 ; Image : 'pic/Btn_Fruit05.bmp' ; Description : 'BAR' ),
    ( ID : 6 ; Image : 'pic/Btn_Fruit04.bmp' ; Description : '鈴鐘' ),
    ( ID : 7 ; Image : 'pic/Btn_Fruit03.bmp' ; Description : '冬瓜' ),
    ( ID : 8 ; Image : 'pic/Btn_Fruit02.bmp' ; Description : '橘子' ),
    ( ID : 9 ; Image : 'pic/Btn_Fruit01.bmp' ; Description : '櫻桃' ),
    ( ID : 10 ; Image : 'pic/Btn_Fruit10.bmp' ; Description : '蘋果' ),
    ( ID : 11 ; Image : 'pic/Btn_Fruit11.bmp' ; Description : '西瓜' ),
    ( ID : 12 ; Image : 'pic/Btn_Fruit12.bmp' ; Description : '星星' ),
    ( ID : 13 ; Image : 'pic/Btn_Fruit13.bmp' ; Description : '幸運七' ),
    ( ID : 14 ; Image : 'pic/Btn_Fruit14.bmp' ; Description : 'BAR' ),
    ( ID : 15 ; Image : 'pic/Btn_Fruit15.bmp' ; Description : '鈴鐘' ),
    ( ID : 16 ; Image : 'pic/Btn_Fruit16.bmp' ; Description : '冬瓜' ),
    ( ID : 17 ; Image : 'pic/Btn_Fruit17.bmp' ; Description : '橘子' ),
    ( ID : 18 ; Image : 'pic/Btn_Fruit18.bmp' ; Description : '櫻桃' )
  );

  CFG_ImageSets :array[0..3] of TImageRecord = (
    // 背景圖
    ( Path:'pic/BG_SmallMary.bmp' ; X:0 ; Y:0 ; Width:500 ; Height:550 ;
      Alpha : False ; ImageType : CFG_ImagType_BG ; ShiftWidth:500 ; ShiftHeight:550 ),
    //得分底框
    ( Path:'pic/Frame_MoneyEdit3.bmp' ; X:145 ; Y:30 ; Width:138 ; Height:27 ;
      Alpha : True ; ImageType : CFG_ImagType_BG ; ShiftWidth:138 ; ShiftHeight:27 ),
    //中獎彩金文字
    ( Path:'pic/CCGradePrize.bmp' ; X:68 ; Y:34 ; Width:66 ; Height:18 ;
      Alpha : True ; ImageType : CFG_ImagType_BG ; ShiftWidth:66 ; ShiftHeight:18 ),
    // 關卡底框
    ( Path:'pic/Frame_MoneyEdit2.bmp' ; X:300 ; Y:30 ; Width:66 ; Height:18 ;
      Alpha : True ; ImageType : CFG_ImagType_BG ; ShiftWidth:66 ; ShiftHeight:18 )
  );

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{---------------------- TMainForm : Main Function --------------------------}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FStage := 1 ; // 關卡
  MainDXDraw.Initialize ;
  Init ;
end;

procedure TMainForm.Init;
var
  i : Integer ;
  vLength : Integer ;
  vImage : TAnimatedImage ;
  vAnimaID : Integer ;
  vTileID : Integer ;
  vX : Integer ;
  vY : Integer ;
  vCol : Byte ;
  vRow : Byte ;
begin
  FMousedownTileID_1 := -1 ;
  FRE_Index := 0 ; // Index of ResultEffect
  
  { 初始化 : 關卡參數 }
  FColumn := CFG_STAGE_SET[ FStage ][ 2 ] * 2 ;
  FRow := CFG_STAGE_SET[ FStage ][ 3 ] * 2 ;
  FEnableTileNum := FColumn * FRow ; //方塊總數, 不含空缺格子 , 1/4 格
  FKillTileNum := 0 ;  // 消失的方塊數 , 0
  FPlayerPass := False ;
  FPlayerDead := False ;
  
  { 初始化 : 得分相關參數 }
  FScore := 0 ;
  FScoreCount := 0 ;
  
  { 初始化 : 按鈕紀錄物件 }
  FActiveData := TActiveData.Create ;
  
  { 初始化 : 連連看物件 }
  LLKUnit := TLLKUnit.Create;
  LLKUnit.Init(FStage);
  LLKShuffle ;

  { 初始化 : 路徑尋找物件 }
  FPathFinder := TAStart.Create( nil );

  vAnimaID := 0 ;
  { 初始化 : 處理場景固定圖 }
  vLength := Length( CFG_ImageSets );
  SetLength( FAnimatedImages , vLength );
  for i := 0 to vLength-1 do
  begin
    vImage := TAnimatedImage.Create( vAnimaID , MainDXDraw ,
                                     CFG_ImageSets[i].Path ,
                                     CFG_ImageSets[i].Alpha ) ;
    vImage.SetCoordinate( Point( CFG_ImageSets[i].X , CFG_ImageSets[i].Y ));
    FAnimatedImages[ vAnimaID ] := vImage ;
    vAnimaID := vAnimaID + 1 ;
  end;

  { 初始化 : 處理場景方塊圖 }
  vAnimaID := 0 ;
  vLength := CFG_TotalTileNum ;
  SetLength( FTileImages , FEnableTileNum ) ;
  SetLength( FTileIDLLKIDMapping , FEnableTileNum ) ;
  SetLength( FLLKIDTileIDMapping , CFG_TotalTileNum ) ;
  for i:=1 to vLength do
  begin
    vTileID := LLKUnit._TGR[i] ;
    if vTileID <> 0 then  // TileID = 0 means no Tile
    begin
      // 圖片 : TAnimatedImage
      vImage := TAnimatedImage.Create( vAnimaID , MainDXDraw ,
                                       CFG_TileTypes[ vTileID ].Image ,
                                       False ) ;
      vCol := (i-1) MOD CFG_MaxColumn ;  // 計算座標
      vRow := (i-1) DIV CFG_MaxColumn ;
      vX := CFG_TileSection_X + vCol * CFG_Tile_ShiftWidth ;
      vY := CFG_TileSection_Y + vRow * CFG_Tile_ShiftHeight ;
      vImage.SetCoordinate( Point( vX , vY ) ) ;   //設置座標
      vImage.SetShiftRange( CFG_Tile_Width, CFG_Tile_Height,
                            CFG_Tile_ShiftWidth, CFG_Tile_ShiftHeight );//設置位移
      FTileImages[ vAnimaID ] := vImage ;
      // 作用 : TActiveData
      FActiveData.AddItem( vX , vY ,
                           CFG_Tile_ShiftWidth , CFG_Tile_ShiftHeight,
                           BUTTONTYPE_TILE , vAnimaID );
      // 對應 : 儲存對應表
      FTileIDLLKIDMapping[ vAnimaID ] := i ;
      FLLKIDTileIDMapping[ i ] := vAnimaID ;
      // Increment
      Inc( vAnimaID ) ;
    end
    else
      FLLKIDTileIDMapping[ i ] := -1 ;
  end;

  { 初始化 : 圖片讀取 - 數字 }
  FNumberSurface[ 0 ] := TDirectDrawSurface.Create( MainDXDraw.DDraw );
  FNumberSurface[ 0 ].LoadFromFile( 'pic/Number_BU.bmp' );
  FNumberSurface[ 0 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;
  FNumberSurface[ 1 ] := TDirectDrawSurface.Create( MainDXDraw.DDraw );
  FNumberSurface[ 1 ].LoadFromFile( 'pic/Number_ELE.bmp' );
  FNumberSurface[ 1 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;
  FNumberSurface[ 2 ] := TDirectDrawSurface.Create( MainDXDraw.DDraw );
  FNumberSurface[ 2 ].LoadFromFile( 'pic/Number_MY.bmp' );
  FNumberSurface[ 2 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;
end;

{---------------------- TMainForm : Main Function End ----------------------}

{---------------------- TMainForm : Draw Function --------------------------}

procedure TMainForm.DrawAllSets;
var
  i : Integer ;
  vLength : Integer ;
begin
  { 繪製 : 場景圖 }
  vLength := Length( FAnimatedImages );
  for i := 0 to vLength-1 do
  begin
    FAnimatedImages[i].OutputImage ;
  end;

  { 繪製 : 數字圖 } // 可更新為 TAnimatedImage版
  DrawNumberGraphic( 248 , 39 , FScoreCount , 'my' , 'center');
  
  { 繪製 : 方塊圖 }
  vLength := Length( FTileImages );
  for i := 0 to vLength-1 do
  begin
    FTileImages[i].OutPutImage ;
  end;

  { 繪製 : 方塊消去效果 (如果有的話) }
  vLength := FRE_Index ;
  for i:= 0 to vLength -1 do
  begin
    FResultEffect[i].DrawLights ;  // 未死亡, 繪圖
  end;

  { 繪制 : 座標軸文字 }
 // DrawText( 420 , 530 , 'X:' + IntToStr(FCursorX) + ' , Y:' + IntToStr(FCursorY), clBlack ) ;

  { 繪制 : 關卡文字 }
  DrawText( 325 , 37 , '第　' + IntToStr( FStage ) + '　關', cl3DLight ) ;
end;

procedure TMainForm.DrawText( X: Integer ; Y : Integer ; aContent: String ; aColor:TColor );
begin
  MainDXDraw.Surface.Canvas.Brush.Style := bsFDiagonal;
  MainDXDraw.Surface.Canvas.Font.Color := aColor ;
  MainDXDraw.Surface.Canvas.TextOut( X , Y , aContent );
  MainDXDraw.Surface.Canvas.Release;
end;

//繪製數字圖形
procedure TMainForm.DrawNumberGraphic( X, Y: Integer; aNumber: Integer ;
                                       aStyle: String ; aAlign: String );
const
  { ShiftWidth : 位移寬 ; ShiftHeight : 位移高 ; ShiftPadding : 對齊與間隔 ;  }
  SHIFTWIDTH_BLUE = 16 ;
  SHIFTPADDING_BLUE = -5 ;
  SHIFTHEIGHT_BLUE = 17 ;

  SHIFTWIDTH_ELECTRIC = 16 ;
  SHIFTPADDING_ELECTRIC = -4 ;
  SHIFTHEIGHT_ELECTRIC = 17 ;

  SHIFTWIDTH_MY = 8 ;
  SHIFTPADDING_MY = 0 ;
  SHIFTHEIGHT_MY = 11 ;
var
  i : Integer ;
  vShiftWidth : Integer ;
  vShiftHeight : Integer ;
  vShiftPadding : Integer ;
  vNumSet : Integer ;
  vNumLength : Integer ;
  vStart_X : Integer ;                                         
  vEnd_X : Integer ;
  vSurface : TDirectDrawSurface ;
begin
  if aStyle = 'blue' then
    begin
      vSurface := FNumberSurface[ 0 ];
      vShiftWidth := SHIFTWIDTH_BLUE ;
      vShiftHeight := SHIFTHEIGHT_BLUE ;
      vShiftPadding := SHIFTPADDING_BLUE ;
    end

  else if aStyle = 'electric' then
    begin
      vSurface := FNumberSurface[ 1 ];
      vShiftWidth := SHIFTWIDTH_ELECTRIC ;
      vShiftHeight := SHIFTHEIGHT_ELECTRIC ;
      vShiftPadding := SHIFTPADDING_ELECTRIC ;
    end

  else if aStyle = 'my' then
    begin
      vSurface := FNumberSurface[ 2 ];
      vShiftWidth := SHIFTWIDTH_MY ;
      vShiftHeight := SHIFTHEIGHT_MY ;
      vShiftPadding := SHIFTPADDING_MY ;
    end
  else
    begin
      vSurface := FNumberSurface[ 2 ];
      vShiftWidth := 8 ;
      vShiftHeight := 17 ;
      vShiftPadding := -3 ;
    end;

  vNumLength := Length( IntToStr(aNumber) );
  //調整置中
  if ( aAlign = 'center') AND ( vNumLength = 3 ) then
    X := X - ( vShiftWidth Div 2 ) + 3
  else if ( aAlign = 'center') AND ( vNumLength = 1 ) then
    X := X + ( vShiftWidth Div 2 ) ;

  for i := 0 to vNumLength-1 do
  begin
    vNumSet := StrToInt( Copy( IntToStr(aNumber) , i+1 , 1 ) ) ;  // 由左至右取得"數字字元"
    vStart_X := vNumSet*vShiftWidth ;
    vEnd_X := ( vNumSet+ 1 ) * vShiftWidth ;
    MainDXDraw.Surface.Draw( X + i* (vShiftWidth + vShiftPadding ), Y ,
                             Rect( vStart_X ,0 , vEnd_X , vShiftHeight ),
                             vSurface );
  end;
end;

{---------------------- TMainForm : Draw Function End --------------------------}

{---------------------- TMainForm : Action Function --------------------------}
procedure TMainForm.CalcuLLKPathLine( LLKID_1, LLKID_2: Integer ; aInvisibleTile : Boolean );
var
  i : Integer ;
  j : Integer ;
  vLength : Integer ;
  vImage_1 : TAnimatedImage ;
  vImage_2 : TAnimatedImage ;
  vTmpLight : TAnimatedImage ;
  vTileID_1 : Integer ;
  vTileID_2 : Integer ;
  vArrayRoadLLKID : array of Integer ;
  vEffect : TResultEffect ;
  vCol : Integer ;
  vRow : Integer ;
  vX : Integer ;
  vY : Integer ;
begin
  SetLength( vArrayRoadLLKID , CFG_TOTALTILENUM ) ;

  // 建立 "方塊死亡" 的效果物件
  vTileID_1 :=  FLLKIDTileIDMapping[ LLKID_1 ] ;   // Get Tile ID
  vTileID_2 :=  FLLKIDTileIDMapping[ LLKID_2 ] ;
  vImage_1 := FTileImages[ vTileID_1 ]  ;  // Get Image
  vImage_2 := FTileImages[ vTileID_2 ]  ;
  vEffect := TResultEffect.Create( LLKID_1,LLKID_2, vImage_1 , vImage_2);

  // 取得所有 路徑上的 LLK ID + 端點位置*2
  vArrayRoadLLKID[ 0 ] := LLKID_1 ;
  vArrayRoadLLKID[ 1 ] := LLKID_2 ;
  j := 2 ;
  for i:=Low( LLKUnit.Road ) to High( LLKUnit.Road ) do
  begin
    if LLKUnit.Road[ i ] > 0 then
    begin
      if InArray( vArrayRoadLLKID , LLKUnit.Road[ i ] ) <> True then
      begin
        vArrayRoadLLKID[ j ] := LLKUnit.Road[ i ] ;
        Inc( j ) ;
      end;
    end;
  end;
  SetLength( vArrayRoadLLKID , j ) ;
  // 判斷每個區塊(Tile)上下左右是否有 路徑鄰居,並劃線
  vLength := Length( vArrayRoadLLKID ) ;
  for i:=Low( vArrayRoadLLKID ) to vLength-1 do
  begin
    // 計算目前 LLKID 所在的 區塊(Tile) 之 X, Y
    vCol := ( vArrayRoadLLKID[i] -1) MOD CFG_MaxColumn ;  // 計算座標
    vRow := ( vArrayRoadLLKID[i] -1) DIV CFG_MaxColumn ;
    vX := CFG_TileSection_X + vCol * CFG_Tile_ShiftWidth ;
    vY := CFG_TileSection_Y + vRow * CFG_Tile_ShiftHeight ;

    // 正中央的燈號, 必劃
    vTmpLight := TAnimatedImage.Create( 0 , MainDXDraw ,'pic/Ico_Light.bmp' , False );
    vTmpLight.SetShiftRange( CFG_Light_Width , CFG_Light_Height ,
                             CFG_Light_ShiftWidth , CFG_Light_ShiftHeight );
    vTmpLight.SetCoordinate(
      Point( vX + ((CFG_Tile_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ) DIV 2) ,
             vY + ((CFG_Tile_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ) DIV 2) ) ) ;
    vEffect.AddLightImage( vTmpLight );
    
    for j:=Low( vArrayRoadLLKID ) to High( vArrayRoadLLKID ) do
    begin
      if vArrayRoadLLKID[ i ] = vArrayRoadLLKID[ j ] then continue ; // 不用檢查自己到自己的線路
      // 劃線 : 中心點向上
      if ( vArrayRoadLLKID[ i ] - CFG_MAXCOLUMN )= vArrayRoadLLKID[ j ] then
      begin
        vTmpLight := TAnimatedImage.Create( 0 , MainDXDraw ,'pic/Ico_Light.bmp' , False );
        vTmpLight.SetShiftRange( CFG_Light_Width , CFG_Light_Height ,
                                 CFG_Light_ShiftWidth , CFG_Light_ShiftHeight );
        vTmpLight.SetCoordinate(
          Point( vX + ((CFG_Tile_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ) DIV 2) ,
                 vY ) );
        vEffect.AddLightImage( vTmpLight );
      end;
      // 劃線 : 中心點向下
      if ( vArrayRoadLLKID[ i ] + CFG_MAXCOLUMN )= vArrayRoadLLKID[ j ] then
      begin
        vTmpLight := TAnimatedImage.Create( 0 , MainDXDraw ,'pic/Ico_Light.bmp' , False );
        vTmpLight.SetShiftRange( CFG_Light_Width , CFG_Light_Height ,
                                 CFG_Light_ShiftWidth , CFG_Light_ShiftHeight );
        vTmpLight.SetCoordinate(
          Point( vX + ((CFG_Tile_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ) DIV 2) ,
                 vY + ((CFG_Tile_SHIFTHEIGHT + CFG_LIGHT_SHIFTHEIGHT ) DIV 2) ) ) ;
        vEffect.AddLightImage( vTmpLight );
      end;
      // 劃線 : 中心點向左
      if ( vArrayRoadLLKID[ i ] - 1 )= vArrayRoadLLKID[ j ] then
      begin
        vTmpLight := TAnimatedImage.Create( 0 , MainDXDraw ,'pic/Ico_Light.bmp' , False );
        vTmpLight.SetShiftRange( CFG_Light_Width , CFG_Light_Height ,
                                 CFG_Light_ShiftWidth , CFG_Light_ShiftHeight );
        vTmpLight.SetCoordinate(
          Point( vX ,
                 vY + ((CFG_Tile_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ) DIV 2) ) ) ;
        vEffect.AddLightImage( vTmpLight );
      end;
      // 劃線 : 中心點向右
      if ( vArrayRoadLLKID[ i ] + 1 )= vArrayRoadLLKID[ j ] then
      begin
        vTmpLight := TAnimatedImage.Create( 0 , MainDXDraw ,'pic/Ico_Light.bmp' , False );
        vTmpLight.SetShiftRange( CFG_Light_Width , CFG_Light_Height ,
                                 CFG_Light_ShiftWidth , CFG_Light_ShiftHeight );
        vTmpLight.SetCoordinate(
          Point( vX + ((CFG_Tile_SHIFTWIDTH + CFG_LIGHT_SHIFTWIDTH ) DIV 2) ,
                 vY + ((CFG_Tile_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ) DIV 2) ) ) ;
        vEffect.AddLightImage( vTmpLight );
      end;
    end;
  end;

  if aInvisibleTile = False then // check 效果結束後是否要殺掉方塊? (提示模式)
    vEffect.SetKillTile( False );
    
  //儲存效果
  FResultEffect[ FRE_Index ] := vEffect ;
  Inc( FRE_Index ) ;
end;

procedure TMainForm.AddEffect(aEffect: TResultEffect);
begin

end;

procedure TMainForm.DeleteEffect;
begin

end;

function TMainForm.GetEffect(aIndex): TResultEffect;
begin

end;

{---------------------- TMainForm : Action Function End --------------------------}

{---------------------- TMainForm : Event Function ------------------------------}
procedure TMainForm.MainDXDrawMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  vPicID : Integer ;
begin
  FCursorX := X ;
  FCursorY := Y ;
  vPicID := FActiveData.GetPicID( X , Y ) ;
  ActionAllButtonMouseup;
  if vPicID >= 0 then
  begin
    if FTileImages[ vPicID ].GetStatus <> 2 then // not Press item
      FTileImages[ vPicID ].SetStatus( 1 );     // picid start with 0 , activeid start with 1
  end;
end;

procedure TMainForm.MainDXDrawMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vActiveID : Integer ;
begin
  vActiveID := FActiveData.GetActiveID( X , Y );
  if vActiveID <> 0 then
    FPresentMousedownID :=  vActiveID ;
end;

procedure TMainForm.MainDXDrawMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vActiveID : Integer ;
  vPicID : Integer ;
  vLLKID_1 : Integer ;
  vLLKID_2 : Integer ;
begin
  vActiveID := FActiveData.GetActiveID( X , Y );
  if ( FPresentMousedownID = vActiveID ) AND
     ( FPresentMousedownID <> 0 )then
  begin
    vPicID := FActiveData.GetPicID( vActiveID ) ;
    FTileImages[ vPicID ].SetStatus( 2 );

    // Press First
    if FMousedownTileID_1 = -1 then
    begin
      FMousedownTileID_1 := vPicID;
    end
    // Press Second
    else
    begin
      FMousedownTileID_2 := FMousedownTileID_1 ;
      FMousedownTileID_1 := vPicID ;
      vLLKID_2 := FTileIDLLKIDMapping[ FMousedownTileID_2 ] ;  // 取得連連看ID
      vLLKID_1 := FTileIDLLKIDMapping[ FMousedownTileID_1 ] ;

      if LLKUnit.IsLink( vLLKID_1, vLLKID_2 ) in [2,4] then       //FTileImages[ FMousedownTileID_1 ].SetVisible( False ) ;
      begin
        FScore := FScore + ( 2 * CFG_SCORE_WEIGHT ) ; // 得分
        CalcuLLKPathLine( vLLKID_1 , vLLKID_2 , True ) ;   // Is Link, Disapear it
        LLKCheckDeadAndPass( False ) ; // 檢查死亡或過關
        if FPlayerPass = True then
        begin
          if FStage = CFG_MaxStage then
          begin
            ShowMessage('你已經全破了,怎辦?!');
          end
          else
          begin
            FStage := FStage + 1 ;
            Init ;
            ShowMessage('過關了, 進行第' + IntToStr( FStage ) + '關');
          end;
        end;
        if FPlayerDead = True then
        begin
          ShowMessage('你已經死了~囧　(轉身)');
        end;
      end
      else
      begin
        FTileImages[ FMousedownTileID_1 ].SetStatus( 0 );
        FTileImages[ FMousedownTileID_2 ].SetStatus( 0 );
      end;

      FMousedownTileID_1 := -1 ;
      FMousedownTileID_2 := -1 ;
    end;
  end;
end;

procedure TMainForm.ActionAllButtonMouseup;
var
  i : Integer;
  vLength : Integer;
begin
  vLength := Length( FTileImages ) ;
  for i:=0 to vLength-1 do
  begin
    if FTileImages[i].GetStatus = 1 then // if mouseover
      FTileImages[i].SetStatus( 0 );
  end;
end;

procedure TMainForm.ActionFindPath( LLKID_1 : Integer ; LLKID_2 : Integer );
var
  vStartPoint : TPoint ;
  vEndPoint : TPoint ;
  vBoundPoint : TPoint ;
  vMapArray : PByteArray ;
begin
  vStartPoint.X:= LLKID_1 MOD CFG_MAXColumn;
  vStartPoint.Y:= LLKID_1 Div CFG_MAXColumn;

  vEndPoint.X:= LLKID_1 MOD CFG_MAXColumn;
  vEndPoint.Y:= LLKID_1 Div CFG_MAXColumn;

  vBoundPoint.X:= CFG_MAXColumn;
  vBoundPoint.Y:= CFG_MAXRow;

  vMapArray := @LLKUnit._TGR;

  FPathFinder.FindPath( vStartPoint, vEndPoint, vBoundPoint, vMapArray );

  // not finish yet
end;



{---------------------- TMainForm : Event Function End------------------------------}

{---------------------- TMainForm : LLK Function ------------------------------}
procedure TMainForm.LLKShuffle;
var
  i : Integer ;
  vSwapID : Integer ;
  vTmp : Integer ;
  vStartID : Integer ;
begin
  vStartID := -1 ;
  Randomize;
  for i := Low( LLKUnit._TGR ) to High( LLKUnit._TGR ) do
  begin
    if LLKUnit._TGR[ i ] = 0 then continue ;
    if vStartID = -1 then vStartID := i ;
    vSwapID := vStartID + random( FEnableTileNum - 1 );
    if LLKUnit._TGR[ vSwapID ] = 0 then continue ;
    vTmp := LLKUnit._TGR[ vSwapID ] ;
    LLKUnit._TGR[ vSwapID ] := LLKUnit._TGR[ i ] ;
    LLKUnit._TGR[ i ] := vTmp ;
  end;
end;

procedure TMainForm.LLKCheckDeadAndPass( aHintRoad : Boolean );
var
  i : Integer ;
  j : Integer ;
  vIsDead : Boolean ;
  vIsPass : Boolean ;
begin
  vIsDead := True ;
  vIsPass := True ;
  for i := Low( LLKUnit._TGR ) to High( LLKUnit._TGR ) do
  begin
    if LLKUnit._TGR[i] <= 0 then continue ;
    vIsPass := False ; // LLKUnit._TGR[i] > 0 還有方塊// 還有連結, 未過關

    for j := Low( LLKUnit._TGR ) to High( LLKUnit._TGR ) do
    begin
      if LLKUnit._TGR[i] <= 0 then continue ; // Empty
      if i = j then continue ;    // Self
      if LLKUnit._TGR[i] <> LLKUnit._TGR[j] then continue ; // Not the same tiletype
      if LLKUnit.isLink( i , j , True ) in [2,4] then
      begin
        vIsDead := False ; // 還有連結, 未死
        if aHintRoad = True then //檢查參數，是否劃出提示線路？
          CalcuLLKPathLine( i , j , False); // arg 3 means 只是提示,不要消滅方塊
        Break ;
      end;
    end;
    if vIsDead = False then Break ;
  end;

  if vIsPass = True then   // Pass, never dead
  begin
    FPlayerPass := True ;
    FPlayerDead := False;
  end
  else
  begin
    FPlayerPass := False ;  // no pass, dead or live
    FPlayerDead := vIsDead ;
  end
end;

{---------------------- TMainForm : LLK Function End------------------------------}

{---------------------- TMainForm : Tick Function ------------------------------}

procedure TMainForm.MainDXTimerTimer(Sender: TObject; LagCount: Integer);
begin
  if FScoreCount < FScore then Inc(FScoreCount) ;// 改變得分跳針

  DrawAllSets;
  MainDXDraw.Flip;
end;

{---------------------- TMainForm : Tick Function End --------------------------}

function TMainForm.InArray(aSearchArray: array of Integer;
  aValue: Integer): Boolean;
var
  i : Integer ;
  vLength : Integer ;
  vFlag : Boolean ;
begin
  vFlag := False ;
  vLength := Length( aSearchArray ) ;
  for i := 0 to vLength-1 do
  begin
    if aSearchArray[ i ] = aValue then
    begin
      vFlag := True ;
      Break ;
    end;
  end;

  Result := vFlag ;
end;

{---------------------- TResultEffect : ------------------------------}

procedure TResultEffect.AddLightImage( aLightImage : TAnimatedImage );
var
  vLength : Integer ;
begin
  vLength := Length( FRoadLight ) + 1 ;
  SetLength( FRoadLight , vLength ) ;
  FRoadLight[ vLength-1 ] := aLightImage ;
end;

constructor TResultEffect.Create(aFLLKID_1, aFLLKID_2: Integer;
  aTileImage_1, aTileImage_2: TAnimatedImage);
begin
  self.FLLKID_1 := aFLLKID_1 ;
  self.FLLKID_2 := aFLLKID_2 ;
  self.FTileImage_1 := aTileImage_1 ;
  self.FTileImage_2 := aTileImage_2 ;
  self.FTimeToLive := 10 ;
  self.FIfKillTile := True ;

  SetLength( FRoadLight , 0 ) ;
end;

destructor TResultEffect.Destroy;
var
  i : Integer ;
begin
  for i:= Low( FRoadLight ) to High( FRoadLight ) do
  begin
    FRoadLight[i].free ;
  end;

  SetLength( FRoadLight , 0 );
  FRoadLight := nil ;
end;

procedure TResultEffect.DrawLights;
var
  i : Integer ;
  vLength : Integer ;
begin
  // 效果已消失
  if FTimeToLive <= 0 then
  begin
    if FIfKillTile = True then
    begin
      FTileImage_1.SetVisible( False );
      FTileImage_2.SetVisible( False );
    end;
    Exit ;
  end ;
  
  Dec( FTimeToLive ) ;
  vLength := Length( FRoadLight );
  for i:=0 to vLength-1 do
  begin
    FRoadLight[i].SetStatus( FTimeToLive MOD 2 );
    FRoadLight[i].OutputImage ;
  end;
end;

procedure TResultEffect.Hide2Tile;
begin
    FTileImage_1.SetVisible( False );
    FTileImage_2.SetVisible( False );
end;

function TResultEffect.IsDead: Boolean;
begin
  if FTimeToLive <= 0 then
    Result := True
  else
    Result := False ;
end;

procedure TResultEffect.SetKillTile(aIfKill: Boolean);
begin
  FIfKillTile := aIfKill ;
end;

procedure TResultEffect.SetLightStatus(aStatus: Integer);
begin

end;

{---------------------- TResultEffect : ------------------------------}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  LLKCheckDeadAndPass( True ) ;
end;

end.
