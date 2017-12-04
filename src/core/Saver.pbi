; ============================================================================
;  SAVER MODULE DECLARATION
; ============================================================================
XIncludeFile "../graph/Node.pbi"
DeclareModule Saver
  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  
  Global Dim extensions.s(3)
  extensions(0) = "compound"     ; Compound
  extensions(1) = "scene"     ; Scene
  extensions(2) = "model"     ; Model
  
  Enumeration 
    #SAVE_COMPOUND
    #SAVE_SCENE
    #SAVE_MODEL
  EndEnumeration
  
  ;}
  
  
  ; ----------------------------------------------------------------------------
  ;  Structure
  ; ----------------------------------------------------------------------------

  Structure Saver_t Extends Object::Object_t
    *obj.Object::Object_t
    path.s
    file.i
    type.i
    xml.i               ; XML Object
    current.i           ; Current XML Node
    root.i              ; XML Root Node
    
    compounds_counter.i
    numSaved3DObject.i
    
    Map *m_nodes.Node::Node_t()
    Map *m_compounds.CompoundNode::CompoundNode_t()
  EndStructure
  
  Declare New(*obj.Object::Object_t,path.s)
  Declare Delete(*saver.Saver_t)
  Declare Save(*saver.Saver_t)
  
  Global CLASS.Class::Class_t
 
EndDeclareModule

; ============================================================================
;  SAVER MODULE IMPLEMENTATION
; ============================================================================

Module Saver
UseModule Math
  ;------------------------------------------------------------------
  ; Save Tree
  ;------------------------------------------------------------------
  
  ;------------------------------------------------------------------
  ; Set Path
  ;------------------------------------------------------------------
  Procedure SetPath(*saver.Saver_t,folder.S,name.s)
    Select *saver\obj\class\name
      
      Case "Compound"
          *saver\path = folder+SLASH+name+"."+extensions(0)
      Case "Scene"
         *saver\path = folder+SLASH+name+"."+extensions(1)
      Case "Model"
        *saver\path = folder+SLASH+name+"."+extensions(2)
                        
      
        
    EndSelect
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Node Ports
  ;----------------------------------------------------------------------------
  Procedure SavePorts(*saver.Saver_t,parentnode.i,*node.Node::Node_t)
    Protected *attr.NodePort::NodePort_t
    Protected attr.i
    ForEach *node\inputs()
      *attr = *node\inputs()
      attr = CreateXMLNode(parentnode,"input_port")
      SetXMLAttribute(attr,"Name",*attr\name)
      SetXMLAttribute(attr,"Type",Str(*attr\currenttype))
      Select *attr\currenttype
        Case Attribute::#ATTR_TYPE_BOOL
          SetXMLAttribute(attr,"Value",Str(CArray::GetValueB(*attr\value,0)))
        Case Attribute::#ATTR_TYPE_INTEGER
          SetXMLAttribute(attr,"Value",Str(CArray::GetValueI(*attr\value,0)))
        Case Attribute::#ATTR_TYPE_FLOAT
          SetXMLAttribute(attr,"Value",StrF(CArray::GetValueF(*attr\value,0)))
        Case Attribute::#ATTR_TYPE_VECTOR2
          Protected *v2.v2f32 = CArray::GetValue(*attr\value,0)
          SetXMLAttribute(attr,"Value","["+StrF(*v2\x)+","+StrF(*v2\y)+"]")
        Case Attribute::#ATTR_TYPE_VECTOR3
          Protected *v3.v3f32 = CArray::GetValue(*attr\value,0)
          SetXMLAttribute(attr,"Value","["+StrF(*v3\x)+","+StrF(*v3\y)+","+StrF(*v3\z)+"]")
        Case Attribute::#ATTR_TYPE_Quaternion
          Protected *q4.q4f32 = CArray::GetValue(*attr\value,0)
          SetXMLAttribute(attr,"Value","["+StrF(*q4\x)+","+StrF(*q4\y)+","+StrF(*q4\z)+","+StrF(*q4\w)+"]")
          Case Attribute::#ATTR_TYPE_COLOR
          Protected *c4.c4f32 = CArray::GetValue(*attr\value,0)
          SetXMLAttribute(attr,"Value","["+StrF(*c4\r)+","+StrF(*c4\g)+","+StrF(*c4\b)+","+StrF(*c4\a)+"]")
      EndSelect
      
