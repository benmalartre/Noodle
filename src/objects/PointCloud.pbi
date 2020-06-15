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
  Declare Setup(*Me.PointCloud_t,*shader.Program::Program_t)
  ;Declare SetProgram(*Me.PointCloud_t,*shader.Program::Program_t)
  Declare Update(*Me.PointCloud_t)
  Declare Clean(*Me.PointCloud_t)
  Declare Draw(*Me.PointCloud_t)
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
    Protected *Me.PointCloud_t = AllocateMemory(SizeOf(PointCloud_t))
    InitializeStructure(*Me,PointCloud_t)
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
    Protected *pointposition = Attribute::New(*Me,"PointPosition",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_positions,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointposition)
    Protected *pointvelocity = Attribute::New(*Me,"PointVelocity",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_velocities,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointvelocity)
    Protected *pointnormal = Attribute::New(*Me,"PointNormal",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_normals,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointnormal)
    Protected *pointtangent = Attribute::New(*Me,"PointTangent",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_tangents,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointtangent)
    Protected *pointcolor = Attribute::New(*Me,"PointColor",Attribute::#ATTR_TYPE_COLOR,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_color,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointcolor)
    Protected *pointsize = Attribute::New(*Me,"PointSize",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_size,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointsize)
    Protected *pointscale = Attribute::New(*Me,"PointScale",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_scale,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointscale)
    Protected *pointindices = Attribute::New(*Me,"PointID",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_indices,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointindices)
    Protected *pointuvws = Attribute::New(*Me,"PointUVW",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_uvws,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointuvws)
  
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.PointCloud_t)
    glDeleteVertexArrays(1,*Me\vao)
    glDeleteBuffers(1,*Me\vbo)
    ClearStructure(*Me,PointCloud_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Buil GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLData(*p.PointCloud_t)
    ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PointCloudGeometry_t = *p\geom
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
    
    glBindAttribLocation(*p\shader\pgm, 0, "position")
    glBindAttribLocation(*p\shader\pgm, 1, "velocity")
    glBindAttribLocation(*p\shader\pgm, 2, "normal")
    glBindAttribLocation(*p\shader\pgm, 3, "tangent")
    glBindAttribLocation(*p\shader\pgm, 4, "scale");
    glBindAttribLocation(*p\shader\pgm, 5, "color")  ;
    glBindAttribLocation(*p\shader\pgm, 6, "size")   ;

  EndProcedure
    
  ; Setup
  ;----------------------------------------------------
  Procedure Setup(*p.PointCloud_t,*pgm.Program::Program_t)

    *p\shader = *pgm

    ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PointCloudGeometry_t = *p\geom
    
    Protected nbv = *geom\nbpoints
   
    ; Setup Static Kinematic STate
    ;ResetStaticKinematicState(*p)
    
    ; Create or ReUse Vertex Array Object
    If Not *p\vao
      glGenVertexArrays(1,@*p\vao)
    EndIf
    glBindVertexArray(*p\vao)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *p\vbo
      glGenBuffers(1,@*p\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo)
    

    ; Fill Buffer
    BuildGLData(*p)
    
     glLinkProgram(*p\shader\pgm);
    ; Check For Errors
    Protected linked.i
    If Not glGetProgramiv(*p\shader\pgm, #GL_LINK_STATUS, @linked);
      ;Make sure linked==TRUE
      ;If linked==FALSE, the log contains information on what went wrong
      Protected maxLength.i
      glGetProgramiv(*p\shader\pgm, #GL_INFO_LOG_LENGTH, @maxLength);
      maxLength = maxLength + 1                                  ;
      Protected uchar.c
      Protected *pLinkInfoLog = AllocateMemory( maxLength * SizeOf(uchar));
      glGetProgramInfoLog(*p\shader\pgm, maxLength, @maxLength, *pLinkInfoLog);
      ;MessageRequester("Error Setup Shader Program for PointCloud",PeekS(*pLinkInfoLog))
    EndIf

    ; Unbind
    glBindVertexArray(0)
   
    
    *p\initialized = #True
    *p\dirty = Object3D::#DIRTY_STATE_CLEAN
  EndProcedure
  
  ;-----------------------------------------------------
  ; Clean
  ;-----------------------------------------------------
  ;{
  Procedure Clean(*p.PointCloud_t)

      If *p\vao : glDeleteVertexArrays(1,@*p\vao) : EndIf

      If *p\vbo: glDeleteBuffers(1,@*p\vbo) : EndIf

;       If *p\eab: glDeleteBuffers(1,@*p\eab) : EndIf

  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Update
  ;-----------------------------------------------------
  ;{
  Procedure Update(*p.PointCloud_t)
    If *p\stack
      Stack::Update(*p\stack)
    EndIf
    
    If *p\dirty & Object3D::#DIRTY_STATE_TOPOLOGY Or Not *p\initialized
      Protected p.Object3D::IObject3D = *p
      p\Setup(*p\shader)
    Else 
      If *p\dirty & Object3D::#DIRTY_STATE_DEFORM
;         PointCloudGeometry::RecomputeNormals(*p\geom,1.0)
        glBindVertexArray(*p\vao)
        glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo)
        BuildGLData(*p)
        glBindBuffer(#GL_ARRAY_BUFFER,0)
        glBindVertexArray(0)
        *p\dirty = Object3D::#DIRTY_STATE_CLEAN
      EndIf
    EndIf
   glCheckError("Update PointCloud")
  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Draw
  ;-----------------------------------------------------
  ;{
  Procedure Draw(*p.PointCloud_t)
    ;Skip invisible Object
    If Not *p\visible  Or Not *p\initialized: ProcedureReturn : EndIf

    Protected *geom.Geometry::PointCloudGeometry_t = *p\geom

    glPointSize(6);*p\pointsize)

    glEnable( #GL_PROGRAM_POINT_SIZE )
  
    ;glEnable(#GL_POINT_SMOOTH)
    glBindVertexArray(*p\vao)
;     glUniformMatrix4fv(glGetUniformLocation(*p\shader\pgm,"model"),1,#GL_FALSE,*p\matrix)
    glDrawArrays(#GL_POINTS,0,*geom\nbpoints) 
    glDisable( #GL_PROGRAM_POINT_SIZE )
    glBindVertexArray(0)
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

  
    
    
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 366
; FirstLine = 330
; Folding = ---
; EnableXP