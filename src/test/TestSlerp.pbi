Structure q4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_1111_value:
  Data.f 1.0,1.0,1.0,1.0
EndDataSection


Procedure SlerpSSE( *out.q4f32, *q1.q4f32, *q2.q4f32, blend.f)
  Define tetha.f
  ! fld [p.v_blend]
  ! fldz
;   ! fcom
  ! mov rdi, [p.p_out]
  ! movss xmm0, [p.v_blend]
  ! xorps xmm1, xmm1
  ! comiss xmm0, xmm1
  ! jb output_quaternion1
  
  ! movss xmm1, [l_sse_1111_value]
  ! comiss xmm0, xmm1
  ! je output_quaternion2
  
  ; spherical interpolation
  ! mov rsi, [p.p_q1]
  ! movups xmm2, [rsi]                  ; load q1 in xmm2
  ! mov rsi, [p.p_q1]
  ! movups xmm3, [rsi]                  ; load q2 in xmm3
  ! movaps xmm4, xmm2                   ; copy q1 in xmm4
  ! movaps xmm5, xmm3                   ; copy q2 in xmm5
  
  ; dot product
  ! mulps xmm4, xmm5                    ; q1 * q2
  ! haddps xmm4, xmm4                   ; horizontal add first pass  
  ! haddps xmm4, xmm4                   ; horizontal add second pass
  
  ; compute tetha
  ! movss [p.v_tetha], xmm4             ; move result to memory
  ! fld dword [p.v_tetha]               ; load X into the fpu
  ! fmul st0, st0                       ; compute X**2
  ! fld st0                             ; duplicate it
  ! fld1                                ; compute 1-X**2
  ! fsubr st0, st2
  ! fdivr st0, st1                      ; compute(1-X**2)/X**2
  ! fsqrt                               ; compute sqrt((1-X**2)/X**2)
  ! fld1                                ; to compute full arc tangent
  ! fpatan                              ; compute atan of the above
  ! fst dword [p.v_tetha]
  Debug "TETHA : "+StrF(tetha)
  ProcedureReturn
  
;       ; arc cos
;       ! fld st(0)           ;Duplicate X on tos.
;       ! fmul                    ;Compute X**2.
;                 fld     st(0)           ;Duplicate X**2 on tos.
;                 fld1                    ;Compute 1-X**2.
;                 fsubr
;                 fdivr                   ;Compute (1-x**2)/X**2.
;                 fsqrt                   ;Compute sqrt((1-X**2)/X**2).
;                 fld1                    ;To compute full arctangent.
;                 fpatan                  ;Compute atan of the above.
;       
  ; output quaternion 1
  ! output_quaternion1:
  !   mov rsi, [p.p_q1]
  !   movups xmm2, [rsi]                ; load q1 in xmm2
  !   movups [rdi], xmm2                ; move back to memory
  Debug "OUTPUT QUATERNION 1"
  ProcedureReturn
  
  ; output quaternion 2
  ! output_quaternion2:
  !   mov rsi, [p.p_q2]
  !   movups xmm2, [rsi]                ; load q2 in xmm2
  !   movups [rdi], xmm2                ; move back to memory
  Debug "OUTPUT QUATERNION 2"
  ProcedureReturn
EndProcedure

Procedure SlerpPB( *out.q4f32, *q1.q4f32, *q2.q4f32, blend.f)
  If blend<0
    *out\x = *q1\x
    *out\y = *q1\y
    *out\z = *q1\z
    *out\w = *q1\w
  ElseIf blend>=1
    *out\x = *q2\x
    *out\y = *q2\y
    *out\z = *q2\z
    *out\w = *q2\w
  Else
    Define dotproduct.f = *q1\x * *q2\x + *q1\y * *q2\y + *q1\z * *q2\z + *q1\w * *q2\w
    Define.f theta, st,sut, sout, coeff1, coeff2
    
    blend * 0.5
    
    theta = ACos(dotproduct)
    If theta<0 : theta * -1 :EndIf
    
    st = Sin(theta)
    sut = Sin(blend*theta)
    sout = Sin((1-blend)*theta)
    coeff1 = sout/st
    coeff2 = sut/st
    
    *out\x = coeff1 * *q1\x + coeff2 * *q2\x
    *out\y = coeff1 * *q1\y + coeff2 * *q2\y
    *out\z = coeff1 * *q1\z + coeff2 * *q2\z
    *out\w = coeff1 * *q1\w + coeff2 * *q2\w
  EndIf
EndProcedure


Define a.q4f32
Define b.q4f32
Define c.q4f32
a\x = 0.25
a\y = 0.5
a\z = 0.25
a\w = 0.333

b\x = 0.2
b\y= -0.5
b\z = -0.25
b\w = 0.1

SlerpPB(c, a,b, 0.5)
Debug StrF(c\x)+","+StrF(c\y)+","+StrF(c\z)+","+StrF(c\w)

SlerpSSE(c, a,b,0.5)
Debug StrF(c\x)+","+StrF(c\y)+","+StrF(c\z)+","+StrF(c\w)

; Define numTests = 100000000
; 
; Define i
; Define q1.q4f32, *q2.q4f32
; q1\x = -1.2566896
; q1\y = -0.25444855
; q1\z = 1.33
; q1\w = 0.25
; 
; Define mem1 = AllocateMemory(numTests * SizeOf(q4f32))
; Define mem2 = AllocateMemory(numTests * SizeOf(q4f32))
; 
; 
; Define T1.q = ElapsedMilliseconds()
; For i=0 To numTests-1
;   *q2 = mem1 + i * SizeOf(q4f32)
;   MConjugate(*q2, q1)
; Next
; 
; Define E1.q = ElapsedMilliseconds() - T1
; 
; 
; Define T2.q = ElapsedMilliseconds()
; For i=0 To numTests-1
;   *q2 = mem2 + i * SizeOf(q4f32)
;   Conjugate(*q2, q1)
; Next
; 
; Define E2.q = ElapsedMilliseconds() - T2
; 
; MessageRequester("CONJUGATE", StrD(E1)+" vs "+StrD(E2)+" = "+Str(CompareMemory(mem1, mem2, numTests * SizeOf(Math::q4f32))))

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; FirstLine = 3
; Folding = -
; EnableXP