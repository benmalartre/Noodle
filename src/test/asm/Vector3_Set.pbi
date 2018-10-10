XIncludeFile "../../core/Time.pbi"

Structure Vector3
  x.f
  y.f
  z.f
EndStructure

Procedure Cross_ASM(*v.Vector3,*a.Vector3,*b.Vector3)
  ! mov rax, [p.p_v]
  ! mov rcx, [p.p_a]
  ! mov rdx, [p.p_b]

  ! movups xmm0,[rdx]        ;If aligned then use movaps
  ! movups xmm1,[rcx]   
  ! movups xmm2,[rax]   
  
  ! movaps xmm3,xmm1         ;Copies
  ! movaps xmm4,xmm2
  
  ! shufps xmm1,xmm1,0xd8    ;Exchange 2 and 3 element (V1)
  ! shufps xmm2,xmm2,0xe1    ;Exchange 1 and 2 element (V2)
  ! mulps  xmm1,xmm2
         
  ! shufps xmm3,xmm3,0xe1    ;Exchange 1 and 2 element (V1)
  ! shufps xmm4,xmm4,0xd8    ;Exchange 2 and 3 element (V2)
  ! mulps  xmm3,xmm4
        
  ! subps  xmm1,xmm3
  
  ! movups [rdx],xmm1        ;Result
EndProcedure

Macro Cross(_v, _a, _b)
  _v\x = (_a\y * _b\z) - (_a\z * _b\y)
  _v\y = (_a\z * _b\x) - (_a\x * _b\z)
  _v\z = (_a\x * _b\y) - (_a\y * _b\x)
EndMacro

Procedure Set_ASM(*v.Vector3,x.f, y.f, z.f)
;   ! mov rax, [p.p_v]
;   ! movlps xmm0, [p.v_x]
;   ! movhps xmm0, [p.v_y]
;   ! shufps xmm0, xmm0, 10001000b
;   ! movlps xmm1, [p.v_z]
;   ! shufps xmm1, xmm1, 00000000b
;   ! shufps xmm0, xmm1, 00010001b
;   ! movups [rax], xmm0
  ! mov rdi, [p.p_v]
  ! mov rsi, [p.v_x]
;   ! fld dword [rsi]
;   ! fst dword [rdi]
;   ! mov rsi, [p.v_y]
;   ! fld dword [rsi]
;   ! fst dword [rdi+4]
;   ! mov rsi, [p.v_z]
;   ! fld dword [rsi]
;   ! fst dword [rdi+8]
EndProcedure

Macro Set(_v,_x,_y,_z)
  _v\x = _x
  _v\y = _y
  _v\z = _z
EndMacro


Define v.Vector3
v\x = 0
v\y = 0
v\z = 0



Time::Init()
Define nb = 12800000
Define *A = AllocateMemory(nb * SizeOf(Vector3))
Define *B = AllocateMemory(nb * SizeOf(Vector3))
Define *C = AllocateMemory(nb * SizeOf(Vector3))

Define *v.Vector3
For i=0 To nb -1
  *v = *A + i * SizeOf(Vector3)
  *v\x = (Random(2000) - 1000) * 0.001
  *v\y = (Random(2000) - 1000) * 0.001
  *v\z = (Random(2000) - 1000) * 0.001
  
  *v = *B + i * SizeOf(Vector3)
  *v\x = (Random(2000) - 1000) * 0.001
  *v\y = (Random(2000) - 1000) * 0.001
  *v\z = (Random(2000) - 1000) * 0.001
Next

Define.Vector3 *v1, *v2, *v3
Define offset.i

Define T.d = Time::Get()

For i=0 To nb-1
  offset = i * SizeOf(Vector3)
  *v1 = *A + offset
  *v2 = *B + offset
  *v3 = *C + offset
  Cross(*v3, *v1, *v2)
Next

Define T1.d = Time::Get() - T
T = ElapsedMilliseconds()

For i=0 To nb-1
  offset = i * SizeOf(Vector3)
  Cross_ASM(*C + offset, *A + offset,  *B + offset)
Next
Define T2.d = Time::Get() - T

MessageRequester("PB vs ASM", StrD(T1) +" : "+StrD(T2))

  
  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 111
; FirstLine = 65
; Folding = -
; EnableXP