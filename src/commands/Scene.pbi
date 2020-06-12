XIncludeFile "../core/Commands.pbi"
XIncludeFile "../core/Saver.pbi"
XIncludeFile "../core/Loader.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/Scene.pbi"

;========================================================================
; SCENE COMMANDS
;========================================================================

;------------------------------------------------------------------------
; Select Object
;------------------------------------------------------------------------
DeclareModule SelectObjectCmd
  
  Structure SelectObjectCmd_t
    *object.Object3D::Object3D_t
    selected.b
  EndStructure
  
;   Declare GetInfo(*object.Object3D::Object3D_t)
;   Declare Clear(*info.SelectObjectCmd_t)
;   Declare Do(*info.SelectObjectCmd_t)
;   Declare Undo(*info.SelectObjectCmd_t)
  Declare Do(*object.Object3D::Object3D_t)
  
EndDeclareModule

Module SelectObjectCmd
  Procedure hlpGetInfo(*object.Object3D::Object3D_t)
    Protected *info.SelectObjectCmd_t = AllocateMemory(SizeOf(SelectObjectCmd_t))
    *info\object = *object
    *info\selected = *object\selected
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.SelectObjectCmd_t)
    FreeMemory(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.SelectObjectCmd_t)
    
    *info\object\selected = 1- *info\selected
    If *info\object\selected
      Scene::AddToSelection(Scene::*current_scene,*info\object)
    Else
      ;Scene::RemoveFromSelection(Scene::*current_scene,*info\object)
    EndIf
    
  EndProcedure
  
  Procedure hlpUndo(*info.SelectObjectCmd_t)
    *info\object\selected = *info\selected
  EndProcedure
  
  Procedure Do(*object.Object3D::Object3D_t)
    
    Protected *info = hlpGetInfo(*object)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule

;------------------------------------------------------------------------
; New Scene
;------------------------------------------------------------------------
DeclareModule NewSceneCmd
  Structure NewSceneCmd_t
    *scene.Scene::Scene_t
    save.b
  EndStructure
  
;   Declare GetInfo(*scene.Scene::Scene_t,save.b=#True)
;   Declare Clear(*info.NewSceneCmd_t)
;   Declare Do(*info.NewSceneCmd_t)
  Declare Do()
EndDeclareModule

Module NewSceneCmd
  Procedure hlpGetInfo(*scene.Scene::Scene_t,save.b=#True)
    Protected *info.NewSceneCmd_t = AllocateMemory(SizeOf(NewSceneCmd_t))
    *info\scene = *scene
    *info\save = save
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.NewSceneCmd_t)
    FreeMemory(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.NewSceneCmd_t)
    Protected *scn.Scene::Scene_t = *info\scene
    If *scn<>#Null And *info\save
      MessageRequester("Delete Scene","Delete SXcene")
      Scene::Save(*scn)
      Scene::Delete(*scn)
    EndIf

    Commands::Clear(Commands::*manager)
    Scene::*current_scene = Scene::New()
  
  EndProcedure
  
  Procedure hlpUndo(*info.NewSceneCmd_t)
    Debug "No undo for New SCene!!!"
  EndProcedure
  
  Procedure Do()
    Protected *info = hlpGetInfo(Scene::*current_scene,#True)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule

;------------------------------------------------------------------------
; Save Scene
;------------------------------------------------------------------------
DeclareModule SaveSceneCmd
  Structure SaveSceneCmd_t
    *scene.Scene::Scene_t
  EndStructure
  
 Declare Do()
EndDeclareModule


Module SaveSceneCmd
  Procedure hlpGetInfo(*scene.Scene::Scene_t)
    Protected *info.SaveSceneCmd_t = AllocateMemory(SizeOf(SaveSceneCmd_t))
    *info\scene = *scene
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.SaveSceneCmd_t)
    FreeMemory(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.SaveSceneCmd_t)
    MessageRequester("SaveSceneCmd","Called")
    Protected *scn.Scene::Scene_t = *info\scene
    If *scn<>#Null
      Protected path.s = SaveFileRequester("Save Scene","D:\Projects\RnD\PureBasic\Noodle\scenes\Save_001.scene","scene",0)
      ;Scene::Save(*scn,path)
      *saver.Saver::Saver_t = Saver::New(Scene::*current_scene,path)
      Saver::Save(*saver)
      MessageRequester("SaveSceneCmd","Saved")
      Saver::Delete(*saver)
    EndIf
  EndProcedure
  
  Procedure hlpUndo(*info.SaveSceneCmd_t)
    Debug "No undo for Save SCene!!!"
  EndProcedure
  
  Procedure Do()
    Protected *info = hlpGetInfo(Scene::*current_scene)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule

;------------------------------------------------------------------------
; Save Scene
;------------------------------------------------------------------------
DeclareModule LoadSceneCmd
  Structure LoadSceneCmd_t
    *scene.Scene::Scene_t
  EndStructure
  
 Declare Do()
EndDeclareModule


Module LoadSceneCmd
  Procedure hlpGetInfo(*scene.Scene::Scene_t)
    Protected *info.LoadSceneCmd_t = AllocateMemory(SizeOf(LoadSceneCmd_t))
    *info\scene = *scene
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.LoadSceneCmd_t)
    FreeMemory(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.LoadSceneCmd_t)
    MessageRequester("SaveSceneCmd","Called")
    Protected *scn.Scene::Scene_t = *info\scene
    If *scn<>#Null

      *loader.Loader::Loader_t = Loader::New()
      Loader::Load(*loader)
      MessageRequester("LoadSceneCmd","Loaded")
      Loader::Delete(*loader)
    EndIf
  EndProcedure
  
  Procedure hlpUndo(*info.LoadSceneCmd_t)
    Debug "No undo for Load SCene!!!"
  EndProcedure
  
  Procedure Do()
    Protected *info = hlpGetInfo(Scene::*current_scene)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule
