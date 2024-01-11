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
XIncludeFile "Head.pbi"
XIncludeFile "Knob.pbi"
XIncludeFile "Color.pbi"

;========================================================================================
; Property Module Declaration
;========================================================================================
DeclareModule ControlProperty
  UseModule Math
  #HEAD_HEIGHT = 24
  
  Enumeration 
    #PROPERTY_FLAT
    #PROPERTY_LABELED
  EndEnumeration
  
  Structure ControlProperty_t Extends ControlGroup::ControlGroup_t
    valid     .b
    *object.Object::Object_t
    *head.ControlHead::ControlHead_t
    List *groups.ControlGroup::ControlGroup_t()

    decoration.i
    lock.Control::IControl
    refresh.Control::IControl
    dx.i
    dy.i
    
    slotID.i
  EndStructure
  
  Interface IControlProperty Extends Control::IControl
  EndInterface
  
  Declare New(*parent.UI::UI_t,name.s,label.s,x.i=0,y.i=0,width.i=320,height.i=120,decoration=#PROPERTY_LABELED)
  Declare Delete(*Me.ControlProperty_t)
  Declare OnEvent( *Me.ControlProperty_t,ev_code.i,*ev_data.Control::EventTypeDatas_t = #Null)  
  Declare Draw( *Me.ControlProperty_t)
  Declare AppendStart( *Me.ControlProperty_t )
  Declare Append( *Me.ControlProperty_t, ctl.Control::IControl )
  Declare AppendStop( *Me.ControlProperty_t )
  Declare RowStart( *Me.ControlProperty_t )
  Declare RowEnd( *Me.ControlProperty_t )
  Declare AddHead( *Me.ControlProperty_t)
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
  Declare.i GetWidth(*Me.ControlProperty_t)
  Declare.i GetHeight(*Me.ControlProperty_t)
  Declare GetControlByIndex(*Me.ControlProperty_t, index.i)
  Declare GetControlByName(*Me.ControlProperty_t, name.s)
  
  DataSection 
    ControlPropertyVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
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
  
  Procedure OnLongChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)    
    Define *array.CArray::CArrayLong = *attr\data
    PokeB(*array\data + id * *array\itemSize + offset, *ctl\down)
    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnLongChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
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
    
    Debug "on enum changed!!!"

    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnEnumChange, Types::#TYPE_PTR, Types::#TYPE_PTR, Types::#TYPE_INT, Types::#TYPE_INT)
  
  ; ----------------------------------------------------------------------------
  ;  hlpNextItem
  ; ----------------------------------------------------------------------------
  Procedure hlpNextItem( *Me.ControlGroup::ControlGroup_t )
    *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
    
    Protected iBound.i = *Me\chilcount - 1
    Protected n.i = (*me\current+1)%iBound
    
    Protected ev_data.Control::EventTypeDatas_t 
    *Me\focuschild = *Me\children(n)
    *Me\focuschild\OnEvent(#PB_EventType_Focus,@ev_data)
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
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
  
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure.i Draw( *Me.ControlProperty_t)
    StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
    ResetCoordinates()
    AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
        
    Protected label.s = *Me\label
    Protected lalen.i = Len(label)
    Protected maxW .i = *Me\sizX - 21
    Protected curW .i
    If *Me\chilcount
      Protected i     .i = 0
      Protected iBound.i = *Me\chilcount - 1
      Protected  son  .Control::IControl
      Protected *son  .Control::Control_t
      Protected ev_data.Control::EventTypeDatas_t

      For i=0 To iBound
         son = *Me\children(i)
        *son = son
        ev_data\xoff = *son\posX + *Me\posX
        ev_data\yoff = *son\posY + *Me\posY
        son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
      Next
    EndIf
    
    StopVectorDrawing()

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw Empty
  ; ----------------------------------------------------------------------------
  Procedure.i DrawEmpty( *Me.ControlProperty_t)
    StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
    ResetCoordinates()
    AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor( UIColor::COLOR_MAIN_BG )
    FillPath()
    StopVectorDrawing()
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; AppendStart
  ;-----------------------------------------------------------------------------
  Procedure AppendStart( *Me.ControlProperty_t )
    If *Me\append : ProcedureReturn : EndIf
    *Me\append = #True
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Append
  ;-----------------------------------------------------------------------------
  Procedure.i Append( *Me.ControlProperty_t, *ctl.Control::Control_t)
    If Not *ctl
      ProcedureReturn
    EndIf

    If #False = *Me\append
     ProcedureReturn #False
    EndIf
  
    If *Me\chilcount > ArraySize( *Me\children() )
      ReDim *Me\children( *Me\chilcount + 10 )
      ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    *ctl\parent = *Me
  
    *Me\children( *Me\chilcount ) = *ctl
    *Me\rowflags( *Me\chilcount ) = *Me\row
    *Me\chilcount + 1
  
    ProcedureReturn( *ctl )
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; AppendStop
  ;-----------------------------------------------------------------------------
  Procedure AppendStop( *Me.ControlProperty_t )
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    *Me\append = #False
    *Me\sizY = GetHeight(*Me)
    ResizeGadget(*Me\gadgetID,*Me\parent\posX +*Me\posY,*Me\parent\posY + *Me\posY,*Me\sizX,*Me\sizY)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowStart
  ;-----------------------------------------------------------------------------
  Procedure RowStart( *Me.ControlProperty_t )
    If *Me\row : ProcedureReturn( void ) : EndIf
    *Me\row = #True
    *Me\dx = 0
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowEnd
  ;-----------------------------------------------------------------------------
  Procedure RowEnd( *Me.ControlProperty_t )
    If *Me\chilcount>0 : *Me\rowflags( *Me\chilcount - 1) = #False : EndIf
    If Not *Me\row : ProcedureReturn( void ) : EndIf
    *Me\row = #False
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Button Control
  ;-----------------------------------------------------------------------------
  Procedure AddButtonControl( *Me.ControlProperty_t, name.s,label.s, color.i,width=18, height=18, toggable.b=#False)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *btn.ControlButton::ControlButton_t
    *Me\dx =0
    Protected *Ctl.Control::Control_t

    If  ListSize(*Me\groups()) And *Me\groups()
      If toggable
        *btn = ControlButton::New(*Me,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      Else
        *btn = ControlButton::New(*Me,name,name,#False, #PB_Button_Toggle,*Me\dx,*Me\dy+2,width,height, color )
      EndIf
      ControlGroup::Append(*Me\groups(),*btn)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
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
  
  ;-----------------------------------------------------------------------------
  ; Add Icon Control
  ;-----------------------------------------------------------------------------
  Procedure AddIconControl( *Me.ControlProperty_t, name.s, color.i, type.i, width=64, height=64)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *icon.ControlIcon::ControlIcon_t
    Protected *ctl.Control::Control_t
    
    If  ListSize(*Me\groups()) And *Me\groups()
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
  
  
  ;-----------------------------------------------------------------------------
  ; Add Knob Control
  ;-----------------------------------------------------------------------------
  Procedure AddKnobControl( *Me.ControlProperty_t, name.s, color.i,width=64, height=100)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *knob.ControlKnob::ControlKnob_t
    Protected *ctl.Control::Control_t
    
    If  ListSize(*Me\groups()) And *Me\groups()
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
  
  ;-----------------------------------------------------------------------------
  ; Add Bool Control
  ;-----------------------------------------------------------------------------
  Procedure AddBoolControl( *Me.ControlProperty_t, name.s,label.s,value.b,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    *Me\dx =0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *ctl.Control::Control_t
    
    If  ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::RowStart(*Me\groups())
      ControlGroup::Append(*Me\groups(),ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append(*Me\groups(),ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *ctl = ControlGroup::Append(*Me\groups(),ControlCheck::New(*Me,name+"Check",name, value,0,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      ControlGroup::RowEnd(*Me\groups())
    Else
      RowStart(*Me)
      Append( *Me,ControlDivot::New(*Me,name+"Divot" ,ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
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
  
  ;-----------------------------------------------------------------------------
  ; Add Long Control
  ;-----------------------------------------------------------------------------
  Procedure AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*attr.Attribute::Attribute_t)
    If Not*Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    If ListSize(*Me\groups()) And *Me\groups()
     ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,60,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      ControlGroup::Append( *Me\groups(), *ctl  )
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,60,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf

    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnIntegerChange, *ctl, *attr, 0, 0)
    EndIf
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Float Control 
  ;-----------------------------------------------------------------------------
  Procedure AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f, *attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
        
    If ListSize(*Me\groups()) And *Me\groups()
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
    
    *Me\dy + 22
    
    ProcedureReturn(*ctl)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Vector2 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    *Me\dx = 0
    *Me\dy + 10
    Protected w= *Me\sizX/3
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/2
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups()) And *Me\groups()
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
  
  ;-----------------------------------------------------------------------------
  ; Add Vector3 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector3Control(*Me.ControlProperty_t, name.s, label.s, *value.v3f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    *Me\dx = 0
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
  
    If ListSize(*Me\groups()) And *Me\groups()
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

  ;--------------------------------------------------------------------
  ;  Add Vector4 Control
  ;--------------------------------------------------------------------
  Procedure AddVector4Control(*Me.ControlProperty_t,name.s,label.s,*value.v4f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    *Me\dx = 5
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/3
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    
    ControlGroup::AppendStart(*Me)
    ControlGroup::RowStart(*Me)
    
    ControlGroup::Append(*group, ControlDivot::New(*Me, "XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "XLabel","X",#False,0,*Me\dx+20,*Me\dy,120,21 ))
    Define *xCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me, "YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "YLabel","Y",#False,0,*Me\dx+width+20,*Me\dy,120,21 ))
    Define *yCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me, "ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
    Define *zCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me, "WDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
    Define *wCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, ">Number",*value\w,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    If ListSize(*Me\groups()) And *Me\groups()
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
  
  ;-----------------------------------------------------------------------------
  ; Add Quaternion Control
  ;-----------------------------------------------------------------------------
  Procedure AddQuaternionControl(*Me.ControlProperty_t, name.s, label.s, *value.q4f32, *attr.Attribute::Attribute_t)

    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 50 ,options)
    
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    Protected *aCtl.Control::Control_t

    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    Protected w= *Me\sizX/4
    ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlGroup::Append(*group,ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
    
    ControlGroup::Append(*group, ControlDivot::New(*Me,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *zCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )

    ControlGroup::Append(*group, ControlDivot::New(*Me,"AngleDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"AngleLabel","Angle",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *aCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"AngleNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
  
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups()) And *Me\groups()
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

  ;-----------------------------------------------------------------------------
  ; Add Matrix4 Control
  ;-----------------------------------------------------------------------------
  Procedure AddMatrix4Control(*Me.ControlProperty_t, name.s, label.s, *value.m4f32, *attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl

    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 200 ,options)

    ControlGroup::AppendStart(*group)
    Protected i
    For i=0 To 3
    
      ControlGroup::RowStart(*group)
    
      Protected w= *Me\sizX/4
      ControlGroup::Append(*group,ControlDivot::New(*Me,"M"+Str(i)+"0Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"0Label","M"+Str(i)+"0",#False,0,*Me\dx+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"0Number",*value\v[i*4],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
      
      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"1Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
      ControlGroup::Append(*group,ControlLabel::New(*Me,"M"+Str(i)+"1Label","M"+Str(i)+"1",#False,0,*Me\dx+width+20,14,120,21 ))
      ControlGroup::Append(*group,ControlNumber::New(*Me,"M"+Str(i)+"1Number",*value\v[i*4+1],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )

      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"2Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"2Label","M"+Str(i)+"2",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"2Number",*value\v[i*4+2],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
      
      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"3Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"3Label","M"+Str(i)+"3",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"3Number",*value\v[i*4+3],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
    
      ControlGroup::RowEnd(*group)
      *Me\posY +50
    Next
    ControlGroup::AppendStop(*group)
  
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Add Reference Control
  ;-----------------------------------------------------------------------------
  Procedure AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
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
    
    Append(*Me,*group)
    
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add File Control
  ;-----------------------------------------------------------------------------
  Procedure AddFileControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected *btn.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
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
    
    Append(*Me,*group)
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Enum Control
  ;-----------------------------------------------------------------------------
  Procedure AddEnumControl( *Me.ControlProperty_t,name.s,label.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    *Me\dx =0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *ctl.Control::Control_t
    
    If  ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::RowStart(*Me\groups())
      ControlGroup::Append(*Me\groups(),ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append(*Me\groups(),ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *ctl = ControlGroup::Append(*Me\groups(),ControlEnum::New(*Me,name+"Check",name,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      ControlGroup::RowEnd(*Me\groups())
    Else
      RowStart(*Me)
      Append( *Me,ControlDivot::New(*Me,name+"Divot" ,ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append( *Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,(width-20)*0.25,21 ))
      *ctl = Append( *Me,ControlEnum::New(*Me, name+"Check",name,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18))
      RowEnd(*Me)
    EndIf
   
    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnCheckChange, *ctl, *attr, 0, 0)
    EndIf
    
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Add String Control
  ;-----------------------------------------------------------------------------
  Procedure AddStringControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
   
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *ctl = ControlEdit::New(*Me,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*ctl)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    Append(*Me,*group)

    If *attr
      Callback::CONNECT_CALLBACK(*ctl\on_change, OnStringChange, *ctl, *attr, 0, 0)
    EndIf
    
    *Me\dy +*group\sizY
    ProcedureReturn *ctl
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Add Color Control
  ;-----------------------------------------------------------------------------
  Procedure AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*attr.Attribute::Attribute_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    Define *color.ControlColor::ControlColor_t = ControlColor::New(*Me, name+"_Color",name+"_Color",*value,*Me\dx,*Me\dy+2,(width-110),18)
    
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    ControlGroup::Append(*group, *color)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    Append(*Me,*group)
    
    *Me\dy + *group\sizY 
    ProcedureReturn(*color)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Group Control
  ;-----------------------------------------------------------------------------
  Procedure AddGroup( *Me.ControlProperty_t,name.s)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    AddElement(*Me\groups())
    *Me\groups() = *group
    Append(*Me,*group)
    
    ControlGroup::AppendStart(*group)

    *Me\dy + 20
    ProcedureReturn(*group)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; End Group Control
  ;-----------------------------------------------------------------------------
  Procedure EndGroup( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    
    Protected *group.ControlGroup::ControlGroup_t = *Me\groups()
    If Not *group : ProcedureReturn : EndIf
    
    *Me\dy + *group\sizY-20
   
    ControlGroup::AppendStop(*group)
    DeleteElement(*Me\groups())
   
    ProcedureReturn(#Null)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Head Control
  ;-----------------------------------------------------------------------------
  Procedure AddHead( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    Protected Me.ControlProperty::IControlProperty = *Me
    *Me\dy = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    *Me\head = ControlHead::New(*Me,*Me\name+"_Head",options,*Me\dx,*Me\dy+2,width,18) 
    Append(*Me,*Me\head)
    
    *Me\dy + *Me\head\sizY

    ProcedureReturn(*head)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Width
  ;-----------------------------------------------------------------------------
  Procedure GetWidth( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    ProcedureReturn(*Me\sizX)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Height
  ;-----------------------------------------------------------------------------
  Procedure GetHeight( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    If *Me\percY > 0
      *Me\sizY = *Me\parent\sizY * (*Me\percY / 100)
    Else
      Protected *son.Control::Control_t
      *Me\sizY = 0
      For i=0 To *Me\chilcount-1
      
        *son = *Me\children(i)
        If (*son\posY+*son\sizY) > *Me\sizY
          *Me\sizY = *son\posY+*son\sizY
        EndIf
      Next
    EndIf
    ProcedureReturn *Me\sizY
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Control By Index
  ;-----------------------------------------------------------------------------
  Procedure GetControlByIndex( *Me.ControlProperty_t, index.i)
    If Not *Me  Or index <0 Or index >= *Me\chilcount : ProcedureReturn #Null : EndIf
    ProcedureReturn *Me\children(index)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get COntrol By Name
  ;-----------------------------------------------------------------------------
  Procedure GetControlByName( *Me.ControlProperty_t, name.s)
    If Not *Me  Or index <0 Or index >= *Me\chilcount : ProcedureReturn : EndIf
    Protected *son.Control::Control_t
    For i=0 To *Me\chilcount-1
      *son = *Me\children(i)
      If *son\name = name
        ProcedureReturn *son
      EndIf
    Next
    ProcedureReturn #Null
  EndProcedure

  
  ;-----------------------------------------------------------------------------
  ; Init
  ;-----------------------------------------------------------------------------
  Procedure Init( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    ControlGroup::DrawPickImage(*Me)
    Draw(*Me)
    
    ProcedureReturn(#True)
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Refresh
  ;-----------------------------------------------------------------------------
  Procedure Refresh( *Me.ControlProperty_t)
    If Not *Me : ProcedureReturn : EndIf
    ProcedureReturn(#True)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Event With Filter
  ;-----------------------------------------------------------------------------
  Procedure EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
    Protected *son.Control::IControl
    Protected i
    For i=0 To *Me\chilcount-1
      *son = *Me\children(i)
      *son\OnEvent(ev_type,#Null)
    Next i
    
;     ForEach *Me\groups()
;     
;       If filter = *Me\groups()\GetGadgetID() : *Me\groups()\Event( ev_type ) : EndIf
;     Next
  EndProcedure

  ; ============================================================================
  ;  OVERRIDE ( Control::IControl )
  ; ============================================================================
  Procedure.i OnEvent( *Me.ControlProperty_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )  
    Protected  ev_data.Control::EventTypeDatas_t
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    Protected idx,xm,ym
    Protected *overchild.Control::Control_t
    Protected nbc_row.i
    
    Protected pickID = ControlGroup::Pick(*Me)
    If pickID > -1 And pickID < *Me\chilcount 
      *overchild = *Me\children(pickID)
    Else
      *overchild = #Null
    EndIf
    
    Select ev_code
        
      Case #PB_EventType_Resize
        If *ev_data\x <> #PB_Ignore And Not *Me\fixedX : *Me\posX = *ev_data\x : EndIf
        If *ev_data\y <> #PB_Ignore And Not *Me\fixedY : *Me\posY = *ev_data\y : EndIf
        If *ev_data\width <> #PB_Ignore : *Me\sizX = *ev_data\width : EndIf
        If *ev_data\height <> #PB_Ignore : *Me\sizY = *ev_data\height : EndIf
        
        If *Me\percX > 0 : *Me\sizX = *Me\parent\sizX * (*Me\percX / 100) : EndIf
        If *Me\percY > 0 : *Me\sizY = *Me\parent\sizY * (*Me\percY / 100) : EndIf

        ev_data\x = 0
        ev_data\y = 0
        ev_data\width = *ev_data\width
        ev_data\height = *ev_data\height
        
        For c=0 To *Me\chilcount - 1
          If *Me\rowflags(c) 
            nbc_row = ControlGroup::GetNumControlInRow(*Me, c)
            ev_data\y + ControlGroup::ResizeControlsInRow(*Me, c, nbc_row)
            
            c + nbc_row - 1
          Else
            son = *Me\children(c)
            *son = son
            If *son\type = Control::#ICON Or *son\type = Control::#TEXT: Continue : EndIf
            ev_data\width = *ev_data\width
            ev_data\height = #PB_Ignore
            son\OnEvent(#PB_EventType_Resize, ev_data)
            ev_data\y + *son\sizY
          EndIf
        Next
        
        ControlGroup::DrawPickImage(*Me)
        Draw( *Me )
        ProcedureReturn( #True )
          
      Case Control::#PB_EventType_DrawChild
        *son.Control::Control_t = *ev_data\datas
        son.Control::IControl    = *son
        ev_data\xoff    = *son\posX
        ev_data\yoff    = *son\posY
        StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
        ResetCoordinates()
        AddPathBox( *son\posX-Control::FRAME_THICKNESS, *son\posY-Control::FRAME_THICKNESS, *son\sizX+2*Control::FRAME_THICKNESS, *son\sizY+2*Control::FRAME_THICKNESS)
        VectorSourceColor(UIColor::COLOR_MAIN_BG )
        FillPath()
        son\OnEvent( Control::#PB_EventType_Draw, ev_data )
        StopVectorDrawing()
  
      Case #PB_EventType_Focus
        If *Me\overchild
          If *Me\overchild <> *overchild
            *Me\overchild\OnEvent(#PB_EventType_LostFocus)
            *Me\overchild = *overchild
            If *Me\overchild
              *Me\overchild\OnEvent(#PB_EventType_Focus)
            EndIf
          EndIf
        Else
          If *overchild
            *Me\overchild = *overchild
            *Me\overchild\OnEvent(#PB_EventType_Focus)
          EndIf
        EndIf

      Case Control::#PB_EventType_ChildFocused
        *Me\focuschild = *ev_data
        
      Case Control::#PB_EventType_ChildDeFocused
        *Me\focuschild = #Null
        
      Case Control::#PB_EventType_ChildCursor
        SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data )
        
      Case #PB_EventType_LostFocus
        If *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          *Me\focuschild = #Null
        EndIf
        
      Case #PB_EventType_MouseMove
        xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
        ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
        
        xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
        ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
        
        If *overchild
          *Me\overchild = *overchild
          ev_data\x    = xm - *overchild\posX + *Me\posX
          ev_data\y    = ym - *overchild\posY + *Me\posY
          *Me\overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
        EndIf
        
    Case #PB_EventType_LeftButtonDown
      *Me\down = #True
      If *Me\overchild
        *overchild = *Me\overchild
        If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          Define *focuschild.Control::Control_t = *Me\focuschild
        EndIf
        ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ); - *overchild\posX
        ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ); - *overchild\posY
        ev_data\xoff = *Me\posX
        ev_data\yoff = *Me\posY
        *Me\overchild\OnEvent(#PB_EventType_LeftButtonDown,@ev_data)
        *Me\focuschild = *Me\overchild
      ElseIf *Me\focuschild
        Define focuschild.Control::IControl = *Me\focuschild
        *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
      EndIf
      
    Case #PB_EventType_LeftButtonUp
        If *overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild = *overchild
          *Me\overchild\OnEvent(#PB_EventType_LeftButtonUp,@ev_data)
        EndIf
        *Me\down = #False

      Case #PB_EventType_LeftDoubleClick
        *overchild.Control::Control_t = *Me\overchild
        If *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_LeftDoubleClick,@ev_data)
          *Me\focuschild = *Me\overchild
        EndIf
        
      Case #PB_EventType_RightButtonDown
        *Me\down = #True
        *overchild.Control::Control_t = *Me\overchild
        If *Me\overchild
          If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonDown,@ev_data)
        ElseIf *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
        EndIf
        
      Case #PB_EventType_RightButtonUp
        
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        *Me\down = #False
      
      Case #PB_EventType_RightButtonUp
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        

      Case #PB_EventType_Input
        If *Me\focuschild
          ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input))
          *Me\focuschild\OnEvent(#PB_EventType_Input,@ev_data)
        EndIf
        
      Case #PB_EventType_KeyDown
        If *Me\focuschild
          ev_data\key   = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key      )
          ev_data\modif = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
          *Me\focuschild\OnEvent(#PB_EventType_KeyDown,@ev_data)
        EndIf
        
      Case Globals::#SHORTCUT_COPY
        If *Me\focuschild
          MessageRequester("COPY", "Copy")
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_COPY,#Null)
        EndIf
        
      Case Globals::#SHORTCUT_CUT
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_CUT,#Null)
        EndIf
        
      Case Globals::#SHORTCUT_PASTE
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_PASTE,#Null)
        EndIf
        
      Case Globals::#SHORTCUT_UNDO
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_UNDO,#Null)
        EndIf
        
  ;       ; ------------------------------------------------------------------------
  ;       ;  SHORTCUT_NEXT
  ;       ; ------------------------------------------------------------------------
  ;       Case Globals::#SHORTCUT_NEXT
  ;         ; ---[ Do We Have A Focused Child ? ]-------------------------------------
  ;         If *Me\focuschild
  ;           ; ---[ Go To Next Item ]------------------------------------------------
  ;           OControlGroup_hlpNextItem( *Me ) 
  ;         EndIf
  ;         
  ;       ;------------------------------------------------------------------------
  ;       ; SHORTCUT_PREVIOUS
  ;       ;------------------------------------------------------------------------
  ;       Case Globals::#SHORTCUT_PREVIOUS
  ;           Debug "Previous Item called"
  ;           ; ---[ Do We Have A Focused Child ? ]-----------------------------------
  ;           If *Me\focuschild
  ;             ; go to previous child
  ;             Debug "previous child per favor..."
  ;           EndIf
                 
               
        
      ;Case #PB_EventType_KeyUp
      ;Case #PB_EventType_MiddleButtonDown
      ;Case #PB_EventType_MiddleButtonUp
      ;Case #PB_EventType_MouseWheel
      ;Case #PB_EventType_PopupMenu
      ;Debug ">> PopupMenu"
      ;Case #PB_EventType_PopupWindow
      ;Debug ">> PopupWindow"
        
    EndSelect
    
    ProcedureReturn( #False )
    
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
  Procedure.i New( *parent.UI::UI_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,decoration = #PROPERTY_LABELED)
    Protected *Me.ControlProperty_t = AllocateStructure(ControlProperty_t)
    
    Object::INI(ControlProperty)
    
    *Me\object     = #Null
    *Me\parent     = *parent
    *Me\type       = #PB_GadgetType_Container
    *Me\decoration = decoration
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
    *Me\head       = ControlHead::New(*Me, name+"Head", 0,0,0,width, 32)
  
    DrawEmpty(*Me)
    
    View::SetContent(*parent,*Me)
   
    ProcedureReturn *Me
    
  EndProcedure
  
  Class::DEF(ControlProperty)
EndModule
; ============================================================================
;  EOF
; ============================================================================

      
      
    
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 261
; FirstLine = 234
; Folding = ---------
; EnableXP