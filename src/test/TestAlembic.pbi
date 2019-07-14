
XIncludeFile "../core/Application.pbi"


XIncludeFile "../libs/OpenGL.pbi"
CompilerIf (#USE_GLFW = #True)
  XIncludeFile "../libs/GLFW.pbi"
CompilerEndIf

XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../libs/Booze.pbi"

XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"

XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/KDTree.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"
XIncludeFile "../objects/Polymesh.pbi"



UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global *pgm.Program::Program_t

Global *layer.LayerDefault::LayerDefault_t
Global layer.Layer::ILayer
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *ssao.LayerSSAO::LayerSSAO_t

Global *cloud.PointCloud::PointCloud_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *viewport2.ViewportUI::ViewportUI_t
Global *model.Model::Model_t
Global texture.i

#WIDTH = 1024
#HEIGHT = 720

Global numVertices

Procedure Draw(*app.Application::Application_t)
;   Time::currentframe + 1
;   If Time::currentframe>100 : Time::currentframe = 1:EndIf
;   Scene::Update(Scene::*current_scene)
  GLContext::SetContext(*app\context)
  Application::Draw(*app, *layer, *viewport\camera)
  ;   FTGL::BeginDraw(*app\context\writer)
  LayerDefault::Draw(*layer, *app\context)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*app\context\writer,"Test Alembic",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"NUM VERTICES : "+Str(numVertices),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)


  GLContext::FlipBuffer(*app\context)
  ViewportUI::Blit(*viewport, *layer\buffer)
EndProcedure
    
Define model.m4f32

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  Alembic::Init()
  FTGL::Init()
  Define f.f
  
  *app = Application::New("Test",#WIDTH,#HEIGHT)
  
  Scene::*current_scene = Scene::New()
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf  
  GLContext::SetContext(*app\context)
  
  
  *layer = LayerDefault::New(#WIDTH,#HEIGHT,*app\context,*app\camera)
  Application::AddLayer(*app, *layer)
  layer = *layer
;   *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
;   *ssao = LayerSSAO::New(400,300,*app\context,*gbuffer\buffer,*app\camera)
;     ViewportUI::AddLayer(*viewport, *layer)
    
  Matrix4::SetIdentity(model)

  ;   *pgm = *app\context\shaders("polymesh")
  *pgm = *app\context\shaders("instances")
  GLCheckError("Before Creating Polymeshes")
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Define path.s = OpenFileRequester("Alembic Archive","/Users/benmalartre/Documents/RnD/PureBasic/Noodle/abc/Chaley.abc","Alembic (*.abc)|*.abc",0)    
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    Define path.s = OpenFileRequester("Alembic Archive","D:\Projects\RnD\PureBasic\Noodle\abc\Elephant.abc","Alembic (*.abc)|*.abc",0)    
  CompilerElse
    Define path.s = OpenFileRequester("Alembic Archive","/home/benmalartre/RnD/PureBasic/Noodle/abc/Elephant.abc","Alembic (*.abc)|*.abc",0)
  CompilerEndIf
     Define i
  For i=0 To 0
      *model = Alembic::LoadABCArchive(path)
;       Define *t.Transform::Transform_t = *model\localT
;       Define p.v3f32
;       Define q.v3f32
;       Vector3::Set(p,i*20,0,0)
; ;       Quaternion::Randomize(@q)
;       Transform::SetTranslation(*t, @p)
; ;       Transform::SetRotationFromQuaternion(*t, @q)
;       Object3D::SetlocalTransform(*model, *t)
      Scene::AddModel(Scene::*current_scene,*model)
      
    Next
  
  Define maxNumVertices.GLint
  
;    *model = Model::New("Model")
;   CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
;     *model = Alembic::LoadABCArchive("../../abc/MonkeySkeleton.abc");
;   CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
;     *model = Alembic::LoadABCArchive("..\..\abc\LizardSkeleton.abc")
;   CompilerElse
;     *model = Alembic::LoadABCArchive("../../abc/MonkeySkeleton.abc")
;   CompilerEndIf
;   
;   Scene::AddModel(Scene::*current_scene,*model)
  
  ;glGetIntegerv(#GL_MAX_ELEMENTS_VERTICES, @maxNumVertices)
  ;MessageRequester("MAXIMUM NUM VERTICES : ",Str(maxNumVertices))
;   Define img = LoadImage(#PB_Any,"D:\Projects\PureBasic\Modules\textures\earth.jpg")
;   texture = Utils::GL_LoadImage(img)
  ;Define *t = Alembic::ABC_TestString("Test")
  
  
;   Define i
;   Define pos.v3f32
;   For i=0 To 12
;     Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Star",Shape::#SHAPE_BUNNY)
;     Vector3::Set(pos,Random(10),Random(10),Random(10))
;     Object3D::AddChild(*model,*mesh)
;     Matrix4::SetTranslation(*mesh\model,@pos)
;   Next
  
  ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
  
  
  Define *monitor.Window::Window_t = Application::AddWindow(*app,0,0,200,200)
  *viewport2 = ViewportUI::New(*monitor\main,"ViewportUI", *app\camera, *app\context)
  
  GLContext::SetContext(*app\context)
  Scene::Setup(Scene::*current_scene,*app\context)
  Application::Loop(*app,@Draw())
  Alembic::Terminate()
EndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 163
; FirstLine = 123
; Folding = -
; EnableThread
; EnableXP
; Executable = bin\Alembic.app
; Compiler = PureBasic 5.31 (Windows - x64)
; Debugger = Standalone
; Warnings = Display
; Constant = #USE_GLFW=0