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
Commands::Init()
UIColor::Init()



Global *app.Application::Application_t = Application::New("Test Controls",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
; Controls::SetTheme(Globals::#GUI_THEME_DARK)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\window\main, "Property", #Null)


Define name.s = "Prop"
Define i
For i=0 To 0
  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name+Str(i+1), name+Str(i+1),0,128,*ui\sizX, *ui\sizY-128)
  
  ControlProperty::AppendStart(*prop)
;   Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)


;   Object::SignalConnect(*ui, *head\ondelete_signal, 0)
;   Object::SignalConnect(*ui, *head\onexpand_signal, 1)
  
  Define v.Math::v3f32
  ControlProperty::AddColorWheelControl(*prop, "ColorWheel")
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
Next



Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 38
; Folding = -
; EnableXP