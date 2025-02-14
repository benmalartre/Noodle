﻿; ============================================================================
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
  
  DataSection
    SaverVT:  
  EndDataSection
  
  
  Declare New(*obj.Object::Object_t,path.s)
  Declare Delete(*Me.Saver_t)
  Declare Save(*Me.Saver_t)
  
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
  Procedure SetPath(*Me.Saver_t,folder.S,name.s)
    Select *Me\obj\class\name
      
      Case "Compound"
          *Me\path = folder+SLASH+name+"."+extensions(0)
      Case "Scene"
         *Me\path = folder+SLASH+name+"."+extensions(1)
      Case "Model"
        *Me\path = folder+SLASH+name+"."+extensions(2)
                        
      
        
    EndSelect
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Node Ports
  ;----------------------------------------------------------------------------
  Procedure SavePorts(*Me.Saver_t,parentnode.i,*node.Node::Node_t)
    Protected *port.NodePort::NodePort_t
    Protected attr.i
    ForEach *node\inputs()
      *port = *node\inputs()
      attr = CreateXMLNode(parentnode,"input_port")
      SetXMLAttribute(attr,"Name",*port\name)
      SetXMLAttribute(attr,"Type",Str(*port\currenttype))
      Protected *array.CArray::CArrayT = NodePort::AcquireInputData(*port)
      Select *port\currenttype
        Case Attribute::#ATTR_TYPE_BOOL
          SetXMLAttribute(attr,"Value",Str(CArray::GetValueB(*array, 0)))
        Case Attribute::#ATTR_TYPE_INTEGER
          SetXMLAttribute(attr,"Value",Str(CArray::GetValueI(*array,0)))
        Case Attribute::#ATTR_TYPE_FLOAT
          SetXMLAttribute(attr,"Value",StrF(CArray::GetValueF(*array,0)))
        Case Attribute::#ATTR_TYPE_VECTOR2
          Protected *v2.v2f32 = CArray::GetValue(*array,0)
          SetXMLAttribute(attr,"Value","["+StrF(*v2\x)+","+StrF(*v2\y)+"]")
        Case Attribute::#ATTR_TYPE_VECTOR3
          Protected *v3.v3f32 = CArray::GetValue(*array,0)
          SetXMLAttribute(attr,"Value","["+StrF(*v3\x)+","+StrF(*v3\y)+","+StrF(*v3\z)+"]")
        Case Attribute::#ATTR_TYPE_Quaternion
          Protected *q4.q4f32 = CArray::GetValue(*array,0)
          SetXMLAttribute(attr,"Value","["+StrF(*q4\x)+","+StrF(*q4\y)+","+StrF(*q4\z)+","+StrF(*q4\w)+"]")
          Case Attribute::#ATTR_TYPE_COLOR
          Protected *c4.c4f32 = CArray::GetValue(*array,0)
          SetXMLAttribute(attr,"Value","["+StrF(*c4\r)+","+StrF(*c4\g)+","+StrF(*c4\b)+","+StrF(*c4\a)+"]")
      EndSelect
      
