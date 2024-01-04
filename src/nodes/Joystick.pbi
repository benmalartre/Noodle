XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; JOYSTICK NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule JoystickNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure JoystickNode_t Extends Node::Node_t
    *joystick::Joystick::Joystick_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IJoystickNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Joystick",x.i=0,y.i=0,w.i=100,h.i=50,c.i=RGB(150,150,180))
  Declare Delete(*node.JoystickNode_t)
  Declare Init(*node.JoystickNode_t)
  Declare Evaluate(*node.JoystickNode_t)
  Declare Terminate(*node.JoystickNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("JoystickNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}

EndDeclareModule

; ============================================================================
; ADD NODE MODULE IMPLEMENTATION
; ============================================================================
Module JoystickNode
  UseModule Math
  Procedure Init(*node.JoystickNode_t)
    Node::AddOutputPort(*node,"Axis1Horizontal",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,datastructure.i=Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Axis1Vertical",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,datastructure.i=Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Axis2Horizontal",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,datastructure.i=Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Axis2Vertical",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,datastructure.i=Attribute::#ATTR_STRUCT_SINGLE)
    For i=0 To 15
      Node::AddOutputPort(*node,"Button"+Str(i+1),Attribute::#ATTR_TYPE_BOOL,Attribute::#ATTR_CTXT_SINGLETON,datastructure.i=Attribute::#ATTR_STRUCT_SINGLE)
    Next
    *node\label = "Joystick"
  EndProcedure
  
  Procedure Evaluate(*node.JoystickNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t

    
    If *output\value = #Null
      Debug "Cannot Init Port For Add Node"
      ProcedureReturn 
    EndIf
    
    Protected i.i
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Long
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *iIn.CArray::CArrayInt,*iOut.CArray::CArrayInt
        *iOut = *output\value
        *iIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*iOut,CArray::GetCount(*iIn))
        CArray::Copy(*iOut,*iIn)
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *iIn = NodePort::AcquireInputData(*input)
          If *iIn
            If CArray::GetCount(*iIn) = 1
              For i=0 To CArray::GetCount(*iOut)-1
                int = CArray::GetValueI(*iOut,i)+CArray::GetValueI(*iIn,0)
                CArray::SetValueI(*iOut,i,int)
              Next i
            Else
              For i=0 To CArray::GetCount(*iIn)-1
                int = CArray::GetValueI(*iOut,i)+CArray::GetValueI(*iIn,i)
                CArray::SetValueI(*iOut,i,int)
              Next i
            EndIf
            
          EndIf
          
        Wend
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
        *fOut = *output\value
        *fIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*fOut,CArray::GetCount(*fIn))
        CArray::Copy(*fOut,*fIn)
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *fIn = NodePort::AcquireInputData(*input)
          If *fIn
            If CArray::GetCount(*fIn) = 1
              For i=0 To CArray::GetCount(*fOut)-1
                float = CArray::GetValueF(*fOut,i)+CArray::GetValueF(*fIn,0)
                CArray::SetValueF(*fOut,i,float)
              Next i
            Else
              For i=0 To CArray::GetCount(*fIN)-1
                float = CArray::GetValueI(*fOut,i)+CArray::GetValueI(*fIn,i)
                CArray::SetValueF(*fOut,i,float)
              Next i
            EndIf
            
          EndIf
          
        Wend
        
        ;....................................................
        ;
        ; Vector 3
        ;....................................................
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected v.v3f32
        Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
        *vOut = *output\value
        *vIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*vOut,CArray::GetCount(*vIn))
        CArray::Copy(*vOut,*vIn)
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *vIn = NodePort::AcquireInputData(*input)
          If *vIn
            If CArray::GetCount(*vIn) = 1
              For i=0 To CArray::GetCount(*vOut)-1
                Vector3::Add(@v,CArray::GetValue(*vOut,i),CArray::GetValue(*vIn,0))
                CArray::SetValue(*vOut,i,v)
              Next i
            Else
              For i=0 To CArray::GetCount(*vIN)-1
                Vector3::Add(@v,CArray::GetValue(*vOut,i),CArray::GetValue(*vIn,0))
                CArray::SetValue(*vOut,i,v)
              Next i
            EndIf
            
          EndIf
          
        Wend
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + "DataType UNDEFIEND"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + "DataType POLYMORPH"
         Default
        Debug *output\name + ": DataType OTHER"
    EndSelect
  
  EndProcedure

  Procedure Terminate(*node.JoystickNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.JoystickNode_t)
    Node::DEL(JoystickNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Add",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.JoystickNode_t = AllocateStructure(JoystickNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::Node_INI(JoystickNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 181
; FirstLine = 165
; Folding = --
; EnableXP
; EnableUnicode