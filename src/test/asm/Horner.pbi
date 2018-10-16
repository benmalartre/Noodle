horner: movsd xmm1, xmm0 ; use xmm1 as x
movsd xmm0, [rdi+rsi*8] ; accumulator for b_k
test esi, 0 ; is the degree 0?
jz done
more: sub esi, 1
mulsd xmm0, xmm1 ; b_k * x
addsd xmm0, [rdi+rsi*8] ; add p_k
jnz more
done: ret
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 8
; EnableXP