XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../objects/Geometry.pbi"
UseModule Math

Procedure WithAdd(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32, *result.v3f32)
  Define *origin = *box\origin
  Define *extend = *box\extend
  
  ! mov rsi, [p.p_origin]
  ! movups xmm11, [rsi]
  ! mov rsi, [p.p_extend]
  ! movups xmm12, [rsi]
  ! mov rsi, [p.p_a]
  ! movups xmm13, [rsi]
  ! mov rsi, [p.p_b]
  ! movups xmm14, [rsi]
  ! mov rsi, [p.p_c]
  ! movups xmm15, [rsi]
  ! mov r13, math.l_sse_1111_negate_mask
  
  ; ---------------------------------------------------------------------------------
  ; triangle-box intersection
  ; ---------------------------------------------------------------------------------
  ! movaps xmm0, xmm14              ; copy p1 to xmm0
  ! movaps xmm1, xmm15              ; copy p2 to xmm1
  
  ; ---------------------------------------------------------------------------------
  ;  compute edges
  ; ---------------------------------------------------------------------------------
  ! subps xmm0, xmm13             ; compute edge0 (p1 - p0)
  ! subps xmm1, xmm14             ; compute edge1 (p2 - p1)
  
  ! movaps xmm2,xmm0              ; copy edge0 to xmm2
  ! movaps xmm3,xmm1              ; copy edge1 to xmm3
  
  ; ---------------------------------------------------------------------------------
  ; compute triangle normal
  ; ---------------------------------------------------------------------------------
  ! shufps xmm0,xmm0,00001001b        ; exchange 2 and 3 element (a)
  ! shufps xmm1,xmm1,00010010b        ; exchange 1 and 2 element (b)
  ! mulps  xmm0,xmm1
           
  ! shufps xmm2,xmm2,00010010b        ; exchange 1 and 2 element (a)
  ! shufps xmm3,xmm3,00001001b        ; exchange 2 and 3 element (b)
  ! mulps  xmm2,xmm3    
  ! subps  xmm0,xmm2                  ; cross product triangle normal
  
  ; ---------------------------------------------------------------------------------
  ; compute minimal bbox
  ; ---------------------------------------------------------------------------------
  ! movaps xmm3, xmm12            ; copy boxhalfsize to xmm3
  ! movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
  
  ! movups xmm6, [r13]            ; load 1111 negate mask
  ! mulps xmm5, xmm6              ; negate boxhalfsize
  
  ! subps xmm3, xmm13             ; box - p0
  ! subps xmm5, xmm13             ; -box - p0
  
  ! xorps xmm2, xmm2
  ! cmpps xmm2, xmm0, 1           ; check zero < normal

  ! movaps xmm4, xmm5
  ! movaps xmm6, xmm3
  
  ! andps xmm4, xmm2
  ! andps xmm6, xmm2

  ! xorps xmm2, xmm2
  ! cmpps xmm2, xmm0, 5          ; check zero >= normal

  ! andps xmm3, xmm2
  ! andps xmm5, xmm2
  
  ! addps xmm4, xmm3
  ! addps xmm6, xmm5
  
  ! label_cool:
  ! mov rax, [p.p_result]
  ! movups [rax], xmm4
  Debug StrF(*result\x)+", "+StrF(*result\y)+", "+StrF(*result\z)+", "+StrF(*result\_w)
EndProcedure


