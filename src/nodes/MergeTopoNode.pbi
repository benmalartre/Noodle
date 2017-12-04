XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MERGE TOPO NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MergeTopoNode
  Structure MergeTopoNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IMergeTopoNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MergeTopoNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MergeTopoNode_t)
  Declare Init(*node.MergeTopoNode_t)
  Declare Evaluate(*node.MergeTopoNode_t)
  Declare Terminate(*node.MergeTopoNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MergeTopoNode","Topology",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MergeTopoNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MERGE TOPO NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module MergeTopoNode

  Procedure Init(*node.MergeTopoNode_t)
    Node::AddInputPort(*node,"Topo1",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Topo2",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::PortAffect(*node, "Topo1", "Topology")
    Node::PortAffect(*node, "Topo2", "Topology")
    *node\label = "Merge Topo"
  EndProcedure
  
  Procedure Evaluate(*node.MergeTopoNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *oVal.CArray::CArrayPtr = *output\value
    Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*oVal,0)
    
    FirstElement(*node\inputs())
    Protected *input1.NodePort::NodePort_t = *node\inputs()
    Protected *iVal1.CArray::CArrayPtr = NodePort::AcquireInputData(*input1)
    NextElement(*node\inputs())
    Protected *input2.NodePort::NodePort_t = *node\inputs()
    Protected *iVal2.CArray::CArrayPtr = NodePort::AcquireInputData(*input2)
    
    Topology::Merge(*topo,CArray::GetValuePtr(*iVal1,0),CArray::GetValuePtr(*iVal2,0))
  EndProcedure
  
  Procedure Terminate(*node.MergeTopoNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MergeTopoNode_t)
    Node::DEL(MergeTopoNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::tree_t,type.s="MergeTopoNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.MergeTopoNode_t = AllocateMemory(SizeOf(MergeTopoNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(MergeTopoNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MergeTopoNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 55
; FirstLine = 31
; Folding = --
; EnableXP