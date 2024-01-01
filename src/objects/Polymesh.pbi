XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Types.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "PolymeshGeometry.pbi"

DeclareModule Polymesh
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure Polymesh_t Extends Object3D::Object3D_t
    deformdirty.b
    topodirty.b
    radius.f
    width.f
    height.f
    depth.f
    u.i
    v.i
    wireframe.b
    Map eaos.i()
    ebo.i
    eea.i
  EndStructure
  
  Interface IPolymesh Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s,shape.i)
  Declare Delete(*Me.Polymesh_t)
  Declare Setup(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
  Declare Update(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
  Declare Clean(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
  Declare Draw(*Me.Polymesh_t, *ctx.GLContext::GLContext_t)
  Declare SetFromShape(*Me.Polymesh_t,shape.i)
  Declare SetDirtyState(*Me.Polymesh_t, state.i)
  Declare UpdateAttributes(*Me.Polymesh_t)
  Declare SetClean(*Me.Polymesh_t)

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
    Protected *Me.Polymesh_t = AllocateStructure(Polymesh_t)
    Object::INI(Polymesh)
    
    *Me\name = name
    ;*Me\shape = Shape::New(shape)
    
    *Me\geom = PolymeshGeometry::New(*Me,shape)
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\type = Object3D::#Polymesh
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
   
    ; ---[ Attributes ]---------------------------------------------------------
    Protected *mesh.Geometry::PolymeshGeometry_t = *Me\geom
    Object3D::OBJECT3DATTR()
    ; Singleton Attributes
    Protected *geom = Attribute::New(*Me,"Geometry",Attribute::#ATTR_TYPE_GEOMETRY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\geom,#True,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*geom)
    Protected *nbp = Attribute::New(*Me,"NbVertices",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbpoints,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbp)
    Protected *nbe = Attribute::New(*Me,"NbEdges",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbedges,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbe)
    Protected *nbf = Attribute::New(*Me,"NbPolygons",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbpolygons,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbf)
    Protected *nbt = Attribute::New(*Me,"NbTriangles",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbtriangles,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbt)
    Protected *nbs = Attribute::New(*Me,"NbSamples",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbsamples,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbs)
    Protected *nbi = Attribute::New(*Me,"NbIndices",Attribute::#ATTR_TYPE_INTEGER,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*mesh\nbindices,#True,#True,#True,#False)
    Object3D::AddAttribute(*Me,*nbi)
    
    ; Singleton Arrays
    Protected *fc = Attribute::New(*Me,"FaceCount",Attribute::#ATTR_TYPE_LONG,Attribute::#ATTR_STRUCT_ARRAY,Attribute::#ATTR_CTXT_SINGLETON,*mesh\a_facecount,#True,#True,#False,#True,#True)
    Object3D::AddAttribute(*Me,*fc)
    Protected *fi = Attribute::New(*Me,"FaceIndices",Attribute::#ATTR_TYPE_LONG,Attribute::#ATTR_STRUCT_ARRAY,Attribute::#ATTR_CTXT_SINGLETON,*mesh\a_faceindices,#True,#True,#False,#True,#True)
    Object3D::AddAttribute(*Me,*fi)
    
    ; Per Point Attributes
    Protected *Meointposition = Attribute::New(*Me,"PointPosition",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_positions,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointposition)
    Protected *Meointnormal = Attribute::New(*Me,"PointNormal",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_pointnormals,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointnormal)
    Protected *Meointvelocity = Attribute::New(*Me,"PointVelocity",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D,*mesh\a_velocities,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointvelocity)
    
    ; Per Sample Attributes
    Protected *normals = Attribute::New(*Me,"Normals",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_normals,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*normals)
    Protected *uvws = Attribute::New(*Me,"UVWs",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_uvws,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*uvws)
    Protected *Meointcolor = Attribute::New(*Me,"Colors",Attribute::#ATTR_TYPE_COLOR,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_COMPONENT0D2D,*mesh\a_colors,#True,#False,#False,#True,#True)
    Object3D::AddAttribute(*Me,*Meointcolor)
    
    ; Topology Attribute
    Protected *topology = Attribute::New(*Me,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*mesh\topo,#True,#False,#True,#True,#True)
    Object3D::AddAttribute(*Me,*topology)
;     *Me\texture = 0
    Object3D::Freeze(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.Polymesh_t)
    Object3D::DeleteAllAttributes(*Me)
    Stack::Delete(*Me\stack)
    PolymeshGeometry::Delete(*Me\geom)
    
    FreeStructure(*Me)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Set Dirty State
  ;-----------------------------------------------------
  Procedure SetDirtyState(*Me.Polymesh_t, state)
    If state = Object3D::#DIRTY_STATE_TOPOLOGY
      *Me\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
      Object3D::SetAttributeDirty(*Me,"Geometry")
      Object3D::SetAttributeDirty(*Me,"NbVertices")
      Object3D::SetAttributeDirty(*Me,"NbEdges")
      Object3D::SetAttributeDirty(*Me,"NbPolygons")
      Object3D::SetAttributeDirty(*Me,"NbTriangles")
      Object3D::SetAttributeDirty(*Me,"NbSamples")
      Object3D::SetAttributeDirty(*Me,"NbIndices")
      Object3D::SetAttributeDirty(*Me,"FaceCount")
      Object3D::SetAttributeDirty(*Me,"FaceIndices")
      Object3D::SetAttributeDirty(*Me,"PointPosition")
      Object3D::SetAttributeDirty(*Me,"PointNormal")
      Object3D::SetAttributeDirty(*Me,"PointVelocity")
      Object3D::SetAttributeDirty(*Me,"Normals")
      Object3D::SetAttributeDirty(*Me,"UVWs")
      Object3D::SetAttributeDirty(*Me,"Colors")
      Object3D::SetAttributeDirty(*Me,"Topology")
    ElseIf state = Object3D::#DIRTY_STATE_DEFORM
      If *me\dirty = Object3D::#DIRTY_STATE_CLEAN
        *Me\dirty = Object3D::#DIRTY_STATE_DEFORM
        Object3D::SetAttributeDirty(*Me,"PointPosition")
        Object3D::SetAttributeDirty(*Me,"PointNormal")
        Object3D::SetAttributeDirty(*Me,"PointVelocity")
        Object3D::SetAttributeDirty(*Me,"Normals")
      EndIf
    EndIf
  EndProcedure
  
  Procedure UpdateAttributes(*Me.Polymesh_t)
    Define *attr.Attribute::Attribute_t
    Define *geom.Geometry::PolymeshGeometry_t = *Me\geom
    *attr = Object3D::GetAttribute(*Me, "Geometry")
    *attr\data = *geom
    *attr = Object3D::GetAttribute(*Me, "NbVertices")
    *attr\data = @*geom\nbpoints
    *attr = Object3D::GetAttribute(*Me, "NbEdges")
    *attr\data = @*geom\nbedges
    *attr = Object3D::GetAttribute(*Me, "NbPolygons")
    *attr\data = @*geom\nbpolygons
    *attr = Object3D::GetAttribute(*Me, "NbTriangles")
    *attr\data = @*geom\nbtriangles
    *attr = Object3D::GetAttribute(*Me, "NbSamples")
    *attr\data = @*geom\nbsamples
    *attr = Object3D::GetAttribute(*Me, "NbIndices")
    *attr\data = @*geom\nbindices
    
    *attr = Object3D::GetAttribute(*Me, "FaceCount")
    *attr\data = *geom\a_facecount
    *attr = Object3D::GetAttribute(*Me, "FaceIndices")
    *attr\data = *geom\a_faceindices
    
    *attr = Object3D::GetAttribute(*Me, "PointPosition")
    *attr\data = *geom\a_positions
    *attr = Object3D::GetAttribute(*Me, "PointNormal")
    *attr\data = *geom\a_pointnormals
    *attr = Object3D::GetAttribute(*Me, "PointVelocity")
    *attr\data = *geom\a_velocities
    
    *attr = Object3D::GetAttribute(*Me, "Normals")
    *attr\data = *geom\a_normals
    *attr = Object3D::GetAttribute(*Me, "UVWs")
    *attr\data = *geom\a_uvws
    *attr = Object3D::GetAttribute(*Me, "Colors")
    *attr\data = *geom\a_colors
    
    *attr = Object3D::GetAttribute(*Me, "Topology")
    *attr\data = *geom\topo

  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Set Clean
  ;-----------------------------------------------------
  Procedure SetClean(*Me.Polymesh_t)
    *Me\dirty = Object3D::#DIRTY_STATE_CLEAN
    ForEach *Me\geom\m_attributes()
      *Me\geom\m_attributes()\dirty = #False
    Next
  EndProcedure
  
  ;-----------------------------------------------------
  ; Update GL Data (position & normals)
  ;-----------------------------------------------------
  Procedure UpdateGLData(*Me.Polymesh_t)
     ;---[ Get Underlying Geometry ]--------------------
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    Protected nbs = *geom\nbsamples
    If nbs <3 : ProcedureReturn : EndIf
    
    Protected GLfloat_s.GLfloat
    
    ; Get Polymesh Datas
    Protected s3 = SizeOf(v3f32)
    Protected s4 = SizeOf(c4f32)
    Protected size_p.i = nbs * s3
    Protected size_c.i = nbs * s4
    Protected size_t.i = 4*size_p + size_c
    
    ; Allocate Memory
    Protected *flatdata = AllocateMemory(size_p)
    Protected i
    Protected *v.v3f32
    Protected *c.c4f32

    ; POSITIONS
    ;-------------------------------------------------------------
    Protected size_v = CArray::GetItemSize(*geom\a_positions)
    Protected size_i = CArray::GetItemSize(*geom\a_triangleindices)
    Protected id.l
    For i=0 To nbs-1
      id = CArray::GetValueL(*geom\a_triangleindices, i)
      *v = CArray::GetValue(*geom\a_positions, id)
      CopyMemory(*v,*flatdata+i*s3,s3)
    Next i
;     For i=0 To nbs-1
;       *v = CArray::GetValue(*geom\a_positions,CArray::GetValueL(*geom\a_triangleindices,i))
;       CopyMemory(*v,*flatdata+i*s3,s3)
;     Next i
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,*flatdata)
    FreeMemory(*flatdata)
    
    ; NORMALS
    ;-------------------------------------------------------------
    glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*geom\a_normals,0))
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Buil GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLData(*Me.Polymesh_t)
    
    ;Get Underlying Geometry
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    Protected nbs = *geom\nbsamples
    If nbs <3 : ProcedureReturn : EndIf
    
    Protected GLfloat_s.GLfloat
    
    ; Get Polymesh Datas
    Protected s3 = SizeOf(v3f32)
    Protected s4 = SizeOf(c4f32)
    Protected size_p.i = nbs * s3
    Protected size_c.i = nbs * s4
    Protected size_t.i = 4*size_p + size_c

    
    ; Allocate Memory
    Protected *flatdata = AllocateMemory(size_p)
    Protected i
    Protected *v.v3f32
    Protected *o.v3f32
    Protected *c.c4f32
    
    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_STATIC_DRAW)
    
    ; POSITIONS
    ;-------------------------------------------------------------
    Protected id.l
    For i=0 To nbs-1
      id = CArray::GetValueL(*geom\a_triangleindices, i)
      *v = CArray::GetValue(*geom\a_positions, id)
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
    glBufferSubData(#GL_ARRAY_BUFFER,4*size_p,size_c,CArray::GetPtr(*geom\a_colors,0))
    
    ; Activate Attributes
    ;-------------------------------------------------------------
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Protected x.a = 4
    CompilerElse
      Protected x.a = 3
    CompilerEndIf
    
    ; Attribute Position 0
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,x,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Attribute Normal 1
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1,x,#GL_FLOAT,#GL_FALSE,0,size_p)
    
    ; Attribute Tangent 2
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2,x,#GL_FLOAT,#GL_FALSE,0,2*size_p)
    
    ; Attribute UVWs 2
    glEnableVertexAttribArray(3)
    glVertexAttribPointer(3,x,#GL_FLOAT,#GL_FALSE,0,3*size_p)
    
    ; Attribute Color 3
    glEnableVertexAttribArray(4)
    glVertexAttribPointer(4,4,#GL_FLOAT,#GL_FALSE,0,4*size_p)

  EndProcedure
  
  ;-----------------------------------------------------
  ; Buil Edges GL Data 
  ;-----------------------------------------------------
  Procedure BuildGLEdgeData(*Me.Polymesh_t)
    
    ;Get Underlying Geometry
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    
    ; Create or ReUse Vertex Array Object
    Object3D::BindVAOForContext(*Me\eaos(), *ctxt, #True)
 
    ; Create or ReUse Vertex Buffer Object
    Object3D::BindVBO(@*Me\ebo)
    
    ; Push Position Datas to GPU
    glBufferData(#GL_ARRAY_BUFFER,CArray::GetSize(*geom\a_positions),CArray::GetPtr(*geom\a_positions, 0),#GL_STATIC_DRAW)
    
    ; Attibute Position 0
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Create or ReUse Edge Elements Buffer
    Object3D::BindEAB(@*Me\eea)
    
    ; Push Element Datas to GPU
    glBufferData(#GL_ELEMENT_ARRAY_BUFFER,CArray::GetSize(*geom\a_edgeindices),CArray::GetPtr(*geom\a_edgeindices, 0),#GL_STATIC_DRAW)
    

  EndProcedure
  
  ;-----------------------------------------------------
  ; Update GL Edge Data (position)
  ;-----------------------------------------------------
  Procedure UpdateGLEdgeData(*Me.Polymesh_t)
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    
    glBufferData(#GL_ARRAY_BUFFER,
                 CArray::GetSize(*geom\a_positions),
                 CArray::GetPtr(*geom\a_positions, 0),
                 #GL_STATIC_DRAW)
    
    glBufferData(#GL_ELEMENT_ARRAY_BUFFER,
                 CArray::GetSize(*geom\a_edgeindices), 
                 CArray::GetPtr(*geom\a_edgeindices), 
                 #GL_STATIC_DRAW)
  EndProcedure
  
   
  ; Setup
  ;----------------------------------------------------
  Procedure Setup(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
    If Not *Me : ProcedureReturn : EndIf
    
    ; Get Underlying Geometry
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    
    Protected nbs = CArray::GetCount(*geom\a_triangleindices)
    If nbs <3 : ProcedureReturn : EndIf
    
    If Object3D::BindVaoFOrContext(*Me\vaos(), *ctxt, #True)
      Object3D::BindVbo(@*Me\vbo)
      
      If *ctxt\share
        ; Fill Buffer
        BuildGLData(*Me)
        GLCheckError("build gl data")
    
        ; Create Edge Elements Buffer
        BuildGLEdgeData(*Me)
        GLCheckError("build edge data")
        *Me\initialized = #True
        SetClean(*Me)
      EndIf
      
      glBindVertexArray(0)
 
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; Clean
  ;-----------------------------------------------------
  Procedure Clean(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
    Object3D::DeleteVAOs(*Me\vaos())
    Object3D::DeleteVBO(@*Me\vbo)
    Object3D::DeleteEAB(@*Me\eab)
    Object3D::DeleteVAOs(*Me\eaos())
    Object3D::DeleteVBO(@*Me\ebo)
    Object3D::DeleteEAB(@*Me\eea)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Update
  ;-----------------------------------------------------
  Procedure Update(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
    If Not *ctxt\share : ProcedureReturn : EndIf
    If *Me\stack And Stack::HasNodes(*Me\stack)
      PolymeshGeometry::Reset(*Me\geom)
      Stack::Update(*Me\stack)
    EndIf
    
    If *Me\dirty & Object3D::#DIRTY_STATE_TOPOLOGY Or Not *Me\initialized
      Setup(*Me, *ctxt)
    ElseIf *Me\dirty & Object3D::#DIRTY_STATE_DEFORM
      PolymeshGeometry::ComputeNormals(*Me\geom,1.0)
      Object3D::BindVaoForContext(*Me\vaos(), *ctxt)
      Object3D::BindVBO(@*Me\vbo)
      UpdateGLData(*Me)
      Object3D::BindVaoForContext(*Me\eaos(), *ctxt)
      Object3D::BindVBO(@*Me\ebo)
      UpdateGLEdgeData(*Me)
      glBindBuffer(#GL_ARRAY_BUFFER,0)
      glBindVertexArray(0)
      SetClean(*Me)
    EndIf

  EndProcedure
  
  ;-----------------------------------------------------
  ; Draw
  ;-----------------------------------------------------
  Procedure Draw(*Me.Polymesh_t, *ctxt.GLContext::GLContext_t)
    Protected *geom.Geometry::PolymeshGeometry_t = *Me\geom
    ;Skip invisible Object
    If Not *Me\visible  Or Not *Me\initialized: ProcedureReturn : EndIf
      If Object3d::BindVaoFOrContext(*Me\vaos(), *ctxt)
  ;     glUseProgram(*ctx\shaders("normal")\pgm)
        glDisable (#GL_POLYGON_OFFSET_FILL)
        glPolygonMode(#GL_FRONT_AND_BACK, #GL_FILL)
        glDrawArrays(#GL_TRIANGLES,0,CArray::GetCount(*geom\a_triangleindices)) 
        GLCheckError("[Polymesh] Draw mesh Called")
        glBindVertexArray(0)
        ;     EndIf
      EndIf
      
  
;     If *Me\selected
;       
;       glBindVertexArray(*Me\eao)
;       glDrawElements(#GL_LINES, *geom\nbedges, #GL_UNSIGNED_INT,#Null)
;       glBindVertexArray(0)
; ;       glEnable(#GL_BLEND)
; ;       glBlendFunc(#GL_ONE_MINUS_SRC_COLOR, #GL_ZERO)
; ;       glEnable (#GL_POLYGON_OFFSET_LINE)
; ;       glPolygonOffset (4.0, 1.0)
; ;       glPolygonMode(#GL_FRONT_AND_BACK, #GL_LINE)
; ; 
; ;       glDrawArrays(#GL_TRIANGLES,0,CArray::GetCount(*geom\a_triangleindices)) 
; ;       glDisable(#GL_BLEND)
; ;       glDisable (#GL_POLYGON_OFFSET_LINE)
; ;       glPolygonMode(#GL_FRONT_AND_BACK, #GL_FILL)
;     EndIf
  EndProcedure
  
  ; Set From Shape
  ;----------------------------------------------------
  Procedure SetFromShape(*Me.Polymesh_t,shape.i)

  EndProcedure

  
  Class::DEF( Polymesh )

EndModule

  
    
    
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 474
; FirstLine = 426
; Folding = ---
; EnableXP