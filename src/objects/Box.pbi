XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Segment.pbi"
;========================================================================================
; Box Module Declaration
;========================================================================================
DeclareModule Box
  UseModule Math
  UseModule Geometry
  #BOX_TOLERANCE = 0.0000000001
  
  Declare Set(*Me.Box_t,*origin.v3f32,*extend.v3f32)
  Declare SetOrig(*Me.Box_t,*origin.v3f32)
  Declare SetExtend(*Me.Box_t,*extend.v3f32)
  Declare SetFromOther(*Me.Box_t, *other.Box_t)
  Declare SetFromMinMax(*Me.Box_t, *bmin.v3f32, *bmax.v3f32)
  Declare Transform(*Me.Box_t, *m.m4f32)
  Declare Reset(*Me.Box_t)
  Declare.b ContainsPoint(*Me.Box_t, *p.v3f32)
  Declare.b IntersectBox(*Me.Box_t, *other.Box_t)
  Declare.b IntersectPlane(*Me.Box_t, *plane.Plane_t)
  Declare.b IntersectSphere(*Me.Box_t, *sphere.Sphere_t)
  Declare.b Union(*Me.Box_t, *other.Box_t)
  Declare.f SquareDistance(*Me.Box_t, *point.v3f32)
  Declare.b InsideBox(*Me.Box_t, *other.Box_t)
  Declare.b InsideSphere(*Me.Box_t, *sphere.Sphere_t)
  Declare GetMatrixRepresentation(*Me.Box_t, *m.m4f32)
EndDeclareModule

