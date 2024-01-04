XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule IntegerNode
  Structure IntegerNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IIntegerNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Integer",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.IntegerNode_t)
  Declare Init(*node.IntegerNode_t)
  Declare Evaluate(*node.IntegerNode_t)
  Declare Terminate(*node.IntegerNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("IntegerNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(IntegerNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module IntegerNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.IntegerNode_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_INTEGER)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_INTEGER)
    Node::PortAffectByName(*node, "Value", "Result")
    *node\label = "0"
  EndProcedure
  
  Procedure Evaluate(*node.IntegerNode_t)
    
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *value.CArray::CArrayInt = NodePort::AcquireInputData(*input)
    
    If *value
      Protected *outdata.CArray::CArrayInt = *output\attribute\data
      Protected i
    
      CArray::SetCount(*outdata,CArray::GetCount(*value))
    
      For i=0 To CArray::GetCount(*value)-1
        CArray::SetValue(*outdata,i,CArray::GetValue(*value,i))
      Next i
    
      *node\label = Str(CArray::GetValueI(*outdata,0))
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.IntegerNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.IntegerNode_t)
    Node::DEL(IntegerNode)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Integer",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.IntegerNode_t = AllocateStructure(IntegerNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(IntegerNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(IntegerNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 90
; FirstLine = 62
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode