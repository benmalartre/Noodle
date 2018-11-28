XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../core/Math.pbi"

UseModule Math

Procedure.f GetDetAsm(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
  Define.f d0,d1,d2,d3,d4
  Define det.f, u.f, v.f
      
  ! mov rsi, [p.p_pnt]              ; move pnt to cpu
  ! movups xmm10, [rsi]             ; move datas to xmm10
  ! mov rsi, [p.p_closest]          ; move closest to cpu
  ! movups xmm11, [rsi]             ; move datas to xmm11
  ! mov rsi, [p.p_uvw]              ; move uvw to cpu
  ! movups xmm12, [rsi]             ; move datas to xmm12
  
  ! mov rsi, [p.p_a]                ; move a to cpu
  ! movups xmm13,[rsi]              ; move datas to xmm13
  ! mov rsi, [p.p_b]                ; move b to cpu
  ! movups xmm14,[rsi]              ; move datas to xmm14
  ! mov rsi, [p.p_c]                ; move c to cpu
  ! movups xmm15,[rsi]              ; move datas to xmm15
  
  ! movaps xmm8, xmm14              ; copy b in xmm8
  ! movaps xmm9, xmm15              ; copy c in xmm9
  ! subps xmm8, xmm13               ; compute edge0 : b - a
  ! subps xmm9, xmm13               ; compute edge1 : c - a
  
  ! movaps xmm7, xmm10              ; copy pnt to xmm7
  ! subps xmm7, xmm13               ; compute v0 : pnt - a
  ! xorps xmm6, xmm6                ; will store d0,d1,d2,d3
  
  ; dot product a : edge0 * edge0                  
  ! movaps xmm0, xmm8
  ! mulps xmm0, xmm8
  ! haddps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! shufps xmm0, xmm0, 00000000b    
  ! blendps xmm6, xmm0, 0001b               
  
  ; dot product b : edge0 * edge1                 
  ! movaps xmm0, xmm8
  ! mulps xmm0, xmm9
  ! haddps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! shufps xmm0, xmm0, 00000000b
  ! blendps xmm6, xmm0, 0010b
  
  ; dot product c : edge1 * edge1                 
  ! movaps xmm0, xmm9
  ! mulps xmm0, xmm9
  ! haddps xmm0, xmm0
  ! haddps xmm0, xmm0
  ! shufps xmm0, xmm0, 00000000b
  ! blendps xmm6, xmm0, 0100b
  
  ; dot product d : edge0 * v0                 
  ! movaps xmm0, xmm8               ; make a copy of edge0
  ! mulps xmm0, xmm13               ; product edge0 * v0
  ! haddps xmm0, xmm0               ; horizontal add first pass
  ! haddps xmm0, xmm0               ; second pass : d stored in first element of xmm0
  ! blendps xmm6, xmm0, 1000b       ; put in in fourth element of xmm6
  
  ; dot product e : edge1 * v0                 
  ! movaps xmm5, xmm9               ; make a copy of edge1
  ! mulps xmm5, xmm13               ; product edge1 * v0
  ! haddps xmm5, xmm5               ; horizontal add first pass
  ! haddps xmm5, xmm5               ; second pass : e stored in first element of xmm5
  
  ! movaps xmm0, xmm6               ; make a copy of a b c d
  ! movaps xmm1, xmm6               ; make a copy of a b c d
  ! shufps xmm0, xmm0, 01000100b    ; shuffle a b a b
  ! shufps xmm1, xmm1, 01100110b    ; shuffle c b c b
  
  ! mulps xmm0, xmm1
  ! hsubps xmm0, xmm1
  ! movss [p.v_det], xmm0
  ProcedureReturn det
EndProcedure

Procedure.f GetDetPB(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
      
  Define edge0.v3f32, edge1.v3f32, v0.v3f32
  Define.f a, b, c, d, e
  Define.f det, infDenom
  
  Vector3::Sub(edge0, *b, *a)
  Vector3::Sub(edge1, *c, *a)
  Vector3::Sub(v0, *a, *pnt)
  
  a = Vector3::Dot(edge0, edge0)
  b = Vector3::Dot(edge0, edge1)
  c = Vector3::Dot(edge1, edge1)
  d = Vector3::Dot(edge0, v0)
  e = Vector3::Dot(edge1, v0)
  
  det = a*c - b*b
  ProcedureReturn det
EndProcedure

Define.v3f32 a, b, c, pnt, closest, uvw
Vector3::Set(a, -1,0,0)
Vector3::Set(b, 0.5,1,0.33)
Vector3::Set(c, 1,0,-0.25)
Vector3::Set(pnt, 0.33,0.25,0.1)

Define det1.f =  GetDetPB(a, b, c, pnt, closest, uvw)
Define det2.f = GetDetASM(a, b, c, pnt, closest, uvw)

Debug det1
Debug det2
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 76
; FirstLine = 39
; Folding = -
; EnableXP