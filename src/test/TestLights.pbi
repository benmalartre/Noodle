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
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)  
  LayerDefault::Draw(*default,*app\context)
  LayerGBuffer::Draw(*gbuffer,*app\context)
  LayerShadowMap::Draw(*shadowmap,*app\context)
;   LayerDefered::Draw(*defered, *app\context)
  LayerShadowDefered::Draw(*shadowdefered,*app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*app\context\writer,"Test Alembic",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"NUM LIGHTS : "+Str(numTriangles),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)
 EndProcedure
 

 Globals::Init()
 Log::Init()
 FTGL::Init()
 Scene::*current_scene = Scene::New()
; Main
;--------------------------------------------
 If Time::Init()
   
   *app = Application::New("Test Lights",WIDTH,HEIGHT)
                           
   CompilerIf Not #USE_GLFW
   *viewport = ViewportUI::New(*app\manager\main,"Viewport 3D")
   *app\context = *viewport\context

    *viewport\camera = *app\camera
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
  Vector3::Set(*lights()\pos,4,6,2)
  Vector3::Set(*lights()\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  Object3D::AddChild(*model,*lights())
  
  
  ; Shaders
  ;-----------------------------------------------------
  *s_wireframe = *app\context\shaders("wireframe")
  *s_polymesh = *app\context\shaders("polymesh")
  *s_gbuffer = *app\context\shaders("gbuffer")
  *s_defered = *app\context\shaders("defered")
   *s_shadowdefered = *app\context\shaders("shadowdefered")
  
  shader = *s_gbuffer\pgm
  glUseProgram(shader)

  ; Meshes
  ;-----------------------------------------------------
  Define pos.v3f32, rot.q4f32

  Define *t.Transform::Transform_t
  Define color.c4f32
  Quaternion::SetFromEulerAngles(rot,40,0,0)
  Define *mesh.Geometry::PolymeshGeometry_t
  Define x,y,z
  For x = 0 To 7
    For y = 0 To 2
      For z = 0 To 7
        Color::Set(color,Random(255)/255,Random(255)/255,Random(255)/255,1.0)
        AddElement(*bunnies())
        *bunnies() = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
        *t = *bunnies()\localT
        *mesh = *bunnies()\geom
        numTriangles + *mesh\nbtriangles
        Vector3::Set(color,Random(100)*0.005+0.5,Random(100)*0.005+0.5,Random(100)*0.005+0.5)
        PolymeshGeometry::SetColors(*bunnies()\geom,color)
        Transform::SetTranslationFromXYZValues(*t,x*2-10,y*2+1.5,z*2-10)
        Transform::SetRotationFromQuaternion(*t,rot)
        Object3D::SetLocalTransform(*bunnies(),*t)
;         Matrix4::SetFromQuaternion(*bunnies()\matrix,@rot)
;         Matrix4::SetTranslation(*bunnies()\matrix,@pos)
        
        
        ;Polymesh::Setup(*bunnies(),*s_gbuffer)
        Object3D::AddChild(*model,*bunnies())
      Next
    Next
  Next
  
  *ground = Polymesh::New("Ground",Shape::#SHAPE_GRID)
;   Shape::RandomizeColors(*ground\shape,@color,0.1)
  ;Polymesh::Setup(*ground,*s_polymesh)
  Object3D::AddChild(*model,*ground)
  
  Scene::AddModel(Scene::*current_scene,*model)
  
  Scene::Setup(Scene::*current_scene,*app\context)
  
  ; Defualt Layer
  ;-----------------------------------------------------
  *default = LayerDefault::New(WIDTH,HEIGHT,*app\context,*app\camera)
  LayerDefault::Setup(*default)
  
  ; Geometry Buffer Layer
  ;-----------------------------------------------------
  *gbuffer = LayerGBuffer::New(WIDTH,HEIGHT,*app\context,*app\camera)
  LayerGBuffer::Setup(*gbuffer)
  
  ; ShadowMap Layer
  ;------------------------------------------------------
  FirstElement(*lights())
  *shadowmap = LayerShadowMap::New(1024,1024,*app\context,*lights())
  LayerShadowMap::Setup(*shadowmap)
  
  ; Deferred Layer
  ;-----------------------------------------------------
  *defered = LayerDefered::New(WIDTH,HEIGHT,*app\context,*gbuffer\buffer,*shadowmap\buffer,*app\camera)
  LayerDefered::Setup(*defered)
  
  ;Shadow  Deferred Layer
  ;-----------------------------------------------------
  *shadowdefered = LayerShadowDefered::New(WIDTH,HEIGHT,*app\context,*gbuffer\buffer,*shadowmap\buffer,*app\camera)
  LayerShadowDefered::Setup(*shadowdefered)
 
  
  Application::Loop(*app,@Update())
  
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 114
; FirstLine = 81
; Folding = -
; EnableXP
; Constant = #USE_GLFW=0