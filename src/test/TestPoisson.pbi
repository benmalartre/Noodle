

XIncludeFile "../core/Application.pbi"


EnableExplicit

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

Global *s_simple.Program::Program_t
Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t
Global *torus.Polymesh::Polymesh_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t


Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)

  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*viewport\width
  Define ratio.f = *viewport\width / *viewport\height
  FTGL::Draw(*app\context\writer,"Testing Poisson Sampling",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)
EndProcedure

Time::Init()
Log::Init()

*app = Application::New("Test Poisson Sampling",800, 800, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)

 If Not #USE_GLFW
   *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
   *app\context = *viewport\context
  *viewport\camera = *app\camera
  View::SetContent(*app\manager\main,*viewport)
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf


Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
*drawer = Drawer::New()

Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
Define.v3f32 bmin, bmax
Vector3::Sub(@bmin, *geom\bbox\origin, *geom\bbox\extend)
Vector3::Add(@bmax, *geom\bbox\origin, *geom\bbox\extend)
Define *octree.Octree::Octree_t = Octree::New(@bmin.v3f32, @bmax.v3f32, 0)
Octree::Build(*octree, *geom)
Octree::Draw(*octree, *drawer, *geom)
Octree::Delete(*octree)

Define *poisson.Poisson::Poisson_t = Poisson::New()
Define box.Geometry::Box_t
Define origin.v3f32, extend.v3f32
Vector3::Set(@origin, 1,3,2)
Vector3::Set(@extend, 12,12,12)
Box::Set(@box, @origin, @extend)

Scene::*current_scene = Scene::New()
*layer = LayerDefault::New(800,800,*app\context,*app\camera)
Global *root.Model::Model_t = Model::New("Model")
; Object3D::AddChild(*root, *mesh)
Object3D::AddChild(*root, *drawer)

Scene::AddModel(Scene::*current_scene, *root)

Define t.d = Time::Get()
; Poisson::CreateGrid(*poisson, *mesh\geom\bbox,0.2)
; ; Define numSamples = Poisson::Sample(*poisson)
; Poisson::SignedDistances(*poisson, *mesh\geom)
; Poisson::Setup(*poisson, *drawer)
Scene::Setup(Scene::*current_scene, *app\context)


; Define str.s
; str + "#################### POISSON SAMPLING ######################"+Chr(10)
; str + " Generated "+Str(numSamples) + " Samples in "+StrD(Time::Get()-t)+" milliseconds"+Chr(10)
; str + "############################################################"+Chr(10)
; 
; MessageRequester("POISSON", str)

Application::Loop(*app, @Draw())



;     
; Define model.m4f32
; ; Main
; ;--------------------------------------------
; If Time::Init()
;   Log::Init()
;   *app = Application::New("Test",800,600)
; 
;   If Not #USE_GLFW
;     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
;     *app\context = *viewport\context
;     *viewport\camera = *app\camera
;     View::SetContent(*app\manager\main,*viewport)
;     ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
;   EndIf
;   
;   Matrix4::SetIdentity(@model)
;   
;   Debug "Size "+Str(*app\width)+","+Str(*app\height)
;   Debug *app\width
;   Debug *app\height
;   *buffer = Framebuffer::New("Color",*app\width,*app\height)
;   
;   *s_simple = Program::NewFromName("simple")
; 
;   ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
;   
;   Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
;   Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)
; 
;   *torus = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *cloud = PointCloud::New("Cloud",Shape::#SHAPE_TORUS)
;   Polymesh::Setup(*torus,*s_simple)
;   PointCloud::Setup(*cloud,*s_simple)
;   
;   Application::Loop(*app,@Draw())
; EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 64
; FirstLine = 48
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode