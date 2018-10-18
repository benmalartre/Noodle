Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_negate_value:
  Data.f -1
  sse_one_value:
  Data.f 1
  
EndDataSection



Procedure ConvertBitMaskToNegateMask(*a.v3f32, *b.v3f32)
  ! mov rax, [p.p_a]
  ! mov rcx, [p.p_b]
  ! movups xmm0, [rax]
  ! movups xmm1, [rcx]
  ! movaps xmm2, xmm0
  
  ! cmpps xmm2, xmm1, 4
  ! movmskps r8, xmm2
  ! blendps xmm0, xmm1, 1
  ! movups [rax], xmm0
EndProcedure


Define a.v3f32, b.v3f32
a\x= 1
a\y = 2
a\z = 3
b\x = -1
b\y = -2
b\z = -3

ConvertBitMaskToNegateMask(a, b)

Debug StrF(a\x)+","+StrF(a\y)+","+StrF(a\z)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 26
; Folding = -
; EnableXP