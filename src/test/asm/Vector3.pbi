

Structure Vector3f Align 4
  x.f
  y.f
  z.f 
  w.f
EndStructure

Procedure.f Float_Add(a.f, b.f)
  Define v.f
  !fld dword [p.v_a]
  !fld dword [p.v_b]
  !fadd st0, st1
  !fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure move_four_float(*src, *dst, count.l)

  !mov     rcx,    [p.v_count]       ; # of float Data
  
    !mov     rdi,    [p.p_dst]         ; dst pointer
    !mov     rsi,    [p.p_src]         ; src pointer

!loop1:
    !movaps  xmm0,   [rsi]             ; get from src
    !movaps  [rdi],  xmm0              ; put To dst

    !add     rsi,    16
    !add     rdi,    16

    !dec     rcx                       ; Next
    !jnz     loop1
    

  EndProcedure
  
 Procedure Vector3_Access(*a.Vector3f, offset.l, *value)
   ! mov rcx, [p.v_offset]
   ! mov rsi, [p.p_a]
   ! add rsi, rcx
   ! fld dword [rsi]
   ! mov rdi, [p.p_value]
   ! fst dword [rdi]
EndProcedure
 
  

Procedure Vector3_Copy(*src.Vector3f, *dst.Vector3f)
   !mov     rdi,    [p.p_dst]         ; dst pointer
   !mov     rsi,    [p.p_src]         ; src pointer
   !movaps  xmm0,   [rsi]             ; get from src
   !movaps  [rdi],  xmm0              ; put To dst
 EndProcedure
 


Procedure.f Vector3_AccessX(*a.Vector3f)
  Define v.f
  ! mov rsi, [p.p_a]
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure.f Vector3_AccessY(*a.Vector3f)
  Define v.f
  ! mov rsi, [p.p_a]
  ! add rsi, 4
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure.f Vector3_AccessZ(*a.Vector3f)
  Define v.f
  ! mov rsi, [p.p_a]
  ! add rsi, 8
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure Vector3_AddInPlace_PB(*a.Vector3f, *b.Vector3f)
  *a\x + *b\x
  *a\y + *b\y
  *a\z + *b\z
EndProcedure 


Procedure Vector3_AddInPlace(*a.Vector3f, *b.Vector3f)
  ! mov rsi, [p.p_b]
  ! mov rdi, [p.p_a]
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! addps xmm0, xmm1
  ! movups [rdi], xmm0
EndProcedure

Procedure Vector3_Add(*a.Vector3f, *b.Vector3f, *c.Vector3f)
  ! mov rsi, [p.p_a]
  ! mov rax, [p.p_b]
  ! mov rdi, [p.p_c]
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! movaps xmm2, [rax]
  ! addps xmm0, xmm1
  ! addps xmm0, xmm2
  ! movaps [rdi], xmm0
EndProcedure

Macro M_Vector3_AddInPlace(a, b)
  EnableASM
  MOV rsi, b
  MOV rdi, a
  DisableASM
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! addps xmm0, xmm1
  ! movups [rdi], xmm0
EndMacro

Procedure Vector3_AddInPlace_Array(*src, *dst, count.l)
    !mov     ecx,    [p.v_count]       ; # of float Data
    !mov     rdi,    [p.p_dst]         ; dst pointer
    !mov     rsi,    [p.p_src]         ; src pointer

!loop2:
    !movaps  xmm0,   [rsi]             ; get from src
    !movaps  [rdi],  xmm0              ; put To dst

    !add     rsi,    16
    !add     rdi,    16

    !dec     ecx                       ; Next
    !jnz     loop2
EndProcedure


Define a.Vector3f
Define b.Vector3f
Define c.Vector3f

