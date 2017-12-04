XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../libs/Alembic.pbi"

; ==================================================================================================
; ALEMBICIPOLYMESHTOPO NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AlembicIPolymeshTopoNode
  Structure AlembicIPolymeshTopoNode_t Extends Node::Node_t
    *obj.Object3D::Object3D_t
    *abc
    sample.Alembic::ABC_Polymesh_Topo_Sample
    *positions.CArray::CArrayV3F32
    *velocities.CArray::CArrayV3F32
    *normals.CARray::CArrayV3F32
    *tangents.CARray::CArrayV3F32
    *uvws.CArray::CArrayV3F32
    *colors.CArray::CArrayC4F32
    *indices.CArray::CArrayLong
    *facecount.CArray::CArrayLong
    
    lastT.f
    lastID.s
    lastFile.s
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAlembicIPolymeshTopoNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AlembicIPolymeshTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AlembicIPolymeshTopoNode_t)
  Declare Init(*node.AlembicIPolymeshTopoNode_t)
  Declare Evaluate(*node.AlembicIPolymeshTopoNode_t)
  Declare Terminate(*node.AlembicIPolymeshTopoNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AlembicIPolymeshTopoNode","Alembic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
   DataSection
    Node::DAT(AlembicIPolymeshTopoNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
; ALEMBICIPOLYMESHTOPO NODE MODULE IMPLEMENTATION
; ============================================================================
Module AlembicIPolymeshTopoNode
  UseModule Math
  
  Procedure PortAffects(*node.AlembicIPolymeshTopoNode_t)
    ForEach(*node\outputs())
      Node::PortAffect(*node, "File", *node\outputs()\name)
      Node::PortAffect(*node, "Identifier", *node\outputs()\name)
      Node::PortAffect(*node, "Time", *node\outputs()\name)
    Next
  EndProcedure
  
  Procedure Init(*node.AlembicIPolymeshTopoNode_t)

    Node::AddInputPort(*node,"File",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Identifier",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY)
    Node::AddOutputPort(*node,"Positions",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Velocities",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Normals",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Tangents",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"UVWs",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Colors",Attribute::#ATTR_TYPE_COLOR)
    
    PortAffects(*node)
    
    *node\positions = CArray::newCArrayV3F32()
    *node\velocities = CArray::newCArrayV3F32()
    *node\normals = CArray::newCArrayV3F32()
    *node\tangents = CArray::newCArrayV3F32()
    *node\uvws = CArray::newCArrayV3F32()
    *node\colors = CArray::newCArrayC4F32()
    *node\indices = CArray::newCArrayLong()
    *node\facecount = CArray::newCArrayLong()
    *node\label = "AlembicIPolymeshTopo"
    *node\lastT = -1
  EndProcedure
  
  Procedure Evaluate(*node.AlembicIPolymeshTopoNode_t)
    FirstElement(*node\inputs())
    Protected *filePort.NodePort::NodePort_t = *node\inputs()
    Protected *fileArray.CArray::CArrayStr = NodePort::AcquireInputData(*filePort)
    Protected file.s = CArray::GetValueStr(*fileArray,0)
    
    NextElement(*node\inputs())
    Protected *identifierPort.NodePort::NodePort_t = *node\inputs()
    Protected *identifierArray.CArray::CArrayStr = NodePort::AcquireInputData(*identifierPort)
    Protected identifier.s = CArray::GetValueStr(*identifierArray,0)
    
    NextElement(*node\inputs())
    Protected *timePort.NodePort::NodePort_t = *node\inputs()
    Protected *timeArray.CArray::CArrayFloat = NodePort::AcquireInputData(*timePort)
    Protected time.f = CArray::GetValueF(*timeArray,0)

    Protected *input.NodePort::NodePort_t
   
    
    Protected *o.AlembicObject::AlembicObject_t = *node\abc
    
    ; Initialize Alembic Object
    ;---------------------------------------------------
    If Not *o Or Not *node\lastFile = file Or Not *node\lastID = identifier
      
      If FileSize(file)>0 And GetExtensionPart(file) = "abc"
        Protected *archive.AlembicArchive::AlembicArchive_t = AlembicManager::OpenArchive(Alembic::*abc_manager,file)
        *o = AlembicArchive::GetObjectByName(*archive,identifier)
        AlembicObject::Init(*o,#Null)
        *node\abc = *o
        *node\lastFile = file
        *node\lastID = identifier
      EndIf
    EndIf
    
    If *o And time <> *node\lastT

      Protected *infos.Alembic::ABC_Polymesh_Topo_Sample_Infos = *o\infos
      
      Alembic::ABC_GetPolymeshTopoSampleDescription(*o\ptr,time,*infos)
    
      
      ; Resize Mesh Datas
      CArray::SetCount(*node\positions,*infos\nbpoints)
      CArray::SetCount(*node\velocities,*infos\nbpoints)
      CArray::SetCount(*node\normals,*infos\nbsamples)
      CArray::SetCount(*node\tangents,*infos\nbsamples)
      CArray::SetCount(*node\uvws,*infos\nbsamples)
      CArray::SetCount(*node\colors,*infos\nbsamples)
      CArray::SetCount(*node\indices,*infos\nbindices)
      CArray::SetCount(*node\facecount,*infos\nbfacecount)

      *node\sample\positions    = *node\positions\data
      *node\sample\velocities   = *node\velocities\data
      *node\sample\normals      = *node\normals\data
      *node\sample\tangents     = *node\tangents\data
      *node\sample\uvs          = *node\uvws\data
      *node\sample\colors       = *node\colors\data
      *node\sample\faceindices  = *node\indices\data
      *node\sample\facecount    = *node\facecount\data
      
      Alembic::ABC_UpdatePolymeshTopoSample(*o\ptr,*infos,*node\sample)
      
      ; Topology
      FirstElement(*node\outputs())
      Protected *topoPort.NodePort::NodePort_t = *node\outputs()
      Protected *topoVal.CArray::CArrayPtr = *topoPort\value
      Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*topoVal,0)
      
      CArray::Copy(*topo\vertices,*node\positions)
      CArray::SetCount(*topo\faces,0)
      Protected i,j
      Protected offset = 0
      For i=0 To CArray::GetCount(*node\facecount)-1
        nbp = CArray::GetValueL(*node\facecount,i)
        For j=0 To nbp-1
          CArray::AppendL(*topo\faces,CArray::GetValueL(*node\indices,offset))
          offset+1
        Next
        
        CArray::AppendL(*topo\faces,-2)
      Next
      
      ; Position
      NextElement(*node\outputs())
      Protected *positionPort.NodePort::NodePort_t = *node\outputs()
      Protected *positionVal.CArray::CArrayV3F32 = *positionPort\value
      CArray::Copy(*positionVal,*node\positions)
      
      ; Velocities
      NextElement(*node\outputs())
      Protected *velocitiesPort.NodePort::NodePort_t = *node\outputs()
      Protected *velocitiesVal.CArray::CArrayV3F32 = *velocitiesPort\value
      CArray::Copy(*velocitiesVal,*node\velocities)
      
      ; Normals
      NextElement(*node\outputs())
      Protected *normalsPort.NodePort::NodePort_t = *node\outputs()
      Protected *normalsVal.CArray::CArrayV3F32 = *normalsPort\value
      CArray::Copy(*normalsVal,*node\normals)
      
      ; Tangents
      NextElement(*node\outputs())
      Protected *tangentsPort.NodePort::NodePort_t = *node\outputs()
      Protected *tangentsVal.CArray::CArrayV3F32 = *tangentsPort\value
      CArray::Copy(*tangentsVal,*node\tangents)
      
      ; UVWs
      NextElement(*node\outputs())
      Protected *uvwsPort.NodePort::NodePort_t = *node\outputs()
      Protected *uvwsVal.CArray::CArrayV3F32 = *uvwsPort\value
      CArray::Copy(*uvwsVal,*node\uvws)
      
      ; Colors
      NextElement(*node\outputs())
      Protected *colorsPort.NodePort::NodePort_t = *node\outputs()
      Protected *colorsVal.CArray::CArrayV3F32 = *colorsPort\value
      CArray::Copy(*colorsVal,*node\colors)
      
      
;       CArray::SetCount(*positions,*infos\nbpoints)
;       *mesh_sample\positions = *positions
;       update.i =  Alembic::ABC_UpdatePolymeshSample(*o\ptr,*infos,*mesh_sample)
      *node\lastT = time
    Else

      
      
;       If *archive : MessageRequester("Open ABC Archive",*archive\path) : EndIf
      
    EndIf
;     

  EndProcedure
  

 Procedure Terminate(*node.AlembicIPolymeshTopoNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AlembicIPolymeshTopoNode_t)
    FreeMemory(*node)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AlembicIPolymeshTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AlembicIPolymeshTopoNode_t = AllocateMemory(SizeOf(AlembicIPolymeshTopoNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AlembicIPolymeshTopoNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(AlembicIPolymeshTopoNode)

  
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 69
; FirstLine = 55
; Folding = --
; EnableXP