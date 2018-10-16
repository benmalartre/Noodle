Structure Vector3 Align 16
  v.f[4]
EndStructure

#ALIGN_BYTES = 16

Macro Align16(_mem)
  ((_mem) + #ALIGN_BYTES-(_mem)%#ALIGN_BYTES)
EndMacro


DataSection
  __ieee754_128_sign_mask__:
  Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
EndDataSection
; 
; ;- define the SSEx-variables in a new data-section, 
; !section '.datapb' Data readable writeable  ;begin of a new section = no problem with alignment16
; __ieee754_128_sign_mask__:
; !
; Ax:                ;address for PB
; !A.x DD $7FFFFFFF        ;the structure or ... 
; Ay:
; !A.y DD $7FFFFFFF
; Az:
; !A.z DD $7FFFFFFF
;
; Macro Aligned_Sign_Mask_128
;   Align16(?__ieee754_128_sign_mask__)
; EndMacro


Macro Vector3_Dot(_a, _b)
  (_a\v[0] * _b\v[0] + _a\v[1] * _b\v[1] +_a\v[2] * _b\v[2])
EndMacro

Procedure.f Vector3_Dot_SSE(*a.Vector3, *b.Vector3)
  Protected d.f    
  ! mov rax, [p.p_a]
  ! mov rdx, [p.p_b]
  
  ; ----------------------------------------------
  ; haddps method
  ; ----------------------------------------------
  ! movups xmm0, [rax]
  ! movups xmm1, [rdx]
  ! mulps xmm0, xmm1
  ! haddps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! movss [p.v_d], xmm0
  
  ; ----------------------------------------------
  ; movss method
  ; ----------------------------------------------
;   ! movss xmm0, [rax]
;   ! mulss xmm0, [rdx]
;   ! movss xmm1, [rax+4]
;   ! mulss xmm1, [rdx+4]
;   ! addss xmm0, xmm1
;   ! movss xmm2, [rax+8]
;   ! mulss xmm2, [rdx+8]
;   ! addss xmm0, xmm2
;   
;   ! movss [p.v_d], xmm0
  ProcedureReturn d
EndProcedure

Procedure Vector3_Dot_Array_SSE(*a, *b, nb.i, *dots)
  
  ! mov rax, [p.p_a]            ; move a vector array to rax
  ! mov rdx, [p.p_b]            ; move b vector array to rdx
  ! mov rcx, [p.v_nb]           ; set vector decrement counter
  ! mov rdi, [p.p_dots]         ; move output float array to rdi
  
  ! dot_array_loop:
  !   movss xmm0, [rax]
  !   mulss xmm0, [rdx]
  !   movss xmm1, [rax+4]
  !   mulss xmm1, [rdx+4]
  !   addss xmm0, xmm1
  !   movss xmm2, [rax+8]
  !   mulss xmm2, [rdx+8]
  !   addss xmm0, xmm2
  !   movss [rdi], xmm0
  !   add rax, 16
  !   add rdx, 16
  !   add rdi, 4
  !   dec rcx
  !   jnz dot_array_loop

  ProcedureReturn
EndProcedure

  

Procedure.s ArrayString(*A, nb)
  Protected s.s
  If nb > 12
    For i=0 To 5
      s+StrF(PeekF(*A+i*4))+","
    Next
    For i=nb-7 To nb-1
      s+StrF(PeekF(*A+i*4))+","
    Next
  Else
    For i=0 To nb-1
      s+StrF(PeekF(*A+i*4))+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure


Procedure Compare(*A1, *A2, nb)
  Protected *v1.Vector3, *v2.Vector3
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(Vector3)
    *v2 = *A2 + i * SizeOf(Vector3)
    If Abs(*v1\v[0] - *v2\v[0]) > 0.0001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\v[1] - *v2\v[1]) > 0.0001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\v[2] - *v2\v[2]) > 0.0001
      ProcedureReturn #False
    EndIf 
  Next
  
  ProcedureReturn #True
