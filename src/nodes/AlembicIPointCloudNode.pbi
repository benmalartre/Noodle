XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../libs/Booze.pbi"

; ==================================================================================================
; ALEMBICIPOINTS NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AlembicIPointCloudNode
  Structure AlembicIPointCloudNode_t Extends Node::Node_t
    *obj.Object3D::Object3D_t
    *abc
    sample.Alembic::ABC_PointCloud_Sample
    
    lastT.f
    lastID.s
    lastFile.s
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAlembicIPointCloudNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AlembicIPoints",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AlembicIPointCloudNode_t)
  Declare Init(*node.AlembicIPointCloudNode_t)
  Declare Evaluate(*node.AlembicIPointCloudNode_t)
  Declare Terminate(*node.AlembicIPointCloudNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AlembicIPointCloudNode","Alembic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
   DataSection
    Node::DAT(AlembicIPointCloudNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
; ALEMBICIPOLYMESHTOPO NODE MODULE IMPLEMENTATION
; ============================================================================
Module AlembicIPointCloudNode
  UseModule Math
  Procedure PortAffects(*node.AlembicIPointCloudNode_t)
    ForEach(*node\outputs())
      Node::PortAffectByName(*node, "File", *node\outputs()\name)
      Node::PortAffectByName(*node, "Identifier", *node\outputs()\name)
      Node::PortAffectByName(*node, "Time", *node\outputs()\name)
    Next
  EndProcedure
  
  
  Procedure Init(*node.AlembicIPointCloudNode_t)

    Node::AddInputPort(*node,"File",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Identifier",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Position",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Velocity",Attribute::#ATTR_TYPE_VECTOR3)
;     Node::AddOutputPort(*node,"ID",Attribute::#ATTR_TYPE_LONG)
    Node::AddOutputPort(*node,"Size",Attribute::#ATTR_TYPE_FLOAT)
    Node::AddOutputPort(*node,"Orientation",Attribute::#ATTR_TYPE_QUATERNION)
    Node::AddOutputPort(*node,"Scale",Attribute::#ATTR_TYPE_VECTOR3)
    Node::AddOutputPort(*node,"Color",Attribute::#ATTR_TYPE_COLOR)
    
    PortAffects(*node)


    *node\label = "AlembicIPointCloud"
    *node\lastT = -1
    
  EndProcedure
  
  Procedure Evaluate(*node.AlembicIPointCloudNode_t)
    
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
   
    
    Protected *o.AlembicIObject::AlembicIObject_t = *node\abc
    
    ; Initialize Alembic Object
    ;---------------------------------------------------
    If Not *o Or Not *node\lastFile = file Or Not *node\lastID = identifier
      
      If FileSize(file)>0 And GetExtensionPart(file) = "abc"
        Protected manager.Alembic::IArchiveManager = Alembic::abc_manager
        Protected archive.Alembic::IArchive = manager\OpenArchive(file)
        *o = archive\GetObjectByName(identifier)
        AlembicIObject::Init(*o,#Null)
        AlembicIObject::GetProperties(*o)
        *node\abc = *o
        *node\lastFile = file
        *node\lastID = identifier
      EndIf
    EndIf
    
    If *o And time <> *node\lastT

      Protected *sample.Alembic::ABC_PointCloud_Sample = *o\sample
    
      Protected *infos.Alembic::ABC_PointCloud_Sample_Infos = *o\infos
      Protected points.Alembic::IPoints = *o\iObj
      points\GetSampleDescription(time,*infos)
      
      
;       CArray::SetCount(*cloud_geom\a_positions,*infos\nbpoints)
;       CArray::SetCount(*cloud_geom\a_color,*infos\nbpoints)
;       CArray::SetCount(*cloud_geom\a_indices,*infos\nbpoints)
      
      FirstElement(*node\outputs())
      Protected *positions.CArray::CArrayV3F32 = *node\outputs()\value
      CArray::SetCount(*positions,*infos\nbpoints)
      *sample\position = *positions\data
      
      NextElement(*node\outputs())
      Protected *velocities.CArray::CArrayV3F32 = *node\outputs()\value
      CArray::SetCount(*velocities,*infos\nbpoints)
      *sample\velocity = *velocities\data
      
      NextElement(*node\outputs())
      Protected *size.CArray::CArrayFloat = *node\outputs()\value
      CArray::SetCount(*size,*infos\nbpoints)
      *sample\size = *size\data
      
      NextElement(*node\outputs())
      Protected *orientation.CArray::CArrayQ4F32 = *node\outputs()\value
      CArray::SetCount(*orientation,*infos\nbpoints)
      *sample\orientation = *orientation\data
      
      NextElement(*node\outputs())
      Protected *scale.CArray::CArrayV3F32 = *node\outputs()\value
      CArray::SetCount(*scale,*infos\nbpoints)
      *sample\scale = *scale\data
      
      NextElement(*node\outputs())
      Protected *color.CArray::CArrayC4F32 = *node\outputs()\value
      CArray::SetCount(*color,*infos\nbpoints)
      *sample\color = *color\data
      
      update.i =  points\UpdateSample(*infos,*sample)
      
      AlembicIObject::UpdateProperties(*o,time/30)
      AlembicIObject::ApplyProperty2(*o,"Scale",*scale)
      AlembicIObject::ApplyProperty2(*o,"Orientation",*orientation)
      AlembicIObject::ApplyProperty2(*o,"Color",*color)
      
      *node\lastT = time
    Else

      
      
;       If *archive : MessageRequester("Open ABC Archive",*archive\path) : EndIf
      
    EndIf
;     

  EndProcedure
  
  Procedure Terminate(*node.AlembicIPointCloudNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AlembicIPointCloudNode_t)
    FreeMemory(*node)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AlembicIPoints",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AlembicIPointCloudNode_t = AllocateMemory(SizeOf(AlembicIPointCloudNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AlembicIPointCloudNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(AlembicIPointCloudNode)

  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 29
; FirstLine = 9
; Folding = --
; EnableXP