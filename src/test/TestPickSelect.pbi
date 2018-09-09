
XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
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

Global *layer.LayerDefault::LayerDefault_t
Global *select.LayerSelection::LayerSelection_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

Procedure RandomBunnies(numItems.i,y.f, *root.Object3D::Object3D_t)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Polymesh::Polymesh_t
  Protected p.v3f32
  Protected q.q4f32
  Define i,j
  Protected *t.Transform::Transform_t
  For i=0 To numItems-1
    Vector3::Set(@p,Mod(i,12), y+i/12, (Random(10)-5)/10)
    Quaternion::Randomize2(@q)
    *item = Polymesh::New("Bunny"+Str(i), Shape::#SHAPE_TEAPOT)
    *t = *item\localT
    Transform::SetTranslation(*t, @p)
    Transform::SetRotationFromQuaternion(*t, @q)
    Object3D::SetLocalTransform(*item, *t)
    Object3D::AddChild(*root, *item)
  Next
EndProcedure


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  *select\mouseX = *viewport\mx
  *select\mouseY = *viewport\height -*viewport\my
  LayerSelection::Draw(*select, *app\context)
  
  LayerDefault::Draw(*layer, *app\context)
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

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
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   *app = Application::New("Test Drawer",width,height, options)

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
  *select = LayerSelection::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
  RandomBunnies(12, -2, *root)
    
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm
; 
;   Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   Object3D::SetShader(*ground,*s_polymesh)
 
  Define i
  
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 80
; FirstLine = 64
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode