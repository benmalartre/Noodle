

Structure Vector3
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure ShuffleVector(*v.Vector3)
  ! mov rdi, qword [p.p_v]
  ! movups xmm0, [rdi]
;   ! movaps xmm1, [rdi]
  ! shufps xmm0, xmm0, 0x1B
  ! movups [rdi], xmm0
EndProcedure

Define v.Vector3
v\x = 6.666
v\y = 5.432
v\z = 3.213
v\w = 65439

Debug StrF(v\x)+", "+StrF(v\y)+", "+StrF(v\z)+", "+StrF(v\w)
ShuffleVector(@v)

Debug StrF(v\x)+", "+StrF(v\y)+", "+StrF(v\z)+", "+StrF(v\w)
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 23
; Folding = -
; EnableXP