XIncludeFile "../core/Application.pbi"


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

Procedure KissThatButton(*Me.Object::Object_t)
  Debug "KISS THAT BUTTON BI-ATCH!"
EndProcedure
Callback::DECLARECALLBACK(KissThatButton, Arguments::#PTR)


Global *app.Application::Application_t = Application::New("Test Controls",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
; Controls::SetTheme(Globals::#GUI_THEME_DARK)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\window\main, "Property", #Null)

Define name.s = "Prop"
Define i

  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, "HeatDiffusion ", "Controls",0,128,*ui\sizX, *ui\sizY-128)
  
  ControlProperty::AppendStart(*prop)
  ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
  ControlProperty::AddFloatControl(*prop, "Diffusion", "Diffusion", 0.05, #Null)
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 26
; Folding = -
; EnableXP