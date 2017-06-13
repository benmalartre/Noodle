XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ==================================================================================================
; MULTIPLY NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SampleGeometryNode
  Structure SampleGeometryNode_t Extends Node::Node_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ISampleGeometryNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="SampleGeometryNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SampleGeometryNode_t)
  Declare Init(*node.SampleGeometryNode_t)
  Declare Evaluate(*node.SampleGeometryNode_t)
  Declare Terminate(*node.SampleGeometryNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SampleGeometryNode","Math",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SampleGeometryNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; MULTIPLY NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module SampleGeometryNode
  UseModule Math
  Procedure Init(*node.SampleGeometryNode_t)
    Protected datatype.i = Attribute::#ATTR_TYPE_FLOAT|Attribute::#ATTR_TYPE_INTEGER|Attribute::#ATTR_TYPE_VECTOR2|Attribute::#ATTR_TYPE_VECTOR3
    Node::AddInputPort(*node,"Geometry",Attribute::#ATTR_TYPE_GEOMETRY)
    Node::AddInputPort(*node,"Mode",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Rate",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddInputPort(*node,"Seed",Attribute::#ATTR_TYPE_INTEGER)
    Node::AddOutputPort(*node,"Points",Attribute::#ATTR_TYPE_LOCATION)
    
    *node\label = "SampleGeometry"
  EndProcedure
  
  Procedure Evaluate(*node.SampleGeometryNode_t)
    
    Protected *output.NodePort::NodePort_t = *node\outputs()
    
    FirstElement(*node\inputs())
    Protected *geomIn.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *modeIn.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *rateIn.NodePort::NodePort_t = *node\inputs()
    NextElement(*node\inputs())
    Protected *seedIn.NodePort::NodePort_t = *node\inputs()
    
    If *geomIn\connected
      Protected *geom.Geometry::PolymeshGeometry_t = NodePort::AcquireInputData(*geomIn)
      Protected *rate.CArray::CArrayInt = NodePort::AcquireInputData(*rateIn)
      Protected *seed.CArray::CArrayInt = NodePort::AcquireInputData(*seedIn)
      If *geom
        Sampler::SamplePolymesh(*geom,*output\value,CArray::GetValueI(*rate,0),CArray::GetValueI(*seed,0))
;         PolymeshGeometry::BunnyTopology(*geom\topo)
;         PolymeshGeometry::Set2(*geom,*geom\topo)
;         Protected *parent.Object3D::Object3D_t = *geom\parent
;         *parent\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
      Else
        MessageRequester("SampleGeometryNode","No Input Geometry")
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.SampleGeometryNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SampleGeometryNode_t)

    FreeMemory(*node)
  EndProcedure
  
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SampleGeometryNode",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.SampleGeometryNode_t = AllocateMemory(SizeOf(SampleGeometryNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(SampleGeometryNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(SampleGeometryNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 76
; FirstLine = 53
; Folding = --
; EnableXP