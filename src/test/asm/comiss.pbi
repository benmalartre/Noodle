Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure SwapAB(*a.v3f32, *b.v3f32)
  ! mov rax, [p.p_a]
  ! mov rcx, [p.p_b]
  
  ! movups xmm0, [rax]
  ! movups xmm1, [rcx]
  ! movaps xmm2, xmm1
  
  ! shufps xmm1, xmm0, 01000100b
  ! shufps xmm0, xmm2, 11101110b
  ! movups [rax], xmm0
  ! movups [rcx], xmm1
  Debug StrF(*a\x)+","+StrF(*a\y)+","+StrF(*a\z)+","+StrF(*a\w)
  Debug StrF(*b\x)+","+StrF(*b\y)+","+StrF(*b\z)+","+StrF(*b\w)
EndProcedure


Procedure SwapT(*a.v3f32)
  Define mask.i

  ! mov rax, [p.p_a]
  ! movups xmm0, [rax]
  ! movaps xmm1, xmm0
  ! psrldq xmm1 , 4
  
  ! ucomiss xmm0, xmm1
  ! jb lower
  ! jg greater
  ! jmp equal
  
  ! lower:
  Debug "LOWER"
  !   jmp exit
  
  ! greater:
  !   shufps xmm0, xmm0, 11100001b
  !   movups [rax], xmm0
  Debug "GREATER"
  ! jmp exit
  
  ! equal:
  Debug "EQUAL"
  ! jmp exit
  
  ! exit:
  Debug StrF(*a\x)+","+StrF(*a\y)+","+StrF(*a\z)+","+StrF(*a\w)
  Debug "MASK : "+Str(mask)
  ProcedureReturn

EndProcedure

Define a.v3f32, b.v3f32

a\x = 1
a\y = 2
a\z = 3
a\w = 4

b\x = 5
b\y = 6
b\z = 7
b\w = 8

SwapAB(a, b)

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 20
; Folding = -
; EnableXP