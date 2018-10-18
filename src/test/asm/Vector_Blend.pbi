XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"

UseModule Math


Procedure Reset(*v.v3f32)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! xorps xmm0, xmm0
  ! movups [rax], xmm0
EndProcedure

Procedure Blend(*a.v3f32, *b.v3f32)
  ! mov rax, [p.p_a]
  ! mov rcx, [p.p_b]
  ! movups xmm0, [rax]
  ! movups xmm1, [rcx]
  ! movaps xmm2, xmm0
  ! cmpps xmm2, xmm1 , 1            ; check a < b
  ! movmskps r12, xmm6
  
  ! blendps xmm0, xmm1, 2
  ! movups [rax], xmm0
EndProcedure

   

Define v.v3f32
v\x = 1
v\y = 6.6
v\z = 2.8

Define o.v3f32
o\x = 666
o\y = -1
o\z = 6.21

Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)
; Reset(v)
; Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)
Blend(v,o)
Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 19
; Folding = -
; EnableXP