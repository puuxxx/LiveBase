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
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 875
    Height = 502
    Margins.Bottom = 10
    Align = alClient
    OnDblClick = pbDblClick
    OnMouseDown = pbMouseDown
    OnMouseMove = pbMouseMove
    OnMouseUp = pbMouseUp
    OnPaint = pbPaint
    ExplicitLeft = 8
    ExplicitTop = -2
  end
end
