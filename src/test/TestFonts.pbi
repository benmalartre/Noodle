Global window = OpenWindow(#PB_Any,0,0,800,600, "FONT")
Global canvas = CanvasGadget(#PB_Any,0,0,800,600)

#SIZE_FONT = 8
#NUM_FONTS = 5
Global Dim fontNames.s(#NUM_FONTS)
fontNames(0) = "corbel"
fontNames(1) = "consolas"
fontNames(2) = "verdana"
fontNames(3) = "georgia"
fontNames(4) = "lucida"

Global Dim fonts(#NUM_FONTS)

Macro MLoadFont(_name, _index)
  fonts(_index) = LoadFont(#PB_Any, _name, #SIZE_FONT, #PB_FONT_BOLD)
EndMacro

Define f
For f=0 To #NUM_FONTS - 1 : MLoadFont(fontNames(f), f) : Next

Global text.s = "This Is Fuckin Text!!!"

Procedure VectorDraw(offsety)
  Define f
  StartVectorDrawing(CanvasVectorOutput(canvas))
  
;   AddPathBox(0,0,800,600)
;   VectorSourceColor(RGBA(120,120,120,255))
;   FillPath()
;   
  VectorSourceColor(RGBA(255,255,255,255))
  For f=0 To ArraySize(fontNames())-1
  
    VectorFont(FontID(fonts(f)))
    MovePathCursor(20,20+f*2*#SIZE_FONT+offsety)
    DrawVectorText(fontNames(f)+" : "+text)
  Next
  StopVectorDrawing()

EndProcedure

Procedure Draw()
  Define f
  StartDrawing(CanvasOutput(canvas))
  
  Box(0,0,800,600,RGB(120,120,120))
  
  For f=0 To ArraySize(fontNames())-1
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(fonts(f)))
    DrawText(20,20+f*2*#SIZE_FONT, fontNames(f)+" : "+text)
  Next
  
  StopDrawing()

EndProcedure

Draw()
VectorDraw(200)

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 15
; Folding = -
; EnableXP