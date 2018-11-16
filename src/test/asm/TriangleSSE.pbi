XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/core/Time.pbi"
XIncludeFile "E:/Projects/RnD/Noodle/src/objects/Geometry.pbi"

UseModule Math
; UseModule Geometry

DataSection 
  x_axis_bits:
  Data.b %10100101    ; y z mask
  y_axis_bits:
  Data.b %10100000    ; x z mask
  z_axis_bits:
  Data.b %01010000    ; x y mask
  epsilon_bits:
  Data.f #F32_EPS, #F32_EPS, #F32_EPS, #F32_EPS
EndDataSection

DataSection
  problematic_tris:
  Data.f -0.6800000072,-0.719999969,-0.719999969,-0.5500000119,-0.8299999833,-0.8299999833,-0.6699999571,-0.5999999642,-0.5199999809
  Data.f -0.7899999619,-0.7299999595,-0.7299999595,-0.5199999809,-0.7599999905,-0.7599999905,-0.6399999857,-0.9499999881,-0.7999999523
  Data.f -0.7799999714,-0.5999999642,-0.5999999642,-0.6899999976,-0.8299999833,-0.8299999833,-0.5899999738,-0.8599999547,-0.719999969
  Data.f -0.5600000024,-0.8499999642,-0.8499999642,-0.969999969,-0.75,-0.75,-0.6699999571,-0.7699999809,-0.6499999762
  
EndDataSection


Macro FINDMINMAX(x0,x1,x2,min,max)
  min = x0
  max = x0
  If(x1<min) : min=x1 : ElseIf(x1>max) : max=x1 : EndIf
  If(x2<min) : min=x2 : ElseIf(x2>max) : max=x2 : EndIf
EndMacro 

; ======================== X-tests ========================
Macro AXISTEST_X01(a, b, fa, fb)
  p0 = a * v0\y - b * v0\z
  p2 = a * v2\y - b * v2\z
  If p0<p2 : min=p0 : max=p2
  Else : min=p2 : max=p0
  EndIf
  
  rad = fa * *extend\y + fb * *extend\z 
  If min>rad Or max<-rad : ProcedureReturn #False : EndIf
  
EndMacro

Macro AXISTEST_X20(a, b, fa, fb)
  p0 = a * v0\y - b * v0\z
  p1 = a * v1\y - b * v1\z
  If p0<p1 : min=p0 : max=p1
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *extend\y + fb * *extend\z
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
  
EndMacro

; ======================== Y-tests ========================
Macro AXISTEST_Y02(a, b, fa, fb)
  p0 = -a * v0\x + b * v0\z
  p2 = -a * v2\x + b * v2\z
  
  If p0<p2 : min=p0 : max=p2
  Else : min=p2 : max=p0
  EndIf
  
  rad = fa * *extend\x + fb * *extend\z
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf

EndMacro

Macro AXISTEST_Y10(a, b, fa, fb)
  p0 = -a * v0\x + b * v0\z
  p1 = -a * v1\x + b * v1\z
  If p0<p1 : min=p0 : max=p1 
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *extend\x + fb * *extend\z
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf

EndMacro
  
; ======================== Z-tests ========================
Macro AXISTEST_Z12(a, b, fa, fb)
  p1 = a * v1\x - b * v1\y
  p2 = a * v2\x - b * v2\y
  If p2<p1 : min=p2 : max=p1
  Else : min=p1 : max=p2
  EndIf

  rad = fa * *extend\x + fb * *extend\y
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf

EndMacro

Macro AXISTEST_Z00(a, b, fa, fb)
  p0 = a * v0\x - b * v0\y
  p1 = a * v1\x - b * v1\y
  If p0<p1 : min=p0 : max=p1
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *extend\x + fb * *extend\y
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf

EndMacro

