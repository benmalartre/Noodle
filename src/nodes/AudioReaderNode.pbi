XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../libs/STK.pbi"
XIncludeFile "AudioNode.pbi"

; ==================================================================================================
; AUDIO READER NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AudioReaderNode
  
  Structure AudioReaderNode_t Extends AudioNode::AudioNode_t
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
  Interface IAudioReaderNode Extends AudioNode::IAudioNode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioReader",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioReaderNode_t)
  Declare Init(*node.AudioReaderNode_t)
  Declare Evaluate(*node.AudioReaderNode_t)
  Declare Terminate(*node.AudioReaderNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AudioReaderNode","Audio",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AudioReaderNode)
  EndDataSection
  
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module AudioReaderNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AudioReaderNode_t)
    AudioNode::Init(*node)
    ; input ports
    Protected *mode.NodePort::NodePort_t = Node::AddInputPort(*node,"Filename",Attribute::#ATTR_TYPE_FILE)

    ; attributes affects
    Node::PortAffectByName(*node, "Filename", "Output")
    
    *node\label = "AudioReader"
  EndProcedure
  
  Procedure Evaluate(*node.AudioReaderNode_t)
    
;     Protected *output.NodePort::NodePort_t = *node\outputs()
;     SelectElement(*node\inputs(), 0)
;     Protected *mute.NodePort::NodePort_t = *node\inputs()
;     SelectElement(*node\inputs(), 1)
;     Protected *mode.NodePort::NodePort_t = *node\inputs()
;     SelectElement(*node\inputs(), 2)
;     Protected *frequency.NodePort::NodePort_t = *node\inputs()
;     
;     
;     Protected *aMute.CArray::CArrayBool =  NodePort::AcquireInputData(*mute)
;     Protected *aFrequency.CArray::CArrayFloat =  NodePort::AcquireInputData(*frequency)
;     Protected *aMode.CArray::CArrayInt =  NodePort::AcquireInputData(*mode)
;     Protected *aOutput.CArray::CArrayPtr =  NodePort::AcquireOutputData(*output)
;     CArray::SetCount(*aOutput,1)
;     
;     *node\label = STK::generator_names(CArray::GetValueI(*aMode, 0))
    
  EndProcedure
  
  Procedure Terminate(*node.AudioReaderNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioReaderNode_t)
    Node::DEL(AudioReaderNode)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioReader",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AudioReaderNode_t = AllocateMemory(SizeOf(AudioReaderNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AudioReaderNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioReaderNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 11
; Folding = --
; EnableXP