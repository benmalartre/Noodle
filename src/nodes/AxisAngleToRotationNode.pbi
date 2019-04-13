XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AxisANgleToRotationNode
  UseModule Math
  Structure AxisANgleToRotationNode_t Extends Node::Node_t
    q.q4f32
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAxisANgleToRotationNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AxisAngleToRotation",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AxisANgleToRotationNode_t)
  Declare Init(*node.AxisANgleToRotationNode_t)
  Declare Evaluate(*node.AxisANgleToRotationNode_t)
  Declare Terminate(*node.AxisANgleToRotationNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AxisAngleToRotationNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AxisANgleToRotationNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


Module AxisANgleToRotationNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AxisANgleToRotationNode_t)
    Node::AddInputPort(*node,"Axis",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddInputPort(*node,"Angle",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Rotation",Attribute::#ATTR_TYPE_QUATERNION)
    
    Node::PortAffectByName(*node, "Axis", "Rotation")
    Node::PortAffectByName(*node, "Angle", "Rotation")
    Quaternion::SetIdentity(*node\q)
    ;Update Label
    *node\label = "AxisAngleToRotation"
    
  EndProcedure
  
  Procedure Evaluate(*node.AxisANgleToRotationNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *qOut.CArray::CArrayQ4F32 = NodePort::AcquireOutputData(*output)
    
    FirstElement(*node\inputs())
    Protected *axis.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
    Protected ac.b = *node\inputs()\connected
    Protected a_max = CArray::GetCount(*axis)
    
    NextElement(*node\inputs())
    Protected *angle.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected nc.b = *node\inputs()\connected
    Protected n_max = CArray::GetCount(*angle)
    
    Protected m_max = 0
    If ac : m_max = a_max 
    ElseIf nc : m_max = n_max
    Else : m_max = 1
    EndIf
    
    CArray::SetCount(*qOut,m_max)
    
    Protected i
    Protected *v.v3f32
    Protected *q.q4f32
    Protected *a.v3f32
    Protected angle.f
    For i =0 To m_max-1
      *q = CArray::GetValue(*qOut,i)
      *a = CArray::GetValue(*axis,Min(i,a_max-1))
      angle = CArray::GetValueF(*angle,Min(i,n_max-1))
      Quaternion::SetFromAxisAngle(*q,*a, angle)
    Next
 
  EndProcedure
  
  Procedure Terminate(*node.AxisANgleToRotationNode_t)
    
  EndProcedure
  
  Procedure Delete(*node.AxisANgleToRotationNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AxisAngleToRotation",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AxisANgleToRotationNode_t = AllocateMemory(SizeOf(AxisANgleToRotationNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AxisANgleToRotationNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(AxisANgleToRotationNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 63
; FirstLine = 59
; Folding = --
; EnableXP