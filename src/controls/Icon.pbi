
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "Button.pbi"

; ==============================================================================
;  CONTROL ICON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlIcon
  #STROKE_WIDTH     = 7
  #BACKGROUND_COLOR = -10172161
  #STROKE_COLOR     = -2302756
  #FILL_COLOR       = -1644826
  #BLACK_COLOR      = -14671840
  #WHITE_COLOR      = -2171170
  #ORANGE_COLOR     = -16736001
  #RED_COLOR        = -16776961
  #GREEN_COLOR      = -16711936
  #BLUE_COLOR       = -34696

  Macro IconType
    b
  EndMacro
  
  Enumeration
    #ICON_VISIBLE
    #ICON_INVISIBLE
    #ICON_PLAYFORWARD
    #ICON_PLAYBACKWARD
    #ICON_STOP
    #ICON_PREVIOUSFRAME
    #ICON_NEXTFRAME
    #ICON_FIRSTFRAME
    #ICON_LASTFRAME
    #ICON_LOOP
    #ICON_TRANSLATE
    #ICON_ROTATE
    #ICON_SCALE
    #ICON_SELECT
    #ICON_SPLITV
    #ICON_SPLITH
    #ICON_LOCKED
    #ICON_UNLOCKED
    #ICON_OP
    #ICON_TRASH
    #ICON_LAYER
    #ICON_PEN
    #ICON_FOLDER
    #ICON_FILE
    #ICON_OPEN
    #ICON_SAVE
    #ICON_HOME
    #ICON_BACK
    #ICON_WARNING
    #ICON_ERROR
    #ICON_OK
    #ICON_LAST
  EndEnumeration
  
  
  Global Dim IconName.s(#ICON_LAST)
  IconName(#ICON_VISIBLE) = "visible"
  IconName(#ICON_INVISIBLE) = "invisible"
  IconName(#ICON_PLAYFORWARD) = "playforward"
  IconName(#ICON_PLAYBACKWARD) = "playbackward"
  IconName(#ICON_STOP) = "stop"
  IconName(#ICON_FIRSTFRAME) = "previousframe"
  IconName(#ICON_LASTFRAME) = "nextframe"
  IconName(#ICON_FIRSTFRAME) = "firstframe"
  IconName(#ICON_LASTFRAME) = "lastframe"
  IconName(#ICON_LOOP) = "loop"
  IconName(#ICON_TRANSLATE) = "translate"
  IconName(#ICON_ROTATE) = "rotate"
  IconName(#ICON_SCALE) = "scale"
  IconName(#ICON_SELECT) = "select"
  IconName(#ICON_SPLITV) = "splitv"
  IconName(#ICON_SPLITH) = "splith"
  IconName(#ICON_LOCKED) = "locked"
  IconName(#ICON_UNLOCKED) = "unlocked"
  IconName(#ICON_OP) = "op"
  IconName(#ICON_TRASH) =  "trash"
  IconName(#ICON_LAYER) = "layer"
  IconName(#ICON_PEN) = "pen"
  IconName(#ICON_FOLDER) = "folder"
  IconName(#ICON_FILE) = "file"
  IconName(#ICON_OPEN) = "open"
  IconName(#ICON_SAVE) = "save"
  IconName(#ICON_HOME) = "home"
  IconName(#ICON_BACK) = "back"
  IconName(#ICON_WARNING) = "warning"
  IconName(#ICON_ERROR) = "error"
  IconName(#ICON_OK) = "ok"

    
  Prototype DrawIconImpl(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  
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
  
  Declare.d OffsetXOut(x.d, a.d, l.d)
  Declare.d OffsetYOut(y.d, a.d, l.d)
  Declare.d OffsetXIn(x.d, a.d, l.d)
  Declare.d OffsetYIn(y.d, a.d, l.d)
  
  Declare VisibleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare InvisibleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare PlayForwardIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare PlayBackwardIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare StopIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare PreviousFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare NextFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare FirstFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare LastFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare LoopIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)  
  Declare TranslateIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare RotateIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare ScaleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare SelectIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare SplitVIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)  
  Declare SplitHIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare LockedIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare UnlockedIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare OpIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare TrashIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare LayerIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare PenIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare FolderIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare FileIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare SaveIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)  
  Declare OpenIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare HomeIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare BackIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare WarningIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Declare ErrorIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  
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
  
  Procedure.d OffsetXOut(x.d, a.d, l.d)
    ProcedureReturn x + l*Cos(Radian(a - 90))
  EndProcedure
  
  Procedure.d OffsetYOut(y.d, a.d, l.d)
    ProcedureReturn y + l*Sin(Radian(a - 90))
  EndProcedure
  
  Procedure.d OffsetXIn(x.d, a.d, l.d)
    ProcedureReturn x + l*Cos(Radian(a + 90))
  EndProcedure
  
  Procedure.d OffsetYIn(y.d, a.d, l.d)
    ProcedureReturn y + l*Sin(Radian(a + 90))
  EndProcedure

Procedure VisibleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 10 50 C 30 20 70 20 90 50 "
  segments + "M 10 50 C 30 80 70 80 90 50 "
  segments + "M 23.1526 36.2483 L 13.8411 23.237 "
  segments + "M 50.0001 27.5 L 50.0001 11.5 "
  segments + "M 76.8475 36.2484 L 86.159 23.2371"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd)
  
  segments = "M 66 50 C 66 58.8366 58.8366 66 50 66 C 41.1635 66 34 58.8366 34 50 C 34 41.1635 41.1634 34 50 34 C 58.8365 34 66 41.1634 66 50 Z "
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd)
  
EndProcedure

Procedure InvisibleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 10 50 C 30 70 70 70 90 50 "
  segments + "M 24.436 59.7602 L 17.9105 74.3691 "
  segments + "M 50.0001 65 L 50.0001 81 "
  segments + "M 75.5642 59.7602 L 82.0896 74.369 "
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd)
EndProcedure

Procedure PlayForwardIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 20 L 80 50 L 20 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure PlayBackwardIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 80 20 L 80 80 L 20 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure StopIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure PreviousFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 75 20 L 75 80 L 25 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 25 20 L 25 80"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure NextFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 25 20 L 25 80 L 75 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 75 20 L 75 80"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FirstFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 80 20 L 80 80 L 40 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 60 20 L 60 80 L 20 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 20 20 L 20 80"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LastFrameIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 20 L 20 80 L 60 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 40 20 L 40 80 L 80 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 80 20 L 80 80"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LoopIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)  
  Define h.d = 8
  Define w.d = 4
  Define r.d = 30
  
  AddPathCircle(50,50,r, 60, -70, #PB_Path_CounterClockwise)
  Define l.d = PathLength()
  Define x1.d = PathPointX(l)
  Define y1.d = PathPointY(l)
  Define a.d = PathPointAngle(l)
  Define x2.d = 50 + r * Cos(Radian(-90))
  Define y2.d = 50 + r * Sin(Radian(-90))
  AddPathLine(OffsetXOut(x1, a, h), OffsetYOut(y1, a , h))
  AddPathLine(x2, y2)
  AddPathLine(OffsetXIn(x1, a, h-w*0.5), OffsetYIn(y1, a, h-w*0.5))
  AddPathLine(x1, y1)
  
  AddPathCircle(50,50,r, -120, 110, #PB_Path_CounterClockwise)
  Define l.d = PathLength()
  Define x1.d = PathPointX(l)
  Define y1.d = PathPointY(l)
  Define a.d = PathPointAngle(l)
  Define x2.d = 50 + r * Cos(Radian(90))
  Define y2.d = 50 + r * Sin(Radian(90))
  AddPathLine(OffsetXOut(x1, a, h), OffsetYOut(y1, a , h))
  AddPathLine(x2, y2)
  AddPathLine(OffsetXIn(x1, a, h-w*0.5), OffsetYIn(y1, a, h-w*0.5))
  AddPathLine(x1, y1)

  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure TranslateIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  
  Define segments.s
  segments + "M 50 15 L 40 25 L 60 25 Z"
  segments + "M 50 85 L 40 75 L 60 75 Z"
  segments + "M 15 50 L 25 40 L 25 60 Z"
  segments + "M 85 50 L 75 40 L 75 60 Z"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 35 35 L 65 35 L 65 65 L 35 65 Z"
  AddPathSegments(segments)
  
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure RotateIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define r.d = 35
  Define segments.s = "M 50 25 L 75 50 L 50 75 L 25 50 Z"
  AddPathSegments(segments)

  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)

  AddPathCircle(50,50,r, 0, 300)
  Define l.d = PathLength()
  
  Define x.d = PathPointX(l)
  Define y.d = PathPointY(l)
  Define a.d = PathPointAngle(l)
  MovePathCursor(r*Cos(Radian(320)) + 50, r*Sin(Radian(320)) + 50)
  AddPathLine(OffsetXOut(x, a, 5), OffsetYOut(y, a, 5))
  AddPathLine(OffsetXIn(x, a, 5), OffsetYIn(y, a, 5))
  
  ClosePath()
  
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure ScaleIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 80 L 20 50 L 50 50 L 50 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
  AddPathSegments(segments)
  DashPath(thickness, 2 * thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 70 20 L 80 20 L 80 30 M 80 20 L 60 40 M 60 30 L 60 40 L 70 40"
  AddPathSegments(segments)
  ;   MovePathCursor(
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SelectIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  MovePathCursor(40,15)
  AddPathLine(40,70)
  AddPathLine(50,60)
  AddPathLine(60,85)
  AddPathLine(70,80)
  AddPathLine(60,55)
  AddPathLine(75,55)
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SplitVIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 20 L 40 20 L 40 80 L 20 80 Z"
  segments + "M 60 20 L 80 20 L 80 80 L 60 80 Z"
  segments + "M 50 10 L 50 90"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SplitHIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 20 L 80 20 L 80 40  L 20 40 Z"
  segments + "M 20 60 L 80 60 L 80 80 L 20 80 Z"
  segments + "M 10 50 L 90 50"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LockedIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  AddPathBox(20,50,60,40)
  MovePathCursor(55, 80)
  AddPathLine(55,80)
  AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
  AddPathLine(45,80)
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  MovePathCursor(25, 50)
  AddPathLine(25, 45)
  AddPathCircle(50, 45, 25, 180, 0, #PB_Path_Connected)
  AddPathLine(75, 50)
  AddPathLine(65, 50)
  AddPathCircle(50, 45, 15, 0, 180, #PB_Path_Connected|#PB_Path_CounterClockwise)
  AddPathLine(35,50)
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
EndProcedure

Procedure UnlockedIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  
  AddPathBox(20,50,60,40)
  MovePathCursor(55, 80)
  AddPathLine(55,80)
  AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
  AddPathLine(45,80)
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
  AddPathCircle(50, 35, 25, 200, 0)
  AddPathLine(75,50)
  AddPathLine(65,50)
  AddPathCircle(50,35, 15, 0, 200, #PB_Path_Connected|#PB_Path_CounterClockwise)
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure OpIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  AddPathCircle(50,50,8)
  
  MovePathCursor(80,50)
  
  Define l.f = 360 / 16
  For i =0 To 15
    If i % 2 = 0
      AddPathCircle(50,50,30, i*l+2,(i+1)*l-2, #PB_Path_Connected)
    Else
      AddPathCircle(50,50,24, i*l,(i+1)*l, #PB_Path_Connected)
    EndIf
  Next
  ClosePath()
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure TrashIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 25 30 L 30 80 L 70 80 L 75 30 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments.s = "M 20 25 L 80 25"
  segments + "M 40 25 L 42 15 L 58 15 L 60 25" 
  segments + "M 35 40 L 38 70 M 50 40 L 50 70 M 65 40 L 62 70"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LayerIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 80 L 60 80 L 80 60 L 40 60 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments.s = "M 20 70 L 60 70 L 80 50 L 40 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
;   segments.s = "M 20 60 L 60 60 L 80 40 L 40 40 Z"
;   AddPathSegments(segments)
;   VectorSourceColor(FILL_COLOR)
;   FillPath(#PB_Path_Preserve)
;   VectorSourceColor(STROKE_COLOR)
;   StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 70 20 L 70 40 M 60 30 L 80 30"
  AddPathSegments(segments)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure PenIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 80 L 20 60 L 40 70 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments.s = "M 20 60 L 50 20 L 70 30 L 40 70 Z"
  AddPathSegments(segments)
  VectorSourceColor(#ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FolderIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s = "M 20 30 L 20 80 L 80 80 L 80 20 L 50 20 L 50 30 Z"
  AddPathSegments(segments)
  segments.s = "M 80 80 L 90 40 L 80 40"
  AddPathSegments(segments)
  VectorSourceColor(#ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FileIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SaveIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments = "M 50 50 L 50 30 L 40 30 L 60 10 L 80 30 L 70 30 L 70 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(#ORANGE_COLOR)
  FillPath()
EndProcedure

Procedure OpenIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments = "M 50 10 L 50 30 L 40 30 L 60 50 L 80 30 L 70 30 L 70 10 Z"
  AddPathSegments(segments)
  VectorSourceColor(#ORANGE_COLOR)
  FillPath()
EndProcedure

Procedure HomeIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 25 80 L 42 80 L 42 50 L 58 50  L 58 80 L 75 80"
  segments + "L 75 40 L 85 40 L 50 20 L 15 40 L 25 40 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure BackIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 20 40 L 40 60 L 40 50 L 60 50 L 60 80"
  segments + "L 80 80 L 80 30 L 40 30 L 40 20 Z"
  AddPathSegments(segments)
  VectorSourceColor(fill)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(stroke)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure WarningIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  Define segments.s
  segments + "M 15 80 L 85 80 L 50 20 Z"
  AddPathSegments(segments)
  VectorSourceColor(#ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  Define segments.s = "M 50 40 L 50 60 M 50 70 L 50 70"
  AddPathSegments(segments)
  VectorSourceColor(#BLACK_COLOR)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure ErrorIcon(fill.i=#FILL_COLOR, stroke.i=#STROKE_COLOR, thickness.i=#STROKE_WIDTH)
  AddPathCircle(50, 50, 35)
  VectorSourceColor(#RED_COLOR)
  FillPath(#PB_Path_Preserve)
  Define segments.s = "M 35 35 L 65 65 M 35 65 L 65 35"
  AddPathSegments(segments)
  VectorSourceColor(#WHITE_COLOR)
  StrokePath(thickness, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
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
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 939
; FirstLine = 918
; Folding = --------
; EnableXP