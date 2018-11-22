XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"

; ============================================================================
;  Segment Module IMPLEMENTATION
; ============================================================================
DeclareModule Segment
  UseModule Math
  #Segment_TOLERANCE = 0.0000000001
  
  Declare Set(*Me.Geometry::Segment_t,*start.v3f32,*end.v3f32)
  Declare SetStart(*Segment.Geometry::Segment_t,*pos.v3f32)
  Declare SetEnd(*Segment.Geometry::Segment_t,*pos.v3f32)
  
  Declare GetPoint( *segment.Geometry::Segment_t, t.f , *io.v3f32)
  Declare.b FindClosestPoint(*segment.Geometry::Segment_t, *p.v3f32, *t=#Null, *io.v3f32=#Null)
  Declare.b FindClosestPoints(*segment1.Geometry::Segment_t,
                              *segment2 .Geometry::Segment_t,
                              *closest1.v3f32,
                              *closest2.v3f32,
                              *t1=#Null,
                              *t2=#Null)
  
EndDeclareModule

Module Segment
  UseModule Math
  
  ;---------------------------------------------------------
  ; Set Origin
  ;---------------------------------------------------------
  Procedure SetStart(*line.Geometry::Segment_t,*pos.v3f32)
    Vector3::SetFromOther(*line\p1,*pos)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Direction
  ;---------------------------------------------------------
  Procedure SetEnd(*segment.Geometry::Segment_t,*pos.v3f32)
    Vector3::SetFromOther(*segment\p2,*pos)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Point
  ;---------------------------------------------------------
  ;Return the point on the line at \p ( p0 + t * dir ).
  ; Remember dir has been normalized so t represents a unit distance.
  Procedure GetPoint( *segment.Geometry::Segment_t, t.f , *io.v3f32)
    Protected direction.v3f32
    Vector3::Sub(direction, *segment\p2, *segment\p1)
    Vector3::NormalizeInPlace(direction)
    Vector3::Scale(*io, direction, t)
    Vector3::AddInPlace(*io, *segment\p1)
  EndProcedure
    
  ;---------------------------------------------------------
  ; Find Closest Point
  ;---------------------------------------------------------
  Procedure.b FindClosestPoint(*segment.Geometry::Segment_t, *p.v3f32, *t=#Null, *io.v3f32=#Null)
    ; Compute the vector from the start point To the given point.
    Protected v.v3f32, d.v3f32
    Vector3::Sub(v, *p, *segment\p1)
    Vector3::Sub(d, *segment\p2, *segment\p1)
    Vector3::NormalizeInPlace(d)
    ; Find the length of the projection of this vector onto the line.
    Protected lt.f = Vector3::Dot(v, d)
    
    If *t : PokeF(*t, lt) : EndIf
    If *io : GetPoint(*segment, lt, *io) : EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Find Closest Points
  ;---------------------------------------------------------
  Procedure.b FindClosestPoints(*segment1.Geometry::Segment_t,
                                *segment2.Geometry::Segment_t,
                                *closest1.v3f32,
                                *closest2.v3f32,
                                *t1=#Null,
                                *t2=#Null)
    ; Define terms:
    ;   p1 = line 1's position
    ;   d1 = line 1's direction
    ;   p2 = line 2's position
    ;   d2 = line 2's direction
    Protected *p1.v3f32 = *segment1\p1 
    Protected d1.v3f32
    Vector3::Sub(d1, *segment1\p2, *segment1\p2)
    Protected *p2.v3f32 = *segment2\p1
    Protected d2.v3f32
    Vector3::Sub(d2, *segment2\p2, *segment2\p2)
    
    ; We want To find points closest1 And closest2 on each line.
    ; Their parametric definitions are:
    ;   closest1 = p1 + t1 * d1
    ;   closest2 = p2 + t2 * d2
    ;
    ; We know that the line connecting closest1 And closest2 is
    ; perpendicular To both the ray And the line segment. So:
    ;   d1 . (closest2 - closest1) = 0
    ;   d2 . (closest2 - closest1) = 0
    ;
    ; Substituting gives us:
    ;   d1 . [ (p2 + t2 * d2) - (p1 + t1 * d1) ] = 0
    ;   d2 . [ (p2 + t2 * d2) - (p1 + t1 * d1) ] = 0
    ;
    ; Rearranging terms gives us:
    ;   t2 * (d1.d2) - t1 * (d1.d1) = d1.p1 - d1.p2
    ;   t2 * (d2.d2) - t1 * (d2.d1) = d2.p1 - d2.p2
    ;
    ; Substitute To simplify:
    ;   a = d1.d2
    ;   b = d1.d1
    ;   c = d1.p1 - d1.p2
    ;   d = d2.d2
    ;   e = d2.d1 (== a, If you're paying attention)
    ;   f = d2.p1 - d2.p2
    Protected a.f = Vector3::Dot(d1, d2)
    Protected b.f  = Vector3::Dot(d1, d1)
    Protected c.f  = Vector3::Dot(d1, *p1) - Vector3::Dot(d1, *p2)
    Protected d.f  = Vector3::Dot(d2, d2)
    Protected e.f  = a;
    Protected f.f  = Vector3::Dot(d2, *p1) - Vector3::Dot(d2, *p2)
    
    ; And we End up With:
    ;  t2 * a - t1 * b = c
    ;  t2 * d - t1 * e = f
    ;
    ; Solve For t1 And t2:
    ;  t1 = (c * d - a * f) / (a * e - b * d)
    ;  t2 = (c * e - b * f) / (a * e - b * d)
    ;
    ; Note the identical denominators...
    Protected denom.f = a * e - b * d

    ; Denominator == 0 means the lines are parallel; no intersection.
    If Abs(denom) < 1e-6 : ProcedureReturn #False : EndIf

    Protected lt1.f = (c * d - a * f) / denom
    Protected lt2.f = (c * e - b * f) / denom

    If ( *closest1 ) : GetPoint( *segment1, lt1, *closest1 ) : EndIf

    If ( *closest2 ) : GetPoint(*segment2, lt2, *closest2) : EndIf
    
    If ( *t1 ) : PokeF(*t1, lt1) : EndIf
    If ( *t2 ) : PokeF(*t2, lt2) : EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  ;---------------------------------------------
  ;  Set
  ;---------------------------------------------
  Procedure Set(*Me.Geometry::Segment_t,*p1.v3f32,*p2.v3f32)
    
    If *p1 : Vector3::SetFromOther(*Me\p1,*p1) : EndIf
    If *p2 : Vector3::SetFromOther(*Me\p2,*p2) : EndIf
    
    ProcedureReturn *Me
  EndProcedure

EndModule

;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; FirstLine = 17
; Folding = --
; EnableXP
; EnableUnicode