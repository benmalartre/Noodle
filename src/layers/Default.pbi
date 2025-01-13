; ============================================================================
;  Default Layer Module
; ============================================================================
XIncludeFile "Layer.pbi"
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
  Declare Draw(*layer.LayerDefault_t, *scene.Scene::Scene_t, *ctxt.GLContext::GLContext_t)
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
  Procedure Draw(*layer.LayerDefault_t, *scene.Scene::Scene_t, *ctxt.GLContext::GLContext_t)
    
    glDisable(#GL_CULL_FACE)
    glFrontFace(#GL_CW)
    glEnable(#GL_DEPTH_TEST)
    
    Protected *buffer.Framebuffer::Framebuffer_t = *layer\framebuffer
    Framebuffer::BindOutput(*buffer)
    
    ;   Clear(*layer)
    glViewport(0,0, *layer\framebuffer\width, *layer\framebuffer\height)
    glClearColor(0.666,0.666,0.666,1.0)
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    

    ; Find Up View Point
    ;-----------------------------------------------
    Protected *view.m4f32,proj.m4f32,view.m4f32
    *view = Layer::GetViewMatrix(*layer)
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected aspect.f
    If Not *ctxt
      aspect = *layer\framebuffer\width / *layer\framebuffer\height
    Else
      aspect = *ctxt\width / *ctxt\height
    EndIf
    
    Matrix4::GetProjectionMatrix(proj,*camera\fov,aspect,*camera\nearplane,*camera\farplane)
    
    ;Draw Shaded Polymeshes 
    ;-----------------------------------------------
    Protected *shader.Program::Program_t = GLContext::*SHARED_CTXT\shaders("polymesh")
    Protected shader.GLuint =  *shader\pgm
    glUseProgram(shader)
      
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    
    If CArray::GetCount(*scene\lights)
      Protected *light.Light::Light_t = CArray::GetValuePtr(*scene\lights,0)
      
      glUniform3f(glGetUniformLocation(shader,"lightPosition"),*light\pos\x,*light\pos\y,*light\pos\z)
      glUniform1i(glGetUniformLocation(shader,"tex"),0)
    EndIf
    Layer::DrawPolymeshes(*layer,*scene\objects,shader, #True)
        
    ;Draw Drawer Objects
    ;-----------------------------------------------
    *shader.Program::Program_t = GLContext::*SHARED_CTXT\shaders("drawer")
    shader.GLuint =  *shader\pgm
    glUseProgram(shader)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    Layer::DrawDrawers(*layer, *scene\helpers, shader)
    GLCheckError("DRAW DRAWER")
    
    ;Draw Curve Objects
    ;-----------------------------------------------
    *shader.Program::Program_t = GLContext::*SHARED_CTXT\shaders("curve")
    shader.GLuint =  *shader\pgm
    glUseProgram(shader)
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@proj)
    Layer::DrawCurves(*layer, *scene\helpers, shader)
    GLCheckError("DRAW CURVES")

    
;     ;Draw Wireframe Polymeshes 
;     ;-----------------------------------------------
;     *shader = GLContext::*SHARED_CTXT\shaders("wireframe")
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
;     Layer::DrawPolymeshes(*layer,*scene\objects,shader, #True)

    ; Draw Point Clouds 
    ;----------------------------------------------
    Protected *pgm.Program::Program_t = GLContext::*SHARED_CTXT\shaders("cloud")
    glUseProgram(*pgm\pgm)
    Define.m4f32 model,view,proj
    Matrix4::SetIdentity(model)
         
    glEnable(#GL_DEPTH_TEST)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE,@model)
    
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,@proj)
    
    Layer::DrawPointClouds(*layer,*scene\objects,*pgm\pgm)
    
    GLCheckError("DRAW POINTS")
    ; Draw Instance Clouds 
    ;-----------------------------------------------
    *pgm.Program::Program_t = GLContext::*SHARED_CTXT\shaders("instances")
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
    
    Layer::DrawInstanceClouds(*layer,*scene\objects,*pgm\pgm)
    ;   PointCloud::Draw(*cloud)
    ;   Model::Update(*model)
    ;Layer::DrawInstanceClouds(*layer,*scene\objects, *pgm\pgm)
  ;   Model::Draw(*model)
    glCheckError("Draw Instance Cloud")
    
    ; Draw Nulls
    ;----------------------------------------------
    *pgm = GLContext::*SHARED_CTXT\shaders("wireframe")
    glUseProgram(*pgm\pgm)
    Matrix4::SetIdentity(model)
 
    glDisable(#GL_DEPTH_TEST)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,proj)
    glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"offset"),1,#GL_FALSE,model)
    Layer::DrawNulls(*layer,*scene\helpers,*pgm\pgm)

  
  Framebuffer::Unbind(*layer\framebuffer)
  
  glDisable(#GL_DEPTH_TEST)
  glDisable(#GL_BLEND)

  glUseProgram(0)
EndProcedure
  
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.LayerDefault_t)
    Object::TERM(LayerDefault)
  EndProcedure
  
  ;---------------------------------------------------
  ; COnstructor
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
    Protected *Me.LayerDefault_t = AllocateStructure(LayerDefault_t)
    Object::INI(LayerDefault)
    
    *Me\name = "LayerDefault"
    *Me\context = *ctx
    *Me\pov = *pov
    *Me\framebuffer = Framebuffer::New("Default",width,height)
    Color::Set(*Me\color,0.33,0.33,0.33,1.0)
    
    Framebuffer::AttachTexture(*Me\framebuffer,"Color", #GL_RGBA, #GL_NEAREST, #GL_REPEAT, #False)
    Framebuffer::AttachRender( *Me\framebuffer,"Depth",#GL_DEPTH_COMPONENT)
    GLContext::AddFramebuffer(*ctx, *Me\framebuffer)
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( LayerDefault )
  
EndModule
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 213
; FirstLine = 200
; Folding = --
; EnableXP