


Procedure.i ReverseBits(value.i)
 !MOV rax,[p.v_value]
 !MOV rdx,rax         ;Make a copy of the the data.
 !SHR rax,1           ;Move the even bits to odd positions.
 !AND rdx,0x55555555  ;Isolate the odd bits by clearing even bits.
 !AND rax,0x55555555  ;Isolate the even bits (in odd positions now).
 !SHL rdx,1           ;Move the odd bits to the even positions.
 !OR rax,rdx          ;Merge the bits and complete the swap.
 !MOV rdx,rax         ;Make a copy of the odd numbered bit pairs.
 !SHR rax,2           ;Move the even bit pairs to the odd positions.
 !AND rdx,0x33333333  ;Isolate the odd pairs by clearing even pairs.
 !AND rax,0x33333333  ;Isolate the even pairs (in odd positions now).
 !SHL rdx,2           ;Move the odd pairs to the even positions.
 !OR rax,rdx          ;Merge the bits and complete the swap.
 !MOV rdx,rax         ;Make a copy of the odd numbered nibbles.
 !SHR rax,4           ;Move the even nibbles to the odd position.
 !AND rdx,0x0f0f0f0f  ;Isolate the odd nibbles.
 !AND rax,0x0f0f0f0f  ;Isolate the even nibbles (in odd position now).
 !SHL rdx,4           ;Move the odd pairs to the even positions.
 !OR rax,rdx          ;Merge the bits and complete the Swap.
 !BSWAP rax           ;Swap the bytes and words.
 ProcedureReturn
EndProcedure


Procedure.i Endian(x.i)
  !MOV rax, [p.v_x]
  !BSWAP rax                  ; 32 bit little endian <-> big endian
  ProcedureReturn             ; eax is returned by default
EndProcedure

Define x.i= %10001000100010001
Debug Bin(x)
x = Endian(x)
Debug Bin(x)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 34
; Folding = -
; EnableXP