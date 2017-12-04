XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule RotateVectorNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure RotateVectorNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IRotateVectorNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="RotateVector",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.RotateVectorNode_t)
  Declare Init(*node.RotateVectorNode_t)
  Declare Evaluate(*node.RotateVectorNode_t)
  Declare Terminate(*node.RotateVectorNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("RotateVectorNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(RotateVectorNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; ADD NODE MODULE IMPLEMENTATION
; ============================================================================
Module RotateVectorNode
  UseModule Math
  Procedure Init(*node.RotateVectorNode_t)

    Node::AddInputPort(*node,"Input",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddInputPort(*node,"Rotation",Attribute::#ATTR_TYPE_QUATERNION)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_VECTOR3)
    
    Node::PortAffect(*node, "Input", "Output")
    Node::PortAffect(*node, "Rotation", "Output")
    
    *node\label = "RotateVector"
  EndProcedure
  
  Procedure Evaluate(*node.RotateVectorNode_t)

    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *vOut.CArray::CArrayV3F32 = *output\value
    
    FirstElement(*node\inputs())
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *vIn.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
    Protected ic.b = *input\connected
    Protected i_max = CArray::GetCount(*vIn)
    
    NextElement(*node\inputs())
    Protected *rotation.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs())
    Protected rc.b = *node\inputs()\connected
    Protected r_max = CArray::GetCount(*rotation)
    
    Protected m_max = 0
    If ic : m_max = i_max 
    ElseIf rc : m_max = r_max
    Else : m_max = 1
    EndIf
    
    CArray::SetCount(*vOut,m_max)
    
    Protected i
    Protected *v.v3f32
    Protected *q.q4f32
    For i =0 To m_max-1
      *v = CArray::GetValue(*vIn,Min(i,i_max-1))
      *q = CArray::GetValue(*rotation,Min(i,r_max-1))
      Vector3::MulByQuaternion(CArray::GetValue(*vOut,i),*v,*q)
    Next
    
  EndProcedure

  Procedure Terminate(*node.RotateVectorNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.RotateVectorNode_t)
    Node::DEL(RotateVectorNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="RotateVector",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.RotateVectorNode_t = AllocateMemory(SizeOf(RotateVectorNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(RotateVectorNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(RotateVectorNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 56
; FirstLine = 45
; Folding = --
; EnableXP