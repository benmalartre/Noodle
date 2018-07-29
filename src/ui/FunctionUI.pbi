XIncludeFile "../core/Eval.pbi"

; Prototype.f FUNC1(x.f)
; Prototype.f FUNC2(x.f, y.f)

Structure Func_t
  func_str.s
  color.i
  
  tolerance.f
  epsilon.f
  
  x0.f
  x1.f
  y.f
  yd.f
  maxIterations.i
  found.b
EndStructure

Macro UpdateFuncX(func_str, x)
  ReplaceString(func_str, "#X", StrF(x))
EndMacro

Macro UpdateFuncY(func_str, y)
  ReplaceString(func_str, "#Y", StrF(y))
EndMacro

Macro UpdateFuncT(func_str, t)
  ReplaceString(func_str, "#T", StrF(t))
EndMacro

Macro UpdateFunc(func_str, x, y, t)
  func_str = UpdateFuncX(func_str, x)
  func_str = UpdateFuncY(func_str, y)
  func_str = UpdateFuncT(func_str, t)
EndMacro

Structure FNView_t
  canvas.i
  input.i
  List funcs.Func_t()
  
  tx.i
  ty.i
  sx.f
  sy.f
  
  lastx.i
  lasty.i
  l_down.b
  r_down.b
  
  T.d
EndStructure

Procedure FuncInit(*func.Func_t, tolerance.f=0.0001, epsilon.f=0.0000001, x0.f=1, maxIterations.i=20)
  *func\tolerance = tolerance
  *func\epsilon = epsilon
  *func\x0 = x0
  *func\maxIterations = maxIterations
  *func\found = #False
  *func\color = RGB(Random(255), Random(255), Random(255))
EndProcedure


Procedure FNViewInit(*view.FNView_t, width.i, height.i)
  InitializeStructure(*view, FNView_t)
  *view\input = StringGadget(#PB_Any, 0,0,width, 24, "Type Function Here")
  *view\canvas = CanvasGadget(#PB_Any, 0,24,width, height-24)
  
  *view\tx = 0
  *view\ty = 0
  *view\sx = 0.1
  *view\sy = 0.1
  *view\T = 0
EndProcedure

Procedure FNViewAddFuncString(*view.FNView_t, str.s)
  AddElement(*view\funcs())
  FuncInit(*view\funcs())
  *view\funcs()\func_str = str  
EndProcedure
  
Procedure FNViewMouseMove(*view.FNView_t)
  If *view\l_down Or *view\r_down
    Protected cx.i = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseX)
    Protected cy.i = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseY)
    
    Protected dx.i = cx - *view\lastx
    Protected dy.i = cy - *view\lasty
    
    If *view\l_down
      *view\tx + dx
      *view\ty + dy
    ElseIf *view\r_down
      Protected s.f = (dx + dy) * 0.005
      *view\sx + s
      *view\sy + s
      If *view\sx < 0.0001 : *view\sx = 0.0001 : EndIf
      If *view\sy < 0.0001 : *view\sy = 0.0001 : EndIf
    EndIf
    
    *view\lastx = cx
    *view\lasty = cy
  EndIf
  
EndProcedure

Procedure FNViewLeftMouseButtonDown(*view.FNView_t)
  *view\l_down = #True
  *view\r_down = #False
  *view\lastx = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseX)
  *view\lasty = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseY)
EndProcedure

Procedure FNViewLeftMouseButtonUp(*view.FNView_t)
  *view\l_down = #False
  *view\lastx = 0
  *view\lasty = 0
EndProcedure

