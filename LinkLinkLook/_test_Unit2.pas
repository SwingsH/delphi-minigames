unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LLK, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    Button40: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    Button48: TButton;
    Button49: TButton;
    Button50: TButton;
    Button51: TButton;
    Button52: TButton;
    Button53: TButton;
    Button54: TButton;
    Button55: TButton;
    Button56: TButton;
    Button57: TButton;
    Button58: TButton;
    Button59: TButton;
    Button60: TButton;
    Button61: TButton;
    Button62: TButton;
    Button63: TButton;
    Button64: TButton;
    Button65: TButton;
    Button66: TButton;
    Button67: TButton;
    Button68: TButton;
    Button69: TButton;
    Button70: TButton;
    Button71: TButton;
    Button72: TButton;
    Button73: TButton;
    Button74: TButton;
    Button75: TButton;
    Button76: TButton;
    Button77: TButton;
    Button78: TButton;
    Button79: TButton;
    Button80: TButton;
    Button81: TButton;
    Button82: TButton;
    Button83: TButton;
    Button84: TButton;
    Button85: TButton;
    Button86: TButton;
    Button87: TButton;
    Button88: TButton;
    Button89: TButton;
    Button90: TButton;
    Button91: TButton;
    Button92: TButton;
    Button93: TButton;
    Button94: TButton;
    Button95: TButton;
    Button96: TButton;
    Button97: TButton;
    Button98: TButton;
    Button99: TButton;
    Button100: TButton;
    Button101: TButton;
    Button102: TButton;
    Button103: TButton;
    Button104: TButton;
    Button105: TButton;
    Button106: TButton;
    Button107: TButton;
    Button108: TButton;
    Button109: TButton;
    Button110: TButton;
    Button111: TButton;
    Button112: TButton;
    Button113: TButton;
    Button114: TButton;
    Button115: TButton;
    Button116: TButton;
    Button117: TButton;
    Button118: TButton;
    Button119: TButton;
    Button120: TButton;
    Button121: TButton;
    Button122: TButton;
    Button123: TButton;
    Button124: TButton;
    Button125: TButton;
    Button126: TButton;
    Button127: TButton;
    Button128: TButton;
    Button129: TButton;
    Button130: TButton;
    Button131: TButton;
    Button132: TButton;
    Button133: TButton;
    Button134: TButton;
    Button135: TButton;
    Button136: TButton;
    Button137: TButton;
    Button138: TButton;
    Button139: TButton;
    Button140: TButton;
    Button141: TButton;
    Button142: TButton;
    Button143: TButton;
    Button144: TButton;
    Button145: TButton;
    Button146: TButton;
    Button147: TButton;
    Button148: TButton;
    Button149: TButton;
    Button150: TButton;
    Button151: TButton;
    Button152: TButton;
    Button153: TButton;
    Button154: TButton;
    Button155: TButton;
    Button156: TButton;
    Button157: TButton;
    Button158: TButton;
    Button159: TButton;
    Button160: TButton;
    Button161: TButton;
    Button162: TButton;
    Button163: TButton;
    Button164: TButton;
    Button165: TButton;
    Button166: TButton;
    Button167: TButton;
    Button168: TButton;
    Button169: TButton;
    Button170: TButton;
    Button171: TButton;
    Button172: TButton;
    Button173: TButton;
    Button174: TButton;
    Button175: TButton;
    Button176: TButton;
    Button177: TButton;
    Button178: TButton;
    Button179: TButton;
    Button180: TButton;
    Button181: TButton;
    Button182: TButton;
    Button183: TButton;
    Button184: TButton;
    Button185: TButton;
    Button186: TButton;
    Button187: TButton;
    Button188: TButton;
    Button189: TButton;
    Button190: TButton;
    Button191: TButton;
    Button192: TButton;
    Button193: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button193Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    Btn: Array[1..192] of TButton;
    tempGR : array [1..192] of Byte;

    vTag1: TButton;

  end;

var
  Form1: TForm1;

implementation


{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);

var
  i: Integer;
  j: Integer;

  tmp: Byte;

  vIdx: Integer;
  vStr: String;
begin
  for i:=1 to 192 do
  begin
    Btn[i]:= TButton(Form1.FindComponent('Button'+IntToStr(i)));
    Btn[i].Tag:= i;
  end;

  LLKUnit:= TLLKUnit.Create;
  LLKUnit.Init(13);


  for i:=1 to 192 do
  begin
    Btn[i].Caption:= IntToStr(LLKUnit._TGR[i]);
    tempGR[i]:=LLKUnit._TGR[i];
  end;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(LLKUnit);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  vTag,vTag2: Integer;
  X,Y,i: Integer;
begin

  // 將之前的路徑(標示為-1)重新歸 0
  for i:=1 to LLKColRow do
  begin
    if LLKUnit._TGR[i]<0 then
    begin
      LLKUnit._TGR[i]:=0;
      Btn[i].Caption:= IntToStr(LLKUnit._TGR[i]);
    end;
  end;
  LLKUnit.RoadNum:=-1;
  
  vTag:= TButton(Sender).Tag;

  if StrToInt( TButton(Sender).Caption ) = 0 then exit;

  if vTag1 = nil then
  begin
    vTag1:= TButton(Sender);
    exit;
  end;

  vTag2:= vTag1.Tag;
  if LLKUnit.IsLink(vTag, vTag2) in [2,4] then
  begin
    vTag1.Caption:= '0';
    TButton(Sender).Caption:= '0';

    for i:=1 to 192 do
      Btn[i].Caption:= IntToStr(LLKUnit._TGR[i]);

    for i:=low(LLKUnit.Road) to high(LLKUnit.Road) do
    begin
      if LLKUnit.Road[i]>0 then
        Btn[LLKUnit.Road[i]].Caption:='-1';
    end;

  end;

  vTag1:= nil;
end;

procedure TForm1.Button193Click(Sender: TObject);
var
  i,j,k,l:integer;

begin
  k:=1;
  l:=1;
  for i:=1 to 192 do
  begin
    if tempGR[i]<>0 then
    begin
      for j:=i+1 to 192 do
      begin
        if tempGR[i]=tempGR[j] then
        begin
          if LLKUnit.IsLink(Btn[i].Tag, Btn[j].Tag) in [2,4] then
          begin
            Btn[i].Caption:='0';
            Btn[j].Caption:='0';
            LLKUnit._TGR[i]:=0;
            LLKUnit._TGR[j]:=0;
{            Edit2.Text:=inttostr(l);
            inc(l);
}
            for k:=1 to 192 do
            begin
              Btn[k].Caption:= IntToStr(LLKUnit._TGR[k]);
              tempGR[i]:=LLKUnit._TGR[i];
            end;
            exit;
          end else
          begin
            tempGR[i]:=0;
            tempGR[j]:=0;          
            Edit1.Text:=inttostr(k);
            inc(k);
          end;
        end;
      end;
    end else
    begin
      Edit1.Text:='';
      Edit2.Text:='';
    end;
  end;
  if Edit2.Text='' then
    Button193.Visible:=false;
end;

end.
