XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; DIVIDE BY SCALAR NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule DivideByScalarNode
  Structure DivideByScalarNode_t Extends Node::Node_t
    *attribute.Attribute::Attribute_t
    sig_onchanged.i
    valid.b
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IDivideByScalarNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="DivideByScalarNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.DivideByScalarNode_t)
  Declare Init(*node.DivideByScalarNode_t)
  Declare Evaluate(*node.DivideByScalarNode_t)
  Declare Terminate(*node.DivideByScalarNode_t)
  
;   Declare ResolveReference(*node.DivideByScalarNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("DivideByScalarNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(DivideByScalarNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; DIVIDE BY SCALAR NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module DivideByScalarNode
  UseModule Math
  
  Procedure Init(*node.DivideByScalarNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3;|#AttributeType_Quaternion
    Node::AddInputPort(*node,"Input",datatype)
    Node::AddInputPort(*node,"Scalar",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",datatype)
    
    Node::PortAffectByName(*node, "Input", "Result")
    Node::PortAffectByName(*node, "Scalar", "Result")
    
    *node\label = "DivideByScalar"
  EndProcedure
  
  Procedure Evaluate(*node.DivideByScalarNode_t)
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
              int = CArray::GetValueI(*lIn,i)/scalar
              CArray::SetValueI(*lOut,i,int)
            Next i
          EndIf
        Else
          If *lIn And CArray::GetCount(*scalarData) = CArray::GetCount(*lIn)
            For i=0 To CArray::GetCount(*lIn)-1
              int = CArray::GetValueI(*lIn,i) / CArray::GetValueF(*scalarData,i)
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
              float = CArray::GetValueF(*fIn,i)/scalar
              CArray::SetValueF(*fOut,i,float)
            Next i
          EndIf
        Else
          If *lIn And CArray::GetCount(*fIn) = CArray::GetCount(*scalarData)
            For i=0 To CArray::GetCount(*fIn)-1
              float = CArray::GetValueF(*fIn,i) / CArray::GetValueF(*scalarData,i)
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
        Define *v.v3f32
        If scalarConstant
          If *vIn
            For i=0 To CArray::GetCount(*vIn)-1
              *v = CArray::GetValue(*vIn,i)
              Vector3::Scale(v,*v,1/scalar)
              CArray::SetValue(*vOut,i,@v)
            Next i
          EndIf
        Else
          If *vIn And CArray::GetCount(*vIn) = CArray::GetCount(*scalarData)
            Define scalar.f
            For i=0 To CArray::GetCount(*vIn)-1
              *v = CArray::GetValue(*vIn,i)
              scalar = CArray::GetValueF(*scalarData,i)
              If scalar <> 0
                Vector3::Scale(v,*v,1/scalar)
              EndIf
              
              CArray::SetValue(*vOut,i,@v)
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
  
  Procedure Terminate(*node.DivideByScalarNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.DivideByScalarNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="DivideByScalarNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.DivideByScalarNode_t = AllocateMemory(SizeOf(DivideByScalarNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(DivideByScalarNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(DivideByScalarNode)

EndModule
; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 171
; FirstLine = 164
; Folding = --
; EnableXP