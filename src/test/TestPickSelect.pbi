
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
Global *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)


Procedure RandomBunnies(numItems.i,y.f, *root.Object3D::Object3D_t)
  Define position.Math::v3f32
  Define color.Math::c4f32
  Protected *item.Polymesh::Polymesh_t
  Protected p.v3f32
  Protected q.q4f32
  Define i,j
  Protected *t.Transform::Transform_t
  For i=0 To numItems-1
    Vector3::Set(p,Mod(i,12), y+i/12, (Random(10)-5)/10)
    Quaternion::Randomize2(q)
    *item = Polymesh::New("Bunny"+Str(i), Shape::#SHAPE_TEAPOT)
    *t = *item\localT
    Transform::SetTranslation(*t, p)
    Transform::SetRotationFromQuaternion(*t, q)
    Object3D::SetLocalTransform(*item, *t)
    Object3D::AddChild(*root, *item)
  Next
EndProcedure


; Update
;--------------------------------------------
Procedure Update(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
  *select\mouseX = *viewport\mx
  *select\mouseY = *viewport\my

  LayerDefault::Draw(*layer, *app\scene, *app\context)
  LayerSelection::Draw(*select, *app\scene, *app\context)
  
   If Event() = #PB_Event_Gadget And EventGadget() = *viewport\gadgetID
    If EventType() = #PB_EventType_LeftClick
      LayerSelection::Pick(*select, *app\scene)
    EndIf
  EndIf
  
  ViewportUI::Blit(*viewport, *select\framebuffer)
  
  
  Define writer = *viewport\context\writer
;   LayerDefault::Draw(*layer, *app\context)
  FTGL::BeginDraw(writer)
  FTGL::SetColor(writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  Define numSelected = MapSize(*select\selection\items())
  FTGL::Draw(writer,"Num Objects Selected : "+Str(numSelected),-0.9,0.8,ss,ss*ratio)
  FTGL::EndDraw(writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure

 Define useJoystick.b = #False
 width = 800
 height = 600
 
 ; Main
 Globals::Init()
 FTGL::Init()
;--------------------------------------------
Time::Init()
 Log::Init()
 Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
 *app = Application::New("Test Drawer",width,height, options)

 If Not #USE_GLFW
   *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
  View::SetContent(*app\window\main,*viewport)
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf


Camera::LookAt(*app\camera)
Matrix4::SetIdentity(model)
*app\scene = Scene::New()
*layer = LayerDefault::New(800,600,*app\context,*app\camera)
*select = LayerSelection::New(800,600,*app\context,*app\camera)
*select\selection = *app\scene\selection
GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)
GLContext::AddFramebuffer(*viewport\context, *select\framebuffer)


Global *root.Model::Model_t = Model::New("Model")
RandomBunnies(128, -2, *root)

Scene::AddModel(*app\scene,*root)
Scene::Setup(*app\scene,*app\context)
Scene::Update(*app\scene)
Application::Loop(*app, @Update())

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 76
; FirstLine = 61
; Folding = -
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode