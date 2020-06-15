XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule TransformTopoNode
  Structure TransformTopoNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ITransformTopoNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="TransformTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.TransformTopoNode_t)
  Declare Init(*node.TransformTopoNode_t)
  Declare Evaluate(*node.TransformTopoNode_t)
  Declare Terminate(*node.TransformTopoNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("TransformTopoNode","Topology",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(TransformTopoNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module TransformTopoNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.TransformTopoNode_t)
    Protected *topo.NodePort::NodePort_t = Node::AddInputPort(*node,"Topo",Attribute::#ATTR_TYPE_TOPOLOGY)
    Protected *Ts.NodePort::NodePort_t = Node::AddInputPort(*node,"Ts",Attribute::#ATTR_TYPE_MATRIX4)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_TOPOLOGY)
    
    Node::PortAffectByName(*node, "Topo", "Result")
    Node::PortAffectByName(*node, "Ts", "Result")
    *node\label = "Transform Topo"
  EndProcedure
  
  Procedure Evaluate(*node.TransformTopoNode_t)
    Debug "EVALUATE TRANSFORM TOPO NODE.."
    Protected *outTopo.NodePort::NodePort_t = *node\outputs()
    FirstElement(*node\inputs())
    Protected *inTopo.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *inTs.NodePort::NodePort_t = *node\inputs()
    
    
    Protected *inTopoArray.CArray::CArrayPtr = NodePort::AcquireInputData(*inTopo)
    Protected *inTsArray.CArray::CArrayM4F32 = NodePort::AcquireInputData(*inTs)
    
    Protected *outTopoArray.CArray::CArrayPtr =  NodePort::AcquireOutputData(*outTopo)
    
    ; Clear old Data
    Protected i
    For i=0 To CArray::GetCount(*outTopoArray)-1
      Topology::Delete(CArray::GetValuePtr(*outTopoArray,i))
    Next
    CArray::SetCount(*outTopoArray,0)
       
    Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*inTopoArray,0)
    If *topo And CArray::GetCount(*inTsArray)>1
      Topology::TransformArray(*topo,*inTsArray,*outTopoArray)
    ElseIf *topo And CArray::GetCount(*inTsArray)=1
      Protected *out = Topology::New(*topo)
      Topology::Transform(*out,CArray::GetValue(*inTsArray,0))
      CArray::AppendPtr(*outTopoArray,*out)
    Else

    EndIf
    

  EndProcedure
  
  Procedure Terminate(*node.TransformTopoNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.TransformTopoNode_t)
    FreeMemory(*node)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="TransformTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.TransformTopoNode_t = AllocateMemory(SizeOf(TransformTopoNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(TransformTopoNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(TransformTopoNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 76
; FirstLine = 36
; Folding = --
; EnableXP