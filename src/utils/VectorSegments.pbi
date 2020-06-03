Define window = OpenWindow(#PB_Any, 0,0,100,120,"Vector", #PB_Window_ScreenCentered)
Define canvas = CanvasGadget(#PB_Any, 0,0,100,100)
Define text = StringGadget(#PB_Any,0,105,100,95, "")
Define init = #False
Repeat
  Define event = WaitWindowEvent()
  If event = #PB_Event_Gadget Or init = #False
    If EventGadget() = canvas Or init = #False
      init = #True
      StartVectorDrawing(CanvasVectorOutput(canvas))
      AddPathCircle(50,50,30)
      VectorSourceColor(RGBA(Random(255), Random(255), Random(255),255))
      Define segments.s = PathSegments()
      StrokePath(4)
      StopVectorDrawing()
      SetGadgetText(text, segments)
    EndIf
  EndIf
  
Until event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 10
; EnableXP