;       SetXMLAttribute(attr,"Context",Str(*attr\currentcontext))
;       SetXMLAttribute(attr,"Structure",Str(*attr\currentstructure))
;       SetXMLAttribute(attr,"Constant",Str(*attr\constant))
      
      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
    ForEach *node\outputs()
      *port = *node\outputs()
      attr = CreateXMLNode(parentnode,"output_port")
      SetXMLAttribute(attr,"Name",*port\name)
      SetXMLAttribute(attr,"Type",Str(*port\currenttype))

      ;SetXMLAttribute(attr,"Size",Str(OGraphNodePort_GetDataSize()))
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Exposed Node Ports
  ;----------------------------------------------------------------------------
  Procedure SaveExposedPorts(*Me.Saver_t,parentnode.i,*compound.CompoundNode::CompoundNode_t)
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
  Procedure.s GetNodeID(*Me.Saver_t,*node.Node::Node_t)
    Protected ID.s = "-1"
    ForEach *Me\m_nodes()
      If *Me\m_nodes() = *node
          ID = MapKey(*Me\m_nodes())
        Break
      EndIf
    Next
    
    ProcedureReturn ID
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Save Node Ports
  ;----------------------------------------------------------------------------
  Procedure SaveConnexions(*Me.Saver_t,parentnode.i,*node.Node::Node_t)
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
      SetXMLAttribute(cnx,"From_Node",GetNodeID(*Me,*start))
      SetXMLAttribute(cnx,"From_Port",*cnx\start\name)
      SetXMLAttribute(cnx,"To_Name",*end\name)
      SetXMLAttribute(cnx,"To_Node",GetNodeID(*Me,*end))
      SetXMLAttribute(cnx,"To_Port",*cnx\end\name)
    Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Check Node
  ;----------------------------------------------------------------------------
  Procedure CheckNode(*Me.Saver_t,*node.Node::Node_t,ID.i)
    AddMapElement(*Me\m_nodes(),Str(ID))
    *Me\m_nodes() = *node
    
    If *node\class\name = "CompoundNode"
      Protected name.s = "[Embedded"+Str(*Me\compounds_counter)+"]"
      AddMapElement(*Me\m_compounds(),name)
      *Me\m_compounds() = *node
      
      *Me\compounds_counter + 1
      
      ForEach *node\nodes()
        CheckNode(*Me,*node\nodes(),ID)
        ID+1
      Next
      
    EndIf
    
    
    
  EndProcedure
  

  
  ;----------------------------------------------------------------------------
  ; Save Node
  ;----------------------------------------------------------------------------
  Procedure SaveNode(*Me.Saver_t,parentnode.i,*node.Node::Node_t,ID.i)
    
    Protected node = CreateXMLNode(parentnode,"node")

    If *node\class\name = "CompoundNode"
      
      Protected name.s = "Embedded"+Str(*Me\compounds_counter)
      SetXMLAttribute(node,"Type","["+name+"]")
      SetXMLAttribute(node,"ID",Str(ID))
      
      attr = CreateXMLNode(node,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*node\posx))
      SetXMLAttribute(attr,"PosY",Str(*node\posy))
      *Me\compounds_counter + 1
    Else
      
      SetXMLAttribute(node,"Type",*node\type)
      SetXMLAttribute(node,"ID",Str(ID))
      
      attr = CreateXMLNode(node,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*node\posx))
      SetXMLAttribute(attr,"PosY",Str(*node\posy))
      
      SavePorts(*Me,node,*node)
  
      ForEach *node\nodes()
        SaveNode(*Me,node,*node\nodes(),ID)
        
      Next
      
      SaveConnexions(*Me,parentnode,*node)
    EndIf 
  
    
    
;     SaveConnexions(*Me,node,*node)

    
    
      
  EndProcedure
  
    ;----------------------------------------------------------------------------
  ; Save Compound Nodes
  ;----------------------------------------------------------------------------
  Procedure SaveCompounds(*Me.Saver_t,parentnode.i)
    Protected ID.i=0
    
    Protected x
    ForEach(*Me\m_compounds())
      Protected name.s = "Embedded"+Str(x)
      x+1
      compound = CreateXMLNode(parentnode,"compound_node")
      SetXMLAttribute(compound,"Name",name)
      SetXMLAttribute(compound,"Type","CompoundNode")
      
      attr = CreateXMLNode(compound,"UI")
      
      SetXMLAttribute(attr,"PosX",Str(*Me\m_compounds()\posx))
      SetXMLAttribute(attr,"PosY",Str(*Me\m_compounds()\posy))
      
      SavePorts(*Me,compound,*Me\m_compounds())
      
      ForEach *Me\m_compounds()\nodes()
        
        SaveNode(*Me,compound,*Me\m_compounds()\nodes(),ID)
        ID+1
      Next
      SaveConnexions(*Me,compound,*Me\m_compounds())
      SaveExposedPorts(*Me,compound,*Me\m_compounds())
      
    Next
    
  EndProcedure
  
  
   ;----------------------------------------------------------------------------
  ; Save Tree
  ;----------------------------------------------------------------------------
  Procedure SaveTree(*Me.Saver_t,parentnode.i,*tree.Tree::Tree_t)
    
    ClearMap(*Me\m_nodes())
    ClearMap(*Me\m_compounds())
;     ClearMap(*Me\m_embeddeds())
    Protected op = CreateXMLNode(parentnode,"Tree")
    SetXMLAttribute(op,"Name",*tree\name)
    SetXMLAttribute(op,"Type","Tree")
    
    Protected ID.i
    AddMapElement(*Me\m_nodes(),Str(0))
    *Me\m_nodes() = *tree\root
    ID +1
    
    
    ForEach *tree\root\nodes()
      CheckNode(*Me,*tree\root\nodes(),ID)
      ID+1
    Next
    
    *Me\compounds_counter = 0
