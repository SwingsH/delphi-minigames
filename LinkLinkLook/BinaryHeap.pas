unit BinaryHeap;

interface

uses
  Windows, Types, Classes, SysUtils;

type
  // Compare function
  THeapCompare = function(Data1, Data2: Pointer): Integer of object;

  // Custome Exception
  NoCompareException = class(Exception);
  EmptyException = class(Exception);
  FullException = class(Exception);
  NoFoundException = class(Exception);

  TBinaryHeap = class(TComponent)
  private
    FHeap: array of Pointer;
    FTop: Integer;
    FCompare: THeapCompare;
    function GetHeap: PPointerArray;
  protected
    property Heap: PPointerArray read GetHeap;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset(size: Integer);
    procedure Push(node: Pointer);
    function Pop: Pointer;
    function Peek: Pointer;
    procedure ReSort(item: Pointer);
    procedure Wait;
    property Count: Integer read FTop;
  published
    property Name;
    property Tag;
    property OnCompare: THeapCompare read FCompare write FCompare;
  end;

implementation

{ TBinaryHeap }

constructor TBinaryHeap.Create(AOwner: TComponent);
begin
  inherited;
  FTop := 0;
end;

function TBinaryHeap.GetHeap: PPointerArray;
begin
  Result := @FHeap[0];
end;

function TBinaryHeap.Peek: Pointer;
begin
  Result := FHeap[1];
end;

function TBinaryHeap.Pop: Pointer;
var
  u, v: Integer;
  tmp: Pointer;
begin
  if FTop = 0 then
    raise EmptyException.Create('Pop error. [Empty]');
  if not Assigned(FCompare) then
    raise NoCompareException.Create('Assign event Compare first.');

  Result := FHeap[1];
  FHeap[1] := FHeap[FTop];
  Dec(FTop);
  v := 1;
  while true do begin
    u := v;
    if u * 2 + 1 <= FTop then begin
      if FCompare(FHeap[u], FHeap[u * 2]) = 1 then begin
        v := u * 2;
      end;
      if FCompare(FHeap[v], FHeap[u * 2 + 1]) = 1 then begin
        v := u * 2 + 1;
      end;
    end else if u * 2 <= FTop then begin
      if FCompare(FHeap[u], FHeap[u * 2]) = 1 then begin
        v := u * 2;
      end;
    end;
    if u <> v then begin
      tmp := FHeap[u];
      FHeap[u] := FHeap[v];
      FHeap[v] := tmp;
    end else begin
      Break;
    end;
  end;
end;

procedure TBinaryHeap.Push(node: Pointer);
var
  u, v: Integer;
  tmp: Pointer;
begin
  if not Assigned(FCompare) then
    raise NoCompareException.Create('Assign event Compare first.');
  if FTop >= High(FHeap) then
    raise FullException.Create('Heap full.');
  Inc(FTop);
  FHeap[FTop] := node;
  v := FTop;
  while v <> 1 do begin
    u := v div 2;
    if FCompare(FHeap[u], FHeap[v]) = 1 then begin
      tmp := FHeap[v];
      FHeap[v] := FHeap[u];
      FHeap[u] := tmp;
    end else
      Break;
    v := u;
  end;
end;

procedure TBinaryHeap.Reset(size: Integer);
begin
  FTop := 0;
  SetLength(FHeap, size + 1);
end;

procedure TBinaryHeap.ReSort(item: Pointer);
var
  i, u: Integer;
  index: Integer;
  tmp: Pointer;
begin
  if not Assigned(FCompare) then
    raise NoCompareException.Create('Assign event Compare first.');
  index := 0;
  for i := 1 to FTop do
    if FHeap[i] = item then
      index := i;
  if index = 0 then
    raise NoFoundException.Create('ReSort error [Not Found].');
  while index <> 1 do begin
    u := index div 2;
    if FCompare(FHeap[u], FHeap[index]) = 1 then begin
      tmp := FHeap[u];
      FHeap[u] := FHeap[index];
      FHeap[index] := tmp;
    end else
      Break;
    index := u;
  end;
end;

procedure TBinaryHeap.Wait;
begin
  while FTop > 0 do
    Sleep(10);
end;

end.

