XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ==================================================================================================
; MATRIX TO SRT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MatrixToSRTNode
  Structure MatrixToSRTNode_t Extends Node::Node_t
  EndStructure
  
  ;-------------------------------------------------------------------------------------------------
  ;Interface
  ;-------------------------------------------------------------------------------------------------
  Interface IMatrixToSRTNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MatrixToSRTNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MatrixToSRTNode_t)
  Declare Init(*node.MatrixToSRTNode_t)
  Declare Evaluate(*node.MatrixToSRTNode_t)
  Declare Terminate(*node.MatrixToSRTNode_t)
  
  ; ==================================================================================================
  ;  ADMINISTRATION
  ; ==================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MatrixToSRTNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MatrixToSRTNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MATRIX TO SRT NODE MODULE DECLARATION
; ==================================================================================================
Module MatrixToSRTNode
  UseModule Math
  Procedure Init(*node.MatrixToSRTNode_t)
    Protected sdata.i = Attribute::#ATTR_TYPE_VECTOR3
    Protected rdata.i = Attribute::#ATTR_TYPE_QUATERNION
    Protected tdata.i = Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Matrix",Attribute::#ATTR_TYPE_MATRIX4)
    Node::AddOutputPort(*node,"Scale",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Rotate", Attribute::#ATTR_TYPE_QUATERNION)
    Node::AddOutputPort(*node,"Translate",Attribute::#ATTR_TYPE_VECTOR3)
    
    
    Node::PortAffectByName(*node, "Matrix", "Scale")
    Node::PortAffectByName(*node, "Matrix", "Rotate")
    Node::PortAffectByName(*node, "Matrix", "Translate")
    
    *node\label = "Matrix To SRT"
  EndProcedure
  
  Procedure Evaluate(*node.MatrixToSRTNode_t)

      Protected *input.NodePort::NodePort_t
      SelectElement(*node\outputs(),0)
      Protected *sclArray.CArray::CArrayV3F32 = NodePort::AcquireOutputData(*node\outputs())
      
      SelectElement(*node\outputs(),1)
      Protected *oriArray.CArray::CArrayQ4F32 = NodePort::AcquireOutputData(*node\outputs())
      
      SelectElement(*node\outputs(),2)
      Protected *posArray.CArray::CArrayV3F32 = NodePort::AcquireOutputData(*node\outputs())

      SelectElement(*node\inputs(),0)
      Protected *matrices.NodePort::NodePort_t = *node\inputs()
      Protected *matricesArray.CArray::CArrayM4F32 = NodePort::AcquireInputData(*matrices)
      Protected nb = CArray::GetCount(*matricesArray)
      CArray::SetCount(*sclArray,nb)
      CArray::SetCount(*oriArray,nb)
      CArray::SetCount(*posArray,nb)
      
      Protected i
      Protected *scl.v3f32,*ori.q4f32,*pos.v3f32
      
      For i=0 To nb - 1
        *scl = CArray::GetValue(*sclArray,i)
        *ori = CArray::GetValue(*oriArray,i)
        *pos = CArray::GetValue(*posArray,i)

        Transform::SetSRTFromMatrix(CArray::GetValue(*matricesArray,i),*scl,*ori,*pos)
      Next

  EndProcedure
  
  Procedure Terminate(*node.MatrixToSRTNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MatrixToSRTNode_t)
    FreeMemory(*node)
  EndProcedure
  
 
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]----------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="MatrixToSRTNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]-----------------------------------------------
    Protected *Me.MatrixToSRTNode_t = AllocateMemory(SizeOf(MatrixToSRTNode_t))
    
    ; ---[ Init Node]-----------------------------------------------------------
    Node::INI(MatrixToSRTNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MatrixToSRTNode)

EndModule
; ==============================================================================
;  EOF
; ==============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 74
; FirstLine = 56
; Folding = --
; EnableXP