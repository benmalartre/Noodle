XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; TRIGONOMETRY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule TrigonometryNode
  
  Enumeration
    #TrigonometryNode_Sinus
    #TrigonometryNode_Cosinus
    #TrigonometryNode_Tangent
  EndEnumeration


  Structure TrigonometryNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ITrigonometryNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="TrigonometryNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.TrigonometryNode_t)
  Declare Init(*node.TrigonometryNode_t)
  Declare Evaluate(*node.TrigonometryNode_t)
  Declare Terminate(*node.TrigonometryNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("TrigonometryNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(TrigonometryNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; TRIGONOMETRY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module TrigonometryNode
  Procedure Init(*node.TrigonometryNode_t)
    Node::AddInputPort(*node,"Operation",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Value",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_FLOAT)
    
    *node\label = "Sin"
  EndProcedure
  
  Procedure Evaluate(*node.TrigonometryNode_t)
    Debug "Trigonometry Node : "+Str(ListSize(*node\inputs()))
    SelectElement(*node\inputs(),0)
    Protected *operationData.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected operation.i = CArray::GetValueI(*operationData,0)
  
    
    SelectElement(*node\inputs(),1)
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
;     If *output\value = #Null
;       NodePort::Init(*output)
;       Debug "Initialized Output Port "+Str(*output\currenttype)
;     EndIf
    
    If *output\value = #Null : ProcedureReturn : EndIf
    
    Protected i.i
    Protected float.f
    Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
    *fOut = *output\value
    *fIn = NodePort::AcquireInputData(*input)
    ;fOut\SetCount(fIn\GetCount())
    CArray::SetCount(*fOut,CArray::GetCount(*fIn))
    
    Select operation
      Case #TrigonometryNode_Sinus ; 0
        *node\label = "Sin"
        For i=0 To CArray::GetCount(*fIn)-1
          float = Sin(Radian(CArray::GetValueF(*fIn,i)))
          CArray::SetValueF(*fOut,i,float)
        Next i
        
        
      Case #TrigonometryNode_Cosinus ; 1
        *node\label= "Cos"
        For i=0 To CArray::GetCount(*fIn)-1
          float = Cos(Radian(CArray::GetValueF(*fIn,i)))
          CArray::SetValueF(*fOut,i,float)
        Next i
        
      Case #TrigonometryNode_Tangent ; 2
        *node\label = "Tan"
        For i=0 To CArray::GetCount(*fIn)-1
          float = Tan(Radian(CArray::GetValueF(*fIn,i)))
          CArray::SetValueF(*fOut,i,float)
          
        Next i
  
    EndSelect
  
  EndProcedure
  
  Procedure Terminate(*node.TrigonometryNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.TrigonometryNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="TrigonometryNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.TrigonometryNode_t = AllocateMemory(SizeOf(TrigonometryNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(TrigonometryNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(TrigonometryNode)
EndModule


; ============================================================================
;  EOF
; ============================================================================



; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 107
; FirstLine = 77
; Folding = --
; EnableXP