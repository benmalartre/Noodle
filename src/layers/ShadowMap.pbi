; ============================================================================
;  ShadowMap Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
DeclareModule LayerShadowMap
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerShadowMap_t Extends Layer::Layer_t
    b_null.b
    b_mesh.b
    b_curve.b
    b_camera.b
    b_light.b
    mode.i
    cullfrontface.b
    
  ;   image.GLuint
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerShadowMap Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerShadowMap_t)
  Declare Setup(*layer.LayerShadowMap_t)
  Declare Update(*layer.LayerShadowMap_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerShadowMap_t)
  Declare Draw(*layer.LayerShadowMap_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  
  DataSection
    LayerShadowMapVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerShadowMap
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerShadowMap_t,*view.m4f32,*proj.m4f32)
    
  EndProcedure
  
  ;------------------------------------
  ; Clean
  ;------------------------------------
  Procedure Clean(*layer.LayerShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerShadowMap_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)

 Debug "-------------------------------- LAYER SHADOW MAP DRAW CALLED -----------------------------------"
  Framebuffer::BindOutput(*layer\framebuffer)
  
;   OLayer_Draw(*layer,*ctx)
  ;clear depth-buffer
  glClearColor(0.0,1.0,0.0,0.0)
  glClearDepth(1)
  glClear(#GL_DEPTH_BUFFER_BIT)
  glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
  ;Disable color rendering, we only want To write To the Z-Buffer
  glColorMask(#GL_FALSE, #GL_FALSE, #GL_FALSE, #GL_FALSE);
  
  Protected *light.Light::Light_t = *layer\pov
  Debug *light\fov
  Debug *light\aspect
	Light::UpdateProjection(*light)
	Light::Update(*light, *ctx)
	
   ; Find Up View Point
  ;-----------------------------------------------
  Protected *view.m4f32,*proj.m4f32
  *view = Layer::GetViewMatrix(*layer)
  *proj = Layer::GetProjectionMatrix(*layer)
	
	; Polymeshes
	;--------------------------------------------------------
  Protected shader.GLuint = *ctx\shaders("shadowmap")\pgm
  glBindAttribLocation(shader, 0, "position")
	glUseProgram(shader)

  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
  
  glEnable(#GL_DEPTH_TEST)
  If *layer\cullfrontface
    glEnable(#GL_CULL_FACE)
    glCullFace(#GL_FRONT)
    glFrontFace(#GL_CW)
  EndIf
  
  
  Layer::DrawPolymeshes(*layer,*scene\objects,shader,#False)
    
    ; Instanced PointCloud
  	;--------------------------------------------------------
  	shader.GLuint = *ctx\shaders("shadowmapic")\pgm
  	glUseProgram(shader)
  	glFrontFace(#GL_CCW)
  	
  	glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*light\view)
  	glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*light\projection)
    glUniform1f(glGetUniformLocation(shader,"nearplane"),*light\nearplane)
    glUniform1f(glGetUniformLocation(shader,"farplane"),*light\farplane)
   
    
    glBindAttribLocation(shader,0,"s_pos")
    glBindAttribLocation(shader,1,"s_norm")
    glBindAttribLocation(shader,2,"s_uvws")
    glBindAttribLocation(shader,3,"position")
    glBindAttribLocation(shader,4,"normal")
    glBindAttribLocation(shader,5,"tangent")
    glBindAttribLocation(shader,6,"color")
    glBindAttribLocation(shader,7,"scale")
    glBindAttribLocation(shader,8,"size")
    
    
    Layer::DrawInstanceClouds(*layer,*scene\objects,shader)
    
    If *layer\cullfrontface
      glDisable(#GL_CULL_FACE)
      glDisable(#GL_DEPTH_TEST)
      glFrontFace(#GL_CCW)
    EndIf
    

    glColorMask(#GL_TRUE, #GL_TRUE, #GL_TRUE, #GL_TRUE);
    
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,Framebuffer::GetTex(*layer\framebuffer,0))
    
    Framebuffer::Unbind(*layer\framebuffer)
    glUseProgram(0)
    
    Debug "-------------------------------- LAYER SHADOW MAP DRAW ENDED -----------------------------------"

  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerShadowMap_t)
    Framebuffer::Delete(*layer\framebuffer)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*light.Light::Light_t)
  
    Protected *Me.LayerShadowMap_t = AllocateMemory(SizeOf(LayerShadowMap_t))
    InitializeStructure(*Me,LayerShadowMap_t)
    Object::INI( LayerShadowMap )
    Color::Set(*Me\color,1,1,1,0)
    *Me\context = *ctx
    *Me\pov = *light
    *Me\framebuffer = Framebuffer::New("ShadowMap",width, height)
    *Me\cullfrontface = #False
    Framebuffer::AttachShadowMap(*Me\framebuffer)
;     Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
;     Framebuffer::AttachRender( *Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
   
    ProcedureReturn *Me
  EndProcedure
  
  
  Class::DEF(LayerShadowMap)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 96
; FirstLine = 68
; Folding = --
; EnableXP