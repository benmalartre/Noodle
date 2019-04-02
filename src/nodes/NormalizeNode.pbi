XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule NormalizeNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure NormalizeNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface INormalizeNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Normalize",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.NormalizeNode_t)
  Declare Init(*node.NormalizeNode_t)
  Declare Evaluate(*node.NormalizeNode_t)
  Declare Terminate(*node.NormalizeNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("NormalizeNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(NormalizeNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; ADD NODE MODULE IMPLEMENTATION
; ============================================================================
Module NormalizeNode
  UseModule Math
  Procedure Init(*node.NormalizeNode_t)

    Node::AddInputPort(*node,"Input",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_VECTOR3)
    
    Node::PortAffectByName(*node, "Input", "Output")
    *node\label = "Normalize"
  EndProcedure
  
  Procedure Evaluate(*node.NormalizeNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
   
    Protected v.v3f32, *v.v3f32
    Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
    *vOut = NodePort::AcquireOutputData(*output)
    *vIn = NodePort::AcquireInputData(*node\inputs())
    CArray::Copy(*vOut,*vIn)
    
    Protected i
    For i =0 To CArray::GetCount(*vOut)
      *v = CArray::GetValue(*vOut,i)
      Vector3::NormalizeInPlace(*v)
    Next
    
  EndProcedure

  Procedure Terminate(*node.NormalizeNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.NormalizeNode_t)
    Node::DEL(NormalizeNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Normalize",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.NormalizeNode_t = AllocateMemory(SizeOf(NormalizeNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(NormalizeNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(NormalizeNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 60
; FirstLine = 42
; Folding = --
; EnableXP