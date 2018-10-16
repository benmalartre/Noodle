Procedure.i Randomize(*seed)
  ! mov rdx, [p.p_seed]
  ! imul rax, [rdx], 16807                    ;#A rax = RandSeed * 16807
  ! mov[rdx], rax
  ! mov al, 080h                          ;#2 rax: rrrrrr80h where r are bits from random seeds
  ! ror rax, 8                            ;#3 rax: 80rrrrrrh. value = s * 2^(e-127). e is set to 128, thus 040h value ( sEee eeee efff ffff ffff ffff ffff ffff)
  ! shr rax, 1                            ;#2 rax: 40rrrrrrh
  ! push rax                              ;#1 push rax on stack to load it as a float. rand [2,4]
  ! fld dword [esp]                       ;#3 load rand st0 = rand [2,4)
  ! push 3                                ;#2 load 3
  ! fisub dword [esp]                     ;#3 st(0) = rand [2,4] - 3 = rand[-1, 1]
  ! pop rax                               ;#1 free stack
  ! pop rax                               ;#1 free stack    
  ProcedureReturn  
  ;#1 return to caller
;       imul eax, dword ptr [RandSeed], 16807 ;#A eax = RandSeed * 16807
;       mov dword ptr [RandSeed], eax         ;#5 RandSeed = eax
;       fild dword ptr [RandSeed]             ;#6 load RandSeed as an integer
;       fidiv dword ptr [RandDiv]             ;#6 div by max int value (absolute) = eax / (-2^31)
EndProcedure



Procedure RandomizeSSE() 
! DQ1 equ 0 
! DQ2 equ 16 
! DQ3 equ 32 
! DQ4 equ 48 
! DQ5 equ 64 
! DQ6 equ 80 
! DQ7 equ 96 
! DQ8 equ 112 
;This function creates a random block of 64bytes 
;based on the 128 byte key. 
;The key structure is modified, so subsequent calls return different 
;random 64byte buffers 
;Return is void 
;IN: 
;Param1 rcx = address of Key struct 
;Param2 rdx = address of output buffer 64bytes 16byte ALIGNED 
! RandomBlock: 
!        mov    rax, rsp ;save stack ptr 
!        and    rsp, 0xFFFFFFFFFFFFFFF0 ; 16byte align 
!        sub    rsp, 16*9 
;save XMM8-15 
!        movdqa, xmm15 
!        movdqa, xmm14 
!        movdqa, xmm13 
!        movdqa, xmm12 
!        movdqa, xmm11 
!        movdqa, xmm10 
!        movdqa, xmm9 
!        movdqa, xmm8 
;setup 
!        movdqa  xmm0, 
!        movdqa  xmm1, 
!        movdqa  xmm2, 
!        movdqa  xmm3, 
!        movdqa  xmm4, 
!        movdqa  xmm5, 
!        movdqa  xmm6, 
!        movdqa  xmm7, 
;copy 
!        movdqa  xmm8, xmm0 
!        movdqa  xmm9, xmm1 
!        movdqa  xmm10, xmm2 
!        movdqa  xmm11, xmm3 
!        movdqa  xmm12, xmm4 
!        movdqa  xmm13, xmm5 
!        movdqa  xmm14, xmm6 
!        movdqa  xmm15, xmm7 
;mask highest qword bit 
!        pand    xmm8, dqword 
!        pand    xmm9, dqword 
!        pand    xmm10, dqword 
!        pand    xmm11, dqword 
!        pand    xmm12, dqword 
!        pand    xmm13, dqword 
!        pand    xmm14, dqword 
!        pand    xmm15, dqword 
;shift right logical 63bits to have the masked bit the lowest spot 
!        psrlq  xmm8, 63 
!        psrlq  xmm9, 63 
!        psrlq  xmm10, 63 
!        psrlq  xmm11, 63 
!        psrlq  xmm12, 63 
!        psrlq  xmm13, 63 
!        psrlq  xmm14, 63 
!        psrlq  xmm15, 63 
;shift left to clear the highest bit and empty the lowest 
!        psllq  xmm4, 1 
!        psllq  xmm5, 1 
!        psllq  xmm6, 1 
!        psllq  xmm7, 1 
;add masked bit 
!        paddq  xmm0, xmm12 
!        paddq  xmm1, xmm13 
!        paddq  xmm2, xmm14 
!        paddq  xmm3, xmm15 
;logical or lowest bit 
!        por    xmm4, xmm8 
!        por    xmm5, xmm9 
!        por    xmm6, xmm10 
!        por    xmm7, xmm11 
;copy 
!        movdqa  xmm8, xmm0 
!        movdqa  xmm9, xmm1 
!        movdqa  xmm10, xmm2 
!        movdqa  xmm11, xmm3 
;Bit ROLL by prime numbers 7, 5, 3, 11 
!        psllq  xmm0, 7 
!        psllq  xmm1, 5 
!        psllq  xmm2, 3 
!        psllq  xmm3, 11 
!        psrlq  xmm8, 57;64-7 
!        psrlq  xmm9, 59;64-5 
!        psrlq  xmm10, 61;64-3 
!        psrlq  xmm11, 53;64-11 
!        por    xmm0, xmm8 
!        por    xmm1, xmm9 
!        por    xmm2, xmm10 
!        por    xmm3, xmm11 
;Dword order switching 
!        pshufd  xmm0, xmm0, 00011011b 
!        pshufd  xmm1, xmm1, 00011011b 
!        pshufd  xmm2, xmm2, 00011011b 
!        pshufd  xmm3, xmm3, 00011011b 
;Modify Key with rotation of dq words 
!        movdqa  , xmm1 
!        movdqa  , xmm2 
!        movdqa  , xmm3 
!        movdqa  , xmm0 
!        movdqa  , xmm4 
!        movdqa  , xmm5 
!        movdqa  , xmm6 
!        movdqa  , xmm7 
;prepare output 
!        paddb  xmm0, xmm4 
!        paddb  xmm1, xmm5 
!        paddb  xmm2, xmm6 
!        paddb  xmm3, xmm7 
!        pxor    xmm0, xmm7 
!        pxor    xmm1, xmm6 
!        pxor    xmm2, xmm5 
!        pxor    xmm3, xmm4 
!        paddb  xmm0, xmm5 
!        paddb  xmm1, xmm4 
!        paddb  xmm2, xmm7 
!        paddb  xmm3, xmm6 
!        pxor    xmm0, xmm6 
!        pxor    xmm1, xmm7 
!        pxor    xmm2, xmm4 
!        pxor    xmm3, xmm5 
;save output 
!        movdqa  , xmm0 
!        movdqa  , xmm1 
!        movdqa  , xmm2 
!        movdqa  , xmm3 
;restore xmm8-15 and return 
!        movdqa  xmm15, 
!        movdqa  xmm14, 
!        movdqa  xmm13, 
!        movdqa  xmm12, 
!        movdqa  xmm11, 
!        movdqa  xmm10, 
!        movdqa  xmm9, 
!        movdqa  xmm8, 
!        mov    rsp, rax 
!        ret    0 ;;return
EndProcedure


Define nb = 12800000
Define seed.i = 7
Define i

Define T.q = ElapsedMilliseconds()
For i=0 To nb-1
  Random(9223372036854775807)
Next
Define T1.q = ElapsedMilliseconds() - T

T = ElapsedMilliseconds()
For i=0 To nb-1
  Randomize(@seed)
Next
Define T2.q = ElapsedMilliseconds() - T

MessageRequester("RANDOM", Str(T1)+" vs "+Str(T2))

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 172
; FirstLine = 131
; Folding = -
; EnableXP