XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
;   ARRAY MINIMUM NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ArrayMaximumNode
  Structure ArrayMaximumNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IArrayMaximumNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ArrayMaximumNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ArrayMaximumNode_t)
  Declare Init(*node.ArrayMaximumNode_t)
  Declare Evaluate(*node.ArrayMaximumNode_t)
  Declare Terminate(*node.ArrayMaximumNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ArrayMaximumNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ArrayMaximumNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ArrayMaximumNode
  Procedure GetSize(*node.ArrayMaximumNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.ArrayMaximumNode_t)
    Node::AddInputPort(*node,
                       "Array",
                       Attribute::#ATTR_TYPE_LONG|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_FLOAT)
    
    Node::AddOutputPort(*node,
                        "Maximum",
                        Attribute::#ATTR_TYPE_LONG|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_FLOAT,
                        Attribute::#ATTR_CTXT_ANY, Attribute::#ATTR_STRUCT_SINGLE)
    
    ;Update Label
    *node\label = "Array Maximum"
  EndProcedure
  
  Procedure Evaluate(*node.ArrayMaximumNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *iIn.CArray::CArrayT = NodePort::AcquireInputData(*input)
    Protected *iOut.CArray::CArrayT = NodePort::AcquireOutputData(*output)
    CArray::SetCount(*iOut, 1)
    Define i
    Select *input\datastructure
      Case Attribute::#ATTR_STRUCT_SINGLE
        Select *input\datatype
          Case Attribute::#ATTR_TYPE_LONG
            Define maxl.l = Math::#U16_MIN
            For i=0 To CArray::GetCount(*iIn)
              If CArray::GetValueL(*iIn, i) > maxl : maxl = CArray::GetValueL(*iIn, i) : EndIf
            Next
            CArray::SetValueL(*iOut, 0, maxl)
            
          Case Attribute::#ATTR_TYPE_INTEGER
            Define maxi.i = Math::#U32_MIN
            For i=0 To CArray::GetCount(*iIn)
              If CArray::GetValueI(*iIn, i) > maxi : maxi = CArray::GetValueI(*iIn, i) : EndIf
            Next
            CArray::SetValueI(*iOut, 0, maxi)
            
          Case Attribute::#ATTR_TYPE_FLOAT
            Define maxf.i = Math::#F32_MIN
            For i=0 To CArray::GetCount(*iIn)
              If CArray::GetValueI(*iIn, i) > maxf : maxf = CArray::GetValueI(*iIn, i) : EndIf
            Next
            CArray::SetValueI(*iOut, 0, maxf)
           
            
        EndSelect
        
      Case Attribute::#ATTR_STRUCT_ARRAY
        Select *input\datatype
          Case Attribute::#ATTR_TYPE_LONG
            
          Case Attribute::#ATTR_TYPE_INTEGER
            
          Case Attribute::#ATTR_TYPE_FLOAT
           
            
        EndSelect
    EndSelect
    
    Protected nbp.i = CArray::GetValueI(*iIn,0)
    CArray::SetCount(*iOut,nbp)
    For i=0 To nbp-1
      CArray::SetValueI(*iOut,i,i)  
    Next i
    
    
  EndProcedure
  
  Procedure Terminate(*node.ArrayMaximumNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ArrayMaximumNode_t)
    Node::DEL(ArrayMaximumNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ArrayMaximumNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ArrayMaximumNode_t = AllocateMemory(SizeOf(ArrayMaximumNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ArrayMaximumNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(ArrayMaximumNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 77
; FirstLine = 57
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode