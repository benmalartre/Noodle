XIncludeFile "E:/Projects/RnD/Noodle/src/core/Math.pbi"
; XIncludeFile "E:/Projects/RnD/Noodle/src/objects/Geometry.pbi"

UseModule Math
; UseModule Geometry

DataSection 
  x_axis_bits:
  Data.b %10100101    ; y z mask
  y_axis_bits:
  Data.b %10100000    ; x z mask
  z_axis_bits:
  Data.b %01010000    ; x y mask
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
  
  rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
  *output\x = rad
  *output\y = rad
  *output\z = rad
  
  
  If min>rad Or max<-rad : ProcedureReturn #False : EndIf
EndMacro

Macro AXISTEST_X20(a, b, fa, fb)
  p0 = a * v0\y - b * v0\z
  p1 = a * v1\y - b * v1\z
  If p0<p1 : min=p0 : max=p1
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
  *output\x = rad
  *output\y = rad
  *output\z = rad
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
  
EndMacro

; ======================== Y-tests ========================
Macro AXISTEST_Y02(a, b, fa, fb)
  p0 = -a * v0\x + b * v0\z
  p2 = -a * v2\x + b * v2\z
  
  If p0<p2 : min=p0 : max=p2
  Else : min=p2 : max=p0
  EndIf
  
  rad = fa * *boxhalfsize\x + fb * *boxhalfsize\z
  *output\x = rad
  *output\y = rad
  *output\z = rad
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
EndMacro

Macro AXISTEST_Y10(a, b, fa, fb)
  p0 = -a * v0\x + b * v0\z
  p1 = -a * v1\x + b * v1\z
  If p0<p1 : min=p0 : max=p1 
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *boxhalfsize\x + fb * *boxhalfsize\z
  *output\x = rad
  *output\y = rad
  *output\z = rad
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
EndMacro
  
; ======================== Z-tests ========================
Macro AXISTEST_Z12(a, b, fa, fb)
  p1 = a * v1\x - b * v1\y
  p2 = a * v2\x - b * v2\y
  If p2<p1 : min=p2 : max=p1
  Else : min=p1 : max=p2
  EndIf
  
  rad = fa * *boxhalfsize\x + fb * *boxhalfsize\y

  *output\x = rad
  *output\y = rad
  *output\z = rad
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
EndMacro

Macro AXISTEST_Z00(a, b, fa, fb)
  p0 = a * v0\x - b * v0\y
  p1 = a * v1\x - b * v1\y
  If p0<p1 : min=p0 : max=p1
  Else : min=p1 : max=p0
  EndIf
  
  rad = fa * *boxhalfsize\x + fb * *boxhalfsize\y
  *output\x = rad
  *output\y = rad
  *output\z = rad
  If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
EndMacro

;------------------------------------------------------------------
; Touch Box
;------------------------------------------------------------------
Procedure.f Touch(*positions, *indices, index.i, *center.v3f32, *boxhalfsize.v3f32, *output.v3f32)
   
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
  Define.v3f32 *a = *positions + index * 64 
  Define.v3f32 *b = *positions + index * 64 + 16 
  Define.v3f32 *c = *positions + index * 64 + 32
  
  Vector3::Sub(v0, *a, *center)
  Vector3::Sub(v1, *b, *center)
  Vector3::Sub(v2, *c, *center)

  ; compute triangle edges
  Define.v3f32 e0
  Vector3::Sub(e0, v1, v0)
  
;   Vector3::SetFromOther(*output, e0)
  
  ;  test the 9 tests first (this was faster) 
  fex = Abs(e0\x)
  fey = Abs(e0\y)
  fez = Abs(e0\z)
  
  AXISTEST_X01(e0\z, e0\y, fez, fey)
  AXISTEST_Y02(e0\z, e0\x, fez, fex)
  AXISTEST_Z12(e0\y, e0\x, fey, fex)


  Define.v3f32 e1
  Vector3::Sub(e1, v2, v1)
  
  fex = Abs(e1\x)
  fey = Abs(e1\y)
  fez = Abs(e1\z)
  
  Vector3::Echo(e1, "Edge1")
  
  AXISTEST_X01(e1\z, e1\y, fez, fey)
  AXISTEST_Y02(e1\z, e1\x, fez, fex)
  AXISTEST_Z00(e1\y, e1\x, fey, fex)
  
  Define.v3f32 e2
  Vector3::Sub(e2, v0, v2)
  Vector3::Echo(e2, "e2")
  
  fex = Abs(e2\x)
  fey = Abs(e2\y)
  fez = Abs(e2\z)
  
  AXISTEST_X20(e2\z, e2\y, fez, fey)
  AXISTEST_Y10(e2\z, e2\x, fez, fex)
  AXISTEST_Z12(e2\y, e2\x, fey, fex)