;------------------------------------------------------------------
; Touch Box
;------------------------------------------------------------------
Procedure.b Touch(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32, *output.v3f32)
   
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
  AXISTEST_Y02(e0\z, e0\x, fez, fex)
  AXISTEST_Z12(e0\y, e0\x, fey, fex)

  fex = Abs(e1\x)
  fey = Abs(e1\y)
  fez = Abs(e1\z)
    
  AXISTEST_X01(e1\z, e1\y, fez, fey)
  AXISTEST_Y02(e1\z, e1\x, fez, fex)
  AXISTEST_Z00(e1\y, e1\x, fey, fex)
    
  fex = Abs(e2\x)
  fey = Abs(e2\y)
  fez = Abs(e2\z)
  
  AXISTEST_X20(e2\z, e2\y, fez, fey)
  AXISTEST_Y10(e2\z, e2\x, fez, fex)
  AXISTEST_Z12(e2\y, e2\x, fey, fex)
  
  ; first test overlap in the {x,y,z}-directions
  ; find min, max of the triangle each direction, And test For overlap in
  ; that direction -- this is equivalent To testing a minimal AABB around
  ; the triangle against the AABB    
  ; test in X-direction
  FINDMINMAX(v0\x,v1\x,v2\x,min,max)
  If(min>*extend\x Or max<-*extend\x) : ProcedureReturn #False : EndIf
  
  ; test in Y-direction
  FINDMINMAX(v0\y,v1\y,v2\y,min,max)
  If(min>*extend\y Or max<-*extend\y) : ProcedureReturn #False : EndIf
  
  ; test in Z-direction
  FINDMINMAX(v0\z,v1\z,v2\z,min,max)
  If(min>*extend\z Or max<-*extend\z) : ProcedureReturn #False : EndIf
;   
  ; test If the box intersects the plane of the triangle
  ; compute plane equation of triangle: normal*x+d=0
;   Protected normal.v3f32 
;   Vector3::Cross(normal, e0, e1)
  
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
;   
  ProcedureReturn #True
EndProcedure

