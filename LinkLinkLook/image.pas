unit image ;
{------------------------------------------------
動態圖片類別, 使用方式
 image := TAnimatedImage.Create( ID , DXDraw , ImagePath , IsAlpha ); 建立
 image.SetCoordinate( XYPoint );  設定座標
 image.SetShiftRange( Width , Height , ShiftWidth , ShiftHeight );
     選擇性設定是否有位移功能, (寬,高,位移格式寬,位移格式高), 有設定才為動態圖
 image.SetStatus( frame );
     設定圖片狀態, 若無 SetShiftRange 等同 SetStatus( 0 ),不需呼叫此方法
 image.OutputImage ;  繪出圖形
-------------------------------------------------}

interface

uses
  Types, Variants, DXDraws, Classes ;

type
  TAnimatedImage = class( TObject )
  private
    FID : Integer ;  // 圖片 ID
    FTypeID : Integer ;  // 圖片類型 ID
    FShiftWidth : Integer ;  // 圖片位移寬
    FShiftHeight : Integer ;  // 圖片位移高
    FShiftRangeArray : Array of TRect ; // 圖片位移範圍資料 : Array
    FAlpha : Boolean ;   // 是否有透明值
    FVisible : Boolean ;   // 是否顯示
    FShift : Boolean ;   // 是否有位移功能

    FSurface : TDirectDrawSurface ;  // 圖片讀取 Surface
    FDXDraw : TDXDraw ;             // DXDraw 畫布 Reference
    FShiftRangeIndex : Integer  ;  // 圖片位移範圍資料 : Index
    FPath : String ; // 圖片位置
  public
    FPosition : TPoint ; // 顯示位置
    procedure AddShiftRange( aRect : TRect ) ;  // 單筆加入位移資料
    procedure SetShiftRange( aWidth, aHeight, aShiftWidth,
                             aShiftHeight:Integer  ) ;  // 一次設定所有位移資料
    procedure OutputImage ;  // 描繪圖像
    procedure SetCoordinate( aPosition:TPoint ) ;    // 設置座標
    function GetStatus: Integer;
    procedure SetStatus( aStatus : Integer ) ;
    function GetVisible : Boolean ;
    procedure SetVisible( aVisible : Boolean ) ;          
    procedure SetImage( aPath : String ; aAlpha : Boolean ) ; // 設置圖片檔路徑
    function GetTypeID : Integer ;                      // 取得圖片類型 ID
    property FStatus : Integer read GetStatus write SetStatus ;
    property X : Integer read FPosition.X write FPosition.X ;
    property Y : Integer read FPosition.Y write FPosition.Y ;
    property Path : String read FPath write FPath ;
    constructor Create( aID : Integer ; aDXDraw: TDXDraw ;
                        aPath: String; aAlpha: Boolean );
    destructor Destroy ; override ;
  end;

  TActiveData = class( TObject )
  private
  protected
  public
    FActiveList : TList ;
    function GetActiveID( aX, aY : Integer ): Integer;
    function GetPicID( aX, aY : Integer ): Integer; overload ;
    function GetPicID( aActiveID : Integer ): Integer; overload ;
    function AddItem(aX, aY, aW, aH, aType, aPicID : Integer ): Integer;
    constructor Create ;
  end;

  //圖片資訊
  TImageRecord = Record
    Path : String[64] ;
    X : Integer ;
    Y : Integer ;
    Width : Integer ;
    Height : Integer ;
    Alpha : Boolean ;  // 是否透明
    ImageType : Byte ; // 圖片類型, 識別圖片的種類
    ShiftWidth : Integer ; //位移模式下的寬
    ShiftHeight : Integer ; //位移模式下的高
  end;

  //可作用(托拉、點選)的物件資訊
  TActiveRecord = Record
    ActiveID : Integer ;  // ID , 由 1開始
    Start_X : Integer ; // 左上角 X
    Start_Y : Integer ; // 左上角 Y
    End_X : Integer ; // 右下角 X
    End_Y : Integer ; // 右下角 Y
    Depth : Integer ; // 深度 , z-index , 堆疊次序
    ActiveType : Integer ; // 可作用物件類型, 按鈕類型
    PicID : Integer ; // 動態圖片的 ID , 參照用, 不檢查重複
  end;

  { Pointer of ActiveRecord }
  PActiveRecord = ^TActiveRecord ;

implementation

{-------------------------- TAnimatedImage : Start --------------------------}

{-------------------------- TAnimatedImage : Contructor --------------------}
constructor TAnimatedImage.Create( aID : Integer ; aDXDraw : TDXDraw ;
                                   aPath:String; aAlpha:Boolean );
begin
  self.FSurface := TDirectDrawSurface.Create( aDXDraw.DDraw ) ;
  self.FSurface.LoadFromFile( aPath ) ;
  self.FID := aID ;
  self.FAlpha := aAlpha ;
  self.FShift := False ;
  self.FPath := aPath ;
  self.FVisible := True ;
  self.FDXDraw := aDXDraw ;
  // 預設值
  self.SetStatus( 0 );
  self.FPosition := Point( 0 , 0 ) ;
  if aAlpha = True then
    self.FSurface.TransparentColor := self.FSurface.Pixels[ 0 , 0 ] ;
end;

{-------------------------- TAnimatedImage : Destructor --------------------}
destructor TAnimatedImage.Destroy;
begin
  self.FSurface.free ;
  inherited ;
end;

procedure TAnimatedImage.AddShiftRange(aRect: TRect);
var
  i : Integer ;
