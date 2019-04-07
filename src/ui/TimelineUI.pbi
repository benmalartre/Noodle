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
  Declare Delete(*Me.TimelineUI_t)
  Declare Init(*Me.TimelineUI_t)
  Declare OnEvent(*Me.TimelineUI_t,event.i)
  Declare Term(*Me.TimelineUI_t)
  Declare Draw(*Me.TimelineUI_t)
  
  
  
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
    
    Object::INI(TimelineUI)
    
    *Me\posX = *parent\x
    *Me\posY = *parent\y
    *Me\sizX = *parent\width
    *Me\sizY = *parent\height
   
    *Me\name = "Timeline"
    ;*Me\type = Globals::::#VIEW_TIMELINE
    
    ; ---[ View Content ]-----------------------
    *parent\content = *Me
    *Me\parent = *parent
    
    ; ---[ Time line Control ]------------------
    *Me\container = ContainerGadget(#PB_Any,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    *Me\timeline = ControlTimeline::New(*parent,0,0,*Me\sizX,*Me\sizY)
    *Me\gadgetID = *Me\timeline\gadgetID
    CloseGadgetList()
    
    OnEvent(*Me,#PB_Event_SizeWindow)
  
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.TimelineUI_t)
    ControlTimeline::Delete(*Me\timeline)
    FreeGadget(*Me\container)
    Object::TERM(TimelineUI)
  EndProcedure

  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.TimelineUI_t)
    ControlTimeline::Draw(*Me\timeline)
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.TimelineUI_t)
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
      Protected *top.View::View_t = *Me\parent
      *Me\posX = *top\x
      *Me\posY = *top\y
      *Me\sizX = *top\width
      *Me\sizY = *top\height
      ev_data\x = *Me\posX
      ev_data\y = *Me\posY
      ev_data\width = *Me\sizX
      ev_data\height = *Me\sizY
      *Me\gadgetID = *Me\timeline\gadgetID
      ResizeGadget(*Me\timeline\gadgetID,0,0,*Me\sizX,*Me\sizY)
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_SizeWindow,@ev_data)
    ElseIf event = #PB_Event_Timer
      ControlTimeline::OnEvent(*Me\timeline,#PB_Event_Timer,#Null)
    Else
      ControlTimeline::OnEvent(*Me\timeline,EventType(),#Null)
    EndIf
   
    ;Redraw Timeline
    Draw(*Me)
    
   ;SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Image,ImageID(*e\imageID))
    ;SetGadgetAttribute(*e\gadgetID,#PB_Canvas_Image,ImageID(*e\imageID))
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.TimelineUI_t)
    Debug "TimelineUI Term Called!!!"
  EndProcedure
  
  
EndModule







; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 115
; FirstLine = 85
; Folding = --
; EnableXP