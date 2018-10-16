XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

; ======================================================
; TRIANGLE DECLARATION
; ======================================================
DeclareModule Triangle
  UseModule Math
  UseModule Geometry

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
    If min>rad Or max<-rad : ProcedureReturn #False : EndIf
  EndMacro
  
  Macro AXISTEST_X20(a, b, fa, fb)
    p0 = a * v0\y - b * v0\z
    p1 = a * v1\y - b * v1\z
    If p0<p1 : min=p0 : max=p1
    Else : min=p1 : max=p0
    EndIf
    
    rad = fa * *boxhalfsize\y + fb * *boxhalfsize\z
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
    If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
  EndMacro

  Macro AXISTEST_Y10(a, b, fa, fb)
    p0 = -a * v0\x + b * v0\z
    p1 = -a * v1\x + b * v1\z
    If p0<p1 : min=p0 : max=p1 
    Else : min=p1 : max=p0
    EndIf
    
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\z
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
    If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
  EndMacro
  
  Macro AXISTEST_Z00(a, b, fa, fb)
    p0 = a * v0\x - b * v0\y
    p1 = a * v1\x - b * v1\y
    If p0<p1 : min=p0 : max=p1
    Else : min=p1 : max=p0
    EndIf
    
    rad = fa * *boxhalfsize\x + fb * *boxhalfsize\y
    If min>rad Or max<-rad : ProcedureReturn #False  : EndIf
  EndMacro

  Declare GetCenter(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *center.v3f32)
  Declare GetNormal(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *normal.v3f32)
  Declare ClosestPoint(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
  Declare.b Touch(*Me.Triangle_t, *positions , *center.v3f32, *boxhalfsize.v3f32)
  Declare TouchArray(*positions , *indices, numTris.i, *center.v3f32, *boxhalfsize.v3f32, *hits)
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
  Procedure ClosestPoint(*Me.Triangle_t, *positions.CArray::CArrayV3f32, *pnt.v3f32 , *closest.v3f32, *uvw.v3f32)
    Define.v3f32 *A, *B, *C
    *A = *positions + *Me\vertices[0] * 12
    *B = *positions + *Me\vertices[1] * 12
    *C = *positions + *Me\vertices[2] * 12
    Protected edge0.v3f32
    Protected edge1.v3f32
    
    Vector3::Sub(edge0, *B, *A)
    Vector3::Sub(edge1, *C, *A)
    
    Protected v0.v3f32
    Vector3::Sub(v0, *A, *pnt)
    
    Define.f a,b,c,d,e
    a = Vector3::Dot(edge0, edge0)
    b = Vector3::Dot(edge0, edge1)
    c = Vector3::Dot(edge1, edge1)
    d = Vector3::Dot(edge0, v0)
    e = Vector3::Dot(edge1, v0)
    
    Define.f det, s, t
    det = a*c - b*b
    s = b*e - c*d
    t = b*d - a*e
    
    If ( s + t < det )
      If ( s < 0.0)
        If ( t < 0.0 )
          If ( d < 0.0 )
            s = -d/a
            CLAMP( s, 0.0, 1.0 )
            t = 0.0
          Else
            s = 0.0
            t = -e/c
            CLAMP( t, 0.0, 1.0 )
          EndIf
        Else
          s = 0.0
          t = -e/c
          CLAMP( t, 0.0, 1.0 )
        EndIf 
      ElseIf ( t < 0.0 )
        s = -d/a
        CLAMP( s, 0.0, 1.0 )
        t = 0.0
      Else
        Define invDet.f = 1.0 / det
        s * invDet
        t * invDet
      EndIf
   Else
    If ( s < 0.0 )
      Define tmp0.f = b+d
      Define tmp1.f = c+e
      If ( tmp1 > tmp0 )
        Define numer.f = tmp1 - tmp0
        Define denom.f = a-2*b+c
        s = numer/denom
        CLAMP( s, 0.0, 1.0 )
        t = 1-s
      Else
        t = -e/c
        CLAMP( t, 0.0, 1.0 )
        s = 0.0
      EndIf
    ElseIf ( t < 0.0 )
      If ( a+d > b+e )
        Define numer.f = c+e-b-d
        Define denom.f = a-2*b+c
        s = numer/denom
        CLAMP( s, 0.0, 1.0)
        t = 1-s
      Else
        s = -e/c
        CLAMP( s, 0.0, 1.0 )
        t = 0.0
      EndIf
    Else
      Define numer.f = c+e-b-d
      Define denom.f = a-2*b+c
      s = numer/denom
      CLAMP( s, 0.0, 1.0 )
      t = 1.0 - s
    EndIf
  EndIf
  
  Vector3::SetFromOther(*closest, *A)
  Vector3::ScaleInPlace(edge0, s)
  Vector3::ScaleInPlace(edge1, t)
  Vector3::AddInPlace(*closest, edge0)
  Vector3::AddInPlace(*closest, edge1)
  
  *uvw\y = s
  *uvw\z = t
  *uvw\x = 1.0-v-w

EndProcedure

  ;------------------------------------------------------------------
  ; Touch Box
  ;------------------------------------------------------------------
  Procedure.b Touch(*Me.Triangle_t, *positions , *center.v3f32, *boxhalfsize.v3f32)
     
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
    Define.v3f32 *a = *positions + *Me\vertices[0] * 12
    Define.v3f32 *b = *positions + *Me\vertices[1] * 12
    Define.v3f32 *c = *positions + *Me\vertices[2] * 12
    Vector3::Sub(v0, *a, *center)
    Vector3::Sub(v1, *b, *center)
    Vector3::Sub(v2, *c, *center)
 
    ; compute triangle edges
    Define.v3f32 e0
    Vector3::Sub(e0, v1, v0)
   
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
    
    AXISTEST_X01(e1\z, e1\y, fez, fey)
    AXISTEST_Y02(e1\z, e1\x, fez, fex)
    AXISTEST_Z00(e1\y, e1\x, fey, fex)
    
    Define.v3f32 e2
    Vector3::Sub(e2, v0, v2)
    
    fex = Abs(e2\x)
    fey = Abs(e2\y)
    fez = Abs(e2\z)
    
    AXISTEST_X20(e2\z, e2\y, fez, fey)
;     AXISTEST_Y10(e2\z, e2\x, fez, fex)
;     AXISTEST_Z12(e2\y, e2\x, fey, fex)

;     ; first test overlap in the {x,y,z}-directions
;     ; find min, max of the triangle each direction, And test For overlap in
;     ; that direction -- this is equivalent To testing a minimal AABB around
;     ; the triangle against the AABB    
;     ; test in X-direction
;     FINDMINMAX(v0\x,v1\x,v2\x,min,max)
;     If(min>*boxhalfsize\x Or max<-*boxhalfsize\x) : ProcedureReturn #False : EndIf
;     
;    ; test in Y-direction
;     FINDMINMAX(v0\y,v1\y,v2\y,min,max)
;     If(min>*boxhalfsize\y Or max<-*boxhalfsize\y) : ProcedureReturn #False : EndIf
;     
;     ; test in Z-direction
;     FINDMINMAX(v0\z,v1\z,v2\z,min,max)
;     If(min>*boxhalfsize\z Or max<-*boxhalfsize\z) : ProcedureReturn #False : EndIf
;     
;     ; test If the box intersects the plane of the triangle
;     ; compute plane equation of triangle: normal*x+d=0
;     Protected normal.v3f32 
;     Vector3::Cross(normal, e0, e1)
;     
;     Define.v3f32 vmin,vmax
;     Define.f v
;     v = v0\x
;     If normal\x > 0.0 :  vmin\x = -*boxhalfsize\x - v : vmax\x = *boxhalfsize\x - v : Else : vmin\x = *boxhalfsize\x -v : vmax\x = -*boxhalfsize\x - v : EndIf
;     v = v0\y
;     If normal\y > 0.0 :  vmin\y = -*boxhalfsize\y - v : vmax\y = *boxhalfsize\y - v : Else : vmin\y = *boxhalfsize\y -v : vmax\y = -*boxhalfsize\y - v : EndIf
;     v = v0\z
;     If normal\z > 0.0 :  vmin\z = -*boxhalfsize\z - v : vmax\z = *boxhalfsize\z - v : Else : vmin\z = *boxhalfsize\z -v : vmax\z = -*boxhalfsize\z - v : EndIf
;     
;     If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
;     If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
    ProcedureReturn #True
        
  EndProcedure
  
  
  Procedure TouchArray(*positions, *indices, numTris.i, *center.v3f32, *boxhalfsize.v3f32, *hits)
    ;     Protected normal.v3f32, a.v3f32, b.v3f32, c.v3f32,e0.v3f32, e1.v3f32
    Define v.v3f32
    ! mov rdi, [p.p_hits]
    ! mov rcx, [p.v_numTris]
    ! mov rax, [p.p_center]             ; move center address to rax
    ! movups xmm11, [rax]               ; move center packed data to xmm8
    ! mov rax, [p.p_boxhalfsize]        ; move boxhalfsize address to rax
    ! movups xmm12, [rax]               ; move boxhalfsize packed data to xmm9
    ! mov rax, [p.p_positions]          ; move positions address to rax
    
;     ! mov r8, [p.p_indices]
;     EnableASM
;       MOV rax, triangle.l___128_sign_mask__  ; move sign mask to rsi register
;     DisableASM

    ! mov r9, math.l_sse_1111_sign_mask     ; move 1111 sign mask to r9 register 
    ! mov r10, math.l_sse_1010_sign_mask    ; move 1010 sign mask to r10 register
    ! mov r11, math.l_sse_1111_negate_mask       ; move negate sign mask to r11 register
    
    ! xor r8, r8
    ! xor rsi, rsi
    
    ; ----------------------------------------------------
    ; touch array start
    ; ----------------------------------------------------
    !toucharray_start:
    ! jmp load_triangle
   
    ; ----------------------------------------------------
    ; load triangle
    ; ----------------------------------------------------
    !load_triangle:
    !   movaps xmm13, [rax+rsi]             ; move point a to xmm13
    !   movaps xmm14, [rax+rsi+16]          ; move point b to xmm14
    !   movaps xmm15, [rax+rsi+32]          ; move point c to xmm15
    
    !   subps xmm13, xmm11                   ; p0 = a - center
    !   subps xmm14, xmm11                   ; p1 = b - center 
    !   subps xmm15, xmm11                   ; p2 = c - center
    !   jmp build_edge
    
    ! build_edge:
    !   cmp r8, 3
    !   jl edge0
    
;     !   cmp r8, 6
;     !   jl edge1
;     
;     !   cmp r8, 9
;     !   jl edge2
    
    !   jmp test_hit
    
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
    !   je edge0_axis0                      ; first axis
    !   cmp r8, 1                           ; check edge counter
    !   je edge0_axis1                      ; second axis
    !   cmp r8, 2                           ; check edge counter
    !   je edge0_axis2                      ; third axis
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
    
    !   movdqu  xmm6, [r9]                  ; load sign bit mask is stored in r9
    !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
    !   jmp edge1_test
    
    ! edge1_test:
    !   cmp r8 , 3                          ; check edge counter
    !   je edge1_axis0                      ; first axis
    !   cmp r8, 4                           ; check edge counter
    !   je edge1_axis1                      ; second axis
    !   cmp r8, 5                           ; check edge counter
    !   je edge1_axis2                      ; third axis
    ! jmp exit
     
    ; ----------------------------------------------------
    ; edge2
    ; ----------------------------------------------------
    ! edge2:
    !   cmp r8, 7
    !   je edge2_load
    !   jmp edge2_test
    
    ! edge2_load:
    !   movaps xmm0, xmm13                  ; move p2 to xmm1
    !   subps xmm0, xmm15                   ; e1 = p0 - p2
    !   movaps xmm7, xmm0                   ; make a copy in xmm7
    
    !   movdqu  xmm6, [r9]                  ; load sign bit mask is stored in r9
    !   andps xmm7, xmm6                    ; bitmask removing sign (Abs(e0))
    !   jmp edge2_test
    
    ! edge2_test:
    !   cmp r8 , 6                          ; check edge counter
    !   je edge2_axis0                      ; first axis
    !   cmp r8, 7                           ; check edge counter
    !   je edge2_axis1                      ; second axis
    !   cmp r8, 8                           ; check edge counter
    !   je edge2_axis2                      ; third axis
    
    ; ----------------------------------------------------
    ; edge0_axis0
    ; ----------------------------------------------------
    ! edge0_axis0:
    !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
    !   shufps xmm2, xmm2, 01011010b        ; e0z e0z e0y e0y
    
    !   movaps xmm3, xmm13                  ; copy p0 to xmm3
    !   movaps xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0y p0z p2y p2z
    !   shufps xmm3, xmm3, 11011000b        ; p0y p2y p0z p2z
    !   jmp axis_test
     
    ; ----------------------------------------------------
    ; edge0_axis1
    ; ----------------------------------------------------
    ! edge0_axis1:
    !   movaps xmm5, xmm0                   ; make a copy of e0 in xmm2
    !   shufps xmm5, xmm5, 00001010b        ; e0z e0z e0x e0x
    !   movdqu xmm6, [r11]                  ; load negate sign mask is stored in r11
    !   movaps xmm2, xmm5
    !   xorps xmm2, xmm6                    ; -e0z -e0z -e0x -e0x
    !   shufps xmm2, xmm5, 01000100b        ; -e0z -e0z e0x e0x
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0x p0z p2x p2z
    !   shufps xmm3, xmm3, 11011000b        ; p0x p2x p0z p2z
    !   jmp axis_test
    
    ; ----------------------------------------------------
    ; edge0_axis2
    ; ----------------------------------------------------
    ! edge0_axis2:
    !   movaps xmm2, xmm0                   ; make a copy of e0 in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; e0y e0y e0x e0x
    
    !   movups xmm3, xmm14                  ; copy p1 to xmm3
    !   movups xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 10001000b        ; p1x p1z p2x p2z
    !   shufps xmm3, xmm3, 11011000b        ; p1x p2x p1z p2z
    !   jmp axis_test
    
    ; ----------------------------------------------------
    ; edge1_axis0
    ; ----------------------------------------------------
    ! edge1_axis0:
    !   movaps xmm2, xmm0                   ; make a copy of e1 in xmm2
    !   shufps xmm2, xmm2, 01011010b        ; e1z e1z e1y e1y
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0y p0z p2y p2z
    !   shufps xmm3, xmm3, 11011000b        ; p0y p2y p0z p2z
    !   jmp axis_test
    
    ; ----------------------------------------------------
    ; edge1_axis1
    ; ----------------------------------------------------
    ! edge1_axis1:
    !   movaps xmm5, xmm0                   ; make a copy of e1 in xmm2
    !   shufps xmm5, xmm5, 00001010b        ; e1z e1z e1x e1x
    !   movdqu xmm6, [r11]                  ; load negate sign mask is stored in r11
    !   movaps xmm2, xmm5
    !   xorps xmm2, xmm6                    ; -e1z -e1z -e1x -e1x
    !   shufps xmm2, xmm5, 01000100b        ; -e1z -e1z e1x e1x
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0x p0z p2x p2z
    !   shufps xmm3, xmm3, 11011000b        ; p0x p2x p0z p2z
    !   jmp axis_test
  
    ; ----------------------------------------------------
    ; edge1_axis2
    ; ----------------------------------------------------
    ! edge1_axis2:
    !   movaps xmm2, xmm0                   ; make a copy of e1 in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; e1y e0y e1x e1x
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm14                  ; copy p1 to xmm4
  
    !   shufps xmm3, xmm4, 01000100b        ; p0x p0y p2x p2y
    !   shufps xmm3, xmm3, 11011000b        ; p0x p2x p0y p2y
    !   jmp axis_test
     
    ; ----------------------------------------------------
    ; edge2_axis0
    ; ----------------------------------------------------
    ! edge2_axis0:
    !   movaps xmm2, xmm0                   ; make a copy of e2 in xmm2
    !   shufps xmm2, xmm2, 01011010b        ; e2z e2z e2y e2y
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm14                  ; copy p1 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0y p0z p1y p1z
    !   shufps xmm3, xmm3, 11011000b        ; p0y p1y p0z p1z
    !   jmp axis_test
    
    ; ----------------------------------------------------
    ; edge2_axis1
    ; ----------------------------------------------------
    ! edge2_axis1:
    !   movaps xmm5, xmm0                   ; make a copy of e2 in xmm2
    !   shufps xmm5, xmm5, 00001010b        ; e2z e2z e2x e2x
    !   movdqu xmm6, [r11]                  ; load negate sign mask is stored in r11
    !   movaps xmm2, xmm5
    !   xorps xmm2, xmm6                    ; -e2z -e2z -e2x -e2x
    !   shufps xmm2, xmm5, 01000100b        ; -e2z -e2z e2x e2x
    
    !   movups xmm3, xmm13                  ; copy p0 to xmm3
    !   movups xmm4, xmm14                  ; copy p1 to xmm4
  
    !   shufps xmm3, xmm4, 10011001b        ; p0x p0z p1x p1z
    !   shufps xmm3, xmm3, 11011000b        ; p0x p1x p0z p1z
    !   jmp axis_test
    
    ; ----------------------------------------------------
    ; edge2_axis2
    ; ----------------------------------------------------
    ! edge2_axis2:
    !   movaps xmm2, xmm0                   ; make a copy of e2 in xmm2
    !   shufps xmm2, xmm2, 00000101b        ; e2y e2y e2x e2x
    
    !   movups xmm3, xmm14                  ; copy p1 to xmm3
    !   movups xmm4, xmm15                  ; copy p2 to xmm4
  
    !   shufps xmm3, xmm4, 01000100b        ; p0x p0y p2x p2y
    !   shufps xmm3, xmm3, 11011000b        ; p0x p2x p0y p2y
    !   jmp axis_test
    
    
    ; ----------------------------------------------------
    ; axis test
    ; ----------------------------------------------------
    ! axis_test:
    !   mulps  xmm1, xmm0                   ; p0 ^ p2 packed 2D cross product (c0)
    !   movaps xmm3, xmm1                   ; copy c0 position to xmm3
    !   movaps xmm4, xmm1                   ; copy c0 position to xmm4
    !   shufps xmm3, xmm3, 00010001b        ; c0x c0y c0x c0y
    !   shufps xmm4, xmm4, 11101110b        ; c0z c0w c0z c0w
    
    !   subps  xmm3, xmm4                   ; packed subtraction
    !   jmp compute_radius
    
    ; ------------------------------------------------------------------
    ; compute radius and store it in xmm8
    ; ------------------------------------------------------------------
    ! compute_radius:
    !   shufps xmm7, xmm7, 11011000b       ; ae0x ae0z ae0y ae0w
    !   mulps xmm7, xmm12                  ; packed multiply with box
    !   shufps xmm7, xmm7, 10100101b       ; r0y r0y r0z r0z
    !   movss xmm8, xmm7                   ; r0y
    !   psrldq xmm7, 8                     ; shift right
    !   movss xmm9, xmm7                   ; r0z
    !   addss xmm8, xmm9                   ; rad = r0y + r0z
    !   shufps xmm8, xmm8, 00000000b       ; rad rad rad rad
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
    !   jmp check_box
    
    ; ------------------------------------------------------------------
    ; test axis lower
    ; ------------------------------------------------------------------
    ! lower:
    !   shufps xmm3, xmm3, 01000100b            ; x y x y
    !   jmp check_box
      
    ; ------------------------------------------------------------------
    ; check box intersection
    ; ------------------------------------------------------------------
    ! check_box:
    !   movaps xmm5, xmm8                 ; move box to xmm5
    !   movdqu  xmm4, [r11]               ; load 1100 sign bit mask is stored in r11
    !   andps xmm3, xmm4                  ; negate max size
    !   cmpps xmm5, xmm3, 1               ; packed compare radius < axis
    !   movmskps r12, xmm5                ; move compare mask to register
    
    !   cmp r12, 16
    !   je test_miss
    !   add r8, 1
    !   cmp r8, 9

    !   jle build_edge
    !   jmp test_hit
    
    ; ------------------------------------------------------------------
    ; axis test miss
    ; ------------------------------------------------------------------
    ! test_miss:
    !   mov dword [rdi], 0          ; set hits 
    !   jmp next_triangle
    
    ; ------------------------------------------------------------------
    ; axist test hit
    ; ------------------------------------------------------------------
    ! test_hit:
    !   mov dword [rdi], 1          ; set hits 
    !   jmp next_triangle
    
    ; ------------------------------------------------------------------
    ; next triangle
    ; ------------------------------------------------------------------
    ! next_triangle:
    !   add rsi, 16                ; incr point offset
  ;     !   add r8, 12                  ; incr indices offset
    !   add rdi, 1                  ; incr hits
    !   xor r8, r8                  ; reset edge counter
    !   dec rcx                     ; decrement counter
    !   jnz load_triangle           ; loop
    !   jmp exit                    ; exit
    
    ; ------------------------------------------------------------------
    ; exit
    ; ------------------------------------------------------------------
    ! exit:
    
    For i=0 To numTris - 1
      If PeekB(*hits + i) : numHits + 1 : EndIf
    Next
    
    ProcedureReturn numHits
;     
    
 
    
;     !   movaps xmm4, xmm0              ; push e0 in xmm4
; ;     !   andps xmm4, 00000001b
;     !   shufps xmm4, xmm4, 01100110b   ; shuffle e0\z,e0\y,e0\z,e0\y
;     
;     !   movaps xmm5, xmm9              ; push p0 to xmm5
;     !   movaps xmm6, xmm11             ; push p2 to xmm6
;     !   shufps xmm5, xmm6, 10011001b   ; shuffle p0\y,p0\z,p2\y,p2\z
;     
;     !   mulps xmm4, xmm5
    
;     !	  movmskps rax, xmm5	            ; Extract the sign bits from four 32-bits floats in xmm6 and create 4 bit mask in eax 
 
; ;     ; test If the box intersects the plane of the triangle
; ;     ; compute plane equation of triangle: normal*x+d=0
; ;     Protected normal.v3f32 
; ;     Vector3::Cross(normal, e0, e1)
; ;     
; ;     Define.v3f32 vmin,vmax
; ;     Define.f v
; ;     v = v0\x
; ;     If normal\x > 0.0 :  vmin\x = -*boxhalfsize\x - v : vmax\x = *boxhalfsize\x - v : Else : vmin\x = *boxhalfsize\x -v : vmax\x = -*boxhalfsize\x - v : EndIf
; ;     v = v0\y
; ;     If normal\y > 0.0 :  vmin\y = -*boxhalfsize\y - v : vmax\y = *boxhalfsize\y - v : Else : vmin\y = *boxhalfsize\y -v : vmax\y = -*boxhalfsize\y - v : EndIf
; ;     v = v0\z
; ;     If normal\z > 0.0 :  vmin\z = -*boxhalfsize\z - v : vmax\z = *boxhalfsize\z - v : Else : vmin\z = *boxhalfsize\z -v : vmax\z = -*boxhalfsize\z - v : EndIf
; ;     
; ;     If Vector3::Dot(normal, vmin) > 0.0 : ProcedureReturn #False : EndIf
; ;     If Vector3::Dot(normal, vmax) >= 0.0 : ProcedureReturn #True : EndIf
; ;     ProcedureReturn #True
    
 
EndProcedure

  
  
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
; CursorPosition = 356
; FirstLine = 390
; Folding = ---
; EnableXP