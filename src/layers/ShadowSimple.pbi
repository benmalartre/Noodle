; ============================================================================
; ShadowSimple Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
DeclareModule LayerShadowSimple
  UseModule OpenGL
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerShadowSimple_t Extends Layer::Layer_t
    *shadowmap.Framebuffer::Framebuffer_t
    *light.Light::Light_t
    once.b
  EndStructure
  
  Interface ILayerShadowSimple Extends Layer::ILayer
  EndInterface
  
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerShadowSimple_t)
  Declare DrawChildren(*layer.LayerShadowSimple_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t,shader)
  Declare Draw(*layer.LayerShadowSimple_t,*ctx.GLContext::GLContext_t)
  Declare Setup(*layer.LayerShadowSimple_t)
  Declare Update(*layer.LayerShadowSimple_t)  
  Declare Clean(*layer.LayerShadowSimple_t)
  Declare Pick(*layer.LayerShadowSimple_t)
  
  DataSection
    LayerShadowSimpleVT:
    Layer::DAT()
  EndDataSection
  
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL GeometryBuffer Layer Implementation
; ============================================================================
Module LayerShadowSimple
    UseModule OpenGL
    UseModule OpenGLExt
    UseModule Math
  ;------------------------------------------------------------------
  ; HELPERS
  ;-----------------------------------------------------------------
  Procedure GetImage(*layer.LayerShadowSimple_t)
    Protected x,y
    Protected l.l
    Protected *mem = AllocateMemory(*layer\width * *layer\height * SizeOf(l))
    
    OpenGL::glGetTexImage(#GL_TEXTURE_2D,0,#GL_DEPTH,#GL_UNSIGNED_INT,*mem)
    
    StartDrawing(ImageOutput(*layer\image))
    Protected row_size = *layer\width
    Protected color.l
    For y=0 To *layer\height-1
      For x=0 To *layer\width-1
        color = PeekA(*mem + (y*row_size+x)*SizeOf(l))
        Plot(x,y,color)
      Next x
    Next y
    
    StopDrawing()
    FreeMemory(*mem)
    SaveImage(*layer\image,"D:\Projects\RnD\PureBasic\Noodle\textures\shadowmapsimple.png")
  EndProcedure
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerShadowSimple_t)
    Protected *main.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    Protected main.Light::ILight = *main
    

    Light::Update(*main)

    
    *layer\light = *main
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerShadowSimple_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerShadowSimple_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerShadowSimple_t)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Draw Children Recursively
  ;---------------------------------------------------------
  Procedure  DrawChildren(*layer.LayerShadowSimple_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t,shader)
    Protected id.v3f32
    Protected nbo = ListSize(*obj\children())
    Protected *child.Object3D::Object3D_t
    Protected child.OBject3D::IObject3D
    Protected *t.Transform::Transform_t
    Protected i
    
    Protected uModelMatrix = glGetUniformLocation(shader,"model")
    ;Protected uUniqueID = glGetUniformLocation(shader,"uniqueID")
    ForEach *obj\children()
      *child = *obj\children()
      Object3D::EncodeID(@id,*child\uniqueID)
      If *child\type = Object3D::#Object3D_Polymesh
        *t = *child\globalT
        ;glUniform3f(uUniqueID,id\x,id\y,id\z)
        glUniformMatrix4fv(uModelMatrix,1,#GL_FALSE,*child\matrix)
        child = *child
        child\Draw()
      EndIf 
      DrawChildren(*layer,*child,*ctx,shader)
    Next
    
  EndProcedure
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerShadowSimple_t,*ctx.GLContext::GLContext_t)
    Protected *main.Light::Light_t = *layer\light
    Protected main.Light::ILight = *main
    
  
    Protected *camera.Camera::Camera_t = *layer\pov
    Framebuffer::BindOutput(*layer\buffer)
    Layer::Clear(*layer)
    
    Protected shader.GLuint = *ctx\shaders("shadowsimple")\pgm
    glUseProgram(shader)
    glEnable(#GL_DEPTH_TEST)
    glEnable(#GL_CULL_FACE)
    glCullFace(#GL_BACK)
  
     Protected bias.m4f32
  
    Matrix4::Set(@bias,
                0.5,0.0,0.0,0.0,
                0.0,0.5,0.0,0.0,
                0.0,0.0,0.5,0.0,
                0.5,0.5,0.5,1.0)
    
    
    glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera\view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
    glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*main\view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*main\projection)
    glUniform1i(glGetUniformLocation(shader,"shadow_mode"),0)
    
    glActiveTexture(#GL_TEXTURE0)
    GLCheckError("ShadowSimple Set Uniforms")
    
    ;     Framebuffer::BindInputByID(*layer\shadowmap,0)
    glBindTexture(#GL_TEXTURE_2D,*layer\texture)
    glUniform1i(glGetUniformLocation(shader,"shadow_map"),0)
    GLCheckError("ShadowSimple Bind Shadow Map")
      
    glUniform1f(glGetUniformLocation(shader,"x_pixel_offset"),1/*layer\shadowmap\width)
    glUniform1f(glGetUniformLocation(shader,"y_pixel_offset"),1/*layer\shadowmap\height)
    
    ;---[ Draw ]---------------------------------------
    Layer::DrawPolymeshes(*layer,Scene::*current_scene\objects,shader,#False)
    
    GLCheckError("ShadowSimple Bind Polymesh Draw")
; ;   ;   ;---[ Instance Cloud ]---------------------------------------
; ;     shader.GLuint = *ctx\s_simpleshadowpc
; ;     glUseProgram(shader)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"bias"),1,#GL_FALSE,@bias)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera\view)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"light_view"),1,#GL_FALSE,*light\view)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"light_proj"),1,#GL_FALSE,*light\projection)
; ;     
; ;     
; ;     
; ;     glUniform1i(glGetUniformLocation(shader,"shadow_map"),0)
; ;     glFrontFace(#GL_CCW)
; ;     glUniform1f(glGetUniformLocation(shader,"x_pixel_offset"),1/2048)
; ;     glUniform1f(glGetUniformLocation(shader,"y_pixel_offset"),1/2048)
; ;     
; ;     ;---[ Bind ]---------------------------------------
; ;     glBindAttribLocation(shader,0,"s_pos")
; ;     glBindAttribLocation(shader,1,"s_norm")
; ;     glBindAttribLocation(shader,2,"s_uvws")
; ;     glBindAttribLocation(shader,3,"position")
; ;     glBindAttribLocation(shader,4,"normal")
; ;     glBindAttribLocation(shader,5,"tangent")
; ;     glBindAttribLocation(shader,6,"color")
; ;     glBindAttribLocation(shader,7,"scale")
; ;     glBindAttribLocation(shader,8,"size")
; ;   
; ;     ;---[ Draw ]---------------------------------------
; ;     For i=0 To nbo-1
; ;       *obj = *raa_current_scene\objects\GetValue(i)
; ;       If *obj\GetType() = #RAA_3DObject_PointCloud
; ;         *t = *obj\GetGlobalTransform()
; ;         glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*t\m)
; ;         *obj\Draw(*ctx,#GL_TRIANGLES)
; ;       EndIf
; ;       
; ;     Next i
; 
;     
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*layer\texture);Framebuffer::GetTex(*layer\shadowmap,0))
    GLCheckError("Bind Texture")
    GetImage(*layer)
    GLCheckError("Get Image")
    
    glDisable(#GL_DEPTH_TEST)
    glDisable(#GL_CULL_FACE)
    
    Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_LINEAR)
     GLCheckError("BlitTo")
    Framebuffer::Unbind(*layer\buffer)
    
    GLCheckError("Unbind")
    
    
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerShadowSimple_t)
    FreeMemory(*layer)
  EndProcedure
  
 
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*shadowmap.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerShadowSimple_t = AllocateMemory(SizeOf(LayerShadowSimple_t))
    InitializeStructure(*Me,LayerShadowSimple_t)

    Object::INI( LayerShadowSimple )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\pov = *camera
  
    *Me\buffer = Framebuffer::New("ShadowSimple",width,height)
    Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
    Framebuffer::AttachRender(*Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
    *Me\mask = #GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT
    *Me\shadowmap = *shadowmap
    *Me\light = #Null
    *Me\once = #False

    *Me\image = CreateImage(#PB_Any,width,height)
    
    Setup(*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerShadowSimple)

EndModule

;}
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 179
; FirstLine = 175
; Folding = --
; EnableXP