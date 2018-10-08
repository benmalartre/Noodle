Macro Align16(_mem)
 ((_mem) + (64- (_mem)%64))
EndMacro

Structure Vector3
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

Procedure move_four_float(*src, *dst, count.i)
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
  
Macro Vector3_Access(_a, _offset, _value)
  EnableASM
  MOV rcx, _offset
  MOV rsi, _a
  MOV rdi, _value
  DisableASM
   ! add rsi, rcx
   ! fld dword [rsi]
   ! fst dword [rdi]
 EndMacro
 
Macro Vector3_Copy(_src, _dst)
  EnableASM
   MOV     rdi,    _dst         ; dst pointer
   MOV     rsi,    _src         ; src pointer
   !movaps  xmm0,   [rsi]       ; get from src
   !movaps  [rdi],  xmm0        ; put To dst
 EndMacro

Procedure.f Vector3_AccessX(*a.Vector3)
  Define v.f
  ! mov rsi, [p.p_a]
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure.f Vector3_AccessY(*a.Vector3)
  Define v.f
  ! mov rsi, [p.p_a]
  ! add rsi, 4
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Procedure.f Vector3_AccessZ(*a.Vector3)
  Define v.f
  ! mov rsi, [p.p_a]
  ! add rsi, 8
  ! fld dword [rsi]
  ! fst dword [p.v_v]
  ProcedureReturn v
EndProcedure

Macro Vector3_AddInPlace_PB(_a, _b)
  _a\x + _b\x
  _a\y + _b\y
  _a\z + _b\z
EndMacro 
; Procedure Vector3_AddInPlace_PB(*a.Vector3, *b.Vector3)
;   *a\x + *b\x
;   *a\y + *b\y
;   *a\z + *b\z
; EndProcedure

Macro Vector3_SubInPlace_PB(_a, _b)
  _a\x - _b\x
  _a\y - _b\y
  _a\z - _b\z
EndMacro 
; Procedure Vector3_SubInPlace_PB(*a.Vector3, *b.Vector3)
;   *a\x - *b\x
;   *a\y - *b\y
;   *a\z - *b\z
; EndProcedure

Macro Vector3_AddInPlace(_a, _b)
  EnableASM
  MOV rsi, _b
  MOV rdi, _a
  DisableASM
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! addps xmm0, xmm1
  ! movaps [rdi], xmm0
EndMacro

Macro Vector3_Add(_a, _b, _c)
  EnableASM
  MOV rsi, _a
  MOV rax, _b
  MOV rdi, _c
  DisableASM
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! movaps xmm2, [rax]
  ! addps xmm0, xmm1
  ! addps xmm0, xmm2
  ! movaps [rdi], xmm0
EndMacro

Macro Vector3_SubInPlace(_a, _b)
  EnableASM
  MOV rsi, _b
  MOV rdi, _a
  DisableASM
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! subps xmm0, xmm1
  ! movaps [rdi], xmm0
EndMacro

Macro Vector3_Sub(_a, _b, _c)
  EnableASM
  MOV rsi, _a
  MOV rax, _b
  MOV rdi, _c
  DisableASM
  ! movaps xmm0, [rdi]
  ! movaps xmm1, [rsi]
  ! movaps xmm2, [rax]
  ! addps xmm0, xmm1
  ! subps xmm0, xmm2
  ! movaps [rdi], xmm0
EndMacro

Procedure Vector3_AddInPlace_Array(*src, *dst, count.i)
!     mov     rcx,    [p.v_count]       ; # of float Data
!     mov     rdi,    [p.p_dst]         ; dst pointer
!     mov     rsi,    [p.p_src]         ; src pointer

!loop_vec3_addinplace_array:
!     movaps  xmm0,   [rdi]             ; get initial value
!     movaps  xmm1,   [rsi]             ; get value to add
!     addps   xmm0,   xmm1              ; 4 float packed addition
!     movaps  [rdi],  xmm0              ; put back to dst

!     add     rsi,    16                ; offset src pointer
!     add     rdi,    16                ; offset dst pointer

!     dec     rcx                       ; next
!     jnz     loop_vec3_addinplace_array
EndProcedure

Procedure Vector3_SubInPlace_Array(*src, *dst, count.i)
!     mov     rcx,    [p.v_count]       ; # of float Data
!     mov     rdi,    [p.p_dst]         ; dst pointer
!     mov     rsi,    [p.p_src]         ; src pointer

!loop_vec3_subinplace_array:
!     movaps  xmm0,   [rdi]             ; get initial value
!     movaps  xmm1,   [rsi]             ; get value to add
!     subps   xmm0,   xmm1              ; 4 float packed substraction
!     movaps  [rdi],  xmm0              ; put back to dst

!     add     rsi,    16                ; offset src pointer
!     add     rdi,    16                ; offset dst pointer

!     dec     rcx                       ; next
!     jnz     loop_vec3_subinplace_array
EndProcedure


Define a.Vector3
Define b.Vector3
Define c.Vector3

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

Define count.i = 12000000
Define T.q = ElapsedMilliseconds()
Define *src = AllocateMemory(count * SizeOf(Vector3))
Define *dst = AllocateMemory(count * SizeOf(Vector3))
Define *v.Vector3

For i=0 To count-1
  *v = *src + i*SizeOf(Vector3)
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
Define sv = SizeOf(Vector3)
Define *d.Vector3
Define *s.Vector3

For i=0 To count-1
  offset = i * sv
  *d = Align16(*dst + offset)
  *s = Align16(*src + offset)
  Vector3_SubInPlace_PB(*d, *s)
Next
Define E2.f = (ElapsedMilliseconds() - T) *0.001

T = ElapsedMilliseconds()
For i=0 To count-1
  offset = i * sv
  *d = Align16(*dst + offset)
  *s = Align16(*src + offset)
  Vector3_SubInPlace(*d, *s)
Next
Define E3.f = (ElapsedMilliseconds() - T)*0.001


T = ElapsedMilliseconds()

Define E4.f = (ElapsedMilliseconds() - T) *0.001


T = ElapsedMilliseconds()
*d = Align16(*dst)
*s = Align16(*src)
Vector3_SubInPlace_Array(*d, *s, count)
Define E5.f = (ElapsedMilliseconds() - T) *0.001

MessageRequester("ASM"," Init : "+StrF(E1)+Chr(10)+
                       " PB : "+StrF(E2)+Chr(10)+
                       " ASM : "+StrF(E3)+Chr(10)+
                       " ASM LOOP : "+StrF(E5))
; ; Debug StrF(Float_Add(1.111, 3.222))

; Define value.f
; Vector3_Access(a, 0, value)
; Debug "X: "+StrF( value )
; Vector3_Access(a, 1, value)
; Debug "Y: "+StrF( value )
; Vector3_Access(a, 2, value)
; Debug "Z: "+StrF( value )

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 295
; FirstLine = 281
; Folding = ---
; EnableXP