; ============================================================================
;  Box Module IMPLEMENTATION
; ============================================================================
Module Box
  UseModule Math
  ;---------------------------------------------------------
  ; Transform
  ;---------------------------------------------------------
  Procedure Transform(*Me.Geometry::Box_t, *m.m4f32)
    Protected origin.v4f32
    Protected extend.v4f32
    ;     Vector4::Set(@origin, (*box\bmin\x + *box\bmax\x) * 0.5, (*box\bmin\y + *box\bmax\y)*0.5, (*box\bmin\z + *box\bmax\z)*0.5, 1)
    Vector4::Set(origin, *Me\origin\x, *Me\origin\y, *Me\origin\z, 1)
    Vector4::MulByMatrix4(*Me\origin, origin, *m, #False)
    Vector4::Set(extend, *Me\extend\x, *Me\extend\y, *Me\extend\z, 0)
    Vector4::MulByMatrix4(*Me\extend, extend, *m, #False)
  EndProcedure
  
  ;---------------------------------------------
  ;  Reet
  ;---------------------------------------------
  Procedure Reset(*Me.Geometry::Box_t)
    Vector3::Set(*Me\origin, 0,0,0)
    Vector3::Set(*Me\extend,0,0,0)
  EndProcedure
  
  ;---------------------------------------------
  ;  Set
  ;---------------------------------------------
  Procedure.i Set(*Me.Geometry::Box_t,*origin.v3f32,*extend.v3f32)
    If *origin : Vector3::SetFromOther(*Me\origin,*origin) : EndIf
    If *extend : Vector3::SetFromOther(*Me\extend,*extend) : EndIf
    ProcedureReturn *Me
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Origin
  ;---------------------------------------------------------
  Procedure SetOrig(*Me.Geometry::Box_t,*orig.v3f32)
    Vector3::SetFromOther(*Me\origin,*orig)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Extend
  ;---------------------------------------------------------
  Procedure SetExtend(*Me.Geometry::Box_t,*extend.v3f32)
    Vector3::SetFromOther(*Me\extend,*extend)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set From Other
  ;---------------------------------------------------------
  Procedure SetFromOther(*Me.Geometry::Box_t,*other.Geometry::Box_t)
    Vector3::SetFromOther(*Me\origin, *other\origin)
    Vector3::SetFromOther(*Me\extend, *other\extend)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set From Min and Max
  ;---------------------------------------------------------
  Procedure SetFromMinMax(*Me.Geometry::Box_t,*bmin.v3f32, *bmax.v3f32)
    Vector3::LinearInterpolate(*Me\origin, *bmin, *bmax, 0.5)
    Vector3::Sub(*Me\extend, *bmax, *bmin)
    Vector3::ScaleInPlace(*Me\extend, 0.5)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Contains Point
  ;---------------------------------------------------------
  Procedure.b ContainsPoint(*Me.Geometry::Box_t,*p.v3f32)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      ! mov rsi, [p.p_Me]
      ! mov rdi, [p.p_p]
      ! movups xmm0, [rsi]              ; load box origin in xmm0
      ! movaps xmm1, xmm0               ; make a copy in xmm1
      ! movups xmm2, [rsi + 16]         ; load box extend in xmm2
      ! movups xmm3, [rdi]              ; load pnt in xmm3
      ! movaps xmm4, xmm3               ; make a copy in xmm4
      ! subps xmm0, xmm2                ; compute box min
      ! addps xmm1, xmm2                ; compute box max
      
      ! cmpps xmm3, xmm0, 5             ; compare p >= bmin
      ! cmpps xmm4, xmm1, 2             ; compare p <= bmax
      
      ! movmskps r8, xmm3               ; move comparison mask to r8 register
      ! movmskps r9, xmm4               ; move comparison mask to r9 register
    
      ! add r8, r9                      ; if all the comparison test succeeded
      ! cmp r8, 30                      ; we should have 30 in r8
      ! je contains_point               ; point in box  
      ! jmp not_contains_point          ; point outside of box
      
      ! contains_point:                 ; point in box  
      ProcedureReturn #True
      
      ! not_contains_point:             ; point outside of box
      ProcedureReturn #False
    CompilerElse
      ProcedureReturn Bool(*p\x>=*Me\origin\x-*Me\extend\x And *p\x <= *Me\origin\x+*Me\extend\x And
                           *p\y>=*Me\origin\y-*Me\extend\y And *p\y <= *Me\origin\y+*Me\extend\y And
                           *p\z>=*Me\origin\z-*Me\extend\z And *p\z <= *Me\origin\z+*Me\extend\z)
    CompilerEndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersect Box
  ;---------------------------------------------------------
  Procedure.b IntersectBox(*Me.Geometry::Box_t,*other.Geometry::Box_t)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      ! mov rsi, [p.p_Me]
      ! movups xmm0, [rsi]              ; load box origin in xmm0
      ! movaps xmm1, xmm0               ; make a copy in xmm1
      ! movups xmm2, [rsi+16]           ; load box extend in xmm4
      
      ! mov rsi, [p.p_other]
      ! movups xmm3, [rsi]              ; load other origin in xmm2
      ! movaps xmm4, xmm3               ; make a copy in xmm3
      ! movups xmm5, [rsi+16]           ; load other extend in xmm5
      
      ! subps xmm0, xmm2                ; box origin - box extend (box min)
      ! addps xmm1, xmm2                ; box origin + box extend (box max)
      
      ! subps xmm3, xmm5                ; other origin - other extend (other min)
      ! addps xmm4, xmm5                ; other origin + other extend (other max)
      
      ! cmpps xmm1, xmm3, 1             ; compare box max < other min
      ! movmskps r9, xmm1               ; if any of these test if true
      ! cmp r9, 0                       ; there is no intersection
      ! jne no_box_box_intersection
        
      ! cmpps xmm4, xmm0, 1             ; compare other max < box min
      ! movmskps r9, xmm4               ; if any of these test if true
      ! cmp r9, 0                       ; there is no intersection
      ! jne no_box_box_intersection
      
      ! box_box_intersection:           ; we've got an intersection
      ProcedureReturn #True
      
      ! no_box_box_intersection:        ; no intersection
      ProcedureReturn #False
      
    CompilerElse
      If *Me\origin\x + *Me\extend\x < *other\origin\x - *other\extend\x :ProcedureReturn #False : EndIf
      If *Me\origin\x - *Me\extend\x > *other\origin\x + *other\extend\x :ProcedureReturn #False : EndIf
      If *Me\origin\y + *Me\extend\y < *other\origin\y - *other\extend\y :ProcedureReturn #False : EndIf
      If *Me\origin\y - *Me\extend\y > *other\origin\y + *other\extend\y :ProcedureReturn #False : EndIf
      If *Me\origin\z + *Me\extend\z < *other\origin\z - *other\extend\z :ProcedureReturn #False : EndIf
      If *Me\origin\z - *Me\extend\z > *other\origin\z + *other\extend\z :ProcedureReturn #False : EndIf
      ProcedureReturn #True
    CompilerEndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersect Plane
  ;---------------------------------------------------------
  Procedure.b IntersectPlane(*Me.Geometry::Box_t,*plane.Geometry::Plane_t)
    ; Compute the projection interval radius of b onto L(t) = b.c + t * p.n
    Define r.f = *Me\extend\x*Abs(*plane\normal\x) + *Me\extend\y*Abs(*plane\normal\y) + *Me\extend\z*Abs(*plane\normal\z);

    ; Compute distance of box center from plane
    Define s.f = Vector3::Dot(*plane\normal, *Me\origin) - *plane\distance

    ; Intersection occurs when distance s falls within [-r,+r] interval
    ProcedureReturn Bool(Abs(s) <= r)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersect Sphere
  ;---------------------------------------------------------
  Procedure.b IntersectSphere(*Me.Geometry::Box_t,*sphere.Geometry::Sphere_t)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      ! mov rsi, [p.p_sphere]             ; load sphere in cpu
      ! movups xmm0, [rsi]                ; load center in xmm0
      ! movss xmm1, [rsi + 16]            ; load radius in xmm1
      ! mulps xmm1, xmm1                  ; square radius : r2
      ! mov rsi, [p.p_Me]                 ; load box in cpu
      ! movups xmm2, [rsi]                ; load box origin in xmm2
      ! movups xmm3, [rsi + 16]           ; load box extend in xmm3

      ! movaps xmm4, xmm0                 ; copy center in xmm4
      ! subps xmm4, xmm2                  ; center - box origin
      ! subps xmm4, xmm3                  ; center - box origin - box extend
    
      ! movaps xmm5, xmm0                 ; copy center in xmm5
      ! subps xmm5, xmm2                  ; center - box origin
      ! addps xmm5, xmm3                  ; center - box origin + box extend
      
      ! mulps xmm4, xmm4                  ; square center - box min
      ! mulps xmm5, xmm5                  ; square center - box max
     
      ! movaps xmm6, xmm0                 ; copy sphere center in xmm6
      ! cmpps xmm6, xmm2, 1               ; compare center < box min
     
      ! movaps xmm7, xmm0                 ; copy sphere center in xmm7
      ! cmpps xmm7, xmm3, 5               ; compare center > box max
      
      ! andps xmm4, xmm6                  ; reset according to comparison mask
      ! andps xmm5, xmm7                  ; reset according to comparison mask
      
      ! movups xmm8, [math.l_sse_zero_vec]
      ! blendps xmm4, xmm8, 1000b         ; reset fourth value
      ! blendps xmm5, xmm8, 1000b         ; reset fourth value
      
      ! addps xmm4, xmm5                  ; add together
      ! haddps xmm4, xmm4                 ; horizontal add first pass
      ! haddps xmm4, xmm4                 ; horizontal add second pass
      
      ! comiss xmm4, xmm1                 ; compare dmin <= r2
      ! jbe box_sphere_intersection       ; if below or equal we've got an intersection
      ! jmp no_box_sphere_intersection    ; no intersection otherwise
      
      ! box_sphere_intersection:
      ProcedureReturn #True
      
      ! no_box_sphere_intersection:
      ProcedureReturn #False
          
    CompilerElse
      Define r2.f = radius * radius
      Define dmin.f = 0
      If *sphere\center\x < *Me\origin\x - *Me\extend\x 
        dmin + Pow(*sphere\center\x-*Me\origin\x-*Me\extend\x, 2)
      ElseIf *sphere\center\x > *Me\origin\x+*Me\extend\x 
        dmin + Pow(*sphere\center\x-*Me\origin\x+*Me\extend\x, 2)
      EndIf
      
      If *sphere\center\y < *Me\origin\y - *Me\extend\y
        dmin + Pow(*sphere\center\y-*Me\origin\y-*Me\extend\y, 2)
      ElseIf *sphere\center\y > *Me\origin\y+*Me\extend\y 
        dmin + Pow(*sphere\center\y-*Me\origin\y+*Me\extend\y, 2)
      EndIf
      
      If *sphere\center\z < *Me\origin\z - *Me\extend\z
        dmin + Pow(*sphere\center\z-*Me\origin\z-*Me\extend\z, 2)
      ElseIf *sphere\center\z > *Me\origin\z+*Me\extend\z 
        dmin + Pow(*sphere\center\z-*Me\origin\z+*Me\extend\z, 2)
      EndIf
      ProcedureReturn Bool(dmin <= r2)
    CompilerEndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Union
  ;---------------------------------------------------------
  Procedure.b Union(*Me.Geometry::Box_t,*other.Geometry::Box_t)
    ProcedureReturn #False
  EndProcedure
  
  ;---------------------------------------------------------
  ; SquareDistance 1D
  ;---------------------------------------------------------
  Macro SquareDistance1D(_v, _bmin, _bmax)
    If (_v) < (_bmin) : result + Pow((_bmin) - (_v), 2) : EndIf          
    If (_v) > (_bmax) : result + Pow((_v) - (_bmax), 2) : EndIf
  EndMacro
  
  ;---------------------------------------------------------
  ; SquareDistance 
  ;---------------------------------------------------------
  Procedure.f SquareDistance(*Me.Geometry::Box_t, *p.v3f32)
    Protected result.f = 0.0
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      ! mov rsi, [p.p_Me]               ; move box to cpu
      
      ! movups xmm0, [rsi]              ; load box origin in xmm0
      ! movups xmm1, [rsi + 16]         ; load box extend in xmm1
      ! mov rsi, [p.p_p]
      ! movups xmm2, [rsi]              ; load pnt in xmm2
      
      ! movaps xmm3, xmm0               ; copy box origin in xmm3
      ! subps xmm3, xmm1                ; compute box min
      ! movaps xmm4, xmm0               ; copy box origin in xmm4
      ! addps xmm4, xmm1                ; compute box max
      
      ! movaps xmm5, xmm3               ; make a copy of bmin in xmm5
      ! subps xmm5, xmm2                ; bmin - pnt
      ! mulps xmm5, xmm5                ; square it
      
      ! movaps xmm6, xmm2               ; make a copy of pnt in xmm6
      ! subps xmm6, xmm4                ; pnt - bmax
      ! mulps xmm6, xmm6                ; square it
      
      ! movaps xmm7, xmm2               ; make a copy of pnt in xmm7
      ! cmpps xmm2, xmm3, 1             ; get pnt < bmin comparison mask (mask1)
      ! cmpps xmm7, xmm4, 6             ; get pnt > bmax comparison mask (mask2)   
      
      ! andps xmm5, xmm2                ; packed and with mask1
      ! andps xmm6, xmm7                ; packed and with mask2
      
      ! addps xmm5, xmm6                ; add masked values
      ! movaps xmm1, xmm5               ; copy in xmm1
      ! shufps xmm1, xmm1, 11101110b    ; shuffle component for horizontal add
      ! addps xmm1, xmm5                ; add shuffled components
      ! movaps xmm2, xmm1               ; copy in xmm2
      ! shufps xmm2, xmm2, 01010101b    ; shuffle component for horizontal add
      ! addps  xmm1, xmm2               ; add shuffled components  
    
      ! movss [p.v_result], xmm1        ; move first value back to memory
      ProcedureReturn result
    CompilerElse
      
      ; Squared distance
      SquareDistance1D( *p\x, *Me\origin\x-*Me\extend\x, *Me\origin\x+*Me\extend\x )
      SquareDistance1D( *p\y, *Me\origin\y-*Me\extend\y, *Me\origin\y+*Me\extend\y )
      SquareDistance1D( *p\z, *Me\origin\z-*Me\extend\z, *Me\origin\z+*Me\extend\z )
   
      ProcedureReturn result
    CompilerEndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Matrix Representation
  ;---------------------------------------------------------
  Procedure GetMatrixRepresentation(*Me.Geometry::Box_t, *m.m4f32)
    Define s.v3f32
    Matrix4::SetIdentity(*m)
    Vector3::Scale(s, *Me\extend, 2)
    Matrix4::SetScale(*m, s)
    Matrix4::SetTranslation(*m, *Me\origin)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Is Inside Other Box
  ;---------------------------------------------------------
  Procedure.b InsideBox(*Me.Geometry::Box_t, *other.Geometry::Box_t)
    Define delta.v3f32
    Vector3::Sub(delta, *Me\origin, *other\origin)
    Vector3::AbsoluteInPlace(delta)
    ProcedureReturn Vector3::LessThan(delta, *other\extend)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Is Inside Sphere
  ;---------------------------------------------------------
  Procedure.b InsideSphere(*Me.Geometry::Box_t, *sphere.Geometry::Sphere_t)
    ; we exploit the symmetry To reduce the test To test
    ; whether the farthest corner is inside the search ball
    Define p.v3f32
    Vector3::Sub(p, *sphere\center, *Me\origin)
    Vector3::AbsoluteInPlace(p)

    ; reminder: (x, y, z) - (-e, -e, -e) = (x, y, z) + (e, e, e)
    Vector3::AddInPlace(p, *Me\extend)
    ProcedureReturn Bool(Vector3::LengthSquared(p) < *sphere\radius * *sphere\radius)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 343
; FirstLine = 324
; Folding = ----
; EnableXP
; EnableUnicode