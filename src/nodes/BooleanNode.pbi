XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; BOOLEAN NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule BooleanNode
  Structure BooleanNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IBooleanNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Boolean",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.BooleanNode_t)
  Declare Init(*node.BooleanNode_t)
  Declare Evaluate(*node.BooleanNode_t)
  Declare Terminate(*node.BooleanNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("BooleanNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(BooleanNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BOOLEAN NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module BooleanNode
  
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.BooleanNode_t)
    Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_BOOL)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_BOOL)
    
    Node::PortAffectByName(*node, "Value", "Result")
    
    ;Update Label
    *node\label = "False"
    
  EndProcedure
  
  Procedure Evaluate(*node.BooleanNode_t)
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
  ;   Protected bIn.CArrayBoo = OGraphNodePort_AcquireInputData(*input)
  ;   Protected bOut.CArrayBoo = OGraphNodePort_AcquireOutputData(*output)
    Protected *bIn.CArray::CArrayBool = *input\value
    Protected *bOut.CArray::CArrayBool = *output\value
    CArray::SetCount(*bOut,CArray::GetCount(*bIn))
    CArray::Copy(*bOut,*bIn)
  
    
  ;   Select bOut\GetValue(0)
  ;     Case #True
  ;       *node\label = "True"
  ;     Case #False
  ;       *node\label = "False"
  ;   EndSelect
    
  EndProcedure
  
  Procedure Terminate(*node.BooleanNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.BooleanNode_t)
    Node::DEL(BooleanNode)
  EndProcedure
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Boolean",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.BooleanNode_t = AllocateMemory(SizeOf(BooleanNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(BooleanNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

  
  Class::DEF(BooleanNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 52
; FirstLine = 49
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode