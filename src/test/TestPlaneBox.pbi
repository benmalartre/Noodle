XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Slot.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Box.pbi"
XIncludeFile "../objects/Triangle.pbi"
XIncludeFile "../objects/Polymesh.pbi"

UseModule Math
Time::Init()

Procedure.b PlaneBoxTestSSE(*normal.v3f32, *origin.v3f32, *maxbox.v3f32)
  ! mov rsi, [p.p_origin]
  ! movups xmm0, [rsi]          ; store origin in xmm0
  ! mov rsi, [p.p_normal]
  ! movups xmm1, [rsi]          ; store normal in xmm1
  ! mov rsi, [p.p_maxbox]
  ! movups xmm2, [rsi]          ; store max box in xmm2
  ! movups xmm3, [math.l_sse_1111_negate_mask]
  ! mulps xmm3, xmm2            ; store negated max box in xmm3
  
  ! subps xmm3, xmm0            ; -maxbox - origin
  ! subps xmm2, xmm0            ; maxbox - origin
  
  ! xorps xmm4, xmm4            ; zero vector
  ! cmpps xmm4, xmm1, 1         ; check zero < normal
  
  ! movaps xmm5, xmm2           ; copy maxbox - origin
  ! movaps xmm6, xmm3           ; copy -maxbox - origin
  
  ! andps xmm5, xmm4            ; reset components with sign mask
  ! andps xmm6, xmm4            ; reset components with sign mask

  ! xorps xmm4, xmm4
  ! cmpps xmm4, xmm1, 5         ; check zero >= normal

  ! andps xmm2, xmm4            ; reset components with sign mask
  ! andps xmm3, xmm4            ; reset components with sign mask
  
  ! addps xmm2, xmm5            ; box minimum
  ! addps xmm3, xmm6            ; box maximum
  
  ! xorps xmm4, xmm4            ; zero vector
  ! mulps xmm2, xmm1            ; dot product box minimum with normal
  ! haddps xmm2, xmm2
  ! haddps xmm2, xmm2
  ! comiss xmm2, xmm4           ; compare first value
  ! jb no_intersection          ; dot(normal, minimum) > 0

  ! mulps xmm3, xmm1            ; dot product box maximum with normal
  ! haddps xmm3, xmm3
  ! haddps xmm3, xmm3
  ! comiss xmm3, xmm4           ; compare first value
  ! jbe intersection            ; dot(normal, minimum) >= 0
  
  ! jmp no_intersection
  
  ! intersection:
  ProcedureReturn #True
  
  ! no_intersection:
  ProcedureReturn #False
EndProcedure
  
Procedure.b PlaneBoxTest(*normal.v3f32, *origin.v3f32, *maxbox.v3f32)
  Define.v3f32 vmin,vmax
  Define.f v
  v = *origin\x
  If *normal\x > 0.0 :  vmin\x = -*maxbox\x - v : vmax\x = *maxbox\x - v : Else : vmin\x = *maxbox\x -v : vmax\x = -*maxbox\x - v : EndIf
  v = *origin\y
  If *normal\y > 0.0 :  vmin\y = -*maxbox\y - v : vmax\y = *maxbox\y - v : Else : vmin\y = *maxbox\y -v : vmax\y = -*maxbox\y - v : EndIf
  v = *origin\z
  If *normal\z > 0.0 :  vmin\z = -*maxbox\z - v : vmax\z = *maxbox\z - v : Else : vmin\z = *maxbox\z -v : vmax\z = -*maxbox\z - v : EndIf
  
  If Vector3::Dot(*normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
  If Vector3::Dot(*normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
  ProcedureReturn #False
EndProcedure


Define N = 10000000

Define *origins.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
Define *normals.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
CArray::SetCount(*origins, N)
CArray::SetCount(*normals, N)
Define *origin.Math::v3f32
Define *normal.Math::v3f32
For i=0 To N-1
  *origin = CArray::GetValue(*origins, i)
  *origin\x = Random_Neg1_1() * 2.0
  *origin\y = Random_Neg1_1() * 2.0
  *origin\z = Random_Neg1_1() * 2.0
  *normal = CArray::GetValue(*normals, i)
  *normal\x = Random_Neg1_1() * 2.0
  *normal\x = Random_Neg1_1() * 2.0
  *normal\x = Random_Neg1_1() * 2.0
  Vector3::NormalizeInPlace(*normal)
Next


Define box.Math::v3f32
Vector3::Set(box, 1, 1, 1)
Dim result1.b(N)

Define startT1.d = Time::Get()
For i=0 To N-1:
  result1(i) = PlaneBoxTest(CArray::GetValue(*normals, i), CArray::GetValue(*origins, i), box)
Next
Define elapsedT1.d = Time::Get() - startT1

Dim result2.b(N)

Define startT2.d = Time::Get()
For i=0 To N-1:
  result2(i) = PlaneBoxTestSSE(CArray::GetValue(*normals, i), CArray::GetValue(*origins, i), box)
Next
Define elapsedT2.d = Time::Get() - startT2

MessageRequester("PlaneBoxTest", "BASIC : "+StrD(elapsedT1) + ", SSE : " + StrD(elapsedT2))
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 82
; FirstLine = 55
; Folding = -
; EnableXP