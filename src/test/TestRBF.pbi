XIncludeFile "../core/RBF.pbi"

Structure Point_t
  x.f
  y.f
  radius.f
  color.Math::c4f32
EndStructure


Global width.i = 800
Global height.i = 800
Global window
Global canvas
Global nbp = 8
Global mode =  RBF::#KERNEL_GAUSSIAN

Global *rbf.RBF::RBF_t
Global Dim *points.Point_t(nbp)
Global *keys.Matrix::Matrix_t 
Global *values.Matrix::Matrix_t 
Global *query.Matrix::Matrix_t
Global *result.Matrix::Matrix_t
Global P.Point_t
Global font = LoadFont(#PB_Any, "Arial",32)
P\radius = 24
Color::Randomize(P\color)


Procedure AddRandomPoint(width, height)
  Protected *p.Point_t = AllocateMemory(SizeOf(Point_t))
  *p\x = Random(width)
  *p\y = Random(height)
  *p\radius = 12
  Color::Randomize(*p\color)
  ProcedureReturn *p
EndProcedure

Procedure DrawPoint(*p.Point_t)
  VectorSourceColor(RGBA(*p\color\r * 255, *p\color\g * 255, *p\color\b * 255, 255))
  AddPathCircle(*p\x, *p\y, *p\radius)  
  FillPath()
EndProcedure

Procedure DrawMode()
  VectorSourceColor(RGBA(200,200,200,255))
  MovePathCursor(50,50)
  VectorFont(FontID(font), 32)
  Select mode
     
    Case RBF::#KERNEL_CUBIC
      DrawVectorText("MODE : CUBIC")
    Case RBF::#KERNEL_GAUSSIAN
      DrawVectorText("MODE : GAUSSINA")
    Case RBF::#KERNEL_INVERSE
      DrawVectorText("MODE : INVESE")
    Case RBF::#KERNEL_LINEAR
      DrawVectorText("MODE : LINEA")
    Case RBF::#KERNEL_MULTIQUADRIC
      DrawVectorText("MODE : MULTIquaDR")
    Case RBF::#KERNEL_QUINTIC
      DrawVectorText("MODE : QUAIN")
    Case RBF::#KERNEL_THINPLATE
      DrawVectorText("MODE : THIDSPL")
  EndSelect

EndProcedure

Procedure MouseMove()
  Define mx = GetGadgetAttribute(canvas, #PB_OpenGL_MouseX)
  Define my = GetGadgetAttribute(canvas, #PB_OpenGL_MouseY)
  P\x = mx
  P\y = my
EndProcedure


Procedure Update()
  *query\matrix(0) = P\x
  *query\matrix(1) = P\y
  RBF::Interpolate(*rbf, *keys, *query, *result) 
  Color::Set(P\color, *result\matrix(0), *result\matrix(1), *result\matrix(2), 1.0)
EndProcedure


Procedure Draw()
  StartVectorDrawing(CanvasVectorOutput(canvas))
  AddPathBox(0,0,width,height)
  VectorSourceColor(RGBA(120,120,120,255))
  FillPath()
  Define i
  For i=0 To nbp-1
    DrawPoint(*points(i))
  Next
  
  DrawPoint(P)
  
  DrawMode()
  StopVectorDrawing()
EndProcedure


Procedure TestRBF()
  window = OpenWindow(#PB_Any, 0,0,width,height,"RBF")
  canvas = CanvasGadget(#PB_Any, 0,0,width,height, #PB_Canvas_Keyboard)
  Define i
  For i=0 To nbp-1
    *points(i) = AddRandomPoint(width, height)
  Next
  
  ; keys
  *keys.Matrix::Matrix_t = Matrix::New(nbp, 2)
  Define k
  For k=0 To nbp-1
    *keys\matrix(k*2) = *points(k)\x
    *keys\matrix(k*2+1) = *points(k)\y
  Next

  ; values
  *values.Matrix::Matrix_t = Matrix::New(nbp, 3)
  For k = 0 To nbp-1
    *values\matrix(k*3) = *points(k)\color\r
    *values\matrix(k*3+1) = *points(k)\color\g
    *values\matrix(k*3+2) = *points(k)\color\b
  Next
  
   Debug "CREATE"
  ; init the linear system
  *rbf.RBF::RBF_t = RBF::New()
  RBF::Init(*rbf, *keys, *values)
  Debug "INIT"
  
  *query.Matrix::Matrix_t = Matrix::New(1,2)
  *result.Matrix::Matrix_t = Matrix::New(1,3)

  ; get the interpolated value
  RBF::Interpolate(*rbf, *keys, *query, *result) 
  Matrix::Echo(*result, "RESULT")
Debug" UPDATE"
  Define e
  Repeat
    e = WaitWindowEvent() 
    If e = #PB_Event_Gadget And EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_MouseMove
          MouseMove()
          Update()
          Draw()
          
        Case #PB_EventType_KeyDown
          key = GetGadgetAttribute(canvas, #PB_OpenGL_Key)
          If key = #PB_Shortcut_Space
            mode + 1
            If mode > RBF::#KERNEL_THINPLATE : mode = RBF::#KERNEL_LINEAR : EndIf
            RBF::SetKernelType(*rbf, mode)
            Update()
            Draw()
          EndIf
          

      EndSelect
      
    EndIf

  Until e= #PB_Event_CloseWindow
  

EndProcedure


TestRBF()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 127
; FirstLine = 100
; Folding = --
; EnableXP