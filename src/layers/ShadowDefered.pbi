; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "ShadowMap.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
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
    
    
    
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    If Not *light : ProcedureReturn : EndIf
    Light::Update(*light)
    
  
    
    glViewport(0,0,*layer\width,*layer\height)
      shader = *ctx\shaders("shadowdefered")\pgm
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
    

      glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,Layer::GetProjectionMatrix(*layer))
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*light\view)
      glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*light\projection)
      glUniform3f(glGetUniformLocation(shader,"light_position"),*light\globalT\t\pos\x,*light\globalT\t\pos\y,*light\globalT\t\pos\z)
      
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
          
      Protected vwidth = *ctx\width
      Protected vheight = *ctx\height
      Protected ratio.f = *layer\width/*layer\height
      
;       glViewport(0,0,vwidth,vheight)
;       glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;       glClearColor(1.0,1.0,1.0,1.0)
;       glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;       glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\buffer\frame_id);
;       glReadBuffer(#GL_COLOR_ATTACHMENT0)
;       Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
;       glBlitFramebuffer(0, 0, *layer\buffer\width,*layer\buffer\height,0, 0, vwidth, vheight*ratio,#GL_COLOR_BUFFER_BIT,#GL_LINEAR);
      
      Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
    ;   glEnable(#GL_BLEND)
    ;   glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
    ;   glDisable(#GL_DEPTH_TEST)
    ;   FTGL::SetColor(*ftgl_drawer,1,1,1,1)
    ;   Define ss.f = 0.85/vwidth
    ;   Define ratio.f = vwidth / vheight
    ;   FTGL::Draw(*ftgl_drawer,"SSAO wip",-0.9,0.9,ss,ss*ratio)
    ;   FTGL::Draw(*ftgl_drawer,"User  : "+UserName(),-0.9,0.85,ss,ss*ratio)
    ;   glDisable(#GL_BLEND)
      glEnable(#GL_DEPTH_TEST)
      
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
    InitializeStructure(*Me,LayerShadowDefered_t)
    Object::INI( LayerShadowDefered )
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
    
  ;   Protected img = LoadImage(#PB_Any,RAAFAL_BASE_PATH+"/rsc/ico/pointcloud.png")
  ;   If img : *Me\image = GL_LoadImage(img,#True) : EndIf
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerShadowDefered)
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 100
; FirstLine = 94
; Folding = --
; EnableXP