; =============================================================================
; MIN MAX MODULE DECLARATION
; =============================================================================
; module by Wilbert To get the minimum And maximum values of an Array
; https://www.purebasic.fr/english/viewtopic.php?f=12&t=70838
; =============================================================================

DeclareModule MinMax
  
  Structure Float_x2 : f.f[2] : EndStructure
  Structure Word_x2  : w.w[2] : EndStructure
  Structure Ascii_x4 : a.a[4] : EndStructure
  
  Declare MinMaxD(*Array.Double, Count, *Min.Double, *Max.Double)
  Declare MinMaxF(*Array.Float, Count, *Min.Float, *Max.Float)
  Declare MinMaxQ(*Array.Quad, Count, *Min.Quad, *Max.Quad)
  Declare MinMaxI(*Array.Integer, Count, *Min.Integer, *Max.Integer)
  Declare MinMaxL(*Array.Long, Count, *Min.Long, *Max.Long)
  Declare MinMaxW(*Array.Word, Count, *Min.Word, *Max.Word)
  Declare MinMaxU(*Array.Unicode, Count, *Min.Unicode, *Max.Unicode)
  Declare MinMaxB(*Array.Byte, Count, *Min.Byte, *Max.Byte)
  Declare MinMaxA(*Array.Ascii, Count, *Min.Ascii, *Max.Ascii)
  
  Declare MinMaxF2(*Array.Float_x2, Count, *Min.Float_x2, *Max.Float_x2)
  Declare MinMaxW2(*Array.Word_x2, Count, *Min.Word_x2, *Max.Word_x2)
  Declare MinMaxA4(*Array.Ascii_x4, Count, *Min.Ascii_x4, *Max.Ascii_x4)
  
EndDeclareModule

