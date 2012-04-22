inherited fmMain: TfmMain
  DoubleBuffered = True
  OnCreate = FormCreate
  OnResize = FormResize
  ExplicitWidth = 624
  ExplicitHeight = 428
  PixelsPerInch = 120
  TextHeight = 16
  object pb: TPaintBox
    Left = 129
    Top = 0
    Width = 487
    Height = 395
    Align = alClient
    OnPaint = pbPaint
    ExplicitLeft = 121
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 129
    Height = 395
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
  end
end
