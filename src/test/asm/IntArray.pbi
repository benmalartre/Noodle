XIncludeFile "E:\Projects\RnD\Noodle\src\core\Time.pbi"

Procedure SumI(a.i, b.i)
!      mov   rax,[p.v_a]           ; eax=param1
!      add   rax,[p.v_b]            ; eax=eax+param2
  ProcedureReturn
EndProcedure

Procedure SumArrayI(*a, *b, nb.i)
!     mov     ecx,    [p.v_nb]        ; nb of integer
!     mov     rdi,    [p.p_a]         ; dst pointer
!     mov     rsi,    [p.p_b]         ; src pointer

!loop_sum_array_i:
!     mov  rax,   [rdi]               ; get from src
!     add  rax,   [rsi]               ; add
!     mov  [rdi],   rax               ; put to dst

!     add     rsi,    8
!     add     rdi,    8

!     dec     ecx                       ; Next
!     jnz     loop_sum_array_i
EndProcedure

Procedure SumArrayISSE(*a, *b, nb.i)
!     mov     ecx,    [p.v_nb]        ; nb of integer
!     mov     rdi,    [p.p_a]         ; dst pointer
!     mov     rsi,    [p.p_b]         ; src pointer

!loop_sum_array_isse:
!     movdqa  xmm0,   [rdi]           ; get from dst
!     movdqa  xmm1,   [rsi]           ; get from src
!     paddq   xmm0,   xmm1            ; packed addition
!     movdqa  [rdi],  xmm0            ; put to dst

!     add     rsi,    16
!     add     rdi,    16

!     dec     ecx                     ; Next
!     jnz     loop_sum_array_isse
EndProcedure

Procedure PBSumArrayI(*a, *b, nb.i)
  Define i, offset
  For i=0 To nb-1
    offset = i*8
    PokeI(*a+offset, PeekI(*a+offset) + PeekI(*b+offset))
  Next
  
EndProcedure

Procedure CompareArray(*a, *b, nb.i)
  ProcedureReturn CompareMemory(*a, *b, nb * 8)
EndProcedure

Time::Init()
Define nb.i = 1280000 * 16
Dim A1.i(nb)
Dim A2.i(nb)
Dim A3.i(nb)
Dim B.i(nb)

For i=0 To nb-1
  A1(i) = Random(1024)
  A2(i) = A1(i)
  A3(i) = A1(i)
  B(i) = -Random(1024)
Next

; Define before1.s = ""
; Define before2.s = ""
; Define add.s = ""
; For i=0 To nb-1 : before1 + Str(A1(i))+"," : Next
; For i=0 To nb-1 : before2 + Str(A2(i))+"," : Next
; For i=0 To nb-1 : add + Str(B(i))+"," : Next
Define t.d = Time::Get()
PBSumArrayI(@A1(0), @B(0), nb)
Define t1.d = Time::Get() - t
t = Time::Get()
SumArrayI(@A2(0), @B(0), nb)
Define t2.d = Time::Get() - t
t = Time::Get()
SumArrayISSE(@A3(0), @B(0), nb/2)
Define t3.d = Time::Get() - t

Define valid1.b = CompareArray(@A1(0), @A2(0), nb)
Define valid2.b = CompareArray(@A1(0), @A3(0), nb)
MessageRequester("SumArrayI", "PB : "+ StrD(t1)+Chr(10)+
                              "ASM : "+StrD(t2)+" ---> "+
                              "VALID : "+Str(valid1)+Chr(10)+
                              "SSE : "+StrD(t3)+" ---> "+
                              "VALID : "+StrD(valid2))

; Define after1.s = ""
; For i=0 To nb-1 : after1 + Str(A1(i))+"," : Next
; Define after2.s = ""
; For i=0 To nb-1 : after2 + Str(A2(i))+"," : Next
; Debug before1
; Debug before2
; Debug add
; Debug after1
; Debug after2





; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 39
; FirstLine = 21
; Folding = -
; EnableXP