; a\x = 1.111
; a\y = 1.222
; a\z = 1.333
; 
; b\x = 0.5
; b\y = 0.5
; b\z = 0.5
; 
; ;Vector3_Add(*a, *b, *c)
; Define v.f
; Vector3_Access(@a, 0, @v)
; Debug "VALUE : "+StrF(v)
; Vector3_Access(@a, 4, @v)
; Debug "VALUE : "+StrF(v)
; Vector3_Access(@a, 8, @v)
; Debug "VALUE : "+StrF(v)
; 
; Debug "X : "+StrF(Vector3_AccessX(@a))
; Debug "Y : "+StrF(Vector3_AccessY(@a))
; Debug "Z : "+StrF(Vector3_AccessZ(@a))
; 
; Vector3_Add(@a, @b, @c)
; Debug "ADD : "+StrF(c\x)+","+StrF(c\y)+","+StrF(c\z)
; 
; Vector3_AddInPlace(@a, @b)
; Debug "ADD IN PLACE : "+StrF(a\x)+","+StrF(a\y)+","+StrF(a\z)
; Define *A.Vector3f = @a
; Define *B.Vector3f = @b
; M_Vector3_AddInPlace(*A, *B)
; Debug "ADD IN PLACE : "+StrF(a\x)+","+StrF(a\y)+","+StrF(a\z)


; Debug "ACCESS : "+StrF(Vector3_Access(@a))
;move_four_float(@a, @b, 4)
; ;Vector3_Copy(@a, @b)
; 
; Debug "AX : "+StrF(b\x)
; Debug "AY : "+StrF(b\y)
; Debug "AZ : "+StrF(b\z)

Define count.l = 20000000
Define T.q = ElapsedMilliseconds()
Define *src = AllocateMemory(count * SizeOf(Vector3f))
Define *dst = AllocateMemory(count * SizeOf(Vector3f))
Define *v.Vector3f

For i=0 To count-1
  *v = *src + i*SizeOf(Vector3f)
  *v\x =  Random(65565)/65565
  *v\y =  Random(65565)/65565
  *v\z =  Random(65565)/65565
Next
Define E1.f = (ElapsedMilliseconds() - T)*0.001


T = ElapsedMilliseconds()


; move_four_float(*src, *dst, count)

; Define *A.Vector3f, *B.Vector3f
; For i=0 To count - 1
;   *A = *src + i * SizeOf(Vector3f)
;   *B = *dst + i * SizeOf(Vector3f)
;   
;   Debug StrF(*A\x)+","+StrF(*A\y)+","+StrF(*A\z)+" ---> "+StrF(*B\x)+","+StrF(*B\y)+","+StrF(*B\z)
; Next

Define offset.i
Define sv = SizeOf(Vector3f)

For i=0 To count-1
  offset = i * sv
  Vector3_AddInPlace_PB(*dst + offset, *src + offset)
Next
Define E2.f = (ElapsedMilliseconds() - T) *0.001

T = ElapsedMilliseconds()
For i=0 To count-1
  offset = i * sv
  Vector3_AddInPlace(*dst + offset, *src + offset)
Next
Define E3.f = (ElapsedMilliseconds() - T)*0.001


T = ElapsedMilliseconds()
Define offset.i
Define *A.Vector3f, *B.Vector3f
For i=0 To count-1
  offset = i * sv
  *A = *dst + offset
  *B = *src + offset
  M_Vector3_AddInPlace(*A, *B)
Next
Define E4.f = (ElapsedMilliseconds() - T) *0.001


T = ElapsedMilliseconds()
Vector3_AddInPlace_Array(*src, *dst, count)
Define E5.f = (ElapsedMilliseconds() - T) *0.001



MessageRequester("ASM"," Init : "+StrF(E1)+Chr(10)+" PB : "+StrF(E2)+Chr(10)+" ASM : "+StrF(E3)+Chr(10)+" ASM MACRO : "+StrF(E4)+Chr(10)+" ASM LOOP : "+StrF(E5))
; ; Debug StrF(Float_Add(1.111, 3.222))

Debug "X: "+StrF( Vector3_Access(@a, 0))
Debug "Y: "+StrF( Vector3_Access(@a, 1))
Debug "Z: "+StrF( Vector3_Access(@a, 2))


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 247
; FirstLine = 201
; Folding = ---
; EnableXP