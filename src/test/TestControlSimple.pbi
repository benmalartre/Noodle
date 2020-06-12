XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Procedure Update()
EndProcedure

Procedure OnEcho(message.s)
  Debug("SLD:  SLD SLD : "+message)
EndProcedure
Callback::DECLARECALLBACK(OnEcho, Arguments::#STRING)

Procedure OnButtonClick(msg.s)
  Debug("CLK : BTN CLK : "+msg)
EndProcedure
Callback::DECLARECALLBACK(OnButtonClick, Arguments::#STRING)

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()




Procedure AddButtonControl(*ui.PropertyUI::PropertyUI_t, name.s)


   Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,128,*ui\sizX, *ui\sizY-128)
  
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
  
  Define *btn.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "fuck","fuck", UIColor::RANDOMIZED, 256,32)
  
  Signal::CONNECTCALLBACK(*btn\on_click, OnButtonClick, HELLO)
EndProcedure


Procedure AddInputControl(*ui.PropertyUI::PropertyUI_t, name.s)
  Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,128,*ui\sizX, 128)
  
  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)
  
  ControlProperty::RowStart(*prop)
  ControlProperty::AddSliderControl(*prop, name, name,0, 0,100,#Null)
  Define *slider.ControlSlider::ControlSlider_t = ControlProperty::GetControlByName(*prop, name+"Slider")
  Debug "SLIDER = "+Str(*slider)
  Signal::CONNECTCALLBACK(*slider\on_change, OnEcho, SLIDIN)
;     ( gadgetID.i, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
 
  ControlProperty::RowEnd(*prop)
  *prop\dy + 64
EndProcedure


Global *app.Application::Application_t = Application::New("Test Control Simple",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\window\main, "Property", #Null)

OpenGadgetList(*ui\container)

Define name.s = "Prop"
Define i
;AddInputControl(*ui, "Input")
AddButtonControl(*ui, "Button")

 
  ;   
;   
; ;   Object::SignalConnect(*ui, *head\ondelete_signal, 0)
; ;   Object::SignalConnect(*ui, *head\onexpand_signal, 1)
;   
;   Define v.Math::v3f32
;   ControlProperty::AddVector3Control(*prop, "Vector3", "Vector3", v, #Null)
;   Define c.Math::c4f32
;   ControlProperty::AddColorControl(*prop, "Color", "Color", c, #Null)
; ;   
;   Define b.b
;   ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)
;   ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)
;   ControlProperty::AddBoolControl(*prop, "Boolean", "Boolean", b, #Null)
; 
;   Define f.f
;   ControlProperty::AddFloatControl(*prop, "Float", "Float", f, #Null)
;   
;   Define v2.v2f32
;   ControlProperty::AddVector2Control(*prop, "Vector2", "Vector2", v2, #Null)
;   
;   Define q.q4f32
;   ControlProperty::AddQuaternionControl(*prop, "Quaternion", "Quaternion", q, #Null)
 
  
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)


CloseGadgetList()


Application::Loop(*app,@Update())

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 71
; FirstLine = 50
; Folding = -
; EnableXP