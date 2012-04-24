inherited fmMain: TfmMain
  ClientHeight = 515
  ClientWidth = 881
  DoubleBuffered = True
  OnCreate = FormCreate
  OnResize = FormResize
  ExplicitWidth = 889
  ExplicitHeight = 548
  PixelsPerInch = 120
  TextHeight = 16
  object pb: TPaintBox
    Left = 217
    Top = 0
    Width = 664
    Height = 515
    Align = alClient
    OnPaint = pbPaint
    ExplicitLeft = 223
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 515
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object pbBackground: TPaintBox
      Left = 0
      Top = 448
      Width = 217
      Height = 67
      Align = alBottom
      OnPaint = pbBackgroundPaint
    end
    object ColorBox1: TColorBox
      Left = 0
      Top = 0
      Width = 217
      Height = 22
      Align = alTop
      Style = [cbStandardColors]
      TabOrder = 0
      OnChange = ColorBox1Change
    end
  end
end
