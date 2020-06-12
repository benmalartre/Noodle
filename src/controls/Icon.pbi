
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "Button.pbi"

; ==============================================================================
;  CONTROL ICON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlIcon
  Macro IconType
    b
  EndMacro
  
  Enumeration
    #Icon_Custom = -1
    #Icon_Default = 0
    #Icon_Close
    #Icon_First
    #Icon_Previous
    #Icon_Back
    #Icon_Stop
    #Icon_Play
    #Icon_Next
    #Icon_Last
    #Icon_Loop
    #Icon_Record
    #Icon_Cross
    
    #Icon_Max
  EndEnumeration
  
  Global Dim s_gui_controls_icon_name.s(#Icon_Max)
  s_gui_controls_icon_name(0) = "default"
  s_gui_controls_icon_name(1) = "close"
  s_gui_controls_icon_name(2) = "first"
  s_gui_controls_icon_name(3) = "previous"
  s_gui_controls_icon_name(4) = "back"
  s_gui_controls_icon_name(5) = "stop"
  s_gui_controls_icon_name(6) = "play"
  s_gui_controls_icon_name(7) = "next"
  s_gui_controls_icon_name(8) = "last"
  s_gui_controls_icon_name(9) = "loop"


  ; ----------------------------------------------------------------------------
  ;  Object ( ControlIcon_t )
  ; ----------------------------------------------------------------------------
  ;{
  Structure ControlIcon_t Extends Control::Control_t
    icon.i
    label.s
    value.i
    over.i
    down.i
    scale.f
    *item.Vector::Item_t
    *on_click.Signal::Signal_t
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlIcon Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares
  ; ----------------------------------------------------------------------------
  Declare New( *parent.Control::Control_t ,name.s,icon.IconType = #Icon_Default, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
  Declare Delete(*Me.ControlIcon_t)
  Declare OnEvent( *Me.ControlIcon_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  Declare EmptyIcon(*Me.ControlIcon_t)
  Declare PlayIcon(*Me.ControlIcon_t)
  Declare StopIcon(*Me.ControlIcon_t)
  Declare RecordIcon(*Me.ControlIcon_t)
  Declare CrossIcon(*Me.ControlIcon_t)

  ; ============================================================================
  ;  VTABLE ( CObject + CControl + ControlIcon )
  ; ============================================================================
  
  DataSection
    ControlIconVT:
    Data.i @OnEvent()            ; mandatory override
    Data.i @Delete()             ; mandatory override
  EndDataSection

  Global CLASS.Class::Class_t
EndDeclareModule


; ==============================================================================
;  CONTROL ICON MODULE IMPLEMENTATION 
; ==============================================================================
Module ControlIcon
 
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlIcon_t, xoff.i = 0, yoff.i = 0 )
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Reset Clipping ]-----------------------------------------------------
    SaveVectorState()
    TranslateCoordinates(xoff, yoff)
    
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable 
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\value < 0
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_NONE)
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_NONE)
      EndIf
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down Or ( *Me\value < 0 )
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_OVER)
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_OVER)
      EndIf
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\value < 0 Or *Me\down
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_SELECTED_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_NONE)
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        Vector::DrawIcon(*Me\item, Vector::#STATE_NONE)
      EndIf
    EndIf
    RestoreVectorState()
 
  EndProcedure

  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlIcon_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        ; ...[ Draw Control ]...................................................
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        ; ...[ Update Topology ]................................................
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        If #PB_Ignore <> *ev_data\height : *Me\sizY = *ev_data\height : EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  MouseEnter
      ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseLeave
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
        If *Me\visible And *Me\enable
          If *Me\down
            If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
              If *Me\over : *Me\over = #False : Control::Invalidate(*Me) : EndIf
            Else
              If Not *Me\over : *Me\over = #True : Control::Invalidate(*Me) : EndIf
            EndIf
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
          *Me\down = #False
          If *Me\over And ( *Me\options & #PB_Button_Toggle )
            *Me\value*-1
          EndIf
          Control::Invalidate(*Me)
          If *Me\over
            Signal::Trigger(*Me\on_click,Signal::#SIGNAL_TYPE_PING)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Enable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
      ; ------------------------------------------------------------------------
      ;  Disable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  ;}
  
  ; ============================================================================
  ;  EMPTY ICON
  ; ============================================================================
  Procedure EmptyIcon(*Me.ControlIcon_t)
    Protected *icon.Vector::Item_t = *Me\item
    Vector::ClearAtoms(*icon)
    *icon\type = Vector::#ATOM_CUSTOM
    *icon\filled = #True
    *icon\segments = ""
    *icon\stroke_color = RGBA(0,200,64,255)
    *icon\fill_color = RGBA(0,255,32,255)
    *icon\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *icon\stroke_width = 12
  EndProcedure
  
  ; ============================================================================
  ;  PLAY ICON
  ; ============================================================================
  Procedure PlayIcon(*Me.ControlIcon_t)
    Protected *icon.Vector::Item_t = *Me\item
    Vector::ClearAtoms(*icon)
    *icon\type = Vector::#ATOM_CUSTOM
    *icon\filled = #True
    *icon\segments = "M 20 20 L 80 50 L 20 80 Z"
    *icon\stroke_color = RGBA(0,200,64,255)
    *icon\fill_color = RGBA(0,255,32,255)
    *icon\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *icon\stroke_width = 12
  EndProcedure
  
  ; ============================================================================
  ;  STOP ICON
  ; ============================================================================
  Procedure StopIcon(*Me.ControlIcon_t)
     Protected *icon.Vector::Item_t = *Me\item
    Vector::ClearAtoms(*icon)
    *icon\type = Vector::#ATOM_CUSTOM
    *icon\filled = #True
    *icon\segments = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
    *icon\stroke_color = RGBA(220,32,0,255)
    *icon\fill_color = RGBA(255,32,0,255)
    *icon\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *icon\stroke_width = 12
  EndProcedure
  
  ; ============================================================================
  ;  RECORD ICON
  ; ============================================================================
  Procedure RecordIcon(*Me.ControlIcon_t)
     Protected *icon.Vector::Item_t = *Me\item
    Vector::ClearAtoms(*icon)
    *icon\type = Vector::#ATOM_CUSTOM
    *icon\filled = #True
    *icon\segments = "M 80 50 C 80 66.5685 66.5685 80 50 80 C 33.4315 80 20 66.5686 20 50 C 20 33.4315 33.4314 20 50 20 C 66.5685 20 80 33.4314 80 50 Z"
    *icon\stroke_color = RGBA(220,32,0,255)
    *icon\fill_color = RGBA(255,32,0,255)
    *icon\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *icon\stroke_width = 12
  EndProcedure
  
  ; ============================================================================
  ;  CROSS ICON
  ; ============================================================================
  Procedure CrossIcon(*Me.ControlIcon_t)
    Protected *icon.Vector::Item_t = *Me\item
    Vector::ClearAtoms(*icon)
    *icon\type = Vector::#ATOM_CUSTOM
    *icon\filled = #False
    *icon\segments = ""
    
    Define *item.Vector::Item_t = Vector::AddCustom(*icon)
    *item\filled = #False
    *item\stroke_color = RGBA(0,0,0,255)
    *item\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *item\stroke_width = 12
    *item\segments = "M 20 20 L 80 80"
    
    *item.Vector::Item_t = Vector::AddCustom(*icon)
    *item\filled = #False
    *item\stroke_color = RGBA(0,0,0,255)
    *item\stroke_style = #PB_Path_RoundCorner | #PB_Path_RoundEnd
    *item\stroke_width = 12
    *item\segments = "M 20 80 L 80 20"
  EndProcedure
  
  ; ============================================================================
  ;  IMPLEMENTATION ( ControlIcon )
  ; ============================================================================
  ;{
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlIcon_t )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    ClearStructure(*Me,ControlIcon_t)
    FreeMemory( *Me )
    
  EndProcedure

  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New( *parent.Control::Control_t ,name.s,icon.IconType = #Icon_Default, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlIcon_t = AllocateMemory( SizeOf(ControlIcon_t) )
    
;     *Me\VT = ?ControlIconVT
;     *Me\classname = "CONTROLICON"
    Object::INI(ControlIcon)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type       = Control::#ICON
    *Me\name       = name
    *Me\parent     = *parent
    *Me\gadgetID   = *parent\gadgetID
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\fixedX     = #True
    *Me\fixedY     = #True
    *Me\percX      = -1
    *Me\percY      = -1
    *Me\options    = options
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\value      = 1
    *Me\label      = name
    *Me\icon       = icon 
    *Me\scale      = ((width + height) * 0.5) / 100.0
    *Me\item       = Vector::NewItem(Vector::#ATOM_CUSTOM)
    
    Select *Me\icon
      Case #Icon_Play
        PlayIcon(*Me)
      Case #Icon_Stop
        StopIcon(*Me)
      Case #Icon_Record
        RecordIcon(*Me)
      Default
        CrossIcon(*Me)
    EndSelect
  
    
    If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
    
    ; ---[ Signals ]------------------------------------------------------------
    *Me\on_click = Object::NewSignal(*Me, "OnClick")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlIcon )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 148
; FirstLine = 109
; Folding = ---
; EnableXP