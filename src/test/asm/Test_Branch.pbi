

Procedure.i Test()
  Define v.i

  ! xor rsi, rsi
  ! mov rcx, 4
  ! mov rdi, [p.v_v]
  
  ! l_loop:
  !   cmp rsi, 3
  !   jl edge0
  
  !   cmp rsi, 6
  !   jl edge1
  
  !   cmp rsi, 9
  !   jl edge2
  
  !   xor rsi, rsi          ; rest edge counter
  !   dec rcx
  !   jnz l_loop
 
  ! jmp exit
  
  ; edge0
  ;-----------------------------------------
  ! next_triangle:
  
  ; edge0
  ;-----------------------------------------
  ! edge0:
  !   add rsi, 1
  !   add rdi, 1
  !   jmp l_loop
  
  ; edge1
  ;-----------------------------------------
  ! edge1:
  !   add rsi, 1
  !   add rdi, 1
  !   jmp l_loop
  
  ; edge2
  ;-----------------------------------------
  ! edge2:
  !   add rsi, 1
  !   add rdi, 1
  !   jmp l_loop
  
  ; exit
  ;-----------------------------------------
  ! exit:
  !   mov [p.v_v], rdi
    ProcedureReturn v
EndProcedure

Debug Test()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 6
; Folding = -
; EnableXP