Procedure.b TouchSSE(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32, *output.v3f32)
  Define hit = #False
  Define v.i
  Define cnt.i=0
  Define offset.i = index * 3 * SizeOf(v3f32) 
  Define *origin.v3f32 = *box\origin
  Define *extend.v3f32 = *box\extend
  
  *output\x = 0
  *output\y = 0
  *output\z = 0
  *output\_unused = 0
    
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
    
  ! build_edge:
  !   cmp r8, 3
  !   jl edge0
  !   cmp r8, 6
  !   jl edge1  
  !   cmp r8, 9
  !   jl edge2
  
  ; ----------------------------------------------------
  ; edge0
  ; ----------------------------------------------------
  ! edge0:
  !   cmp r8, 0
  !   je edge0_load
  !   jmp edge0_test
  
  ! edge0_load:
  !   movaps xmm0, xmm14                  ; move p1 to xmm0
  !   subps xmm0, xmm13                   ; e0 = p1 - p0
  !   movaps xmm7, xmm0                   ; make a copy in xmm7
  !   movdqu  xmm6, [r9]                  ; load sign bit mask is stored in r9
  !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
  !   jmp edge0_test
  
  ! edge0_test:
  !   cmp r8 , 0                          ; check edge counter
  !   je edge_axis_x01                       ; first axis
  !   cmp r8, 1                           ; check edge counter
  !   je edge_axis_y02                       ; second axis
  !   cmp r8, 2                           ; check edge counter
  !   je edge_axis_z12                       ; second axis
  
  ; ----------------------------------------------------
  ; edge1
  ; ----------------------------------------------------
  ! edge1:
  !   cmp r8, 3
  !   je edge1_load
  !   jmp edge1_test
  
  ! edge1_load:
  !   movaps xmm0, xmm15                  ; move p2 to xmm1
  !   subps xmm0, xmm14                   ; e1 = p2 - p1
  !   movaps xmm7, xmm0                   ; make a copy in xmm7
  
  !   movdqu  xmm6, [r9]                  ; load sign bit mask stored in r9
  !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
  !   jmp edge1_test
  
  ! edge1_test:
  !   cmp r8 , 3                         ; check edge counter
  !   je edge_axis_x01                     ; first axis
  !   cmp r8, 4                          ; check edge counter
  !   je edge_axis_y02                      ; second axis
  !   cmp r8, 5                          ; check edge counter
  !   je edge_axis_z00                      ; second axis
  
   
  ; ----------------------------------------------------
  ; edge2
  ; ----------------------------------------------------
  ! edge2:
  !   cmp r8, 6
  !   je edge2_load
  !   jmp edge2_test
  
  ! edge2_load:
  !   movaps xmm0, xmm13                  ; move p0 to xmm1
  !   subps xmm0, xmm15                   ; e2 = p0 - p2
  !   movaps xmm7, xmm0                   ; make a copy in xmm7
  !   movdqu  xmm6, [r9]                  ; load sign bit mask stored in r9
  !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
  !   jmp edge2_test

  ! edge2_test:
  !   cmp r8 , 6                          ; check edge counter
  !   je edge_axis_x20                       ; first axis
  !   cmp r8, 7                           ; check edge counter
  !   je edge_axis_y10                     ; second axis
  !   cmp r8, 8                           ; check edge counter
  !   je edge_axis_z12                       ; second axis

  ; ----------------------------------------------------
  ; edge_axis0_x01
  ; ----------------------------------------------------
  ! edge_axis_x01:
  !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
  !   shufps xmm2, xmm2, 01011010b        ; ez ez ey ey
  
  !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)

  !   shufps xmm3, xmm4, 10011001b        ; ay az by bz
  !   shufps xmm3, xmm3, 11011000b        ; ay by az bz
  
  !   jmp axis_test_sub
  
  ; ----------------------------------------------------
  ; edge_axis0_x20
  ; ----------------------------------------------------
  ! edge_axis_x20:
  !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
  !   shufps xmm2, xmm2, 01011010b        ; ez ez ey ey
  
  !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)

  !   shufps xmm3, xmm4, 10011001b        ; ay az by bz
  !   shufps xmm3, xmm3, 11011000b        ; ay by az bz
  
  !   jmp axis_test_sub
   
  ; ----------------------------------------------------
  ; edge_axis_y02
  ; ----------------------------------------------------
  ! edge_axis_y02:
  !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
  !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
  
  !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
  !   mulps xmm2, xmm6                    ; -ez -ez ex ex
  
  !   movups xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movups xmm4, xmm15                  ; copy p2 to xmm4 (b)

  !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
  !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
 
  !   jmp axis_test_add
  
  ; ----------------------------------------------------
  ; edge_axis_y10
  ; ----------------------------------------------------
  ! edge_axis_y10:
  !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
  !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
  
  !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
  !   mulps xmm2, xmm6                    ; -ez -ez ex ex
  
  !   movups xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movups xmm4, xmm14                  ; copy p1 to xmm4 (b)

  !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
  !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
 
  !   jmp axis_test_add
  
  ; ----------------------------------------------------
  ; edge_axis_z12
  ; ----------------------------------------------------
  ! edge_axis_z12:
  !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
  !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
  
  !   movups xmm3, xmm14                  ; copy p1 to xmm3 (a)
  !   movups xmm4, xmm15                  ; copy p2 to xmm4 (b)

  !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
  !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
  
  !   jmp axis_test_sub
  
  ; ----------------------------------------------------
  ; edge_axis_z00
  ; ----------------------------------------------------
  ! edge_axis_z00:
  !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
  !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
  
  !   movups xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movups xmm4, xmm14                  ; copy p1 to xmm4 (b)

  !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
  !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
  
  !   jmp axis_test_sub
 
  
  ; ----------------------------------------------------
  ; edge_axis4
  ; ----------------------------------------------------
  ! edge_axis4:
  !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
  !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
  
  !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
  !   mulps xmm2, xmm6                    ; -ez -ez ex ex
  
  !   movups xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movups xmm4, xmm14                  ; copy p1 to xmm4 (b)

  !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
  !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
 
  !   jmp axis_test_add
  
  ; ----------------------------------------------------
  ; axis test sub
  ; ----------------------------------------------------
  ! axis_test_sub:
  !   mulps  xmm2, xmm3                   ; p0 ^ p2 packed 2D cross product (c0)

  !   movaps xmm3, xmm2                   ; copy c0 position to xmm3
  !   movaps xmm4, xmm2                   ; copy c0 position to xmm4
  
  !   shufps xmm3, xmm3, 01000100b        ; ax ay ax ay
  !   shufps xmm4, xmm4, 11101110b        ; az aw az aw

  !   subps  xmm3, xmm4                   ; packed subtraction 
  !   jmp compute_radius
  
  ; ----------------------------------------------------
  ; axis test add
  ; ----------------------------------------------------
  ! axis_test_add:
  !   mulps  xmm2, xmm3                   ; p0 ^ p2 packed 2D cross product (c0)
 
  !   movaps xmm3, xmm2                   ; copy c0 position to xmm3
  !   movaps xmm4, xmm2                   ; copy c0 position to xmm4
  
  !   shufps xmm3, xmm3, 01000100b        ; c0x c0y c0x c0y
  !   shufps xmm4, xmm4, 11101110b        ; c0z c0w c0z c0w

  !   addps xmm3, xmm4                    ; packed addition
  !   jmp compute_radius
  
  ; ------------------------------------------------------------------
  ; compute radius and store it in xmm8
  ; ------------------------------------------------------------------
  ! compute_radius:
  !   cmp r8, 3
  !   jl compute_radius_e0
  !   cmp r8, 6
  !   jl compute_radius_e1
  !   cmp r8, 9
  !   jl compute_radius_e2
  
  ; ------------------------------------------------------------------
  ; compute radius edge0
  ; ------------------------------------------------------------------
  ! compute_radius_e0:
  !   cmp r8, 0
  !   je radius_0
  !   cmp r8, 1
  !   je radius_1
  !   cmp r8, 2
  !   je radius_2
  
  ; ------------------------------------------------------------------
  ; compute radius edge1
  ; ------------------------------------------------------------------
  ! compute_radius_e1:
  !   cmp r8, 3
  !   je radius_0
  !   cmp r8, 4
  !   je radius_1
  !   cmp r8, 5
  !   je radius_2
  
  ; ------------------------------------------------------------------
  ; compute radius edge2
  ; ------------------------------------------------------------------
  ! compute_radius_e2:
  !   cmp r8, 6
  !   je radius_0
  !   cmp r8, 7
  !   je radius_1
  !   cmp r8, 8
  !   je radius_2
  
  ; ------------------------------------------------------------------
  ; radius
  ; ------------------------------------------------------------------
  ! radius_0:
  !   movaps xmm6, xmm12                 ; copy box to xmm6
  !   shufps xmm6, xmm6, 10100101b       ; yyzz mask (box)
  !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
  !   shufps xmm8, xmm8, 01011010b       ; zzyy mask (abs edge)
  !   mulps xmm6, xmm8                   ; packed multiply with box
  !   jmp finalize_radius
  
  ! radius_1:      
  !   movaps xmm6, xmm12                 ; copy box to xmm6
  !   shufps xmm6, xmm6, 10100000b       ; xxzz mask (box)
  !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
  !   shufps xmm8, xmm8, 00001010b       ; zzxx mask (abs edge)

  !   mulps xmm6, xmm8                   ; packed multiply with box
  !   jmp finalize_radius
  
  ! radius_2:            
  !   movaps xmm6, xmm12                 ; copy box to xmm6
  !   shufps xmm6, xmm6, 01010000b       ; xxyy mask (box)
  !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
  !   shufps xmm8, xmm8, 00000101b       ; yyxx mask (abs edge)
  !   mulps xmm6, xmm8                   ; packed multiply with box
  !   jmp finalize_radius

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
  !   movaps xmm4, xmm3                  ; copy xmm3 in xmm4
  !   psrldq xmm4, 4                     ; shift right 4 bytes
  !   comiss xmm4, xmm3                 ; compare first value

  !   jb lower
  !   jmp greater
  
  ; ------------------------------------------------------------------
  ; test axis greater
  ; ------------------------------------------------------------------
  ! greater:      
  !   shufps xmm3, xmm3, 01000100b       ; x y x y 
  !   jmp separate_axis

  ; ------------------------------------------------------------------
  ; test axis lower
  ; ------------------------------------------------------------------
  ! lower:  
  !   shufps xmm3, xmm3, 00010001b       ; y x y x
  !   jmp separate_axis
   
  ; ------------------------------------------------------------------
  ; separate axis theorem
  ; ------------------------------------------------------------------
  ! separate_axis:
  !   movaps xmm9, xmm8                   ; make a copy of rad in xmm9
  !   shufps xmm8, xmm3, 11111010b        ; shuffle rad rad  max  max
  !   shufps xmm3, xmm9, 00000000b        ; shuffle min min -rad -rad
  
  !   cmpps xmm8, xmm3, 5                 ; packed compare radius < axis
  !   movmskps r12, xmm8                  ; move compare mask to register
  
  !   cmp r12, 15                         ; if not 15, an exclusion condition happened
  !   je next_edge
  !   jmp no_intersection                 ; discard    
  
  ! next_edge:
  !   inc r8                              ; increment edge counter
  !   cmp r8, 9                           ; if not last edge  
  !   jl build_edge                       ; loop
  !   jmp test_intersection

  ; ------------------------------------------------------------------
  ; axist test hit
  ; ------------------------------------------------------------------
  ! test_intersection:
  ; ---------------------------------------------------------------------------------
  ; load points
  ; ---------------------------------------------------------------------------------
  !   movaps xmm0, xmm13            ; make a copy of p0 in xmm0
  !   movaps xmm1, xmm13            ; make a copy of p0 in xmm1
  !   movaps xmm2, xmm14            ; make a copy of p1 in xmm2
  !   movaps xmm3, xmm15            ; make a copy of p2 in xmm3
  ; ---------------------------------------------------------------------------------
  ; load box
  ; ---------------------------------------------------------------------------------
  !   movaps xmm4, xmm12            ; copy box extend to xmm4
  !   movaps xmm5, xmm12            ; copy box extend to xmm5
  
  !   movups  xmm6, [math.l_sse_1111_negate_mask]; load 1111 negate mask
  !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  ; ---------------------------------------------------------------------------------
  ; find min/max
  ; ---------------------------------------------------------------------------------
  !   minps xmm0, xmm2              ; packed minimum
  !   minps xmm0, xmm3              ; packed minimum
    
  !   maxps xmm1, xmm2              ; packed maximum
  !   maxps xmm1, xmm3              ; packed maximum
  
  ; ---------------------------------------------------------------------------------
  ; early axis rejection
  ; ---------------------------------------------------------------------------------
  !   cmpps xmm4, xmm0, 1           ; packed compare boxhalfsize < minimum
  !   movmskps r12, xmm4            ; get comparison result
  
  !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
  !   jg no_intersection                        
  
  !   cmpps xmm1, xmm5, 1           ; packed compare maximum < -boxhalfsize
  !   movmskps r12, xmm1                
  
  !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
  !   jg no_intersection     
  
    ! jmp intersection

  ; ---------------------------------------------------------------------------------
  ; triangle-box intersection
  ; ---------------------------------------------------------------------------------
  !   movaps xmm0, xmm14          ; copy p1 to xmm0
  !   movaps xmm1, xmm15          ; copy p2 to xmm1
  
  ; ---------------------------------------------------------------------------------
  ;  compute edges
  ; ---------------------------------------------------------------------------------
  !   subps xmm0, xmm13             ; compute edge0 (p1 - p0)
  !   subps xmm1, xmm14             ; compute edge1 (p2 - p1)
  
  !   movaps xmm2,xmm0              ; copy edge0 to xmm2
  !   movaps xmm3,xmm1              ; copy edge1 to xmm3
  
  ; ---------------------------------------------------------------------------------
  ; compute triangle normal
  ; ---------------------------------------------------------------------------------
  !   shufps xmm0,xmm0,00001001b        ; exchange 2 and 3 element (a)
  !   shufps xmm1,xmm1,00010010b        ; exchange 1 and 2 element (b)
  !   mulps  xmm0,xmm1
           
  !   shufps xmm2,xmm2,00010010b        ; exchange 1 and 2 element (a)
  !   shufps xmm3,xmm3,00001001b        ; exchange 2 and 3 element (b)
  !   mulps  xmm2,xmm3
          
  !   subps  xmm0,xmm2                  ; cross product triangle normal

  ; ---------------------------------------------------------------------------------
  ; check side
  ; ---------------------------------------------------------------------------------
  !   xorps xmm6, xmm6
  !   cmpps xmm6, xmm0 , 1          ; check 0 < normal
  !   movmskps r12, xmm6
  
  !   movaps xmm4, xmm11            ; copy boxhalfsize to xmm7
  !   movaps xmm5, xmm11            ; copy boxhalfsize to xmm5 
  
  !   movups  xmm6, [math.l_sse_1111_negate_mask]; load 1111 negate mask
  !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
  
  !   subps xmm4, xmm13             ; box - p0
  !   subps xmm5, xmm13             ; -box - p0
  !   movaps xmm6, xmm4             ; make a copy
  
  !   cmp r12, 8
  !   jbe case_low
  !   jmp case_up
  
  ; ---------------------------------------------------------------------------------
  ; case 0-7
  ; ---------------------------------------------------------------------------------
  ! case_low:
  !   cmp r12, 0
  !   je case_0
  
  !   cmp r12, 1
  !   je case_1
  
  !   cmp r12, 2
  !   je case_2
  
  !   cmp r12, 3
  !   je case_3
  
  !   cmp r12, 4
  !   je case_4
  
  !   cmp r12, 5
  !   je case_5
  
  !   cmp r12, 6
  !   je case_6
  
  !   cmp r12, 7
  !   je case_7
  
  ; ---------------------------------------------------------------------------------
  ; case 8-15
  ; ---------------------------------------------------------------------------------
  ! case_up:
  !   cmp r12, 8
  !   je case_8
  
  !   cmp r12, 9
  !   je case_9
  
  !   cmp r12, 10
  !   je case_10
  
  !   cmp r12, 11
  !   je case_11
  
  !   cmp r12, 12
  !   je case_12
  
  !   cmp r12, 13
  !   je case_13
  
  !   cmp r12, 14
  !   je case_14
  
  !   cmp r12, 15
  !   je case_15
  
  ; ---------------------------------------------------------------------------------
  ; cases
  ; ---------------------------------------------------------------------------------
  ! case_0:
  !   blendps xmm4, xmm5, 0                    ; vmin = boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 15                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp normal_dot
  
  ! case_1:
  !   blendps xmm4, xmm5, 1                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 14                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_2:
  !   blendps xmm4, xmm5, 2                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 13                   ; vmax =  -boxx-p0x, boxy-p0y, -boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_3:
  !   blendps xmm4, xmm5, 3                   ; vmin = -boxx-p0x, -boxy-p0y, boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 12                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  -boxw-p0w
  !   jmp normal_dot
  
  ! case_4:
  !   blendps xmm4, xmm5, 4                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 11                  ; vmax = -boxx-p0x, -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_5:
  !   blendps xmm4, xmm5, 5                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 10                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_6:
  !   blendps xmm4, xmm5, 6                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 9                   ; vmax = -boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_7:
  !   blendps xmm4, xmm5, 7                   ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   blendps xmm6, xmm5, 8                   ; vmax = boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
  !   jmp normal_dot
  
  ! case_8:
  !   blendps xmm4, xmm5, 8                   ; vmin = boxx-p0x, boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 7                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_9:
  !   blendps xmm4, xmm5, 9                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 6                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_10:
  !   blendps xmm4, xmm5, 10                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 5                   ; vmax =  -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_11:
  !   blendps xmm4, xmm5, 11                   ; vmin =-boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 4                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  boxw-p0w
  !   jmp normal_dot
  
  ! case_12:
  !   blendps xmm4, xmm5, 12                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 3                   ; vmax =  -boxx-p0x, -boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_13:
  !   blendps xmm4, xmm5, 13                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 2                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_14:
  !   blendps xmm4, xmm5, 14                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 1                   ; vmax =  -boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! case_15:
  !   blendps xmm4, xmm5, 15                  ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
  !   blendps xmm6, xmm5, 0                   ; vmax = boxx-p0x, boxy-p0y, boxz-p0z, boxw-p0w
  !   jmp normal_dot
  
  ! normal_dot:
  !   jmp normal_dot_min
  
  ; ---------------------------------------------------------------------------------
  ; normal dot vmin > 0 ?
  ; ---------------------------------------------------------------------------------
  ! normal_dot_min:
  !   movups xmm7, xmm0                       ; copy normal to xmm7
  !   mulps xmm7, xmm4                        ; compute normal dot vmin
  !   haddps xmm7, xmm7
  !   haddps xmm7, xmm7
  !   xorps xmm8, xmm8
  
  !   comiss xmm8, xmm7                       ; 0<=vmin
  !   jbe no_intersection                     ; branch if lower or equal
  !   jmp normal_dot_max                      ; branch if greater

  ; ---------------------------------------------------------------------------------
  ; normal dot vmax >= 0 ?
  ; ---------------------------------------------------------------------------------
  ! normal_dot_max:
  !   movups xmm7, xmm0                       ; copy normal to xmm7
  !   mulps xmm7, xmm6                        ; compute normal dot vmax
  !   haddps xmm7, xmm7
  !   haddps xmm7, xmm7                       ; dot 
  !   xorps xmm8, xmm8
  !   comiss xmm8, xmm7                      ; packed compare
  !   jb intersection                        ; 0 < vmax
  !   jmp no_intersection                    ; branch if lower
  
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
Define numTris = 24000000

