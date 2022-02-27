
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Icons.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "Button.pbi"

; ==============================================================================
;  CONTROL ICON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlIcon
  UseModule Icon
  
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
    draw.DrawIconImpl
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
  Declare New( *parent.Control::Control_t ,name.s,icon.IconType = #ICON_VISIBLE, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
  Declare Delete(*Me.ControlIcon_t)
  Declare OnEvent( *Me.ControlIcon_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
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
  UseModule Icon
  Procedure GetDrawImplementation(icon.i)
    Select icon
      Case #ICON_VISIBLE
        ProcedureReturn @VisibleIcon()  
      Case #ICON_INVISIBLE
        ProcedureReturn @InvisibleIcon()
      Case #ICON_PLAYFORWARD
        ProcedureReturn @PlayForwardIcon()
      Case #ICON_PLAYBACKWARD
        ProcedureReturn @PlayBackwardIcon()
      Case #ICON_STOP
        ProcedureReturn @StopIcon()
      Case #ICON_PREVIOUSFRAME
        ProcedureReturn @PreviousFrameIcon()
      Case #ICON_NEXTFRAME
        ProcedureReturn @NextFrameIcon()
      Case #ICON_FIRSTFRAME
        ProcedureReturn @FirstFrameIcon()
      Case #ICON_LASTFRAME
        ProcedureReturn @LastFrameIcon()
      Case #ICON_LOOP
        ProcedureReturn @LoopIcon()
      Case #ICON_TRANSLATE
        ProcedureReturn @TranslateIcon()
      Case #ICON_ROTATE
        ProcedureReturn @RotateIcon()
      Case #ICON_SCALE
        ProcedureReturn @ScaleIcon()
      Case #ICON_BRUSH
        ProcedureReturn @BrushIcon()
      Case #ICON_PEN
        ProcedureReturn @PenIcon()
      Case #ICON_SELECT
        ProcedureReturn @SelectIcon()
      Case #ICON_SPLITH
       ProcedureReturn @SplitHIcon()
      Case #ICON_SPLITV
       ProcedureReturn @SplitVIcon()
      Case #ICON_LOCKED
       ProcedureReturn @LockedIcon()
      Case #ICON_UNLOCKED
       ProcedureReturn @LockedIcon()
      Case #ICON_OP
       ProcedureReturn @OpIcon()
      Case #ICON_TRASH
        ProcedureReturn @TrashIcon()
      Case #ICON_STAGE
       ProcedureReturn @StageIcon()
      Case #ICON_LAYER
       ProcedureReturn @LayerIcon()
      Case #ICON_PEN
       ProcedureReturn @PenIcon()
      Case #ICON_FOLDER
       ProcedureReturn @FolderIcon()
      Case #ICON_FILE
       ProcedureReturn @FileIcon()
      Case #ICON_SAVE
       ProcedureReturn @SaveIcon()
      Case #ICON_OPEN
       ProcedureReturn @OpenIcon()
      Case #ICON_HOME
       ProcedureReturn @HomeIcon()
      Case #ICON_BACK
       ProcedureReturn @BackIcon()
      Case #ICON_WARNING
       ProcedureReturn @WarningIcon()
      Case #ICON_ERROR
        ProcedureReturn @ErrorIcon()
      Case #ICON_OK
        ProcedureReturn @OKIcon()
      Case #ICON_EXPENDED
        ProcedureReturn @ExpendedIcon()
      Case #ICON_CONNECTED
        ProcedureReturn @ConnectedIcon()
      Case #ICON_COLLAPSED
        ProcedureReturn @CollapsedIcon()
      Case #ICON_ARROWLEFT
        ProcedureReturn @ArrowLeftIcon()
      Case #ICON_ARROWRIGHT
        ProcedureReturn @ArrowRightIcon()
      Case #ICON_ARROWUP
        ProcedureReturn @ArrowUpIcon()
      Case #ICON_ARROWDOWN
       ProcedureReturn @ArrowDownIcon()
    EndSelect
  EndProcedure
  
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
        *Me\draw()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        *Me\draw()
      EndIf
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down Or ( *Me\value < 0 )
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        *Me\draw()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        *Me\draw()
      EndIf
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\value < 0 Or *Me\down
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_SELECTED_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        *Me\draw()
      ; ---[ Up ]---------------------------------------------------------------
      Else
        Vector::RoundBoxPath(0, 0, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        ScaleCoordinates(*Me\scale, *Me\scale)
        *Me\draw()
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
  Procedure.i New( *parent.Control::Control_t ,name.s,icon.IconType = #ICON_VISIBLE, options.i = #False, value.i=#False , x.i = 0, y.i = 0, width.i = 32, height.i = 32 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlIcon_t = AllocateMemory( SizeOf(ControlIcon_t) )
    
;     *Me\VT = ?ControlIconVT
;     *Me\classname = "CONTROLICON"
    Object::INI(ControlIcon)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\draw       = GetDrawImplementation(icon)
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
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 13
; FirstLine = 10
; Folding = --
; EnableXP