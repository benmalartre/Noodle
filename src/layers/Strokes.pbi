; ============================================================================
;  Strokes Layer Module
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
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
      
      ; Attribute Packed position xy, radius , color

    EndIf
      glEnableVertexAttribArray(0)
      glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
      GLCheckError("Enable Vertex Attr Pointer Datas")
  EndProcedure
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
    ; Create or ReUse Vertex Array Object
    If Not *layer\vao
      glGenVertexArrays(1,@*layer\vao)
    EndIf
    glBindVertexArray(*layer\vao)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *layer\vbo
      glGenBuffers(1,@*layer\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*layer\vbo)
    
    ; load shader
    Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
    glUseProgram(shader)
    GLCheckError("Use Program Stroke 2D From Context")
    
    Update(*layer)

    glBindVertexArray(#GL_NONE)  
    
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
    Framebuffer::BindOutput(*layer\datas\buffer)
    glViewport(0,0,*layer\datas\width,*layer\datas\height)

    glClearColor(*layer\background_color\r,*layer\background_color\g,*layer\background_color\b,*layer\background_color\a);
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glDisable(#GL_DEPTH_TEST)
   
    Protected *stroke.Geometry::Stroke_t
    If *layer\nbp
      Protected i
      Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
      glBindVertexArray(*layer\vao)
      GLCheckError("Bind Vertex Array")
      glUseProgram(shader)
      GLCheckError("Use Program")
    
      glPointSize(2)
      glLineWidth(12)
;       glEnable(#GL_POINT_SMOOTH)
      glEnable(#GL_BLEND)
      
  
      Protected offset = 0
      Protected f.f
  
      For i=0 To CArray::GetCount(*layer\strokes)-1
        *stroke = CArray::GetValuePtr(*layer\strokes, i)
        With *stroke
          glDrawArrays(#GL_LINE_STRIP_ADJACENCY, offset,\datas\itemCount)
;           glDrawArrays(#GL_POINTS, offset,\datas\itemCount)
          GLCheckError("Draw Array")
          offset+\datas\itemCount
        EndWith
      Next
      glBindVertexArray(#GL_NONE)
    EndIf
    
    Framebuffer::Unbind(*layer\datas\buffer)
    Framebuffer::BlitTo(*layer\datas\buffer, 0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
   
;      glDisable(#GL_POINT_SMOOTH)
     glDisable(#GL_BLEND)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Point
  ;---------------------------------------------------
  Procedure AddPoint(*layer.LayerStroke_t,x.i,y.i)
    Protected w = *layer\datas\width
    Protected h = *layer\datas\height
  
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
  Procedure Delete(*layer.LayerStroke_t)
    glDeleteBuffers(1,*layer\vbo)
    glDeleteVertexArrays(1,*layer\vao)
    ClearStructure(*layer,LayerStroke_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
    Protected *Me.LayerStroke_t = AllocateMemory(SizeOf(LayerStroke_t))
    InitializeStructure(*Me,LayerStroke_t)
    Object::INI( LayerStroke )
    Color::Set(*Me\background_color,0.5,0.5,0.5,0.0)
    *Me\name = "LayerStroke2D"
    *Me\datas\width = width
    *Me\datas\height = height
    *Me\context = *ctx
    *Me\shader = *ctx\shaders("stroke2D")
    *Me\datas\buffer = Framebuffer::New("Strokes",width,height)
    Framebuffer::AttachTexture(*Me\datas\buffer,"Color",#GL_RGBA,#GL_LINEAR)
    Framebuffer::AttachRender( *Me\datas\buffer,"Depth",#GL_DEPTH_COMPONENT)
    

    *Me\pov = *pov
    *Me\strokes = CArray::New(CArray::#ARRAY_PTR)
    Setup(*Me,*ctx)
    ProcedureReturn *Me
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  REFLECTION
  ; ----------------------------------------------------------------------------
  Class::DEF( LayerStroke )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 91
; FirstLine = 45
; Folding = ---
; EnableXP