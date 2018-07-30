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

Procedure DrawBackground(width.i, height.i, ox.i, oy.i, zoomx.i, zoomy.i)
  Box(0,0,width, height, RGB(66,66,66))
  Line(ox,0,1,height,RGB(54,54,54))
  Line(0,oy,width, 1, RGB(54,54,54))
  
  Protected sx.f = width / (100/zoomx)
  Protected sy.f = height / (100/zoomy)
  
  Debug "SX : "+StrD(sx)
  Debug "SY : "+StrD(sy)
  
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawText(20,20,"Zoom X : "+StrD(zoomx),RGB(255,255,255))
  DrawText(20,40,"Zoom Y : "+StrD(zoomy), RGB(255,255,255))
EndProcedure

Define key.AnimX::Keyframe_t
Define width = 800
Define height = 600

Define window.i = OpenWindow(#PB_Any, 0, 0, width, height, "AnimX")
Define canvas.i = CanvasGadget(#PB_Any,0,0,width, height)

Define px, py, zx,zy
Define event.i
Define pan.b
Define zoom.b
Define ox.i, oy.i
zx = 100
zy = 100

fps = 25
Repeat
  event = WaitWindowEvent()
  If event = #PB_Event_Gadget 
    Select EventGadget()
      Case canvas
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            pan = #True
            zoom = #False
            ox = px + GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            oy = py + GetGadgetAttribute(canvas, #PB_Canvas_MouseY)          
          Case #PB_EventType_LeftButtonUp
            pan = #False
            zoom = #False
          Case #PB_EventType_RightButtonDown
            zoom = #True
            ox = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            oy = GetGadgetAttribute(canvas, #PB_Canvas_MouseY)    
            pan = #False
          Case #PB_EventType_RightButtonUp
            pan = #False
            zoom = #False
          Case #PB_EventType_MouseMove
            Define mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            Define my = GetGadgetAttribute(canvas, #PB_Canvas_MouseY)   
            If pan
               px = ox - mx
               py = oy - my
             ElseIf zoom
               zx = ox - mx
               zy = oy - my
               If zx <1 : zx = 1 : ElseIf zx >= 400 : zx = 400 : EndIf
               If zy <1 : zy = 1 : ElseIf zy >= 400 : zy = 400 : EndIf
             EndIf
         EndSelect
     EndSelect
   EndIf    
   
   StartDrawing(CanvasOutput(canvas))
   DrawBackground(width, height, -px, -py, zx, zy)
;     StartVectorDrawing(CanvasVectorOutput(canvas))  
;     
;     AddPathBox(0, 0, width, height)
;     VectorSourceColor(RGBA(66,66,66, 255))
;     FillPath()
    
    For i=0 To ArraySize(*curves())-1
      AnimCurve::DrawCurve(*curves(i), px,py,width, height, zx, zy)
    Next
    
    ;     StopVectorDrawing()
    StopDrawing()

    
  
Until event = #PB_Event_CloseWindow


For i=0 To ArraySize(*curves())-1
  AnimCurve::Delete(*curves(i))
Next
AnimX::Term()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 82
; FirstLine = 52
; Folding = -
; EnableXP