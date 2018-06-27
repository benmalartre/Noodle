XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; ARRAY SUB INDICES NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ArraySubIndicesNode
  Structure ArraySubIndicesNode_t Extends Node::Node_t

  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IArraySubIndicesNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ArraySubIndicesNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ArraySubIndicesNode_t)
  Declare Init(*node.ArraySubIndicesNode_t)
  Declare Evaluate(*node.ArraySubIndicesNode_t)
  Declare Terminate(*node.ArraySubIndicesNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ArraySubIndicesNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ArraySubIndicesNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; ARRAY SUB INDICES NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ArraySubIndicesNode
  Procedure GetSize(*node.ArraySubIndicesNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.ArraySubIndicesNode_t)
    Node::AddInputPort(*node,"Count",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_INTEGER)
    
    Node::PortAffectByName(*node, "Count", "Result")
    
    ;Update Label
    *node\label = "Build Index Array"
  EndProcedure
  
  Procedure Evaluate(*node.ArraySubIndicesNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iIn.CArray::CArrayT = NodePort::AcquireInputData(*node\inputs())
    Protected *iOut.CArray::CArrayInt = *node\outputs()\value
    
    Protected nbp.i = CArray::GetCount(*iIn)
    CArray::SetCount(*iOut,nbp)
    Protected i
    For i=0 To nbp-1
      CArray::SetValueI(*iOut,i,i)  
      Debug "Sub Index --------------------------------------------------> "+Str(i)
    Next i
    
    
  EndProcedure
  
  Procedure Terminate(*node.ArraySubIndicesNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ArraySubIndicesNode_t)
    Node::DEL(ArraySubIndicesNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ArraySubIndicesNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ArraySubIndicesNode_t = AllocateMemory(SizeOf(ArraySubIndicesNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ArraySubIndicesNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(ArraySubIndicesNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 62
; FirstLine = 58
; Folding = --
; EnableXP