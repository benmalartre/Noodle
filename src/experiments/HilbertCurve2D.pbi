Structure HilbertCurve_t
  dist0.i
  dist.i
EndStructure

Global window.i
Global canvas.i

Declare HilbertA(*crv.HilbertCurve_t, level.i)
Declare HilbertB(*crv.HilbertCurve_t, level.i)
Declare HilbertC(*crv.HilbertCurve_t, level.i)
Declare HilbertD(*crv.HilbertCurve_t, level.i)

Procedure HilbertA(*crv.HilbertCurve_t, level.i)

  If level > 0
    HilbertB(*crv,level-1)
    AddPathLine(0, *crv\dist, #PB_Path_Relative)
    HilbertA(*crv,level-1)
    AddPathLine(*crv\dist, 0,#PB_Path_Relative)
    HilbertA(*crv,level-1)
    AddPathLine(0, -*crv\dist, #PB_Path_Relative)
    HilbertC(*crv,level-1)
  EndIf
  
EndProcedure

Procedure HilbertB(*crv.HilbertCurve_t, level.i) 
  If level > 0
    HilbertA(*crv,level-1)
    AddPathLine(*crv\dist, 0, #PB_Path_Relative)
    HilbertB(*crv,level-1)
    AddPathLine(0, *crv\dist, #PB_Path_Relative)
    HilbertB(*crv,level-1)
    AddPathLine(-*crv\dist, 0,#PB_Path_Relative)
    HilbertD(*crv,level-1)
  EndIf
EndProcedure

Procedure HilbertC (*crv.HilbertCurve_t, level.i) 
  If level > 0
    HilbertD(*crv,level-1)
    AddPathLine(-*crv\dist, 0, #PB_Path_Relative)
    HilbertC(*crv,level-1)
    AddPathLine(0, -*crv\dist, #PB_Path_Relative)
    HilbertC(*crv,level-1)
    AddPathLine(*crv\dist, 0, #PB_Path_Relative)
    HilbertA(*crv,level-1)
  EndIf
EndProcedure

Procedure HilbertD (*crv.HilbertCurve_t, level.i)
  If level > 0
    HilbertC(*crv,level-1)
    AddPathLine(0, -*crv\dist, #PB_Path_Relative)
    HilbertD(*crv,level-1)
    AddPathLine(-*crv\dist, 0, #PB_Path_Relative)
    HilbertD(*crv,level-1)
    AddPathLine(0, *crv\dist, #PB_Path_Relative)
    HilbertB(*crv,level-1)
  EndIf
EndProcedure

Procedure Draw(*crv.HilbertCurve_t) 
  Protected level=6
  *crv\dist0 = 1024
  *crv\dist=*crv\dist0
  Protected i = level
  While i >0
    *crv\dist * 0.5
    MovePathCursor(*crv\dist * 0.5, *crv\dist * 0.5)
    HilbertA(*crv, level)

    VectorSourceColor(RGBA((i * 255 / level), 255 - (i * 255 / level), 0, 255))
    StrokePath(i, #PB_Path_RoundCorner)
        i - 1
  Wend  
  
 
EndProcedure


window = OpenWindow(#PB_Any, 0,0,1024,1024, "Hilbert Curve")
canvas = CanvasGadget(#PB_Any,0,0,1024,1024)
Define crv.HilbertCurve_t
StartVectorDrawing(CanvasVectorOutput(canvas))
AddPathBox(0, 0, 1024, 1024)
VectorSourceColor(RGBA(63,63,63, 255))
FillPath()
Draw(@crv)
StopVectorDrawing()

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow


  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 75
; FirstLine = 24
; Folding = -
; EnableXP