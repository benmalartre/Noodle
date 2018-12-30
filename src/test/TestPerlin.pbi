;Test Perlin
;-----------------------------------------
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Perlin.pbi"
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
  Protected r.c, g.c, b.c
  For x = 0 To Width-1
    For y = Height-1 To 0 Step -1
      ;       Protected noise.d = PerlinNoise::Unsigned(PerlinNoise::PerlinNoise3D((1 / Width) * x, (1 / Height) * y, time, 3, 12, 6))
            Vector3::Set(p, (1 / Width) * x * 32 - time, (1 / Height) * y * 32, time*2)
;       Vector3::Set(p, x * 0.01, y * 0.01, time)
            noise = PerlinNoise::Eval(*perlin,p, deriv)
            r = Int((deriv\x*0.5+0.5) * 255)
            g = Int((deriv\y*0.5+0.5) * 255)
            b = Int((deriv\z*0.5+0.5) * 255)
      
      Plot(x, y, RGB(r, g, b))
    Next
      
  Next

  StopDrawing()
  time + 0.1
  
EndProcedure

*perlin = PerlinNoise::New(666)
PerlinNoise::Init(*perlin)
#width = 1200
#height = 1200
Define image = CreateImage(#PB_Any,128,128,24)
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
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 36
; FirstLine = 15
; Folding = -
; EnableXP