XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD INDEX ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule BuildIndexArrayNode
  Structure BuildIndexArrayNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IBuildIndexArrayNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="BuildIndexArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.BuildIndexArrayNode_t)
  Declare Init(*node.BuildIndexArrayNode_t)
  Declare Evaluate(*node.BuildIndexArrayNode_t)
  Declare Terminate(*node.BuildIndexArrayNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("BuildIndexArrayNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(BuildIndexArrayNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module BuildIndexArrayNode
  Procedure GetSize(*node.BuildIndexArrayNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.BuildIndexArrayNode_t)
    Node::AddInputPort(*node,"Count",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_INTEGER)
    
    ;Update Label
    *node\label = "Build Index Array"
  EndProcedure
  
  Procedure Evaluate(*node.BuildIndexArrayNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iIn.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected *iOut.CArray::CArrayInt = *node\outputs()\value
    
    Protected nbp.i = CArray::GetValueI(*iIn,0)
    CArray::SetCount(*iOut,nbp)
    Protected i
    For i=0 To nbp-1
      CArray::SetValueI(*iOut,i,i)  
    Next i
    
    
  EndProcedure
  
  Procedure Terminate(*node.BuildIndexArrayNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.BuildIndexArrayNode_t)
    Node::DEL(BuildIndexArrayNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="BuildIndexArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.BuildIndexArrayNode_t = AllocateMemory(SizeOf(BuildIndexArrayNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(BuildIndexArrayNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(BuildIndexArrayNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================



; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 86
; FirstLine = 33
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP