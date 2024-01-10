XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/Topology.pbi"

; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SetDataNode
  Structure SetDataNode_t Extends Node::Node_t
    *data
    *attribute.Attribute::Attribute_t
    *parent3dobject.Object3D::Object3D_t
  EndStructure
  
  ;------------------------------
  ;Interface
  ;------------------------------
  Interface ISetDataNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="SetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.SetDataNode_t)
  Declare Init(*node.SetDataNode_t)
  Declare Evaluate(*node.SetDataNode_t)
  Declare Terminate(*node.SetDataNode_t)
  
  Declare ResolveReference(*node.SetDataNode_t)
  
  ; ============================================================================
  ;  ADMINISTRATION
  ; ============================================================================
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("SetDataNode","Data",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
  DataSection
    Node::DAT(SetDataNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ==================================================================================================
; SET DATA NODE MODULE IMPLEMENTATION
; ==================================================================================================
Module SetDataNode
  UseModule Math
  ; ------------------------------------------------------------
  ; RESOLVE REFERENCE
  ;-------------------------------------------------------------
  Procedure ResolveReference(*node.SetDataNode_t)
    Protected *ref.NodePort::NodePort_t = Node::GetPortByName(*node,"Reference")
    Protected refname.s = NodePort::AcquireReferenceData(*ref)
    If refname
      Protected fields.i = CountString(refname, ".")+1
      Protected base.s = StringField(refname, 1,".")
      
      If base ="Self" Or base ="This"
        Protected *obj.Object3D::Object3D_t = Node::GetParent3DObject(*node)
        *node\parent3dobject = *obj
        Protected *input.NodePort::NodePort_t
        Protected name.s = StringField(refname, 2,".")
        If FindMapElement(*obj\geom\m_attributes(),name)
          *node\attribute = *obj\geom\m_attributes()
          *input = Node::GetPortByName(*node,"Data")
          NodePort::InitFromReference(*input,*node\attribute)
          *node\state = Graph::#Node_StateOK
          *node\errorstr = ""
          
        ; If Attribute NOT Exist Create It
        Else
          *input = Node::GetPortByName(*node,"Data")
          If *input\connected
            With *input\source
              Protected *datas.CArray::CArrayT
              Select \datatype
                Case Attribute::#ATTR_TYPE_BOOL
                  *datas = CArray::New(Types::#TYPE_BOOL)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_LONG
                  *datas = CArray::New(Types::#TYPE_LONG)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_INTEGER
                  *datas = CArray::New(Types::#TYPE_INT)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_FLOAT
                  *datas = CArray::New(Types::#TYPE_FLOAT)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_VECTOR2
                  *datas = CArray::New(Types::#TYPE_V2F32)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_VECTOR3
                  *datas = CArray::New(Types::#TYPE_V3F32)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_QUATERNION
                  *datas = CArray::New(Types::#TYPE_Q4F32)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_MATRIX3
                  *datas = CArray::New(Types::#TYPE_M3F32)
                  CArray::Copy(*datas, *input\source\attribute\data)
                Case Attribute::#ATTR_TYPE_MATRIX4
                  *datas = CArray::New(Types::#TYPE_M4F32)
                  CArray::Copy(*datas, *input\source\attribute\data)
              EndSelect
              
              *node\attribute = Attribute::New(*node,name,*obj\geom,\datatype,\datastructure,\datacontext,*datas,#True,#False,#True)
              Object3D::AddAttribute(*obj,*node\attribute)
              *node\state = Graph::#Node_StateOK
              NodePort::Init(*input, *obj\geom)
              *node\errorstr = ""
            EndWith
          EndIf
          
        EndIf
      EndIf
    Else
      *node\state = Graph::#Node_StateError
      *node\errorstr = "[ERROR] Input Empty"
      *node\attribute = #Null
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------
  ;   INITIALIZE
  ; -----------------------------------------------------------
  Procedure Init(*node.SetDataNode_t) 
    Node::AddInputPort(*node,"Data",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddInputPort(*node,"Reference",Attribute::#ATTR_TYPE_REFERENCE)
    Node::AddOutputPort(*node,"Execute",Attribute::#ATTR_TYPE_EXECUTE)
    
    Node::PortAffectByName(*node, "Data", "Execute")
    Node::PortAffectByName(*node, "Reference", "Execute")
    *node\label = "Set Data"
    ResolveReference(*node)
  EndProcedure
  
  ; -----------------------------------------------------------
  ;   EVALUATE
  ; -----------------------------------------------------------
  Procedure Evaluate(*node.SetDataNode_t)
    FirstElement(*node\inputs())
    Define *input.NodePort::NodePort_t = *node\inputs()
    Define x, i, size_t
    Define v.v3f32
    Define *refPort.NodePort::NodePort_t = Node::GetPortByName(*node,"Reference")
    Define *ref.Globals::Reference_t = *refPort\attribute\data
    If Not *node\attribute Or *ref\refchanged
      ResolveReference(*node.SetDataNode_t)
      *ref\refchanged = #False
    EndIf
    If Not *node\attribute : ProcedureReturn : EndIf
    
    Define *obj.Object3D::Object3D_t
    Define *parent.Object3D::Object3D_t
    Define *mesh.Polymesh::Polymesh_t
    Define *cloud.PointCloud::PointCloud_t
    
    Define *in_data.CArray::CArrayT = NodePort::AcquireInputData(*input)
    If *node\state = Graph::#Node_StateOK And *in_data And *node\attribute
      If CArray::GetCount(*in_data) = 0 : ProcedureReturn : EndIf
      size_t = Carray::GetCount(*in_data)
      Select *input\currenttype
          
      ; ------------------------------------------------------------
      ; BOOLEAN
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_BOOL
        Define *bIn.Carray::CArrayBool = *in_data
        If *input\currentcontext =Attribute::#ATTR_CTXT_SINGLETON
          PokeB(*node\attribute\data,CArray::GetValueB(*bIn,0))
        Else
          For x=0 To CArray::GetCount(*bIn)-1
            If CArray::GetValueB(*bIn,x)
              Debug "SetDataNode Array Item ["+Str(x)+"]: True"
            Else
              Debug "SetDataNode Array Item ["+Str(x)+"]: False"
            EndIf
          Next x
        EndIf
        
      ; ------------------------------------------------------------
      ; FLOAT
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_FLOAT
        Define *fIn.Carray::CArrayFloat = *in_data
        For x=0 To CArray::GetCount(*fIn)-1
          Debug "SetDataNode Array Item ["+Str(x)+"]: "+StrF(CArray::GetValueF(*fIn,x))
        Next x
        
      ; ------------------------------------------------------------
      ; VECTOR3
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_VECTOR3
        Define *vIn.Carray::CArrayV3F32 = *in_data
        Define *vOut.Carray::CArrayV3F32 = *node\attribute\data
        Define m_max = CArray::GetCount(*vIn)

        For i=0 To CArray::GetCount(*vOut)-1
          CArray::SetValue(*vOut,i,CArray::GetValue(*vIn,Min(i,m_max-1)))
        Next
        
        If *node\attribute\name = "PointPosition"
          *obj = *node\parent3dobject
     
          If *obj\type = Object3D::#Polymesh
            *mesh = *obj
            Polymesh::SetDirtyState(*mesh, Object3D::#DIRTY_STATE_DEFORM)
          ElseIf *obj\type = Object3D::#PointCloud Or *obj\type = Object3D::#InstanceCloud
            
            *cloud = *obj
            Polymesh::SetDirtyState(*mesh, Object3D::#DIRTY_STATE_DEFORM)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------
      ; QUATERNION
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_QUATERNION
        Define *qIn.Carray::CArrayQ4F32 = *in_data
        Define *qOut.Carray::CArrayQ4F32 = *node\attribute\data
        CArray::Copy(*qOut,*qIn)
        
        If *node\attribute\name = "Orientation"
          *obj = *node\parent3dobject
     
          If *obj\type = Object3D::#PointCloud
            *mesh = *obj
            PointCloud::SetDirtyState(*mesh, Object3D::#DIRTY_STATE_TOPOLOGY)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------
      ; COLOR
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_COLOR
        Define *cIn.Carray::CArrayC4F32 = *in_data
        Define *cOut.Carray::CArrayC4F32 = *node\attribute\data
        CArray::Copy(*cOut,*cIn)
        
      ; ------------------------------------------------------------
      ; MATRIX3
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_MATRIX3
        Define *m3In.Carray::CArrayM3F32 = *in_data
        Define *m3Out.Carray::CArrayM3F32 = *node\attribute\data
        CArray::Copy(*m3Out,*m3In)
        
      ; ------------------------------------------------------------
      ; MATRIX4
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_MATRIX4
        Define *m4In.Carray::CArrayM4F32 = *in_data
        Define *m4.m4f32 = CArray::GetValue(*m4In,0)
        Define *m4Out.m4f32 = *node\attribute\data
        Matrix4::SetFromOther(*m4Out,*m4)
        
        ;CArray::Copy(*m4Out,*m4In)
        
        If *node\attribute\name = "GlobalTransform"
          *parent = *node\parent3dobject
          If *parent
            Transform::UpdateSRTFromMatrix(*parent\globalT)
            Object3D::UpdateLocalTransform(*parent)
            Object3D::UpdateTransform(*parent,#Null)
          EndIf
          
        ElseIf *node\attribute\name = "LocalTransform"
          *parent = *node\parent3dobject
          If *parent
            Transform::UpdateSRTFromMatrix(*parent\localT)
            Object3D::UpdateTransform(*parent,#Null)
          EndIf 
        EndIf
        
      ; ------------------------------------------------------------
      ; TOPOLOGY
      ;-------------------------------------------------------------
      Case Attribute::#ATTR_TYPE_TOPOLOGY
        If *node\attribute\name = "Topology"
          Define *tIn.Carray::CArrayPtr = *in_data
          If CARray::GetCount(*tIn)>0
             Define *iTopo.Geometry::Topology_t = CArray::GetValuePtr(*tIn,0)
            *parent = *node\parent3dobject
  ;           
  ;           If *parent And Object3D::IsA(*parent,Object3D::#Polymesh)
              Define *geom.Geometry::PolymeshGeometry_t = *parent\geom
  ;             ;If *iTopo\dirty
              PolymeshGeometry::Set2(*geom,*iTopo)
              Polymesh::UpdateAttributes(*parent)
              Polymesh::SetDirtyState(*parent, Object3D::#DIRTY_STATE_TOPOLOGY)
              
  ;               *iTopo\dirty = #False
  ; ;               Else
  ; ;                  PolymeshGeometry::SetPointsPosition(*geom,*iTopo\vertices)
  ; ;                  Polymesh::SetDirtyState(*parent, Object3D::#DIRTY_STATE_DEFORM)
  ; ;                EndIf
  ;             Log::Message("[SetDataNode] Update Polymesh Topology")
  ;           Else
  ;             Log::Message( "[SetDataNode] Topology only supported on POLYMESH!!")
  ;           EndIf       
          EndIf    
        EndIf
      EndSelect
    EndIf

    *node\outputs()\attribute\dirty = #False
  EndProcedure

  Procedure Terminate(*node.SetDataNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SetDataNode_t)
    Node::DEL(SetDataNode)
  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Define *Me.SetDataNode_t = AllocateStructure(SetDataNode_t)
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(SetDataNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
  Class::DEF(SetDataNode)

EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 108
; FirstLine = 65
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode