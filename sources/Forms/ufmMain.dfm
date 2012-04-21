inherited fmMain: TfmMain
  OnCreate = FormCreate
  OnResize = FormResize
  ExplicitWidth = 624
  ExplicitHeight = 428
  PixelsPerInch = 120
  TextHeight = 16
  object pb: TPaintBox
    Left = 97
    Top = 0
    Width = 519
    Height = 395
    Align = alClient
    OnPaint = pbPaint
    ExplicitLeft = 456
    ExplicitTop = 208
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 97
    Height = 395
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
  end
end
