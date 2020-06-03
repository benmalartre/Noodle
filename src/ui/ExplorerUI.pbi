XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Icon.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../controls/Explorer.pbi"
XIncludeFile "UI.pbi"
XIncludeFile "View.pbi"

; ======================================================================================
;   EXPLORER UI MODULE DECLARATION
; ======================================================================================
DeclareModule ExplorerUI

  Structure ExplorerUI_t Extends UI::UI_t
    
    *explorer.ControlExplorer::ControlExplorer_t
    
    *scene.Scene::Scene_t
  EndStructure
  
  Declare New(*parent.View::View_t,name.s="Explorer")
  Declare Delete(*Me.ExplorerUI_t)
  Declare Draw(*Me.ExplorerUI_t)
  Declare DrawPickImage(*Me.ExplorerUI_t)
  Declare Pick(*Me.ExplorerUI_t)
  Declare Resize(*Me.ExplorerUI_t)
  Declare OnEvent(*Me.ExplorerUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare Clear(*Me.ExplorerUI_t)
  Declare Setup(*Me.ExplorerUI_t)
  Declare Connect(*Me.ExplorerUI_t, *scene.Scene::Scene_t)
  
  DataSection 
    ExplorerUIVT: 
    Data.i @Delete()
    Data.i @Resize()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
    Data.i @OnEvent()
  EndDataSection 
  
  Global CLASS.Class::Class_t

EndDeclareModule

; ======================================================================================
;   EXPLORER UI MODULE IMPLEMENTATION
; ======================================================================================
Module ExplorerUI
  
  ; ====================================================================================
  ;   CALLBACKS
  ; ====================================================================================
  Procedure OnDeleteScene(*Me.ExplorerUI_t)
    ControlExplorer::Clear(*Me\explorer)
    ControlExplorer::Draw(*Me\explorer)
    Draw(*Me)
  EndProcedure
  Callback::DECLARECALLBACK(OnDeleteScene, Arguments::#PTR)
  
  Procedure OnNewScene(*Me.ExplorerUI_t)
    ControlExplorer::Fill(*Me\explorer, Scene::*current_scene)
    ControlExplorer::Draw(*Me\explorer)
    Draw(*Me)
  EndProcedure
  Callback::DECLARECALLBACK(OnNewScene, Arguments::#PTR)
  
  Procedure OnHierarchyChange(*Me.ExplorerUI_t)
    ControlExplorer::Clear(*Me\explorer)
    ControlExplorer::Fill(*Me\explorer, Scene::*current_scene)
    ControlExplorer::Draw(*Me\explorer)
    Draw(*Me)
  EndProcedure
  Callback::DECLARECALLBACK(OnHierarchyChange, Arguments::#PTR)
  
  Procedure OnSelectionChange(*Me.ExplorerUI_t)
    ControlExplorer::Clear(*Me\explorer)
    ControlExplorer::Fill(*Me\explorer, Scene::*current_scene)
    ControlExplorer::Draw(*Me\explorer)
    Draw(*Me)
  EndProcedure
  Callback::DECLARECALLBACK(OnSelectionChange, Arguments::#PTR)
  
  ; --------------------------------------------------------
  ;  Setup
  ; --------------------------------------------------------
  Procedure Setup(*Me.ExplorerUI_t)
  
  EndProcedure
  
  ; --------------------------------------------------------
  ;  Connect
  ; --------------------------------------------------------
  Procedure Connect(*Me.ExplorerUI_t, *scn.Scene::Scene_t)
    Signal::CONNECTCALLBACK(*scn\on_delete, OnDeleteScene, *Me)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Size
  ;---------------------------------------------------------
  Procedure GetSize(*Me.ExplorerUI_t)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Resize
  ;---------------------------------------------------------
  Procedure Resize(*Me.ExplorerUI_t)
    Protected *top.View::View_t = *Me\parent
    *Me\sizX = *top\sizX
    *Me\sizY = *top\sizY
    *Me\scrollMaxX = ImageWidth(*Me\explorer\imageID)
    *Me\scrollMaxY = 200
  ;   *Me\grp\Event(#PB_EventType_Resize,@ed)
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Draw
  ;---------------------------------------------------------
  Procedure Draw(*Me.ExplorerUI_t)
    StartDrawing(CanvasOutput(*Me\explorer\gadgetID))
    Box(0,0,*Me\explorer\sizX,*Me\explorer\sizY,UIColor::COLOR_MAIN_BG)
    DrawImage(ImageID(*Me\explorer\imageID),*Me\scrollx,*Me\scrolly)
    StopDrawing()
  EndProcedure
  
  ;---------------------------------------------------------
  ; Draw Pick Image
  ;---------------------------------------------------------
  Procedure DrawPickImage(*Me.ExplorerUI_t)

  EndProcedure
  
  ;---------------------------------------------------------
  ; Pick
  ;---------------------------------------------------------
  Procedure Pick(*Me.ExplorerUI_t)
      
  EndProcedure
  
  ;---------------------------------------------------------
  ; Clear
  ;---------------------------------------------------------
  Procedure Clear(*Me.ExplorerUI_t)
      
  EndProcedure

  
  ;---------------------------------------------------------
  ;  OnEvent
  ;---------------------------------------------------------
  Procedure OnEvent(*Me.ExplorerUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
    Define ev_datas.Control::EventTypeDatas_t
    Select event
      Case Globals::#EVENT_NEW_SCENE
        ControlExplorer::Fill(*Me\explorer,Scene::*current_scene) 
      Case #PB_EventType_Resize
        If *Me\parent
          Resize(*Me)
          
          ev_datas\width = *Me\sizX
          ev_datas\height = *Me\sizY
          ControlExplorer::OnEvent(*Me\explorer,#PB_Event_SizeWindow,ev_datas)
        EndIf
        
      Case #PB_Event_SizeWindow
        If *Me\parent
          Resize(*Me)
          Define ev_datas.Control::EventTypeDatas_t
          ev_datas\width = *Me\sizX
          ev_datas\height = *Me\sizY
          ControlExplorer::OnEvent(*Me\explorer,#PB_Event_SizeWindow,ev_datas)
        EndIf
    
      Case #PB_Event_Gadget
        ev_datas\xoff = *Me\scrollX
        ev_datas\yoff = *Me\scrollY
        ev_datas\width = *Me\sizX
        ev_datas\height = *Me\sizY
        ControlExplorer::OnEvent(*Me\explorer,event,#Null)
        If EventType() = #PB_EventType_MouseWheel
          UI::Scroll(*Me,#True)
        EndIf
    EndSelect
    
    Draw(*Me)
    
  EndProcedure
  
  ; ======================================================================================
  ;   DESTRUCTOR
  ; ======================================================================================
  Procedure Delete(*Me.ExplorerUI_t)
    ControlExplorer::Delete(*Me\explorer)
    FreeGadget(*Me\container)
    Object::TERM(ExplorerUI)
  EndProcedure
  
  ; ======================================================================================
  ;   CONSTRUCTOR
  ; ======================================================================================
  Procedure New(*view.View::View_t,name.s="Explorer")
    Protected *Me.ExplorerUI_t = AllocateMemory(SizeOf(ExplorerUI_t))
    Object::INI(ExplorerUI)
    
    *Me\container = ContainerGadget(#PB_Any,*view\posX,*view\posY,*view\sizX,*view\sizY)
    *Me\name = name
    *Me\sizX = *view\sizX
    *Me\sizY = *view\sizY
    *Me\scrollX = 0
    *Me\scrollY = 0
    *Me\scrollable = #True
    *Me\gadgetID = CanvasGadget(#PB_Any,0,0,*Me\sizX,*Me\sizY,#PB_Canvas_Keyboard)
    *Me\explorer = ControlExplorer::New(*Me,0,0,*view\sizX,*view\sizY)

    CloseGadgetList()
    
    View::SetContent(*view,*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(ExplorerUI)
EndModule
; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 213
; FirstLine = 161
; Folding = ---
; EnableXP