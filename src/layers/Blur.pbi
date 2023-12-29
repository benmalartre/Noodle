; ============================================================================
;  Blur Layer Module
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
DeclareModule LayerBlur
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerBlur_t Extends Layer::Layer_t
    *input.Framebuffer::Framebuffer_t
  ;   image.GLuint
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerBlur Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerBlur_t)
  Declare Setup(*layer.LayerBlur_t)
  Declare Update(*layer.LayerBlur_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerBlur_t)
  Declare Draw(*layer.LayerBlur_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*input.Framebuffer::Framebuffer_t,*pov.Object3D::Object3D_t)
  
  DataSection
    LayerBlurVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerBlur
  UseModule OpenGL
  UseModule OpenGLExt
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerBlur_t,*view.m4f32,*proj.m4f32)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerBlur_t,*ctx.GLContext::GLContext_t)
    Debug " --------------------------- Draw Blur Layer -----------------------------------"
    
    ; Blur SSAO texture To remove noise
    Protected shader = *ctx\shaders("ssao_blur")\pgm
    glUseProgram(shader)
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
    Framebuffer::BindInput(*layer\input)
    Framebuffer::BindOutput(*layer\framebuffer)
    glClear(#GL_COLOR_BUFFER_BIT);
    ScreenQuad::Draw(*layer\quad)
    
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\framebuffer);
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    glBlitFramebuffer(0, 0, *layer\framebuffer\width,*layer\framebuffer\height,0, 0, WIDTH, HEIGHT,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
    
    Framebuffer::Unbind(*layer\framebuffer)
    
;     Layer::WriteImage(*layer,"D:\Projects\RnD\PureBasic\Noodle\pictures\Test.png",#GL_RGBA)
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerBlur_t)
    FreeMemory(*layer)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*input.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerBlur_t = AllocateMemory(SizeOf(LayerBlur_t))
    Object::INI( LayerBlur )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
    *Me\name = "LayerBlur"
    *Me\input = *input
    *Me\context = *ctx
    *Me\pov = *camera
    *Me\framebuffer = Framebuffer::New("Blur",width,height)
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
    
    *Me\mask = #GL_COLOR_BUFFER_BIT
  
    Layer::AddScreenSpaceQuad(*Me,*ctx)
    
    ProcedureReturn *Me
  EndProcedure
  
  
  Class::DEF(LayerBlur)
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 112
; FirstLine = 72
; Folding = --
; EnableXP
; EnableUnicode