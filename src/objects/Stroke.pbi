XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Segment.pbi"

; ============================================================================
;  Stroke Module IMPLEMENTATION
; ============================================================================
DeclareModule Stroke
  UseModule Math
  #Stroke_TOLERANCE = 0.0000000001
  
  Declare SetPoints(*Me.Geometry::Stroke_t,*pnts.CArray::CArrayV3F32)
  Declare SetPackedPoints(*Me.Geometry::Stroke_t,*pnts.CArray::CArrayV4F32)
  Declare SetColors(*Me.Geometry::Stroke_t,*colors.CArray::CArrayC4F32)
  Declare SetRadius(*Me.Geometry::Stroke_t,*radius.CArray::CArrayFloat)
  Declare AddPoint(*Stroke.Geometry::Stroke_t,*pos.v3f32, *col.c4f32, radius.f)
  Declare AddPoints(*Stroke.Geometry::Stroke_t,*pnts.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32, *radius.CArray::CArrayFloat)
  
  Declare GetPoint( *Stroke.Geometry::Stroke_t, t.f , *io.v3f32, *color.c4f32, *radius)
  Declare.b FindClosestPoint(*Stroke.Geometry::Stroke_t, *p.v3f32, *t=#Null, *io.v3f32=#Null)
  Declare.b FindClosestPoints(*Stroke1.Geometry::Stroke_t,
                              *Stroke2.Geometry::Stroke_t,
                              *closest1.v3f32,
                              *closest2.v3f32,
                              *t1=#Null,
                              *t2=#Null)
  Declare.f AccumulatedLength(*stroke.Geometry::Stroke_t, *accumulated.CArray::CArrayFloat)
  Declare Resample(*Stroke.Geometry::Stroke_t, size.f)
  Declare New()
  Declare Delete(*Me.Geometry::Stroke_t)
  
EndDeclareModule

Module Stroke
  UseModule Math
  
  ;---------------------------------------------------------
  ; Constructor
  ;---------------------------------------------------------
  Procedure New()
    Protected *stroke.Geometry::Stroke_t = AllocateMemory(SizeOf(Geometry::Stroke_t))
    InitializeStructure(*stroke, Geometry::Stroke_t)
    *stroke\datas = CArray::newCArrayV4F32()
    ProcedureReturn *stroke
  EndProcedure
  
  ;---------------------------------------------------------
  ; Destructor
  ;---------------------------------------------------------
  Procedure Delete(*stroke.Geometry::Stroke_t)
    CArray::Delete(*stroke\datas)
    ClearStructure(*stroke, Geometry::Stroke_t)
    FreeMemory(*stroke)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Colors
  ;---------------------------------------------------------
  Procedure SetColors(*Stroke.Geometry::Stroke_t,*colors.CArray::CArrayC4F32)
;     CArray::Copy(*Stroke\colors, *colors)
  EndProcedure
  
  
  ;---------------------------------------------------------
  ; Set Points
  ;---------------------------------------------------------
  Procedure SetPoints(*Stroke.Geometry::Stroke_t,*pnts.CArray::CArrayV3F32) 
;     CArray::Copy(*Stroke\positions, *pnts)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Packed Points
  ;---------------------------------------------------------
  Procedure SetPackedPoints(*Stroke.Geometry::Stroke_t,*pnts.CArray::CArrayV4F32) 
    CArray::Copy(*Stroke\datas, *pnts)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Points
  ;---------------------------------------------------------
  Procedure SetRadius(*Stroke.Geometry::Stroke_t,*radius.CArray::CArrayFloat)
;     CArray::Copy(*Stroke\radius, *radius)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Add Point
  ;---------------------------------------------------------
  Procedure AddPoint(*stroke.Geometry::Stroke_t,*pos.v3f32, *col.c4f32, radius.f)
    Protected datas.v4f32
    Vector4::Set(datas, *pos\x, *pos\y, radius, Random(MATH::#COLOR_MAX));Color::PackColor(*col))
    CArray::Append(*stroke\datas, datas)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Add Packed Point
  ;---------------------------------------------------------
  Procedure AddPackedPoint(*stroke.Geometry::Stroke_t,*datas.v4f32)
    CArray::Append(*stroke\datas, *datas)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Add Points
  ;---------------------------------------------------------
  Procedure AddPoints(*Stroke.Geometry::Stroke_t,*pnts.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32, *radius.CArray::CArrayFloat)
    Define *tmp.CArray::CArrayV4F32 = CArray::newCArrayV4F32()
    CArray::SetCount(*tmp, *pnts\itemCount)
    Define i
    Define *v.v4f32
    Define *p.v3f32
    Define *c.c4f32
    Define radius.f
    
    For i=0 To *pnts\itemCount - 1
      *v = CArray::GetValue(*tmp, i)
      *p = CArray::GetValue(*pnts, i)
      *c = CArray::GetValue(*colors, i)
      radius = CArray::GetValueF(*radius, i)
      Vector4::Set(*v, *p\x, *p\y, radius, Color::PackColor(*c))
    Next
    
    CArray::AppendArray(*stroke\datas, *tmp)
    CArray::Delete(*tmp)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Add Packed Points
  ;---------------------------------------------------------
  Procedure AddPackedPoints(*Stroke.Geometry::Stroke_t,*datas.CArray::CArrayV4F32)
    CArray::AppendArray(*stroke\datas, *datas)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Length
  ;---------------------------------------------------------
  Procedure.f AccumulatedLength(*stroke.Geometry::Stroke_t, *accumulated.CArray::CArrayFloat)
    Define length.f
    Define s.i
    Define.v2f32 *a, *b, delta
    Define nbp = CArray::GetCount(*stroke\datas)
    CArray::SetCount(*accumulated, nbp)
    If nbp > 1
      CArray::SetValueF(*accumulated, 0, 0)
      For s=1 To nbp-1
        *a = CArray::GetValue(*stroke\datas, s-1)
        *b = CArray::GetValue(*stroke\datas, s)
        Vector2::Sub(delta, *a, *b)
        length + Vector2::Length(delta)
        CARray::SetValueF(*accumulated,s, length)
      Next
    EndIf
    ProcedureReturn length
  EndProcedure
  
  ;---------------------------------------------------------
  ; Resample
  ;---------------------------------------------------------
  Procedure Resample(*Stroke.Geometry::Stroke_t, size.f)
    Define initNb = CArray::GetCount(*stroke\datas)
    Define *accumulated.CArray::CArrayFloat = CArray::newCArrayFloat()
    Define *newdatas.CArray::CArrayV4f32 = CARray::newCArrayV4F32()
    
    Define initLen.f = AccumulatedLength(*stroke, *accumulated)
    Define finalNb = Max(initLen / size, 2)
    CArray::SetCount(*newdatas, finalNb)
    Define segLen.f = initLen / finalNb
    Define curLen.f
    Define sAccumLen.f, eAccumLen.f
    Define i, j
    Define *p.v4f32, *s.v4f32, *e.v4f32
    For i =0 To finalNb-1
      curLen = i*segLen
      While curLen > CArray::GetValueF(*accumulated, j)
        j+1
      Wend
      sAccumLen = CArray::GetValueF(*accumulated, j)
      eAccumLen = CArray::GetValueF(*accumulated, j+1)
      
      *p = CArray::GetValue(*newdatas, i)
      *s = CArray::GetValue(*stroke\datas, j)
      *e = CArray::GetValue(*stroke\datas, j+1)

      *p\x = *s\x + (curLen - sAccumLen) * (*e\x - *s\x) / (eAccumLen - sAccumLen)
      *p\y = *s\y + (curLen - sAccumLen) * (*e\y - *s\y) / (eAccumLen - sAccumLen)
      *p\z = *s\z + (curLen - sAccumLen) * (*e\z - *s\z) / (eAccumLen - sAccumLen)
      *p\w = *s\w + (curLen - sAccumLen) * (*e\w - *s\w) / (eAccumLen - sAccumLen)
    Next

    SetPackedPoints(*stroke, *newdatas)
    CArray::Delete(*accumulated)
    CArray::Delete(*newdatas)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Point
  ;---------------------------------------------------------
  ;Return the point on the Stroke at \p ( p0 + t * dir ).
  ; Remember dir has been normalized so t represents a unit distance.
  Procedure GetPoint( *Stroke.Geometry::Stroke_t, t.f , *io.v3f32, *color.c4f32, *radius)
    Protected direction.v3f32
    
;     Vector3::Sub(direction, *Stroke\p2, *Stroke\p1)
;     Vector3::NormalizeInPlace(direction)
;     Vector3::Scale(*io, direction, t)
;     Vector3::AddInPlace(*io, *Stroke\p1)
  EndProcedure
    
  ;---------------------------------------------------------
  ; Find Closest Point
  ;---------------------------------------------------------
  Procedure.b FindClosestPoint(*Stroke.Geometry::Stroke_t, *p.v3f32, *t=#Null, *io.v3f32=#Null)
    ; Compute the vector from the start point To the given point.
;     Protected v.v3f32, d.v3f32
;     Vector3::Sub(v, *p, *Stroke\p1)
;     Vector3::Sub(d, *Stroke\p2, *Stroke\p1)
;     Vector3::NormalizeInPlace(d)
;     ; Find the length of the projection of this vector onto the Stroke.
;     Protected lt.f = Vector3::Dot(v, d)
;     
;     If *t : PokeF(*t, lt) : EndIf
;     If *io : GetPoint(*Stroke, lt, *io) : EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Find Closest Points
  ;---------------------------------------------------------
  Procedure.b FindClosestPoints(*Stroke1.Geometry::Stroke_t,
                                *Stroke2.Geometry::Stroke_t,
                                *closest1.v3f32,
                                *closest2.v3f32,
                                *t1=#Null,
                                *t2=#Null)
;     ; Define terms:
;     ;   p1 = Stroke 1's position
;     ;   d1 = Stroke 1's direction
;     ;   p2 = Stroke 2's position
;     ;   d2 = Stroke 2's direction
;     Protected *p1.v3f32 = *Stroke1\p1 
;     Protected d1.v3f32
;     Vector3::Sub(d1, *Stroke1\p2, *Stroke1\p2)
;     Protected *p2.v3f32 = *Stroke2\p1
;     Protected d2.v3f32
;     Vector3::Sub(d2, *Stroke2\p2, *Stroke2\p2)
;     
;     ; We want To find points closest1 And closest2 on each Stroke.
;     ; Their parametric definitions are:
;     ;   closest1 = p1 + t1 * d1
;     ;   closest2 = p2 + t2 * d2
;     ;
;     ; We know that the Stroke connecting closest1 And closest2 is
;     ; perpendicular To both the ray And the Stroke segment. So:
;     ;   d1 . (closest2 - closest1) = 0
;     ;   d2 . (closest2 - closest1) = 0
;     ;
;     ; Substituting gives us:
;     ;   d1 . [ (p2 + t2 * d2) - (p1 + t1 * d1) ] = 0
;     ;   d2 . [ (p2 + t2 * d2) - (p1 + t1 * d1) ] = 0
;     ;
;     ; Rearranging terms gives us:
;     ;   t2 * (d1.d2) - t1 * (d1.d1) = d1.p1 - d1.p2
;     ;   t2 * (d2.d2) - t1 * (d2.d1) = d2.p1 - d2.p2
;     ;
;     ; Substitute To simplify:
;     ;   a = d1.d2
;     ;   b = d1.d1
;     ;   c = d1.p1 - d1.p2
;     ;   d = d2.d2
;     ;   e = d2.d1 (== a, If you're paying attention)
;     ;   f = d2.p1 - d2.p2
;     Protected a.f = Vector3::Dot(d1, d2)
;     Protected b.f  = Vector3::Dot(d1, d1)
;     Protected c.f  = Vector3::Dot(d1, *p1) - Vector3::Dot(d1, *p2)
;     Protected d.f  = Vector3::Dot(d2, d2)
;     Protected e.f  = a;
;     Protected f.f  = Vector3::Dot(d2, *p1) - Vector3::Dot(d2, *p2)
;     
;     ; And we End up With:
;     ;  t2 * a - t1 * b = c
;     ;  t2 * d - t1 * e = f
;     ;
;     ; Solve For t1 And t2:
;     ;  t1 = (c * d - a * f) / (a * e - b * d)
;     ;  t2 = (c * e - b * f) / (a * e - b * d)
;     ;
;     ; Note the identical denominators...
;     Protected denom.f = a * e - b * d
; 
;     ; Denominator == 0 means the Strokes are parallel; no intersection.
;     If Abs(denom) < 1e-6 : ProcedureReturn #False : EndIf
; 
;     Protected lt1.f = (c * d - a * f) / denom
;     Protected lt2.f = (c * e - b * f) / denom
; 
;     If ( *closest1 ) : GetPoint( *Stroke1, lt1, *closest1 ) : EndIf
; 
;     If ( *closest2 ) : GetPoint(*Stroke2, lt2, *closest2) : EndIf
;     
;     If ( *t1 ) : PokeF(*t1, lt1) : EndIf
;     If ( *t2 ) : PokeF(*t2, lt2) : EndIf
;     
;     ProcedureReturn #True
  EndProcedure
  
EndModule

;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 89
; FirstLine = 85
; Folding = ---
; EnableXP
; EnableUnicode