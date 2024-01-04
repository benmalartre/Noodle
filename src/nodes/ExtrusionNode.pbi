XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Topology.pbi"

; ==================================================================================================
; EXTRUSION NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ExtrusionNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure ExtrusionNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IExtrusionNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ExtrusionNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ExtrusionNode_t)
  Declare Init(*node.ExtrusionNode_t)
  Declare Evaluate(*node.ExtrusionNode_t)
  Declare Terminate(*node.ExtrusionNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ExtrusionNode","Topology",@New())
  Nodes::AppendDescription(*desc)
  
  
  DataSection
    Node::DAT(ExtrusionNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ==================================================================================================
; EXTRUSION NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ExtrusionNode
  ; ---[ INIT ]-----------------------------------------------------------------
  Procedure Init(*node.ExtrusionNode_t)
    Node::AddInputPort(*node,"Points",Attribute::#ATTR_TYPE_MATRIX4)
    Node::AddInputPort(*node,"Section",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY)
    
    Node::PortAffectByName(*node, "Points", "Topology")
    Node::PortAffectByName(*node, "Section", "Topology")
    *node\label = "Extrusion Mesh"
  EndProcedure
  
  ; ---[ EVALUATE ]-----------------------------------------------------------------
  Procedure Evaluate(*node.ExtrusionNode_t)
    Define *topoArray.CArray::CArrayPtr = NodePort::AcquireOutputData(*node\outputs())
    Define *topo.Geometry::Topology_t = CArray::GetValuePtr(*topoArray, 0)
    
    FirstElement(*node\inputs())
    Define *points.CArray::CArrayM4F32 = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Define *section.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())

    Define closed = #False
    
   Topology::Extrusion(*topo,*points,*section,closed)
  EndProcedure
  
  ; ---[ TERMINATE ]-----------------------------------------------------------------
  Procedure Terminate(*node.ExtrusionNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ExtrusionNode_t)
    Node::DEL(ExtrusionNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ExtrusionNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ExtrusionNode_t = AllocateStructure(ExtrusionNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ExtrusionNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Class::DEF(ExtrusionNode)
  

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 81
; FirstLine = 65
; Folding = --
; EnableXP