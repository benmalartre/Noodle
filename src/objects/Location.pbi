; ============================================================================
;  Location Object Module Implementation
; ============================================================================
XIncludeFile "Geometry.pbi"

DeclareModule Location
  UseModule Geometry
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
; CursorPosition = 65
; FirstLine = 55
; Folding = ---
; EnableXP