
XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "UI.pbi"

;========================================================================================
; ScintillaUI Module Declaration
;========================================================================================
DeclareModule ScintillaUI
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Structure ScintillaUI_t Extends UI::UI_t
    
  EndStructure
  
  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*Me.ScintillaUI_t)
  Declare Init(*Me.ScintillaUI_t)
  Declare OnEvent(*Me.ScintillaUI_t,event.i)
  Declare Term(*Me.ScintillaUI_t)
  Declare Clear(*Me.ScintillaUI_t)
  
  DataSection 
    ScintillaUIVT: 
    Data.i @Init()
    Data.i @OnEvent()
    Data.i @Term()

  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

;========================================================================================
; ScintillaUI Module Implementation
;========================================================================================
Module ScintillaUI

  ; ----------------------------------------------------------------------------
  ;  Constructor
  ; ----------------------------------------------------------------------------
  Procedure New(*parent.View::View_t, name.s,*obj. Object3D::Object3D_t)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
   
    Protected *Me.ScintillaUI_t = AllocateMemory(SizeOf(ScintillaUI_t))
    InitializeStructure(*Me,ScintillaUI_t)
    Object::INI(ScintillaUI)
    *Me\name = name
    *Me\x = x
    *Me\y = y
    *Me\width = w
    *Me\height = h
    
    *Me\container = ScrollAreaGadget(#PB_Any,x,y,w,h,w-1,h-1)
    SetGadgetColor(*Me\container,#PB_Gadget_BackColor, UIColor::COLOR_MAIN_BG)
    
    *Me\scintilla = ControlScintilla::New()
   
    CloseGadgetList()
    
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete(*Me.ScintillaUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    
    ClearStructure(*Me,ScintillaUI_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure Init(*Me.ScintillaUI_t)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  OnEvent
  ; ----------------------------------------------------------------------------
  Procedure OnEvent(*Me.ScintillaUI_t,event.i)
    If *Me
      Protected *top.View::View_t = *Me\top
      Protected ev_datas.Control::EventTypeDatas_t
      ev_datas\x = 0
      ev_datas\y = 0
      ev_datas\width = *top\width
      Select event
        Case #PB_Event_SizeWindow
          ResizeGadget(*Me\container,*top\x,*top\y,*top\width,*top\height)
          ev_datas\x = 0
          ev_datas\y = 0
          ev_datas\height = #PB_Ignore

          If ListSize(*Me\props())
            ForEach *Me\props()
              ControlProperty::OnEvent(*Me\props(),#PB_EventType_Resize,@ev_datas)
              ev_datas\y = ev_datas\y + *Me\props()\sizY
            Next
          EndIf

          SetGadgetAttribute(*Me\container,#PB_ScrollArea_InnerWidth, *top\width-2)
          SetGadgetAttribute(*Me\container,#PB_ScrollArea_InnerHeight, ev_datas\y-2)
          
        Case #PB_Event_Gadget
          If ListSize(*Me\props())
            ForEach *Me\props()
              ControlProperty::OnEvent(*Me\props(),EventType(),@ev_datas)
            Next
          EndIf

        Case #PB_Event_Menu
          If ListSize(*Me\props())
            ForEach *Me\props()
              ControlProperty::OnEvent(*Me\props(),EventMenu(),#Null)
              ev_datas\y+*Me\props()\sizY
            Next
          EndIf 
      EndSelect
      
    EndIf
    
  EndProcedure

  
  ; ----------------------------------------------------------------------------
  ;  Terminate
  ; ----------------------------------------------------------------------------
  Procedure Term(*Me.ScintillaUI_t)
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  On Message
  ; ----------------------------------------------------------------------------
  Procedure OnMessage( id.i, *up)
    Protected *sig.Signal::Signal_t = *up
    Protected *Me.ScintillaUI::ScintillaUI_t = *sig\rcv_inst
    Protected *h.ControlHead::ControlHead_t = *sig\snd_inst
    Protected *c.ControlProperty::ControlProperty_t = *h\parent
    Protected cmd.b = *sig\sigdata
    If cmd
      DeleteProperty(*Me, *c)
    Else
      If *c\expanded
        CollapseProperty(*Me, *c)
      Else
        ExpandProperty(*Me, *c)
      EndIf
      
    EndIf

        
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear(*Me.ScintillaUI_t)
    Protected i
    Protected *prop.ControlProperty::ControlProperty_t = *Me\prop
    If *prop
      For i=0 To *prop\chilcount-1
        Debug *prop\children(i)\name
      Next
      ControlProperty::Clear(*prop)
    EndIf
  EndProcedure
 
  ; ----------------------------------------------------------------------------
  ;  Setup From 3D Object
  ; ----------------------------------------------------------------------------
  Procedure SetupFrom3DObject(*Me.ScintillaUI_t,*object.Object3D::Object3D_t)
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
    ForEach *object\m_attributes()
      *attr = *object\m_attributes()
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
            ControlProperty::AddVector2Control(*p,*attr\name,*attr\name,@v2,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR3
            Protected v3.v3f32
            ControlProperty::AddVector3Control(*p,*attr\name,*attr\name,@v3,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR4
            Protected c4.c4f32
            ControlProperty::AddColorControl(*p,*attr\name,*attr\name,@c4,*attr)
          Case Attribute::#ATTR_TYPE_QUATERNION
            Protected q.q4f32
            ControlProperty::AddQuaternionControl(*p,*attr\name,*attr\name,@q,*attr)
          Case Attribute::#ATTR_TYPE_MATRIX4
            Protected m.m4f32
            Matrix4::SetIdentity(@m)
            ControlProperty::AddMatrix4Control(*p,*attr\name,*attr\name,@m,*attr) 
        EndSelect
      EndIf
    Next
    
    ControlProperty::AppendStop(*p)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Setup From Node
  ; ----------------------------------------------------------------------------
  Procedure SetupFromNode(*Me.ScintillaUI_t,*node.Node::Node_t)
    
    If Not *node Or Not *Me: ProcedureReturn : EndIf
    ;Clear(*Me)
    Protected *p.ControlProperty::ControlProperty_t = ControlProperty::New(*node,*node\name,*node\name,*Me\anchorX,*Me\anchorY,*Me\width, *Me\height) 
    AddElement(*Me\props())
    *Me\props() = *p
    *Me\prop = *p
    *p\label = *node\type
    
    ControlProperty::AppendStart(*p)
    ControlProperty::AddHead(*p)

    Protected *attr.Attribute::Attribute_t
    Define i
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
              
            Case Attribute::#ATTR_TYPE_REFERENCE
              ControlProperty::AddReferenceControl(*p,\name,\reference,*node\inputs())
              
            Case Attribute::#ATTR_TYPE_STRING
              Protected *sVal.CArray::CArrayStr =  NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddStringControl(*p,\name,CArray::GetValueStr(*sVal,0),*node\inputs())
          EndSelect
        EndIf
        
      EndWith    
    Next
    
    ControlProperty::AppendStop(*p)
    *Me\anchorY + *p\dy
    
    SetGadgetAttribute(*Me\container, #PB_ScrollArea_InnerWidth, *Me\width)
    SetGadgetAttribute(*Me\container, #PB_ScrollArea_InnerHeight, *Me\anchorY)
    
    Protected *head.ControlHead::ControlHead_t = *p\head
    Object::SignalConnect(*Me, *head\slot,0)

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Add Property
  ; ----------------------------------------------------------------------------
  Procedure AddProperty(*Me.ScintillaUI_t,*prop.ControlProperty::ControlProperty_t)
    OpenGadgetList(*Me\container)
    AddElement(*Me\props())
    *Me\props() = *prop
    *Me\prop = *prop
    *Me\anchorY + *prop\dy
    CloseGadgetList()
  EndProcedure
  
  
  
  ; ----------------------------------------------------------------------------
  ;  Setup
  ; ----------------------------------------------------------------------------
  Procedure Setup(*Me.ScintillaUI_t,*object.Object::Object_t)
    OpenGadgetList(*Me\container)
    Protected cName.s = *object\class\name
    If Right(cName,4) = "Node"
      Protected *node.Node::Node_t = *object
      SetupFromNode(*Me,*node)
    Else
      Protected *obj.Object3D::Object3D_t = *object
       SetupFrom3DObject(*Me,*obj)
    EndIf
    CloseGadgetList()
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Collapse Property
  ; ----------------------------------------------------------------------------
  Procedure CollapseProperty(*Me.ScintillaUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY = 0
    ForEach *Me\props()
      If *Me\props() = *prop
        *Me\props()\expanded = #False
        *Me\props()\sizX = *Me\width
        offY = *Me\props()\sizY - ControlHead::#HEAD_HEIGHT
        *Me\props()\sizY = ControlHead::#HEAD_HEIGHT
        ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\width, *Me\props()\sizY)
        dirty = #True
      Else
        If dirty
          *Me\props()\posY - offY
          ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\width, *Me\props()\sizY)
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
  Procedure ExpandProperty(*Me.ScintillaUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY.i = 0
    ForEach *Me\props()
      If *Me\props() = *prop
        *Me\props()\expanded = #True
        *Me\props()\sizX = *Me\width
        *Me\props()\sizY = ControlProperty::GetHeight(*Me\props())
        ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\width, *Me\props()\sizY)
        offY = *Me\props()\sizY - ControlHead::#HEAD_HEIGHT
        dirty = #True
      Else
        If dirty
          *Me\props()\posY + offY
          ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\width, *Me\props()\sizY)
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
  Procedure DeleteProperty(*Me.ScintillaUI_t, *prop.ControlProperty::ControlProperty_t)
    Protected dirty.b  =#False
    Protected offY.i = 0
    
    ForEach *Me\props()
      If *Me\props() = *prop
        offY = *Me\props()\sizY
        DeleteElement(*Me\props())
        ControlProperty::Delete(*prop)
        dirty = #True
      Else
        If dirty
          *Me\props()\posY - offY
          ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\width, *Me\props()\sizY)
        EndIf
      EndIf
    Next
    
    If dirty
      If ListSize(*Me\props())
        *Me\anchorY - offY
      Else
        *Me\anchorY = 0
      EndIf
    EndIf    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Procedure DeletePropertyByIndex(*Me.ScintillaUI_t, index.i)
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ScintillaUI )
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 106
; FirstLine = 103
; Folding = ---
; EnableXP