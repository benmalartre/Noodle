XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule BuildArrayNode
  Structure BuildArrayNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IBuildArrayNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="BuildArray",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.BuildArrayNode_t)
  Declare Init(*node.BuildArrayNode_t)
  Declare Evaluate(*node.BuildArrayNode_t)
  Declare Terminate(*node.BuildArrayNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("BuildArrayNode","Array",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(BuildArrayNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module BuildArrayNode
  Procedure GetSize(*node.BuildArrayNode_t)
    Protected *a.CArray::CArrayT
    Protected sum.i = 0
    ForEach *node\inputs()
      *a = *node\inputs()
      sum + CArray::GetCount(*a)
    Next
    ProcedureReturn sum
    
  EndProcedure
  
  Procedure Init(*node.BuildArrayNode_t)
    Node::AddInputPort(*node,"Value1",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddInputPort(*node,"New(Value1)...",Attribute::#ATTR_TYPE_NEW)
    Node::AddOutputPort(*node,"Result",Attribute::#ATTR_TYPE_POLYMORPH)
    
    ForEach *node\inputs()
      Node::PortAffectByName(*node, *node\inputs()\name, "Result")
    Next
    
    ;Update Label
    *node\label = "Build Array"
  EndProcedure
  
  Procedure Evaluate(*node.BuildArrayNode_t)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    FirstElement(*node\inputs())
    Protected l.i = ListSize(*node\inputs())
    Protected id.i = 0
    Protected size_t.i = GetSize(*node)
    
  
    Select *output\currenttype
      ; BOOLEAN ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_BOOL
        Protected *bIn.CArray::CArrayInt,*bOut.CArray::CArrayInt
        *bOut = *output\attribute\data
        If Not *bOut : *bOut = CArray::New(CArray::#ARRAY_BOOL) : Else : CArray::SetCount(*bOut,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *bIn = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*bOut,*bIn)
        Next
        *output\attribute\data = *bOut
        
      ; INTEGER ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected *lIn.CArray::CArrayInt,*lOut.CArray::CArrayInt
        *lOut = *output\attribute\data
        If Not *lOut : *lOut = CArray::New(CArray::#ARRAY_INT): Else : CArray::SetCount(*lOut,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *lIn = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*lOut,*lIn)
        Next
        *output\attribute\data = *lOut
        
      ; FLOAT ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
        *fOut = *output\attribute\data
        If Not *fOut : *fOut = CArray::New(CArray::#ARRAY_FLOAT) : Else : CArray::SetCount(*fOut,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *fIn = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*fOut,*fIn)
        Next
        *output\attribute\data = *fOut
        
      ; VECTOR2 ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_VECTOR2
        Protected *v2f32In.CArray::CArrayV2F32,*v2f32Out.CArray::CArrayV2F32
        *v2f32Out = *output\attribute\data
        If Not *v2f32Out : *v2f32Out = CArray::New(CArray::#ARRAY_V2F32) : Else : CArray::SetCount(*v2f32Out,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *v2f32In = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*v2f32Out,*v2f32In)
        Next
        *output\attribute\data = *v2f32Out
        
      ; VECTOR3 ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *v3f32In.CArray::CArrayV3F32,*v3f32Out.CArray::CArrayV3F32
        *v3f32Out = *output\attribute\data
        If Not *v3f32Out : *v3f32Out = CArray::New(CArray::#ARRAY_V3F32) : Else : CArray::SetCount(*v3f32Out,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *v3f32In = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*v3f32Out,*v3f32In)
        Next
        *output\attribute\data = *v3f32Out
        
      ; VECTOR4 ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_QUATERNION
        Protected *q4f32In.CArray::CArrayQ4F32,*q4f32Out.CArray::CArrayQ4F32
        *q4f32Out = *output\attribute\data
        If Not *q4f32Out : *q4f32Out = CArray::New(CArray::#ARRAY_Q4F32) : Else : CArray::SetCount(*q4f32Out,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *q4f32In = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*q4f32Out,*q4f32In)
        Next
        *output\attribute\data = *q4f32Out
        
      ; COLOR ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_COLOR
        Protected *c4f32In.CArray::CArrayC4F32,*c4f32Out.CArray::CArrayC4F32
        *c4f32Out = *output\attribute\data
        If Not *c4f32Out : *c4f32Out = CArray::New(CArray::#ARRAY_C4F32) : Else : CArray::SetCount(*c4f32Out,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *c4f32In = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*c4f32Out,*c4f32In)
        Next
        *output\attribute\data = *c4f32Out
        
      ; TOPOLOGY ATTRIBUTE
      ; ------------------------------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        Protected *topoIn.CArray::CArrayPtr,*topoOut.CArray::CArrayPtr
        *topoOut = *output\attribute\data
        If Not *topoOut : *topoOut = CArray::New(CArray::#ARRAY_PTR) : Else : CArray::SetCount(*topoOut,0) : EndIf
        
        ForEach *node \inputs()
          If *node \inputs()\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *topoIn = NodePort::AcquireInputData(*node\inputs())
          CArray::AppendArray(*topoOut,*topoIn)
        Next
        *output\attribute\data = *topoOut
        
  
    EndSelect 
    
  EndProcedure
  
  Procedure Terminate(*node.BuildArrayNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.BuildArrayNode_t)
    Node::DEL(BuildArrayNode)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="BuildArray",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.BuildArrayNode_t = AllocateStructure(BuildArrayNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(BuildArrayNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(BuildArrayNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 218
; FirstLine = 192
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode