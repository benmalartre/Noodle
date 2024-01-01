; ======================================================================================================
; Test Shared Context
; ======================================================================================================
XIncludeFile "../core/Application.pbi"

UseModule OpenGL
UseModule OpenGLExt
UseModule Math

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *layer.Layer::Layer_t
Global *scene.Scene::Scene_t
Global *polymesh.Polymesh::Polymesh_t

Structure Monitor_t
  *window.Window::Window_t
  *camera.Camera::Camera_t
  *viewport.ViewportUI::ViewportUI_t
  *layer.LayerDefault::LayerDefault_t
EndStructure

#NUM_MONITORS = 3
Global Dim children.Monitor_t(#NUM_MONITORS+1)

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
  Scene::Update(*app\scene, *viewport\context)
  *app\scene\dirty= #True
  
  
  GLContext::SetContext(*viewport\context)
 
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)
 
  Define writer = *viewport\context\writer
;   LayerDefault::Draw(*layer, *app\context)
  FTGL::BeginDraw(writer)
  FTGL::SetColor(writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(writer)
  
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure



Global width    = 1024
Global height   = 720



Time::Init()
Log::Init()



 Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
 *app = Application::New("Test Share GL COntext",width,height, options) 
 Debug "construct app"
 *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
 Debug "construct viewport"
 
Define model.Math::m4f32
Camera::LookAt(*app\camera)
Matrix4::SetIdentity(model)
*app\scene = Scene::New()
*layer = LayerDefault::New(800,600,*viewport\context,*viewport\camera)
GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)

; Global *log.LogUI::LogUI_t = LogUI::New(*app\window\main)
 
For i=0 To #NUM_MONITORS-1
  
  children(i)\window = Window::TearOff(*app\window, i*100, i*100, width * 0.5,height * 0.5)
  children(i)\camera = Camera::New("Camera"+Str(i),Camera::#Camera_Perspective)
  children(i)\viewport = ViewportUI::New(children(i)\window\main, "VIEWPORT"+Str(i), children(i)\camera, *app\handle)
  children(i)\layer = LayerDefault::New(children(i)\window\main\sizX, children(i)\window\main\sizY, 
                                        children(i)\viewport\context, children(i)\camera )
  Vector3::RandomizeInPlace(children(i)\camera\pos, 12)
  Camera::LookAt(children(i)\camera)
  Window::OnEvent(children(i)\window, #PB_Event_SizeWindow)
  
Next


Global *root.Model::Model_t = Model::New("Model")
RandomBunnies(128, -2, *root)
GLContext::SetContext(GLContext::*SHARED_CTXT)
Scene::AddModel(*app\scene,*root)

Scene::Setup(*app\scene, GLContext::*SHARED_CTXT)
Scene::Update(*app\scene, GLContext::*SHARED_CTXT)

Application::Loop(*app, @Update())




; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 99
; FirstLine = 48
; Folding = -
; EnableXP