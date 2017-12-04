XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Topology.pbi"

; ==================================================================================================
; EXTRUSION NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule ExtrusionNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure ExtrusionNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IExtrusionNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="ExtrusionNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.ExtrusionNode_t)
  Declare Init(*node.ExtrusionNode_t)
  Declare Evaluate(*node.ExtrusionNode_t)
  Declare Terminate(*node.ExtrusionNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("Extrusion","Topology",@New())
  Nodes::AppendDescription(*desc)
  
  
  DataSection
    Node::DAT(ExtrusionNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ==================================================================================================
; EXTRUSION NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module ExtrusionNode
  ;------------------------------
  ;Implementation
  ;------------------------------
  Procedure Reset(*node.ExtrusionNode_t)
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
  
  Procedure Init(*node.ExtrusionNode_t)
    Node::AddInputPort(*node,"Shape",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"U",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"V",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"W",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Radius",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY)
    
    Node::PortAffect(*node, "Shape", "Topology")
    Node::PortAffect(*node, "U", "Topology")
    Node::PortAffect(*node, "V", "Topology")
    Node::PortAffect(*node, "W", "Topology")
    Node::PortAffect(*node, "Radius", "Topology")
    *node\label = "Primitive Mesh"
    Reset(*node)
  EndProcedure
  
  Procedure Evaluate(*node.ExtrusionNode_t)
    
    Protected time.f = raa_time_currentframe
    FirstElement(*node\inputs())
    Debug "[ExtrusionNode] Begin Evaluate"
    Protected *shapeData.CArray::CArrayInt = NodePort::AcquireInputData(*node\inputs())
    Protected shape.i = CArray::GetValueI(*shapeData,0)
    
    Debug "[ExtrusionNode] Curent Selected Shape : "+Str(shape)
    
    Protected *parent.Object3D::Object3D_t = *node\parent3dobject
    If Not *parent Or *parent\type <>Object3D::#Object3D_Polymesh
      *node\state = Graph::#Node_StateError
      *node\errorstr =  "[ERROR]ExtrusionNode only works on Polymesh..."
      ProcedureReturn
    EndIf
  
    ; Get Parent Objectts
    Protected *mesh.Polymesh::Polymesh_t = *node\parent3dobject
  
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
    
    ; Get Output
    Protected *output.NodePort::NodePort_t = *node\outputs()
    Protected *oVal.CArray::CArrayPtr = *output\value
    ;   Protected *topo.CAttributePolymeshTopology_t = oVal\GetValue(0)
    Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*oVal,0)

    Select shape
        ; Box Shape
      Case 0
        ;PolymeshGeometry::Cube(*mesh\geometry,radius,u,v,w)
        PolymeshGeometry::CubeTopology(*topo,radius,u,v,w)
      Case 1
        ;PolymeshGeometry::Sphere(*mesh\geometry,radius,u,v)
        PolymeshGeometry::SphereTopology(*topo,radius,u,v)
      Case 2
        ;PolymeshGeometry::Grid(*mesh\geometry,radius,radius,u,v)
        PolymeshGeometry::GridTopology(*topo,radius,u,v)
      Case 3
        ;PolymeshGeometry::Grid(*mesh\geometry,radius,radius,u,v)
        PolymeshGeometry::CylinderTopology(*topo,radius,u,v,w,#False,#False)
      Case 4
        ;PolymeshGeometry::Grid(*mesh\geometry,radius,radius,u,v)
        PolymeshGeometry::BunnyTopology(*topo)
      Case 5
        ;PolymeshGeometry::Grid(*mesh\geometry,radius,radius,u,v)
        PolymeshGeometry::TorusTopology(*topo)
    EndSelect

    Debug "-----------> ExtrusionNode End Evaluate"
  EndProcedure
  
  Procedure Terminate(*node.ExtrusionNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.ExtrusionNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="ExtrusionNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.ExtrusionNode_t = AllocateMemory(SizeOf(ExtrusionNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(ExtrusionNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Class::DEF(ExtrusionNode)
  

EndModule


; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 83
; FirstLine = 54
; Folding = --
; EnableXP