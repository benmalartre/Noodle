#RES = 1024
#C = 234
img = CreateImage(#PB_Any, #RES,#RES)
window = OpenWindow(#PB_Any, 0,0,#RES,#RES,"Mandelbrot")

gadget = ImageGadget(#PB_Any, 0,0,#RES, #RES, ImageID(img))

*data = AllocateMemory(#RES * #RES * 4 )
For i=0 To #RES-1
  For j=0 To #RES-1
    PokeL(*data + (j * #RES + i) * 4, RGB(Random(2555), Random(255), Random(255)))
  Next
Next

Repeat
  e = WaitWindowEvent(120)
  
  StartDrawing(ImageOutput(img))
  DrawingMode(#PB_2DDrawing_Default)
  For i = 0 To #RES - 1
    For j = 0 To #RES - 1
      ;PokeL(*data + (i * #RES + j) * 4,  Pow(PeekL(*data + (i * #RES + j) * 4), 2) + #C)
      Plot(i,j, PeekL(*data + (j * #RES + i) * 4))
    Next
  Next
  StopDrawing()
Until e = #PB_Event_CloseWindow



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 26
; EnableXP