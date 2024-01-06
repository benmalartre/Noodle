;Test Menu
XIncludeFile "../core/Application.pbi"
XIncludeFile "../controls/Menu.pbi"
XIncludeFile "../ui/DummyUI.pbi"


Globals::Init()
Time::Init()
UIColor::Init()
Commands::Init()
Log::Init()
FTGL::Init()

*app.Application::Application_t = Application::New("Test Menu",800,600,#PB_Window_SystemMenu|#PB_Window_SizeGadget)
*view.View::View_t = View::Split(*app\window\main,#False)
*top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)
*bottom.View::View_t = View::Split(*view\right,#PB_Splitter_Vertical,30)
*app\scene  = Scene::New()


*menu.UI::UI_t = MenuUI::New(*top\left,"Menu")
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*top\right,"Viewport", *app\camera, *app\handle)
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)


; *dummy1.UI::UI_t = DummyUI::New(*bottom\left,"Dummy1")
*explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*bottom\left,"Explorer")
*graph.GraphUI::GraphUI_t = GraphUI::New(*bottom\right,"Graph")
Scene::Setup(*app\scene)
; Application::OnEvent(*app,#PB_Event_SizeWindow)


*mesh.Polymesh::Polymesh_t = Polymesh::New("Test",Shape::#SHAPE_BUNNY)
Scene::AddChild(*app\scene,*mesh)

Scene::Setup(*app\scene)

ControlExplorer::Fill(*explorer\explorer,*app\scene)
Global *layer.Layer::Layer_t = LayerDefault::New(800,600,*viewport\context,*app\camera)
GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)
Global *selection.Layer::Layer_t = LayerSelection::New(800,600,*viewport\context,*app\camera)
GLContext::AddFramebuffer(*viewport\context, *selection\framebuffer)

Global layer.Layer::ILayer = *layer
Procedure Update(*app.Application::Application_t)
  Scene::Update(*app\scene)
  LayerDefault::Draw(*layer, *app\scene)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
EndProcedure

Window::OnEvent(*app\window, #PB_Event_SizeWindow)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 46
; FirstLine = 7
; Folding = -
; EnableXP