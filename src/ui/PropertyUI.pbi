
XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "UI.pbi"

;========================================================================================
; PropertyUI Module Declaration
;========================================================================================
DeclareModule PropertyUI
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Structure PropertyUI_t Extends UI::UI_t
    *prop.ControlProperty::ControlProperty_t
    List *props.ControlProperty::ControlProperty_t()
    *focus.Control::Control_t
    anchorX.i
    anchorY.i
  EndStructure
  
  Declare New(*parent.View::View_t,name.s,*obj.Object3D::Object3D_t)
  Declare Delete(*Me.PropertyUI_t)
  Declare Resize(*Me.PropertyUI_t)
  Declare Draw(*Me.PropertyUI_t)
  Declare DrawPickImage(*Me.PropertyUI_t)
  Declare Pick(*Me.PropertyUI_t)
  Declare OnEvent(*Me.PropertyUI_t,event.i)
  Declare Clear(*Me.PropertyUI_t)
  Declare.b CheckObject3DExists(*Me.PropertyUI_t, *object.Object3D::Object3D_t)
  Declare SetupFromObject3D(*Me.PropertyUI_t,*object.Object3D::Object3D_t)
  Declare.b CheckNodeExists(*Me.PropertyUI_t, *node.Node::Node_t)
  Declare SetupFromNode(*Me.PropertyUI_t,*node.Node::Node_t)
  Declare AppendStart(*Me.PropertyUI_t)
  Declare AppendStop(*Me.PropertyUI_t)
  Declare AddProperty(*Me.PropertyUI_t, *prop.ControlProperty::COntrolProperty_t)
  Declare Setup(*Me.PropertyUI_t,*object.Object::Object_t)
  Declare CollapseProperty(*Me.PropertyUI_t, index.i)
  Declare ExpandProperty(*Me.PropertyUI_t, index.i)
  Declare DeleteProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
  Declare DeletePropertyByIndex(*Me.PropertyUI_t, index.i)
  Declare OnDeleteProperty(*Me.PropertyUI_t, index.i)
  Declare OnExpandProperty(*Me.PropertyUI_t, expand.b, index.i)
  
  DataSection 
    PropertyUIVT: 
    Data.i @Delete()
    Data.i @Resize()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
    Data.i @OnEvent()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

