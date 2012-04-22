unit uDrawingEvent;

interface

uses uEventModel, uGraphicPrimitive, Graphics;

const
  CHANGE_BACKGROUND_COLOR = 'CHANGE_BACKGROUND_COLOR';

type
  TDrawingEventData = class(TEventData)
    Primitive: TGraphicPrimitive;
    Color: TColor;
  end;

implementation

end.
