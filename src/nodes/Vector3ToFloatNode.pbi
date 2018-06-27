XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ==================================================================================================
; VECTOR3 TO FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule Vector3ToFloatNode
  Structure Vector3ToFloatNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IVector3ToFloatNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Vector3ToFloatNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.Vector3ToFloatNode_t)
  Declare Init(*node.Vector3ToFloatNode_t)
  Declare Evaluate(*node.Vector3ToFloatNode_t)
  Declare Terminate(*node.Vector3ToFloatNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("Vector3ToFloatNode","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(Vector3ToFloatNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; VECTOR3 TO FLOAT NODE MODULE DECLARATION
; ==================================================================================================
Module Vector3ToFloatNode
  UseModule Math
  Procedure Init(*node.Vector3ToFloatNode_t)
    Protected idata.i = Attribute::#ATTR_TYPE_VECTOR3
    Protected odata.i = Attribute::#ATTR_TYPE_FLOAT
    Node::AddInputPort(*node,"Pos",idata)
    Node::AddOutputPort(*node,"X",odata)
    Node::AddOutputPort(*node,"Y",odata)
    Node::AddOutputPort(*node,"Z",odata)
    
    Node::PortAffectByName(*node, "Pos", "X")
    Node::PortAffectByName(*node, "Pos", "Y")
    Node::PortAffectByName(*node, "Pos", "Z")
    
    *node\label = "Vector3ToFloat"
  EndProcedure
  
  Procedure Evaluate(*node.Vector3ToFloatNode_t)
    Protected *outputX.NodePort::NodePort_t = Node::GetPortByName(*node,"X")
    Protected *outputY.NodePort::NodePort_t = Node::GetPortByName(*node,"Y")
    Protected *outputZ.NodePort::NodePort_t = Node::GetPortByName(*node,"Z")
    
    Protected *input.NodePort::NodePort_t = *node\inputs()
    
    Protected *vVal.CArray::CArrayV3F32 = NodePort::AcquireInputData(*input)
    Protected *xVal.CArray::CArrayFloat = *outputX\value
    Protected *yVal.CArray::CArrayFloat = *outputY\value
    Protected *zVal.CArray::CArrayFloat = *outputZ\value
    
    Protected size_t = CArray::GetCount(*vVal)
    
    CArray::SetCount(*xVal,size_t)
    CArray::SetCount(*yVal,size_t)
    CArray::SetCount(*zVal,size_t)
    
    Protected i
    Protected *v.v3f32
    For i=0 To CArray::GetCount(*vVal)-1
      *v = CArray::GetValue(*vVal,i)
      CArray::SetValueF(*xVal,i,*v\x)
      CArray::SetValueF(*yVal,i,*v\y)
      CArray::SetValueF(*zVal,i,*v\z)
    Next i
   
  EndProcedure
  
  Procedure Terminate(*node.Vector3ToFloatNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.Vector3ToFloatNode_t)
    FreeMemory(*node)
  EndProcedure
  
  

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================

  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::tree_t,type.s="Vector3ToFloatNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.Vector3ToFloatNode_t = AllocateMemory(SizeOf(Vector3ToFloatNode_t))
    ; ---[ Init Node]----------------------------------------------
    Node::INI(Vector3ToFloatNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure

EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 56
; FirstLine = 50
; Folding = --
; EnableXP