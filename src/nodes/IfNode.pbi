XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; IF NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule IfNode
  Structure IfNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IIfNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="IfNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.IfNode_t)
  Declare Init(*node.IfNode_t)
  Declare Evaluate(*node.IfNode_t)
  Declare Terminate(*node.IfNode_t)
  
;   Declare ResolveReference(*node.IfNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("IfNode","Logic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(IfNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; IF NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module IfNode
  
  Procedure Init(*node.IfNode_t)
    Protected *input.NodePort::NodePort_t = Node::AddInputPort(*node,"Condition",Attribute::#ATTR_TYPE_BOOL)
    Protected *iftrue.NodePort::NodePort_t = Node::AddInputPort(*node,"If True",Attribute::#ATTR_TYPE_POLYMORPH)
    Protected *iffalse.NodePort::NodePort_t = Node::AddInputPort(*node,"If False",Attribute::#ATTR_TYPE_POLYMORPH)
    Protected *output.NodePort::NodePort_t = Node::AddOutputPort(*node,"Output",Attribute::#ATTR_TYPE_POLYMORPH)
    *node\label = "If"
  EndProcedure
  
  Procedure Evaluate(*node.IfNode_t)
    SelectElement(*node\inputs(),0)
    Protected *if.NodePort::NodePort_t = *node\Inputs()
    SelectElement(*node\inputs(),1)
    Protected *true.NodePort::NodePort_t = *node\inputs()
    SelectElement(*node\inputs(),2)
    Protected *false.NodePort::NodePort_t = *node\inputs()
    
    
    Protected *bIn.CArray::CArrayBool = NodePort::AcquireInputData(*if)
    Debug "If Node Evaluate ---> Boolean Array Input Size : "+Str(CArray::GetCount(*bIn))
    Protected *output.NodePort::NodePort_t = *node\Outputs()
    
    
    Protected *aIn.CArray::CArrayT
    If CArray::GetValueB(*bIn,0)
      *aIn = NodePort::AcquireInputData(*true)
    Else
      *aIn = NodePort::AcquireInputData(*false)
    EndIf
    Protected *aOut.CArray::CArrayT = *output\value
    CArray::Copy(*aOut,*aIn)
    
    
;     If CArray::GetValuePtr(*bIn,0)
;       Debug "We have Input Value...."
;       Select *output\currenttype
;         Case Attribute::#ATTR_TYPE_BOOL
;           Protected *bIn.CArray::CArrayBool = NodePort::AcquireInputData(*true)
;           If *bIn And CArray::GetCount(*bIn)>0
;             Protected *bOut.CArray::CArrayBool = *output\value
;             CArray::Copy(*bOut,*bIn)
;           EndIf
;           
;         Case Attribute::#ATTR_TYPE_TOPOLOGY
;           Protected *tIn.CArray::CArrayPtr = NodePort::AcquireInputData(*true)
;           If *tIn And CArray::GetCount(*tIn)>0
;             Protected *tOut.CArray::CArrayPtr = *output\value
;   ;           Protected *iTopo.CAttributePolymeshTopology_t = tIn\GetValue(0)
;   ;           Protected *oTopo.CAttributePolymeshTopology_t = tOut\GetValue(0)
;             Protected *iTopo.CTopology_t = CArray::GetValuePtr(*tIn,0)
;             Protected *oTopo.CTopology_t = CArray::GetValuePtr(*tOut,0)
;             Topology::Copy(*oTopo,*iTopo)
;           EndIf
;           
;       EndSelect
;       
;     Else
;       Debug "We don't have Inputs Data"
;       Select *output\currenttype
;         Case Attribute::#ATTR_TYPE_TOPOLOGY
;           tIn.CArrayPtr = NodePort::AcquireInputData(*false)
;           If tIn And tIn\GetCount()>0
;             tOut.CArrayPtr = *output\value 
;   ;           *iTopo.CAttributePolymeshTopology_t = tIn\GetValue(0)
;   ;           *oTopo.CAttributePolymeshTopology_t = tOut\GetValue(0)
;   ;           OAttributePolymeshTopology_Copy(*oTopo,*iTopo)
;             *iTopo.CTopology_t = tIn\GetValue(0)
;             *oTopo.CTopology_t = tOut\GetValue(0)
;             OTopology_Copy(*oTopo,*iTopo)
;           EndIf
;           
;       EndSelect
;       
;     EndIf
;     
  EndProcedure
  
  Procedure Terminate(*node.IfNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.IfNode_t)
    Node::DEL(IfNode)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="IfNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.IfNode_t = AllocateMemory(SizeOf(IfNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(IfNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(IfNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 125
; FirstLine = 50
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP