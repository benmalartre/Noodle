Structure q4f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection

Procedure ChangeSign(*q.q4f32, bits.c)
  ! mov rax, [p.p_q]
  ! movups xmm0, [rax]
  ! andps xmm0, 0
  ! movups [rax], xmm0
EndProcedure

Macro Echo(_q)
  Debug StrF(_q\x)+","+StrF(_q\y)+","+StrF(_q\z)+","+StrF(_q\w)
EndMacro


Define q.q4f32
q\x = 1 
q\y = 2
q\z = 3
q\w = 666

Echo(q)

ChangeSign(q, %0010)
Echo(q)



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP