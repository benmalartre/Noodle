XIncludeFile "..\libs\AnimX.pbi"

; ==============================================================================
;  AnimCurve Module Declaration
; ==============================================================================
DeclareModule AnimCurve
  Structure Curve_t
    Array keys.AnimX::Keyframe_t(0)
    crv.AnimX::ICurve
    color.f[3]
  EndStructure
 
  Declare New()
  Declare Delete(*crv.Curve_t)
  Declare AddKeys(*crv.Curve_t)
  Declare DrawKey(*key.AnimX::Keyframe_t,x.d, y.d)
  Declare DrawCurve(*crv.Curve_t, x.d, y.d, width.d, height.d)
EndDeclareModule

; ==============================================================================
;  AnimCurve Module Implementation
; ==============================================================================
Module AnimCurve  
  ; create curve
  Procedure New()
    Protected *crv.Curve_t = AllocateMemory(SizeOf(Curve_t))
    InitializeStructure(*crv, Curve_t)
    *crv\crv = AnimX::newCurve()
    *crv\color[0] = Random(255)
    *crv\color[1] = Random(255)
    *crv\color[2] = Random(255)
    ProcedureReturn *crv
  EndProcedure
  
  ; destroy curve
  Procedure Delete(*crv.Curve_t)
    *crv\crv\destructor()
    ClearStructure(*crv, Curve_t)
    FreeMemory(*crv)
  EndProcedure
  
  ; test proc
  Procedure AddKeys(*crv.Curve_t)
    Protected numKeys = 32
    ReDim *crv\keys(numKeys)
    Protected *key.AnimX::Keyframe_t
    Protected i
    For i = 0 To numKeys - 1
      *key = *crv\keys(i)
      *key\index = i
      *key\time = i*50
      *key\value = Random(600)
      *key\quaternionW = 1.0
      *key\tanIn\type = AnimX::#TT_Smooth
      *key\tanIn\x = 25
      *key\tanIn\y = 0
      *key\tanOut\type = AnimX::#TT_Smooth
      *key\tanOut\x  = 25
      *key\tanOut\y = 0
      *key\linearInterpolation = Bool(Random(100)>50)
    Next
    *crv\crv\setNumKeys(numKeys)
    *crv\crv\setKeys(*crv\keys())
    
  EndProcedure
      
  Procedure DeleteKey(*crv, index.i)
    
  EndProcedure
  
  Procedure DrawKey(*key.AnimX::Keyframe_t,x.d, y.d)
    
    If *key\linearInterpolation
      AddPathCircle(*key\time - x, *key\value - y,2)
      VectorSourceColor(RGBA(120, 255, 120, 255))
      StrokePath(3)
    Else
      AddPathCircle(*key\time - x, *key\value - y,2)
      VectorSourceColor(RGBA(255, 120, 120, 255))
      StrokePath(3)
      AddPathCircle(*key\time - *key\tanIn\x - x, *key\value - *key\tanIn\y - y,1)
      VectorSourceColor(RGBA(255, 200, 200, 255))
      StrokePath(2)
      AddPathCircle(*key\time + *key\tanOut\x - x, *key\value + *key\tanOut\y - y,1)
      VectorSourceColor(RGBA(255, 200, 200, 255))
      StrokePath(2)
    EndIf
    
  EndProcedure
  
  Procedure DrawCurve(*crv.Curve_t, x.d, y.d, width.d, height.d)
    Protected dx.d, dy.d
    Protected i
    dx = x
    dy = AnimX::evaluateCurve(x, *crv\crv)
    MovePathCursor(dx-x, dy-y)
    For i=0 To width Step 12
      dy = AnimX::evaluateCurve(dx, *crv\crv)
      AddPathLine(dx-x, dy-y, #PB_Path_Default)
      dx+12
    Next
    VectorSourceColor(RGBA(*crv\color[0], *crv\color[1], *crv\color[2], 255))
    StrokePath(2)
    
    For i=0 To ArraySize(*crv\keys())-1
      DrawKey(*crv\keys(i), x, y)
    Next
    
  EndProcedure
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 99
; FirstLine = 52
; Folding = --
; EnableXP