;       SetXMLAttribute(attr,"Context",Str(*attr\currentcontext))
;       SetXMLAttribute(attr,"Structure",Str(*attr\currentstructure))
;       SetXMLAttribute(attr,"Constant",Str(*attr\constant))
      
      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
    ForEach *node\outputs()
      *attr = *node\outputs()
      attr = CreateXMLNode(parentnode,"output_port")
      SetXMLAttribute(attr,"Name",*attr\name)
      SetXMLAttribute(attr,"Type",Str(*attr\currenttype))

      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Exposed Node Ports
  ;----------------------------------------------------------------------------
  Procedure SaveExposedPorts(*saver.Saver_t,parentnode.i,*compound.CompoundNode::CompoundNode_t)
    Protected *attr.CompoundNodePort::CompoundNodePort_t
    Protected attr.i
    ForEach *compound\exposed_inputs()
      *attr = *compound\exposed_inputs()
      attr = CreateXMLNode(parentnode,"exposed_port")
      SetXMLAttribute(attr,"Name",*attr\name)

      
      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
    ForEach *compound\exposed_outputs()
      *attr = *compound\exposed_outputs()
      attr = CreateXMLNode(parentnode,*attr\name)
      
      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Get Node ID
  ;----------------------------------------------------------------------------
  Procedure.s GetNodeID(*saver.Saver_t,*node.Node::Node_t)
    Protected ID.s = "-1"
    ForEach *saver\m_nodes()
      If *saver\m_nodes() = *node
          ID = MapKey(*saver\m_nodes())
        Break
      EndIf
    Next
    
    ProcedureReturn ID
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Save Node Ports
  ;----------------------------------------------------------------------------
  Procedure SaveConnexions(*saver.Saver_t,parentnode.i,*node.Node::Node_t)
    Protected *cnx.Connexion::Connexion_t
    Protected cnx
    Protected *start.Node::Node_t
    Protected *end.Node::Node_t
    
    ForEach *node\connexions()
      *cnx = *node\connexions()
      cnx = CreateXMLNode(parentnode,"Connexion")
      *start = *cnx\start\node
      *end = *cnx\end\node
      SetXMLAttribute(cnx,"From_Name",*start\name)
      SetXMLAttribute(cnx,"From_Node",GetNodeID(*saver,*start))
      SetXMLAttribute(cnx,"From_Port",*cnx\start\name)
      SetXMLAttribute(cnx,"To_Name",*end\name)
      SetXMLAttribute(cnx,"To_Node",GetNodeID(*saver,*end))
      SetXMLAttribute(cnx,"To_Port",*cnx\end\name)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Check Node
  ;----------------------------------------------------------------------------
  Procedure CheckNode(*saver.Saver_t,*node.Node::Node_t,ID.i)
    AddMapElement(*saver\m_nodes(),Str(ID))
    *saver\m_nodes() = *node
    
    If *node\class\name = "CompoundNode"
      Protected name.s = "[Embedded"+Str(*saver\compounds_counter)+"]"
      AddMapElement(*saver\m_compounds(),name)
      *saver\m_compounds() = *node
      
      *saver\compounds_counter + 1
      
      ForEach *node\nodes()
        CheckNode(*saver,*node\nodes(),ID)
        ID+1
      Next
      
    EndIf
    
    
    
  EndProcedure
  

  
  ;----------------------------------------------------------------------------
  ; Save Node
  ;----------------------------------------------------------------------------
  Procedure SaveNode(*saver.Saver_t,parentnode.i,*node.Node::Node_t,ID.i)
    
    Protected node = CreateXMLNode(parentnode,"node")

    If *node\class\name = "CompoundNode"
      
      Protected name.s = "Embedded"+Str(*saver\compounds_counter)
      SetXMLAttribute(node,"Type","["+name+"]")
      SetXMLAttribute(node,"ID",Str(ID))
      
      attr = CreateXMLNode(node,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*node\posx))
      SetXMLAttribute(attr,"PosY",Str(*node\posy))
      *saver\compounds_counter + 1
    Else
      
      SetXMLAttribute(node,"Type",*node\type)
      SetXMLAttribute(node,"ID",Str(ID))
      
      attr = CreateXMLNode(node,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*node\posx))
      SetXMLAttribute(attr,"PosY",Str(*node\posy))
      
      SavePorts(*saver,node,*node)
  
      ForEach *node\nodes()
        SaveNode(*saver,node,*node\nodes(),ID)
        
      Next
      
      SaveConnexions(*saver,parentnode,*node)
    EndIf 
  
    
    
