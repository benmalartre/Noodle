Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure test(*v.v3f32, mask.b)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! mulps xmm0, xmm0
  
  ! shufps xmm0, xmm0, 0
  ! movups [rax], xmm0
EndProcedure

Procedure Test2(nb.i)
  Define cnt.i = 0
  Define a.i = 666
  Define b.i = 255
  
  ! mov rcx, [p.v_nb]
  ! label_loop:
  ! cmp rcx, 2
  ! jne label_incr
  ! je label_elevator
  
  !   jne label_incr
  !   jmp label_elevator
  
  ! label_incr:
  !   inc word[p.v_cnt]
  ! jmp label_elevator
  
  ! label_elevator:
  !   dec rcx
  !   jnz label_loop
  ProcedureReturn cnt
EndProcedure


Define v.v3f32
v\x = 1
v\y = 2
v\z = 3

test(v, %01010101)

Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)



Debug Test2(666)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP