Global window = OpenWindow(#PB_Any, 0, 0, 800, 800, "TEST")
Global canvas = CanvasGadget(#PB_Any, 0, 0, 800, 800)
Global color = RGB(127, 234, 200)
Debug color
StartDrawing(CanvasOutput(canvas))
DrawingMode(#PB_2DDrawing_AllChannels)
Box(0,0,800,800,color)
StopDrawing()

Repeat
  event = WaitWindowEvent()
  If event = #PB_Event_Gadget And EventGadget() = canvas
    Define mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
    Define my = GetGadgetAttribute(canvas, #PB_Canvas_MouseY)
    If mx>=0 And mx <800 And my>=0 And my<800
      StartDrawing(CanvasOutput(canvas))
      DrawingMode(#PB_2DDrawing_AllChannels)
      Define picked = Point(mx, my)
      Debug picked
      DrawingMode(#PB_2DDrawing_AlphaChannel)
      Define picked = Point(mx, my)
      Debug picked
      DrawingMode(#PB_2DDrawing_Default)
      Define picked = Point(mx, my)
      Debug picked
      StopDrawing()
    EndIf
  EndIf 
Until event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 2
; EnableXP