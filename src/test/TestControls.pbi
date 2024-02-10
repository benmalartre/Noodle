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

Procedure KissThatNumber(*ctl.ControlNumber::ControlNumber_t)
  Debug *ctl\class\name +" : "+ ControlNumber::GetValue(*ctl)
EndProcedure
Callback::DECLARE_CALLBACK(KissThatNumber, Types::#TYPE_PTR)

Procedure KissThatButton(*btn.ControlButton::ControlButton_t)
  Debug *btn\class\name
  Debug *btn\value
  Debug Str(*btn\state)
EndProcedure
Callback::DECLARE_CALLBACK(KissThatButton, Types::#TYPE_PTR)


Global *app.Application::Application_t = Application::New("Test Controls",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
UIColor::SetTheme(Globals::#GUI_THEME_Light)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\window\main, "Property")
Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, "Controls ", "Controls",0,128,*ui\sizX, *ui\sizY-128)
ControlProperty::AppendStart(*prop)

ControlProperty::AddGroup(*prop, "Group")
Define *steps.ControlNumber::ControlNumber_t = ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
Callback::CONNECT_CALLBACK(*steps\on_change, KissThatNumber, *steps)
ControlProperty::AddFloatControl(*prop, "Diffusion", "Diffusion", 0.05, #Null)
Define *enum.ControlEnum::ControlEnum_t = ControlProperty::AddEnumControl(*prop, "Enum", "Enum", #Null)
ControlEnum::AddItem(*enum, "one", 0)
ControlENum::AddItem(*enum, "two", 1)
ControlEnum::AddItem(*enum, "three", 2)
ControlProperty::EndGroup(*prop)

; Define color.c4f32
; ControlProperty::AddColorControl(*prop, "Color", "Color", color, #Null)
; Define *btn.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "Button", "Button", RGBA(255,128,128,255), 200,64, #True)
; Callback::CONNECT_CALLBACK(*btn\on_click, KissThatButton, *btn)
; ControlProperty::AddFileControl(*prop, "FILE", "Zob.scn", #Null)
; ControlProperty::AddBoolControl(*prop, "Bool", "Bool", #False, #Null)
; 
; ControlProperty::RowStart(*prop)
; ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_HOME, 32, 32)
; ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_ERROR, 32, 32)
; ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_FOLDER, 32, 32)
; ControlProperty::RowEnd(*prop)

; ControlProperty::AddKnobControl(*prop, "Knob", RGBA(255,255,100,255),100,100)
Define q.q4f32
ControlProperty::AddQuaternionControl(*prop, "quaternion", "quaternion", q, #Null)
Define m.m4f32
ControlProperty::AddMatrix4Control(*prop, "Matrix", "Matrix", m, #Null)

; Define *enum.ControlEnum::ControlEnum_t = ControlProperty::AddEnumControl(*prop, "Mode", "Mode", #Null)
; ControlEnum::AddItem(*enum, "Wireframe", 0)
; ControlEnum::AddItem(*enum, "Shader", 1)
; ControlEnum::AddItem(*enum, "Flat", 2)

ControlProperty::AppendStop(*prop)
PropertyUI::AddProperty(*ui, *prop)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 56
; FirstLine = 16
; Folding = -
; EnableXP