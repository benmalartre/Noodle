
Structure Vector3 ;Align 16
  v.f[3]
EndStructure


Macro Vector3_Normalize(_v)
   Define _mag.f = Sqr(_v\v[0] * _v\v[0] + _v\v[1] * _v\v[1] + _v\v[2] * _v\v[2])
    ;Avoid error dividing by zero
    If _mag = 0 : _mag =1.0 :EndIf
    
    Define _div.f = 1.0/_mag
    _v\v[0] * _div
    _v\v[1] * _div
    _v\v[2] * _div
EndMacro

Procedure Vector3_Normalize_SIMD(*v.Vector3)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  
  ! movaps xmm6, xmm0      ;effectue une copie du vecteur dans xmm6
  ! mulps xmm0, xmm0       ;carré de chaque composante
  ; mix1
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $4e
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; mix2
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $11
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; 1/sqrt
  ! rsqrtps xmm0, xmm0     ;inverse de la racine carrée (= longueur)
  ! mulps xmm0, xmm6       ;que multiplie le vecteur initial
  
  ! movups [rax], xmm0     ; send back to memory
  
EndProcedure


Procedure Vector3_Normalize_SIMD_Array(*v.Vector3, nb.i)
  ! mov rax, [p.p_v]
  ! mov ecx, [p.v_nb]

  !vector3_normalize_simd_array_loop:
  ! movups xmm0, [rax]

  ; Entrée: xmm0 contient un vecteur à normaliser
  ! movaps xmm6, xmm0      ;effectue une copie du vecteur dans xmm6
  ! mulps xmm0, xmm0       ;carré de chaque composante
  ; mix1
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7,  $4e
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; mix2
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $11
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; 1/sqrt
  ! rsqrtps xmm0, xmm0     ;inverse de la racine carrée (= longueur)
  ! mulps xmm0, xmm6       ;que multiplie le vecteur initial
  ; Sortie: xmm0 contient le vecteur normalisé
  ! movups [rax], xmm0
  ! add rax, 12
  ! dec ecx
  ! jnz vector3_normalize_simd_array_loop
EndProcedure

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


Define nb.l = 1280000 * 12
Define *v1.Vector3
Define _s.i = nb * SizeOf(Vector3)
Define *v1A = AllocateMemory(_s)
Define *v2A = AllocateMemory(_s)
Define *v3A = AllocateMemory(_s)

For i=0 To nb -1
  *v1 = *v1A + i * SizeOf(Vector3)
  *v1\v[0] = Random(1024) - 512
  *v1\v[1] = Random(1024) - 512
  *v1\v[2] = Random(1024) - 512
Next

CopyMemory(*v1A, *v2A, _s)
CopyMemory(*v1A, *v3A, _s)

Define startT.q = ElapsedMilliseconds()
For i=0 To nb -1
  *v1 = *v1A + i * SizeOf(Vector3)
  Vector3_Normalize(*v1)
Next
Define T1.q = ElapsedMilliseconds() - startT

startT.q = ElapsedMilliseconds()
For i=0 To nb -1
  *v1 = *v2A + i * SizeOf(Vector3)
  Vector3_Normalize_SIMD(*v1)
Next
Define T2.q = ElapsedMilliseconds() - startT

startT.q = ElapsedMilliseconds()
Vector3_Normalize_SIMD_Array(*v3A, nb)
Define T3.q = ElapsedMilliseconds() - startT

MessageRequester("COMPARE", "PB : "+Str(T1)+Chr(10)+
                            "SIMD : "+Str(T2)+" : "+Str(Compare(*v1A, *v2A, nb))+Chr(10)+
                            "ASM LOOP + SIMD : "+Str(T3)+" : "+Str(Compare(*v1A, *v3A, nb))+Chr(10)+
                            Str(CompareMemory(*v2A, *v3A, _s))+Chr(10)+"-------------"+Chr(10)+
                            ArrayString(*v1A, nb)+Chr(10)+"-------------"+Chr(10)+
                            ArrayString(*v2A, nb)+Chr(10)+"-------------"+Chr(10)+
                            ArrayString(*v3A, nb)+Chr(10)+"-------------")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 62
; FirstLine = 51
; Folding = -
; EnableXP