; Procedure OScene_Save_Do()
;  
;   If *current_scene
;      MessageRequester("Noodle","Scene Save Called!!!")
;     ;Scene_Save(*current_scene)
;     Protected *saver.CSaver = newCSaver(*current_scene,"")
;     If *saver
;       OSaver_Save(*saver)
;       OSaver_Free(*saver)
;     EndIf
;     
;   Else
;     MessageRequester("Noodle Saver","No Current Scene! Save Aborted!!!")
;   EndIf
;   
; EndProcedure


;------------------------------------------------------------------------
; Create Polymesh
;------------------------------------------------------------------------

DeclareModule CreatePolymeshCmd
  Structure CreatePolymeshCmd_t
    *parent.Object3D::Object3D_t
    *mesh.Object3D::Object3D_t
    type.i
  EndStructure
  
;   Declare GetInfo(*parent.Object3D::Object3D_t,type.i)
;   Declare Clear(*info.CreatePolymeshCmd_t)
;   Declare Do(*info.CreatePolymeshCmd_t)
  Declare Do(*args.Arguments::Arguments_t)
EndDeclareModule

Module CreatePolymeshCmd
  Procedure hlpGetInfo(type.i)
    Protected *info.CreatePolymeshCmd_t = AllocateMemory(SizeOf(CreatePolymeshCmd_t))

    *info\type = type
    
    ProcedureReturn *info
  EndProcedure
  
  Procedure hlpClear(*info.CreatePolymeshCmd_t)
    FreeMemory(*info)  
  EndProcedure
  
  Procedure hlpDo(*info.CreatePolymeshCmd_t)
    Protected *parent.Object3D::Object3D_t
    
    If *parent=#Null
      If CArray::GetCount(Scene::*current_scene\selection)
        *selected.Object3D::Object3D_t = Selection::Get(Scene::*current_scene\selection)
        If *selected
          MessageRequester("CreatePolymeshCmd","Parent Selected "+*selected\class\name)
          *parent = *selected
        Else
          *parent = Scene::*current_scene\root
        EndIf
      Else
        *parent = Scene::*current_scene\root
      EndIf
      
      
      ;Something wrong exit!!
      If Not *parent : ProcedureReturn : EndIf
    EndIf
    *info\parent = *parent
    
    Protected *mesh.Polymesh::Polymesh_t
    Select *info\type
      Case Shape::#SHAPE_CUBE
        *mesh.Polymesh::Polymesh_t = Polymesh::New("Cube",Shape::#SHAPE_CUBE)
      Case Shape::#SHAPE_GRID
        *mesh.Polymesh::Polymesh_t  = Polymesh::New("Grid",Shape::#SHAPE_GRID) 
      Case Shape::#SHAPE_NONE
        *mesh.Polymesh::Polymesh_t  = Polymesh::New("Empty",Shape::#SHAPE_NONE) 
      Case Shape::#SHAPE_SPHERE
        *mesh.Polymesh::Polymesh_t  = Polymesh::New("Sphere",Shape::#SHAPE_SPHERE) 
      Case Shape::#SHAPE_BUNNY
        *mesh.Polymesh::Polymesh_t  = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
      Case Shape::#SHAPE_TORUS
        *mesh.Polymesh::Polymesh_t  = Polymesh::New("Torus",Shape::#SHAPE_TORUS) 
        
      Default
        ProcedureReturn
    EndSelect
    
    Scene::AddObject(Scene::*current_scene,*mesh)
    Object3D::AddChild(*parent,*mesh)
    PostEvent(Globals::#EVENT_GRAPH_CHANGED)
    *mesh\selected = #True
    *info\mesh = *mesh
  EndProcedure
  
  Procedure hlpUndo(*info.CreatePolymeshCmd_t)
    If *info\mesh
      Scene::RemoveObject(Scene::*current_scene,*info\mesh)
      Object3D::RemoveChild(*info\parent,*info\mesh)
      Polymesh::Delete(*info\mesh)
    EndIf
    
  EndProcedure
  
  Procedure Do(*args.Arguments::Arguments_t)

    Protected type.i = *args\args(0)\l
    
    Protected *info = hlpGetInfo(type)
    Commands::Add(Commands::*manager,@hlpDo(),@hlpUndo(),@hlpClear(),*info)
    Commands::Do(Commands::*manager)
  EndProcedure
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 5
; Folding = ------
; EnableXP
; EnableUnicode