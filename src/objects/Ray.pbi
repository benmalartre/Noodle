XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Segment.pbi"

; ============================================================================
;  Ray Module IMPLEMENTATION
; ============================================================================
DeclareModule Ray
  UseModule Math
  #RAY_TOLERANCE = 0.0000000001
  
  Declare Set(*Me.Geometry::Ray_t,*origin.v3f32,*direction.v3f32)
  Declare SetOrig(*ray.Geometry::Ray_t,*pos.v3f32)
  Declare SetDirection(*ray.Geometry::Ray_t,*dir.v3f32)
  Declare Transform(*Me.Geometry::Ray_t, *m.m4f32)
  Declare.b FindClosestPoint(*ray.Geometry::Ray_t, *p.v3f32, *rayDistance=#Null, *io.v3f32=#Null)
  
  Declare.b SolveQuadratic(a.f, b.f, c.f, *enterDistance, *exitDistance)
  Declare.b PlaneIntersection(*ray.Geometry::ray_t, *plane.Geometry::Plane_t, *distance=#Null, *frontFacing=#Null)
  Declare.b BoxIntersection(*ray.Geometry::Ray_t, *box.Geometry::Box_t)
  Declare.b CylinderIntersection(*ray.Geometry::Ray_t, *cylinder.Geometry::Cylinder_t, *enterDistance=#Null, *exitDistance=#Null)
  Declare.b SphereIntersection(*ray.Geometry::Ray_t, *sphere.Geometry::Sphere_t, *enterDistance=#Null, *exitDistance=#Null)
  Declare.b TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32, *distance=#Null, *baryCoords.v3f32=#Null, *frontFacing=#Null, maxDist.f=#F32_MAX)
  Declare GetIntersectionPoint(*ray.Geometry::Ray_t, distance.f, *io.v3f32)
EndDeclareModule

Module Ray
  UseModule Math
  ;---------------------------------------------------------
  ; Transform
  ;---------------------------------------------------------
  Procedure Transform(*ray.Geometry::Ray_t, *m.m4f32)
    Protected origin.v4f32
    Protected direction.v4f32
    Vector4::Set(origin, *ray\origin\x, *ray\origin\y, *ray\origin\z, 1)
    Vector4::MulByMatrix4(*ray\origin, origin, *m, #False)
    Vector4::Set(direction, *ray\direction\x, *ray\direction\y, *ray\direction\z, 0)
    Vector4::MulByMatrix4(*ray\direction, direction, *m, #False)
  EndProcedure
  
  ;---------------------------------------------
  ;  Set
  ;---------------------------------------------
  Procedure.i Set(*Me.Geometry::Ray_t,*origin.v3f32,*direction.v3f32)
    
    If *origin : Vector3::SetFromOther(*Me\origin,*origin) : EndIf
    If *direction 
      Vector3::SetFromOther(*Me\direction,*direction)
      Vector3::NormalizeInPlace(*Me\direction)
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Origin
  ;---------------------------------------------------------
  Procedure SetOrig(*ray.Geometry::Ray_t,*pos.v3f32)
    Vector3::SetFromOther(*ray\origin,*pos)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Direction
  ;---------------------------------------------------------
  Procedure SetDirection(*ray.Geometry::Ray_t,*dir.v3f32)
    Vector3::SetFromOther(*ray\direction,*dir)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Find Closest Point
  ;---------------------------------------------------------
  Procedure.b FindClosestPoint(*ray.Geometry::Ray_t, *p.v3f32, *rayDistance=#Null, *io.v3f32=#Null)
    Protected segment.Geometry::Segment_t
    Protected l.f = Segment::Set(segment, *ray\origin, *ray\direction)
    Protected lrd.f
    Segment::FindClosestPoint(segment, *p, @lrd)
    If lrd < 0 : lrd = 0 : EndIf
    
    If *rayDistance : PokeF(*rayDistance, lrd/l) : EndIf
    If *io : Segment::GetPoint(segment, lrd, *io ): EndIf
    ProcedureReturn #True

  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with plane
  ;---------------------------------------------------------
  Procedure.b PlaneIntersection(*ray.Geometry::ray_t, *plane.Geometry::Plane_t, *distance=#Null, *frontFacing=#Null)
    ; The dot product of the ray direction And the plane normal
    ; indicates the angle between them. Reject glancing
    ; intersections. Note: this also rejects ill-formed planes With
    ; zero normals.
    Protected d.f= Vector3::Dot(*ray\direction, *plane\normal)
    If d < #MIN_VECTOR_LENGTH And d > -#MIN_VECTOR_LENGTH
      ProcedureReturn #False
    EndIf
    
    ; get a point on the plane
    Protected planePoint.v3f32
    Vector3::Scale(planePoint, *plane\normal,  *plane\distance)
    
    ; compute the parametric distance to the plane
    ; reject intersection ouside the ray bounds
    Vector3::SubInPlace(planePoint, *ray\origin)
    Protected t.f = Vector3::Dot(planePoint, *plane\normal) / d
    If t < 0 : ProcedureReturn #False : EndIf
    If *distance : PokeF(*distance, t) : EndIf
    If *frontFacing : PokeB(*frontFacing, Bool(d < 0)) : EndIf
    ProcedureReturn #True
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with box
  ;---------------------------------------------------------
  Procedure.b BoxIntersection(*ray.Geometry::Ray_t, *box.Geometry::Box_t)
    Vector3::Invert(*ray\inv_direction, *ray\direction)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define *box_orig.v3f32 = *box\origin
      Define *box_extend.v3f32 = *box\extend
      Define *ray_orig.v3f32 = *ray\origin
      Define *ray_invdir.v3f32 = *ray\inv_direction
      
      ! mov rax, [p.p_box_orig]
      ! movups xmm0, [rax]
      ! mov rax, [p.p_box_extend]
      ! movups xmm1, [rax]
      
      ! mov rax, [p.p_ray_orig]
      ! movups xmm2, [rax]
      ! mov rax, [p.p_ray_invdir]
      ! movups xmm3, [rax]
      
      ! movaps xmm4, xmm0                 ; copy box origin to xmm4
      ! subps xmm4, xmm1                  ; subtract box extend
      ! subps xmm4, xmm2                  ; subtract ray orig
      ! mulps xmm4, xmm3                  ; mul by ray in dir
      
      ! movaps xmm5, xmm0                 ; copy box origin to xmm5
      ! addps xmm5, xmm1                  ; add box extend
      ! subps xmm5, xmm2                  ; subtract ray orig
      ! mulps xmm5, xmm3                  ; mul by ray in dir
      
      ! movaps xmm6, xmm4                 ; copy in xmm6
      ! minps xmm4, xmm5                  ; packed minimum
      ! maxps xmm6, xmm5                  ; packed maximum
      
      ! movhlps xmm7,xmm4                 ; move top two floats to lower part of xmm1
      ! minps   xmm4,xmm7                 ; get minimum of the two sets of floats
      ! pshufd  xmm7,xmm4,$55             ; move second float to lower part of xmm1
      ! minps   xmm4,xmm7                 ; get minimum of the two remaining floats
      
      ! movhlps xmm8,xmm6                 ; move top two floats to lower part of xmm1
      ! maxps   xmm6,xmm8                 ; get maximum of the two sets of floats
      ! pshufd  xmm8,xmm6,$55             ; move second float to lower part of xmm1
      ! maxps   xmm6,xmm8                 ; get maximum of the two remaining floats
      
      ! comiss xmm8, xmm6
      
      ! jge ray_box_intersection
      ! jmp ray_box_no_intersection
      
      ! ray_box_no_intersection:
      ProcedureReturn #False

      ! ray_box_intersection:
      ProcedureReturn #True

    CompilerElse
      Define.f tx1,tx2,ty1,ty2,tz1,tz2,tmin,tmax
      tx1 = (*box\origin\x - *box\extend\x - *ray\origin\x)* *ray\inv_direction\x
      tx2 = (*box\origin\x + *box\extend\x - *ray\origin\x)* *ray\inv_direction\x
     
      tmin = Min(tx1, tx2)
      tmax = Max(tx1, tx2)
     
      ty1 = (*box\origin\y - *box\extend\y - *ray\origin\y)* *ray\inv_direction\y
      ty2 = (*box\origin\y + *box\extend\y - *ray\origin\y)* *ray\inv_direction\y
     
      tmin = Max(tmin, Min(ty1, ty2))
      tmax = Min(tmax, Max(ty1, ty2))
      
      tz1 = (*box\origin\z - *box\extend\z - *ray\origin\z)* *ray\inv_direction\z
      tz2 = (*box\origin\z + *box\extend\z - *ray\origin\z)* *ray\inv_direction\z
     
      tmin = Max(tmin, Min(tz1, tz2))
      tmax = Min(tmax, Max(tz1, tz2))
     
    
      ProcedureReturn Bool(tmax >= tmin)
    CompilerEndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with sphere
  ;---------------------------------------------------------
  Procedure.b SphereIntersection(*ray.Geometry::Ray_t, *sphere.Geometry::Sphere_t, *enterDistance=#Null, *exitDistance=#Null)
    Protected Q.v3f32
    Vector3::Sub(Q,*sphere\center,*ray\origin)
    Protected c.f = Vector3::Length(Q)
    Protected v.f = Vector3::Dot(Q,*ray\direction)
    Protected d.d = *sphere\radius * *sphere\radius - (c*c - v*v)
    
    ;if there was no intersection return -1
    If(d<0.0) : ProcedureReturn #False : EndIf
    
    ;return the distance to the first intersecting point
    If *enterDistance : PokeF(*enterDistance, v-Sqr(d)) : EndIf
    If *exitDistance : PokeF(*exitDistance, v+Sqr(d)) : EndIf
    ProcedureReturn #True
     
  EndProcedure
  
  ;---------------------------------------------------------
  ; Solve Quadratic
  ;---------------------------------------------------------
  Procedure.b SolveQuadratic(a.f, b.f, c.f, *enterDistance, *exitDistance)
    Protected t.f
    If Abs(a) < #RAY_TOLERANCE
      If Abs(b) < #RAY_TOLERANCE
        ; Degenerate Solution
        ProcedureReturn #False
      EndIf
      t.f = -c / b
      If t<0 : ProcedureReturn #False : EndIf
      If *enterDistance : PokeF(*enterDistance, t) : EndIf
      If *exitDistance : PokeF(*exitDistance, t) : EndIf
      ProcedureReturn #True
    EndIf
    
    ; Discriminant
    Protected disc.f = (b * b) - 4.0 * a * c

    If Abs(disc) < #RAY_TOLERANCE
      ; Tangent
      t = -b / (2.0 * a)
      If t<0 : ProcedureReturn #False : EndIf
      If *enterDistance : PokeF(*enterDistance, t) : EndIf
      If *exitDistance : PokeF(*exitDistance, t) : EndIf
      ProcedureReturn #True
    EndIf
    
    If disc < 0.0
      ; No Intersection
      ProcedureReturn #False
    EndIf
    
    ; Two Intersection Points
    Protected q.f = -0.5 * (b + Sign(b) * Sqr(disc))
    Protected t0.f = q / a
    Protected t1.f = c / q
    
    If t0 > t1
      Protected tt.f = t0
      t0 = t1
      t1 = tt
    EndIf
    
    If t1 >= 0
      If *enterDistance : PokeF(*enterDistance, t0) : EndIf
      If *exitDistance : PokeF(*exitDistance, t1) : EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
          
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with cylinder
  ;---------------------------------------------------------
  Procedure.b CylinderIntersection(*ray.Geometry::Ray_t, *cylinder.Geometry::Cylinder_t, *enterDistance=#Null, *exitDistance=#Null)
    Protected unitAxis.v3f32
    Protected delta.v3f32
    Protected u.v3f32, v.v3f32, w.v3f32
    Vector3::Normalize(unitAxis, *cylinder\axis)
    Vector3::Sub(delta, *ray\origin, *cylinder\position)
    Vector3::Scale(w, unitAxis, Vector3::Dot(*ray\direction, unitAxis))
    Vector3::Sub(u, *ray\direction, w)
    Vector3::Scale(w, unitAxis, Vector3::Dot(delta, unitAxis))
    Vector3::Sub(v, delta, w)
    
    ; Quadratic equation For implicit infinite cylinder
    Protected a.f = Vector3::Dot(u, u)
    Protected b.f = 2.0 * Vector3::Dot(u, v)
    Protected c.f = Vector3::Dot(v, v) - Sqr(*cylinder\radius)
    
    ProcedureReturn SolveQuadratic(a, b, c, *enterDistance, *exitDistance)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with triangle
  ;---------------------------------------------------------
  Procedure.b TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32, *distance=#Null, *baryCoords.v3f32=#Null, *frontFacing=#Null, maxDist.f=#F32_MAX)
    Protected plane.Geometry::Plane_t
    Geometry::ConstructPlaneFromThreePoints(plane, *a, *b, *c)
    Protected intersectDist.f
    If Not Ray::PlaneIntersection(*ray, plane, @intersectDist, *frontFacing)
      ProcedureReturn #False
    EndIf
    If intersectDist > maxDist : ProcedureReturn #False : EndIf
    
    ; Find the largest component of the plane normal. The other two
    ; dimensions are the axes of the aligned plane we will use To
    ; project the triangle.
    Protected xAbs.f = Abs(plane\normal\x)
    Protected yAbs.f = Abs(plane\normal\y)
    Protected zAbs.f = Abs(plane\normal\z)
    
    Protected inter0.f, inter1.f
    Protected d0.v2f32, d1.v2f32, d2.v2f32
    If xAbs > yAbs And xAbs > zAbs
      inter0 = *ray\origin\y + intersectDist * *ray\direction\y
      inter1 = *ray\origin\z + intersectDist * *ray\direction\z
      Vector2::Set(d0, inter0 - *a\y, inter1 - *a\z)
      Vector2::Set(d1, *b\y - *a\y, *b\z - *a\z)
      Vector2::Set(d2, *c\y - *a\y, *c\z - *a\z)
    ElseIf yAbs > zAbs
      inter0 = *ray\origin\z + intersectDist * *ray\direction\z
      inter1 = *ray\origin\x + intersectDist * *ray\direction\x
      Vector2::Set(d0, inter0 - *a\z, inter1 - *a\x)
      Vector2::Set(d1, *b\z - *a\z, *b\x - *a\x)
      Vector2::Set(d2, *c\z - *a\z, *c\x - *a\x)
    Else
      inter0 = *ray\origin\x + intersectDist * *ray\direction\x
      inter1 = *ray\origin\y + intersectDist * *ray\direction\y
      Vector2::Set(d0, inter0 - *a\x, inter1 - *a\y)
      Vector2::Set(d1, *b\x - *a\x, *b\y - *a\y)
      Vector2::Set(d2, *c\x - *a\x, *c\y - *a\y)
    EndIf
    
    ; XXX This code can miss some intersections on very tiny tris.
    Protected alpha.f
    Protected beta.f = ((d0\y * d1\x - d0\x * d1\y) / (d2\y * d1\x - d2\x * d1\y))

    ; clamp beta To 0 If it is only very slightly less than 0
    If beta < 0 And beta > -#MIN_VECTOR_LENGTH : beta = 0 : EndIf
    If beta < 0 Or beta > 1.0 : ProcedureReturn #False : EndIf
    
    alpha = -1.0
    If d1\y < -#MIN_VECTOR_LENGTH Or d1\y > #MIN_VECTOR_LENGTH
      alpha = (d0\y - beta * d2\y) / d1\y
    Else
      alpha = (d0\x - beta * d2\x) / d1\x
    EndIf
    
    ; clamp alpha to 0 if it is only very slightly less than 0
    If alpha < 0 And alpha > -#MIN_VECTOR_LENGTH : alpha = 0 : EndIf
    
    ; clamp gamma To 0 If it is only very slightly less than 0
    Protected gamma.f = 1.0 - (alpha + beta)
    If gamma < 0 And gamma > -#MIN_VECTOR_LENGTH : gamma = 0 : EndIf
    
    If alpha < 0 Or gamma < 0 : ProcedureReturn #False : EndIf
    
    If *distance : PokeF(*distance, intersectDist) : EndIf
    If *baryCoords : Vector3::Set(*baryCoords, gamma, alpha, beta) : EndIf
    
    ProcedureReturn #True
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Intersection Point
  ;---------------------------------------------------------
  Procedure GetIntersectionPoint(*ray.Geometry::Ray_t, distance.f, *io.v3f32)
    Vector3::ScaleAdd(*io, *ray\origin, *ray\direction, distance)  
  EndProcedure
  

EndModule

;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 362
; FirstLine = 313
; Folding = ---
; EnableXP
; EnableUnicode