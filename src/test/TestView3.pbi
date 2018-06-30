XIncludeFile "../core/Application.pbi"

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Controls::Init()
Commands::Init()
UIColor::Init()

Global WIDTH = 800
Global HEIGHT = 600
Global *viewport.ViewportUI::ViewportUI_t
Global *default.Layer::Layer_t
Global *app.Application::Application_t

Procedure Update()
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*default,*app\context)
  SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
EndProcedure

*app = Application::New("Graph UI",1200,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)
Scene::*current_scene = Scene::New()
Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
Scene::AddChild(Scene::*current_scene,*bunny)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)

Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,60)

Define *ui1.UI::UI_t = DummyUI::New(*top\left,"Top")
Define *ui2.UI::UI_t = DummyUI::New(*middle\right,"MiddleRight")
;Define *ui3.UI::UI_t = DummyUI::New(*center\right,"CenterRight")
Define *ui3.UI::Ui_t = ViewportUI::New(*center\right,"CenterRight")
*viewport = *ui3
Define *ui4.UI::UI_t = DummyUI::New(*center\left,"CenterLeft")
;Define *ui5.UI::UI_t = DummyUI::New(*bottom\left,"Bottom")
Define *ui5.UI::UI_t = GraphUI::New(*bottom\left,"Bottom")
;Define *ui6.UI::UI_t = DummyUI::New(*bottom\right,"Timeline")
Define *timeline.TimelineUI::TimelineUI_t = TimelineUI::New(*bottom\right,"Timeline")

*default = LayerDefault::New(1200,600,*viewport\context,Scene::*current_scene\camera)
*app\context = *viewport\context
Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 52
; Folding = -
; EnableUnicode
; EnableXP