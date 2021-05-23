UsePNGImageEncoder()

Enumeration
  #ICON_VISIBLE
  #ICON_INVISIBLE
  #ICON_PLAYFORWARD
  #ICON_PLAYBACKWARD
  #ICON_STOP
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

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Global iconFolder.s = "C:/Users/graph/Documents/bmal/src/Amnesie/build/icons/ "
CompilerElseIf #PB_Compiler_OS  = #PB_OS_MacOS
  Global iconFolder.s = "/Users/benmalartre/Documents/RnD/amnesie/icons/"
CompilerEndIf


Global Dim IconName.s(#ICON_LAST)
IconName(#ICON_VISIBLE) = "visible"
IconName(#ICON_INVISIBLE) = "invisible"
IconName(#ICON_PLAYFORWARD) = "playforward"
IconName(#ICON_PLAYBACKWARD) = "playbackward"
IconName(#ICON_STOP) = "stop"
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

#RESOLUTION = 64
Define window = OpenWindow(#PB_Any, 0,0,800,800,"Icons")
Define  canvas = CanvasGadget(#PB_Any, 0,0,800,800)


Global STROKE_WIDTH = 7
Global BACKGROUND_COLOR = RGBA(255,200,100,255)
Global STROKE_COLOR = RGBA(220,220,220,255)
Global FILL_COLOR = RGBA(230,230,230,255)
Global BLACK_COLOR = RGBA(32,32,32,255)
Global WHITE_COLOR = RGBA(222,222,222,255)
Global ORANGE_COLOR = RGBA(255,160,0,255)
Global RED_COLOR = RGBA(255,0,0,255)
Global GREEN_COLOR = RGBA(0,255,0,255)
Global BLUE_COLOR = RGBA(120,120,255,255)
  
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

Procedure VisibleIcon()
  Define segments.s
  segments + "M 10 50 C 30 20 70 20 90 50 "
  segments + "M 10 50 C 30 80 70 80 90 50 "
  segments + "M 23.1526 36.2483 L 13.8411 23.237 "
  segments + "M 50.0001 27.5 L 50.0001 11.5 "
  segments + "M 76.8475 36.2484 L 86.159 23.2371"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd)
  
  segments = "M 66 50 C 66 58.8366 58.8366 66 50 66 C 41.1635 66 34 58.8366 34 50 C 34 41.1635 41.1634 34 50 34 C 58.8365 34 66 41.1634 66 50 Z "
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd)
  
EndProcedure

Procedure InvisibleIcon()
  Define segments.s
  segments + "M 10 50 C 30 70 70 70 90 50 "
  segments + "M 24.436 59.7602 L 17.9105 74.3691 "
  segments + "M 50.0001 65 L 50.0001 81 "
  segments + "M 75.5642 59.7602 L 82.0896 74.369 "
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd)
EndProcedure

Procedure PlayForwardIcon()
  Define segments.s = "M 20 20 L 80 50 L 20 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure PlayBackwardIcon()
  Define segments.s = "M 80 20 L 80 80 L 20 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  Debug PathSegments()
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure StopIcon()
  Define segments.s = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FirstFrameIcon()
  Define segments.s = "M 80 20 L 80 80 L 40 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 60 20 L 60 80 L 20 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 20 20 L 20 80"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LastFrameIcon()
  Define segments.s = "M 20 20 L 20 80 L 60 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 40 20 L 40 80 L 80 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 80 20 L 80 80"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LoopIcon()  
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

  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure TranslateIcon()
  
  Define segments.s
  segments + "M 50 15 L 40 25 L 60 25 Z"
  segments + "M 50 85 L 40 75 L 60 75 Z"
  segments + "M 15 50 L 25 40 L 25 60 Z"
  segments + "M 85 50 L 75 40 L 75 60 Z"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 35 35 L 65 35 L 65 65 L 35 65 Z"
  AddPathSegments(segments)
  
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
EndProcedure

Procedure RotateIcon()
  Define r.d = 35
  Define segments.s = "M 50 25 L 75 50 L 50 75 L 25 50 Z"
  AddPathSegments(segments)

  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)

  AddPathCircle(50,50,r, 0, 300)
  Define l.d = PathLength()
  
  Define x.d = PathPointX(l)
  Define y.d = PathPointY(l)
  Define a.d = PathPointAngle(l)
  MovePathCursor(r*Cos(Radian(320)) + 50, r*Sin(Radian(320)) + 50)
  AddPathLine(OffsetXOut(x, a, 5), OffsetYOut(y, a, 5))
  AddPathLine(OffsetXIn(x, a, 5), OffsetYIn(y, a, 5))
  
  ClosePath()
  
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure ScaleIcon()
  Define segments.s = "M 20 80 L 20 50 L 50 50 L 50 80 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 20 20 L 80 20 L 80 80 L 20 80 Z"
  AddPathSegments(segments)
  DashPath(STROKE_WIDTH, 2*STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 70 20 L 80 20 L 80 30 M 80 20 L 60 40 M 60 30 L 60 40 L 70 40"
  AddPathSegments(segments)
  ;   MovePathCursor(
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SelectIcon()
  MovePathCursor(40,15)
  AddPathLine(40,70)
  AddPathLine(50,60)
  AddPathLine(60,85)
  AddPathLine(70,80)
  AddPathLine(60,55)
  AddPathLine(75,55)
  ClosePath()
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SplitVIcon()
  Define segments.s = "M 20 20 L 40 20 L 40 80 L 20 80 Z"
  segments + "M 60 20 L 80 20 L 80 80 L 60 80 Z"
  segments + "M 50 10 L 50 90"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SplitHIcon()
  Define segments.s = "M 20 20 L 80 20 L 80 40  L 20 40 Z"
  segments + "M 20 60 L 80 60 L 80 80 L 20 80 Z"
  segments + "M 10 50 L 90 50"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LockedIcon()
  AddPathBox(20,50,60,40)
  MovePathCursor(55, 80)
  AddPathLine(55,80)
  AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
  AddPathLine(45,80)
  ClosePath()
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  MovePathCursor(25, 50)
  AddPathLine(25, 45)
  AddPathCircle(50, 45, 25, 180, 0, #PB_Path_Connected)
  AddPathLine(75, 50)
  AddPathLine(65, 50)
  AddPathCircle(50, 45, 15, 0, 180, #PB_Path_Connected|#PB_Path_CounterClockwise)
  AddPathLine(35,50)
  ClosePath()
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
EndProcedure

Procedure UnlockedIcon()
  
  AddPathBox(20,50,60,40)
  MovePathCursor(55, 80)
  AddPathLine(55,80)
  AddPathCircle(50, 65, 8, 45, 135, #PB_Path_CounterClockwise|#PB_Path_Connected)
  AddPathLine(45,80)
  ClosePath()
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
  AddPathCircle(50, 35, 25, 200, 0)
  AddPathLine(75,50)
  AddPathLine(65,50)
  AddPathCircle(50,35, 15, 0, 200, #PB_Path_Connected|#PB_Path_CounterClockwise)
  ClosePath()
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure OpIcon()
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
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure TrashIcon()
  Define segments.s = "M 25 30 L 30 80 L 70 80 L 75 30 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments.s = "M 20 25 L 80 25"
  segments + "M 40 25 L 42 15 L 58 15 L 60 25" 
  segments + "M 35 40 L 38 70 M 50 40 L 50 70 M 65 40 L 62 70"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
  
EndProcedure

Procedure LayerIcon()
  Define segments.s = "M 20 80 L 60 80 L 80 60 L 40 60 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments.s = "M 20 70 L 60 70 L 80 50 L 40 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
;   segments.s = "M 20 60 L 60 60 L 80 40 L 40 40 Z"
;   AddPathSegments(segments)
;   VectorSourceColor(FILL_COLOR)
;   FillPath(#PB_Path_Preserve)
;   VectorSourceColor(STROKE_COLOR)
;   StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  segments = "M 70 20 L 70 40 M 60 30 L 80 30"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure PenIcon()
  Define segments.s = "M 20 80 L 20 60 L 40 70 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments.s = "M 20 60 L 50 20 L 70 30 L 40 70 Z"
  AddPathSegments(segments)
  VectorSourceColor(ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FolderIcon()
  Define segments.s = "M 20 30 L 20 80 L 80 80 L 80 20 L 50 20 L 50 30 Z"
  AddPathSegments(segments)
  segments.s = "M 80 80 L 90 40 L 80 40"
  AddPathSegments(segments)
  VectorSourceColor(ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure FileIcon()
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure SaveIcon()
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments = "M 50 50 L 50 30 L 40 30 L 60 10 L 80 30 L 70 30 L 70 50 Z"
  AddPathSegments(segments)
  VectorSourceColor(ORANGE_COLOR)
  FillPath()
EndProcedure

Procedure OpenIcon()
  Define segments.s
  segments + "M 25 20 L 25 80 L 75 80 L 75 40  L 55 20 L 55 40 L 75 40 L 55 20 Z"
  segments + "M 35 55 L 65 55 M 35 65 L 65 65"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  segments = "M 50 10 L 50 30 L 40 30 L 60 50 L 80 30 L 70 30 L 70 10 Z"
  AddPathSegments(segments)
  VectorSourceColor(ORANGE_COLOR)
  FillPath()
EndProcedure

Procedure HomeIcon()
  Define segments.s
  segments + "M 25 80 L 42 80 L 42 50 L 58 50  L 58 80 L 75 80"
  segments + "L 75 40 L 85 40 L 50 20 L 15 40 L 25 40 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure BackIcon()
  Define segments.s
  segments + "M 20 40 L 40 60 L 40 50 L 60 50 L 60 80"
  segments + "L 80 80 L 80 30 L 40 30 L 40 20 Z"
  AddPathSegments(segments)
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure WarningIcon()
  Define segments.s
  segments + "M 15 80 L 85 80 L 50 20 Z"
  AddPathSegments(segments)
  VectorSourceColor(ORANGE_COLOR)
  FillPath(#PB_Path_Preserve)
  Define segments.s = "M 50 40 L 50 60 M 50 70 L 50 70"
  AddPathSegments(segments)
  VectorSourceColor(BLACK_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure ErrorIcon()
  AddPathCircle(50, 50, 35)
  VectorSourceColor(RED_COLOR)
  FillPath(#PB_Path_Preserve)
  Define segments.s = "M 35 35 L 65 65 M 35 65 L 65 35"
  AddPathSegments(segments)
  VectorSourceColor(WHITE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure



StartVectorDrawing(CanvasVectorOutput(canvas))
ResetCoordinates()
TranslateCoordinates(0,0)
LoopIcon()
TranslateCoordinates(100, 0)
PlayForwardIcon()
TranslateCoordinates(100, 0)
PlayBackwardIcon()
TranslateCoordinates(100, 0)
StopIcon()
TranslateCoordinates(100, 0)
FirstFrameIcon()
TranslateCoordinates(100, 0)
LastFrameIcon()
TranslateCoordinates(100, 0)
VisibleIcon()
TranslateCoordinates(100, 0)
InvisibleIcon()
TranslateCoordinates(-700, 100)
TranslateIcon()
TranslateCoordinates(100, 0)
RotateIcon()
TranslateCoordinates(100, 0)
ScaleIcon()
TranslateCoordinates(100, 0)
SelectIcon()
TranslateCoordinates(100, 0)
SplitVIcon()
TranslateCoordinates(100, 0)
SplitHIcon()
TranslateCoordinates(100, 0)
LockedIcon()
TranslateCoordinates(100, 0)
UnlockedIcon()
TranslateCoordinates(-700, 100)
OpIcon()
TranslateCoordinates(100, 0)
TrashIcon()
TranslateCoordinates(100, 0)
LayerIcon()
TranslateCoordinates(100, 0)
PenIcon()
TranslateCoordinates(100, 0)
FolderIcon()
TranslateCoordinates(100, 0)
FileIcon()
TranslateCoordinates(100, 0)
HomeIcon()
TranslateCoordinates(100, 0)
BackIcon()
TranslateCoordinates(-700, 100)
WarningIcon()
TranslateCoordinates(100, 0)
ErrorIcon()
TranslateCoordinates(100, 0)
SaveIcon()
TranslateCoordinates(100, 0)
OpenIcon()
StopVectorDrawing()

Procedure SaveIconAsImage(icon.i)
  Define image.i = CreateImage(#PB_Any, #RESOLUTION, #RESOLUTION, 32)
  
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AlphaChannel)
  Box(0,0,#RESOLUTION, #RESOLUTION, RGBA(0,0,0,0))
  StopDrawing()

  StartVectorDrawing(ImageVectorOutput(image))
  

  ResetCoordinates()
  ScaleCoordinates(#RESOLUTION / 100, #RESOLUTION / 100)
  Select icon
    Case #ICON_VISIBLE
      VisibleIcon()  
    Case #ICON_INVISIBLE
      InvisibleIcon()
    Case #ICON_PLAYFORWARD
      PlayForwardIcon()
    Case #ICON_PLAYBACKWARD
      PlayBackwardIcon()
    Case #ICON_STOP
      StopIcon()
    Case #ICON_FIRSTFRAME
      FirstFrameIcon()
    Case #ICON_LASTFRAME
      LastFrameIcon()
    Case #ICON_LOOP
      LoopIcon()
    Case #ICON_TRANSLATE
      TranslateIcon()
    Case #ICON_ROTATE
      RotateIcon()
    Case #ICON_SCALE
      ScaleIcon()
     Case #ICON_SELECT
       SelectIcon()
     Case #ICON_SPLITH
       SplitHIcon()
     Case #ICON_SPLITV
       SplitVIcon()
     Case #ICON_LOCKED
       LockedIcon()
     Case #ICON_UNLOCKED
       LockedIcon()
     Case #ICON_OP
       OpIcon()
     Case #ICON_TRASH
       TrashIcon()
     Case #ICON_LAYER
       LayerIcon()
     Case #ICON_PEN
       PenIcon()
     Case #ICON_FOLDER
       FolderIcon()
     Case #ICON_FILE
       FileIcon()
     Case #ICON_SAVE
       SaveIcon()
     Case #ICON_OPEN
       OpenIcon()
     Case #ICON_HOME
       HomeIcon()
     Case #ICON_BACK
       BackIcon()
     Case #ICON_WARNING
       WarningIcon()
     Case #ICON_ERROR
       ErrorIcon()
  EndSelect
  
  StopVectorDrawing()
  SaveImage(image, iconFolder+IconName(icon)+".png", #PB_ImagePlugin_PNG, #False, 32)
  FreeImage(image)
EndProcedure

For i=0 To #ICON_LAST - 1
  SaveIconAsImage(i)
Next

  
Repeat
  event = WaitWindowEvent()
  
Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 36
; Folding = --b9--
; EnableXP