Define *positions = AllocateMemory(numTris * 3 * SizeOf(v3f32))
Define *indices = AllocateMemory(numTris * 12)
Define *hits = AllocateMemory(numTris)
Global box.Geometry::Box_t

Vector3::Set(box\origin, 0,0,0)
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

Procedure Divergence(*A, *B, nb)
  Define diverge.i = 0
  Define i
 
  For i = 0 To nb - 1
    If PeekB(*A+i) <> PeekB(*B+i)
      diverge + 1
    EndIf
  Next
  ProcedureReturn diverge
EndProcedure

Procedure.i Problematic(*X, *Y, nb, *positions)
  Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32
  Define pblm.i = 0
  Define output.v3f32
  For i = 0 To nb - 1
    If PeekB(*X+i) <> PeekB(*Y+i)
      *a = *positions + (i*3) * SizeOf(Math::v3f32)
      *b = *positions + (i*3+1) * SizeOf(Math::v3f32)
      *c = *positions + (i*3+2) * SizeOf(Math::v3f32)
      pblm + 1
    EndIf
    
  Next
  ProcedureReturn pblm
EndProcedure


Define output1.v3f32
Define output2.v3f32

Define.v3f32 *a, *b, *c
Define pbs.s, asms.s
Dim touch1.b(numTris)
Dim touch2.b(numTris)
Define hits1 = 0
Define hits2 = 0
Define T.d = Time::get()
Define msg1.s
For i=0 To numTris - 1
  *a = *positions + (i*3)*SizeOf(v3f32)
  *b = *positions + (i*3+1)*SizeOf(v3f32)
  *c = *positions + (i*3+2)*SizeOf(v3f32)
  touch1(i) = Touch(box, *a, *b, *c, output1)
  If touch1(i) : hits1 + 1 : EndIf
  