begin
  self.FShift := True ;
  i := Length( FShiftRangeArray ) ;
  SetLength( FShiftRangeArray , i + 1 );
  FShiftRangeArray[ i ] := aRect ;
end;

function TAnimatedImage.GetTypeID: Integer;
begin
  Result := FTypeID ;
end;

procedure TAnimatedImage.OutputImage;
var
  vRect : TRect ;
begin
  if FVisible = False then
    exit ;

  if FShift = True then
  begin
    vRect := FShiftRangeArray[ FShiftRangeIndex ] ;
    FDXDraw.Surface.Draw( FPosition.X , FPosition.Y , vRect , FSurface , FAlpha );
  end
  else
  begin
    FDXDraw.Surface.Draw( FPosition.X , FPosition.Y , FSurface , FAlpha );
  end;
end;

procedure TAnimatedImage.SetCoordinate(aPosition: TPoint );
begin
  FPosition := aPosition ;
end;

procedure TAnimatedImage.SetImage( aPath: String; aAlpha: Boolean );
begin
  FAlpha := aAlpha ;
  FSurface.LoadFromFile( aPath ) ;
end;

procedure TAnimatedImage.SetStatus( aStatus: Integer );
begin
  FShiftRangeIndex := aStatus ;
end;

function TAnimatedImage.GetStatus: Integer;
begin
  Result := FShiftRangeIndex ;
end;

procedure TAnimatedImage.SetShiftRange( aWidth, aHeight, aShiftWidth ,
                                        aShiftHeight : Integer );
var
  i : Integer ;
  vLength : Integer ;
  vRect : TRect ;
begin
  self.FShift := True ; // 設定有位移功能
  FShiftWidth := aShiftWidth ;
  FShiftHeight := aShiftHeight ;
  // Shift By Y
  if aWidth = aShiftWidth then
  begin
    vLength := aHeight DIV aShiftHeight ;
    SetLength( FShiftRangeArray , vLength ) ;
    for i:=0 to vLength-1 do
    begin
      vRect := Rect( 0 , i*aShiftHeight , aShiftWidth , (i+1)*aShiftHeight ) ;
      FShiftRangeArray[ i ] := vRect ;
    end;
  end
  // Shift By X
  else if aHeight = aShiftHeight then
  begin
    vLength := aWidth DIV aShiftWidth ;
    SetLength( FShiftRangeArray , vLength ) ;
    for i:=0 to vLength-1 do
    begin
      vRect := Rect( i*aShiftWidth , 0 , (i+1)*aShiftWidth , aShiftHeight ) ;
      FShiftRangeArray[ i ] := vRect ;
    end;
  end
  else
    SetLength( FShiftRangeArray , 1 ) ;
end;

function TAnimatedImage.GetVisible: Boolean;
begin
  Result := self.FVisible ;
end;

procedure TAnimatedImage.SetVisible( aVisible : Boolean );
begin
  self.FVisible := aVisible ;
end;

{-------------------------- TAnimatedImage : End --------------------------}

{-------------------------- TActiveData : Start --------------------------}

function TActiveData.AddItem(aX, aY, aW, aH, aType, aPicID: Integer): Integer;
var
  vPActiveRecord : PActiveRecord ;
begin
  New( vPActiveRecord );
  vPActiveRecord^.ActiveID := FActiveList.Count + 1 ;
  vPActiveRecord^.Start_X := aX ;
  vPActiveRecord^.Start_Y := aY ;
  vPActiveRecord^.End_X := aX + aW ;
  vPActiveRecord^.End_Y := aY + aH ;
  vPActiveRecord^.Depth := 0 ;
  vPActiveRecord^.ActiveType := aType ;
  vPActiveRecord^.PicID := aPicID ;

  FActiveList.Add( vPActiveRecord ) ;
  Result := vPActiveRecord.ActiveID ;
end;

constructor TActiveData.Create;
begin
  FActiveList := TList.Create ;
end;

//取得座標是否有涵蓋到 "作用物件"之ID
function TActiveData.GetActiveID(aX, aY: Integer): Integer ;
var
  i : Integer ;
  vLength : Integer ;
  vID : Integer ;
  vPActive : PActiveRecord ;
begin
  vID := 0 ;  // 預設滑鼠沒有在任何 "作用物件" (按鈕) 上
  vLength := FActiveList.Count ;

  for i := 0 to vLength-1 do
  begin
    vPActive := FActiveList.Items[ i ] ;
    if (( aX >= vPActive.Start_X ) AND ( aX <= vPActive.End_X ))
       AND
       (( aY >= vPActive.Start_Y ) AND ( aY <= vPActive.End_Y )) then
    begin
      vID := vPActive.ActiveID ;
    end ;
  end;

  Result := vID ;
end;

function TActiveData.GetPicID(aX, aY: Integer): Integer;
var
  vActiveID : Integer ;
  vPicID : Integer ;
begin
  vPicID := -1 ;
  vActiveID := GetActiveID( aX, aY );  // 取得滑鼠所在物件
  if vActiveID > 0 then
    vPicID := GetPicID( vActiveID );   // 若滑鼠下有物件,回傳圖片ID

  Result := vPicID ;
end;

function TActiveData.GetPicID(aActiveID: Integer): Integer;
var
  vPActive : PActiverecord ;
begin
  vPActive := FActiveList.Items[ aActiveID - 1 ];
  Result := vPActive.PicID ;
end;

{-------------------------- TActiveData : End --------------------------}


end.