; 
;   ; first test overlap in the {x,y,z}-directions
;   ; find min, max of the triangle each direction, And test For overlap in
;   ; that direction -- this is equivalent To testing a minimal AABB around
;   ; the triangle against the AABB    
;   ; test in X-direction
;   FINDMINMAX(v0\x,v1\x,v2\x,min,max)
;   If(min>*boxhalfsize\x Or max<-*boxhalfsize\x) : ProcedureReturn #False : EndIf
;   
;  ; test in Y-direction
;   FINDMINMAX(v0\y,v1\y,v2\y,min,max)
;   If(min>*boxhalfsize\y Or max<-*boxhalfsize\y) : ProcedureReturn #False : EndIf
;   
;   ; test in Z-direction
;   FINDMINMAX(v0\z,v1\z,v2\z,min,max)
;   If(min>*boxhalfsize\z Or max<-*boxhalfsize\z) : ProcedureReturn #False : EndIf
;   
;   ; test If the box intersects the plane of the triangle
;   ; compute plane equation of triangle: normal*x+d=0
;   Protected normal.v3f32 
;   Vector3::Cross(normal, e0, e1)
;   
;   Define.v3f32 vmin,vmax
;   Define.f v
;   v = v0\x
;   If normal\x > 0.0 :  vmin\x = -*boxhalfsize\x - v : vmax\x = *boxhalfsize\x - v : Else : vmin\x = *boxhalfsize\x -v : vmax\x = -*boxhalfsize\x - v : EndIf
;   v = v0\y
;   If normal\y > 0.0 :  vmin\y = -*boxhalfsize\y - v : vmax\y = *boxhalfsize\y - v : Else : vmin\y = *boxhalfsize\y -v : vmax\y = -*boxhalfsize\y - v : EndIf
;   v = v0\z
;   If normal\z > 0.0 :  vmin\z = -*boxhalfsize\z - v : vmax\z = *boxhalfsize\z - v : Else : vmin\z = *boxhalfsize\z -v : vmax\z = -*boxhalfsize\z - v : EndIf
;   
;   If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
;   If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
    ProcedureReturn #True
EndProcedure


Procedure.f TouchTriangle(*positions, *indices, index.i, *center.v3f32, *boxhalfsize.v3f32, *output.v3f32)
  Define hit = #False
  Define v.f
  Define cnt.i=0
  index * 64
  
  ! mov rcx, [p.v_index]
  ! mov rax, [p.p_center]             ; move center address to rax
  ! movups xmm11, [rax]               ; move center packed data to xmm11
  ! mov rax, [p.p_boxhalfsize]        ; move boxhalfsize address to rax
  ! movups xmm12, [rax]               ; move boxhalfsize packed data to xmm12
  ! mov rax, [p.p_positions]          ; move positions address to rax
  ! mov rdx, [p.p_output]
  
