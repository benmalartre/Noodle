XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

; ======================================================
; TRIANGLE DECLARATION
; ======================================================
DeclareModule Triangle
  UseModule Math
  UseModule Geometry

  Macro FINDMINMAX(x0,x1,x2,bmin,bmax)
    bmin = x0
    bmax = x0
    If(x1<bmin) : bmin=x1 : ElseIf(x1>bmax) : bmax=x1 : EndIf
    If(x2<bmin) : bmin=x2 : ElseIf(x2>bmax) : bmax=x2 : EndIf
  EndMacro 
  
  Macro ON_TEST_FAIL_RETURN
    ProcedureReturn #False
  EndMacro
  
  Macro ON_TEST_FAIL_CONTINUE
    Continue
  EndMacro

  ; ======================== X-tests ========================
  Macro AXISTEST_X01(a, b, fa, fb, ret)
    p0 = a * v0\y - b * v0\z
    p2 = a * v2\y - b * v2\z
    If p0<p2 : bmin=p0 : bmax=p2
    Else : bmin=p2 : bmax=p0
    EndIf
   
    rad = fa * *box\extend\y + fb * *box\extend\z
    If bmin>rad Or bmax<-rad : ret : EndIf
  EndMacro
  
  Macro AXISTEST_X20(a, b, fa, fb, ret)
    p0 = a * v0\y - b * v0\z
    p1 = a * v1\y - b * v1\z
    If p0<p1 : bmin=p0 : bmax=p1
    Else : bmin=p1 : bmax=p0
    EndIf
    
    rad = fa * *box\extend\y + fb * *box\extend\z
    If bmin>rad Or bmax<-rad : ret  : EndIf
  EndMacro

  ; ======================== Y-tests ========================
  Macro AXISTEST_Y02(a, b, fa, fb, ret)
    p0 = -a * v0\x + b * v0\z
    p2 = -a * v2\x + b * v2\z
    If p0<p2 : bmin=p0 : bmax=p2
    Else : bmin=p2 : bmax=p0
    EndIf
    
    rad = fa * *box\extend\x + fb * *box\extend\z
    If bmin>rad Or bmax<-rad : ret  : EndIf
  EndMacro

  Macro AXISTEST_Y10(a, b, fa, fb, ret)
    p0 = -a * v0\x + b * v0\z
    p1 = -a * v1\x + b * v1\z
    If p0<p1 : bmin=p0 : bmax=p1 
    Else : bmin=p1 : bmax=p0
    EndIf
    
    rad = fa * *box\extend\x + fb * *box\extend\z
    If bmin>rad Or bmax<-rad : ret : EndIf
  EndMacro
    
  ; ======================== Z-tests ========================
  Macro AXISTEST_Z12(a, b, fa, fb, ret)
    p1 = a * v1\x - b * v1\y
    p2 = a * v2\x - b * v2\y
    If p2<p1 : bmin=p2 : bmax=p1
    Else : bmin=p1 : bmax=p2
    EndIf
    
    rad = fa * *box\extend\x + fb * *box\extend\y
    If bmin>rad Or bmax<-rad : ret  : EndIf
  EndMacro
  
  Macro AXISTEST_Z00(a, b, fa, fb, ret)
    p0 = a * v0\x - b * v0\y
    p1 = a * v1\x - b * v1\y
    If p0<p1 : bmin=p0 : bmax=p1
    Else : bmin=p1 : bmax=p0
    EndIf
    
    rad = fa * *box\extend\x + fb * *box\extend\y
    If bmin>rad Or bmax<-rad : ret  : EndIf
  EndMacro

  Declare GetCenter(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32)
  Declare GetNormal(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *normal.v3f32)
  Declare ClosestPoint(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
  Declare.b Touch(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32)
  Declare TouchArray(*positions , *indices, *elements, numTris.i, *box.Geometry::Box_t, *hits)
  Declare.b PlaneBoxTest( *normal.v3f32, *vert.v3f32, *maxbox.v3f32)
  Declare.b IsBoundary(*Me.Triangle_t)
EndDeclareModule


; ======================================================
; TRIANGLE IMPLEMENTATION
; ======================================================
Module Triangle
  UseModule Math
  UseModule Geometry
  
  ;------------------------------------------------------------------
  ; Get Center
  ;------------------------------------------------------------------
  Procedure GetCenter(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32)
    Protected *a.v3f32 = CArray::GetPtr(*positions, *Me\vertices[0])
    Protected *b.v3f32 = CArray::GetPtr(*positions, *Me\vertices[1])
    Protected *c.v3f32 = CArray::GetPtr(*positions, *Me\vertices[2])
    Vector3::Add(*center, *a, *b)
    Vector3::AddInPlace(*center, *c)
    Vector3::ScaleInPlace(*center,1.0/3.0)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get Normal
  ;------------------------------------------------------------------
  Procedure GetNormal(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *normal.v3f32)
    
;     CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
;       ; ---------------------------------------------------------------------------------
;       ; load datas
;       ; ---------------------------------------------------------------------------------
;       ! mov rcx, [p.p_Me]
;       ! add ecx, 16
;       ! mov rsi, [p.p_positions + CARRAY_DATA_OFFSET]
;       ! movups xmm0, [rsi + rcx]
;       ! add ecx, 4
;       ! movups xmm1, [rsi + rcx]
;       ! add ecx, 4
;       ! movups xmm2, [rsi + rcx]
;       
;       ; ---------------------------------------------------------------------------------
;       ; compute edges
;       ; ---------------------------------------------------------------------------------
;       ! subps xmm0, xmm2                  ; compute vector AB
;       ! subps xmm1, xmm3                  ; compute vector AC
;       
;       ; ---------------------------------------------------------------------------------
;       ; cross product
;       ; ---------------------------------------------------------------------------------
;       ! movaps xmm2,xmm0                  ; copy vec AB to xmm2
;       ! movaps xmm3,xmm1                  ; copy vec AC to xmm3
;         
;       ! shufps xmm2,xmm2,00001001b        ; exchange 2 and 3 element (a)
;       ! shufps xmm3,xmm3,00010010b        ; exchange 1 and 2 element (b)
;       ! mulps  xmm2,xmm3
;                
;       ! shufps xmm0,xmm0,00010010b        ; exchange 1 and 2 element (a)
;       ! shufps xmm1,xmm1,00001001b        ; exchange 2 and 3 element (b)
;       ! mulps  xmm0,xmm1
;               
;       ! subps  xmm0,xmm2                  ; cross product triangle normal
;       
;       ; ---------------------------------------------------------------------------------
;       ; normalize in place
;       ; ---------------------------------------------------------------------------------
;       ! movaps xmm6, xmm0                 ; copy normal in xmm6
;       ! mulps xmm0, xmm0                  ; square it
;       ! movaps xmm7, xmm0                 ; copy in xmm7
;       ! shufps xmm7, xmm7, 01001110b      ; shuffle component z w x y
;       ! addps xmm0, xmm7                  ; packed addition
;       ! movaps xmm7, xmm0                 ; copy in xmm7  
;       ! shufps xmm7, xmm7, 00010001b      ; shuffle componennt y x y x
;       ! addps xmm0, xmm7                  ; packed addition
;       ! rsqrtps xmm0, xmm0                ; reciproqual root square (length)
;       ! mulps xmm0, xmm6                  ; multiply by intila vector
;       
;       ; ---------------------------------------------------------------------------------
;       ; send back to memory
;       ; ---------------------------------------------------------------------------------
;       ! mov rdi, [p.p_normal]             ; copy normal in xmm6
;       ! movups [rdi], xmm0
; 
;     CompilerElse
      ; get triangle edges
      Protected AB.v3f32, AC.v3f32
      Protected *a.v3f32 = CArray::GetPtr(*positions, *Me\vertices[0])
      Protected *b.v3f32 = CArray::GetPtr(*positions, *Me\vertices[1])
      Protected *c.v3f32 = CArray::GetPtr(*positions, *Me\vertices[2])
      Vector3::Sub(AB, *b, *a)
      Vector3::Sub(AC, *c, *a)
      ; cross product
      Vector3::Cross(*normal, AB, AC)
      ; normalize
      Vector3::NormalizeInPlace(*normal)
;     CompilerEndIf
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Closest Point
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Procedure ClosestPoint(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
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
      ! closest_point_case_1:
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
      ! case1_s_below_zero:
      !   test r12, 2                     ; check t < 0.0
      !   jnz case1_t_below_zero          ; if true
      !   jmp case1_t_upon_zero
      
      ; case 1 : s >= 0
      ! case1_s_upon_zero:
      !   test r12, 2                     
      !   jnz closest_point_case1_output_one
      !   jmp closest_point_case1_output_three
      
      ; case 1 :  t < 0
      ! case1_t_below_zero:
      !   test r12, 4                     ; check d < 0.0
      !   jnz closest_point_case1_output_one
      !   jmp closest_point_case1_output_two
      
      ; case 1 : t >= 0
      ! case1_t_upon_zero:
      !   jmp closest_point_case1_output_two
      
      ; --------------------------------------------------------------------------------------------
      ; case 1 outputs
      ; --------------------------------------------------------------------------------------------
      ! closest_point_case1_output_one:
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
      
      ! closest_point_case1_output_two:
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
      
      ! closest_point_case1_output_three:
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
      ! closest_point_case_2:
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
      ! case2_s_below_zero:
      !   comiss xmm4, xmm3               ; compare d1+d3 <= d2+d4
      !   jbe closest_point_case2_output_one
      !   jmp closest_point_case2_output_two
     
      
      ; case 2 : s >= 0
      ! case2_s_upon_zero:
      !   test r12, 2                     ; check t < 0
      !   jnz case2_t_below_zero
      !   jmp case2_t_upon_zero
      
      ; case 2 :  t < 0
      ! case2_t_below_zero:
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
      ! case2_t_upon_zero:
      !   jmp closest_point_case2_output_one
      
      ; --------------------------------------------------------------------------------------------
      ; case 2 outputs
      ; --------------------------------------------------------------------------------------------
      ! closest_point_case2_output_one:
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
      
      ! closest_point_case2_output_two:
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
      
      ! closest_point_case2_output_three:
      !   movups xmm0, [math.l_sse_one_vec]
      !   movups xmm1, [math.l_sse_zero_vec]
      !   blendps xmm0, xmm1, 1101b     ; set xmm0 to (0 1 0 0)
      !   blendps xmm5, xmm0, 0110b     ; set s and t back to xmm5
      !   jmp closest_point_output
    
     
      ; --------------------------------------------------------------------------------------------
      ; OUTPUT
      ; --------------------------------------------------------------------------------------------
      ! closest_point_output:
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
      ! clamp_0_to_1:
      !   movups xmm1, [math.l_sse_zero_vec]            ; load 0000 vec (min)
      !   movups xmm2, [math.l_sse_one_vec]             ; load 1111 vec (max)
      !   comiss xmm0, xmm1                             ; compare value with 0000
      !   jb clamp_0_to_1_return_min                    ; if below return min
      !   comiss xmm2, xmm0                             ; compare value with 1111
      !   jb clamp_0_to_1_return_max                    ; if over return max
      !   ret                                           ; leave untouched
    
      ! clamp_0_to_1_return_min:                        ; clamp return min    
      !   movss xmm0, xmm1
      !   ret
      
      ! clamp_0_to_1_return_max:                        ; clamp return max  
      !   movss xmm0, xmm2
      !   ret
    EndProcedure
  CompilerElse
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
              index=1
              s = -d3/d0
              CLAMP( s, 0.0, 1.0 )
              t = 0.0
            Else
              index=2
              s = 0.0
              t = -d4/d2
              CLAMP( t, 0.0, 1.0 )
            EndIf
          Else
            index=3
            s = 0.0
            t = -d4/d2
            CLAMP( t, 0.0, 1.0 )
          EndIf 
        ElseIf ( t < 0.0 )
          index=4
          s = -d3/d0
          CLAMP( s, 0.0, 1.0 )
          t = 0.0
        Else
          index=5
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
  CompilerEndIf
  

  ;---------------------------------------------------------------------------------------------
  ; Touch Box
  ;---------------------------------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
   Procedure.b Touch(*box.Geometry::Box_t, *a.v3f32, *b.v3f32, *c.v3f32)
    Define *origin.v3f32 = *box\origin
    Define *extend.v3f32 = *box\extend
 
    ! mov rax, [p.p_origin]                   ; move center address to rax
    ! movups xmm11, [rax]                     ; move center packed data to xmm11
    ! mov rax, [p.p_extend]                   ; move boxhalfsize address to rax
    ! movups xmm12, [rax]                     ; move boxhalfsize packed data to xmm12
  
    ! mov r9, math.l_sse_1111_sign_mask       ; move 1111 sign mask to r9 register 
    ! mov r10, math.l_sse_1100_negate_mask    ; move 1100 negate mask to r10 register
    ! mov r13, math.l_sse_1111_negate_mask    ; move 1111 negate mask to r13 register
    
    ! xor r8, r8                              ; edge counter 

    ; ----------------------------------------------------
    ; load triangle
    ; ----------------------------------------------------
    ! mov rax, [p.p_a]                        ; move positions address to rax
    ! movaps xmm13, [rax]                     ; move point a to xmm13
    ! mov rax, [p.p_b] 
    ! movaps xmm14, [rax]                     ; move point b to xmm14
    ! mov rax, [p.p_c]  
    ! movaps xmm15, [rax]                     ; move point c to xmm15
    
    ! subps xmm13, xmm11                      ; p0 = a - center
    ! subps xmm14, xmm11                      ; p1 = b - center 
    ! subps xmm15, xmm11                      ; p2 = c - center
      
    ! build_edge:
    !   cmp r8, 3
    !   jl edge0                              ; edge 0
    !   cmp r8, 6
    !   jl edge1                              ; edge 1
    !   cmp r8, 9
    !   jl edge2                              ; edge 2
    
    ; ----------------------------------------------------
    ; edge0
    ; ----------------------------------------------------
    ! edge0:
    !   cmp r8, 0
    !   je edge0_load
    !   jmp edge0_test
    
    ! edge0_load:
    !   xor r15, r15                        ; reset axis counter
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
    !   xor r15, r15                        ; reset axis counter
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
    !   xor r15, r15                        ; reset axis counter
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
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
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
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
    !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
   
    !   jmp axis_test_add
    
    ; ----------------------------------------------------
    ; edge_axis_z12
    ; ----------------------------------------------------
    ! edge_axis_z12:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
    
    !   movaps xmm3, xmm14                  ; copy p1 to xmm3 (a)
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
    !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
    
    !   jmp axis_test_sub
    
    ; ----------------------------------------------------
    ; edge_axis_z00
    ; ----------------------------------------------------
    ! edge_axis_z00:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
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
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
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
    !   cmp r15, 0
    !   je radius_0
    !   cmp r15, 1
    !   je radius_1
    !   cmp r15, 2
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
    !   inc r15                            ; increment axis counter
    !   movss xmm8, xmm6                   ; r0
    !   psrldq xmm6, 8                     ; shift right 8 bytes
    !   addss xmm8, xmm6                   ; rad = r0 + r1
    !   shufps xmm8, xmm8, 00000000b       ; rad rad rad rad 
    !   movups  xmm4, [r10]                ; load 1100 sign bit mask is stored in r10
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
    !   shufps xmm8, xmm3, 11111111b        ; shuffle rad rad  max  max
    !   shufps xmm3, xmm9, 00000000b        ; shuffle min min -rad -rad
    !   cmpps xmm8, xmm3, 1                 ; packed compare radius < axis
    !   movmskps r12, xmm8                  ; move compare mask to register
        
    !   cmp r12, 0                          ; if not 0, an exclusion condition happened
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
    
    !   movups  xmm6, [r13]           ; load 1111 negate mask
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
    
    !   btr r12, 3                    ; reset fourth bit (unused only there for alignment)
    !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
    !   jne no_intersection         
    
    !   cmpps xmm1, xmm5, 1           ; packed compare maximum < -boxhalfsize
    !   movmskps r12, xmm1                
    
    !   btr r12, 3                    ; reset fourth bit (unused only there for alignment)
    !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
    !   jne no_intersection  
    
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
    ! movaps xmm3, xmm12            ; copy boxhalfsize to xmm3
    ! movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
    
    ! movups xmm6, [r13]            ; load 1111 negate mask
    ! mulps xmm5, xmm6              ; negate boxhalfsize
    
    ! subps xmm3, xmm13             ; box - p0
    ! subps xmm5, xmm13             ; -box - p0
    
    ! xorps xmm2, xmm2
    ! cmpps xmm2, xmm0, 1           ; check zero < normal
  
    ! movaps xmm4, xmm5
    ! movaps xmm6, xmm3
    
    ! andps xmm4, xmm2
    ! andps xmm6, xmm2
  
    ! xorps xmm2, xmm2
    ! cmpps xmm2, xmm0, 5          ; check zero >= normal
  
    ! andps xmm3, xmm2
    ! andps xmm5, xmm2
    
    ! addps xmm4, xmm3
    ! addps xmm6, xmm5
    
    !   jmp normal_dot_min
    
    ; ---------------------------------------------------------------------------------
    ; normal dot vmin > 0 ?
    ; ---------------------------------------------------------------------------------
    ! normal_dot_min:
    !   movaps xmm7, xmm0                       ; copy normal to xmm7
    !   mulps xmm7, xmm4                        ; compute normal dot vmin
    !   haddps xmm7, xmm7
    !   haddps xmm7, xmm7
    !   xorps xmm8, xmm8
    
    !   comiss xmm8, xmm7                       ; 0<=vmin
    !   jbe no_intersection                     ; branch if lower or equal
    !   jmp normal_dot_max                      ; branch if greater
  
    ; ---------------------------------------------------------------------------------
    ; 0 < normal dot vmax ?
    ; ---------------------------------------------------------------------------------
    ! normal_dot_max:
    !   movaps xmm7, xmm0                       ; copy normal to xmm7
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
CompilerElse
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
    Define.f bmin,bmax,p0,p1,p2,rad,fex,fey,fez
    
    ; This is the fastest branch on Sun 
    ; move everything so that the boxcenter is in (0,0,0)
    Define.v3f32 v0, v1, v2
    Vector3::Sub(v0, *a, *box\origin)
    Vector3::Sub(v1, *b, *box\origin)
    Vector3::Sub(v2, *c, *box\origin)
 
    ; compute triangle edges
    Define.v3f32 e0
    Vector3::Sub(e0, v1, v0)
   
    ;  test the 9 tests first (this was faster) 
    fex = Abs(e0\x)
    fey = Abs(e0\y)
    fez = Abs(e0\z)
    
    AXISTEST_X01(e0\z, e0\y, fez, fey, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Y02(e0\z, e0\x, fez, fex, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Z12(e0\y, e0\x, fey, fex, Triangle::ON_TEST_FAIL_RETURN)

    Define.v3f32 e1
    Vector3::Sub(e1, v2, v1)
    
    fex = Abs(e1\x)
    fey = Abs(e1\y)
    fez = Abs(e1\z)
    
    AXISTEST_X01(e1\z, e1\y, fez, fey, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Y02(e1\z, e1\x, fez, fex, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Z00(e1\y, e1\x, fey, fex, Triangle::ON_TEST_FAIL_RETURN)
        
    Define.v3f32 e2
    Vector3::Sub(e2, v0, v2)
    
    fex = Abs(e2\x)
    fey = Abs(e2\y)
    fez = Abs(e2\z)
    
    AXISTEST_X20(e2\z, e2\y, fez, fey, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Y10(e2\z, e2\x, fez, fex, Triangle::ON_TEST_FAIL_RETURN)
    AXISTEST_Z12(e2\y, e2\x, fey, fex, Triangle::ON_TEST_FAIL_RETURN)
    
    
    ; first test overlap in the {x,y,z}-directions
    ; find min, max of the triangle each direction, And test For overlap in
    ; that direction -- this is equivalent To testing a minimal AABB around
    ; the triangle against the AABB    
    ; test in X-direction
    FINDMINMAX(v0\x,v1\x,v2\x,bmin,bmax)
    If(bmin>*box\extend\x Or bmax<-*box\extend\x) : ProcedureReturn #False : EndIf
    
   ; test in Y-direction
    FINDMINMAX(v0\y,v1\y,v2\y,bmin,bmax)
    If(bmin>*box\extend\y Or bmax<-*box\extend\y) : ProcedureReturn #False : EndIf
    
    ; test in Z-direction
    FINDMINMAX(v0\z,v1\z,v2\z,bmin,bmax)
    If(bmin>*box\extend\z Or bmax<-*box\extend\z) : ProcedureReturn #False : EndIf
    
    ; test If the box intersects the plane of the triangle
    ; compute plane equation of triangle: normal*x+d=0
    Protected normal.v3f32 
    Vector3::Cross(normal, e0, e1)
    
    Define.v3f32 vmin,vmax
    Define.f v
    v = v0\x
    If normal\x > 0.0 
      vmin\x = -*box\extend\x - v 
      vmax\x = *box\extend\x - v 
    Else 
      vmin\x = *box\extend\x -v 
      vmax\x = -*box\extend\x - v 
    EndIf
    
    v = v0\y
    If normal\y > 0.0
      vmin\y = -*box\extend\y - v
      vmax\y = *box\extend\y - v
    Else
      vmin\y = *box\extend\y -v
      vmax\y = -*box\extend\y - v 
    EndIf
    
    v = v0\z
    If normal\z > 0.0 
      vmin\z = -*box\extend\z - v 
      vmax\z = *box\extend\z - v 
    Else 
      vmin\z = *box\extend\z -v 
      vmax\z = -*box\extend\z - v 
    EndIf
    
    If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
    If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
    ProcedureReturn #False
  EndProcedure
CompilerEndIf


 
CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
  Procedure TouchArray(*positions, *indices, *elements, numTris.i, *box.Geometry::Box_t, *hits)
    
    Define *center.v3f32 = *box\origin
    Define *boxhalfsize.v3f32 = *box\extend
    Define numHits.i = 0
    
    ! mov edi, [p.p_hits]
    ! mov ecx, [p.v_numTris]
    ! mov edx, [p.p_indices]            ; move indices to edx register
    ! mov r14, [p.p_elements]           ; move indices to r14 register
    ! mov rsi, [p.p_center]             ; move center address to rsi
    ! movups xmm11, [rsi]               ; move center packed data to xmm11
    ! mov rsi, [p.p_boxhalfsize]        ; move boxhalfsize address to rsi
    ! movups xmm12, [rsi]               ; move boxhalfsize packed data to xmm12
    ! mov rsi, [p.p_positions]          ; move positions address to rsi

    ! mov r9, math.l_sse_1111_sign_mask       ; move 1111 sign mask to r9 register 
    ! mov r10, math.l_sse_1100_negate_mask    ; move 1100 negate mask to r10 register
    ! mov r13, math.l_sse_1111_negate_mask    ; move 1111 negate mask to r13 register
    
    ! xor r8, r8                              ; edge counter
    ! xor r11, r11                            ; hits counter

    ; ----------------------------------------------------
    ; load triangle
    ; ----------------------------------------------------
    ! array_load_triangle:
    !   mov eax, [r14]                    ; load triangle index
    !   imul rax, 12                      ; compute offset in indices array
    !   mov eax, [edx + eax]              ; get index for desired point A
    !   imul rax, 16                      ; compute offset in position array
    !   movaps xmm13, [rsi + rax]         ; load point A to xmm13
    
    !   mov eax, [r14]                    ; load triangle index
    !   imul rax, 12                      ; compute offset in indices array
    !   mov eax, [edx + eax + 4]          ; get value for desired point B
    !   imul rax, 16                      ; compute offset in position array
    !   movaps xmm14, [rsi + rax]         ; load point B to xmm14
    
    !   mov eax, [r14]                    ; load triangle index
    !   imul rax, 12                      ; compute offset in indices array
    !   mov eax, [edx + eax + 8]          ; get value for desired point C
    !   imul rax, 16                      ; compute offset in position array
    !   movaps xmm15, [rsi + rax]         ; load point C to xmm15
    
    !   subps xmm13, xmm11                ; p0 = a - center
    !   subps xmm14, xmm11                ; p1 = b - center 
    !   subps xmm15, xmm11                ; p2 = c - center
    
    !   add r14, 4

    ; ----------------------------------------------------
    ; build edge
    ; ----------------------------------------------------
    ! array_build_edge:
    !   cmp r8, 3
    !   jl array_edge0
    !   cmp r8, 6
    !   jl array_edge1  
    !   cmp r8, 9
    !   jl array_edge2
    
    ; ----------------------------------------------------
    ; edge0
    ; ----------------------------------------------------
    ! array_edge0:
    !   cmp r8, 0
    !   je array_edge0_load
    !   jmp array_edge0_test
    
    ! array_edge0_load:
    !   xor r15, r15                        ; reset axis counter
    !   movaps xmm0, xmm14                  ; move p1 to xmm0
    !   subps xmm0, xmm13                   ; e0 = p1 - p0
    !   movaps xmm7, xmm0                   ; make a copy in xmm7
    !   movdqu  xmm6, [r9]                  ; load sign bit mask is stored in r9
    !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
    !   jmp array_edge0_test
    
    ! array_edge0_test:
    !   cmp r8 , 0                          ; check edge counter
    !   je array_edge_axis_x01              ; first axis
    !   cmp r8, 1                           ; check edge counter
    !   je array_edge_axis_y02              ; second axis
    !   cmp r8, 2                           ; check edge counter
    !   je array_edge_axis_z12              ; second axis
    
    ; ----------------------------------------------------
    ; edge1
    ; ----------------------------------------------------
    ! array_edge1:
    !   cmp r8, 3
    !   je array_edge1_load
    !   jmp array_edge1_test
    
    ! array_edge1_load:
    !   xor r15, r15                        ; reset axis counter
    !   movaps xmm0, xmm15                  ; move p2 to xmm1
    !   subps xmm0, xmm14                   ; e1 = p2 - p1
    !   movaps xmm7, xmm0                   ; make a copy in xmm7
    
    !   movdqu  xmm6, [r9]                  ; load sign bit mask stored in r9
    !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
    !   jmp array_edge1_test
    
    ! array_edge1_test:
    !   cmp r8 , 3                         ; check edge counter
    !   je array_edge_axis_x01             ; first axis
    !   cmp r8, 4                          ; check edge counter
    !   je array_edge_axis_y02             ; second axis
    !   cmp r8, 5                          ; check edge counter
    !   je array_edge_axis_z00             ; second axis
    
     
    ; ----------------------------------------------------
    ; edge2
    ; ----------------------------------------------------
    ! array_edge2:
    !   cmp r8, 6
    !   je array_edge2_load
    !   jmp array_edge2_test
    
    ! array_edge2_load:
    !   xor r15, r15                        ; reset axis counter
    !   movaps xmm0, xmm13                  ; move p0 to xmm1
    !   subps xmm0, xmm15                   ; e2 = p0 - p2
    !   movaps xmm7, xmm0                   ; make a copy in xmm7
    !   movdqu  xmm6, [r9]                  ; load sign bit mask stored in r9
    !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
    !   jmp array_edge2_test
  
    ! array_edge2_test:
    !   cmp r8 , 6                          ; check edge counter
    !   je array_edge_axis_x20              ; first axis
    !   cmp r8, 7                           ; check edge counter
    !   je array_edge_axis_y10              ; second axis
    !   cmp r8, 8                           ; check edge counter
    !   je array_edge_axis_z12              ; second axis
  
    ; ----------------------------------------------------
    ; edge_axis0_x01
    ; ----------------------------------------------------
    ! array_edge_axis_x01:
    !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
    !   shufps xmm2, xmm2, 01011010b        ; ez ez ey ey
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10011001b        ; ay az by bz
    !   shufps xmm3, xmm3, 11011000b        ; ay by az bz
    
    !   jmp array_axis_test_sub
    
    ; ----------------------------------------------------
    ; edge_axis0_x20
    ; ----------------------------------------------------
    ! array_edge_axis_x20:
    !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
    !   shufps xmm2, xmm2, 01011010b        ; ez ez ey ey
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10011001b        ; ay az by bz
    !   shufps xmm3, xmm3, 11011000b        ; ay by az bz
    
    !   jmp array_axis_test_sub
     
    ; ----------------------------------------------------
    ; edge_axis_y02
    ; ----------------------------------------------------
    ! array_edge_axis_y02:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
    
    !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
    !   mulps xmm2, xmm6                    ; -ez -ez ex ex
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
    !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
   
    !   jmp array_axis_test_add
    
    ; ----------------------------------------------------
    ; edge_axis_y10
    ; ----------------------------------------------------
    ! array_edge_axis_y10:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
    
    !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
    !   mulps xmm2, xmm6                    ; -ez -ez ex ex
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
    !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
   
    !   jmp array_axis_test_add
    
    ; ----------------------------------------------------
    ; edge_axis_z12
    ; ----------------------------------------------------
    ! array_edge_axis_z12:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
    
    !   movaps xmm3, xmm14                  ; copy p1 to xmm3 (a)
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
    !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
    
    !   jmp array_axis_test_sub
    
    ; ----------------------------------------------------
    ; edge_axis_z00
    ; ----------------------------------------------------
    ! array_edge_axis_z00:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; ey ey ex ex
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 01000100b        ; ax ay bx by
    !   shufps xmm3, xmm3, 11011000b        ; ax bx ay by
    
    !   jmp array_axis_test_sub
   
    
    ; ----------------------------------------------------
    ; edge_axis4
    ; ----------------------------------------------------
    ! array_edge_axis4:
    !   movaps xmm2, xmm0                   ; make a copy of e in xmm2
    !   shufps xmm2, xmm2, 00001010b        ; ez ez ex ex
    
    !   movups  xmm6, [r10]                 ; load 1100 negate mask stored in r10
    !   mulps xmm2, xmm6                    ; -ez -ez ex ex
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3 (a)
    !   movaps xmm4, xmm14                  ; copy p1 to xmm4 (b)
  
    !   shufps xmm3, xmm4, 10001000b        ; ax az bx bz
    !   shufps xmm3, xmm3, 11011000b        ; ax bx az bz
   
    !   jmp array_axis_test_add
    
    ; ----------------------------------------------------
    ; axis test sub
    ; ----------------------------------------------------
    ! array_axis_test_sub:
    !   mulps  xmm2, xmm3                   ; p0 ^ p2 packed 2D cross product (c0)
  
    !   movaps xmm3, xmm2                   ; copy c0 position to xmm3
    !   movaps xmm4, xmm2                   ; copy c0 position to xmm4
    
    !   shufps xmm3, xmm3, 01000100b        ; ax ay ax ay
    !   shufps xmm4, xmm4, 11101110b        ; az aw az aw
  
    !   subps  xmm3, xmm4                   ; packed subtraction 
    !   jmp array_compute_radius
    
    ; ----------------------------------------------------
    ; axis test add
    ; ----------------------------------------------------
    ! array_axis_test_add:
    !   mulps  xmm2, xmm3                   ; p0 ^ p2 packed 2D cross product (c0)
   
    !   movaps xmm3, xmm2                   ; copy c0 position to xmm3
    !   movaps xmm4, xmm2                   ; copy c0 position to xmm4
    
    !   shufps xmm3, xmm3, 01000100b        ; c0x c0y c0x c0y
    !   shufps xmm4, xmm4, 11101110b        ; c0z c0w c0z c0w
  
    !   addps xmm3, xmm4                    ; packed addition
    !   jmp array_compute_radius
    
    ; ------------------------------------------------------------------
    ; compute radius and store it in xmm8
    ; ------------------------------------------------------------------
    ! array_compute_radius:
    !   cmp r15, 0
    !   je array_radius_0
    !   cmp r15, 1
    !   je array_radius_1
    !   cmp r15, 2
    !   je array_radius_2
    
    ; ------------------------------------------------------------------
    ; radius
    ; ------------------------------------------------------------------
    ! array_radius_0:
    !   movaps xmm6, xmm12                 ; copy box to xmm6
    !   shufps xmm6, xmm6, 10100101b       ; yyzz mask (box)
    !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
    !   shufps xmm8, xmm8, 01011010b       ; zzyy mask (abs edge)
    !   mulps xmm6, xmm8                   ; packed multiply with box
    !   jmp array_finalize_radius
    
    ! array_radius_1:      
    !   movaps xmm6, xmm12                 ; copy box to xmm6
    !   shufps xmm6, xmm6, 10100000b       ; xxzz mask (box)
    !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
    !   shufps xmm8, xmm8, 00001010b       ; zzxx mask (abs edge)
  
    !   mulps xmm6, xmm8                   ; packed multiply with box
    !   jmp array_finalize_radius
    
    ! array_radius_2:            
    !   movaps xmm6, xmm12                 ; copy box to xmm6
    !   shufps xmm6, xmm6, 01010000b       ; xxyy mask (box)
    !   movaps xmm8, xmm7                  ; copy abs edge to xmm8
    !   shufps xmm8, xmm8, 00000101b       ; yyxx mask (abs edge)
    !   mulps xmm6, xmm8                   ; packed multiply with box
    !   jmp array_finalize_radius
  
    ; ------------------------------------------------------------------
    ; finalize compute radius
    ; ------------------------------------------------------------------
    ! array_finalize_radius:
    !   inc r15                            ; increment axis counter
    !   movss xmm8, xmm6                   ; r0
    !   psrldq xmm6, 8                     ; shift right 8 bytes
    !   addss xmm8, xmm6                   ; rad = r0 + r1
    !   shufps xmm8, xmm8, 00000000b       ; rad rad rad rad 
    !   movups  xmm4, [r10]                ; load 1100 sign bit mask is stored in r10
    !   mulps xmm8, xmm4                   ; -rad -rad rad rad
    !   jmp array_check_side               ; check side
    
    
    ; ------------------------------------------------------------------
    ; check side
    ; ------------------------------------------------------------------
    ! array_check_side:
    !   movaps xmm4, xmm3                  ; copy xmm3 in xmm4
    !   psrldq xmm4, 4                     ; shift right 4 bytes
    !   comiss xmm4, xmm3                  ; compare first value
  
    !   jb array_lower
    !   jmp array_greater
    
    ; ------------------------------------------------------------------
    ; test axis greater
    ; ------------------------------------------------------------------
    ! array_greater:      
    !   shufps xmm3, xmm3, 01000100b       ; x y x y 
    !   jmp array_separate_axis
  
    ; ------------------------------------------------------------------
    ; test axis lower
    ; ------------------------------------------------------------------
    ! array_lower:  
    !   shufps xmm3, xmm3, 00010001b       ; y x y x
    !   jmp array_separate_axis
     
    ; ------------------------------------------------------------------
    ; separate axis theorem
    ; ------------------------------------------------------------------
    ! array_separate_axis:
    !   movaps xmm9, xmm8                   ; make a copy of rad in xmm9
    !   shufps xmm8, xmm3, 11111111b        ; shuffle rad rad  max  max
    !   shufps xmm3, xmm9, 00000000b        ; shuffle min min -rad -rad
    !   cmpps xmm8, xmm3, 1                 ; packed compare radius < axis
    !   movmskps r12, xmm8                  ; move compare mask to register
        
    !   cmp r12, 0                          ; if not 0, an exclusion condition happened
    !   je array_next_edge
    !   jmp array_no_intersection           ; discard    
    
    ! array_next_edge:
    !   inc r8                              ; increment edge counter
    !   cmp r8, 9                           ; if not last edge  
    !   jl array_build_edge                 ; loop
    !   jmp array_test_intersection
    
    ; ------------------------------------------------------------------
    ; axist test hit
    ; ------------------------------------------------------------------
    ! array_test_intersection:
    
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
    
    !   movups  xmm6, [r13]           ; load 1111 negate mask
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
    
    !   btr r12, 3                    ; reset fourth bit (unused only there for alignment)
    !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
    !   jne array_no_intersection         
    
    !   cmpps xmm1, xmm5, 1           ; packed compare maximum < -boxhalfsize
    !   movmskps r12, xmm1                
    
    !   btr r12, 3                    ; reset fourth bit (unused only there for alignment)
    !   cmp r12, 0                    ; if any of the above test is true the triangle is outside of the box
    !   jne array_no_intersection     
    
    ; ---------------------------------------------------------------------------------
    ; triangle-box intersection
    ; ---------------------------------------------------------------------------------
    !   movaps xmm0, xmm14              ; copy p1 to xmm0
    !   movaps xmm1, xmm15              ; copy p2 to xmm1
    
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
    ! movaps xmm9, xmm12            ; copy boxhalfsize to xmm9
    ! movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
    
    ! movups xmm6, [r13]            ; load 1111 negate mask in r13
    ! mulps xmm5, xmm6              ; negate boxhalfsize
    
    ! subps xmm9, xmm13             ; box - p0
    ! subps xmm5, xmm13             ; -box - p0
    
    ! xorps xmm2, xmm2
    ! cmpps xmm2, xmm0, 1           ; check zero < normal
  
    ! movaps xmm4, xmm5
    ! movaps xmm6, xmm9
    
    ! andps xmm4, xmm2
    ! andps xmm6, xmm2
  
    ! xorps xmm2, xmm2
    ! cmpps xmm2, xmm0, 5          ; check zero >= normal
  
    ! andps xmm9, xmm2
    ! andps xmm5, xmm2
    
    ! addps xmm4, xmm9
    ! addps xmm6, xmm5

    ; ---------------------------------------------------------------------------------
    ; normal dot vmin > 0 ?
    ; ---------------------------------------------------------------------------------
    ! array_normal_dot_min:
    !   movaps xmm7, xmm0                       ; copy normal to xmm7
    !   mulps xmm7, xmm4                        ; compute normal dot vmin
    !   haddps xmm7, xmm7
    !   haddps xmm7, xmm7
    !   xorps xmm8, xmm8
    
    !   comiss xmm8, xmm7                       ; 0<=vmin
    !   jbe array_no_intersection               ; branch if lower or equal
    !   jmp array_normal_dot_max                ; branch if greater
  
    ; ---------------------------------------------------------------------------------
    ; 0 < normal dot vmax ?
    ; ---------------------------------------------------------------------------------
    ! array_normal_dot_max:
    !   movaps xmm7, xmm0                       ; copy normal to xmm7
    !   mulps xmm7, xmm6                        ; compute normal dot vmax
    !   haddps xmm7, xmm7
    !   haddps xmm7, xmm7                       ; dot 
    !   xorps xmm8, xmm8
    !   comiss xmm8, xmm7                       ; packed compare
    !   jb array_intersection                   ; 0 < vmax
    !   jmp array_no_intersection               ; branch if lower
    
    ; ---------------------------------------------------------------------------------
    ; triangle intersect box
    ; ---------------------------------------------------------------------------------
    ! array_intersection:
    !   mov [edi], byte 1                       ; set hit flag
    !   inc r11                                 ; increment hits counter
    !   jmp array_next_triangle

    
    ; ---------------------------------------------------------------------------------
    ; triangle does NOT intersect box
    ; ---------------------------------------------------------------------------------
    ! array_no_intersection:  
    !   mov [edi], byte 0                      ; set hit flag
    !   jmp array_next_triangle
    
    ; ------------------------------------------------------------------
    ; next triangle
    ; ------------------------------------------------------------------
    ! array_next_triangle:
    !   inc edi                                 ; incr hits
    !   xor r8, r8                              ; reset edge counter
    !   dec ecx                                 ; decrement triangle counter
    !   jnz array_load_triangle                 ; loop
    !   jmp array_exit                          ; exit
    
    ; ------------------------------------------------------------------
    ; exit
    ; ------------------------------------------------------------------
    ! array_exit:
    !   mov [p.v_numHits], r11
    ProcedureReturn numHits
 
  EndProcedure
CompilerElse
  Procedure TouchArray(*positions, *indices, *elements, numTris.i, *box.Geometry::Box_t, *hits)
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
    Define.v3f32 *a, *b, *c
    Define.v3f32 v0, v1, v2
    Define.v3f32 e0, e1, e2
    
    Define t
    Define si = 4
    Define sp = SizeOf(v3f32)
    Define numHits.i = 0
    Define it
    Protected normal.v3f32 
    Define.v3f32 vmin,vmax
    Define.f v
            
    For t=0 To numTris - 1
      it = PeekL(*elements + t*4)
      *a = *positions + PeekL(*indices +it*12) * sp
      *b = *positions + PeekL(*indices +it*12+4) * sp
      *c = *positions + PeekL(*indices +it*12+8) * sp
      
      ; reset hit info
      PokeB(*hits + t, #False)
      
      ; This is the fastest branch on Sun 
      ; move everything so that the boxcenter is in (0,0,0)
      Vector3::Sub(v0, *a, *box\origin)
      Vector3::Sub(v1, *b, *box\origin)
      Vector3::Sub(v2, *c, *box\origin)
   
      ; compute triangle edges
      Vector3::Sub(e0, v1, v0)
     
      ;  test the 9 tests first (this was faster) 
      fex = Abs(e0\x)
      fey = Abs(e0\y)
      fez = Abs(e0\z)
      
      AXISTEST_X01(e0\z, e0\y, fez, fey, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Y02(e0\z, e0\x, fez, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Z12(e0\y, e0\x, fey, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      
      Vector3::Sub(e1, v2, v1)
      
      fex = Abs(e1\x)
      fey = Abs(e1\y)
      fez = Abs(e1\z)
      
      AXISTEST_X01(e1\z, e1\y, fez, fey, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Y02(e1\z, e1\x, fez, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Z00(e1\y, e1\x, fey, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      
      Vector3::Sub(e2, v0, v2)
      
      fex = Abs(e2\x)
      fey = Abs(e2\y)
      fez = Abs(e2\z)
      
      AXISTEST_X20(e2\z, e2\y, fez, fey, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Y10(e2\z, e2\x, fez, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      AXISTEST_Z12(e2\y, e2\x, fey, fex, Triangle::ON_TEST_FAIL_CONTINUE)
      
      ; first test overlap in the {x,y,z}-directions
      ; find min, max of the triangle each direction, And test For overlap in
      ; that direction -- this is equivalent To testing a minimal AABB around
      ; the triangle against the AABB    
      ; test in X-direction
      FINDMINMAX(v0\x,v1\x,v2\x,min,max)
      If(min>*box\extend\x Or max<-*box\extend\x) : Continue : EndIf
      
     ; test in Y-direction
      FINDMINMAX(v0\y,v1\y,v2\y,min,max)
      If(min>*box\extend\y Or max<-*box\extend\y) : Continue : EndIf
      
      ; test in Z-direction
      FINDMINMAX(v0\z,v1\z,v2\z,min,max)
      If(min>*box\extend\z Or max<-*box\extend\z) : Continue : EndIf
      
      ; test If the box intersects the plane of the triangle
      ; compute plane equation of triangle: normal*x+d=0
      Vector3::Cross(normal, e0, e1)

      v = v0\x
      If normal\x > 0.0 
        vmin\x = -*box\extend\x - v 
        vmax\x = *box\extend\x - v 
      Else 
        vmin\x = *box\extend\x -v 
        vmax\x = -*box\extend\x - v 
      EndIf
      
      v = v0\y
      If normal\y > 0.0
        vmin\y = -*box\extend\y - v
        vmax\y = *box\extend\y - v
      Else
        vmin\y = *box\extend\y -v
        vmax\y = -*box\extend\y - v 
      EndIf
      
      v = v0\z
      If normal\z > 0.0 
        vmin\z = -*box\extend\z - v 
        vmax\z = *box\extend\z - v 
      Else 
        vmin\z = *box\extend\z -v 
        vmax\z = -*box\extend\z - v 
      EndIf
      
      If Vector3::Dot(normal, vmin) > 0.0 : Continue : EndIf
      If Vector3::Dot(normal, vmax) >= 0.0 : PokeB(*hits+t, #True) : numHits + 1: EndIf
    Next
    
    ProcedureReturn numHits
  EndProcedure
CompilerEndIf

  ;------------------------------------------------------------------
  ; Plane Box Test
  ;------------------------------------------------------------------
  Procedure.b PlaneBoxTest(*normal.v3f32, *vert.v3f32, *maxbox.v3f32)

    Define.v3f32 vmin,vmax
    Define.f v
    v = *vert\x
    If *normal\x > 0.0 :  vmin\x = -*maxbox\x - v : vmax\x = *maxbox\x - v : Else : vmin\x = *maxbox\x -v : vmax\x = -*maxbox\x - v : EndIf
    v = *vert\y
    If *normal\y > 0.0 :  vmin\y = -*maxbox\y - v : vmax\y = *maxbox\y - v : Else : vmin\y = *maxbox\y -v : vmax\y = -*maxbox\y - v : EndIf
    v = *vert\z
    If *normal\z > 0.0 :  vmin\z = -*maxbox\z - v : vmax\z = *maxbox\z - v : Else : vmin\z = *maxbox\z -v : vmax\z = -*maxbox\z - v : EndIf
    
    If Vector3::Dot(*normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
    If Vector3::Dot(*normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
    ProcedureReturn #False

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Is Boundary
  ;------------------------------------------------------------------
  Procedure.b IsBoundary(*Me.Triangle_t) 
    ProcedureReturn *Me\boundary
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 195
; FirstLine = 153
; Folding = -----
; EnableXP