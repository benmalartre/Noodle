
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; BUILD ARRAY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule RandomNode
  Structure RandomNode_t Extends Node::Node_t
    mode.i
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IRandomNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="RandomNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.RandomNode_t)
  Declare Init(*node.RandomNode_t)
  Declare Evaluate(*node.RandomNode_t)
  Declare Terminate(*node.RandomNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("RandomNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(RandomNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; BUILD ARRAY NODE MODULE DECLARATION
; ==================================================================================================
Module RandomNode
  UseModule Math
  
  Procedure Init(*node.RandomNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"TimeVarying",Attribute::#ATTR_TYPE_BOOL)
    Node::AddInputPort(*node,"MeanValue",datatype)
    Node::AddInputPort(*node,"Variance",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",datatype)
    
    Node::PortAffectByName(*node, "Seed", "result")
    Node::PortAffectByName(*node, "TimeVarying", "result")
    Node::PortAffectByName(*node, "MeanValue", "result")
    Node::PortAffectByName(*node, "Variance", "result")
    
    *node\label = "Random"
  EndProcedure
  
  Procedure Evaluate(*node.RandomNode_t)
    FirstElement(*node\inputs())
    Protected *seedArray.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *timeVaryingArray.CArray::CArrayBool = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *meanValuePort.NodePort::NodePort_t = *node\inputs()
    Protected *meanValueArray.CArray::CArrayT = NodePort::AcquireInputData(*node\inputs())
    NextElement(*node\inputs())
    Protected *varianceArray.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected varianceConstant.b = Bool(CArray::GetCount(*varianceArray)=1)
    Protected variance.f = CArray::GetValueF(*varianceArray,0)
    variance = Max(variance,0)
    
    Protected variancei.f
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    If *output\value = #Null
      NodePort::Init(*output)
    EndIf
    
    Protected i.i
    Protected time.f = Time::currentframe
    If CArray::GetValueB(*timeVaryingArray,0)
      RandomSeed(CArray::GetValueI(*seedArray,0)+time+i)
    Else
      RandomSeed(CArray::GetValueI(*seedArray,0)+i)
    EndIf
          
    Select *output\currenttype
        ;....................................................
        ;
        ; Integer
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *iIn.CArray::CArrayInt,*iOut.CArray::CArrayInt
        *iOut = *output\value
        *iIn = NodePort::AcquireInputData(*meanValuePort)
        
        CArray::Copy(*iOut,*iIn)
        If varianceConstant Or Not CArray::GetCount(*varianceArray) = CArray::GetCount(*iIn)
          For i=0 To *iIn\itemCount-1
            
            Protected r.f = Random(variance*2)
            int = CArray::GetValueI(*iOut,i)-variance+r
            CArray::SetValueI(*iOut,i,int)
          Next i
        Else
          For i=0 To CArray::GetCount(*iIn)-1
            variancei = CArray::GetValueI(*varianceArray,i)
            r.f = Random(variancei*2)
            int = CArray::GetValueI(*iOut,i)-variancei+r
            CArray::SetValueI(*iOut,i,int)
          Next i
        EndIf
        
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayInt,*fOut.CArray::CArrayInt
        *fOut = *output\value
        *fIn = NodePort::AcquireInputData(*meanValuePort)
        
        CArray::Copy(*fOut,*fIn)
        If varianceConstant Or Not CArray::GetCount(*varianceArray) = CArray::GetCount(*fIn)
          For i=0 To *fIn\itemCount-1
            
            r.f = Random(variance*2)
            float = CArray::GetValueF(*iOut,i)-variance+r
            CArray::SetValueI(*iOut,i,float)
          Next i
        Else
          For i=0 To CArray::GetCount(*iIn)-1
            variancef = CArray::GetValueF(*varianceArray,i)
            r.f = Random(variancef*2)
            float = CArray::GetValueF(*iOut,i)-variancef+r
            CArray::SetValueF(*iOut,i,float)
          Next i
        EndIf
        
        
        
        ;....................................................
        ;
        ; Vector 3
        ;....................................................
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected *v.v3f32
        Protected v2.v3f32
        Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
        Define.f rx,ry,rz
        *vOut = *output\value
        *vIn = NodePort::AcquireInputData(*meanValuePort)
        CArray::Copy(*vOut,*vIn)


        If varianceConstant Or Not CArray::GetCount(*varianceArray) = CArray::GetCount(*vIn)
          For i=0 To CArray::GetCount(*vIn)-1
           
            rx.f = -variance + (Random(100)/50)*variance
            ry.f = -variance + (Random(100)/50)*variance
            rz.f = -variance + (Random(100)/50)*variance
            *v = CArray::GetValue(*vOut,i);-variance+r
            Vector3::Set(@v2,rx,ry,rz)
            Vector3::AddInPlace(*v,@v2)
            CArray::SetValue(*vOut,i,*v)
    
          Next i
        Else
          For i=0 To CArray::GetCount( *vIn)-1
            
            variancei = CArray::GetValueF(*varianceArray,i)
            rx.f = -variance + (Random(100)/50)*variance
            ry.f = -variance + (Random(100)/50)*variance
            rz.f = -variance + (Random(100)/50)*variance
            *v = CArray::GetValue(*vOut,i);-variance+r
            Vector3::Set(@v2,rx,ry,rz)
            Vector3::AddInPlace(*v,@v2)
            CArray::SetValue(*vOut,i,*v)
    
          Next i
        EndIf
        
  
      
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + "DataType UNDEFIEND"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + "DataType POLYMORPH"
         Default
        Debug *output\name + ": DataType OTHER"
    EndSelect
  
  EndProcedure
  
  Procedure Terminate(*node.RandomNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.RandomNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="RandomNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.RandomNode_t = AllocateMemory(SizeOf(RandomNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(RandomNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(RandomNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 60
; FirstLine = 53
; Folding = --
; EnableXP