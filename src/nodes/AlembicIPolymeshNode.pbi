XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../libs/Booze.pbi"

; ==================================================================================================
; ADD NODE MODULE DECLARATION
; ==================================================================================================
DeclareModule AlembicIPolymeshNode
  Structure AlembicIPolymeshNode_t Extends Node::Node_t
    *obj.Object3D::Object3D_t
    *abc
    

  EndStructure
  
  ;------------------------------
  ; Interface
  ;------------------------------
  Interface IAlembicIPolymeshNode Extends Node::INode 
  EndInterface
  
  Declare New(*tree.Tree::Tree_t,type.s="AlembicIPolymesh",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
  Declare Delete(*node.AlembicIPolymeshNode_t)
  Declare Init(*node.AlembicIPolymeshNode_t)
  Declare Evaluate(*node.AlembicIPolymeshNode_t)
  Declare Terminate(*node.AlembicIPolymeshNode_t)
  
  ;------------------------------
  ;  ADMINISTRATION
  ;------------------------------
  ;{
  Define *desc.Nodes::NodeDescription_t = Nodes::NewNodeDescription("AlembicIPolymeshNode","Alembic",@New())
  Nodes::AppendDescription(*desc)
  ;}
  
   DataSection
    Node::DAT(AlembicIPolymeshNode)
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
; ALEMBICIPOLYMESH NODE MODULE IMPLEMENTATION
; ============================================================================
Module AlembicIPolymeshNode
  UseModule Math
  Procedure Init(*node.AlembicIPolymeshNode_t)

    Node::AddInputPort(*node,"File",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Identifier",Attribute::#ATTR_TYPE_STRING,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddInputPort(*node,"Time",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_CTXT_SINGLETON,Attribute::#ATTR_STRUCT_SINGLE)
    Node::AddOutputPort(*node,"PointPosition",Attribute::#ATTR_TYPE_VECTOR3)
    
    Node::PortAffectByName(*node, "File", "PointPosition")
    Node::PortAffectByName(*node, "Identifer", "PointPosition")
    Node::PortAffectByName(*node, "Time", "PointPosition")
   
    
    *node\label = "AlembicIPolymesh"
  EndProcedure
  
  Procedure Evaluate(*node.AlembicIPolymeshNode_t)
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
    If Not *o
      If FileSize(file)>0 And GetExtensionPart(file) = "abc"
        Protected manager.Alembic::IArchiveManager = Alembic::abc_manager
        Protected archive.Alembic::IArchive = manager\OpenArchive(file)
        *o = archive\GetObjectByName(identifier)
        AlembicIObject::Init(*o,#Null)
      EndIf
    EndIf
    
    If *o
   

      Protected *infos.Alembic::ABC_Polymesh_Topo_Sample_Infos = *o\infos
      Protected mesh.Alembic::IPolymesh = *o\iObj
      mesh\GetTopoSampleDescription(time,*infos)
     
      
;        
;       *node\sample\positions = *node\positions\data
;       *node\sample\faceindices = *node\indices\data
;       *node\sample\facecount = *node\facecount\data
;       
;       *infos\sampleindex = time
;       
;       Alembic::ABC_UpdatePolymeshTopoSimpleSample(*o\ptr,*infos,*node\sample)
;       
;       Protected *output.NodePort::NodePort_t = *node\outputs()
;       Protected *oVal.CArray::CArrayPtr = *output\value
;       Protected *topo.Geometry::Topology_t = CArray::GetValuePtr(*oVal,0)
;       
;       CArray::Copy(*topo\vertices,*node\positions)
;       CArray::SetCount(*topo\faces,0)
;       Protected i,j,nbp
;       Protected offset = 0
;       For i=0 To CArray::GetCount(*node\facecount)-1
;         nbp = CArray::GetValueL(*node\facecount,i)
;         For j=0 To nbp-1
;           CArray::AppendL(*topo\faces,CArray::GetValueL(*node\indices,offset))
;           offset+1
;         Next
;         
;         CArray::AppendL(*topo\faces,-2)
;       Next

      
      
;       CArray::SetCount(*positions,*infos\nbpoints)
;       *mesh_sample\positions = *positions
;       update.i =  Alembic::ABC_UpdatePolymeshSample(*o\ptr,*infos,*mesh_sample)
    Else

      
      
;       If *archive : MessageRequester("Open ABC Archive",*archive\path) : EndIf
      
    EndIf
;     

  EndProcedure
  

  Procedure Terminate(*node.AlembicIPolymeshNode_t)
  
  EndProcedure
  
  Procedure Delete(*node.AlembicIPolymeshNode_t)
    FreeMemory(*node)
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Heap & stack]-----------------------------------------------------------------
  Procedure.i New(*tree.Tree::Tree_t,type.s="AlembicIPolymesh",x.i=0,y.i=0,w.i=100,h.i=50,c.i=0)
    
    ; ---[ Allocate Node Memory ]---------------------------------------------
    Protected *Me.AlembicIPolymeshNode_t = AllocateMemory(SizeOf(AlembicIPolymeshNode_t))
    
    ; ---[ Init Node]----------------------------------------------
    Node::INI(AlembicIPolymeshNode,*tree,type,x,y,w,h,c)
    
    ; ---[ Return Node ]--------------------------------------------------------
    ProcedureReturn( *Me)
    
  EndProcedure
  
   Class::DEF(AlembicIPolymeshNode)


;   
;   
;   Procedure New(*obj.Object3D::Object3D_t,*abc)
;     Protected *node.AlembicNode_t = AllocateMemory(SizeOf(AlembicNode_t))
;     InitializeStructure(*node,AlembicNode_t)
;     *node\obj = *obj
;     *node\abc = *abc
;     ProcedureReturn *node
;   EndProcedure
;   
;   Procedure Delete(*node.AlembicNode_t)
;     ClearStructure(*node,AlembicNode_t)
;     FreeMemory(*node)
;   EndProcedure
;   
;   Procedure Update(*node.AlembicNode_t)
;     Debug "(((((((((((((((((((((((((( Node Update Called ))))))))))))))))))))))))))))))))))))))))))"
;     Alembic::UpdateSample(*node\abc,Time::current_frame)
;   EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 149
; FirstLine = 133
; Folding = --
; EnableXP