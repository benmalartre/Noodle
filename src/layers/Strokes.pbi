; ============================================================================
;  Strokes Layer Module
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "../objects/Stroke.pbi"

DeclareModule LayerStroke
  
   UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerStroke_t Extends Layer::Layer_t
    vao.i
    vbo.i
    linewidth.f
    *strokes.CArray::CArrayPtr
    *current.Geometry::Stroke_t
    nbp.i
    needUpdate.b
    radius.f
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerStroke Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*Me.LayerStroke_t)
  Declare Setup(*Me.LayerStroke_t,*ctx.GLContext::GLContext_t)
  Declare Update(*Me.LayerStroke_t)
  Declare Clean(*Me.LayerStroke_t)
  Declare Draw(*Me.LayerStroke_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  
  Declare AddPoint(*Me.LayerStroke_t,x.i,y.i)
  Declare StartStroke(*Me.LayerStroke_t, x.i, y.i)
  Declare EndStroke(*Me.LayerStroke_t, x.i, y.i)
  
  DataSection
    LayerStrokeVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerStroke
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  
  Procedure ComputeNumPoints(*Me.LayerStroke_t)
    Define i
    Define nbp = 0
    Define *stroke.Geometry::Stroke_t
    For i=0 To CArray::GetCount(*Me\strokes)-1
      *stroke = CArray::GetValuePtr(*Me\strokes, i)
      nbp + CArray::GetCount(*stroke\datas)
    Next
    ProcedureReturn nbp
  EndProcedure
  
  ;---------------------------------------------------
  ; Update
  ;---------------------------------------------------
  Procedure Update(*Me.LayerStroke_t)
    glBindFramebuffer(#GL_FRAMEBUFFER, *Me\framebuffer\frame_id)
    Protected *stroke.Geometry::Stroke_t
    Protected *pnt.Math::v3f32
    Protected f.GLfloat
    Protected i
    
    *Me\nbp = ComputeNumPoints(*Me)
    Protected size_t = SizeOf(v4f32) * *Me\nbp
    If size_t 
      Object3D::BindVao(@*Me\vao)
      Object3D::BindVBO(@*Me\vbo)
      Define offset = 0
      Define size_s
       ; Push Buffer to GPU
      glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_DYNAMIC_DRAW)
      For i=0 To CArray::GetCount(*Me\strokes)-1
        *stroke = CArray::GetValuePtr(*Me\strokes, i)
        size_s = CArray::GetCount(*stroke\datas) * SizeOf(v4f32)
        glBufferSubData(#GL_ARRAY_BUFFER, offset, size_s, CArray::GetPtr(*stroke\datas, 0))
        offset + size_s
      Next
      GLCheckError("Push Buffer Data to GPU")
    EndIf
    glBindVertexArray(0)
    glBindFramebuffer(#GL_FRAMEBUFFER, 0)
  EndProcedure
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*Me.LayerStroke_t,*ctx.GLContext::GLContext_t)
    GLCheckError("setup strokes layer")
    Object3D::BindVao(@*Me\vao)
    Object3D::BindVBO(@*Me\vbo)
    
    ; load shader
    Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
    glUseProgram(shader)
    GLCheckError("Use Program Stroke 2D From Context")
    
    ; Attribute Packed position xy, radius , color
    glEnableVertexAttribArray(0)
    GLCheckError("enable vertex attrib array 0")
    glVertexAttribPointer(0, 4, #GL_FLOAT, #GL_FALSE, 0, 0)
    GLCheckError("set vertex attrib ptr")
    
    Update(*Me)
    
    glBindVertexArray(0)
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Clean
  ;---------------------------------------------------
  Procedure Clean(*Me.LayerStroke_t)
   
  EndProcedure
  ;---------------------------------------------------
  ; Pick
  ;---------------------------------------------------
  Procedure Pick(*Me.LayerStroke_t)
   
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*Me.LayerStroke_t,*ctx.GLContext::GLContext_t)
    
    Framebuffer::BindOutput(*Me\framebuffer)
    glViewport(0,0,*Me\framebuffer\width,*Me\framebuffer\height)

    glClearColor(0.75,0.75,0.75,0);
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glDisable(#GL_DEPTH_TEST)
   
    Protected *stroke.Geometry::Stroke_t
    If *Me\nbp
      Protected i
      Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
      glUseProgram(shader)    
      glEnable(#GL_BLEND)
      Object3D::BindVao(@*Me\vao)
      Object3D::BindVBO(@*Me\vbo)
      
      If *Me\needUpdate : Update(*Me) : *Me\needUpdate = #False : EndIf
      
      Protected start.GLint = 0
      Protected count.GLsizei = 0
  
      For i=0 To CArray::GetCount(*Me\strokes)-1
        *stroke = CArray::GetValuePtr(*Me\strokes, i)
        
        count = CArray::GetCount(*stroke\datas)
        If count
          glDrawArrays(#GL_LINE_STRIP_ADJACENCY, start, count)
        EndIf
        start + count
      Next
      glBindVertexArray(0)
    EndIf
    
    Framebuffer::Unbind(*Me\framebuffer)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Point
  ;---------------------------------------------------
  Procedure AddPoint(*Me.LayerStroke_t,x.i,y.i)
    Protected w = *Me\framebuffer\width
    Protected h = *Me\framebuffer\height
  
    If *Me\current
      Protected pos.v3f32
      Protected color.c4f32
      Protected radius.f = 0.02
      Vector3::Set(pos, (2*x/w)-1, (2*(1-y/h))-1, 0)
      Color::Randomize(color)
      Stroke::AddPoint(*Me\current, pos, *Me\color, *Me\radius)
      
      *Me\nbp+1
    EndIf
    
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure StartStroke(*Me.LayerStroke_t, x.i, y.i)
   
    Protected *stroke.Geometry::Stroke_t = Stroke::New()

    CArray::AppendPtr(*Me\strokes, *stroke)
    *Me\current = *stroke
    *Me\color\r = Random_0_1()
    *Me\color\g = Random_0_1()
    *Me\color\b = Random_0_1()
    AddPoint(*Me, x, y)

  EndProcedure
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure EndStroke(*Me.LayerStroke_t, x.i, y.i)
    If *Me\current
      AddPoint(*Me, x, y)
      Stroke::Resample(*Me\current, 0.04)
      
      *Me\needUpdate = #True
    EndIf
    
    *Me\current = #Null
    
  EndProcedure
  
  ;---------------------------------------------------
  ; DESTRUCTOR
  ;---------------------------------------------------
  Procedure Delete(*Me.LayerStroke_t)
    glDeleteBuffers(1,*Me\vbo)
    glDeleteVertexArrays(1,*Me\vao)
    FreeStructure(LayerStroke)
  EndProcedure
  
  ;---------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
    Protected *Me.LayerStroke_t = AllocateStructure(LayerStroke_t)
    Object::INI( LayerStroke )
    Color::Set(*Me\color,0.5,0.5,0.5,0.0)
    *Me\name = "LayerStroke2D"
    *Me\context = *ctx
    *Me\shader = *ctx\shaders("stroke2D")
    *Me\framebuffer = Framebuffer::New("Strokes",width,height)
    GLCheckError("constructor strokes")
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
    GLCheckError("attach texture strokes")
    Framebuffer::AttachRender( *Me\framebuffer,"Depth",#GL_DEPTH_COMPONENT)
    GLCheckError("attach re der strokes")
    
    *Me\pov = *pov
    *Me\strokes = CArray::New(Types::#TYPE_PTR)
    *Me\radius = 0.01
    Setup(*Me,*ctx)
    GLCheckError("setup strokes")
    ProcedureReturn *Me
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  REFLECTION
  ; ----------------------------------------------------------------------------
  Class::DEF( LayerStroke )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 255
; FirstLine = 201
; Folding = ---
; EnableXP