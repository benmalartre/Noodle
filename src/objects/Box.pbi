XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Line.pbi"
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
  Declare.f SquareDistance1D(pn.f, bmin.f, bmax.f)
  Declare.f SquareDistance(*Me.Box_t, *point.v3f32)

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
    Vector4::MulByMatrix4(*Me\origin, origin, *m)
    Vector4::Set(extend, *Me\extend\x, *Me\extend\y, *Me\extend\z, 0)
    Vector4::MulByMatrix4(*Me\extend, extend, *m)
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
    ProcedureReturn Bool(*p\x>=*Me\origin\x-*Me\extend\x And *p\x <= *Me\origin\x+*Me\extend\x And
                         *p\y>=*Me\origin\y-*Me\extend\y And *p\y <= *Me\origin\y+*Me\extend\y And
                         *p\z>=*Me\origin\z-*Me\extend\z And *p\z <= *Me\origin\z+*Me\extend\z)

  EndProcedure
  
  ;---------------------------------------------------------
  ; Intersect Box
  ;---------------------------------------------------------
  Procedure.b IntersectBox(*Me.Geometry::Box_t,*other.Geometry::Box_t)
    If *Me\origin\x + *Me\extend\x < *other\origin\x - *other\extend\x :ProcedureReturn #False : EndIf
    If *Me\origin\x - *Me\extend\x < *other\origin\x + *other\extend\x :ProcedureReturn #False : EndIf
    If *Me\origin\y + *Me\extend\y < *other\origin\y - *other\extend\y :ProcedureReturn #False : EndIf
    If *Me\origin\y - *Me\extend\y < *other\origin\y + *other\extend\y :ProcedureReturn #False : EndIf
    If *Me\origin\z + *Me\extend\z < *other\origin\z - *other\extend\z :ProcedureReturn #False : EndIf
    If *Me\origin\z - *Me\extend\z < *other\origin\z + *other\extend\z :ProcedureReturn #False : EndIf
    ProcedureReturn #True
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
    ProcedureReturn #False
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
  Procedure.f SquareDistance1D(pn.f, bmin.f, bmax.f)
    Protected out.f = 0
    Protected v.f = pn
    Protected val.f
    If v < bmin : val = bmin - v : out + Pow(val, 2) : EndIf          
    If v > bmax : val = v - bmax : out + Pow(val, 2) : EndIf
    ProcedureReturn out
  EndProcedure
  
  ;---------------------------------------------------------
  ; SquareDistance 
  ;---------------------------------------------------------
  Procedure.f SquareDistance(*Me.Geometry::Box_t, *p.v3f32)
    ; Squared distance
    Protected sq.f = 0.0
 
    sq + SquareDistance1D( *p\x, *Me\origin\x-*Me\extend\x, *Me\origin\x+*Me\extend\x )
    sq + SquareDistance1D( *p\y, *Me\origin\y-*Me\extend\y, *Me\origin\y+*Me\extend\y )
    sq + SquareDistance1D( *p\z, *Me\origin\z-*Me\extend\z, *Me\origin\z+*Me\extend\z )
 
    ProcedureReturn sq
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 43
; FirstLine = 36
; Folding = ---
; EnableXP
; EnableUnicode