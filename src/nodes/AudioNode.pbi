XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"

; ==================================================================================================
; BASE AUDIO NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioNode
  Structure AudioNode_t Extends Node::Node_t
    playing.b
    mute.b
    volume.f
    *node.STK::Node
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioNode_t)
  Declare Init(*node.AudioNode_t)
  Declare Evaluate(*node.AudioNode_t)
  Declare Terminate(*node.AudioNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module AudioNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AudioNode_t)

    ; COMMON input ports
    Protected *mute.NodePort::NodePort_t = Node::AddInputPort(*node,"Mute",Attribute::#ATTR_TYPE_BOOL)
    Protected *volume.NodePort::NodePort_t = Node::AddInputPort(*node,"Volume",Attribute::#ATTR_TYPE_FLOAT)
    
    ; COMMON output port
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_AUDIO)
  EndProcedure
  
  Procedure Evaluate(*node.AudioNode_t)
    
  EndProcedure
  
  Procedure Terminate(*node.AudioNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioNode_t)
    Node::DEL(AudioNode)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AudioNode_t = AllocateMemory(SizeOf(AudioNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AudioNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 14
; FirstLine = 1
; Folding = --
; EnableXP