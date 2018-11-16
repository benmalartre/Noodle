; Test axis a00
; a00 = np.Array([0, -f0[Z], f0[Y]])
; p0 = np.dot(v0, a00)
; p1 = np.dot(v1, a00)
; p2 = np.dot(v2, a00)
; r = box_extents[Y] * Abs(f0[Z]) + box_extents[Z] * Abs(f0[Y])
; If (max(-max(p0, p1, p2), min(p0, p1, p2))) > r:
;     Return False
; 
; ! mov rax, [p.p_a]
; ! movups xmm13, [rax]
; ! mov rax, [p.p_b]
; ! movups xmm14, [rax]
; ! mov rax, [p.p_c]
; ! movups xmm15, [rax]


XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../objects/Geometry.pbi"
XIncludeFile "../../objects/Triangle.pbi"

Procedure Vector3_SetX(*v.Math::v3f32, x.f)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! movaps xmm1, xmm0
  ! movss xmm1, [p.v_x]
  ! shufps xmm1, xmm0, 00000000b
  ! movups [rax], xmm0
EndProcedure

Procedure Vector3_SetY(*v.Math::v3f32, x.f)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! movaps xmm1, xmm0
  ! movss xmm1, [p.v_x]
  ! shufps xmm0, xmm1, 11100100b
  ! movups [rax], xmm0
EndProcedure

Procedure Vector3_SetZ(*v.Math::v3f32, x.f)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  ! movaps xmm1, xmm0
  ! movss xmm1, [p.v_x]
  ! shufps xmm1, xmm0, 11100100b
  ! movups [rax], xmm1
EndProcedure



Define v.Math::v3f32
Vector3::Set(v,1,2,3)
Vector3::Echo(v, "SET")
Vector3_SetX(v, 7)
Vector3::Echo(v, "SET")
Vector3_SetY(v, 7)
Vector3::Echo(v, "SET")
Vector3_SetZ(v, 7)
Vector3::Echo(v, "SET")
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 27
; FirstLine = 1
; Folding = -
; EnableXP