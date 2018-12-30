XIncludeFile "../../core/Application.pbi"

Procedure TestMask(*v.Math::v3f32)
  ! movups xmm0, [p.p_v]
  ! xorps xmm1, xmm1
  ! cmpps xmm0, xmm1, 1             ; packed compare (s t d3 d4) < (0,0,0,0)
  ! movmskps r12, xmm0              ; move comparison mask to r12 register
EndProcedure


Procedure TestLong(*mem, nb)
  
  Define total.l
  ! mov rsi, [p.p_mem]
  ! mov rcx, [p.v_nb]
  ! xor rdi, rdi
  
  ! loop_elements:
  !   movsxd rax, dword [rsi]
  !   add rdi, rax
  !   dec rcx
  !   jnz loop_elements
  
  ! mov [p.v_total], rdi
  Debug "TOTAL : "+Str(total)
  
EndProcedure

Procedure TestLong2(*mem, nb)
  
  Define total.l
  ! mov rsi, [p.p_mem]
  ! mov rcx, [p.v_nb]
  ! xor rdi, rdi
  
  ! loop_elements:
  !   mov eax, [rsi]
  !   add rdi, rax
  !   add rsi, 4
  !   dec rcx
  !   jnz loop_elements
  
  ! mov [p.v_total], rdi
  Debug "TOTAL : "+Str(total)
  
EndProcedure




; Debug "READY"
; 
; Define v.Math::v3f32
; Vector3::Set(v, -1,1,-2)
; 
; TestMask(v)
; Procedure Test(*datas, nb.l)
;    Define total.l
;   ! mov rsi, [p.p_datas]
;   ! mov rcx, [p.v_nb]
;   ! xor rdi, rdi
;   
;   ! loop_elements:
;   !   movzx rax, word [rsi]
;   !   add rdi, rax
;   !   dec rcx
;   !   jnz loop_elements
;   
;   ! mov [p.v_total], rdi
;   Debug "TOTAL : "+Str(total)
;  
; EndProcedure
; 
; Procedure TestMathLabel()
;   ! movups xmm0, [math.l_sse_1111_negate_mask]
; EndProcedure
; 
; 

Define nb = 2
Define *datas = AllocateMemory(nb * 4)
Define total.i = 0
Define i
For i=0 To nb-1
  PokeI(*datas + i * 4, 12800000)
Next

TestLong2(*datas, nb)
; TestMathLabel()
;Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Tata", Shape::#SHAPE_CUBE)
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 63
; FirstLine = 56
; Folding = -
; EnableXP