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
    
    Node::AddInputPort(*node,"Count", Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Mode", Attribute::#ATTR_TYPE_ENUM)
    Node::AddOutputPort(*node,"Matrix",Attribute::#ATTR_TYPE_MATRIX4)

    Node::PortAffectByName(*node, "Count", "Matrix")
    Node::PortAffectByName(*node, "Mode", "Matrix")
    *node\label = "Matrix Array"
  EndProcedure
  
  Procedure Evaluate(*node.MatrixArrayNode_t)
    
    FirstElement(*node\inputs())
    Define *count.CArray::CarrayInt = NodePort::AcquireInputData(*node\inputs())
    Define numMatrices = Carray::GetValueI(*count, 0)
    

    SelectElement(*node\outputs(),0)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *matricesArray.CArray::CArrayM4F32 = NodePort::AcquireOutputData(*output)
    If numMatrices
      CArray::SetCount(*matricesArray,numMatrices)
      
      Protected i
      Protected scl.v3f32,ori.q4f32,pos.v3f32
      Vector3::Set(scl,1,1,1)
      Quaternion::SetIdentity(ori)
      For i=0 To numMatrices - 1
        Vector3::Set(pos,0,i,0)
        Transform::SetMatrixFromSRT(CArray::GetValue(*matricesArray,i),scl,ori,pos)
      Next
    Else
      CArray::SetCount(*matricesArray, 0)
    EndIf
    
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



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 81
; FirstLine = 33
; Folding = --
; EnableXP