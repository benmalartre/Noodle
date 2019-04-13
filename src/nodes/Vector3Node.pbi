XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; VECTOR3 NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule Vector3Node
  Structure Vector3Node_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IVector3Node Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Vector3",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.Vector3Node_t)
  Declare Init(*node.Vector3Node_t)
  Declare Evaluate(*node.Vector3Node_t)
  Declare Terminate(*node.Vector3Node_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("Vector3Node","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(Vector3Node)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; VECTOR3 NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module Vector3Node
  
  UseModule Math
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.Vector3Node_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_VECTOR3)
    Protected *datas.CArray::CArrayV3F32 = *input\attribute\data
  
    Protected *value.v3f32 = CArray::GetValue(*datas,0)
    *node\label = "<"+StrF(*value\x,1)+","+StrF(*value\y,1)+","+StrF(*value\z,1)+">"
    
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_VECTOR3)
    
    Node::PortAffectByName(*node, "Value", "Result")
    
  EndProcedure
  
  Procedure Evaluate(*node.Vector3Node_t)
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *ipos.CArray::CArrayV3F32 = NodePort::AcquireInputData(*input)
    Protected *opos.CArray::CArrayV3F32 = *output\attribute\data
    CArray::Copy(*opos,*ipos)

    If CArray::GetCount(*ipos) = 1
      Protected *value.v3f32 = CArray::GetValue(*ipos,0)
      *node\label = "<"+StrF(*value\x,1)+","+StrF(*value\y,1)+","+StrF(*value\z,1)+">"
    Else
      *node\label = "[...]"
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.Vector3Node_t)
  
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete(*node.Vector3Node_t)
    FreeMemory(*node)
  EndProcedure
  
 
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  ; ---[ Heap & stack fuck that ]-----------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Vector3",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.Vector3Node_t = AllocateMemory(SizeOf(Vector3Node_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(Vector3Node,*tree,type,x,y,w,h,c)
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(Vector3Node)
  
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 66
; FirstLine = 55
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode