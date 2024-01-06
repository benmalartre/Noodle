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
  ControlProperty::AddGroup(*prop, "Group")
  ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
  ControlProperty::AddFloatControl(*prop, "Diffusion", "Diffusion", 0.05, #Null)
  ControlProperty::EndGroup(*prop)
  Define color.c4f32
  ControlProperty::AddColorControl(*prop, "Color", "Color", color, #Null)
  ControlProperty::AddButtonControl(*prop, "Button", "Button", RGBA(255,128,128,255), 200,64)
  ControlProperty::AddFileControl(*prop, "FILE", "Zob.scn", #Null)
  ControlProperty::AddBoolControl(*prop, "Bool", "Bool", #False, #Null)
;   Define slide.f
;   ControlProperty::AddSliderControl(*prop, "Slider", "Slider", slide, 0, 100, #Null)
;   ControlProperty::RowStart(*prop)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_HOME, 32, 32)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_ERROR, 32, 32)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_FOLDER, 32, 32)
;   ControlProperty::RowEnd(*prop)
;   ControlProperty::AddKnobControl(*prop, "Knob", RGBA(255,255,100,255),100,100)
;   Define q.q4f32
;   ControlProperty::AddQuaternionControl(*prop, "quaternion", "quaternion", q, #Null)
;   Define m.m4f32
;   ControlProperty::AddMatrix4Control(*prop, "Matrix", "Matrix", m, #Null)
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 42
; FirstLine = 2
; Folding = -
; EnableXP