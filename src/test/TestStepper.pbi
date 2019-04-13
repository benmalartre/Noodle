XIncludeFile "../core/Application.pbi"
XIncludeFile "../controls/Number.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../controls/Controls.pbi"
Globals::Init()
Controls::Init()
Time::Init()
UIColor::Init()
; txt = TextGadget(#PB_Any,2,5,25,25,"Red")
; input = StringGadget(#PB_Any,25,0,25,25,"0.0",#PB_String_Numeric)
; up = ButtonGadget(#PB_Any,50,2,20,10,"N")
; down = ButtonGadget(#PB_Any,50,13,20,10,"U")

Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Mesh",Shape::#SHAPE_CUBE)
Define msg.s = "ATTRIBUTES : "+Chr(10)
ForEach *mesh\m_attributes()
  msg + *mesh\m_attributes()\name + ","+Str(Bool(*mesh\m_attributes()\datastructure = Attribute::#ATTR_STRUCT_SINGLE))+Chr(10)
Next
MessageRequester("ATTRIBUTES",msg)

Global window = OpenWindow(#PB_Any,0,0,800,600,"Property",#PB_Window_SystemMenu|#PB_Window_SizeGadget)
; Global container = ContainerGadget(#PB_Any,0,0,800,600)
; SetGadgetColor(container,#PB_Gadget_BackColor,RGB(255,0,0))
*prop = ControlProperty::New(*mesh,"mesh","mesh",200,0,32,32)
ControlProperty::AppendStart(*prop)
ControlProperty::Append(*prop,ControlIcon::New(*mesh,"Back",ControlIcon::#Icon_Back,0,#False,0))
; ControlProperty::AddBoolControl(*prop,"boolean","boolean",#False,*mesh)
; ControlProperty::AddFloatControl(*prop,"float","float",#False,*mesh)
; ControlProperty::AddIntegerControl(*prop,"integer","integer",#False,*mesh)
; ControlProperty::AddReferenceControl(*prop,"reference1","ref1",*mesh)
; ControlProperty::AddReferenceControl(*prop,"reference2","ref2",*mesh)
; ControlProperty::AddReferenceControl(*prop,"reference3","ref3",*mesh)
; *group = ControlProperty::AddGroup(*prop,"BUTTON")
; 
; ControlGroup::Append(*group,ControlButton::New(*prop,"button","button",#True,#PB_Button_Toggle))
; ControlProperty::EndGroup(*prop)
; 
; 
; 
; Define q.Math::q4f32
; Quaternion::SetIdentity(@q)
; ControlProperty::AddQuaternionControl(*prop,"quaternion","quat",@q,*mesh)
; 
; *group = ControlProperty::AddGroup(*prop,"ICONS")
; ControlGroup::RowStart(*group)
; ControlGroup::Append(*group,ControlIcon::New(*mesh,"Back",ControlIcon::#Icon_Back,0))
; ControlGroup::Append(*group,ControlIcon::New(*mesh,"Stop",ControlIcon::#Icon_Stop,0))
; ControlGroup::Append(*group,ControlIcon::New(*mesh,"Play",ControlIcon::#Icon_Play,#PB_Button_Toggle))
; ControlGroup::Append(*group,ControlIcon::New(*mesh,"Loop",ControlIcon::#Icon_Loop,0))
; ControlGroup::RowEnd(*group)
; ControlProperty::EndGroup(*prop)


; ControlProperty::Append(*prop,ControlTimeline::New(#Null,window,0,WindowHeight(window)-100,WindowWidth(window),100))

ControlProperty::AppendStop(*prop)

; CloseGadgetList()

Repeat
  e=WaitWindowEvent()
  Select e
    Case Globals::#EVENT_PARAMETER_CHANGED
        ;MessageRequester("Parameter Changed",PeekS(EventData()))
      Case Globals::#EVENT_BUTTON_PRESSED
        MessageRequester("Button Pressed",PeekS(EventData()))
    Case #PB_Event_SizeWindow
      Define datas.Control::EventTypeDatas_t 
      datas\x = 0
      datas\y = 0
      datas\width = WindowWidth(window)
      datas\height = WindowHeight(window)
      ControlProperty::Event(*prop,Control::#PB_EventType_Resize,@datas)
      Case Globals::#EVENT_PARAMETER_CHANGED
        Debug("PARAMETER CHANGED -------------> EVENT")
        d = EventData()
        If d
          Debug "Event Data ---> "+PeekS(d)
        EndIf
      Default
        ControlProperty::Event(*prop,EventType(),#Null)
        
    EndSelect
    
  
Until e = #PB_Event_CloseWindow

; *stepper1.ControlStepper::ControlStepper_t = ControlStepper::New(*mesh,"Test1",0,0,80,30)
; *stepper2.ControlStepper::ControlStepper_t = ControlStepper::New(*mesh,"Test2",80,0,80,30)
; *stepper3.ControlStepper::ControlStepper_t = ControlStepper::New(*mesh,"Test3",0,30,80,30)
; *stepper4.ControlStepper::ControlStepper_t = ControlStepper::New(*mesh,"Test4",80,30,80,30)
; Define NewList *steppers.ControlStepper::ControlStepper_t()
; AddElement(*steppers())
; *steppers() = *stepper1
; AddElement(*steppers())
; *steppers() = *stepper2
; AddElement(*steppers())
; *steppers() = *stepper3
; AddElement(*steppers())
; *steppers() = *stepper4
; 
; Define e
; Repeat
;   e = WaitWindowEvent()
;   ForEach *steppers()
;     stepper.ControlStepper::IControlStepper = *steppers()
;     stepper\Event(e,#Null)
;   Next
;   If e = Globals::#EVENT_PARAMETER_CHANGED
;     Debug "-------------------------- PARAMETER CHANGED -----------------------"  
;     Define *obj.Object::Object_t = EventGadget()
;     Debug "OBJECT CLASS NAME : "+*obj\classname
;   EndIf
;   
; Until e = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 34
; FirstLine = 30
; EnableXP