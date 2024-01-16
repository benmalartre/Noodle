XIncludeFile "../core/Demo.pbi"

UseModule Math
UseModule OpenGL
UseModule OpenGLExt

Procedure OnButtonClick(*btn.ControlButton::COntrolButton_t)
  Debug "Button Click "+*btn\name
EndProcedure
Callback::DECLARE_CALLBACK(OnButtonClick, Types::#Type_PTR)

Procedure AddButtonControl(*ui.PropertyUI::PropertyUI_t, name.s)
  Define *prop.ControlProperty::ControlProperty_t
  Define *btn.ControlButton::ControlButton_t 
  Define *group.ControlGroup::ControlGroup_t
  
  *prop = ControlProperty::New(*ui, name, name,0,0,*ui\sizX, 256)
  
  ControlProperty::AppendStart(*prop)
  
;   ControlProperty::RowStart(*prop)
;   Define i
;   For i=0 To 2
;     Define *knob.ControlKnob::ControlKnob_t = ControlProperty::AddKnobControl(*prop, name, RGBA(128,128,128,255), 64, 64)
;     ControlKnob::SetLimits(*knob, 1000,9000)
; ;     ( gadgetID.i, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
;   Next
;   ControlProperty::RowEnd(*prop)
;   *prop\dy + 64
;   
  *btn = ControlProperty::AddButtonControl(*prop, "fuck","fuck", UIColor::RANDOMIZED, 256,32)
  
  Callback::CONNECT_CALLBACK(*btn\on_click, OnButtonClick, *btn)
  

  ControlProperty::AddStringControl(*prop, "String", "Fuck Dat Shit", #Null)
  
  *group = ControlProperty::AddGroup(*prop, "Numbers")
  ControlProperty::RowStart(*prop)
  For i=0 To 3
        ControlProperty::AddFloatControl(*prop, "Number"+Str(i), "Number"+Str(i), i, #Null)
;     *btn = ControlProperty::AddButtonControl(*prop, "fuck","fuck", UIColor::RANDOMIZED, 256,32)
  Next
  ControlProperty::RowEnd(*prop)
  ControlProperty::EndGroup(*prop)
  
  ControlProperty::AppendStop(*prop)
  
  PropertyUI::AddProperty(*ui, *prop)
  
  ProcedureReturn *prop
  
EndProcedure


Procedure OnEcho()
  Debug "Test Control >SImple ECho Co Co cococococ !!"
EndProcedure
Callback::DECLARE_CALLBACK(OnEcho)

Procedure AddInputControl(*ui.PropertyUI::PropertyUI_t, name.s)
  Define *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, name, name,0,500,*ui\sizX, 128)
  
  ControlProperty::AppendStart(*prop)
  
  ControlProperty::AddGroup(*prop, "Heat Diffusion")
  ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
  ControlProperty::AddFloatControl(*prop, "Diffusion", "Diffusion", 0.05, #Null)
  ControlProperty::EndGroup(*prop)
  Define color.c4f32
  ControlProperty::AddColorControl(*prop, "Color", "Color", color, #Null)
  Define *btn.ControlButton::ControlButton_t = ControlProperty::AddButtonControl(*prop, "Button", "Button", RGBA(255,128,128,255), 200,64)
  Callback::CONNECT_CALLBACK(*btn\on_click, OnButtonClick, *btn)
  ControlProperty::AddFileControl(*prop, "FILE", "Zob.scn", #Null)
  ControlProperty::AddBoolControl(*prop, "Bool", "Bool", #False, #Null)
;   Define slide.f
;   ControlProperty::RowStart(*prop)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_HOME, 32, 32)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_ERROR, 32, 32)
;   ControlProperty::AddIconControl(*prop, "Icon", RGBA(0,255,128,255), Icon::#ICON_FOLDER, 32, 32)
;   ControlProperty::RowEnd(*prop)
;   ControlProperty::AddKnobControl(*prop, "Knob", RGBA(255,255,100,255),100,100)
;   Define q.q4f32
;   ControlProperty::AddQuaternionControl(*prop, "quaternion", "quaternion", q, #Null)
;   Define m.m4f32
;   ControlProperty::AddMatrix4Control(*prop, "matrix", "matrix", m, #Null)
  ControlProperty::AppendStop(*prop)
  
  
  PropertyUI::AddProperty(*ui, *prop)
  ProcedureReturn *prop
EndProcedure

Global *demo.DemoApplication::DemoApplication_t

Global *instancer.InstanceCloud::InstanceCloud_t = InstanceCloud::New("Instancer", Shape::#SHAPE_NONE,128)
Global *geom.Geometry::PointCloudGeometry_t = *instancer\geom
PointCloudGeometry::PointsOnSphere(*geom, 256, 5.0)

Global *prototype.Polymesh::Polymesh_t = Polymesh::New("mesh",Shape::#SHAPE_BUNNY)
PolymeshGeometry::ToShape(*prototype\geom,*instancer\shape)

Define width = 1200
Define height = 800

*demo = AllocateStructure(DemoApplication::DemoApplication_t)
DemoApplication::Init(*demo, "Test Control Simple",width,height)
*model = Model::New("Model")
Object3D::AddChild(*model, *instancer)


Scene::AddModel(*demo\scene, *model)
Scene::Setup(*demo\scene)
If *demo\explorer
  
  ExplorerUI::Connect(*demo\explorer, *demo\scene)
  ExplorerUI::OnEvent(*demo\explorer, Globals::#EVENT_NEW_SCENE, #Null)
EndIf

If *demo\property
  PropertyUI::Clear(*demo\property)
  PropertyUI::AppendStart(*demo\property)
  AddButtonControl(*demo\property, "group one")
  AddInputControl(*demo\property, "group two")
  PropertyUI::AppendStop(*demo\property)
EndIf 



 Application::Loop(*demo, DemoApplication::@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 71
; FirstLine = 64
; Folding = -
; EnableXP