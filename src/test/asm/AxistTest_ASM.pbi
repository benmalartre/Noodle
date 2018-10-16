Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_0000_sign_mask:
  Data.l $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF
  sse_0001_sign_mask:
  Data.l $7FFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF
  sse_0010_sign_mask:
  Data.l $FFFFFFFF, $7FFFFFFF, $FFFFFFFF, $FFFFFFFF
  sse_0011_sign_mask:
  Data.l $7FFFFFFF, $7FFFFFFF, $FFFFFFFF, $FFFFFFFF
  sse_0100_sign_mask:
  Data.l $FFFFFFFF, $FFFFFFFF, $7FFFFFFF, $FFFFFFFF
  sse_0101_sign_mask:
  Data.l $7FFFFFFF, $FFFFFFFF, $7FFFFFFF, $FFFFFFFF
  sse_0110_sign_mask:
  Data.l $FFFFFFFF, $7FFFFFFF, $7FFFFFFF, $FFFFFFFF
  sse_0111_sign_mask:
  Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $FFFFFFFF
  sse_1000_sign_mask:
  Data.l $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $7FFFFFFF
  sse_1001_sign_mask:
  Data.l $7FFFFFFF, $FFFFFFFF, $FFFFFFFF, $7FFFFFFF
  sse_1010_sign_mask:
  Data.l $FFFFFFFF, $7FFFFFFF, $FFFFFFFF, $7FFFFFFF
  sse_1011_sign_mask:
  Data.l $7FFFFFFF, $7FFFFFFF, $FFFFFFFF, $7FFFFFFF
  sse_1100_sign_mask:
  Data.l $FFFFFFFF, $FFFFFFFF, $7FFFFFFF, $7FFFFFFF
  sse_1101_sign_mask:
  Data.l $7FFFFFFF, $FFFFFFFF, $7FFFFFFF, $7FFFFFFF
  sse_1110_sign_mask:
  Data.l $FFFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
  sse_1111_sign_mask:
  Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
  
  sse_equal:
  Data.f 0,0,0,0
  sse_lower:
  Data.f -1,-1,-1,-1
  sse_greater:
  Data.f 1,1,1,1
EndDataSection

  
Procedure.l Test(*e0.v3f32,*p0.v3f32, *p2.v3f32, *box.v3f32)
  Protected o.l = #False
  ! mov rax, qword [p.p_e0]             ; move e0 to register
  ! mov rcx, qword [p.p_p0]             ; move p0 to register
  ! mov rdx, qword [p.p_p2]             ; move p2 to register
  ! mov r8, qword [p.p_box]  
  
  ; project points to edge
  ! movups xmm0, [rax]                  ; move e0 packed datas to xmm0
  ! movaps xmm7, xmm0                   ; make a copy in xmm7
  ! shufps xmm0, xmm0, 01011010b        ; e0z e0z e0y e0y
  
  ! movups xmm1, [rcx]                  ; move p0 packed datas to xmm1
  ! movups xmm2, [rdx]                  ; move p2 packed datas to xmm2
  ! shufps xmm1, xmm2, 10011001b        ; p0y p0z p2y p2z
  ! shufps xmm1, xmm1, 11011000b        ; p0y p2y p0z p2z

  ! mulps  xmm1, xmm0                   ; p0 ^ p2 packed 2D cross product (c0)
  ! movaps xmm3, xmm1                   ; copy c0 position to xmm3
  ! movaps xmm4, xmm1                   ; copy c0 position to xmm4
  ! shufps xmm3, xmm3, 00010001b        ; c0x c0y c0x c0y
  ! shufps xmm4, xmm4, 11101110b        ; c0z c0w c0z c0w
  
  ! subps  xmm3, xmm4                   ; packed subtraction
 
  ; box
  ! movaps xmm5, [r8]                  ; mov box to xmm5
  
  ; absolute edge
  ! mov r9, l_sse_1111_sign_mask       ; move 1111 sign mask to rsi register
  ! movdqu  xmm6, [r9]                 ; move packed data to xmm6    
  ! andps xmm7, xmm6                   ; bitmask removing sign (Abs(e0))
  
  ; compute radius
  ! shufps xmm7, xmm7, 11011000b       ; ae0x ae0z ae0y ae0w
  ! mulps xmm7, xmm5                   ; packed multiply with box
  ! shufps xmm7, xmm7, 10100101b       ; r0y r0y r0z r0z
  ! movss xmm8, xmm7                   ; r0y
  ! psrldq xmm7, 8                     ; shift right
  ! movss xmm9, xmm7                   ; r0z
  ! addss xmm8, xmm9                   ; rad = r0y + r0z
  ! shufps xmm8, xmm8, 00000000b       ; rad rad rad rad

  ; shuffle
  ! movaps xmm4, xmm3                  ; copy xmm3 in xmm4
  ! psrldq xmm4, 4                     ; shift left 4 bytes
  ! ucomiss xmm4, xmm3                 ; compare first value
  
  ! jp greater                         ; branch is greater
  ! jmp lower                          ; branch is lower
  
  ; p0>rad Or -p2>rad And p2>rad Or -p0>rad
  ; p0 >= p1
  ! greater:
  !   shufps xmm3, xmm3, 00010001b
  !   jmp check_box
  
  ; p0 < p1
  ! lower:
  !   shufps xmm3, xmm3, 01000100b
  !   jmp check_box
  
  ; check box intersection
  ! check_box:
  !   mov rcx, l_sse_1010_sign_mask
  !   movups xmm4, [rcx]
  !   andps xmm3, xmm4
 
  !   cmpps xmm8, xmm3, 1
  !   movmskps r9, xmm8
  !   cmp r9, 16
  !   mov [p.v_o], r9
;   !   je no_intersection
;   !   jmp intersect
  
;   ! no_intersection:
;   ProcedureReturn #False
;   ! intersect:
;   ProcedureReturn #True
  
 ProcedureReturn o
  
EndProcedure

;     e0\z, e0\y
;     p0 = a * v0\y - b * v0\z
;     p2 = a * v2\y - b * v2\z

Define a.v3f32, b.v3f32, e.v3f32, box.v3f32
a\x = -1
a\y = 0
a\z = 0

b\x = 0
b\y = 1
b\z = 1

e\x = 1
e\y = 1
e\z = 1

box\x = 0.1
box\y = 0.1
box\z = 0.1

Debug Bin(Test(e,a, b, box))
Debug StrF(e\x,3)+","+StrF(e\y,3)+","+StrF(e\z,3)+","+StrF(e\w,3)

;  AXISTEST_X01(e0\z, e0\y, fez, fey)
;     Macro AXISTEST_X01(a, b, fa, fb)
;     p0 = a * v0\y - b * v0\z
;     p2 = a * v2\y - b * v2\z
min=p0
max=p2


;     If p0<p2 : min=p0 : max=p2
;     Else : min=p2 : max=p0
;     EndIf
;     rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
;     If min>rad Or max<-rad : ProcedureReturn #False : EndIf
;     EndMacro
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 48
; FirstLine = 36
; Folding = -
; EnableXP