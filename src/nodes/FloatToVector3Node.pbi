XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"

; ==================================================================================================
; FLOAT TO VECTOR3 NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule FloatToVector3Node
  Structure FloatToVector3Node_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface IFloatToVector3Node Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="FloatToVector3Node",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.FloatToVector3Node_t)
  Declare Init(*node.FloatToVector3Node_t)
  Declare Evaluate(*node.FloatToVector3Node_t)
  Declare Terminate(*node.FloatToVector3Node_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("FloatToVector3Node","Conversion",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(FloatToVector3Node)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; FLOAT To VECTOR3 NODE MODULE DECLARATION
; ==================================================================================================
Module FloatToVector3Node
  UseModule Math
  Procedure Init(*node.FloatToVector3Node_t)
    Protected idata.i = Attribute::#ATTR_TYPE_FLOAT
    Protected odata.i = Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"X",idata)
    Node::AddInputPort(*node,"Y",idata)
    Node::AddInputPort(*node,"Z",idata)
    Node::AddOutputPort(*node,"Pos",odata)
    
    Node::PortAffectByName(*node, "X", "Pos")
    Node::PortAffectByName(*node, "Y", "Pos")
    Node::PortAffectByName(*node, "Z", "Pos")
    *node\label = "Vector3"
  EndProcedure
  
  Procedure Evaluate(*node.FloatToVector3Node_t)
    

    SelectElement(*node\outputs(),0)
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *input.NodePort::NodePort_t
    
    SelectElement(*node\inputs(),0)
    Protected x_con = *node\inputs()\connected
    Protected *m_x.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected x_const.b = *node\inputs()\constant

    Protected x_nb = CArray::GetCount(*m_x)
    SelectElement(*node\inputs(),1)
    Protected y_con = *node\inputs()\connected
    Protected *m_y.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected y_const.b = *node\inputs()\constant

    Protected y_nb =  CArray::GetCount(*m_y)
    SelectElement(*node\inputs(),2)
    Protected z_con = *node\inputs()\connected
    Protected *m_z.CArray::CArrayFloat = NodePort::AcquireInputData(*node\inputs())
    Protected z_const.b = *node\inputs()\constant

    Protected z_nb =  CArray::GetCount(*m_z)
    
    Protected m_max= 0
    If x_con : m_max = x_nb 
    ElseIf y_con : m_max = y_nb
    ElseIf z_con : m_max = z_nb
    Else : m_max = 1 
    EndIf
    
    
    Protected *m_out.CArray::CArrayV3F32 = NodePort::AcquireOutputData(*output)
    CArray::SetCount(*m_out,m_max)
    
    Protected i=0
    Protected v.v3f32

    For i=0 To m_max-1
      
      Vector3::Set(v,CArray::GetValueF(*m_x,Min(i,x_nb-1)),CArray::GetValueF(*m_y,Min(i,y_nb-1)),CArray::GetValueF(*m_z,Min(i,z_nb-1)))
      CArray::SetValue(*m_out,i,v)
    Next i
   
  EndProcedure
  
  Procedure Terminate(*node.FloatToVector3Node_t)
  
  EndProcedure
  
  Procedure Delete(*node.FloatToVector3Node_t)
    Node::DEL(FloatToVector3Node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="FloatToVector3Node",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.FloatToVector3Node_t = AllocateStructure(FloatToVector3Node_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(FloatToVector3Node,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(FloatToVector3Node)
EndModule



; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 125
; FirstLine = 99
; Folding = --
; EnableXP