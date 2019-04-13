XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; INTEGER TO FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule IntegerToFloatNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure IntegerToFloatNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IIntegerToFloatNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="IntegerToFloatNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.IntegerToFloatNode_t)
  Declare Init(*node.IntegerToFloatNode_t)
  Declare Evaluate(*node.IntegerToFloatNode_t)
  Declare Terminate(*node.IntegerToFloatNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("IntegerToFloatNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(IntegerToFloatNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; INTEGER TO FLOAT NODE MODULE IMPLEMENTATION
; ============================================================================
Module IntegerToFloatNode
  Procedure Init(*node.IntegerToFloatNode_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_INTEGER)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_FLOAT)
    Node::PortAffectByName(*node, "Value", "Result")
    *node\label = "Integer To Float"
  EndProcedure
  
  Procedure Evaluate(*node.IntegerToFloatNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\Inputs()
    Protected *iIn.CArray::CArrayInt = NodePort::AcquireInputData(*input)
    Protected *fOut.CArray::CArrayFloat = NodePort::AcquireOutputData(*output)
    CArray::SetCount(*fOut,CArray::GetCount(*iIn))
    Protected i
    For i=0 To CArray::GetCount(*iIn)-1
      CArray::SetValueF(*fOut,i,CArray::GetValueI(*iIn,i))
    Next i
    
  EndProcedure
  
  Procedure Terminate(*node.IntegerToFloatNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.IntegerToFloatNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="IntegerToFloatNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.IntegerToFloatNode_t = AllocateMemory(SizeOf(IntegerToFloatNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(IntegerToFloatNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(IntegerToFloatNode)
  
  
  ; ============================================================================
  ;  EOF
  ; ============================================================================

EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 59
; FirstLine = 43
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode