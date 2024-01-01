XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "PointCloudGeometry.pbi"
XIncludeFile "../opengl/Shader.pbi"

DeclareModule PointCloud
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure PointCloud_t Extends Object3D::Object3D_t
    topodirty.b
    pointsize.i
  EndStructure
  
  Interface IPointCloud Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s,numPoints.i)
  Declare Delete(*Me.PointCloud_t)
  Declare Setup(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
  Declare Update(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
  Declare Clean(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
  Declare Draw(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
  Declare SetFromShape(*Me.PointCloud_t,shape.i)
  Declare SetDirtyState(*Me.PointCloud_t, state.i)
  Declare SetClean(*Me.PointCloud_t)
  Declare OnMessage(id.i,*up)
  DataSection 
    PointCloudVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module PointCloud
  UseModule OpenGL
  UseModule OpenGLExt

  ; Constructor
  ;----------------------------------------------------
  Procedure New(name.s,numPoints.i)
    Protected *Me.PointCloud_t = AllocateStructure(PointCloud_t)
    *Me\name = name
    *Me\type = Object3D::#PointCloud
    Object::INI(PointCloud)
    *Me\geom = PointCloudGeometry::New(*Me,numPoints)
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\pointsize = 2
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::OBJECT3DATTR()
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    
     ; ---[ Attributes ]---------------------------------------------------------
    Protected *cloud.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *geom = Attribute::New(*Me,"Geometry",Attribute::#ATTR_TYPE_GEOMETRY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*cloud,#True,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*geom)
    Protected *nbpoints = Attribute::New(*Me,"NbPoints",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*cloud\nbpoints,#True,#True,#True, #True, #False)
    Object3D::AddAttribute(*Me,*nbpoints)
    Protected *Meointposition = Attribute::New(*Me,"PointPosition",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_positions,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointposition)
    Protected *Meointvelocity = Attribute::New(*Me,"PointVelocity",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_velocities,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointvelocity)
    Protected *Meointnormal = Attribute::New(*Me,"PointNormal",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_normals,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointnormal)
    Protected *Meointtangent = Attribute::New(*Me,"PointTangent",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_tangents,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointtangent)
    Protected *Meointcolor = Attribute::New(*Me,"PointColor",Attribute::#ATTR_TYPE_COLOR,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_color,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointcolor)
    Protected *Meointsize = Attribute::New(*Me,"PointSize",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_size,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointsize)
    Protected *Meointscale = Attribute::New(*Me,"PointScale",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_scale,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointscale)
    Protected *Meointindices = Attribute::New(*Me,"PointID",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_indices,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointindices)
    Protected *Meointuvws = Attribute::New(*Me,"PointUVW",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_uvws,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointuvws)
  
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.PointCloud_t)
    Object3D::DeleteVAOs(*Me\vaos())
    Object3D::DeleteVBO(@*Me\vbo)
    FreeStructure(*Me)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Buil GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLData(*Me.PointCloud_t)
    ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    Protected nbv = *geom\nbpoints
    If nbv <3 : ProcedureReturn : EndIf
    
    Protected float.f
    
    ; Get PointCloud Datas
    Protected s1 = SizeOf(float)
    Protected s3 = SizeOf(v3f32)
    Protected s4 = SizeOf(c4f32)
    Protected size_p.i = nbv * s3
    Protected size_c.i = nbv * s4
    Protected size_s.i = nbv * s1
    Protected size_t.i = 5*size_p + size_c + size_s
    
    ; Allocate Memory
    Protected i
    Protected *v.v3f32
    Protected *c.c4f32
    
    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_DYNAMIC_DRAW)
    
    ; POSITIONS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,CArray::GetPtr(*geom\a_positions,0))
    
    ; VELOCITIES
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*geom\a_velocities,0))
    
    ; NORMALS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,2*size_p,size_p,CArray::GetPtr(*geom\a_normals,0))
    
    ; TANGENTS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,3*size_p,size_p,CArray::GetPtr(*geom\a_tangents,0))
    
    ; SCALE
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,4*size_p,size_p,CArray::GetPtr(*geom\a_scale,0))
    
    ; COLORS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,5*size_p,size_c,CArray::GetPtr(*geom\a_color,0))
    
    ; SIZE
     ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,5*size_p+size_c,size_s,CArray::GetPtr(*geom\a_size,0))
    
    Define x.a = 3
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      x.a = 4
    CompilerEndIf
    
    ; Attibute Position 0
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,x,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Attibute Velocities 1
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1,x,#GL_FLOAT,#GL_FALSE,0,size_p)
    
    ;Attibute Normal 2
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2,x,#GL_FLOAT,#GL_FALSE,0,2*size_p)
    
    ;Attibute Tangent 3
    glEnableVertexAttribArray(3)
    glVertexAttribPointer(3,x,#GL_FLOAT,#GL_FALSE,0,3*size_p)
    
    ;Attibute Scale 4
    glEnableVertexAttribArray(4)
    glVertexAttribPointer(4,x,#GL_FLOAT,#GL_FALSE,0,4*size_p)
    
    ; Attribute Color 5
    glEnableVertexAttribArray(5)
    glVertexAttribPointer(5,4,#GL_FLOAT,#GL_FALSE,0,5*size_p)
    
    ; Attribute Size 6
    glEnableVertexAttribArray(6)
    glVertexAttribPointer(6,1,#GL_FLOAT,#GL_FALSE,0,5*size_p+size_c)
    
    Define pgm = GLContext::*SHARED_CTXT\shaders("cloud")\pgm
    glBindAttribLocation(pgm, 0, "position")
    glBindAttribLocation(pgm, 1, "velocity")
    glBindAttribLocation(pgm, 2, "normal")
    glBindAttribLocation(pgm, 3, "tangent")
    glBindAttribLocation(pgm, 4, "scale");
    glBindAttribLocation(pgm, 5, "color")  ;
    glBindAttribLocation(pgm, 6, "size")   ;

  EndProcedure
    
  ; Setup
  ;----------------------------------------------------
  Procedure Setup(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)

    ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    
    Protected nbv = *geom\nbpoints
   
    ; Setup Static Kinematic STate
    ;ResetStaticKinematicState(*Me)
    
    ; Create or ReUse Vertex Array Object
    If Object3D::BindVaoFOrContext(*Me\vaos(), *ctxt)
    
      ; Create or ReUse Vertex Buffer Object
      Object3D::BindVBO(@*Me\vbo)
      
      If *ctxt\share
        ; Fill Buffer
        BuildGLData(*Me)
      EndIf
      
      *Me\initialized = #True
      *Me\dirty = Object3D::#DIRTY_STATE_CLEAN
    EndIf
  
  EndProcedure
  
  ;-----------------------------------------------------
  ; Clean
  ;-----------------------------------------------------
  ;{
  Procedure Clean(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)

     If *ctxt\share
      glDeleteBuffers(1, *Me\vbo)
    EndIf
    Define key.s = Str(*ctxt)
    If FindMapElement(*Me\vaos(), key)
      glDeleteVertexArrays(1,*Me\vaos())
      DeleteMapElement(*Me\vaos(), key)
    EndIf

;       If *Me\eab: glDeleteBuffers(1,@*Me\eab) : EndIf

  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Update
  ;-----------------------------------------------------
  ;{
  Procedure Update(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
    If *Me\stack
      Stack::Update(*Me\stack)
    EndIf
    
    If *Me\dirty & Object3D::#DIRTY_STATE_TOPOLOGY Or Not *Me\initialized
      Protected p.Object3D::IObject3D = *Me
      p\Setup(*ctxt)
    Else 
       If *ctxt\share And *Me\dirty & Object3D::#DIRTY_STATE_DEFORM
;       PolymeshGeometry::ComputeNormals(*Me\geom,1.0)
        Object3D::BindVaoFOrContext(*Me\vaos(), *ctxt)
        glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
;         UpdateGLData(*Me)
;         glBindVertexArray(*Me\eao)
;         glBindBuffer(#GL_ARRAY_BUFFER,*Me\ebo)
;         UpdateGLEdgeData(*Me)
        glBindVertexArray(0)
        SetClean(*Me)
      EndIf
    EndIf
   glCheckError("Update PointCloud")
  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Draw
  ;-----------------------------------------------------
  ;{
  Procedure Draw(*Me.PointCloud_t, *ctxt.GLContext::GLContext_t)
    
    If Not *Me\visible  Or Not *Me\initialized: ProcedureReturn : EndIf
    If Object3d::BindVaoFOrContext(*Me\vaos(), *ctxt)
      Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom

      glDrawArrays(#GL_POINTS,0,*geom\nbpoints) 
      glDisable( #GL_PROGRAM_POINT_SIZE )
      GLCheckError("[Polymesh] Draw mesh Called")
      glBindVertexArray(0)
        ;     EndIf
    EndIf
  
  EndProcedure
  ;}
  
  ; Set From Shape
  ;----------------------------------------------------
  Procedure SetFromShape(*Me.PointCloud_t,shape.i)

  EndProcedure
  
  ;-----------------------------------------------------
  ; Set Dirty State
  ;-----------------------------------------------------
  Procedure SetDirtyState(*Me.PointCloud_t, state)
    If state = Object3D::#DIRTY_STATE_TOPOLOGY
      *Me\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
      Object3D::SetAttributeDirty(*Me,"Geometry")
      Object3D::SetAttributeDirty(*Me,"NbPoints")
      Object3D::SetAttributeDirty(*Me,"PointPosition")
      Object3D::SetAttributeDirty(*Me,"PointVelocity")
      Object3D::SetAttributeDirty(*Me,"PointNormal")
      Object3D::SetAttributeDirty(*Me,"PointTangent")
      Object3D::SetAttributeDirty(*Me,"PointColor")
      Object3D::SetAttributeDirty(*Me,"PointSize")
      Object3D::SetAttributeDirty(*Me,"PointScale")
      Object3D::SetAttributeDirty(*Me,"PointID")
      Object3D::SetAttributeDirty(*Me,"PointUVW")
    ElseIf state = Object3D::#DIRTY_STATE_DEFORM
      If *me\dirty = Object3D::#DIRTY_STATE_CLEAN
        *Me\dirty = Object3D::#DIRTY_STATE_DEFORM
        Object3D::SetAttributeDirty(*Me,"Geometry")
        Object3D::SetAttributeDirty(*Me,"PointPosition")
        Object3D::SetAttributeDirty(*Me,"PointVelocity")
        Object3D::SetAttributeDirty(*Me,"PointNormal")
        Object3D::SetAttributeDirty(*Me,"PointTangent")
        Object3D::SetAttributeDirty(*Me,"PointColor")
        Object3D::SetAttributeDirty(*Me,"PointSize")
        Object3D::SetAttributeDirty(*Me,"PointScale")
      EndIf
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------
  ; Set Clean
  ;-----------------------------------------------------
  Procedure SetClean(*Me.PointCloud_t)
    *Me\dirty = Object3D::#DIRTY_STATE_CLEAN
    ForEach *Me\geom\m_attributes()
      *Me\geom\m_attributes()\dirty = #False
    Next
  EndProcedure
  
  ; On Message
  ;----------------------------------------------------
  Procedure OnMessage(id.i,*up)
    
;     Protected *sig.Signal::Signal_t = *up
;     Protected *snd.Object::Object_t = *sig\snd_inst
;     Protected *rcv.Object::Object_t = *sig\rcv_inst
;     
;     Debug "PointCloud Recieved Message"
;     Debug "Sender Class Name : "+*snd\class\name
;     Debug "Reciever Class Name : "+*rcv\class\name
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( PointCloud )
EndModule

  
    
    
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 286
; FirstLine = 282
; Folding = ---
; EnableXP