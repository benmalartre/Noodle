#ALIGN_BYTES = 64

Macro Align16(_mem)
  ((_mem) + #ALIGN_BYTES-(_mem)%#ALIGN_BYTES)
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
    !movups  xmm0,   [rsi]             ; get from src
    !movups  [rdi],  xmm0              ; put To dst

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
   DisableASM
   !movups  xmm0,   [rsi]       ; get from src
   !movups  [rdi],  xmm0        ; put To dst
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

Macro Vector3_SubInPlace_PB(_a, _b)
  _a\x - _b\x
  _a\y - _b\y
  _a\z - _b\z
EndMacro 

Macro Vector3_AddInPlace(_a, _b)
  EnableASM
  MOV rsi, _b
  MOV rdi, _a
  DisableASM

  ! movups xmm0, [rdi]
  ! movups xmm1, [rsi]
  ! addps xmm0, xmm1
  ! movups [rdi], xmm0

EndMacro

Macro Vector3_Add(_a, _b, _c)
  EnableASM
  MOV rsi, _a
  MOV rax, _b
  MOV rdi, _c
  DisableASM
  ! movups xmm0, [rdi]
  ! movups xmm1, [rsi]
  ! movaps xmm2, [rax]
  ! addps xmm0, xmm1
  ! addps xmm0, xmm2
  ! movups [rdi], xmm0
EndMacro

Macro Vector3_SubInPlace(_a, _b)
  EnableASM
  MOV rsi, _b
  MOV rdi, _a
  DisableASM
  ! movups xmm0, [rdi]
  ! movups xmm1, [rsi]
  ! subps xmm0, xmm1
  ! movups [rdi], xmm0
EndMacro

Macro Vector3_Sub(_a, _b, _c)
  EnableASM
  MOV rsi, _a
  MOV rax, _b
  MOV rdi, _c
  DisableASM
  ! movups xmm0, [rdi]
  ! movups xmm1, [rsi]
  ! movups xmm2, [rax]
  ! addps xmm0, xmm1
  ! subps xmm0, xmm2
  ! movups [rdi], xmm0
EndMacro

Macro Vector3_Dot(_a, _b)
  EnableASM
  MOV rdi, _a
  MOV rsi, _b
  DisableASM
  
  ! movups xmm6, [rdi]             ;le U signifie qu'on ne suppose pas que les données sont alignées à 128 bits
  ! shufps xmm6, xmm6, 9         ;= 1 + 8, c'est-à-dire une rotation des 3 composantes
  ! movups xmm7, [rsi]
  ! shufps xmm7, xmm7, 18        ;= 2 + 16, c'est-à-dire une rotation dans l'autre sens
  ! movaps xmm0,xmm6             ;premier produit pour chaque composante
  ! mulps xmm0,xmm7
  ! movups xmm6, vS1
  ! shufps xmm6, xmm6, 18
  ! movups xmm7, vS2
  ! shufps xmm7, xmm7, 9
  ! mulps xmm7,xmm6              ;deuxième produit retranché pour chaque composante
  ! subps xmm0,xmm7
  
EndMacro

Procedure Vector3_AddInPlace_Array(*src, *dst, count.i)
!     mov     rcx,    [p.v_count]       ; # of float Data
!     mov     rdi,    [p.p_dst]         ; dst pointer
!     mov     rsi,    [p.p_src]         ; src pointer

!loop_vec3_addinplace_array:
!     movups  xmm0,   [rdi]             ; get initial value
!     movups  xmm1,   [rsi]             ; get value to add
!     addps   xmm0,   xmm1              ; 4 float packed addition
!     movups  [rdi],  xmm0              ; put back to dst

!     add     rsi,    12                ; offset src pointer
!     add     rdi,    12                ; offset dst pointer

!     dec     rcx                       ; next
!     jnz     loop_vec3_addinplace_array
EndProcedure

Procedure Vector3_SubInPlace_Array(*src, *dst, count.i)
!     mov     rcx,    [p.v_count]       ; # of float Data
!     mov     rdi,    [p.p_dst]         ; dst pointer
!     mov     rsi,    [p.p_src]         ; src pointer

!loop_vec3_subinplace_array:
!     movups  xmm0,   [rdi]             ; get initial value
!     movups  xmm1,   [rsi]             ; get value to add
!     subps   xmm0,   xmm1              ; 4 float packed substraction
!     movups  [rdi],  xmm0              ; put back to dst

!     add     rsi,    12                ; offset src pointer
!     add     rdi,    12                ; offset dst pointer

!     dec     rcx                       ; next
!     jnz     loop_vec3_subinplace_array
EndProcedure

Procedure Vector3_Cross(*a.Vector3, *b.Vector3)
  ! mov rax,[p.p_a]          ;Put argument addresses to registers
  ! mov rbx,[p.p_b]
  
  ! movups xmm0,[rax]        ;If aligned then use movaps
  ! movups xmm1,[rbx]   
  
  ! movaps xmm2,xmm0         ;Copies
  ! movaps xmm3,xmm1
  
  ! shufps xmm0,xmm0,0xd8    ;Exchange 2 and 3 element (V1)
  ! shufps xmm1,xmm1,0xe1    ;Exchange 1 and 2 element (V2)
  ! mulps  xmm0,xmm1
         
  ! shufps xmm2,xmm2,0xe1    ;Exchange 1 and 2 element (V1)
  ! shufps xmm3,xmm3,0xd8    ;Exchange 2 and 3 element (V2)
  ! mulps  xmm2,xmm3
        
  ! subps  xmm0,xmm2
  
  ! movups [rax],xmm0        ;Result
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
  *v\x =  (Random(2000)-1000)*0.001
  *v\y =  (Random(2000)-1000)*0.001
  *v\z =  (Random(2000)-1000)*0.001
Next
Define E1.f = (ElapsedMilliseconds() - T)*0.001

Define *aligned_src = Align16(*src)
Define *aligned_dst = Align16(*dst)

T = ElapsedMilliseconds()


; move_four_float(*src, *dst, count)

; Define *A.Vector3f, *B.Vector3f
; For i=0 To count - 1
;   *A = *src + i * SizeOf(Vector3f)
;   *B = *dst + i * SizeOf(Vector3f)
;   
;   Debug StrF(*A\x)+","+StrF(*A\y)+","+StrF(*A\z)+" ---> "+StrF(*B\x)+","+StrF(*B\y)+","+StrF(*B\z)
; Next

Define msg.s
Define offset.l
Define sv.l = SizeOf(Vector3)
Define *d.Vector3
Define *s.Vector3


For i=0 To count-1
  offset = i * sv
  *d = *aligned_dst + offset
  *s = *aligned_src + offset
  Vector3_AddInPlace_PB(*d, *s)
Next
Define E2.f = (ElapsedMilliseconds() - T) *0.001

T = ElapsedMilliseconds()
For i=0 To count-1
  offset = i * sv
  *d = *aligned_dst + offset
  *s = *aligned_src + offset
  Vector3_AddInPlace(*d, *s)
Next
Define E3.f = (ElapsedMilliseconds() - T)*0.001


T = ElapsedMilliseconds()

Define E4.f = (ElapsedMilliseconds() - T) *0.001


T = ElapsedMilliseconds()
Vector3_AddInPlace_Array(*aligned_dst, *aligned_src, count)
Define E5.f = (ElapsedMilliseconds() - T) *0.001


FreeMemory(*src)
FreeMemory(*dst)

msg + "NUM POINTS : "+Str(count)+Chr(10)
msg + " Init : "+StrF(E1)+Chr(10)+
      " PB : "+StrF(E2)+Chr(10)+
      " ASM : "+StrF(E3)+Chr(10)+
      " ASM LOOP : "+StrF(E5)

MessageRequester("ASM",msg)
; ; Debug StrF(Float_Add(1.111, 3.222))

; Define value.f
; Vector3_Access(a, 0, value)
; Debug "X: "+StrF( value )
; Vector3_Access(a, 1, value)
; Debug "Y: "+StrF( value )
; Vector3_Access(a, 2, value)
; Debug "Z: "+StrF( value )

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; Folding = ----
; EnableXP