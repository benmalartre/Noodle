

EnableExplicit

XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *layer.LayerDefault::LayerDefault_t
Global *shadows.LayerShadowMap::LayerShadowMap_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *defshadows.LayerShadowDefered::LayerShadowDefered_t
Global *ssao.LayerSSAO::LayerSSAO_t

Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_simple.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *handle.Handle::Handle_t

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
   
; ;    
  Protected *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)
  Vector3::Set(*light\pos, 5-Random(10),10,5-Random(10))
  Light::Update(*light)
  GLContext::SetContext(*viewport\context)
  
  Scene::Update(*app\scene)
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
  If *app\tool
    Protected *wireframe.Program::Program_t = GLContext::*SHARED_CTXT\shaders("wireframe")
    glUseProgram(*wireframe\pgm)

    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,Matrix4::IDENTITY())
    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE, *app\camera\view)
    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE, *app\camera\projection)
    Handle::Resize(*app\handle, *app\camera)
    Handle::Draw( *app\handle) 
  EndIf

  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*viewport\context\writer,"Test Handle",-0.9,0.9,ss,ss*ratio)
  
  Select *app\tool
    Case Globals::#TOOL_TRANSLATE
      FTGL::Draw(*viewport\context\writer,"Active Tool : Translate",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_ROTATE
      FTGL::Draw(*viewport\context\writer,"Active Tool : Rotate",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_SCALE
      FTGL::Draw(*viewport\context\writer,"Active Tool : Scale",-0.9,0.8,ss,ss*ratio)
    Case Globals::#TOOL_CAMERA
      FTGL::Draw(*viewport\context\writer,"Active Tool : Camera",-0.9,0.8,ss,ss*ratio)
    Default
      FTGL::Draw(*viewport\context\writer,"Active Tool : NONE",-0.9,0.8,ss,ss*ratio)
  EndSelect
  
  Define ns.i = MapSize(*app\scene\selection\items())
  FTGL::Draw(*viewport\context\writer,"Num selected objects : "+Str(ns),-0.9,0.7,ss,ss*ratio)


  FTGL::EndDraw(*viewport\context\writer)
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure
 

 Define useJoystick.b = #False
 width = 800
 height = 600
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Test Handle",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  GLContext::SetContext(*viewport\context)
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)
  GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)
;   *shadows = LayerShadowMap::New(800,800,*viewport\context,CArray::GetValuePtr(*app\scene\lights, 0))
;   *gbuffer = LayerGBuffer::New(800,600,*viewport\context,*app\camera)
;   *defered = LayerDefered::New(800,600,*viewport\context,*gbuffer\buffer,*shadows\buffer,*app\camera)
;   *defshadows = LayerShadowDefered::New(800,600,*viewport\context,*gbuffer\buffer, *shadows\buffer,*app\camera)
  Global *root.Model::Model_t = Model::New("Model")
  
  ; FTGL Drawer
  ;-----------------------------------------------------

  
  
  Global *model.Model::Model_t = Model::New("Model")
  *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TEAPOT)
  Object3D::AddChild(*model,*torus)
  Scene::AddModel(*app\scene,*model)
  Scene::Setup(*app\scene)
  
  Scene::SelectObject(*app\scene, *torus)
  ViewportUI::SetHandleTarget(*viewport, *torus)
  Application::AddShortcuts(*app)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 83
; FirstLine = 60
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode