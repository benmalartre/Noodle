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
Controls::SetTheme(Globals::#GUI_THEME_DARK)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*m\main, "Property", #Null)

OpenGadgetList(*ui\container)

Define name.s = "Prop"
Define i
For i=0 To 1
  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name+Str(i+1), name+Str(i+1),0,128,*ui\width, *ui\height-128)
  
  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)
  Object::SignalConnect(*ui, *head\ondelete_signal, 0)
  Object::SignalConnect(*ui, *head\onexpand_signal, 1)
  
  Define v.Math::v3f32
  ControlProperty::AddVector3Control(*prop, "Vector3", "Vector3", v, #Null)
  Define c.Math::c4f32
  ControlProperty::AddColorControl(*prop, "Color", "Color", c, #Null)
;   
  Define b.b
  ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)
  ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)
  ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)

  Define f.f
  ControlProperty::AddFloatControl(*prop, "Float", "Float", f, #Null)
  
  Define v2.v2f32
  ControlProperty::AddVector2Control(*prop, "Vector2", "Vector2", v2, #Null)
  
  Define q.q4f32
  ControlProperty::AddQuaternionControl(*prop, "Quaternion", "Quaternion", q, #Null)
;   
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
Next

CloseGadgetList()


Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 53
; Folding = -
; EnableXP