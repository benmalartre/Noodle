XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD INDEX ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ArraySizeNode
  Structure ArraySizeNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IArraySizeNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ArraySizeNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ArraySizeNode_t)
  Declare Init(*node.ArraySizeNode_t)
  Declare Evaluate(*node.ArraySizeNode_t)
  Declare Terminate(*node.ArraySizeNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ArraySizeNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ArraySizeNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ArraySizeNode
  Procedure GetSize(*node.ArraySizeNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.ArraySizeNode_t)
    Node::AddInputPort(*node,"Count",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_INTEGER)
    
    ;Update Label
    *node\label = "Build Index Array"
  EndProcedure
  
  Procedure Evaluate(*node.ArraySizeNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iIn.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected *iOut.CArray::CArrayInt = NodePort::AcquireOutputData(*node\outputs())
    
    Protected nbp.i = CArray::GetValueI(*iIn,0)
    CArray::SetCount(*iOut,nbp)
    Protected i
    For i=0 To nbp-1
      CArray::SetValueI(*iOut,i,i)  
    Next i
    
    
  EndProcedure
  
  Procedure Terminate(*node.ArraySizeNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ArraySizeNode_t)
    Node::DEL(ArraySizeNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ArraySizeNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ArraySizeNode_t = AllocateStructure(ArraySizeNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ArraySizeNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(ArraySizeNode)
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