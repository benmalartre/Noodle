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
Alembic::Init()


Global WIDTH = 800
Global HEIGHT = 600
Global *viewport.ViewportUI::ViewportUI_t
Global *default.Layer::Layer_t
Global *app.Application::Application_t

Procedure Update()
  
;   ViewportUI::SetContext(*viewport)
;   Scene::Update(Scene::*current_scene)
;   LayerDefault::Draw(*default,*app\context)
;   ViewportUI::FlipBuffer(*viewport)
EndProcedure

Procedure Callback()
  MessageRequester("CALLBACK" , "CALL 911")  
EndProcedure


*app = Application::New("Test Property",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
Controls::SetTheme(Globals::#GUI_THEME_DARK)
Scene::*current_scene = Scene::New()
Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
Scene::AddChild(Scene::*current_scene,*bunny)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*main, "Property", #Null)
OpenGadgetList(*ui\container)
; PropertyUI::Init(*ui)
Define *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, "test", "test",0,0,*main\width, *main\height)

ControlProperty::AppendStart(*prop)
ControlProperty::AddColorControl(*prop, "color1", "color1",Color::_MAGENTA(),#Null)
ControlProperty::AddColorControl(*prop, "color2", "color2",Color::_BLUE(),#Null)
ControlProperty::AddColorControl(*prop, "color3", "color3",Color::_RED(),#Null)
ControlProperty::AppendStop(*prop)
CloseGadgetList()

PropertyUI::AddProperty(*ui, *prop)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 33
; Folding = -
; EnableXP
; EnableUnicode