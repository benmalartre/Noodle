XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule FloatToQuaternionNode
  UseModule Math
  Structure FloatToQuaternionNode_t Extends Node::Node_t
    q.q4f32
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IFloatToQuaternionNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.FloatToQuaternionNode_t)
  Declare Init(*node.FloatToQuaternionNode_t)
  Declare Evaluate(*node.FloatToQuaternionNode_t)
  Declare Terminate(*node.FloatToQuaternionNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("FloatToQuaternionNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(FloatToQuaternionNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


Module FloatToQuaternionNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.FloatToQuaternionNode_t)
    Node::AddInputPort(*node,"X",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Y",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Z",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"W",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_QUATERNION)
    Quaternion::SetIdentity(*node\q)
    ;Update Label
    *node\label = "FloatToQuaternion"
    
  EndProcedure
  
  Procedure Evaluate(*node.FloatToQuaternionNode_t)
    
    Define.f x,y,z,w
    FirstElement(*node\inputs())
    Protected *xVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected x_con = *node\inputs()\connected
    Protected x_nb = CArray::GetCount(*xVal)
    NextElement(*node\inputs())
    Protected *yVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected y_con = *node\inputs()\connected
    Protected y_nb = CArray::GetCount(*yVal)
    NextElement(*node\inputs())
    Protected *zVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected z_con = *node\inputs()\connected
    Protected z_nb = CArray::GetCount(*zVal)
    NextElement(*node\inputs())
    Protected *wVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected w_con = *node\inputs()\connected
    Protected w_nb = CArray::GetCount(*wVal)
    
     Protected m_max= 0
    If x_con : m_max = x_nb 
    ElseIf y_con : m_max = y_nb
    ElseIf z_con : m_max = z_nb
    ElseIf w_con : m_max = w_nb
    Else : m_max = 1 
    EndIf
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *qOut.CArray::CArrayQ4F32 = *output\value
    CArray::SetCount(*qOut,m_max)
    
    Protected i
    For i=0 To m_max-1
      x = CArray::GetValueF(*xVal,Min(i,x_nb))
      y = CArray::GetValueF(*yVal,Min(i,y_nb))
      z = CArray::GetValueF(*zVal,Min(i,z_nb))
      w = CArray::GetValueF(*wVal,Min(i,w_nb))
      Quaternion::Set(*node\q,x,y,z,w)
      
      CArray::SetValue(*qOut,i,*node\q)
    Next
 
  EndProcedure
  
  Procedure Terminate(*node.FloatToQuaternionNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.FloatToQuaternionNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Quaternion",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.FloatToQuaternionNode_t = AllocateMemory(SizeOf(FloatToQuaternionNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(FloatToQuaternionNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(FloatToQuaternionNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================



; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 30
; FirstLine = 18
; Folding = --
; EnableXP