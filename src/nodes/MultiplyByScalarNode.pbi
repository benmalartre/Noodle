XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MULTIPLY BY SCALAR NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule MultiplyByScalarNode
  Structure MultiplyByScalarNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IMultiplyByScalarNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="MultiplyByScalarNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.MultiplyByScalarNode_t)
  Declare Init(*node.MultiplyByScalarNode_t)
  Declare Evaluate(*node.MultiplyByScalarNode_t)
  Declare Terminate(*node.MultiplyByScalarNode_t)
  
;   Declare ResolveReference(*node.MultiplyByScalarNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("MultiplyByScalarNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(MultiplyByScalarNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MULTIPLY BY SCALAR NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module MultiplyByScalarNode
  UseModule Math
  
  Procedure Init(*node.MultiplyByScalarNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3;|#AttributeType_Quaternion
    Node::AddInputPort(*node,"Input",datatype)
    Node::AddInputPort(*node,"Scalar",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",datatype)
    
    Node::PortAffectByName(*node, "Input", "Result")
    Node::PortAffectByName(*node, "Scalar", "Result")
    *node\label = "MultiplyByScalar"
  EndProcedure
  
  Procedure Evaluate(*node.MultiplyByScalarNode_t)
    SelectElement(*node\inputs(),1)
    Protected *scalarData.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected scalarConstant.b = Bool(CArray::GetCount(*scalarData) = 1)
    Protected scalar.f = CArray::GetValueF(*scalarData,0)
    
    FirstElement(*node\inputs())
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
    If *output\value = #Null
      NodePort::Init(*output)
    EndIf
    
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
        
        lIn = NodePort::AcquireInputData(*input)
        If scalarConstant
          If *lIn
            
            For i=0 To CArray::GetCount(*lIn)-1
              int = CArray::GetValueI(*lIn,i)*scalar
              CArray::SetValueI(*lOut,i,int)
            Next i
          EndIf
        Else
          If *lIn And CArray::GetCount(*scalarData) = CArray::GetCount(*lIn)
            For i=0 To CArray::GetCount(*lIn)-1
              int = CArray::GetValueI(*lIn,i) * CArray::GetValueF(*scalarData,i)
              CArray::SetValueI(*lOut,i,int)
            Next i
          EndIf
        EndIf
        
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
  
        *fOut = *output\value
        *fIn = NodePort::AcquireInputData(*input)
        CArray::SetCount(*fOut,CArray::GetCount(*fIn))
        If scalarConstant
          If *fIn
            For i=0 To CArray::GetCount(*fIn)-1
              float = CArray::GetValueF(*fIn,i)*scalar
              CArray::SetValueF(*fOut,i,float)
            Next i
          EndIf
        Else
          If *lIn And CArray::GetCount(*fIn) = CArray::GetCount(*scalarData)
            For i=0 To CArray::GetCount(*fIn)-1
              float = CArray::GetValueF(*fIn,i) * CArray::GetValueF(*scalarData,i)
              CArray::SetValueF(*fOut,i,float)
            Next i
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
        CArray::SetCount(*vOut,CArray::GetCount(*vIn))
        Protected *v.v3f32
        Define scalar.f
        If scalarConstant
          If *vIn
            For i=0 To CArray::GetCount(*vIn)-1
              *v = CArray::GetValue(*vIn,i)
              Vector3::Scale(v,*v,scalar)
              CArray::SetValue(*vOut,i,v)
            Next i
          EndIf
        Else
          If *vIn And CArray::GetCount(*vIn) = CArray::GetCount(*scalarData)
            For i=0 To CArray::GetCount(*vIn)-1
              *v = CArray::GetValue(*vIn,i)
              scalar = CArray::GetValueF(*scalarData,i)
              Vector3::Scale(v,*v,scalar)
              CArray::SetValue(*vOut,i,v)
            Next i
          EndIf
        EndIf
        
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + "DataType UNDEFINED"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + "DataType POLYMORPH"
      Default
        Debug *output\name + ": DataType OTHER"
    EndSelect
    
    *output\dirty = #False
  
  EndProcedure
  
  Procedure Terminate(*node.MultiplyByScalarNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.MultiplyByScalarNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="MultiplyByScalarNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.MultiplyByScalarNode_t = AllocateMemory(SizeOf(MultiplyByScalarNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(MultiplyByScalarNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(MultiplyByScalarNode)

EndModule
; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 89
; FirstLine = 65
; Folding = --
; EnableXP