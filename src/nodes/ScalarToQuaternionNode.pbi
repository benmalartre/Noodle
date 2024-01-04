XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ScalarToScalarToQuaternionNode
  UseModule Math
  Structure ScalarToQuaternionNode_t Extends Node::Node_t
    q.q4f32
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IScalarToQuaternionNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ScalarToQuaternionNode_t)
  Declare Init(*node.ScalarToQuaternionNode_t)
  Declare Evaluate(*node.ScalarToQuaternionNode_t)
  Declare Terminate(*node.ScalarToQuaternionNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ScalarToQuaternionNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ScalarToQuaternionNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


Module ScalarToQuaternionNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.ScalarToQuaternionNode_t)
    Node::AddInputPort(*node,"X",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Y",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Z",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"W",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_QUATERNION)
    
    Node::PortAffect(*node, "X", "Result")
    Node::PortAffect(*node, "Y", "Result")
    Node::PortAffect(*node, "Z", "Result")
    Node::PortAffect(*node, "W", "Result")
    
    Quaternion::SetIdentity(*node\q)
    ;Update Label
    *node\label = "(0,0,0,1)"
    
  EndProcedure
  
  Procedure Evaluate(*node.ScalarToQuaternionNode_t)
    Define.f x,y,z,w
    FirstElement(*node\inputs())
    Protected *xVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *yVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *zVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *wVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    x = CArray::GetValueF(*xVal,0)
    y = CArray::GetValueF(*yVal,0)
    z = CArray::GetValueF(*zVal,0)
    w = CArray::GetValueF(*wVal,0)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
    Quaternion::Set(*node\q,x,y,z,w)
    Protected *qOut.CArray::CArrayQ4F32 = *output\value
    CArray::SetValue(*qOut,0,*node\q)
    
  
    *node\label = "("+Str(x)+","+Str(y)+","+Str(z)+","+Str(w)+")"
  
    
  EndProcedure
  
  Procedure Terminate(*node.ScalarToQuaternionNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.ScalarToQuaternionNode_t)
    Node::DEL(ScalarToScalarToQuaternionNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ScalarToQuaternionNode_t = AllocateStructure(ScalarToQuaternionNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ScalarToQuaternionNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(ScalarToQuaternionNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 96
; FirstLine = 79
; Folding = --
; EnableXP