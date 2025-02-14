XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Topology.pbi"

; ==================================================================================================
; PRIMITIVE MESH NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SimpleTopoNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure SimpleTopoNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface ISimpleTopoNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="SimpleTopoNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SimpleTopoNode_t)
  Declare Init(*node.SimpleTopoNode_t)
  Declare Evaluate(*node.SimpleTopoNode_t)
  Declare Terminate(*node.SimpleTopoNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SimpleTopo","Topology",@New())
  Nodes::AppendDescription(*desc)
  
  
  DataSection
    Node::DAT(SimpleTopoNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

Module SimpleTopoNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Reset(*node.SimpleTopoNode_t)
    Protected *iVal.CArray::CArrayInt
    Protected *fVal.CArray::CArrayFloat
    Protected *port.NodePort::NodePort_t = Node::GetPortByName(*node,"Shape")
    *iVal = NodePort::AcquireInputData(*port)
    CArray::SetValueI(*iVal,0,1)
    *port.NodePort::NodePort_t = Node::GetPortByName(*node,"U")
    *iVal = NodePort::AcquireInputData(*port)
    CArray::SetValueI(*iVal,0,32)
    *port.NodePort::NodePort_t = Node::GetPortByName(*node,"V")
    *iVal = NodePort::AcquireInputData(*port)
    CArray::SetValueI(*iVal,0,32)
    *port.NodePort::NodePort_t = Node::GetPortByName(*node,"Radius")
    *fVal = NodePort::AcquireInputData(*port)
    CArray::SetValueF(*fVal,0,5)
    
    
  EndProcedure
  
  Procedure Init(*node.SimpleTopoNode_t)
    Node::AddInputPort(*node,"Shape"    , Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"U"        , Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"V"        , Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"W"        , Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Radius"   , Attribute::#ATTR_TYPE_FLOAT)
    Node::AddInputPort(*node,"Geometry" , Attribute::#ATTR_TYPE_GEOMETRY)
    Node::AddOutputPort(*node,"Topology", Attribute::#ATTR_TYPE_TOPOLOGY)
    *node\label = "Primitive Mesh"
    Reset(*node)
    
    Node::PortAffectByName(*node, "Shape" , "Topology")
    Node::PortAffectByName(*node, "U"     , "Topology")
    Node::PortAffectByName(*node, "V"     , "Topology")
    Node::PortAffectByName(*node, "W"     , "Topology")
    Node::PortAffectByName(*node, "Radius", "Topology")
  EndProcedure
  
  Procedure Evaluate(*node.SimpleTopoNode_t)
    FirstElement(*node\inputs())
    Protected *shapeData.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected shape.i = CArray::GetValueI(*shapeData,0)

  
    ; Get Inputs
    Protected *input.NodePort::NodePort_t
    Protected *iVal.CArray::CArrayInt
    Protected *fVal.CArray::CArrayFloat
  
    Protected u,v,w
    Protected radius.f
    *input = Node::GetPortByName(*node,"U")
    *iVal = NodePort::AcquireInputData(*input)
    u = CArray::GetValueI(*iVal,0)
    *input = Node::GetPortByName(*node,"V")
    *iVal = NodePort::AcquireInputData(*input)
    v = CArray::GetValueI(*iVal,0)
    *input = Node::GetPortByName(*node,"W")
    *iVal = NodePort::AcquireInputData(*input)
    w = CArray::GetValueI(*iVal,0)
    *input = Node::GetPortByName(*node,"Radius")
    *fVal = NodePort::AcquireInputData(*input)
    radius = CArray::GetValueF(*fVal,0)
    
    Debug "SIMPLE TOPO NODE EVALUATE ..."
    Debug "U : "+Str(u)
    Debug "V : "+Str(v)
    Debug "W : "+Str(w)
    Debug "RADIUS : "+Str(radius)
    
    ; Get Output
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *topoArray.CArray::CArrayPtr =  NodePort::AcquireOutputData(*output)

    Define *topo.Geometry::Topology_t = CArray::GetValuePtr(*topoArray,0)
    Select shape
      Case 0
        Topology::Cube(*topo,radius,u,v,w)
      Case 1
        Topology::Sphere(*topo,radius,u,v)
      Case 2
        Topology::Grid(*topo,radius,u,v)
      Case 3
        Topology::Cylinder(*topo,radius,u,v,w,#False,#False)
      Case 4
        Topology::Bunny(*topo)
      Case 5
        Topology::Torus(*topo)
          
    EndSelect
    ForEach *node\outputs()
      *node\outputs()\attribute\dirty = #False
    Next
  EndProcedure
  
  Procedure Terminate(*node.SimpleTopoNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SimpleTopoNode_t)
    FreeMemory(*node)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SimpleTopoNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.SimpleTopoNode_t = AllocateStructure(SimpleTopoNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(SimpleTopoNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Class::DEF(SimpleTopoNode)
  

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 158
; FirstLine = 131
; Folding = --
; EnableXP