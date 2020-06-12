; ============================================================================
;  OpenGL Defered CSM Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "ShadowMap.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
DeclareModule LayerShadowDeferedCSM
  UseModule OpenGL
  UseModule Math
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure LayerShadowDeferedCSM_t Extends Layer::Layer_t
    *gbuffer.Framebuffer::Framebuffer_t
    *shadowmaps.Framebuffer::Framebuffer_t
  
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerShadowDeferedCSM Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmaps.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerShadowDeferedCSM_t)
  Declare Setup(*layer.LayerShadowDeferedCSM_t)
  Declare Update(*layer.LayerShadowDeferedCSM_t)
  Declare Clean(*layer.LayerShadowDeferedCSM_t)
  Declare Pick(*layer.LayerShadowDeferedCSM_t)
  Declare Draw(*layer.LayerShadowDeferedCSM_t,*ctx.GLContext::GLContext_t)
  
  DataSection 
    LayerShadowDeferedCSMVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL Defered Shadow CSM Rendering Layer Module Declaration
; ============================================================================
Module LayerShadowDeferedCSM
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;------------------------------------------------------------------
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerShadowDeferedCSM_t)

    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerShadowDeferedCSM_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerShadowDeferedCSM_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerShadowDeferedCSM_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerShadowDeferedCSM_t,*ctx.GLContext::GLContext_t)
    
    
    
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    If Not *light : ProcedureReturn : EndIf
    Light::Update(*light)
    
  
    
    glViewport(0,0,*layer\width,*layer\height)
      shader = *ctx\shaders("shadowdeferedCSM")\pgm
      glUseProgram(shader)
      Framebuffer::BindInput(*layer\gbuffer)
      Framebuffer::BindInputByID(*layer\shadowmap,0,4)
      Framebuffer::BindOutput(*layer\buffer)
      glClearColor(0.5,0.5,0.5,0.5)
      glClear(#GL_COLOR_BUFFER_BIT);
      
      glViewport(0,0,*layer\buffer\width,*layer\buffer\height)
      glUniform1i(glGetUniformLocation(shader,"position_map"),0)
      glUniform1i(glGetUniformLocation(shader,"normal_map"),1)
      glUniform1i(glGetUniformLocation(shader,"color_map"),2)
      glUniform1i(glGetUniformLocation(shader,"shadowcoords_map"),3)
      glUniform1i(glGetUniformLocation(shader,"shadow_map"),4)
;       
; ;       uniform vec3 camera_position;
; ;       uniform mat4 light_view;
; ;       uniform mat4 light_proj;
; ;       uniform mat4 view;
; 
      
      Protected bias.m4f32
      Matrix4::Set(@bias,
                0.5,0.0,0.0,0.0,
                0.0,0.5,0.0,0.0,
                0.0,0.0,0.5,0.0,
                0.5,0.5,0.5,1.0)
      
      Protected view_rotation_matrix
      Protected *camera.Camera::Camera_t = *layer\pov
      Protected *view.Math::m4f32 = *camera\view
      Matrix4::Set(@view_rotation_matrix,
                   *view\v[0],*view\v[1],*view\v[2],*view\v[3],
                   *view\v[4],*view\v[5],*view\v[6],*view\v[7],
                   *view\v[8],*view\v[9],*view\v[10],*view\v[11],
                   0,0,0,1)
     
      glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,Layer::GetProjectionMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*light\view)
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*light\projection)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view_rotation_matrix"),1,#GL_FALSE,@view_rotation_matrix)
      glUniform3f(glGetUniformLocation(shader,"light_position"),*light\pos\x,*light\pos\y,*light\pos\z)
      
      glUniform1f(glGetUniformLocation(shader,"x_pixel_offset"),1/*layer\shadowmap\width)
      glUniform1f(glGetUniformLocation(shader,"y_pixel_offset"),1/*layer\shadowmap\height)

      
;       Define i = 0
;       ForEach *lights()
;         Light::PassToShader(*lights(),shader,i)
;         i+1
;       Next
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))
    ;       glUniform3fv(glGetUniformLocation(shader, "viewPos"),1, *camera\pos)_
      *layer\quad\pgm = *ctx\shaders("defered")
      ScreenQuad::Draw(*layer\quad)
      GLCheckError("ShadowDefered Draw Done")
      Protected vwidth = *ctx\width
      Protected vheight = *ctx\height
      Protected ratio.f = *layer\width/*layer\height
      
      Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
      GLCheckError("ShadowDefered Blit Result")
      ;glDepthMask(#GL_FALSE)
      ;glViewport(0,0,vwidth,vheight)
;       glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;       GLCheckError("Bind Default Write Framebuffer")
;       glClearColor(0.0,0.0,0.0,1.0)
;       glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;       glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\shadowmap\frame_id)
;       GLCheckError("Bind Read Shadow Framebuffer")
;       glReadBuffer(#GL_DEPTH_ATTACHMENT)
;       GLCheckError("Read Shadow Buffer")
;       glBlitFramebuffer(0, 0, 800,600,0, 0, 200, 200*ratio,#GL_DEPTH_BUFFER_BIT,#GL_LINEAR);
;       GLCheckError("ShadowDefered Blit Shadow Texture")
      glEnable(#GL_DEPTH_TEST)
      
      GLCheckError("ShadowDefered Done")
      
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerShadowDeferedCSM_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerShadowDeferedCSM_t = AllocateMemory(SizeOf(LayerShadowDeferedCSM_t))
    InitializeStructure(*Me,LayerShadowDeferedCSM_t)
    Object::INI( LayerShadowDeferedCSM )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\gbuffer = *gbuffer
    *Me\shadowmap = *shadowmap
    *Me\pov = *camera
    *Me\image = CreateImage(#PB_Any,width,height,32)
    *Me\buffer = Framebuffer::New("Deferred",width,height)
    Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
;     Framebuffer::AttachRender(*Me\buffer,"Depth",#GL_DEPTH)
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\quad = ScreenQuad::New()
    ScreenQuad::Setup(*Me\quad,*ctx\shaders("shadowdefered"))
    
    Layer::AddScreenSpaceQuad(*Me,*ctx)

    Setup(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerShadowDeferedCSM)
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 207
; FirstLine = 148
; Folding = --
; EnableXP