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
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerStroke Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerStroke_t)
  Declare Setup(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
  Declare Update(*layer.LayerStroke_t)
  Declare Clean(*layer.LayerStroke_t)
  Declare Draw(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  
  Declare AddPoint(*layer.LayerStroke_t,x.i,y.i)
  Declare StartStroke(*layer.LayerStroke_t)
  Declare EndStroke(*layer.LayerStroke_t)
  
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
  
  Procedure ComputeNumPoints(*layer.LayerStroke_t)
    Define i
    Define nbp = 0
    Define *stroke.Geometry::Stroke_t
    For i=0 To CArray::GetCount(*layer\strokes)-1
      *stroke = CArray::GetValuePtr(*layer\strokes, i)
      nbp + CArray::GetCount(*stroke\datas)
    Next
    ProcedureReturn nbp
  EndProcedure
  
  ;---------------------------------------------------
  ; Update
  ;---------------------------------------------------
  Procedure Update(*layer.LayerStroke_t)
    glBindFramebuffer(#GL_FRAMEBUFFER, *layer\framebuffer\frame_id)
    Protected *stroke.Geometry::Stroke_t
    Protected *pnt.Math::v3f32
    Protected f.GLfloat
    Protected i
    
    *layer\nbp = ComputeNumPoints(*layer)
    Protected size_t = SizeOf(v4f32) * *layer\nbp
    If size_t 
      Define offset = 0
      Define size_s
       ; Push Buffer to GPU
      glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_DYNAMIC_DRAW)
      For i=0 To CArray::GetCount(*layer\strokes)-1
        *stroke = CArray::GetValuePtr(*layer\strokes, i)
        size_s = CArray::GetCount(*stroke\datas) * SizeOf(v4f32)
        glBufferSubData(#GL_ARRAY_BUFFER, offset, size_s, CArray::GetPtr(*stroke\datas, 0))
        offset + size_s
      Next
      GLCheckError("Push Buffer Data to GPU")
    EndIf
    glBindFramebuffer(#GL_FRAMEBUFFER, 0)
  EndProcedure
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
    GLCheckError("setup strokes layer")
    ; Create or ReUse Vertex Array Object
    If Not *layer\vao
      glGenVertexArrays(1,@*layer\vao)
    EndIf
    glBindVertexArray(*layer\vao)
    GLCheckError("strokes vao")
    
    ; Create or ReUse Vertex Buffer Object
    If Not *layer\vbo
      glGenBuffers(1,@*layer\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*layer\vbo)
    GLCheckError("strokes vbo")
    
    ; load shader
    Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
    glUseProgram(shader)
    GLCheckError("Use Program Stroke 2D From Context")
    
    ; Attribute Packed position xy, radius , color
    glEnableVertexAttribArray(0)
    GLCheckError("enable vertex attrib array 0")
    glVertexAttribPointer(0, 4, #GL_FLOAT, #GL_FALSE, 0, 0)
    GLCheckError("set vertex attrib ptr")
    
    Update(*layer)
    
    glBindVertexArray(0)
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Clean
  ;---------------------------------------------------
  Procedure Clean(*layer.LayerStroke_t)
   
  EndProcedure
  ;---------------------------------------------------
  ; Pick
  ;---------------------------------------------------
  Procedure Pick(*layer.LayerStroke_t)
   
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
    Framebuffer::BindOutput(*layer\framebuffer)
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)

    glClearColor(*layer\color\r,*layer\color\g,*layer\color\b,*layer\color\a);
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glDisable(#GL_DEPTH_TEST)
   
    Protected *stroke.Geometry::Stroke_t
    If *layer\nbp
      Protected i
      Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
      glUseProgram(shader)    
      glEnable(#GL_BLEND)
      glBindVertexArray(*layer\vao)
      
      Protected start.GLint = 0
      Protected count.GLsizei = 0
  
      For i=0 To CArray::GetCount(*layer\strokes)-1
        *stroke = CArray::GetValuePtr(*layer\strokes, i)
        
        count = CArray::GetCount(*stroke\datas)
        If count
          glDrawArrays(#GL_LINE_STRIP_ADJACENCY, start, count)
        EndIf
        start + count
      Next
      glBindVertexArray(0)
    EndIf
    
    Framebuffer::Unbind(*layer\framebuffer)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Point
  ;---------------------------------------------------
  Procedure AddPoint(*layer.LayerStroke_t,x.i,y.i)
    Protected w = *layer\framebuffer\width
    Protected h = *layer\framebuffer\height
  
    If *layer\current
      Protected pos.v3f32
      Protected color.c4f32
      Protected radius.f = 0.02
      Vector3::Set(pos, (2*x/w)-1, (2*(1-y/h))-1, 0)
      Color::Randomize(color)
      Stroke::AddPoint(*layer\current, pos, color, radius)
      
      *layer\nbp+1
    EndIf
    
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure StartStroke(*layer.LayerStroke_t)
   
    Protected *stroke.Geometry::Stroke_t = Stroke::New()

    CArray::AppendPtr(*layer\strokes, *stroke)
    *layer\current = *stroke

  EndProcedure
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure EndStroke(*layer.LayerStroke_t)
    If *layer\current
      Stroke::Resample(*layer\current, 0.1)
     ;CLine_Simplify(*layer\line,0.1)
     ;CLine_Relax(*layer\line,10)
      
      Update(*layer)
    EndIf
    
    *layer\current = #Null
    
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
    *Me\strokes = CArray::New(CArray::#ARRAY_PTR)
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
; CursorPosition = 155
; FirstLine = 141
; Folding = ---
; EnableXP