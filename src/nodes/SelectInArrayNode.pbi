XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; SELECT IN ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SelectInArrayNode
  Structure SelectInArrayNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ISelectInArrayNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="SelectInArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SelectInArrayNode_t)
  Declare Init(*node.SelectInArrayNode_t)
  Declare Evaluate(*node.SelectInArrayNode_t)
  Declare Terminate(*node.SelectInArrayNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SelectInArrayNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SelectInArrayNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; SELECT IN ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module SelectInArrayNode
  Procedure GetSize(*node.SelectInArrayNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.SelectInArrayNode_t)
    Node::AddInputPort(*node,"Array",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddInputPort(*node,"Indices",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::PortAffectByName(*node, "Array", "Result")
    Node::PortAffectByName(*node, "Indices", "Result")
    ;Update Label
    *node\label = "Build Index Array"
  EndProcedure
  
  Procedure Evaluate(*node.SelectInArrayNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    FirstElement(*node\inputs())
    Protected *array.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *indices.NodePort::NodePort_t = *node\inputs()
    
    Protected *iArray.CArray::CArrayT = NodePort::AcquireInputData(*array)
    Protected *iIndices.CArray::CArrayT = NodePort::AcquireInputData(*indices)
    Protected *iOut.CArray::CArrayT = NodePort::AcquireOutputData(*output)
    
    If Not *iOut\type = *iArray\type : *iOut\type = *iArray\type :  EndIf
    If Not *iOut\itemSize = *iArray\itemSize : *iOut\itemSize = *iArray\itemSize :  EndIf
    
    Protected nbp.i = CArray::GetCount(*iArray)
    Protected nbi.i = CArray::GetCount(*iIndices)
    Protected nit.i
    If nbp >= nbi : nit = nbi:Else:nit = nbp:EndIf

    If nit > 0
      CArray::SetCount(*iOut, nit)
      Protected i
      For i=0 To nit-1
        CopyMemory(CArray::GetPtr(*iArray, CArray::GetValueI(*iIndices, i)), CArray::GetPtr(*iOut, i) , *iArray\itemSize) 
      Next i
    EndIf
    

  EndProcedure
  
  Procedure Terminate(*node.SelectInArrayNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SelectInArrayNode_t)
    Node::DEL(SelectInArrayNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SelectInArrayNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.SelectInArrayNode_t = AllocateStructure(SelectInArrayNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(SelectInArrayNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(SelectInArrayNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 115
; FirstLine = 87
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode