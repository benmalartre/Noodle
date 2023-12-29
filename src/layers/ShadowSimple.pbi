; ============================================================================
; ShadowSimple Layer Module Declaration
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
DeclareModule LayerShadowSimple
  UseModule OpenGL
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerShadowSimple_t Extends Layer::Layer_t
    *shadowmap.Framebuffer::Framebuffer_t
    *light.Light::Light_t
    texture.i
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
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;-----------------------------------------------------------------
  Procedure GetImage(*layer.LayerShadowSimple_t)
    Protected x,y
    Protected l.l
    Protected *mem = AllocateMemory(*layer\framebuffer\width * *layer\framebuffer\height * SizeOf(l))
    
    OpenGL::glGetTexImage(#GL_TEXTURE_2D,0,#GL_DEPTH,#GL_UNSIGNED_INT,*mem)
    
    Define image.i = CreateImage(#PB_Any, *layer\framebuffer\width, *layer\framebuffer\height)
    StartDrawing(ImageOutput(image))
    Protected row_size = *layer\framebuffer\width
    Protected color.l
    For y=0 To *layer\framebuffer\height-1
      For x=0 To *layer\framebuffer\width-1
        color = PeekA(*mem + (y*row_size+x)*SizeOf(l))
        Plot(x,y,color)
      Next x
    Next y
    
    StopDrawing()
    FreeMemory(*mem)
    SaveImage(image,"D:\Projects\RnD\PureBasic\Noodle\textures\shadowmapsimple.png")
    FreeImage(image)
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
      If *child\type = Object3D::#Polymesh
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
    Framebuffer::BindOutput(*layer\framebuffer)
    Layer::Clear(*layer)
    
    Protected shader.GLuint = *ctx\shaders("shadowsimple")\pgm
    glUseProgram(shader)
    glEnable(#GL_DEPTH_TEST)
    glEnable(#GL_CULL_FACE)
    glCullFace(#GL_BACK)
  
     Protected bias.m4f32
  
    Matrix4::Set(bias,
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

    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*layer\texture);Framebuffer::GetTex(*layer\shadowmap,0))
    GLCheckError("Bind Texture")
    GetImage(*layer)
    GLCheckError("Get Image")
    
    glDisable(#GL_DEPTH_TEST)
    glDisable(#GL_CULL_FACE)
    
    Framebuffer::BlitTo(*layer\framebuffer,0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_LINEAR)
     GLCheckError("BlitTo")
    Framebuffer::Unbind(*layer\framebuffer)
    
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
    *Me\context = *ctx
    *Me\pov = *camera
  
    *Me\framebuffer = Framebuffer::New("ShadowSimple",width,height)
    Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
    Framebuffer::AttachRender(*Me\framebuffer,"Depth",#GL_DEPTH_COMPONENT)
    *Me\mask = #GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT
    *Me\shadowmap = *shadowmap
    *Me\light = #Null
    *Me\once = #False
    
    Setup(*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerShadowSimple)

EndModule

;}
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 233
; FirstLine = 193
; Folding = --
; EnableXP