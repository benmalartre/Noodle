XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; SUBTRACT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SubtractNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure SubtractNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface ISubtractNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="Subtract",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SubtractNode_t)
  Declare Init(*node.SubtractNode_t)
  Declare Evaluate(*node.SubtractNode_t)
  Declare Terminate(*node.SubtractNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SubtractNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SubtractNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; SUBTRACT NODE MODULE IMPLEMENTATION
; ============================================================================
Module SubtractNode
  UseModule Math
  Procedure Init(*node.SubtractNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Value1",datatype)
    Node::AddInputPort(*node,"Value2",datatype)
    Node::AddInputPort(*node,"New(Value2)...",Attribute::#ATTR_TYPE_NEW)
    Node::AddOutputPort(*node,"Result",datatype)
    
    ForEach *node\inputs()
      Node::PortAffectByName(*node, *node\inputs()\name, "Result")
    Next
    
    *node\label = "Subtract"
  EndProcedure
  
  Procedure Evaluate(*node.SubtractNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    If *output\attribute\data = #Null
      NodePort::Init(*output)
    EndIf
    
    Protected i.i
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Long
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected int.i
        Protected *iIn.CArray::CArrayInt,*iOut.CArray::CArrayInt
        *iOut = NodePort::AcquireInputData(*output)
        *iIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*iOut,CArray::GetCount(*iIn))
        CArray::Copy(*iOut,*iIn)
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *iIn = NodePort::AcquireInputData(*input)
          If *iIn
            If CArray::GetCount(*iIn) = 1
              For i=0 To CArray::GetCount(*iOut)-1
                int = CArray::GetValueI(*iOut,i)-CArray::GetValueI(*iIn,0)
                CArray::SetValueI(*iOut,i,int)
              Next i
            Else
              For i=0 To CArray::GetCount(*iIn)-1
                int = CArray::GetValueI(*iOut,i)-CArray::GetValueI(*iIn,i)
                CArray::SetValueI(*iOut,i,int)
              Next i
            EndIf
            
          EndIf
          
        Wend
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat
        *fOut = *output\attribute\data
        *fIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*fOut,CArray::GetCount(*fIn))
        CArray::Copy(*fOut,*fIn)
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *fIn = NodePort::AcquireInputData(*input)
          If *fIn
            If CArray::GetCount(*fIn) = 1
              For i=0 To CArray::GetCount(*fOut)-1
                float = CArray::GetValueF(*fOut,i)-CArray::GetValueF(*fIn,0)
                CArray::SetValueF(*fOut,i,float)
              Next i
            Else
              For i=0 To CArray::GetCount(*fIn)-1
                float = CArray::GetValueI(*fOut,i)-CArray::GetValueI(*fIn,i)
                CArray::SetValueF(*fOut,i,float)
              Next i
            EndIf
            
          EndIf
          
        Wend
        
        ;....................................................
        ;
        ; Vector 3
        ;....................................................
      Case Attribute::#ATTR_TYPE_VECTOR3
        Protected v.v3f32
        Protected *vIn.CArray::CArrayV3F32,*vOut.CArray::CArrayV3F32
        *vOut = *output\attribute\data
        *vIn = NodePort::AcquireInputData(*node\inputs())
        CArray::SetCount(*vOut,CArray::GetCount(*vIn))
        CArray::Copy(*vOut,*vIn)
        Define *p1.v3f32, *p2.v3f32
        While NextElement(*node\inputs())
          *input = *node\inputs()
          If *input\currenttype = Attribute::#ATTR_TYPE_NEW:Break:EndIf
          *vIn = NodePort::AcquireInputData(*input)
          If *vIn
            If CArray::GetCount(*vIn) = 1
              *p1 = CArray::GetValue(*vIn,0)
              For i=0 To CArray::GetCount(*vOut)-1
                *p2 = CArray::GetValue(*vOut,i)
                Vector3::Sub(v,*p2,*p1)
                CArray::SetValue(*vOut,i,v)
              Next i
            Else
              For i=0 To CArray::GetCount(*vIn)-1
                *p1 = CArray::GetValue(*vIn,i)
                *p2 = CArray::GetValue(*vOut,i)
                Vector3::Sub(v,*p2, *p1)
                CArray::SetValue(*vOut,i,v)
                If i=CArray::GetCount(*vOut)-1 : Break : EndIf
                
              Next i
            EndIf
            
          EndIf
          
        Wend
        
      Case Attribute::#ATTR_TYPE_UNDEFINED
        Debug *output\name + " : DataType UNDEFINED"
        
      Case Attribute::#ATTR_TYPE_POLYMORPH
        Debug *output\name + " : DataType POLYMORPH"
         Default
        Debug *output\name + " : DataType OTHER"
    EndSelect
  
  EndProcedure

  Procedure Terminate(*node.SubtractNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SubtractNode_t)
    Node::DEL(SubtractNode)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="Subtract",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.SubtractNode_t = AllocateMemory(SizeOf(SubtractNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(SubtractNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(SubtractNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 171
; FirstLine = 141
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode