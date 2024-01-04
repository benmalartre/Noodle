XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"

; ==================================================================================================
; AUDIO EFFECT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioEffectNode
  
  Enumeration
    #EFFECT_ENVELOPE
	  #EFFECT_PRCREV
	  #EFFECT_JCREV
	  #EFFECT_NREV
	  #EFFECT_FREEVERB
	  #EFFECT_ECHO
	  #EFFECT_PITSHIFT
	  #EFFECT_LENTPITSHIFT
	  #EFFECT_CHORUS
	  #EFFECT_MOOG
  EndEnumeration
  
 
  
  Structure AudioEffectNode_t Extends Node::Node_t
    playing.b
    mute.b
    *node.STK::Effect
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioEffectNode Extends Node::INode
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioEffect",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioEffectNode_t)
  Declare Init(*node.AudioEffectNode_t)
  Declare Evaluate(*node.AudioEffectNode_t)
  Declare Terminate(*node.AudioEffectNode_t)
  Declare OnConnect(*node.AudioEffectNode_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*node.AudioEffectNode_t, *port.NodePort::NodePort_t)
  
  ; ================================================================================================
  ;  ADMINISTRATION
  ; ================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioEffectNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioEffectNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; AUDIO SINEWAVE NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module AudioEffectNode
  ; ------------------------------------------------------------------------------------------------
  ;   INIT
  ; ------------------------------------------------------------------------------------------------
  Procedure Init(*node.AudioEffectNode_t)
    ; input ports
    Protected *mute.NodePort::NodePort_t = Node::AddInputPort(*node,"Mute",Attribute::#ATTR_TYPE_BOOL)
    
    ; output port
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_AUDIO)
    
    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    
    *node\label = "Effect: Envelope"
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------------
  ;   EVALUATE
  ; ------------------------------------------------------------------------------------------------
  Procedure Evaluate(*node.AudioEffectNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 1)
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   TERMINATE
  ; -----------------------------------------------------------------------------------------------
  Procedure Terminate(*node.AudioEffectNode_t)
  
  EndProcedure
  
   ; -----------------------------------------------------------------------------------------------
  ;   ON CONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnConnect(*node.AudioEffectNode_t, *port.NodePort::NodePort_t)
    Define *cnx.Connexion::Connexion_t
    Define *src.NodePort::NodePort_t
    Define *audio.AudioNode::AudioNode_t
     Define *stk_node.STK::Node
    
    If *port\name = "LHS"
      If *port\connected
        *cnx = *port\connexion
        *src = *cnx\start
        *audio = *src\node 
        *stk_node = *audio\node
        STK::SetArythmeticLHS(*node\node, *stk_node)
      EndIf
      
    ElseIf *port\name = "RHS"
      If *port\connected
        *cnx = *port\connexion
        *src = *cnx\start
        *audio = *src\node 
        *stk_node = *audio\node
        STK::SetArythmeticRHS(*node\node, *stk_node)
      EndIf
      
    ElseIf *port\name = "Output"
      Define *stream.STK::Stream
      
      Define *target.NodePort::NodePort_t = *port\targets()
      Define *dst.Node::Node_t = *target\node
      If *dst\class\name = "AudioDACNode"
        Define *DAC.AudioDACNode::AudioDACNode_t = *dst
        *stream = *DAC\node
        *node\node = STK::AddArythmetic(*stream, #Null, #Null, #True)
      Else
        Define *audio.AudioNode::AudioNode_t = *dst
        If *audio And *audio\node
          *stream = STK::GetStream(*audio\node)
          If *stream
            *node\node = STK::AddArythmetic(*stream, #Null, #Null, #False)
          EndIf
        Else 
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON DISCONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnDisconnect(*node.AudioEffectNode_t, *port.NodePort::NodePort_t)
    If *port\name = "LHS"
      If *port\connected
        MessageRequester("AUDIO Arythmetic", "OnDisconnect called on port ---> "+*port\name)
      EndIf
      
    ElseIf *port\name = "RHS"
      If *port\connected
        MessageRequester("AUDIO Arythmetic", "OnDisconnect called on port ---> "+*port\name)
      EndIf
      
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   DELETE
  ; -----------------------------------------------------------------------------------------------
  Procedure Delete(*node.AudioEffectNode_t)
    Node::DEL(AudioEffectNode)
  EndProcedure

  ; ===============================================================================================
  ;  CONSTRUCTORS
  ; ===============================================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioEffect",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]------------------------------------------------------------------
    Protected *Me.AudioEffectNode_t = AllocateStructure(AudioEffectNode_t)
    
    ; ---[ Init Node]------------------------------------------------------------------------------
    Node::INI(AudioEffectNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]---------------------------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioEffectNode)
EndModule

; =================================================================================================
;  EOF
; =================================================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 185
; FirstLine = 157
; Folding = --
; EnableXP