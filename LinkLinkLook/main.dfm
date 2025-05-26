object MainForm: TMainForm
  Left = 216
  Top = 124
  Width = 508
  Height = 577
  Caption = #21487#24976#30340#23567#29802#33673' : '#23567#29802#33673#24976#24976#30475
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
  object MainDXDraw: TDXDraw
    Left = 0
    Top = 0
    Width = 500
    Height = 550
    AutoInitialize = True
    AutoSize = True
    Color = clBtnFace
    Display.FixedBitCount = True
    Display.FixedRatio = True
    Display.FixedSize = False
    Options = [doAllowReboot, doWaitVBlank, doCenter, doDirectX7Mode, doHardware, doSelectDriver]
    SurfaceHeight = 550
    SurfaceWidth = 500
    TabOrder = 0
    OnMouseDown = MainDXDrawMouseDown
    OnMouseMove = MainDXDrawMouseMove
    OnMouseUp = MainDXDrawMouseUp
  end
  object Button1: TButton
    Left = 424
    Top = 32
    Width = 49
    Height = 25
    Caption = #25552#31034
    TabOrder = 1
    OnClick = Button1Click
  end
  object MainDXTimer: TDXTimer
    ActiveOnly = True
    Enabled = True
    Interval = 50
    OnTimer = MainDXTimerTimer
    Left = 16
    Top = 16
  end
end
