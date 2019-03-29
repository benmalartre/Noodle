XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"

; ==================================================================================================
; AUDIO SINEWAVE NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioArythmeticNode
  
  Enumeration
    #ADD_MODE
    #SUB_MODE
    #MULTIPLY_MODE
    #SCALE_MODE
    #SCALEADD_MODE
    #SCALESUB_MODE
    #MIX_MODE
    #BLEND_MODE
    #SHIFT_MODE
  EndEnumeration
  
  Global Dim MODE_NAMES.s(9)
  MODE_NAMES(0) = "Add"
  MODE_NAMES(1) = "Sub"
  MODE_NAMES(2) = "Multiply"
  MODE_NAMES(3) = "Scale"
  MODE_NAMES(4) = "ScaleAdd"
  MODE_NAMES(5) = "ScaleSub"
  MODE_NAMES(6) = "Mix"
  MODE_NAMES(7) = "Blend"
  MODE_NAMES(8) = "Shift"
  
  Structure AudioArythmeticNode_t Extends Node::Node_t
    playing.b
    mute.b
    *node.STK::Arythmetic
    mode.i
    scalar.f
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioArythmeticNode Extends Node::INode
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioArythmetic",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioArythmeticNode_t)
  Declare Init(*node.AudioArythmeticNode_t)
  Declare Evaluate(*node.AudioArythmeticNode_t)
  Declare Terminate(*node.AudioArythmeticNode_t)
  Declare OnConnect(*node.AudioArythmeticNode_t, *port.NodePort::NodePort_t)
  Declare OnDisconnect(*node.AudioArythmeticNode_t, *port.NodePort::NodePort_t)
  
  ; ================================================================================================
  ;  ADMINISTRATION
  ; ================================================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioArythmeticNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioArythmeticNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; AUDIO SINEWAVE NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module AudioArythmeticNode
  ; ------------------------------------------------------------------------------------------------
  ;   INIT
  ; ------------------------------------------------------------------------------------------------
  Procedure Init(*node.AudioArythmeticNode_t)
    ; input ports
    Protected *mute.NodePort::NodePort_t = Node::AddInputPort(*node,"Mute",Attribute::#ATTR_TYPE_BOOL)
    Protected *mode.NodePort::NodePort_t = Node::AddInputPort(*node,"Mode",Attribute::#ATTR_TYPE_INTEGER)
    Protected *lhs.NodePort::NodePort_t = Node::AddInputPort(*node,"LHS",Attribute::#ATTR_TYPE_AUDIO)
    Protected *rhs.NodePort::NodePort_t = Node::AddInputPort(*node,"RHS",Attribute::#ATTR_TYPE_AUDIO)
    Protected *scalar.NodePort::NodePort_t = Node::AddInputPort(*node,"Scalar",Attribute::#ATTR_TYPE_FLOAT)
    
    ; output port
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_AUDIO)
    
    ; attributes affects
    Node::PortAffectByName(*node, "Mute", "Output")
    Node::PortAffectByName(*node, "Mode", "Output")
    Node::PortAffectByName(*node, "LHS", "Output")
    Node::PortAffectByName(*node, "RHS", "Output")
    Node::PortAffectByName(*node, "Scalar", "Output")
    
    *node\label = "Arythmetic : ADD"
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------------
  ;   EVALUATE
  ; ------------------------------------------------------------------------------------------------
  Procedure Evaluate(*node.AudioArythmeticNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    SelectElement(*node\inputs(), 0)
    Protected *mute.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 1)
    Protected *mode.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(), 4)
    Protected *scalar.NodePort::NodePort_t = *node\inputs()
    
    Protected *aMute.CArray::CArrayBool = *mute\value
    Protected *aMode.CArray::CArrayInt = *mode\value
    Protected *aScalar.CArray::CArrayFloat = *scalar\value
    
    If *node\node
      *node\mode = CArray::GetValueF(*aMode, 0)
      *node\scalar = CArray::GetValueF(*aScalar, 0)
      
      STK::SetArythmeticMode(*node\node, *node\mode)
      STK::SetArythmeticScalar(*node\node, *node\scalar)
      
      *node\label = "Arythmetic : "+STK::arythmetic_modes(*node\mode)
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   TERMINATE
  ; -----------------------------------------------------------------------------------------------
  Procedure Terminate(*node.AudioArythmeticNode_t)
  
  EndProcedure
  
   ; -----------------------------------------------------------------------------------------------
  ;   ON CONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnConnect(*node.AudioArythmeticNode_t, *port.NodePort::NodePort_t)
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
      Define *stream.STK::GeneratorStream
      
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
            MessageRequester("AUDIO SINE", "ADD GENERATOR :)")
          EndIf
        Else
          MessageRequester("AUDIO", "NO AUDIO NODE For THIS ITEM")  
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------------------
  ;   ON DISCONNECT
  ; -----------------------------------------------------------------------------------------------
  Procedure OnDisconnect(*node.AudioArythmeticNode_t, *port.NodePort::NodePort_t)
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
  Procedure Delete(*node.AudioArythmeticNode_t)
    Node::DEL(AudioArythmeticNode)
  EndProcedure

  ; ===============================================================================================
  ;  CONSTRUCTORS
  ; ===============================================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioArythmetic",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]------------------------------------------------------------------
    Protected *Me.AudioArythmeticNode_t = AllocateMemory(SizeOf(AudioArythmeticNode_t))
    
    ; ---[ Init Node]------------------------------------------------------------------------------
    Node::INI(AudioArythmeticNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]---------------------------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioArythmeticNode)
EndModule

; =================================================================================================
;  EOF
; =================================================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 169
; FirstLine = 146
; Folding = --
; EnableXP