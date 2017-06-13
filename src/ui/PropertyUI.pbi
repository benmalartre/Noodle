
XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "UI.pbi"

; -----------------------------------------
; PropertyUI Module Declaration
; -----------------------------------------
DeclareModule PropertyUI
  Structure PropertyUI_t Extends UI::UI_t
    *prop.ControlProperty::ControlProperty_t
  EndStructure
  
  Declare New(*parent.View::View_t,name.s,*obj.Object3D::Object3D_t)
  Declare Delete(*Me.PropertyUI_t)
  ;   Declare Draw(*Me.PropertyUI_t)
  Declare Init(*Me.PropertyUI_t)
  Declare Event(*Me.PropertyUI_t,event.i)
  Declare Term(*Me.PropertyUI_t)
  Declare Clear(*Me.PropertyUI_t)
  Declare SetupFrom3DObject(*Me.PropertyUI_t,*object.Object3D::Object3D_t)
  Declare SetupFromNode(*Me.PropertyUI_t,*node.Node::Node_t)
  Declare Setup(*Me.PropertyUI_t,*object.Object::Object_t)
  
  DataSection 
    PropertyUIVT: 
    Data.i @Init()
    Data.i @Event()
    Data.i @Term()

  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

; -----------------------------------------
; PropertyUI Module Implementation
; -----------------------------------------
Module PropertyUI
  UseModule Math
  
  ; Constructor
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s,*obj.Object3D::Object3D_t)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
   
    Protected *Me.PropertyUI_t = AllocateMemory(SizeOf(PropertyUI_t))
    
    Object::INI(PropertyUI)
    *Me\name = name
    *Me\x = x
    *Me\y = y
    *Me\width = w
    *Me\height = h
    
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h);ScrollAreaGadget(#PB_Any,x,y,w,h,w,h)
;     SetGadgetColor(*Me\container,#PB_Gadget_BackColor,RGB(Red(Globals::COLOR_MAIN_BG),Green(Globals::COLOR_MAIN_BG),Blue(Globals::COLOR_MAIN_BG)))
    *Me\prop = ControlProperty::New(*obj,name,name,0,0,w,h)

    CloseGadgetList()
    
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;-------------------------------
  Procedure Delete(*Me.PropertyUI_t)
    ControlProperty::Delete(*Me\prop)
    
    FreeMemory(*Me)
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.PropertyUI_t)
    
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure Event(*Me.PropertyUI_t,event.i)

    Protected ev_datas.Control::EventTypeDatas_t
    ev_datas\x = mx
    ev_datas\y = mY
    Select event
      Case #PB_Event_SizeWindow
        Protected *top.View::View_t = *Me\top
        ResizeGadget(*me\container,*top\x,*top\y,*top\width,*top\height)
        ev_datas\x = 0
        ev_datas\y = 0
        ev_datas\width = *top\width
        ev_datas\height = *top\height
        ControlProperty::Event(*Me\prop,Control::#PB_EventType_Resize,@ev_datas)
      Case #PB_Event_Gadget
        Debug " ooooooooo PropertyUI Event oooooooooooooo"
        ControlProperty::Event(*Me\prop,EventType(),@ev_datas)
      Case #PB_Event_Menu
        ControlProperty::Event(*Me\prop,EventMenu(),#Null)

        
        
    EndSelect
    
  EndProcedure
  
  Procedure Test(*prop.ControlProperty::ControlProperty_t,*mesh.Polymesh::Polymesh_t)
   
    ControlProperty::AppendStart(*prop)
    ControlProperty::AddBoolControl(*prop,"boolean","boolean",#False,*mesh)
    ControlProperty::AddFloatControl(*prop,"float","float",#False,*mesh)
    ControlProperty::AddIntegerControl(*prop,"integer","integer",#False,*mesh)
    ControlProperty::AddReferenceControl(*prop,"reference1","ref1",*mesh)
    ControlProperty::AddReferenceControl(*prop,"reference2","ref2",*mesh)
    ControlProperty::AddReferenceControl(*prop,"reference3","ref3",*mesh)
    *group = ControlProperty::AddGroup(*prop,"BUTTON")
    
    ControlGroup::Append(*group,ControlButton::New(*mesh,"button","button",#True,#PB_Button_Toggle))
    ControlProperty::EndGroup(*prop)
    
    
    
    Define q.Math::q4f32
    Quaternion::SetIdentity(@q)
    ControlProperty::AddQuaternionControl(*prop,"quaternion","quat",@q,*mesh)
    
    *group = ControlProperty::AddGroup(*prop,"ICONS")
    ControlGroup::RowStart(*group)
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Back",ControlIcon::#Icon_Back,0))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Stop",ControlIcon::#Icon_Stop,0))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Play",ControlIcon::#Icon_Play,#PB_Button_Toggle))
    ControlGroup::Append(*group,ControlIcon::New(*mesh,"Loop",ControlIcon::#Icon_Loop,0))
    ControlGroup::RowEnd(*group)
    ControlProperty::EndGroup(*prop)
    
    
    ; ControlProperty::Append(*prop,ControlTimeline::New(#Null,window,0,WindowHeight(window)-100,WindowWidth(window),100))
    
    ControlProperty::AppendStop(*prop)
  EndProcedure

  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.PropertyUI_t)
    
  EndProcedure

  ;  Clear
  ; ----------------------------------------
  Procedure Clear(*Me.PropertyUI_t)
    Protected i
    Protected *prop.ControlProperty::ControlProperty_t = *Me\prop
    For i=0 To *prop\chilcount-1
      Debug *prop\children(i)\name
    Next
    ControlProperty::Clear(*prop)
  
  EndProcedure
 
  ;  Setup From 3D Object
  ; need to port 3D Object to graph  Node for unified editing
  ; ----------------------------------------
  Procedure SetupFrom3DObject(*Me.PropertyUI_t,*object.Object3D::Object3D_t)
    If Not *object Or Not *Me: ProcedureReturn : EndIf
    Clear(*Me)
    Protected *p.ControlProperty::ControlProperty_t = *Me\prop  
    *p\label = *object\name
    ControlProperty::AppendStart(*p)
  
    Protected v.Math::v3f32
   Protected msg.s
    Protected *attr.Attribute::Attribute_t
    Define i
    ForEach *object\m_attributes()
      *attr = *object\m_attributes()
      msg+*attr\name+" : ReadOnly "+Str(*attr\readonly)+", Constant "+Str(*attr\constant)+Chr(10)
      If Not *attr\readonly And *attr\constant
        Select *attr\datatype
          Case Attribute::#ATTR_TYPE_BOOL
            msg.s + ">>> Add BOOl Control"+Chr(10)
            ControlProperty::AddBoolControl(*p,*attr\name,*attr\name,#False,*attr)
          Case Attribute::#ATTR_TYPE_INTEGER
            msg.s + ">>> Add INT Control"+Chr(10)
            ControlProperty::AddIntegerControl(*p,*attr\name,*attr\name,0,*attr)
          Case Attribute::#ATTR_TYPE_FLOAT
            msg.s + ">>> Add FLOAT Control"+Chr(10)
            ControlProperty::AddFloatControl(*p,*attr\name,*attr\name,0,*attr)
  ;         Case Attribute::#ATTR_TYPE_VECTOR2
  ;           Protected v2.v2f32
  ;           ControlProperty::AddVector2Control(*p,*attr\name,*attr\name,@v2,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR3
            msg.s + ">>> Add VECTOR3 Control"+Chr(10)
            Protected v3.v3f32
            ControlProperty::AddVector3Control(*p,*attr\name,*attr\name,@v3,*attr)
          Case Attribute::#ATTR_TYPE_VECTOR4
            msg.s + ">>> Add VECTOR4 Control"+Chr(10)
            Protected c4.c4f32
            ControlProperty::AddColorControl(*p,*attr\name,*attr\name,@c4,*attr)
          Case Attribute::#ATTR_TYPE_QUATERNION
            msg.s + ">>> Add QUATERNION Control"+Chr(10)
            Protected q.q4f32
            ControlProperty::AddQuaternionControl(*p,*attr\name,*attr\name,@q,*attr)
          Case Attribute::#ATTR_TYPE_MATRIX4
            
            msg.s + ">>> Add MATRIX4 Control"+Chr(10)
            Protected m.m4f32
            Matrix4::SetIdentity(@m)
            ControlProperty::AddMatrix4Control(*p,*attr\name,*attr\name,@m,*attr)
            
        EndSelect
      EndIf
      
    Next
    
    MessageRequester("PropertyUI"+*object\name,msg)
  
  ;   *Me\prop\EndGroup()
    
    ControlProperty::AppendStop(*p)
  
  EndProcedure
  
  ;  Setup From Node
  ; ----------------------------------------
  Procedure SetupFromNode(*Me.PropertyUI_t,*node.Node::Node_t)
    
    If Not *node Or Not *Me: ProcedureReturn : EndIf
    Clear(*Me);
  
    
    Protected *p.ControlProperty::ControlProperty_t = *Me\prop  
    *p\label = *node\type
    
    ControlProperty::AppendStart(*p)
    Protected v.v3f32
   
    Protected *attr.Attribute::Attribute_t
    Define i
    ; ---[ Add Input Ports ]----------------------------------------------------
    ForEach *node\inputs()
      With *node\inputs()
        
        If Not \connected
          Select \currenttype
            Case Attribute::#ATTR_TYPE_BOOL
              Protected *bVal.CArray::CArrayBool = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddBoolControl(*p,\name,\name,CArray::GetValueB(*bVal,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_FLOAT
              Protected *fVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddFloatControl(*p,\name,\name,CArray::GetValueF(*fVal,0),*node\inputs())
    
              
            Case Attribute::#ATTR_TYPE_INTEGER
              Protected *iVal.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddIntegerControl(*p,\name,\name,CArray::GetValueI(*iVal,0),*node\inputs())
              
  ;           Case Attribute::#ATTR_TYPE_VECTOR2
  ;             Protected vVal2.CArrayV2F32 = NodePort::AcquireInputData(*node\inputs());\value
  ;             ControlProperty::AddVector2Control(\name,\name,vVal2\GetValue(0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_VECTOR3
              Protected *vVal3.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddVector3Control(*p,\name,\name,CArray::GetValue(*vVal3,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_VECTOR4
              Protected *vVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*vVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_QUATERNION
              Protected *qVal4.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddQuaternionControl(*p,\name,\name,CArray::GetValue(*qVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_COLOR
              Protected *cVal4.CArray::CArrayC4F32 = NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddColorControl(*p,\name,\name,CArray::GetValue(*cVal4,0),*node\inputs())
              
            Case Attribute::#ATTR_TYPE_REFERENCE
              ControlProperty::AddReferenceControl(*p,\name,\reference,*node\inputs())
              
            Case Attribute::#ATTR_TYPE_STRING
              Protected *sVal.CArray::CArrayStr =  NodePort::AcquireInputData(*node\inputs());\value
              ControlProperty::AddStringControl(*p,\name,CArray::GetValueStr(*sVal,0),*node\inputs())
          EndSelect
        EndIf
        
      EndWith
      
          
    Next
    
    ControlProperty::AppendStop(*p)
  
  EndProcedure
  
  
  ;  Setup
  ; ----------------------------------------
  Procedure Setup(*Me.PropertyUI_t,*object.Object::Object_t)
    MessageRequester("PropertyUI" ,"Property UI SETUP"+*object\class\name)
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




EndModule
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 214
; FirstLine = 210
; Folding = ---
; EnableUnicode
; EnableXP