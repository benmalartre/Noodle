XIncludeFile "../core/Application.pbi"

EnableExplicit

Alembic::Init()
Global *manager.AlembicManager::AlembicManager_t = Alembic::*abc_manager

Global window = OpenWindow(#PB_Any,0,0,800,600,"Alembic Archive")
Global load = ButtonGadget(#PB_Any,0,0,800,25, "Choose Alembic File")
Global explorer = TreeGadget(#PB_Any,0,25,800,575)

Procedure.i LogABCArchive(path.s)
  If FileSize(path)>0 And GetExtensionPart(path) = "abc"
    
    If Alembic::*abc_manager<>#Null
      Protected *abc_manager.AlembicManager::AlembicManager_t = Alembic::*abc_manager
      Global *abc_archive.AlembicArchive::AlembicArchive_t = AlembicManager::OpenArchive(*abc_manager,path)
      Global startframe = Alembic::ABC_GetStartFrame(*abc_archive\archive)
      Global endframe = Alembic::ABC_GetEndFrame(*abc_archive\archive)
      Global numsamples = Alembic::ABC_GetMaxNumSamplesForTimeSamplingIndex(*abc_archive\archive,0)
      Global numsamples2 = Alembic::ABC_GetMaxNumSamplesForTimeSamplingIndex(*abc_archive\archive,1)
      ; CreateObject List
      Protected i,j
      Protected *abc_obj.AlembicObject::AlembicObject_t
      Protected *abc_par.AlembicObject::AlembicObject_t = #Null
      Protected *prop.Alembic::ABC_property
      Protected nbp = 0

      Protected pName.s
      Protected infos.Alembic::ABC_Attribute_Sample_Infos
            
      For i=0 To AlembicArchive::GetNbObjects(*abc_archive)-1
        *abc_obj = AlembicArchive::CreateObjectByID(*abc_archive,i)
        ;Alembic::ABC_InitObject(*abc_obj\ptr,*abc_obj\type)
        
        AddGadgetItem(explorer,-1,*abc_obj\name)
      
        If *abc_obj\type = Alembic::#ABC_OBJECT_POLYMESH Or *abc_obj\type = Alembic::#ABC_OBJECT_POINTCLOUD
          nbp = Alembic::ABC_GetNumProperties(*abc_obj\ptr)
          Debug *abc_obj\name+" ---> Num Properties : "+Str(nbp)
     
          For j=0 To nbp-1
            Protected *mem = Alembic::ABC_GetPropertyName(*abc_obj\ptr,j)
            If *mem
              pName = PeekS(*mem, -1, #PB_UTF8)
              Debug pName
              *prop = Alembic::ABC_GetProperty(*abc_obj\ptr,j)
              If *prop
                Alembic::ABC_GetAttributeSampleDescription(*prop,1,@infos)
                Debug "PROPERTY "+pName 
                Debug "Name "+PeekS(@infos\name,-1,#PB_UTF8)
                ;Alembic::ABC_GetAttributeValueAtIndex(*prop,1,0)
                Debug "Nb Items : "+Str(infos\nbitems)
                Debug "Type : "+Str(infos\type)
              EndIf
              
            Else
              Debug "Property Invalid "+Str(i)
            EndIf
            
          Next
          
        EndIf
        
      Next i

      
;       ; Create a new Model
;       Protected *model.Model::Model_t = Model::New("Alembic")
;       
;       ;Create Objects contained in alembic file
;       Define i
;       Protected *abc_obj.AlembicObject::AlembicObject_t
;       Protected *abc_par.AlembicObject::AlembicObject_t = #Null
;       Protected *child.Object3D::Object3D_t
;       For i=0 To AlembicArchive::GetNbObjects(*abc_archive)-1
;         Debug "Alembic Object ID "+Str(i)
;         *abc_obj = AlembicArchive::CreateObjectByID(*abc_archive,i)
;         If *abc_obj <> #Null
;           AlembicObject::Init(*abc_obj,*abc_par)
;           If AlembicObject::Get3DObject(*abc_obj)<>#Null
;             *abc_par = #Null
;             *child = AlembicObject::Get3DObject(*abc_obj)
;             Object3D::AddChild(*model,*child)
;             
;           Else 
;             *abc_par = *abc_obj
;           EndIf
;         EndIf
;         
;       Next i
    Else
      Debug "[Alembic] : Invalid Manager"
    EndIf
    ProcedureReturn *abc_archive
  Else
    Debug "[Alembic Archive] : Invalid File"
    ProcedureReturn #Null
  EndIf
  
EndProcedure

Define quit.b = #False
Define ev.i
Repeat
  ev = WaitWindowEvent()
  If ev = #PB_Event_CloseWindow
    quit = #True
  ElseIf ev = #PB_Event_Gadget
    If EventGadget() = load And EventType() = #PB_EventType_LeftClick 
      ClearGadgetItems(explorer)
      Define path.s = OpenFileRequester("Alembic Archive","","Alembic (*.abc)|*.abc",0)
      Define *archive.AlembicArchive::AlembicArchive_t = LogABCArchive(path)
  
      If *archive <> #Null
        Debug AlembicManager::GetNumOpenArchives(*manager)
        AlembicManager::CloseArchive(*manager, *archive)
      EndIf
    EndIf
    
  EndIf
  
  
Until quit = #True

Alembic::Terminate()

  

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 29
; Folding = -
; EnableXP
; EnableUnicode