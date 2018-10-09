Structure Vector3
  v.f[3]
EndStructure

#ALIGN_BYTES = 64

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
  ! movdqu  xmm1, [rax]                 ; bitmask removing sign        
  ! movups xmm0, [rdi]                  ; data register to sse register
  ! andps xmm0, xmm1                    ; bitmask removing sign
  ! movups [rdi], xmm0                  ; mov back to memory

EndMacro

Macro Vector3_Absolute_SIMD_Array(_v, _nb)
  EnableASM
  MOV rdi, _v                           ; vector3 array to data register
  MOV rcx, _nb                          ; num vector to count register
  MOV rax, qword l___ieee754_128_sign_mask__  ; move sign mask to rsi register
  DisableASM
  ! movdqu  xmm1, [rax]  
  ! vector3_normalize_simd_array_loop:
  !   movups xmm0, [rdi]                ; data register to sse register
  !   andps xmm0, xmm1                  ; bitmask removing sign
  !   movups [rdi], xmm0                ; move back to array memory
  !   add rdi, 12                       ; data offset
  !   dec rcx                           ; dec counter
  !   jnz vector3_normalize_simd_array_loop
EndMacro

Procedure.s ArrayString(*A, nb)
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
Define *v.Vector3
Define _s.i = nb * SizeOf(Vector3) 
Define *v1 = AllocateMemory(_s + #ALIGN_BYTES)
Define *v2 = AllocateMemory(_s + #ALIGN_BYTES)
Define *v3 = AllocateMemory(_s + #ALIGN_BYTES)



If Not *v1 Or Not *v2 Or Not *v3
  MessageRequester("ERROR", "INVALID MEMORY")
Else
  
  Define *av1 = Align16(*v1)
  Define *av2 = Align16(*v2)
  Define *av3 = Align16(*v3)


  For i=0 To nb -1
    *v = *av1 + i * SizeOf(Vector3)
    *v\v[0] = (Random(1024) - 512) * 0.1
    *v\v[1] = (Random(1024) - 512) * 0.1
    *v\v[2] = (Random(1024) - 512) * 0.1
  Next
  
  Define original.s = ArrayString(*av1, nb)
  
  CopyMemory(*av1, *av2, _s)
  CopyMemory(*av1, *av3, _s)
  
  
  
  Define startT.q = ElapsedMilliseconds()
  For i=0 To nb -1
    *v = *av1 + i * SizeOf(Vector3)
    Vector3_Absolute(*v)
  Next
  Define T1.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  For i=0 To nb -1
    *v = *av2 + i * SizeOf(Vector3)
    Vector3_Absolute_SIMD(*v)
  Next
  Define T2.q = ElapsedMilliseconds() - startT
  
  startT.q = ElapsedMilliseconds()
  Vector3_Absolute_SIMD_Array(*av3, nb)
  Define T3.q = ElapsedMilliseconds() - startT
  
  MessageRequester("COMPARE", "NUM TRIANGLES : "+Str(nb)+Chr(10)+
                              "PB : "+StrD(T1*0.001)+Chr(10)+
                              "SIMD : "+StrD(T2*0.001)+" : "+Str(Compare(*av1, *av2, nb))+Chr(10)+
                              "ASM LOOP + SIMD : "+StrD(T3*0.001)+" : "+Str(Compare(*av1, *av2, nb))+Chr(10)+
;                               Str(CompareMemory(*v2A, *v3A, _s))+Chr(10)+
                              original+Chr(10)+"###############"+Chr(10)+
                              ArrayString(*av1, nb)+Chr(10)+"###############"+Chr(10)+
                              ArrayString(*av2, nb)+Chr(10)+"###############"+Chr(10)+
                              ArrayString(*av3, nb)+Chr(10))
  EndIf
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 155
; FirstLine = 125
; Folding = --
; EnableXP