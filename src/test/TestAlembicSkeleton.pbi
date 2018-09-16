XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global *pgm.Program::Program_t

Global *layer.Layer::Layer_t
Global layer.Layer::ILayer
Global *cloud.PointCloud::PointCloud_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *model.Model::Model_t
Global texture.i

Procedure Draw(*app.Application::Application_t)
  layer\Draw(*app\context)

  If Not #USE_GLFW
    ViewportUI::FlipBuffer( *viewport )
  EndIf
EndProcedure
    
Define model.m4f32

; Main
;--------------------------------------------
If Time::Init()
  Globals::Init()
  Controls::Init()
  Log::Init()
  Alembic::Init()
  FTGL::Init()
  Define f.f


  *app = Application::New("Test",800,600)
  Scene::*current_scene = Scene::New("Scene")
  
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::SetContext(*viewport)
  EndIf
  
  Debug "Camera :: "+Str(*app\camera)
  
  Matrix4::SetIdentity(@model)
    
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)
  layer = *layer
  *pgm = *app\context\shaders("instances")
  
  *model = Model::New("Model")
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    *model = Alembic::LoadABCArchive("../../abc/MonkeySkeleton.abc");
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    *model = Alembic::LoadABCArchive("..\..\abc\MonkeySkeleton.abc")
  CompilerElse
    *model = Alembic::LoadABCArchive("../../abc/MonkeySkeleton.abc")
  CompilerEndIf
  
  Scene::AddModel(Scene::*current_scene,*model)
  
  
 
;   CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
;     Define img = LoadImage(#PB_Any,"../../textures/earth.jpg")
;   CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
;     Define img = LoadImage(#PB_Any,"..\..\textures\earth.jpg")
;   CompilerElse
;     Define img = LoadImage(#PB_Any,"..\..\textures\earth.jpg")
;   CompilerEndIf
;   
;   texture = Utils::GL_LoadImage(img)
;   Scene::Setup(Scene::*current_scene,*app\context)
;   Global *skeleton.Skeleton::Skeleton_t = Skeleton::New()
; Global *model.Model::Model_t = Model::New("Character")
; Object3D::AddChild(*model,*skeleton\cloud)
; Scene::AddModel(Scene::*current_scene,*model)
; 
; Global *animation.Animation::Animation_t = Animation::New(*skeleton)
; Define path.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/abc/LizardSkeleton.abc"
; Define identifier.s = "ICE_SkeletonShape"
; Animation::Load(*animation,path,identifier)
; Skeleton::SetupPointCloud(*animation\skeleton)

  ;Define *t = Alembic::ABC_TestString("Test")
  
  
;   Define i
;   Define pos.v3f32
;   For i=0 To 12
;     Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Star",Shape::#SHAPE_BUNNY)
;     Vector3::Set(@pos,Random(10),Random(10),Random(10))
;     Object3D::AddChild(*model,*mesh)
;     Matrix4::SetTranslation(*mesh\model,@pos)
;   Next
  
  ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
  

;   *cloud = PointCloud::New("PointCloud",100)
;   PointCloud::Setup(*cloud,*pgm)
;    Scene::*current_scene = Scene::New()
;   Scene::AddModel(Scene::*current_scene,*model)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  Debug "Setup Model Done!!!"
 Application::Loop(*app,@Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 55
; FirstLine = 28
; Folding = -
; EnableXP