;     SaveConnexions(*saver,node,*node)

    
    
      
  EndProcedure
  
    ;----------------------------------------------------------------------------
  ; Save Compound Nodes
  ;----------------------------------------------------------------------------
  Procedure SaveCompounds(*saver.Saver_t,parentnode.i)
    Protected ID.i=0
    
    Protected x
    ForEach(*saver\m_compounds())
      Protected name.s = "Embedded"+Str(x)
      x+1
      compound = CreateXMLNode(parentnode,"compound_node")
      SetXMLAttribute(compound,"Name",name)
      SetXMLAttribute(compound,"Type","CompoundNode")
      
      attr = CreateXMLNode(compound,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*saver\m_compounds()\posx))
      SetXMLAttribute(attr,"PosY",Str(*saver\m_compounds()\posy))
      
      SavePorts(*saver,compound,*saver\m_compounds())
      
      ForEach *saver\m_compounds()\nodes()
        
        SaveNode(*saver,compound,*saver\m_compounds()\nodes(),ID)
        ID+1
      Next
      SaveConnexions(*saver,compound,*saver\m_compounds())
      SaveExposedPorts(*saver,compound,*saver\m_compounds())
      
    Next
    
  EndProcedure
  
  
   ;----------------------------------------------------------------------------
  ; Save Tree
  ;----------------------------------------------------------------------------
  Procedure SaveTree(*saver.Saver_t,parentnode.i,*tree.Tree::Tree_t)
    
    ClearMap(*saver\m_nodes())
    ClearMap(*saver\m_compounds())
;     ClearMap(*saver\m_embeddeds())
    Protected op = CreateXMLNode(parentnode,"Tree")
    SetXMLAttribute(op,"Name",*tree\name)
    SetXMLAttribute(op,"Type","Tree")
    
    Protected ID.i
    AddMapElement(*saver\m_nodes(),Str(0))
    *saver\m_nodes() = *tree\root
    ID +1
    
    
    ForEach *tree\root\nodes()
      CheckNode(*saver,*tree\root\nodes(),ID)
      ID+1
    Next
    
    *saver\compounds_counter = 0
;     AddMapElement(*saver\m_nodes(),Str(ID))
;     *saver\m_nodes() = *tree\root
    SaveNode(*saver,op,*tree\root,0)
    SaveCompounds(*saver,op)
    
      
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Save Stack
  ;----------------------------------------------------------------------------
  Procedure SaveStack(*saver.Saver_t,node.i,*item.Object3D::Object3D_t)
    Debug "---------------------------------- SAVE STACK ---------------------------------"
    Debug "3DObject ---> "+*item\fullname
    Protected op
    Protected stack = CreateXMLNode(node,"Stack")
    Protected *stack.Stack::Stack_t = *item\stack 
    ForEach *stack\levels()
      Select *stack\levels()\class\name
        Case "Tree"
          Debug "Save Tree"
          Protected *t.Stack::StackLevel_t = *stack\levels()
