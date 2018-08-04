XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"

; ============================================================================
;  Ray Module IMPLEMENTATION
; ============================================================================
DeclareModule Ray
  UseModule Math
  
  Declare Set(*Me.Geometry::Ray_t,*origin.v3f32,*direction.v3f32)
  Declare InverseDirection(*ray.Geometry::Ray_t)
  Declare SetPosition(*ray.Geometry::Ray_t,*pos.v3f32)
  Declare BoxIntersection(*ray.Geometry::Ray_t, *box.Geometry::Box_t)
  Declare CylinderIntersection(*ray.Geometry::Ray_t, *cylinder.Geometry::Cylinder_t)
  Declare.f SphereIntersection(*ray.Geometry::Ray_t, *sphere.Geometry::Sphere_t)
  Declare.f TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,*t)
EndDeclareModule

Module Ray
  UseModule Math
  ;---------------------------------------------------------
  ; Get Inverse Direction
  ;---------------------------------------------------------
  Procedure InverseDirection(*ray.Geometry::Ray_t)
    Vector3::ScaleInPlace(*ray\inv_direction,-1)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Position
  ;---------------------------------------------------------
  Procedure SetPosition(*ray.Geometry::Ray_t,*pos.v3f32)
    Vector3::SetFromOther(*ray\origin,*pos)
  EndProcedure
  
  ; ;---------------------------------------------------------
  ; ; Get Inverse Direction
  ; ;---------------------------------------------------------
  ; Procedure Inverse(*ray.Geometry::Ray_t,*m.m4f32)
  ;   Vector3_MulByMatrix4(*ray\inv_direction,*ray\direction,*m)
  ;   Vector3_MulByMatrix4(*ray\inv_origin,*ray\origin,*m)
  ; EndProcedure
  
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
  ; Intersection with triangle
  ;---------------------------------------------------------
  Procedure.f TriangleIntersection(*ray.Geometry::Ray_t, *a.v3f32, *b.v3f32, *c.v3f32,*uvw.v3f32,*t)
    Define.v3f32 e1,e2,q,s,r
    ; edge vectors
    Vector3::Sub(@e1,*b,*a)
    Vector3::Sub(@e2,*c,*a)
    
    Vector3::Cross(@q,*ray\direction,@e2)
    
    Define a.f =Vector3::Dot(@e1,@q)
    Vector3::Sub(@s,*ray\origin,*a)
    Vector3::Cross(@r,@s,@e1)
    
    ;Barycentric vertex weights
    *uvw\y = Vector3::Dot(@s,@q)/a
    *uvw\x = Vector3::Dot(*ray\direction,@r)/a
    *uvw\z = 1.0 - (*uvw\x + *uvw\y)
    
    Define dist.f =Vector3::Dot(@e2,@r)/a
    
    If a<#F32_EPS Or *uvw\x<-#F32_EPS Or *uvw\y<-#F32_EPS Or *uvw\z<-#F32_EPS Or dist<0.0
      ProcedureReturn #False
    Else
      PokeF(*t,dist)
      ProcedureReturn #True
    EndIf
    
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
    
  ;   InverseDirection(*Me)
    ProcedureReturn *Me
  EndProcedure

EndModule

;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; FirstLine = 9
; Folding = --
; EnableXP
; EnableUnicode