; ============================================================================
;  OpenGL GeometryBuffer Layer Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
DeclareModule LayerGBuffer
  UseModule OpenGL
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerGBuffer_t Extends Layer::Layer_t
    display.b
    color_map.GLuint
    depth_map.GLuint
    uvws_map.GLuint
    normal_map.GLuint
  EndStructure
  
  Interface ILayerGBuffer Extends Layer::ILayer
  EndInterface
  
  Declare DrawChildren(*layer.LayerGBuffer_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t)
  Declare Draw(*layer.LayerGBuffer_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*camera.Camera::Camera_t)
  Declare Setup(*layer.LayerGBuffer_t)
  Declare Update(*layer.LayerGBuffer_t)  
  Declare Clean(*layer.LayerGBuffer_t)
  Declare Pick(*layer.LayerGBuffer_t)
  Declare Delete(*layer.LayerGBuffer_t)
  DataSection
    LayerGBufferVT:
    Layer::DAT()
  EndDataSection
  
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL GeometryBuffer Layer Implementation
; ============================================================================
Module LayerGBuffer
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Procedure Setup(*layer.LayerGBuffer_t)
    
  EndProcedure
  
  Procedure Update(*layer.LayerGBuffer_t)
    
  EndProcedure
  
  Procedure Clean(*layer.LayerGBuffer_t)
    
  EndProcedure
  
  Procedure Pick(*layer.LayerGBuffer_t)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Draw Children Recursively
  ;---------------------------------------------------------
  Procedure DrawChildren(*layer.LayerGBuffer_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t)
  
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    Protected *t.Transform::Transform_t
    Protected shader.GLuint = *ctx\shaders("gbuffer")\pgm
  
    ForEach *obj\children()
      *child = *obj\children()
      *t = *child\globalT
      If Object3D::IsA(*child,Object3D::#Polymesh)
        Protected id.v3f32
        Object3D::EncodeID(@id,*child\uniqueID)
        glUniform1i(glGetUniformLocation(shader,"selectionMode"),1)
        glUniform3f(glGetUniformLocation(shader,"uniqueID"),id\x,id\y,id\z)
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*t\m)
        child = *child
        child\Draw(*ctxt)
      EndIf
      
     ; OLayerSelection_DrawChildren(*layer,*child,contextID,shader)
    Next
    
  EndProcedure
  

  
  
  ;---------------------------------------------------------
  ; Draw Layer
  ;---------------------------------------------------------
  Procedure Draw(*layer.LayerGBuffer_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
    
    Protected *gbuffer.Framebuffer::Framebuffer_t = *layer\framebuffer
    Protected offset.m4f32
    Matrix4::SetIdentity(offset)
    
    ; 1. Geometry Pass: render scene's geometry/color data into gbuffer
    Framebuffer::BindOutput(*gbuffer)
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
    glClearColor(0.0,0.0,0.0,0.0)
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    
    ; Draw Polymeshes
    ;---------------------------------------------------------------------
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected shader.i = *ctx\shaders("gbuffer")\pgm
    glUseProgram(shader)
    GLCheckError("CHECK SHADER")
    
    Protected *light.Light::Light_t = Scene::GetMainLight(*scene)
    
     Protected bias.m4f32
     Protected invmodelview.m4f32
     
    Matrix4::Set(bias,
                0.5,0.0,0.0,0.0,
                0.0,0.5,0.0,0.0,
                0.0,0.0,0.5,0.0,
                0.5,0.5,0.5,1.0)
    
;     Matrix4::Multiply(@invmodelview,*camera\view)
  ;   glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera\view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
    glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*camera\view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*camera\projection)
    ;glUniformMatrix4fv(glGetUniformLocation(shader,"invmodelview"),1,#GL_FALSE,@invmodelview)
    glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
    glUniform1f(glGetUniformLocation(shader,"nearplane"),*camera\nearplane)
    glUniform1f(glGetUniformLocation(shader,"farplane"),*camera\farplane)
    glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  ;       glUniform3f(glGetUniformLocation(shader,"color"),0,1,0)
    glUniform1f(glGetUniformLocation(shader,"T"),0)
    
    glEnable(#GL_DEPTH_TEST)
    Define p.v3f32
    
    Layer::DrawPolymeshes(*layer,*scene\objects,shader,#False)
    
    
    ; Draw Instance Clouds
    ;---------------------------------------------------------------------
    shader.i = *ctx\shaders("gbufferic")\pgm
    glUseProgram(shader)
    
    
    ;   glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
    glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@model)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera\view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
    glUniform1f(glGetUniformLocation(shader,"nearplane"),*camera\nearplane)
    glUniform1f(glGetUniformLocation(shader,"farplane"),*camera\farplane)
    glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  ;       glUniform3f(glGetUniformLocation(shader,"color"),0,1,0)
    glUniform1f(glGetUniformLocation(shader,"T"),0)
    
    glEnable(#GL_DEPTH_TEST)
    Define p.v3f32
    
    Layer::DrawInstanceClouds(*layer,*scene\objects,shader)
    
    glDisable(#GL_DEPTH_TEST)
    
    Define WIDTH = *ctx\width
    Define HEIGHT = *ctx\height
    Define RATIO = WIDTH/HEIGHT
    Define bw = WIDTH/5
    Define bh = HEIGHT/5*RATIO
    
    glViewport(0,0,*ctx\width,*ctx\height)
    ;Framebuffer::BlitTo(*gbuffer,#Null,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glBindFramebuffer(#GL_READ_FRAMEBUFFER, *gbuffer\frame_id);
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,0, 0, *ctx\width,*ctx\height*RATIO,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
    glDisable(#GL_DEPTH_TEST)
    glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,WIDTH-bw, HEIGHT-bh, WIDTH, HEIGHT,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
    glDisable(#GL_DEPTH_TEST)
    glReadBuffer(#GL_COLOR_ATTACHMENT1)
    glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,WIDTH-bw, HEIGHT-2*bh, WIDTH, HEIGHT-bh,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
    glReadBuffer(#GL_COLOR_ATTACHMENT2)
    glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,WIDTH-bw, HEIGHT-3*bh, WIDTH, HEIGHT-2*bh,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
    
    Framebuffer::Unbind(*layer\framebuffer)
;   
;     Framebuffer::BindOutput(*layer\buffer)
;   
;     glViewport(0,0,*layer\width,*layer\height)
;     glClearColor(0.5,0.5,0.5,0.0)
;     glClear (#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
;   
;     glEnable(#GL_DEPTH_TEST)
;     
;     Define.m4f32 *view,*proj
;     Define.f nearplane, farplane, aspect, tanhalffov
;   
;     Protected *camera.Camera::Camera_t = *layer\pov
;     *view = *camera\view
;     *proj = *camera\projection
;     nearplane = *camera\nearplane
;     farplane = *camera\farplane
;     aspect = *camera\aspect
;   
;     tanhalffov = Tan(Radian(*camera\fov*0.5))
;     
;     ; Draw PolyMeshes
;     ;----------------------------------------------
;     Protected shader.GLuint = *ctx\shaders("gbuffer")\pgm
;     glUseProgram(shader)
;     
;     glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
;     glUniform1f(glGetUniformLocation(shader,"nearplane"),nearplane)
;     glUniform1f(glGetUniformLocation(shader,"farplane"),farplane)
;     glUniform1f(glGetUniformLocation(shader,"tanhalffov"),tanhalffov)
;     glUniform1f(glGetUniformLocation(shader,"aspectratio"),aspect)
;     glUniform1i(glGetUniformLocation(shader,"tex"),0)
;     
;     glDisable(#GL_CULL_FACE)
;     
;     
;   ;   glEnable(#GL_BLEND)
;   ;   glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
;     
;     Protected i
;     Protected id.v3f32
;     Protected nbo = CArray::GetCount(*scene\objects)
;     Protected *obj.Object3D::Object3D_t
;     Protected obj.Object3D::IObject3D
;     Protected *mesh.Polymesh::Polymesh_t
;     Protected *t.Transform::Transform_t
;     
;     For i=0 To nbo-1
;       *obj = CArray::GetValuePtr(*scene\objects,i)
;       If *obj\type = Object3D::#Polymesh
;         *mesh = *obj
;         If *mesh\texture
;           glActiveTexture(#GL_TEXTURE0)
;           glBindTexture(#GL_TEXTURE_2D,*mesh\texture)
;         EndIf
;         
;         *t = *obj\globalT
;         glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*t\m)
;         obj = *obj
;         obj\Draw()
;       EndIf
;       
;     Next i
;     
;     ; Draw InstanceClouds
;     ;----------------------------------------------
;     shader = *ctx\shaders("gbufferpc")\pgm
;     
;     glUseProgram(shader)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
;      glUniform1f(glGetUniformLocation(shader,"nearplane"),nearplane)
;     glUniform1f(glGetUniformLocation(shader,"farplane"),farplane)
;     glUniform1f(glGetUniformLocation(shader,"tanhalffov"),tanhalffov)
;     glUniform1f(glGetUniformLocation(shader,"aspectratio"),aspect)
;   
;     glUniform1i(glGetUniformLocation(shader,"tex"),0)
;     
;     Protected uModelMatrix = glGetUniformLocation(shader,"model")
;     Protected *cloud.InstanceCloud::InstanceCloud_t
;     For i=0 To nbo-1
;       *obj = CArray::GetValuePtr(*scene\objects,i)
;       If *obj\type = Object3D::#InstanceCloud
;         *cloud = *obj
;         If *cloud\texture
;           glActiveTexture(#GL_TEXTURE0)
;           glBindTexture(#GL_TEXTURE_2D,*cloud\texture)
;         EndIf
;         *t = *obj\globalT
;         glUniformMatrix4fv(uModelMatrix,1,#GL_FALSE,*t\m)
;         obj = *obj
;         obj\Draw()
;       EndIf 
;     Next i
;   
;     glDisable(#GL_DEPTH_TEST)
;     glDisable(#GL_BLEND)
;     
;     If *layer\display
;       Protected bw = *layer\width/5
;       Protected bh = *layer\height/5
;     
;       glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;       glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\buffer\frame_id);
;       glReadBuffer(#GL_COLOR_ATTACHMENT0)
;       glBlitFramebuffer(0, 0, *layer\width,*layer\height,*layer\width-bw, *layer\height-bh, *layer\width, *layer\height,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT,#GL_NEAREST);
;       glReadBuffer(#GL_COLOR_ATTACHMENT1)
;       glBlitFramebuffer(0, 0, *layer\width,*layer\height,*layer\width-bw, *layer\height-2*bh, *layer\width, *layer\height-bh,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT,#GL_NEAREST);
;       glReadBuffer(#GL_COLOR_ATTACHMENT2)
;       glBlitFramebuffer(0, 0, *layer\width,*layer\height,*layer\width-bw, *layer\height-3*bh, *layer\width, *layer\height-2*bh,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT,#GL_NEAREST);
;       glReadBuffer(#GL_COLOR_ATTACHMENT3)
;       glBlitFramebuffer(0, 0, *layer\width,*layer\height,*layer\width-bw, *layer\height-4*bh, *layer\width, *layer\height-3*bh,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT,#GL_NEAREST);
;       glReadBuffer(#GL_COLOR_ATTACHMENT4)
;       glBlitFramebuffer(0, 0, *layer\width,*layer\height,*layer\width-bw, *layer\height-5*bh, *layer\width, *layer\height-4*bh,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT | #GL_STENCIL_BUFFER_BIT,#GL_NEAREST);
;     EndIf
;     
;     glBindFramebuffer(#GL_READ_FRAMEBUFFER,0)
;     glUseProgram(0)
  ;   GLCheckError("Finished")
  EndProcedure
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.LayerGBuffer_t)
    Object::TERM(LayerGBuffer)
  EndProcedure
  
  ;----------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*camera.Camera::Camera_t)
    Protected *Me.LayerGBuffer_t = AllocateStructure(LayerGBuffer_t)
    Object::INI( LayerGBuffer )
    *Me\context = *ctx
    *Me\pov = *camera
    *Me\display = #True
    Color::Set(*Me\color,0.5,0.5,0.5,1.0)
    
    ; Create Framebuffer Object
    *Me\framebuffer = Framebuffer::New("GBuffer",width,height)
    
    ; Add Render Buffers
    Framebuffer::AttachTexture(*Me\framebuffer,"Position",#GL_RGBA16F,#GL_LINEAR)              ; POSITION
    Framebuffer::AttachTexture(*Me\framebuffer,"Normal",#GL_RGBA16F,#GL_LINEAR)              ; NORMAL
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)                 ; COLOR
    Framebuffer::AttachRender(*Me\framebuffer,"Render",#GL_DEPTH_COMPONENT)
    
    ;OFramebuffer_Check(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( LayerGBuffer )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 319
; FirstLine = 303
; Folding = --
; EnableXP