


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

EnableExplicit

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

Global *curve.Curve::Curve_t


Global *layer.LayerDefault::LayerDefault_t


Global shader.l
Global *s_wireframe.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f

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
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)

  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  ViewportUI::Draw(*viewport, *app\context)

 
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Test Curves ",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestCurve",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")
  
  
  *s_wireframe = *app\context\shaders("simple")
  
  shader = *s_wireframe\pgm
  
  *curve = Curve::New("CRV")
  Object3D::AddChild(*root,*curve)
  
  Define *mesh.Polymesh::Polymesh_t = Polymesh::New("bunny", Shape::#SHAPE_BUNNY)
  Object3D::AddChild(*root,*mesh)
;   
;   Object3D::AddChild(*root,*ground)
;   Object3D::AddChild(*root,*bunny)
   Scene::AddModel(Scene::*current_scene,*root)
   Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.61 (Linux - x64)
; CursorPosition = 16
; FirstLine = 9
; Folding = -
; EnableThread
; EnableXP
; Executable = D:/Volumes/STORE N GO/Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode