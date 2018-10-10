XIncludeFile "../../core/Time.pbi"

Structure Vector3
  x.f
  y.f
  z.f
  w.f
EndStructure

Procedure Compare(*A1, *A2, nb)
  Protected *v1.Vector3, *v2.Vector3
  For i=0 To nb-1
    *v1 = *A1 + i * SizeOf(Vector3)
    *v2 = *A2 + i * SizeOf(Vector3)
    If Abs(*v1\x - *v2\x) > 0.000001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\y - *v2\y) > 0.000001
      ProcedureReturn #False
    EndIf
    If Abs(*v1\z - *v2\z) > 0.000001
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure

Procedure.s ArrayString(*A, nb)
  Protected *v.Vector3
  Protected s.s
  If nb > 12
    For i=0 To 5
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
    For i=nb-7 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  Else
    For i=0 To nb-1
      *v = *A + i * SizeOf(Vector3)
      s+StrF(*v\x,3)+","+StrF(*v\y,3)+","+StrF(*v\z,3)+","
    Next
  EndIf
    
  ProcedureReturn s
EndProcedure


Procedure Cross_ASM(*v.Vector3,*a.Vector3,*b.Vector3)
  ! mov rax, [p.p_a]
  ! mov rcx, [p.p_b]

  ! movaps xmm0,[rax]   
  ! movaps xmm1,[rcx]   
  
  ! movaps xmm2,xmm0         ;Copies
  ! movaps xmm3,xmm1
  
  ! shufps xmm0,xmm0,00001001b    ;Exchange 2 and 3 element (V1)
  ! shufps xmm1,xmm1,00010010b    ;Exchange 1 and 2 element (V2)
  ! mulps  xmm0,xmm1
         
  ! shufps xmm2,xmm2,00010010b    ;Exchange 1 and 2 element (V1)
  ! shufps xmm3,xmm3,00001001b    ;Exchange 2 and 3 element (V2)
  ! mulps  xmm2,xmm3
        
  ! subps  xmm0,xmm2
  
  ! mov rdx, [p.p_v]
  ! movaps [rdx],xmm0        ;Result
EndProcedure

Macro Cross(_v, _a, _b)
  _v\x = (_a\y * _b\z) - (_a\z * _b\y)
  _v\y = (_a\z * _b\x) - (_a\x * _b\z)
  _v\z = (_a\x * _b\y) - (_a\y * _b\x)
EndMacro

Time::Init()
Define nb = 12800000
Define *A = AllocateMemory(nb * SizeOf(Vector3))
Define *B = AllocateMemory(nb * SizeOf(Vector3))
Define *C = AllocateMemory(nb * SizeOf(Vector3))
Define *D = AllocateMemory(nb * SizeOf(Vector3))

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

T = Time::Get()

For i=0 To nb-1
  offset = i * SizeOf(Vector3)
  *v1 = *A + offset
  *v2 = *B + offset
  *v3 = *D + offset
  Cross_ASM(*v3, *v1, *v2)
Next
Define T2.d = Time::Get() - T


MessageRequester("PB vs ASM", StrD(T1) +" : "+StrD(T2)+" EQUAL ? "+Str(Compare(*C, *D, nb))+Chr(10)+
                              ArrayString(*C, nb)+Chr(10)+"----------------------------"+Chr(10)+
                              ArrayString(*D, nb)+Chr(10))

  
  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 115
; FirstLine = 74
; Folding = -
; EnableXP