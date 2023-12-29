; ======================================================================================
; N*M MATRIX MODULE DECLARATION
; ======================================================================================
XIncludeFile "Math.pbi"

DeclareModule Matrix
  Enumeration
    #MATRIX_VALID = 0
    #MATRIX_INVALID
    #MATRIX_SIZE_ZERO
    #MATRIX_SIZE_MISMATCH
    #MATRIX_INDEX_OUTOFBOUND
    #MATRIX_NON_SQUARE
    #MATRIX_IS_SINGULAR
  EndEnumeration
  
  Structure Matrix_t
    rows.i
    columns.i
    Array matrix.f(0)
    *lu.Matrix_t
    transposed.b
    singular.b
    even.b
  EndStructure
  
  Declare New(row.i, column.i)
  Declare Delete(*m.Matrix_t)
  Declare Resize(*m.Matrix_t, row.i, colum.i)
  Declare Copy(*o.Matrix_t)
  Declare Transpose(*m.Matrix_t)
  Declare GetIndex(*m.Matrix_t, row.i, colum.i)
  Declare GetColumnFromIndex(*m.Matrix_t, idx.i)
  Declare GetRowFromIndex(*m.Matrix_t, idx.i)
  Declare Set(*m.Matrix_t, row.i, colum.i, value.f)
  Declare SetRow(*m.Matrix_t, y, Array row.f(1))
  Declare SetColumn(*m.Matrix_t, x, Array column.f(1))
  Declare.f Get(*m.Matrix_t, row.i, colum.i)
  Declare GetRow(*m.Matrix_t, row.i, Array values.f(1))
  Declare GetColumn(*m.Matrix_t, column.i, Array values.f(1))
  Declare.f GetRowMinimum(*m.Matrix_t, row.i)
  Declare GetRowsMinimum(*m.Matrix_t, Array minimums.f(1))
  Declare.f GetRowMaximum(*m.Matrix_t, row.i)
  Declare GetRowsMaximum(*m.Matrix_t, Array maximums.f(1))
  Declare.f GetColumnMinimum(*m.Matrix_t, column.i)
  Declare GetColumnsMinimum(*m.Matrix_t, Array minimums.f(1))
  Declare.f GetColumnMaximum(*m.Matrix_t, column.i)
  Declare GetColumnsMaximum(*m.Matrix_t, Array maximums.f(1))
  Declare Add(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
  Declare AddInPlace(*m.Matrix_t, *o.Matrix_t)
  Declare Subtract(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
  Declare SubtractInPlace(*m.Matrix_t, *o.Matrix_t)
  Declare Multiply(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
  Declare MultiplyInPlace(*m.Matrix_t, *o.Matrix_t)
  Declare MultiplyVector(*m.Matrix_t, *o.Matrix_t, Array vector.f(1))
  Declare SwapRows(*m.Matrix_t, a.i, b.i)
  Declare SwapColumns(*m.Matrix_t, a.i, b.i)
  Declare.b LUDecomposition(*m.Matrix_t, Array pivot.i(1)) 
  Declare SolveLU(*m.Matrix_t, Array pivot.i(1), Array b.f(1), Array x.f(1)) 
  Declare Inverse(*m.Matrix_t, *o.Matrix_t)
  Declare InverseInPlace(*m.Matrix_t)
  Declare Echo(*m.Matrix_t, suffix.s="")
  Declare EchoRow(*m.Matrix_t, row.i, suffix.s="")
  Declare EchoColumn(*m.Matrix_t, column.i, suffix.s="")
EndDeclareModule

  ; ======================================================================================
  ; N*M MATRIX MODULE IMPLEMENTATION
  ; ======================================================================================
  Module Matrix
    ; ------------------------------------------------------------------------------------
    ; Constructor
    ; ------------------------------------------------------------------------------------
    Procedure New(row.i, column.i)   
      Protected *m.Matrix_t = AllocateMemory(SizeOf(Matrix_t))
      InitializeStructure(*m, Matrix_t)
      *m\rows = row
      *m\columns = column
      ReDim *m\matrix(row * column)
      ProcedureReturn *m  
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Destructor
    ; ------------------------------------------------------------------------------------
    Procedure Delete(*m.Matrix_t)
      If *m
        ClearStructure(*m, Matrix_t)
        FreeMemory(*m)
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Resize
    ; ------------------------------------------------------------------------------------
    Procedure Resize(*m.Matrix_t, row.i, column.i)
      *m\rows = row
      *m\columns = column
      ReDim *m\matrix(row * column)
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Copy Constructor ( allocating memory )
    ; ------------------------------------------------------------------------------------
    Procedure Copy(*o.Matrix_t)
      Protected *m.Matrix_t = New(*o\rows, *o\columns)
      *m\transposed = *o\transposed
      CopyMemory(@*o\matrix(0), @*m\matrix(0), *m\rows * *m\columns * 4)
      ProcedureReturn *m
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Transpose
    ; ------------------------------------------------------------------------------------
    Procedure Transpose(*m.Matrix_t)
      *m\transposed = 1 - *m\transposed
      Protected tmp = *m\rows
      *m\rows = *m\columns
      *m\columns = tmp
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Index
    ; ------------------------------------------------------------------------------------
    Procedure GetIndex(*m.Matrix_t, row.i, column.i)
      If row < *m\rows And column < *m\columns
        If *m\transposed
          ProcedureReturn *m\rows * column + row
        Else
          ProcedureReturn *m\columns * row + column
        EndIf
      Else
        ProcedureReturn -1
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Colum From Index
    ; ------------------------------------------------------------------------------------
    Procedure GetColumnFromIndex(*m.Matrix_t, idx.i)
      If index < ArraySize(*m\matrix())
        ProcedureReturn Int(Mod(index, *m\columns))
      Else
        ProcedureReturn -1
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Row From Index
    ; ------------------------------------------------------------------------------------
    Procedure GetRowFromIndex(*m.Matrix_t, idx.i)
      If index < ArraySize(*m\matrix())
        ProcedureReturn (idx + 1 - GetColumnFromIndex(*m, idx)) / *m\columns
      Else
        ProcedureReturn -1
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Set 
    ; ------------------------------------------------------------------------------------
    Procedure Set(*m.Matrix_t, row.i, column.i, value.f)
      *m\matrix(GetIndex(*m, row, column)) = value
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Set Row
    ; ------------------------------------------------------------------------------------
    Procedure SetRow(*m.Matrix_t, y, Array row.f(1))
      If y < *m\rows And ArraySize(row()) = *m\columns
        Define i
        For i=0 To *m\columns-1
          *m\matrix(GetIndex(*m, y, i)) = row(i)
        Next
      Else
        ProcedureReturn #MATRIX_SIZE_MISMATCH 
      EndIf
    EndProcedure
  
    ; ------------------------------------------------------------------------------------
    ; Set Column
    ; ------------------------------------------------------------------------------------
    Procedure SetColumn(*m.Matrix_t, x, Array column.f(1))
      If x < *m\columns And ArraySize(column()) = *m\rows
        Define i
        For i=0 To *m\rows-1
          *m\matrix(GetIndex(*m, i, x)) = column(i)
        Next
      Else
        ProcedureReturn #MATRIX_SIZE_MISMATCH 
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get 
    ; ------------------------------------------------------------------------------------
    Procedure.f Get(*m.Matrix_t, row.i, column.i)
      ProcedureReturn *m\matrix(GetIndex(*m, row, column))
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Row
    ; ------------------------------------------------------------------------------------
    Procedure GetRow(*m.Matrix_t, row.i, Array values.f(1))
      If row < *m\rows
        ReDim values(*m\columns)
        Define i
        For i=0 To *m\columns-1
          values(i) = Get(*m, row, i)
        Next
        ProcedureReturn #MATRIX_VALID
      Else
        ProcedureReturn #MATRIX_INDEX_OUTOFBOUND
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Column
    ; ------------------------------------------------------------------------------------
    Procedure GetColumn(*m.Matrix_t, column.i, Array values.f(1))
      If column < *m\columns
        ReDim values(*m\rows)
        Define i
        For i=0 To *m\rows-1 : values(i) = Get(*m, i, column) : Next
        ProcedureReturn #MATRIX_VALID
      Else
        ProcedureReturn #MATRIX_INDEX_OUTOFBOUND
      EndIf
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Row Minimum
    ; ------------------------------------------------------------------------------------
    Procedure.f GetRowMinimum(*m.Matrix_t, row.i)
      Define minValue.f = Math::#F32_MAX, value.f
      Define i
      For i=0 To *m\columns-1
        value = Get(*m, row, i)
        If value < minValue:
          minValue = value
        EndIf
      Next
      ProcedureReturn minValue
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Rows Minimum
    ; ------------------------------------------------------------------------------------
    Procedure GetRowsMinimum(*m.Matrix_t, Array minimums.f(1))
      ReDim minimums(*m\rows)
      Define i
      For i=0 To *m\rows-1
        minimums(i) = GetRowMinimum(*m, i)
      Next
      ProcedureReturn #True
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Row Maximum
    ; ------------------------------------------------------------------------------------
    Procedure.f GetRowMaximum(*m.Matrix_t, row.i)
      Define maxValue.f = Math::#F32_MIN, value.f
      Define i
      For i=0 To *m\columns-1
        value = Get(*m, row, i)
        If value > maxValue:
          maxValue = value
        EndIf
      Next
      ProcedureReturn maxValue
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Rows Maximum
    ; ------------------------------------------------------------------------------------
    Procedure GetRowsMaximum(*m.Matrix_t, Array maximums.f(1))
      ReDim maximums(*m\rows)
      Define i
      For i=0 To *m\rows-1
        maximums(i) = GetRowMaximum(*m, i)
      Next
      ProcedureReturn #True
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Column Minimum
    ; ------------------------------------------------------------------------------------
    Procedure.f GetColumnMinimum(*m.Matrix_t, column.i)
      Define minValue.f = Math::#F32_MAX, value.f
      Define j
      For j=0 To *m\columns-1
        value = Get(*m, row, j)
        If value < minValue:
          minValue = value
        EndIf
      Next
      ProcedureReturn minValue
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Columns Minimum
    ; ------------------------------------------------------------------------------------
    Procedure GetColumnsMinimum(*m.Matrix_t, Array minimums.f(1))
      ReDim minimums(*m\columns)
      Define i
      For i=0 To *m\columns-1
        minimums(i) = GetColumnMinimum(*m, i)
      Next
      ProcedureReturn #True
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Column Maximum
    ; ------------------------------------------------------------------------------------
    Procedure.f GetColumnMaximum(*m.Matrix_t, column.i)
      Define maxValue.f = Math::#F32_MIN, value.f
      Define j
      For j=0 To *m\columns-1
        value = Get(*m, j, column)
        If value > maxValue:
          maxValue = value
        EndIf
      Next
      ProcedureReturn maxValue
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Columns Maximum
    ; ------------------------------------------------------------------------------------
    Procedure GetColumnsMaximum(*m.Matrix_t, Array maximums.f(1))
      ReDim maximums(*m\columns)
      Define i
      For i=0 To *m\columns-1
        maximums(i) = GetColumnMaximum(*m, i)
      Next
      ProcedureReturn #True
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Add
    ; ------------------------------------------------------------------------------------
    Procedure AddInPlace(*m.Matrix_t, *o.MAtrix_t)
      If Not ArraySize(*m\matrix()) = ArraySize(*o\matrix()) : ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
      Define i
      For i = 0 To ArraySize(*m\matrix())-1
        *m\matrix(i) + *o\matrix(i)
      Next
      
    EndProcedure
    
    Procedure Add(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
      If Not (*a\rows = *b\rows And *a\columns = *b\columns): ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
      Resize(*m, *a\rows, *a\columns)
      Define i
      For i = 0 To ArraySize(*m\matrix())-1
        *m\matrix(i) = *a\matrix(i)+ *b\matrix(i)
      Next
    EndProcedure
     
    ; ------------------------------------------------------------------------------------
    ; Subtract
    ; ------------------------------------------------------------------------------------
    Procedure SubtractInPlace(*m.Matrix_t, *o.MAtrix_t)
      If Not ArraySize(*m\matrix()) = ArraySize(*o\matrix()) : ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
      Define i
      For i = 0 To ArraySize(*m\matrix())-1
        *m\matrix(i) - *o\matrix(i)
      Next
      
    EndProcedure
    
     Procedure Subtract(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
       If Not (*a\rows = *b\rows And *a\columns = *b\columns): ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
       Resize(*m, *a\rows, *a\columns)
       Define i
       For i = 0 To ArraySize(*m\matrix())-1
        *m\matrix(i) = *a\matrix(i) - *b\matrix(i)
       Next
     EndProcedure
     
     
    ; ------------------------------------------------------------------------------------
    ; Multiply
    ; ------------------------------------------------------------------------------------
     Procedure Multiply(*m.Matrix_t, *a.Matrix_t, *b.Matrix_t)
       If *a\columns <> *b\rows : ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
       
       Define i, j, k
       ; first reset output matrix
       For i=0 To ArraySize(*m\matrix())-1 : *m\matrix(i) = 0 : Next
       
       For i=0 To *a\rows-1
         For k=0 To *b\columns-1
           For j=0 To *a\columns-1
             *m\matrix(GetIndex(*m, i, j)) + (Get(*a, i, k) * Get(*b, k, j))
           Next
         Next
       Next
     EndProcedure
     
     Procedure MultiplyInPlace(*m.Matrix_t, *o.Matrix_t)
       Define *tmp.Matrix_t = Copy(*m)
       Multiply(*m, *tmp, *o)
       Delete(*tmp)
     EndProcedure
     
    ; ------------------------------------------------------------------------------------
    ; Multiply Vector ( m = o * vector)
    ; ------------------------------------------------------------------------------------
     Procedure MultiplyVector(*m.Matrix_t, *o.Matrix_t, Array vector.f(1))
      If ArraySize(vector()) <> *o\columns : ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
      Resize(*m, *o\columns, 1)
      Define product.f
      Define i, j
      For i = 0 To *o\rows-1
        product = 0
        For j=0 To *o\columns-1
          product + Get(*o, i, j) * vector(j)
        Next
        Matrix::Set(*m, i, 0, product)
      Next
     EndProcedure
     
    ; ------------------------------------------------------------------------------------
    ; Scale
    ; ------------------------------------------------------------------------------------
     Procedure Scale(*m.Matrix_t, *o.Matrix_t, v.f)
       Resize(*m, *o\rows, *o\columns)
       Define i
       For i=0 To ArraySize(*o\matrix())-1
         *m\matrix(i) = *o\matrix(i) * v
       Next
     EndProcedure
     
     Procedure ScaleInPlace(*m.Matrix_t, v.f)
       Define i
       For i=0 To ArraySize(*m\matrix())-1
         *m\matrix(i) * v
       Next
     EndProcedure
     
    ; ------------------------------------------------------------------------------------
    ; Swaps
    ; ------------------------------------------------------------------------------------
    Procedure SwapRows(*m.Matrix_t, a.i, b.i)
      Define i
      For i=0 To *m\columns-1
        Swap *m\matrix(a * *m\columns + i), *m\matrix(b * *m\columns + i)
      Next
    EndProcedure
     
    Procedure SwapColumns(*m.Matrix_t, a.i, b.i)
      Define i
      For i=0 To *m\rows-1
        Swap *m\matrix(*m\columns * i + a), *m\matrix(*m\columns * i + b)
      Next
    EndProcedure
     
    ; ------------------------------------------------------------------------------------
    ; Inverse
    ; ------------------------------------------------------------------------------------
    Procedure Inverse(*m.Matrix_t, *o.Matrix_t)
      Dim piv(*o\columns)
      If Not LUDecomposition(*o, piv())
        Resize(*m, *o\columns, *o\columns)
        Define i
        For i=0 To *o\columns-1
          Dim b.f(*o\columns)
          Dim w.f(*o\columns)
          b(i) = 1.0
          SolveLU(*o, piv(), b(), w())
          SetColumn(*m, i, w())
        Next
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False  
    EndProcedure
    
    Procedure InverseInPlace(*m.Matrix_t)
      Dim piv(*m\columns)
      If Not LUDecomposition(*m, piv())
        Define i
        For i=0 To *m\columns-1
          Dim b.f(*m\columns)
          Dim w.f(*m\columns)
          b(i) = 1.0
          SolveLU(*m, piv(), b(), w())
          SetColumn(*m, i, w())
        Next
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False  
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Echo
    ; ------------------------------------------------------------------------------------
    Procedure Echo(*m.Matrix_t, suffix.s="")
      Define x, y, idx = 0
      Define sv.s
      For x=0 To *m\rows-1
        sv = ""
        For y =0 To *m\columns-1
          idx = Matrix::GetIndex(*m, x, y)
          sv + StrF(*m\matrix(idx), 3)+","
          idx+1
        Next
        Debug suffix+": "+ sv
      Next
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Echo Row
    ; ------------------------------------------------------------------------------------
    Procedure EchoRow(*m.Matrix_t, row.i, suffix.s="")
      Define x, idx = 0
      Define sv.s = ""
      sv = ""
      For x=0 To *m\columns-1
        idx = Matrix::GetIndex(*m, row, x)
        sv + StrF(*m\matrix(idx), 3)+","
        idx+1
      Next
      Debug suffix+": "+ sv
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Echo Column
    ; ------------------------------------------------------------------------------------
    Procedure EchoColumn(*m.Matrix_t, column.i, suffix.s="")
      Define y, idx = 0
      Define sv.s = ""
      sv = ""
      For y=0 To *m\rows-1
        idx = Matrix::GetIndex(*m, y, column)
        sv + StrF(*m\matrix(idx), 3)+","
        idx+1
      Next
      Debug suffix+": "+ sv
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; Get Determinant
    ; ------------------------------------------------------------------------------------
    Procedure.f GetDeterminant(*m.Matrix_t, Array pivot.i(1))
      If *m\singular Or Not *m\lu : ProcedureReturn 0 : EndIf
      
      Define m = ArraySize(pivot())
      Define i
      Define determinant.f
      If *m\even : determinant = 1 : Else : determinant = -1 : EndIf
      
      For i=0 To m-1
        determinant * Get(*m\lu, i, i)
      Next
      ProcedureReturn determinant
    EndProcedure
    
    ; ------------------------------------------------------------------------------------
    ; LU Decomposition
    ; ------------------------------------------------------------------------------------
    Procedure.b LUDecomposition(*m.Matrix_t, Array pivot.i(1))
      Define singularityThreshold.f = 0
      If *m\rows <> *m\columns : ProcedureReturn #MATRIX_NON_SQUARE : EndIf
  
      Define m = *m\columns
      If *m\lu : Delete(*m\lu) : EndIf
      *m\lu = Copy(*m)
  
      ; initialize permutation array And parity
      Define row, column, i
      For row = 0 To m-1 : pivot(row) = row : Next
      
      *m\even = #True
      *m\singular = #False
  
      ; loop over columns
      For column = 0 To m-1
        ; upper
        For row = 0 To column-1
          Dim luRow.f(0)
          GetRow(*m\lu, row, luRow())
          Define sum.f = luRow(column)
          For i = 0 To row-1
            sum - (luRow(i) * Get(*m\lu, i, column))
          Next
            
          Set(*m\lu, row, column, sum)
        Next
  
        ; lower
        Define max = column ;  permutation row
        Define largest = Math::#F32_MIN
        For row = column To m-1
          Dim luRow(0)
          GetRow(*m\lu, row, luRow())
          Define sum.f = luRow(column)
          For i = 0 To column-1
            sum - (luRow(i) * Get(*m\lu, i, column))
          Next
            
          Set(*m\lu, row, column, sum)
  
          ; maintain best permutation choice
          If Abs(sum) > largest
            largest = Abs(sum)
            max = row
          EndIf
        Next
  
        ; singularity check
        If Abs(Get(*m\lu, max, column)) < singularityThreshold
           ProcedureReturn #MATRIX_IS_SINGULAR
        EndIf
  
        ; pivot if necessary
        If max <> column
          SwapRows(*m\lu, max, column)
          Swap pivot(max), pivot(column)
          *m\even = 1 - *m\even
        EndIf
  
        ; divide the lower elements by the "winning" diagonal elt.
        Define luDiag.f = Get(*m\lu, column, column)
        For row = column + 1 To m-1
          *m\lu\matrix(row * m + column) = Get(*m\lu, row, column) / luDiag
        Next
      Next
      
    EndProcedure
    
    Procedure SolveLU(*m.Matrix_t, Array pivot.i(1), Array b.f(1), Array x.f(1)) 
      If Not *m\lu : ProcedureReturn #MATRIX_INVALID : EndIf
      Define m = ArraySize(pivot())
      If *m\lu\columns <> m : ProcedureReturn #MATRIX_SIZE_MISMATCH : EndIf
      If *m\lu\singular : ProcedureReturn #MATRIX_IS_SINGULAR : EndIf
      
      Define row, column, i
      ; apply permutations to b
      For row = 0 To m-1 : x(row) = b(pivot(row)): Next
      
      ; solve LY = b
      Define xColumn.f
      For column = 0 To m-1
        xColumn = x(column)
        For i = column+1 To m-1
          x(i) - (xColumn * Get(*m\lu, i, column))
        Next
      Next
      
      ; solve UX = Y
      For column = m-1 To 0 Step -1
        x(column) = x(column) / Get(*m\lu, column, column)
        xColumn = x(column)
        For i=0 To column - 1
          x(i) - xColumn * Get(*m\lu, i, column)
        Next
      Next
      
      ProcedureReturn #MATRIX_VALID
    EndProcedure
    
  EndModule


; ; ------------------------------------------------------------------------------------
; ; Test Code
; ; ------------------------------------------------------------------------------------
; 
; Procedure TestMultiply()
;   Define.Math::m4f32 m1, m2
;   Define.Math::v3f32 p1, p2
;   Vector3::Set(p1,1,2,3)
;   Vector3::Set(p2,4,5,6)
;   Matrix4::SetIdentity(m1)
;   Matrix4::SetTranslation(m1, p1)
;   Matrix4::SetIdentity(m2)
;   Matrix4::SetTranslation(m2, p2)
;   Matrix4::Echo(m1, "M1")
;   Matrix4::Echo(m2, "M2")
;   
;   Debug m1
;   Debug m2
;   
;   Matrix4::MultiplyInPlace(m1, m2)
;   
;   ; Matrix4::InverseInPlace(m4)
;   Matrix4::Echo(m1, "MULTIPLIED")
;   
;   Define *m1.Matrix::Matrix_t = Matrix::New(4,4)
;   Define *m2.Matrix::Matrix_t = Matrix::New(4,4)
;   
;   Matrix::Set(*m1, 0, 0, 1)
;   Matrix::Set(*m1, 1, 1, 1)
;   Matrix::Set(*m1, 2, 2, 1)
;   Matrix::Set(*m1, 3, 3, 1)
;   
;   Matrix::Set(*m1, 3, 0, 1)
;   Matrix::Set(*m1, 3, 1, 2)
;   Matrix::Set(*m1, 3, 2, 3)
;   
;   Matrix::Echo(*m1)
;   
;   Matrix::Set(*m2, 0, 0, 1)
;   Matrix::Set(*m2, 1, 1, 1)
;   Matrix::Set(*m2, 2, 2, 1)
;   Matrix::Set(*m2, 3, 3, 1)
;   
;   Matrix::Set(*m2, 3, 0, 4)
;   Matrix::Set(*m2, 3, 1, 5)
;   Matrix::Set(*m2, 3, 2, 6)
;   
;   Matrix::Echo(*m2)
;   
;   Matrix::MultiplyInPlace(*m1, *m2)
;   Matrix::Echo(*m1)
; EndProcedure
; 
; Procedure TestInverse()
;   Define m1.Math::m4f32
;   Matrix4::SetIdentity(m1)
;   Matrix4::Echo(m1, "Original")
;   Matrix4::InverseInPlace(m1)
;   Matrix4::Echo(m1, "Inverted")
;   
;   Define *m1.Matrix::Matrix_t = Matrix::New(4,4)
;   Matrix::Set(*m1, 0, 0, 1)
;   Matrix::Set(*m1, 1, 1, 1)
;   Matrix::Set(*m1, 2, 2, 1)
;   Matrix::Set(*m1, 3, 3, 1)
;   
;   Matrix::Set(*m1, 3, 0, 4)
;   Matrix::Set(*m1, 3, 1, 3)
;   Matrix::Set(*m1, 3, 2, 2)
;   Matrix::Echo(*m1)
;   Matrix::InverseInPlace(*m1)
;   Matrix::Echo(*m1)
; EndProcedure
; 
; Procedure TestRow()
;   Define *m.Matrix::Matrix_t = Matrix::New(4,4)
;   Define i, j
;   For i = 0 To *m\rows - 1
;     For j=0 To *m\columns - 1
;       Matrix::Set(*m, i, j, i)
;     Next
;   Next
;   Matrix::Echo(*m)
;   Debug "--------------------------------------"
;   Dim row.f(0)
;   Define s.s
;   For i=0 To *m\rows-1
;     Matrix::GetRow(*m, i, row())
;     s = ""
;     For j=0 To *m\columns-1
;       s+StrF(row(j))+","
;     Next
;     Debug s
;   Next
;   
; EndProcedure
; 
; Procedure TestColumn()
;   Define *m.Matrix::Matrix_t = Matrix::New(4,4)
;   Define i, j
;   For i = 0 To *m\rows - 1
;     For j=0 To *m\columns - 1
;       Matrix::Set(*m, i, j, i)
;     Next
;   Next
;   Matrix::Echo(*m)
;   Debug "--------------------------------------"
;   Dim column.f(0)
;   Define s.s
;   For i=0 To *m\columns-1
;     Matrix::GetColumn(*m, i, column())
;     s = ""
;     For j=0 To *m\rows-1
;       s+StrF(column(j))+","
;     Next
;     Debug s
;   Next
;   
; EndProcedure
; 
; ; TestRow()
; ; TestColumn()
; TestInverse()
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 767
; FirstLine = 743
; Folding = --------
; EnableXP