;========================================================================================
; PropertyUI Module Implementation
;========================================================================================
Module PropertyUI
  UseModule Math
  
  ; ----------------------------------------------------------------------------
  ;  Constructor
  ; ----------------------------------------------------------------------------
  Procedure New(*parent.View::View_t, name.s,*obj. Object3D::Object3D_t)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
   
    Protected *Me.PropertyUI_t = AllocateMemory(SizeOf(PropertyUI_t))
    InitializeStructure(*Me,PropertyUI_t)
    Object::INI(PropertyUI)
    *Me\name = name
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
    
    *Me\parent = *parent
    *Me\container = ScrollAreaGadget(#PB_Any,x,y,w,h,w,h,10,#PB_ScrollArea_BorderLess)
    *Me\gadgetID = *Me\container
    
    SetGadgetColor(*Me\container,#PB_Gadget_BackColor, UIColor::COLOR_MAIN_BG)
    
    *Me\prop = #Null
   
    View::SetContent(*parent,*Me)
    CloseGadgetList()
    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete(*Me.PropertyUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    
    ClearStructure(*Me,PropertyUI_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw(*Me.PropertyUI_t)
    
  EndProcedure
  
  ; Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure DrawPickImage(*Me.PropertyUI_t)
    
  EndProcedure
  
  ; Pick
  ; ----------------------------------------------------------------------------
  Procedure Pick(*Me.PropertyUI_t)
    
  EndProcedure
  
  ; Resize
  ; ----------------------------------------------------------------------------
  Procedure Resize(*Me.PropertyUI_t)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Append Start
  ; ----------------------------------------------------------------------------
  Procedure AppendStart(*Me.PropertyUI_t)
    OpenGadgetList(*Me\container)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Append End
  ; ----------------------------------------------------------------------------
  Procedure AppendStop(*Me.PropertyUI_t)
    CloseGadgetList()
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  OnEvent
  ; ----------------------------------------------------------------------------
  Procedure OnEvent(*Me.PropertyUI_t,event.i)    
    If *Me
      Protected *top.View::View_t = *Me\parent
      Protected ev_datas.Control::EventTypeDatas_t
      ev_datas\x = 0
      ev_datas\y = 0
      ev_datas\width = *top\width 
      Select event
        Case #PB_Event_SizeWindow
          *Me\sizX = *top\width
          ResizeGadget(*Me\container,*top\x,*top\y,*top\width,*top\height)
          SetGadgetAttribute(*Me\container, #PB_ScrollArea3D_InnerWidth, *Me\sizX)
          SetGadgetAttribute(*Me\container, #PB_ScrollArea3D_InnerHeight, *Me\sizY)
         
          ev_datas\x = #PB_Ignore
          ev_datas\y = #PB_Ignore
          ev_datas\height = #PB_Ignore

          If ListSize(*Me\props())
            ForEach *Me\props()
              CompilerIf #PB_Compiler_Version <560
                ControlProperty::OnEvent(*Me\props(),Control::#PB_EventType_Resize,@ev_datas)
              CompilerElse
                ControlProperty::OnEvent(*Me\props(),#PB_EventType_Resize,@ev_datas)
              CompilerEndIf
            Next
          EndIf
          
        Case #PB_Event_Gadget
          If EventType()  = #PB_EventType_LeftButtonDown
            *Me\down = #True
          ElseIf EventType() = #PB_EventType_LeftButtonUp
            *Me\down = #False
          EndIf
          
          Define currentGadget
          If *Me\down And *Me\focus
            currentGadget = *Me\focus\gadgetID
          Else
            currentGadget = EventGadget()
          EndIf

          If ListSize(*Me\props())
            ForEach *Me\props()
              If *Me\props()\gadgetID = currentGadget
                ControlProperty::OnEvent(*Me\props(),EventType(),@ev_datas)
                *Me\focus = *Me\props()
              EndIf
            Next
          EndIf

        Case #PB_Event_Menu
          If ListSize(*Me\props())
            ForEach *Me\props()
              ControlProperty::OnEvent(*Me\props(),EventMenu(),#Null)
            Next
          EndIf 
      EndSelect
      
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   CALLBACKS
  ; ----------------------------------------------------------------------------
  Procedure OnDeleteProperty( *Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
    PropertyUI::DeleteProperty(*Me, *prop)
  EndProcedure
  Callback::DECLARECALLBACK(OnDeleteProperty, Arguments::#PTR, Arguments::#PTR)
  
  Procedure OnExpandProperty( *Me.PropertyUI_t, expand.b, index.i)
    ;PropertyUI::DeletePropertyByIndex(*Me, index)
  EndProcedure
  Callback::DECLARECALLBACK(OnExpandProperty, Arguments::#PTR, Arguments::#BOOL, Arguments::#INT)
  
  Procedure OnDeleteObject(*Me.PropertyUI_t, *object.Object::Object_t)
    ForEach *Me\props()
      If *Me\props()\object = *object
        If *Me\props()\head
          Signal::Trigger(*Me\props()\head\on_delete, Signal::#SIGNAL_TYPE_PING)
        EndIf
        Break
      EndIf
    Next
  EndProcedure
  Callback::DECLARECALLBACK(OnDeleteObject, Arguments::#PTR, Arguments::#PTR)
  
  ; ----------------------------------------------------------------------------
  ;  On Message
  ; ----------------------------------------------------------------------------
  Procedure OnMessage( id.i, *up)
;     Protected *sig.Signal::Signal_t = *up
;     Protected *Me.PropertyUI::PropertyUI_t = *sig\rcv_inst
;     Protected *h.ControlHead::ControlHead_t = *sig\snd_inst
;     Protected *c.ControlProperty::ControlProperty_t = *h\parent
; 
;     If id = 0
;       DeleteProperty(*Me, *c)
;     ElseIf id = 1
;       If *c\expanded
;         CollapseProperty(*Me, *c)
;       Else
;         ExpandProperty(*Me, *c)
;       EndIf
;     EndIf
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear(*Me.PropertyUI_t)
    Protected i
    Protected *prop.ControlProperty::ControlProperty_t = *Me\prop
    If *prop
      ControlProperty::Clear(*prop)
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Check 3D Object Exists
  ; ----------------------------------------------------------------------------
  Procedure.b CheckObject3DExists(*Me.PropertyUI_t, *obj.Object3D::Object3D_t)
    ProcedureReturn #False
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Setup From Object 3D
  ; ----------------------------------------------------------------------------
  Procedure SetupFromObject3D(*Me.PropertyUI_t,*object.Object3D::Object3D_t)
    If Not *object Or Not *Me: ProcedureReturn : EndIf
    Clear(*Me)
    Protected *p.ControlProperty::ControlProperty_t = ControlProperty::New(*Me, *object\name, *object\name, *object)
    AddElement(*Me\props())
    *Me\props() = *p
    *Me\prop = *p
    *p\label = *object\name
    ControlProperty::AppendStart(*p)
  
    Protected v.Math::v3f32
    Protected *attr.Attribute::Attribute_t
    Define i
    ForEach *object\geom\m_attributes()
      *attr = *object\geom\m_attributes()
      If Not *attr\readonly And *attr\constant
        Select *attr\datatype
          Case Attribute::#ATTR_TYPE_BOOL
            ControlProperty::AddBoolControl(*p,*attr\name,*attr\name,#False,*attr)
          Case Attribute::#ATTR_TYPE_INTEGER
            ControlProperty::AddIntegerControl(*p,*attr\name,*attr\name,0,*attr)
          Case Attribute::#ATTR_TYPE_FLOAT
            ControlProperty::AddFloatControl(*p,*attr\name,*attr\name,0,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR2
            Protected v2.v2f32
            ControlProperty::AddVector2Control(*p,*attr\name,*attr\name,v2,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR3
            Protected v3.v3f32
            ControlProperty::AddVector3Control(*p,*attr\name,*attr\name,v3,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR4
            Protected c4.c4f32
            ControlProperty::AddColorControl(*p,*attr\name,*attr\name,c4,*attr)
          Case Attribute::#ATTR_TYPE_QUATERNION
            Protected q.q4f32
            ControlProperty::AddQuaternionControl(*p,*attr\name,*attr\name,q,*attr)
          Case Attribute::#ATTR_TYPE_MATRIX4
            Protected m.m4f32
            Matrix4::SetIdentity(m)
            ControlProperty::AddMatrix4Control(*p,*attr\name,*attr\name,m,*attr) 
        EndSelect
      EndIf
    Next
    
    ControlProperty::AppendStop(*p)
    Signal::CONNECTCALLBACK(*object\on_delete, OnDeleteObject, *Me, *object)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Check Node Exists
  ; ----------------------------------------------------------------------------
  Procedure.b CheckNodeExists(*Me.PropertyUI_t, *node.Node::Node_t)
    Define index.i = 0
    If ListSize(*Me\props())
      FirstElement(*Me\props())
      Define *first = @*Me\props()
    EndIf
    
;     ForEach *Me\props()
;       If *Me\props()\object = *node
;         If ListSize(*Me\props()) > 1 And index > 0
;           Define *current = @*Me\props()
;           SwapElements(*Me\props(), *current, *first)
;           OnEvent(*Me, #PB_Event_SizeWindow)
;         EndIf
;         
;         ProcedureReturn #True
;       EndIf
;       index + 1
;     Next
    ProcedureReturn #False
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Setup From Node
  ; ----------------------------------------------------------------------------
  Procedure SetupFromNode(*Me.PropertyUI_t,*node.Node::Node_t)
    
    If Not *node Or Not *Me: ProcedureReturn : EndIf
    ;Clear(*Me)
    Protected *p.ControlProperty::ControlProperty_t = ControlProperty::New(*node,*node\name,*node\name,*Me\anchorX,*Me\anchorY,*Me\sizX, *Me\sizY) 
    *p\label = *node\type
    
    ControlProperty::AppendStart(*p)
    ControlProperty::AddHead(*p)

    Protected *attr.Attribute::Attribute_t
    Define i
    Define *port.NodePort::NodePort_t
    ; Add Input Ports 
    ForEach *node\inputs()
      With *node\inputs()
        
        If Not \connected
          Select \currenttype
            Case Attribute::#ATTR_TYPE_BOOL
              Protected *bVal.CArray::CArrayBool = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddBoolControl(*p,\name,\name,CArray::GetValueB(*bVal,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_FLOAT
              Protected *fVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddFloatControl(*p,\name,\name,CArray::GetValueF(*fVal,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_INTEGER
              Protected *iVal.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddIntegerControl(*p,\name,\name,CArray::GetValueI(*iVal,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_VECTOR2
              Protected *vVal2.CArray::CArrayV2F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddVector2Control(*p,\name,\name,CArray::GetValue(*vVal2,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_VECTOR3
              Protected *vVal3.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddVector3Control(*p,\name,\name,CArray::GetValue(*vVal3,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_VECTOR4
              Protected *vVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*vVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_QUATERNION
              Protected *qVal4.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddQuaternionControl(*p,\name,\name,CArray::GetValue(*qVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_COLOR
              Protected *cVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*cVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_MATRIX4
              Protected *mVal4.CArray::CArrayM4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddMatrix4Control(*p,\name,\name,CArray::GetValue(*mVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_REFERENCE
              Protected *ref.Globals::Reference_t = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddReferenceControl(*p,\name,*ref\reference,*node\inputs())
              
            Case Attribute::#ATTR_TYPE_FILE
              ControlProperty::AddFileControl(*p,\name,\name,*node\inputs())
              
            Case Attribute::#ATTR_TYPE_STRING
              Protected *sVal.CArray::CArrayStr =  NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddStringControl(*p,\name,CArray::GetValueStr(*sVal,0),*node\inputs())
          EndSelect
        EndIf
        
      EndWith    
    Next
    
    ControlProperty::AppendStop(*p)
    *Me\anchorY + *p\dy
    
    SetGadgetAttribute(*Me\container, #PB_ScrollArea_InnerWidth, *Me\sizX)
    SetGadgetAttribute(*Me\container, #PB_ScrollArea_InnerHeight, *Me\anchorY)
    Signal::CONNECTCALLBACK(*node\on_delete, OnDeleteObject, *Me, *object)
    ProcedureReturn *p

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Add Property
  ; ----------------------------------------------------------------------------
  Procedure AddProperty(*Me.PropertyUI_t,*prop.ControlProperty::ControlProperty_t)
    ;check if already in list
    ForEach *Me\props() : If *prop = *Me\props() :  ProcedureReturn : EndIf : Next
    
    AddElement(*Me\props())
    *Me\props() = *prop
    *Me\prop = *prop
    If *prop\head
      Define idx = ListSize(*Me\props())-1
      Signal::CONNECTCALLBACK(*prop\head\on_delete, OnDeleteProperty, *Me, *prop)
    EndIf
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Setup
  ; ----------------------------------------------------------------------------
  Procedure Setup(*Me.PropertyUI_t,*object.Object::Object_t)
    OpenGadgetList(*Me\container)
    Protected cName.s = *object\class\name
    If Right(cName,4) = "Node"
      Protected *node.Node::Node_t = *object
      Protected *prop.ControlProperty::ControlProperty_t = SetupFromNode(*Me,*node)
      PropertyUI::AddProperty(*Me, *prop)
      
    Else
      Protected *obj.Object3D::Object3D_t = *object
       SetupFromObject3D(*Me,*obj)
    EndIf
    CloseGadgetList()
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Collapse Property
  ; ----------------------------------------------------------------------------
  Procedure CollapseProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY = 0
    ForEach *Me\props()
      If *Me\props() = *prop
        *Me\props()\expanded = #False
        *Me\props()\sizX = *Me\sizX
        offY = *Me\props()\sizY - ControlHead::#HEAD_BUTTON_SIZE
        *Me\props()\sizY = ControlHead::#HEAD_BUTTON_SIZE
        ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
        dirty = #True
      Else
        If dirty
          *Me\props()\posY - offY
          ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
        EndIf
      EndIf
    Next
    
    If dirty
      *Me\anchorY - offY
    EndIf
    
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Expand Property
  ; ----------------------------------------------------------------------------
  Procedure ExpandProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY.i = 0
    ForEach *Me\props()
      If *Me\props() = *prop
        *Me\props()\expanded = #True
        *Me\props()\sizX = *Me\sizX
        *Me\props()\sizY = ControlProperty::GetHeight(*Me\props())
        ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
        offY = *Me\props()\sizY - ControlHead::#HEAD_BUTTON_SIZE
        dirty = #True
      Else
        If dirty
          *Me\props()\posY + offY
          ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
        EndIf
      EndIf
    Next
    ResetList(*Me\props())
    
    If dirty
      OnEvent(*Me, #PB_Event_SizeWindow)
      *Me\anchorY + offY
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Delete Property
  ; ----------------------------------------------------------------------------
  Procedure DeleteProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY.i = 0
    Protected idx.i=0
    Protected toRemove.i = -1
    
    ForEach *Me\props()
      If *Me\props() = *prop
        offY = *Me\props()\sizY
        
        toRemove = idx
        dirty=#True
      Else
        If dirty
         
          ResizeGadget(*Me\props()\gadgetID, #PB_Ignore, *Me\props()\posY-offY, *Me\sizX, #PB_Ignore)
           *Me\props()\posY - offY
        EndIf
      EndIf
      idx+1
    Next
    
    If toRemove > -1
      SelectElement(*Me\props(), toRemove)
      DeleteElement(*Me\props())
      ControlProperty::Delete(*prop)
    EndIf
    
    If ListSize(*Me\props())
      *Me\anchorY - offY
    Else
      *Me\anchorY = 0
    EndIf
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Procedure DeletePropertyByIndex(*Me.PropertyUI_t, index.i)
    SelectElement(*Me\props(), index)
    Define offY = *Me\props()\sizY
    ControlProperty::Delete(*Me\props())
    DeleteElement(*Me\props())
    While NextElement(*Me\props())
      *Me\props()\posY - offY
    Wend
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( PropertyUI )
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 27
; FirstLine = 6
; Folding = -----
; EnableXP
; EnableUnicode