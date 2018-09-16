XIncludeFile "../core/Application.pbi"

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Controls::Init()
Commands::Init()
UIColor::Init()
CompilerIf #USE_ALEMBIC
  Alembic::Init()
CompilerEndIf

Global WIDTH = 800
Global HEIGHT = 600
Global *viewport.ViewportUI::ViewportUI_t
Global *default.Layer::Layer_t
Global *app.Application::Application_t

Procedure Update()
  ViewportUI::SetContext(*viewport)
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*default,*app\context)
  ViewportUI::FlipBuffer(*viewport)
EndProcedure

Procedure Callback(type.i, *sig.Signal::Signal_t)
  MessageRequester("CALLBACK" , "CALL 911 : "+StrF(*sig\sigdata))  
EndProcedure

Procedure BunnyCallback(*bunny.Polymesh::Polymesh_t)
  
EndProcedure


Structure MyObject_t Extends Object::Object_t
  
EndStructure

Procedure AddButton (*ui.PropertyUI::PropertyUI_t, name.s)
  OpenGadgetList(*ui\container)
  Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,0,*ui\width, 128)
  ControlProperty::AppendStart(*prop)
  Define *btn.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, name, name, RGB(128,128,128), *ui\width, 64)
  Object::SignalConnect(*prop, *btn\onleftclick_signal, @Callback())
  ControlProperty::AppendStop(*prop)
  PropertyUI::AddProperty(*ui, *prop)
  CloseGadgetList()
EndProcedure


Procedure AddProperty(*ui.PropertyUI::PropertyUI_t, name.s)
  OpenGadgetList(*ui\container)
  
  Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,128,*ui\width, *ui\height-128)

  ControlProperty::AppendStart(*prop)
  Define *head.ControlHead::ControlHead_t = ControlProperty::AddHead(*prop)
  Object::SignalConnect(*ui,*head\slot,0)

  Define v.Math::v3f32

  ControlProperty::AddVector3Control(*prop, "Vector3", "Vector3", @v, #Null)
  ; ; 
  ; ; ; ControlProperty::RowStart(*prop)
  ; ControlProperty::AddGroup(*prop, "Buttons")
  ; Define *btn.ControlButton::ControlButton_t
  ; Define i
  ; For i =0 To 3
  ;   
  ;   *btn = ControlProperty::AddButtonControl(*prop, "BUTTON "+Str(i), "BUTTON "+Str(i), RGB(128,128,128))
  ; Next
  ; ControlProperty::AddColorControl(*prop, "Color1", "Color1", Color::_GREEN(), #Null)
  ; ControlProperty::EndGroup(*prop)
  ; 
  ; 

  Define *color.ControlColor::ControlColor_t = ControlProperty::AddColorControl(*prop, "Color2", "Color2", Color::_BLUE(), #Null)
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
  CloseGadgetList()
  
  PropertyUI::AddProperty(*ui, *prop)
EndProcedure


*app = Application::New("Test Property",400,600,#PB_Window_SizeGadget|#PB_Window_SystemMenu)
Controls::SetTheme(Globals::#GUI_THEME_DARK)
Scene::*current_scene = Scene::New()
Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
Scene::AddChild(Scene::*current_scene,*bunny)
Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
Global *splitted.View::View_t = View::Split(*m\main, 0,75)
Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*splitted\right, "Property", #Null)
AddButton(*ui, "PUSH ME")
AddProperty(*ui.PropertyUI::PropertyUI_t, "TOTO")

Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*splitted\left, "Viewport")
*app\context = *viewport\context
*viewport\camera = *app\camera
ViewportUI::SetContext(*viewport)

*default = LayerDefault::New(*viewport\width, *viewport\height, *app\context, *app\camera)
ViewportUI::AddLayer(*viewport, *default)
Scene::Setup(Scene::*current_scene, *app\context)

Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; Folding = --
; EnableXP
; EnableUnicode