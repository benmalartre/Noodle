XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../core/Array.pbi"
XIncludeFile "../../core/Time.pbi"

UseModule Math

Macro QuaternionMultiplyMacro(_out,_q1,_q2)
  Define.f _x,_y,_z,_w
  _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
  _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
  _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
  _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)
  
  _out\x = _x
  _out\y = _y
  _out\z = _z
  _out\w = _w
EndMacro

Procedure QuaternionMultiplySSE(*out.q4f32,*q1.q4f32, *q2.q4f32)
;   _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
;   _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
;   _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
;   _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)

  ! mov rdi, [p.p_out]
  ! mov rcx, [p.p_q1]
  ! mov rdx, [p.p_q2]
  
  ! movups xmm0, [rcx]              ; load q1 
  ! movaps xmm1, xmm0               ; copy to xmm1
  ! movaps xmm2, xmm0               ; and xmm2
  ! movaps xmm3, xmm0               ; and xmm3
  
  ! shufps xmm0, xmm0, 11111111b    ; q1 ( w, w, w, w)
  ! shufps xmm1, xmm1, 00100100b    ; q1 ( x, y, z, x)
  ! shufps xmm2, xmm2, 01001001b    ; q1 ( y, z, x, y)
  ! shufps xmm3, xmm3, 10010010b    ; q1 ( z, x, y, z)
  
  ! movups xmm4, [rdx]              ; load q2
  ! movaps xmm5, xmm4               ; copy to xmm5
  ! movaps xmm6, xmm4               ; and xmm6
  ! movaps xmm7, xmm4               ; and xmm7
  
  ! shufps xmm5, xmm5, 00111111b    ; q2 ( w, w, w, x)
  ! shufps xmm6, xmm6, 01010010b    ; q2 ( z, x, y, y)
  ! shufps xmm7, xmm7, 10001001b    ; q2 ( y, z, x, z)
  
  ! mulps xmm0, xmm4              
  ! mulps xmm1, xmm5
  ! mulps xmm2, xmm6
  ! mulps xmm3, xmm7
  
  ! movaps xmm8, [math.l_sse_0001_negate_mask]
  ! mulps xmm1, xmm8
  ! mulps xmm2, xmm8
  ! movaps xmm8, [math.l_sse_1111_negate_mask]
  ! mulps xmm3, xmm8
  
  ! addps xmm0, xmm1
  ! addps xmm0, xmm2
  ! addps xmm0, xmm3
  
  ! movups [rdi], xmm0
EndProcedure

Define q1.Math::q4f32
Define q2.Math::q4f32
Define out.q4f32
Time::Init()

Define nb = 12800000
Define i
Define *q.Math::q4f32

Define *QIN.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
CArray::SetCount(*QIN, 2)

; *q1 = CArray::GetValue(*QIN, 0)
Quaternion::SetFromAxisAngleValues(q1, 0, 1, 0, Radian(45))
; *q2 = CArray::GetValue(*QIN, 1)
Quaternion::SetFromAxisAngleValues(q2, 1, 0, 0, Radian(90))

Define *O1.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
Define *O2.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
CArray::SetCount(*O1, nb)
CArray::SetCount(*O2, nb)


Define startT.d = Time::Get()
For i=0 To nb-1 
  *q = CArray::GetValue(*O1, i)
  QuaternionMultiplyMacro(*q,q1,q2)
Next
Define E1.d = Time::Get() - startT

startT.d = Time::Get()
For i=0 To nb-1 
  *q = CArray::GetValue(*O2, i)
  QuaternionMultiplySSE(*q,q1,q2)
Next
Define E2.d = Time::Get() - startT


MessageRequester("QUATERNION MULTIPLY", "PB : "+StrD(E1)+" vs SSE : "+StrD(E2)+Chr(10)+
                                        "COMPARE : "+Str(CompareMemory(*O1\data, *O2\data, CArray::GetSize(*O1))))
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 91
; FirstLine = 74
; Folding = -
; EnableXP