XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; BOOLEAN NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule StringNode
  Structure StringNode_t Extends Node::Node_t
    str.s
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IStringNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="String",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.StringNode_t)
  Declare Init(*node.StringNode_t)
  Declare Evaluate(*node.StringNode_t)
  Declare Terminate(*node.StringNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("StringNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(StringNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BOOLEAN NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module StringNode
  ;------------------------------
  ; Init
  ;------------------------------
  Procedure Init(*node.StringNode_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::PortAffectByName(*node, "Value", "Result")
  EndProcedure
  
  ;------------------------------
  ; Evaluate
  ;------------------------------
  Procedure Evaluate(*node.StringNode_t)
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *value.CArray::CArrayStr = NodePort::AcquireInputData(*input)
    
    If *value
      Protected *outdata.CArray::CArrayStr = *output\attribute\data
      Protected i
      CArray::SetCount(*outData,CArray::GetCount(*value))
  
    
      For i=0 To CArray::GetCount(*value)-1
        CArray::SetValueStr(*outdata,i,CArray::GetValueStr(*value,i))
      Next i
    
      *node\label = CArray::GetValueStr(*outdata,0)
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.StringNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.StringNode_t)
    Node::DEL(StringNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="String",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.StringNode_t = AllocateStructure(StringNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(StringNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  
  Class::DEF(StringNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 82
; FirstLine = 66
; Folding = --
; EnableXP