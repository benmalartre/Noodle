XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
; ==================================================================================================
; ADD POINT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AddPointNode
  ;------------------------------
  ; Structure
  ;------------------------------
  Structure AddPointNode_t Extends Node::Node_t
    *geom.Geometry::PointCloudGeometry_t
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAddPointNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AddPoint",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AddPointNode_t)
  Declare Init(*node.AddPointNode_t)
  Declare Evaluate(*node.AddPointNode_t)
  Declare Terminate(*node.AddPointNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AddPointNode","Generators",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(AddPointNode)
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; ADD NODE MODULE IMPLEMENTATION
; ============================================================================
Module AddPointNode
  UseModule Math
  Procedure Init(*node.AddPointNode_t)
    Node::AddInputPort(*node,"Points",Attribute::#ATTR_TYPE_VECTOR3|Attribute::#ATTR_TYPE_LOCATION)
    Node::AddInputPort(*node,"Reference",Attribute::#ATTR_TYPE_REFERENCE)
    Node::AddOutputPort(*node,"Data",Attribute::#ATTR_TYPE_EXECUTE)
    
    Node::PortAffect(*node, "Points", "Data")
    Node::PortAffect(*node, "Reference", "Data")
    *node\label = "Add Point"
    
    Protected *obj.Object3D::Object3D_t = *node\parent3dobject
    
    If *obj\type = Object3D::#Object3D_PointCloud  Or *obj\type = Object3D::#Object3D_InstanceCloud
      Protected *pc.PointCloud::PointCloud_t = *obj
      *node\geom = *pc\geom
      *node\errorstr = "Add Point Node valid!!"
    Else
      *node\errorstr = "Add Point only works on Point Cloud"
      *node\geom = #Null
    EndIf
    
    Debug "Error STr AddPointNode : "+*node\errorstr
    
  EndProcedure
  
  Procedure Evaluate(*node.AddPointNode_t)    
    FirstElement(*node\inputs())
    If *node\geom
      
      Protected *obj.Object3D::Object3D_t
      Protected *inP.NodePort::NodePort_t = *node\inputs()
      If *inP\currenttype = Attribute::#ATTR_TYPE_VECTOR3
        Protected *in_data.CArray::CArrayV3F32 = NodePort::AcquireInputData(*node\inputs())
        
        If CArray::GetCount(*in_data)
          PointCloudGeometry::AddPoints(*node\geom,*in_data)
          *obj = *node\parent3dobject
          *obj\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
        EndIf
      ElseIf *inP\currenttype = Attribute::#ATTR_TYPE_LOCATION
        Protected *loc_data.CArray::CArrayPtr = NodePort::AcquireInputData(*node\inputs())
        Protected *pos_data.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
        Protected *loc.Geometry::Location_t
        If CArray::GetCount(*loc_data)
          Protected j
          Protected *pos.v3f32
          For j=0 To CArray::GetCount(*loc_data)-1
            *loc = CArray::GetValuePtr(*loc_data,j)
            *pos = Location::GetPosition(*loc)
            CArray::Append(*pos_data,*pos)
          Next
          
          PointCloudGeometry::AddPoints(*node\geom,*pos_data)
          *obj = *node\parent3dobject
              
          *obj\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
          CArray::Delete(*pos_data)
        EndIf
      EndIf
    Else
      MessageRequester("AddPointNode","No Point Cloud Geometry")
    EndIf
    
  EndProcedure
  
  Procedure Terminate(*node.AddPointNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AddPointNode_t)
    FreeMemory(*node)
  EndProcedure
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AddPoint",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AddPointNode_t = AllocateMemory(SizeOf(AddPointNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AddPointNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  ;}
  
  Class::DEF(AddPointNode)
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 56
; FirstLine = 33
; Folding = --
; EnableXP