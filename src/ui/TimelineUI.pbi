XIncludeFile "../core/Time.pbi"
XIncludeFile "../controls/Timeline.pbi"
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; TimelineUI Module Declaration
; -----------------------------------------
DeclareModule TimelineUI

  Structure TimelineUI_t Extends UI::UI_t
    *timeline.ControlTimeline::ControlTimeline_t
  EndStructure
  
  Interface ITimelineUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s="TimelineUI")
  Declare Delete(*Me.TimelineUI_t)
  Declare Resize(*Me.TimelineUI_t)
  Declare Draw(*Me.TimelineUI_t)
  Declare DrawPickImage(*Me.TimelineUI_t)
  Declare Pick(*Me.TimelineUI_t)
  Declare OnEvent(*Me.TimelineUI_t,event.i)
  Declare Draw(*Me.TimelineUI_t)

  DataSection 
    TimelineUIVT: 
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
      Data.i @DrawPickImage()
      Data.i @Pick()
    EndDataSection 

  Global CLASS.Class::Class_t
EndDeclareModule

; -----------------------------------------
; TimelineUI Module Implementation
; -----------------------------------------
Module TimelineUI
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent.View::View_t,name.s="TimelineUI")
    Protected *Me.TimelineUI_t = AllocateStructure(TimelineUI_t)
    Object::INI(TimelineUI)
    
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    *Me\name = "Timeline"
    
    ; ---[ Time line Control ]------------------
    *Me\gadgetID = CanvasGadget(#PB_Any, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY, #PB_Canvas_Keyboard)
    *Me\timeline = ControlTimeline::New(*Me,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    
    
    ; ---[ View Content ]-----------------------
    *Me\parent = *parent
    View::SetContent(*parent, *Me)
    OnEvent(*Me,#PB_Event_SizeWindow)
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.TimelineUI_t)
    ControlTimeline::Delete(*Me\timeline)
    Object::TERM(TimelineUI)
  EndProcedure

  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.TimelineUI_t)
    ControlTimeline::Draw(*Me\timeline)
  EndProcedure
  
  ; Draw Pick Image
  ;-------------------------------
  Procedure DrawPickImage(*Me.TimelineUI_t)
    
  EndProcedure
  
  ; Pick
  ;-------------------------------
  Procedure Pick(*Me.TimelineUI_t)
    
  EndProcedure
  
  ; Resize
  ;-------------------------------
  Procedure Resize(*Me.TimelineUI_t)
    
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.TimelineUI_t,event.i)
    Protected Me.ITimelineUI = *Me
    If event =  #PB_EventType_Resize Or event = #PB_Event_SizeWindow  
      Protected ev_data.Control::EventTypeDatas_t
      Protected *top.View::View_t = *Me\parent
      *Me\posX = *top\posX
      *Me\posY = *top\posY
      *Me\sizX = *top\sizX
      *Me\sizY = *top\sizY
      ev_data\x = *Me\posX
      ev_data\y = *Me\posY
      ev_data\width = *Me\sizX
      ev_data\height = *Me\sizY
      ResizeGadget(*Me\timeline\gadgetID,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_SizeWindow,@ev_data)
    ElseIf event = #PB_Event_Timer
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_Timer,#Null)
    Else
      ControlTimeline::OnEvent(*Me\timeline,EventType(),#Null)
    EndIf

    Draw(*Me)
   
  EndProcedure
  
  Class::DEF(TimelineUI)
  
EndModule






; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 116
; FirstLine = 74
; Folding = --
; EnableXP