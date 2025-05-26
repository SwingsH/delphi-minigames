unit Unit_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXDraws, DXClass, StdCtrls;

type

  //圖片資訊
  TImageRecord = Record
    Path : String[64] ;
    X : Integer ;
    Y : Integer ;
    Width : Integer ;
    Height : Integer ;
    Alpha : Boolean ;
    ActiveID : Integer ; //作用 ID ,FK, 若非-1則表示可以點選或托拉, 對應到 TActiveRecord.ActiveID
    ActiveType : Integer ; //作用類型, 識別該物件的種類
    Status : Integer ; //狀態, 如 1.None 2.MouseOver 3.MouseDown 4.Click
    ShiftMode : Integer ; //位移模式, 0.無位移 1.X軸-縱位移 2.Y軸-縱位移
    ShiftHeight : Integer ; //位移模式下的高
    ShiftWidth : Integer ; //位移模式下的寬
  end;

  //下注類型
  TBetType = Record
    ID : Integer ; //編號
    Weighting : Integer ; //賭注加權
    Description : String ;//類型說明
    Visible : Boolean ; //是否顯示在下注列表上
    ActiveID : Integer ; //作用 ID ,FK, 若非-1則表示可以點選或托拉, 對應到 TActiveRecord.ActiveID
    Status : Integer ; //狀態, 如 1.None 2.MouseOver 3.MouseDown 4.Click
    ButtonImage : String ; //按鈕圖示
    TableImage : String ;//臺桌圖示
  end;

  //可作用(托拉、點選)的物件資訊
  TActiveRecord = Record
    ActiveID : Integer ;
    Start_X : Integer ; // 左上角 X
    Start_Y : Integer ; // 左上角 Y
    End_X : Integer ; // 右下角 X
    End_Y : Integer ; // 右下角 Y
    Depth : Integer ; // 深度 , z-index , 堆疊次序
    ActiveType : Integer ;
  end;

  { Pointer of ActiveRecord }
  PActiveRecord = ^TActiveRecord ;

  TMainForm = class(TForm)
    DXMainDraw: TDXDraw;
    DXMainTimer: TDXTimer;
    MemoMain: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure DXMainDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXMainDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXMainDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXMainTimerTimer(Sender: TObject; LagCount: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    FMainSurface : TDirectDrawSurface ;
    FMainSurface2 : TDirectDrawSurface ;
    FCursorX : Integer ;  // 鼠標 X
    FCursorY : Integer ;  // 鼠標 Y
    FTableCount : Integer ; // 臺桌燈號計數器
    FTableCount_GameResult : Integer ; // 臺桌燈號 : 遊戲結果
    FDoubleGameCount : Integer ; // 大小遊戲燈號
    FDoubleGameCount_GameResult : Integer ; // 大小遊戲燈號 : 遊戲結果
    FTick : Integer ; // 計數器
    FTickInterval : Integer ; // 計數器的移動間隔
    FItvlIndex : Integer ; // 計數器的移動間隔表索引值
    FActiveList : TList ; // 存放畫面中所有可作用(托拉、點選)的物件資訊
    FPresentMouseoverID : Integer ; // 滑鼠Over的物件ID
    FPresentMousedownID : Integer ; // 滑鼠Down的物件ID
    FTotalMoney : Integer ; // 持有金錢
    FTotalCoin : Integer ; // 持有彩金
    FWinCoin : Integer ; // 中獎彩金
    FBetEnableNums : Integer ; // 可下注按鈕數量
    FPlayMode : Integer ; // 遊戲進行進度

    { 代幣下注紀錄 }
    FBetCoinArray : array of Integer ;

    { 左右加倍下注紀錄 }
    FBetDouble : Integer ;

    { 動態圖片資產's 變數 , 下注按鈕物件 }
    FBetTypes : array of TBetType ;

    { 動態圖片資產's 變數 , 操作按鈕物件 }
    FImageSets : array of TImageRecord ;

    { 可作用物件的圖片讀取器 : index 與 FActiveList 相同 }
    FActiveSurface : array[0..14] of TDirectDrawSurface ;

    { 靜態的圖片讀取器 : 背景 }
    FStaticSurface : array[0..6] of TDirectDrawSurface ;

    { 靜態的圖片讀取器 : 桌面物件 }
    FTableSurface : array of TDirectDrawSurface ;

    { 燈泡的圖片讀取器 }
    FLightSurface : TDirectDrawSurface ;

    { 數字的圖片讀取器 }
    FNumberSurface : array[0..2] of TDirectDrawSurface ;

    procedure DrawAllSets( aIfFlip : Boolean );
    procedure DrawNumberGraphic( X: Integer ; Y : Integer ; aNumber : Integer ;
                                 aStyle: String ; aAlign : String ); //繪製數字圖形
    procedure DrawText( X: Integer ; Y : Integer ; aContent: String ; aColor : TColor ); //繪製文字
    procedure DrawCoordinateMSG ; //繪製座標軸文字
    function RecordAddActive( aX, aY, aW, aH, aType : Integer) : Integer ;  // 加入可作用物件
    procedure RecordUpdateActive( aActiveID, aStatus : Integer ) ;  // 加入可作用物件
    procedure SetBetRecord( aIndex : Integer ; aIncrement : Integer ) ;
    procedure ActionMoveTableLight ;
    function ActionCheckIfBetted : Boolean ;
    procedure ActionChangeInterval( aSeed : Integer ; aIfRand : Boolean ; aMode : Integer) ;
    procedure ActionCalcuGameResult;
    function ActionCalcuTotalBet: Integer ;
    procedure ActionDepositCoin ;
    procedure ShowNotice( aContent : String );
    function GetBetRecord( aIndex : Integer ) : Integer ;
    function GetBetIDByActiveID( aActiveID : Integer ) : Integer ;
    function GetCursorActiveID : Integer ;
    function GetActiveStatus( aActiveID : Integer ) : Integer ;
    function GetActiveType( aActiveID : Integer ) : Integer ;
    procedure InitialData ;
  end;

const        
  CFG_BETICON_SHIFTWIDTH = 36 ;   // 下注按鈕寬
  CFG_BETICON_SHIFTHEIGHT = 36 ;  // 下注按鈕高

  CFG_BETBUTTON_BLOCK_X = 45 ;    // 下注按鈕區塊起始 X
  CFG_BETBUTTON_BLOCK_Y = 442 ;   // 下注按鈕區塊起始 Ｙ

  CFG_TABLEELEMENT_SHIFTWIDTH = 50 ;   // 桌面物件寬
  CFG_TABLEELEMENT_SHIFTHEIGHT = 50 ;  // 桌面物件高

  CFG_TABLEELEMENT_BLOCK_X = 30 ;  // 桌面物件區塊起始 X
  CFG_TABLEELEMENT_BLOCK_Y = 50 ;  // 桌面物件區塊起始 Y

  CFG_TABLEELEMENT_ROWNUM = 6 ; // 桌面物件每一列的數目

  CFG_LIGHT_IMG = 'pic/Ico_Light.bmp' ;  // 燈泡圖檔
  CFG_LIGHT_SHIFTWIDTH = 12 ;    // 燈泡寬
  CFG_LIGHT_SHIFTHEIGHT = 12 ;   // 燈泡高

  CFG_MAXBET = 9 ;     // 投注最大值
  CFG_COINPRICE = 10 ; // 一枚代幣的價格, 金錢與代幣比值

  CFG_DEFAULT_INTERVAL = 5 ;

  ONCEMORE = -1 ;
  NONE = -1 ;
  BY_X = 1 ;
  BY_Y = 2 ;
  STATUS_NONE = 0 ;
  STATUS_OVER = 1 ;
  STATUS_DOWN = 2 ;
  BET_BIG = 0 ;
  BET_SMALL = 1 ;

  // Button : ActiveType Setup
  BUTTON_BET = 1 ;
  BUTTON_CONTROL = 0 ;
  BUTTON_CONTROL_START = 2 ;
  BUTTON_CONTROL_GET = 3 ;
  BUTTON_CONTROL_RESET = 4 ;
  BUTTON_CONTROL_LEAVE = 5 ;
  BUTTON_CONTROL_BIG = 11 ;
  BUTTON_CONTROL_SMALL = 12 ;
  
  DECREASE = 0 ;
  INCREASE = 1 ;

  PLAYMODE_BEGIN = 1 ;  // 遊戲狀態 : 遊戲開始前
  PLAYMODE_BETTING = 2 ;  // 遊戲狀態 : 下注中
  PLAYMODE_RUN = 3 ;  // 遊戲狀態 : 跑桌面燈號
  PLAYMODE_RESULT = 4 ;  // 遊戲狀態 : 桌面賭注結果
  PLAYMODE_DOUBLEGAME = 5 ;  // 遊戲狀態 : 跑大小燈號
  PLAYMODE_DOUBLEGAME_FINISH = 6 ;  // 遊戲狀態 : 大小燈號賭注結果

  { 靜態圖片資產 }
  CFG_BackgroundSets :array[0..6] of TImageRecord = (
    // 背景圖
    ( Path:'pic/BG_SmallMary.bmp' ; X:0 ; Y:0 ; Width:500 ; Height:550 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //中獎彩金
    ( Path:'pic/CCGradePrize.bmp' ; X:45 ; Y:20 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //中獎彩金底框
    ( Path:'pic/Frame_MoneyEdit2.bmp' ; X:117 ; Y:15 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //身上彩金
    ( Path:'pic/CCMaryPrize.bmp' ; X:392 ; Y:242 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //身上彩金底框
    ( Path:'pic/Frame_MoneyEdit2.bmp' ; X:385 ; Y:262 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //身上金錢
    ( Path:'pic/icon_Money.bmp' ; X:392 ; Y:300 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 ),
    //身上金錢底框
    ( Path:'pic/Frame_MoneyEdit2.bmp' ; X:385 ; Y:322 ; Width:-1 ; Height:-1 ;
      ActiveID :-1 ;Status : -1 ; ShiftMode:-1 ; ShiftHeight:-1 ; ShiftWidth:-1 )
  );

  { 動態圖片資產, 操作按鈕物件 }
  CFG_ImageSets :array[0..5] of TImageRecord = (
    //按鈕:啟動
    ( Path:'pic/btnStart.bmp' ; X:387 ; Y:360 ; Width:39 ; Height:63 ;
      Alpha : True ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_START ;
      Status : 0 ; ShiftMode:BY_X ;  ShiftHeight:21 ; ShiftWidth:39 ),
    //按鈕:得分
    ( Path:'pic/btn_GetGrade.bmp' ; X:387 ; Y:381 ; Width:39 ; Height:63 ;
      Alpha : True ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_GET ;
      Status : 0 ; ShiftMode:BY_X ; ShiftHeight:21 ; ShiftWidth:39 ),
    //按鈕:清除
    ( Path:'pic/btnClear.bmp' ; X:387 ; Y:402 ; Width:39 ; Height:63 ;
      Alpha : True ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_RESET ;
      Status : 0 ; ShiftMode:BY_X ;  ShiftHeight:21 ; ShiftWidth:39 ),
    //按鈕:離開
    ( Path:'pic/btn_Leave.bmp' ; X:387 ; Y:442 ; Width:39 ; Height:63 ;
      Alpha : True ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_LEAVE ;
      Status : 0 ; ShiftMode:BY_X ;  ShiftHeight:21 ; ShiftWidth:39 ),
    //按鈕: 臺桌 - 大
    ( Path:'pic/Btn_Big.bmp' ; X:137 ; Y:290 ; Width:36 ; Height:108 ;
      Alpha : False ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_BIG ;
      Status : 0 ; ShiftMode:BY_X ;  ShiftHeight:36 ; ShiftWidth:36 ),
    //按鈕: 臺桌 - 小
    ( Path:'pic/Btn_Small.bmp' ; X:233 ; Y:290 ; Width:36 ; Height:108 ;
      Alpha : False ; ActiveID :-1 ; ActiveType : BUTTON_CONTROL_SMALL ;
      Status : 0 ; ShiftMode:BY_X ;  ShiftHeight:36 ; ShiftWidth:36 )
  );

  { 動態圖片資產,下注類型 }
  CFG_BetTypes : array[0..11] of TBetType = (
    ( ID : 0 ; Weighting :   4 ; Description : '蘋果' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit09.bmp' ; TableImage : 'pic/Ico_Fruit10.bmp' ),
    ( ID : 1 ; Weighting :  20 ; Description : '西瓜' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit08.bmp' ; TableImage : 'pic/Ico_Fruit09.bmp'),
    ( ID : 2 ; Weighting :  30 ; Description : '星星' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit07.bmp' ; TableImage : 'pic/Ico_Fruit08.bmp' ),
    ( ID : 3 ; Weighting :  40 ; Description : '幸運七' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit06.bmp' ; TableImage : 'pic/Ico_Fruit07.bmp' ),
    ( ID : 4 ; Weighting : 100 ; Description : 'BAR' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit05.bmp' ; TableImage : 'pic/Ico_Fruit06.bmp' ),
    ( ID : 5 ; Weighting :  15 ; Description : '鈴鐘' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit04.bmp' ; TableImage : 'pic/Ico_Fruit04.bmp' ),
    ( ID : 6 ; Weighting :  10 ; Description : '冬瓜' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit03.bmp' ; TableImage : 'pic/Ico_Fruit03.bmp' ),
    ( ID : 7 ; Weighting :  10 ; Description : '橘子' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit02.bmp' ; TableImage : 'pic/Ico_Fruit02.bmp' ),
    ( ID : 8 ; Weighting :   2 ; Description : '櫻桃' ; Visible : True ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : 'pic/Btn_Fruit01.bmp' ; TableImage : 'pic/Ico_Fruit01.bmp' ),
    ( ID : 9 ; Weighting :  50 ; Description : 'BAR50' ; Visible : False ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : '' ; TableImage : 'pic/Ico_Fruit05.bmp' ),
    ( ID :10 ; Weighting :ONCEMORE ; Description : 'ONCEMORE' ; Visible : False ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : '' ; TableImage : 'pic/Ico_Fruit11.bmp' ),
    ( ID :11 ; Weighting :ONCEMORE ; Description : 'ONCEMORE' ; Visible : False ; ActiveID :-1 ;Status : 0 ;
               ButtonImage : '' ; TableImage : 'pic/Ico_Fruit12.bmp' )
  );

  { 座標資訊, 大小遊戲燈號 }
  CFG_PointDoubleLight :array[0..1] of TPoint =       
    ( ( X: 149 ; Y : 278 ), ( X: 245 ; Y : 278 ) );

  { 資料, 臺桌佈置設定值 }
  CFG_TableElement : array[0..23] of Integer =
    ( 7,5,9,4,0,8,6,1,8,11,0,8,7,5,8,3,0,8,6,2,8,10,0,8 );

  { 資料, 台桌燈號間隔表 , 0 表示燈號結束 , 停止 }
  CFG_IntervalSet : array[0..7] of Integer =
    ( 3 , 2 , 1 , 8 , 20 , 50 , 90 ,  0 ) ;

  { 資料, 大小燈號間隔表 , 0 表示燈號結束 , 停止 }
  CFG_IntervalSetDouble : array[0..6] of Integer =
    ( 4 , 6 , 9 , 12 , 12 , 18 , 0 ) ;
var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{---------------------- Main Function -------------------------}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Data
  FActiveList := TList.Create ;
  FCursorX := 0 ;
  FCursorY := 0 ;
  FTableCount := NONE ;
  FTableCount_GameResult := NONE ;
  FDoubleGameCount := NONE ;
  FDoubleGameCount_GameResult := NONE ;
  FTickInterval := 1 ;
  FItvlIndex := 0 ;
  FTotalMoney := 2000000000 ;
  FTotalCoin := 0 ;
  FWinCoin := 0 ;
  FPresentMousedownID := NONE ;
  FPresentMouseoverID := NONE ;
  FBetEnableNums := 0 ;
  FPlayMode := PLAYMODE_BEGIN ;
  FBetDouble := NONE ;
  DXMainDraw.Initialize ;
  MemoMain.Lines.Clear ;

  InitialData;
  FMainSurface := TDirectDrawSurface.Create( DXMainDraw.DDraw );

  //Graphic
  DrawAllSets( True ) ;

end;

procedure TMainForm.InitialData;
var
  i : Integer ;
  vLength : Integer ;
  vActiveID : Integer ;
  vID : Integer ;
begin
  { 初始化 : 動態圖片資產, 操作按鈕物件 }
  vLength := Length( CFG_ImageSets );
  SetLength( FImageSets , vLength ) ;

  for i := Low(FImageSets) to vLength-1 do
  begin
    // Record assign , assign pointer
    FImageSets[ i ] := CFG_ImageSets[ i ] ;   //  指派 cons 的 record 到 dynamic variable

    // 新增按鈕為可作用物件資料
    vActiveID := RecordAddActive( FImageSets[ i ].X ,
                                  FImageSets[ i ].Y ,
                                  FImageSets[ i ].ShiftWidth ,
                                  FImageSets[ i ].ShiftHeight,
                                  FImageSets[ i ].ActiveType );
    // 新增可作用物件資料專用的圖片讀取器                              
    FImageSets[ i ].ActiveID := vActiveID ;
    FActiveSurface[ vActiveID ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
    FActiveSurface[ vActiveID ].LoadFromFile( FImageSets[ i ].Path );
    if FImageSets[ i ].Alpha = True then
      FActiveSurface[ vActiveID ].TransparentColor := FActiveSurface[ vActiveID ].Pixels[0,0];
  end;

  { 初始化 : 動態圖片資產, 下注類型 }
  vLength := Length( CFG_BetTypes ) ;
  SetLength( FBetTypes , vLength ) ;
  for i := Low( FBetTypes ) to vLength-1 do
  begin
    // Record assign , assign pointer
    FBetTypes[ i ] := CFG_BetTypes[ i ] ;
    // 新增按鈕為可作用物件資料
    if FBetTypes[ i ].Visible = True then
    begin
      vActiveID := RecordAddActive( CFG_BETBUTTON_BLOCK_X + ( i * CFG_BETICON_SHIFTWIDTH ) ,
                                    CFG_BETBUTTON_BLOCK_Y ,
                                    CFG_BETICON_SHIFTWIDTH,
                                    CFG_BETICON_SHIFTHEIGHT,
                                    BUTTON_BET );
      FBetTypes[ i ].ActiveID := vActiveID ;
      // 新增可作用物件資料專用的圖片讀取器
      FActiveSurface[ vActiveID ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
      FActiveSurface[ vActiveID ].LoadFromFile( FBetTypes[ i ].ButtonImage );
      FActiveSurface[ vActiveID ].TransparentColor := FActiveSurface[ vActiveID ].Pixels[0,0];
      FBetEnableNums := FBetEnableNums + 1 ;
    end;
  end;

  { 初始化 : 圖片讀取 - 燈泡}
  FLightSurface := TDirectDrawSurface.Create( DXMainDraw.DDraw ) ;
  FLightSurface.LoadFromFile( CFG_LIGHT_IMG );

  { 初始化 : 圖片讀取 - 靜態 }
  vLength := Length( CFG_BackgroundSets ) ;
  for i := 0 to vLength-1  do
  begin
    FStaticSurface[ i ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
    FStaticSurface[ i ].LoadFromFile( CFG_BackgroundSets[ i ].Path );
    FStaticSurface[ i ].TransparentColor := FStaticSurface[ i ].Pixels[0, 0] ;
  end;

  { 初始化 : 圖片讀取 - 桌面物件 }
  vLength := Length( CFG_TableElement ) ;
  SetLength( FTableSurface , vLength ) ;
  for i:= 0 to vLength-1 do
  begin
    vID := CFG_TableElement[ i ];
    FTableSurface[ i ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
    FTableSurface[ i ].LoadFromFile( CFG_BetTypes[ vID ].TableImage ) ;
  end;
  { 初始化 : 圖片讀取 - 數字 }
  FNumberSurface[ 0 ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
  FNumberSurface[ 0 ].LoadFromFile( 'pic/Number_BU.bmp' );
  FNumberSurface[ 0 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;
  FNumberSurface[ 1 ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
  FNumberSurface[ 1 ].LoadFromFile( 'pic/Number_ELE.bmp' );
  FNumberSurface[ 1 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;
  FNumberSurface[ 2 ] := TDirectDrawSurface.Create( DXMainDraw.DDraw );
  FNumberSurface[ 2 ].LoadFromFile( 'pic/Number_MY.bmp' );
  FNumberSurface[ 2 ].TransparentColor := FNumberSurface[ 0 ].Pixels[0, 0] ;

  { 初始化 : 代幣下注紀錄 }
  SetLength( FBetCoinArray , FBetEnableNums ) ;
  SetBetRecord( NONE , 0 ) ;
end;

{---------------------- Draw Functions -------------------------}
procedure TMainForm.DrawAllSets( aIfFlip : Boolean );
const
  // 桌面矩形排列設定, 上右下左, 絕對位置
  TB_SF_INCRE : array[0..3] of TPoint = (
    ( X: CFG_TABLEELEMENT_SHIFTWIDTH ; Y: 0 ),
    ( X: 0 ; Y: CFG_TABLEELEMENT_SHIFTHEIGHT ),
    ( X: -CFG_TABLEELEMENT_SHIFTWIDTH ; Y: 0 ),
    ( X: 0 ; Y: -CFG_TABLEELEMENT_SHIFTHEIGHT )
  );
  // 燈泡角落排列設定, 上右下左, 相對位置
  LIGHT_CORNER_POS : array[0..3] of TPoint = (
    ( X: CFG_TABLEELEMENT_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ;
      Y: CFG_TABLEELEMENT_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ),
    ( X: 0 ; Y: CFG_TABLEELEMENT_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ),
    ( X: 0 ; Y: 0 ),
    ( X: CFG_TABLEELEMENT_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ; Y: 0 )
  );
  // 燈泡矩形排列設定, 上右下左, 相對位置
  LIGHT_RELATED_POS : array[0..3] of TPoint = (
    ( X: ( CFG_TABLEELEMENT_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ) DIV 2 ;
      Y: CFG_TABLEELEMENT_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ),
    ( X: 0 ; Y: ( CFG_TABLEELEMENT_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ) DIV 2 ),
    ( X: ( CFG_TABLEELEMENT_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ) DIV 2 ; Y: 0 ),
    ( X: CFG_TABLEELEMENT_SHIFTWIDTH - CFG_LIGHT_SHIFTWIDTH ;
      Y: ( CFG_TABLEELEMENT_SHIFTHEIGHT - CFG_LIGHT_SHIFTHEIGHT ) DIV 2 )
  );
var
  i : Integer ;
  vNums : Integer ;
  vImage : TImageRecord ;
  vID : Integer ;
  vBet : TBetType ;
  vX : Integer ;
  vY : Integer ;
  vX_Incre : Integer ;
  vY_Incre : Integer ;
  vStatus : Integer ;
begin
  // 繪制固定之 "圖片資產"
  vNums := Length( CFG_BackgroundSets ) ;
  for i := 0 to vNums-1  do
  begin
    DXMainDraw.Surface.Draw( CFG_BackgroundSets[ i ].X ,
                             CFG_BackgroundSets[ i ].Y ,
                             FStaticSurface[ i ] );
  end;

  // 繪制動態之 "圖片資產"        
  vNums := Length( FImageSets ) ;
  for i := 0 to vNums-1  do
  begin
    vImage := FImageSets[ i ] ;
    vStatus := GetActiveStatus( vImage.ActiveID );
    vID := vImage.ActiveID ;
    DXMainDraw.Surface.Draw( vImage.X, vImage.Y,
                             Rect( 0 ,
                                   vImage.ShiftHeight*vStatus ,
                                   vImage.ShiftWidth,
                                   vImage.ShiftHeight*(vStatus+1) ) ,
                             FActiveSurface[ vID ] );
  end;

  // 繪製 "大小燈號" 按鈕
  vX := CFG_PointDoubleLight[0].X ;   // 大
  vY := CFG_PointDoubleLight[0].Y ;
  if FDoubleGameCount = 0 then vStatus := 1
  else vStatus := 0 ;
  DXMainDraw.Surface.Draw( vX, vY,
                           Rect( 0, CFG_LIGHT_SHIFTHEIGHT*vStatus ,
                                 CFG_LIGHT_SHIFTWIDTH ,
                                 CFG_LIGHT_SHIFTHEIGHT*(vStatus+1) ) ,
                             FLightSurface ,False ) ;
  vX := CFG_PointDoubleLight[1].X ;   // 小
  vY := CFG_PointDoubleLight[1].Y ;
  if FDoubleGameCount = 1 then vStatus := 1
  else vStatus := 0 ;
  DXMainDraw.Surface.Draw( vX, vY,
                           Rect( 0, CFG_LIGHT_SHIFTHEIGHT*vStatus ,
                                 CFG_LIGHT_SHIFTWIDTH ,
                                 CFG_LIGHT_SHIFTHEIGHT*(vStatus+1) ) ,
                             FLightSurface ,False ) ;

  // 繪製 "下注類型" 按鈕
  vNums := Length( CFG_BetTypes ) ;
  for i := 0 to vNums-1 do
  begin
    vBet := FBetTypes[ i ] ;
    if vBet.Visible = True then
    begin
      // 取得 Mouse 狀態
      vStatus := GetActiveStatus( vBet.ActiveID );
      // 繪製按鈕
      vX := CFG_BETBUTTON_BLOCK_X + ( i * CFG_BETICON_SHIFTWIDTH );
      vY := CFG_BETBUTTON_BLOCK_Y ;
      DXMainDraw.Surface.Draw( vX , vY ,
                               Rect( 0,
                                     CFG_BETICON_SHIFTWIDTH*vStatus,
                                     CFG_BETICON_SHIFTWIDTH,
                                     CFG_BETICON_SHIFTHEIGHT*(vStatus+1)),
                               FActiveSurface[ vBet.ActiveID ] ,False);
      // 繪製加權數字碼
      DrawNumberGraphic( vX + 3 , vY - 20 , vBet.Weighting , 'blue' , 'center');
      // 繪製投注數字碼
      DrawNumberGraphic( vX + 8 , vY + 42 , GetBetRecord( vBet.ID ) , 'electric' , '');
    end;
  end;

  // 繪製 "臺桌物件"
  vNums := Length( CFG_TableElement ) ;
  vX := CFG_TABLEELEMENT_BLOCK_X ;
  vY := CFG_TABLEELEMENT_BLOCK_Y ;
  vX_Incre := TB_SF_INCRE[ 0 ].X ;
  vY_Incre := TB_SF_INCRE[ 0 ].Y ;
 
  for i := 0 to vNums-1 do
  begin
    // 繪製桌面物件
    DXMainDraw.Surface.Draw( vX , vY , FTableSurface[ i ] ,False ) ;

    // 繪製桌面物件 : 燈泡
    if FTableCount = i then
      vStatus := 1
    else
      vStatus := 0 ;

    if i mod CFG_TABLEELEMENT_ROWNUM = 0 then
    begin
      DXMainDraw.Surface.Draw( vX + LIGHT_CORNER_POS[ i DIV CFG_TABLEELEMENT_ROWNUM ].X ,
                               vY + LIGHT_CORNER_POS[ i DIV CFG_TABLEELEMENT_ROWNUM ].Y ,
                               Rect( 0, CFG_LIGHT_SHIFTHEIGHT*vStatus ,
                                     CFG_LIGHT_SHIFTWIDTH ,
                                     CFG_LIGHT_SHIFTHEIGHT*(vStatus+1) ) ,
                               FLightSurface ,False ) ;
    end
    else
      DXMainDraw.Surface.Draw( vX + LIGHT_RELATED_POS[ i DIV CFG_TABLEELEMENT_ROWNUM ].X ,
                               vY + LIGHT_RELATED_POS[ i DIV CFG_TABLEELEMENT_ROWNUM ].Y ,
                               Rect( 0, CFG_LIGHT_SHIFTHEIGHT*vStatus ,
                                     CFG_LIGHT_SHIFTWIDTH ,
                                     CFG_LIGHT_SHIFTHEIGHT*(vStatus+1) ) ,
                               FLightSurface ,False) ;

    // 偵測轉角
    if i MOD CFG_TABLEELEMENT_ROWNUM = 0 then
    begin
      vX_Incre := TB_SF_INCRE[ i DIV CFG_TABLEELEMENT_ROWNUM ].X ;
      vY_Incre := TB_SF_INCRE[ i DIV CFG_TABLEELEMENT_ROWNUM ].Y ;
    end;

    vX := vX + vX_Incre ;
    vY := vY + vY_Incre ;
  end;

  // 繪製 遊戲中的三種 "金錢數值"
  DrawNumberGraphic( 391 , 330 , FTotalMoney , 'my' , 'center');
  DrawNumberGraphic( 391 , 270 , FTotalCoin , 'my' , 'center');
  DrawNumberGraphic( 121 ,  23 , FWinCoin , 'my' , 'center');
  DrawCoordinateMSG ;

  if aIfFlip = True then
    DXMainDraw.Flip();
end;

procedure TMainForm.DrawCoordinateMSG ;
begin
  //繪制座標軸文字
  DrawText( 420 , 530 , 'X:' + IntToStr(FCursorX) + ' , Y:' + IntToStr(FCursorY), clBlack ) ;
end;

//繪製數字圖形
procedure TMainForm.DrawNumberGraphic( X, Y: Integer; aNumber: Integer ; aStyle: String ; aAlign: String );
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
    DXMainDraw.Surface.Draw( X + i* (vShiftWidth + vShiftPadding ), Y ,
                             Rect( vStart_X ,0 , vEnd_X , vShiftHeight ),
                             vSurface );
  end;
end;

procedure TMainForm.DrawText( X: Integer ; Y : Integer ; aContent: String ; aColor:TColor );
begin
  DXMainDraw.Surface.Canvas.Brush.Style := bsFDiagonal;
  DXMainDraw.Surface.Canvas.Font.Color := aColor ;
  DXMainDraw.Surface.Canvas.TextOut( X , Y , aContent );
  DXMainDraw.Surface.Canvas.Release;
end;

procedure TMainForm.ShowNotice(aContent: String);
begin
  MemoMain.Lines.Append( aContent ) ;
end;


{---------------------- Draw Functions End -------------------------}

{---------------------- Record Functions -------------------------}

function TMainForm.RecordAddActive(aX, aY, aW, aH, aType: Integer ): Integer;
var
  vPActiveRecord : PActiveRecord ;
begin

  New( vPActiveRecord );
  vPActiveRecord^.ActiveID := FActiveList.Count ;
  vPActiveRecord^.Start_X := aX ;
  vPActiveRecord^.Start_Y := aY ;
  vPActiveRecord^.End_X := aX + aW ;
  vPActiveRecord^.End_Y := aY + aH ;
  vPActiveRecord^.Depth := 0 ;
  vPActiveRecord^.ActiveType := aType ;

  FActiveList.Add( vPActiveRecord ) ;

  Result := vPActiveRecord.ActiveID ;

end;

procedure TMainForm.RecordUpdateActive(aActiveID, aStatus: Integer);
begin
  //
end;

function TMainForm.GetBetRecord(aIndex: Integer): Integer;
begin
  Result := FBetCoinArray[ aIndex ] ;
end;

procedure TMainForm.SetBetRecord( aIndex, aIncrement: Integer);
var
  i : Integer ;
  vLength : Integer ;
begin
  // 清空所有下注
  if aIndex = NONE then
  begin
    vLength := Length( FBetCoinArray ) ;
    for i:= 0 to vLength-1 do
    begin
      //下注模式下的清空 BETTING :還回金錢
      //非下注模式下的清空 RESULT , DOUBLEGAME_FINISH  : 不還回金錢
      if FPlayMode = PLAYMODE_BETTING then
        FTotalMoney := FTotalMoney + (FBetCoinArray[ i ]*CFG_COINPRICE) ;
      
      FBetCoinArray[ i ] := 0 ;
    end;
  end
  // 正常下注
  else
  begin
    if ( aIncrement = DECREASE ) AND (FBetCoinArray[ aIndex ] > 0 )then
      FBetCoinArray[ aIndex ] := FBetCoinArray[ aIndex ] - 1  // FTotalMoney := FTotalMoney + CFG_COINPRICE ;
    else if ( aIncrement = INCREASE ) AND ( FBetCoinArray[ aIndex ] < CFG_MAXBET ) then
      FBetCoinArray[ aIndex ] := FBetCoinArray[ aIndex ] + 1 ; // FTotalMoney := FTotalMoney - CFG_COINPRICE ;
  end;
end;

function TMainForm.GetActiveStatus( aActiveID : Integer ) : Integer ;
begin
  if aActiveID = FPresentMousedownID then
    Result := STATUS_DOWN
  else if aActiveID = FPresentMouseoverID then
    Result := STATUS_OVER
  else
    Result := STATUS_NONE ;
end;

function TMainForm.GetActiveType(aActiveID: Integer): Integer;
var
  vPActive : PActiveRecord ;
begin
  if aActiveID < FActiveList.Count then
  begin
    vPActive := FActiveList.Items[ aActiveID ] ;
    Result := vPActive.ActiveType ;
  end
  else
    Result := NONE ;
end;

function TMainForm.GetBetIDByActiveID( aActiveID : Integer ): Integer;
var
  i : Integer ;
  vLength : Integer ;
  vID : Integer ;
begin
  vLength := Length( FBetTypes );
  vID := NONE ;
  for i:=Low( FBetTypes ) to vLength-1 do
  begin
    if FBetTypes[ i ].ActiveID = aActiveID then
      vID := FBetTypes[ i ].ID ;
  end;

  Result := vID ;
end;

{---------------------- Record Functions End -------------------------}

{---------------------- Action Function ---------------------------}
procedure TMainForm.ActionMoveTableLight ;
var
  vLightNums : Integer ;
begin
  vLightNums := Length( CFG_TABLEELEMENT ) ;
  FTableCount := FTableCount + 1 ;
  if FTableCount = vLightNums then
    FTableCount := 0 ;
end;

function TMainForm.ActionCheckIfBetted: Boolean;
var
  i : Integer;
  vLength : Integer ;
  vFlag : Boolean ;
begin
  // 檢測是否有下注
  vLength := Length( FBetCoinArray );
  vFlag := False ;
  for i:=0 to vLength-1 do
  begin
    if FBetCoinArray[ i ] > 0 then
    begin
      vFlag := True ;
    end;
  end;

  Result := vFlag ;
end;

function TMainForm.ActionCalcuTotalBet: Integer ;
var
  i : Integer;
  vLength : Integer ;
  vTotalBet : Integer ;
begin
  vLength := Length( FBetCoinArray );
  vTotalBet := 0 ;
  for i:=0 to vLength-1 do
  begin
    vTotalBet := vTotalBet + FBetCoinArray[ i ] * CFG_COINPRICE ;
  end;

  Result := vTotalBet ;
end;

procedure TMainForm.ActionCalcuGameResult;
var
  vBetTypeID : Integer ;
  vBet : TBetType ;
  vCoin : Integer ;
begin
  vBetTypeID := CFG_TableElement[ FTableCount_GameResult ] ;
  vBet := CFG_BetTypes[ vBetTypeID ] ; // 取得 BetType 物件的 "類型資訊"
  if vBetTypeID = 9 then vBetTypeID := 4 ; // 轉換 Bar50 的 ID 成為 Bar 的 ID
  vCoin := FBetCoinArray[ vBetTypeID ]; // 取得 BetType 物件的 "代幣投注金額"

  // ONCEMORE 再來一次
  if vBet.Weighting = ONCEMORE then
    FPlayMode := PLAYMODE_RUN
  else
  // "不是" 再來一次
  begin
    vCoin := vCoin * vBet.Weighting ;  // 1.計算結果
    if vCoin > 0 then
      ShowNotice( '贏得' + IntToStr( vCoin ) + '彩金。' );// 2.顯示結果
    FWinCoin := vCoin ;  // 3.更改彩金
  end;
end;

procedure TMainForm.ActionChangeInterval( aSeed: Integer; aIfRand: Boolean ; aMode : Integer );
begin

  if aMode = PLAYMODE_RUN then
  begin
    if aIfRand = False then
      FTickInterval := aSeed
    else if aIfRand = True then
    begin
      if Random( 100 ) > 95 then
      begin
        FItvlIndex := ( FItvlIndex + 1 ) MOD Length( CFG_IntervalSet ) ;
        FTickInterval := CFG_IntervalSet[ FItvlIndex ] ;
      end;
    end;
  end

  else if aMode = PLAYMODE_DOUBLEGAME then
  begin
    if Random( 100 ) > 95 then
    begin
      FItvlIndex := ( FItvlIndex + 1 ) MOD Length( CFG_IntervalSetDouble ) ;
      FTickInterval := CFG_IntervalSetDouble[ FItvlIndex ] ;
    end;
  end;
end;


procedure TMainForm.ActionDepositCoin;
begin
  if FWinCoin > 0 then //取得前次未結彩金
  begin
   ShowNotice( '取回' + IntToStr(FWinCoin) + '彩金' );
   FTotalCoin := FTotalCoin + FWinCoin ;
   FWinCoin := 0 ;
  end;
end;

{---------------------- Action Function End ---------------------------}

{---------------------- Mouse Event Functions -------------------------}
procedure TMainForm.DXMainDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vID : Integer ;
begin
  vID := GetCursorActiveID ;
  FPresentMousedownID := vID ;
end;

procedure TMainForm.DXMainDrawMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  FCursorX := X ;
  FCursorY := Y ;
  FPresentMouseoverID := GetCursorActiveID ;
  if FPresentMouseoverID <> NONE then
  begin
    
  end;
end;

procedure TMainForm.DXMainDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vUpID : Integer ;
  vBetID : Integer ;
  vType : Integer ;
  vTotalBet : Integer ;
begin
  vUpID := GetCursorActiveID ;

  // Down 目標與 Up 目標相同, 才有動作
  if ( FPresentMousedownID = vUpID ) AND
     ( FPresentMousedownID <> NONE) then
  begin
     vType := GetActiveType( vUpID ) ;
     case vType of

       BUTTON_BET :  // 投注按鈕
       begin
         // 可以執行此操作的 "遊戲狀態 PlayMode"
         if ( FPlayMode = PLAYMODE_BEGIN )OR
            ( FPlayMode = PLAYMODE_BETTING ) OR
            ( FPlayMode = PLAYMODE_RESULT ) OR
            ( FPlayMode = PLAYMODE_DOUBLEGAME_FINISH ) then
         begin
           FPlayMode:= PLAYMODE_BETTING ;  //更新遊戲狀態

           //設置加或減少投注碼
           vBetID := GetBetIDByActiveID( vUpID ) ;
           if mbLeft = Button then
             SetBetRecord( vBetID , INCREASE )
           else if mbRight = Button then
             SetBetRecord( vBetID , DECREASE );
         end;
       end ;

       BUTTON_CONTROL_START :  // 功能按鈕 : "啟動"
       begin
         vTotalBet := ActionCalcuTotalBet ;
         // 可以執行此操作的 "遊戲狀態 PlayMode"
         if ( vTotalBet > 0 ) AND  // 已下注才可開始
            (( FPlayMode = PLAYMODE_BETTING ) OR
             ( FPlayMode = PLAYMODE_RESULT ) OR
             ( FPlayMode = PLAYMODE_DOUBLEGAME_FINISH )) then
         begin
           FPlayMode:= PLAYMODE_RUN ;  //更新遊戲狀態
           ActionDepositCoin ; // 取得前次未結彩金
           FTableCount := 0 ;  //初始化燈號
           FTotalMoney := FTotalMoney - vTotalBet ; // 扣除金錢
           ShowNotice( '花費' + IntToStr( vTotalBet ) + '金錢。' );
         end;
       end;

       BUTTON_CONTROL_GET :  // 功能按鈕 : "得分"
       begin
         //可以執行此操作的 "遊戲狀態 PlayMode"
         if ( FPlayMode = PLAYMODE_BETTING ) OR
            ( FPlayMode = PLAYMODE_RESULT ) OR
            ( FPlayMode = PLAYMODE_DOUBLEGAME_FINISH ) then
         begin
           FPlayMode := PLAYMODE_BETTING ;
           //取得未結彩金
           ActionDepositCoin;
         end;
       end;         

       BUTTON_CONTROL_RESET :  // 功能按鈕 : "清除"
       begin
         // 可以執行此操作的 "遊戲狀態 PlayMode"
         if ( FPlayMode = PLAYMODE_BETTING ) OR
            ( FPlayMode = PLAYMODE_RESULT ) OR
            ( FPlayMode = PLAYMODE_DOUBLEGAME_FINISH ) then
         begin
           FPlayMode := PLAYMODE_BETTING ;
           SetBetRecord( NONE , NONE ); // 清除投注
           ActionDepositCoin ; // 取得彩金
         end;
       end;

       BUTTON_CONTROL_LEAVE :  // 功能按鈕 : "離開"
       begin
         if ( FPlayMode = PLAYMODE_BEGIN ) OR
            ( FPlayMode = PLAYMODE_BETTING ) OR
            ( FPlayMode = PLAYMODE_RESULT ) OR
            ( FPlayMode = PLAYMODE_DOUBLEGAME_FINISH ) then
           Close;
       end;

       BUTTON_CONTROL_BIG :
       begin
         // 可以執行此操作的 "遊戲狀態 PlayMode"
         if FWinCoin > 0 then
         begin
           FPlayMode := PLAYMODE_DOUBLEGAME ;
           FTableCount := NONE ;   // 取消桌面燈號
           FBetDouble := BET_BIG ;
         end;
       end;

       BUTTON_CONTROL_SMALL :
       begin
         // 可以執行此操作的 "遊戲狀態 PlayMode"
         if FWinCoin > 0 then
         begin
           FPlayMode := PLAYMODE_DOUBLEGAME ;
           FTableCount := NONE ;   // 取消桌面燈號
           FBetDouble := BET_SMALL ;
         end;
       end;

       NONE :
       begin
         // Do nothing
       end;

     end;
  end;

  FPresentMousedownID := NONE ; // 點選放開時, 清空點選紀錄
end;

// 取得指標所在的 "作用物件"之ID
function TMainForm.GetCursorActiveID : Integer ;
var
  i : Integer ;
  vLength : Integer ;
  vID : Integer ;
  vPActive : PActiveRecord ;
begin

  vID := NONE ;
  vLength := FActiveList.Count ;

  for i := 0 to vLength-1 do
  begin
    vPActive := FActiveList.Items[ i ] ;
    if (( FCursorX >= vPActive.Start_X ) AND ( FCurSorX <= vPActive.End_X ))
       AND
       (( FCursorY >= vPActive.Start_Y ) AND ( FCurSorY <= vPActive.End_Y )) then
    begin
      vID := vPActive.ActiveID ;
    end ;
  end;

  Result := vID ;
end;

{---------------------- Mouse Event Functions END-------------------------}

{---------------------------- Tick Functions -----------------------------}

procedure TMainForm.DXMainTimerTimer(Sender: TObject; LagCount: Integer);
begin

  case FPlayMode of
    { 遊戲狀態 : 遊戲開始前 }
    PLAYMODE_BEGIN :
    begin
      FTick := FTick + 1 ;
      if FTick MOD FTickInterval = 0 then
        ActionMoveTableLight ; // 移動桌面燈號
    end;

    { 遊戲狀態 : 下注中 }
    PLAYMODE_BETTING :
    begin
      FTableCount := NONE ;  // 取消桌面燈號
    end;

    { 遊戲狀態 : 跑桌面燈號 }
    PLAYMODE_RUN :
    begin
      FTick := FTick + 1 ;
      ActionChangeInterval( NONE , True , PLAYMODE_RUN );  // 更改燈號間隔
      // 桌面燈號結束
      if FTickInterval = 0 then
      begin
        FPlayMode := PLAYMODE_RESULT ;  // 更改狀態
        FTickInterval := CFG_DEFAULT_INTERVAL ; // 恢復燈號移動間隔值
        FItvlIndex := 0 ; // 恢復燈號移動間隔 索引值
        FTableCount_GameResult := FTableCount ; // 儲存該輪結果
        ActionCalcuGameResult ; // 計算該輪結果
      end
      // 桌面燈號尚未結束
      else if FTick MOD FTickInterval = 0 then
        ActionMoveTableLight ; // 移動桌面燈號
    end;

    { 遊戲狀態 : 桌面賭注結果 }
    PLAYMODE_RESULT :
    begin
      FTick := FTick + 1 ;
      ActionChangeInterval( 2 , False , PLAYMODE_RUN );  // 更改燈號間隔

      // 閃爍桌面燈號
      if FTick MOD FTickInterval = 0 then
        FTableCount := FTableCount_GameResult
      else
        FTableCount := NONE ;
    end;

    {遊戲狀態 : 跑大小燈號}
    PLAYMODE_DOUBLEGAME :
    begin
      FTick := FTick + 1 ;
      ActionChangeInterval( NONE , True , PLAYMODE_DOUBLEGAME );  // 更改燈號間隔

      // 大小燈號結束
      if FTickInterval = 0 then
      begin
        FPlayMode := PLAYMODE_DOUBLEGAME_FINISH ;  // 更改狀態
        FTickInterval := CFG_DEFAULT_INTERVAL ; // 恢復大小燈號移動間隔值
        FItvlIndex := 0 ; // 恢復燈號移動間隔 索引值
        FDoubleGameCount_GameResult := FDoubleGameCount ; // 儲存大小遊戲該輪結果
        // 計算結果
        if FDoubleGameCount_GameResult = FBetDouble then // 是否中獎
        begin
          FWinCoin := FWinCoin * 2 ;
          ShowNotice( '彩金加倍！' );
        end
        else
        begin
          FWinCoin := 0 ;
          ShowNotice( '彩金歸零。' );
        end;
      end
      // 大小燈號尚未結束
      else if FTick MOD FTickInterval = 0 then
        FDoubleGameCount := (FDoubleGameCount+1) MOD 2 ; // 移動大小燈號
    end;

    { 遊戲狀態 : 大小燈號賭注結果 }
    PLAYMODE_DOUBLEGAME_FINISH :
    begin
      FTick := FTick + 1 ;
      ActionChangeInterval( 2 , False , PLAYMODE_RUN );  // 更改燈號間隔

      // 閃爍桌面燈號
      if FTick MOD FTickInterval = 0 then
        FDoubleGameCount := FDoubleGameCount_GameResult
      else
        FDoubleGameCount := NONE
    end;

  end;
  
  DrawAllSets( False );

  DXMainDraw.Flip ;
end;

{-------------------------- Tick Functions End -------------------------------}

end.
