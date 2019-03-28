XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"

; ==================================================================================================
; AUDIO NOISE GENERATOR NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioNoiseNode
  Structure AudioNoiseNode_t Extends Node::Node_t
    playing.b
    mute.b
    *node.STK::GeneratorStream
    seed.i
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioNoiseNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioNoise",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioNoiseNode_t)
  Declare Init(*node.AudioNoiseNode_t)
  Declare Evaluate(*node.AudioNoiseNode_t)
  Declare Terminate(*node.AudioNoiseNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioNoiseNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioNoiseNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module AudioNoiseNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AudioNoiseNode_t)
    ; input ports
    Protected *mute.NodePort::NodePort_t = Node::AddInputPort(*node,"Mute",Attribute::#ATTR_TYPE_BOOL)
    Protected *seed.NodePort::NodePort_t = Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)
    
    ; output port
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_AUDIO)
    
    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    Node::PortAffectByName(*node, "Seed", "Output")
    
    *node\label = "AudioNoise"
  EndProcedure
  
  Procedure Evaluate(*node.AudioNoiseNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 1)
    Protected *seed.NodePort::NodePort_t = *node\inputs()
    
    
    Protected *aMute.CArray::CArrayBool = *mute\value
    Protected *aSeed.CArray::CArrayFloat = *seed\value
    CArray::SetCount(*aOutput,1)
    
    *node\label = "Noise Seed : "+Str(CArray::GetValue(*aSeed, 0))
    
  EndProcedure
  
  Procedure Terminate(*node.AudioNoiseNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioNoiseNode_t)
    Node::DEL(AudioNoiseNode)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioNoise",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AudioNoiseNode_t = AllocateMemory(SizeOf(AudioNoiseNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AudioNoiseNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioNoiseNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 14
; FirstLine = 2
; Folding = --
; EnableXP