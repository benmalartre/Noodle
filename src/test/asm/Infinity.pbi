Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  ! align 16 
  ! sse_1111_sign_mask:
  ! dd $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
  ! sse_1111_infinity_value:
  ! dd $7F800000, $7F800000, $7F800000, $7F800000
  ! sse_one_vec:
  ! dd 1.0, 1.0, 1.0, 1.0
EndDataSection

; DataSection
;   sse_1111_sign_mask:
;   Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
;   sse_1111_infinity_value:
;   Data.l $7F800000, $7F800000, $7F800000, $7F800000
;   sse_one_vec:
;   Data.f 1, 1, 1, 1
; EndDataSection


Procedure TestInfinity(*v.v3f32)
  Define mask.l
  ! mov rsi, [p.p_v]
  ! movups xmm0, [rsi]
  ! mulps xmm0, xmm0
  ! rsqrtps xmm0, xmm0
  ! movaps xmm1, xmm0
;   ! lea r9, [l_sse_1111_sign_mask]
;   ! movdqu  xmm1, [r9] 
;   ! andnps xmm0, xmm1
  
  
;   ! lea r10, [l_sse_1111_infinity_value]
;   ! movdqu xmm2, [r10]
    ! movaps xmm2, [sse_1111_infinity_value]

  ! cmpps xmm1, xmm2, 0
;   ! movmskps r12, xmm1
;   ! mov [p.v_mask], r12
;   
  ! xorps xmm0, xmm1
  ! movaps xmm3, [sse_one_vec]
  
;   ! andps xmm3, xmm1
;   ! addps xmm0, xmm3
  
  ! movups [rsi], xmm3
  
;   Debug Bin(mask)
;   
;   ! xor r11, r12
;   ! and r11, 15
;   ! mov [p.v_mask], r11
  Debug Bin(mask)
EndProcedure

Define v.v3f32
v\x = -1
v\y = 0
v\z = 3.333
TestInfinity(v)
Debug StrF(v\x)+","+StrF(v\y)+","+StrF(v\z)
; Debug Hex(PeekL(@v\x))+","+Hex(PeekL(@v\y))+","+Hex(PeekL(@v\z))
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 8
; FirstLine = 5
; Folding = -
; EnableXP