EndProcedure

; ---------------------------------------------------------
; COMPARE TWO FLOAT ARRAYS
; ---------------------------------------------------------
Procedure CompareResults(*a1, *a2, nb)

  For i = 0 To nb - 1
    Debug "COMPARE "+StrF(PeekF(*a1 + i* 4))+" vs "+StrF(PeekF(*a2 +i * 4))
    If Abs(PeekF(*a1 + i* 4) - PeekF(*a2 +i * 4)) > 0.0001
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
   
EndProcedure

; 
; Define v.Vector3, o.Vector3
; v\v[0] = 1.1
; v\v[1] = 2.2
; v\v[2] = -3.3
; 
; o\v[0] = -6.1
; o\v[1] = 92
; o\v[2] = 23
; 
; Vector3_Dot_SSE(v,o)
; Debug StrF(v\v[0])+","+StrF(v\v[1])+","+StrF(v\v[2])
; 
; v\v[0] = 1.1
; v\v[1] = 2.2
; v\v[2] = -3.3
; 
; o\v[0] = -6.1
; o\v[1] = 92
; o\v[2] = 23
; 
; Vector3_Dot(v,o)
; Debug StrF(v\v[0])+","+StrF(v\v[1])+","+StrF(v\v[2])


Define nb.i = 12000000
Define *v.Vector3
Define _s.i = nb * SizeOf(Vector3) 
Define *v1 = AllocateMemory(_s + #ALIGN_BYTES)
Define *n1 = AllocateMemory(_s + #ALIGN_BYTES)

Define *result1 = AllocateMemory(nb * 4)
Define *result2 = AllocateMemory(nb * 4)
Define *result3 = AllocateMemory(nb * 4)

If Not *v1 Or Not *n1
  MessageRequester("ERROR", "INVALID MEMORY")
Else
  
  Define *av = Align16(*v1)
  Define *an = Align16(*n1)


  For i=0 To nb -1
    *v = *av + i * SizeOf(Vector3)
    *v\v[0] = (Random(1024) - 512) * 0.1
    *v\v[1] = (Random(1024) - 512) * 0.1
    *v\v[2] = (Random(1024) - 512) * 0.1
    
    *v = *an + i * SizeOf(Vector3)
    *v\v[0] = 0
    *v\v[1] = 1
    *v\v[2] = 0
  Next
  
  Define original.s = ArrayString(*av, nb)
  
  
  Define N.Vector3
  
  N\v[0] = 0
  N\v[1] = 1
  N\v[2] = 0
  
  Define startT.q = ElapsedMilliseconds()
  Define *v.Vector3
  For i=0 To nb -1
    *v = *av + i * SizeOf(Vector3)
    PokeF(*result1+i*4, Vector3_Dot(*v, N))
    Debug StrF(PeekF(*result1+i*4))
  Next
  Define T1.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  For i=0 To nb -1
    *v = *av + i * SizeOf(Vector3)
    PokeF(*result2+i*4, Vector3_Dot_SSE(*v, N))
    Debug StrF(PeekF(*result2+i*4))
  Next
  Define T2.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  Vector3_Dot_Array_SSE(*av, *an, nb, *result3)
  Define T3.q = ElapsedMilliseconds() - startT
  

  
  Debug ArrayString(*result1, nb)
  Debug ArrayString(*result2, nb)
  Debug ArrayString(*result3, nb)
  
  Define c1.b = CompareResults(*result1, *result2, nb)
  Define c2.b = CompareResults(*result1, *result3, nb)

  
  MessageRequester("DOT", "Num Vectors : "+Str(nb)+Chr(10)+
                               "PB DOT: "+StrD(T1*0.001)+Chr(10)+
                               "SSE DOT : "+StrD(T2*0.001)+" : "+Str(c1)+Chr(10)+
                               "ASM LOOP + SSE DOT : "+StrD(T3*0.001)+" : "+Str(c2))
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 33
; FirstLine = 11
; Folding = --
; EnableXP