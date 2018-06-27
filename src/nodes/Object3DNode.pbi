XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule Object3DNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure Object3DNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IObject3DNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Object3D",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.Object3DNode_t)
  Declare Init(*node.Object3DNode_t)
  Declare Evaluate(*node.Object3DNode_t)
  Declare Terminate(*node.Object3DNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("Object3DNode","Hierarchy",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(Object3DNode)
  EndDataSection
  

EndDeclareModule

; ==================================================================================================
; ADD NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module Object3DNode
  Procedure Init(*node.Object3DNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_3DOBJECT
    Node::AddInputPort(*node,"Child1",datatype)
    Node::AddInputPort(*node,"New(Child1)...",Attribute::#ATTR_TYPE_NEW)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_3DOBJECT)
    
    ForEach *node\inputs()
      Node::PortAffectByName(*node, *node\inputs()\name, "Output")
    Next
    
    *node\label = "3DObject"
  EndProcedure
  
  Procedure Evaluate(*node.Object3DNode_t)
  
  EndProcedure
  
  Procedure Terminate(*node.Object3DNode_t)
  
  EndProcedure
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete(*node.Object3DNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Object3D",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
   
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.Object3DNode_t = AllocateMemory(SizeOf(Object3DNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(Object3DNode,*tree,type,x,y,w,h,c)
    Debug "3D Object Node : "+Str(*Me)
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 54
; FirstLine = 50
; Folding = --
; EnableXP