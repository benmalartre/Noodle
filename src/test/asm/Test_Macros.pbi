XIncludeFile "../../core/Time.pbi"
XIncludeFile "../../core/Math.pbi"
XIncludeFile "../../objects/Geometry.pbi"
XIncludeFile "../../objects/Triangle.pbi"
UseModule Math

DataSection
  sse_1111_negate_mask:
  Data.f -1.0, -1.0, -1.0, -1.0
EndDataSection

Macro AXISTEST_X01(a, b, fa, fb)
  p0 = a * v0\y - b * v0\z
  p2 = a * v2\y - b * v2\z
  If p0<p2 : min=p0 : max=p2
  Else : min=p2 : max=p0
  EndIf
  
  rad = fa * *extend\y + fb * *extend\z 
 
  If min>rad Or max<-rad : ProcedureReturn #False : EndIf
  
EndMacro

Macro SSE_AXISTEST_X01() 
  !   movaps xmm1, xmm0                   ; make a copy of e0 in xmm1
  !   shufps xmm1, xmm1, 01011010b        ; ez ez ey ey
  
  !   movaps xmm2, xmm13                  ; copy p0 to xmm2 (a)
  !   movaps xmm3, xmm15                  ; copy p2 to xmm3 (b)

  !   shufps xmm2, xmm3, 10011001b        ; ay az by bz
  !   shufps xmm2, xmm2, 11011000b        ; ay by az bz
  
  !   mulps  xmm1, xmm2                   ; p0 ^ p2 packed 2D cross product (c0)

  !   movaps xmm2, xmm1                   ; copy c0 position to xmm2
  !   movaps xmm3, xmm1                   ; copy c0 position to xmm3
  
  !   shufps xmm2, xmm2, 01000100b        ; ax ay ax ay
  !   shufps xmm3, xmm3, 11101110b        ; az aw az aw
  
  !   subps  xmm2, xmm3                   ; packed subtraction 
    
  !   movaps xmm6, xmm12                 ; copy box to xmm6
  !   shufps xmm6, xmm6, 10100101b       ; yyzz mask (box)
  !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
  !   shufps xmm8, xmm8, 01011010b       ; zzyy mask (abs edge)
  !   mulps xmm6, xmm8                   ; packed multiply with box
  
  ; ------------------------------------------------------------------
  ; finalize compute radius
  ; ------------------------------------------------------------------
  ! finalize_radius:
  !   movss xmm8, xmm6                   ; r0
  !   psrldq xmm6, 8                     ; shift right 8 bytes
  !   addss xmm8, xmm6                   ; rad = r0 + r1
  !   shufps xmm8, xmm8, 00000000b       ; rad rad rad rad 
  !   movups  xmm4, [r10]                ; load 1100 sign bit mask is stored in r11
  !   mulps xmm8, xmm4                   ; -rad -rad rad rad
  !   jmp check_side                     ; check side
  
  
  ; ------------------------------------------------------------------
  ; check side
  ; ------------------------------------------------------------------
  ! check_side:
  !   movaps xmm3, xmm2                  ; copy xmm3 in xmm4
  !   pslldq xmm3, 4                     ; shift left 4 bytes
  !   comiss xmm3, xmm2                 ; compare first value

  !   jbe lower
  !   jmp greater
  
  ; ------------------------------------------------------------------
  ; test axis greater
  ; ------------------------------------------------------------------
  ! greater:      
  !   shufps xmm2, xmm2, 01000100b       ; x y x y 
  !   jmp separate_axis

  ; ------------------------------------------------------------------
  ; test axis lower
  ; ------------------------------------------------------------------
  ! lower:  
  !   shufps xmm2, xmm2, 00010001b       ; y x y x
  !   jmp separate_axis
   
  ; ------------------------------------------------------------------
  ; separate axis theorem
  ; ------------------------------------------------------------------
  ! separate_axis:
  !   movaps xmm9, xmm8                   ; make a copy of rad in xmm9
  !   shufps xmm8, xmm2, 11111010b        ; shuffle rad rad  max  max
  !   shufps xmm2, xmm9, 01010000b        ; shuffle min min -rad -rad
  
  !   cmpps xmm8, xmm2, 5                 ; packed compare radius < axis
  !   movmskps r12, xmm8                  ; move compare mask to register
  
  !   cmp r12, 15                         ; if not 15, an exclusion condition happened
  !   je next_edge
  !   jmp no_intersection                 ; discard    
  
  ! next_edge:
  !   inc r8                              ; increment edge counter
  !   cmp r8, 9                           ; if not last edge  
  ;   !   jl build_edge                       ; loop
  
  !   jmp intersection
  
  
