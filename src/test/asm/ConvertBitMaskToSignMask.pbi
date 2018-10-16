Structure v3f32
  x.f
  y.f
  z.f
  w.f
EndStructure

DataSection
  sse_negate_mask:
  Data.f -1
EndDataSection

Procedure ConvertBitMaskToNegateMask(bitMask.c, *mask.v3f32)
  
  Define _x.c
  ! mov rax, [p.v_bitMask]
  ! mov r8, [p.v__x]
  
  ! xor rcx, rcx
  ! add rcx, 16
  
  ! loop_mask:
  !   mov rax, [p.v_bitMask]
  !   and rax, rcx
  
  ! mov [p.v__x], rax
  
  
  !   dec rcx
  !   jnz loop_mask
  

  
EndProcedure


Define mask.v3f32
ConvertBitMaskToNegateMask(%0100, *mask.v3f32)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 20
; Folding = -
; EnableXP