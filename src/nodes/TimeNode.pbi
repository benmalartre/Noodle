XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; TIME NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule TimeNode
  Structure TimeNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ITimeNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="TimeNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.TimeNode_t)
  Declare Init(*node.TimeNode_t)
  Declare Evaluate(*node.TimeNode_t)
  Declare Terminate(*node.TimeNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("TimeNode","Constants",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(TimeNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module TimeNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.TimeNode_t)
    Node::AddInputPort(*node,"Global",Attribute::#ATTR_TYPE_BOOL,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    
    Node::PortAffect(*node, "Global", "Time")
    *node\label = "Time"
  EndProcedure
  
  Procedure Evaluate(*node.TimeNode_t)
    Protected time.f =Time::currentframe
    time * 1/Time::framerate
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *value.CArray::CArrayFloat = NodePort::AcquireInputData(*input)
    
    Protected *outdata.CArray::CArrayFloat = *output\value
    Protected i
  
    CArray::SetValueF(*outdata,0,time)
  
    *node\label = "Time : "+StrF(time,3)
    
  EndProcedure
  
  Procedure Terminate(*node.TimeNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.TimeNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="TimeNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.TimeNode_t = AllocateMemory(SizeOf(TimeNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(TimeNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(TimeNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 48
; FirstLine = 25
; Folding = --
; EnableXP