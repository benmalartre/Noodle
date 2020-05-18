XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"
XIncludeFile "AudioNode.pbi"

; ==================================================================================================
; AUDIO GENERATOR NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioGeneratorNode
  Structure AudioGeneratorNode_t Extends AudioNode::AudioNode_t
    mode.STK::GeneratorType
    frequency.f
    t60.f
    target.f
    tau.f
    time.f
    value.f
    harmonics.i
    phase.f
    phaseoffset.f
    seed.i
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioGeneratorNode Extends AudioNode::IAudioNode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioGenerator",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioGeneratorNode_t)
  Declare Init(*node.AudioGeneratorNode_t)
  Declare Evaluate(*node.AudioGeneratorNode_t)
  Declare Terminate(*node.AudioGeneratorNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioGeneratorNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioGeneratorNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module AudioGeneratorNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AudioGeneratorNode_t)
    AudioNode::Init(*node)
    ; input ports
    Protected *mode.NodePort::NodePort_t = Node::AddInputPort(*node,"Mode",Attribute::#ATTR_TYPE_INTEGER)
    Protected *frequency.NodePort::NodePort_t = Node::AddInputPort(*node,"Frequency",Attribute::#ATTR_TYPE_FLOAT)
    Protected *t60.NodePort::NodePort_t = Node::AddInputPort(*node,"T60",Attribute::#ATTR_TYPE_FLOAT)
    Protected *target.NodePort::NodePort_t = Node::AddInputPort(*node,"Target",Attribute::#ATTR_TYPE_FLOAT)
    Protected *tau.NodePort::NodePort_t = Node::AddInputPort(*node,"Tau",Attribute::#ATTR_TYPE_FLOAT)
    Protected *time.NodePort::NodePort_t = Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT)
    Protected *value.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_FLOAT)
    Protected *harmonics.NodePort::NodePort_t = Node::AddInputPort(*node,"Harmonics",Attribute::#ATTR_TYPE_INTEGER)
    Protected *phase.NodePort::NodePort_t = Node::AddInputPort(*node,"Phase",Attribute::#ATTR_TYPE_FLOAT)
    Protected *phaseoffset.NodePort::NodePort_t = Node::AddInputPort(*node,"PhaseOffset",Attribute::#ATTR_TYPE_FLOAT)
    Protected *seed.NodePort::NodePort_t = Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)

    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    Node::PortAffectByName(*node, "Volume", "Output")
    Node::PortAffectByName(*node, "Mode", "Output")
    Node::PortAffectByName(*node, "Frequency", "Output")
    Node::PortAffectByName(*node, "T60", "Output")
    Node::PortAffectByName(*node, "Target", "Output")
    Node::PortAffectByName(*node, "Tau", "Output")
    Node::PortAffectByName(*node, "Time", "Output")
    Node::PortAffectByName(*node, "Value", "Output")
    Node::PortAffectByName(*node, "Harmonics", "Output")
    Node::PortAffectByName(*node, "Phase", "Output")
    Node::PortAffectByName(*node, "PhaseOffset", "Output")
    Node::PortAffectByName(*node, "Seed", "Output")
    
    *node\label = "AudioGenerator"
  EndProcedure
  
  Procedure Evaluate(*node.AudioGeneratorNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 1)
    Protected *volume.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 2)
    Protected *mode.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 3)
    Protected *frequency.NodePort::NodePort_t = *node\inputs()
    

    Protected *aMute.CArray::CArrayBool =  NodePort::AcquireInputData(*mute)
    Protected *aVolume.CArray::CArrayFloat =  NodePort::AcquireInputData(*volume)
    Protected *aFrequency.CArray::CArrayFloat =  NodePort::AcquireInputData(*frequency)
    Protected *aMode.CArray::CArrayInt =  NodePort::AcquireInputData(*mode)
    Protected *aOutput.CArray::CArrayPtr =  NodePort::AcquireOutputData(*output)
    CArray::SetCount(*aOutput,1)
    
    *node\label = STK::generator_names(CArray::GetValueI(*aMode, 0))
    
    ;Stk::SetGeneratorScalar(*node\node)
    
  EndProcedure
  
  Procedure Terminate(*node.AudioGeneratorNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioGeneratorNode_t)
    Node::DEL(AudioGeneratorNode)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioGenerator",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AudioGeneratorNode_t = AllocateMemory(SizeOf(AudioGeneratorNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AudioGeneratorNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioGeneratorNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 112
; FirstLine = 64
; Folding = --
; EnableXP