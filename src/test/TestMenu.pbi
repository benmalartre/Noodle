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
Scene::*current_scene  = Scene::New()


*menu.UI::UI_t = MenuUI::New(*top\left,"Menu")
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*top\right,"Viewport", *app\camera, *app\handle)
*app\context = *viewport\context
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
Debug "APP GL CONTEXT : "+Str(*app\context)

; ; *dummy1.UI::UI_t = DummyUI::New(*bottom\left,"Dummy1")
; *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*bottom\left,"Explorer")
; *graph.GraphUI::GraphUI_t = GraphUI::New(*bottom\right,"Graph")
; Scene::Setup(Scene::*current_scene ,*app\context)
; ; Application::OnEvent(*app,#PB_Event_SizeWindow)
; 
; *viewport\camera = *app\camera     
; 
; *mesh.Polymesh::Polymesh_t = Polymesh::New("Test",Shape::#SHAPE_BUNNY)
; Scene::AddChild(Scene::*current_scene,*mesh)
; 
; Scene::Setup(Scene::*current_scene,*app\context)
; 
; ControlExplorer::Fill(*explorer\explorer,Scene::*current_scene)
Global *layer.Layer::Layer_t = LayerDefault::New(800,600,*app\context,*app\camera)
Global *selection.Layer::Layer_t = LayerSelection::New(800,600,*app\context,*app\camera)

Global layer.Layer::ILayer = *layer
Procedure Update(*app.Application::Application_t)
  
  *app\context\width = GadgetWidth(*viewport\gadgetID)
  *app\context\height = GadgetHeight(*viewport\gadgetID)
  Scene::Update(Scene::*current_scene)
  layer\Draw(*app\context)
  SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
EndProcedure

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 32
; Folding = -
; EnableXP