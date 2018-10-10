XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

;========================================================================================
; PointCloudGeometry Module Declaration
;========================================================================================
DeclareModule PointCloudGeometry
  UseModule Math
  UseModule Geometry
  Declare New(*parent,nbp.i)
  Declare Delete(*geom.PointCloudGeometry_t)
  Declare Init(*geom.PointCloudGeometry_t)
  Declare Update(*geom.PointCloudGeometry_t)
  Declare PointsOnSphere(*geom.PointCloudGeometry_t, radius.f)
  Declare PointsOnGrid(*geom.PointCloudGeometry_t, nx.i, nz.i)
  Declare PointsOnLine(*geom.PointCloudGeometry_t,*start.v3f32,*end.v3f32)
  Declare RandomizeColor(*geom.PointCloudGeometry_t,*base.c4f32 = #Null,randomize.f = 0.5)
  Declare AddPoints(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32 )
  Declare Reset(*p.PointCloudGeometry_t)
EndDeclareModule

;========================================================================================
; PointCloudGeometry Module Implementation
;========================================================================================
Module PointCloudGeometry
  UseModule Geometry
  UseModule Math
  ; Constructor
  ;-----------------------------------------------------------
  Procedure New(*parent,nbp.i)
    Protected *geom.PointCloudGeometry_t = AllocateMemory(SizeOf(PointCloudGeometry_t))
    *geom\nbpoints = nbp
    *geom\parent = *parent
    *geom\a_positions = CArray::newCArrayV3F32()
    *geom\a_velocities = CArray::newCArrayV3F32()
    *geom\a_normals = CArray::newCArrayV3F32()
    *geom\a_tangents = CArray::newCArrayV3F32()
    *geom\a_color = CArray::newCArrayC4F32()
    *geom\a_indices = CArray::newCArrayLong()
    *geom\a_scale = CArray::newCArrayV3F32()
    *geom\a_size = CArray::newCArrayFloat()
    *geom\a_uvws = CArray::newCArrayV3F32()
    
    CArray::SetCount(*geom\a_positions,nbp)
    CArray::SetCount(*geom\a_velocities,nbp)
    CArray::SetCount(*geom\a_normals,nbp)
    CArray::SetCount(*geom\a_tangents,nbp)
    CArray::SetCount(*geom\a_color,nbp)
    CArray::SetCount(*geom\a_indices,nbp)
    CArray::SetCount(*geom\a_scale,nbp)
    CArray::SetCount(*geom\a_size,nbp)
    CArray::SetCount(*geom\a_uvws,nbp)
    
    Init(*geom)
    ProcedureReturn *geom
  EndProcedure
  
  ; Destructor
  ;-----------------------------------------------------------
  Procedure Delete(*geom.PointCloudGeometry_t)
    CArray::Delete(*geom\a_positions )
    CArray::Delete(*geom\a_velocities )
    CArray::Delete(*geom\a_normals)
    CArray::Delete(*geom\a_tangents )
    CArray::Delete(*geom\a_color)
    CArray::Delete(*geom\a_indices)
    CArray::Delete(*geom\a_scale)
    CArray::Delete(*geom\a_size)
    CArray::Delete(*geom\a_uvws)
    FreeMemory(*geom)
  EndProcedure
  
  ; Init
  ;-----------------------------------------------------------
  Procedure Init(*geom.PointCloudGeometry_t)
    Protected i
    Protected *pos.v3f32,*norm.v3f32,*tan.v3f32
    Protected *col.c4f32
    Protected size.f = 1.0
    For i=0 To *geom\nbpoints-1
      *pos = CArray::GetValue(*geom\a_positions,i)
      Vector3::Set(*pos,(Random(100)*0.01-0.5)*10000,(Random(100)*0.01-0.5)*10000,(Random(100)*0.01-0.5)*10000)
      *norm = CArray::GetValue(*geom\a_normals,i)
      Vector3::Set(*norm,0,1,0)
      *tan = CArray::GetValue(*geom\a_tangents,i)
      Vector3::Set(*tan,0,0,1)
      size = 2
      CArray::SetValueF(*geom\a_size,i,size)
      *col = CArray::GetValue(*geom\a_color,i)
      Color::RandomLuminosity(*col,0,1)
    Next
    
  EndProcedure
  
  ; Update
  ;-----------------------------------------------------------
  Procedure Update(*geom.PointCloudGeometry_t)
    
  EndProcedure
  
  ; Points  On Sphere
  ;-----------------------------------------------------------
  Procedure PointsOnSphere(*geom.PointCloudGeometry_t, radius.f)
    
    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_velocities,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbpoints)
    CArray::SetCount(*geom\a_tangents,*geom\nbpoints)
    CArray::SetCount(*geom\a_color,*geom\nbpoints)
    CArray::SetCount(*geom\a_scale,*geom\nbpoints)
    CArray::SetCount(*geom\a_size,*geom\nbpoints)
    CArray::SetCount(*geom\a_indices,*geom\nbpoints)
    CArray::SetCount(*geom\a_uvws,*geom\nbpoints)
    
    Protected i
    Protected v.v3f32
    Protected c.c4f32
    Protected s.v3f32
    Protected t.v3f32
    
    Vector3::Set(s,1,1,1)
    
    Define.f r,g,b, x,y ,z
    
    For i=0 To *geom\nbPoints-1
      ;Set Position
      x = Random(255)/255 - 0.5
      y = Random(255)/255 - 0.5
      z = Random(255)/255 - 0.5
      
      Vector3::Set(v,x,y,z)
      Vector3::NormalizeInPlace(v)
      Vector3::ScaleInPlace(v,radius)
      
      CArray::SetValue(*geom\a_positions,i,v)

      ; Set Normals
      Vector3::NormalizeInPlace(v)
      CArray::SetValue(*geom\a_normals,i,v)
      
      ; Set Tangents
      Vector3::Set(c,0,1,0)
      Vector3::Cross(t,v,c)
      CArray::SetValue(*geom\a_tangents,i,t)

      ; Set Color
      r = (120+Random(50))/255
      g = (20+Random(5))/255
      b = (10+Random(4))/255
      Color::Set(c,r,g,b,1.0)
      CArray::SetValue(*geom\a_color,i,c)

      ; Set Scale
      Vector3::Set(s,1,1,1)
      CArray::SetValue(*geom\a_scale,i,s)
      
      ; Set Size
      CArray::SetValueF(*geom\a_size,i,1)
      
    Next 

  EndProcedure
  
  ; Point On Grid
   ;-----------------------------------------------------------
  Procedure PointsOnGrid(*geom.PointCloudGeometry_t, nx.i, nz.i)
    
    *geom\nbpoints = nx * nz
    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_velocities,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbpoints)
    CArray::SetCount(*geom\a_tangents,*geom\nbpoints)
    CArray::SetCount(*geom\a_color,*geom\nbpoints)
    CArray::SetCount(*geom\a_scale,*geom\nbpoints)
    CArray::SetCount(*geom\a_size,*geom\nbpoints)
    CArray::SetCount(*geom\a_indices,*geom\nbpoints)
    CArray::SetCount(*geom\a_uvws,*geom\nbpoints)
    
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
        CArray::SetValue(*geom\a_positions,i,v)
        
       ; Set Normals
        Vector3::Set(v, 0,1,0)
        CArray::SetValue(*geom\a_normals,i,v)
        
        ; Set Tangents
        Vector3::Set(t,1,0,0)
        CArray::SetValue(*geom\a_tangents,i,t)
  
        ; Set Color
        r = (120+Random(50))/255
        g = (20+Random(5))/255
        b = (10+Random(4))/255
        Color::Set(c,r,g,b,1.0)
        CArray::SetValue(*geom\a_color,i,c)
  
        ; Set Scale
        Vector3::Set(s,1,1,1)
        CArray::SetValue(*geom\a_scale,i,s)
        
        ; Set Size
        CArray::SetValueF(*geom\a_size,i,1)
        
        ; increment counter
        i + 1
      Next
    Next

  EndProcedure
  
  
  ; Points  On Line
  ;-----------------------------------------------------------
  Procedure PointsOnLine(*geom.PointCloudGeometry_t,*start.v3f32,*end.v3f32)
    
    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbpoints)
    CArray::SetCount(*geom\a_tangents,*geom\nbpoints)
    CArray::SetCount(*geom\a_color,*geom\nbpoints)
    CArray::SetCount(*geom\a_scale,*geom\nbpoints)
    CArray::SetCount(*geom\a_size,*geom\nbpoints)
    
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
    Define st.f = l/(*geom\nbPoints-1.0)
    Define stc.f
    
    For i=0 To *geom\nbPoints-1
      ; step
      stc = st * i / l
      
      ;Set Position
      *v = CArray::GetValue(*geom\a_positions,i)
      Vector3::LinearInterpolate(*v,*start,*end,stc)
      
      ; Set Normal
      *v = CArray::GetValue(*geom\a_normals,i)
      Vector3::NormalizeInPlace(*v)
      
      ; Set Tangent
      *t = CArray::GetValue(*geom\a_tangents,i)
      Vector3::Set(*t,0,1,0)
      Vector3::Cross(tmp,*v,*t)
      Vector3::SetFromOther(*t,@tmp)
      
      ;Set Color
      *c = CArray::GetValue(*geom\a_color,i)
      r = (120+Random(50))/255
      g = (20+Random(5))/255
      b = (10+Random(4))/255
      Color::Set(*c,r,g,b,1.0)

      ;Set Scale
      *s = CArray::GetValue(*geom\a_scale,i)
      Vector3::Set(*s,0.1,0.1,0.1)
      
      ;Set Size
      CArray::SetValueF(*geom\a_size,i,1)
      
    Next 
  EndProcedure
  
  ; Randomize Colors
  ;----------------------------------------------
  Procedure RandomizeColor(*geom.Geometry::PointCloudGeometry_t,*base.c4f32 = #Null,randomize.f = 0.5)
    Protected i.i
    Protected *c.c4f32
    Protected r.f,g.f,b.f,a.f

    If *base = #Null
      Protected base.c4f32
      Color::Set(base,0.5,0.5,0.5,1.0)
      *base = @base
    EndIf
    
    For i=0 To CArray::GetCount(*geom\a_color)-1
      *c = CArray::GetValue(*geom\a_color,i)
      r = (Random(255)/255 - 0.5) * randomize
      g = (Random(255)/255 - 0.5) * randomize
      b = (Random(255)/255 - 0.5) * randomize
      a = 1
      Color::Set(*c,r,g,b,a)
    Next
  EndProcedure
  
  ; Add Points
  ;----------------------------------------------
  Procedure AddPoints(*p.PointCloudGeometry_t, *pos.CArray::CArrayV3F32 )
    Protected i
    Debug "Add Point Called"
    Debug "Num Points : "+Str(CArray::GetCount(*pos))
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
      Vector3::Set(n,0,1,0)
      CArray::Append(*p\a_normals,@n)
      Vector3::Set(c,1,0,0)
      Vector3::Cross(t,n,c)
      CArray::Append(*p\a_tangents,@t)

      CArray::AppendL(*p\a_indices,*p\incrementID)
      
      ;Set Color
      r = Random(255)/255
      g = Random(255)/255
      b = Random(255)/255
      Vector3::Set(c,r,g,b)
      CArray::Append(*p\a_color,@c)
      
      Vector3::Set(s,1,1,1)
      CArray::Append(*p\a_scale,@s)
      
      CArray::AppendF(*p\a_size,1)
  
      ;Increment Counter
      *p\incrementID + 1
      
      
      
    Next i
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Reset
  ;---------------------------------------------------------
  Procedure Reset(*geom.PointCloudGeometry_t)
    *geom\nbpoints = 0
    CArray::SetCount(*geom\a_positions,0)
    CArray::SetCount(*geom\a_velocities,0)
    CArray::SetCount(*geom\a_normals,0)
    CArray::SetCount(*geom\a_tangents,0)
    CArray::SetCount(*geom\a_indices,0)
    CArray::SetCount(*geom\a_size,0)
    CArray::SetCount(*geom\a_scale,0)
    CArray::SetCount(*geom\a_uvws,0)
    CArray::SetCount(*geom\a_color,0)
;     If Not CArray::GetCount(*geom\topo\vertices) = CArray::GetCount(*geom\base\vertices) Or Not CArray::GetCount(*geom\topo\faces) = CArray::GetCount(*geom\base\faces)
;       Set2(*geom,*geom\base)
;     Else
;       SetPointsPosition(*geom,*geom\base\vertices)
;       ;SetPointsNormal(*geom,*geom\base\normals)
;       ;RecomputeNormals(*geom)
;     EndIf 
    
      

  EndProcedure


EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 204
; FirstLine = 192
; Folding = ---
; EnableXP