Procedure WithMask(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32, *result.v3f32)
  
  Define *origin = *box\origin
  Define *extend = *box\extend
  
  ! mov rsi, [p.p_origin]
  ! movups xmm11, [rsi]
  ! mov rsi, [p.p_extend]
  ! movups xmm12, [rsi]
  ! mov rsi, [p.p_a]
  ! movups xmm13, [rsi]
  ! mov rsi, [p.p_b]
  ! movups xmm14, [rsi]
  ! mov rsi, [p.p_c]
  ! movups xmm15, [rsi]
  ! mov r13, math.l_sse_1111_negate_mask
  
  ; ---------------------------------------------------------------------------------
  ; triangle-box intersection
  ; ---------------------------------------------------------------------------------
  ! movaps xmm0, xmm14              ; copy p1 to xmm0
  ! movaps xmm1, xmm15              ; copy p2 to xmm1
  
  ; ---------------------------------------------------------------------------------
  ;  compute edges
  ; ---------------------------------------------------------------------------------
  ! subps xmm0, xmm13             ; compute edge0 (p1 - p0)
  ! subps xmm1, xmm14             ; compute edge1 (p2 - p1)
  
  ! movaps xmm2,xmm0              ; copy edge0 to xmm2
  ! movaps xmm3,xmm1              ; copy edge1 to xmm3
  
  ; ---------------------------------------------------------------------------------
  ; compute triangle normal
  ; ---------------------------------------------------------------------------------
  ! shufps xmm0,xmm0,00001001b        ; exchange 2 and 3 element (a)
  ! shufps xmm1,xmm1,00010010b        ; exchange 1 and 2 element (b)
  ! mulps  xmm0,xmm1
           
  ! shufps xmm2,xmm2,00010010b        ; exchange 1 and 2 element (a)
  ! shufps xmm3,xmm3,00001001b        ; exchange 2 and 3 element (b)
  ! mulps  xmm2,xmm3    
  ! subps  xmm0,xmm2                  ; cross product triangle normal
  
  ; ---------------------------------------------------------------------------------
  ; compute minimal bbox
  ; ---------------------------------------------------------------------------------
  !   xorps xmm6, xmm6
  !   cmpps xmm6, xmm0 , 1          ; check 0 < normal
  !   movmskps r12, xmm6
  
  !   movaps xmm4, xmm12            ; copy boxhalfsize to xmm7
  !   movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
  
  !   movups  xmm6, [r13]           ; load 1111 negate mask
  !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  !   subps xmm4, xmm13             ; box - p0
  !   subps xmm5, xmm13             ; -box - p0
  !   movaps xmm6, xmm4             ; make a copy
  
 
  !   cmp r12, 8
  !   jbe array_case_low
  !   jmp array_case_up
  
  ; ---------------------------------------------------------------------------------
  ; case 0-7
  ; ---------------------------------------------------------------------------------
  ! array_case_low:
  !   cmp r12, 0
  !   je array_case_0
  
  !   cmp r12, 1
  !   je array_case_1
  
  !   cmp r12, 2
  !   je array_case_2
  
  !   cmp r12, 3
  !   je array_case_3
  
  !   cmp r12, 4
  !   je array_case_4
  
  !   cmp r12, 5
  !   je array_case_5
  
  !   cmp r12, 6
  !   je array_case_6
  
  !   cmp r12, 7
  !   je array_case_7
  
  ; ---------------------------------------------------------------------------------
  ; case 8-15
  ; ---------------------------------------------------------------------------------
  ! array_case_up:
  !   cmp r12, 8
  !   je array_case_8
  
  !   cmp r12, 9
  !   je array_case_9
  
  !   cmp r12, 10
  !   je array_case_10
  
  !   cmp r12, 11
  !   je array_case_11
  
  !   cmp r12, 12
  !   je array_case_12
  
  !   cmp r12, 13
  !   je array_case_13
  
  !   cmp r12, 14
  !   je array_case_14
  
  !   cmp r12, 15
  !   je array_case_15
  
  ; ---------------------------------------------------------------------------------
  ; cases
  ; ---------------------------------------------------------------------------------
  ! array_case_0:
  !   blendps xmm4, xmm5, 0                    ; vmin = boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 15                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_1:
  !   blendps xmm4, xmm5, 1                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 14                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_2:
  !   blendps xmm4, xmm5, 2                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 13                   ; vmax =  -boxx-p0x, boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_3:
  !   blendps xmm4, xmm5, 3                   ; vmin = -boxx-p0x, -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 12                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_4:
  !   blendps xmm4, xmm5, 4                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 11                  ; vmax = -boxx-p0x, -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_5:
  !   blendps xmm4, xmm5, 5                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 10                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_6:
  !   blendps xmm4, xmm5, 6                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 9                   ; vmax = -boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_7:
  !   blendps xmm4, xmm5, 7                   ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 8                   ; vmax = boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_8:
  !   blendps xmm4, xmm5, 8                   ; vmin = boxx-p0x, boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 7                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_9:
  !   blendps xmm4, xmm5, 9                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 6                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_10:
  !   blendps xmm4, xmm5, 10                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 5                   ; vmax =  -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_11:
  !   blendps xmm4, xmm5, 11                   ; vmin =-boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 4                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_12:
  !   blendps xmm4, xmm5, 12                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 3                   ; vmax =  -boxx-p0x, -boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_13:
  !   blendps xmm4, xmm5, 13                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 2                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_14:
  !   blendps xmm4, xmm5, 14                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 1                   ; vmax =  -boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_case_15:
  !   blendps xmm4, xmm5, 15                  ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 0                   ; vmax = boxx-p0x, boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp array_label_cool
  
  ! array_label_cool:
  !   mov rax, [p.p_result]
  !   movups [rax], xmm4
  Debug StrF(*result\x)+", "+StrF(*result\y)+", "+StrF(*result\z)+", "+StrF(*result\_w)
EndProcedure

Define box.Geometry::Box_t
Vector3::Set(box\extend,2,4,1)

Define a.v3f32, b.v3f32, c.v3f32
Define result.v3f32
Vector3::Set(a,Random(50)-25, Random(50)-25, Random(50)-25)
Vector3::ScaleInPlace(a, 0.1)
Vector3::Set(b,Random(50)-25, Random(50)-25, Random(50)-25)
Vector3::ScaleInPlace(b, 0.1)
Vector3::Set(c,Random(50)-25, Random(50)-25, Random(50)-25)
Vector3::ScaleInPlace(c, 0.1)

WithAdd(box, a, b, c, result)
WithMask(box, a, b, c, result)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 44
; Folding = -
; EnableXP