; ============================================================================
;  Scene Module Declaration
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "Root.pbi"
XIncludeFile "Model.pbi"
XIncludeFile "Scene.pbi"
XIncludeFile "Polymesh.pbi"
XIncludeFile "Camera.pbi"
XIncludeFile "Light.pbi"

DeclareModule Scene
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Structure Scene_t Extends Object::Object_t
    filename.s
    *root.Root::Root_t
    ;handle.Handle::Handle_t
    ;grid.Grid::Grid2D_t
    *models.CArray::CArrayPtr
    *objects.CArray::CArrayPtr
    *helpers.CArray::CArrayPtr
    dirty.b
    *lights.CArray::CArrayPtr
    *cameras.CArray::CArrayPtr
    *camera.Camera::Camera_t
    *selection.CArray::CArrayPtr
    *rayhit.Object3D::Object3D_t
    dirtycount.i
    
    nbpolygons.i
    nbtriangles.i
    nbvertices.i
    
    nbobjects.i
    
    Map *m_objects.Object3D::Object3D_t()
    Map *m_uuids.Object3D::Object3D_t()

  EndStructure
  
  
  Interface IScene Extends Object3D::IObject3D
  EndInterface
  
  Declare New( name.s = "ActiveScene")
  Declare Delete(*Me.Scene_t)
  Declare Setup(*scn.Scene_t,*ctx.GLContext::GLContext_t)
  Declare Update(*Me.Scene_t)
  Declare Draw(*Me.Scene_t,*shader.Program::Program_t,filter.i=-1)
  
  Declare SelectObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
  Declare AddObject(*scn.Scene_t,*obj.Object3D::Object3D_t)
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
  Declare Save(*scn.Scene_t)
  Declare SaveAs(*scn.Scene_t, filename.s)
  Declare GetUniqueID(*scn.Scene_t, *o.Object3D::Object3D_t)
  
  DataSection 
    SceneVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Draw()
  EndDataSection 
  
  Global *current_scene.Scene::Scene_t
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  Scene Module Implementation
; ============================================================================
Module Scene
  
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
        AddMapElement(*s\m_objects(), *o\fullname ,#PB_Map_ElementCheck)
        
        *s\m_objects() = *o
        *o\name = name
        found = #True
      EndIf  
    Wend
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Delete Unique Name
  ;---------------------------------------------------------------------------
  Procedure DeleteUniqueName(*s.Scene::Scene_t,*o.Object3D::Object3D_t)
    If FindMapElement(*s\m_objects(),*o\fullname)
      DeleteMapElement(*s\m_objects(),*o\fullname)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select Object
  ;---------------------------------------------------------------------------
  Procedure SelectObject(*Me.Scene_t,*obj.Object3D::Object3D_t)
    Protected nbs = CArray::GetCount(*Me\selection)
    Protected s
    Protected *o.Object3D::Object3D_t
    For s = 0 To nbs-1
      *o = CArray::GetValue(*Me\selection,s)
      If *o\selected : *o\selected = #False : EndIf
    Next s
    
    *obj\selected = #True
    CArray::SetCount(*Me\selection,0)
    CArray::AppendPtr(*Me\selection,*obj)
    ;Handle::SetTarget(*Me\handle,*obj)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Object To Selection
  ;---------------------------------------------------------------------------
  Procedure AddToSelection(*Me.Scene_t,*obj.Object3D::Object3D_t)
    CArray::AppendPtr(*Me\selection,*obj)  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Add Object To Scene Graph
  ;---------------------------------------------------------------------------
  Procedure AddObject(*scn.Scene_t,*obj.Object3D::Object3D_t)
    ResolveUniqueName(*scn,*obj)
    *scn\nbobjects  + 1
    *obj\uniqueID = GetUniqueID(*scn, *obj)
    Select *obj\type
      Case Object3D::#Object3D_Drawer
        CArray::AppendUnique(*scn\helpers,*obj)
      Case Object3D::#Object3D_Null
        CArray::AppendUnique(*scn\helpers,*obj)
      Case Object3D::#Object3D_Model
        CArray::AppendUnique(*scn\models,*obj)
      Case Object3D::#Object3D_Curve
        CArray::AppendUnique(*scn\helpers,*obj)
      Case Object3D::#Object3D_Polymesh
        CArray::AppendUnique(*scn\objects,*obj)
      Case Object3D::#Object3D_PointCloud        
        CArray::AppendUnique(*scn\objects,*obj)
      Case Object3D::#Object3D_InstanceCloud        
        CArray::AppendUnique(*scn\objects,*obj)
      Case Object3D::#Object3D_Light 
        CArray::AppendUnique(*scn\lights,*obj)
      Case Object3D::#Object3D_Camera
        CArray::AppendUnique(*scn\cameras,*obj)
    EndSelect
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Remove Object To Scene Graph
  ;---------------------------------------------------------------------------
  Procedure RemoveObject(*scn.Scene_t,*obj.Object3D::Object3D_t)

    Select *obj\type
      Case Object3D::#Object3D_Null
        CArray::Remove(*scn\helpers,*obj)
      Case Object3D::#Object3D_Model
        CArray::Remove(*scn\models,*obj)
      Case Object3D::#Object3D_Curve
        CArray::Remove(*scn\helpers,*obj)
      Case Object3D::#Object3D_Polymesh
        CArray::Remove(*scn\objects,*obj)
      Case Object3D::#Object3D_PointCloud        
        CArray::Remove(*scn\objects,*obj)
      Case Object3D::#Object3D_InstanceCloud        
        CArray::Remove(*scn\objects,*obj)
      Case Object3D::#Object3D_Light 
        CArray::Remove(*scn\lights,*obj)
      Case Object3D::#Object3D_Camera
        CArray::Remove(*scn\cameras,*obj)
    EndSelect
  
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
      If *obj\type = Object3D::#Object3D_Model
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
    If nbc >0
      
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
  Procedure SetupChildren(*scn.Scene_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t)
    Protected j
    Protected child.Object3D::IObject3D
    ForEach *obj\children()
      child = *obj\children()
      If Not *obj\children()\initialized
        Select *obj\children()\type
          Case Object3D::#Object3D_Polymesh
            child\Setup(*ctx\shaders("polymesh"))
          Case Object3D::#Object3D_PointCloud
            MessageRequester("CLOUD SHADER", Str(*ctx\shaders("cloud")))
            child\Setup(*ctx\shaders("cloud"))
          Case Object3D::#Object3D_InstanceCloud
            child\Setup(*ctx\shaders("instances"))
          Case Object3D::#Object3D_Null
            child\Setup(*ctx\shaders("wireframe"))
          Case Object3D::#Object3D_Curve
            child\Setup(*ctx\shaders("curve"))
          Case Object3D::#Object3D_Drawer
            child\Setup(*ctx\shaders("drawer"))
        EndSelect
      EndIf
      SetupChildren(*scn,child,*ctx)
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; SetupObject
  ;---------------------------------------------------------------------------
  Procedure Setup(*scn.Scene_t,*ctx.GLContext::GLContext_t)
    Protected i,j
    Protected *root.Root::Root_t = *scn\root
    Protected child.Object3D::IObject3D
    Protected *model.Model::Model_t
  
    ForEach *root\children()
      child = *root\children()
      If Not *root\children()\initialized
        Select *root\children()\type
          Case Object3D::#Object3D_Polymesh
            child\Setup(*ctx\shaders("polymesh"))
          Case Object3D::#Object3D_PointCloud
            child\Setup(*ctx\shaders("cloud"))
          Case Object3D::#Object3D_InstanceCloud
            child\Setup(*ctx\shaders("instances"))
          Case Object3D::#Object3D_Null
            child\Setup(*ctx\shaders("wireframe"))
          Case Object3D::#Object3D_Curve
            child\Setup(*ctx\shaders("curve"))
          Case Object3D::#Object3D_Drawer
            child\Setup(*ctx\shaders("drawer"))
      EndSelect
      EndIf
      
      SetupChildren(*scn,child,*ctx)
    Next
    
    ; Setup Handle
    ;OHandle::Setup(*scn\handle,*ctx)
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
      
      child\Clean()
      CleanChildren(*child)
    Next
    
    Protected object.Object3D::IObject3D = *obj
    object\Clean()
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Object in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure CleanObject(*scn.Scene_t,*obj.Object3D::Object3D_t)
  
    Protected i
    Protected child.Object3D::IObject3D
    
    ForEach *obj\children()
      child = *obj\children()
      CleanChildren(child)
    Next
    
    Protected object.Object3D::IObject3D = *obj
    object\Clean()
  
  
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Scene in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure Clean(*scn.Scene_t)
  
    Protected i,j
    Protected child.Object3D::IObject3D
    Protected *model.Model::Model_t
    
    For i = 0 To CArray::GetCount(*scn\models)-1
      *model = CArray::GetValue(*scn\models,i)
      ForEach *model\children()
        child = *model\children()
        child\Clean()
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
    Protected *local.Transform::Transform_t
    ForEach *obj\children()
      child = *obj\children()
      If Not *obj\children()\initialized
        child\Setup(#Null)
      EndIf
      
      *local = *obj\children()\localT

      Object3D::UpdateTransform(*obj\children(),*obj\globalT)
      child\Update()
      
      *local = *obj\children()\localT
      UpdateChildren(*obj\children())
    Next
    
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Clean Scene in OpenGL Context
  ;---------------------------------------------------------------------------
  Procedure Update(*scn.Scene_t)
    If Not *scn : ProcedureReturn : EndIf
    If *scn\dirty
      Protected i
      Protected *root.Object3D::Object3D_t = *scn\root
      Protected child.Object3D::IObject3D
      Protected *c.Object3D::Object3D_t

      Matrix4::SetIdentity(*root\globalT\m)
      ForEach *root\children()
        child = *root\children()
        
        Object3D::UpdateTransform(child,*root\globalT)
        child\Update()
        UpdateChildren( child)
      Next
      
      *scn\dirty = #False
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Num 3D Objects
  ;---------------------------------------------------------------------------
  Procedure GetNbObjects(*scn.Scene_t)
    ProcedureReturn CArray::GetCount(*scn\objects)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Object By Name
  ;---------------------------------------------------------------------------
  Procedure GetObjectByName(*scn.Scene_t,name.s)
    Protected i
    Protected *o.Object3D::Object3D_t
    For i =0 To CArray::GetCount(*scn\objects)-1
      *o = CArray::GetValuePtr(*scn\objects,i)
      If *o\name = name
        ProcedureReturn *o
      EndIf
      
    Next
    ProcedureReturn #Null
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Num Polygons In Scene
  ;---------------------------------------------------------------------------
  Procedure GetNbPolygons(*scn.Scene_t)
    *scn\nbpolygons=0
    Protected i
    Protected *o.Object3D::Object3D_t
    Protected *m.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t
    For i=0 To CArray::GetCount(*scn\objects)-1
      *o = CArray::GetValue(*scn\objects,i)
      If *o\type = Object3D::#Object3D_Polymesh
        *m = *o
        *geom = *m\geom
        *scn\nbpolygons + *geom\nbpolygons
      EndIf
    Next
    
    ProcedureReturn *scn\nbpolygons
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Num Triangles In Scene
  ;---------------------------------------------------------------------------
  Procedure GetNbTriangles(*scn.Scene_t)
    *scn\nbtriangles=0
    Protected i
    Protected *o.Object3D::Object3D_t
    Protected *m.Polymesh::Polymesh_t
    Protected *geom.Geometry::PolymeshGeometry_t = *m\geom
    For i=0 To CArray::GetCount(*scn\objects)-1
      *o = CArray::GetValue(*scn\objects,i)
      If *o\type = Object3D::#Object3D_Polymesh
        *m = *o
         *geom = *m\geom
        *scn\nbtriangles + *geom\nbtriangles
      EndIf
    Next
    
    ProcedureReturn *scn\nbtriangles
  EndProcedure

  ;---------------------------------------------------------------------------
  ; Get Active Camera
  ;---------------------------------------------------------------------------
  Procedure GetActiveCamera(*scn.Scene_t)
    If Not *scn\camera
      *scn\camera = CArray::GetValue(*scn\cameras,0)
    EndIf
    ProcedureReturn *scn\camera
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Get Scene Root
  ;---------------------------------------------------------------------------
  Procedure GetRoot(*scn.Scene_t)
    ProcedureReturn *scn\root
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Save Scene
  ;---------------------------------------------------------------------------
  Procedure Save(*scn.Scene_t)
    Debug "------------------------ SAVE SCENE ------------------------------"
    Debug *scn
    Debug CArray::GetCount(*scn\models)
    Debug CArray::GetCount(*scn\lights)
    
    Debug "Scene Save Called"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Save SCene As
  ;---------------------------------------------------------------------------
  Procedure SaveAs(*scn.Scene_t, filename.s)
    Debug "Scene Save As Called"
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ; Select By ID
  ;---------------------------------------------------------------------------
  Procedure SelectByID(*scn.Scene_t,uuid.i)
    Protected i
    Protected *object.Object3D::Object3D_t
    Protected *out.Object3D::IObject3D = #Null
    For i=0 To CArray::GetCount(*scn\objects)-1
      *object = CArray::GetValue(*scn\objects,i)
      If id = *object\uniqueID
        *object\selected = #True
        *out = *object
        Break
      EndIf 
    Next 
    
    ;Update others selectivity
    If *out<>#Null
      For i=0 To CArray::GetCount(*scn\objects)-1
        *object = CArray::GetValue(*scn\objects,i)
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
  ; Draw
  ;---------------------------------------------------------------------------
  Procedure Draw(*scn.Scene_t,*shader.Program::Program_t,filter.i=-1)
   
    Protected i
    Protected obj.Object3D::IObject3D
    Protected *obj.Object3D::Object3D_t
    For i=0 To CArray::GetCount(*scn\objects)-1
      *obj = CArray::GetValuePtr(*scn\objects,i)
      If filter
        If *obj\type & filter
          obj = *obj
          glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,*obj\matrix)
          obj\Draw()
        EndIf
      Else
        obj\Draw()
      EndIf
    Next
    
    For i=0 To CArray::GetCount(*scn\helpers)-1
      *obj = CArray::GetValuePtr(*scn\helpers,i)
      If filter
        If *obj\type & filter
          obj = *obj
          glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,*obj\matrix)
          obj\Draw()
        EndIf
      Else
        obj\Draw()
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;  Destructor
  ;---------------------------------------------------------------------------
  Procedure Delete( *Me.Scene_t )
    Protected *model.Model::Model_t
    Protected i
    
    Root::Delete(*Me\root)
    CArray::Delete(*Me\models)
    CArray::Delete(*Me\objects)
    CArray::Delete(*Me\helpers)
    CArray::Delete(*Me\lights)
    CArray::Delete(*Me\cameras)
    CArray::Delete(*Me\selection)
    
 
    ; Deallocate Memory
    ClearStructure(*Me,Scene_t)
    FreeMemory( *Me )
    
    Scene::*current_scene = #Null
    PostEvent(Globals::#EVENT_GRAPH_CHANGED)
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;  CONSTRUCTORS
  ;---------------------------------------------------------------------------
  Procedure.i New( name.s = "ActiveScene")
    
    ; Allocate Object Memory
    Protected *Me.Scene_t = AllocateMemory( SizeOf(Scene_t) )
    Scene::*current_scene = *Me
    *Me\filename = name
    Object::INI(Scene)
    InitializeStructure(*Me,Scene_t)

    
    Protected Me.IScene = *Me
    
    ; Create Containers
    *Me\models = CArray::newCArrayPtr()
    *Me\objects = CArray::newCArrayPtr()
    *Me\cameras = CArray::newCArrayPtr()
    *Me\lights = CArray::newCArrayPtr()
    *Me\selection = CArray::newCArrayPtr()
    *Me\helpers = CArray::newCArrayPtr()

    ; Create Root
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
    
    ProcedureReturn( *Me )
  EndProcedure
  
  ;---------------------------------------------------------------------------
  ;  REFLECTION
  ;---------------------------------------------------------------------------
  Class::DEF( Scene )
EndModule
; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 517
; FirstLine = 513
; Folding = -------
; EnableThread
; EnableXP
; EnableUnicode