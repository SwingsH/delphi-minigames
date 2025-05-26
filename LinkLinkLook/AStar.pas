unit AStar;
// A* 演算法
// 使用方法：
// findpath = AStart.Create(nil);
// findpath.FindPath(START, END, MapSize, Map array);
// for i:=0 to findpath.PathCount do begin
//   findpath.Path[i].X, findpath.Path[i].Y
// end;

interface

uses
  Windows, Types, Classes, SysUtils, Math,
  BinaryHeap, Contnrs, ExtCtrls;

const
  XDirection: array[0..8] of Integer = (-1, -1, -1, 0, 1, 1, 1, 0, 0);
  YDirection: array[0..8] of Integer = (-1, 0, 1, 1, 1, 0, -1, -1, 0);
  GDirection: array[0..1] of Integer = (14, 10);

type

  TSearchFlag = (sfInOpenQueue, sfInClosedQueue);
  TSearchFlags = set of TSearchFlag;

  TAStart = class;

  // A* 的一個節點
  TAStartNode = class
  private
    FF: Integer;
    FG: Integer;
    FH: Integer;
    FParent: TAStartNode;
    FPoint: TPoint;
    FNeighborCount: Integer;
    FState: TSearchFlags;
    FOwner: TAStart;
    function GetNeighbor(index: Integer): TASTartNode;
  public
    constructor Create(AOwner: TAStart; x, y: Integer);
    property Point: TPoint read FPoint write FPoint;
    property F: Integer read FF write FF;
    property G: Integer read FG write FG;
    property H: Integer read FH write FH;
    property Parent: TAStartNode read FParent write FParent;
    property State: TSearchFlags read FState write FState;
    property Owner: TAStart read FOwner;
    property NeighborCount: Integer read FNeighborCount;
    property Neighbor[index: Integer]: TAStartNode read GetNeighbor;
  end;

  TNodesFactory = class(TObjectList)
  private
    FOwner: TAStart;
  public
    constructor Create(AOwner: TAStart);
    procedure Resize(width, height: Integer);
  end;

  TOpenSet = class(TBinaryHeap)
  private
    function AStartCompare(Data1, Data2: Pointer): Integer;
  public
    constructor Create;
    procedure Push(node: TAStartNode);
    function Pop: TAStartNode;
  end;

  TPathStep = class
  private
    FY: Integer;
    FX: Integer;
  public
    constructor Create(ax, ay: Integer);

    property X: Integer read FX;
    property Y: Integer read FY;
  end;

  TAStart = class(TComponent)
  private
    FSPoint, FEPoint: TPoint;
    FMap: PByteArray;
    FBound: TPoint;
    FPath: TObjectList;

    OpenSet: TOpenSet;
    NodesList: TNodesFactory;

    procedure GetFGH(s, e: TPoint; node: TAStartNode; G: Integer);

    function GetPath(aindex: Integer): TPathStep;
    function GetPathCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FindPath(aspoint, aepoint, bound: TPoint; amap: PByteArray);
    function NodeFromXY(x, y: Integer): TAStartNode;
    procedure ClearPath;    
    property Path[aindex: Integer]: TPathStep read GetPath;
    property PathCount: Integer read GetPathCount;
  end;

implementation

{ TOpenSet }

function TOpenSet.AStartCompare(Data1, Data2: Pointer): Integer;
var
  Item1: TAStartNode;
  Item2: TAStartNode;
begin
  Item1 := TAStartNode(Data1);
  Item2 := TAStartNode(Data2);
  if Item1.F > Item2.F then
    Result := 1
  else
    Result := 0;
end;

constructor TOpenSet.Create;
begin
  inherited Create(nil);
  Self.OnCompare := AStartCompare;
end;

function TOpenSet.Pop: TAStartNode;
begin
  Result := TAStartNode(inherited Pop);
  Result.State := Result.State - [sfInOpenQueue];
end;

procedure TOpenSet.Push(node: TAStartNode);
begin
  node.State := node.State + [sfInOpenQueue];
  inherited Push(Pointer(node));
end;

{ TAStart }

procedure TAStart.ClearPath;
begin
  FPath.Clear;
end;

