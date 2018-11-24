XIncludeFile "../../core/Time.pbi"

Structure v4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Time::Init()

Procedure.f SquareDistancePB(*a.v4f32, *b.v4f32)
  ProcedureReturn (Pow(*a\x - *b\x, 2) + Pow(*a\y - *b\y, 2) + Pow(*a\z - *b\z, 2))
EndProcedure


Procedure.f SquareDistanceSSE(*a.v4f32, *b.v4f32)
  Define output.f
  ! mov rsi, [p.p_a]
  ! movups xmm0, [rsi]
  ! mov rsi, [p.p_b]
  ! movups xmm1, [rsi]
  
  ! subps xmm0, xmm1
  ! mulps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! movss [p.v_output], xmm0
  ProcedureReturn output
EndProcedure

Define a.v4f32
Define b.v4f32

a\x = -1
b\x = 12.6

Define numTests = 10000000
Define i
Define mem1 = AllocateMemory(numTests * 4)
Define mem2 = AllocateMemory(numTests * 4)


Define T1.d = Time::Get()
For i=0 To numTests-1
  PokeF(mem1+i*4, SquareDistancePB(a, b))
Next
Define E1.d = Time::Get() - T1

Define T2.d = Time::Get()
For i=0 To numTests-1
  PokeF(mem2+i*4, SquareDistanceSSE(a, b))
Next
Define E2.d = Time::Get() - T2

MessageRequester("SquaredDistance", "PB : "+StrD(E1)+", SSE : "+StrD(E2)+", EQ = "+Str(CompareMemory(mem1, mem2, numTests * 4)))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 37
; Folding = -
; EnableXP