;           op = CreateXMLNode(stack,*gt\name)
          SaveTree(*saver,stack,*t)
  
      EndSelect
    Next
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Attributes
  ;----------------------------------------------------------------------------
  Procedure SaveAttributes(*saver.Saver_t,node.i,*item.Object3D::Object3D_t)
    Protected a
    Protected *a.Attribute::Attribute_t
    Protected attrs = CreateXMLNode(node,"Attributes")
    ForEach *item\m_attributes()
      *a = *item\m_attributes()
      Protected attr = CreateXMLNode(attrs,*a\name)
      
      SetXMLAttribute(attr,"Type",Str(*a\datatype))
      SetXMLAttribute(attr,"Context",Str(*a\datacontext))
      SetXMLAttribute(attr,"Structure",Str(*a\datastructure))
      SetXMLAttribute(attr,"Constant",Str(*a\constant))
      SetXMLAttribute(attr,"Size",Str(Attribute::GetSize(*a)))
  ;     SetXMLNodeText(attr, OGraphAttribute_GetAsString(*a))
      SetXMLNodeText(attr, Attribute::GetAsBase64(*a))
  
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Transform
  ;----------------------------------------------------------------------------
  Procedure SaveTransform(node.i,*obj.Object3D::Object3D_t)
    Protected kine = CreateXMLNode(node,"Kinematics")
    Protected *t.Transform::Transform_t = *obj\localT
    Protected *m.Math::m4f32 = *t\m
    Protected size_t = SizeOf(Math::m4f32)
    Protected *mem = AllocateMemory(size_t*1.5)
    Protected local = CreateXMLNode(kine,"transform")
    SetXMLAttribute(local,"Name","Local Transform")
    Protected value.s = Matrix4::AsString(*m)
    SetXMLAttribute(local,"Value", value)
    ;Base64Encoder(*m,size_t,*mem,size_t*1.5)
    ;SetXMLAttribute(local,"Value",PeekS(*mem,size_t*1.5))
    
;     *t = *obj\globalT
;     *m = *t\m
;     Protected glob = CreateXMLNode(kine,"transform")
;     SetXMLAttribute(glob,"Name","Global Transform")
;     Base64Encoder(*m,size_t,*mem,size_t*1.5)
;     SetXMLAttribute(glob,"Value",PeekS(*mem,size_t*1.5))
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save 3D Object
  ;----------------------------------------------------------------------------
  Procedure Save3DObject(*saver.Saver_t,parent.i,*item.Object3D::Object3D_t)
    Protected object = CreateXMLNode(parent,*item\name,-1)
    Select *item\type
      Case Object3D::#Object3D_Camera
        SetXMLAttribute(object,"Type","Camera")
      Case Object3D::#Object3D_Light
        SetXMLAttribute(object,"Type","Light")
      Case Object3D::#Object3D_Null
        SetXMLAttribute(object,"Type","Null")
      Case Object3D::#Object3D_Polymesh
        SetXMLAttribute(object,"Type","Polymesh")
      Case Object3D::#Object3D_Curve
        SetXMLAttribute(object,"Type","Curve")
      Case Object3D::#Object3D_PointCloud
        SetXMLAttribute(object,"Type","PointCloud")
      Case Object3D::#Object3D_InstanceCloud
        SetXMLAttribute(object,"Type","InstanceCloud")
      Case Object3D::#Object3D_Grid
        SetXMLAttribute(object,"Type","Grid")
      Case Object3D::#Object3D_Model
        SetXMLAttribute(object,"Type","Model")
      Case Object3D::#Object3D_Root
        SetXMLAttribute(object,"Type","Root")
      Case Object3D::#Object3D_Layer
        SetXMLAttribute(object,"Type","Layer")
    EndSelect
    
    
    Select *item\type
      Case Object3D::#Object3D_Camera
      Case Object3D::#Object3D_Curve
      Case Object3D::#Object3D_Grid
      Case Object3D::#Object3D_Layer
      Case Object3D::#Object3D_Light
      Case Object3D::#Object3D_Model
      Case Object3D::#Object3D_Null
      Case Object3D::#Object3D_PointCloud
        Protected *cloud.PointCloud::PointCloud_t = *item
        Protected *geo.Geometry::PointCloudGeometry_t = *cloud\geom
        Protected geometrynode = CreateXMLNode(object,"Geometry")
        
        ; Geometry definition
        SetXMLAttribute(geometrynode,"NbPoints",Str(CArray::GetCount(*geo\a_positions)))
  
        
      Case Object3D::#Object3D_Polymesh
        Protected *mesh.Polymesh::Polymesh_t = *item
        Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
        Protected geom = CreateXMLNode(object,"Geometry")
        
        ; Geometry definition
        SetXMLAttribute(geom,"NbVertices",Str(CArray::GetCount(*geom\topo\vertices)))
        SetXMLAttribute(geom,"NbIndices",Str(CArray::GetCount(*geom\topo\faces)))
        
        Protected datas.s
        ; Vertices
        Protected size_t = CArray::GetCount(*geom\topo\vertices) * CArray::GetItemSize(*geom\topo\vertices)
        ;Protected *mem = AllocateMemory(size_t*1.5)
        ;Protected Base64Encoder(CArray::GetPtr(*geom\topo\vertices,0),size_t,*mem,size_t*1.5)
        ;SetXMLAttribute(geom,"Vertices",PeekS(*mem,size_t*1.5))
        datas = Base64Encoder(CArray::GetPtr(*geom\topo\vertices,0),size_t)
        SetXMLAttribute(geom,"Vertices",datas)
        
        ; Indices
        size_t = CArray::GetCount(*geom\topo\faces)* CArray::GetItemSize(*geom\topo\faces)
        ;*mem = ReAllocateMemory(*mem,size_t*1.5)
        ;Base64Encoder(CArray::GetPtr(*geom\topo\faces,0),size_t,*mem,size_t*1.5)
        ;SetXMLAttribute(geom,"Indices",PeekS(*mem,size_t*1.5))
        datas = Base64Encoder(CArray::GetPtr(*geom\topo\faces,0),size_t)
        SetXMLAttribute(geom,"Indices",datas)
        
        FreeMemory(*mem)
    EndSelect
    
    SaveTransform(object,*item)
    