;   pbs + Str(PeekB(*touch1+i))+" : "+StrF(output1\x,3)+","+StrF(output1\y,3)+","+StrF(output1\z,3)+","+StrF(output1\_unused,3)+Chr(10)
Next
Define T1.d = Time::Get() - t
Define msg2.s
T = Time::Get()
For i=0 To numTris - 1
  *a = *positions + (i*3)*SizeOf(v3f32)
  *b = *positions + (i*3+1)*SizeOf(v3f32)
  *c = *positions + (i*3+2)*SizeOf(v3f32)
  touch2(i) = TouchSSE(box, *a, *b, *c, output2)
  If touch2(i) : hits2 + 1 : EndIf
;   asms + Str(PeekB(*touch2+i))+ " : "+StrF(output2\x,3)+","+StrF(output2\y,3)+","+StrF(output2\z,3)+","+StrF(output2\_unused,3)+Chr(10)
Next
Define T2.d = Time::Get() - t
Define msg.s = "EQUAL : "+Str(CompareMemory(@touch1(0), @touch2(0), numTris))+Chr(10)
msg + "HITS 1 : "+Str(hits1)+", HITS 2 : "+Str(hits2)+Chr(10)
msg+ StrD(T1)+" vs "+StrD(T2)+Chr(10)
msg + "PROBLEMATICS : "+Str(Problematic(@touch1(0), @touch2(0), numTris, *positions))

MessageRequester("Touch",msg)
; Debug pbs
; Debug "-----------------------------------------------------"
; Debug asms

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 889
; FirstLine = 871
; Folding = --
; EnableXP
; DisableDebugger
; Constant = #USE_SSE=1