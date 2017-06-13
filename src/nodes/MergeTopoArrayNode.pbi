XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MERGE TOPO ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MergeTopoArrayNode
  Structure MergeTopoArrayNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IMergeTopoArrayNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MergeTopoArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MergeTopoArrayNode_t)
  Declare Init(*node.MergeTopoArrayNode_t)
  Declare Evaluate(*node.MergeTopoArrayNode_t)
  Declare Terminate(*node.MergeTopoArrayNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MergeTopoArrayNode","Topology",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MergeTopoArrayNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MERGE TOPO ARRAY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module MergeTopoArrayNode

  Procedure Init(*node.MergeTopoArrayNode_t)
    Node::AddInputPort(*node,"Array",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_ARRAY)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    *node\label = "Merge Topo Array"
  EndProcedure
  
  Procedure Evaluate(*node.MergeTopoArrayNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *oVal.CArray::CArrayPtr = *output\value
    
    Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*oVal,0)
    
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iVal.CArray::CArrayPtr = NodePort::AcquireInputData(*input)
    
    If CArray::GetCount(*iVal)>1
      Debug ">>>>>>>>>>>>>>>>>>>>>>>> Merge Topo Array Node : Nb Topos ---> "+Str(CArray::GetCount(*iVal))
      Topology::MergeArray(*topo,*iVal)
    ElseIf CArray::GetCount(*iVal)=1
      Topology::Copy(*topo,CArray::GetValuePtr(*iVal,0))
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.MergeTopoArrayNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MergeTopoArrayNode_t)
    Node::DEL(MergeTopoArrayNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::tree_t,type.s="MergeTopoArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.MergeTopoArrayNode_t = AllocateMemory(SizeOf(MergeTopoArrayNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(MergeTopoArrayNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MergeTopoArrayNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 69
; FirstLine = 25
; Folding = --
; EnableXP