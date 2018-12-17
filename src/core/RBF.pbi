; ---------------------------------------------------------------------
; Radial Basis Function (RBF) Declaration
; ---------------------------------------------------------------------
XIncludeFile "Matrix.pbi"
EnableExplicit
DeclareModule RBF
  Enumeration
    #RBF_KEY_1D
    #RBF_KEY_2D
    #RBF_KEY_3D
    #RBF_KEY_XD
  EndEnumeration
  
  Structure RBFKeyValue_t
    StructureUnion
      
    EndStructureUnion
  EndStructure
  
    
  Structure RBFKey_t
    type.l
  EndStructure
  
  Enumeration
    #KERNEL_LINEAR
    #KERNEL_GAUSSIAN
    #KERNEL_CUBIC
    #KERNEL_QUINTIC
    #KERNEL_INVERSE
    #KERNEL_MULTIQUADRIC
    #KERNEL_THINPLATE
  EndEnumeration
  
  
  Structure RBF_t
    initialized.b
    epsilon.f
    kernel.i
    *A.Matrix::Matrix_t           ; column vector
    *P.Matrix::Matrix_t           ; positions data
    *F.Matrix::Matrix_t           ; function values
;     sigma.f
;     Array keys.RBFKey_t(0)
;     Array weights.f(0)
  EndStructure
  
  ; Interpolator Kernels
  Macro MULTIQUADRIC(_r, _eps)
    (Sqr(Pow(_r / _eps, 2) +1))
  EndMacro
  
  Macro INVERSE(_r, _eps)
    (1.0 / Sqr(Pow(_r / _eps, 2) + 1))
  EndMacro
  
  Macro GAUSSIAN(_r, _eps)
    (Exp(- Pow(_r / _eps, 2)))
  EndMacro
  
  Macro LINEAR(_r)
    (_r)
  EndMacro
  
  Macro CUBIC(_r)
    (Pow(_r, 3))
  EndMacro
  
  Macro QUINTIC(_r)
    (Pow(_r, 5))
  EndMacro
  
  Macro THINPLATE(_r)
    ((Pow(_r, 2) * Log(_r)) * Bool(_r<0))
  EndMacro  

  
  Declare New()
  Declare Delete(*rbf.RBF_t)
  Declare.f Distance(*rbf.RBF_t, r.f)
  Declare ComputeEpsilon(*rbf.RBF_t, *m.Matrix::Matrix_t)
  Declare Init(*rbf.RBF_t, *xd.Matrix::Matrix_t, *f.Matrix::Matrix_t)
  Declare Interpolate(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
  Declare GetWeights(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
  Declare Update(*rbf.RBF_t, *f.Matrix::Matrix_t)
EndDeclareModule


; ---------------------------------------------------------------------
; Radial Basis Function (RBF) Implementation
; ---------------------------------------------------------------------
Module RBF
  ; constructor
  Procedure New()
    Protected *rbf.RBF_t = AllocateMemory(SizeOf(RBF_t))
    InitializeStructure(*rbf, RBF_t)
    *rbf\epsilon = -1
    *rbf\kernel = #KERNEL_MULTIQUADRIC
    *rbf\initialized = #False
    ProcedureReturn *rbf
  EndProcedure
  
  ; destructor
  Procedure Delete(*rbf.RBF_t)
    If *rbf
      ClearStructure(*rbf, RBF_t)
      FreeMemory(*rbf)
    EndIf
  EndProcedure
  
  ; automaticaly compute the best epsilon
  Procedure ComputeEpsilon(*rbf.RBF_t, *m.Matrix::Matrix_t)
    Define N = *m\rows
    Dim minimums.f(0)
    Dim maximums.f(0)
    
    Matrix::GetColumnsMinimum(*m, minimums())
    Matrix::GetColumnsMaximum(*m, maximums())
    Define product.f = 1.0
    Define size, i
    For i=0 To *m\columns-1
      Define edge.f = maximums(i) - minimums(i)
      If edge <> 0
        product * edge
        size + 1
      EndIf
    Next
    
    *rbf\epsilon = Pow(product / N, 1.0 / size)
  EndProcedure
  
  ; compute distance with active kernel
  Procedure.f Distance(*rbf.RBF_t, r.f)
    Define dist.f
    Select *rbf\kernel
      Case #KERNEL_LINEAR
        dist = MULTIQUADRIC(r, *rbf\epsilon)
      Case #KERNEL_GAUSSIAN
        dist = GAUSSIAN(r, *rbf\epsilon)
      Case #KERNEL_CUBIC
        dist = CUBIC(r)
      Case #KERNEL_QUINTIC
        dist = QUINTIC(r)
      Case #KERNEL_MULTIQUADRIC
        dist = MULTIQUADRIC(r, *rbf\epsilon)
      Case #KERNEL_INVERSE
        dist = INVERSE(r, *rbf\epsilon)
      Case #KERNEL_THINPLATE
        dist = THINPLATE(r)
      Default
        dist = MULTIQUADRIC(r, *rbf\epsilon)
    EndSelect
    ProcedureReturn dist
  EndProcedure
  
  
  ; Inputs
  ;   xd[pntCount * dimentions], the Data points:
  ;   pnt 0: [x, y, ....]
  ;   pnt 1: [x, y, ....]
  ;   pnt 2: [x, y, ....]
  ;
  ;   f[pntCount], the function values at the Data points.
  ; Output:
  ;   nothing : the weights stored in the member A.
  Procedure Init(*rbf.RBF_t, *xd.Matrix::Matrix_t, *f.Matrix::Matrix_t)
    If *rbf\epsilon = -1 : ComputeEpsilon(*rbf, *xd) : EndIf
    
    ; store the distances
    *rbf\P = *xd
    *rbf\F = *f
    
    Define nbp = *xd\rows
    Define d = *xd\columns
    Define r.f
    
    If Not *rbf\A 
      *rbf\A.Matrix::Matrix_t = Matrix::New(nbp, nbp)
    Else
      Matrix::Resize(*rbf\A, nbp, nbp)  
    EndIf
    
    Define i, j, k
    For i=0 To nbp-1
      For j=0 To nbp-1
        r = 0.0
        For k=0 To d-1
          r + Pow(Matrix::Get(*xd, i, k) - Matrix::Get(*xd, j, k), 2)
        Next
        r = Sqr(r)
        Matrix::Set(*rbf\A, i, j, Distance(*rbf, r))
      Next
    Next
    
    ; solve the weights
    Matrix::InverseInPlace(*rbf\A)
    *rbf\initialized = #True
    
  EndProcedure
  
  Procedure InterpolateAtIndex(*rbf.RBF_t, i.i, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, column.i, nd.i, m.i, *AxF.Matrix::Matrix_t, Array fi.f(1))
    Define r.f
    Dim v.f(nd)
    Define j, k
    For j=0 To nd-1
      r = 0.0
      For k=0 To m-1
        r + Pow(Matrix::Get(*xi, i, k) - Matrix::Get(*xd, j, k), 2)
      Next
      r = Sqr(r)
      v(j) = Distance(*rbf, r)
    Next
    
    fi(i) = 0.0
    For j=0 To nd-1

      fi(i) + v(j) * *AxF\matrix(j)
    Next
    
  EndProcedure
  
;    Inputs
;      xd[posesCount * dimentions], the Data points:
;      pnt 0: [x, y, ....]
;      pnt 1: [x, y, ....]
;      pnt 2: [x, y, ....]
;
;      xi[pntCount * dimentions], the interpolation points:
;
;    Output:
;      an Array of interpolated values per xi points.
  Procedure Interpolate(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
    Matrix::Resize(*result, *xi\rows, *rbf\F\columns)
    Define nd = *xd\rows
    Define m = *xd\columns
    Define ni = *xi\rows
    Define column, i
    Define *AxF.Matrix::Matrix_t = Matrix::New(0,0)
    For column=0 To *rbf\F\columns-1
      Dim fi.f(ni)
      Dim vector.f(0)
      Matrix::GetColumn(*rbf\F, column, vector())
      Matrix::MultiplyVector(*AxF, *rbf\A, vector())
      For i=0 To ni-1
        InterpolateAtIndex(*rbf, i, *xd, *xi, column, nd, m, *AxF, fi())
      Next
      
      Matrix::SetColumn(*result, column, fi())
    Next
    Matrix::Delete(*AxF)
    
  EndProcedure
  
  Procedure InterpolatedWeightsAtIndex(*rbf.RBF_t, i.i, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, column.i, nd.i, m.i, *AxF.Matrix::Matrix_t, Array w.f(1))
    Define j, k
    Define sum.f = 0
    For j=0 To nd-1
      w(j) = 0.0
      For k = 0 To m-1
        w(j) + Pow(Matrix::Get(*xi, i, k) - Matrix::Get(*xd, j, k), 2)
      Next
      
      If w(j) <> 0
        w(j) = 1.0 / w(j)
      EndIf
      
;       If Abs(w(j)) < 0.00000001
;         w(j) = Math::#F32_MAX
;       Else
;         w(j) = 1.0/w(j)
;       EndIf
      
      sum + w(j)
    Next
    For j=0 To nd-1 : w(j) / sum : Next
  EndProcedure
  
  ; Inputs
  ;   xd[posesCount * dimentions], the Data points:
  ;   pnt 0: [x, y, ....]
  ;   pnt 1: [x, y, ....]
  ;   pnt 2: [x, y, ....]
  ;
  ;   xi[pntCount * dimentions], the interpolation points:
  ;
  ; Output:
  ;   an Array of interpolated values per xi points.
  Procedure GetWeights(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
    Matrix::Resize(*result, *xd\rows, *rbf\F\columns)
    Define nd = *xd\rows
    Define m = *xd\columns
    Define ni = *xi\rows
    Define column, i
    Define *AxF.Matrix::Matrix_t = Matrix::New(0,0)
    For column = 0 To *rbf\F\columns - 1
      Dim fi.f(nd)
      Dim vector.f(0)
      Matrix::GetColumn(*rbf\F, column, vector())
      Matrix::MultiplyVector(*AxF, *rbf\A, vector())
      For i=0 To ni-1
        InterpolatedWeightsAtIndex(*rbf, i, *xd, *xi, column, nd, m, *AxF, fi())
      Next
      Matrix::SetColumn(*result, column, fi())
    Next
    
  EndProcedure
  
  ; update
  Procedure Update(*rbf.RBF_t, *f.Matrix::Matrix_t)
    *rbf\F = *f
  EndProcedure
  
EndModule


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

Global *rbf.RBF::RBF_t
Global Dim *points.Point_t(nbp)
Global *keys.Matrix::Matrix_t 
Global *values.Matrix::Matrix_t 
Global *query.Matrix::Matrix_t
Global *result.Matrix::Matrix_t
Global P.Point_t
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
  Matrix::Echo(*result, "RESULT")
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
  StopVectorDrawing()
EndProcedure


Procedure TestRBF()
  window = OpenWindow(#PB_Any, 0,0,width,height,"RBF")
  canvas = CanvasGadget(#PB_Any, 0,0,width,height)
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
  
  ;Matrix::Transpose(*keys)

  ; values
  *values.Matrix::Matrix_t = Matrix::New(nbp, 3)
  For k = 0 To nbp-1
    *values\matrix(k*3) = *points(k)\color\r
    *values\matrix(k*3+1) = *points(k)\color\g
    *values\matrix(k*3+2) = *points(k)\color\b
  Next
  ;Matrix::Transpose(*values)

  ; init the linear system
  *rbf.RBF::RBF_t = RBF::New()
  *rbf\kernel = RBF::#KERNEL_LINEAR
  RBF::Init(*rbf, *keys, *values)
  
  *query.Matrix::Matrix_t = Matrix::New(1,2)
  *result.Matrix::Matrix_t = Matrix::New(1,3)

  ; get the interpolated value
  RBF::Interpolate(*rbf, *keys, *query, *result) 
  Matrix::Echo(*result, "RESULT")

  
  Define e
  Repeat
    e = WaitWindowEvent() 
    If e = #PB_Event_Gadget And EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_MouseMove
          MouseMove()
          Update()
          Draw()
      EndSelect
      
    EndIf

  Until e= #PB_Event_CloseWindow
  

EndProcedure


TestRBF()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 416
; FirstLine = 387
; Folding = -----
; EnableXP