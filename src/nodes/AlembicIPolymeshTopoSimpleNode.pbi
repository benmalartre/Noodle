XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../libs/Alembic.pbi"

; ==================================================================================================
; ALEMBICIPOLYMESHTOPO NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AlembicIPolymeshTopoSimpleNode
  Structure AlembicIPolymeshTopoSimpleNode_t Extends Node::Node_t
    *obj.Object3D::Object3D_t
    *abc
    sample.Alembic::ABC_Polymesh_TopoSimple_Sample
    *positions.CArray::CArrayV3F32
    *indices.CArray::CArrayLong
    *facecount.CArray::CArrayLong
    
    lastT.f
    lastID.s
    lastFile.s
  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAlembicIPolymeshTopoSimpleNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AlembicIPolymeshTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AlembicIPolymeshTopoSimpleNode_t)
  Declare Init(*node.AlembicIPolymeshTopoSimpleNode_t)
  Declare Evaluate(*node.AlembicIPolymeshTopoSimpleNode_t)
  Declare Terminate(*node.AlembicIPolymeshTopoSimpleNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AlembicIPolymeshTopoSimpleNode","Alembic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
   DataSection
    Node::DAT(AlembicIPolymeshTopoSimpleNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
; ALEMBICIPOLYMESHTOPO NODE MODULE IMPLEMENTATION
; ============================================================================
Module AlembicIPolymeshTopoSimpleNode
  UseModule Math
  Procedure Init(*node.AlembicIPolymeshTopoSimpleNode_t)

    Node::AddInputPort(*node,"File",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Identifier",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"Topology",Attribute::#ATTR_TYPE_TOPOLOGY)
   
    *node\positions = CArray::newCArrayV3F32()
    *node\indices = CArray::newCArrayLong()
    *node\facecount = CArray::newCArrayLong()
    *node\label = "AlembicIPolymeshTopo"
    *node\lastT = -1
    
  EndProcedure
  
  Procedure Evaluate(*node.AlembicIPolymeshTopoSimpleNode_t)
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
      CArray::SetCount(*node\indices,*infos\nbindices)
      CArray::SetCount(*node\facecount,*infos\nbfacecount)
      
      *node\sample\positions    = *node\positions\data
      *node\sample\faceindices  = *node\indices\data
      *node\sample\facecount    = *node\facecount\data
      
      Alembic::ABC_UpdatePolymeshTopoSimpleSample(*o\ptr,*infos,*node\sample)

      ; Topology
      FirstElement(*node\outputs())
      Protected *topoPort.NodePort::NodePort_t = *node\outputs()
      Protected *topoVal.CArray::CArrayPtr = *topoPort\value
      Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*topoVal,0)
      
      CArray::Copy(*topo\vertices,*node\positions)
      CArray::SetCount(*topo\faces,CArray::GetCount(*node\indices)+CArray::GetCount(*node\facecount))

      Protected offset = 0,offset2
      For i=0 To CArray::GetCount(*node\facecount)-1
        nbp = CArray::GetValueL(*node\facecount,i)
        For j=0 To nbp-1
          ;CArray::AppendL(*topo\faces,CArray::GetValueL(*node\indices,offset))
          CArray::SetValueL(*topo\faces,offset2,CArray::GetValueL(*node\indices,offset))
          offset+1
          offset2+1
        Next
        
        ;CArray::AppendL(*topo\faces,-2)
        CArray::SetValueL(*topo\faces,offset2,-2)
        offset2+1
      Next
      
      
      *node\lastT = time
    Else

      
      
;       If *archive : MessageRequester("Open ABC Archive",*archive\path) : EndIf
      
    EndIf
;     

  EndProcedure
  

 Procedure Terminate(*node.AlembicIPolymeshTopoSimpleNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AlembicIPolymeshTopoSimpleNode_t)
    FreeMemory(*node)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AlembicIPolymeshTopo",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AlembicIPolymeshTopoSimpleNode_t = AllocateMemory(SizeOf(AlembicIPolymeshTopoSimpleNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AlembicIPolymeshTopoSimpleNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(AlembicIPolymeshTopoSimpleNode)

  
EndModule
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 68
; FirstLine = 24
; Folding = --
; EnableThread
; EnableXP