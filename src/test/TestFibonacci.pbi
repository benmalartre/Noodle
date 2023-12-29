XIncludeFile "../core/Fibonacci.pbi"
XIncludeFile "../core/UIColor.pbi"
Global N = 32
Global T.f = 0
Global *fibonacci.Fibonacci::Fibonacci_t = Fibonacci::New(N)


Global window = OpenWindow(#PB_Any, 0,0,800,800,"Fibonacci")
Global canvas = CanvasGadget(#PB_Any,0,0,800,800)

Global OFFSETX = 0
Global OFFSETY = 0


Procedure DrawGrid(*fibonacci.Fibonacci::Fibonacci_t, canvas.i, scl.f=0.1)

  Define i
  Define *p.Math::v3f32
  Define s.i
  
  ;Define sp.Math::v2f32, ep.Math::v2f32
  For i=1 To *fibonacci\N-2
    *p = CArray::GetValue(*fibonacci\positions, i)
    s = CArray::GetValueI(*fibonacci\sizes, i)
    
    AddPathBox(*p\x, *p\z, s, s)
    VectorSourceColor(UIColor::RANDOMIZEDWITHALPHA)
    FillPath()
  Next
  
EndProcedure

Procedure DrawSpiral(*fibonacci.Fibonacci::Fibonacci_t, canvas.i)
  Define i, c
  Define *p.Math::v3f32
  Define s.i
  
  ;Define sp.Math::v2f32, ep.Math::v2f32
  For i=1 To *fibonacci\N-2
    c = Int(Mod(i, 4))
    *p = CArray::GetValue(*fibonacci\positions, i)
    s = CArray::GetValueI(*fibonacci\sizes, i)
    Select c
      Case 0
        AddPathCircle(*p\x, *p\z, s, 0, 90)
      Case 1
        AddPathCircle(*p\x, *p\z+s, s, 270, 360)
      Case 2
        AddPathCircle(*p\x+s, *p\z+s, s, 180, 270)
      Case 3
        AddPathCircle(*p\x+s, *p\z, s, 90, 180)
    EndSelect
  Next
  
  VectorSourceColor(RGBA(255,0,0,255))
  StrokePath(2)
  
;   Define path.s = PathSegments()
;   ResetPath()
;   
;   
;   VectorSourceColor(RGBA(255,0,0,255))
;   For i=0 To 34
;     RotateCoordinates(width*0.5, height*0.5, (360/34)*i)
;     AddPathSegments(path)
;     DotPath(3, 12, #PB_Path_RoundCorner)
;   Next
;   
;   FlipCoordinatesX(width*0.5)
;   FlipCoordinatesY(height*0.5)
;   VectorSourceColor(RGBA(0,0,255,255))
;   
;   For i=0 To 21
;     RotateCoordinates(width*0.5, height*0.5, (360/21)*i)
;     AddPathSegments(path)
;     DotPath(3, 12, #PB_Path_RoundCorner)
;   Next
  
EndProcedure
  
Procedure DrawDisc(*fibonacci.Fibonacci::Fibonacci_t, canvas, scl.f)
  Static T = 0
  VectorSourceColor(RGBA(0,255,0,255))
  Define i
  Define *p.Math::v3f32
  For i=0 To CArray::GetCount(*fibonacci\positions)-1
    VectorSourceColor(RGBA(T +i,255,0,255))
    *p = CArray::GetValue(*fibonacci\positions, i)
    AddPathCircle(*p\x, *p\z, 12/scl)
;     StrokePath(1/scl)
    FillPath()
  Next
  
  *p = CArray::GetValue(*fibonacci\positions, 0)
  MovePathCursor(*p\x, *p\z)
  For i=1 To CArray::GetCount(*fibonacci\positions)-1

    *p = CArray::GetValue(*fibonacci\positions, i)
    AddPathLine(*p\x, *p\z)

  Next
  
      VectorSourceColor(RGBA(255,255,0,255))
      StrokePath(1/scl)

  T + 1
EndProcedure

Procedure DrawSphere(*fibonacci.Fibonacci::Fibonacci_t, canvas, scl.f)
  
  VectorSourceColor(RGBA(0,255,0,255))
  Define i
  Define *p.Math::v3f32
  For i=0 To CArray::GetCount(*fibonacci\positions)-1
    VectorSourceColor(RGBA(0,255,0,255))
    *p = CArray::GetValue(*fibonacci\positions, i)
    AddPathCircle(*p\x, *p\y, 16/scl)
    StrokePath(1/scl)
  Next
EndProcedure

Procedure CanvasEvent(canvas)
  OFFSETX + 10
  OFFSETY + 10
EndProcedure


Define scl.f = 0.05
Define width = GadgetWidth(canvas)
Define height = GadgetHeight(canvas)
Define event
Repeat
  event = WaitWindowEvent(10)
  If event = #PB_Event_Gadget 
    If EventGadget() = canvas 
      CanvasEvent(canvas)
    EndIf
    
  EndIf
  
;   Fibonacci::Sphere(*fibonacci)
  Fibonacci::Grid(*fibonacci)
  StartVectorDrawing(CanvasVectorOutput(canvas))  
  TranslateCoordinates(OFFSETX,OFFSETY)
; ;   AddPathBox(0,0, width, height)
; ;   VectorSourceColor(RGBA(0,0,0,255))
; ;   FillPath()
; ;   
; ;   VectorSourceColor(RGBA(0,0,0,255))
; ;   TranslateCoordinates(width * 0.5, height*0.5)
; ;   ScaleCoordinates(scl, scl)
; ; ;   
  
  DrawGrid(*fibonacci,canvas)
  DrawSpiral(*fibonacci, canvas)
; ;   *fibonacci\N + 1
; ;   Fibonacci::Disc(*fibonacci)
;     DrawSphere(*fibonacci, canvas, scl)
; ;   DrawDisc(*fibonacci, canvas, 1024)
;   ;*fibonacci\N+1
  StopVectorDrawing()
    

Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 123
; FirstLine = 101
; Folding = -
; EnableXP