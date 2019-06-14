XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "DrawerGeometry.pbi"

;==============================================================================
; Drawer Module Declaration
;==============================================================================
DeclareModule Drawer
  UseModule OpenGL
  UseModule OpenGLExt
  
  Enumeration
    #ITEM_POINT
    #ITEM_LINE
    #ITEM_STRIP
    #ITEM_LOOP
    #ITEM_BOX
    #ITEM_MATRIX
    #ITEM_SPHERE
    #ITEM_TRIANGLE
    #ITEM_TEXT
    #ITEM_COMPOUND
  EndEnumeration
  
  Structure Item_t
    type.i
    *positions.CArray::CArrayV3F32
    *colors.CArray::CArrayC4F32
    size.f
    vao.i
    vbo.i
    eab.i
    wireframe.b
  EndStructure
  
  Structure Point_t Extends Item_t
  EndStructure
  
  Structure Line_t Extends Item_t
  EndStructure
  
  Structure Strip_t Extends Item_t
    *indices.CArray::CArrayLong  
  EndStructure
  
  Structure Loop_t Extends Item_t
    *indices.CArray::CArrayLong  
  EndStructure
  
  Structure Triangle_t Extends Item_t
  EndStructure
  
  Structure Text_t Extends Item_t
    text.s
  EndStructure
  
  Structure Box_t Extends Item_t
    m.Math::m4f32  
  EndStructure
  
  Structure Sphere_t Extends Item_t
    m.Math::m4f32
  EndStructure
  
  Structure Matrix_t Extends Item_t
    m.Math::m4f32
  EndStructure
  
  Structure Compound_t Extends Item_t
    List *items.Item_t()
  EndStructure
  
  Structure Drawer_t Extends Object3D::Object3D_t
    ; uniforms
    u_model.GLint
    u_proj.GLint
    u_view.GLint
    u_offset.GLint
;     u_color.GLint
;     u_colored.GLint
    overlay.b
    List *items.Item_t()

  EndStructure
  
  Interface IDrawer Extends Object3D::IObject3D
  EndInterface

  Declare New( name.s = "Drawer")
  Declare AddPoint(*Me.Drawer_t, *position.Math::v3f32)
