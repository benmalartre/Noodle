XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "Geometry.pbi"
XIncludeFile "PointCloudGeometry.pbi"


;========================================================================================
; InstanceCloud Module Declaration
;========================================================================================
DeclareModule InstanceCloud
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure InstanceCloud_t Extends Object3D::Object3D_t
    *shape.Shape::Shape_t
  EndStructure
  
  Interface IInstanceCloud Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s,shape.i=Shape::#SHAPE_CUBE,nbp.i = 1)
  Declare Delete(*Me.InstanceCloud_t)
  Declare Setup(*Me.InstanceCloud_t,*shader.Program::Program_t)
  Declare Update(*Me.InstanceCloud_t)
  Declare Clean(*Me.InstanceCloud_t)
  Declare Draw(*Me.InstanceCloud_t)

  DataSection 
    InstanceCloudVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

;========================================================================================
; InstanceCloud Module Implementation
;========================================================================================
Module InstanceCloud
  UseModule OpenGL
  UseModule OpenGLExt

  ; Constructor
  ;----------------------------------------------------
  Procedure New(name.s,shape.i=Shape::#SHAPE_CUBE,nbp.i = 1)
    Protected *Me.InstanceCloud_t = AllocateMemory(SizeOf(InstanceCloud_t))
    InitializeStructure(*Me,InstanceCloud_t)
    Object::INI(InstanceCloud)
    *Me\name = name
    *Me\geom = PointCloudGeometry::New(*Me,nbp)
    *Me\visible = #True
    *Me\shape = Shape::New(shape)
    *Me\stack = Stack::New()
    *Me\type = Object3D::#InstanceCloud
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::OBJECT3DATTR()
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    
     ; ---[ Attributes ]---------------------------------------------------------
    Protected *cloud.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *geom = Attribute::New("Geometry",Attribute::#ATTR_TYPE_GEOMETRY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*cloud,#True,#True,#True)
    Object3D::AddAttribute(*Me,*geom)
    Protected *nbpoints = Attribute::New("NbPoints",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*cloud\nbpoints,#True,#True,#True)
    Object3D::AddAttribute(*Me,*nbpoints)
    Protected *pointposition = Attribute::New("PointPosition",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_positions,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointposition)
    Protected *pointvelocity = Attribute::New("PointVelocity",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_velocities,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointvelocity)
    Protected *pointnormal = Attribute::New("PointNormal",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_normals,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointnormal)
    Protected *pointtangent = Attribute::New("PointTangent",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_tangents,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointtangent)
    Protected *pointcolor = Attribute::New("PointColor",Attribute::#ATTR_TYPE_COLOR,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_color,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointcolor)
    Protected *pointsize = Attribute::New("PointSize",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_size,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointsize)
    Protected *pointscale = Attribute::New("PointScale",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_scale,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointscale)
    Protected *pointindices = Attribute::New("PointIndices",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_indices,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointindices)
    Protected *pointuvws = Attribute::New("PointUVWs",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*cloud\a_uvws,#False,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*pointuvws)
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.InstanceCloud_t)
    If *Me\vao : glDeleteVertexArrays(1,*Me\vao) : EndIf
    If *Me\vbo : glDeleteBuffers(1,*Me\vbo) : EndIf
    If *Me\eab : glDeleteBuffers(1,*Me\eab) : EndIf
    ClearStructure(*Me,InstanceCloud_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; Coatlicue Deesse Azteque de la mort
  
  
  ; Get Shape Flat Array Data Size
  ;----------------------------------------------------
  Procedure GetShapeDataSize(*Me.InstanceCloud_t)
    Protected *shape.Shape::Shape_t = *Me\shape
    ProcedureReturn *shape\nbt * 3 * SizeOf(v3f32)
  EndProcedure
  
  ; Build Shape Flat Array Data
  ;----------------------------------------------------
  Procedure GetShapeArrayDatas(*Me.InstanceCloud_t,size_s)
    If Not size_s : ProcedureReturn : EndIf
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *shape.Shape::Shape_t = *Me\shape
    
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_s,CArray::GetPtr(*shape\positions,0))
    glBufferSubData(#GL_ARRAY_BUFFER,1*size_s,size_s,CArray::GetPtr(*shape\normals,0))
    glBufferSubData(#GL_ARRAY_BUFFER,2*size_s,size_s,CArray::GetPtr(*shape\uvws,0))
    glBufferSubData(#GL_ARRAY_BUFFER,3*size_s,size_s,CArray::GetPtr(*shape\colors,0))
   
  EndProcedure
  
  ; Build GL Data
  ;----------------------------------------------------
  Procedure  BuildGLData(*Me.InstanceCloud_t)
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *shape.Shape::Shape_t = *Me\shape
    Protected sts.i = GetShapeDataSize(*Me)
    If sts
      ; Get Point Cloud Datas
      Protected f.f
      Protected l.l
      Define st1.i = *geom\nbpoints * SizeOf(f)
      Define st3.i = *geom\nbpoints * SizeOf(v3f32)
      Define st4.i = *geom\nbpoints * SizeOf(v4f32)
  
      ; Vertex Array Object
      If Not *Me\vao
        glGenVertexArrays(1,@*Me\vao)
      EndIf
      glBindVertexArray(*Me\vao)
      
      ; Create Vertex Buffer Object
      If Not *Me\vbo
        glGenBuffers(1,@*Me\vbo)
      EndIf
      glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
        
      ; Push Buffer to GPU
      glBufferData(#GL_ARRAY_BUFFER,sts*4+st3*4+st4+st1,#Null,#GL_DYNAMIC_DRAW)
      GetShapeArrayDatas(*Me,sts)
      Define offset.i = sts * 4
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st3,CArray::GetPtr(*geom\a_positions,0))
      offset + st3
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st3,CArray::GetPtr(*geom\a_normals,0))
      offset + st3
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st3,CArray::GetPtr(*geom\a_tangents,0))
      offset + st3
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st4,CArray::GetPtr(*geom\a_color,0))
      offset + st4
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st3,CArray::GetPtr(*geom\a_scale,0))
      offset + st3
      glBufferSubData(#GL_ARRAY_BUFFER,offset,st1,CArray::GetPtr(*geom\a_size,0))
      offset + st1
      
      If *Me\shape\indexed
        ; Create\Reuse Element Array Buffer
        If Not *Me\eab
          glGenBuffers(1,@*Me\eab)
        EndIf        
        glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*Me\eab)
        glBufferData(#GL_ELEMENT_ARRAY_BUFFER,
                     CArray::GetCount(*Me\shape\indices)* SizeOf(l),
                     CArray::GetPtr(*Me\shape\indices,0),
                     #GL_DYNAMIC_DRAW)
      EndIf
      
      
      ; Shape Datas
      CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
        Define v3i = 4
      CompilerElse
        Define v3i = 3
      CompilerEndIf
      
      glEnableVertexAttribArray(0)
      glVertexAttribPointer(0,v3i,#GL_FLOAT,#GL_FALSE,0,0)
      
      glEnableVertexAttribArray(1)
      glVertexAttribPointer(1,v3i,#GL_FLOAT,#GL_FALSE,0,sts)
      
      glEnableVertexAttribArray(2)
      glVertexAttribPointer(2,v3i,#GL_FLOAT,#GL_FALSE,0,sts*2)
      
      glEnableVertexAttribArray(3)
      glVertexAttribPointer(3,4,#GL_FLOAT,#GL_FALSE,0,sts*3)
      
      ; Attribute Position
      glEnableVertexAttribArray(4)
      glVertexAttribPointer(4,v3i,#GL_FLOAT,#GL_FALSE,0,sts*4)
      
      ; Attribute Normal
      glEnableVertexAttribArray(5)
      glVertexAttribPointer(5,v3i,#GL_FLOAT,#GL_FALSE,0,sts*4 + st3)
      
      ; Attribute Tangent
      glEnableVertexAttribArray(6)
      glVertexAttribPointer(6,v3i,#GL_FLOAT,#GL_FALSE,0,sts*4 + st3*2)
      
      ; Attribute Color
      glVertexAttribPointer(7,4,#GL_FLOAT,#GL_FALSE,0,sts*4 + st3*3)
      glEnableVertexAttribArray(7)
      
      ;Attribute Scale
      glVertexAttribPointer(8,v3i,#GL_FLOAT,#GL_FALSE,0,sts*4 + st3*3 + st4)
      glEnableVertexAttribArray(8)
      
      ;Attribute Size
      glVertexAttribPointer(9,1,#GL_FLOAT,#GL_FALSE,0,sts*4 + st3*4 + st4)
      glEnableVertexAttribArray(9)
      
      Protected pgm = *Me\shader\pgm
      ; Bind Attributes Locations
      glBindAttribLocation(pgm,0,"s_pos")
      glBindAttribLocation(pgm,1,"s_norm")
      glBindAttribLocation(pgm,2,"s_uvws")
      glBindAttribLocation(pgm,3,"s_color")
      glBindAttribLocation(pgm,4,"position")
      glBindAttribLocation(pgm,5,"normal")
      glBindAttribLocation(pgm,6,"tangent")
      glBindAttribLocation(pgm,7,"color")
      glBindAttribLocation(pgm,8,"scale")
      glBindAttribLocation(pgm,9,"size")
      
      
      glVertexAttribDivisor(4,1)
      glVertexAttribDivisor(5,1)
      glVertexAttribDivisor(6,1)
      glVertexAttribDivisor(7,1)
      glVertexAttribDivisor(8,1)
      glVertexAttribDivisor(9,1)
    EndIf
    
  EndProcedure
  
  
   
  ; Setup
  ;----------------------------------------------------
  Procedure Setup(*Me.InstanceCloud_t,*pgm.Program::Program_t)
    
    Debug "INSTANCE CLOUD SETUP..."
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *shape.Shape::Shape_t = *Me\shape
    ; Update Geometry
    PointCloudGeometry::Update(*Me)
 
    ;If Not *p\initialized : ProcedureReturn #Null : EndIf
    
    ;Attach Shader
    *Me\shader = *pgm
    Protected pgm = *pgm\pgm
    glUseProgram(pgm)
    
    BuildGLData(*Me)
    
    glLinkProgram(*Me\shader\pgm);
    ; Check For Errors
    Protected linked.i
    If Not glGetProgramiv(*Me\shader\pgm, #GL_LINK_STATUS, @linked);
      ;Make sure linked==TRUE
      ;If linked==FALSE, the log contains information on what went wrong
      Protected maxLength.i
      glGetProgramiv(*Me\shader\pgm, #GL_INFO_LOG_LENGTH, @maxLength);
      maxLength = maxLength + 1                                  ;
      Protected uchar.c
      Protected *pLinkInfoLog = AllocateMemory( maxLength * SizeOf(uchar));
      glGetProgramInfoLog(*Me\shader\pgm, maxLength, @maxLength, *pLinkInfoLog);
      ;MessageRequester("Error Setup Shader Program for InstanceCloud",PeekS(*pLinkInfoLog))
    EndIf
  
    glBindBuffer(#GL_ARRAY_BUFFER,0)
    glBindVertexArray(0)
    
  
    *Me\initialized = #True
  EndProcedure
  
  ; Update
  ;----------------------------------------------------
  Procedure Update(*Me.InstanceCloud_t)
    Debug "INSTANCE CLOUD UPDATE..."
    If *Me\stack
      PointCloudGeometry::Reset(*Me\geom)
      Stack::Update(*Me\stack)
    EndIf
    
    If *Me\dirty & Object3D::#DIRTY_STATE_TOPOLOGY Or Not *Me\initialized
      Protected Me.Object3D::IObject3D = *Me
      Me\Setup(*Me\shader)
      Debug "INSTANCE CLOUD SETUP..."
    Else 
      If *Me\dirty & Object3D::#DIRTY_STATE_DEFORM
;         PointCloudGeometry::RecomputeNormals(*p\geom,1.0)
        glBindVertexArray(*Me\vao)
        ;glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
        BuildGLData(*Me)
        ;glBindBuffer(#GL_ARRAY_BUFFER,0)
        glBindVertexArray(0)
        Debug "INSTANCE CLOUD UPDATE..."
        *Me\dirty = Object3D::#DIRTY_STATE_CLEAN
      EndIf
    EndIf
   glCheckError("Update InstanceCloud")
    
    
 EndProcedure
 
  ; Update
  ;----------------------------------------------------
  Procedure Clean(*Me.InstanceCloud_t)

  EndProcedure
  
  
  ; Draw
  ;----------------------------------------------------
  Procedure Draw(*Me.InstanceCloud_t)
    If *Me\initialized And *Me\visible
    glBindVertexArray(*Me\vao)
    Protected id.v3f32
    glPointSize(12)
    Protected *geom.Geometry::PointCloudGeometry_t = *Me\geom
    Protected *shape.Shape::Shape_t = *Me\shape

    If *Me\shape\indexed
      glDrawElementsInstanced(#GL_TRIANGLES,CArray::GetCount(*Me\shape\indices),#GL_UNSIGNED_INT,0,*geom\nbpoints)
    Else
      glDrawArraysInstanced(#GL_TRIANGLES,0,*Me\shape\nbt*3,*geom\nbpoints)
    EndIf
        
    glBindVertexArray(0)
    
  EndIf
  EndProcedure
  
  ; Set From Shape
  ;----------------------------------------------------
  Procedure SetFromShape(*Me.InstanceCloud_t,shape.i)

  EndProcedure
  
  ; Reflection
  ;----------------------------------------------------
  Class::DEF( InstanceCloud )
EndModule

  
    
    
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 183
; FirstLine = 180
; Folding = ---
; EnableXP
; EnableUnicode