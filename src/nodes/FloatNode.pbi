XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule FloatNode
  Structure FloatNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IFloatNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Float",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.FloatNode_t)
  Declare Init(*node.FloatNode_t)
  Declare Evaluate(*node.FloatNode_t)
  Declare Terminate(*node.FloatNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("FloatNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(FloatNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
;  IMPLEMENTATION
; ============================================================================
Module FloatNode
  ;------------------------------
  ; Init
  ;------------------------------
  Procedure Init(*node.FloatNode_t)
   Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_ANY,Attribute::#ATTR_STRUCT_SINGLE)
   Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_ANY,Attribute::#ATTR_STRUCT_SINGLE)
  EndProcedure
  
  ;------------------------------
  ; Evaluate
  ;------------------------------
  Procedure Evaluate(*node.FloatNode_t)
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *value.CArray::CArrayFloat = NodePort::AcquireInputData(*input)
    
    If *value
      Protected *outdata.CArray::CArrayFloat = *output\value
      Protected i
    
      CArray::SetCount(*outdata,CArray::GetCount(*value))
    
      For i=0 To CArray::GetCount(*value)-1
        CArray::SetValue(*outdata,i,CArray::GetValue(*value,i))
      Next i
    
      *node\label = StrF(CArray::GetValueF(*outdata,0),3)
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.FloatNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.FloatNode_t)
    Node::DEL(FloatNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure New(*tree.Tree::Tree_t,type.s="Float",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.FloatNode_t = AllocateMemory(SizeOf(FloatNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(FloatNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(FloatNode)
  
EndModule

; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 71
; FirstLine = 38
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP