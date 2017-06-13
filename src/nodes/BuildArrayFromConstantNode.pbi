XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule BuildArrayFromConstantNode
  Structure BuildArrayFromConstantNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IBuildArrayFromConstantNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="BuildArrayFromConstantNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.BuildArrayFromConstantNode_t)
  Declare Init(*node.BuildArrayFromConstantNode_t)
  Declare Evaluate(*node.BuildArrayFromConstantNode_t)
  Declare Terminate(*node.BuildArrayFromConstantNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("BuildArrayFromConstantNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(BuildArrayFromConstantNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY FROM CONSTANT NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module BuildArrayFromConstantNode
  UseModule Math
  Procedure GetSize(*node.BuildArrayFromConstantNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.BuildArrayFromConstantNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_POLYMORPH
    Node::AddInputPort(*node,"Constant",datatype)
    Node::AddInputPort(*node,"Count",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Result",datatype)
    
    ;Update Label
    *node\label = "Build Array From Constant"
  EndProcedure
  
  Procedure Evaluate(*node.BuildArrayFromConstantNode_t)
    ;Inputs
    ;-------------------------------------------------
    Protected *output.NodePort::NodePort_t = *node\outputs()
    LastElement(*node\inputs())
    Protected *iCount.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
  
    FirstElement(*node\inputs())
    
    ; Output
    ;-------------------------------------------------
    If *output\value = #Null
      NodePort::Init(*output)
    EndIf
    
    Protected *iOut.CArray::CArrayT = *node\outputs()\value
    
    Protected nbp.i = CArray::GetValueI(*iCount,0)
    Protected i
    CArray::SetCount(*iOut,nbp)
    
    Select *output\currenttype
      Case Attribute::#ATTR_TYPE_BOOL
        Protected *bInVal.CArray::CArrayFloat = *iOut
        Protected *bOutVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected v_b.b = CArray::GetValueB(*bInVal,0)
          CArray::SetValueB(*bOutVal,i,v_b)  
        Next i
        
      Case Attribute::#ATTR_TYPE_LONG
        Protected *lInVal.CArray::CArrayFloat = *iOut
        Protected *lOutVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected v_l.l = CArray::GetValueL(*lInVal,0)
          CArray::SetValueL(*lOutVal,i,v_l)  
        Next i
        
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected *iInVal.CArray::CArrayFloat = *iOut
        Protected *iOutVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected v_i.i = CArray::GetValueI(*iInVal,0)
          CArray::SetValueI(*iOutVal,i,v_i)  
        Next i
        
        
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected *fVal.CArray::CArrayFloat = *iOut
        Protected *iVal.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected v_f.f = CArray::GetValueF(*iVal,0)
          CArray::SetValueF(*fVal,i,v_f)  
        Next i
        
      Case Attribute::#ATTR_TYPE_VECTOR2
        Protected *iV2Val.CArray::CArrayV2F32 = *iOut
        Protected *oV2Val.CArray::CArrayV2F32 = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected *v_v2.v2f32 = CArray::GetValue(*iV2Val,0)
          CArray::SetValue(*oV2Val,i,*v_v2)  
        Next i
        
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *iV3Val.CArray::CArrayV3F32 = *iOut
        Protected *oV3Val.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
        
        For i=0 To nbp-1
          Protected *v_v3.v3f32 = CArray::GetValue(*iV3Val,0)
          CArray::SetValue(*oV3Val,i,*v_v3)  
        Next i
    EndSelect
    
    
  EndProcedure
  
  Procedure Terminate(*node.BuildArrayFromConstantNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.BuildArrayFromConstantNode_t)
    Node::DEL(BuildArrayFromConstantNode)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="BuildArrayFromConstantNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.BuildArrayFromConstantNode_t = AllocateMemory(SizeOf(BuildArrayFromConstantNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(BuildArrayFromConstantNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(BuildArrayFromConstantNode)

EndModule

; ============================================================================
;  EOF
; ============================================================================



; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 46
; FirstLine = 25
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP