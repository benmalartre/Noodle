;#USE_GLFW = #False
XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Global WIDTH = 1200
Global HEIGHT = 600


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()
CompilerIf #USE_ALEMBIC
  Alembic::Init()
CompilerEndIf



Define *app.Application::Application_t = Application::New("Vector Canvas",1200,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)
Define *window.Window::Window_t = *app\window
Global *main.View::View_t = *window\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)
Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,60)


Global *menu.MenuUI::MenuUI_t = MenuUI::New(*top\left,"Menu")
Global *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
; ExplorerUI::Connect(*explorer, Scene::*current_scene)

Global *canvas.CanvasUI::CanvasUI_t = CanvasUI::New(*center\right,"Canvas")

Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*middle\right,"Property",#Null)

Window::OnEvent(*app\window, #PB_Event_SizeWindow)

Procedure Update(*app.Application::Application_t)
;   GLContext::SetContext(*app\context)
;   
;   Scene::Update(Scene::*current_scene)
;   Application::Draw(*app, *layer, *viewport\camera)
;   
;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Graph Tree",-0.9,0.9,ss,ss*ratio)
;   FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
;   FTGL::Draw(*app\context\writer,"Nb Objects : "+Str(Scene::GetNbObjects(Scene::*current_scene)),-0.9,0.7,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
;   
; 
;   GLContext::FlipBuffer(*app\context)
EndProcedure


Define e.i

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 32
; FirstLine = 6
; Folding = -
; EnableXP