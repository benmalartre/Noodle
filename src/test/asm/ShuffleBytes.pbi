Structure Pixel_t
  r.a
  g.a
  b.a
  a.a
EndStructure

Structure Mask_t
  b.a[16]
EndStructure

Procedure SwapRedAndBlue(*pixels, *mask.Mask_t)
  ! mov rax, [p.p_pixels]
  ! mov rcx, [p.p_mask]
  ! movups xmm0, [rax]
  ! movups xmm1, [rcx]
  ! pshufb xmm0, xmm1
  ! movups [rax], xmm0
  
;   ! mov rax, [p.p_q]
;   ! movups xmm0, [rax]
;   ! andps xmm0, 0
;   ! movups [rax], xmm0
EndProcedure

Define pixel.Pixel_t
Define mask.Mask_t

Debug SizeOf(pixel)
Debug SizeOf(mask)

DataSection
  swap_red_blue_mask:
  Data.a 0,3,2,1,4,7,5,6,8,11,10,9,12,15,14,13
EndDataSection

For i = 0 To 15
  mask\b[i] = 255
Next
Dim pixels.Pixel_t(4)
For i=0 To 3
  pixels(i)\r = 1 + i * 5
  pixels(i)\g = 2 + i * 5
  pixels(i)\b = 3 + i * 5
  pixels(i)\a = 4 + i * 5
Next


Debug "PIXEL : ("+StrF(pixels(0)\r)+","+StrF(pixels(0)\g)+","+StrF(pixels(0)\b)+","+StrF(pixels(0)\a)+")"
Debug "PIXEL : ("+StrF(pixels(1)\r)+","+StrF(pixels(1)\g)+","+StrF(pixels(1)\b)+","+StrF(pixels(1)\a)+")"
Debug "PIXEL : ("+StrF(pixels(2)\r)+","+StrF(pixels(2)\g)+","+StrF(pixels(2)\b)+","+StrF(pixels(2)\a)+")"
Debug "PIXEL : ("+StrF(pixels(3)\r)+","+StrF(pixels(3)\g)+","+StrF(pixels(3)\b)+","+StrF(pixels(3)\a)+")"
Debug "-------------------------------------------------------------------------------------------------"
SwapRedAndBlue(@pixels(0), ?swap_red_blue_mask)
Debug "PIXEL : ("+StrF(pixels(0)\r)+","+StrF(pixels(0)\g)+","+StrF(pixels(0)\b)+","+StrF(pixels(0)\a)+")"
Debug "PIXEL : ("+StrF(pixels(1)\r)+","+StrF(pixels(1)\g)+","+StrF(pixels(1)\b)+","+StrF(pixels(1)\a)+")"
Debug "PIXEL : ("+StrF(pixels(2)\r)+","+StrF(pixels(2)\g)+","+StrF(pixels(2)\b)+","+StrF(pixels(2)\a)+")"
Debug "PIXEL : ("+StrF(pixels(3)\r)+","+StrF(pixels(3)\g)+","+StrF(pixels(3)\b)+","+StrF(pixels(3)\a)+")"

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 17
; Folding = -
; EnableXP