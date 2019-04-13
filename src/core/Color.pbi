DeclareModule Color
  
  ;---------------------------------------------------------
  ; Pixel Structure
  ;---------------------------------------------------------
  Structure Pixel_t
    r.c
    g.c
    b.c
    a.c
    s.b
    done.b
  EndStructure
  
  ;---------------------------------------------------------
  ; Color structure
  ;---------------------------------------------------------
  Structure Color_t
    v.l
    r.c
    g.c
    b.c
    a.c
    x.i
    y.i
    width.i
    height.i
    id.i
  EndStructure
  
  ;---------------------------------------------------------
  ; Default colors
  ;---------------------------------------------------------
  Global Dim Greyscale(8)
  Greyscale(0) = RGBA(0,0,0,255)
  Greyscale(1) = RGBA(31,31,31,255)
  Greyscale(2) = RGBA(62,62,62,255)
  Greyscale(2) = RGBA(93,93,93,255)
  Greyscale(3) = RGBA(124,124,124,255)
  Greyscale(4) = RGBA(155,155,155,255)
  Greyscale(5) = RGBA(186,186,186,255)
  Greyscale(6) = RGBA(217,217,217,255)
  Greyscale(7) = RGBA(248,248,248,255)
  Greyscale(8) = RGBA(255,255,255,255)
  
  Global Dim MinitelColors(6)
  MinitelColors(0) = RGBA(0,0,0,255)
  MinitelColors(1) = RGBA(255,0,0,255)
  MinitelColors(2) = RGBA(255,255,0,255)
  MinitelColors(3) = RGBA(0,255,0,255)
  MinitelColors(2) = RGBA(0,255,255,255)
  MinitelColors(3) = RGBA(255,255,255,255)
  
  Global Dim Colors.i(15)
  Colors(0) = RGBA(0,0,0,255)
  Colors(1) = RGBA(50,0,0,255)
  Colors(2) = RGBA(100,0,0,255)
  Colors(3) = RGBA(150,0,0,255)
  Colors(4) = RGBA(200,0,0,255)
  Colors(5) = RGBA(255,0,0,255)
  Colors(6) = RGBA(0,50,0,255)
  Colors(7) = RGBA(0,100,0,255)
  Colors(8) = RGBA(0,150,0,255)
  Colors(9) = RGBA(0,200,0,255)
  Colors(10) = RGBA(0,255,0,255)
  Colors(11) = RGBA(0,0,50,255)
  Colors(12) = RGBA(0,0,100,255)
  Colors(13) = RGBA(0,0,150,255)
  Colors(14) = RGBA(0,0,200,255)
  Colors(15) = RGBA(0,0,255,255)
  
  Global FILL.i = RGBA(64,180,255,255)
  Global STROKE.i = RGBA(0,0,0,255)
  
  Declare Draw(*color.Color_t)
  Declare DrawPickImage(*color.Color_t)
  Declare Compare(*first.Color_t,*second.Color_t)
  
 

EndDeclareModule

Module Color
  UseModule Constants

  ;---------------------------------------------------------
  ; Draw ONE Color
  ;---------------------------------------------------------
  Procedure Draw(*color.Color_t)
    With *color
      AddPathBox(\x, \y,\width, \height)
      VectorSourceColor(RGBA(\r,\g,\b,\a))
      FillPath(#PB_Path_Preserve)
      
      VectorSourceColor(Color::GRID)
      StrokePath(2)
    EndWith
  EndProcedure

  Procedure DrawPickImage(*color.Color_t)
    With *color
      AddPathBox(\x,\y,\width,\height)
      VectorSourceColor(RGBA(\id+1,0,0,255))
      FillPath()
    EndWith
  EndProcedure
  
  Procedure Compare(*first.Color_t,*second.Color_t)
    If *second\r<*first\r : ProcedureReturn #True : EndIf
    If *second\g<*first\g : ProcedureReturn #True : EndIf
    If *second\b<*first\b : ProcedureReturn #True : EndIf
    ProcedureReturn #False
    
  EndProcedure
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 78
; FirstLine = 56
; Folding = -
; EnableXP