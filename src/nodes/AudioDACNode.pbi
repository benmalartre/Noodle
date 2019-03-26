XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"

; ==================================================================================================
; RTAUDIO DAC NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioDACNode
  Structure AudioDACNode_t Extends Node::Node_t
    mute.b
    playing.b
    *DAC.STK::RtAudio
    nbStreams.i
  EndStructure
  
  ; ------------------------------
  ;   Interface
  ; ------------------------------
  Interface IAudioDACNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t, type.s="AudioDAC", x.i=0, y.i=0, w.i=100, h.i=50, c.i=0)
  Declare Delete(*node.AudioDACNode_t)
  Declare Init(*node.AudioDACNode_t)
  Declare Evaluate(*node.AudioDACNode_t)
  Declare Terminate(*node.AudioDACNode_t)
  
  ; ================================================================================================
  ;  ADMINISTRATION
  ; ================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioDACNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioDACNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module AudioDACNode
  ; --------------------------------------------------------------------------------------------------
  ;   Implementation
  ; --------------------------------------------------------------------------------------------------
  Procedure Init(*node.AudioDACNode_t)
    Protected *mute.NodePort::NodePort_t = Node::AddInputPort(*node,
                                                              "Mute",
                                                              Attribute::#ATTR_TYPE_BOOL, 
                                                              Attribute::#ATTR_CTXT_SINGLETON,
                                                              Attribute::#ATTR_STRUCT_SINGLE)
    
    Protected *input0.NodePort::NodePort_t = Node::AddInputPort(*node,
                                                                "Input0",
                                                                Attribute::#ATTR_TYPE_AUDIO, 
                                                                Attribute::#ATTR_CTXT_SINGLETON,
                                                                Attribute::#ATTR_STRUCT_SINGLE)
    
    Protected *new.NodePort::NodePort_t = Node::AddInputPort(*node,
                                                             "New(Input1)...",
                                                             Attribute::#ATTR_TYPE_NEW)
    
    Protected *execute.NodePort::NodePort_t = Node::AddOutputPort(*node,
                                                                  "Execute",
                                                                  Attribute::#ATTR_TYPE_EXECUTE,
                                                                  Attribute::#ATTR_CTXT_SINGLETON,
                                                                  Attribute::#ATTR_STRUCT_SINGLE)
    
    Node::PortAffectByName(*node, "Input0", "Execute")
    Node::PortAffectByName(*node, "Mute", "Execute")
    
    *node\label = "AudioDAC"
    
    *node\DAC = STK::Init()
    Protected *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*node\DAC)
    Protected *wave1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 128, #True)
    Protected *wave2.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 256, #True)
    
;     Protected *envelope.STK::Envelope = STK::AddEnvelope(*stream, STK::#ADSR_GENERATOR, *wave, #True)
;     
;     STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TIME, 0.01)
;     STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TARGET, 1)
;     STK::SetEnvelopeScalar(*envelope, STK::#ENV_DECAY_TIME, 0.02)
;     STK::SetEnvelopeScalar(*envelope, STK::#ENV_RELEASE_TIME, 0.1)
    
    STK::GeneratorStreamStart(*stream)
    Debug   " GENERATOR STREAM STARTED..."
  EndProcedure
  
  Procedure Evaluate(*node.AudioDACNode_t)
    Protected *execute.NodePort::NodePort_t = *node\outputs()
    FirstElement(*node\inputs())
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    Protected *input.NodePort::NodePort_t
    While NextElement(*node\inputs())
      *input = *node\inputs()
    Wend  
    
    
    
;     Protected *aInputs.CArray::CArrayPtr = *inputs\value
;     Protected *aMute.CArray::CArrayBool = *mute\value
  EndProcedure
  
  Procedure Terminate(*node.AudioDACNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioDACNode_t)
    Node::DEL(AudioDACNode)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]----------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t, type.s="AudioDAC", x.i=0, y.i=0, w.i=100, h.i=50, c.i=0)
    
    ; ---[ Allocate Node Memory ]-----------------------------------------------
    Protected *Me.AudioDACNode_t = AllocateMemory(SizeOf(AudioDACNode_t))
    
    ; ---[ Init Node]-----------------------------------------------------------
    Node::INI(AudioDACNode, *tree, type, x, y, w, h, c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me) 
  EndProcedure
  
  Class::DEF(AudioDACNode)
EndModule

; ==============================================================================
;  EOF
; ==============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 80
; Folding = --
; EnableXP