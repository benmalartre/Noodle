; ! edge0_axis1:
;   !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
;   !   shufps xmm2, xmm2, 00001010b        ; e0z e0z e0x e0x
;   
;   !   movups  xmm6, [r10]                 ; load 1100 sign bit mask is stored in r9
;   !   mulps xmm2, xmm6                    ; -e0z -e0z e0x e0x
; 
;   !   movups xmm3, xmm13                  ; copy p0 to xmm3
;   !   movups xmm4, xmm15                  ; copy p2 to xmm4
; 
;   !   shufps xmm3, xmm4, 10001000b        ; p0x p0z p2x p2z
;   !   shufps xmm3, xmm3, 11011000b        ; p0x p2x p0z p2z
;   
;   !   jmp axis_test_add


DataSection
  negate_mask:
  Data.f  -1,-1,1,1
EndDataSection

Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure Test(*v.v3f32, *a.v3f32, *b.v3f32)
  ! mov rax, [p.p_v]
  ! mov rcx, [p.p_a]
  ! mov rdx, [p.p_b]
  ! mov r10, l_negate_mask
  ! movups xmm0, [rax]
  ! movups xmm3, [rcx]
  ! movups xmm4, [rdx]
  ! movaps xmm2, xmm0                   ; make a copy 
  ! shufps xmm2, xmm2, 00001010b        ; e0z e0z e0x e0x
  
  ! movups  xmm6, [r10]                 ; load 1100 sign bit mask is stored in r9
  ! mulps xmm2, xmm6                    ; -e0z -e0z e0x e0x
  
  !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
  !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
  
  ! movups [rax], xmm3
EndProcedure

Procedure Minimum(*v.v3f32, *a.v3f32, *b.v3f32)
  ! mov rax, [p.p_v]
  ! mov rcx, [p.p_a]
  ! mov rdx, [p.p_b]
  
  ! movups xmm0, [rcx]
  ! movups xmm1, [rdx]
  ! minps xmm0, xmm1
  
  ! movups [rax], xmm0
EndProcedure



Define v.v3f32, a.v3f32, b.v3f32

v\x = 1
v\y = -3
v\z = 3

a\x =-5
a\y = 2
a\z = -5

b\x = 0.333
b\y = -2
b\z = -24

Minimum(v, a, b)

Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 74
; FirstLine = 20
; Folding = -
; EnableXP