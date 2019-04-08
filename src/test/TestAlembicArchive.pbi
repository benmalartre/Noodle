XIncludeFile "../core/Application.pbi"

EnableExplicit

Alembic::Init()
Global *manager.Alembic::IArchiveManager = Alembic::abc_manager

Global window = OpenWindow(#PB_Any,0,0,800,600,"Alembic Archive")
Global load = ButtonGadget(#PB_Any,0,0,800,25, "Choose Alembic File")
Global explorer = TreeGadget(#PB_Any,0,25,800,575)

Procedure.i LogABCArchive(path.s)
    If FileSize(path)>0 And GetExtensionPart(path) = "abc"
      
      Protected manager.Alembic::IArchiveManager = Alembic::abc_manager
      If manager<>#Null
        Protected archive.Alembic::IArchive = Alembic::OpenIArchive(path)
        ; Create a new Model
        Protected *model.Model::Model_t = Model::New("Alembic")
         If archive\IsValid()
          
          Define id = 1
          ;Create Objects contained in alembic file
          Define i,j = 0
          Protected *abc_obj.AlembicIObject::AlembicIObject_t
          Protected *abc_par.AlembicIObject::AlembicIObject_t = #Null
          Protected *child.Object3D::Object3D_t
          Protected identifier.s
          For i=0 To archive\GetNumObjects()-1
            *abc_obj = AlembicIObject::New(archive\GetObject(i))
            If *abc_obj <> #Null
              AlembicIObject::Init(*abc_obj,*abc_par)
              If AlembicIObject::Get3DObject(*abc_obj)<>#Null
                *abc_par = #Null
                *child = AlembicIObject::Get3DObject(*abc_obj)
                Object3D::AddChild(*model,*child)
              Else 
                *abc_par = *abc_obj
              EndIf
            EndIf
            
          Next i
        EndIf
        
      EndIf
      ProcedureReturn *model
    Else
      MessageRequester( "[Alembic LoadABCArchive] "," Invalid File !!!")
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
  
  ;       For i=0 To *abc_archive\GetNumObjects()-1
;         *abc_obj = *abc_archive\GetObject(i)(i)
;         ;Alembic::ABC_InitObject(*abc_obj\ptr,*abc_obj\type)
;         
;         AddGadgetItem(explorer,-1,*abc_obj\name)
;       
;         If *abc_obj\type = Alembic::#ABC_OBJECT_POLYMESH Or *abc_obj\type = Alembic::#ABC_OBJECT_POINTCLOUD
;           nbp = Alembic::ABC_GetNumProperties(*abc_obj\ptr)
;           Debug *abc_obj\name+" ---> Num Properties : "+Str(nbp)
;      
;           For j=0 To nbp-1
;             Protected *mem = Alembic::ABC_GetPropertyName(*abc_obj\ptr,j)
;             If *mem
;               pName = PeekS(*mem, -1, #PB_UTF8)
;               Debug pName
;               *prop = Alembic::ABC_GetProperty(*abc_obj\ptr,j)
;               If *prop
;                 Alembic::ABC_GetAttributeSampleDescription(*prop,1,@infos)
;                 Debug "PROPERTY "+pName 
;                 Debug "Name "+PeekS(@infos\name,-1,#PB_UTF8)
;                 ;Alembic::ABC_GetAttributeValueAtIndex(*prop,1,0)
;                 Debug "Nb Items : "+Str(infos\nbitems)
;                 Debug "Type : "+Str(infos\type)
;               EndIf
;               
;             Else
;               Debug "Property Invalid "+Str(i)
;             EndIf
;             
;           Next
;           
;         EndIf
;         
;       Next i

Define quit.b = #False
Define ev.i
Define manager.Alembic::IArchiveManager = Alembic::abc_manager
Repeat
  ev = WaitWindowEvent()
  If ev = #PB_Event_CloseWindow
    quit = #True
  ElseIf ev = #PB_Event_Gadget
    If EventGadget() = load And EventType() = #PB_EventType_LeftClick 
      ClearGadgetItems(explorer)
      Define path.s = OpenFileRequester("Alembic Archive","","Alembic (*.abc)|*.abc",0)
      Define *archive.Alembic::IArchive = LogABCArchive(path)
      
      If manager
        Debug manager\GetNumOpenArchives()
;         manager\CloseArchive(*archive)
      EndIf
      

    EndIf
    
  EndIf
  
  
Until quit = #True

Alembic::Terminate()

  

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 16
; FirstLine = 12
; Folding = -
; EnableXP
; EnableUnicode