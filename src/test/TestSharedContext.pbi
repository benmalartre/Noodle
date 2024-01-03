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
  name.c[256]
  *window.Window::Window_t
  *camera.Camera::Camera_t
  *viewport.ViewportUI::ViewportUI_t
  *layer.LayerDefault::LayerDefault_t
EndStructure

#NUM_MONITORS = 1
Global NewList children.Monitor_t()

Procedure GetMonitorById(window)
  ForEach children()
    If children()\window\ID = window
      ProcedureReturn children()
    EndIf 
  Next
  ProcedureReturn #Null
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
;   Debug "update..."
;   GLContext::SetContext(GLContext::*SHARED_CTXT)
;   Debug *app\scene
;   Scene::Update(*app\scene, GLContext::*SHARED_CTXT)
;   Debug "update scene..."
;   *app\scene\dirty= #True
  
  
  Define *active.Monitor_t = GetMonitorById(EventWindow())

  If *active
    Debug "ACTIVE : "+PeekS(@*active\name[0], 256)
    GLContext::SetContext(*active\viewport\context)
   
    LayerDefault::Draw(*active\layer, *app\scene, *active\viewport\context)
    
    ViewportUI::Blit(*active\viewport, *active\layer\framebuffer)
    
    GLContext::FlipBuffer(*active\viewport\context)
  EndIf
  
 EndProcedure



Global width    = 1024
Global height   = 720



Time::Init()
Log::Init()

 Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
 *app = Application::New("Test Share GL COntext",width,height, options) 
 *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
 
Define model.Math::m4f32
Camera::LookAt(*app\camera)
Matrix4::SetIdentity(model)
*app\scene = Scene::New()
*layer = LayerDefault::New(800,600,*viewport\context,*viewport\camera)
GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)

AddElement(children())
PokeS(@children()\name[0], "Main")
children()\window = *app\window
children()\camera = *app\camera
children()\viewport = *viewport
children()\layer = *layer

; Global *log.LogUI::LogUI_t = LogUI::New(*app\window\main)
 
For i=1 To #NUM_MONITORS
  AddElement(children())
  PokeS(@children()\name[0], "Child"+Str(i))
  children()\window = Window::TearOff(*app\window, i*100, i*100, width * 0.5,height * 0.5)
  children()\camera = *app\camera;Camera::New("Camera"+Str(i),Camera::#Camera_Perspective)
  children()\viewport = ViewportUI::New(children()\window\main, "VIEWPORT"+Str(i), children()\camera, *app\handle)
  

  GLContext::SetContext(children()\viewport\context)
  children()\layer = LayerDefault::New(children()\window\main\sizX, children()\window\main\sizY, 
                                        children()\viewport\context, children()\camera )
;   Vector3::RandomizeInPlace(children()\camera\pos, 12)
;   Camera::LookAt(children()\camera)
  Window::OnEvent(children()\window, #PB_Event_SizeWindow)
  
Next


Global *root.Model::Model_t = Model::New("Model")
RandomBunnies(128, -2, *root)

Scene::AddModel(*app\scene,*root)


Scene::Setup(*app\scene, GLContext::*SHARED_CTXT)
Scene::Update(*app\scene, GLContext::*SHARED_CTXT)



Application::Loop(*app, @Update())




; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 136
; FirstLine = 87
; Folding = -
; EnableXP