Module MinMax
  
  EnableExplicit
  DisableDebugger
  EnableASM
  
  ; *** SSE2 check for 32 bit mode ***
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    Global.l _NoSSE2_
    Procedure SSE2_Check()
      Protected.l NoSSE2
      !mov eax, 1
      !push ebx
      !cpuid
      !pop ebx
      !test edx, 0x04000000
      !setz [p.v_NoSSE2]
      _NoSSE2_ = NoSSE2
    EndProcedure
    SSE2_Check()
  CompilerEndIf    
        
  Macro M_SSE2_Check()
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      Protected.l NoSSE2 = _NoSSE2_
      !test dword [p.v_NoSSE2], 1
      !jnz .pb  
    CompilerEndIf
  EndMacro
    
  ; *** General PB Fallback code ***
  
  Macro M_MinMaxPB(type)
    If Count : Count - 1
      *Min\type = *Array\type: *Max\type = *Array\type
      While Count : Count - 1 : *Array + SizeOf(*Array\type)
        If *Array\type < *Min\type : *Min\type = *Array\type
          ElseIf *Array\type > *Max\type : *Max\type = *Array\type : EndIf
      Wend
    EndIf  
  EndMacro
  
  ; *** Some additional macros ***
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    Macro rcx : ecx : EndMacro
    Macro rdx : edx : EndMacro
  CompilerEndIf
  
  Macro M_(opcode, arg1, arg2)
    !opcode arg1, arg2
  EndMacro
  
  ; *** Implementation of declared procedures ***
  
  Procedure MinMaxD(*Array.Double, Count, *Min.Double, *Max.Double)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 2
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movupd, xmm0, [rdx + rcx*8 - 16])
    !movapd xmm1, xmm0
    !and ecx, -2
    !jz .l1
    ; main loop
    !.l0:
    M_(movupd, xmm2, [rdx])
    add rdx, 16
    !minpd xmm0, xmm2
    !maxpd xmm1, xmm2
    !sub ecx, 2
    !jnz .l0
    !.l1:
    ; combine 2 into 1
    !movhlps xmm2, xmm0
    !movhlps xmm3, xmm1
    !minsd xmm0, xmm2
    !maxsd xmm1, xmm3
    mov rdx, [p.p_Min]
    M_(movsd, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movsd, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    If Count
      *Min\d = *Array\d : *Max\d = *Array\d
    EndIf    
  EndProcedure
  
  Procedure MinMaxF(*Array.Float, Count, *Min.Float, *Max.Float)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 4
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movups, xmm0, [rdx + rcx*4 - 16])
    !movaps xmm1, xmm0
    !and ecx, -4
    !jz .l1
    ; main loop
    !.l0:
    M_(movups, xmm2, [rdx])
    add rdx, 16
    !minps xmm0, xmm2
    !maxps xmm1, xmm2
    !sub ecx, 4
    !jnz .l0
    !.l1:
    ; combine 4 into 2
    !movhlps xmm2, xmm0
    !movhlps xmm3, xmm1
    !minps xmm0, xmm2
    !maxps xmm1, xmm3
    ; combine 2 into 1
    !movaps xmm2, xmm0
    !movaps xmm3, xmm1
    !shufps xmm2, xmm2, 1
    !shufps xmm3, xmm3, 1
    !minss xmm0, xmm2
    !maxss xmm1, xmm3
    mov rdx, [p.p_Min]
    M_(movss, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movss, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    M_MinMaxPB(f)
  EndProcedure
  
  Procedure MinMaxQ(*Array.Quad, Count, *Min.Quad, *Max.Quad)
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      !mov ecx, [p.v_Count]
      !cmp ecx, 0
      !je .l4    
      !mov rdx, [p.p_Array]
      !mov r8, [rdx]
      !add rdx, 8
      !mov r9, r8
      !sub ecx, 1
      !jz .l3
      !.l0:
      !mov rax, [rdx]
      !add rdx, 8
      !cmp rax, r8
      !jge .l1
      !mov r8, rax
      !jmp .l2
      !.l1:
      !cmp rax, r9
      !jle .l2
      !mov r9, rax
      !.l2:
      !sub ecx, 1
      !jnz .l0
      !.l3:
      !mov rdx, [p.p_Min]
      !mov [rdx], r8
      !mov rdx, [p.p_Max]
      !mov [rdx], r9
      !.l4:
    CompilerElse
      M_MinMaxPB(q)
    CompilerEndIf
  EndProcedure    
  
  Procedure MinMaxI(*Array.Integer, Count, *Min.Integer, *Max.Integer)
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      MinMaxQ(*Array, Count, *Min, *Max)
    CompilerElse
      MinMaxL(*Array, Count, *Min, *Max)
    CompilerEndIf
  EndProcedure    
  
  Procedure MinMaxL(*Array.Long, Count, *Min.Long, *Max.Long)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 4
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx*4 - 16])
    !movdqa xmm1, xmm0
    !and ecx, -4
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !movdqa xmm4, xmm2
    !movdqa xmm5, xmm1
    !pcmpgtd xmm4, xmm0
    !pcmpgtd xmm5, xmm2
    !pand xmm0, xmm4
    !pand xmm1, xmm5
    !pandn xmm4, xmm2
    !pandn xmm5, xmm2
    !por xmm0, xmm4
    !por xmm1, xmm5
    !sub ecx, 4
    !jnz .l0
    !.l1:
    ; combine 4 into 2
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !movdqa xmm4, xmm2
    !movdqa xmm5, xmm1
    !pcmpgtd xmm4, xmm0
    !pcmpgtd xmm5, xmm3
    !pand xmm0, xmm4
    !pand xmm1, xmm5
    !pandn xmm4, xmm2
    !pandn xmm5, xmm3
    !por xmm0, xmm4
    !por xmm1, xmm5
    ; combine 2 into 1
    !pshufd xmm2, xmm0, 1
    !pshufd xmm3, xmm1, 1
    !movdqa xmm4, xmm2
    !movdqa xmm5, xmm1
    !pcmpgtd xmm4, xmm0
    !pcmpgtd xmm5, xmm3
    !pand xmm0, xmm4
    !pand xmm1, xmm5
    !pandn xmm4, xmm2
    !pandn xmm5, xmm3
    !por xmm0, xmm4
    !por xmm1, xmm5
    mov rdx, [p.p_Min]
    M_(movd, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movd, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    M_MinMaxPB(l)
  EndProcedure
  
  Procedure MinMaxW(*Array.Word, Count, *Min.Word, *Max.Word)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 8
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx*2 - 16])
    !movdqa xmm1, xmm0
    !and ecx, -8
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm2
    !sub ecx, 8
    !jnz .l0
    !.l1:
    ; combine 8 into 4
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    ; combine 4 into 2
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    ; combine 2 into 1
    !pshuflw xmm2, xmm0, 1
    !pshuflw xmm3, xmm1, 1
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    !movd eax, xmm0
    !movd ecx, xmm1
    mov rdx, [p.p_Min]
    mov [rdx], ax
    mov rdx, [p.p_Max]
    mov [rdx], cx
    ProcedureReturn
    !.pb:
    M_MinMaxPB(w)
  EndProcedure
  
  Procedure MinMaxU(*Array.Unicode, Count, *Min.Unicode, *Max.Unicode)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 8
    !jb .pb
    !pcmpeqw xmm4, xmm4
    !psllw xmm4, 15
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx*2 - 16])
    !pxor xmm0, xmm4
    !movdqa xmm1, xmm0
    !and ecx, -8
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pxor xmm2, xmm4
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm2
    !sub ecx, 8
    !jnz .l0
    !.l1:
    ; combine 8 into 4
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    ; combine 4 into 2
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    ; combine 2 into 1
    !pshuflw xmm2, xmm0, 1
    !pshuflw xmm3, xmm1, 1
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    !movd eax, xmm0
    !movd ecx, xmm1
    !xor eax, 0x8000
    !xor ecx, 0x8000
    mov rdx, [p.p_Min]
    mov [rdx], ax
    mov rdx, [p.p_Max]
    mov [rdx], cx
    ProcedureReturn
    !.pb:
    M_MinMaxPB(u)    
  EndProcedure
  
  Procedure MinMaxB(*Array.Byte, Count, *Min.Byte, *Max.Byte)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 16
    !jb .pb
    !pcmpeqw xmm4, xmm4
    !psllw xmm4, 15
    !packsswb xmm4, xmm4
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx - 16])
    !pxor xmm0, xmm4  
    !movdqa xmm1, xmm0
    !and ecx, -16
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pxor xmm2, xmm4
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm2
    !sub ecx, 16
    !jnz .l0
    !.l1:
    ; combine 16 into 8
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 8 into 4
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 4 into 2
    !pshuflw xmm2, xmm0, 1
    !pshuflw xmm3, xmm1, 1
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 2 into 1
    !movdqa xmm2, xmm0
    !movdqa xmm3, xmm1
    !psrlw xmm2, 8
    !psrlw xmm3, 8
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    !movd eax, xmm0
    !movd ecx, xmm1
    !xor eax, 0x80
    !xor ecx, 0x80
    mov rdx, [p.p_Min]
    mov [rdx], al
    mov rdx, [p.p_Max]
    mov [rdx], cl
    ProcedureReturn
    !.pb:
    M_MinMaxPB(b)    
  EndProcedure
  
  Procedure MinMaxA(*Array.Ascii, Count, *Min.Ascii, *Max.Ascii)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 16
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx - 16])
    !movdqa xmm1, xmm0
    !and ecx, -16
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm2
    !sub ecx, 16
    !jnz .l0
    !.l1:
    ; combine 16 into 8
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 8 into 4
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 4 into 2
    !pshuflw xmm2, xmm0, 1
    !pshuflw xmm3, xmm1, 1
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 2 into 1
    !movdqa xmm2, xmm0
    !movdqa xmm3, xmm1
    !psrlw xmm2, 8
    !psrlw xmm3, 8
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    !movd eax, xmm0
    !movd ecx, xmm1
    mov rdx, [p.p_Min]
    mov [rdx], al
    mov rdx, [p.p_Max]
    mov [rdx], cl
    ProcedureReturn
    !.pb:
    M_MinMaxPB(a)
  EndProcedure
  
  Procedure MinMaxF2(*Array.Float_x2, Count, *Min.Float_x2, *Max.Float_x2)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 2
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movups, xmm0, [rdx + rcx*8 - 16])
    !movaps xmm1, xmm0
    !and ecx, -2
    !jz .l1
    ; main loop
    !.l0:
    M_(movups, xmm2, [rdx])
    add rdx, 16
    !minps xmm0, xmm2
    !maxps xmm1, xmm2
    !sub ecx, 2
    !jnz .l0
    !.l1:
    ; combine 2 into 1
    !movhlps xmm2, xmm0
    !movhlps xmm3, xmm1
    !minps xmm0, xmm2
    !maxps xmm1, xmm3
    mov rdx, [p.p_Min]
    M_(movlps, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movlps, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    If Count
      *Min\f[0] = *Array\f[0] : *Max\f[0] = *Array\f[0]
      *Min\f[1] = *Array\f[1] : *Max\f[1] = *Array\f[1]
    EndIf
  EndProcedure
  
  Procedure MinMaxW2(*Array.Word_x2, Count, *Min.Word_x2, *Max.Word_x2)
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 4
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx*4 - 16])
    !movdqa xmm1, xmm0
    !and ecx, -4
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm2
    !sub ecx, 4
    !jnz .l0
    !.l1:
    ; combine 4 into 2
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    ; combine 2 into 1
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminsw xmm0, xmm2
    !pmaxsw xmm1, xmm3
    mov rdx, [p.p_Min]
    M_(movd, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movd, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    If Count : Count - 1
      *Min\w[0] = *Array\w[0] : *Max\w[0] = *Array\w[0]
      *Min\w[1] = *Array\w[1] : *Max\w[1] = *Array\w[1]
      While Count : Count - 1 : *Array + 4
        If *Array\w[0] < *Min\w[0] : *Min\w[0] = *Array\w[0]
          ElseIf *Array\w[0] > *Max\w[0] : *Max\w[0] = *Array\w[0] : EndIf
        If *Array\w[1] < *Min\w[1] : *Min\w[1] = *Array\w[1]
          ElseIf *Array\w[1] > *Max\w[1] : *Max\w[1] = *Array\w[1] : EndIf
      Wend
    EndIf  
  EndProcedure
  
  Procedure MinMaxA4(*Array.Ascii_x4, Count, *Min.Ascii_x4, *Max.Ascii_x4)  
    M_SSE2_Check()
    !mov ecx, [p.v_Count]
    !cmp ecx, 4
    !jb .pb
    mov rdx, [p.p_Array]
    M_(movdqu, xmm0, [rdx + rcx*4 - 16])
    !movdqa xmm1, xmm0
    !and ecx, -4
    !jz .l1
    ; main loop
    !.l0:
    M_(movdqu, xmm2, [rdx])
    add rdx, 16
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm2
    !sub ecx, 4
    !jnz .l0
    !.l1:
    ; combine 4 into 2
    !pshufd xmm2, xmm0, 1110b
    !pshufd xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    ; combine 2 into 1
    !pshuflw xmm2, xmm0, 1110b
    !pshuflw xmm3, xmm1, 1110b
    !pminub xmm0, xmm2
    !pmaxub xmm1, xmm3
    mov rdx, [p.p_Min]
    M_(movd, [rdx], xmm0)
    mov rdx, [p.p_Max]
    M_(movd, [rdx], xmm1)
    ProcedureReturn
    !.pb:
    If Count : Count - 1
      *Min\a[0] = *Array\a[0] : *Max\a[0] = *Array\a[0]
      *Min\a[1] = *Array\a[1] : *Max\a[1] = *Array\a[1]
      *Min\a[2] = *Array\a[2] : *Max\a[2] = *Array\a[2]
      *Min\a[3] = *Array\a[3] : *Max\a[3] = *Array\a[3]
      While Count : Count - 1 : *Array + 4
        If *Array\a[0] < *Min\a[0] : *Min\a[0] = *Array\a[0]
          ElseIf *Array\a[0] > *Max\a[0] : *Max\a[0] = *Array\a[0] : EndIf
        If *Array\a[1] < *Min\a[1] : *Min\a[1] = *Array\a[1]
          ElseIf *Array\a[1] > *Max\a[1] : *Max\a[1] = *Array\a[1] : EndIf
        If *Array\a[2] < *Min\a[2] : *Min\a[2] = *Array\a[2]
          ElseIf *Array\a[2] > *Max\a[2] : *Max\a[2] = *Array\a[2] : EndIf
        If *Array\a[3] < *Min\a[3] : *Min\a[3] = *Array\a[3]
          ElseIf *Array\a[3] > *Max\a[3] : *Max\a[3] = *Array\a[3] : EndIf
      Wend
    EndIf      
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 583
; FirstLine = 513
; Folding = -----
; EnableXP