EndMacro

;------------------------------------------------------------------
; Touch Box
;------------------------------------------------------------------
Procedure.b Touch(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32)
   
;      use separating axis theorem To test overlap between triangle And box
;      need To test For overlap in these directions:
;      
;      1) the {x,y,z}-directions (actually, since we use the AABB of the triangle
;      we do Not even need To test these)
;      2) normal of the triangle
;      3) crossproduct(edge from triangle, {x,y,z}-direction)
;      
;      this gives 3x3=9 more tests 
  Define.f min,max,p0,p1,p2,rad,fex,fey,fez
  
  ; This is the fastest branch on Sun 
  ; move everything so that the boxcenter is in (0,0,0)
  Define.v3f32 v0, v1, v2
  Define *origin.v3f32 = *box\origin
  Define *extend.v3f32 = *box\extend
  
  Vector3::Sub(v0, *a, *origin)
  Vector3::Sub(v1, *b, *origin)
  Vector3::Sub(v2, *c, *origin) 
  

  ; compute triangle edges
  Define.v3f32 e0, e1, e2
  Vector3::Sub(e0, v1, v0)
  Vector3::Sub(e1, v2, v1)
  Vector3::Sub(e2, v0, v2)
  
  fex = Abs(e0\x)
  fey = Abs(e0\y)
  fez = Abs(e0\z)
 
  AXISTEST_X01(e0\z, e0\y, fez, fey)
  
  ProcedureReturn #True
;   AXISTEST_Y02(e0\z, e0\x, fez, fex)
;   AXISTEST_Z12(e0\y, e0\x, fey, fex)
; 
;   fex = Abs(e1\x)
;   fey = Abs(e1\y)
;   fez = Abs(e1\z)
;     
;   AXISTEST_X01(e1\z, e1\y, fez, fey)
;   AXISTEST_Y02(e1\z, e1\x, fez, fex)
;   AXISTEST_Z00(e1\y, e1\x, fey, fex)
;     
;   fex = Abs(e2\x)
;   fey = Abs(e2\y)
;   fez = Abs(e2\z)
;   
;   AXISTEST_X20(e2\z, e2\y, fez, fey)
;   AXISTEST_Y10(e2\z, e2\x, fez, fex)
;   AXISTEST_Z12(e2\y, e2\x, fey, fex)
;   
;   ; first test overlap in the {x,y,z}-directions
;   ; find min, max of the triangle each direction, And test For overlap in
;   ; that direction -- this is equivalent To testing a minimal AABB around
;   ; the triangle against the AABB    
;   ; test in X-direction
;   FINDMINMAX(v0\x,v1\x,v2\x,min,max)
;   If(min>*extend\x Or max<-*extend\x) : ProcedureReturn #False : EndIf
;   
;  ; test in Y-direction
;   FINDMINMAX(v0\y,v1\y,v2\y,min,max)
;   If(min>*extend\y Or max<-*extend\y) : ProcedureReturn #False : EndIf
;   
;   ; test in Z-direction
;   FINDMINMAX(v0\z,v1\z,v2\z,min,max)
;   If(min>*extend\z Or max<-*extend\z) : ProcedureReturn #False : EndIf
;   
;   ; test If the box intersects the plane of the triangle
;   ; compute plane equation of triangle: normal*x+d=0
;   Protected normal.v3f32 
;   Vector3::Cross(normal, e0, e1)
;   
;   Define.v3f32 vmin,vmax
;   Define.f v
;   v = v0\x
;   If normal\x > 0.0 :  vmin\x = -*extend\x - v : vmax\x = *extend\x - v : Else : vmin\x = *extend\x -v : vmax\x = -*extend\x - v : EndIf
;   v = v0\y
;   If normal\y > 0.0 :  vmin\y = -*extend\y - v : vmax\y = *extend\y - v : Else : vmin\y = *extend\y -v : vmax\y = -*extend\y - v : EndIf
;   v = v0\z
;   If normal\z > 0.0 :  vmin\z = -*extend\z - v : vmax\z = *extend\z - v : Else : vmin\z = *extend\z -v : vmax\z = -*extend\z - v : EndIf
;   
;   If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
;   If Vector3::Dot(normal, vmax) < 0.0 : ProcedureReturn #False : EndIf
  
