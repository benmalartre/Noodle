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
XIncludeFile "Slider.pbi"
XIncludeFile "Color.pbi"
XIncludeFile "ColorWheel.pbi"

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
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Structure ControlProperty_t Extends Control::Control_t
    pickID    .i
    imageID   .i
    label     .s
    append    .i
    row       .i
    down      .i
    valid     .b
    *object.Object::Object_t
    *head.ControlHead::ControlHead_t
    overchild .Control::IControl
    focuschild.Control::IControl
    Array *children .Control::Control_t(10)
    Array rowflags .i(10)
    List *groups.ControlGroup::ControlGroup_t()
    chilcount .i
    current   .i
    closed    .b
    decoration.i
    lock.Control::IControl
    refresh.Control::IControl
    dx.i
    dy.i
    
    slotID.i
  
  EndStructure
  
  Interface IControlProperty Extends Control::IControl
  EndInterface
  
  Declare New( *object.Object::Object_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,decoration = #PROPERTY_LABELED)
  Declare Delete(*Me.ControlProperty_t)
  Declare OnEvent( *Me.ControlProperty_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )  
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
  Declare AddColorWheelControl( *Me.ControlProperty_t,name.s)
  Declare AddStringControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
  Declare AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*attr.Attribute::Attribute_t)
  Declare AddButtonControl(*Me.ControlProperty_t, name.s,label.s, color.i, width=18, height=18)
  Declare AddIconControl( *Me.ControlProperty_t, name.s, color.i, type.i, width=64, height=64)
  Declare AddKnobControl(*Me.ControlProperty_t, name.s,color.i, width.i=64, height.i=64)
  Declare AddSliderControl( *Me.ControlProperty_t,name.s,label.s,value.f, min_value.f, max_value.f, *attr.Attribute::Attribute_t)
  Declare AddFileControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
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
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  CONTROL PROPERTY MODULE IMPLEMENTATION 
; ============================================================================
Module ControlProperty
  UseModule Math
  
  ; ----------------------------------------------------------------------------
  ;   CALLBACKS
  ; ----------------------------------------------------------------------------
  Procedure OnCheckChange(*ctl.ControlCheck::ControlCheck_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)   
    Define *array.CArray::CArrayBool = *attr\data
    PokeB(*array\data + id * *array\itemSize + offset, *ctl\value)

    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARECALLBACK(OnCheckChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
  Procedure OnLongChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)    
    Define *array.CArray::CArrayLong = *attr\data
    PokeB(*array\data + id * *array\itemSize + offset, *ctl\down)
    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARECALLBACK(OnLongChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
  Procedure OnIntegerChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)   
    Define *array.CArray::CArrayInt = *attr\data
    PokeI(*array\data + id * *array\itemSize + offset, Val(*ctl\value))
    *attr\dirty = #True

    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARECALLBACK(OnIntegerChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
  Procedure OnFloatChange(*ctl.ControlNumber::ControlNumber_t, *attr.Attribute::Attribute_t, id.i=0, offset.i=0)
    Define *array.CArray::CArrayFloat = *attr\data
    PokeF(*array\data + id * *array\itemSize + offset, ValF(*ctl\value)) 
    *attr\dirty = #True
    
    PostEvent(Globals::#EVENT_PARAMETER_CHANGED)
  EndProcedure
  Callback::DECLARECALLBACK(OnFloatChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
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
  Callback::DECLARECALLBACK(OnReferenceChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
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
  Callback::DECLARECALLBACK(OnFileChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
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
  Callback::DECLARECALLBACK(OnStringChange, Arguments::#PTR, Arguments::#PTR, Arguments::#INT, Arguments::#INT)
  
  ; ----------------------------------------------------------------------------
  ;  hlpNextItem
  ; ----------------------------------------------------------------------------
  Procedure hlpNextItem( *Me.ControlGroup::ControlGroup_t )
    ; ---[ Unfocus Current Item ]-----------------------------------------------
    *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected iBound.i = *Me\chilcount - 1
    Protected n.i = (*me\current+1)%iBound
    
    Protected ev_data.Control::EventTypeDatas_t 
    *Me\focuschild = *Me\children(n)
    *Me\focuschild\OnEvent(#PB_EventType_Focus,@ev_data)
    ;*Me\focuschild\Event( #PB_EventType_Focus, #Null);*ev_data )
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
  ;  Get Image ID
  ; ----------------------------------------------------------------------------
  Procedure.i GetImageID( *Me.ControlProperty_t)
    ProcedureReturn *Me\imageID
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ; Select Gadget Under Mouse 
  ; ----------------------------------------------------------------------------
  Procedure Pick(*Me.ControlProperty_t)
    If Not *Me Or Not *Me\valid : ProcedureReturn 0 : EndIf
    Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
    Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
    
    Protected iw = ImageWidth(*Me\imageID)
    Protected ih = ImageHeight(*Me\imageID)

    If xm<0 Or ym<0 Or xm>= iw Or ym>= ih : ProcedureReturn : EndIf
    
    StartDrawing( ImageOutput(*Me\imageID) )
    *Me\pickID = Point(xm,ym)-1
    StopDrawing()
    If *Me\pickID >-1 And *Me\pickID<*Me\chilcount
      Protected *overchild.Control::Control_t = *Me\children(*Me\pickID)
      If *overchild\type = Control::#GROUP
        ControlGroup::Pick(*overchild)
      EndIf
    EndIf
  
    ProcedureReturn *Me\pickID
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure.i DrawPickImage( *Me.ControlProperty_t)
    If Not *Me\sizX Or Not *Me\sizY : *Me\valid = #False : ProcedureReturn : EndIf
    *Me\valid = #True
    ResizeImage(*Me\imageID, *Me\sizX, *Me\sizY)

    ; ---[ Local Variables ]----------------------------------------------------
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount - 1
  
    Protected  son  .Control::IControl
    Protected *son  .Control::Control_t
    
    If *Me\chilcount
      ; ---[ Draw ]---------------------------------------------------------------
      StartVectorDrawing( ImageVectorOutput(*Me\imageID) )
      ResetCoordinates()
      AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
      VectorSourceColor(RGBA(0,255,255,255))
      FillPath()
      
      For i=0 To iBound
        *son = *Me\children(i)
        If *son\type = Control::#GROUP
          AddPathBox( *Me\posX + *son\posX, *Me\posY + *son\posY, *son\sizX, *son\sizY)
          VectorSourceColor(RGBA(i+1,0,0,255))
          FillPath()
        Else
          AddPathBox( *Me\posX + *son\posX, *Me\posY + *son\posY, *son\sizX, *son\sizY)
          VectorSourceColor(RGBA(i+1,0,0,255))
          FillPath()
        EndIf
        
      Next
      StopVectorDrawing()
    EndIf
   
  EndProcedure
  
  Procedure.i DrawTitle( *Me.ControlProperty_t)
    
  EndProcedure
  
    
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure.i Draw( *Me.ControlProperty_t)
    ; ---[ Drawing Start ]------------------------------------------------------
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
      ; ---[ Local Variables ]----------------------------------------------------
      Protected i     .i = 0
      Protected iBound.i = *Me\chilcount - 1
      Protected  son  .Control::IControl
      Protected *son  .Control::Control_t
      Protected ev_data.Control::EventTypeDatas_t

      ; ---[ Redraw Children ]----------------------------------------------------
      For i=0 To iBound
         son = *Me\children(i)
        *son = son
        ev_data\xoff = *son\posX + *Me\posX
        ev_data\yoff = *son\posY + *Me\posY
        son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
      Next
    EndIf
    
    ; ---[ Drawing End ]--------------------------------------------------------
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
  
  ; ---[ AppendStart ]----------------------------------------------------------
  Procedure AppendStart( *Me.ControlProperty_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If *Me\append : ProcedureReturn : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #True
  EndProcedure

  ; ---[ Append ]---------------------------------------------------------------
  Procedure.i Append( *Me.ControlProperty_t, *ctl.Control::Control_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *ctl
      ProcedureReturn
    EndIf

    ; ---[ Check Gadget List Status ]-------------------------------------------
    If #False = *Me\append
      ; ...[ FAILED ]...........................................................
     ProcedureReturn #False
    EndIf
  
    ; ---[ Check Array Space ]--------------------------------------------------
    If *Me\chilcount > ArraySize( *Me\children() )
      ReDim *Me\children( *Me\chilcount + 10 )
      ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    ; ---[ Set Me As Control Parent ]-------------------------------------------
    *ctl\parent = *Me
  
    ; ---[ Append Control ]-----------------------------------------------------
    *Me\children( *Me\chilcount ) = *ctl
  
    ; ---[ Set Row Flag ]-------------------------------------------------------
    *Me\rowflags( *Me\chilcount ) = *Me\row
    
    ; ---[ One More Control ]---------------------------------------------------
    *Me\chilcount + 1
  
    ; ---[ Return The Added Control ]-------------------------------------------
    ProcedureReturn( *ctl )
  
  EndProcedure
  
  ; ---[ AppendStop ]-----------------------------------------------------------
  Procedure AppendStop( *Me.ControlProperty_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #False
    
    ; ---[ Recompute Size ]-----------------------------------------------------
;     *Me\sizY = GetHeight(*Me)
;     ResizeGadget(*Me\gadgetID,*Me\parent\posX +*Me\posY,*Me\parent\posY + *Me\posY,*Me\sizX,*Me\sizY)

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowStart
  ;-----------------------------------------------------------------------------
  Procedure RowStart( *Me.ControlProperty_t )
    ; Check Row Status
    If *Me\row : ProcedureReturn( void ) : EndIf
    ; Update Status
    *Me\row = #True
    *Me\dx = 0
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; RowEnd
  ;-----------------------------------------------------------------------------
  Procedure RowEnd( *Me.ControlProperty_t )
    ; Update Current Child
    If *Me\chilcount>0 : *Me\rowflags( *Me\chilcount - 1) = #False : EndIf

    ; Check Row Status
    If Not *Me\row : ProcedureReturn( void ) : EndIf

    ; Update Status
    *Me\row = #False
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Button Control
  ;-----------------------------------------------------------------------------
  Procedure AddButtonControl( *Me.ControlProperty_t, name.s,label.s, color.i,width=18, height=18)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *btn.ControlButton::ControlButton_t
    *Me\dx =0
    Protected *Ctl.Control::Control_t

    ; Add Parameter
    If  ListSize(*Me\groups()) And *Me\groups()
      *btn = ControlButton::New(*Me,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      ControlGroup::Append(*Me\groups(),*btn)
      If Not *Me\groups()\row Or Not *Me\groups()\chilcount > 1 : *Me\dy + height : EndIf
    Else
      *btn = ControlButton::New(*Me,name,name,#False, 0,*Me\dx,*Me\dy+2,width,height, color )
      Append( *Me, *btn)
      If Not *Me\row : *Me\dy + height : Else : *Me\dx + width : EndIf
    EndIf
    ProcedureReturn(*btn)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Icon Control
  ;-----------------------------------------------------------------------------
  Procedure AddIconControl( *Me.ControlProperty_t, name.s, color.i, type.i, width=64, height=64)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *icon.ControlIcon::ControlIcon_t
    Protected *ctl.Control::Control_t
    
    ; Add Parameter
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
  Procedure AddKnobControl( *Me.ControlProperty_t, name.s, color.i,width=64, height=64)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Protected *knob.ControlKnob::ControlKnob_t
    Protected *ctl.Control::Control_t
    
    ; Add Parameter
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
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.IControlProperty = *Me
    Debug "### ADD BOOL CONTROL : "+Str(value)
    *Me\dx =0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    Protected *ctl.Control::Control_t
    
    ; Add Parameter
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
    
     ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnCheckChange, *ctl, *attr, 0, 0)
    EndIf
    
    
    *Me\dy + 22
    ProcedureReturn(*ctl)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Long Control
  ;-----------------------------------------------------------------------------
  Procedure AddIntegerControl( *Me.ControlProperty_t,name.s,label.s,value.i,*attr.Attribute::Attribute_t)
    ; Sanity Check
    If Not*Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    ; Add Parameter
    If ListSize(*Me\groups()) And *Me\groups()
     ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,120,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      ControlGroup::Append( *Me\groups(), *ctl  )
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,120,21 ))
      *ctl = ControlNumber::New(*Me,name+"Number",value,ControlNumber::#NUMBER_INTEGER,-1000,1000,0,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf

     ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnIntegerChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + 22
    ProcedureReturn(*ctl)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Slider Control 
  ;-----------------------------------------------------------------------------
  Procedure AddSliderControl( *Me.ControlProperty_t,name.s,label.s,value.f, min_value.f, max_value.f, *attr.Attribute::Attribute_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
        
    ; Add Parameter
    If ListSize(*Me\groups()) And *Me\groups()
     ControlGroup::RowStart( *Me\groups())
      *ctl =  ControlSlider::New(*Me, name+"Slider", value, #Null, min_value, max_value,min_value,max_value,*Me\dx,*Me\dy,width-20,32) 
      ControlGroup::Append(*Me\groups(), *ctl)
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      *ctl = ControlSlider::New(*Me, name+"Slider", value, #Null, min_value, max_value, min_value, max_value,*Me\dx,*Me\dy,width,32)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf
    
    ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnFloatChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + 36
    
    ProcedureReturn(*ctl)
  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Add Float Control 
  ;-----------------------------------------------------------------------------
  Procedure AddFloatControl( *Me.ControlProperty_t,name.s,label.s,value.f, *attr.Attribute::Attribute_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    *Me\dx = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
        
    ; Add Parameter
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::RowStart( *Me\groups())
      ControlGroup::Append( *Me\groups(), ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      ControlGroup::Append( *Me\groups(), ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,120,21 ))
      *ctl =  ControlNumber::New(*Me, name+"Number", value, ControlNumber::#NUMBER_SCALAR, -1000, 1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) 
      ControlGroup::Append(*Me\groups(), *ctl)
      ControlGroup::RowEnd( *Me\groups())
    Else
      RowStart(*Me)
      Append(*Me,ControlDivot::New(*Me,name+"Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
      Append(*Me,ControlLabel::New(*Me,name+"Label",label,#False,0,*Me\dx+20,*Me\dy,120,21 ))
      *ctl = ControlNumber::New(*Me, name+"Number", value, ControlNumber::#NUMBER_SCALAR, -1000, 1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18)
      Append(*Me, *ctl)
      RowEnd(*Me)
    EndIf
    
    ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnFloatChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + 22
    
    ProcedureReturn(*ctl)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Vector2 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector2Control(*Me.ControlProperty_t,name.s,label.s,*value.v2f32,*attr.Attribute::Attribute_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    *Me\dx = 0
    *Me\dy + 10
    Protected w= *Me\sizX/3
    ; Create Group
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/2
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ; Add X Parameter
    ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ; Add Y Parameter
    ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ; Terminate Group
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf
    
    ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Signal::CONNECTCALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Vector3 Control
  ;-----------------------------------------------------------------------------
  Procedure AddVector3Control(*Me.ControlProperty_t, name.s, label.s, *value.v3f32,*attr.Attribute::Attribute_t)
    ; Sanity Check
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    *Me\dx = 0
    Protected w = *Me\sizX/4
    
    ; Create Group
    Protected options.i = 0;ControlGroup::#Autostack|ControlGroup::#Autosize_V;
    Protected width = GadgetWidth(*Me\gadgetID)/3
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    ; Add X Parameter
;     ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18)
    ControlGroup::Append(*group, *xCtl )
    
    ; Add Y Parameter
;     ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *yCtl )
    
    ; Add Z Parameter
;     ControlGroup::Append(*group, ControlDivot::New(*Me,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *zCtl = ControlNumber::New(*Me,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18)
    ControlGroup::Append(*group, *zCtl)
    
    ; Terminate Group
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
    Else
      Append(*Me,*group)
    EndIf

    ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Signal::CONNECTCALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
      Signal::CONNECTCALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
    EndIf
    
    ; Offset for Next Control
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

;--------------------------------------------------------------------
;  Add Vector4 Control
;--------------------------------------------------------------------
Procedure AddVector4Control(*Me.ControlProperty_t,name.s,label.s,*value.v4f32,*attr.Attribute::Attribute_t)
  ; Sanity Check
  ;------------------------------
  If Not *Me : ProcedureReturn : EndIf
  
  Protected Me.ControlProperty::IControlProperty = *Me
  Protected Ctl.Control::IControl
  *Me\dx = 5
  ; Create Group
  ;------------------------------
  Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
  Protected width = GadgetWidth(*Me\gadgetID)/3
  Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, GadgetWidth(*Me\gadgetID), 40 ,options)
  
  ; Add X,Y,Z,W parameters
  ;------------------------------
  ControlGroup::AppendStart(*Me)
  ControlGroup::RowStart(*Me)
  
  ; X
  ControlGroup::Append(*group, ControlDivot::New(*Me, "XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,*Me\dy+2,18,18 ))
  ControlGroup::Append(*group, ControlLabel::New(*Me, "XLabel","X",#False,0,*Me\dx+20,*Me\dy,120,21 ))
  Define *xCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
  
  ; Y
  ControlGroup::Append(*group, ControlDivot::New(*Me, "YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,*Me\dy+2,18,18 ))
  ControlGroup::Append(*group, ControlLabel::New(*Me, "YLabel","Y",#False,0,*Me\dx+width+20,*Me\dy,120,21 ))
  Define *yCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
  
  ; Z
  ControlGroup::Append(*group, ControlDivot::New(*Me, "ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
  ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
  Define *zCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, "ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
  
  ; W
  ControlGroup::Append(*group, ControlDivot::New(*Me, "WDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,*Me\dy+2,18,18 ))
  ControlGroup::Append(*group, ControlLabel::New(*Me, "ZLabel","Z",#False,0,*Me\dx+2*width+20,*Me\dy,120,21 ))
  Define *wCtl.Control::Control_t = ControlGroup::Append(*group, ControlNumber::New(*Me, ">Number",*value\w,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width+20+(width-20)*0.25,*Me\dy,(width-20)*0.75,18) )
  
  ControlGroup::RowEnd(*group)
  ControlGroup::AppendStop(*group)
  
  ; Add Group to PPG
  If ListSize(*Me\groups()) And *Me\groups()
    ControlGroup::Append(*Me\groups(),*group)
  Else
    Append(*Me,*group)
  EndIf
  
  ; Connect Signal
  If *obj
    Signal::CONNECTCALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
    Signal::CONNECTCALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
    Signal::CONNECTCALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
    Signal::CONNECTCALLBACK(*zCtl\on_change, OnFloatChange, *wCtl, *attr, 0, 12)
  EndIf
  
  
  ; Offset for Next Control
  ;---------------------------------
  *Me\dy + *group\sizY

  ProcedureReturn(#True)
EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Quaternion Control
  ;-----------------------------------------------------------------------------
  Procedure AddQuaternionControl(*Me.ControlProperty_t, name.s, label.s, *value.q4f32, *attr.Attribute::Attribute_t)
    ; Sanity Check
    ;------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    
    ; Create Group
    ;------------------------------
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 50 ,options)
    
    Protected *xCtl.Control::Control_t
    Protected *yCtl.Control::Control_t
    Protected *zCtl.Control::Control_t
    Protected *aCtl.Control::Control_t

    ; Add X,Y,Z parameters
    ;------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
  
    Protected w= *Me\sizX/4
    ;X
    ControlGroup::Append(*group,ControlDivot::New(*Me,"XDivot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"XLabel","X",#False,0,*Me\dx+20,14,120,21 ))
    *xCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"XNumber",*value\x,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
    
    ;Y
    ControlGroup::Append(*group, ControlDivot::New(*Me,"YDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
    ControlGroup::Append(*group,ControlLabel::New(*Me,"YLabel","Y",#False,0,*Me\dx+width+20,14,120,21 ))
    *yCtl = ControlGroup::Append(*group,ControlNumber::New(*Me,"YNumber",*value\y,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
    
    ;Z
    ControlGroup::Append(*group, ControlDivot::New(*Me,"ZDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"ZLabel","Z",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *zCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"ZNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
    
    ;Angle
    ControlGroup::Append(*group, ControlDivot::New(*Me,"AngleDivot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
    ControlGroup::Append(*group, ControlLabel::New(*Me,"AngleLabel","Angle",#False,0,*Me\dx+2*width+20,14,120,21 ))
    *aCtl = ControlGroup::Append(*group, ControlNumber::New(*Me,"AngleNumber",*value\z,ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
  
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    ;---------------------------------
    ; ---[ Add Parameter ]--------------------------------------------
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    ; Connect Signal
    If *attr
      Signal::CONNECTCALLBACK(*xCtl\on_change, OnFloatChange, *xCtl, *attr, 0, 0)
      Signal::CONNECTCALLBACK(*yCtl\on_change, OnFloatChange, *yCtl, *attr, 0, 4)
      Signal::CONNECTCALLBACK(*zCtl\on_change, OnFloatChange, *zCtl, *attr, 0, 8)
      Signal::CONNECTCALLBACK(*aCtl\on_change, OnFloatChange, *aCtl, *attr, 0, 12)
    EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY
    
    ProcedureReturn(*group)
  
  EndProcedure

  ; ---[ Add Matrix4 Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddMatrix4Control(*Me.ControlProperty_t, name.s, label.s, *value.m4f32, *attr.Attribute::Attribute_t)
    ; Sanity Check
    ;------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
        
    ; Create Group
    ;------------------------------
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Protected width = GadgetWidth(*Me\gadgetID)/4
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width*4, 200 ,options)
    
    ; Add Row Parameters
    ;------------------------------
    ControlGroup::AppendStart(*group)
    Protected i
    For i=0 To 3
    
      ControlGroup::RowStart(*group)
    
      Protected w= *Me\sizX/4
      ;Mi0
      ControlGroup::Append(*group,ControlDivot::New(*Me,"M"+Str(i)+"0Divot",ControlDivot::#ANIM_NONE,0,*Me\dx,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"0Label","M"+Str(i)+"0",#False,0,*Me\dx+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"0Number",*value\v[i*4],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+40,12,(width-40),18) )
      
      ;Mi1
      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"1Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+width,14,18,18 ))
      ControlGroup::Append(*group,ControlLabel::New(*Me,"M"+Str(i)+"1Label","M"+Str(i)+"1",#False,0,*Me\dx+width+20,14,120,21 ))
      ControlGroup::Append(*group,ControlNumber::New(*Me,"M"+Str(i)+"1Number",*value\v[i*4+1],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+width,12,(width-20)*0.75,18) )
      
      ;Mi2
      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"2Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"2Label","M"+Str(i)+"2",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"2Number",*value\v[i*4+2],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+2*width,12,(width-20)*0.75,18) )
      
      ;Mi3
      ControlGroup::Append(*group, ControlDivot::New(*Me,"M"+Str(i)+"3Divot",ControlDivot::#ANIM_NONE,0,*Me\dx+2*width,14,18,18 ))
      ControlGroup::Append(*group, ControlLabel::New(*Me,"M"+Str(i)+"3Label","M"+Str(i)+"3",#False,0,*Me\dx+2*width+20,14,120,21 ))
      ControlGroup::Append(*group, ControlNumber::New(*Me,"M"+Str(i)+"3Number",*value\v[i*4+3],ControlNumber::#NUMBER_SCALAR,-1000,1000,-10,10,*Me\dx+3*width,12,(width-20)*0.75,18) )
    
      ControlGroup::RowEnd(*group)
      *Me\posY +50
    Next
    ControlGroup::AppendStop(*group)
  
    ; Add Group to PPG
    ;---------------------------------
    ; ---[ Add Parameter ]--------------------------------------------
    If ListSize(*Me\groups()) And *Me\groups()
      ControlGroup::Append(*Me\groups(),*group)
  
    Else
      Append(*Me,*group)
    EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY
    ProcedureReturn(*group)
  EndProcedure

  ; ---[ Add Reference Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddReferenceControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *Ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    ; Create Group
    ;------------------------------
    Protected options.i = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New( *Me,name, name, *Me\dx, *Me\dy, width, 200 ,options)

    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *Ctl = ControlEdit::New(*Me,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*Ctl)
    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Connect Signal
    ;---------------------------------
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnReferenceChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Add Group to PPG
    ;---------------------------------
    Append(*Me,*group)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ; ---[ Add File Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddFileControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected *btn.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)

    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *ctl = ControlEdit::New(*Me,"File", "File",#False,*Me\dx,*Me\dy+2,(width-110),32) 
    ControlGroup::Append( *group,*ctl)
    *btn = ControlButton::New(*Me, "Pick", "...",#False,0,0)
    ControlGroup::Append( *group,*btn)
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Connect Signal
    ;---------------------------------
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnFileChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Add Group to PPG
    ;---------------------------------
    Append(*Me,*group)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy +*group\sizY
    ProcedureReturn(#True)
  EndProcedure
  
  ; ---[ Add String Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddStringControl( *Me.ControlProperty_t,name.s,value.s,*attr.Attribute::Attribute_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected *ctl.Control::Control_t
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
   
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    *ctl = ControlEdit::New(*Me,name+"_Edit",value,5,*Me\dx,*Me\dy+2,(width-110),18) 
    ControlGroup::Append( *group,*ctl)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Add Group to PPG
    ;---------------------------------
    Append(*Me,*group)
    
    ; Connect Signal
    ;---------------------------------
    If *attr
      Signal::CONNECTCALLBACK(*ctl\on_change, OnStringChange, *ctl, *attr, 0, 0)
    EndIf
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy +*group\sizY
    ProcedureReturn *ctl
  EndProcedure

  ; ---[ Add Color Control  ]------------------------------------------
  ;--------------------------------------------------------------------
  Procedure AddColorControl(*Me.ControlProperty_t,name.s,label.s,*value.c4f32,*attr.Attribute::Attribute_t)
  
    ; ---[ Sanity Check ]----------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    Define *color.ControlColor::ControlColor_t = ControlColor::New(*Me, name+"_Color",name+"_Color",*value,*Me\dx,*Me\dy+2,(width-110),18)
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    ControlGroup::Append(*group, *color)

    
    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; ---[ Add Group to PPG ]-----------------------------------------
    Append(*Me,*group)
    
    ; ---[ Offset for Next Control ]----------------------------------
    *Me\dy + *group\sizY 
    ProcedureReturn(*color)
  EndProcedure
  
  ; ---[ Add ColorWheel Control  ]-------------------------------------
  Procedure AddColorWheelControl(*Me.ControlProperty_t,name.s)
  
    ; ---[ Sanity Check ]----------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    Define *wheel.ControlColorWheel::ControlColorWheel_t = ControlColorWheel::New(*Me,*Me\dx,*Me\dy+2,(width-110),256)
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
    ControlGroup::RowStart(*group)
    
    ControlGroup::Append(*group, *wheel)

    ControlGroup::RowEnd(*group)
    ControlGroup::AppendStop(*group)
    
    ; Add Group to PPG
    ;---------------------------------
;      AddElement(*Me\groups())
;     *Me\groups() = *group
    Append(*Me,*group)
    
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + *group\sizY 
    ProcedureReturn(*color)
  EndProcedure

  
  ; ---[ Add Group Control  ]------------------------------------------
  Procedure AddGroup( *Me.ControlProperty_t,name.s)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected Me.ControlProperty::IControlProperty = *Me
    Protected Ctl.Control::IControl
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    Define *group.ControlGroup::ControlGroup_t = ControlGroup::New(*Me, name, name, *Me\dx, *Me\dy, width, 50 ,options)
    AddElement(*Me\groups())
    *Me\groups() = *group
    Append(*Me,*group)
    
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStart(*group)
  
    ; Offset for Next Control
    ;---------------------------------
    *Me\dy + 20
    ProcedureReturn(*group)
  EndProcedure

  Procedure EndGroup( *Me.ControlProperty_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; Retrieve currently open group
    Protected *group.ControlGroup::ControlGroup_t = *Me\groups()
    If Not *group : ProcedureReturn : EndIf
    
    ; ---[ Offset for Next Control ]------------------------------------------
    *Me\dy + *group\sizY-20
   
    ; ---[ Add Parameter ]--------------------------------------------
    ControlGroup::AppendStop(*group)
    DeleteElement(*Me\groups())
   
    ProcedureReturn(#Null)
  EndProcedure
  
  ; ---[ Add Head Control  ]------------------------------------------
  Procedure AddHead( *Me.ControlProperty_t)
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    Protected Me.ControlProperty::IControlProperty = *Me
    *Me\dy = 0
    Protected width = GadgetWidth(*Me\gadgetID)-10
    
    Protected options = ControlGroup::#Autostack|ControlGroup::#Autosize_V
    *Me\head = ControlHead::New(*Me,*Me\name+"_Head",options,*Me\dx,*Me\dy+2,width,18) 
    Append(*Me,*Me\head)
    
    ; ---[ Offset for Next Control ---------------------------------------
    *Me\dy + *Me\head\sizY

    ProcedureReturn(*head)
  EndProcedure
  
  ; ---[ Get Width ]-----------------------------------------------
  Procedure GetWidth( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ProcedureReturn(*Me\sizX)
  EndProcedure
  
  ; ---[ Get Height ]-----------------------------------------------
  Procedure GetHeight( *Me.ControlProperty_t)
;     ; ---[ Sanity Check ]-----------------------------------------------
;     If Not *Me : ProcedureReturn : EndIf
;     If *Me\percY > 0
;       *Me\sizY = *Me\parent\sizY * (*Me\percY / 100)
;     Else
;       Protected *son.Control::Control_t
;       *Me\sizY = 0
;       For i=0 To *Me\chilcount-1
;       
;         *son = *Me\children(i)
;         If (*son\posY+*son\sizY) > *Me\sizY
;           *Me\sizY = *son\posY+*son\sizY
;         EndIf
;       Next
;     EndIf
;     
    ProcedureReturn *Me\parent\sizY
  EndProcedure
  
  ; ---[ Get Control By Index ]-----------------------------------------------
  Procedure GetControlByIndex( *Me.ControlProperty_t, index.i)
    
    ; ---[ Sanity Check ]-----------------------------------------------
    If Not *Me  Or index <0 Or index >= *Me\chilcount : ProcedureReturn #Null : EndIf
    ProcedureReturn *Me\children(index)

  EndProcedure
  
  ; ---[ Get Control By Index ]-----------------------------------------------
  Procedure GetControlByName( *Me.ControlProperty_t, name.s)
    
    ; ---[ Sanity Check ]-----------------------------------------------
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

  
  ; ---[ On Init ]-----------------------------------------------
  Procedure Init( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; ---[ Draw Pick Image ]------------------------------------------
    DrawPickImage(*Me)
    Draw(*Me)
    
    ProcedureReturn(#True)
  EndProcedure

  ; ---[ Refresh ]-----------------------------------------------
  Procedure Refresh( *Me.ControlProperty_t)
    
    ; ---[ Sanity Check ]--------------
    If Not *Me : ProcedureReturn : EndIf
    
    
    ProcedureReturn(#True)
  EndProcedure
  
  ; ---[ Send Event To Filtered Child ]-----------------------------------------------
  Procedure EventWithFilter(*Me.ControlProperty_t,filter.i,ev_type.i)
    Protected *son.Control::IControl
    Protected i
    For i=0 To *Me\chilcount-1
      *son = *Me\children(i)
      *son\OnEvent(ev_type,#Null)
    Next i
    
  ;   ForEach *Me\groups()
  ;   
  ;     If filter = *Me\groups()\GetGadgetID() : *Me\groups()\Event( ev_type ) : EndIf
  ;   Next
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Get Num Control In Row
  ; ----------------------------------------------------------------------------
  Procedure GetNumControlInRow(*Me.ControlProperty_t, base.i)
    Protected index = base
    Protected search.b = #True
    While search
      If Not *Me\rowflags(index) : search = #False : EndIf
      index+1
    Wend
    ProcedureReturn index - base
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Resize Controls In Row
  ; ----------------------------------------------------------------------------
  Procedure ResizeControlsInRow(*Me.ControlProperty_t, start_index.i, num_controls.i)
    Dim widths.i(num_controls)
    Define fixed_width = Control::MARGING * 2
    Define current_width, current_index, num_fixed
    Define e
    For i=0 To num_controls - 1
      current_index = start_index + i
      If *Me\children(current_index)\fixedX
        current_width = *Me\children(current_index)\sizX 
        fixed_width + current_width + Control::PADDING
        widths(i) = current_width
        num_fixed + 1
      EndIf
    Next
    Define remaining_width = *Me\sizX - (fixed_width + Control::MARGING)
    Define x = Control::MARGING
    Define ev_data.Control::EventTypeDatas_t
    ev_data\x = 0
    ev_data\y = #PB_Ignore
    ev_data\width = #PB_Ignore
    ev_data\height = #PB_Ignore
    
    Define son.Control::IControl
    For i=0 To num_controls - 1
      current_index = start_index + i
      son = *Me\children(current_index)
      
      If *Me\children(current_index)\fixedX
        ev_data\width = widths(i)
      Else
        ev_data\width = remaining_width / (num_controls - num_fixed)
      EndIf

      ev_data\x     = *Me\posX + x
      ev_data\y     = #PB_Ignore
      son\OnEvent(#PB_EventType_Resize, ev_data)
      x + ev_data\width + Control::PADDING
    Next
  EndProcedure

  ; ============================================================================
  ;  OVERRIDE ( Control::IControl )
  ; ============================================================================
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlProperty_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )  
    ; ---[ Local Variables ]----------------------------------------------------
    Protected  ev_data.Control::EventTypeDatas_t
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    Protected idx,xm,ym
    Protected *overchild.Control::Control_t
    Protected nbc_row.i
    
    *Me\pickID = Pick(*Me)
    If *Me\pickID > -1 And *Me\pickID < *Me\chilcount 
      *overchild = *Me\children(*Me\pickID)
    Else
      *overchild = #Null
    EndIf

    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
        If *ev_data\x <> #PB_Ignore And Not *Me\fixedX : *Me\posX = *ev_data\x : EndIf
        If *ev_data\y <> #PB_Ignore And Not *Me\fixedY : *Me\posY = *ev_data\y : EndIf
        If *ev_data\width <> #PB_Ignore : *Me\sizX = *ev_data\width : EndIf
        If *ev_data\height <> #PB_Ignore : *Me\sizY = *ev_data\height : EndIf
        
        If *Me\percX > 0 : *Me\sizX = *Me\parent\sizX * (*Me\percX / 100) : EndIf
        If *Me\percY > 0 : *Me\sizY = *Me\parent\sizY * (*Me\percY / 100) : EndIf
 
        ev_data\x = 0
        ev_data\y = #PB_Ignore
        ev_data\width = *ev_data\width
        ev_data\height = #PB_Ignore

        ; Resize Controls
        For c=0 To *Me\chilcount - 1
          If *Me\rowflags(c) 
            nbc_row = GetNumControlInRow(*Me, c)
            ResizeControlsInRow(*Me, c, nbc_row)
            c + nbc_row - 1
          Else
            son = *Me\children(c)
            *son = son
            If *son\type = Control::#ICON Or *son\type = Control::#TEXT: Continue : EndIf
            ev_data\width = *ev_data\width
            ev_data\x     = *son\posX
            ev_data\y     = *son\posY
            son\OnEvent(#PB_EventType_Resize, ev_data)

          EndIf
        Next
        
        DrawPickImage(*Me)
        Draw( *Me )
        ProcedureReturn( #True )
          
      ; ------------------------------------------------------------------------
      ;  DrawChild
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_DrawChild
        *son.Control::Control_t = *ev_data
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
  
      ; ------------------------------------------------------------------------
      ;  Focus
      ; ------------------------------------------------------------------------
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

      ; ------------------------------------------------------------------------
      ;  ChildFocused
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildFocused
        *Me\focuschild = *ev_data
        
      ; ------------------------------------------------------------------------
      ;  ChildDeFocused
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildDeFocused
        *Me\focuschild = #Null
        
      ; ------------------------------------------------------------------------
      ;  ChildCursor
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_ChildCursor
        SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data )
        
      ; ------------------------------------------------------------------------
      ;  LostFocus
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LostFocus
        If *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          *Me\focuschild = #Null
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
        ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
        
        xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
        ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )

         If *Me\overchild <> *overchild And  Not *Me\down
            If *Me\overchild : *Me\overchild\OnEvent(#PB_EventType_MouseLeave) : EndIf
            *Me\overchild = *overchild
            If *Me\overchild : *Me\overchild\OnEvent(#PB_EventType_MouseEnter) : EndIf
            SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )

        ElseIf *overchild And Not *Me\down
          *Me\overchild = *overchild
          ev_data\x    = xm - *overchild\posX + *Me\posX
          ev_data\y    = ym - *overchild\posY + *Me\posY
          *Me\overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
        Else
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x    = xm - *overchild\posX + *Me\posX
            ev_data\y    = ym - *overchild\posY + *Me\posY
            *Me\overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      *Me\down = #True
      If *Me\overchild
        Define *overchild.Control::Control_t = *Me\overchild
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
      
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
        If *overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild = *overchild
          *Me\overchild\OnEvent(#PB_EventType_LeftButtonUp,@ev_data)
        EndIf
        *Me\down = #False
        
      ; ------------------------------------------------------------------------
      ;  LeftDoubleClick
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftDoubleClick
        *overchild.Control::Control_t = *Me\overchild
        If *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_LeftDoubleClick,@ev_data)
          *Me\focuschild = *Me\overchild
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  RightButtonDown
      ; ------------------------------------------------------------------------
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
        
      ; ------------------------------------------------------------------------
      ;  RightButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_RightButtonUp
        
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        *Me\down = #False
      
      ; ------------------------------------------------------------------------
      ;  RightButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_RightButtonUp
        If *Me\overchild
          *overchild.Control::Control_t = *Me\overchild
          ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
          ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Input
      ; ------------------------------------------------------------------------
    Case #PB_EventType_Input
        ; Do We Have A Focused Child
        If *Me\focuschild
          ; Retrieve Character
          ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input))
          ; Send Character To Focused Child
          *Me\focuschild\OnEvent(#PB_EventType_Input,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  KeyDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_KeyDown
        ; Do We Have A Focused Child
        If *Me\focuschild
          ; Retrieve Key 
          ev_data\key   = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key      )
          ev_data\modif = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
          
          ; Send Key To Focused Child
          *Me\focuschild\OnEvent(#PB_EventType_KeyDown,@ev_data)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_COPY
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_COPY
        ; Do We Have A Focused Child
        If *Me\focuschild
          MessageRequester("COPY", "Copy")
          ; Send Key To Focused Child
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_COPY,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_CUT
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_CUT
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_CUT,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_PASTE
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_PASTE
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_PASTE,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_UNDO
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_UNDO
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
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
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  
;   ; ----------------------------------------------------------------------------
;   ;  Test
;   ; ----------------------------------------------------------------------------
;   Procedure Test(*prop.ControlProperty_t,*mesh.Polymesh::Polymesh_t)
;    
;     AppendStart(*prop)
;     AddBoolControl(*prop,"boolean","boolean",#False,*mesh)
;     AddFloatControl(*prop,"float","float",#False,*mesh)
;     AddIntegerControl(*prop,"integer","integer",#False,*mesh)
;     AddReferenceControl(*prop,"reference1","ref1",*mesh)
;     AddReferenceControl(*prop,"reference2","ref2",*mesh)
;     AddReferenceControl(*prop,"reference3","ref3",*mesh)
;     *group = AddGroup(*prop,"BUTTON")
;     
;     ControlGroup::Append(*group,ControlButton::New(*prop,"button","button",#True,#PB_Button_Toggle))
;     EndGroup(*prop)
;     
;     
;     
;     Define q.Math::q4f32
;     Quaternion::SetIdentity(q)
;     AddQuaternionControl(*prop,"quaternion","quat",@q,*mesh)
;     
;     *group = AddGroup(*prop,"ICONS")
;     ControlGroup::RowStart(*group)
;     ControlGroup::Append(*group,ControlIcon::New(*mesh,"Back",ControlIcon::#Icon_Back,0))
;     ControlGroup::Append(*group,ControlIcon::New(*mesh,"Stop",ControlIcon::#Icon_Stop,0))
;     ControlGroup::Append(*group,ControlIcon::New(*mesh,"Play",ControlIcon::#Icon_Play,#PB_Button_Toggle))
;     ControlGroup::Append(*group,ControlIcon::New(*mesh,"Loop",ControlIcon::#Icon_Loop,0))
;     ControlGroup::RowEnd(*group)
;     EndGroup(*prop)
;         
;     AppendStop(*prop)
;   EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlProperty_t )
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me : ProcedureReturn : EndIf
    Protected c
    
    Protected ictl.Control::IControl
    For c=0 To *Me\chilcount-1
      ictl = *Me\children(c)
      ictl\Delete()
    Next
    If IsGadget(*Me\gadgetID) : FreeGadget(*Me\gadgetID) : EndIf
    If IsImage(*Me\imageID) : FreeImage(*Me\imageID) : EndIf
    If IsImage(*Me\pickID) : FreeImage(*Me\pickID) : EndIf
    
    Object::TERM(ControlProperty)

  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.UI::UI_t, name.s, label.s,x.i=0,y.i=0,width.i=320,height.i=120 ,decoration = #PROPERTY_LABELED)
    ; Allocate Object Memory
    Protected *Me.ControlProperty_t = AllocateMemory( SizeOf(ControlProperty_t) )
    
    Object::INI(ControlProperty)
    
    ; Init Members
    *Me\object     = #Null
    *Me\parent     = *parent
    *Me\type       = #PB_GadgetType_Container
    *Me\decoration = decoration
    *Me\name       = name
    *Me\gadgetID   = *parent\gadgetID
    *Me\imageID    = CreateImage(#PB_Any,width,height)
    *Me\pickID     = CreateImage(#PB_Any,width,height)
    SetGadgetColor(*Me\gadgetID,#PB_Gadget_BackColor,UIColor::COLOR_MAIN_BG )
  
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\label      = label
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\head       = ControlHead::New(*Me, name+"Head", 0,0,0,width, 32)
  
    ; Init Structure
    InitializeStructure( *Me, ControlProperty_t ) ; List
    DrawEmpty(*Me)
    
    View::SetContent(*parent,*Me)
   
    ; Return Initialized Object
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Class::DEF(ControlProperty)
EndModule


; ============================================================================
;  EOF
; ============================================================================

      
      
    
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 297
; FirstLine = 283
; Folding = ----------
; EnableXP