;     AddMapElement(*Me\m_nodes(),Str(ID))
;     *Me\m_nodes() = *tree\root
    SaveNode(*Me,op,*tree\root,0)
    SaveCompounds(*Me,op)
    
      
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Save Stack
  ;----------------------------------------------------------------------------
  Procedure SaveStack(*Me.Saver_t,node.i,*item.Object3D::Object3D_t)
    Protected op
    Protected stack = CreateXMLNode(node,"Stack")
    Protected *stack.Stack::Stack_t = *item\stack 
    ForEach *stack\levels()
      Select *stack\levels()\class\name
        Case "Tree"
          Protected *t.Stack::StackLevel_t = *stack\levels()
;           op = CreateXMLNode(stack,*gt\name)
          SaveTree(*Me,stack,*t)
  
      EndSelect
    Next
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save Attributes
  ;----------------------------------------------------------------------------
  Procedure SaveAttributes(*Me.Saver_t,node.i,*item.Object3D::Object3D_t)
    Protected a
    Protected *a.Attribute::Attribute_t
    Protected attrs = CreateXMLNode(node,"Attributes")
    ForEach *item\geom\m_attributes()
      *a = *item\geom\m_attributes()
      Protected attr = CreateXMLNode(attrs,*a\name)
      
      SetXMLAttribute(attr,"Type",Str(*a\datatype))
      SetXMLAttribute(attr,"Context",Str(*a\datacontext))
      SetXMLAttribute(attr,"Structure",Str(*a\datastructure))
      SetXMLAttribute(attr,"Constant",Str(*a\constant))
      SetXMLAttribute(attr,"Size",Str(Attribute::GetSize(*a)))
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
    Protected value.s = Matrix4::ToString(*m)
    SetXMLAttribute(local,"Value", value)

  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Save 3D Object
  ;----------------------------------------------------------------------------
  Procedure Save3DObject(*Me.Saver_t,parent.i,*item.Object3D::Object3D_t)
    Protected object = CreateXMLNode(parent,*item\name,-1)
    Select *item\type
      Case Object3D::#Camera
        SetXMLAttribute(object,"Type","Camera")
      Case Object3D::#Light
        SetXMLAttribute(object,"Type","Light")
      Case Object3D::#Locator
        SetXMLAttribute(object,"Type","Null")
      Case Object3D::#Polymesh
        SetXMLAttribute(object,"Type","Polymesh")
      Case Object3D::#Curve
        SetXMLAttribute(object,"Type","Curve")
      Case Object3D::#PointCloud
        SetXMLAttribute(object,"Type","PointCloud")
      Case Object3D::#InstanceCloud
        SetXMLAttribute(object,"Type","InstanceCloud")
      Case Object3D::#Grid
        SetXMLAttribute(object,"Type","Grid")
      Case Object3D::#Model
        SetXMLAttribute(object,"Type","Model")
      Case Object3D::#Root
        SetXMLAttribute(object,"Type","Root")
      Case Object3D::#Layer
        SetXMLAttribute(object,"Type","Layer")
    EndSelect
    
    
    Select *item\type
      Case Object3D::#Camera
      Case Object3D::#Curve
      Case Object3D::#Grid
      Case Object3D::#Layer
      Case Object3D::#Light
      Case Object3D::#Model
      Case Object3D::#Locator
      Case Object3D::#PointCloud
        Protected *cloud.PointCloud::PointCloud_t = *item
        Protected *geo.Geometry::PointCloudGeometry_t = *cloud\geom
        Protected geometrynode = CreateXMLNode(object,"Geometry")
        
        ; Geometry definition
        SetXMLAttribute(geometrynode,"NbPoints",Str(CArray::GetCount(*geo\a_positions)))
  
        
      Case Object3D::#Polymesh
        Protected *mesh.Polymesh::Polymesh_t = *item
        Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
        Protected geom = CreateXMLNode(object,"Geometry")
        
        ; Geometry definition
        SetXMLAttribute(geom,"NbVertices",Str(CArray::GetCount(*geom\topo\vertices)))
        SetXMLAttribute(geom,"NbIndices",Str(CArray::GetCount(*geom\topo\faces)))
        
        Protected datas.s
        ; Vertices
        Protected size_t = CArray::GetCount(*geom\topo\vertices) * CArray::GetItemSize(*geom\topo\vertices)
        CompilerIf #PB_Compiler_Version < 560
          Protected *mem = AllocateMemory(size_t*1.5)
          Base64Encoder(CArray::GetPtr(*geom\topo\vertices,0),size_t,*mem,size_t*1.5)
          SetXMLAttribute(geom,"Vertices",PeekS(*mem,size_t*1.5))
        CompilerElse
          datas = Base64Encoder(CArray::GetPtr(*geom\topo\vertices,0),size_t)
        CompilerEndIf
        
        
        SetXMLAttribute(geom,"Vertices",datas)
        
        ; Indices
        size_t = CArray::GetCount(*geom\topo\faces)* CArray::GetItemSize(*geom\topo\faces)
        CompilerIf #PB_Compiler_Version < 560
          *mem = ReAllocateMemory(*mem,size_t*1.5)
          Base64Encoder(CArray::GetPtr(*geom\topo\faces,0),size_t,*mem,size_t*1.5)
          SetXMLAttribute(geom,"Indices",PeekS(*mem,size_t*1.5))
        CompilerElse
          datas = Base64Encoder(CArray::GetPtr(*geom\topo\faces,0),size_t)
        CompilerEndIf
        
        SetXMLAttribute(geom,"Indices",datas)
        
        If *mem : FreeMemory(*mem) : EndIf
    EndSelect
    
    SaveTransform(object,*item)
    
    If MapSize(*item\geom\m_attributes())
      SaveAttributes(*Me,object,*item)
    EndIf
    
    SaveStack(*Me,object,*item)
    *Me\numSaved3DObject +1
    
    ; Recursive Save
    ;-------------------------------------------------------------
    If ListSize(*item\children())
      Protected c
      ForEach *item\children()
        Save3DObject(*Me,object,*item\children())
      Next
    EndIf
    
    
  EndProcedure
    
  
  ;------------------------------------------------------------------
  ; Save
  ;------------------------------------------------------------------
  Procedure Save(*Me.Saver_t)
    Protected *obj.Object::Object_t = *Me\obj
  
    Select *obj\class\name
      Case "Scene"
        
        Protected *scene.Scene::Scene_t = *obj
        ; ---[ Create XML node] -------------------------------------
        *Me\root = CreateXMLNode(RootXMLNode(*Me\xml),*scene\filename)
        Protected *objs.CArray::CArrayPtr = *scene\objects
        Protected *o.Object3D::Object3D_t
        Protected i
        For i =0 To CArray::GetCount(*scene\objects)-1
          *o = CArray::GetValuePtr(*scene\objects,i)
          Save3DObject(*Me,*Me\root,*o)
        Next
        ; ---[ format XML ] -----------------------------------------
        FormatXML(*Me\xml,#PB_XML_LinuxNewline|#PB_XML_ReFormat|#PB_XML_ReIndent)
        ; ---[ Save XML ] -------------------------------------------
        SaveXML(*Me\xml, *Me\path)
        
;         Protected s.s = ComposeXML(*Me\xml)
;         MessageRequester("Save Tree",s)
  
      Default
        MessageRequester("Noodle","Save File Failed..."+*obj\class\name)
    EndSelect
    
  EndProcedure
  ; ==================================================================
  ;  DESTRUCTOR
  ; ==================================================================
  Procedure Delete(*Me.Saver_t)
    FreeXML(*Me\xml)
    Object::TERM(Saver)
  EndProcedure
  
  ; ==================================================================
  ;  CONSTRUCTOR
  ; ==================================================================
  Procedure.i New(*obj.Object::Object_t,path.s)
    Protected *Me.Saver_t = AllocateStructure(Saver_t)
    Object::INI(Saver)
    *Me\obj = *obj
    *Me\numSaved3DObject = 0
    If Not path = ""
      *Me\path = path
    Else
      Protected defaultFile$ = GetCurrentDirectory()+"scene.scene"
      Protected pattern$ = "Noodle Scene File | *.scene"
      *Me\path = SaveFileRequester("Noodle Saver",defaultFile$,pattern$,0)
    EndIf
    If *Me\path
      *Me\xml = CreateXML(#PB_Any,#PB_UTF8)
      ProcedureReturn *Me
    Else
      Delete(*Me)
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
  
  
  Class::DEF(Saver)
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 544
; FirstLine = 523
; Folding = ----
; EnableXP
; EnableUnicode