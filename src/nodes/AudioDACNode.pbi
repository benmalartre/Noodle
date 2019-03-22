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
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IAudioDACNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AudioDAC",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AudioDACNode_t)
  Declare Init(*node.AudioDACNode_t)
  Declare Evaluate(*node.AudioDACNode_t)
  Declare Terminate(*node.AudioDACNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
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
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Init(*node.AudioDACNode_t)
    Protected *inputs.NodePort::NodePort_t = Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_AUDIO)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_AUDIO)
    Node::PortAffectByName(*node, "Value", "Result")
    *node\label = "0"
  EndProcedure
  
  Procedure Evaluate(*node.AudioDACNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\Inputs()
    Protected *bIn.CArray::CArrayInt = *input\value
    Protected *bOut.CArray::CArrayInt = *output\value
    CArray::SetCount(*bOut,CArray::GetCount(*bIn))
    CArray::Copy(*bOut,*bIn)
    
    *node\label = Str(CArray::GetValueI(*bOut,0))
    If Carray::GetCount(*bOut)>1
      *node\label + "[]"
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.AudioDACNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AudioDACNode_t)
    Node::DEL(AudioDACNode)
  EndProcedure
  
  

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AudioDAC",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AudioDACNode_t = AllocateMemory(SizeOf(AudioDACNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AudioDACNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AudioDACNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 48
; FirstLine = 26
; Folding = --
; EnableXP