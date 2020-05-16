; ============================================================================
;  Toon Layer Module
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
DeclareModule LayerToon
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerToon_t Extends Layer::Layer_t
    *gbuffer.Framebuffer::Framebuffer_t
  ;   image.GLuint
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerToon Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerToon_t)
  Declare Setup(*layer.LayerToon_t)
  Declare Update(*layer.LayerToon_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerToon_t)
  Declare Draw(*layer.LayerToon_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*pov.Object3D::Object3D_t)
  
  DataSection
    LayerToonVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerToon
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;---------------------------------------------------
  ; Update
  ;---------------------------------------------------
  Procedure Update(*layer.LayerToon_t,*view.m4f32,*proj.m4f32)
;     Protected *stack.Stack::Stack_t = *layer\stack
;     Protected *tree.CStackItem
;     ForEach *stack\nodes()
;       Debug *stack\nodes()\class\name
;       *tree = *stack\nodes()
;       *tree\Update()
;     Next
  
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*layer.LayerToon_t)
  
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Clean
  ;---------------------------------------------------
  Procedure Clean(*layer.LayerToon_t)
  
    
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Pick
  ;-----------------------------------------------a----
  Procedure Pick(*layer.LayerToon_t)
  
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*layer.LayerToon_t,*ctx.GLContext::GLContext_t)

  
    glDisable(#GL_CULL_FACE)
    glFrontFace(#GL_CW)
   
    
    
    Protected *buffer.Framebuffer::Framebuffer_t = *layer\buffer
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)

    Framebuffer::BindInput(*layer\gbuffer)
    Framebuffer::BindOutput(*layer\buffer)
    glViewport(0,0,*layer\buffer\width,*layer\buffer\height)
    glClear(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT);

    Protected *shader.Program::Program_t = *ctx\shaders("toon")
    Protected shader.GLuint =  *shader\pgm
    glUseProgram(shader)
    glUniform1i(glGetUniformLocation(shader,"position_map"),0)
    glUniform1i(glGetUniformLocation(shader,"normal_map"),1)
    glUniform1i(glGetUniformLocation(shader,"color_map"),2)
    
    ;   Clear(*layer)
    ;-----------------------------------------------
    glClearColor(0.66,0.66,0.66,1.0)
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glCheckError("Clear")
  
    
    ;Draw Screen Quad
    ;-----------------------------------------------
    glUniform3f(glGetUniformLocation(shader,"lightPosition"),*light\pos\x,*light\pos\y,*light\pos\z)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))

    
    ScreenQuad::Draw(*ctx)
    
    Framebuffer::Unbind(*layer\buffer)
    Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_LINEAR)
  
    glDisable(#GL_BLEND)
  EndProcedure
  
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*layer.LayerToon_t)
    FreeMemory(*layer)
  EndProcedure
  
 
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*pov.Object3D::Object3D_t)
    Protected *Me.LayerToon_t = AllocateMemory(SizeOf(LayerToon_t))
    InitializeStructure(*Me,LayerToon_t)
    Object::INI(LayerToon)
    
    *Me\type = Object3D::#Layer
    *Me\name = "LayerToon"

    *Me\gbuffer = *gbuffer
    Color::Set(*Me\background_color,0.33,0.33,0.33,1.0)
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\pov = *pov
    *Me\buffer = Framebuffer::New("Default",width,height)
    Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
    Framebuffer::AttachRender( *Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
    
    *Me\quad = ScreenQuad::New();
    ScreenQuad::Setup(*Me\quad,*ctx\shaders("toon"))
  ;   Protected img = LoadImage(#PB_Any,"/home/benmalartre/RnD/IconMaker/icons/pen.png")
  ;   If img : *Me\image = GL_LoadImage(img,#True) : EndIf
      
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( LayerToon )
  
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 3
; Folding = --
; EnableXP