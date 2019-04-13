DeclareModule Fibonacci
  Structure Fibonacci_t
    N.i
    *P
  EndStructure
  
  Declare Compute(*Me.Fibonacci_t, n.i)
    
EndDeclareModule

Module Fibonacci
  
  Procedure Compute(*Me.Fibonacci_t, n.i)
    *Me\N = n
    *Me\P = AllocateMemory(N*8)
    
    Define c, first=0, second=1, nxt
    For c=0 To n-1
      If c<=1
        nxt = c
      Else
        nxt = first + second
        first = second
        second = nxt
      EndIf
      PokeI(*Me\P + c * 8, nxt)
    Next
  EndProcedure
  
EndModule

Define N = 1024
Define fib.Fibonacci::Fibonacci_t
Fibonacci::Compute(fib, N)

Define win = OpenWindow(#PB_Any, 0,0,800,800,"Fibonacci")
Define can = CanvasGadget(#PB_Any,0,0,800,800)

StartVectorDrawing(CanvasVectorOutput(can))

AddPathBox(0,0,800,800)
VectorSourceColor(RGBA(180,180,180,255))
FillPath()

MovePathCursor(400,400)
For i=1 To N-1
  Define f = 65000 >> PeekI(fib\P+i*8) 
  AddPathLine(i, f+400)
Next
VectorSourceColor(RGBA(255,0,0,255))
StrokePath(1)
StopVectorDrawing()


Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 37
; Folding = -
; EnableXP