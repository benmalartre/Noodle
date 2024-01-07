XIncludeFile "../core/Application.pbi"

; XIncludeFile "FTGL.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit

Global WIDTH = 720
Global HEIGHT = 576

Global vwidth
Global vheight

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global NewList *lights.Light::Light_t()
Global *ground.Polymesh::Polymesh_t
Global NewList *bunnies.Polymesh::Polymesh_t()

Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *s_gbuffer.Program::Program_t
Global *s_defered.Program::Program_t
Global *s_shadowdefered.Program::Program_t
Global shader.l

Global *default.LayerDefault::LayerDefault_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *shadowdefered.LayerShadowDefered::LayerShadowDefered_t
Global *shadowmap.LayerShadowMap::LayerShadowMap_t


Global *ftgl_drawer.FTGL::FTGL_Drawer

Global offset.m4f32
Matrix4::SetIdentity(offset)

Global a.v3f32
Global b.v3f32
Global c.v3f32
Global m.m4f32
Global q.q4f32
Global s.v3f32

Global nb_lights = 1
Global numTriangles = 0
 
; Draw
;--------------------------------------------
Procedure Update()
  GLContext::SetContext(*viewport\context)
  Scene::Update(*app\scene)  
  LayerDefault::Draw(*default, *app\scene, *viewport\context)
  LayerGBuffer::Draw(*gbuffer, *app\scene, *viewport\context)
  LayerShadowMap::Draw(*shadowmap, *app\scene, *viewport\context)
  LayerDefered::Draw(*defered, *app\scene,  *viewport\context)
;   LayerShadowDefered::Draw(*shadowdefered, *app\scene, *viewport\context)
  
  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*viewport\context\writer,"Test Alembic",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*viewport\context\writer,"NUM LIGHTS : "+Str(numTriangles),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)
 EndProcedure
 

 Globals::Init()
 Log::Init()
 FTGL::Init()

; Main
;--------------------------------------------
 If Time::Init()
   
   *app = Application::New("Test Lights",WIDTH,HEIGHT)
    *app\scene = Scene::New()
                           
   CompilerIf Not #USE_GLFW
   *viewport = ViewportUI::New(*app\window\main,"Viewport 3D", *app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  CompilerEndIf
  
  Define i
  
  Define *model.Model::Model_t = Model::New("Model")
  
  ; Lights
  ;----------------------------------------------------
  Define i
;   For i=0 To nb_lights
;     AddElement(*lights())
;     *lights() = Light::New("Light"+Str(i+1),Light::#Light_Infinite)
;     Vector3::Set(*lights()\pos,Random(20)-10,4,Random(20)-10)
;     Vector3::Set(*lights()\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;     Object3D::AddChild(*model,*lights())
;   Next
  AddElement(*lights())
  *lights() = Light::New("Light",Light::#Light_Infinite)
  Vector3::Set(*lights()\pos,4,8,2)
  Vector3::Set(*lights()\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  Object3D::AddChild(*model,*lights())
  
  Define *bunnies.Model::Model_t = Scene::CreateMeshGrid(12,2,12, Shape::#SHAPE_BUNNY)
 
  
  *ground = Polymesh::New("Ground",Shape::#SHAPE_GRID)
  Transform::SetScaleFromXYZValues(*ground\localT, 3, 3, 3)
  Object3D::SetLocalTransform(*ground, *ground\localT)
;   Shape::RandomizeColors(*ground\shape,@color,0.1)
  ;Polymesh::Setup(*ground,*s_polymesh)
  Object3D::AddChild(*model,*ground)
  
  Scene::AddModel(*app\scene, *bunnies)
  Scene::AddModel(*app\scene,*model)
  
  Scene::Setup(*app\scene)
  
  ; Defualt Layer
  ;-----------------------------------------------------
  *default = LayerDefault::New(WIDTH,HEIGHT,*viewport\context,*app\camera)
  LayerDefault::Setup(*default)
  
  ; Geometry Buffer Layer
  ;-----------------------------------------------------
  *gbuffer = LayerGBuffer::New(WIDTH,HEIGHT,*viewport\context,*app\camera)
  LayerGBuffer::Setup(*gbuffer)
  
  ; ShadowMap Layer
  ;------------------------------------------------------
  FirstElement(*lights())
  *shadowmap = LayerShadowMap::New(511,512,*viewport\context,*lights())
  LayerShadowMap::Setup(*shadowmap)
  
  ; Deferred Layer
  ;-----------------------------------------------------
  *defered = LayerDefered::New(WIDTH,HEIGHT,*viewport\context,*gbuffer\framebuffer,*shadowmap\framebuffer,*app\camera)
  LayerDefered::Setup(*defered)
  
  ;Shadow  Deferred Layer
  ;-----------------------------------------------------
  *shadowdefered = LayerShadowDefered::New(WIDTH,HEIGHT,*viewport\context,*gbuffer\framebuffer,*shadowmap\framebuffer,*app\camera)
  LayerShadowDefered::Setup(*shadowdefered)
 
  
  Application::Loop(*app,@Update())
  
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 65
; FirstLine = 48
; Folding = -
; EnableXP
; Constant = #USE_GLFW=0