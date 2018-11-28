


XIncludeFile "../../core/Application.pbi"
XIncludeFile "../../libs/FTGL.pbi"
XIncludeFile "../../opengl/Framebuffer.pbi"
XIncludeFile "../../objects/Polymesh.pbi"
XIncludeFile "../../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i
Global diff.f

Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t

Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
Global *query.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
Global *closest.CArray::CArrayV3F32 = CArray::newCArrayV3F32()


Global numQuery.i = 256
Global queryMode.i
Global worldPos.v3f32

Enumeration 
  #QUERY_MODE_RANDOM
  #QUERY_MODE_CIRCLE
EndEnumeration

Global ray.Geometry::Ray_t
Global plane.Geometry::Plane_t

Vector3::Set(plane\normal, 0,1,0)

;------------------------------------------------------------------
; Closest Point
;------------------------------------------------------------------
Procedure ClosestPointSSE(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
  ! closestpointsse:
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
  
  ! movaps xmm7, xmm13              ; copy a to xmm7
  ! subps xmm7, xmm10               ; compute v0 : a - pnt
  ! xorps xmm6, xmm6                ; will store d0,d1,d2,d3
  
  ; dot product d0 : edge0 * edge0                  
  ! movaps xmm0, xmm8               ; make a copy of edge0 in xmm0
  ! mulps xmm0, xmm8                ; product edge0 * edge0
  ! haddps xmm0, xmm0               ; horizontal add first pass
  ! haddps xmm0, xmm0               ; second pass : d0 stored in first element of xmm0
  ! blendps xmm6, xmm0, 0001b       ; put d0 in first element of xmm6
  
  ; dot product d1 : edge0 * edge1                 
  ! movaps xmm0, xmm8               ; make a copy of edge0 in xmm0
  ! mulps xmm0, xmm9                ; product edge0 * edge1
  ! haddps xmm0, xmm0               ; horizontal add first pass
  ! haddps xmm0, xmm0               ; second pass : d1 stored in first element of xmm0
  ! shufps xmm0, xmm0, 00000000b    ; fill xmm0 with d1
  ! blendps xmm6, xmm0, 0010b       ; put d1 in second element of xmm6
  
  ; dot product d2 : edge1 * edge1                 
  ! movaps xmm0, xmm9               ; make a copy of edge1 in xmm0
  ! mulps xmm0, xmm9                ; product edge1 * edge1
  ! haddps xmm0, xmm0               ; horizontal add first pass
  ! haddps xmm0, xmm0               ; second pass : d2 stored in first element of xmm0
  ! shufps xmm0, xmm0, 00000000b    ; fill xmm0 with d2
  ! blendps xmm6, xmm0, 0100b       ; put d2 in third element of xmm6
  
  ; dot product d3 : edge0 * v0                 
  ! movaps xmm0, xmm8               ; make a copy of edge0
  ! mulps xmm0, xmm7                ; product edge0 * v0
  ! haddps xmm0, xmm0               ; horizontal add first pass
  ! haddps xmm0, xmm0               ; second pass : d3 stored in first element of xmm0
  ! blendps xmm6, xmm0, 1000b       ; put d3 in fourth element of xmm6
  
  ; dot product d4 : edge1 * v0                 
  ! movaps xmm5, xmm9               ; make a copy of edge1
  ! mulps xmm5, xmm7                ; product edge1 * v0
  ! haddps xmm5, xmm5               ; horizontal add first pass
  ! haddps xmm5, xmm5               ; second pass : d4 stored in first element of xmm5
  
  ; compute determinant
  ! movaps xmm0, xmm6               ; make a copy of (d0 d1 d2 d3)
  ! movaps xmm1, xmm6               ; make a copy of (d0 d1 d2 d3)
  ! shufps xmm0, xmm0, 01000100b    ; shuffle (d0 d1 d0 d1)
  ! shufps xmm1, xmm1, 01100110b    ; shuffle (d2 d1 d2 d1)
  
  ! mulps xmm0, xmm1                
  ! hsubps xmm0, xmm1               ; det = d0*d2 - d1*d1
  ! shufps xmm0, xmm0, 00000000b
  ! blendps xmm5, xmm0, 1000b       ; put det in fourth element of xmm5
  
  ! movaps xmm0, xmm6               ; make a copy of (d0 d1 d2 d3)
  ! movaps xmm1, xmm5               ; make a copy of (d4 ? ? det)
  ! shufps xmm1, xmm0, 11110000b    ; shuffle (d4 d4 d3 d3)
  ! shufps xmm1, xmm1, 00111100b    ; shuffle (d4 d3 d3 d4)
  ! shufps xmm0, xmm0, 00100101b    ; shuffle (d1 d1 d2 d0)
  
  ! mulps xmm0, xmm1                ; packed multiply
  ! movaps xmm1, xmm0               ; copy in xmm1
  ! shufps xmm0, xmm0, 00010001b    ; shuffle (d1*d3 d1*d4 d1*d1 d1*d4)
  ! shufps xmm1, xmm1, 10111011b    ; shuffle (d0*d4 d2*d2 d0*d4 d2*d3)
  
  ! subps xmm0, xmm1                ; compute s (d1*d4-d3*d3) and t (d1*d3-d0*d4)
  ! blendps xmm5, xmm0, 0110b       ; put them in second and third elements of xmm5 
  
  ! movaps xmm0, xmm5               ; make  a copy of (d4 s t det) in xmm0
  ! shufps xmm0, xmm0, 10011001b    ; shuffle it : (s t s t)
  ! haddps xmm0, xmm0               ; horizontal addition ( s + t )
  ! movaps xmm1, xmm5               ; make  a copy of (d4 s t det) in xmm1
  ! shufps xmm1, xmm1, 11111111b    ; shuffle it : (det det det det)
  ! comiss xmm0, xmm1               ; compare first element s + t < det
  
  ! jb closest_point_case_1
  ! jmp closest_point_case_2
  
  ; --------------------------------------------------------------------------------------------
  ; case 1 : (s + t) < det
  ; --------------------------------------------------------------------------------------------
  ! .closest_point_case_1:
  !   movaps xmm0, xmm5               ; make  a copy of (d4 s t det) in xmm0
  !   shufps xmm0, xmm0, 00111001b    ; shuffle it (s t det d4)
  !   movaps xmm1, xmm6               ; make a copy of (d0 d1 d2 d3) in xmm1
  !   shufps xmm1, xmm1, 10110100b    ; shuffle it (d0 d1 d2 d3)
  !   blendps xmm0, xmm1, 0100b       ; blend ( s t d3 d4)
  !   movups xmm1, [math.l_sse_zero_vec]
  !   cmpps xmm0, xmm1, 1             ; packed compare (s t d3 d4) < (0,0,0,0)
  !   movmskps r12, xmm0              ; move comparison mask to r12 register
  
  !   test r12, 1                     ; check s < 0.0
  !   jnz case1_s_below_zero
  !   jmp case1_s_upon_zero
  
  ; case 1 : s < 0
  ! .case1_s_below_zero:
  !   test r12, 2                     ; check t < 0.0
  !   jnz case1_t_below_zero          ; if true
  !   jmp case1_t_upon_zero
  
  ; case 1 : s >= 0
  ! .case1_s_upon_zero:
  !   test r12, 2                     
  !   jnz closest_point_case1_output_one
  !   jmp closest_point_case1_output_three
  
  ; case 1 :  t < 0
  ! .case1_t_below_zero:
  !   test r12, 4                     ; check d < 0.0
  !   jnz closest_point_case1_output_one
  !   jmp closest_point_case1_output_two
  
  ; case 1 : t >= 0
  ! .case1_t_upon_zero:
  !   jmp closest_point_case1_output_two
  
  ; --------------------------------------------------------------------------------------------
  ; case 1 outputs
  ; --------------------------------------------------------------------------------------------
  ! .closest_point_case1_output_one:
  !   movaps xmm0, xmm6             ; make a copy of (d0 d1 d2 d3)
  !   movaps xmm1, xmm6             ; make a copy of (d0 d1 d2 d3)
  !   movups xmm2, [math.l_sse_1111_negate_mask]
  !   shufps xmm0, xmm0, 11111111b  ; shuffle (d3 d3 d3 d3)
  !   mulps xmm0, xmm2              ; negate it (-d3 -d3 -d3 -d3)
  !   divss xmm0, xmm1              ; s = -d3/d0
  !   call clamp_0_to_1             ; clamp s between 0 and 1
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (s s s s)
  !   blendps xmm0, xmm1, 1101b     ; set xmm1 to (0 s 0 0)
  !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
  !   jmp closest_point_output
  
  ! .closest_point_case1_output_two:
  !   movaps xmm1, xmm6             ; make a copy of (d0 d1 d2 d3)
  !   shufps xmm1, xmm1, 10101010b  ; shuffle (d2 d2 d2 d2)
  !   movaps xmm0, xmm5             ; make a copy of (d4 s t det)
  !   movups xmm2, [math.l_sse_1111_negate_mask]
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (d4 d4 d4 d4)
  !   mulps xmm0, xmm2              ; negate it (-d4 -d4 -d4 -d4)
  !   divss xmm0, xmm1              ; t = -d4/d2
  !   call clamp_0_to_1             ; clamp t between 0 and 1
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (t t t t)
  !   blendps xmm0, xmm1, 1011b     ; set xmm0 to (0 0 t 0)
  !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
  !   jmp closest_point_output
  
  ! .closest_point_case1_output_three:
  !   movaps xmm0, xmm6               ; make a copy of (d0 d1 d2 d3)
  !   movaps xmm1, xmm5               ; make a copy of (d4 s t det)  
  !   shufps xmm1, xmm1, 11111111b    ; shuffle (det det det det)

  !   movups xmm2, [math.l_sse_one_vec]
  !   divps xmm2, xmm1
  !   mulps xmm5, xmm2                ; multiply (d4 s t det) * invDet
  !   jmp closest_point_output
  
  ; --------------------------------------------------------------------------------------------
  ; case 2 : (s +t) >= det
  ; --------------------------------------------------------------------------------------------
  ! .closest_point_case_2:
  !   movaps xmm0, xmm6               ; make a copy of (d0 d1 d2 d3) in xmm0
  !   movaps xmm1, xmm5               ; make a copy of (d4 s t det) in xmm1
  !   shufps xmm1, xmm1, 00000000b    ; fill with d4 ( d4 d4 d4 d4 )
  !   movups xmm2, [math.l_sse_one_vec]
  !   addps xmm2, xmm2                ; add with itself : 2 2 2 2 
  !   mulps xmm0, xmm2                ; multiply by 2
  !   blendps xmm0, xmm6, 1101b       ; d0 2d1 d2 d3
  !   hsubps xmm0, xmm0               ; d0 - 2 * d1 
  !   shufps xmm0, xmm0, 00000000b    ; fill vec with value  

  !   movaps xmm4, xmm6               ; make a copy of (d0 d1 d2 d3) in xmm4
  !   shufps xmm4, xmm4, 10011001b    ; shuffle (d1 d2 d1 d2)
  !   blendps xmm4, xmm0, 1100b       ; blend (d1 d2 d0-2*d1 d0-2*d1)
  !   movaps xmm3, xmm6               ; make a copy of (d0 d1 d2 d3) in xmm3
  !   shufps xmm3, xmm3, 00100111b    ; shuffle (d3 d1 d2 d0)
  !   blendps xmm3, xmm1, 0010b       ; blend (d3 d4 d2 d0)
  !   addps xmm4, xmm3                ; add (d1+d3 d2+d4 d0-2*d1+d2)
  
  !   movaps xmm3, xmm4
  !   psrldq xmm3, 4                  ; shift right 4 bytes
  
  !   movaps xmm0, xmm5               ; make  a copy of (d4 s t det) in xmm0
  !   shufps xmm0, xmm0, 00111001b    ; shuffle it (s t det d4)
  !   movaps xmm1, xmm6               ; make a copy of (d0 d1 d2 d3) in xmm1
  !   shufps xmm1, xmm1, 10110100b    ; shuffle it (d0 d1 d3 d2)
  !   blendps xmm0, xmm1, 0100b       ; blend (s t d3 d4)
  !   movups xmm1, [math.l_sse_zero_vec]
  !   cmpps xmm0, xmm1, 1             ; packed compare (s t d3 d4) < (0,0,0,0)
  !   movmskps r12, xmm0              ; move comparison mask to r12 register
  
  !   test r12, 1                     ; check s < 0.0
  !   jnz case2_s_below_zero
  !   jmp case2_s_upon_zero
  
   ; case 2 : s < 0
  ! .case2_s_below_zero:
  !   comiss xmm4, xmm3               ; compare d1+d3 <= d2+d4
  !   jbe closest_point_case2_output_one
  !   jmp closest_point_case2_output_two
 
  
  ; case 2 : s >= 0
  ! .case2_s_upon_zero:
  !   test r12, 2                     ; check t < 0
  !   jnz case2_t_below_zero
  !   jmp case2_t_upon_zero
  
  ; case 2 :  t < 0
  ! .case2_t_below_zero:
  !   movaps xmm0, xmm6                     ; make a copy of (d0 d1 d2 d3) in xmm0
  !   movaps xmm1, xmm5                     ; make  a copy of (d4 s t det) in xmm1
  !   blendps xmm1, xmm0, 1110b             ; blend (d4 d1 d2 d3)
  !   shufps xmm1, xmm1, 00110011b          ; shuffle (d3 d4 d3 d4)
  !   shufps xmm0, xmm0, 01000100b          ; shuffle (d0 d1 d0 d1)
  !   addps xmm0, xmm1
  !   movaps xmm1, xmm0
  !   psrldq xmm1, 4                        ; shift right 4 bytes
  !   comiss xmm1, xmm0                     ; check d1+d4 <=  d0+d3
  !   jbe closest_point_case2_output_one
  !   jmp closest_point_case2_output_three
  
  ; case 2 : t >= 0
  ! .case2_t_upon_zero:
  !   jmp closest_point_case2_output_one
  
  ; --------------------------------------------------------------------------------------------
  ; case 2 outputs
  ; --------------------------------------------------------------------------------------------
  ! .closest_point_case2_output_one:
  !   movaps xmm0, xmm4             ; make a copy of (d1+d3 d2+d4 d0-2*d1+d2) in xmm0
  !   shufps xmm0, xmm0, 00010001b  ; shuffle (d2+d4 d1+d3 d2+d4 d1+d3)
  !   hsubps xmm0, xmm0             ; denom : (d2+d4) - (d1+d3) 
  !   movaps xmm1, xmm4
  !   shufps xmm1, xmm1, 10101010b  ; numer : d0-2*d1+d2
  !   divps xmm0, xmm1              ; s = numer / denom
  !   call clamp_0_to_1             ; clamp between 0 and 1
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (s s s s)
  !   movups xmm1, [math.l_sse_one_vec]
  !   subps xmm1, xmm0              ; t = 1 - s
  !   blendps xmm0, xmm1, 0100b     ; set xmm0 to (s s t s)
  !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
  !   jmp closest_point_output
  
  ! .closest_point_case2_output_two:
  !   movaps xmm1, xmm6             ; make a copy of (d0 d1 d2 d3) 
  !   shufps xmm1, xmm1, 10101010b  ; shuffle (d2, d2, d2, d2)
  !   movaps xmm0, xmm5             ; make a copy of (d4 s t det)
  !   movups xmm2, [math.l_sse_1111_negate_mask]
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (d4 d4 d4 d4)
  !   mulps xmm0, xmm2              ; negate it (-d4 -d4 -d4 -d4)
  !   divss xmm0, xmm1              ; t = -d4/d2
  !   call clamp_0_to_1             ; clamp t between 0 and 1
  !   shufps xmm0, xmm0, 00000000b  ; shuffle (t t t t)
  !   movups xmm1, [math.l_sse_zero_vec]
  !   blendps xmm0, xmm1, 1011b     ; set xmm0 to (0 0 t 0)
  !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
  !   jmp closest_point_output
  
  ! .closest_point_case2_output_three:
  !   movups xmm0, [math.l_sse_one_vec]
  !   movups xmm1, [math.l_sse_zero_vec]
  !   blendps xmm0, xmm1, 1101b     ; set xmm0 to (0 1 0 0)
  !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
  !   jmp closest_point_output

 
  ; --------------------------------------------------------------------------------------------
  ; OUTPUT
  ; --------------------------------------------------------------------------------------------
  ! .closest_point_output:
  !   movaps xmm0, xmm5               ; make a copy of (d4 s t det) in xmm0
  !   shufps xmm0, xmm0, 10011001b    ; shuffle (s t s t)
  !   haddps xmm0, xmm0               ; horizontal subtraction ( s - t)
  !   movups xmm1, [math.l_sse_one_vec]
  !   subps xmm1, xmm0                ; compute w : 1 - s - t
  !   shufps xmm1, xmm1, 00000000b    ; shuffle (w w w w)
  !   blendps xmm5, xmm1, 0001b       ; blend (w s t det)
  !   movups xmm1, [math.l_sse_zero_vec]
  !   blendps xmm5, xmm1, 1000b       ; reset fourth value
  !   mov rdi, [p.p_uvw]
  !   movups [rdi], xmm5              ; set back uvw
  
  !   movaps xmm0, xmm5
  !   shufps xmm0, xmm0, 01010101b      ; v v v v
  !   mulps xmm8, xmm0                  ; multiply edge0 by v
 
  !   movaps xmm0, xmm5
  !   shufps xmm0, xmm0, 10101010b      ; w w w w
  !   mulps xmm9, xmm0                  ; multiply edge1 by w
  
  !   addps xmm8, xmm9                 ; edge0 * u + edge1 *v
  !   addps xmm8, xmm13                ; edge0 * u + edge1 *v + a
  !   movups xmm0, [math.l_sse_zero_vec]
  !   blendps xmm13, xmm0, 1000b
  !   mov rdi, [p.p_closest]
  !   movups [rdi], xmm8              ; set back closest
  ProcedureReturn
  
  ; --------------------------------------------------------------------------------------------
  ; CLAMP 0 TO 1
  ; clamp function (will clamp xmm0 first element betwenn 0 and 1)
  ; warning xmm1 and xmm2 will be destroyed
  ; --------------------------------------------------------------------------------------------
  ! .clamp_0_to_1:
  !   movups xmm1, [math.l_sse_zero_vec]            ; load 0000 vec (min)
  !   movups xmm2, [math.l_sse_one_vec]             ; load 1111 vec (max)
  !   comiss xmm0, xmm1                             ; compare value with 0000
  !   jb clamp_0_to_1_return_min                    ; if below return min
  !   comiss xmm2, xmm0                             ; compare value with 1111
  !   jb clamp_0_to_1_return_max                    ; if over return max
  !   ret                                           ; leave untouched

  ! .clamp_0_to_1_return_min:                        ; clamp return min    
  !   movss xmm0, xmm1
  !   ret
  
  ! .clamp_0_to_1_return_max:                        ; clamp return max  
  !   movss xmm0, xmm2
  !   ret
  
EndProcedure

;------------------------------------------------------------------
; Closest Point
;------------------------------------------------------------------
Procedure ClosestPoint(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)

  Define.v3f32 edge0, edge1, v0
  Define.f d0, d1, d2, d3, d4
  Define.f det, s, t
  
  Vector3::Sub(edge0, *b, *a)
  Vector3::Sub(edge1, *c, *a)
  Vector3::Sub(v0, *a, *pnt)
  
  d0 = Vector3::Dot(edge0, edge0)
  d1= Vector3::Dot(edge0, edge1)
  d2 = Vector3::Dot(edge1, edge1)
  d3 = Vector3::Dot(edge0, v0)
  d4 = Vector3::Dot(edge1, v0)
  
  det = d0*d2 - d1*d1
  s = d1*d4 - d2*d3
  t = d1*d3 - d0*d4

  If ( (s + t) < det )
    If ( s < 0.0)
      If ( t < 0.0 )
        If ( d3 < 0.0 )
          s = -d3/d0
          CLAMP( s, 0.0, 1.0 )
          t = 0.0
        Else
          s = 0.0
          t = -d4/d2
          CLAMP( t, 0.0, 1.0 )
        EndIf
      Else
        s = 0.0
        t = -d4/d2
        CLAMP( t, 0.0, 1.0 )
      EndIf 
    ElseIf ( t < 0.0 )
      s = -d3/d0
      CLAMP( s, 0.0, 1.0 )
      t = 0.0
    Else
      Define invDet.f = 1.0 / det
      s * invDet
      t * invDet
    EndIf
  Else
    Define numer.f
    Define denom.f
    If ( s < 0.0 )
      Define tmp0.f = d1+d3
      Define tmp1.f = d2+d4
      If ( tmp1 > tmp0 )
        numer.f = tmp1 - tmp0
        denom.f = d0-2*d1+d2
        s = numer/denom
        CLAMP( s, 0.0, 1.0 )
        t = 1-s
      Else
        t = -d4/d2
        CLAMP(t, 0.0, 1.0 )
        s = 0.0
      EndIf
    ElseIf ( t < 0.0 )
      If ( d0+d3 > d1+d4 )
        numer.f = (d2+d4)-(d1+d3)
        denom.f = d0-2*d1+d2
        s = numer/denom
        CLAMP( s, 0.0, 1.0)
        t = 1-s
      Else
        s = 1
        t = 0
      EndIf
    Else
      numer.f = (d2+d4)-(d1+d3)
      denom.f = d0-2*d1+d2
      s = numer/denom
      CLAMP( s, 0.0, 1.0 )
      t = 1.0 - s
    EndIf
  EndIf
  
  *uvw\x = 1.0-s-t
  *uvw\y = s
  *uvw\z = t
  
  *closest\x = *a\x + edge0\x * s + edge1\x * t
  *closest\y = *a\y + edge0\y * s + edge1\y * t
  *closest\z = *a\z + edge0\z * s + edge1\z * t

EndProcedure


Procedure UpdateQuery()
  
  Define *p.v3f32
  Define i
  Select queryMode
    Case #QUERY_MODE_RANDOM
      For i=0 To numQuery-1
        *p = CArray::GetValue(*query, i)
        Vector3::RandomizeInPlace(*p, 12)
        Vector3::AddInPlace(*p, worldPos)
      Next
    Case #QUERY_MODE_CIRCLE
      Utils::BuildCircleSection(*query, CARray::GetCount(*query), 12)
      Define m.m4f32
      Matrix4::SetIdentity(m)
      Matrix4::SetTranslation(m, worldPos)
      Utils::TransformPositionArrayInPlace(*query, m)
  EndSelect
  
EndProcedure


; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

Procedure HitTriangle()

  Drawer::AddTriangle(*drawer, *positions)
  
  Define *pnts.Drawer::Item_t = Drawer::AddPoints(*drawer, *query)
  Drawer::SetSize(*pnts, 12)
  Drawer::SetColor(*pnts, Color::_RED())
 
  
  Define closest2.v3f32, uvw2.v3f32
  Define t2.d = Time::Get()
  Define i
  For i=0 To numQuery - 1
    ClosestPoint(CArray::GetValue(*positions, 0),
                 CArray::GetValue(*positions, 1),
                 CArray::GetValue(*positions, 2),
                 CArray::GetValue(*query, i),
                 CArray::GetValue(*closest, i),
                 uvw2)
    
  Next
  
  Define e2.d = Time::Get()- t2
  
  
  
  Define *hit2.Drawer::Item_t = Drawer::AddPoints(*drawer, *closest)
  Drawer::SetSize(*hit2, 3)
  Drawer::SetColor(*hit2, Color::_BLUE())
  
  Define *line2.Drawer::Drawer_t = Drawer::AddLines2(*drawer, *query, *closest)
  Drawer::SetColor(*line2, Color::_WHITE())
  
  Define closest1.v3f32, uvw1.v3f32
  Define t1.d = Time::Get()
  
  For i=0 To numQuery - 1 
    ClosestPointSSE(CArray::GetValue(*positions, 0),
                    CArray::GetValue(*positions, 1),
                    CArray::GetValue(*positions, 2),
                    CArray::GetValue(*query, i),
                    CArray::GetValue(*closest, i),
                    uvw1)
  Next
  
  Define e1.d = Time::Get()- t1
  
 
  Define *hit1.Drawer::Item_t = Drawer::AddPoints(*drawer, *closest)
  Drawer::SetSize(*hit1, 2)
  Drawer::SetColor(*hit1, Color::_GREEN())
  
  Define *line1.Drawer::Drawer_t = Drawer::AddLines2(*drawer, *query, *closest)
  Drawer::SetColor(*line1, Color::_WHITE())
  diff = diff * 0.75 + (e2 - e1) * 0.25
  
 EndProcedure
 
 Procedure ClosestPointBenchmark(numTests.i)
     RandomSeed(1)
  
  Define numProblematics = 0
  Define avgT1.q, avgT2.q
  Define i
  
  Define a.v3f32, b.v3f32, c.v3f32
  Define pnt.v3f32, closest1.v3f32, closest2.v3f32,uvw1.v3f32, uvw2.v3f32

  Vector3::RandomizeInPlace(a,2)
  Vector3::RandomizeInPlace(b,2)
  Vector3::RandomizeInPlace(c,2)
  
  Vector3::RandomizeInPlace(pnt,2)
  
  Define T1.q = ElapsedMilliseconds()
  For i=0 To numTests-1
    ClosestPoint(a, b, c, pnt, closest1, uvw1)
  Next
  Define E1.q = ElapsedMilliseconds() - T1
  
  
  Define T2.q = ElapsedMilliseconds()
  For i=0 To numTests-1
    ClosestPointSSE(a, b, c, pnt, closest2, uvw2)
  Next
  Define E2.q = ElapsedMilliseconds() - T2

  MessageRequester("CLOSEST POINT", StrD(E1)+" vs "+StrD(E2)+", NUM PROBLEMATICS : "+Str(numProblematics))

EndProcedure
 


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    Define mx = GetGadgetAttribute(*viewport\gadgetID, #PB_OpenGL_MouseX)
    Define my = GetGadgetAttribute(*viewport\gadgetID, #PB_OpenGL_MouseY)
    ViewportUI::GetRay(*viewport, ray)
    
;     ViewportUI::ViewToWorld(*viewport, mx, my, worldPos)  
    Define distance.f
    If Ray::PlaneIntersection(ray, plane, @distance)
      Vector3::SetFromOther(worldPos, ray\origin)
      Vector3::NormalizeInPlace(ray\direction)
;       Vector3::AddInPlace(worldPos, ray\direction)
      Vector3::ScaleAddInPlace(worldPos, ray\direction, distance)
    EndIf
    
  EndIf

  UpdateQuery()
  ViewportUI::SetContext(*viewport)
 
  Drawer::Flush(*drawer)
;   RandomSpheres(Random(64,16), Random(10)-5)
  HitTriangle()
;   RandomPoints(Random(256, 64))
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer, "Difference : "+StrF(diff), -0.9, 0.8, ss, ss*ratio)
;   FTGL::Draw(*app\context\writer, "Side : "+StrF(side)+", Index : "+Str(index), -0.9, 0.7, ss, ss*ratio)
;   FTGL::Draw(*app\context\writer, "WOrld Pos : "+Vector3::ToString(worldPos), -0.9, 0.6, ss, ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  glDisable(#GL_BLEND)
  
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure

 Define useJoystick.b = #False
 width = 800
 height = 600
 
 ; Main
 Globals::Init()
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   *app = Application::New("Test Drawer",width,height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  queryMode = #QUERY_MODE_CIRCLE
  RandomSeed(4)
  CArray::SetCount(*positions, 3)
  Define i
  Define *p.v3f32
  For i=0 To 2 
    *p = CArray::GetValue(*positions, i)
    Vector3::RandomizeInPlace(*p, 12) 
    *p\y = 0
  Next
  
  CArray::SetCount(*query, numQuery)
  CArray::SetCount(*closest, numQuery)
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm
; 
;   Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   Object3D::SetShader(*ground,*s_polymesh)
 
  Define i
  
  *drawer = Drawer::New("Drawer")
  
;   Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  
;   ClosestPointBenchmark(12000000)
   
  Application::Loop(*app, @Draw())
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 47
; FirstLine = 13
; Folding = --
; EnableXP