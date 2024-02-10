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

  Structure PropertyUI_t Extends UI::UI_t
    List *props.ControlProperty::ControlProperty_t()
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
 
  Procedure Draw(*Me.PropertyUI_t)
    
  EndProcedure

  Procedure DrawPickImage(*Me.PropertyUI_t)
    
  EndProcedure
  
  Procedure Pick(*Me.PropertyUI_t)
    
  EndProcedure
  
  Procedure Resize(*Me.PropertyUI_t)
    Protected *view.View::View_t = *Me\view
    *Me\posX = *view\posX
    *Me\posY = *view\posY
    *Me\sizX = *view\sizX
    *Me\sizY = *view\sizY
    *Me\active = #Null
    
    ResizeGadget(*Me\gadgetID, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    AddPathBox(0,0,*Me\sizX, *Me\sizY)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    StopVectorDrawing()
    Protected ev_datas.Control::EventTypeDatas_t
    ev_datas\x = 0
    ev_datas\y = 0
    ev_datas\width = *Me\sizX 
    ev_datas\height = *Me\sizY
    
    ForEach *Me\props()
      ControlGroup::OnEvent(*Me\props(), #PB_EventType_Resize,ev_datas)
      ev_datas\y + *Me\props()\sizY
    Next
    
  EndProcedure
  
  Procedure AppendStart(*Me.PropertyUI_t)
  EndProcedure
  
  Procedure AppendStop(*Me.PropertyUI_t)
    Resize(*Me)
  EndProcedure
  
  Procedure _GetActiveProperty(*Me.PropertyUI_t)
    Protected mx.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX)
    Protected my.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseY)
    
    ForEach *Me\props()
      If my > *Me\props()\posY And my < (*Me\props()\posY + *Me\props()\sizY)
        ProcedureReturn *Me\props()
      EndIf
    Next
    FirstElement(*Me\props())
    ProcedureReturn *Me\props()
    
  EndProcedure
  
  
  Procedure OnEvent(*Me.PropertyUI_t,event.i)    
    If Not ListSize(*Me\props()) : ProcedureReturn : EndIf
    Protected *top.View::View_t = *Me\view
    
    *Me\active = _GetActiveProperty(*Me)

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
          ev_datas\y = *Me\active\posY
          ControlGroup::OnEvent(*Me\active, EventType(), ev_datas)
        EndIf

      Case #PB_Event_Menu
        If *Me\active
          ev_datas\y = *Me\active\posY
          ControlGroup::OnEvent(*Me\active, EventMenu(), ev_datas)
        EndIf 
        
    EndSelect
  EndProcedure
  
  Procedure Clear(*Me.PropertyUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    ClearList(*Me\props())
  EndProcedure
  
  Procedure.b CheckObject3DExists(*Me.PropertyUI_t, *obj.Object3D::Object3D_t)
    ProcedureReturn #False
  EndProcedure
  
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
    
    AddElement(*Me\props())
    *Me\props() = *prop
    
  EndProcedure
  
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
    
    AddElement(*Me\props())
    *Me\props() = *p
    ProcedureReturn *p

  EndProcedure
  
  Procedure AddProperty(*Me.PropertyUI_t,*prop.ControlProperty::ControlProperty_t)
   AddElement(*Me\props())
   *Me\props() = *prop
   
    Resize(*Me)
  EndProcedure

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
  
  Procedure DeletePropertyByIndex(*Me.PropertyUI_t, index.i)
;     SelectElement(*Me\props(), index)
;     Define offY = *Me\props()\sizY
;     ControlProperty::Delete(*Me\props())
;     DeleteElement(*Me\props())
;     While NextElement(*Me\props())
;       *Me\props()\posY - offY
;     Wend
  EndProcedure
  
  Procedure Delete(*Me.PropertyUI_t)
    ForEach *Me\props()
      ControlProperty::Delete(*Me\props())
    Next
    
    Object::TERM(PropertyUI)
  EndProcedure
  
  Procedure New(*parent.View::View_t, name.s)
    Protected *Me.PropertyUI_t = AllocateStructure(PropertyUI_t)
    Object::INI(PropertyUI)
    *Me\name = name
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    
    *Me\active = #Null
    *Me\gadgetID = CanvasGadget(#PB_Any, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY, #PB_Canvas_Keyboard)
   
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( PropertyUI )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 77
; FirstLine = 48
; Folding = ----
; EnableXP
; EnableUnicode