constructor TAStart.Create(AOwner: TComponent);
begin
  inherited Create(Aowner);
  FPath := TObjectList.Create;
  OpenSet := TOpenSet.Create;
  NodesList := TNodesFactory.Create(self);
end;

destructor TAStart.Destroy;
begin
  FPath.Free;
  OpenSet.Free;
  NodesList.Free;
  inherited;
end;

procedure TAStart.FindPath(aspoint, aepoint, bound: TPoint;
  amap: PByteArray);
var
  node, subnode: TAStartNode;
  G: Integer;
  step: TPathStep;
  i: Integer;
begin
  NodesList.Resize(bound.X, bound.Y);

  OpenSet.Reset(bound.X * bound.Y);
  FPath.Clear;

  FSPoint := aspoint;
  FEpoint := aepoint;
  FBound := bound;
  FMap := amap;

  node := NodeFromXY(aspoint.X, aspoint.Y);
  GetFGH(aspoint, aepoint, node, 0);
  node.Parent := nil;
  OpenSet.Push(node);

  while OpenSet.Count <> 0 do begin
    node := OpenSet.Pop;
    node.State := node.State + [sfInClosedQueue];
    if (node.Point.X = FEPoint.X) and (node.Point.Y = FEPoint.Y) then
      break;
    for i := 0 to node.NeighborCount do begin
      subnode := node.Neighbor[i];
      if (subnode = nil) or (FMap[subnode.Point.Y * bound.X + subnode.Point.X] <> 0) then
        Continue;
      if sfInClosedQueue in subnode.State then
        Continue;
      G := node.G + GDirection[i mod 2];
      if sfInOpenQueue in subnode.State then begin
        if subnode.G > G then begin
          subnode.G := G;
          subnode.F := subnode.H + G;
          subnode.Parent := node;
          OpenSet.ReSort(subnode);
        end;
        Continue;
      end;
      GetFGH(subnode.Point, FEPoint, subnode, G);
      subnode.Parent := node;
      OpenSet.Push(subnode);
    end;
  end;
  node := NodeFromXY(FEPoint.X, FEPoint.Y);
  while true do begin
    step := TPathStep.Create(node.Point.X, node.Point.Y);
    FPath.Add(step);
    if node.Parent = nil then
      break;
    node := node.Parent;
  end;
end;

procedure TAStart.GetFGH(s, e: TPoint; node: TAStartNode; G: Integer);
begin
//  node.H := (Abs(e.X - s.X) + Abs(e.y - s.y)) * 10;
  node.H := Trunc(Sqrt(Sqr(e.X-s.X) + Sqr(e.Y-s.Y))) * 10;
  node.G := G;
  node.F := node.H + G;
end;

function TAStart.GetPath(aindex: Integer): TPathStep;
begin
  Result := TPathStep(FPath[aindex]);
end;

function TAStart.GetPathCount: Integer;
begin
  Result := FPath.Count;
end;

function TAStart.NodeFromXY(x, y: Integer): TAStartNode;
begin
  Result := TAStartNode(NodesList[y*FBound.X+x]);
end;

{ TPathStep }

constructor TPathStep.Create(ax, ay: Integer);
begin
  self.FX := ax;
  self.FY := ay;
end;

{ TAStartNode }

constructor TAStartNode.Create(AOwner: TAStart; x, y: Integer);
begin
  FOwner := AOwner;
  FNeighborCount := 4;
  FF := 0;
  FG := 0;
  FH := 0;
  FParent := nil;
  FPoint := Types.Point(x, y);
  FState := [];
end;

function TAStartNode.GetNeighbor(index: Integer): TASTartNode;
begin
  Result := FOwner.NodeFromXY(FPoint.X + XDirection[index], FPoint.Y + YDirection[index]);
end;

{ TNodesFactory }

constructor TNodesFactory.Create(AOwner: TAStart);
begin
  FOwner := AOwner;
end;

procedure TNodesFactory.Resize(width, height: Integer);
var
  x, y: Integer;
begin
  for x:=0 to self.Count-1 do
    TAStartNode(self[x]).Free;
  self.Count := width * height;
  for y := 0 to height - 1 do begin
    for x := 0 to width - 1 do begin
      self[y * width + x] := TAStartNode.Create(FOwner, x, y);
    end;
  end;
end;

end.

