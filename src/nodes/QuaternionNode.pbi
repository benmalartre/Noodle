XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule QuaternionNode
  UseModule Math
  Structure QuaternionNode_t Extends Node::Node_t
    q.q4f32
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IQuaternionNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.QuaternionNode_t)
  Declare Init(*node.QuaternionNode_t)
  Declare Evaluate(*node.QuaternionNode_t)
  Declare Terminate(*node.QuaternionNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("QuaternionNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(QuaternionNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


Module QuaternionNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.QuaternionNode_t)
    Node::AddInputPort(*node,"Input",Attribute::#ATTR_TYPE_QUATERNION)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_QUATERNION)
    
    Node::PortAffectByName(*node, "Input", "Output")
    Quaternion::SetIdentity(*node\q)
    ;Update Label
    *node\label = "Quaternion"
    
  EndProcedure
  
  Procedure Evaluate(*node.QuaternionNode_t)
    Define.f x,y,z,w
    FirstElement(*node\inputs())
    Protected *qIn.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs())
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
    Protected *qOut.CArray::CArrayQ4F32 = *output\attribute\data
    CArray::Copy(*qOut,*qIn)
  
    
  EndProcedure
  
  Procedure Terminate(*node.QuaternionNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.QuaternionNode_t)
    Node::DEL(QuaternionNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.QuaternionNode_t = AllocateStructure(QuaternionNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(QuaternionNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(QuaternionNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 76
; FirstLine = 58
; Folding = --
; EnableXP