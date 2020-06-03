XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Math.pbi"


Structure q4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure PBConjugate(*out.q4f32, *q.q4f32)
  *out\x = -*q\x
  *out\y = -*q\y
  *out\z = -*q\z
  *out\w = *q\w
EndProcedure

Procedure PBConjugateInPlace(*q.q4f32)
  *q\x = -*q\x
  *q\y = -*q\y
  *q\z = -*q\z
EndProcedure

Macro MConjugate()
  *q2\x = -q1\x
  *q2\y = -q1\y
  *q2\z = -q1\z
  *q2\w = q1\w
EndMacro

Macro MConjugateInPlace(_q)
  _q\x = -_q\x
  _q\y = -_q\y
  _q\z = -_q\z
EndMacro
    
Procedure Conjugate(*out.q4f32,*q.q4f32)
  ! mov rsi, [p.p_q]
  ! movups xmm0, [rsi]
  ! movups xmm1, [math.l_sse_1110_negate_mask]
  ! mulps xmm0, xmm1
  ! mov rdi, [p.p_out]
  ! movups [rdi], xmm0
EndProcedure

;------------------------------------------------------------------
; QUATERNION CONJUGATE IN PLACE
;------------------------------------------------------------------
Procedure ConjugateInPlace(*q.q4f32)
  ! mov rdi, [p.p_q]
  ! movups xmm0, [rsi]
  ! movups xmm1, [math.l_sse_1110_negate_mask]
  ! mulps xmm0, xmm1
  ! movups [rdi], xmm0
EndProcedure


Time::Init()
Define numTests = 100000000

Define i
Define q1.q4f32, *q2.q4f32
q1\x = -1.2566896
q1\y = -0.25444855
q1\z = 1.33
q1\w = 0.25

Define mem1 = AllocateMemory(numTests * SizeOf(Math::q4f32))
Define mem2 = AllocateMemory(numTests * SizeOf(Math::q4f32))


Define T1.d = Time::Get()
For i=0 To numTests-1
  *q2 = mem1 + i * SizeOf(Math::q4f32)
  PBConjugate(*q2, q1)
Next

Define E1.d = Time::Get() - T1


Define T2.d = Time::Get()
For i=0 To numTests-1
  *q2 = mem2 + i * SizeOf(Math::q4f32)
  Conjugate(*q2, q1)
Next

Define E2.d = Time::Get() - T2

MessageRequester("CONJUGATE", StrD(E1)+" vs "+StrD(E2)+" = "+Str(CompareMemory(mem1, mem2, numTests * SizeOf(Math::q4f32))))
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 52
; FirstLine = 24
; Folding = --
; EnableXP