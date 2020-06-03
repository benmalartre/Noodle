; ============================================================================
;  Default Layer Module
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
DeclareModule LayerDefault
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerDefault_t Extends Layer::Layer_t
    b_null.b
    b_mesh.b
    b_curve.b
    b_camera.b
    b_light.b
    mode.i
  ;   image.GLuint
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerDefault Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerDefault_t)
  Declare Setup(*layer.LayerDefault_t)
  Declare Update(*layer.LayerDefault_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerDefault_t)
  Declare Draw(*layer.LayerDefault_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  
  DataSection
    LayerDefaultVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerDefault
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;---------------------------------------------------
  ; Update
  ;---------------------------------------------------
  Procedure Update(*layer.LayerDefault_t,*view.m4f32,*proj.m4f32)
;     Protected *stack.Stack::Stack_t = *layer\stack
;     Protected *tree.CStackItem
;     ForEach *stack\nodes()
;       Debug *stack\nodes()\class\name
;       *tree = *stack\nodes()
;       *tree\Update()
;     Next
  
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*layer.LayerDefault_t)
  
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Clean
  ;---------------------------------------------------
  Procedure Clean(*layer.LayerDefault_t)
  
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Pick
  ;-----------------------------------------------a----
  Procedure Pick(*layer.LayerDefault_t)
  
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*layer.LayerDefault_t,*ctx.GLContext::GLContext_t)

    glDisable(#GL_CULL_FACE)
    glFrontFace(#GL_CW)
    glEnable(#GL_DEPTH_TEST)

    Protected *buffer.Framebuffer::Framebuffer_t = *layer\buffer
    Framebuffer::BindOutput(*buffer)

    ;   Clear(*layer)
    glViewport(0,0, *layer\width, *layer\height)
    glClearColor(0.666,0.666,0.666,1.0)
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    
    
    ; Find Up View Point
    ;-----------------------------------------------
    Protected *view.m4f32,proj.m4f32,view.m4f32
    *view = Layer::GetViewMatrix(*layer)
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected aspect.f = *layer\width / *layer\height
    Matrix4::GetProjectionMatrix(proj,*camera\fov,aspect,*camera\nearplane,*camera\farplane)
    
    ;Draw Shaded Polymeshes 
    ;-----------------------------------------------
    Protected *shader.Program::Program_t = *ctx\shaders("polymesh")
    Protected shader.GLuint =  *shader\pgm
    glUseProgram(shader)
      
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    
    glUniform3f(glGetUniformLocation(shader,"lightPosition"),*light\pos\x,*light\pos\y,*light\pos\z)
    glUniform1i(glGetUniformLocation(shader,"tex"),0)
    
    Layer::DrawPolymeshes(*layer,Scene::*current_scene\objects,shader, #True)
    
    ;Draw Drawer Objects
    ;-----------------------------------------------
    *shader.Program::Program_t = *ctx\shaders("drawer")
    shader.GLuint =  *shader\pgm
    glUseProgram(shader)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    Layer::DrawDrawers(*layer, Scene::*current_scene\helpers, shader)
    GLCheckError("DRAW DRAWER")
    
    ;Draw Curve Objects
    ;-----------------------------------------------
    *shader.Program::Program_t = *ctx\shaders("curve")
    shader.GLuint =  *shader\pgm
    glUseProgram(shader)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    Layer::DrawCurves(*layer, Scene::*current_scene\helpers, shader)
    GLCheckError("DRAW CURVES")

    
;     ;Draw Wireframe Polymeshes 
;     ;-----------------------------------------------
;     *shader = *ctx\shaders("wireframe")
;     shader =  *shader\pgm
;     glUseProgram(shader)
; ;       
;     ;   GLCheckError("Use Program")
;     glUniform4f(glGetUniformLocation(shader,"color"), 0.0, 1.0, 0.0, 1.0)
;     Protected m.m4f32
;     Matrix4::SetIdentity(@m)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
;     glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@m)
;     Layer::DrawPolymeshes(*layer,Scene::*current_scene\objects,shader, #True)

    ; Draw Point Clouds 
    ;----------------------------------------------
    Protected *pgm.Program::Program_t = *ctx\shaders("cloud")
    glUseProgram(*pgm\pgm)
    Define.m4f32 model,view,proj
    Matrix4::SetIdentity(model)
 
    glEnable(#GL_DEPTH_TEST)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE,@model)
    
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,@proj)
    
    Layer::DrawPointClouds(*layer,Scene::*current_scene\objects,*pgm\pgm)
    
    GLCheckError("DRAW POINTS")
    ; Draw Instance Clouds 
    ;-----------------------------------------------
    *pgm.Program::Program_t = *ctx\shaders("instances")
    glUseProgram(*pgm\pgm)
    
    Matrix4::SetIdentity(model)
 
  glEnable(#GL_DEPTH_TEST)
    
  ;   glEnable(#GL_TEXTURE_2D)
  ;   glBindTexture(#GL_TEXTURE_2D,texture)
  ;   glUniform1i(glGetUniformLocation(*pgm\pgm,"texture"),0)
  ;   
    
  ;   glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"offset"),1,#GL_FALSE,@model)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE,@model)
    
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,@proj)
  ;   glUniform3f(glGetUniformLocation(*pgm\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  ;   glUniform3f(glGetUniformLocation(*pgm\pgm,"lightPosition"),5,25,5)
    
    Layer::DrawInstanceClouds(*layer,Scene::*current_scene\objects,*pgm\pgm)
    ;   PointCloud::Draw(*cloud)
    ;   Model::Update(*model)
    ;Layer::DrawInstanceClouds(*layer,Scene::*current_scene\objects, *pgm\pgm)
  ;   Model::Draw(*model)
    glCheckError("Draw Instance Cloud")
    
    ; Draw Nulls
    ;----------------------------------------------
    *pgm = *ctx\shaders("wireframe")
    glUseProgram(*pgm\pgm)
    Matrix4::SetIdentity(model)
 
    glDisable(#GL_DEPTH_TEST)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,proj)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"offset"),1,#GL_FALSE,model)
    Layer::DrawNulls(*layer,Scene::*current_scene\helpers,*pgm\pgm)
  ;   Layer::CenterFrambuffer(*layer)
  ;   MessageRequester("SIZE","Context : "+StrF(*ctx\width)+","+StrF(*ctx\height)+",Layer : "+StrF(*layer\width)+","+StrF(*layer\height))
  Protected basewidth = *layer\width
  If(*ctx\width < *layer\width) 
    
  ElseIf *ctx\height < *layer\height
    
  EndIf
  
  Framebuffer::Unbind(*layer\buffer)
  glViewport(0,0,*ctx\width,*ctx\height)
  Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
  glDisable(#GL_DEPTH_TEST)
  glDisable(#GL_BLEND)
  
  glUseProgram(0)

;   Layer::WriteImage(*layer,"D:\Projects\RnD\PureBasic\Noodle\pictures\Test.png",#GL_RGBA)
  EndProcedure
  
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*layer.LayerDefault_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; COnstructor
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
    Protected *Me.LayerDefault_t = AllocateMemory(SizeOf(LayerDefault_t))
    Object::INI(LayerDefault)
    
    *Me\type = Object3D::#Layer
    *Me\name = "LayerDefault"

    
    Color::Set(*Me\background_color,0.33,0.33,0.33,1.0)
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\pov = *pov
    *Me\buffer = Framebuffer::New("Default",width,height)
    
    Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
    Framebuffer::AttachRender( *Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
    
    *Me\image = CreateImage(#PB_Any,width,height)
  ;   Protected img = LoadImage(#PB_Any,"/home/benmalartre/RnD/IconMaker/icons/pen.png")
  ;   If img : *Me\image = GL_LoadImage(img,#True) : EndIf
;     GLContext::AddLayer(*ctx, *Me)
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( LayerDefault )
  
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 273
; FirstLine = 214
; Folding = --
; EnableXP