Structure Vector3 Align 16
  v.f[3]
EndStructure

Macro Align16(_mem)
  ((_mem) + 64-(_mem)%64)
EndMacro


DataSection
  __ieee754_128_sign_mask__:
  Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
EndDataSection

Macro Vector3_Absolute(_v)
    If _v\v[0] < 0 : _v\v[0] = -_v\v[0] : EndIf
    If _v\v[1] < 0 : _v\v[1] = -_v\v[1] : EndIf
    If _v\v[2] < 0 : _v\v[2] = -_v\v[2] : EndIf
EndMacro

Macro Vector3_Absolute_SIMD(_v)
  
  EnableASM
  MOV rdi, _v                           ; vector3 to data register
  MOV rax, qword l___ieee754_128_sign_mask__  ; move sign mask to rsi register
  DisableASM
  ! movdqa  xmm1, [rax]                 ; bitmask removing sign        
  ! movaps xmm0, [rdi]                  ; data register to sse register
  ! andps xmm0, xmm1                    ; bitmask removing sign
  ! movaps [rdi], xmm0                  ; mov back to memory

EndMacro

Macro Vector3_Absolute_SIMD_Array(_v, _nb)
  EnableASM
  MOV rdi, _v                           ; vector3 array to data register
  MOV rcx, _nb                          ; num vector to count register
  MOV rax, qword l___ieee754_128_sign_mask__  ; move sign mask to rsi register
  DisableASM
  ! movdqa  xmm1, [rax]  
  ! vector3_normalize_simd_array_loop:
  !   movaps xmm0, [rdi]                ; data register to sse register
  !   andps xmm0, xmm1                  ; bitmask removing sign
  !   movaps [rdi], xmm0                ; move back to array memory
  !   add rdi, 16                       ; data offset
  !   dec rcx                           ; dec counter
  !   jnz vector3_normalize_simd_array_loop
EndMacro

Procedure.s ArrayString(*A, nb)
  Protected *v.Vector3
  Protected s.s
  If nb > 32 : nb = 32 : EndIf
  
  For i=0 To nb-1
    *v = *A + i * SizeOf(Vector3)
    s+StrF(*v\v[0],3)+","+StrF(*v\v[1],3)+","+StrF(*v\v[2],3)+","
  Next
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


Define nb.i = 12000000
Define *v1.Vector3
Define _s.i = nb * SizeOf(Vector3)
Define *v1A = AllocateMemory(_s)
Define *v2A = AllocateMemory(_s)
Define *v3A = AllocateMemory(_s)

If Not *v1A Or Not *v2A Or Not *v3A
  MessageRequester("ERROR", "INVALID MEMORY")
Else
  
  For i=0 To nb -1
    *v1 = *v1A + i * SizeOf(Vector3)
    *v1\v[0] = (Random(1024) - 512) * 0.1
    *v1\v[1] = (Random(1024) - 512) * 0.1
    *v1\v[2] = (Random(1024) - 512) * 0.1
  Next
  
  Define original.s = ArrayString(*v1A, nb)
  
  CopyMemory(*v1A, *v2A, _s)
  CopyMemory(*v1A, *v3A, _s)
  
  Define startT.q = ElapsedMilliseconds()
  For i=0 To nb -1
    *v1 = *v1A + i * SizeOf(Vector3)
    Vector3_Absolute(*v1)
  Next
  Define T1.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  Define *aligned 
  For i=0 To nb -1
    *v1 = *v2A + i * SizeOf(Vector3)
    *aligned = Align16(*v1)
    Vector3_Absolute_SIMD(*aligned)
  Next
  Define T2.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  Define *aligned = Align16(*v3A)
  Vector3_Absolute_SIMD_Array(*aligned, nb)
  Define T3.q = ElapsedMilliseconds() - startT
  
  MessageRequester("COMPARE", "NUM TRIANGLES : "+Str(nb)+Chr(10)+
                              "PB : "+StrD(T1*0.001)+Chr(10)+
                              "SIMD : "+StrD(T2*0.001)+" : "+Str(Compare(*v1A, *v2A, nb))+Chr(10)+
                              "ASM LOOP + SIMD : "+StrD(T3*0.001)+" : "+Str(Compare(*v1A, *v3A, nb))+Chr(10))
;                               Str(CompareMemory(*v2A, *v3A, _s))+Chr(10)+
;                               original+Chr(10)+"###############"+Chr(10)+
;                               ArrayString(*v1A, nb)+Chr(10)+"###############"+Chr(10)+
;                               ArrayString(*v2A, nb)+Chr(10)+"###############"+Chr(10)+
;                               ArrayString(*v3A, nb)+Chr(10))
  EndIf
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 82
; FirstLine = 81
; Folding = --
; EnableXP