Procedure FNViewRightMouseButtonDown(*view.FNView_t)
  *view\r_down = #True
  *view\l_down = #False
  *view\lastx = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseX)
  *view\lasty = GetGadgetAttribute(*view\canvas, #PB_Canvas_MouseY)
EndProcedure

Procedure FNViewRightMouseButtonUp(*view.FNView_t)
  *view\r_down = #False
  *view\lastx = 0
  *view\lasty = 0
EndProcedure

Procedure FNViewDraw(*view.FNView_t)
  Protected w = GadgetWidth(*view\canvas)
  Protected h = GadgetHeight(*view\canvas)
  Protected ox = w * 0.5
  Protected oy = h * 0.5
  Protected stx.f = 20 / w * 1 / *view\sx
  Protected sty.f = 20 / h * 1 / *view\sy  
  Protected cx.f = -(1/*view\sx)
  Protected cy.f = -(1/*view\sy)
  Protected dx.f, dy.f
  Protected p1x, p1y, p2x, p2y
  Protected d1x, d1y, d2x, d2y
  Protected initialized = #False
  Protected func_str.s
  StartDrawing(CanvasOutput(*view\canvas))
  Box(0,0,w,h,RGB(200,200,200))
  Line(0,oy+*view\ty,w,1,RGB(66,66,66))
  Line(ox+*view\tx,0,1,h,RGB(66,66,66))
  
  Protected i
  
  For i=0 To w/stx
    Line(i*1/stx,oy+*view\ty,1,10, RGB(66,66,66))  
  Next
  
  
  ForEach *view\funcs()
    cx.f = -(1/*view\sx)
    cy.f = -(1/*view\sy)
    initialized = #False
    
    While cx < (1/*view\sx)
      func_str = UpdateFuncX(*view\funcs()\func_str, cx)
;       func_str = UpdateFuncY(*view\funcs()\func_str, 0)
      func_str = UpdateFuncT(func_str, *view\T)
      cy = Eval::d(func_str)
      p2x = cx * ox * *view\sx + ox + *view\tx
      p2y = oy - cy * oy * *view\sx + *view\ty
      
      d2x = cx * ox * *view\sx + ox + *view\tx
      d2y = oy - dy * oy * *view\sy + *view\ty
      
      If initialized
        LineXY(p1x, p1y, p2x, p2y, *view\funcs()\color)
        Circle(p2x,p2y,2, *view\funcs()\color)
      Else
        initialized = #True
      EndIf
      
      p1x = p2x
      p1y = p2y
      d1x = d2x
      d1y = d2y
      
      cx + stx
    Wend  
  
    If *view\funcs()\found
       func_str = UpdateFuncX(*view\funcs()\func_str, *view\funcs()\x1)
;       func_str = UpdateFuncY(*view\funcs()\func_str, 0)
      func_str = UpdateFuncT(func_str, *view\T)
      cy = oy - Eval::d(func_str) * oy * *view\sy + *view\ty
      Circle(*view\funcs()\x1 * ox * *view\sx + ox + *view\tx, cy, 2, RGB(255,0,0))
      StopDrawing()
    EndIf  
  Next
  
  
  StopDrawing()
EndProcedure

Procedure FNViewOnCanvasEvent(*view.FNView_t)
  Select EventType()
    Case #PB_EventType_LeftButtonDown
      FNViewLeftMouseButtonDown(*view)
    Case #PB_EventType_LeftButtonUp
       FNViewLeftMouseButtonUp(*view)
    Case #PB_EventType_RightButtonDown
      FNViewRightMouseButtonDown(*view)
    Case #PB_EventType_RightButtonUp
      FNViewRightMouseButtonUp(*view)
    Case #PB_EventType_MouseMove
       FNViewMouseMove(*view)
  EndSelect
EndProcedure

Procedure FNViewOnInputEvent(*view.FNView_t)
  Select EventType()
    Case #PB_EventType_Change
      Debug GetGadgetText(*view\input)
    Case #PB_EventType_Focus
      ;       SetActiveGadget(*view\input)
      Debug "INPUT GET FOCUS"
    Case #PB_EventType_LostFocus
      ;       SetActiveGadget(
      Debug "INPUT LOOSE FOCUS"
  EndSelect
EndProcedure

Procedure FNViewCompute(*view.FNView_t)
  Define i.i
  Protected w = GadgetWidth(*view\canvas)
  Protected h = GadgetHeight(*view\canvas)
  Protected ox = w * 0.5
  Protected oy = h * 0.5
  
  Protected *func.Func_t
  Protected func_str.s
  ForEach *view\funcs()
    *func.Func_t = *view\funcs()
    func_str = *func\func_str
    For i=0 To *func\maxIterations-1
      func_str = UpdateFuncX(*func\func_str, *func\x0)
      func_str = UpdateFuncT(func_str, *view\T)
      *func\y = Eval::d(func_str)
      ;*view\yd = *view\deriv_fn(*view\x0)
      ; check too denominator is too small
      If Abs(*func\yd) < *func\epsilon : Break: EndIf
      
      ; newton computation
      *func\x1 = *func\x0 - *func\y/*func\yd
      
      ; check if the result is within the desired tolerance
      If Abs(*func\x1 - *func\x0) <= *func\tolerance : *func\found=#True : Break : EndIf
      
      ; update and loop
      *func\x0 = *func\x1
    Next 
  Next
  
EndProcedure

#WIDTH = 1200
#HEIGHT = 800
Define window = OpenWindow(#PB_Any, 0,0, #WIDTH,#HEIGHT, "FUNCKY WINDOW")
Define view.FNView_t
FNViewInit(@view,#WIDTH,#HEIGHT)

FNViewAddFuncString(@view, "Sin(#X)+2*#T")
FNViewAddFuncString(@view, "Sin(#X-#T)")
FNViewAddFuncString(@view, "Cos(#X+#T)")
FNViewAddFuncString(@view, "Tan(#X+#T)")
FNViewAddFuncString(@view, "ATan(#X*#T)")
FNViewAddFuncString(@view, "Pow(#X, 2)")
FNViewCompute(@view)

Define event.i

Repeat
  event = WaitWindowEvent(0.01)
  If event = #PB_Event_Gadget
    Select EventGadget()
      Case view\canvas
        FNViewOnCanvasEvent(@view) 
      Case view\input
        FNViewOnInputEvent(@view)
    EndSelect
  EndIf
  FNViewDraw(@view)
  view\T + 0.01
  
Until event = #PB_Event_CloseWindow




; %These choices depend on the problem being solved
; x0 = 1 %The initial value
; f = @(x) x^2 - 2 %The function whose root we are trying To find
; fprime = @(x) 2*x %The derivative of f(x)
; tolerance = 10^(-7) %7 digit accuracy is desired
; epsilon = 10^(-14) %Don't want to divide by a number smaller than this
; 
; maxIterations = 20 %Don't allow the iterations to continue indefinitely
; haveWeFoundSolution = false %Have Not converged To a solution yet
; 
; For i = 1 : maxIterations
; 
;  y = f(x0)
;  yprime = fprime(x0)
; 
;  If(Abs(yprime) < epsilon) %Don't want to divide by too small of a number
;  % denominator is too small
;  Break; %Leave the loop
;  End
; 
;  x1 = x0 - y/yprime %Do Newton's computation
; 
;  If(Abs(x1 - x0) <= tolerance * Abs(x1)) %If the result is within the desired tolerance
;  haveWeFoundSolution = true
;  Break; %Done, so leave the loop
;  End
; 
;  x0 = x1 %Update x0 To start the process again
; 
; End
; 
; If (haveWeFoundSolution)
;  ... % x1 is a solution within tolerance And maximum number of iterations
; Else
;  ... % did Not converge
; End
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 277
; FirstLine = 249
; Folding = ---
; EnableXP