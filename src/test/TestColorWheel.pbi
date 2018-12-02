XIncludeFile "../core/Application.pbi"

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Procedure Update()
EndProcedure


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Controls::Init()
Commands::Init()
UIColor::Init()



Global *app.Application::Application_t = Application::New("Test Controls",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
; Controls::SetTheme(Globals::#GUI_THEME_DARK)
Controls::SetTheme(Globals::#GUI_THEME_LIGHT)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*m\main, "Property", #Null)

OpenGadgetList(*ui\container)

Define name.s = "Prop"
Define i
For i=0 To 0
  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name+Str(i+1), name+Str(i+1),0,128,*ui\width, *ui\height-128)
  
  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)

  Object::SignalConnect(*ui, *head\ondelete_signal, 0)
  Object::SignalConnect(*ui, *head\onexpand_signal, 1)
  
  Define v.Math::v3f32
  ControlProperty::AddColorWheelControl(*prop, "ColorWheel")
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
Next

CloseGadgetList()


Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 31
; Folding = -
; EnableXP