; StkFloat temp = 1.0;
;   For (i=99; i>=0; i--) {
;     fmGains_[i] = temp;
;     temp *= 0.933033;
;   }

; temp = 1.0;
;   For (i=15; i>=0; i--) {
;     fmSusLevels_[i] = temp;
;     temp *= 0.707101;
;   }
; 
;   temp = 8.498186;
;   For (i=0; i<32; i++) {
;     fmAttTimes_[i] = temp;
;     temp *= 0.707101;
;   }

Global window = OpenWindow(#PB_Any, 0,0, 800, 600, "Test Graph")
Global canvas = CanvasGadget(#PB_Any, 0, 0, 800, 600)
Global WIDTH = 800
Global HEIGHT = 600
Procedure DrawBG()
  StartDrawing(CanvasOutput(canvas))
  
  Box(0,0, WIDTH,600, RGB(128,128,128))
  
  StopDrawing()
EndProcedure

Procedure DrawGraph(*values, N, color)
  Define ax.i, ay.i, bx.i, by.i
  ax = 0
  ay = HEIGHT - PeekF(*values) * 80
  
  StartDrawing(CanvasOutput(canvas))
  
  For i=1 To N - 1
    bx = WIDTH / N * i
    by =  HEIGHT - PeekF(*values + i * 4) * 80
    LineXY(ax, ay, bx, by, color)
    ax = bx
    ay = by
  Next
  
  StopDrawing()
EndProcedure

DrawBG()

Define N = 99
Define *values = AllocateMemory(N * 4)

Define tmp.f = 1.0
For i=0 To N -1
  PokeF(*values + i*4, tmp)
   tmp * 0.933033
Next

DrawGraph(*values, N, RGB(128,64,64))
FreeMemory(*values)

N = 15
*values = AllocateMemory(N * 4)

tmp.f = 1.0
For i=0 To N -1
  PokeF(*values + i*4, tmp)
   tmp * 0.707101
Next

DrawGraph(*values, N, RGB(64,128,64))

N = 32
*values = AllocateMemory(N * 4)

tmp.f = 8.498186
For i=0 To N -1
  PokeF(*values + i*4, tmp)
   tmp * 0.707101
Next

DrawGraph(*values, N, RGB(64,64,128))

Repeat
  
Until WaitWindowEvent() = #PB_Event_CloseWindow


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 49
; FirstLine = 28
; Folding = -
; EnableXP