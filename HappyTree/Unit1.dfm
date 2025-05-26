object Form1: TForm1
  Left = 214
  Top = 300
  Width = 719
  Height = 510
  Caption = 'HappyTree'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 320
    Top = 232
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object Label1: TLabel
    Left = 48
    Top = 48
    Width = 75
    Height = 13
    Caption = #19968#36215#20358#31278#27193#65281'.'
  end
  object Label3: TLabel
    Left = 528
    Top = 16
    Width = 3
    Height = 13
  end
  object DXDraw1: TDXDraw
    Left = 24
    Top = 72
    Width = 657
    Height = 385
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 385
    SurfaceWidth = 657
    TabOrder = 0
    OnClick = EveStageCurRealease
    OnMouseDown = DXDraw1MouseDown
  end
  object Button1: TButton
    Left = 24
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Plant Tree'
    TabOrder = 1
    OnClick = BTNPlantTreeOnclick
  end
  object Button2: TButton
    Left = 144
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Plant AppleTree'
    TabOrder = 2
    OnClick = BTNPlantAppleTreeOnclick
  end
  object Button3: TButton
    Left = 264
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Move Tree'
    TabOrder = 3
    OnClick = BTNMoveTreeOnclick
  end
  object Button4: TButton
    Left = 384
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Kill Tree'
    TabOrder = 4
    OnClick = BTNKillTreeOnclick
  end
  object DXTimer1: TDXTimer
    ActiveOnly = True
    Enabled = True
    Interval = 50
    OnTimer = TickTime
    Left = 672
  end
end
