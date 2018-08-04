XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"

; ============================================================================
;  Ray Module IMPLEMENTATION
; ============================================================================
DeclareModule Ray
  UseModule Math
  #RAY_TOLERANCE = 0.0000001
  
  Declare Set(*Me.Geometry::Ray_t,*origin.v3f32,*direction.v3f32)
  Declare InverseDirection(*ray.Geometry::Ray_t)
  Declare SetPosition(*ray.Geometry::Ray_t,*pos.v3f32)
  Declare.b SolveQuadratic(a.f, b.f, c.f, *enterDistance, *exitDistance)
  Declare.b PlaneIntersection(*ray.Geometry::ray_t, *plane.Geometry::Plane_t, *distance=#Null, *frontFacing=#Null)
  Declare BoxIntersection(*ray.Geometry::Ray_t, *box.Geometry::Box_t)
  Declare.b CylinderIntersection(*ray.Geometry::Ray_t, *cylinder.Geometry::Cylinder_t, *enterDistance=#Null, *exitDistance=#Null)
  Declare.f SphereIntersection(*ray.Geometry::Ray_t, *sphere.Geometry::Sphere_t)
  Declare.b TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32, *distance=#Null, *baryCoords.v3f32=#Null, *frontFacing=#Null, maxDist.f=#F32_MAX)
EndDeclareModule

Module Ray
  UseModule Math
  ;---------------------------------------------------------
  ; Get Inverse Direction
  ;---------------------------------------------------------
  Procedure InverseDirection(*ray.Geometry::Ray_t)
    Vector3::Scale(*ray\inv_direction, *ray\direction,-1)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Position
  ;---------------------------------------------------------
  Procedure SetPosition(*ray.Geometry::Ray_t,*pos.v3f32)
    Vector3::SetFromOther(*ray\origin,*pos)
  EndProcedure
  
;   ;---------------------------------------------------------
;   ; Get Inverse Direction
;   ;---------------------------------------------------------
;   Procedure Inverse(*ray.Geometry::Ray_t,*m.m4f32)
;     Vector3::MulByMatrix4(*ray\inv_direction,*ray\direction,*m)
;     Vector3::MulByMatrix4(*ray\inv_origin,*ray\origin,*m)
;   EndProcedure
  
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
    Vector3::SCale(@planePoint, *plane\normal,  *plane\distance)
    
    ; compute the parametric distance to the plane
    ; reject intersection ouside the ray bounds
    Vector3::SubInPlace(@planePoint, *ray\origin)
    Protected t.f = Vector3::Dot(@planePoint, *plane\normal) / d
    If t < 0 : ProcedureReturn #False : EndIf
    If *distance : PokeF(*distance, t) : EndIf
    If *frontFacing : PokeB(*frontFacing, Bool(d < 0)) : EndIf
    ProcedureReturn #True
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with box
  ;---------------------------------------------------------
  Procedure BoxIntersection(*ray.Geometry::Ray_t, *box.Geometry::Box_t)
    Define.f tx1,tx2,ty1,ty2,tz1,tz2,tmin,tmax
    tx1 = (*box\p_min\x - *ray\origin\x)* *ray\inv_direction\x
    tx2 = (*box\p_max\x - *ray\origin\x)* *ray\inv_direction\x
   
    tmin = Min(tx1, tx2)
    tmax = Max(tx1, tx2)
   
    ty1 = (*box\p_min\y - *ray\origin\y)* *ray\inv_direction\y
    ty2 = (*box\p_max\y - *ray\origin\y)* *ray\inv_direction\y
   
    tmin = Max(tmin, Min(ty1, ty2))
    tmax = Min(tmax, Max(ty1, ty2))
    
    tz1 = (*box\p_min\z - *ray\origin\z)* *ray\inv_direction\z
    tz2 = (*box\p_max\z - *ray\origin\z)* *ray\inv_direction\z
   
    tmin = Max(tmin, Min(tz1, tz2))
    tmax = Min(tmax, Max(tz1, tz2))
  
    ProcedureReturn Bool(tmax >= tmin)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with sphere
  ;---------------------------------------------------------
  Procedure.f SphereIntersection(*ray.Geometry::Ray_t, *sphere.Geometry::Sphere_t)
    Protected Q.v3f32
    Vector3::Sub(@Q,*sphere\p_center,*ray\origin)
    Protected c.f = Vector3::Length(@Q)
    Protected v.f = Vector3::Dot(@Q,*ray\direction)
    Protected d.d = *sphere\p_radius * *sphere\p_radius - (c*c - v*v)
    
    ;if there was no intersection return -1
    If(d<0.0) : ProcedureReturn -1.0 : EndIf
    
    ;return the distance to the first intersecting point
    ProcedureReturn (v- Sqr(d))
     
  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersection with cylinder
  ;---------------------------------------------------------
  Procedure.b CylinderIntersection(*ray.Geometry::Ray_t, *cylinder.Geometry::Cylinder_t, *enterDistance=#Null, *exitDistance=#Null)
    Protected unitAxis.v3f32
    Protected delta.v3f32
    Protected u.v3f32, v.v3f32
    Vector3::Normalize(@unitAxis, *cylinder\p_axis)
    Vector3::Sub(@delta, *ray\origin, *cylinder\p_position)
    Vector3::Scale(@u, @unitAxis, Vector3::Dot(*ray\direction, @unitAxis))
    Vector3::Sub(@u, *ray\direction, @u)
    Vector3::Scale(@v, @unitAxis, Vector3::Dot(@delta, @unitAxis))
    Vector3::Sub(@v, @delta, @v)
    
    ; Quadratic equation For implicit infinite cylinder
    Protected a.f = Vector3::Dot(u, u)
    Protected b.f = 2.0 * Vector3::Dot(u, v)
    Protected c.f = Vector3::Dot(v, v) - Sqr(*cylinder\p_radius)
    
    ProcedureReturn SolveQuadratic(a, b, c, *enterDistance, *exitDistance)
  EndProcedure
  
;   ;---------------------------------------------------------
;   ; Intersection with triangle
;   ;---------------------------------------------------------
;   Procedure.b TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,*t)
;     Define.v3f32 e1,e2,q,s,r
;     ; edge vectors
;     Vector3::Sub(@e1,*b,*a)
;     Vector3::Sub(@e2,*c,*a)
;     
;     Vector3::Cross(@q,*ray\direction,@e2)
;     
;     Define a.f =Vector3::Dot(@e1,@q)
;     Vector3::Sub(@s,*ray\origin,*a)
;     Vector3::Cross(@r,@s,@e1)
;     
;     ;Barycentric vertex weights
;     *uvw\y = Vector3::Dot(@s,@q)/a
;     *uvw\x = Vector3::Dot(*ray\direction,@r)/a
;     *uvw\z = 1.0 - (*uvw\x + *uvw\y)
;     
;     Define dist.f =Vector3::Dot(@e2,@r)/a
;     Debug StrF(a)+","+StrF(*uvw\x)+","+StrF(*uvw\y)+","+StrF(*uvw\z)+","+StrF(dist)
;     
;     If a<#F32_EPS Or *uvw\x<-#F32_EPS Or *uvw\y<-#F32_EPS Or *uvw\z<-#F32_EPS Or dist<0.0
;       ProcedureReturn #False
;     Else
;       PokeF(*t,dist)
;       ProcedureReturn #True
;     EndIf
;     
;   EndProcedure
  
  Procedure.b TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32, *distance=#Null, *baryCoords.v3f32=#Null, *frontFacing=#Null, maxDist.f=#F32_MAX)
    Protected plane.Geometry::Plane_t
    Geometry::ConstructPlaneFromThreePoints(@plane, *a, *b, *c)
    Protected intersectDist.f
    If Not Ray::PlaneIntersection(*ray, @plane, @intersectDist, *frontFacing)
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
      Vector2::Set(@d0, inter0 - *a\y, inter1 - *a\z)
      Vector2::Set(@d1, *b\y - *a\y, *b\z - *a\z)
      Vector2::Set(@d2, *c\y - *a\y, *c\z - *a\z)
    ElseIf yAbs > zAbs
      inter0 = *ray\origin\z + intersectDist * *ray\direction\z
      inter1 = *ray\origin\x + intersectDist * *ray\direction\x
      Vector2::Set(@d0, inter0 - *a\z, inter1 - *a\x)
      Vector2::Set(@d1, *b\z - *a\z, *b\x - *a\x)
      Vector2::Set(@d2, *c\z - *a\z, *c\x - *a\x)
    Else
      inter0 = *ray\origin\x + intersectDist * *ray\direction\x
      inter1 = *ray\origin\y + intersectDist * *ray\direction\y
      Vector2::Set(@d0, inter0 - *a\x, inter1 - *a\y)
      Vector2::Set(@d1, *b\x - *a\x, *b\y - *a\y)
      Vector2::Set(@d2, *c\x - *a\x, *c\y - *a\y)
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
    Protected disc.f = Sqr(b) - 4.0 * a * c
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
 

  ; ;---------------------------------------------------------
  ; ; Intersection with triangle
  ; ; If ray P + tw hits triangle *a,*b,*c, then the
  ; ; function returns #True, stores the barycentric coordinates in
  ; ; *uv, And stores the distance To the intersection in t(pointer to float).
  ; ; Otherwise returns false And the other output parameters are
  ; ; undefined.*/
  ; ;---------------------------------------------------------
  ; Procedure.f TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,*t)
  ; 
  ;   ; edge vectors
  ;   Define.v3f32 e1, e2
  ;   Vector3_Sub(@e1,*b,*a)
  ;   Vector3_Sub(@e2,*c,*a)
  ;   
  ;   ; triangle normal
  ;   Define.v3f32 n
  ;   Vector3_Cross(@n,@e1,@e2)
  ;   Vector3_NormalizeInPlace(@n)
  ;   
  ;   Define.v3f32 q
  ;   Vector3_Cross(@q,*ray\direction,@e2)
  ;   Define a.f = Vector3_Dot(@e1,@q)
  ;   
  ;   ; backfacing or nearly parallel
  ;   If(Vector3_Dot(@n,*ray\direction)>=0) Or (Abs(a)<=#F32_EPS)
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   Define.v3f32 s
  ;   Vector3_Sub(@s,*ray\origin,*a)
  ;   Vector3_ScaleInPlace(@s,1/a)
  ;   
  ;   Define.v3f32 r
  ;   Vector3_Cross(@r,@s,@e1)
  ;   
  ;   *uvw\x = Vector3_Dot(@s,@q)
  ;   *uvw\y = Vector3_Dot(@r,*ray\direction)
  ;   *uvw\z = 1.0 - *uvw\x - *uvw\y
  ;   
  ;   ; Intersected Outside Triangle
  ;   If *uvw\x<0 Or *uvw\y<0 Or *uvw\z<0 
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   Protected t.f = Vector3_Dot(@e2,@r)
  ;   PokeF(*t,t)
  ;   ProcedureReturn Bool(t>0.0)
  ;   
  ; EndProcedure
  
  ; Procedure TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,*t)
  ;   Define.v3f32 e1,e2,h,s,q
  ;   Define.f a,f,u,v,t
  ;   
  ;   Vector3_Sub(@e1,*b,*a)
  ;   Vector3_Sub(@e2,*c,*a)
  ;   
  ;   Vector3_Cross(@h,*ray\direction,@e2)
  ;   a = Vector3_Dot(@e1,@h)
  ;   
  ;   If a>-#F32_EPS And a<#F32_EPS
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   f = 1/a
  ;   Vector3_Sub(@s,*ray\origin,*a)
  ;   u = f * Vector3_Dot(@s,@h)
  ;   
  ;   If u<0.0 Or u>1.0
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   Vector3_Cross(@q,@s,@e1)
  ;   v = f*Vector3_Dot(*ray\direction,@q)
  ;   
  ;   If v<0.0 Or v>1.0
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   ; at this stage we can compute t To find out where
  ; 	; the intersection point is on the line
  ;   t = f * Vector3_Dot(@e2,@q)
  ;   
  ;   If t>#F32_EPS
  ;     PokeF(*t,t)
  ;     Vector3_Set(*uvw,u,v,0)
  ;     ProcedureReturn #True
  ;   Else; this means that there is a line intersection
  ; 		 ; but Not a ray intersection
  ;     ProcedureReturn #False
  ;   EndIf
  ;  
  ; EndProcedure
  
  ; ; MOLLER_TRUMBORE Algorithm
  ; Procedure TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,culling.b=#False)
  ;   Define.v3f32 e1,e2,p,t,q
  ;   Define.f det, invDet
  ;   Vector3_Sub(@e1,*b,*a)
  ;   Vector3_Sub(@e2,*c,*a)
  ;   
  ;   Vector3_Cross(@p,*ray\direction,@e2)
  ;   det.f = Vector3_Dot(@e1,@p)
  ;   
  ;   If culling 
  ;     If det < #F32_EPS : ProcedureReturn #False : EndIf
  ;   Else
  ;     ;     If Abs(det) < #F32_EPS : ProcedureReturn #False : EndIf 
  ;     If det > -#F32_EPS And det < #F32_EPS : ProcedureReturn #False : EndIf
  ;   EndIf
  ;     
  ;   invDet.f = 1/det
  ;   Vector3_Sub(@t,*ray\origin,*a)
  ;   
  ;   *uvw\x = Vector3_Dot(@t,@p) * invDet
  ;   If *uvw\x<0 Or *uvw\x>1 
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   Vector3_Cross(@q,@t,@e1)
  ;   *uvw\y = Vector3_Dot(*ray\direction,@q) * invDet
  ;   If *uvw\y<0 Or (*uvw\x+*uvw\y)>1 
  ;     ProcedureReturn #False
  ;   EndIf
  ;   
  ;   *uvw\z = Vector3_Dot(@e2,@q) * invDet
  ;   ProcedureReturn #True
  ;   
  ; EndProcedure
  
  ; Geometric Method
  ; Procedure TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,culling.b=#False)
  ;   Define.v3f32 ab,ac,e0,e1,e2,n,p,c,vp0,vp1,vp2
  ;   Define.f denom,NdotRayDirection,d,t
  ;   Vector3_Sub(@ab,*b,*a)
  ;   Vector3_Sub(@ac,*c,*a)
  ;   
  ;   ; No Need to normalize
  ;   Vector3_Cross(@n,@ab,@ac)
  ;   denom = Vector3_Dot(@n,@n)
  ;   
  ;   ; Step 1 : finding P
  ;   ; check If ray And plane are parallel ?
  ;   NdotRayDirection = Vector3_Dot(@n,*ray\direction)
  ;   If Abs(NdotRayDirection)<#F32_EPS : ProcedureReturn #False : EndIf
  ;   
  ;   ; Compute d
  ;   d = Vector3_Dot(@n,*a)
  ;   
  ;   ; Compute t
  ;   t = (Vector3_Dot(@n,*ray\origin)+d)/NdotRayDirection
  ;   ; Check if triangle is behind the ray
  ;   If t < 0 : ProcedureReturn #False : EndIf; // the triangle is behind 
  ;   
  ;   ; compute the intersection point using equation 1
  ;   Vector3_Scale(@p,*ray\direction,t)
  ;   Vector3_AddInPlace(@p,*ray\origin)
  ;  
  ;   ; Step 2: inside-outside test
  ;   ; c vector perpendicular To triangle's plane 
  ;   ; edge 0
  ;   Vector3_Sub(@e0,*b,*a)
  ;   Vector3_Sub(@vp0,@p,*a)
  ;   Vector3_Cross(@c,@e0,@vp0)
  ;   If Vector3_Dot(@n,@c)<0 : ProcedureReturn #False : EndIf ;P is on the right side 
  ;   
  ;   ; edge 1
  ;   Vector3_Sub(@e1,*c,*b)
  ;   Vector3_Sub(@vp1,@p,*b)
  ;   Vector3_Cross(@c,@e1,@vp1)
  ;   *uvw\x = Vector3_Dot(@n,@c)
  ;   If *uvw\x<0 : ProcedureReturn #False : EndIf ;P is on the right side 
  ;   
  ;   ; edge 2
  ;   Vector3_Sub(@e2,*a,*c)
  ;   Vector3_Sub(@vp2,@p,*c)
  ;   Vector3_Cross(@c,@e2,@vp2)
  ;   *uvw\y = Vector3_Dot(@n,@c)
  ;   If *uvw\y<0 : ProcedureReturn #False : EndIf ;P is on the right side 
  ;   
  ;   Vector3_Scale(*uvw,1/denom)
  ;   ProcedureReturn #True
  ;   
  ; EndProcedure
  
  
  ;---------------------------------------------
  ;  Init
  ;---------------------------------------------
  ;{
  Procedure.i Set(*Me.Geometry::Ray_t,*origin.v3f32,*direction.v3f32)
    
    If *origin : Vector3::SetFromOther(*Me\origin,*origin) : EndIf
    If *direction : Vector3::SetFromOther(*Me\direction,*direction) : EndIf
    
    InverseDirection(*Me)
    ProcedureReturn *Me
  EndProcedure

EndModule

;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 230
; FirstLine = 193
; Folding = ---
; EnableXP
; EnableUnicode