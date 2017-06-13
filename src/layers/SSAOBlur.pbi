; ============================================================================
;  OpenGL SSAO Blur Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "SSAO.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
DeclareModule LayerSSAOBlur
  UseModule OpenGL
  UseModule Math
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure LayerSSAOBlur_t Extends Layer::Layer_t
    *ssao.Framebuffer::Framebuffer_t
    
    *kernel.Carray::CArrayV3F32
    *noise.CArray::CArrayV3F32
    
    ; Uniforms SSAO
    u_texture_size.i
   
  
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerSSAOBlur Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*ssao.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerSSAOBlur_t)
  Declare Setup(*layer.LayerSSAOBlur_t)
  Declare Update(*layer.LayerSSAOBlur_t)
  Declare Clean(*layer.LayerSSAOBlur_t)
  Declare Pick(*layer.LayerSSAOBlur_t)
  Declare Draw(*layer.LayerSSAOBlur_t,*ctx.GLContext::GLContext_t)
  
  DataSection 
    LayerSSAOBlurVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL SSAOBlur Layer Module Declaration
; ============================================================================
Module LayerSSAOBlur
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;------------------------------------------------------------------

  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerSSAOBlur_t)
    Protected *ctx.GLContext::GLContext_t = *layer\context
    Protected *s_ssao_blur.Program::Program_t = *ctx\shaders("ssao_blur")
    *layer\u_texture_size = glGetUniformLocation(*s_ssao_blur\pgm,"texture_size")
    ;*layer\u_ssao_map = glGetUniformLocation(*s_ssao_blur\pgm,"normal_map")
    
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerSSAOBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerSSAOBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerSSAOBlur_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerSSAOBlur_t,*ctx.GLContext::GLContext_t)
    Protected *s_ssao_blur.Program::Program_t = *ctx\shaders("ssao_blur")
    shader = *s_ssao_blur\pgm
    glUseProgram(shader)
    glViewport(0,0,*layer\width,*layer\height)
    Framebuffer::BindInput(*layer\ssao)
    Framebuffer::BindOutput(*layer\buffer)
    glUniform2f(*layer\u_texture_size,*layer\width,*layer\height)
    glClear(#GL_COLOR_BUFFER_BIT);
    ScreenQuad::Draw(*layer\quad)
    
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\buffer\frame_id);
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    glBlitFramebuffer(0, 0, *layer\width,*layer\height,0, 0, *ctx\width, *ctx\height,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
    
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerSSAOBlur_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*ssao.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerSSAOBlur_t = AllocateMemory(SizeOf(LayerSSAOBlur_t))
    InitializeStructure(*Me,LayerSSAOBlur_t)
    Object::INI( LayerSSAOBlur )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
 

    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\ssao = *ssao

    *Me\pov = *camera
    
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\buffer = Framebuffer::New("SSAOBlur",width,height)
    Framebuffer::AttachTexture(*Me\buffer,"Blur",#GL_RED,#GL_NEAREST,#GL_CLAMP)
   ;Framebuffer::AttachTexture(*Me\buffer,"AO",#GL_RGB,#GL_NEAREST,#GL_CLAMP)
    Layer::AddScreenSpaceQuad(*Me,*ctx)

    Setup(*Me)
    
  ;   Protected img = LoadImage(#PB_Any,RAAFAL_BASE_PATH+"/rsc/ico/pointcloud.png")
  ;   If img : *Me\image = GL_LoadImage(img,#True) : EndIf
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerSSAOBlur)
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 63
; FirstLine = 47
; Folding = --
; EnableUnicode
; EnableXP