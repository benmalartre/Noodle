; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "ShadowMap.pbi"

DeclareModule LayerDefered
  UseModule OpenGL
  UseModule Math
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure LayerDefered_t Extends Layer::Layer_t
    *gbuffer.Framebuffer::Framebuffer_t
    *shadowmap.Framebuffer::Framebuffer_t
    

   
  
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerDefered Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerDefered_t)
  Declare Setup(*layer.LayerDefered_t)
  Declare Update(*layer.LayerDefered_t)
  Declare Clean(*layer.LayerDefered_t)
  Declare Pick(*layer.LayerDefered_t)
  Declare Draw(*layer.LayerDefered_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
  
  DataSection 
    LayerDeferedVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
Module LayerDefered
  UseModule OpenGL
  UseModule OpenGLExt
  
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerDefered_t)
   
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerDefered_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerDefered_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
    Protected *light.Light::Light_t = CArray::GetValuePtr(*scene\lights,0)
    If Not *light : ProcedureReturn : EndIf
    Light::Update(*light)
    
    Define nb_lights = CArray::GetCount(*scene\lights)
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
    shader = *ctx\shaders("deferred")\pgm
      glUseProgram(shader)
      Framebuffer::BindInput(*layer\gbuffer)
      Framebuffer::BindInput(*layer\shadowmap,ArraySize(*layer\gbuffer\tbos()))
      Framebuffer::BindOutput(*layer\framebuffer)
      glClear(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT);
      
      glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
      glUniform1i(glGetUniformLocation(shader,"position_map"),0)
      glUniform1i(glGetUniformLocation(shader,"normal_map"),1)
      glUniform1i(glGetUniformLocation(shader,"color_map"),2)
      glUniform1i(glGetUniformLocation(shader,"shadow_map"),3)
      glUniform1i(glGetUniformLocation(shader,"nb_lights"),nb_lights)
      
      Protected sunColor.v3f32
      Protected sunDirection.v3f32
      Protected sunIntensity.f = 1.0
      Vector3::Set(sunColor, 1,0.9,0.75)
      Vector3::Set(sunDirection, 0.45,1, 0.66)
      glUniform3fv(glGetUniformLocation(shader,"sun.direction"), 1, @sunDirection)
      glUniform3fv(glGetUniformLocation(shader,"sun.color"), 1, @sunColor)
      glUniform1f(glGetUniformLocation(shader,"sun.intensity"), @sunIntensity)

      Protected i
      For i=0 To CArray::GetCount(*scene\lights)-1
        *light = CArray::GetValuePtr( *scene\lights,i)
        Light::PassToShader(*light,shader,i)
      Next
      
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
      
      
      ScreenQuad::Draw(*layer\quad)
      
          
      Protected vwidth = *ctx\width
      Protected vheight = *ctx\height
      
      glViewport(0,0,vwidth,vheight)
      glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
      glClearColor(1.0,1.0,1.0,1.0)
      glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
      glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\framebuffer\frame_id);
      glReadBuffer(#GL_COLOR_ATTACHMENT0)
      glBlitFramebuffer(0, 0, *layer\framebuffer\width,*layer\framebuffer\height,0, 0, vwidth, vheight,#GL_COLOR_BUFFER_BIT,#GL_LINEAR);
;      
      glEnable(#GL_DEPTH_TEST)

    
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*Me.LayerDefered_t)
    Object::TERM(LayerDefered)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerDefered_t = AllocateStructure(LayerDefered_t)
    Object::INI( LayerDefered )
    Color::Set(*Me\color,0.5,0.5,0.5,1)

    *Me\context = *ctx
    *Me\gbuffer = *gbuffer
    *Me\shadowmap = *shadowmap
    *Me\pov = *camera
  
    *Me\framebuffer = Framebuffer::New("Deferred",width,height)
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
    *Me\mask = #GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT
    
    Layer::AddScreenSpaceQuad(*Me,*ctx)

    Setup(*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerDefered)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 109
; FirstLine = 109
; Folding = --
; EnableXP