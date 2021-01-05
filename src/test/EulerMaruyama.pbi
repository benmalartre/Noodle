XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Utils.pbi"

#NUM_SIMS = 5   ; five runs
Global t_init = 3
Global t_end = 7
Global N = 1000       ; compute 1000 grid points
Global.f dt.f = (t_end - t_init) / N
Global.f y_init = 0
Global.f c_theta = 0.7
Global.f c_mu = 1.5
Global.f c_sigma = 0.06

; Implement the Ornstein–Uhlenbeck mu = \theta (\mu-Y_t)
Procedure.f mu(y.f, t.f)
  ProcedureReturn c_theta * (c_mu - y)
EndProcedure

; Implement the Ornstein–Uhlenbeck sigma = \sigma
Procedure.f sigma(y.f, t.f)
  ProcedureReturn c_sigma
EndProcedure

; Sample a random number at each call
Procedure.f dW(delta_t.f)
  ProcedureReturn Random(Math::#RAND_MAX)/Math::#RAND_MAX
EndProcedure

Define *ts = AllocateMemory(N * 4)
Utils::EvenlyInterpolate1D(t_init, t_end, N, *ts)
Define *ys = AllocateMemory(N * 4)
PokeF(*ys, y_init)

Define window = OpenWindow(#PB_Any,0,0,1200,800,"EulerMaruyama")
Define canvas = CanvasGadget(#PB_Any,0,0,1200,800)

StartDrawing(CanvasOutput(canvas))
Box(10,10,1180,780, RGB(128,128,128))
DrawingMode(#PB_2DDrawing_Default)
Define t.f, y.f
For i=0 To #NUM_SIMS-1
  For j=1 To N-1
    t = (i-1) * dt
    y = PeekF(*ys+(i-1)*4)
    PokeF(*ys+i*4, y + mu(y,t) * dt + sigma(y, t) * dW(dt))
    Circle(PeekF(*ts+i*4)*1000, PeekF(*ys+i*4)*1000, 2, RGB(255,0,0))
    ;Circle(Random(1200), Random(800), Random(5)+2, RGB(Random(255), Random(255), Random(255)))
  Next
Next
StopDrawing()

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
  
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 45
; FirstLine = 17
; Folding = -
; EnableXP