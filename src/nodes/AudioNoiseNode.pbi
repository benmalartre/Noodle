﻿XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"
XIncludeFile "AudioNode.pbi"

; ==================================================================================================
; AUDIO NOISE GENERATOR NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioNoiseNode
  Structure AudioNoiseNode_t Extends AudioNode::AudioNode_t
    seed.i
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioNoiseNode Extends AudioNode::IAudioNode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioNoise",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioNoiseNode_t)
  Declare Init(*node.AudioNoiseNode_t)
  Declare Evaluate(*node.AudioNoiseNode_t)
  Declare Terminate(*node.AudioNoiseNode_t)
   Declare OnConnect(*node.AudioNoiseNode_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*node.AudioNoiseNode_t, *port.NodePort::NodePort_t)
  
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
    AudioNode::Init(*node)
    Protected *seed.NodePort::NodePort_t = Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)
    
    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    Node::PortAffectByName(*node, "Volume", "Output")
    Node::PortAffectByName(*node, "Seed", "Output")
    
    *node\label = "AudioNoise"
  EndProcedure
  
  Procedure Evaluate(*node.AudioNoiseNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 1)
    Protected *volume.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 2)
    Protected *seed.NodePort::NodePort_t = *node\inputs()
    
    Protected *aMute.CArray::CArrayBool = NodePort::AcquireInputData(*mute)
    Protected *aVolume.CArray::CArrayFloat = NodePort::AcquireInputData(*volume)
    Protected *aSeed.CArray::CArrayFloat = NodePort::AcquireInputData(*seed)
     
    *node\seed = CArray::GetValue(*aSeed, 0)
    *node\volume = CArray::GetValue(*aVolume, 0)
    
    If *node\node
      STK::SetNodeVolume(*node\node, *node\volume)
      STK::SetGeneratorScalar(*node\node, STK::#GEN_SEED, *node\seed)
    EndIf
    
    *node\label = "Noise Seed : "+Str(*node\seed)
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON CONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnConnect(*node.AudioNoiseNode_t, *port.NodePort::NodePort_t)
    If *port\name = "Output"
      
      Define *stream.STK::Stream
      
      Define *target.NodePort::NodePort_t = *port\targets()
      Define *dst.Node::Node_t = *target\node
      If *dst\class\name = "AudioDACNode"
        Define *DAC.AudioDACNode::AudioDACNode_t = *dst
        *stream = *DAC\node
        *node\node = STK::AddGenerator(*stream, STK::#GENERATOR_SINEWAVE, 220, #True)
      Else
        Define *audio.AudioNode::AudioNode_t = *dst
        If *audio And *audio\node
          *stream = STK::GetStream(*audio\node)
          If *stream
            *node\node = STK::AddGenerator(*stream, STK::#GENERATOR_NOISE, 128, #False)
          EndIf
        EndIf
        
      EndIf
      
;       *port\connectioncallback(*port)
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON DISCONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnDisconnect(*node.AudioNoiseNode_t, *port.NodePort::NodePort_t)
    MessageRequester("AUDIO SINE WAVE", "OnDisconnect called on port ---> "+*port\name)
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
    Protected *Me.AudioNoiseNode_t = AllocateStructure(AudioNoiseNode_t)
    
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
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 143
; FirstLine = 115
; Folding = --
; EnableXP