;     If MapSize(*item\m_attributes())
;       SaveAttributes(*saver,object,*item)
;     EndIf
    
    SaveStack(*saver,object,*item)
    *saver\numSaved3DObject +1
    
    ; Recursive Save
    ;-------------------------------------------------------------
    If ListSize(*item\children())
      Protected c
      ForEach *item\children()
        Save3DObject(*saver,object,*item\children())
      Next
    EndIf
    
    
  EndProcedure
    
  
  ;------------------------------------------------------------------
  ; Save
  ;------------------------------------------------------------------
  Procedure Save(*saver.Saver_t)
    Protected *obj.Object::Object_t = *saver\obj
  
    Select *obj\class\name
      Case "Scene"
        
        Protected *scene.Scene::Scene_t = *obj
        
        *saver\root = CreateXMLNode(RootXMLNode(*saver\xml),*scene\filename)
        Protected *objs.CArray::CArrayPtr = *scene\objects
        Protected *o.Object3D::Object3D_t
        Protected i
        For i =0 To CArray::GetCount(*scene\objects)-1
          *o = CArray::GetValuePtr(*scene\objects,i)
          Save3DObject(*saver,*saver\root,*o)
        Next
        MessageRequester("SAVER", "NUM SAVED 3D OBJECTS : "+Str(*saver\numSaved3DObject))
        FormatXML(*saver\xml,#PB_XML_LinuxNewline|#PB_XML_ReFormat|#PB_XML_ReIndent)
        ;Save the xml tree into a xml file
        ;MessageRequester("Save XML ",*saver\path)
        SaveXML(*saver\xml, *saver\path)
        
;         Protected s.s = ComposeXML(*saver\xml)
;         MessageRequester("Save Tree",s)
  
      Default
        MessageRequester("Raabit","Save File Failed..."+*obj\class\name)
    EndSelect
    
  EndProcedure
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Saver_t)
    ClearStructure(*Me,Saver_t)
    FreeXML(*Me\xml)
    FreeMemory(*Me)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*obj.Object::Object_t,path.s)
    Protected *saver.Saver_t = AllocateMemory(SizeOf(Saver_t))
    InitializeStructure(*saver,Saver_t)
    *saver\obj = *obj
    *saver\numSaved3DObject = 0
    If Not path = ""
      *saver\path = path
    Else
      Protected defaultFile$ = GetCurrentDirectory()+"scene.raaScene"
      Protected pattern$ = "Raabit Scene File | *.raaScene"
      *saver\path = SaveFileRequester("Raabit Saver",defaultFile$,pattern$,0)
    EndIf
    If *saver\path
      *saver\xml = CreateXML(#PB_Any,#PB_UTF8)
      ProcedureReturn *saver
    Else
      Delete(*saver)
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
  
  
  Class::DEF(Saver)
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 470
; FirstLine = 466
; Folding = ----
; EnableXP
; EnableUnicode