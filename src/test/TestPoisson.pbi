

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
  GLContext::SetContext(*viewport\context)
  *app\scene\dirty= #True
  
  Scene::Update(*app\scene)
  Application::Draw(*app, *layer, *app\camera)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)

  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/*viewport\sizX
  Define ratio.f = *viewport\sizX / *viewport\sizY
  FTGL::Draw(*viewport\context\writer,"Testing Poisson Sampling",-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
  
  GLContext::FlipBuffer(*viewport\context)
  
EndProcedure

Time::Init()
Log::Init()

*app = Application::New("Test Poisson Sampling",1024, 720, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)

 If Not #USE_GLFW
   *viewport = ViewportUI::New(*app\window\main,"Poisson", *app\camera, *app\handle)     
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf

GLContext::SetContext(*viewport\context)
Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
*drawer = Drawer::New()

; Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
; Define.v3f32 bmin, bmax
; Vector3::Sub(@bmin, *geom\bbox\origin, *geom\bbox\extend)
; Vector3::Add(@bmax, *geom\bbox\origin, *geom\bbox\extend)
; Define *octree.Octree::Octree_t = Octree::New(@bmin.v3f32, @bmax.v3f32, 0)
; Octree::Build(*octree, *geom)
; Octree::Draw(*octree, *drawer, *geom)
; Octree::Delete(*octree)

Define *poisson.Poisson::Poisson_t = Poisson::New()
Define box.Geometry::Box_t
Define origin.v3f32, extend.v3f32
Vector3::Set(origin, 1,3,2)
Vector3::Set(extend, 12,12,12)
Box::Set(@box, @origin, @extend)

*app\scene = Scene::New()
*layer = LayerDefault::New(800,800,*viewport\context,*app\camera)
Global *root.Model::Model_t = Model::New("Model")
; Object3D::AddChild(*root, *mesh)
Object3D::AddChild(*root, *drawer)

Scene::AddModel(*app\scene, *root)

Define t.d = Time::Get()
Poisson::CreateGrid(*poisson, *mesh\geom\bbox,0.1)
; Define numSamples = Poisson::Sample(*poisson)
Poisson::SignedDistances(*poisson, *mesh\geom)

MessageRequester("TOOK", StrD(Time::Get() - t))
Poisson::Setup(*poisson, *drawer)
Scene::Setup(*app\scene)


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
;     *viewport\context = *viewport\context
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
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 31
; FirstLine = 24
; Folding = -
; EnableThread
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode