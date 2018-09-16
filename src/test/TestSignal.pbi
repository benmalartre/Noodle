XIncludeFile "../core/Application.pbi"

Time::Init()
Globals::Init()
Controls::Init()

Procedure Update()
  Debug "APPLICATIOn LOOP"  
EndProcedure



Global *app.Application::Application_t = Application::New("TEST SIGNAL",800, 600)

Global *obj.Object3D::Object3D_t = Polymesh::New("Test",Shape::#Shape_Cube)

Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\manager\main, "UI", *obj)


Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New( *ui, "Property", "FUCK")
ControlProperty::AppendStart(*prop)
Global *btn1.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "Red", "RED", RGB(120,120,120))
Global *btn2.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "Green", "GREEN", RGB(120,120,120))
Global *btn3.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "Blue", "BLUE", RGB(120,120,120))


Global *color.ControlColor::ControlColor_t = ControlProperty::AddColorControl(*prop,"COLOR","COLOR",Color::_MAGENTA(),#Null)
Global color.ControlColor::IControlCOlor = *color
Object::SignalConnect(*color, *btn1\onleftclick_signal, 0)
Object::SignalConnect(*color, *btn2\onleftclick_signal, 1)
Object::SignalConnect(*color, *btn3\onleftclick_signal, 2)



ControlProperty::AppendStop(*prop)

PropertyUI::AddProperty(*ui, *prop)

Application::Loop(*app, @Update())


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 27
; Folding = -
; EnableXP