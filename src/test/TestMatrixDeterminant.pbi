Structure SqMatrix
  Array X.f(0)
  N.i
EndStructure

Procedure Init(*m.SqMatrix, N.i)
  InitializeStructure(*m, SqMatrix)
  *m\N = N
  ReDim *m\X(N*N)
  Define i, j
  For c=0 To (N*N)-1
    i = c/*m\N
    j = c%N
    If i = j 
      *m\X(c) = 1.0 
    Else
      *m\X(c) = 0.0
    EndIf   
  Next 
EndProcedure

;Procedure Determinant(*m.SqMatrix)
;   Define s.s
;   Define N2 = *m\N * *m\N
; ;   For i=0 To *m\N-1
; ;     For j=0 To *m\N-1
; ;       s+Chr(*m\X((i**m\N+j*(*m\N+1))%N2))
; ;     Next
; ;     If i < *m\N-1 : s + " + " : EndIf
; ;   Next
;   Define i, j
;   Define N2 = *m\N * *m\N
;   For n=0 To N2-1
;     i = n/*m\N
;     j = n%*m\N
;     s+Chr(*m\X((i**m\N+j*(*m\N+1))%N2))
;     If j = *m\N-1  And n < N2-1: s + " + " : EndIf
;   Next
;   
;   
;   s + " - "
;   
;   For i=0 To *m\N-1
;     For j=0 To *m\N-1
;       s+Chr(*m\X(((i+1)* *m\N-1 +j * (*m\N-1))%N2))
;     Next
;     If i < *m\N-1 : s + " - " : EndIf
;   Next
;   
;   Debug s
;EndProcedure

Procedure.f Determinant(*m.SqMatrix)
  Define det.f = 0.0
  Define N2 = *m\N * *m\N

  Define i, j
  Define m.f, n.f
  For x=0 To N2-1
    i = x/*m\N
    j = x%*m\N
    
    If j = 0
      m = *m\X((i**m\N+j*(*m\N+1))%N2)
      n = *m\X(((i+1)* *m\N-1 +j * (*m\N-1))%N2)
    Else 
      m * *m\X((i**m\N+j*(*m\N+1))%N2)
      n * *m\X(((i+1)* *m\N-1 +j * (*m\N-1))%N2)
    EndIf
    
    If j = *m\N-1 : det + m - n: EndIf
  Next
  
  ProcedureReturn det
EndProcedure

Define m.SqMatrix
Init(m,4)
Debug Determinant(m)
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 57
; FirstLine = 46
; Folding = -
; EnableXP