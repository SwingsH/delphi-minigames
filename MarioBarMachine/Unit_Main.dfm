object MainForm: TMainForm
  Left = 276
  Top = 139
  Width = 508
  Height = 584
  Caption = 'Mario Bar Machine'
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
  object DXMainDraw: TDXDraw
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
    OnMouseDown = DXMainDrawMouseDown
    OnMouseMove = DXMainDrawMouseMove
    OnMouseUp = DXMainDrawMouseUp
  end
  object MemoMain: TMemo
    Left = 386
    Top = 32
    Width = 97
    Height = 201
    Color = clMenuBar
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 1
    WantReturns = False
  end
  object DXMainTimer: TDXTimer
    ActiveOnly = True
    Enabled = True
    Interval = 30
    OnTimer = DXMainTimerTimer
    Left = 8
    Top = 512
  end
end
