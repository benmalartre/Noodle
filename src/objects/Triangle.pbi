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
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Closest Point
  ;------------------------------------------------------------------
  Procedure ClosestPoint(*a.v3f32, *b.v3f32, *c.v3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
    Protected edge0.v3f32
    Protected edge1.v3f32
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define.f a,b,c,d,e
      
      ! mov rsi, [p.p_pnt]              ; move pnt to cpu
      ! movups xmm10, [rsi]             ; move datas to xmm10
      ! mov rsi, [p.p_closest]          ; move closest to cpu
      ! movups xmm11, [rsi]             ; move datas to xmm11
      ! mov rsi, [p.p_uvw]              ; move uvw to cpu
      ! movups xmm12, [rsi]             ; move datas to xmm12
      
      ! mov rsi, [p.p_a]                ; move a to cpu
      ! movaps xmm13,[rsi]              ; move datas to xmm13
      ! mov rsi, [p.p_b]                ; move b to cpu
      ! movaps xmm14,[rsi]              ; move datas to xmm14
      ! mov rsi, [p.p_c]                ; move c to cpu
      ! movaps xmm15,[rsi]              ; move datas to xmm15
      
      ! movaps xmm8, xmm14              ; copy b in xmm8
      ! movaps xmm9, xmm15              ; copy c in xmm9
      ! subps xmm8, xmm13               ; compute edge0 : b - a
      ! subps xmm9, xmm13               ; compute edge1 : c - a
      ! movups [p.v_edge0], xmm8
      ! movups [p.v_edge1], xmm9
      
      ! movaps xmm7, xmm10              ; copy pnt to xmm7
      ! subps xmm7, xmm13               ; compute v0 : pnt - a
      
                                        ; dot product a : edge0 * edge0                  
      ! movaps xmm0, xmm8
      ! mulps xmm0, xmm8
      ! haddps xmm0, xmm0
      ! haddps xmm0, xmm0
      ! movss [p.v_a], xmm0
      
                                        ; dot product a : edge0 * edge1                 
      ! movaps xmm1, xmm8
      ! mulps xmm1, xmm9
      ! haddps xmm1, xmm1
      ! haddps xmm1, xmm1
      ! movss [p.v_b], xmm1
      
                                        ; dot product a : edge1 * edge1                 
      ! movaps xmm2, xmm9
      ! mulps xmm2, xmm9
      ! haddps xmm2, xmm2
      ! haddps xmm2, xmm2
      ! movss [p.v_c], xmm2
      
                                        ; dot product a : edge0 * v0                 
      ! movaps xmm3, xmm8
      ! mulps xmm3, xmm13
      ! haddps xmm3, xmm3
      ! haddps xmm3, xmm3
      ! movss [p.v_d], xmm3
      
                                        ; dot product a : edge1 * v0                 
      ! movaps xmm4, xmm9
      ! mulps xmm4, xmm13
      ! haddps xmm4, xmm4
      ! haddps xmm4, xmm4
      ! movss [p.v_e], xmm4

    CompilerElse
      
      Vector3::Sub(edge0, *b, *a)
      Vector3::Sub(edge1, *c, *a)
      
      Protected v0.v3f32
      Vector3::Sub(v0, *a, *pnt)
      
      Define.f a,b,c,d,e
      a = Vector3::Dot(edge0, edge0)
      b = Vector3::Dot(edge0, edge1)
      c = Vector3::Dot(edge1, edge1)
      d = Vector3::Dot(edge0, v0)
      e = Vector3::Dot(edge1, v0)
      
    CompilerEndIf
    
      
      Define.f det
      det = a*c - b*b
      *uvw\y = b*e - c*d
      *uvw\z = b*d - a*e
      
      If ( *uvw\y + *uvw\z < det )
        If ( *uvw\y < 0.0)
          If ( *uvw\z < 0.0 )
            If ( d < 0.0 )
              *uvw\y = -d/a
              CLAMP( *uvw\y, 0.0, 1.0 )
              *uvw\z = 0.0
            Else
              *uvw\y = 0.0
              *uvw\z = -e/c
              CLAMP( *uvw\z, 0.0, 1.0 )
            EndIf
          Else
            *uvw\y = 0.0
            *uvw\z = -e/c
            CLAMP( *uvw\z, 0.0, 1.0 )
          EndIf 
        ElseIf ( *uvw\z < 0.0 )
          *uvw\y = -d/a
          CLAMP( *uvw\y, 0.0, 1.0 )
          *uvw\z = 0.0
        Else
          Define invDet.f = 1.0 / det
          *uvw\y * invDet
          *uvw\z * invDet
        EndIf
     Else
      If ( *uvw\y < 0.0 )
        Define tmp0.f = b+d
        Define tmp1.f = c+e
        If ( tmp1 > tmp0 )
          Define numer.f = tmp1 - tmp0
          Define denom.f = a-2*b+c
          *uvw\y = numer/denom
          CLAMP( *uvw\y, 0.0, 1.0 )
          *uvw\z = 1-*uvw\y
        Else
          *uvw\z = -e/c
          CLAMP( *uvw\z, 0.0, 1.0 )
          *uvw\y = 0.0
        EndIf
      ElseIf ( *uvw\z < 0.0 )
        If ( a+d > b+e )
          Define numer.f = c+e-b-d
          Define denom.f = a-2*b+c
          *uvw\y = numer/denom
          CLAMP( *uvw\y, 0.0, 1.0)
          *uvw\z = 1-*uvw\y
        Else
          *uvw\y = -e/c
          CLAMP( *uvw\y, 0.0, 1.0 )
          *uvw\z = 0.0
        EndIf
      Else
        Define numer.f = c+e-b-d
        Define denom.f = a-2*b+c
        *uvw\y = numer/denom
        CLAMP( *uvw\y, 0.0, 1.0 )
        *uvw\z = 1.0 - *uvw\y
      EndIf
    EndIf
    
    *closest\x = *a\x + edge0\x * s + edge1\x * t
    *closest\y = *a\y + edge0\y * s + edge1\y * t
    *closest\z = *a\z + edge0\z * s + edge1\z * t
    *uvw\x = 1.0-*uvw\y-*uvw\z
    
;   CompilerEndIf
EndProcedure

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
    !   xorps xmm6, xmm6
    !   cmpps xmm6, xmm0 , 1          ; check 0 < normal
    !   movmskps r12, xmm6
    
    !   movaps xmm4, xmm12            ; copy boxhalfsize to xmm7
    !   movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
    
    !   movups  xmm6, [r13]           ; load 1111 negate mask
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
    ! mov r14, [p.p_elements]           ; move indices to edx register
    ! mov rsi, [p.p_center]             ; move center address to rsi
    ! movups xmm11, [rsi]               ; move center packed data to xmm11
    ! mov rsi, [p.p_boxhalfsize]        ; move boxhalfsize address to rsi
    ! movups xmm12, [rsi]               ; move boxhalfsize packed data to xmm12
    ! mov rsi, [p.p_positions]          ; move positions address to rsi

    ! mov r9, math.l_sse_1111_sign_mask       ; move 1111 sign mask to r9 register 
    ! mov r10, math.l_sse_1100_negate_mask    ; move 1100 negate mask to r10 register
    ! mov r13, math.l_sse_1111_negate_mask    ; move 1111 negate mask to r13 register
    
    ! xor r8, r8
    ! xor r11, r11

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
    !   cmp r8, 3
    !   jl array_compute_radius_e0
    !   cmp r8, 6
    !   jl array_compute_radius_e1
    !   cmp r8, 9
    !   jl array_compute_radius_e2
    
    ; ------------------------------------------------------------------
    ; compute radius edge0
    ; ------------------------------------------------------------------
    ! array_compute_radius_e0:
    !   cmp r8, 0
    !   je array_radius_0
    !   cmp r8, 1
    !   je array_radius_1
    !   cmp r8, 2
    !   je array_radius_2
    
    ; ------------------------------------------------------------------
    ; compute radius edge1
    ; ------------------------------------------------------------------
    ! array_compute_radius_e1:
    !   cmp r8, 3
    !   je array_radius_0
    !   cmp r8, 4
    !   je array_radius_1
    !   cmp r8, 5
    !   je array_radius_2
    
    ; ------------------------------------------------------------------
    ; compute radius edge2
    ; ------------------------------------------------------------------
    ! array_compute_radius_e2:
    !   cmp r8, 6
    !   je array_radius_0
    !   cmp r8, 7
    !   je array_radius_1
    !   cmp r8, 8
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
    !   xorps xmm6, xmm6
    !   cmpps xmm6, xmm0 , 1          ; check 0 < normal
    !   movmskps r12, xmm6
    
    !   movaps xmm4, xmm12            ; copy boxhalfsize to xmm7
    !   movaps xmm5, xmm12            ; copy boxhalfsize to xmm5 
    
    !   movups  xmm6, [r13]           ; load 1111 negate mask
    !   mulps xmm5, xmm6              ; -x -y -z -w (-boxhalfsize)
    
    !   subps xmm4, xmm13             ; box - p0
    !   subps xmm5, xmm13             ; -box - p0
    !   movaps xmm6, xmm4             ; make a copy
    
    !   cmp r12, 8
    !   jbe array_case_low
    !   jmp array_case_up
    
    ; ---------------------------------------------------------------------------------
    ; case 0-7
    ; ---------------------------------------------------------------------------------
    ! array_case_low:
    !   cmp r12, 0
    !   je array_case_0
    
    !   cmp r12, 1
    !   je array_case_1
    
    !   cmp r12, 2
    !   je array_case_2
    
    !   cmp r12, 3
    !   je array_case_3
    
    !   cmp r12, 4
    !   je array_case_4
    
    !   cmp r12, 5
    !   je array_case_5
    
    !   cmp r12, 6
    !   je array_case_6
    
    !   cmp r12, 7
    !   je array_case_7
    
    ; ---------------------------------------------------------------------------------
    ; case 8-15
    ; ---------------------------------------------------------------------------------
    ! array_case_up:
    !   cmp r12, 8
    !   je array_case_8
    
    !   cmp r12, 9
    !   je array_case_9
    
    !   cmp r12, 10
    !   je array_case_10
    
    !   cmp r12, 11
    !   je array_case_11
    
    !   cmp r12, 12
    !   je array_case_12
    
    !   cmp r12, 13
    !   je array_case_13
    
    !   cmp r12, 14
    !   je array_case_14
    
    !   cmp r12, 15
    !   je array_case_15
    
    ; ---------------------------------------------------------------------------------
    ; cases
    ; ---------------------------------------------------------------------------------
    ! array_case_0:
    !   blendps xmm4, xmm5, 0                    ; vmin = boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 15                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z,  -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_1:
    !   blendps xmm4, xmm5, 1                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 14                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_2:
    !   blendps xmm4, xmm5, 2                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 13                   ; vmax =  -boxx-p0x, boxy-p0y, -boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_3:
    !   blendps xmm4, xmm5, 3                   ; vmin = -boxx-p0x, -boxy-p0y, boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 12                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_4:
    !   blendps xmm4, xmm5, 4                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 11                  ; vmax = -boxx-p0x, -boxy-p0y, boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_5:
    !   blendps xmm4, xmm5, 5                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 10                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_6:
    !   blendps xmm4, xmm5, 6                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 9                   ; vmax = -boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_7:
    !   blendps xmm4, xmm5, 7                   ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
    !   blendps xmm6, xmm5, 8                   ; vmax = boxx-p0x,  boxy-p0y,  boxz-p0z, -boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_8:
    !   blendps xmm4, xmm5, 8                   ; vmin = boxx-p0x, boxy-p0y, boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 7                   ; vmax = -boxx-p0x, -boxy-p0y, -boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_9:
    !   blendps xmm4, xmm5, 9                   ; vmin = -boxx-p0x,  boxy-p0y, boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 6                   ; vmax = boxx-p0x,  -boxy-p0y, -boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_10:
    !   blendps xmm4, xmm5, 10                   ; vmin = boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 5                   ; vmax =  -boxx-p0x,  boxy-p0y, -boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_11:
    !   blendps xmm4, xmm5, 11                   ; vmin =-boxx-p0x,  -boxy-p0y, boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 4                   ; vmax = boxx-p0x, boxy-p0y, -boxz-p0z,  boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_12:
    !   blendps xmm4, xmm5, 12                   ; vmin = boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 3                   ; vmax =  -boxx-p0x, -boxy-p0y,  boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_13:
    !   blendps xmm4, xmm5, 13                   ; vmin = -boxx-p0x,  boxy-p0y, -boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 2                   ; vmax = boxx-p0x,  -boxy-p0y, boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_14:
    !   blendps xmm4, xmm5, 14                   ; vmin = boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 1                   ; vmax =  -boxx-p0x,  boxy-p0y,  boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_case_15:
    !   blendps xmm4, xmm5, 15                  ; vmin = -boxx-p0x,  -boxy-p0y, -boxz-p0z, -boxw-p0w
    !   blendps xmm6, xmm5, 0                   ; vmax = boxx-p0x, boxy-p0y, boxz-p0z, boxw-p0w
    !   jmp array_normal_dot
    
    ! array_normal_dot:
    !   jmp array_normal_dot_min
    
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
    ! mov [p.v_numHits], r11
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
; CursorPosition = 206
; FirstLine = 162
; Folding = ----
; EnableXP