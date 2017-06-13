;Test Perlin
;-----------------------------------------
XIncludeFile "../core/Perlin.pbi"

Procedure.i ShowTurbulence(img.i)
  Protected Width = ImageWidth(img)
  Protected Height = ImageHeight(img)
  
  Static time.d = 0.0
  StartDrawing(ImageOutput(img))

  Dim param.d(2)
  
  For x = Width-1 To 1 Step -1
    For y = Height-1 To 1 Step -1
      Protected noise.d = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise3D((1 / Width) * x, (1 / Height) * y, time, 3, 12, 6))
;       Protected noise.d = Perlin::Unsigned(Perlin::OctavePerlin(x,time,y,5,0.5))
      Protected b.i = Int(255 * noise)
      
      Plot(x, y, RGB(b,b,b))
    Next
      
  Next

  StopDrawing()
  time + 0.02
  
EndProcedure


; Perlin::Init()
#width = 1200
#height = 1200
Define image = CreateImage(#PB_Any,120,120,24)
Define display
starttime = ElapsedMilliseconds()
ShowTurbulence(image)
TotalSeconds = (ElapsedMilliseconds() - starttime)

OpenWindow(0, 100, 100, #width, #height, "Perlin Noise - " + Str(TotalSeconds))
ImageGadget(0, 0, 0, #width, #height, ImageID(image))

Repeat
  Event = WaitWindowEvent(1)
  If Event = 0
    starttime = ElapsedMilliseconds()
    ShowTurbulence(image)
    
    TotalSeconds = (ElapsedMilliseconds() - starttime)
    SetWindowTitle(0, "Perlin Noise - " + Str(TotalSeconds)+" ms")

    display = CopyImage(image,#PB_Any)
    ResizeImage(display, #width, #height)
    SetGadgetState(0, ImageID(display))
  EndIf  
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 15
; Folding = -
; EnableXP