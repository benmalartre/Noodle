UsePNGImageEncoder()

Enumeration
  #ICON_VISIBLE
  #ICON_INVISIBLE
  #ICON_PLAYFORWARD
  #ICON_PLAYBACKWARD
  #ICON_STOP
  #ICON_FIRSTFRAME
  #ICON_LASTFRAME
  #ICON_TRANSLATE
  #ICON_ROTATE
  #ICON_SCALE
  #ICON_LAST
EndEnumeration

Global iconFolder.s = "E:/Projects/RnD/Amnesie/build/icons/"

Global Dim IconName.s(#ICON_LAST)
IconName(#ICON_VISIBLE) = "visible"
IconName(#ICON_INVISIBLE) = "invisible"
IconName(#ICON_PLAYFORWARD) = "playforward"
IconName(#ICON_PLAYBACKWARD) = "playbackward"
IconName(#ICON_STOP) = "stop"
IconName(#ICON_FIRSTFRAME) = "firstframe"
IconName(#ICON_LASTFRAME) = "lastframe"
IconName(#ICON_TRANSLATE) = "translate"
IconName(#ICON_ROTATE) = "rotate"
IconName(#ICON_SCALE) = "scale"

#RESOLUTION = 64
Define window = OpenWindow(#PB_Any, 0,0,800,800,"Icons")
Define  canvas = CanvasGadget(#PB_Any, 0,0,800,800)


Global STROKE_WIDTH = 8
Global BACKGROUND_COLOR = RGBA(100,100,100,0)
Global STROKE_COLOR = RGBA(90,90,90,255)
Global FILL_COLOR = RGBA(180,180,220,255)
  
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
  segments + "M 66 50 C 66 58.8366 58.8366 66 50 66 C 41.1635 66 34 58.8366 34 50 C 34 41.1635 41.1634 34 50 34 C 58.8365 34 66 41.1634 66 50 Z "
  segments + "M 23.1526 36.2483 L 13.8411 23.237 "
  segments + "M 50.0001 27.5 L 50.0001 11.5 "
  segments + "M 76.8475 36.2484 L 86.159 23.2371"
  AddPathSegments(segments)
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
  Define segments.s = "M 80 25 L 80 75 L 40 50 Z"
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
  
  segments = "M 20 25 L 20 75"
  AddPathSegments(segments)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure LastFrameIcon()
  Define segments.s = "M 20 25 L 20 75 L 60 50 Z"
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
  
  segments = "M 80 25 L 80 75"
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
;   Define segments.s
;   segments + "M 61.9707 17.1107 C 80.1349 23.722 89.5005 43.8064 82.8893 61.9706 C 78.6126 73.7208 68.3921 82.2969 56.0777 84.4683 "
;   segments + "M 61.9707 17.1107 L 74.6643 14.7665 L 65.4954 27.8787 Z"
;   segments + "M 43.9223 84.4683 C 24.886 81.1117 12.1751 62.9586 15.5317 43.9224 C 18.4812 27.1951 33.0147 15 49.9999 15 "
;   segments + "M 43.9223 84.4683 L 30.4621 88.3152 L 37.7507 74.0718 Z"
;   AddPathSegments(segments)
;   VectorSourceColor(FILL_COLOR)
;   FillPath(#PB_Path_Preserve)
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
EndProcedure

Procedure TranslateIcon()
  
  MovePathCursor(50, 10)
  AddPathLine(40,20)
  AddPathLine(60,20)
  ClosePath()
  
  MovePathCursor(50, 90)
  AddPathLine(40,80)
  AddPathLine(60,80)
  ClosePath()
  
  MovePathCursor(10, 50)
  AddPathLine(20,40)
  AddPathLine(20,60)
  ClosePath()
  
  MovePathCursor(90, 50)
  AddPathLine(80,40)
  AddPathLine(80,60)
  ClosePath()
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  MovePathCursor(40,40)
  AddPathLine(60,40)
  AddPathLine(60,60)
  AddPathLine(40,60)
  ClosePath()
  
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
EndProcedure

Procedure RotateIcon()
  Define r.d = 35
  
  MovePathCursor(40,40)
  AddPathLine(60,40)
  AddPathLine(60,60)
  AddPathLine(40,60)
  ClosePath()
  
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)

  AddPathCircle(50,50,r, 0, 270)
  
  MovePathCursor(60, 15)
  AddPathLine(50, 5)
  AddPathLine(50,25)
  ClosePath()
  
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  
  
EndProcedure

Procedure ScaleIcon()
  MovePathCursor(40,40)
  AddPathLine(60,40)
  AddPathLine(60,60)
  AddPathLine(40,60)
  ClosePath()
  
  VectorSourceColor(FILL_COLOR)
  FillPath(#PB_Path_Preserve)
  
  VectorSourceColor(STROKE_COLOR)
  StrokePath(STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  MovePathCursor(10,10)
  AddPathLine(90,10)
  AddPathLine(90,90)
  AddPathLine(10,90)
  ClosePath()
  DashPath(STROKE_WIDTH, 2*STROKE_WIDTH, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
  
  MovePathCursor(20,70)
  AddPathLine(20,80)
  AddPathLine(30,80)
  MovePathCursor(70,20)
  AddPathLine(80,20)
  AddPathLine(80,30)
  
  MovePathCursor(20,80)
  AddPathLine(30,70)
  MovePathCursor(80,20)
  AddPathLine(70,30)
  ;   MovePathCursor(
  VectorSourceColor(STROKE_COLOR)
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

StopVectorDrawing()

Procedure SaveIcon(icon.i)
  Define image.i = CreateImage(#PB_Any, #RESOLUTION, #RESOLUTION, 32)
  StartVectorDrawing(ImageVectorOutput(image))
  AddPathBox(0,0, #RESOLUTION, #RESOLUTION)
  VectorSourceColor(RGBA(0,0,0,0))
  FillPath()
  
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
    Case #ICON_TRANSLATE
      TranslateIcon()
    Case #ICON_ROTATE
      RotateIcon()
    Case #ICON_SCALE
      ScaleIcon()
  EndSelect
  
  StopVectorDrawing()
  SaveImage(image, iconFolder+IconName(icon)+".png", #PB_ImagePlugin_PNG)
  FreeImage(image)
EndProcedure

For i=0 To #ICON_LAST - 1
  SaveIcon(i)
Next

  
Repeat
  event = WaitWindowEvent()
  
Until event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 33
; Folding = ---
; EnableXP