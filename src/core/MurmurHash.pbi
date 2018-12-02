; **********************************************
; * MurmurHash3 was written by Austin Appleby, *
; * and is placed in the public domain.        *
; * The author disclaims copyright to this     *
; * source code.                               *
; *                                            *
; * PureBasic conversion by Wilbert            *
; * Last update : 2012/02/29                   *
; **********************************************
DeclareModule MurmurHash
  Declare.l Compute(key, len.l, seed.l = 0)
EndDeclareModule

Module MurmurHash
    
  Procedure.l Compute(key, len.l, seed.l = 0)
    !mov eax, [p.v_seed]
    !mov ecx, [p.v_len]
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !mov edx, [p.v_key]
      !push ebx
      !push ecx
    CompilerElse
      !mov rdx, [p.v_key]
      !push rbx
      !push rcx
    CompilerEndIf
    !mov ebx, eax
    !sub ecx, 4
    !js mh3_tail
    ; body
    !mh3_body_loop:
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !mov eax, [edx]
      !add edx, 4
    CompilerElse
      !mov eax, [rdx]
      !add rdx, 4
    CompilerEndIf
    !imul eax, 0xcc9e2d51
    !rol eax, 15
    !imul eax, 0x1b873593
    !xor ebx, eax
    !rol ebx, 13
    !imul ebx, 5
    !add ebx, 0xe6546b64
    !sub ecx, 4
    !jns mh3_body_loop
    ; tail
    !mh3_tail:
    !xor eax, eax
    !add ecx, 3
    !js mh3_finalize
    !jz mh3_t1
    !dec ecx
    !jz mh3_t2
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !mov al, [edx + 2]
      !shl eax, 16
      !mh3_t2: mov ah, [edx + 1]
      !mh3_t1: mov al, [edx]
    CompilerElse
      !mov al, [rdx + 2]
      !shl eax, 16
      !mh3_t2: mov ah, [rdx + 1]
      !mh3_t1: mov al, [rdx]
    CompilerEndIf
    !imul eax, 0xcc9e2d51
    !rol eax, 15
    !imul eax, 0x1b873593
    !xor ebx, eax
    ; finalization
    !mh3_finalize:
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !pop ecx
    CompilerElse
      !pop rcx
    CompilerEndIf
    !xor ebx, ecx
    !mov eax, ebx
    !shr ebx, 16
    !xor eax, ebx
    !imul eax, 0x85ebca6b
    !mov ebx, eax
    !shr ebx, 13
    !xor eax, ebx
    !imul eax, 0xc2b2ae35
    !mov ebx, eax
    !shr ebx, 16
    !xor eax, ebx
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      !pop ebx
    CompilerElse
      !pop rbx  
    CompilerEndIf
    ProcedureReturn
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; Folding = --
; EnableXP