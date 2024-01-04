XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"
XIncludeFile "../nodes/AudioNode.pbi"
XIncludeFile "AudioNode.pbi"

; ==================================================================================================
; AUDIO SINEWAVE NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioSineWaveNode
  Structure AudioSineWaveNode_t Extends AudioNode::AudioNode_t
    frequency.f
    time.f
    phase.f
    phaseoffset.f
    
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioSineWaveNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioSineWave",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioSineWaveNode_t)
  Declare Init(*node.AudioSineWaveNode_t)
  Declare Evaluate(*node.AudioSineWaveNode_t)
  Declare Terminate(*node.AudioSineWaveNode_t)
  Declare OnConnect(*node.AudioSineWaveNode_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*node.AudioSineWaveNode_t, *port.NodePort::NodePort_t)
  
  ; ================================================================================================
  ;  ADMINISTRATION
  ; ================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioSineWaveNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioSineWaveNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; AUDIO SINEWAVE NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module AudioSineWaveNode
  ; ------------------------------------------------------------------------------------------------
  ;   INIT
  ; ------------------------------------------------------------------------------------------------
  Procedure Init(*node.AudioSineWaveNode_t)
    
    AudioNode::Init(*node)
    
    ; input ports
    Protected *frequency.NodePort::NodePort_t = Node::AddInputPort(*node,"Frequency",Attribute::#ATTR_TYPE_FLOAT)
    Protected *time.NodePort::NodePort_t = Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT)
    Protected *phase.NodePort::NodePort_t = Node::AddInputPort(*node,"Phase",Attribute::#ATTR_TYPE_FLOAT)
    Protected *phaseoffset.NodePort::NodePort_t = Node::AddInputPort(*node,"PhaseOffset",Attribute::#ATTR_TYPE_FLOAT)
    
    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    Node::PortAffectByName(*node, "Volume", "Output")
    Node::PortAffectByName(*node, "Frequency", "Output")
    Node::PortAffectByName(*node, "Time", "Output")
    Node::PortAffectByName(*node, "Phase", "Output")
    Node::PortAffectByName(*node, "PhaseOffset", "Output")

    *node\label = "AudioSineWave"
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------------
  ;   EVALUATE
  ; ------------------------------------------------------------------------------------------------
  Procedure Evaluate(*node.AudioSineWaveNode_t)
    Debug "EVALUATE AUDIO SINE NODE..."
    Protected *output.NodePort::NodePort_t      = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t        = *node\inputs()
    SelectElement(*node\inputs(), 1)
    Protected *volume.NodePort::NodePort_t      = *node\inputs()
    SelectElement(*node\inputs(), 2)
    Protected *frequency.NodePort::NodePort_t   = *node\inputs()
    SelectElement(*node\inputs(), 3)
    Protected *time.NodePort::NodePort_t        = *node\inputs()
    SelectElement(*node\inputs(), 4)
    Protected *phase.NodePort::NodePort_t       = *node\inputs()
    SelectElement(*node\inputs(), 5)
    Protected *phaseoffset.NodePort::NodePort_t = *node\inputs()
    
    Protected *aMute.CArray::CArrayBool         =  NodePort::AcquireInputData(*mute)
    Protected *aVolume.CArray::CArrayFloat      =  NodePort::AcquireInputData(*volume)
    Protected *aFrequency.CArray::CArrayFloat   =  NodePort::AcquireInputData(*frequency)
    Protected *aTime.CArray::CArrayInt          =  NodePort::AcquireInputData(*time)
    Protected *aPhase.CArray::CArrayFloat       =  NodePort::AcquireInputData(*phase)
    Protected *aPhaseOffset.CArray::CArrayFloat =  NodePort::AcquireInputData(*phaseoffset)
    Protected *aOutput.CArray::CArrayPtr        =  NodePort::AcquireOutputData(*output)
    
    *node\volume                                = CArray::GetValueF(*aVolume, 0)
    *node\frequency                             = CArray::GetValueF(*aFrequency, 0)
    *node\time                                  = CArray::GetValueF(*aTime, 0)
    *node\phase                                 = CArray::GetValueF(*aPhase, 0)
    *node\phaseoffset                           = CArray::GetValueF(*aPhaseOffset, 0)
    
    If *node\node
      STK::SetNodeVolume(*node\node, *node\volume)
      Debug "SET NODE FREQUENCY : "+Str(*node\frequency)
      STK::SetGeneratorScalar(*node\node, STK::#GEN_FREQUENCY, *node\frequency)
      STK::SetGeneratorScalar(*node\node, STK::#GEN_TIME, *node\time)
      STK::SetGeneratorScalar(*node\node, STK::#GEN_PHASE, *node\phase)
      STK::SetGeneratorScalar(*node\node, STK::#GEN_PHASEOFFSET, *node\phaseoffset)
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   TERMINATE
  ; -----------------------------------------------------------------------------------------------
  Procedure Terminate(*node.AudioSineWaveNode_t)
  
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON CONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnConnect(*node.AudioSineWaveNode_t, *port.NodePort::NodePort_t)
    If *port\name = "Output"
      
      Define *stream.STK::Stream
      
      Define *target.NodePort::NodePort_t = *port\targets()
      Define *dst.Node::Node_t = *target\node
      If *dst\class\name = "AudioDACNode"
        Define *DAC.AudioDACNode::AudioDACNode_t = *dst
        *stream = *DAC\node
        *node\node = STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, 64, #True)
      Else
        Define *audio.AudioNode::AudioNode_t = *dst
        If *audio And *audio\node
          *stream = STK::GetStream(*audio\node)
          If *stream
            *node\node = STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, 64, #False)
          EndIf
        Else
        EndIf
        
      EndIf
      
;       *port\connectioncallback(*port)
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON DISCONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnDisconnect(*node.AudioSineWaveNode_t, *port.NodePort::NodePort_t)
    MessageRequester("AUDIO SINE WAVE", "OnDisconnect called on port ---> "+*port\name)
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   DELETE
  ; -----------------------------------------------------------------------------------------------
  Procedure Delete(*node.AudioSineWaveNode_t)
    Node::DEL(AudioSineWaveNode)
  EndProcedure

  ; ===============================================================================================
  ;  CONSTRUCTORS
  ; ===============================================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioSineWave",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]------------------------------------------------------------------
    Protected *Me.AudioSineWaveNode_t = AllocateStructure(AudioSineWaveNode_t)
    *Me\alwaysDirty = #True
    ; ---[ Init Node]------------------------------------------------------------------------------
    Node::INI(AudioSineWaveNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]---------------------------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioSineWaveNode)
EndModule

; =================================================================================================
;  EOF
; =================================================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 182
; FirstLine = 154
; Folding = --
; EnableXP