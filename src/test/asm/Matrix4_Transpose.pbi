XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"
UseModule Math

Macro MTranspose(_m,_o)
  _m\v[0] = _o\v[0]
  _m\v[4] = _o\v[1]
  _m\v[8] = _o\v[2]
  _m\v[12] = _o\v[3]
  
  _m\v[1] = _o\v[4]
  _m\v[5] = _o\v[5]
  _m\v[9] = _o\v[6]
  _m\v[13] = _o\v[7]
  
  _m\v[2] = _o\v[8]
  _m\v[6] = _o\v[9]
  _m\v[10] = _o\v[10]
  _m\v[14] = _o\v[11]
  
  _m\v[3] = _o\v[12]
  _m\v[7] = _o\v[13]
  _m\v[11] = _o\v[14]
  _m\v[15] = _o\v[15]
EndMacro

Macro MTransposeInPlace(_m)
  Define _m4_tmp.m4f32
  Matrix4::Transpose(_m4_tmp,_m)
  CopyMemory(@_m4_tmp\v[0], @_m\v[0], Matrix4::#M4F32_SIZE)
EndMacro


Procedure Compare(*A1, *A2, nb)
  Protected *m1.m4f32, *m2.m4f32
  For i=0 To nb-1
    *m1 = *A1 + i * SizeOf(m4f32)
    *m2 = *A2 + i * SizeOf(m4f32)
    For j=0 To 15
      If Abs(*m1\v[j] - *m2\v[j]) > 0.001
        ProcedureReturn #False
      EndIf
    Next
  Next
  
  ProcedureReturn #True
EndProcedure


; ---------------------------------------------------------------
;  VECTOR3 MUL BY MATRIX4
; ---------------------------------------------------------------
Procedure TransposeInPlace(*m.m4f32)
  ! mov rax, [p.p_m]
  
  ! movups xmm1, [rax]                  ; move m4 row 0 to xmm4
  ! movups xmm2, [rax+16]               ; move m4 row 1 to xmm5
  ! movups xmm3, [rax+32]               ; move m4 row 2 to xmm6
  ! movups xmm4, [rax+48]               ; move m4 row 3 to xmm7
  
  ! movaps      xmm0,   xmm3         ; xmm0:   c4 c3 c2 c1
  ! punpckldq   xmm3,    xmm4        ; xmm3:   d2 c2 d1 c1
  ! punpckhdq   xmm0,    xmm4        ; xmm0:   d4 c4 d3 c3

  ! movaps      xmm4,    xmm1        ; xmm4:  a4 a3 a2 a1
  ! punpckldq   xmm1,    xmm2        ; xmm1:   b2 a2 b1 a1
  ! punpckhdq   xmm4,    xmm2        ; xmm4:   b4 a4 b3 a3

  ! movaps      xmm2,    xmm1        ; xmm2:   b2 a2 b1 a1
  ! punpcklqdq  xmm1,    xmm3        ; xmm1:   d1 c1 b1 a1
  ! punpckhqdq  xmm2,    xmm3        ; xmm2:   d2 c2 b2 a2
  ! movaps      xmm3,    xmm4        ; xmm3:   b4 a4 b3 a3
  ! punpcklqdq  xmm3,    xmm0        ; xmm3:   d3 c3 b3 a3
  ! punpckhqdq  xmm4,    xmm0        ; xmm4:   d4 c4 b4 a4
  
  ! movups [rax], xmm1
  ! movups [rax+16], xmm2
  ! movups [rax+32], xmm3
  ! movups [rax+48], xmm4
EndProcedure

Procedure Transpose(*m.m4f32, *o.m4f32)
  ! mov rax, [p.p_o]
  ! mov rdx, [p.p_m]
   
  ! movups xmm1, [rax]                  ; move m4 row 0 to xmm4
  ! movups xmm2, [rax+16]               ; move m4 row 1 to xmm5
  ! movups xmm3, [rax+32]               ; move m4 row 2 to xmm6
  ! movups xmm4, [rax+48]               ; move m4 row 3 to xmm7
  
  ! movaps      xmm0,   xmm3         ; xmm0:   c4 c3 c2 c1
  ! punpckldq   xmm3,    xmm4        ; xmm3:   d2 c2 d1 c1
  ! punpckhdq   xmm0,    xmm4        ; xmm0:   d4 c4 d3 c3

  ! movaps      xmm4,    xmm1        ; xmm4:  a4 a3 a2 a1
  ! punpckldq   xmm1,    xmm2        ; xmm1:   b2 a2 b1 a1
  ! punpckhdq   xmm4,    xmm2        ; xmm4:   b4 a4 b3 a3

  ! movaps      xmm2,    xmm1        ; xmm2:   b2 a2 b1 a1
  ! punpcklqdq  xmm1,    xmm3        ; xmm1:   d1 c1 b1 a1
  ! punpckhqdq  xmm2,    xmm3        ; xmm2:   d2 c2 b2 a2
  ! movaps      xmm3,    xmm4        ; xmm3:   b4 a4 b3 a3
  ! punpcklqdq  xmm3,    xmm0        ; xmm3:   d3 c3 b3 a3
  ! punpckhqdq  xmm4,    xmm0        ; xmm4:   d4 c4 b4 a4
  
  ! movups [rdx], xmm1
  ! movups [rdx+16], xmm2
  ! movups [rdx+32], xmm3
  ! movups [rdx+48], xmm4
EndProcedure

Define nb = 12800000
Define m.m4f32, *o.m4f32
Define p.v3f32
Matrix4::SetIdentity(m)
Vector3::Set(p, 3.3,7.25,1.007)
Matrix4::SetTranslation(m, p)

Define *M1 = AllocateMemory(nb * SizeOf(m4f32))
Define i
For i=0 To nb-1 : *o = *M1 + i * SizeOf(m4f32) : Matrix4::SetFromOther(*o, m) : Next

Define T.q = ElapsedMilliseconds()
For i=0 To nb-1
  *o = *M1 + i * SizeOf(m4f32) 
  MTransposeInPlace(*o)
Next
Define T1.q = ElapsedMilliseconds() - T


Define *M2 = AllocateMemory(nb * SizeOf(m4f32))
For i=0 To nb-1 : *o = *M2 + i * SizeOf(m4f32) : Matrix4::SetFromOther(*o, m) : Next

Define T.q = ElapsedMilliseconds()
For i=0 To nb-1
  *o = *M2 + i * SizeOf(m4f32) 
  TransposeInPlace(*o)
Next
Define T2.q = ElapsedMilliseconds() - T

MessageRequester("Transpose", Str(T1)+" ---> "+Str(T2)+" EQUALS : "+Str(Compare(*M1, *M2, nb)))



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 135
; FirstLine = 84
; Folding = -
; EnableXP