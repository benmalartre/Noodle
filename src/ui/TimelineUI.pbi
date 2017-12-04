XIncludeFile "../core/Time.pbi"
XIncludeFile "../controls/Timeline.pbi"
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; TimelineUI Module Declaration
; -----------------------------------------
DeclareModule TimelineUI
  UseModule UI
  
  Structure TimelineUI_t Extends UI_t
    *timeline.ControlTimeline::ControlTimeline_t
  EndStructure
  
  Interface ITimelineUI Extends IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s="TimelineUI")
  Declare Delete(*ui.TimelineUI_t)
  Declare Init(*ui.TimelineUI_t)
  Declare OnEvent(*ui.TimelineUI_t,event.i)
  Declare Term(*ui.TimelineUI_t)
  Declare Draw(*ui.TimelineUI_t)
  
  
  
  DataSection 
    TimelineUIVT: 
      Data.i @Init()
      Data.i @OnEvent()
      Data.i @Term()
  
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; TimelineUI Module Implementation
; -----------------------------------------
Module TimelineUI
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*parent.View::View_t,name.s="TimelineUI")
    Protected *Me.TimelineUI_t = AllocateMemory(SizeOf(TimelineUI_t))
    
    *Me\VT = ?TimelineUIVT
    ;*Me\classname = "TIMELINEUI"
    
    *Me\x = *parent\x
    *Me\y = *parent\y
    *Me\width = *parent\width
    *Me\height = *parent\height
   
    *Me\name = "Timeline"
    ;*Me\type = Globals::::#VIEW_TIMELINE
    
    ; ---[ View Content ]-----------------------
    *parent\content = *Me
    *Me\top = *parent
    
    ; ---[ Initialize Structures ]--------------
    InitializeStructure(*Me,TimelineUI_t)
    
    ; ---[ Time line Control ]------------------
    *Me\container = ContainerGadget(#PB_Any,*Me\x,*Me\y,*Me\width,*Me\height)
    Protected *m.ViewManager::ViewManager_t = *parent\manager
    *Me\timeline = ControlTimeline::New(#Null,*m\window,0,0,*Me\width,*Me\height)
    CloseGadgetList()
    
    OnEvent(*Me,#PB_Event_SizeWindow)
    
  
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*ui.TimelineUI_t)
    ClearStructure(*ui,TimelineUI_t)
    FreeMemory(*ui)
  EndProcedure

  
  ; Draw
  ;-------------------------------
  Procedure Draw(*ui.TimelineUI_t)
    ControlTimeline::Draw(*ui\timeline)
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*ui.TimelineUI_t)
    Debug "TimelineUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.TimelineUI_t,event.i)
    Protected Me.ITimelineUI = *Me
    
    CompilerIf #PB_Compiler_Version < 560
      If event =  Control::#PB_EventType_Resize Or event = #PB_Event_SizeWindow
    CompilerElse
      If event =  #PB_EventType_Resize Or event = #PB_Event_SizeWindow  
    CompilerEndIf
      Protected ev_data.Control::EventTypeDatas_t
      Protected *top.View::View_t = *Me\top
      *Me\x = *top\x
      *Me\y = *top\y
      *Me\width = *top\width
      *Me\height = *top\height
      ev_data\x = *Me\x
      ev_data\y = *Me\y
      ev_data\width = *Me\width
      ev_data\height = *Me\height
      ResizeGadget(*Me\timeline\gadgetID,0,0,*Me\width,*Me\height)
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_SizeWindow,@ev_data)
    ElseIf event = #PB_Event_Timer
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_Timer,#Null)
    Else
      ControlTimeline::OnEvent(*Me\timeline,EventType(),#Null)
    EndIf
   
    ;Redraw Timeline
  ;   Draw(*Me)
    
   ;SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Image,ImageID(*e\imageID))
    ;SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Image,ImageID(*e\imageID))
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*ui.TimelineUI_t)
    Debug "TimelineUI Term Called!!!"
  EndProcedure
  
  
EndModule







; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 124
; FirstLine = 106
; Folding = --
; EnableXP