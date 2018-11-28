Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_0000_value:
  Data.f 0,0,0,0
  sse_1111_value:
  Data.f 1,1,1,1
EndDataSection


Procedure Test(*a.v3f32, min.f, max.f)
  Define result.i
  ! mov rsi, [p.p_a]
  ! movups xmm0, [rsi]
  ! movups xmm1, [l_sse_0000_value]
  ! movss xmm2, [p.v_min]
  ! movss xmm3, [p.v_max]
  ! xor r9, r9
  ! cmpps xmm0, xmm1, 1             ; packed compare (a b c d) < (0,0,0,0)
  ! movmskps r12, xmm0              ; move comparison mask to r12 register
  
  ! test_first_bit:
  !   test r12, 1
  !   jz test_second_bit
  !   call bit_one_set
  
  ! test_second_bit:
  !   test r12, 2
  !   jz test_third_bit
  !   call bit_two_set
  
  ! test_third_bit:
  !   test r12, 4
  !   jz output_test
  !   call bit_three_set
  
  ! output_test:
  !   mov [p.v_result], r9
  ProcedureReturn result
  
  ! bit_one_set:
  !   bts r9, 0
  !   ret
  
  ! bit_two_set:
  !   bts r9, 1
  !   ret
  
  ! bit_three_set:
  !   bts r9, 2
  !   ret
  
  
EndProcedure


Procedure Test2(*a.v3f32)
  
  ! mov rdi, [p.p_a]
  ! movups xmm1, [rdi]
  ! call clamp_xmm1_0_to_1
  ! movups [rdi], xmm1
  ProcedureReturn 
  
  
  ; clamp function
  ! clamp_xmm1_0_to_1:
  !   movups xmm2, [l_sse_0000_value]
  !   movups xmm3, [l_sse_1111_value]
  !   comiss xmm2, xmm1
  !   jb greater_than_zero
  !   call clamp_xmm1_to_0
  
  ! greater_than_zero:
  !   comiss xmm1, xmm3
  !   jbe lower_than_one
  !   call clamp_xmm1_to_1
  
  ! lower_than_one:
  !   movups [rdi], xmm1
  !   ret
  
  ! clamp_xmm1_to_0:
  !   movss xmm1, xmm2
  !   ret
  
  ! clamp_xmm1_to_1:
  !   movss xmm1, xmm3
  !   ret
EndProcedure



Define a.v3f32
a\x = 1.1
a\y = 0.01
a\z = -0.01

; Debug Bin(Test(a, 0, 1))

Test2(a)

Debug StrF(a\x)+","+StrF(a\y)+","+StrF(a\z)+","+StrF(a\w)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 88
; FirstLine = 50
; Folding = -
; EnableXP