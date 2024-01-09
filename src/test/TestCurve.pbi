


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
  Protected *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)

  GLContext::SetContext(GLContext::*SHARED_CTXT)
  Scene::Update(*app\scene)
  
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  
  FTGL::BeginDraw(GLContext::*SHARED_CTXT\writer)
  FTGL::SetColor(GLContext::*SHARED_CTXT\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(GLContext::*SHARED_CTXT\writer,"Test Curves ",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(GLContext::*SHARED_CTXT\writer)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)
 
 
  
  GLContext::FlipBuffer(GLContext::*SHARED_CTXT)

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestCurve",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(800,600, GLContext::*SHARED_CTXT,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
  
  
  *s_wireframe = GLContext::*SHARED_CTXT\shaders("simple")
  
  shader = *s_wireframe\pgm
  
  *curve = Curve::New("CRV")
  Object3D::AddChild(*root,*curve)
  
  Define *mesh.Polymesh::Polymesh_t = Polymesh::New("bunny", Shape::#SHAPE_BUNNY)
  Object3D::AddChild(*root,*mesh)
;   
;   Object3D::AddChild(*root,*ground)
;   Object3D::AddChild(*root,*bunny)
   Scene::AddModel(*app\scene,*root)
   Scene::Setup(*app\scene)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 99
; FirstLine = 63
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode