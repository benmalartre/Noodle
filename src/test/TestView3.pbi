XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
 
CompilerIf #USE_ALEMBIC
  Alembic::Init()
CompilerEndIf
; 
; Global WIDTH = 800
; Global HEIGHT = 600
Global *viewport.ViewportUI::ViewportUI_t
Global *layer.Layer::Layer_t
Global *app.Application::Application_t
; 
Procedure Update()
  GLContext::SetContext(*app\context)
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer,*app\context)
  GLContext::FlipBuffer(*app\context)
EndProcedure

Procedure NineOneOneCallback( message.s)
  MessageRequester("CALLBACK" , "CALL 911 : "+message)  
EndProcedure
Callback::DECLARECALLBACK(NineOneOneCallback, Arguments::#STRING)

Procedure BunnyCallback(*bunny.Polymesh::Polymesh_t)
EndProcedure
Callback::DECLARECALLBACK(BunnyCallback, Arguments::#PTR)


Structure MyObject_t Extends Object::Object_t
EndStructure
; 
; Procedure AddButton (*ui.PropertyUI::PropertyUI_t, name.s)
;   OpenGadgetList(*ui\container)
;   Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,0,*ui\sizX, *ui\sizY)
;   ControlProperty::AppendStart(*prop)
;   Define *btn.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, name, name, RGBA(128,128,128,255), *ui\sizX, 24)
;   Define message.s = "ZobiNickVraimentTout"
;   Signal::CONNECTCALLBACK(*btn\on_click, NineOneOneCallback, message)
;   ControlProperty::AppendStop(*prop)
;   PropertyUI::AddProperty(*ui, *prop)
;   CloseGadgetList()
; EndProcedure

Procedure AddKnobs (*ui.PropertyUI::PropertyUI_t, name.s)
  OpenGadgetList(*ui\container)
  Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,0,*ui\sizX, 128)
  ControlProperty::AppendStart(*prop)
  ControlProperty::RowStart(*prop)
  Define i
  For i=0 To 3
     Define *knob.ControlKnob::ControlKnob_t = ControlProperty::AddknobControl(*prop, name, RGBA(128,128,128,255), *ui\sizX/4)
  Next
  ControlProperty::RowEnd(*prop)
  *prop\dy + 128

  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
  CloseGadgetList()
EndProcedure


Procedure AddProperty(*ui.PropertyUI::PropertyUI_t, name.s)
  OpenGadgetList(*ui\container)
  
  Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,128,*ui\sizX, *ui\sizY-128)

  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)

  Define v.Math::v3f32

  ControlProperty::AddVector3Control(*prop, "Vector3", "Vector3", @v, #Null)
;   ControlProperty::RowStart(*prop)
;   ControlProperty::AddGroup(*prop, "Buttons")
;   Define *btn.ControlButton::ControlButton_t
;   Define i
;   For i =0 To 3
;     
;     *btn = ControlProperty::AddButtonControl(*prop, "BUTTON "+Str(i), "BUTTON "+Str(i), RGB(128,128,128))
;   Next
;   ControlProperty::AddColorControl(*prop, "Color1", "Color1", Color::_GREEN(), #Null)
;   ControlProperty::EndGroup(*prop)

  Define *color.ControlColor::ControlColor_t = ControlProperty::AddColorControl(*prop, "Color2", "Color2", UIColor::BLUE, #Null)
  Define icolor.ControlColor::IControlColor = *color
  
  
;   ControlGroup::RowStart(*group)
;   Define i
;   For i =0 To 6
;     
;     Object::SignalConnect(*color, *btn\onleftclick_signal, @Callback())
;   Next
;   
;   ControlGroup::RowEnd(*group)
;   ControlProperty::EndGroup(*prop)

  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
  CloseGadgetList()
EndProcedure

width = 1024
height = 720

*app = Application::New("Test Property",width,height,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
Scene::*current_scene = Scene::New()
Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
Scene::AddChild(Scene::*current_scene,*bunny)

Global *splitted.View::View_t = View::Split(*app\window\main, 0,75)
Define model.Math::m4f32
If Not #USE_GLFW
   *viewport = ViewportUI::New(*splitted\left,"ViewportUI", *app\camera, *app\handle)     
   *app\context = *viewport\context
   *app\context\writer\background = #True
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf
Camera::LookAt(*app\camera)
Matrix4::SetIdentity(model)

GLContext::SetContext(*app\context)
*layer = LayerDefault::New(*viewport\sizX,*viewport\sizY,*app\context,*app\camera)
Application::AddLayer(*app, *layer)
Scene::Setup(Scene::*current_scene, *app\context)


  
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*splitted\right, "Property", #Null)
; AddButton(*ui, "Button One")
; AddButton(*ui, "Button Two")
; AddButton(*ui, "Button Three")
AddKnobs(*ui, "FUCK")
; AddProperty(*ui.PropertyUI::PropertyUI_t, "TOTO")


Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 116
; FirstLine = 81
; Folding = --
; EnableXP
; EnableUnicode