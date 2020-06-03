#DRAW_PIXEL = 0
#DRAW_VECTOR = 1
#WIDTH = 600
#HEIGHT = 800
#RADIUS = 80
#NUM_CIRCLE = 2000
#CIRCLE_SEGMENTS = "M 80 50 C 80 66.5685 66.5685 80 50 80 C 33.4315 80 20 66.5686 20 50 C 20 33.4315 33.4314 20 50 20 C 66.5685 20 80 33.4314 80 50 Z"

XIncludeFile "../core/Time.pbi"
Time::Init()

Procedure.d DrawImg(img)
  Define T.d = Time::Get()
  
  ProcedureReturn Time::Get() - T
EndProcedure

Procedure.d DrawPixel()
  Define T.d = Time::Get()
  For i=0 To #NUM_CIRCLE - 1
    Circle(Random(#WIDTH), Random(#HEIGHT), #RADIUS, RGB(Random(255),Random(255),Random(255)))
  Next
  ProcedureReturn Time::Get() - T
EndProcedure

Procedure.d DrawVector()
  Define T.d = Time::Get()
  
  For i=0 To #NUM_CIRCLE - 1
    AddPathCircle(Random(#WIDTH), Random(#HEIGHT), #RADIUS)
    VectorSourceColor(RGBA(Random(255),Random(255),Random(255), 255))
    FillPath()
  Next
  ProcedureReturn Time::Get() - T
EndProcedure

Global window = OpenWindow(#PB_Any, 0,0,2*#WIDTH,#HEIGHT,"Benchmark Drawing")
Global canvas1 = CanvasGadget(#PB_Any,0,0,#WIDTH,#HEIGHT)
Global canvas2 = CanvasGadget(#PB_Any, 600,0,#WIDTH,#HEIGHT)
Define event

LoadFont(0, "Arial", 12)
Define img = CreateImage(#PB_Any, #RADIUS, #RADIUS, 32)
StartDrawing(ImageOutput(img))
Circle(#RADIUS, #RADIUS, #RADIUS, RGB(0,0,255))
StopDrawing()

Define pixelT.d, vectorT.d, imageT.d
Repeat 
  event = WaitWindowEvent(1)
  
  StartDrawing(CanvasOutput(canvas1))
  pixelT = DrawPixel()
  DrawText(20,#HEIGHT - 20, "PIXEL TIME : "+StrD(pixelT)+", FRAME TIME AVG : "+StrD(pixelT / #NUM_CIRCLE))
  StopDrawing()
  
  StartVectorDrawing(CanvasVectorOutput(canvas2))
  vectorT = DrawVector()
  VectorFont(FontID(0))
  MovePathCursor(20,#HEIGHT - 20)
  StopVectorDrawing()
  StartDrawing(CanvasOutput(canvas2))
  DrawText(20,#HEIGHT - 20, "VECTOR TIME : "+StrD(vectorT)+", FRAME TIME AVG : "+StrD(vectorT / #NUM_CIRCLE))
  StopDrawing()
Until event = #PB_Event_CloseWindow

  
    

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 21
; FirstLine = 3
; Folding = -
; EnableXP