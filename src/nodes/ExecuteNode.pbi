XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; EXECUTE NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ExecuteNode
  Structure ExecuteNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IExecuteNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Execute",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ExecuteNode_t)
  Declare Init(*node.ExecuteNode_t)
  Declare Evaluate(*node.ExecuteNode_t)
  Declare Terminate(*node.ExecuteNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ExecuteNode","Data",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ExecuteNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; EXECUTE NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ExecuteNode
  
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.ExecuteNode_t)
    Node::AddInputPort(*node,"Execute1",Attribute::#ATTR_TYPE_EXECUTE)
    Node::AddInputPort(*node,"New",Attribute::#ATTR_TYPE_NEW)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_EXECUTE)
    
    ;Update Label
    *node\label = "Execute"
    
  EndProcedure
  
  Procedure Evaluate(*node.ExecuteNode_t)
    ;Do Nothing
    
  EndProcedure
  
  Procedure Terminate(*node.ExecuteNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.ExecuteNode_t)
    Node::DEL(ExecuteNode)
  EndProcedure
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Execute",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ExecuteNode_t = AllocateStructure(ExecuteNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ExecuteNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(ExecuteNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 79
; FirstLine = 53
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode