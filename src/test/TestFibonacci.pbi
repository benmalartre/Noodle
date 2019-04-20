XIncludeFile "../core/Fibonacci.pbi"
XIncludeFile "../core/UIColor.pbi"
Global N = 32
Global T.f = 0
Global *fibonacci.Fibonacci::Fibonacci_t = Fibonacci::New(N)


Global window = OpenWindow(#PB_Any, 0,0,800,800,"Fibonacci")
Global canvas = CanvasGadget(#PB_Any,0,0,800,800)


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
  
  VectorSourceColor(RGBA(0,255,0,255))
  Define i
  Define *p.Math::v3f32
  For i=0 To CArray::GetCount(*fibonacci\positions)-1
    VectorSourceColor(RGBA(0,255,0,255))
    *p = CArray::GetValue(*fibonacci\positions, i)
    AddPathCircle(*p\x, *p\z, 8/scl)
    StrokePath(1/scl)
  Next
EndProcedure

Procedure DrawSphere(*fibonacci.Fibonacci::Fibonacci_t, canvas, scl.f)
  
  VectorSourceColor(RGBA(0,255,0,255))
  Define i
  Define *p.Math::v3f32
  For i=0 To CArray::GetCount(*fibonacci\positions)-1
    VectorSourceColor(RGBA(0,255,0,255))
    *p = CArray::GetValue(*fibonacci\positions, i)
    AddPathCircle(*p\x, *p\y, 8/scl)
    StrokePath(1/scl)
  Next
EndProcedure

Define scl.f = 1
Define width = GadgetWidth(canvas)
Define height = GadgetHeight(canvas)
Repeat
;   Fibonacci::Sphere(*fibonacci)
;   DrawVogel(*fibonacci, canvas)
  Fibonacci::Grid(*fibonacci)
  StartVectorDrawing(CanvasVectorOutput(canvas))  
  AddPathBox(0,0, width, height)
  VectorSourceColor(RGBA(0,0,0,255))
  FillPath()
  
  VectorSourceColor(RGBA(0,0,0,255))
  TranslateCoordinates(width * 0.5, height*0.5)
  ScaleCoordinates(scl, scl)
  
  DrawGrid(*fibonacci,canvas)
  DrawSpiral(*fibonacci, canvas)
;   DrawSphere(*fibonacci, canvas, scl)
  ;*fibonacci\N+1
  StopVectorDrawing()
    

Until WaitWindowEvent(10) = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 2
; Folding = -
; EnableXP