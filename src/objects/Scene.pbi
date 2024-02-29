; ============================================================================
;  Scene Module Declaration
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "Root.pbi"
XIncludeFile "Model.pbi"
XIncludeFile "Polymesh.pbi"
XIncludeFile "PointCloud.pbi"
XIncludeFile "Camera.pbi"
XIncludeFile "Light.pbi"
XIncludeFile "Selection.pbi"

DeclareModule Scene
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure Twist_t
    speed.f
    phase.f
    amplitude.f
  EndStructure
  
  Structure Scene_t Extends Object::Object_t
    filename.s
    *root.Root::Root_t    
    *models.CArray::CArrayPtr
    *objects.CArray::CArrayPtr
    *helpers.CArray::CArrayPtr
    dirty.b
    *lights.CArray::CArrayPtr
    *cameras.CArray::CArrayPtr
    *camera.Camera::Camera_t
    *selection.Selection::Selection_t
    *rayhit.Object3D::Object3D_t
    dirtycount.i
    
    nbpolygons.i
    nbtriangles.i
    nbvertices.i
    
    nbobjects.i
    
    Map *m_objects.Object3D::Object3D_t()
    Map *m_uuids.Object3D::Object3D_t()
    Map twists.Twist_t()
    
    *on_new.Callback::Callback_t
    *on_delete.Callback::Callback_t
    *on_change.Callback::Callback_t
    *on_selection.Callback::Callback_t
    *on_time.Callback::Callback_t
    *on_edit.Callback::Callback_t
    *on_create.Callback::Callback_t

  EndStructure
  
  Declare New( name.s = "ActiveScene")
  Declare Delete(*Me.Scene_t)
  Declare Setup(*Me.Scene_t)
  Declare Update(*Me.Scene_t)
  
  ; twist a scene
  Declare InitTwist(*Me.Scene_t, speed.f=0.06, amplitude=1.0)
  Declare Twist(*Me.Scene_t)
  
  Declare SelectObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare AddObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare AddChild(*Me.Scene_t,*obj.Object3D::Object3d_t)
  Declare AddModel(*Me.Scene_t,*model.Model::Model_t)
  Declare AddObjectChildren(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare AddToSelection(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare RemoveObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare GetCamera(*Me.Scene_t)
  Declare GetMainLight(*Me.Scene_t)
  Declare GetSecondaryLight(*Me.Scene_t,id.i)
  Declare GetNbLights(*Me.Scene_t)
  Declare GetNbObjects(*Me.Scene_t)
  Declare GetObjectByName(*Me.Scene_t,name.s)
  Declare Save(*Me.Scene_t)
  Declare SaveAs(*Me.Scene_t, filename.s)
  Declare GetUniqueID(*Me.Scene_t, *o.Object3D::Object3D_t)
  Declare.s GetInfos(*Me.Scene_t)
  
  Declare CreateRandomGround(size.f, height.f)
  Declare CreateMeshGrid(nx.i, ny.i, nz.i, shape.i)
  
  DataSection 
    SceneVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  Scene Module Implementation
; ============================================================================
Module Scene
  
  ;---------------------------------------------------------------------------
  ; Create Unique ID
  ;---------------------------------------------------------------------------
  Procedure GetUniqueID(*s.Scene_t, *o.Object3D::Object3D_t)
    Protected uuid.i = Random(1<<24)
    If FindMapElement(*s\m_uuids(), Str(uuid))
      GetUniqueID(*s, *o)
    Else
      AddMapElement(*s\m_uuids(), Str(uuid))
      *s\m_uuids() = *o
      Protected v.v3f32
      Object3D::EncodeID(@v, uuid)
      Protected decoded = Object3D::DecodeID(v\x*255, v\y*255, v\z*255)
      ProcedureReturn uuid
    EndIf  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Infos
  ;---------------------------------------------------------------------------
  Procedure.s GetInfos(*Me.Scene_t)
    Define infos.s 
    infos + "Cameras : "+Str(*Me\cameras\itemCount)+Chr(10)
    infos + "Lights : "+Str(*Me\lights\itemCount)+Chr(10)
    infos + "Objects : "+Str(*Me\objects\itemCount)+Chr(10)
    infos + "Helpers : "+Str(*Me\helpers\itemCount)+Chr(10)
    
    ProcedureReturn infos
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Resolve Unique Name
  ;---------------------------------------------------------------------------
  Procedure ResolveUniqueName(*s.Scene::Scene_t,*o.Object3D::Object3D_t)
    Protected found = #False
    Protected i = 0
    Protected name.s = *o\name
  
    While Not found
      If *o\model <> #Null
        *o\fullname = *o\model\name+"."+name
      Else
        *o\fullname = name
      EndIf
      
      If FindMapElement(*s\m_objects(),*o\fullname)
        i+1
        name = *o\name+Str(i)
      Else
        AddMapElement(*s\m_objects(), *o\fullname , #PB_Map_ElementCheck)
        
        *s\m_objects() = *o
        *o\name = name
        found = #True
      EndIf  
    Wend
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Delete Unique Name
  ;---------------------------------------------------------------------------
  Procedure DeleteUniqueName(*s.Scene::Scene_t, *o.Object3D::Object3D_t)
    If FindMapElement(*s\m_objects(), *o\fullname)
      DeleteMapElement(*s\m_objects(), *o\fullname)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select Object
  ;---------------------------------------------------------------------------
  Procedure SelectObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
    Selection::Clear(*Me\selection)
    Selection::AddObject(*Me\selection, *obj)
    Callback::Trigger(*Me\on_selection)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Object To Selection
  ;---------------------------------------------------------------------------
  Procedure AddToSelection(*Me.Scene_t,*obj.Object3D::Object3D_t)
    Selection::AddObject(*Me\selection, *obj)
    Callback::Trigger(*Me\on_selection)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Object To Scene Graph
  ;---------------------------------------------------------------------------
  Procedure AddObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
    ResolveUniqueName(*Me,*obj)
    *Me\nbobjects  + 1
    *obj\uniqueID = GetUniqueID(*Me, *obj)
    Select *obj\type
      Case Object3D::#Drawer
        CArray::AppendUnique(*Me\helpers,*obj)
      Case Object3D::#Locator
        CArray::AppendUnique(*Me\helpers,*obj)
      Case Object3D::#Model
        CArray::AppendUnique(*Me\models,*obj)
      Case Object3D::#Curve
        CArray::AppendUnique(*Me\helpers,*obj)
      Case Object3D::#Polymesh
        CArray::AppendUnique(*Me\objects,*obj)
      Case Object3D::#PointCloud        
        CArray::AppendUnique(*Me\objects,*obj)
      Case Object3D::#InstanceCloud        
        CArray::AppendUnique(*Me\objects,*obj)
      Case Object3D::#Light 
        CArray::AppendUnique(*Me\lights,*obj)
      Case Object3D::#Camera
        CArray::AppendUnique(*Me\cameras,*obj)
    EndSelect
    Callback::Trigger(*Me\on_create)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Remove Object To Scene Graph
  ;---------------------------------------------------------------------------
  Procedure RemoveObject(*Me.Scene_t,*obj.Object3D::Object3D_t)

    Select *obj\type
      Case Object3D::#Locator
        CArray::Remove(*Me\helpers,*obj)
      Case Object3D::#Model
        CArray::Remove(*Me\models,*obj)
      Case Object3D::#Curve
        CArray::Remove(*Me\helpers,*obj)
      Case Object3D::#Polymesh
        CArray::Remove(*Me\objects,*obj)
      Case Object3D::#PointCloud        
        CArray::Remove(*Me\objects,*obj)
      Case Object3D::#InstanceCloud        
        CArray::Remove(*Me\objects,*obj)
      Case Object3D::#Light 
        CArray::Remove(*Me\lights,*obj)
      Case Object3D::#Camera
        CArray::Remove(*Me\cameras,*obj)
    EndSelect
    Callback::Trigger(*Me\on_delete)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Object
  ;---------------------------------------------------------------------------
  Procedure AddObjectChildren(*Me.Scene_t,*obj.Object3D::Object3D_t)
  
    ; Add Object Children to scene graph
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected fullname.s
    Protected basename.s
    Protected *model.Model::Model_t = *obj\model
    If *model : basename = *model\name+"|":EndIf
    
    ForEach *obj\children()
      *child = *obj\children()
      If *obj\type = Object3D::#Model
        *child\model = *obj
      Else
        *child\model = *obj\model
      EndIf
      
      fullname = basename+*child\name
  
      AddObject(*Me,*child)
      
      AddObjectChildren(*Me,*child)
      *Me\dirty = #True
      *Me\dirtycount+1
    Next
    AddObject(*Me,*obj)
  EndProcedure
 
  ;---------------------------------------------------------------------------
  ; Add Model
  ;---------------------------------------------------------------------------
  Procedure AddModel(*Me.Scene_t,*model.Model::Model_t)
    If *model = #Null Or *Me = #Null
      ProcedureReturn
    EndIf

    AddChild(*Me,*model)
    datas.s
    ForEach *me\root\children()
      datas + *Me\root\children()\name
    Next
   
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Child
  ;---------------------------------------------------------------------------
  Procedure AddChild(*Me.Scene_t,*obj.Object3D::Object3d_t)
    If *obj = #Null Or *Me = #Null
      ProcedureReturn
    EndIf
    
    Object3D::AddChild(*Me\root,*obj)
    AddObject(*Me,*obj)
    
    Protected fullname.s = *obj\name
  
    *Me\m_objects(fullname) = *obj
    fullname = *obj\name
    
    ; Add Children to scene graph
    Protected i
    Protected *child.Object3D::Object3D_t
    ForEach *obj\children()
      *child = *obj\children()
      AddObjectChildren(*Me,*child)
    Next
    *Me\dirty = #True
    *Me\dirtycount+1
  EndProcedure

  ;---------------------------------------------------------------------------
  ; Delete Object Children (Recursive)
  ;---------------------------------------------------------------------------
  Procedure DeleteObjectChildren(*Me.Scene_t,*obj.Object3D::Object3D_t)
    Protected c
    Protected o.Object3D::IObject3D = *obj
    Protected *child.Object3D::Object3D_t
    Protected id
    Protected nbc = ListSize(*obj\children())
    If nbc > 0 
      ForEach *obj\children()
        *child = *obj\children()
        RemoveObject(*Me,*child)
        DeleteObjectChildren(*Me,*child)
      Next
   EndIf
   RemoveObject(*Me,*obj)
   o\Delete()  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Delete Object
  ;---------------------------------------------------------------------------
  Procedure DeleteObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
    If Not *Me Or Not *obj : ProcedureReturn : EndIf
    
    Protected id = -1
    Protected *parent.Object3D::Object3D_t = *obj\parent
    If *parent
      ForEach *parent\children()
        If *parent\children() = *obj
          DeleteElement(*parent\children())
          Break
        EndIf
      Next
     
    EndIf

    DeleteObjectChildren(*Me,*obj)
    
    PostEvent(Globals::#EVENT_GRAPH_CHANGED,EventWindow(),#Null,0,#Null)
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Parent Object
  ;---------------------------------------------------------------------------
  Procedure ParentObject(*obj.Object3D::Object3D_t,*parent.Object3D::Object3D_t)
    Protected obj.Object3D::IObject3D = *obj
    Protected parent.Object3D::IObject3D = *parent
    Protected old.Object3D::IObject3D = *obj\parent
    Object3D::RemoveChild(*obj\parent,*obj)
    Object3D::AddChild(*parent,*obj)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Cut Object
  ;---------------------------------------------------------------------------
  Procedure CutObject(*obj.Object3D::Object3D_t)
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Setup Children
  ;---------------------------------------------------------------------------
  Procedure SetupChildren(*Me.Scene_t,*obj.Object3D::Object3D_t)
    Protected j
    Protected child.Object3D::IObject3D
    ForEach *obj\children()
      child = *obj\children()
      If Not *obj\children()\initialized
        child\Setup(GLContext::*SHARED_CTXT)
      EndIf
      SetupChildren(*Me,child)
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; SetupObject
  ;---------------------------------------------------------------------------
  Procedure Setup(*Me.Scene_t)
    Protected i,j
    Protected *root.Root::Root_t = *Me\root
    Protected child.Object3D::IObject3D
    Protected *model.Model::Model_t
    GLContext::*SHARED_CTXT\scene = *Me
    GLContext::SetContext(GLContext::*SHARED_CTXT)
    ForEach *root\children()
      child = *root\children()
      child\Setup(GLContext::*SHARED_CTXT)

      SetupChildren(*Me,child)
    Next

    ; Setup Handle
    ;OHandle::Setup(*Me\handle,*ctx)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Children in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure CleanChildren(*obj.Object3D::Object3D_t)
    Protected i,j
    Protected child.Object3D::IObject3D
  
    ForEach *obj\children()
      child = *obj\children()
      Protected *ochild.Object3D::Object3D_t = *child
      
      child\Clean(GLContext::*SHARED_CTXT)
      CleanChildren(*child)
    Next
    
    Protected object.Object3D::IObject3D = *obj
    object\Clean(GLContext::*SHARED_CTXT)
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Object in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure CleanObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
  
    Protected i
    Protected child.Object3D::IObject3D
    
    ForEach *obj\children()
      child = *obj\children()
      CleanChildren(child)
    Next
    
    Protected object.Object3D::IObject3D = *obj
    object\Clean(GLContext::*SHARED_CTXT)
  
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Scene in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure Clean(*Me.Scene_t)
  
    Protected i,j
    Protected child.Object3D::IObject3D
    Protected *model.Model::Model_t
    GLContext::SetContext(GLContext::*SHARED_CTXT)
    For i = 0 To CArray::GetCount(*Me\models)-1
      *model = CArray::GetValue(*Me\models,i)
      ForEach *model\children()
        child = *model\children()
        child\Clean(GLContext::*SHARED_CTXT)
        CleanChildren(child)
      Next
      
    Next i
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Update Children in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure UpdateChildren(*obj.Object3D::Object3D_t)

    Protected i
    Protected child.Object3D::IObject3D = *obj
    ForEach *obj\children()
      child = *obj\children()
      If Not *obj\children()\initialized
        child\Setup(GLContext::*SHARED_CTXT)
      EndIf
      Object3D::UpdateTransform(*obj\children(),*obj\globalT)
      child\Update(GLContext::*SHARED_CTXT)

      UpdateChildren(*obj\children())
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Scene in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure Update(*Me.Scene_t)
    If Not *Me : ProcedureReturn : EndIf
    ;If *Me\dirty
    GLContext::SetContext(GLContext::*SHARED_CTXT)
      Protected i
      Protected *root.Object3D::Object3D_t = *Me\root
      Protected child.Object3D::IObject3D
      Protected *c.Object3D::Object3D_t

      Matrix4::SetIdentity(*root\globalT\m)
      ForEach *root\children()
        child = *root\children()
        
        Object3D::UpdateTransform(child,*root\globalT)
        child\Update(GLContext::*SHARED_CTXT)
        UpdateChildren( child)
      Next
      
      *Me\dirty = #False
     ;EndIf
    EndProcedure
    
  ;---------------------------------------------------------------------------
  ; Twist a scene
  ;---------------------------------------------------------------------------
  Procedure InitTwist(*Me.Scene_t, speed.f=0.06, amplitude=1.0)
    ClearMap(*Me\twists())
    Protected key.s
    ForEach *Me\m_uuids()
      key = MapKey(*Me\m_uuids())
      Transform::SetFromOther(*Me\m_uuids()\staticT, *Me\m_uuids()\localT)
      AddMapElement(*Me\twists(), key)
      *Me\twists(key)\phase = Math::Random_0_1()
      *Me\twists(key)\speed = speed
      *Me\twists(key)\amplitude = amplitude
    Next
  EndProcedure
  
  Procedure Twist(*Me.Scene_t)
    Define t.Transform::Transform_t
    Define p.v3f32
    Define r.q4f32
    Define key.s
    ForEach *Me\m_uuids()
      key = MapKey(*Me\m_uuids())
      Transform::SetSRTFromMatrix(*Me\m_uuids()\staticT\m, t\t\scl, t\t\rot, t\t\pos)
      Vector3::Set(p, t\t\pos\x + Math::Random_0_1() * 0.05, t\t\pos\y + Math::Random_0_1() * 0.05, t\t\pos\z + Math::Random_0_1() * 0.05)
      Transform::SetTranslation(t, p)
      Object3D::SetLocalTransform(*Me\m_uuids(), t)
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Num 3D Objects
  ;---------------------------------------------------------------------------
  Procedure GetNbObjects(*Me.Scene_t)
    ProcedureReturn CArray::GetCount(*Me\objects)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get object by name
  ;---------------------------------------------------------------------------
  Procedure GetObjectByName(*Me.Scene_t,name.s)
    Protected i
    Protected *o.Object3D::Object3D_t
    For i =0 To CArray::GetCount(*Me\objects)-1
      *o = CArray::GetValuePtr(*Me\objects,i)
      If *o\name = name
        ProcedureReturn *o
      EndIf 
    Next
    ProcedureReturn #Null
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get num polygons in scene
  ;---------------------------------------------------------------------------
  Procedure GetNbPolygons(*Me.Scene_t)
    *Me\nbpolygons=0
    Protected i
    Protected *o.Object3D::Object3D_t
    Protected *m.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t
    For i=0 To CArray::GetCount(*Me\objects)-1
      *o = CArray::GetValuePtr(*Me\objects,i)
      If *o\type = Object3D::#Polymesh
        *m = *o
        *geom = *m\geom
        *Me\nbpolygons + *geom\nbpolygons
      EndIf
    Next
    
    ProcedureReturn *Me\nbpolygons
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get num triangles in scene
  ;---------------------------------------------------------------------------
  Procedure GetNbTriangles(*Me.Scene_t)
    *Me\nbtriangles=0
    Protected i
    Protected *o.Object3D::Object3D_t
    Protected *m.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t = *m\geom
    For i=0 To CArray::GetCount(*Me\objects)-1
      *o = CArray::GetValuePtr(*Me\objects,i)
      If *o\type = Object3D::#Polymesh
        *m = *o
        *geom = *m\geom
        *Me\nbtriangles + *geom\nbtriangles
      EndIf
    Next
    
    ProcedureReturn *Me\nbtriangles
  EndProcedure

  ;---------------------------------------------------------------------------
  ; Get Active Camera
  ;---------------------------------------------------------------------------
  Procedure GetActiveCamera(*Me.Scene_t)
    If Not *Me\camera
      *Me\camera = CArray::GetValue(*Me\cameras,0)
    EndIf
    ProcedureReturn *Me\camera
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Scene Root
  ;---------------------------------------------------------------------------
  Procedure GetRoot(*Me.Scene_t)
    ProcedureReturn *Me\root
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Save Scene
  ;---------------------------------------------------------------------------
  Procedure Save(*Me.Scene_t)
    Debug "------------------------ SAVE SCENE ------------------------------"
    
    Debug "Scene Save Called"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Save SCene As
  ;---------------------------------------------------------------------------
  Procedure SaveAs(*Me.Scene_t, filename.s)
    Debug "Scene Save As Called"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select By ID
  ;---------------------------------------------------------------------------
  Procedure SelectByID(*Me.Scene_t,uuid.i)
    Protected i
    Protected *object.Object3D::Object3D_t
    Protected *out.Object3D::IObject3D = #Null
    For i=0 To CArray::GetCount(*Me\objects)-1
      *object = CArray::GetValue(*Me\objects,i)
      If id = *object\uniqueID
;         *object\selected = #True
        *out = *object
        Break
      EndIf 
    Next 
    
    ;Update others selectivity
    If *out<>#Null
      For i=0 To CArray::GetCount(*Me\objects)-1
        *object = CArray::GetValue(*Me\objects,i)
      If Not *object = *out
        *object\selected = #False
      EndIf 
    Next 
    EndIf
    
    ProcedureReturn *out
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Camera
  ;---------------------------------------------------------------------------
  Procedure GetCamera(*Me.Scene_t)
    ProcedureReturn *Me\camera  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Main Light
  ;---------------------------------------------------------------------------
  Procedure GetMainLight(*Me.Scene_t)
    ; Main Light is always the first one in Scene Light Array
    ; Should be infinite aka the sun
    Protected *main.Light::Light_t = CArray::GetValuePtr(*Me\lights,0)
    ProcedureReturn *main
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Secondary Light
  ;---------------------------------------------------------------------------
  Procedure GetSecondaryLight(*Me.Scene_t,id.i)
    If id>0 And id <CArray::GetCount(*Me\lights)
      ProcedureReturn CArray::GetValuePtr(*Me\lights,id)
    EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Nb Lights(main + secondaries)
  ;---------------------------------------------------------------------------
  Procedure GetNbLights(*Me.Scene_t)
    ProcedureReturn CArray::GetCount(*Me\lights)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Create a random ground polymesh
  ;---------------------------------------------------------------------------
  Procedure CreateRandomGround(size.f, height.f)
    Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_NONE)
    Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom
  
    PolymeshGeometry::GridTopology(*geom, size,32,32)
    
    Protected *topo.Geometry::Topology_t = *geom\topo
    Define i
    Define *p.v3f32
    For i=0 To CArray::GetCount(*topo\vertices)-1
      *p = CArray::GetValue(*topo\vertices, i)
      *p\y + Random(height*100) /100
    Next
    PolymeshGeometry::Set2(*geom, *topo)
    Object3D::Freeze(*ground)
    ProcedureReturn *ground
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Create a grid of mesh
  ;---------------------------------------------------------------------------
  Procedure CreateMeshGrid(nx.i, ny.i, nz.i, shape.i)
    Define pos.v3f32, rot.q4f32

    Define *t.Transform::Transform_t
    Define color.c4f32
    Define rot.q4f32
    
    Define *mesh.Polymesh::Polymesh_t
    Define *geom.Geometry::PolymeshGeometry_t
    Define *model.Model::Model_t = Model::New("Grid")
    Define x,y,z
    Define o.f
    For x = 0 To nx
      For y = 0 To ny
        For z = 0 To nz
          *mesh = Polymesh::New("Bunny",shape)
          *t = *mesh\localT
          *geom = *mesh\geom
          numTriangles + *geom\nbtriangles
          Vector3::Set(color,Random_0_1(),Random_0_1(),Random_0_1())
          PolymeshGeometry::SetColor(*geom,color)
          Transform::SetTranslationFromXYZValues(*t,x-nx*0.5,y+2,z-nz*0.5)
          Quaternion::SetFromEulerAngles(rot,Random(360),Random(360),Random(360))
          Transform::SetRotationFromQuaternion(*t,rot)
          Define s.f = RANDOM_0_1() * 0.5
          Transform::SetScaleFromXYZValues(*t, s, s, s)
          Object3D::SetLocalTransform(*mesh,*t)

          Object3D::AddChild(*model,*mesh)
        Next
      Next
    Next
    ProcedureReturn *model
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Scatter a mesh on another
  ;---------------------------------------------------------------------------
  Procedure CreateScatteredMesh()
;     Define pos.v3f32,scl.v3f32
; 
; 
;   *ground.Polymesh::Polymesh_t = Scene::RandomGround()
;   
; 
;   *box = Polymesh::New("Box",Shape::#SHAPE_CUBE)
;   
;   Define *samples.CArray::CArrayLocation = CArray::New(Types::#TYPE_LOCATION)
;   *samples\geometry = *ground\geom
;   *samples\transform = *ground\globalT
;   Sampler::SamplePolymesh(*ground\geom,*samples,256,7)
;   
;   *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
;   
;   Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
;   *merged\wireframe = #False
;   Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
;   
;   Define *topos.CArray::CArrayPtr = CArray::New(Types::#TYPE_PTR)
;   Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
;   Define *gtopo.Geometry::Topology_t = *ggeom\topo
;   Define i
;       
;   Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
;   
;   Define *topos.CArray::CArrayPtr = CArray::New(Types::#TYPE_PTR)
;   Define *matrices.CArray::CarrayM4F32 = CArray::New(Types::#TYPE_M4F32)
;   Define m.m4f32
;   Define pos.v3f32
;     
;   Define *loc.Geometry::Location_t
;   Define *pos.v3f32, *nrm.v3f32
;   Define scl.v3f32
;   Define size.f = 7
;   Define pos.v3f32, center.v3f32
;   Vector3::Set(center, 0,5,0)
; ;   CArray::SetCount(*matrices, CArray::GetCount(*samples))
;   For i=0 To CArray::GetCount(*samples)-1
;     *loc = CArray::GetValue(*samples,i)
;     Location::GetPosition(*loc,*ggeom,*ground\globalT)
;     Location::GetNormal(*loc,*ggeom,*ground\globalT)
;     Matrix4::SetIdentity(m)
;     size = Random(50)+5
;     Vector3::ScaleInPlace(*loc\n, size/2)
;     Vector3::AddInPlace(*loc\p, *loc\n)
;     Vector3::Randomize(pos, center, 12)
;     Matrix4::SetIdentity(m)
;     Matrix4::SetTranslation(m, *loc\p)
;     
;     Vector3::Set(scl, size, size, size)
;     Matrix4::SetScale(m, scl)
;    
;     CArray::Append(*matrices,m)
; ;     CArray::SetValue(*matrices, i, m)
;  Next
;   
;  Define *topo.Geometry::Topology_t = Topology::New(*bgeom\topo)
;  
;  
;  Topology::TransformArray(*topo,*matrices,*topos)
;   Topology::MergeArray(*topo,*topos)
;  
;   Define sT.d = Time::Get()
;   PolymeshGeometry::Set2(*mgeom,*topo)
;   Topology::Delete(*topo)
;   
; ;   PolymeshGeometry::ComputeHalfEdges(*mgeom)
; ;   PolymeshGeometry::ComputeIslands(*mgeom)
; ;   PolymeshGeometry::RandomColorByIsland(*mgeom)
;   Object3D::Freeze(*merged)
;   
;   Object3D::AddChild(*model,*merged)
;   
;   Object3D::AddChild(*model,*ground)
;   Object3D::AddChild(*model,*bunny)  
  EndProcedure
  
  
  
  ;---------------------------------------------------------------------------
  ;  Destructor
  ;---------------------------------------------------------------------------
  Procedure Delete( *Me.Scene_t )
    Protected *model.Model::Model_t
    Protected i
    
    Callback::Trigger(*Me\on_delete, Callback::#SIGNAL_TYPE_PING)
    Root::Delete(*Me\root)
    Selection::Delete(*Me\selection)
    CArray::Delete(*Me\models)
    CArray::Delete(*Me\objects)
    CArray::Delete(*Me\helpers)
    CArray::Delete(*Me\lights)
    CArray::Delete(*Me\cameras)

    ; Deallocate Memory
    FreeStructure(*Me)

  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;  CONSTRUCTORS
  ;---------------------------------------------------------------------------
  Procedure.i New( name.s = "ActiveScene")
    
    ; Allocate Object Memory
    Protected *Me.Scene_t = AllocateStructure( Scene_t )
    *Me\filename = name
    Object::INI(Scene)
    
    ; Create Containers
    *Me\models = CArray::New(Types::#TYPE_PTR)
    *Me\objects = CArray::New(Types::#TYPE_PTR)
    *Me\cameras = CArray::New(Types::#TYPE_PTR)
    *Me\lights = CArray::New(Types::#TYPE_PTR)
    *Me\helpers = CArray::New(Types::#TYPE_PTR)

    ; Create Root
    *Me\selection = Selection::New()
    *Me\root = Root::New("SceneRoot")
    
    ; Create Camera
    Protected *camera.Camera::Camera_t = Camera::New("Camera",Camera::#Camera_Perspective)
    
    *Me\camera = *camera
    CArray::AppendPtr(*Me\cameras,*camera)
    Object3D::AddChild(*Me\root,*camera)
    
    ; Create Light
    Protected *light.Light::Light_t = Light::New("Light",Light::#Light_Infinite)
    CArray::AppendPtr(*Me\lights,*light)
    Object3D::AddChild(*Me\root,*light)
    
    ; Callbacks
    *Me\on_new = Object::NewCallback(*Me, "OnNew")
    *Me\on_delete = Object::NewCallback(*Me, "OnDelete")
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    *Me\on_selection = Object::NewCallback(*Me, "OnSelection")
    *Me\on_time = Object::NewCallback(*Me, "OnTime")
    *Me\on_edit = Object::NewCallback(*Me, "OnEdit")
    *Me\on_create = Object::NewCallback(*Me, "OnCreate")
    
    ProcedureReturn( *Me )
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;  REFLECTION
  ;---------------------------------------------------------------------------
  Class::DEF( Scene )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 357
; FirstLine = 335
; Folding = --------
; EnableXP