XIncludeFile "../core/Demo.pbi"
XIncludeFile "../core/Fibonacci.pbi"
Global N = 32
Global T.f = 0
Global *fibonacci.Fibonacci::Fibonacci_t = Fibonacci::New(N)
Global *demo.DemoApplication::DemoApplication_t


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


Define width = 800
Define height = 800

 *demo = DemoApplication::New("Test Fibonacci",width,height)
 Define model = Scene::CreateMeshGrid(8,8,8, Shape::#SHAPE_BUNNY)
 Scene::AddModel(*demo\scene, model)
 Scene::Setup(*demo\scene)

 Application::Loop(*demo, DemoApplication::@Draw())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 122
; FirstLine = 68
; Folding = -
; EnableXP