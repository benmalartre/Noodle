XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../core/Array.pbi"

UseModule Math

Procedure RandomPositionArray(nb)
  Define *positions.CArray::CArrayV3F32 = CARray::newCArrayV3F32()
  CArray::SetCount(*positions, nb)
  Define i
  Define *p.v3f32
  For i=0 To nb-1
    *p = CArray::GetValue(*positions, i)
    Vector3::RandomizeInPlace(*p, 12)
  Next
  ProcedureReturn *positions
EndProcedure


Procedure.b EqualsPB(*v.v3f32,*o.v3f32, eps.f=0.0000001)
  Define tmp.v3f32
  Vector3::Sub(tmp, *v, *o)
  If Vector3::Length(tmp) < eps : ProcedureReturn #True : EndIf
  ProcedureReturn #False
  
EndProcedure

Procedure.b EqualsPB2(*v.v3f32,*o.v3f32, eps.f=0.0000001)
  If Abs(*v\x - *o\x) > eps Or Abs(*v\y - *o\y) Or Abs(*v\z - *o\z)
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.b EqualsSSE(*v.v3f32,*o.v3f32, eps.f=0.0000001)
  ! mov rsi, [p.p_v]
  ! movups xmm0, [rsi]
  ! mov rsi, [p.p_o]
  ! movups xmm1, [rsi]
  ! subps xmm0, xmm1
  ! movss xmm2, [p.v_eps]
  ! shufps xmm2, xmm2, 00000000b
  ! movups xmm3, [math.l_sse_1111_sign_mask]
  ! andps xmm0, xmm3
  ! cmpps xmm0, xmm2, 1
  ! movmskps r12, xmm0
  ! cmp r12, 15
  ! je vector_are_equivalents
  ! jmp vector_are_differents
  
  ! vector_are_equivalents:
  ProcedureReturn #True
  
  ! vector_are_differents:
  ProcedureReturn #False

EndProcedure

Define numTests = 20000000
Define *p1.CArray::CArrayV3F32 = RandomPositionArray(numTests)
Define *p2.CArray::CArrayV3F32 = RandomPositionArray(numTests)
Define mem1 = AllocateMemory(numTests)
Define mem2 = AllocateMemory(numTests)
Define mem3 = AllocateMemory(numTests)
Define i
Define T1.q = ElapsedMilliseconds()
For i=0 To numTests - 1
  PokeB(mem1+i, EqualsPB(CArray::GetValue(*p1, i),CArray::GetValue(*p2, i)))
Next
Define E1.q = ElapsedMilliseconds() - T1
  
Define T2.q = ElapsedMilliseconds()
For i=0 To numTests - 1
  PokeB(mem2+i, EqualsPB2(CArray::GetValue(*p1, i),CArray::GetValue(*p2, i)))
Next
Define E2.q = ElapsedMilliseconds() - T2

Define T3.q = ElapsedMilliseconds()
For i=0 To numTests - 1
  PokeB(mem3+i, EqualsSSE(CArray::GetValue(*p1, i),CArray::GetValue(*p2, i)))
Next
Define E3.q = ElapsedMilliseconds() - T3
Define check1 = CompareMemory(mem1, mem2, numTests)
Define check2 = CompareMemory(mem2, mem3, numTests)
MessageRequester("EQUALS", StrD(E1)+" vs "+StrD(E2)+" vs "+StrD(E3)+",  CHECK : "+Str(check1)+", "+Str(check2))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 33
; FirstLine = 21
; Folding = -
; EnableXP