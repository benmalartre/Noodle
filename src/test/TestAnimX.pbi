XIncludeFile "..\objects\AnimCurve.pbi"

; test
AnimX::Init()

Dim *curves.AnimCurve::Curve_t(0)
ReDim *curves(3)
Define i
For i=0 To ArraySize(*curves())-1
  *curves(i) = AnimCurve::New()
  AnimCurve::AddKeys(*curves(i))
  *curves(i)\crv\setPostInfinityType(AnimX::#ITT_Oscillate)
  *curves(i)\crv\setPreInfinityType(AnimX::#ITT_Oscillate)
Next

Define T.d
While T< 120
  T+10
Wend

Define key.AnimX::Keyframe_t
Define width = 800
Define height = 600

Define window.i = OpenWindow(#PB_Any, 0, 0, width, height, "AnimX")
Define canvas.i = CanvasGadget(#PB_Any,0,0,width, height)

Define cx, cy
Define event.i
Define pan.b
Define bx.i, by.i

Repeat
  event = WaitWindowEvent()
  If event = #PB_Event_Gadget 
    Select EventGadget()
      Case canvas
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            pan = #True
            bx = cx + GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            by = cy + GetGadgetAttribute(canvas, #PB_Canvas_MouseY)          
          Case #PB_EventType_LeftButtonUp
            pan = #False
          Case #PB_EventType_MouseMove
            If pan
               Define mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
               Define my = GetGadgetAttribute(canvas, #PB_Canvas_MouseY)   
               cx = bx - mx
               cy = by - my
             EndIf
         EndSelect
     EndSelect
   EndIf    

    StartVectorDrawing(CanvasVectorOutput(canvas))  
    
    AddPathBox(0, 0, width, height)
    VectorSourceColor(RGBA(66,66,66, 255))
    FillPath()
    
    For i=0 To ArraySize(*curves())-1
      
      AnimCurve::DrawCurve(*curves(i), cx,cy,width, height)
    Next
    
    StopVectorDrawing()

    
  
Until event = #PB_Event_CloseWindow


For i=0 To ArraySize(*curves())-1
  AnimCurve::Delete(*curves(i))
Next
AnimX::Term()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 12
; EnableXP