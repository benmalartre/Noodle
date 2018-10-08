Structure m4f32
  v.f[16]
EndStructure


Macro Matrix4_Multiply(_m)
  EnableASM
  MOV rdi, _m
  DisableASM
  ! mov rcx, 48
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rdi + 16]
  ! movaps xmm2, [rdi + 32]
  ! movaps xmm3, [rdi + 48]
  
  ! m4f32_multiply_loop:
  ! movss (rsi, rcx), xmm4
;      ! mov rdi, [p.p_a]
; !    movaps rdi, xmm0
; !    movaps 16rdi, xmm1
; !    movaps 32rdi, xmm2
; !    movaps 48rdi, xmm3
; !    movq   48, rcx                     ; 2. loop reversal
; !m4f32_multiply_loop:                   ;    (For simpler exit condition)
;     movss (%rsi, %rcx), %xmm4           ; 3. extended address operands
;     shufps $0, %xmm4, %xmm4             ;    (faster than pointer calculation)
;     mulps %xmm0, %xmm4
;     movaps %xmm4, %xmm5
;     movss 4(%rsi, %rcx), %xmm4
;     shufps $0, %xmm4, %xmm4
;     mulps %xmm1, %xmm4
;     addps %xmm4, %xmm5
;     movss 8(%rsi, %rcx), %xmm4
;     shufps $0, %xmm4, %xmm4
;     mulps %xmm2, %xmm4
;     addps %xmm4, %xmm5
;     movss 12(%rsi, %rcx), %xmm4
;     shufps $0, %xmm4, %xmm4
;     mulps %xmm3, %xmm4
;     addps %xmm4, %xmm5
;     movaps %xmm5, (%rdx, %rcx)
;     subq $16, %rcx                      ; one 'sub' (vs 'add' & 'cmp')
;     jge m4f32_multiply_loop             ; SF=OF, idiom: jump If positive
;     ret

; ! mov rsi, [p.p_b]
;   ! mov rdi, [p.p_a]
;   ! movaps xmm0, [rdi]
;   ! movaps xmm1, [rsi]
;   ! addps xmm0, xmm1
;   ! movups [rdi], xmm0
EndMacro

Define m.m4f32
m\v[0] = 1
m\v[5] = 1
m\v[9] = 1
m\v[15] = 1
Matrix4_Multiply(m)  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; FirstLine = 5
; Folding = -
; EnableXP