;     ! mov r8, [p.p_indices]
;     EnableASM
;       MOV rax, triangle.l___128_sign_mask__  ; move sign mask to rsi register
;     DisableASM

  ! mov r9, math.l_sse_1111_sign_mask       ; move 1111 sign mask to r9 register 
  ! mov r10, math.l_sse_1100_negate_mask    ; move 1100 negate mask to r10 register
  ! mov r11, math.l_sse_1010_negate_mask    ; move 1010 negate mask to r11 register
  
  
  ! xor r8, r8                              ; edge counter 
  ! xorps xmm10, xmm10                      ; will store triangle bounding box
  
  ; ----------------------------------------------------
  ; touch array start
  ; ----------------------------------------------------
  !toucharray_start:
  !   jmp load_triangle
 
  ; ----------------------------------------------------
  ; load triangle
  ; ----------------------------------------------------
  !load_triangle:
  !   movups xmm13, [rax+rcx]             ; move point a to xmm13
  !   movups xmm14, [rax+rcx+16]          ; move point b to xmm14
  !   movups xmm15, [rax+rcx+32]          ; move point c to xmm15
  
  !   subps xmm13, xmm11                  ; p0 = a - center
  !   subps xmm14, xmm11                  ; p1 = b - center 
  !   subps xmm15, xmm11                  ; p2 = c - center
  !   jmp build_edge
  
  ! build_edge:
  !   cmp r8, 3
  !   jl edge0
  
  !   cmp r8, 6
  !   jl edge1
    
  !   cmp r8, 9
  !   jl edge2

  !   jmp test_miss
  
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
  !   je edge_axis0                      ; first axis
  !   cmp r8, 1                           ; check edge counter
  !   je edge_axis1                      ; second axis
  !   cmp r8, 2                           ; check edge counter
  !   je edge_axis2                      ; second axis
  ! jmp exit
  
  
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
  !   je edge_axis0                      ; first axis
  !   cmp r8, 4                          ; check edge counter
  !   je edge_axis1                      ; second axis
  !   cmp r8, 5                          ; check edge counter
  !   je edge_axis2                      ; second axis
  ! jmp exit
   
  ; ----------------------------------------------------
  ; edge2
  ; ----------------------------------------------------
  ! edge2:
  !   cmp r8, 6
  !   je edge2_load
  !   jmp edge2_test
  
  ! edge2_load:
  !   movaps xmm0, xmm13                  ; move p2 to xmm1
  !   subps xmm0, xmm15                   ; e1 = p0 - p2
  !   movaps xmm7, xmm0                   ; make a copy in xmm7
  
  !   movdqu  xmm6, [r9]                  ; load sign bit mask stored in r9
  !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
  !   jmp edge2_test

  ! edge2_test:
  !   cmp r8 , 6                          ; check edge counter
  !   je edge_axis0                      ; first axis
  !   cmp r8, 7                           ; check edge counter
  !   je edge_axis1                      ; second axis
  !   cmp r8, 8                           ; check edge counter
  !   je edge_axis2                      ; second axis
  !   jmp exit
   
  ; ----------------------------------------------------
  ; edge_axis0
  ; ----------------------------------------------------
  ! edge_axis0:
  !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
  !   shufps xmm2, xmm2, 01011010b        ; ez ez ey ey
  
  !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)

  !   shufps xmm3, xmm4, 10011001b        ; ay az by bz
  !   shufps xmm3, xmm3, 11011000b        ; ay by az bz
  
  !   jmp axis_test_sub
   
  ; ----------------------------------------------------
  ; edge_axis1
  ; ----------------------------------------------------
  ! edge_axis1:
  !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
  !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex

  !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r9
  !   mulps xmm2, xmm6                    ; -e0z -e0z e0x e0x

  !   movups xmm3, xmm13                  ; copy p0 to xmm3 (a)
  !   movups xmm4, xmm15                  ; copy p2 to xmm4 (b)

  !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
  !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
  
  !   jmp axis_test_add
  
  ; ----------------------------------------------------
  ; edge_axis2
  ; ----------------------------------------------------
  ! edge_axis2:
  !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
  !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
  
  !   movups xmm3, xmm14                  ; copy p1 to xmm3 (a)
  !   movups xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
  !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
  !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
  
  !   jmp axis_test_sub
  
  
  ; ----------------------------------------------------
  ; axis test sub
  ; ----------------------------------------------------
  ! axis_test_sub:
  !   mulps  xmm2, xmm3                   ; p0 ^ p2 packed 2D cross product (c0)
  !   movaps xmm3, xmm2                   ; copy c0 position to xmm3
  !   movaps xmm4, xmm2                   ; copy c0 position to xmm4
  
  !   shufps xmm3, xmm3, 00010001b        ; ax ay ax ay
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
  
  !   shufps xmm3, xmm3, 00010001b        ; c0x c0y c0x c0y
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
  !   jmp exit
  
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
  !   jmp exit
  
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
  !   jmp exit
  
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
    
  !   psrldq xmm6, 8                     ; shift right
  !   movss xmm9, xmm6                   ; r0
  !   addss xmm8, xmm9                   ; rad = r0 + r1
  !   shufps xmm8, xmm8, 00000000b       ; rad rad rad rad
  !   movups [rdx], xmm8
  !   jmp negate_max_radius              ; negate max radius
  
  ; ------------------------------------------------------------------
  ; negate max radius
  ; ------------------------------------------------------------------
  ! negate_max_radius:
  !   movups  xmm4, [r11]               ; load 1010 sign bit mask is stored in r11
  !   mulps xmm8, xmm4                  ; rad -rad rad -rad
  !   jmp check_side
  
  ; ------------------------------------------------------------------
  ; check side
  ; ------------------------------------------------------------------
  ! check_side:
  !   movaps xmm4, xmm3                  ; copy xmm3 in xmm4
  !   psrldq xmm4, 4                     ; shift left 4 bytes
  !   ucomiss xmm4, xmm3                 ; compare first value
  !   jp greater                         ; branch is greater
  !   jmp lower                          ; branch is lower
  
  
  ; ------------------------------------------------------------------
  ; test axis greater
  ; ------------------------------------------------------------------
  ! greater:
  !   shufps xmm3, xmm3, 00010001b            ; y x y x
  !   minps xmm10, xmm3
  !   jmp separate_axis
  
  ; ------------------------------------------------------------------
  ; test axis lower
  ; ------------------------------------------------------------------
  ! lower:
  !   shufps xmm3, xmm3, 01000100b            ; x y x y
  !   jmp separate_axis
  
  
  ; ------------------------------------------------------------------
  ; separate axis theorem
  ; ------------------------------------------------------------------
  ! separate_axis:
  !   cmpps xmm8, xmm3, 1               ; packed compare radius < axis
  !   movmskps r12, xmm8                ; move compare mask to register
  
  !   cmp r12, 16                       
  !   je test_miss                      ; check intersection    
  
  !   add r8, 1                         ; increment edge counter
  !   cmp r8, 9                         ; if not last edge  
  !   jl next_triangle
  !   jmp test_hit
  
  ; ------------------------------------------------------------------
  ; next triangle
  ; ------------------------------------------------------------------
  ! next_triangle:
  !   xorps xmm10, xmm10                ; reset triangle bbox
  !   jl build_edge                     ; process next  
  
  ; ------------------------------------------------------------------
  ; check box intersection
  ; ------------------------------------------------------------------
  ! check_box_x:
  
  ;   FINDMINMAX(v0\x,v1\x,v2\x,min,max)
