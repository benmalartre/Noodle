; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "ShadowMap.pbi"

DeclareModule LayerShadowDefered
  UseModule OpenGL
  UseModule Math
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure LayerShadowDefered_t Extends Layer::Layer_t
    *gbuffer.Framebuffer::Framebuffer_t
    *shadowmap.Framebuffer::Framebuffer_t
  
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerShadowDefered Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerShadowDefered_t)
  Declare Setup(*layer.LayerShadowDefered_t)
  Declare Update(*layer.LayerShadowDefered_t)
  Declare Clean(*layer.LayerShadowDefered_t)
  Declare Pick(*layer.LayerShadowDefered_t)
  Declare Draw(*layer.LayerShadowDefered_t,*ctx.GLContext::GLContext_t)
  
  DataSection 
    LayerShadowDeferedVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
Module LayerShadowDefered
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;------------------------------------------------------------------
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerShadowDefered_t)

    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerShadowDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerShadowDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerShadowDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerShadowDefered_t,*ctx.GLContext::GLContext_t)
    
    
    Debug "SHADOW DEFERED DRAW CALLED................................."
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    If Not *light : ProcedureReturn : EndIf
    Light::Update(*light)
    
  
    
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
      shader = *ctx\shaders("shadowdefered")\pgm
      glUseProgram(shader)
      Framebuffer::BindInput(*layer\gbuffer)
      Framebuffer::BindInput(*layer\shadowmap,ArraySize(*layer\gbuffer\tbos()))
      Framebuffer::BindOutput(*layer\framebuffer)
      glClearColor(0.5,0.5,0.5,0.5)
      glClear(#GL_COLOR_BUFFER_BIT);
      
      glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
      glUniform1i(glGetUniformLocation(shader,"position_map"),0)
      glUniform1i(glGetUniformLocation(shader,"normal_map"),1)
      glUniform1i(glGetUniformLocation(shader,"color_map"),2)
      glUniform1i(glGetUniformLocation(shader,"shadow_map"),3)

      Protected bias.m4f32
      Matrix4::Set(bias,
                   0.5,0.0,0.0,0.0,
                   0.0,0.5,0.0,0.0,
                   0.0,0.0,0.5,0.0,
                   0.5,0.5,0.5,1.0)
      
      Protected view_rotation_matrix.m4f32
      Protected *camera.Camera::Camera_t = *layer\pov
      Protected *view.Math::m4f32 = *camera\view
      Matrix4::Set(view_rotation_matrix,
                   *view\v[0],*view\v[1],*view\v[2],*view\v[3],
                   *view\v[4],*view\v[5],*view\v[6],*view\v[7],
                   *view\v[8],*view\v[9],*view\v[10],*view\v[11],
                   0,0,0,1)
     
      glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,Layer::GetProjectionMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*light\view)
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*light\projection)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view_rotation_matrix"),1,#GL_FALSE,view_rotation_matrix)
      glUniform3f(glGetUniformLocation(shader,"light_position"),*light\pos\x,*light\pos\y,*light\pos\z)
      glUniform3f(glGetUniformLocation(shader,"camera_position"),0,0,0)
      
      glUniform1f(glGetUniformLocation(shader,"x_pixel_offset"),1/*layer\shadowmap\width)
      glUniform1f(glGetUniformLocation(shader,"y_pixel_offset"),1/*layer\shadowmap\height)

      
;       Define i = 0
;       ForEach *lights()
;         Light::PassToShader(*lights(),shader,i)
;         i+1
;       Next

      *layer\quad\pgm = *ctx\shaders("shadowdefered")
      ScreenQuad::Draw(*layer\quad)
      Protected vwidth = *ctx\width
      Protected vheight = *ctx\height
      Protected ratio.f = *layer\framebuffer\width/*layer\framebuffer\height
      
      Framebuffer::BlitTo(*layer\framebuffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
      GLCheckError("ShadowDefered Done")
      
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerShadowDefered_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerShadowDefered_t = AllocateMemory(SizeOf(LayerShadowDefered_t))
    Object::INI( LayerShadowDefered )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
    *Me\context = *ctx
    *Me\gbuffer = *gbuffer
    *Me\shadowmap = *shadowmap
    *Me\pov = *camera
    *Me\framebuffer = Framebuffer::New("ShadowDefered",width,height)
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
;     Framebuffer::AttachRender(*Me\buffer,"Depth",#GL_DEPTH)
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\quad = ScreenQuad::New()
    ScreenQuad::Setup(*Me\quad,*ctx\shaders("shadowdefered"))
    
    Layer::AddScreenSpaceQuad(*Me,*ctx)

    Setup(*Me)

    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerShadowDefered)
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 2
; Folding = --
; EnableXP