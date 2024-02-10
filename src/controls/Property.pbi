XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "Divot.pbi"
XIncludeFile "Label.pbi"
XIncludeFile "Check.pbi"
XIncludeFile "Edit.pbi"
XIncludeFile "Number.pbi"
XIncludeFile "Enum.pbi"
XIncludeFile "Button.pbi"
XIncludeFile "Group.pbi"
XIncludeFile "Knob.pbi"
XIncludeFile "Color.pbi"

;========================================================================================
; Property Module Declaration
;========================================================================================
DeclareModule ControlProperty
  UseModule Math
  
  Structure ControlProperty_t Extends ControlGroup::ControlGroup_t
    valid     .b
    *object.Object::Object_t
    List *groups.ControlGroup::ControlGroup_t()

    decoration.i
    lock.Control::IControl
    refresh.Control::IControl
    dx.i
    dy.i
  EndStructure
  
  Interface IControlProperty Extends Control::IControl
  EndInterface
  
  Declare New(*parent.UI::UI_t,name.s,label.s,x.i=0,y.i=0,width.i=320,height.i=120,options=ControlGroup::#Group_Collapsable)
  Declare Delete(*Me.ControlProperty_t)
  Declare AppendStart( *Me.ControlProperty_t )
  Declare Append( *Me.ControlProperty_t, ctl.Control::IControl )
  Declare AppendStop( *Me.ControlProperty_t )
  Declare RowStart( *Me.ControlProperty_t )
  Declare RowEnd( *Me.ControlProperty_t )
  Declare AddBoolControl( *Me.ControlProperty_t, name.s,label.s,value.b,*attr.Attribute::Attribute_t)
  Declare AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*attr.Attribute::Attribute_t)
  Declare AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f,*attr.Attribute::Attribute_t)
  Declare AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*attr.Attribute::Attribute_t)
  Declare AddVector3Control(*Me.ControlProperty_t,name.s,label.s,*value.v3f32,*attr.Attribute::Attribute_t)
  Declare AddQuaternionControl(*Me.ControlProperty_t,name.s,label.s,*value.q4f32,*attr.Attribute::Attribute_t)
  Declare AddMatrix4Control(*Me.ControlProperty_t,name.s,label.s,*value.m4f32,*attr.Attribute::Attribute_t)
  Declare AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
  Declare AddStringControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
  Declare AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*attr.Attribute::Attribute_t)
  Declare AddButtonControl(*Me.ControlProperty_t, name.s,label.s, color.i, width=18, height=18, toggable.b=#False)
  Declare AddIconControl( *Me.ControlProperty_t, name.s, color.i, type.i, width=64, height=64)
  Declare AddKnobControl(*Me.ControlProperty_t, name.s,color.i, width.i=64, height.i=100)
  Declare AddFileControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
  Declare AddEnumControl( *Me.ControlProperty_t,name.s,label.s,*attr.Attribute::Attribute_t)
  Declare AddGroup( *Me.ControlProperty_t,name.s)
  Declare EndGroup( *Me.ControlProperty_t)
  Declare Init( *Me.ControlProperty_t)
  Declare Refresh( *Me.ControlProperty_t)
  Declare EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
  Declare Clear( *Me.ControlProperty_t )
  
  DataSection 
    ControlPropertyVT: 
    Data.i ControlGroup::@OnEvent()
    Data.i @Delete()
    Data.i ControlGroup::@Draw()
    Data.i ControlGroup::@DrawPickImage()
    Data.i ControlGroup::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  CONTROL PROPERTY MODULE IMPLEMENTATION 
; ============================================================================
Module ControlProperty
  UseModule Math
  
  Procedure OnCheckChange(*ctl.ControlCheck::ControlCheck_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)   
    Define *array.CArray::CArrayBool = *attr\data
    PokeB(*array\data + id * *array\itemSize + offset, *ctl\value)

    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnCheckChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnIntegerChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)   
    Define *array.CArray::CArrayInt = *attr\data
    PokeI(*array\data + id * *array\itemSize + offset, Val(*ctl\value))
    *attr\dirty = #True

    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnIntegerChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnFloatChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)
    Define *array.CArray::CArrayFloat = *attr\data
    PokeF(*array\data + id * *array\itemSize + offset, ValF(*ctl\value)) 
    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnFloatChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnReferenceChange(*ctl.ControlEdit::ControlEdit_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)
    Protected *obj.Object::Object_t = *attr\parent
    Select *obj\class\name
      Case "SetDataNode"
        Define *port.NodePort::NodePort_t = Node::GetPortByName(*obj, *attr\name)
        NodePort::SetReference(*port,*ctl\value)
        *port\attribute\dirty = #True

      Case "GetDataNode"
        Define *port.NodePort::NodePort_t = Node::GetPortByName(*obj, *attr\name)
        NodePort::SetReference(*port,*ctl\value)
        GetDataNode::ResolveReference(*port\node)
        *port\attribute\dirty = #True
        
      Default
        Define *array.CArray::CArrayStr = *attr\data
        *attr\dirty = #True
            
    EndSelect
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnReferenceChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnFileChange(*ctl.ControlEdit::ControlEdit_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)
;     Select *obj\class\name
;       Case "Attribute"
;         Define *attribute.Attribute::Attribute_t = *obj
;         
;         If *attribute
;           Define *array.CArray::CArrayStr = *attribute\data
;           CArray::SetCount(*array, 1)
;           CArray::SetValueStr(*array, 0, *ctl\value)
;           *attribute\dirty = #True
;         EndIf
;         
;       Case "NodePort"
;         Define *port.NodePort::NodePort_t = *obj
;         Define *attribute.Attribute::Attribute_t = *port\attribute
;         If *attribute
;           Define *array.CArray::CArrayStr = *attribute\data
;           CArray::SetCount(*array, 1)
;           CArray::SetValueStr(*array, 0, *ctl\value)
;           *attribute\dirty = #True
;         EndIf
;     EndSelect
;     PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnFileChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnStringChange(*ctl.ControlEdit::ControlEdit_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)
;     Select *obj\class\name
;       Case "Attribute"
;         Define *attribute.Attribute::Attribute_t = *obj
;         
;         If *attribute
;           Define *array.CArray::CArrayStr = *attribute\data
;           CArray::SetCount(*array, 1)
;           CArray::SetValueStr(*array, 0, *ctl\value)
;           *attribute\dirty = #True
;         EndIf
;         
;       Case "NodePort"
;         Define *port.NodePort::NodePort_t = *obj
;         Define *attribute.Attribute::Attribute_t = *port\attribute
;         If *attribute
;           Define *array.CArray::CArrayStr = *attribute\data
;           CArray::SetCount(*array, 1)
;           CArray::SetValueStr(*array, 0, *ctl\value)
;           *attribute\dirty = #True
;         EndIf
;     EndSelect
;     PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnStringChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  Procedure OnEnumChange(*ctl.ControlEnum::ControlEnum_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)   
;     Define *array.CArray::CArrayInt = *attr\data
;     PokeI(*array\data + id * *array\itemSize + offset, Val(*ctl\value))
;     *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnEnumChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)

  Procedure hlpNextItem( *Me.ControlGroup::ControlGroup_t )
    *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
    
    Protected iBound.i = *Me\chilcount - 1
    Protected n.i = (*me\current+1)%iBound
    
    Protected ev_data.Control::EventTypeDatas_t 
    *Me\focuschild = *Me\children(n)
    *Me\focuschild\OnEvent(#PB_EventType_Focus,ev_data)
  EndProcedure

  Procedure Clear( *Me.ControlProperty_t )
    Protected i
    Protected *ctl.Control::IControl
    Protected *c.Control::Control_t
    
    If ArraySize(*Me\children())>0
      
      For i=0 To *Me\chilcount-1
        *ctl = *Me\children(i)
        *c = *ctl
        If *ctl<>#Null : *ctl\Delete() : EndIf
      Next
      ReDim *Me\children(0)
      ReDim *Me\rowflags(0)
      *Me\chilcount = 0
    EndIf
    
    *Me\dx = 0
    *Me\dy = 0
    
    *Me\focuschild = #Null
    *Me\current = #Null
    *Me\overchild = #Null
  EndProcedure
 
  Procedure AppendStart( *Me.ControlProperty_t )
    If *Me\append : ProcedureReturn : EndIf
    *Me\append = #True
    *Me\dx + ControlGroup::#Group_Border_Margin
    *Me\dy + 20
  EndProcedure

  Procedure.i Append( *Me.ControlProperty_t, *ctl.Control::Control_t)
    If Not *ctl
      ProcedureReturn
    EndIf

    If #False = *Me\append
     ProcedureReturn #False
   EndIf
  
   If *Me\chilcount >= ArraySize( *Me\children() )
     ReDim *Me\children( *Me\chilcount + 10 )
     ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    *ctl\parent = *Me
    *Me\children( *Me\chilcount ) = *ctl

    *Me\rowflags( *Me\chilcount ) = *Me\row
    *Me\chilcount + 1
  
    ProcedureReturn( *ctl )
  
  EndProcedure

  Procedure AppendStop( *Me.ControlProperty_t )
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    *Me\append = #False
    *Me\sizY = ControlGroup::GetHeight(*Me)
    
    ResizeGadget(*Me\gadgetID,*Me\parent\posX +*Me\posY,*Me\parent\posY + *Me\posY,*Me\sizX,*Me\sizY)
    ControlGroup::OnEvent(*Me, #PB_EventType_Resize, #Null)
  EndProcedure

  Procedure RowStart( *Me.ControlProperty_t )
    If *Me\row : ProcedureReturn( void ) : EndIf
    *Me\row = #True
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
    EndIf
    
  EndProcedure

  Procedure RowEnd( *Me.ControlProperty_t )
    If *Me\chilcount>0 : *Me\rowflags( *Me\chilcount - 1) = #False : EndIf
    If Not *Me\row : ProcedureReturn( void ) : EndIf
    
    *Me\dy + 32
    *Me\row = #False
  EndProcedure

  Procedure AddButtonControl( *Me.ControlProperty_t, name.s,label.s, color.i,width=18, height=18, toggable.b=#False)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *btn.ControlButton::ControlButton_t
    Protected *Ctl.Control::Control_t
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
      If toggable
        *btn = ControlButton::New(*Me,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      Else
        *btn = ControlButton::New(*Me,name,name,#False, #PB_Button_Toggle,*Me\dx,*Me\dy+2,width,height, color )
      EndIf
      ControlGroup::Append(*Me\groups(),*btn)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
      If toggable
        *btn = ControlButton::New(*Me,name,name,#False, #PB_Button_Toggle,*Me\dx,*Me\dy+2,width,height, color )
      Else
        *btn = ControlButton::New(*Me,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      EndIf
      Append( *Me, *btn)
      If Not *Me\row : *Me\dy + height : Else : *Me\dx + width : EndIf
    EndIf
    ProcedureReturn(*btn)
  
  EndProcedure

  Procedure AddIconControl( *Me.ControlProperty_t, name.s, color.i, type.i, width=64, height=64)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *icon.ControlIcon::ControlIcon_t
    Protected *ctl.Control::Control_t
    
    If ListSize(*Me\groups())
      *icon = ControlIcon::New( *Me ,name, type, #False, #False , *Me\dx, *Me\dy, width, height )
      ControlGroup::Append(*Me\groups(),*icon)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
      *icon = ControlIcon::New( *Me ,name, type, #False, #False , *Me\dx, *Me\dy, width, height )
      Append( *Me, *icon)
      If *Me\row  : *Me\dx + width : Else : *Me\dy + height : EndIf
    EndIf
    
    ProcedureReturn(*icon)
  EndProcedure
  
  Procedure AddKnobControl( *Me.ControlProperty_t, name.s, color.i,width=64, height=100)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *knob.ControlKnob::ControlKnob_t
    Protected *ctl.Control::Control_t
    
     If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
    EndIf
     
    
    If ListSize(*Me\groups())
      *knob = ControlKnob::New(*Me,name,0, 0,*Me\dx,*Me\dy,width,height, color )
      ControlGroup::Append(*Me\groups(),*knob)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
      *knob = ControlKnob::New(*Me,name,0, 0,*Me\dx,*Me\dy,width,height, color )
      Append( *Me, *knob)
      If *Me\row  : *Me\dx + width : Else : *Me\dy + height : EndIf
    EndIf
    ProcedureReturn(*knob)
  EndProcedure
  
  Procedure AddBoolControl( *Me.ControlProperty_t, name.s,label.s,value.b,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *ctl.Control::Control_t
    
    If ListSize(*Me\groups())
      ControlGroup::RowStart(*Me\groups())
;       ControlGroup::Append(*Me\groups(),ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append(*Me\groups(),ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *ctl = ControlGroup::Append(*Me\groups(),ControlCheck::New(*Me,name+"Check",name, value,0,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      ControlGroup::RowEnd(*Me\groups())
    Else
      RowStart(*Me)
;       Append( *Me,ControlDivot::New(*Me,name+"Divot" ,ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append( *Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *ctl = Append( *Me,ControlCheck::New(*Me, name+"Check",name, value, 0,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      RowEnd(*Me)
    EndIf
    
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnCheckChange, *ctl, *attr, 0, 0)
    EndIf
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  Procedure AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*attr.Attribute::Attribute_t)
    If Not*Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
     ControlGroup::RowStart( *Me\groups())
;       ControlGroup::Append( *Me\groups(), ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx,*Me\dy,60,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+width*0.25,*Me\dy,width*0.75,18)
      ControlGroup::Append( *Me\groups(), *ctl  )
      ControlGroup::RowEnd( *Me\groups())
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
      RowStart(*Me)
;       Append(*Me,ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx,*Me\dy,60,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+width*0.25,*Me\dy,width*0.75,18)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf

    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnIntegerChange, *ctl, *attr, 0, 0)
    EndIf
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  Procedure AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f, *attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
        
    If ListSize(*Me\groups())
      ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,60,21 ))
      *ctl =  ControlNumber::New(*Me, name+"Number", value, ControlNumber::#NUMBER_SCALAR, -1000, 1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) 
      ControlGroup::Append(*Me\groups(), *ctl)
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,60,21 ))
      *ctl = ControlNumber::New(*Me, name+"Number", value, ControlNumber::#NUMBER_SCALAR, -1000, 1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf
    
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnFloatChange, *ctl, *attr, 0, 0)
    EndIf
        
    ProcedureReturn(*ctl)
  EndProcedure
  
  Procedure AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    *Me\dy + 10
    Protected w= *Me\sizX/3
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/2
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
;     ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    If *attr
      Callback::CONNECT_CALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Callback::CONNECT_CALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
    EndIf
    
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

  Procedure AddVector3Control(*Me.ControlProperty_t, name.s, label.s, *value.v3f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    Protected w = *Me\sizX/4
    
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/3
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ControlGroup::Append(*group, ControlLabel::New(*Me,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *zCtl = ControlNumber::New(*Me,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *zCtl)
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf

    If *attr
      Callback::CONNECT_CALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Callback::CONNECT_CALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
      Callback::CONNECT_CALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
    EndIf
    
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

  Procedure AddVector4Control(*Me.ControlProperty_t,name.s,label.s,*value.v4f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected options.i = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/3
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    
    ControlGroup::AppendStart(*Me)
    ControlGroup::RowStart(*Me)
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me, "XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "XLabel","X",#False,0,*Me\dx+20,*Me\dy,120,21 ))
    Define *xCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me, "YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "YLabel","Y",#False,0,*Me\dx+width+20,*Me\dy,120,21 ))
    Define *yCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me, "ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
    Define *zCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me, "WDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
    Define *wCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, ">Number",*value\w,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    If *obj
      Callback::CONNECT_CALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Callback::CONNECT_CALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
      Callback::CONNECT_CALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
      Callback::CONNECT_CALLBACK(*zCtl\on_change, OnFloatChange, *wCtl, *attr, 0, 12)
    EndIf
    
    *Me\dy + *group\sizY
  
    ProcedureReturn(#True)
  EndProcedure
  
  Procedure AddQuaternionControl(*Me.ControlProperty_t, name.s, label.s, *value.q4f32, *attr.Attribute::Attribute_t)

    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    
    Protected options.i = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 50 ,options)
    
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    Protected *aCtl.Control::Control_t

    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    Protected w= *Me\sizX/4
;     ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlGroup::Append(*group,ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
    
;     ControlGroup::Append(*group, ControlDivot::New(*Me,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *zCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )

;     ControlGroup::Append(*group, ControlDivot::New(*Me,"AngleDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"AngleLabel","Angle",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *aCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"AngleNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
  
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    If *attr
      Callback::CONNECT_CALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Callback::CONNECT_CALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
      Callback::CONNECT_CALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
      Callback::CONNECT_CALLBACK(*aCtl\on_change, OnFloatChange, *aCtl, *attr, 0, 12)
    EndIf
    
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  
  EndProcedure

  Procedure AddMatrix4Control(*Me.ControlProperty_t, name.s, label.s, *value.m4f32, *attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl

    Protected options.i = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 200 ,options)
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
    EndIf
    
    ControlGroup::AppendStart(*group)
    Protected i
    For i=0 To 3
    
      ControlGroup::RowStart(*group)
    
      Protected w= *Me\sizX/4
;       ControlGroup::Append(*group,ControlDivot::New(*Me,"M"+Str(i)+"0Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"0Label","M"+Str(i)+"0",#False,0,*Me\dx+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"0Number",*value\v[i*4],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
      
;       ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"1Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
      ControlGroup::Append(*group,ControlLabel::New(*Me,"M"+Str(i)+"1Label","M"+Str(i)+"1",#False,0,*Me\dx+width+20,14,120,21 ))
      ControlGroup::Append(*group,ControlNumber::New(*Me,"M"+Str(i)+"1Number",*value\v[i*4+1],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )

;       ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"2Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"2Label","M"+Str(i)+"2",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"2Number",*value\v[i*4+2],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
      
;       ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"3Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"3Label","M"+Str(i)+"3",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"3Number",*value\v[i*4+3],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
    
      ControlGroup::RowEnd(*group)
      *Me\posY +50
    Next
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

  Procedure AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options.i = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width, 200 ,options)

    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *Ctl = ControlEdit::New(*Me,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*Ctl)
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnReferenceChange, *ctl, *attr, 0, 0)
    EndIf
    
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  Procedure AddFileControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected *btn.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-5
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
    EndIf
    
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 )

    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *ctl = ControlEdit::New(*Me,"File", "File",#False,*Me\dx,*Me\dy+2,(width-60),24) 
    ControlGroup::Append( *group,*ctl)
    *btn = ControlButton::New(*Me, "Pick", "...",#False,0,0)
    ControlGroup::Append( *group,*btn)
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnFileChange, *ctl, *attr, 0, 0)
    EndIf
    
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure

  Procedure AddEnumControl( *Me.ControlProperty_t,name.s,label.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *ctl.Control::Control_t
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
      ControlGroup::RowStart(*Me\groups())
;       ControlGroup::Append(*Me\groups(),ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append(*Me\groups(),ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx,*Me\dy,(width-20)*0.25,21 ))
      *ctl = ControlGroup::Append(*Me\groups(),ControlEnum::New(*Me,name+"Check",name,*Me\dx+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      ControlGroup::RowEnd(*Me\groups())
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
      RowStart(*Me)
;       Append( *Me,ControlDivot::New(*Me,name+"Divot" ,ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append( *Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx,*Me\dy,(width-20)*0.25,21 ))
      *ctl = Append( *Me,ControlEnum::New(*Me, name+"Check",name,*Me\dx+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      RowEnd(*Me)
    EndIf
   
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnCheckChange, *ctl, *attr, 0, 0)
    EndIf
    
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  Procedure AddStringControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
   
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *ctl = ControlEdit::New(*Me,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*ctl)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me, *group)
    EndIf

    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnStringChange, *ctl, *attr, 0, 0)
    EndIf
    
    *Me\dy +*group\sizY
    ProcedureReturn *ctl
  EndProcedure

  Procedure AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-5
    
    If ListSize(*Me\groups())
      *Me\dx = *Me\groups()\posX + ControlGroup::#Group_Border_Margin
    Else
      *Me\dx = ControlGroup::#Group_Border_Margin
    EndIf
    
    Protected options = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    Define *color.ControlColor::ControlColor_t = ControlColor::New(*Me, name+"_Color",name+"_Color",*value,*Me\dx,*Me\dy+2,(width-110),18)
    
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    ControlGroup::Append(*group, *color)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
     If ListSize(*Me\groups())
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me, *group)
    EndIf

    
    *Me\dy + *group\sizY 
    ProcedureReturn(*color)
  EndProcedure
  
  Procedure AddGroup( *Me.ControlProperty_t,name.s)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID) - 2 * ControlGroup::#Group_Border_Margin
    *Me\dx + ControlGroup::#Group_Border_Margin
        
    Protected options = ControlGroup::#Group_Autostack|ControlGroup::#Group_Autosize_V
    AddElement(*Me\groups())
    *Me\groups() = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)

    Append(*Me,*Me\groups())
    
    ControlGroup::AppendStart(*Me\groups())
    
    *Me\dy + ControlGroup::#Group_Frame_Height
    ProcedureReturn(*group)
  EndProcedure
  
  Procedure EndGroup( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    
    If Not ListSize(*Me\groups()) : ProcedureReturn : EndIf
    *Me\dx - ControlGroup::#Group_Border_Margin
;     *Me\dy + ControlGroup::#Group_Frame_Height
   
    ControlGroup::AppendStop(*Me\groups())
    DeleteElement(*Me\groups())
   
    ProcedureReturn(#Null)
  EndProcedure

  Procedure Init( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    ControlGroup::DrawPickImage(*Me)
    ControlGroup::Draw(*Me)
    
    ProcedureReturn(#True)
  EndProcedure

  Procedure Refresh( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    ProcedureReturn(#True)
  EndProcedure
  
  Procedure EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
    Protected *son.Control::IControl
    Protected i
    For i=0 To *Me\chilcount-1
      *son = *Me\children(i)
      *son\OnEvent(ev_type,#Null)
    Next i
  EndProcedure

  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlProperty_t )
    If Not *Me : ProcedureReturn : EndIf
    Protected c
    
    Protected ictl.Control::IControl
    For c=0 To *Me\chilcount-1
      ictl = *Me\children(c)
      ictl\Delete()
    Next
    If IsGadget(*Me\gadgetID) : FreeGadget(*Me\gadgetID) : EndIf
    If IsImage(*Me\imageID) : FreeImage(*Me\imageID) : EndIf
    
    Object::TERM(ControlProperty)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.UI::UI_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,options=ControlGroup::#Group_Collapsable)
    Protected *Me.ControlProperty_t = AllocateStructure(ControlProperty_t)
    
    Object::INI(ControlProperty)
    
    *Me\object     = #Null
    *Me\parent     = *parent
    *Me\type       = #PB_GadgetType_Container
    *Me\name       = name
    *Me\gadgetID   = *parent\gadgetID
    *Me\imageID    = CreateImage(#PB_Any,width,height)
    SetGadgetColor(*Me\gadgetID,#PB_Gadget_BackColor,UIColor::COLOR_MAIN_BG )
  
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\label      = label
    *Me\visible    = #True
    *Me\enable     = #True 
    *Me\options    = options
    *Me\state      = Control::#State_Enable
    
    View::SetContent(*parent,*Me)
   
    ProcedureReturn *Me
    
  EndProcedure
  
  Class::DEF(ControlProperty)
EndModule
; ============================================================================
;  EOF
; ============================================================================

      
      
    
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 258
; FirstLine = 108
; Folding = DEzJCM9
; EnableXP