;   If(min>*boxhalfsize\x Or max<-*boxhalfsize\x) : ProcedureReturn #False : EndIf

  ; ------------------------------------------------------------------
  ; axis test miss
  ; ------------------------------------------------------------------
  ! test_miss:
  !   mov [p.v_hit], byte 0
  !   jmp exit
  
  ; ------------------------------------------------------------------
  ; axist test hit
  ; ------------------------------------------------------------------
  ! test_hit:
  !   mov [p.v_hit], byte 1
  !   jmp exit

  ; ------------------------------------------------------------------
  ; exit
  ; ------------------------------------------------------------------
  ! exit:
  ProcedureReturn hit
EndProcedure

Define numTris = 128
Define *positions = AllocateMemory(numTris * 3 * SizeOf(v3f32))
Define *indices = AllocateMemory(numTris * 12)
Define *hits = AllocateMemory(numTris)

Define center.v3f32
Define halfsize.v3f32
Vector3::Set(center, 0,0.5,0)
Vector3::Set(halfsize,10,10,10)

; ax bx az bz

Define i
Define *p.v3f32
For i=0 To numTris - 1
  *p = *positions + (i*3)*SizeOf(v3f32)
;   Vector3::Set(*p, -0.55, 0, 0.66)
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

Define output1.v3f32
Define output2.v3f32
Define pbs.s, asms.s
For i=0 To numTris - 1
  Touch(*positions, *indices, i, center, halfsize, output1)
  pbs + "PB : "+StrF(output1\x,3)+","+StrF(output1\y,3)+","+StrF(output1\z,3)+Chr(10)
Next

For i=0 To numTris - 1
  TouchTriangle(*positions, *indices, i, center, halfsize, output2)
  asms + "ASM : "+StrF(output2\x,3)+","+StrF(output2\y,3)+","+StrF(output2\z,3)+Chr(10)
Next

Debug pbs
Debug "-----------------------------------------------------"
Debug asms

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 575
; FirstLine = 528
; Folding = --
; EnableXP