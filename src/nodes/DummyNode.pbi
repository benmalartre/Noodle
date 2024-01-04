XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MULTIPLY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule DummyNode
  Structure DummyNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IDummyNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="DummyNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.DummyNode_t)
  Declare Init(*node.DummyNode_t)
  Declare Evaluate(*node.DummyNode_t)
  Declare Terminate(*node.DummyNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("DummyNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(DummyNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MULTIPLY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module DummyNode
  UseModule Math
  Procedure Init(*node.DummyNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Value1",datatype)
    Node::AddInputPort(*node,"Value2",datatype)
    Node::AddOutputPort(*node,"Result",datatype)
    
    *node\label = "Multiply"
  EndProcedure
  
  Procedure Evaluate(*node.DummyNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t

    If *output\value = #Null : ProcedureReturn : EndIf
    
    Protected i.i
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Integer
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *lIn.CArray::CArrayInt,*lOut.CArray::CArrayInt
        *lOut = *output\value
        *lIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*lOut,CArray::GetCount(*lIn))
        CArray::Copy(*lOut,*In)
        NextElement(*node\inputs())
        *input = *node\inputs()
        
        lIn = NodePort::AcquireInputData(*input)
        If lIn
          For i=0 To CArray::GetCount(*lIn)-1
            long = CArray::GetValueI(*lOut,i)*CArray::GetValueI(*lIn,i)
            CArray::SetValueI(*lOut,i,long)
          Next i
        EndIf
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Debug "Multiply FLOAT Mode..."
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
  
        *fOut = *output\value
        *fIn = NodePort::AcquireInputData(*node\inputs())
        
        CArray::Copy(*fOut,*fIn)
        NextElement(*node\inputs())
        *input = *node\inputs()
        
        *fIn = NodePort::AcquireInputData(*input)
        If *fIn
          If CArray::GetCount(*fIn) = CArray::GetCount(*fOut)
            For i=0 To CArray::GetCount(*fIn)-1
              float = CArray::GetValueF(*fOut,i)*CArray::GetValueF(*fIn,i)
              CArray::SetValueF(*fOut,i,float)
            Next i
          Else
            For i=0 To CArray::GetCount(*fIn)-1
              float = CArray::GetValueF(*fOut,i)*CArray::GetValueF(*fIn,0)
              CArray::SetValueF(*fOut,i,float)
            Next
          EndIf
        EndIf
        
        ;....................................................
        ;
        ; Vector 3
        ;....................................................
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected v.v3f32
        Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
  
        *vOut = *output\value
        *vIn = NodePort::AcquireInputData(*node\inputs())
        
        CArray::Copy(*vOut,*vIn)
        NextElement(*node\inputs())
        *input = *node\inputs()
  
        *vIn = NodePort::AcquireInputData(*input)
        If *vIn
          If CArray::GetCount(*vIn) = CArray::GetCount(*vOut)
            For i=0 To CArray::GetCount(*vIn)-1
              Vector3::Multiply(@v,CArray::GetValue(*vOut,i),CArray::GetValue(*vIn,i))
              CArray::SetValue(*vOut,i,v)
            Next i
          Else
            For i=0 To CArray::GetCount(*vIn)-1
              Vector3::Multiply(@v,CArray::GetValue(*vOut,i),CArray::GetValue(*vIn,0))
              CArray::SetValue(*vOut,i,v)
            Next i
          EndIf
        
        EndIf
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + "DataType UNDEFIEND"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + "DataType POLYMORPH"
         Default
        Debug *output\name + ": DataType OTHER"
    EndSelect
  
  EndProcedure
  
  Procedure Terminate(*node.DummyNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.DummyNode_t)
    Node::DEL(DummyNode)    
  EndProcedure
  
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="DummyNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.DummyNode_t = AllocateStructure(DummyNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(DummyNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(DummyNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 167
; FirstLine = 153
; Folding = --
; EnableXP