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
For i=0 To 1
  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name+Str(i+1), name+Str(i+1),0,128,*ui\width, *ui\height-128)
  
  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)
  
   ControlProperty::RowStart(*prop)
  Define i
  For i=0 To 2
    Define *knob.ControlKnob::ControlKnob_t = ControlProperty::AddKnobControl(*prop, name, RGBA(128,128,128,255), 64, 64)
    ControlKnob::SetLimits(*knob, 1000,9000)
;     ( gadgetID.i, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
  Next
  ControlProperty::RowEnd(*prop)
  *prop\dy + 64
  ;   
  
;   Object::SignalConnect(*ui, *head\ondelete_signal, 0)
;   Object::SignalConnect(*ui, *head\onexpand_signal, 1)
  
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
 
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
Next

CloseGadgetList()


Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 49
; FirstLine = 19
; Folding = -
; EnableXP