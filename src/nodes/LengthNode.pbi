XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule LengthNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure LengthNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface ILengthNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Length",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.LengthNode_t)
  Declare Init(*node.LengthNode_t)
  Declare Evaluate(*node.LengthNode_t)
  Declare Terminate(*node.LengthNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("LengthNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(LengthNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; ADD NODE MODULE IMPLEMENTATION
; ============================================================================
Module LengthNode
  UseModule Math
  Procedure Init(*node.LengthNode_t)

    Node::AddInputPort(*node,"Vector",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Length",Attribute::#ATTR_TYPE_FLOAT)
    
    Node::PortAffectByName(*node, "Vector", "Length")
    
    *node\label = "Length"
  EndProcedure
  
  Procedure Evaluate(*node.LengthNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
   
    Protected v.v3f32, *v.v3f32
    Protected *vIn.CArray::CArrayV3F32,*fOut.CArray::CArrayFloat
    *vOut = *output\value
    *vIn = NodePort::AcquireInputData(*node\inputs())
    CArray::SetCount(*vOut,CArray::GetCount(*vIn))
    
    Protected i
    For i =0 To CArray::GetCount(*vIn)
      *v = CArray::GetValue(*vIn,i)
      CArray::SetValueF(*fOut,i,Vector3::Length(*v))
    Next
    
  EndProcedure

  Procedure Terminate(*node.LengthNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.LengthNode_t)
    Node::DEL(LengthNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Length",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.LengthNode_t = AllocateMemory(SizeOf(LengthNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(LengthNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(LengthNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 64
; FirstLine = 58
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode