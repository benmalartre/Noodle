XIncludeFile "../../core/Time.pbi"

Time::Init()

Structure v4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Macro Echo(_v)
  Debug StrF(_v\x)+", "+StrF(_v\y)+", "+StrF(_v\z)+", "+StrF(_v\w)
EndMacro

Procedure HorizontalAdd(*v.v4f32, *o.v4f32)
  *v\x = *o\x + *o\y + *o\z + *o\w
EndProcedure

Procedure HorizontalAddArray(mem, *o.v4f32, nb)
  Define i
  For i=0 To nb-1
    PokeF(mem+i*SizeOf(v4f32), *o\x + *o\y + *o\z + *o\w)
  Next
EndProcedure


Procedure HorizontalAdd1(*v.v4f32, *o.v4f32)
  ! mov rsi, [p.p_o]
  ! mov rdi, [p.p_v]
  ! movups xmm0, [rsi]
  ! haddps xmm0, xmm0                 ; horizontal add first pass
  ! haddps xmm0, xmm0                 ; horizontal add second pass  
  ! movss [rdi], xmm0
EndProcedure

Procedure HorizontalAdd2(*v.v4f32, *o.v4f32)
  ! mov rsi, [p.p_o]
  ! mov rdi, [p.p_v]
  ! movups xmm0, [rsi]
  ! movaps xmm1, xmm0
  ! shufps xmm1, xmm1, 11101110b
  ! addps xmm1, xmm0
  ! movaps xmm2, xmm1
  ! shufps xmm2, xmm2, 01010101b
  ! addss  xmm1, xmm2
  ! movss [rdi], xmm1
EndProcedure

Procedure HorizontalAddArray1(*mem, *o.v4f32, nb)
  ! mov ecx, [p.v_nb]
  ! mov rsi, [p.p_o]
  ! mov rdi, [p.p_mem]
  ! loop_horizontal_add_array1:
  !   movups xmm0, [rsi]
  !   haddps xmm0, xmm0                 ; horizontal add first pass
  !   haddps xmm0, xmm0                 ; horizontal add second pass  
  !   movss [rdi], xmm0                 ; send back to memory
  !   add rdi, 16                       ; offset next point
  !   dec ecx                           ; decrement loop counter      
  !   jg loop_horizontal_add_array1
EndProcedure

Procedure HorizontalAddArray2(*mem, *o.v4f32, nb)
  ! mov ecx, [p.v_nb]
  ! mov rsi, [p.p_o]
  ! mov rdi, [p.p_mem]
  ! loop_horizontal_add_array2:
  !   movups xmm0, [rsi]
  !   movaps xmm1, xmm0
  !   shufps xmm1, xmm1, 11101110b
  !   addps xmm1, xmm0
  !   movaps xmm2, xmm1
  !   shufps xmm2, xmm2, 01010101b
  !   addss  xmm1, xmm2
  !   movss [rdi], xmm1
  !   add rdi, 16                       ; offset next point
  !   dec ecx                           ; decrement loop counter      
  !   jg loop_horizontal_add_array2
EndProcedure


Define numTests = 1000000
Define pntSize = SizeOf(v4f32)
Define memSize = numTests * pntSIze
Define mem0 = AllocateMemory(memSize)
Define memX = AllocateMemory(memSize)
Define mem1 = AllocateMemory(memSize)
Define mem2 = AllocateMemory(memSize)
Define mem3 = AllocateMemory(memSize)
Define mem4 = AllocateMemory(memSize)
Define o.v4f32
Define *v.v4f32

Define i

o\x = 3
o\y = 2
o\z = 1

Define S0.d = Time::Get()
For i=0 To numTests-1
  HorizontalAdd(mem0 + i * pntSize, o)
Next
Define E0.d = Time::Get() - S0

Define SX.d = Time::Get()
HorizontalAddArray(memX, o, numTests)
Define EX.d = Time::Get() - SX

Define S1.d = Time::Get()
For i=0 To numTests-1
  HorizontalAdd1(mem1 + i * pntSize, o)
Next
Define E1.d = Time::Get() - S1


Define S2.d = Time::Get()
For i=0 To numTests-1
  HorizontalAdd2(mem2 + i * pntSize, o)
Next
Define E2.d = Time::Get() - S2

Define S3.d = Time::Get()
HorizontalAddArray1(mem3, o, numTests)
Define E3.d = Time::Get() - S3


Define S4.d = Time::Get()
HorizontalAddArray2(mem4, o, numTests)
Define E4.d = Time::Get() - S4

Define cmp0.b = CompareMemory(mem0, memX, memSize)
Define cmp1.b = CompareMemory(mem1, mem2, memSize)
Define cmp2.b = CompareMemory(mem3, mem4, memSize)
Define cmp3.b = CompareMemory(mem0, mem1, memSize)
Define cmp4.b = CompareMemory(mem1, mem3, memSize)

MessageRequester("ASM HORIZONTAL ADD", "NORMAL              : "+StrD(E0)+Chr(10)+
                                       "NORMAL ARRAY        : "+StrD(EX)+Chr(10)+
                                       "HADDPS              : "+StrD(E1)+Chr(10)+
                                       "SHUFPS+ADDPS        : "+StrD(E2)+Chr(10)+
                                       "HADDPS ARRAY        : "+StrD(E3)+Chr(10)+
                                       "SHUFPS+ADDPS ARRAY  : "+StrD(E4)+Chr(10)+
                                       "RESULTS COMPARE     : "+Str(cmp0)+", "+Str(cmp1)+", "+Str(cmp2)+", "+Str(cmp3)+", "+Str(cmp4))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; Folding = --
; EnableXP