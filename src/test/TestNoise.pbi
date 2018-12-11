;Test Perlin
;-----------------------------------------
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Perlin.pbi"
EnableExplicit
Global time.d = 0.0

Structure TurbulenceDatas_t
  width.i
  height.i
  *positions
  *result
  *perlin.PerlinNoise::PerlinNoise_t
EndStructure

Structure ThreadedTurbulenceDatas_t
  *datas.TurbulenceDatas_t
  start_index.i
  end_index.i
EndStructure

Procedure NewTurbulenceDatas(width.i, height.i, seed.i)
  Define *datas.TurbulenceDatas_t  = AllocateMemory(SizeOf(TurbulenceDatas_t))
  *datas\width = width
  *datas\height = height
  *datas\positions = AllocateMemory(width * height * 12)
  *datas\result = AllocateMemory(width * height * 4)
  *datas\perlin = PerlinNoise::New(seed)
  PerlinNoise::Init(*datas\perlin)
  ProcedureReturn *datas
EndProcedure

Procedure DeleteTurbulenceDatas(*datas.TurbulenceDatas_t)
  FreeMemory(*datas\positions)
  FreeMemory(*datas\result)
  FreeMemory(*datas)
EndProcedure


Procedure InitPositions(*datas.TurbulenceDatas_t)
  Define x, y, idx
  Define *p.Math::v3f32
   For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * 12
      Vector3::Set(*p, x*0.01, y*0.01, 0)
    Next
  Next
EndProcedure

Procedure UpdatePositions(*datas.TurbulenceDatas_t)
  Define x, y, idx
  Define *p.Math::v3f32
   For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * 12
      *p\z + 0.1
    Next
  Next
EndProcedure

Procedure MonoTurbulence(*datas.TurbulenceDatas_t)
  Define x, y, idx
  Define *p.Math::v3f32
  Define deriv.Math::v3f32
  For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * 12
      PokeF(*datas\result + idx * 4, PerlinNoise::Eval(*datas\perlin, *p, deriv))
    Next
  Next
EndProcedure

Procedure ThreadedTurbulence(*datas.ThreadedTurbulenceDatas_t)
  Define i
  Define *p.Math::v3f32
  Define deriv.Math::v3f32
  For i=0 To *datas\end_index - *datas\start_index -1
    *p = *datas\datas\positions + i * 12
    PokeF(*datas\datas\result + i * 4, PerlinNoise::Eval(*datas\datas\perlin, *p, deriv))
  Next
EndProcedure


Procedure.i ShowTurbulence(img.i, *datas.TurbulenceDatas_t)
  Protected width = ImageWidth(img)
  Protected height = ImageHeight(img)
  UpdatePositions(*datas)
  MonoTurbulence(*datas)
  
  Define threaddatas.ThreadedTurbulenceDatas_t
  threaddatas\
  ThreadedTurbulence(threaddatas)
  Define x, y, b
  Define noise.f
  StartDrawing(ImageOutput(img))
  For x = Width-1 To 1 Step -1
    For y = Height-1 To 1 Step -1
      noise = PeekF(*datas\result + (y*width+x) * 4)
      b = Int((noise*0.5+0.5) * 255)
      
      Plot(x, y, RGB(b,b,b))
    Next
      
  Next

  StopDrawing()
  time + 0.1
  
EndProcedure


#width = 1200
#height = 1200
Define *turb.TurbulenceDatas_t = NewTurbulenceDatas(#width, #height, 666)
InitPositions(*turb)
Define image = CreateImage(#PB_Any,#width,#height,24)
Define display
Define starttime.q = ElapsedMilliseconds()
ShowTurbulence(image, *turb)
Define TotalSeconds.q = (ElapsedMilliseconds() - starttime)

OpenWindow(0, 100, 100, #width, #height, "Perlin Noise - " + Str(TotalSeconds))
ImageGadget(0, 0, 0, #width, #height, ImageID(image))
Define Event
Repeat
  Event = WaitWindowEvent(1)
  If Event = 0
    starttime = ElapsedMilliseconds()
    ShowTurbulence(image, *turb)
    
    TotalSeconds = (ElapsedMilliseconds() - starttime)
    SetWindowTitle(0, "Perlin Noise - " + Str(TotalSeconds)+" ms")

    display = CopyImage(image,#PB_Any)
    ResizeImage(display, #width, #height)
    SetGadgetState(0, ImageID(display))
  EndIf  
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 94
; FirstLine = 66
; Folding = --
; EnableXP