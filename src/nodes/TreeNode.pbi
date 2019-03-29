XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; TREENODE MODULE DECLARATION
; ==================================================================================================
DeclareModule TreeNode
  Structure TreeNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ITreeNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Tree",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.TreeNode_t)
  Declare Init(*node.TreeNode_t)
  Declare Terminate(*node.TreeNode_t)
  Declare RecurseNodes(*node.TreeNode_t,*current.Node::Node_t)
  Declare Evaluate(*node.TreeNode_t)
  Declare OnConnect(*node.TreeNode_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*node.TreeNode_t, *port.NodePort::NodePort_t)

  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("TreeNode","",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(TreeNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ==================================================================================================
; TREENODE MODULE IMPLEMENTATION
; ==================================================================================================
Module TreeNode 
  Procedure Init(*node.TreeNode_t)
    Node::AddInputPort(*node,"Port1",Attribute::#ATTR_TYPE_EXECUTE)
    Node::AddInputPort(*node,"New(Port1)...",Attribute::#ATTR_TYPE_NEW)
    *node\label = "Tree"
    *node\leaf = #False
    *node\isroot = #True
  EndProcedure

  Procedure RecurseNodes(*node.TreeNode_t,*current.Node::Node_t)
  ;   CHECK_PTR1_NULL(*current)
  ; 
  ;   ForEach *current\inputs()
  ;     If *current\inputs()\connected
  ;       *node\nodes\Append(*current\inputs()\source\node)
  ;       OTreeNode_RecurseNodes(*node,*current\inputs()\source\node)
  ;     EndIf
  ;   Next
  EndProcedure
  
  Procedure EvaluatePort(*node.TreeNode_t,*port.NodePort::NodePort_t)
    
    ;recurse to leaf node
    If Not *port\connected Or *port\connexion = #Null : ProcedureReturn : EndIf
    ClearList(*node\nodes())
    AddElement(*node\nodes())
    *node\nodes() = *port\source\node
  
    RecurseNodes(*node,*port\source\node)
    Protected *current.Node::Node_t
    Protected current.Node::INode

    Protected i = ListSize(*node\nodes())-1
    LastElement(*node\nodes())
    While i>=0
      *current = *node\nodes()
      current = *current
      current\Evaluate()
      PreviousElement(*node\nodes())
      i-1
    Wend
  
    
  EndProcedure
  
  Procedure Evaluate(*node.TreeNode_t)
     Debug "-------------- Begin Evaluate Tree ----------------------------------"
    ForEach *node\inputs()
      EvaluatePort(*node,*node\inputs())
    Next
    Debug "----------------- End Evaluate Tree -------------------------"
  EndProcedure
  
  Procedure Terminate(*node.TreeNode_t)
  
  EndProcedure
  
   Procedure OnConnect(*node.TreeNode_t, *port.NodePort::NodePort_t)
    If *port\name = "Input0" And *port\connectioncallback
      *port\connectioncallback(*port)
    EndIf
    
  EndProcedure
  
  Procedure OnDisconnect(*node.TreeNode_t, *port.NodePort::NodePort_t)
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete(*node.TreeNode_t)
    FreeMemory(*node)
  EndProcedure
 
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Tree",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.TreeNode_t = AllocateMemory(SizeOf(TreeNode_t))
    ; ---[ Init Node]----------------------------------------------
    Node::INI(TreeNode,*tree,type,x,y,w,h,c)
    
    *Me\name = "TreeNode"
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  Class::DEF(TreeNode)
  
  ; ============================================================================
  ;  EOF
  ; ============================================================================
EndModule


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 111
; FirstLine = 87
; Folding = ---
; EnableThread
; EnableXP
; EnableUnicode