XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
;   ARRAY MINIMUM NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ArrayMinimumNode
  Structure ArrayMinimumNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IArrayMinimumNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ArrayMinimumNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ArrayMinimumNode_t)
  Declare Init(*node.ArrayMinimumNode_t)
  Declare Evaluate(*node.ArrayMinimumNode_t)
  Declare Terminate(*node.ArrayMinimumNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ArrayMinimumNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ArrayMinimumNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ArrayMinimumNode
  Procedure GetSize(*node.ArrayMinimumNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.ArrayMinimumNode_t)
    Node::AddInputPort(*node,"Count",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_INTEGER)
    
    ;Update Label
    *node\label = "Build Index Array"
  EndProcedure
  
  Procedure Evaluate(*node.ArrayMinimumNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iIn.CArray::CArrayInt = NodePort::AcquireInputData(*input)
    Protected *iOut.CArray::CArrayInt = NodePort::AcquireOutputData(*output)
    
    Protected nbp.i = CArray::GetValueI(*iIn,0)
    CArray::SetCount(*iOut,nbp)
    Protected i
    For i=0 To nbp-1
      CArray::SetValueI(*iOut,i,i)  
    Next i
    
    
  EndProcedure
  
  Procedure Terminate(*node.ArrayMinimumNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ArrayMinimumNode_t)
    Node::DEL(ArrayMinimumNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ArrayMinimumNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ArrayMinimumNode_t = AllocateStructure(ArrayMinimumNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ArrayMinimumNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(ArrayMinimumNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 99
; FirstLine = 72
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode