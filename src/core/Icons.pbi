
XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Vector.pbi"

; ==============================================================================
;  CONTROL ICON MODULE DECLARATION
; ==============================================================================
DeclareModule Icon
  #STROKE_WIDTH           = 4
  #STROKE_STYLE           = #PB_Path_SquareEnd
  #BACKGROUND_COLOR       = -10172161 ; RGBA(255,200,100,255)
  #STROKE_COLOR_DEFAULT   = -986896   ; RGBA(240,240,240,255)
  #STROKE_COLOR_SELECTED  = -12566464 ; RGBA(64, 64, 64, 255)
  #STROKE_COLOR_DISABLED  = -6908266  ; RGBA(150,150,150,255)
  #FILL_COLOR_DEFAULT     = -1644826  ; RGBA(230,230,230,255)
  #FILL_COLOR_SELECTED    = -10461088 ; RGBA(96, 96, 96, 255)
  #FILL_COLOR_DISABLED    = -8355712  ; RGBA(128,128,128,255)
  #BLACK_COLOR            = -14671840 ; RGBA(32,  32, 32,255)
  #WHITE_COLOR            = -2171170  ; RGBA(222,222,222,255)
  #ORANGE_COLOR           = -16736001 ; RGBA(255,160,0,  255)
  #RED_COLOR              = -16776961 ; RGBA(255,120,120,255)
  #GREEN_COLOR            = -16711936 ; RGBA(120,255,120,255)
  #BLUE_COLOR             = -34696    ; RGBA(120,120,255,255)
  
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
    #ICON_BRUSH
    #ICON_PEN
    #ICON_SELECT
    #ICON_SPLITV
    #ICON_SPLITH
    #ICON_LOCKED
    #ICON_UNLOCKED
    #ICON_OP
    #ICON_TRASH
    #ICON_STAGE
    #ICON_LAYER
    #ICON_FOLDER
    #ICON_FILE
    #ICON_OPEN
    #ICON_SAVE
    #ICON_HOME
    #ICON_BACK
    #ICON_WARNING
    #ICON_ERROR
    #ICON_OK
    #ICON_EXPENDED
    #ICON_CONNECTED
    #ICON_COLLAPSED
    #ICON_ARROWLEFT
    #ICON_ARROWRIGHT
    #ICON_ARROWUP
    #ICON_ARROWDOWN
    #ICON_ADD
    #ICON_SUB
    #ICON_LAST
  EndEnumeration
  
  Global Dim IconName.s(#ICON_LAST)
  IconName(#ICON_VISIBLE) = "visible"
  IconName(#ICON_INVISIBLE) = "invisible"
  IconName(#ICON_PLAYFORWARD) = "playforward"
  IconName(#ICON_PLAYBACKWARD) = "playbackward"
  IconName(#ICON_STOP) = "stop"
  IconName(#ICON_PREVIOUSFRAME) = "previousframe"
  IconName(#ICON_NEXTFRAME) = "nextframe"
  IconName(#ICON_FIRSTFRAME) = "firstframe"
  IconName(#ICON_LASTFRAME) = "lastframe"
  IconName(#ICON_LOOP) = "loop"
  IconName(#ICON_TRANSLATE) = "translate"
  IconName(#ICON_ROTATE) = "rotate"
  IconName(#ICON_SCALE) = "scale"
  IconName(#ICON_BRUSH) = "brush"
  IconName(#ICON_PEN) = "pen"
  IconName(#ICON_SELECT) = "select"
  IconName(#ICON_SPLITV) = "splitv"
  IconName(#ICON_SPLITH) = "splith"
  IconName(#ICON_LOCKED) = "locked"
  IconName(#ICON_UNLOCKED) = "unlocked"
  IconName(#ICON_OP) = "op"
  IconName(#ICON_TRASH) =  "trash"
  IconName(#ICON_STAGE) = "stage"
  IconName(#ICON_LAYER) = "layer"
  IconName(#ICON_FOLDER) = "folder"
  IconName(#ICON_FILE) = "file"
  IconName(#ICON_OPEN) = "open"
  IconName(#ICON_SAVE) = "save"
  IconName(#ICON_HOME) = "home"
  IconName(#ICON_BACK) = "back"
  IconName(#ICON_WARNING) = "warning"
  IconName(#ICON_ERROR) = "error"
  IconName(#ICON_OK) = "ok"
  IconName(#ICON_EXPENDED) = "expended"
  IconName(#ICON_CONNECTED) = "connected"
  IconName(#ICON_COLLAPSED) = "collapsed"
  IconName(#ICON_ARROWLEFT) = "arrowleft"
  IconName(#ICON_ARROWRIGHT) = "arrowright"
  IconName(#ICON_ARROWUP) = "arrowup"
  IconName(#ICON_ARROWDOWN) = "arrowdown"
  IconName(#ICON_ADD) = "add"
  IconName(#ICON_SUB) = "sub"
  
  Prototype DrawIconImpl(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT,
                         thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  
  Declare.d OffsetXOut(x.d, a.d, l.d)
  Declare.d OffsetYOut(y.d, a.d, l.d)
  Declare.d OffsetXIn(x.d, a.d, l.d)
  Declare.d OffsetYIn(y.d, a.d, l.d)
  
  Declare VisibleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare InvisibleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare PlayForwardIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare PlayBackwardIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare StopIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare PreviousFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare NextFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare FirstFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare LastFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare LoopIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)  
  Declare TranslateIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare RotateIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ScaleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare BrushIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare PenIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare SelectIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare SplitVIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)  
  Declare SplitHIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare LockedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare UnlockedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare OpIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare TrashIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare StageIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare LayerIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare FolderIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare FileIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare SaveIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)  
  Declare OpenIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare HomeIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare BackIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare WarningIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ErrorIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare OKIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ExpendedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ConnectedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare CollapsedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ArrowLeftIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ArrowRightIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ArrowUpIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare ArrowDownIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare AddIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
  Declare SubIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
EndDeclareModule


; ==============================================================================
;  CONTROL ICON MODULE IMPLEMENTATION 
; ==============================================================================
Module Icon
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

  Procedure VisibleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
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

  Procedure InvisibleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 10 50 C 30 70 70 70 90 50 "
    segments + "M 24.436 59.7602 L 17.9105 74.3691 "
    segments + "M 50.0001 65 L 50.0001 81 "
    segments + "M 75.5642 59.7602 L 82.0896 74.369 "
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, #PB_Path_RoundEnd)
  EndProcedure

  Procedure PlayForwardIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 20 L 80 50 L 20 80 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure PlayBackwardIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 80 20 L 80 80 L 20 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure StopIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure PreviousFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 75 20 L 75 80 L 30 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 25 20 L 25 80"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure NextFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 25 20 L 25 80 L 70 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 75 20 L 75 80"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure FirstFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 80 20 L 80 80 L 40 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 60 20 L 60 80 L 25 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 20 20 L 20 80"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure LastFrameIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 20 L 20 80 L 60 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 40 20 L 40 80 L 75 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 80 20 L 80 80"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure LoopIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)  
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
    StrokePath(thickness, style)
  EndProcedure

  Procedure TranslateIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    
    Define segments.s
    segments + "M 50 15 L 40 25 L 60 25 Z"
    segments + "M 50 85 L 40 75 L 60 75 Z"
    segments + "M 15 50 L 25 40 L 25 60 Z"
    segments + "M 85 50 L 75 40 L 75 60 Z"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 35 35 L 65 35 L 65 65 L 35 65 Z"
    AddPathSegments(segments)
    
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure RotateIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define r.d = 35
    Define segments.s = "M 50 25 L 75 50 L 50 75 L 25 50 Z"
    AddPathSegments(segments)
  
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  
    AddPathCircle(50,50,r, 0, 300)
    Define l.d = PathLength()
    
    Define x.d = PathPointX(l)
    Define y.d = PathPointY(l)
    Define a.d = PathPointAngle(l)
    MovePathCursor(r*Cos(Radian(320)) + 50, r*Sin(Radian(320)) + 50)
    AddPathLine(OffsetXOut(x, a, 5), OffsetYOut(y, a, 5))
    AddPathLine(OffsetXIn(x, a, 5), OffsetYIn(y, a, 5))
    
    ClosePath()
    
    StrokePath(thickness, style)
  EndProcedure

  Procedure ScaleIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 80 L 20 50 L 50 50 L 50 80 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
    AddPathSegments(segments)
    DashPath(thickness, 2 * thickness, style)
    
    segments = "M 70 20 L 80 20 L 80 30 M 80 20 L 60 40 M 60 30 L 60 40 L 70 40"
    AddPathSegments(segments)
    ;   MovePathCursor(
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure BrushIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments.s = "M 10 80 C 30 90 50 70 45 55 L 30 50 C 10 60 10 70 10 80"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath()
    
    segments.s = "M 35 50 L 45 55 L 77 15 L 65 10 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure SelectIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
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
    StrokePath(thickness, style)
  EndProcedure

  Procedure SplitVIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 20 L 40 20 L 40 80 L 20 80 Z"
    segments + "M 60 20 L 80 20 L 80 80 L 60 80 Z"
    segments + "M 50 10 L 50 90"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure SplitHIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 20 L 80 20 L 80 40  L 20 40 Z"
    segments + "M 20 60 L 80 60 L 80 80 L 20 80 Z"
    segments + "M 10 50 L 90 50"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure LockedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20,50,60,40)
    MovePathCursor(55, 80)
    AddPathLine(55,80)
    AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
    AddPathLine(45,80)
    ClosePath()
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
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
    StrokePath(thickness, style)
  EndProcedure

  Procedure UnlockedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    
    AddPathBox(20,50,60,40)
    MovePathCursor(55, 80)
    AddPathLine(55,80)
    AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
    AddPathLine(45,80)
    ClosePath()
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    
    AddPathCircle(50, 35, 25, 200, 0)
    AddPathLine(75,50)
    AddPathLine(65,50)
    AddPathCircle(50,35, 15, 0, 200, #PB_Path_Connected|#PB_Path_CounterClockwise)
    ClosePath()
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure OpIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
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
    StrokePath(thickness, style)
  EndProcedure

  Procedure TrashIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 25 30 L 30 80 L 70 80 L 75 30 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments.s = "M 18 25 L 82 25"
    segments + "M 40 25 L 42 15 L 58 15 L 60 25" 
    segments + "M 42 40 L 44 70 M 58 40 L 56 70"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure StageIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 25 45 L 25 85 M 25 65 L 40 65 M 25 85 L 40 85"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    AddPathBox(10, 37, 45, 16)
    AddPathBox(40, 57, 40, 16)
    AddPathBox(40, 77 , 40, 16)
    
    VectorSourceColor(fill)
    FillPath()
    
    segments = "M 70 20 L 70 40 M 60 30 L 80 30"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure LayerIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 80 L 60 80 L 80 60 L 40 60 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
    segments.s = "M 20 70 L 60 70 L 80 50 L 40 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    
  ;   segments.s = "M 20 60 L 60 60 L 80 40 L 40 40 Z"
  ;   AddPathSegments(segments)
  ;   VectorSourceColor(FILL_COLOR)
  ;   FillPath(#PB_Path_Preserve)
  ;   VectorSourceColor(STROKE_COLOR)
  ;   StrokePath(STROKE_WIDTH, style)
    
    segments = "M 70 20 L 70 40 M 60 30 L 80 30"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure PenIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 80 L 20 60 L 40 70 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    segments.s = "M 20 60 L 50 20 L 70 30 L 40 70 Z"
    AddPathSegments(segments)
    VectorSourceColor(#ORANGE_COLOR)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure FolderIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 30 L 20 80 L 80 80 L 80 20 L 50 20 L 50 30 Z"
    AddPathSegments(segments)
    segments.s = "M 80 80 L 90 40 L 80 40"
    AddPathSegments(segments)
    VectorSourceColor(#ORANGE_COLOR)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure FileIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
    segments + "M 35 55 L 65 55 M 35 65 L 65 65"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure SaveIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
    segments + "M 35 55 L 65 55 M 35 65 L 65 65"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    segments = "M 50 50 L 50 30 L 40 30 L 60 10 L 80 30 L 70 30 L 70 50 Z"
    AddPathSegments(segments)
    VectorSourceColor(#ORANGE_COLOR)
    FillPath()
  EndProcedure

  Procedure OpenIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
    segments + "M 35 55 L 65 55 M 35 65 L 65 65"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
    segments = "M 50 10 L 50 30 L 40 30 L 60 50 L 80 30 L 70 30 L 70 10 Z"
    AddPathSegments(segments)
    VectorSourceColor(#ORANGE_COLOR)
    FillPath()
  EndProcedure
  
  Procedure HomeIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 25 80 L 42 80 L 42 50 L 58 50  L 58 80 L 75 80"
    segments + "L 75 40 L 85 40 L 50 20 L 15 40 L 25 40 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure BackIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 20 40 L 40 60 L 40 50 L 60 50 L 60 80"
    segments + "L 80 80 L 80 30 L 40 30 L 40 20 Z"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure WarningIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s
    segments + "M 15 80 L 85 80 L 50 20 Z"
    AddPathSegments(segments)
    VectorSourceColor(#ORANGE_COLOR)
    FillPath(#PB_Path_Preserve)
    Define segments.s = "M 50 40 L 50 60"
    AddPathSegments(segments)
    VectorSourceColor(#BLACK_COLOR)
    StrokePath(thickness, style)
    AddPathCircle(50, 68, thickness * 0.5)
    FillPath()
  EndProcedure

  Procedure ErrorIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathCircle(50, 50, 35)
    VectorSourceColor(#RED_COLOR)
    FillPath(#PB_Path_Preserve)
    Define segments.s = "M 35 35 L 65 65 M 35 65 L 65 35"
    AddPathSegments(segments)
    VectorSourceColor(#WHITE_COLOR)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure OKIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathCircle(50, 50, 35)
    VectorSourceColor(#RED_COLOR)
    FillPath(#PB_Path_Preserve)
    Define segments.s = "M 35 35 L 65 65 M 35 65 L 65 35"
    AddPathSegments(segments)
    VectorSourceColor(#WHITE_COLOR)
    StrokePath(thickness, style)
  EndProcedure

  Procedure ExpendedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20, 20, 60, 15)
    VectorSourceColor(fill)
    FillPath()
    AddPathBox(20, 40, 60, 15)
    VectorSourceColor(fill)
    FillPath()
    AddPathBox(20, 60, 60, 15)
    VectorSourceColor(fill)
    FillPath()
  EndProcedure
  
  Procedure ConnectedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20, 40, 60, 15)
    VectorSourceColor(fill)
    FillPath()
    AddPathBox(20, 60, 60, 15)
    VectorSourceColor(fill)
    FillPath()
  EndProcedure

  Procedure CollapsedIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20, 60, 60, 15)
    VectorSourceColor(fill)
    FillPath()
  EndProcedure
  
  Procedure ArrowLeftIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 40 20 L 10 50 L 40 80 M 10 50 L 90 50"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure ArrowRightIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 60 20 L 90 50 L 60 80 M 10 50 L 90 50"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure ArrowUpIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 40 L 50 10 L 80 40 M 50 10 L 50 90"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure

  Procedure ArrowDownIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    Define segments.s = "M 20 60 L 50 90 L 80 60 M 50 10 L 50 90"
    AddPathSegments(segments)
    VectorSourceColor(stroke)
    StrokePath(thickness, style)
  EndProcedure
  
  Procedure AddIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20,20,60,60)
    Define segments.s = "M 30 46 L 30 54 L 46 54 L 46 70 L 54 70 L 54 54 L 70 54 L 70 46 L 54 46 L 54 30 L 46 30 L 46 46"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath()
  EndProcedure
  
  Procedure SubIcon(fill.i=#FILL_COLOR_DEFAULT, stroke.i=#STROKE_COLOR_DEFAULT, thickness.i=#STROKE_WIDTH, style.i=#STROKE_STYLE)
    AddPathBox(20,20,60,60)
    Define segments.s = "M 30 46 L 30 54 L 70 54 L 70 46"
    AddPathSegments(segments)
    VectorSourceColor(fill)
    FillPath()
  EndProcedure
EndModule
; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 8
; Folding = ---------
; EnableXP