XIncludeFile "../../core/Time.pbi"

Structure Vector3
  x.f
  y.f
  z.f
  w.f
EndStructure


Procedure SetSSE(*v.Vector3,x.f, y.f, z.f)
  ! mov rax, [p.p_v]
  ! movlps xmm0, [p.v_x]
  ! movhps xmm0, [p.v_y]
  ! shufps xmm0, xmm0, 10001000b
  ! movlps xmm1, [p.v_z]
  ! shufps xmm1, xmm1, 00000000b
  ! shufps xmm0, xmm1, 00010001b
  ! movups [rax], xmm0
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

Define *v.Vector3

Define T.d = Time::Get()
For i=0 To nb -1
  *v = *A + i * SizeOf(Vector3)
  Set(*v, (Random(2000) - 1000) * 0.001, (Random(2000) - 1000) * 0.001, (Random(2000) - 1000) * 0.001)
Next
Define T1.d = Time::Get() - T
T = Time::Get()

For i=0 To nb-1
  *v = *B + i * SizeOf(Vector3)
  SetSSE(*v, (Random(2000) - 1000) * 0.001, (Random(2000) - 1000) * 0.001, (Random(2000) - 1000) * 0.001)
Next
Define T2.d = Time::Get() - T

MessageRequester("PB vs ASM", StrD(T1) +" : "+StrD(T2))

  
  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 21
; Folding = -
; EnableXP