EndProcedure

Procedure.b TouchSSE(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32)

  Define offset.i = index * 3 * SizeOf(v3f32) 
  Define *origin.v3f32 = *box\origin
  Define *extend.v3f32 = *box\extend
  
  ! mov rcx, [p.v_offset]
  ! mov rax, [p.p_origin]             ; move center address to rax
  ! movups xmm11, [rax]               ; move center packed data to xmm11
  ! mov rax, [p.p_extend]             ; move boxhalfsize address to rax
  ! movups xmm12, [rax]               ; move boxhalfsize packed data to xmm12
  
;     ! mov r8, [p.p_indices]
;     EnableASM
;       MOV rax, triangle.l___128_sign_mask__  ; move sign mask to rsi register
;     DisableASM

  ! mov r9, math.l_sse_1111_sign_mask       ; move 1111 sign mask to r9 register 
  ! mov r10, math.l_sse_1100_negate_mask    ; move 1100 negate mask to r10 register
  ! mov r11, math.l_sse_0101_negate_mask    ; move 0101 negate mask to r11 register
  ! mov r12, math.l_sse_1010_negate_mask    ; move 1010 negate mask to r12 register
  
  ! xor r8, r8                              ; edge counter 
  
  ; ----------------------------------------------------
  ; load triangle
  ; ----------------------------------------------------
  ! mov rax, [p.p_a]                    ; move positions address to rax
  ! movups xmm13, [rax]                 ; move point a to xmm13
  ! mov rax, [p.p_b] 
  ! movups xmm14, [rax]                 ; move point b to xmm14
  ! mov rax, [p.p_c]  
  ! movups xmm15, [rax]                 ; move point c to xmm15
  
  ! subps xmm13, xmm11                  ; p0 = a - center
  ! subps xmm14, xmm11                  ; p1 = b - center 
  ! subps xmm15, xmm11                  ; p2 = c - center
    
  ! movaps xmm0, xmm14                  ; move p1 to xmm0
  ! subps xmm0, xmm13                   ; e0 = p1 - p0
  ! movaps xmm7, xmm0                   ; make a copy in xmm7
  ! movdqu  xmm6, [r9]                  ; load sign bit mask is stored in r9
  ! andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
   SSE_AXISTEST_X01() 
   
  ; ---------------------------------------------------------------------------------
  ; triangle intersect box
  ; ---------------------------------------------------------------------------------
  ! intersection:
  ProcedureReturn #True
  
  ; ---------------------------------------------------------------------------------
  ; triangle does NOT intersect box
  ; ---------------------------------------------------------------------------------
  ! no_intersection:
  ProcedureReturn #False

EndProcedure


Time::Init()


; Define numTris = 4
Define numTris = 1000000

Define *positions = AllocateMemory(numTris * 3 * SizeOf(v3f32))
Define *indices = AllocateMemory(numTris * 12)
Define *hits = AllocateMemory(numTris)
Global box.Geometry::Box_t

Vector3::Set(box\origin, 1,2,1)
Vector3::Set(box\extend,0.5,0.5,0.5)

; ax bx az bz

RandomSeed(2)
Define i
Define *p.v3f32

; CopyMemory(?problematic_tris, *positions, 12 * SizeOf(v3f32))
; For i=0 To numTris - 1
;   PokeL(*indices + (i*3+0)*4, i*3+0)
;   PokeL(*indices + (i*3+1)*4, i*3+1)
;   PokeL(*indices + (i*3+2)*4, i*3+2)
; Next

For i=0 To numTris - 1
  *p = *positions + (i*3)*SizeOf(v3f32)
  Vector3::Set(*p, -0.55, 0, 0.66)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
  PokeL(*indices + (i*3)*4, i*3)
  
  *p = *positions + (i*3+1)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
;   Vector3::Set(*p, 0.1, 1, 0.1)
  PokeL(*indices + (i*3+1)*4, i*3+1)
  
  *p = *positions + (i*3+2)*SizeOf(v3f32)
  Vector3::Set(*p, Random(50)-100, Random(50)-100, Random(50)-100)
  Vector3::ScaleInPlace(*p, 0.01)
;   Vector3::Set(*p, 0.55, 0,-0.66)
  PokeL(*indices + (i*3+2)*4, i*3+2)
Next

Procedure Divergence(Array datas1.s(1), Array datas2.s(1), nb)
  Define diverge.i = 0
  Define i
 
  For i = 0 To nb - 1
    If datas1(i) <> datas2(i)
      diverge + 1
    EndIf
  Next
  ProcedureReturn diverge
EndProcedure

Procedure.s Problematic(Array datas1.s(1), Array datas2.s(1), nb, *positions)
  Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32
  Define msg.s = ""
  For i = 0 To nb - 1
    If datas1(i) <> datas2(i)
      msg + Str(i)+Chr(10)
      *a = *positions + (i*3) * SizeOf(Math::v3f32)
      *b = *positions + (i*3+1) * SizeOf(Math::v3f32)
      *c = *positions + (i*3+2) * SizeOf(Math::v3f32)

;       msg + Str(Touch(box, *a, *b, *c)) +Chr(10)
;       msg + Str(TouchSSE(box, *a, *b, *c)) + Chr(10)
    EndIf
    
  Next
  
  If msg = "": msg = "GOOD" : EndIf
  ProcedureReturn msg
EndProcedure

Define output1.s
Define output2.s

Define.v3f32 *a, *b, *c
Define pbs.s, asms.s
Dim datas1.s(numTris)
Dim datas2.s(numTris)

Define T.d = Time::get()
Define msg1.s
For i=0 To numTris - 1
  *a = *positions + (i*3)*SizeOf(v3f32)
  *b = *positions + (i*3+1)*SizeOf(v3f32)
  *c = *positions + (i*3+2)*SizeOf(v3f32)
  datas1(i) = Str(Touch(box, *a, *b, *c))
;   pbs + Str(PeekB(*touch1+i))+" : "+StrF(output1\x,3)+","+StrF(output1\y,3)+","+StrF(output1\z,3)+","+StrF(output1\_unused,3)+Chr(10)
Next

Define T1.d = Time::Get() - t
Define msg2.s
T = Time::Get()
For i=0 To numTris - 1
  *a = *positions + (i*3)*SizeOf(v3f32)
  *b = *positions + (i*3+1)*SizeOf(v3f32)
  *c = *positions + (i*3+2)*SizeOf(v3f32)
  datas2(i) = Str(TouchSSE(box, *a, *b, *c))
;   asms + Str(PeekB(*touch2+i))+ " : "+StrF(output2\x,3)+","+StrF(output2\y,3)+","+StrF(output2\z,3)+","+StrF(output2\_unused,3)+Chr(10)
Next

MessageRequester("PROBLEMATIC", Problematic(datas1(), datas2(), nb, *positions))
; Define T2.d = Time::Get() - t
; Define msg.s
; msg + "Divergence : "+Str(Divergence(datas1(), datas2(), numTris))+" on "+Str(numTris)+Chr(10)
; msg+ StrD(T1)+" vs "+StrD(T2)+Chr(10)
; msg + Problematic(datas1(), datas2(), numTris, *positions)
; 
; MessageRequester("TEST MACROS",msg)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 342
; FirstLine = 321
; Folding = --
; EnableXP
; Constant = #USE_SSE=1