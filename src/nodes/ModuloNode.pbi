XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MODULO NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ModuloNode
  Structure ModuloNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IModuloNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ModuloNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ModuloNode_t)
  Declare Init(*node.ModuloNode_t)
  Declare Evaluate(*node.ModuloNode_t)
  Declare Terminate(*node.ModuloNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("ModuloNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(ModuloNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MODULO NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ModuloNode
  Procedure Init(*node.ModuloNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER
    Node::AddInputPort(*node,"Value",datatype)
    Node::AddInputPort(*node,"Modulo",datatype)
    Node::AddOutputPort(*node,"Result",datatype)
    
    Node::PortAffectByName(*node, "Value", "Result")
    Node::PortAffectByName(*node, "Modulo", "Result")
    
    *node\label = "Modulo"
  EndProcedure
  
  Procedure Evaluate(*node.ModuloNode_t)
    FirstElement(*node\inputs())
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    If *output\attribute\data = #Null
      NodePort::Init(*output)
    EndIf
    
    If *output\attribute\data = #Null
      Debug "Cannot Init Port For Modulo Node"
      ProcedureReturn 
    EndIf
    
    Protected i.i
    Protected nbp.i
    
    Select *output\currenttype
        ;....................................................
        ;
        ; Long
        ;....................................................
      Case Attribute::#ATTR_TYPE_INTEGER
        Protected long.i
        Protected *lIn.CArray::CArrayInt,*lOut.CArray::CArrayInt,*mIn.CArray::CArrayInt
        *lOut = *output\attribute\data
        FirstElement(*node\inputs())
        *lIn = NodePort::AcquireInputData(*node\inputs())
        NextElement(*node\inputs())
        *mIn = NodePort::AcquireInputData(*node\inputs())
        
        nbp = CArray::GetCount(*lIn)
        CArray::SetCount(*lOut,nbp)
        Protected modi.i = CArray::GetValueI(*mIn,0)
        For i=0 To nbp-1
          long = Carray::GetValueI(*lIn,i)%modi
          CArray::SetValueI(*lOut,i,long)
        Next
        
        ;....................................................
        ;
        ; Float
        ;....................................................
      Case Attribute::#ATTR_TYPE_FLOAT
        Protected float.f
        Protected *fIn.CArray::CArrayFloat,*fOut.CArray::CArrayFloat,*mIn2.CArray::CArrayFloat
        *fOut = *output\attribute\data
        FirstElement(*node\inputs())
        *fIn = NodePort::AcquireInputData(*node\inputs())
        NextElement(*node\inputs())
        *mIn = NodePort::AcquireInputData(*node\inputs())
        
        nbp = CArray::GetCount(*fIn)
        CArray::SetCount(*lOut,nbp)
        Protected modf.f = CArray::GetValueI(*mIn2,0)
        For i=0 To nbp-1
          float = Math::Max(Mod(Carray::GetValueF(*lIn,i),modf),0)
          CArray::SetValueF(*lOut,i,float)
        Next
        
    EndSelect
  
  EndProcedure
  
  Procedure Terminate(*node.ModuloNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ModuloNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ModuloNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ModuloNode_t = AllocateMemory(SizeOf(ModuloNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ModuloNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(ModuloNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 103
; FirstLine = 96
; Folding = --
; EnableXP