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

Procedure Update()
  
EndProcedure

Procedure AddKnobs (*ui.PropertyUI::PropertyUI_t, name.s)
  OpenGadgetList(*ui\container)
  Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,0,*ui\width, 128)
  ControlProperty::AppendStart(*prop)
  ControlProperty::RowStart(*prop)
  Define i
  For i=0 To 2
    Define *knob.ControlKnob::ControlKnob_t = ControlProperty::AddKnobControl(*prop, name, RGBA(128,128,128,255), 256, 256)
    ControlKnob::SetLimits(*knob, 1000,9000)
;     ( gadgetID.i, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
  Next
  ControlProperty::RowEnd(*prop)
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
  CloseGadgetList()
EndProcedure

Global *app.Application::Application_t = Application::New("Test Knob",512,512,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
Controls::SetTheme(Globals::#GUI_THEME_DARK)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
; Global *splitted.View::View_t = View::Split(*m\main, 0,75)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*main, "Property", #Null)
AddKnobs(*ui, "KNOB")

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP