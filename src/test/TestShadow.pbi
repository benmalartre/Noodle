


XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit


Global width.i
Global height.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *box.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *default.LayerDefault::LayerDefault_t
Global *shadows.LayerShadowMap::LayerShadowMap_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *defshadows.LayerShadowDefered::LayerShadowDefered_t
Global *ssao.LayerSSAO::LayerSSAO_t
Global *quad.ScreenQuad::ScreenQuad_t

Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.d


Procedure RandomLine()
  Protected seed.v3f32
  
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLEnable(#GL_DEPTH_TEST)
  GLContext::SetContext(*viewport\context)
  Scene::Twist(*app\scene)
  Scene::Update(*app\scene)  
  LayerDefault::Draw(*default, *app\scene, *viewport\context)
  LayerGBuffer::Draw(*gbuffer, *app\scene, *viewport\context)
  LayerShadowMap::Draw(*shadows, *app\scene, *viewport\context)
  LayerDefered::Draw(*defered, *app\scene,  *viewport\context)
;   LayerShadowDefered::Draw(*defshadows, *app\scene, *viewport\context)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*viewport\context\writer,"Test Shadow Map",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 800
 
 Globals::Init()
 FTGL::Init()
 
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("Test Shadow Map",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"Test Shadow", *app\camera, *app\handle)     
   
  EndIf

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()

  Define *model.Model::Model_t = Scene::CreateMeshGrid(6,4,6, Shape::#SHAPE_BUNNY)
 
  *ground = Polymesh::New("Ground",Shape::#SHAPE_GRID)
  Transform::SetScaleFromXYZValues(*ground\localT, 10, 10, 10)
  Object3D::SetLocalTransform(*ground, *ground\localT)

  Object3D::AddChild(*model,*ground)
  
  Define *light.Light::Light_t = Light::New("Light",Light::#Light_Infinite)
  Vector3::Set(*light\pos,4,8,2)
  Vector3::Set(*light\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  Object3D::AddChild(*model,*light)
  
  Scene::AddModel(*app\scene,*model)
  
  Scene::Setup(*app\scene)
  
  Scene::Setup(*app\scene)
  
  *default = LayerDefault::New(width,height,*viewport\context,*app\camera)
  *gbuffer = LayerGBuffer::New(width,height,*viewport\context,*app\camera)
  *shadows= LayerShadowMap::New(1024,1024,*viewport\context,*light)
  *defered = LayerDefered::New(width,height,*viewport\context,*gbuffer\framebuffer,*shadows\framebuffer,*app\camera)
  *defshadows = LayerShadowDefered::New(width,height,*viewport\context,*gbuffer\framebuffer,*shadows\framebuffer,*app\camera)
 
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 57
; FirstLine = 45
; Folding = -
; EnableXP