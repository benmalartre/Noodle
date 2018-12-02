;Test Perlin
;-----------------------------------------
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Perlin3.pbi"
Global *perlin.PerlinNoise::PerlinNoise_t
EnableExplicit
Global time.d = 0.0

Procedure.i ShowTurbulence(img.i)
  Protected Width = ImageWidth(img)
  Protected Height = ImageHeight(img)
  
  StartDrawing(ImageOutput(img))

  Dim param.d(2)
  Define p.Math::v3f32
  Define deriv.Math::v3f32
  Define x, y
  Protected noise.f
  Protected b.c
  For x = Width-1 To 1 Step -1
    For y = Height-1 To 1 Step -1
      ;       Protected noise.d = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise3D((1 / Width) * x, (1 / Height) * y, time, 3, 12, 6))
            Vector3::Set(p, (1 / Width) * x * 8, time, (1 / Height) * y * 8)
;       Vector3::Set(p, x * 0.01, y * 0.01, time)
            noise = PerlinNoise::Eval(*perlin,p, deriv)
          b = Int((noise*0.5+0.5) * 255)
      
      Plot(x, y, RGB(b,b,b))
    Next
      
  Next

  StopDrawing()
  time + 0.1
  
EndProcedure

*perlin = PerlinNoise::New(0)
PerlinNoise::Init(*perlin)
#width = 1200
#height = 1200
Define image = CreateImage(#PB_Any,512,512,24)
Define display
Define starttime.q = ElapsedMilliseconds()
ShowTurbulence(image)
Define TotalSeconds.q = (ElapsedMilliseconds() - starttime)

OpenWindow(0, 100, 100, #width, #height, "Perlin Noise - " + Str(TotalSeconds))
ImageGadget(0, 0, 0, #width, #height, ImageID(image))
Define Event
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

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 23
; FirstLine = 10
; Folding = -
; EnableXP