XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ==================================================================================================
; MATRIX ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MatrixArrayNode
  Structure MatrixArrayNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IMatrixArrayNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MatrixArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MatrixArrayNode_t)
  Declare Init(*node.MatrixArrayNode_t)
  Declare Evaluate(*node.MatrixArrayNode_t)
  Declare Terminate(*node.MatrixArrayNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MatrixArrayNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MatrixArrayNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; SRT TO MATRIX NODE MODULE DECLARATION
; ==================================================================================================
Module MatrixArrayNode
  UseModule Math
  Procedure Init(*node.MatrixArrayNode_t)

    Node::AddOutputPort(*node,"Matrix",Attribute::#ATTR_TYPE_MATRIX4)

    
    *node\label = "Matrix Array"
  EndProcedure
  
  Procedure Evaluate(*node.MatrixArrayNode_t)
    
      
     
      Protected nb = 12
      SelectElement(*node\outputs(),0)
      Protected *output.NodePort::NodePort_t = *node\outputs()
      Protected *m_out.CArray::CArrayM4F32 = *output\value
      CArray::SetCount(*m_out,nb)
      
      Protected i


      Protected scl.v3f32,ori.q4f32,pos.v3f32
      Vector3::Set(@scl,1,1,1)
      Quaternion::SetIdentity(@ori)
      
      For i=0 To nb - 1
        Vector3::Set(@pos,i,0,0)
        Transform::SetMatrixFromSRT(CArray::GetValue(*m_out,i),@scl,@ori,@pos)

      Next

    ; ;   Protected *of.CArrayF32 = NodePort::AcquireOutputData(*output)
    ; ;   Protected m_max = *of\GetCount();\Max(m_x\GetCount(),Max(m_y\GetCount(),m_z\GetCount()))
    ;   
    ;   Protected m_max = x_nb
    ;   If y_nb>m_max : m_max = y_nb :EndIf
    ;   If z_nb>m_max : m_max = z_nb :EndIf
    ;   
    ;   Protected m_out.CArrayV3F32 = NodePort::AcquireOutputData(*output)
    ;   m_out\SetCount(m_max)
    ;   
    ;   Debug ">>>>>>>>>>>>>>>>>>> SRTToMatrixNode : Out Data Size : "+Str(m_out\GetCount())
    ;   
    ;   Protected i=0
    ;   Protected v.v3f32
    ;   For i=0 To m_max-1
    ;     Vector3_Set(@v,m_x\GetValue(Min(i,x_nb)),m_y\GetValue(Min(i,y_nb)),m_z\GetValue(Min(i,z_nb)))
    ;     m_out\SetValue(i,@v)
    ;     Vector3_Log(@v,"-----> ")
    ;   Next i
     
  EndProcedure
  
  Procedure Terminate(*node.MatrixArrayNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MatrixArrayNode_t)
    FreeMemory(*node)
  EndProcedure
  
 
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="MatrixArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.MatrixArrayNode_t = AllocateMemory(SizeOf(MatrixArrayNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(MatrixArrayNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MatrixArrayNode)

EndModule
; ============================================================================
;  EOF
; ============================================================================



; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 76
; FirstLine = 36
; Folding = --
; EnableXP