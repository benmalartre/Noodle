XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ==================================================================================================
; SRT TO MATRIX NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SRTToMatrixNode
  Structure SRTToMatrixNode_t Extends Node::Node_t
  EndStructure
  
  ;-------------------------------------------------------------------------------------------------
  ;Interface
  ;-------------------------------------------------------------------------------------------------
  Interface ISRTToMatrixNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="SRTToMatrixNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SRTToMatrixNode_t)
  Declare Init(*node.SRTToMatrixNode_t)
  Declare Evaluate(*node.SRTToMatrixNode_t)
  Declare Terminate(*node.SRTToMatrixNode_t)
  
  ; ==================================================================================================
  ;  ADMINISTRATION
  ; ==================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SRTToMatrixNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SRTToMatrixNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; SRT TO MATRIX NODE MODULE DECLARATION
; ==================================================================================================
Module SRTToMatrixNode
  UseModule Math
  Procedure Init(*node.SRTToMatrixNode_t)
    Protected sdata.i = Attribute::#ATTR_TYPE_VECTOR3
    Protected rdata.i = Attribute::#ATTR_TYPE_QUATERNION
    Protected tdata.i = Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"S",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddInputPort(*node,"R", Attribute::#ATTR_TYPE_QUATERNION)
    Node::AddInputPort(*node,"T",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Matrix",Attribute::#ATTR_TYPE_MATRIX4)
    
    Node::PortAffectByName(*node, "S", "Matrix")
    Node::PortAffectByName(*node, "R", "Matrix")
    Node::PortAffectByName(*node, "T", "Matrix")
    
    FirstElement(*node\inputs())
    Protected scl.v3f32
    Vector3::Set(scl,1,1,1)
    CArray::SetValue(*node\inputs()\value,0,@scl)
    NextElement(*node\inputs())
    Protected quat.q4f32
    Quaternion::SetIdentity(@quat)
    CArray::SetValue(*node\inputs()\value,0,@quat)
    
    *node\label = "SRT To Matrix"
  EndProcedure
  
  Procedure Evaluate(*node.SRTToMatrixNode_t)

      Protected *input.NodePort::NodePort_t
      SelectElement(*node\inputs(),0)
      Protected *m_scl.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
      Protected scl_nb = CArray::GetCount(*m_scl)
      Protected scl_const.b = Bool(scl_nb=1);*node\inputs()\constant
      SelectElement(*node\inputs(),1)

      Protected *m_ori.CArray::CArrayQ4F32 = NodePort::AcquireInputData(*node\inputs())
      Protected ori_nb = CArray::GetCount(*m_ori)
      Protected ori_const.b = Bool(ori_nb=1);*node\inputs()\constant
      SelectElement(*node\inputs(),2)
      Protected *m_pos.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
      Protected pos_nb = CArray::GetCount(*m_pos)
      Protected pos_const.b = Bool(pos_nb=1);*node\inputs()\constant
      Protected nb = pos_nb;
      If scl_nb>nb:nb=scl_nb:EndIf
      If ori_nb>nb:nb=ori_nb:EndIf
      
      SelectElement(*node\outputs(),0)
      Protected *output.NodePort::NodePort_t = *node\outputs()
      Protected *m_out.CArray::CArrayM4F32 = *output\value
      CArray::SetCount(*m_out,nb)
      
      Protected i
      Protected *scl.v3f32,*ori.q4f32,*pos.v3f32
      
      For i=0 To nb - 1
        If scl_const
          *scl = CArray::GetValue(*m_scl,0)
        Else
          *scl = CArray::GetValue(*m_scl,Min(i,scl_nb))
        EndIf
        If ori_const
          *ori = CArray::GetValue(*m_ori,0)
        Else
          *ori = CArray::GetValue(*m_ori,Min(i,ori_nb))
        EndIf
        If pos_const
          *pos = CArray::GetValue(*m_pos,0)
        Else
          *pos = CArray::GetValue(*m_pos,Min(i,pos_nb))
        EndIf
        Transform::SetMatrixFromSRT(CArray::GetValue(*m_out,i),*scl,*ori,*pos)
      Next

  EndProcedure
  
  Procedure Terminate(*node.SRTToMatrixNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SRTToMatrixNode_t)
    FreeMemory(*node)
  EndProcedure
  
 
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]----------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SRTToMatrixNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]-----------------------------------------------
    Protected *Me.SRTToMatrixNode_t = AllocateMemory(SizeOf(SRTToMatrixNode_t))
    
    ; ---[ Init Node]-----------------------------------------------------------
    Node::INI(SRTToMatrixNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(SRTToMatrixNode)

EndModule
; ==============================================================================
;  EOF
; ==============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 61
; FirstLine = 57
; Folding = --
; EnableXP