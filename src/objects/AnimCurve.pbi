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
  Declare DrawKey(*key.AnimX::Keyframe_t,x.d, y.d, zoom.d)
  Declare DrawCurve(*crv.Curve_t, x.d, y.d, width.d, height.d, zoomx.d, zoomy.d)
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
      *key\time = i*10
      *key\value = (Random(100)-50)
      *key\quaternionW = 1.0
      *key\tanIn\type = AnimX::#TT_Smooth
      *key\tanIn\x = 50
      *key\tanIn\y = 0
      *key\tanOut\type = AnimX::#TT_Smooth
      *key\tanOut\x  = 50
      *key\tanOut\y = 0
      *key\linearInterpolation = #False;Bool(Random(100)>50)
    Next
    *crv\crv\setNumKeys(numKeys)
    *crv\crv\setKeys(*crv\keys())
    
  EndProcedure
      
  Procedure DeleteKey(*crv, index.i)
    
  EndProcedure
  
  Procedure DrawKey(*key.AnimX::Keyframe_t,x.d, y.d, z.d)
    
    If *key\linearInterpolation
      Circle((*key\time - x)*z, (*key\value - y)*z,3, RGB(200,100,100))
    Else
      Circle((*key\time - x)*z, (*key\value - y)*z,3, RGB(100,200,100))
      Circle(*key\time - *key\tanIn\x - x, *key\value - *key\tanIn\y - y,2, RGB(250,150,0))
      Circle(*key\time + *key\tanOut\x - x, *key\value + *key\tanOut\y - y,2, RGB(250,150,0))
    EndIf
    
  EndProcedure
  
  Procedure DrawCurve(*crv.Curve_t, ox.d, oy.d, width.d, height.d, zoomx.d, zoomy.d)
    Protected stepx.d = 1 / (zoomx * 0.01)
    Protected stepy.d = 1 / (zoomy * 0.01)
    Protected cx.d,cy.d,lx.d,ly.d
    Protected dx.i, dy.i
    cx = ox
    cy = AnimX::evaluateCurve(cx, *crv\crv)
    lx = cx * (zoomx/100)
    ly = cy * (zoomy/100)
    dx=0
    While cx < width + ox
      cx + stepx
      cy = AnimX::evaluateCurve(cx, *crv\crv)
      LineXY(lx - ox,ly - oy, cx * (zoomx/100) - ox, cy * (zoomx/100) - oy,RGB(*crv\color[0], *crv\color[1],*crv\color[2]))
      lx = cx* (zoomx/100)
      ly = cy* (zoomx/100)
    Wend
    
  EndProcedure
EndModule

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 95
; FirstLine = 40
; Folding = --
; EnableXP