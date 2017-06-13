

XIncludeFile "../core/Log.pbi"
XIncludeFile "../controls/Icon.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../controls/Explorer.pbi"
XIncludeFile "UI.pbi"
XIncludeFile "View.pbi"

; -----------------------------------------
; ExplorerUI Module Declaration
; -----------------------------------------
DeclareModule ExplorerUI
  



  Structure ExplorerUI_t Extends UI::UI_t
    
    *explorer.ControlExplorer::ControlExplorer_t
    
    *scene.Scene::Scene_t
  EndStructure
  
  Declare New(*parent.View::View_t,name.s="Explorer")
  Declare Delete(*Me.ExplorerUI_t)
  ;   Declare Draw(*Me.ExplorerUI_t)
  Declare Init()
  Declare Event(*Me.ExplorerUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare Term()
  Declare Clear(*Me.ExplorerUI_t)
  Declare Setup(*Me.ExplorerUI_t)
  
  DataSection 
    ExplorerUIVT: 
    Data.i @Init()
    Data.i @Event()
    Data.i @Term()
  EndDataSection 
  
  Global CLASS.Class::Class_t

  ; ----------------------------------------------------------------------------
  ;  FORWARD DECLARATION
  ; ----------------------------------------------------------------------------
  Declare Event(*Me.ExplorerUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare ConnectSignalsSlots(*Me.ExplorerUI_t)


EndDeclareModule

; -----------------------------------------
; ExplorerUI Module Implementation
; -----------------------------------------
Module ExplorerUI

  
  
  
  ; ----------------------------------------------------------------------------
  ;  IMPLEMENTATION
  ; ----------------------------------------------------------------------------
  
  ;  Setup
  ; ----------------------------------------
  Procedure Setup(*Me.ExplorerUI_t)
  
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
    Protected *top.View::View_t = *Me\top
    *Me\width = *top\width
    *Me\height = *top\height
    *Me\scrollmaxx = ImageWidth(*Me\explorer\imageID)
    *Me\scrollmaxy = 200
  ;   *Me\grp\Event(#PB_EventType_Resize,@ed)
    
  EndProcedure
  
  
  Procedure Draw(*Me.ExplorerUI_t)
    StartDrawing(CanvasOutput(*Me\explorer\gadgetID))
    Box(0,0,*Me\explorer\sizX,*Me\explorer\sizY,UIColor::COLOR_MAIN_BG)
    DrawImage(ImageID(*Me\explorer\imageID),*Me\scrollx,*Me\scrolly)
    StopDrawing()
  EndProcedure
  
  Procedure Clear(*Me.ExplorerUI_t)
      
  EndProcedure
  
   Procedure Init()
      
  EndProcedure 
  
  Procedure Term()
      
  EndProcedure 
  
;----------------------------------------
  ;  Event
  ;---------------------------------------------------
  Procedure Event(*e.ExplorerUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
    ;   GetItems(*e)
    
    If event = Globals::#EVENT_GRAPH_CHANGED
      ControlExplorer::Fill(*e\explorer,Scene::*current_scene) 
    EndIf
    
    If event =  Control::#PB_EventType_Resize Or event = #PB_Event_SizeWindow
  
      ;If *ev_data = #Null : ProcedureReturn #Null : EndIf
      If *e\top
        Resize(*e)
        Define ev_datas.Control::EventTypeDatas_t
        ev_datas\width = *e\width
        ev_datas\height = *e\height
        ControlExplorer::Event(*e\explorer,#PB_Event_SizeWindow,@ev_datas)

      EndIf
    
    ElseIf event = #PB_Event_Gadget
      ControlExplorer::Event(*e\explorer,event,#Null)
      If EventType() = #PB_EventType_MouseWheel
        UI::Scroll(*e,#True)
      EndIf
      
    EndIf
    
    Draw(*e)
    
  EndProcedure
  
  Procedure ConnectSignalsSlots(*Me.ExplorerUI_t)
    
  EndProcedure
  
  
  Procedure Delete(*Me.ExplorerUI_t)
    
  EndProcedure
  
  
  Procedure New(*view.View::View_t,name.s="Explorer")
    Protected *Me.ExplorerUI_t = AllocateMemory(SizeOf(ExplorerUI_t))
    InitializeStructure(*Me,ExplorerUI_t)
    Object::INI(ExplorerUI)
    
    *Me\container = ContainerGadget(#PB_Any,*view\x,*view\y,*view\width,*view\height)
    
    *Me\width = *view\width
    *Me\height = *view\height
    *Me\scrollx = 0
    *Me\scrolly = 0
    *Me\scrollable = #True
    *Me\explorer = ControlExplorer::New(*Me,0,0,*view\width,*view\height)
    *Me\gadgetID = *Me\explorer\gadgetID
    CloseGadgetList()
    
    View::SetContent(*view,*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(ExplorerUI)
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.41 LTS (Linux - x64)
; CursorPosition = 86
; FirstLine = 61
; Folding = ---
; EnableXP