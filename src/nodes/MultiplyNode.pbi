XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MULTIPLY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MultiplyNode
  Structure MultiplyNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IMultiplyNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MultiplyNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MultiplyNode_t)
  Declare Init(*node.MultiplyNode_t)
  Declare Evaluate(*node.MultiplyNode_t)
  Declare Terminate(*node.MultiplyNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MultiplyNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MultiplyNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MULTIPLY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module MultiplyNode
  UseModule Math
  Procedure Init(*node.MultiplyNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Value1",datatype)
    Node::AddInputPort(*node,"Value2",datatype)
    Node::AddOutputPort(*node,"Result",datatype)
    
    Node::PortAffectByName(*node, "Value1", "Result")
    Node::PortAffectByName(*node, "Value2", "Result")
    
    *node\label = "Multiply"
  EndProcedure
  
  Procedure Evaluate(*node.MultiplyNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    If *output\attribute\data = #Null
      NodePort::Init(*output)
    EndIf
    
    If *output\attribute\data = #Null : ProcedureReturn : EndIf
    
    Protected i.i
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Integer
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *lIn.CArray::CArrayInt,*lOut.CArray::CArrayInt
        *lOut = *output\attribute\data
        *lIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*lOut,CArray::GetCount(*lIn))
        CArray::Copy(*lOut,*lIn)
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
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
  
        *fOut = *output\attribute\data
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
  
        *vOut = *output\attribute\data
        *vIn = NodePort::AcquireInputData(*node\inputs())
        
        CArray::Copy(*vOut,*vIn)
        NextElement(*node\inputs())
        *input = *node\inputs()
  
        *vIn = NodePort::AcquireInputData(*input)
        Define *p1.v3f32, *p2.v3f32
        If *vIn
          If CArray::GetCount(*vIn) = CArray::GetCount(*vOut)
            For i=0 To CArray::GetCount(*vIn)-1
              *p1 = CArray::GetValue(*vIn,i)
              *p2 = CArray::GetValue(*vOut,i)
              Vector3::Multiply(v,*p2, *p1)
              CArray::SetValue(*vOut,i,v)
            Next i
          Else
            *p1 = CArray::GetValue(*vIn,0)
            For i=0 To CArray::GetCount(*vIn)-1
              *p2 = CArray::GetValue(*vOut,i)
              Vector3::Multiply(v,*p2, *p1)
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
  
  Procedure Terminate(*node.MultiplyNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MultiplyNode_t)

    FreeMemory(*node)
  EndProcedure
  
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="MultiplyNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.MultiplyNode_t = AllocateMemory(SizeOf(MultiplyNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(MultiplyNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MultiplyNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 132
; FirstLine = 132
; Folding = --
; EnableXP