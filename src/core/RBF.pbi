; ======================================================================================
; RADIAL BASIS FUNCTION (RBF) MODULE DECLARATION
; ======================================================================================
XIncludeFile "Matrix.pbi"

DeclareModule RBF
  
  Enumeration
    #KERNEL_LINEAR
    #KERNEL_GAUSSIAN
    #KERNEL_CUBIC
    #KERNEL_QUINTIC
    #KERNEL_INVERSE
    #KERNEL_MULTIQUADRIC
    #KERNEL_THINPLATE
  EndEnumeration
  
    ; Prototype
  Prototype.f PFNRBFKERNEL(r.f, eps.f)
  
  Structure RBF_t
    initialized.b
    epsilon.f
    type.i
    kernel.PFNRBFKERNEL
    *A.Matrix::Matrix_t           ; column vector
    *K.Matrix::Matrix_t           ; keys
    *V.Matrix::Matrix_t           ; values
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
    ((Pow(_r, 2) * Log(_r)) * Bool(_r>0))
  EndMacro  
  
  Declare New()
  Declare Delete(*rbf.RBF_t)
  
  Declare.f LinearKernel(r.f, eps.f)
  Declare.f GaussianKernel(r.f, eps.f)
  Declare.f CubicKernel(r.f, eps.f)
  Declare.f QuinticKernel(r.f, eps.f)
  Declare.f MultiQuadricKernel(r.f, eps.f)
  Declare.f InverseKernel(r.f, eps.f)
  Declare.f ThinPlateKernel(r.f, eps.f)
  
  Declare SetKernelType(*rbf.RBF_t, type.i)
  Declare ComputeEpsilon(*rbf.RBF_t, *m.Matrix::Matrix_t)
  Declare Init(*rbf.RBF_t, *xd.Matrix::Matrix_t, *f.Matrix::Matrix_t)
  Declare Interpolate(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
  Declare GetWeights(*rbf.RBF_t, *xd.Matrix::Matrix_t, *xi.Matrix::Matrix_t, *result.Matrix::Matrix_t)
EndDeclareModule


; ======================================================================================
; Radial Basis Function (RBF) Implementation
; ======================================================================================
Module RBF
  ; constructor
  Procedure New()
    Protected *rbf.RBF_t = AllocateMemory(SizeOf(RBF_t))
    InitializeStructure(*rbf, RBF_t)
    *rbf\epsilon = -1
    *rbf\type = #KERNEL_MULTIQUADRIC
    *rbf\kernel = @MultiQuadricKernel()
    *rbf\initialized = #False
    ProcedureReturn *rbf
  EndProcedure
  
  ; destructor
  Procedure Delete(*rbf.RBF_t)
    If *rbf
      If *rbf\A : Matrix::Delete(*rbf\A) : EndIf
      ClearStructure(*rbf, RBF_t)
      FreeMemory(*rbf)
    EndIf
  EndProcedure
  
  ; change kernel type
  Procedure SetKernelType(*rbf.RBF_t, type.i)
    *rbf\type = type
    Select *rbf\type
      Case #KERNEL_LINEAR
        *rbf\kernel = @LinearKernel()
      Case #KERNEL_GAUSSIAN
        *rbf\kernel = @GaussianKernel()
      Case #KERNEL_CUBIC
        *rbf\kernel = @CubicKernel()
      Case #KERNEL_QUINTIC
        *rbf\kernel = @QuinticKernel()
      Case #KERNEL_MULTIQUADRIC
        *rbf\kernel = @MultiQuadricKernel()
      Case #KERNEL_INVERSE
        *rbf\kernel = @InverseKernel()
      Case #KERNEL_THINPLATE
        *rbf\kernel = @ThinPlateKernel()
    EndSelect
    
    ; recompute weights
    If *rbf\K And *rbf\V : Init(*rbf, *rbf\K, *rbf\V) : EndIf

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
  Procedure.f LinearKernel(r.f, eps.f)
    Debug "KERNELE LINEAR"
    ProcedureReturn LINEAR(r)
  EndProcedure
  
  Procedure.f GaussianKernel(r.f, eps.f)
    Debug "KERNELE GAUSSIAN"
    ProcedureReturn GAUSSIAN(r, f)
  EndProcedure
  
  Procedure.f CubicKernel(r.f, eps.f)
    ProcedureReturn CUBIC(r)
  EndProcedure
  
  Procedure.f QuinticKernel(r.f, eps.f)
    ProcedureReturn QUINTIC(r)
  EndProcedure
  
  Procedure.f MultiQuadricKernel(r.f, eps.f)
    ProcedureReturn MULTIQUADRIC(r, eps)
  EndProcedure
  
  Procedure.f InverseKernel(r.f, eps.f)
    ProcedureReturn INVERSE(r, eps)
  EndProcedure
  
  Procedure.f ThinPlateKernel(r.f, eps.f)
    ProcedureReturn THINPLATE(r)
  EndProcedure
  
  ; init
  Procedure Init(*rbf.RBF_t, *keys.Matrix::Matrix_t, *values.Matrix::Matrix_t)
    If *rbf\epsilon = -1 : ComputeEpsilon(*rbf, *keys) : EndIf
    
    ; store the distances
    *rbf\K = *keys
    *rbf\V = *values
    
    Define nbp = *keys\rows
    Define d =  *keys\columns
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
          r + Pow(Matrix::Get(*keys, i, k) - Matrix::Get(*keys, j, k), 2)
        Next
        r = Sqr(r)
        Matrix::Set(*rbf\A, i, j, *rbf\kernel(r, *rbf\epsilon))
      Next
    Next
    
    ; solve the weights
    Matrix::InverseInPlace(*rbf\A)
    *rbf\initialized = #True
    
  EndProcedure
  
  ; interpolate
  Procedure Interpolate(*rbf.RBF_t, *keys.Matrix::Matrix_t, *query.Matrix::Matrix_t, *result.Matrix::Matrix_t)
    Matrix::Resize(*result, *query\rows, *rbf\V\columns)
    Define nd = *keys\rows
    Define m = *keys\columns
    Define ni = *query\rows
    Define column, i, j, k
    Define r.f
    Dim v.f(nd)
    Define *AxV.Matrix::Matrix_t = Matrix::New(0,0)
    For column=0 To *rbf\V\columns-1
      Dim results.f(ni)
      Dim vector.f(0)
      Matrix::GetColumn(*rbf\V, column, vector())
      Matrix::MultiplyVector(*AxV, *rbf\A, vector())
      For i=0 To ni-1
        For j=0 To nd-1
          r = 0.0
          For k=0 To m-1
            r + Pow(Matrix::Get(*query, i, k) - Matrix::Get(*keys, j, k), 2)
          Next
          r = Sqr(r)
          v(j) = *rbf\kernel(r, *rbf\epsilon)
        Next
        results(i) = 0.0
        For j=0 To nd-1 : results(i) + v(j) * *AxV\matrix(j) : Next
      Next
      
      Matrix::SetColumn(*result, column, results())
    Next
    Matrix::Delete(*AxV)
    
  EndProcedure
 
  
  ; get weights
  Procedure GetWeights(*rbf.RBF_t, *keys.Matrix::Matrix_t, *query.Matrix::Matrix_t, *result.Matrix::Matrix_t)
    Matrix::Resize(*result, *keys\rows, *rbf\V\columns)
    Define nd = *keys\rows
    Define m = *keys\columns
    Define ni = *query\rows
    Define column, i, j, k

    Define *AxV.Matrix::Matrix_t = Matrix::New(0,0)
    For column = 0 To *rbf\V\columns - 1
      Dim weights.f(nd)
      Dim vector.f(0)
      Matrix::GetColumn(*rbf\V, column, vector())
      Matrix::MultiplyVector(*AxF, *rbf\A, vector())
      For i=0 To ni-1
        For j=0 To nd-1
          weights(j) = 0.0
          For k = 0 To m-1
            weights(j) + Pow(Matrix::Get(*query, i, k) - Matrix::Get(*keys, j, k), 2)
          Next
          
          If Abs(weights(j)) < 0.00000001
            weights(j) = Math::#F32_MAX
          Else
            weights(j) = 1.0/weights(j)
          EndIf
          
          sum + weights(j)
        Next
        For j=0 To nd-1 : weights(j) / sum : Next
      Next
      Matrix::SetColumn(*result, column, weights())
    Next
    Matrix::Delete(*AxV)
  EndProcedure
  
EndModule


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 238
; FirstLine = 171
; Folding = ----
; EnableXP