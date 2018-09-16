; ============================================================================
;  Location Object Module Implementation
; ============================================================================
XIncludeFile "Geometry.pbi"

DeclareModule Location
  UseModule Geometry
  UseModule Math
  Declare GetPosition(*Me.Location_t)
  Declare GetNormal(*Me.Location_t)
  Declare GetSmoothedNormal(*Me.Location_t)
  Declare GetColor(*Me.Location_t)
  Declare GetAttribute(*Me.Location_t,attribute.s)
  Declare Update(*Me.Location_t)
  Declare SetTriangleID(*Me.Location_t,ID.i=-1)
  Declare SetUVW(*Me.Location_t,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare New(*geom.Geometry::PolymeshGeometry_t,*t.Transform::Transform_t,tid.i=-1,u.f=0.0,v.f=0.0,w.f=0.0)
  Declare Delete(*Me.Location_t)
  Declare ClosestPoint( *Me.Location_t, *A.v3f32, *B.v3f32, *C.v3f32, *P.v3f32, *distance, maxDistance.f=Math::#F32_MAX)
  DataSection
    LocationVT:
  EndDataSection
  
EndDeclareModule

Module Location
  UseModule Math
  ;---------------------------------------------------------
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetPosition(*Me.Geometry::Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    Protected a,b,c

    a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
    b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
    c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
    
    *a = CArray::GetValue(*geom\a_positions,a)
    *b = CArray::GetValue(*geom\a_positions,b)
    *c = CArray::GetValue(*geom\a_positions,c)
    
    ; Position : P= wA + uB + vC
    Vector3::Set(*Me\p,0,0,0)
    Vector3::Scale(@x,*a, *Me\u)
    Vector3::AddInPlace(*Me\p,@x)
    Vector3::Scale(@x,*b, *Me\v)
    Vector3::AddInPlace(*Me\p,@x)
    Vector3::Scale(@x,*c, *Me\w)
    Vector3::AddInPlace(*Me\p,@x)
    Vector3::MulByMatrix4InPlace(*Me\p,*Me\t\m)
    ProcedureReturn *Me\p
   
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Normal
  ;---------------------------------------------------------
  Procedure GetNormal(*Me.Location_t)
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    Define.v3f32 *a,*b,*c,ab,ac
    Define a = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2)
    Define b = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1)
    Define c = CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3)
    
    *a = CArray::GetValue(*geom\a_positions,a)
    *b = CArray::GetValue(*geom\a_positions,b)
    *c = CArray::GetValue(*geom\a_positions,c)
    
    
    Vector3::Sub(@ab,*b,*a)
    Vector3::Sub(@ac,*c,*a)
    
    Vector3::NormalizeInPlace(@ab)
    Vector3::NormalizeInPlace(@ac)
    
    Vector3::Cross(*Me\n,@ab,@ac)
  ;   Vector3::MulByMatrix4InPlace(*Me\n,*Me\t\GetMatrix())
    Vector3::NormalizeInPlace(*Me\n)
    ;   Vector3::MulByQuaternionInPlace(*Me\n,*Me\t\GetQuaternion())
    
    ProcedureReturn *Me\n
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Smoothed Normal
  ;---------------------------------------------------------
  Procedure GetSmoothedNormal(*Me.Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
  ;   *a = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3))
  ;   *b = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3+1))
  ;   *c = *geom\a_pointnormals\GetValue(*geom\a_triangleindices\GetValue(*Me\tid*3+2))
    *a = CArray::GetValue(*geom\a_normals,*Me\tid*3)
    *b = CArray::GetValue(*geom\a_normals,*Me\tid*3+1)
    *c = CArray::GetValue(*geom\a_normals,*Me\tid*3+2)
    
  ;   Normal :
    Vector3::Set(*Me\n,0,0,0)
    Vector3::Scale(@x,*a,*Me\u)
    Vector3::AddInPlace(*Me\n,@x)
    Vector3::Scale(@x,*b,*Me\v)
    Vector3::AddInPlace(*Me\n,@x)
    Vector3::Scale(@x,*c,*Me\w)
    Vector3::AddInPlace(*Me\n,@x)
    Vector3::MulByMatrix4InPlace(*Me\n,*Me\t)
    
    ProcedureReturn *Me\n
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Color
  ;---------------------------------------------------------
  Procedure GetColor(*Me.Location_t)
    Define.c4f32 *a,*b,*c
    Define.c4f32 x
  
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    *a = CArray::GetValue(*geom\a_colors,*Me\tid*3)
    *b = CArray::GetValue(*geom\a_colors,*Me\tid*3+1)
    *c = CArray::GetValue(*geom\a_colors,*Me\tid*3+2)
    
    ; Color : P= wA + uB + vC
    Vector3::Set(*Me\c,0,0,0)
    Vector3::Scale(@x,*a,*Me\w)
    Vector3::AddInPlace(*Me\c,@x)
    Vector3::Scale(@x,*b,*Me\u)
    Vector3::AddInPlace(*Me\c,@x)
    Vector3::Scale(@x,*c,*Me\v)
    Vector3::AddInPlace(*Me\c,@x)
  
  ;   ; Color
  ;   Color4_Set(*Me\n,0,0,0,0)
  ;   Color4_Scale(@x,*a,*Me\u)
  ;   Color4_AddInPlace(*Me\c,@x)
  ;   Color4_Scale(@x,*b,*Me\v)
  ;   Color4_AddInPlace(*Me\c,@x)
  ;   Color4_Scale(@x,*c,1-(*Me\u+*Me\v))
  ;   Color4_AddInPlace(*Me\c,@x)
    
    ProcedureReturn(*Me\c)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Interpolated Attribute
  ;---------------------------------------------------------
  Procedure GetAttribute(*Me.Location_t,attribute.s)
  
  EndProcedure
  
  ;---------------------------------------------------------
  ; Update
  ;---------------------------------------------------------
  Procedure Update(*Me.Location_t)
    Define.v3f32 *a,*b,*c
    Define.v3f32 x
    Define.v3f32 ab,ac
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geometry
    *a = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3))
    *b = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+1))
    *c = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,*Me\tid*3+2))
    
    ; Position
    Vector3::Set(*Me\p,0,0,0)
    Vector3::Scale(@x,*a,*Me\u)
    Vector3::AddInPlace(*Me\p,@x)
    Vector3::Scale(@x,*b,*Me\v)
    Vector3::AddInPlace(*Me\p,@x)
    Vector3::Scale(@x,*c,1-(*Me\u+*Me\v))
    Vector3::AddInPlace(*Me\p,@x)
    
    ; Normal
    Vector3::Sub(@ab,*b,*a)
    Vector3::Sub(@ac,*c,*a)
    Vector3::Cross(*Me\n,@ab,@ac)
    Vector3::NormalizeInPlace(*Me\n)
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set Triangle ID
  ;------------------------------------------------------------------
  Procedure SetTriangleID(*Me.Location_t,ID.i=-1)
    If Not *Me : ProcedureReturn : EndIf
    *Me\tid = ID
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set UVW
  ;------------------------------------------------------------------
  Procedure SetUVW(*Me.Location_t,u.f=0.0,v.f=0.0,w.f=0.0)
    If Not *Me : ProcedureReturn : EndIf
    *Me\u = u
    *Me\v = v
    *Me\w = w
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Closest Point
  ;------------------------------------------------------------------
  Procedure ClosestPoint( *Me.Location_t, *A.v3f32, *B.v3f32, *C.v3f32, *P.v3f32, *distance, maxDistance.f=Math::#F32_MAX)
    Protected edge0.v3f32
    Protected edge1.v3f32
    
    Vector3::Sub(@edge0, *B, *A)
    Vector3::Sub(@edge1, *C, *A)
    
    Protected v0.v3f32
    Vector3::Sub(@v0, *A, *P)
    
    Define.f a,b,c,d,e
    a = Vector3::Dot(@edge0, @edge0)
    b = Vector3::Dot(@edge0, @edge1)
    c = Vector3::Dot(@edge1, @edge1)
    d = Vector3::Dot(@edge0, @v0)
    e = Vector3::Dot(@edge1, @v0)
    
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

  Protected closest.v3f32, delta.v3f32
  Vector3::SetFromOther(@closest, *A)
  Vector3::ScaleInPlace(@edge0, s)
  Vector3::ScaleInPlace(@edge1, t)
  Vector3::AddInPlace(@closest, @edge0)
  Vector3::AddInPlace(@closest, @edge1)
  
  Vector3::Sub(@delta, *p, @closest)
  d.f = Vector3::Length(@delta)
  
  If d < maxDistance And d < PeekF(*distance)
    Vector3::SetFromOther(*Me\p, @closest)
    *Me\v = s
    *Me\w = t
    *Me\u = 1.0 - v - w
    PokeF(*distance, d)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False

EndProcedure

  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Location_t)
   If Not *Me : ProcedureReturn : EndIf
    ClearStructure(*Me,Location_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*geom.Geometry::Geometry_t,*t.Transform::Transform_t,tid.i=-1,u.f=0.0,v.f=0.0,w.f=0.0)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Location_t = AllocateMemory(SizeOf(Location_t))
    
    ; ----[ Initialize ]--------------------------------------------------------
    *Me\tid = tid
    *Me\geometry = *geom
    *Me\u = u
    *Me\v = v
    *Me\w = w
    *Me\t = *t
    If *Me\geometry And *Me\tid>-1
      ;Update(*Me)
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 300
; FirstLine = 263
; Folding = ---
; EnableXP