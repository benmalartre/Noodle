XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

;========================================================================================
; PointCloudGeometry Module Declaration
;========================================================================================
DeclareModule PointCloudGeometry
  UseModule Math
  UseModule Geometry
  Declare New(*parent,nbp.i=0)
  Declare Delete(*Me.PointCloudGeometry_t)
  Declare Init(*Me.PointCloudGeometry_t, nb.i=-1)
  Declare Update(*Me.PointCloudGeometry_t)
  Declare PointsOnSphere(*Me.PointCloudGeometry_t, nb.i, radius.f)
  Declare PointsOnGrid(*Me.PointCloudGeometry_t, nx.i, nz.i)
  Declare PointsOnLine(*Me.PointCloudGeometry_t,nb.i, *start.v3f32,*end.v3f32)
  Declare RandomizeColor(*Me.PointCloudGeometry_t,*base.c4f32 = #Null, randomize.f = 0.5)
  Declare AddPoints(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32 )
  Declare Reset(*p.PointCloudGeometry_t)
  Declare SetPositions(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32)
  Declare SetColors(*p.PointCloudGeometry_t, *col.CArray::CArrayC4F32)
  Declare SetSizes(*p.PointCloudGeometry_t, *siz.CArray::CArrayFloat)
  Declare SetSize(*p.PointCloudGeometry_t, siz.f)
  
  DataSection 
    PointCloudGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

;========================================================================================
; PointCloudGeometry Module Implementation
;========================================================================================
Module PointCloudGeometry
  UseModule Geometry
  UseModule Math

  ; Init
  ;-----------------------------------------------------------
  Procedure Init(*Me.PointCloudGeometry_t, nb.i=-1)
    Protected i
    Protected *pos.v3f32,*norm.v3f32,*tan.v3f32
    Protected *col.c4f32
    Protected size.f = 1.0
    If nb >= 0 And nb <> *Me\nbpoints
      *Me\nbpoints = nb
      CArray::SetCount(*Me\a_positions,*Me\nbpoints)
      CArray::SetCount(*Me\a_velocities,*Me\nbpoints)
      CArray::SetCount(*Me\a_normals,*Me\nbpoints)
      CArray::SetCount(*Me\a_tangents,*Me\nbpoints)
      CArray::SetCount(*Me\a_color,*Me\nbpoints)
      CArray::SetCount(*Me\a_scale,*Me\nbpoints)
      CArray::SetCount(*Me\a_size,*Me\nbpoints)
      CArray::SetCount(*Me\a_indices,*Me\nbpoints)
      CArray::SetCount(*Me\a_uvws,*Me\nbpoints)
    EndIf
  EndProcedure
  
  ; Update
  ;-----------------------------------------------------------
  Procedure Update(*Me.PointCloudGeometry_t)
    
  EndProcedure
  
  ; Points  On Sphere
  ;-----------------------------------------------------------
  Procedure PointsOnSphere(*Me.PointCloudGeometry_t, nb.i, radius.f)
    Init(*Me, nb)
    
    Protected i
    Protected v.v3f32
    Protected c.c4f32
    Protected s.v3f32
    Protected t.v3f32
    
    Vector3::Set(s,1,1,1)
    
    Define.f r,g,b, x,y ,z
    
    For i=0 To *Me\nbPoints-1
      ;Set Position
      x = Random(255)/255 - 0.5
      y = Random(255)/255 - 0.5
      z = Random(255)/255 - 0.5
      
      Vector3::Set(v,x,y,z)
      Vector3::NormalizeInPlace(v)
      Vector3::ScaleInPlace(v,radius)
      
      CArray::SetValue(*Me\a_positions,i,v)

      ; Set Normals
      Vector3::NormalizeInPlace(v)
      CArray::SetValue(*Me\a_normals,i,v)
      
      ; Set Tangents
      Vector3::Set(c,0,1,0)
      Vector3::Cross(t,v,c)
      CArray::SetValue(*Me\a_tangents,i,t)

      ; Set Color
      r = (120+Random(50))/255
      g = (20+Random(5))/255
      b = (10+Random(4))/255
      Color::Set(c,r,g,b,1.0)
      CArray::SetValue(*Me\a_color,i,c)

      ; Set Scale
      Vector3::Set(s,1,1,1)
      CArray::SetValue(*Me\a_scale,i,s)
      
      ; Set Size
      CArray::SetValueF(*Me\a_size,i,Random_0_1() * 12)
      
    Next 

  EndProcedure
  
  ; Point On Grid
   ;-----------------------------------------------------------
  Procedure PointsOnGrid(*Me.PointCloudGeometry_t, nx.i, nz.i)
    Init(*Me, nx * nz)
   
    Protected i
    Protected v.v3f32
    Protected c.c4f32
    Protected s.v3f32
    Protected t.v3f32
    Protected incrx.f = 1.0
    Protected incrz.f = 1.0
    
    Vector3::Set(s,1,1,1)
    
    Define.f r,g,b
    Protected x, z
    i=0
    
    For x=0 To nx-1
      For z=0 To nz-1
        ; position
        Vector3::Set(v,x*incrx,0,z*incrz)
        CArray::SetValue(*Me\a_positions,i,v)
        
       ; Set Normals
        Vector3::Set(v, 0,1,0)
        CArray::SetValue(*Me\a_normals,i,v)
        
        ; Set Tangents
        Vector3::Set(t,1,0,0)
        CArray::SetValue(*Me\a_tangents,i,t)
  
        ; Set Color
        r = (120+Random(50))/255
        g = (20+Random(5))/255
        b = (10+Random(4))/255
        Color::Set(c,r,g,b,1.0)
        CArray::SetValue(*Me\a_color,i,c)
  
        ; Set Scale
        Vector3::Set(s,1,1,1)
        CArray::SetValue(*Me\a_scale,i,s)
        
        ; Set Size
        CArray::SetValueF(*Me\a_size,i,1)
        
        ; increment counter
        i + 1
      Next
    Next

  EndProcedure
  
  
  ; Points  On Line
  ;-----------------------------------------------------------
  Procedure PointsOnLine(*Me.PointCloudGeometry_t, nb.i, *start.v3f32,*end.v3f32)
    Init(*Me, nb)
    
    Protected i
    Protected *v.v3f32
    Protected *c.c4f32
    Protected *s.v3f32
    Protected *t.v3f32
    Protected tmp.v3f32
   
    
    Define.f r,g,b, x,y ,z
    Define delta.v3f32
    Vector3::Sub(delta,*end,*start)
    
    Define l.f = Vector3::Length(delta)
    Define st.f = l/(*Me\nbPoints-1.0)
    Define stc.f
    
    For i=0 To *Me\nbPoints-1
      ; step
      stc = st * i / l
      
      ;Set Position
      *v = CArray::GetValue(*Me\a_positions,i)
      Vector3::LinearInterpolate(*v,*start,*end,stc)
      
      ; Set Normal
      *v = CArray::GetValue(*Me\a_normals,i)
      Vector3::NormalizeInPlace(*v)
      
      ; Set Tangent
      *t = CArray::GetValue(*Me\a_tangents,i)
      Vector3::Set(*t,0,1,0)
      Vector3::Cross(tmp,*v,*t)
      Vector3::SetFromOther(*t,@tmp)
      
      ;Set Color
      *c = CArray::GetValue(*Me\a_color,i)
      r = (120+Random(50))/255
      g = (20+Random(5))/255
      b = (10+Random(4))/255
      Color::Set(*c,r,g,b,1.0)

      ;Set Scale
      *s = CArray::GetValue(*Me\a_scale,i)
      Vector3::Set(*s,0.1,0.1,0.1)
      
      ;Set Size
      CArray::SetValueF(*Me\a_size,i,1)
      
    Next 
  EndProcedure
  
  ; Randomize Colors
  ;----------------------------------------------
  Procedure RandomizeColor(*Me.Geometry::PointCloudGeometry_t,*base.c4f32 = #Null,randomize.f = 0.5)
    Protected i.i
    Protected *c.c4f32
    Protected r.f,g.f,b.f,a.f

    If *base = #Null
      Protected base.c4f32
      Color::Set(base,0.5,0.5,0.5,1.0)
      *base = base
    EndIf
    
    For i=0 To CArray::GetCount(*Me\a_color)-1
      *c = CArray::GetValue(*Me\a_color,i)
      r = (Random(255)/255 + 0.5) * randomize
      g = (Random(255)/255 + 0.5) * randomize
      b = (Random(255)/255 + 0.5) * randomize
      a = 1
      Color::Set(*c,r,g,b,a)
    Next
  EndProcedure
  
  ; Add Points
  ;----------------------------------------------
  Procedure AddPoints(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32 )
    Protected i

    Protected nbp.i = CArray::GetCount(*pos)
    Protected v.v3f32
    Protected c.v3f32
    Protected n.v3f32
    Protected s.v3f32
    Protected t.v3f32
    Vector3::Set(s,1,1,1)
    
    Define .f r,g,b
    
    For i=0 To nbp-1
      *p\nbpoints + 1
      CArray::Append(*p\a_positions,CArray::GetValue(*pos,i))
      CArray::Append(*p\a_velocities,CArray::GetValue(*pos,i))
      Vector3::Set(n,0,1,0)
      CArray::Append(*p\a_normals,n)
      Vector3::Set(c,1,0,0)
      Vector3::Cross(t,n,c)
      CArray::Append(*p\a_tangents,t)

      CArray::AppendI(*p\a_indices,*p\incrementID)
      
      ;Set Color
      r = Random(255)/255
      g = Random(255)/255
      b = Random(255)/255
      Vector3::Set(c,r,g,b)
      CArray::Append(*p\a_color,c)
      
      Vector3::Set(s,1,1,1)
      CArray::Append(*p\a_scale,s)
      
      CArray::AppendF(*p\a_size,1)
  
      ;Increment Counter
      *p\incrementID + 1
    Next i
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Reset
  ;---------------------------------------------------------
  Procedure Reset(*Me.PointCloudGeometry_t)
    *Me\nbpoints = 0
    CArray::SetCount(*Me\a_positions,0)
    CArray::SetCount(*Me\a_velocities,0)
    CArray::SetCount(*Me\a_normals,0)
    CArray::SetCount(*Me\a_tangents,0)
    CArray::SetCount(*Me\a_indices,0)
    CArray::SetCount(*Me\a_size,0)
    CArray::SetCount(*Me\a_scale,0)
    CArray::SetCount(*Me\a_uvws,0)
    CArray::SetCount(*Me\a_color,0)
;     If Not CArray::GetCount(*Me\topo\vertices) = CArray::GetCount(*Me\base\vertices) Or Not CArray::GetCount(*Me\topo\faces) = CArray::GetCount(*Me\base\faces)
;       Set2(*Me,*Me\base)
;     Else
;       SetPointsPosition(*Me,*Me\base\vertices)
;       ;SetPointsNormal(*Me,*Me\base\normals)
;       ;RecomputeNormals(*Me)
;     EndIf   

  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Positions
  ;---------------------------------------------------------
  Procedure SetPositions(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32)
    If CArray::GetCount(*pos) = *p\nbpoints
      CArray::Copy(*p\a_positions, *pos) 
    EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Colors
  ;---------------------------------------------------------
  Procedure SetColors(*p.PointCloudGeometry_t, *col.CArray::CArrayC4F32)
    If CArray::GetCount(*col) = *p\nbpoints
      CArray::Copy(*p\a_color, *col)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Sizes
  ;---------------------------------------------------------
  Procedure SetSizes(*p.PointCloudGeometry_t, *siz.CArray::CArrayFloat)
    If CArray::GetCount(*siz) = *p\nbpoints
      CArray::Copy(*p\a_size, *siz)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------
  ; Set Size
  ;---------------------------------------------------------
  Procedure SetSize(*p.PointCloudGeometry_t, siz.f)
    For i=0 To *p\nbpoints-1
      CArray::SetValueF(*p\a_size, i, siz)
    Next
  EndProcedure
  
  
  ; Destructor
  ;-----------------------------------------------------------
  Procedure Delete(*Me.PointCloudGeometry_t)
    CArray::Delete(*Me\a_positions )
    CArray::Delete(*Me\a_velocities )
    CArray::Delete(*Me\a_normals)
    CArray::Delete(*Me\a_tangents )
    CArray::Delete(*Me\a_color)
    CArray::Delete(*Me\a_indices)
    CArray::Delete(*Me\a_scale)
    CArray::Delete(*Me\a_size)
    CArray::Delete(*Me\a_uvws)
    Object::TERM(PointCloudGeometry)
  EndProcedure
  
  ; Constructor
  ;-----------------------------------------------------------
  Procedure New(*parent,nbp.i=0)
    Protected *Me.PointCloudGeometry_t = AllocateStructure(PointCloudGeometry_t)
    Object::INI(PointCloudGeometry)
    *Me\nbpoints = nbp
    *Me\parent = *parent
    *Me\a_positions = CArray::New(Types::#TYPE_V3F32)
    *Me\a_velocities = CArray::New(Types::#TYPE_V3F32)
    *Me\a_normals = CArray::New(Types::#TYPE_V3F32)
    *Me\a_tangents = CArray::New(Types::#TYPE_V3F32)
    *Me\a_color = CArray::New(Types::#TYPE_C4F32)
    *Me\a_indices = CArray::New(Types::#TYPE_INT)
    *Me\a_scale = CArray::New(Types::#TYPE_V3F32)
    *Me\a_size = CArray::New(Types::#TYPE_FLOAT)
    *Me\a_uvws = CArray::New(Types::#TYPE_V3F32)
    
    If nbp:
      CArray::SetCount(*Me\a_positions,nbp)
      CArray::SetCount(*Me\a_velocities,nbp)
      CArray::SetCount(*Me\a_normals,nbp)
      CArray::SetCount(*Me\a_tangents,nbp)
      CArray::SetCount(*Me\a_color,nbp)
      CArray::SetCount(*Me\a_indices,nbp)
      CArray::SetCount(*Me\a_scale,nbp)
      CArray::SetCount(*Me\a_size,nbp)
      CArray::SetCount(*Me\a_uvws,nbp)
    EndIf
    
    Init(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  

  Class::DEF( PointCloudGeometry )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 46
; FirstLine = 37
; Folding = ---
; EnableXP