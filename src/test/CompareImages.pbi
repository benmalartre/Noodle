Global down.b =  #False
Global hovered.b = #False
Global canvas.i
Global img1.i, img2.i
Global perc.f = 0.5
Global width, height, middle

Procedure SwipeImages()
  middle = height * perc
  Define lhs.i, rhs.i
  StartDrawing(CanvasOutput(canvas))
  lhs = GrabImage(img1, #PB_Any, 0, 0, width, middle)
  rhs = GrabImage(img2, #PB_Any, 0, middle, width, height - middle)
  DrawImage(ImageID(lhs), 0, 0)
  DrawImage(ImageID(rhs), 0, middle)
  If hovered
    Box(0, middle-2, width, 4, RGB(255, 255, 0))
  Else
    Box(0, middle-2, width, 4, RGB(0, 255, 255))
  EndIf
  FreeImage(lhs)
  FreeImage(rhs)
  
  StopDrawing()
EndProcedure

Procedure.b OnEvent(event)
  hovered = #False
  If event = #PB_Event_Gadget And EventGadget() = canvas
    Define mouseX = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
    Define mouseY = GetGadgetAttribute(canvas, #PB_Canvas_MouseY)
    If mouseY >= middle - 3 And mouseY <= middle + 3
        hovered = #True
    EndIf
    Define eventType = EventType()
    width = GadgetWidth(canvas)
    height = GadgetHeight(canvas)
    middle = height * perc
    
    
    If down
      If eventType = #PB_EventType_MouseMove
        perc = mouseY / height
      EndIf
    ElseIf eventType = #PB_EventType_LeftButtonDown
      If hovered
        down = #True
      EndIf
    ElseIf eventType =  #PB_EventType_LeftButtonUp
      down = #False
    EndIf
    SwipeImages()
  EndIf
  
EndProcedure


Procedure ReadPixels(image)
  width = ImageWidth(image)
  height = ImageHeight(image)
  
  Define *pixels = AllocateMemory(width * height * 32)
  Define color
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_Default)
  For y = 0 To height -1
    For x = 0 To width -1
      color = Point(x, y)
      PokeC(*pixels + 32 * (y * width + x), Red(color))
      PokeC(*pixels + 32 * (y * width + x) + 8, Green(color))
      PokeC(*pixels + 32 * (y * width + x) + 16, Blue(color))
    Next
  Next
  StopDrawing()
  ProcedureReturn *pixels
EndProcedure

Procedure.b ComparePixels(*src, *dst)
  Define srcSize = MemorySize(*src)
  Define dstSize = MemorySize(*dst)
  
  If Not srcSize = dstSize
    MessageRequester("Compare Images", "Different resolutions, Fail Comparaison")
    ProcedureReturn #False
  EndIf
  
  Define mismatchPixels = 0
  For i = 0 To (srcSize / 32) - 1
    If Not PeekF(*src + i * 32) = PeekF(*dst + i * 32)
      mismatchPixels + 1
    EndIf
  Next
  
  MessageRequester("Compare Images", "Num Mismatch Pixels : "+Str(mismatchPixels))
  If Not mismatchPixels
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure


UseTGAImageDecoder()
Define folder.s = "/Users/benmalartre/Documents/RnD/raycast/"
img1 = LoadImage(#PB_Any, folder + "trivial.tga")
img2 = LoadImage(#PB_Any, folder + "accel.tga")

Define *img1 = ReadPixels(img1)
Define *img2 = ReadPixels(img2)

ComparePixels(*img1, *img2)

FreeMemory(*img1)
FreeMemory(*img2)

width = ImageWidth(img1)
height = ImageHeight(img2)
perc.f = 0.5

Define window = OpenWindow(#PB_Any, 0, 0, width, height, "Compare Images", #PB_Window_SystemMenu)
canvas = CanvasGadget(#PB_Any, 0, 0, width, height)
Define event.i
Repeat
  event = WaitWindowEvent()
  OnEvent(event)
Until event = #PB_Event_CloseWindow



; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 34
; FirstLine = 24
; Folding = -
; EnableXP