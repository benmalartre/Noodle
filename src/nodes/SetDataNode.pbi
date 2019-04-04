XIncludeFile "../core/Attribute.pbi"
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/Topology.pbi"

; ==================================================================================================
; FLOAT NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule SetDataNode
  Structure SetDataNode_t Extends Node::Node_t
    *data
    *attribute.Attribute::Attribute_t
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
  Procedure ResolveReference(*node.SetDataNode_t)
    Protected *ref.NodePort::NodePort_t = Node::GetPortByName(*node,"Reference")
    Protected refname.s = NodePort::AcquireReferenceData(*ref)
    If refname
      Protected fields.i = CountString(refname, ".")+1
      Protected base.s = StringField(refname, 1,".")
      
      If base ="Self" Or base ="This"
        Protected *obj.Object3D::Object3D_t = *node\parent3dobject
        Protected *input.NodePort::NodePort_t
        Protected name.s = StringField(refname, 2,".")
        If FindMapElement(*obj\geom\m_attributes(),name)
          *node\attribute = *obj\geom\m_attributes(name)
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
                  *datas = CArray::newCArrayBool()
                Case Attribute::#ATTR_TYPE_LONG
                  *datas = CArray::newCArrayLong()
                Case Attribute::#ATTR_TYPE_INTEGER
                  *datas = CArray::newCArrayInt()
                Case Attribute::#ATTR_TYPE_FLOAT
                  *datas = CArray::newCArrayFloat()
                Case Attribute::#ATTR_TYPE_VECTOR2
                  *datas = CArray::newCArrayV2F32()
                Case Attribute::#ATTR_TYPE_VECTOR3
                  *datas = CArray::newCArrayV3F32()
                Case Attribute::#ATTR_TYPE_QUATERNION
                  *datas = CArray::newCArrayQ4F32()
                Case Attribute::#ATTR_TYPE_MATRIX3
                  *datas = CArray::newCArrayM3F32()
                Case Attribute::#ATTR_TYPE_MATRIX4
                  *datas = CArray::newCArrayM4F32()
              EndSelect
              
              *node\attribute = Attribute::New(name,\datatype,\datastructure,\datacontext,*datas,#False,#True)
              Object3D::AddAttribute(*obj,*node\attribute)
              *node\state = Graph::#Node_StateOK
              NodePort::Init(*input)
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

  
  Procedure Init(*node.SetDataNode_t) 
    Node::AddInputPort(*node,"Data",Attribute::#ATTR_TYPE_POLYMORPH)
    Node::AddInputPort(*node,"Reference",Attribute::#ATTR_TYPE_REFERENCE)
    Node::AddOutputPort(*node,"Execute",Attribute::#ATTR_TYPE_EXECUTE)
    
    Node::PortAffectByName(*node, "Data", "Execute")
    Node::PortAffectByName(*node, "Reference", "Execute")
    *node\label = "Set Data"
    ResolveReference(*node)
  EndProcedure
  
  Procedure Evaluate(*node.SetDataNode_t)
    FirstElement(*node\inputs())
    Protected *input.NodePort::NodePort_t = *node\inputs()
    Protected x, i, size_t
    Protected v.v3f32
    ;NodePort::Echo(*input)
    
    Protected *in_data.Carray::CArrayT = NodePort::AcquireInputData(*input)
    Protected *ref.NodePort::NodePort_t = Node::GetPortByName(*node,"Reference")
    If Not *node\attribute Or *ref\refchanged
      ResolveReference(*node.SetDataNode_t)
      *ref\refchanged = #False
    EndIf
    
    
    If Not *node\attribute : ProcedureReturn : EndIf
    
    Protected *obj.Object3D::Object3D_t
    Protected *parent.Object3D::Object3D_t
    Protected *mesh.Polymesh::Polymesh_t
    
    If *node\state = Graph::#Node_StateOK And *in_data And *node\attribute
      size_t = Carray::GetCount(*in_data)
      Select *input\currenttype
        Case Attribute::#ATTR_TYPE_BOOL
          Protected *bIn.Carray::CArrayBool = *in_data
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
          
        Case Attribute::#ATTR_TYPE_FLOAT
          Protected *fIn.Carray::CArrayFloat = *in_data
          For x=0 To CArray::GetCount(*fIn)-1
            Debug "SetDataNode Array Item ["+Str(x)+"]: "+StrF(CArray::GetValueF(*fIn,x))
          Next x
          
        Case Attribute::#ATTR_TYPE_VECTOR3
          Protected *vIn.Carray::CArrayV3F32 = *in_data
          Protected *vOut.Carray::CArrayV3F32 = *node\attribute\data
          Protected m_max = CArray::GetCount(*vIn)

          For i=0 To CArray::GetCount(*vOut)-1
            CArray::SetValue(*vOut,i,CArray::GetValue(*vIn,Min(i,m_max-1)))
          Next
          
          If *node\attribute\name = "PointPosition"
            *obj = *node\parent3dobject
       
            If *obj\type = Object3D::#Object3D_Polymesh
              *mesh = *obj
              Polymesh::SetDirtyState(*mesh, Object3D::#DIRTY_STATE_DEFORM)
            EndIf
          EndIf

        Case Attribute::#ATTR_TYPE_QUATERNION
          Protected *qIn.Carray::CArrayQ4F32 = *in_data
          Protected *qOut.Carray::CArrayQ4F32 = *node\attribute\data
          CArray::Copy(*qOut,*qIn)
          
        Case Attribute::#ATTR_TYPE_COLOR
          Protected *cIn.Carray::CArrayC4F32 = *in_data
          Protected *cOut.Carray::CArrayC4F32 = *node\attribute\data
          CArray::Copy(*cOut,*cIn)
          
        Case Attribute::#ATTR_TYPE_MATRIX3
          Protected *m3In.Carray::CArrayM3F32 = *in_data
          Protected *m3Out.Carray::CArrayM3F32 = *node\attribute\data
          CArray::Copy(*m3Out,*m3In)
          
        Case Attribute::#ATTR_TYPE_MATRIX4
          Protected *m4In.Carray::CArrayM4F32 = *in_data
          Protected *m4.m4f32 = CArray::GetValue(*m4In,0)
          ;           Protected *m4Out.Carray::CArrayM4F32 = *node\attribute\data
          Protected *m4Out.m4f32 = *node\attribute\data
          Matrix4::SetFromOther(*m4Out,*m4)
          
          ;CArray::Copy(*m4Out,*m4In)
          
          If *node\attribute\name = "GlobalTransform"
            *parent = *node\parent3dobject
            If *parent
              Transform::UpdateSRTFromMatrix(*parent\globalT)
              Object3D::UpdateLocalTransform(*parent)
              ;Object3D::UpdateTransform(*parent,#Null)
            EndIf
            
          ElseIf *node\attribute\name = "LocalTransform"
            *parent = *node\parent3dobject
            If *parent
              Transform::UpdateSRTFromMatrix(*parent\localT)
              Object3D::UpdateTransform(*parent,#Null)
            EndIf 
          EndIf

        Case Attribute::#ATTR_TYPE_TOPOLOGY
          If *node\attribute\name = "Topology"
            Protected *tIn.Carray::CArrayPtr = *in_data
            Protected *tOut.Carray::CArrayPtr = *node\attribute\data
           
            Protected *iTopo.Geometry::Topology_t = CArray::GetValuePtr(*tIn,0)
            *parent = *node\parent3dobject
            
            If *parent And Object3D::IsA(*parent,Object3D::#Object3D_Polymesh)
              Protected *geom.Geometry::PolymeshGeometry_t = *parent\geom
              ;If *iTopo\dirty
                PolymeshGeometry::Set2(*geom,*iTopo)
                Polymesh::SetDirtyState(*parent, Object3D::#DIRTY_STATE_TOPOLOGY)
                *iTopo\dirty = #False
;               Else
;                  PolymeshGeometry::SetPointsPosition(*geom,*iTopo\vertices)
;                  Polymesh::SetDirtyState(*parent, Object3D::#DIRTY_STATE_DEFORM)
;                EndIf
              Log::Message("[SetDataNode] Update Polymesh Topology")
            Else
              Log::Message( "[SetDataNode] Topology only supported on POLYMESH!!")
            EndIf
          EndIf
      EndSelect
      
          
    EndIf
    *node\outputs()\dirty = #False
  EndProcedure

  Procedure Terminate(*node.SetDataNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.SetDataNode_t)
    FreeMemory(*node)
  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="SetData",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.SetDataNode_t = AllocateMemory(SizeOf(SetDataNode_t))
    
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
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 98
; FirstLine = 94
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode