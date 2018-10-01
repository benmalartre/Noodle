XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; LINEAR INTERPOLATE NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule LinearInterpolateNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure LinearInterpolateNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface ILinearInterpolateNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="LinearInterpolate",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.LinearInterpolateNode_t)
  Declare Init(*node.LinearInterpolateNode_t)
  Declare Evaluate(*node.LinearInterpolateNode_t)
  Declare Terminate(*node.LinearInterpolateNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("LinearInterpolateNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(LinearInterpolateNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; LINEAR INTERPOLATE  NODE MODULE IMPLEMENTATION
; ============================================================================
Module LinearInterpolateNode
  UseModule Math
  Procedure Init(*node.LinearInterpolateNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"First",datatype)
    Node::AddInputPort(*node,"Second",datatype)
    Node::AddInputPort(*node,"Blend",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Result",datatype)
    
    *node\label = "Linear Interpolate"
  EndProcedure
  
  Procedure Evaluate(*node.LinearInterpolateNode_t)

    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    Protected *arr.CArray::CArrayT
    FirstElement(*node\inputs())
    Protected *inFirst.NodePort::NodePort_t = *node\inputs()
    *arr = NodePort::AcquireInputData(*inFirst)
    Protected f_nb = CArray::GetCount(*arr)
    Protected f_con = *inFirst\connected
    NextElement(*node\inputs())
    Protected *inSecond.NodePort::NodePort_t = *node\inputs()
    *arr = NodePort::AcquireInputData(*inSecond)
    Protected s_nb = CArray::GetCount(*arr)
    Protected s_con = *inSecond\connected
    NextElement(*node\inputs())
    Protected *inBlend.NodePort::NodePort_t = *node\inputs()
    Protected *blend.CArray::CArrayFloat = NodePort::AcquireInputData(*inBlend)
    Protected b_nb = CArray::GetCount(*blend)
    Protected b_con = *inBlend\connected
    Protected i.i
    
    Protected m_max=0
    If f_con : m_max = f_nb
    ElseIf s_con : m_max = s_nb
    ElseIf b_con : m_max = b_nb
    Else : m_max = 1
    EndIf
    
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Integer
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *iIn1.CArray::CArrayInt,*iIn2.CArray::CArrayInt,*iOut.CArray::CArrayInt
        *iOut = *output\value
        
        *iIn1 = NodePort::AcquireInputData(*inFirst)
        *iIn2 = NodePort::AcquireInputData(*inSecond)
        
        CArray::SetCount(*iOut,m_max)

        Protected fi,si
        Protected bi.f
        For i=0 To m_max-1
          fi = CArray::GetValueI(*iIn1,Max(i,f_nb-1))
          si = CArray::GetValueI(*iIn2,Max(i,s_nb-1))
          bi = CArray::GetValueF(*blend,Max(i,b_nb-1))
          LINEAR_INTERPOLATE(int,fi,si,bi)
          CArray::SetValueI(*iOut,i,int)
        Next i
          
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
       Protected float.f
        Protected *fIn1.CArray::CArrayFloat,*fIn2.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
        *fOut = *output\value
        
        *fIn1 = NodePort::AcquireInputData(*inFirst)
        *fIn2 = NodePort::AcquireInputData(*inSecond)
        
        CArray::SetCount(*fOut,m_max)

        Protected ff,sf
        Protected bf.f
        For i=0 To m_max-1
          ff = CArray::GetValueF(*fIn1,Max(i,f_nb-1))
          sf = CArray::GetValueI(*fIn2,Max(i,s_nb-1))
          bf = CArray::GetValueF(*blend,Max(i,b_nb-1))
          LINEAR_INTERPOLATE(int,ff,sf,bf)
          CArray::SetValueI(*iOut,i,int)
        Next i
        
        ;....................................................
        ;
        ; Vector 3
        ;....................................................
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected v3.v3f32
        Protected *v3In1.CArray::CArrayV3F32,*v3In2.CArray::CArrayV3F32,*v3Out.CArray::CArrayV3F32
        *v3Out = *output\value
        
        *v3In1 = NodePort::AcquireInputData(*inFirst)
        *v3In2 = NodePort::AcquireInputData(*inSecond)
        
        CArray::SetCount(*v3Out,m_max)

        Protected *fv3.v3f32,*sv3.v3f32
        Protected bv3.f
        For i=0 To m_max-1
          *fv3 = CArray::GetValue(*v3In1,Max(i,f_nb-1))
          *sv3 = CArray::GetValue(*v3In2,Max(i,s_nb-1))
          bv3 = CArray::GetValueF(*blend,Max(i,b_nb-1))
          Vector3::LinearInterpolate(v3,*fv3,*sv3,bv3)
          CArray::SetValue(*v3Out,i,@v)
        Next i
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + "DataType UNDEFIEND"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + "DataType POLYMORPH"
         Default
        Debug *output\name + ": DataType OTHER"
    EndSelect
  
  EndProcedure

  Procedure Terminate(*node.LinearInterpolateNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.LinearInterpolateNode_t)
    Node::DEL(LinearInterpolateNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="LinearInterpolate",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.LinearInterpolateNode_t = AllocateMemory(SizeOf(LinearInterpolateNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(LinearInterpolateNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(LinearInterpolateNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 153
; FirstLine = 131
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode