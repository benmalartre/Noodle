XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Math.pbi"


Structure q4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Macro MConjugate(_out,_q)
  _out\x = -_q\x
  _out\y = -_q\y
  _out\z = -_q\z
  _out\w = _q\w
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
  MConjugate(*q2, q1)
Next

Define E1.d = Time::Get() - T1


Define T2.d = Time::Get()
For i=0 To numTests-1
  *q2 = mem2 + i * SizeOf(Math::q4f32)
  Conjugate(*q2, q1)
Next

Define E2.d = Time::Get() - T2

MessageRequester("CONJUGATE", StrD(E1)+" vs "+StrD(E2)+" = "+Str(CompareMemory(mem1, mem2, numTests * SizeOf(Math::q4f32))))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 46
; FirstLine = 16
; Folding = -
; EnableXP