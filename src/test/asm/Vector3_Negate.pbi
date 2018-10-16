Procedure Test()
  Define v.i
  ! xor rax, rax
  ! add rax, 3
  ! cmp rax, 69
  ! jl sub_62
  ! jmp add_7
  
  ! exit:
  ! mov [p.v_v], rax
  ProcedureReturn v
  
  ! sub_62:
  ! sub rax, 62
  ! jmp exit
  
  ! add_7:
  ! add rax, 7
  ! jmp exit
EndProcedure

DataSection
  sse_1111_sign_mask:
  Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
  sse_1100_sign_mask:
  Data.l $FFFFFFFF, $FFFFFFFF, $7FFFFFFF, $7FFFFFFF
  sse_1111:
  Data.f 1,1,1,1
  sse_0000:
  Data.f 0,0,0,0
  sse_1111_negate_mask:
  Data.f -1, -1, -1, -1
  sse_1100_negate_mask:
  Data.l -1, -1, 1, 1
EndDataSection


Structure v3f32
  x.f
  y.f
  z.f
EndStructure

Procedure Negate2(*v.v3f32)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  
  ! mov rcx, l_sse_1111_sign_mask
  ! movups xmm1, [rcx]
  
  ! mulps xmm0, xmm1
  ! movups [rax], xmm0
EndProcedure


Procedure Negate(*v.v3f32)
  Define bitMask.a
  
  ! mov rcx, l_sse_1111_negate_mask
  ! movups xmm1, [rcx]
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! mulps xmm0, xmm1
  ! movups [rax], xmm0
  ProcedureReturn bitMask
EndProcedure




Define v.v3f32
v\x = -1
v\y = 3
v\z = -666

Debug StrF(v\x,3)+","+StrF(v\y,3)+","+StrF(v\z,3);+","+StrF(v\_unused,3)

Debug (Bin(Negate(v)))

Debug StrF(v\x,3)+","+StrF(v\y,3)+","+StrF(v\z,3);+","+StrF(v\_unused,3)

Debug (Bin(Negate(v)))

Debug StrF(v\x,3)+","+StrF(v\y,3)+","+StrF(v\z,3);+","+StrF(v\_unused,3)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 30
; FirstLine = 9
; Folding = -
; EnableXP