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
    Node::PortAffectByName(*node, "Topo1", "Topology")
    Node::PortAffectByName(*node, "Topo2", "Topology")
    *node\label = "Merge Topo"
  EndProcedure
  
  Procedure AcquireInputTopology(*port.NodePort::NodePort_t)
    Define *topologyArray.CArray::CArrayPtr = NodePort::AcquireInputData(*port)
    ProcedureReturn CArray::GetValuePtr(*topologyArray, 0)
  EndProcedure
  
  Procedure AcquireOutputTopology(*port.NodePort::NodePort_t)
    Define *topologyArray.CArray::CArrayPtr = NodePort::AcquireOutputData(*port)
    ProcedureReturn CArray::GetValuePtr(*topologyArray, 0)
  EndProcedure
  
  
  Procedure Evaluate(*node.MergeTopoNode_t)
    Protected *topo.Geometry::Topology_t = AcquireOutputTopology(*node\outputs())

    FirstElement(*node\inputs())
    Protected *iTopo1.Geometry::Topology_t = AcquireInputTopology(*node\inputs())
    NextElement(*node\inputs())
    Protected *iTopo2.Geometry::Topology_t = AcquireInputTopology(*node\inputs())
    Topology::Merge(*topo,*iTopo1,*iTopo2)
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
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 71
; FirstLine = 40
; Folding = --
; EnableXP