;   Declare NewColoredPoint(*Me.Drawer_t, *position.v3f32, *color.c4f32)
  Declare AddPoints(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
  Declare AddColoredPoints(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
  Declare AddLine(*Me.Drawer_t, *start.Math::v3f32, *end.Math::v3f32)
  Declare AddLines(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
  Declare AddLines2(*Me.Drawer_t, *start.CArray::CArrayV3F32, *end.CARray::CArrayV3F32)
  Declare AddColoredLines(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
  Declare AddStrip(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *indices.CArray::CArrayLong=#Null)
  Declare AddLoop(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *indices.CArray::CArrayLong=#Null)
  Declare AddBox(*Me.Drawer_t, *m.Math::m4f32)
  Declare AddSphere(*Me.Drawer_t, *m.Math::m4f32)
  Declare AddMatrix(*Me.Drawer_t, *m.Math::m4f32)
  Declare AddTriangle(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
  Declare AddColoredTriangle(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
  Declare Delete(*Me.Drawer_t)
  Declare DeletePoint(*Me.Point_t)
  Declare DeleteLine(*Me.Line_t)
  Declare DeleteStrip(*Me.Strip_t)
  Declare DeleteLoop(*Me.Loop_t)
  Declare DeleteBox(*Me.Box_t)
  Declare DeleteMatrix(*Me.Matrix_t)
  Declare DeleteTriangle(*Me.Triangle_t)
  Declare SetColor(*Me.Item_t, *color.Math::c4f32)
  Declare SetSize(*Me.Item_t, size.f)
  Declare SetWireframe(*Me.Item_t, wireframe.b)
  Declare Flush(*Me.Drawer_t)
  Declare Setup(*Me.Drawer_t,*shader.Program::Program_t)
  Declare Update(*Me.Drawer_t)
  Declare Clean(*Me.Drawer_t)
  Declare Draw(*Me.Drawer_t)
  
  DataSection 
    DrawerVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_T  
EndDeclareModule

;==============================================================================
; Drawer Module Implementation
;==============================================================================
Module Drawer
  UseModule OpenGL
  UseModule OpenGLExt

  ;----------------------------------------------------------------------------
  ;  Echo ( Debug )
  ;----------------------------------------------------------------------------
  Procedure Echo(*Me.Drawer_t)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Size
  ;---------------------------------------------------------------------------- 
  Procedure SetSize(*Me.Item_t,size.f)
    If Not *Me : ProcedureReturn : EndIf
    *me\size = size
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Wireframe
  ;---------------------------------------------------------------------------- 
  Procedure SetWireframe(*Me.Item_t,wireframe.b)
    If Not *Me : ProcedureReturn : EndIf
    *me\wireframe = wireframe
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Color
  ;---------------------------------------------------------------------------- 
  Procedure SetColor(*Me.Item_t,*color.Math::c4f32)
    If Not *Me : ProcedureReturn : EndIf
    Protected i
    Protected *c.Math::c4f32
    For i=0 To CArray::GetCount(*Me\colors) - 1
      *c = CArray::GetValue(*Me\colors, i)
      Color::SetFromOther(*c, *color)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Shader
  ;---------------------------------------------------------------------------- 
  Procedure SetShader(*Me.Drawer_t,*pgm.Program::Program_t)
    If Not *Me : ProcedureReturn : EndIf
    
    *Me\shader = *pgm
    
    *Me\u_model = glGetUniformLocation(*pgm\pgm,"model")
    *Me\u_proj = glGetUniformLocation(*pgm\pgm,"projection")
    *Me\u_view = glGetUniformLocation(*pgm\pgm,"view")
    *Me\u_offset = glGetUniformLocation(*pgm\pgm, "offset")
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Setup OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Setup(*Me.Drawer_t,*shader.Program::Program_t)
    ; ---[ Sanity Check ]----------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; ---[ Reset Kinematic State ]-------------------
    
    Object3D::ResetStaticKinematicState(*Me)
    Protected shader.i
    Protected plength.i, clength.i, tlength.i
    ; ---[ Assign Shader ]---------------------------
    If *shader : SetShader(*Me, *shader) : EndIf
    
    Protected *item.Item_t
    ForEach *Me\items()
      *item = *me\items()
      ;Create Or ReUse Vertex Array Object
      If Not *item\vao
        glGenVertexArrays(1,@*item\vao)
      EndIf
      glBindVertexArray(*item\vao)
      
      ; Create or ReUse Vertex Buffer Object
      If Not *item\vbo
        glGenBuffers(1,@*item\vbo)
      EndIf
      glBindBuffer(#GL_ARRAY_BUFFER,*item\vbo)
      
      ; Fill Buffer Data
      plength = CArray::GetItemSize(*item\positions) * CArray::GetCount(*item\positions)
      clength = CArray::GetItemSize(*item\colors) * CArray::GetCount(*item\colors)
      tlength = plength + clength
      glBufferData(#GL_ARRAY_BUFFER,tlength,#Null,#GL_DYNAMIC_DRAW)
      glBufferSubData(#GL_ARRAY_BUFFER, 0, plength, CArray::GetPtr(*item\positions,0))
      glBufferSubData(#GL_ARRAY_BUFFER, plength, clength, CArray::GetPtr(*item\colors,0))
      glEnableVertexAttribArray(0)
      CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
        glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
      CompilerElse
        glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
      CompilerEndIf
      glEnableVertexAttribArray(1)
      glVertexAttribPointer(1,4,#GL_FLOAT,#GL_FALSE,0,plength)
      
    Next
    
    *Me\initialized = #True
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Clean OpenGL Context
  ;---------------------------------------------------------------------------- 
  Procedure Clean(*Me.Drawer_t)
    ForEach *me\items()
      If *Me\items()\vao : glDeleteVertexArrays(1,@*Me\items()\vao) : EndIf
      If *Me\items()\vbo : glDeleteBuffers(1,@*Me\items()\vbo) : EndIf
      If *Me\items()\eab : glDeleteBuffers(1,@*Me\items()\eab) : EndIf
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Update OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Update(*Me.Drawer_t)
    Protected *item.Item_t
    Protected s.GLfloat
    Protected length.i, plength.i, clength.i
       
    ForEach *Me\items()
      *item = *me\items()
      ;Create Or ReUse Vertex Array Object
      If Not *item\vao
        glGenVertexArrays(1,@*item\vao)
      EndIf
      glBindVertexArray(*item\vao)
      
      ; Create or ReUse Vertex Buffer Object
      If Not *item\vbo
        glGenBuffers(1,@*item\vbo)
      EndIf
      glBindBuffer(#GL_ARRAY_BUFFER,*item\vbo)
      
      plength.i = CArray::GetItemSize(*item\positions) * CArray::GetCount(*item\positions)
      If *item\colors
        clength = CArray::GetItemSize(*item\colors) * CArray::GetCount(*item\colors)
        length = plength + clength
        glBufferData(#GL_ARRAY_BUFFER,length,#Null,#GL_DYNAMIC_DRAW)
        glBufferSubData(#GL_ARRAY_BUFFER, 0, plength, CArray::GetPtr(*item\positions,0))
        glBufferSubData(#GL_ARRAY_BUFFER, plength, clength, CArray::GetPtr(*item\colors,0))
          
        glEnableVertexAttribArray(0)
        CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
          glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
        CompilerElse
          glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
        CompilerEndIf
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1,4,#GL_FLOAT,#GL_FALSE,0,plength)
      Else
        length = plength 
        glBufferData(#GL_ARRAY_BUFFER,length,#Null,#GL_DYNAMIC_DRAW)
        glBufferSubData(#GL_ARRAY_BUFFER, 0, length, CArray::GetPtr(*item\positions,0))
          
        glEnableVertexAttribArray(0)
        CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
          glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
        CompilerElse
          glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
        CompilerEndIf
      EndIf
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Flush
  ;---------------------------------------------------------------------------- 
  Procedure Flush(*Me.Drawer_t)
    ForEach *Me\items()
      Select *Me\items()\type
        Case #ITEM_POINT
          DeletePoint(*Me\items())
        Case #ITEM_STRIP
          DeleteStrip(*Me\items())
        Case #ITEM_LINE
          DeleteLine(*Me\items())
        Case #ITEM_LOOP
          DeleteLoop(*Me\items())
        Case #ITEM_BOX
          DeleteBox(*Me\items())
        Case #ITEM_MATRIX
          DeleteMatrix(*Me\items())
        Case #ITEM_TRIANGLE
          DeleteTriangle(*Me\items())
        Case #ITEM_COMPOUND
          Debug "NOT IMPLEMENTED"
      EndSelect
    Next
    ClearList(*Me\items())
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;---------------------------------------------------------------------------- 
  ; ---[ Draw Point Item ]-----------------------------------------------------
  Procedure DrawPoint(*Me.Point_t)
    glPointSize(*Me\size)
    glDrawArrays(#GL_POINTS,0,CArray::GetCount(*Me\positions))
  EndProcedure
  
  ; ---[ Draw Line Item ]------------------------------------------------------
  Procedure DrawLine(*Me.Line_t)
    glLineWidth(*Me\size)
    glDrawArrays(#GL_LINES,0,CArray::GetCount(*Me\positions))
  EndProcedure
  
  ; ---[ Draw Loop Item ]------------------------------------------------------
  Procedure DrawLoop(*Me.Loop_t)
    Protected i.i, cnt.i, base.i
    base = 0
    glLineWidth(*Me\size)
    For i=0 To CArray::GetCount(*Me\indices)-1
      cnt = CArray::GetValueL(*Me\indices, i)
      glDrawArrays(#GL_LINE_LOOP,base,cnt)
      base +cnt
    Next
  EndProcedure
  
  ; ---[ Draw Strip Item ]-----------------------------------------------------
  Procedure DrawStrip(*Me.Strip_t)
    Protected i.i, cnt.i, base.i
    base = 0
    glLineWidth(*Me\size)
    For i=0 To CArray::GetCount(*Me\indices)-1
      cnt = CArray::GetValueL(*Me\indices, i)
      glDrawArrays(#GL_LINE_STRIP,base,cnt)
      base +cnt
    Next
  EndProcedure
  
  ; ---[ Draw Box Item ]-----------------------------------------------------
  Procedure DrawBox(*Me.Box_t, *pgm)
    If *Me\wireframe
      glLineWidth(Math::Max(Int(*Me\size),1))
      glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,Shape::GetEdges(Shape::#SHAPE_CUBE))
    Else
      glPolygonMode(#GL_FRONT_AND_BACK, #GL_FILL)
      glDrawElements(#GL_TRIANGLES,48,#GL_UNSIGNED_INT,Shape::GetFaces(Shape::#SHAPE_CUBE))
    EndIf
  EndProcedure
  
  ; ---[ Draw Sphere Item ]--------------------------------------------------
  Procedure DrawSphere(*Me.Matrix_t, *pgm)
    glPolygonMode(#GL_FRONT_AND_BACK, #GL_FILL)
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,*Me\m)
    
    glLineWidth(Math::Max(Int(*Me\size),1))
    Protected *indices = Shape::GetFaces(Shape::#SHAPE_SPHERE)
    Protected offset.i = 8
    If *Me\wireframe
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_LINE)
      glDrawElements(#GL_TRIANGLES,Shape::#SPHERE_NUM_INDICES,#GL_UNSIGNED_INT,*indices)
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
    Else
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
      glDrawElements(#GL_TRIANGLES,Shape::#SPHERE_NUM_INDICES,#GL_UNSIGNED_INT,*indices)
    EndIf
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,Matrix4::IDENTITY())
    glLineWidth(1)
  EndProcedure
  
  ; ---[ Draw Matrix Item ]--------------------------------------------------
  Procedure DrawMatrix(*Me.Matrix_t, *pgm)
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,*Me\m)
    glLineWidth(Math::Max(Int(*Me\size),1))
    Protected *indices = Shape::GetEdges(Shape::#SHAPE_AXIS)
    Protected offset.i = 8
    Protected u_color = glGetUniformLocation(*pgm,"color")
    glUniform4f(u_color,1.0,0.0,0.0,1.0)
    glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,*indices)
    glUniform4f(u_color,0.0,1.0,0.0,1.0)
    glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,*indices + offset)
    glUniform4f(u_color,0.0,0.0,1.0,1.0)
    glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,*indices + 2 * offset)
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,Matrix4::IDENTITY())
    glLineWidth(1)
  EndProcedure
  
  ; ---[ Draw Triangle Item ]--------------------------------------------------
  Procedure DrawTriangle(*Me.Triangle_t)
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,Matrix4::IDENTITY())
    If *Me\wireframe
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_LINE)
      glDrawArrays(#GL_TRIANGLES, 0, CArray::GetCount(*Me\positions))
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
    Else
      glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
      glDrawArrays(#GL_TRIANGLES, 0, CArray::GetCount(*Me\positions))
    EndIf
    glUniformMatrix4fv(glGetUniformLocation(*pgm,"offset"),1,#GL_FALSE,Matrix4::IDENTITY())
  EndProcedure
  
  ; ---[ Draw Item ]-----------------------------------------------------------
  Procedure Draw(*Me.Drawer_t)
    If Not *Me : ProcedureReturn : EndIf
    Protected *t.Transform::Transform_t = *Me\globalT
    Protected base.i, i
    If *Me\overlay
      glDisable(#GL_DEPTH_TEST)
    Else
      glEnable(#GL_DEPTH_TEST)
    EndIf
    
    
    glUniformMatrix4fv(*Me\u_model,1,#GL_FALSE,*t\m)
    glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,Matrix4::IDENTITY())
    ForEach *Me\items()
      With *Me\items()
        glBindVertexArray(\vao)
        Select \type
          Case #ITEM_POINT
            DrawPoint(*Me\items())
          Case #ITEM_LINE
            DrawLine(*Me\items())
          Case #ITEM_LOOP
            DrawLoop(*me\items())
          Case #ITEM_STRIP
            DrawStrip(*Me\items())
          Case #ITEM_BOX
            DrawBox(*Me\items(), *Me\shader\pgm)
          Case #ITEM_SPHERE
            DrawSphere(*Me\items(), *Me\shader\pgm)
          Case #ITEM_MATRIX
            DrawMatrix(*Me\items(), *Me\shader\pgm)
          Case #ITEM_TRIANGLE
            DrawTriangle(*Me\items())
          Case #ITEM_COMPOUND
            Debug "[DRAWER] Compound Shape NOT Implemented"
        EndSelect
      EndWith
    Next
  
    glBindVertexArray(0)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Pick
  ;---------------------------------------------------------------------------- 
  Procedure Pick(*n.Drawer_t)
   
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ;  Delete
  ;----------------------------------------------------------------------------
  ; ---[ Delete GL Item ]------------------------------------------------------
  Procedure DeleteItem(*Me.Item_t)
    If *Me\vao : glDeleteVertexArrays(1, @*Me\vao) : EndIf
    If *Me\vbo : glDeleteBuffers(1,  @*Me\vbo) : EndIf
    If *me\eab : glDeleteBuffers(1,@*Me\eab) : EndIf
    CArray::Delete(*Me\positions)
    CArray::Delete(*Me\colors)
  EndProcedure
  
  ; ---[ Delete Point Item ]---------------------------------------------------
  Procedure DeletePoint(*Me.Point_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Line Item ]----------------------------------------------------
  Procedure DeleteLine(*Me.Line_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Strip Item ]---------------------------------------------------
  Procedure DeleteStrip(*Me.Strip_t)
    DeleteItem(*Me)
    CArray::Delete(*Me\indices)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Loop Item ]----------------------------------------------------
  Procedure DeleteLoop(*Me.Loop_t)
    DeleteItem(*Me)
    CArray::Delete(*Me\indices)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Box Item ]-----------------------------------------------------
  Procedure DeleteBox(*Me.Box_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Sphere Item ]--------------------------------------------------
  Procedure DeleteSphere(*Me.Sphere_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Matrix Item ]--------------------------------------------------
  Procedure DeleteMatrix(*Me.Matrix_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Triangle Item ]--------------------------------------------------
  Procedure DeleteTriangle(*Me.Triangle_t)
    DeleteItem(*Me)
    FreeMemory(*Me)
  EndProcedure
  
  ; ---[ Delete Drawer Item ]--------------------------------------------------
  Procedure Delete( *Me.Drawer_t )
    ForEach *Me\items()
      Select *Me\items()\type
        Case #ITEM_POINT
          DeletePoint(*Me\items())
        Case #ITEM_LINE
          DeleteLine(*ME\items())
        Case #ITEM_STRIP
          DeleteStrip(*Me\items())
        Case #ITEM_LOOP
          DeleteLoop(*ME\items())
        Case #ITEM_BOX
          DeleteBox(*Me\items())
        Case #ITEM_SPHERE
          DeleteSphere(*Me\items())
        Case #ITEM_MATRIX
          DeleteMatrix(*Me\items())
        Case #ITEM_TRIANGLE
          DeleteTriangle(*Me\items())
        Case #ITEM_COMPOUND
          Debug "[DRAWER] Compound Shape NOT Implemented"
          ;           DeleteCompound(*Me\items())
      EndSelect
    Next
    ClearList(*Me\items())
    Object::TERM(Drawer)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; New
  ;----------------------------------------------------------------------------
  Procedure.i New( name.s = "Drawer")
    ; Allocate Object Memory
    Protected *Me.Drawer_t = AllocateMemory( SizeOf(Drawer_t) )
    ; Initialize Structure
    Object::INI(Drawer)
    
    ; Init Members
    *Me\type = Object3D::#Drawer
    *Me\name = name
    *Me\wireframe_r = Random(255)/255
    *Me\wireframe_g = Random(255)/255
    *Me\wireframe_b = Random(255)/255
    *Me\geom = DrawerGeometry::New(*Me)
    
    Object3D::OBJECT3DATTR()
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    
    
    ; Return Initialized Object
    ProcedureReturn *Me 
    
  EndProcedure

  ; ---[ Add Point Item ]------------------------------------------------------
  Procedure AddPoint(*Me.Drawer_t, *position.Math::v3f32)
    Protected *point.Point_t = AllocateMemory(SizeOf(Point_t))
    *point\type = #ITEM_POINT
    *point\positions = CArray::newCArrayV3F32()
    *point\colors = CArray::newCArrayC4F32()
    SetColor(*point, Color::BLACK)
    CArray::SetCount(*point\positions, 1)
    CArray::SetCount(*point\colors, 1)
    If *position : CArray::SetValue(*point\positions, 0, *position) : EndIf
    AddElement(*Me\items())
    *Me\items() = *point
    *Me\dirty = #True
    
    ProcedureReturn *point
  EndProcedure
  
  ; ---[ Add Points Item ]------------------------------------------------------
  Procedure AddPoints(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
    Protected *point.Point_t = AllocateMemory(SizeOf(Point_t))
    *point\type = #ITEM_POINT
    If CArray::GetCount(*positions)
      *point\positions = CArray::newCArrayV3F32()
      *point\colors = CArray::newCArrayC4F32()
      CArray::Copy(*point\positions, *positions)
      CArray::SetCount(*point\colors, CArray::GetCount(*point\positions))
    EndIf
    
    SetColor(*point, Color::BLACK)
    AddElement(*Me\items())
    *Me\items() = *point
    *Me\dirty = #True
    ProcedureReturn *point
  EndProcedure
  
  ; ---[ Add Colored Points Item ]------------------------------------------------------
  Procedure AddColoredPoints(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
    Protected *point.Point_t = AllocateMemory(SizeOf(Point_t))
    *point\type = #ITEM_POINT
    If CArray::GetCount(*positions)
      *point\positions = CArray::newCArrayV3F32()
      *point\colors = CArray::newCArrayC4F32()
      CArray::Copy(*point\positions, *positions)
      CArray::Copy(*point\colors, *colors)
    EndIf
    AddElement(*Me\items())
    *Me\items() = *point
    *Me\dirty = #True
    ProcedureReturn *point
  EndProcedure
  
  
  ; ---[ Add Line Item ]-------------------------------------------------------
  Procedure AddLine(*Me.Drawer_t, *start.Math::v3f32, *end.Math::v3f32)
    Protected *line.Line_t = AllocateMemory(SizeOf(Line_t))
    *line\type = #ITEM_LINE
    *line\positions = CArray::newCArrayV3F32()
    *line\colors = CArray::newCArrayC4F32()
    CArray::SetCount(*line\positions, 2)
    CArray::SetValue(*line\positions, 0, *start)
    CArray::SetValue(*line\positions, 1, *end)
    CArray::SetCount(*line\colors, CArray::GetCount(*line\positions))
    SetColor(*line, Color::BLACK)
    AddElement(*Me\items())
    *Me\items() = *line
    *Me\dirty = #True
    ProcedureReturn *line
  EndProcedure
  
  ; ---[ Add Lines Item ]-------------------------------------------------------
  Procedure AddLines(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
    Protected *line.Line_t = AllocateMemory(SizeOf(Line_t))
    *line\type = #ITEM_LINE
    If CArray::GetCount(*positions)
      *line\positions = CArray::newCArrayV3F32()
      *line\colors = CArray::newCArrayC4F32()
      CArray::Copy(*line\positions, *positions)
      CArray::SetCount(*line\colors, CArray::GetCount(*line\positions))
    EndIf
    SetColor(*line, Color::BLACK)
    AddElement(*Me\items())
    *Me\items() = *line
    *Me\dirty = #True
    ProcedureReturn *line
  EndProcedure
  
  ; ---[ Add Lines Item ]-------------------------------------------------------
  Procedure AddLines2(*Me.Drawer_t, *start.CArray::CArrayV3F32, *end.CARray::CArrayV3F32)
    Protected *line.Line_t = AllocateMemory(SizeOf(Line_t))
    *line\type = #ITEM_LINE
    Define nbp = CArray::GetCount(*start)
    If nbp And nbp = CArray::GetCount(*end)
        *line\positions = CArray::newCArrayV3F32()
        *line\colors = CArray::newCArrayC4F32()
        CArray::SetCount(*line\positions, nbp*2)
        CArray::SetCount(*line\colors, nbp*2)
        Define i
        For i=0 To nbp-1
          CArray::SetValue(*line\positions, i*2, CArray::GetValue(*start,i))
          CArray::SetValue(*line\positions, i*2+1, CArray::GetValue(*end,i))
        Next
    EndIf
    SetColor(*line, Color::BLACK)
    AddElement(*Me\items())
    *Me\items() = *line
    *Me\dirty = #True
    ProcedureReturn *line
  EndProcedure
  
  ; ---[ Add Colored Lines Item ]-----------------------------------------------
  Procedure AddColoredLines(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
    Protected *line.Line_t = AllocateMemory(SizeOf(Line_t))
    *line\type = #ITEM_LINE
    If CArray::GetCount(*positions)
      *line\positions = CArray::newCArrayV3F32()
      *line\colors = CArray::newCArrayC4F32()
      CArray::Copy(*line\positions, *positions)
      CArray::Copy(*line\colors, *colors)
    EndIf
    AddElement(*Me\items())
    *Me\items() = *line
    *Me\dirty = #True
    ProcedureReturn *line
  EndProcedure
  
  ; ---[ Add Strip Item ]------------------------------------------------------
  Procedure AddStrip(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *indices.CArray::CArrayLong=#Null)
    Protected *strip.Strip_t = AllocateMemory(SizeOf(Strip_t))
    *strip\type = #ITEM_STRIP
    If CArray::GetCount(*positions)
      *strip\positions = CArray::newCArrayV3F32()
      *strip\colors = CArray::newCArrayC4F32()
      *strip\indices = CArray::newCArrayLong()
      CArray::Copy(*strip\positions, *positions)
      CArray::SetCount(*strip\colors, CArray::GetCount(*strip\positions))
      If Not *indices = #Null
        CArray::Copy(*strip\indices, *indices)
      Else
        CArray::AppendL(*strip\indices, CArray::GetCount(*strip\positions))
      EndIf
    EndIf
    AddElement(*Me\items())
    *Me\items() = *strip
    *Me\dirty = #True
    ProcedureReturn *strip
  EndProcedure
  
  ; ---[ Add Loop Item ]-------------------------------------------------------
  Procedure AddLoop(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *indices.CArray::CArrayLong=#Null)
    Protected *loop.Loop_t = AllocateMemory(SizeOf(Loop_t))
    *loop\type = #ITEM_LOOP
    If CArray::GetCount(*positions)
      *loop\positions = CArray::newCArrayV3F32()
      *loop\colors = CArray::newCArrayC4F32()
      *loop\indices = CArray::newCArrayLong()
      CArray::Copy(*loop\positions, *positions)
      CArray::SetCount(*loop\colors, CArray::GetCount(*loop\positions))
      If Not *indices = #Null
        CArray::Copy(*loop\indices, *indices)
      Else
        CArray::AppendL(*loop\indices, CArray::GetCount(*loop\positions))
      EndIf
    EndIf
    AddElement(*Me\items())
    *Me\items() = *loop
    *Me\dirty = #True
    ProcedureReturn *loop
  EndProcedure
  
  ; ---[ Add Box Item ]--------------------------------------------------------
  Procedure AddBox(*Me.Drawer_t, *m.Math::m4f32)
    Protected *box.Box_t = AllocateMemory(SizeOf(Box_t))
    *box\type = #ITEM_BOX
    *box\positions = CArray::newCArrayV3F32()
    *box\colors = CArray::newCArrayC4F32()
    *box\wireframe = #True
    Matrix4::SetFromOther(*box\m, *m)
    CArray::SetCount(*box\positions, 8)
    CArray::SetCount(*box\colors, 8)
    CopyMemory(Shape::?shape_cube_positions, CArray::GetPtr(*box\positions, 0), 8 * CArray::GetItemSize(*box\positions))
    
    ; Transform vertex positions
    Protected i
    Protected *p.Math::v3f32
    For i=0 To 7
      *p = CArray::GetValue(*box\positions, i)
      Vector3::MulByMatrix4InPlace(*p,*box\m)
    Next
    AddElement(*Me\items())
    *Me\items() = *box
    *Me\dirty = #True
    
    ProcedureReturn *box
  EndProcedure
  
  ; ---[ Add Sphere Item ]-----------------------------------------------------
  Procedure AddSphere(*Me.Drawer_t, *m.Math::m4f32)
    Protected *sphere.Sphere_t = AllocateMemory(SizeOf(Sphere_t))
    *sphere\type = #ITEM_SPHERE
    *sphere\positions = CArray::newCArrayV3F32()
    *sphere\colors = CArray::newCArrayC4F32()
    Matrix4::SetFromOther(*sphere\m, *m)
    CArray::SetCount(*sphere\positions, Shape::#SPHERE_NUM_VERTICES)
    CArray::SetCount(*sphere\colors, Shape::#SPHERE_NUM_VERTICES)
    CopyMemory(Shape::?shape_sphere_positions, CArray::GetPtr(*sphere\positions, 0), Shape::#SPHERE_NUM_VERTICES * CArray::GetItemSize(*sphere\positions))
    
;     ; Transform vertex positions
;     Protected i
;     Protected *p.Math::v3f32
;     For i=0 To Shape::#SPHERE_NUM_VERTICES-1
;       *p = CArray::GetValue(*sphere\positions, i)
;       Vector3::MulByMatrix4InPlace(*p,*sphere\m)
;     Next
    AddElement(*Me\items())
    *Me\items() = *sphere
    *Me\dirty = #True
    ProcedureReturn *sphere
  EndProcedure
  
  ; ---[ Add Matrix Item ]-----------------------------------------------------
  Procedure AddMatrix(*Me.Drawer_t, *m.Math::m4f32)
    Protected *matrix.Matrix_t = AllocateMemory(SizeOf(Matrix_t))
    *matrix\type = #ITEM_MATRIX
    *matrix\positions = CArray::newCArrayV3F32()
    Matrix4::SetFromOther(*matrix\m, *m)
    CArray::SetCount(*matrix\positions, Shape::#AXIS_NUM_VERTICES)
    CopyMemory(Shape::?shape_axis_positions, CArray::GetPtr(*matrix\positions, 0), Shape::#AXIS_NUM_VERTICES * CArray::GetItemSize(*matrix\positions))
    
    AddElement(*Me\items())
    *Me\items() = *matrix
    *Me\dirty = #True
    ProcedureReturn *matrix
  EndProcedure
  
  ; ---[ Add Triangle Item ]------------------------------------------------------
  Procedure AddTriangle(*Me.Drawer_t, *positions.CArray::CArrayV3F32)
    Protected *triangle.Triangle_t = AllocateMemory(SizeOf(Triangle_t))
    *triangle\type = #ITEM_TRIANGLE
    *triangle\positions = CArray::newCArrayV3F32()
    *triangle\colors = CArray::newCArrayC4F32()
    CArray::Copy(*triangle\positions, *positions)
    CArray::SetCount(*triangle\colors, CArray::GetCount(*triangle\positions))
    SetColor(*triangle, Color::BLACK)
    AddElement(*Me\items())
    *Me\items() = *triangle
    *Me\dirty = #True
    ProcedureReturn *triangle
  EndProcedure
  
  ; ---[ Add Colored Triangle Item ]------------------------------------------------------
  Procedure AddColoredTriangle(*Me.Drawer_t, *positions.CArray::CArrayV3F32, *colors.CArray::CArrayC4F32)
    Protected *triangle.Triangle_t = AllocateMemory(SizeOf(Triangle_t))
    *triangle\type = #ITEM_TRIANGLE
    *triangle\positions = CArray::newCArrayV3F32()
    *triangle\colors = CArray::newCArrayC4F32()
    CArray::Copy(*triangle\positions, *positions)
    CArray::Copy(*triangle\colors, *colors)
    AddElement(*Me\items())
    *Me\items() = *triangle
    *Me\dirty = #True
    ProcedureReturn *triangle
  EndProcedure
  
  ; ---[ Add Text Item ]------------------------------------------------------
  Procedure AddText(*Me.Drawer_t, *position.Math::v3f32, text.s, size.f)
    Protected *text.Text_t = AllocateMemory(SizeOf(Text_t))
    *text\type = #ITEM_TEXT
    *text\positions = CArray::newCArrayV3F32()
    *text\colors = CArray::newCArrayC4F32()
    *text\text = text
    *text\size = size
    SetColor(*text, Color::BLACK)
    CArray::SetCount(*text\positions, 1)
    CArray::SetCount(*text\colors, 1)
    If *position : CArray::SetValue(*text\positions, 0, *position) : EndIf
    AddElement(*Me\items())
    *Me\items() = *text
    *Me\dirty = #True
    
    ProcedureReturn *text
  EndProcedure
  
  ; ---[ Reflection ]----------------------------------------------------------
  Class::DEF( Drawer )
  
EndModule

;==============================================================================
; EOF
;==============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 859
; FirstLine = 837
; Folding = ---------
; EnableXP