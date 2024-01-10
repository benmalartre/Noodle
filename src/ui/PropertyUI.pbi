XIncludeFile "UI.pbi"
XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/CompoundPort.pbi"

;========================================================================================
; PropertyUI Module Declaration
;========================================================================================
DeclareModule PropertyUI
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Structure PropertyUI_t Extends UI::UI_t
    Map *props.ControlProperty::ControlProperty_t()
    *active.ControlProperty::ControlProperty_t
  EndStructure
  
  Declare New(*parent.View::View_t,name.s)
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
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
      Data.i @DrawPickImage()
      Data.i @Pick()
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
  Procedure New(*parent.View::View_t, name.s)
    Protected *Me.PropertyUI_t = AllocateStructure(PropertyUI_t)
    Object::INI(PropertyUI)
    *Me\name = name
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    
    *Me\parent = *parent
    *Me\active = #Null
    *Me\gadgetID = CanvasGadget(#PB_Any, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY, #PB_Canvas_Keyboard)
   
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Destructor
  ; ----------------------------------------------------------------------------
  Procedure Delete(*Me.PropertyUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    
    Object::TERM(PropertyUI)
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
    *Me\posX = *Me\parent\posX
    *Me\posY = *Me\parent\posY
    *Me\sizX = *Me\parent\sizX
    *Me\sizY = *Me\parent\sizY
    
    ResizeGadget(*Me\gadgetID, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    Protected ev_datas.Control::EventTypeDatas_t
    ev_datas\x = 0
    ev_datas\y = 0
    ev_datas\width = *Me\sizX 
    ev_datas\height = *Me\sizY
    
    ForEach *Me\props()
      ControlProperty::OnEvent(*Me\props(), #PB_EventType_Resize,@ev_datas)
    Next
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Append Start
  ; ----------------------------------------------------------------------------
  Procedure AppendStart(*Me.PropertyUI_t)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Append End
  ; ----------------------------------------------------------------------------
  Procedure AppendStop(*Me.PropertyUI_t)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  OnEvent
  ; ----------------------------------------------------------------------------
  Procedure OnEvent(*Me.PropertyUI_t,event.i)    
    If Not MapSize(*Me\props()) : ProcedureReturn : EndIf
    Protected *top.View::View_t = *Me\parent
    
    If Not *Me\active
      ResetMap(*Me\props())
      If NextMapElement(*Me\props()) : *Me\active = *Me\props() : EndIf
    EndIf

    Protected ev_datas.Control::EventTypeDatas_t
    ev_datas\x = 0
    ev_datas\y = 0
    ev_datas\width = *top\sizX 
    ev_datas\height = *top\sizY
    Select event
      Case #PB_Event_SizeWindow
        Resize(*Me)
        
      Case #PB_Event_Gadget
        If EventType()  = #PB_EventType_LeftButtonDown
          *Me\down = #True
        ElseIf EventType() = #PB_EventType_LeftButtonUp
          *Me\down = #False
        EndIf
        
        If *Me\active
          ControlProperty::OnEvent(*Me\active, EventType(), @ev_datas)
        EndIf

      Case #PB_Event_Menu
        If *Me\active
          ControlProperty::OnEvent(*Me\active, EventMenu(), #Null)
        EndIf 
        
    EndSelect
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;   CALLBACKS
  ; ----------------------------------------------------------------------------
  Procedure OnDeleteProperty( *Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
    PropertyUI::DeleteProperty(*Me, *prop)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnDeleteProperty, Args::#PTR, Args::#PTR)
  
  Procedure OnExpandProperty( *Me.PropertyUI_t, expand.b, index.i)
    ;PropertyUI::DeletePropertyByIndex(*Me, index)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnExpandProperty, Args::#PTR, Args::#BOOL, Args::#INT)
  
  Procedure OnDeleteObject(*Me.PropertyUI_t, *object.Object::Object_t)
;     If *Me\prop = *object
;       If *Me\prop\head
;         Callback::Trigger(*Me\prop\head\on_delete, Callback::#SIGNAL_TYPE_PING)
;       EndIf
;     EndIf
  EndProcedure
  Callback::DECLARE_CALLBACK(OnDeleteObject, Args::#PTR, Args::#PTR)
  
  ; ----------------------------------------------------------------------------
  ;  Clear
  ; ----------------------------------------------------------------------------
  Procedure Clear(*Me.PropertyUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    ClearMap(*Me\props())
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
    Protected *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*Me, *object\name, *object\name, 0, 0)

    *prop\label = *object\name
    ControlProperty::AppendStart(*prop)
  
    Protected v.Math::v3f32
    Protected *attr.Attribute::Attribute_t
    Define i
    ForEach *object\geom\m_attributes()
      *attr = *object\geom\m_attributes()
      If Not *attr\readonly And *attr\constant
        Select *attr\datatype
          Case Attribute::#ATTR_TYPE_BOOL
            ControlProperty::AddBoolControl(*prop,*attr\name,*attr\name,#False,*attr)
          Case Attribute::#ATTR_TYPE_INTEGER
            ControlProperty::AddIntegerControl(*prop,*attr\name,*attr\name,0,*attr)
          Case Attribute::#ATTR_TYPE_FLOAT
            ControlProperty::AddFloatControl(*prop,*attr\name,*attr\name,0,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR2
            Protected v2.v2f32
            ControlProperty::AddVector2Control(*prop,*attr\name,*attr\name,v2,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR3
            Protected v3.v3f32
            ControlProperty::AddVector3Control(*prop,*attr\name,*attr\name,v3,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR4
            Protected c4.c4f32
            ControlProperty::AddColorControl(*prop,*attr\name,*attr\name,c4,*attr)
          Case Attribute::#ATTR_TYPE_QUATERNION
            Protected q.q4f32
            ControlProperty::AddQuaternionControl(*prop,*attr\name,*attr\name,q,*attr)
          Case Attribute::#ATTR_TYPE_MATRIX4
            Protected m.m4f32
            Matrix4::SetIdentity(m)
            ControlProperty::AddMatrix4Control(*prop,*attr\name,*attr\name,m,*attr) 
        EndSelect
      EndIf
    Next
    
    ControlProperty::AppendStop(*prop)
    Callback::CONNECT_CALLBACK(*object\on_delete, OnDeleteObject, *Me, *object)
    
    *Me\props(*object\name) = *prop
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Check Node Exists
  ; ----------------------------------------------------------------------------
  Procedure.b CheckNodeExists(*Me.PropertyUI_t, *node.Object::Object_t)
    Define index.i = 0
    
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
    Protected *p.ControlProperty::ControlProperty_t =  ControlProperty::New(*node, *node\name, *node\label, 0, 0, *Me\sizX, 120)
        
    ControlProperty::AppendStart(*p)

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
              ControlProperty::AddBoolControl(*p,\name,\name,CArray::GetValueB(*bVal,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_FLOAT
              Protected *fVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddFloatControl(*p,\name,\name,CArray::GetValueF(*fVal,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_INTEGER
              Protected *iVal.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddIntegerControl(*p,\name,\name,CArray::GetValueI(*iVal,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_VECTOR2
              Protected *vVal2.CArray::CArrayV2F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddVector2Control(*p,\name,\name,CArray::GetValue(*vVal2,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_VECTOR3
              Protected *vVal3.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddVector3Control(*p,\name,\name,CArray::GetValue(*vVal3,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_VECTOR4
              Protected *vVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*vVal4,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_QUATERNION
              Protected *qVal4.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddQuaternionControl(*p,\name,\name,CArray::GetValue(*qVal4,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_COLOR
              Protected *cVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*cVal4,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_MATRIX4
              Protected *mVal4.CArray::CArrayM4F32 = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddMatrix4Control(*p,\name,\name,CArray::GetValue(*mVal4,0),*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_REFERENCE
              Protected *ref.Globals::Reference_t = NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddReferenceControl(*p,\name,*ref\reference,*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_FILE
              ControlProperty::AddFileControl(*p,\name,\name,*node\inputs()\attribute)
              
            Case Attribute::#ATTR_TYPE_STRING
              Protected *sVal.CArray::CArrayStr =  NodePort::AcquireInputData(*node\inputs())
              ControlProperty::AddStringControl(*p,\name,CArray::GetValueStr(*sVal,0),*node\inputs()\attribute)
          EndSelect
        EndIf
        
      EndWith    
    Next
    
    ControlProperty::AppendStop(*p)
    Control::Invalidate(*p)
    
    *Me\props(*node\name) = *p
    ProcedureReturn *p

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Add Property
  ; ----------------------------------------------------------------------------
  Procedure AddProperty(*Me.PropertyUI_t,*prop.ControlProperty::ControlProperty_t)
   
    *Me\props(*prop\name) = *prop
    Debug *Me\props(*prop\name)
    
    If *prop\head
      Callback::CONNECT_CALLBACK(*prop\head\on_delete, OnDeleteProperty, *Me, *prop)
    EndIf
    Resize(*Me)
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Setup
  ; ----------------------------------------------------------------------------
  Procedure Setup(*Me.PropertyUI_t,*object.Object::Object_t)
    Protected cName.s = *object\class\name
    
    If Right(cName,4) = "Node"
      Protected *node.Node::Node_t = *object
      Protected *prop.ControlProperty::ControlProperty_t = SetupFromNode(*Me,*node)

    Else
      Protected *obj.Object3D::Object3D_t = *object
       SetupFromObject3D(*Me,*obj)
     EndIf
     Resize(*Me)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Collapse Property
  ; ----------------------------------------------------------------------------
  Procedure CollapseProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
;     Protected dirty.b  =#False
;     Protected offY = 0
;     ForEach *Me\props()
;       If *Me\props() = *prop
;         *Me\props()\expanded = #False
;         *Me\props()\sizX = *Me\sizX
;         offY = *Me\props()\sizY - ControlHead::#HEAD_BUTTON_SIZE
;         *Me\props()\sizY = ControlHead::#HEAD_BUTTON_SIZE
;         ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
;         dirty = #True
;       Else
;         If dirty
;           *Me\props()\posY - offY
;           ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
;         EndIf
;       EndIf
;     Next
;     
;     If dirty
;       *Me\anchorY - offY
;     EndIf
    
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Expand Property
  ; ----------------------------------------------------------------------------
  Procedure ExpandProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
;     Protected dirty.b  =#False
;     Protected offY.i = 0
;     ForEach *Me\props()
;       If *Me\props() = *prop
;         *Me\props()\expanded = #True
;         *Me\props()\sizX = *Me\sizX
;         *Me\props()\sizY = ControlProperty::GetHeight(*Me\props())
;         ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
;         offY = *Me\props()\sizY - ControlHead::#HEAD_BUTTON_SIZE
;         dirty = #True
;       Else
;         If dirty
;           *Me\props()\posY + offY
;           ResizeGadget(*Me\props()\gadgetID,#PB_Ignore,*Me\props()\posY,*Me\sizX, *Me\props()\sizY)
;         EndIf
;       EndIf
;     Next
;     ResetList(*Me\props())
;     
;     If dirty
;       OnEvent(*Me, #PB_Event_SizeWindow)
;       *Me\anchorY + offY
;     EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Delete Property
  ; ----------------------------------------------------------------------------
  Procedure DeleteProperty(*Me.PropertyUI_t, *prop.ControlProperty::ControlProperty_t)
;     Protected dirty.b  =#False
;     Protected offY.i = 0
;     Protected idx.i=0
;     Protected toRemove.i = -1
;     
;     ForEach *Me\props()
;       If *Me\props() = *prop
;         offY = *Me\props()\sizY
;         
;         toRemove = idx
;         dirty=#True
;       Else
;         If dirty
;          
;           ResizeGadget(*Me\props()\gadgetID, #PB_Ignore, *Me\props()\posY-offY, *Me\sizX, #PB_Ignore)
;            *Me\props()\posY - offY
;         EndIf
;       EndIf
;       idx+1
;     Next
;     
;     If toRemove > -1
;       SelectElement(*Me\props(), toRemove)
;       DeleteElement(*Me\props())
;       ControlProperty::Delete(*prop)
;     EndIf
;     
;     If ListSize(*Me\props())
;       *Me\anchorY - offY
;     Else
;       *Me\anchorY = 0
;     EndIf
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------
  Procedure DeletePropertyByIndex(*Me.PropertyUI_t, index.i)
;     SelectElement(*Me\props(), index)
;     Define offY = *Me\props()\sizY
;     ControlProperty::Delete(*Me\props())
;     DeleteElement(*Me\props())
;     While NextElement(*Me\props())
;       *Me\props()\posY - offY
;     Wend
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( PropertyUI )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 157
; FirstLine = 108
; Folding = -----
; EnableXP
; EnableUnicode