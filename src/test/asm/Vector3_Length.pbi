Structure Vector3 ;Align 16
  v.f[4]
EndStructure

Procedure.s Vector3ArrayString(*A, nb)
  Protected *v.Vector3
  Protected s.s
  If nb > 12
    For i=0 To 5
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\v[0],3)+","+StrF(*v\v[1],3)+","+StrF(*v\v[2],3)+","
    Next
    For i=nb-7 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\v[0],3)+","+StrF(*v\v[1],3)+","+StrF(*v\v[2],3)+","
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\v[0],3)+","+StrF(*v\v[1],3)+","+StrF(*v\v[2],3)+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure

Procedure.s FloatArrayString(*A, nb)
  Protected v.f
  Protected s.s
  If nb > 12
    For i=0 To 5
      f = PeekF(*A + i * 4)
      s+StrF(f,3)+","
    Next
    For i=nb-7 To nb-1
      f = PeekF(*A + i * 4)
      s+StrF(f,3)+","
    Next
  Else
    For i=0 To nb-1
      f = PeekF(*A + i * 4)
      s+StrF(f,3)+","
    Next
  EndIf
  ProcedureReturn s
EndProcedure



Procedure CompareVector3Array(*A1, *A2, nb)
  Protected *v1.Vector3, *v2.Vector3
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(Vector3)
    *v2 = *A2 + i * SizeOf(Vector3)
    If Abs(*v1\v[0] - *v2\v[0]) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\v[1] - *v2\v[1]) > 0.001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\v[2] - *v2\v[2]) > 0.001
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure

Procedure CompareFloatArray(*A1, *A2, nb)
  Define.f f1, f2
  For i=0 To nb-1
    f1 = PeekF(*A1 + i * 4)
    f2 = PeekF(*A2 + i * 4)
    If Abs(f1 - f2) > 0.001
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
EndProcedure

Procedure.f LengthSquared(*v.Vector3)
  ProcedureReturn (*v\v[0] * *v\v[0] + *v\v[1] * *v\v[1] + *v\v[2] * *v\v[2])
EndProcedure

Procedure.f Length(*v.Vector3)
  ProcedureReturn Sqr(*v\v[0] * *v\v[0] + *v\v[1] * *v\v[1] + *v\v[2] * *v\v[2])
EndProcedure

Procedure.f SSELengthSquared(*v.Vector3)
  Protected l.f
  ! mov rax, [p.p_v]
  ! movaps xmm0, [rax]
  ! mulps xmm0, xmm0
  ! movaps xmm1, xmm0
  ! shufps xmm0, xmm1, 0x4e
	!	addps xmm0, xmm1
	!	movaps xmm1, xmm0
	!	shufps xmm1, xmm1, 0x11
	!	addps xmm0, xmm1
	! movss [p.v_l], xmm0
	ProcedureReturn l
EndProcedure

Procedure.f SSELength(*v.Vector3)
  Protected l.f
  ! mov rax, [p.p_v]
  ! movaps xmm0, [rax]
  ! mulps xmm0, xmm0
  ! movaps xmm1, xmm0
  ! shufps xmm0, xmm1, 0x4e
	!	addps xmm0, xmm1
	!	movaps xmm1, xmm0
	!	shufps xmm1, xmm1, 0x11
	!	addps xmm0, xmm1
  ! sqrtss xmm0, xmm0
  ! movss [p.v_l], xmm0
  ProcedureReturn l
EndProcedure

Procedure SSELengthSquared_Array(*v.Vector3, *lengths, nb.i)
  ! mov rax, [p.p_v]
  ! mov rdx, [p.p_lengths]
  ! mov ecx, [p.v_nb]

  !sselengthsquared_array_loop:
  !   movaps xmm0, [rax]
  !   mulps xmm0, xmm0
  !   movaps xmm1, xmm0
  !   shufps xmm0, xmm1, 0x4e
	!	  addps xmm0, xmm1
	! 	movaps xmm1, xmm0
	!	  shufps xmm1, xmm1, 0x11
	!	  addps xmm0, xmm1
	!   movss [rdx], xmm0
  !   add rax, 16
  !   add rdx, 4
  !   dec ecx
  !   jnz sselengthsquared_array_loop
EndProcedure

Procedure SSELength_Array(*v.Vector3, *lengths, nb.i)
  ! mov rax, [p.p_v]
  ! mov rdx, [p.p_lengths]
  ! mov ecx, [p.v_nb]

  !sselength_array_loop:
  !   movaps xmm0, [rax]
  !   mulps xmm0, xmm0
  !   movaps xmm1, xmm0
  !   shufps xmm0, xmm1, 0x4e
	!	  addps xmm0, xmm1
	!	  movaps xmm1, xmm0
	!	  shufps xmm1, xmm1, 0x11
	!	  addps xmm0, xmm1
  !   sqrtss xmm0, xmm0
	!   movss [rdx], xmm0
  !   add rax, 16
  !   add rdx, 4
  !   dec ecx
  !   jnz sselength_array_loop
EndProcedure


Define nb.l = 12800000
Define *v.Vector3
Define _s.i = nb * SizeOf(Vector3)
Define _o.i = nb *4
Define *vA = AllocateMemory(_s)
Define *o1A = AllocateMemory(_o)
Define *o2A = AllocateMemory(_o)
Define *o3A = AllocateMemory(_o)

For i=0 To nb -1
  *v = *vA + i * SizeOf(Vector3)
  *v\v[0] = Random(1024) - 512
  *v\v[1] = Random(1024) - 512
  *v\v[2] = Random(1024) - 512
Next


Define startT.q = ElapsedMilliseconds()
For i=0 To nb -1
  *v = *vA + i * SizeOf(Vector3)
  PokeF(*o1A + i * 4, Length(*v))
Next
Define T1.q = ElapsedMilliseconds() - startT

startT.q = ElapsedMilliseconds()
For i=0 To nb -1
  *v = *vA + i * SizeOf(Vector3)
  PokeF(*o2A + i * 4, SSELength(*v))
;   Vector3_Normalize_SIMD(*v1)
Next
Define T2.q = ElapsedMilliseconds() - startT

startT.q = ElapsedMilliseconds()
SSELength_Array(*vA, *o3A, nb)
Define T3.q = ElapsedMilliseconds() - startT


MessageRequester("VECTOR LENGTH", "PB : "+Str(T1)+Chr(10)+
                                  "SIMD : "+Str(T2)+" : "+Str(CompareFloatArray(*o1A, *o2A, nb))+Chr(10)+
                                  "ASM LOOP + SIMD : "+Str(T3)+" : "+Str(CompareFloatArray(*o1A, *o3A, nb))+Chr(10)+
;                             Str(CompareMemory(*o2A, *o3A, _s))+Chr(10)+"-------------"+Chr(10)+
                            FloatArrayString(*o1A, nb)+Chr(10)+"-------------"+Chr(10)+
                            FloatArrayString(*o2A, nb)+Chr(10)+"-------------"+Chr(10)+
                            FloatArrayString(*o3A, nb)+Chr(10)+"-------------")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 105
; FirstLine = 76
; Folding = --
; EnableXP