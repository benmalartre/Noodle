XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "PolymeshGeometry.pbi"


DeclareModule Polymesh
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure Polymesh_t Extends Object3D::Object3D_t
    ;*shape.Shape::Shape_t
    deformdirty.b
    topodirty.b
    radius.f
    width.f
    height.f
    depth.f
    u.i
    v.i
    wireframe.b
    vao2.i
    vbo2.i
    eab2.i
  EndStructure
  
  Interface IPolymesh Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s,shape.i)
  Declare Delete(*Me.Polymesh_t)
  Declare Setup(*Me.Polymesh_t,*shader.Program::Program_t)
  Declare Update(*Me.Polymesh_t)
  Declare Clean(*Me.Polymesh_t)
  Declare Draw(*Me.Polymesh_t)
  Declare SetFromShape(*Me.Polymesh_t,shape.i)
  Declare TestClass(*Me.Polymesh_t)
  Declare OnMessage(id.i, *up)
  DataSection 
    PolymeshVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

Module Polymesh
  UseModule OpenGL
  UseModule OpenGLExt

  ; Constructor
  ;----------------------------------------------------
  Procedure New(name.s,shape.i)
    Protected *Me.Polymesh_t = AllocateMemory(SizeOf(Polymesh_t))
    InitializeStructure(*Me,Polymesh_t)
;     *Me\VT = ?PolymeshVT
;     *Me\classname = "POLYMESH"
    Object::INI(Polymesh)
    
    *Me\name = name
    ;*Me\shape = Shape::New(shape)
    
    *Me\geom = PolymeshGeometry::New(*Me,shape)
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\type = Object3D::#Object3D_Polymesh
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
   
    
    ; ---[ Attributes ]---------------------------------------------------------
    Protected *mesh.Geometry::PolymeshGeometry_t = *Me\geom
    Object3D::Object3D_ATTR()
    ; Singleton Attributes
    
    Protected *geom = Attribute::New("Geometry",Attribute::#ATTR_TYPE_GEOMETRY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*mesh,#True,#True)
    Object3D::AddAttribute(*Me,*geom)
    Protected *nbp = Attribute::New("NbVertices",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbpoints,#True,#True)
    Object3D::AddAttribute(*Me,*nbp)
    Protected *nbe = Attribute::New("NbEdges",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbedges,#True,#True)
    Object3D::AddAttribute(*Me,*nbe)
    Protected *nbf = Attribute::New("NbPolygons",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbpolygons,#True,#True)
    Object3D::AddAttribute(*Me,*nbf)
    Protected *nbt = Attribute::New("NbTriangles",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbtriangles,#True,#True)
    Object3D::AddAttribute(*Me,*nbt)
    Protected *nbs = Attribute::New("NbSamples",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbsamples,#True,#True)
    Object3D::AddAttribute(*Me,*nbs)
    Protected *nbi = Attribute::New("NbIndices",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbindices,#True,#True)
    Object3D::AddAttribute(*Me,*nbi)
    
    ; Singleton Arrays
    Protected *fc = Attribute::New("FaceCount",Attribute::#ATTR_TYPE_LONG,Attribute::#ATTR_STRUCT_ARRAY,Attribute::#ATTR_CTXT_SINGLETON,*mesh\a_facecount,#True,#False)
    Object3D::AddAttribute(*Me,*fc)
    Protected *fi = Attribute::New("FaceIndices",Attribute::#ATTR_TYPE_LONG,Attribute::#ATTR_STRUCT_ARRAY,Attribute::#ATTR_CTXT_SINGLETON,*mesh\a_faceindices,#True,#False)
    Object3D::AddAttribute(*Me,*fi)
    
    ; Per Point Attributes
    Protected *pointposition = Attribute::New("PointPosition",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_positions,#False,#False)
    Object3D::AddAttribute(*Me,*pointposition)
    Protected *pointnormal = Attribute::New("PointNormal",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_pointnormals,#False,#False)
    Object3D::AddAttribute(*Me,*pointnormal)
    Protected *pointvelocity = Attribute::New("PointVelocity",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_velocities,#False,#False)
    Object3D::AddAttribute(*Me,*pointvelocity)
    
    ; Per Sample Attributes
    Protected *normals = Attribute::New("Normals",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_normals,#False,#False)
    Object3D::AddAttribute(*Me,*normals)
    Protected *uvws = Attribute::New("UVWs",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_uvws,#False,#False)
    Object3D::AddAttribute(*Me,*uvws)
    Protected *pointcolor = Attribute::New("Colors",Attribute::#ATTR_TYPE_COLOR,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_colors,#False,#False)
    Object3D::AddAttribute(*Me,*pointcolor)
    Protected *data.CArray::CArrayPtr = CArray::newCArrayPtr()
    CArray::AppendPtr(*data,*mesh\topo)
    
    ; Topology Attribute
    Protected *topology = Attribute::New("Topology",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*data,#False,#True)
    Object3D::AddAttribute(*Me,*topology)
;     *Me\texture = 0
  
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.Polymesh_t)
    Object3D::DeleteAllAttributes(*Me)
    Stack::Delete(*Me\stack)
    PolymeshGeometry::Delete(*Me\geom)
    
    ClearStructure(*Me,Polymesh_t)
    FreeMemory(*Me)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Update GL Data (position & normals)
  ;-----------------------------------------------------
  Procedure UpdateGLData(*p.Polymesh_t)
    
     ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PolymeshGeometry_t = *p\geom
    Protected nbv = *geom\nbsamples
    If nbv <3 : ProcedureReturn : EndIf
    
    Protected GLfloat_s.GLfloat
    
    ; Get Polymesh Datas
    Protected s3 = SizeOf(GLfloat_s) * 3
    Protected s4 = SizeOf(GLfloat_s) * 4
    Protected size_p.i = nbv * s3
    Protected size_c.i = nbv * s4
    Protected size_t.i = 4*size_p + size_c
    
    ; Allocate Memory
    Protected *flatdata = AllocateMemory(size_p)
    Protected i
    Protected *v.v3f32
    Protected *c.c4f32

    ; POSITIONS
    ;-------------------------------------------------------------
    For i=0 To nbv-1
      *v = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,i))
      CopyMemory(*v,*flatdata+i*s3,s3)
    Next i
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,*flatdata)
    FreeMemory(*flatdata)
    
    ; NORMALS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*geom\a_normals,0))
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Buil GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLData(*p.Polymesh_t)
    
    ;Get Underlying Geometry
    Protected *geom.Geometry::PolymeshGeometry_t = *p\geom
    Protected nbv = *geom\nbsamples
    If nbv <3 : ProcedureReturn : EndIf
    
    Protected GLfloat_s.GLfloat
    
    ; Get Polymesh Datas
    Protected s3 = SizeOf(GLfloat_s) * 3
    Protected s4 = SizeOf(GLfloat_s) * 4
    Protected size_p.i = nbv * s3
    Protected size_c.i = nbv * s4
    Protected size_t.i = 4*size_p + size_c
    
    ; Allocate Memory
    Protected *flatdata = AllocateMemory(size_p)
    Protected i
    Protected *v.v3f32
    Protected *c.c4f32
    
    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_STATIC_DRAW)
    
    ; POSITIONS
    ;-------------------------------------------------------------
    For i=0 To nbv-1
      *v = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,i))
      CopyMemory(*v,*flatdata+i*s3,s3)
    Next i
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,*flatdata)
    FreeMemory(*flatdata)
    
    ; NORMALS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*geom\a_normals,0))
    
    ; TANGENTS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,2*size_p,size_p,CArray::GetPtr(*geom\a_tangents,0))
    
    ; UVWS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,3*size_p,size_p,CArray::GetPtr(*geom\a_uvws,0))
    
     ; COLORS
     ;-------------------------------------------------------------
    Protected c
    Protected *cl.c4f32
    
    glBufferSubData(#GL_ARRAY_BUFFER,4*size_p,size_c,CArray::GetPtr(*geom\a_colors,0))
    
    ; Attibute Position 0
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    
    ;Attibute Normal 1
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1,3,#GL_FLOAT,#GL_FALSE,0,size_p)
    
    ;Attibute Tangent 2
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2,3,#GL_FLOAT,#GL_FALSE,0,2*size_p)
    
    ;Attibute UVWs 2
    glEnableVertexAttribArray(3)
    glVertexAttribPointer(3,3,#GL_FLOAT,#GL_FALSE,0,3*size_p)
    
    ; Attribute Color 3
    glEnableVertexAttribArray(4)
    glVertexAttribPointer(4,4,#GL_FLOAT,#GL_FALSE,0,4*size_p)

  EndProcedure
  
  ;-----------------------------------------------------
  ; Buil Edges GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLEdgeData(*p.Polymesh_t)
    
    ;Get Underlying Geometry
    Protected *geom.Geometry::PolymeshGeometry_t = *p\geom
    
    ; Create or ReUse Vertex Array Object
    If Not *p\vao2
      glGenVertexArrays(1,@*p\vao2)
    EndIf
    glBindVertexArray(*p\vao2)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *p\vbo2
      glGenBuffers(1,@*p\vbo2)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo2)
    
    ; Push Position Datas to GPU
    Protected size_t = CArray::GetItemSize(*geom\a_positions) * *geom\nbpoints
    glBufferData(#GL_ARRAY_BUFFER,size_t,CArray::GetPtr(*geom\a_positions, 0),#GL_STATIC_DRAW)
    
    ; Attibute Position 0
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Create or ReUse Edge Elements Buffer
    If Not *p\eab2
      glGenBuffers(1,@*p\eab2)
    EndIf 
    glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*p\eab2)
    
    ; Push Element Datas to GPU
    size_t = CArray::GetItemSize(*geom\a_edgeindices) * 2 * *geom\nbedges
    glBufferData(#GL_ELEMENT_ARRAY_BUFFER,size_t,CArray::GetPtr(*geom\a_edgeindices, 0),#GL_STATIC_DRAW)

  EndProcedure
   
  ; Setup
  ;----------------------------------------------------
  Procedure Setup(*p.Polymesh_t,*pgm.Program::Program_t)

    If Not *p : ProcedureReturn : EndIf
    
    If *pgm : *p\shader = *pgm : EndIf
    
    ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PolymeshGeometry_t = *p\geom
    
    Protected nbv = CArray::GetCount(*geom\a_triangleindices)
    If nbv <3 : ProcedureReturn : EndIf
   
    ; Setup Static Kinematic STate
    ;ResetStaticKinematicState(*p)
    
    GLCheckError("Setup Mesh OpenGL Start")
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
  GLCheckError("Build GL DATAS")
    
    If *p\shader
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
        ;MessageRequester("Error Setup Shader Program for Polymesh",PeekS(*pLinkInfoLog))
      EndIf
    EndIf

;     ; Create or ReUse Edge Elements Buffer
;     If Not *p\eab
;       glGenBuffers(1,@*p\eab)
;     EndIf 
; 
;     glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*p\eab)

    ; Unbind
    glBindVertexArray(0)
    
    BuildGLEdgeData(*p)
    
    *p\initialized = #True
    *p\dirty = Object3D::#DIRTY_STATE_CLEAN
  EndProcedure
  
  ;-----------------------------------------------------
  ; Clean
  ;-----------------------------------------------------
  ;{
  Procedure Clean(*p.Polymesh_t)

    If *p\vao : glDeleteVertexArrays(1,@*p\vao) : EndIf 
    If *p\vbo: glDeleteBuffers(1,@*p\vbo) : EndIf
    If *p\eab: glDeleteBuffers(1,@*p\eab) : EndIf

  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Update
  ;-----------------------------------------------------
  ;{
  Procedure Update(*p.Polymesh_t)
    
    If *p\stack
      PolymeshGeometry::Reset(*p\geom)
      Stack::Update(*p\stack)
    EndIf
    
    If *p\dirty & Object3D::#DIRTY_STATE_TOPOLOGY Or Not *p\initialized
      Protected p.Object3D::IObject3D = *p
      p\Setup(*p\shader)

    Else 
      If *p\dirty & Object3D::#DIRTY_STATE_DEFORM
        PolymeshGeometry::RecomputeNormals(*p\geom,1.0)
        glBindVertexArray(*p\vao)
        glBindBuffer(#GL_ARRAY_BUFFER,*p\vbo)
        UpdateGLData(*p)
        glBindBuffer(#GL_ARRAY_BUFFER,0)
        glBindVertexArray(0)
        *p\dirty = Object3D::#DIRTY_STATE_CLEAN
      EndIf
    EndIf
   glCheckError("Update Polymesh")
  EndProcedure
  ;}
  
  ;-----------------------------------------------------
  ; Draw
  ;-----------------------------------------------------
  ;{
  Procedure Draw(*p.Polymesh_t)

    ;Skip invisible Object
    If Not *p\visible  Or Not *p\initialized: ProcedureReturn : EndIf
    Protected *geom.Geometry::PolymeshGeometry_t = *p\geom
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And #USE_LEGACY_OPENGL
      glBegin(#GL_TRIANGLES)
      Define.v3f32 *a,*b,*c
      For i = 0 To *geom\nbtriangles-1
        *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3))
        *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3+1))
        *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, i*3+2))
        glVertex3f(*a\x, *a\y, *a\z)
        glVertex3f(*b\x, *b\y, *b\z)
        glVertex3f(*c\x, *c\y, *c\z)
      Next
      
      glEnd()
    CompilerElse
      
      If *p\wireframe
        glBindVertexArray(*p\vao2)
        glPointSize(4)
        glDrawArrays(#GL_POINTS, 0, *geom\nbpoints)
  ;     glUniformMatrix4fv(glGetUniformLocation(*p\shader\pgm,"model"),1,#GL_FALSE,*p\matrix)
        glDrawElements(#GL_LINES,*geom\nbedges*2,#GL_UNSIGNED_INT,0)
        
        GLCheckError("DRAW MESH WIREFRAME")
      Else
        glBindVertexArray(*p\vao)
;       glUniformMatrix4fv(glGetUniformLocation(*p\shader\pgm,"model"),1,#GL_FALSE,*p\matrix)
        glDrawArrays(#GL_TRIANGLES,0,CArray::GetCount(*geom\a_triangleindices)) 
        GLCheckError("DRAW MESH SHADED")
      EndIf
      
      
      glBindVertexArray(0)
    CompilerEndIf
    
  EndProcedure
  ;}
  
  ; Set From Shape
  ;----------------------------------------------------
  Procedure SetFromShape(*Me.Polymesh_t,shape.i)

  EndProcedure
  
  
  Procedure OnMessage(id.i,*up)
    Protected *sig.Signal::Signal_t = *up
    Protected *snd.Object::Object_t = *sig\snd_inst
    Protected *rcv.Object::Object_t = *sig\rcv_inst
    
    Debug "Polymesh Recieved Message"
    Debug "Sender Class Name : "+*snd\class\name
    Debug "Reciever Class Name : "+*rcv\class\name
    
  EndProcedure
  
  Procedure TestClass(*Me.Polymesh_t)
    Debug ">>>>>>>>>>> "+Class\name
    Protected *cls.Class::Class_t = *Me\class
    Debug *cls
    Debug *cls\name
    Debug *cls\cmsg
    *cls\cmsg(0,#Null)
  EndProcedure
  
  Class::DEF( Polymesh )
  
  

  
  
EndModule

  
    
    
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 445
; FirstLine = 421
; Folding = ----
; EnableXP