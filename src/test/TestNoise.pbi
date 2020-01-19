;Test Perlin
;-----------------------------------------
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Perlin.pbi"
XIncludeFile "../core/Thread.pbi"
XIncludeFile "../core/Time.pbi"


EnableExplicit
Global time.d = 0.0
Global *pool.Thread::ThreadPool_t = Thread::NewPool()

Structure TurbulenceDatas_t Extends Thread::TaskDatas_t
  width.i
  height.i
  *positions
  *result
  *perlin.PerlinNoise::PerlinNoise_t
EndStructure

Structure ThreadedTurbulenceDatas_t Extends Thread::ThreadDatas_t
EndStructure


Procedure NewTurbulenceDatas(width.i, height.i, seed.i)
  Define *datas.TurbulenceDatas_t  = AllocateMemory(SizeOf(TurbulenceDatas_t))
  *datas\width = width
  *datas\height = height
  *datas\positions = AllocateMemory(width * height * SizeOf(Math::v3f32))
  *datas\result = AllocateMemory(width * height * SizeOf(Math::v3f32))
  *datas\num_elements = width * height
  *datas\perlin = PerlinNoise::New(0)
  PerlinNoise::Init(*datas\perlin)
  ProcedureReturn *datas
EndProcedure

Procedure DeleteTurbulenceDatas(*datas.TurbulenceDatas_t)
  FreeMemory(*datas\positions)
  FreeMemory(*datas\result)
  FreeMemory(*datas)
EndProcedure


Procedure InitPositions(*datas.TurbulenceDatas_t, size.f=0.01)
  Define x, y, idx
  Define *p.Math::v3f32
   For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * SizeOf(Math::v3f32)
      Vector3::Set(*p, x*size, y*size, 0)
    Next
  Next
EndProcedure

Procedure UpdatePositions(*datas.TurbulenceDatas_t)
  Define x, y, idx
  Define *p.Math::v3f32
   For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y * *datas\width + x)
      *p = *datas\positions + idx * SizeOf(Math::v3f32)
      *p\z + 0.1
    Next
  Next
EndProcedure

Procedure MonoTurbulence(*datas.TurbulenceDatas_t)
  Define x, y, idx
  Define *p.Math::v3f32
  Define *d.Math::v3f32
  For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * SizeOf(Math::v3f32)
      *d = *datas\result + idx * SizeOf(Math::v3f32)
      PerlinNoise::Eval(*datas\perlin, *p, *d)
    Next
  Next
EndProcedure

Procedure ThreadedTurbulence(*datas.ThreadedTurbulenceDatas_t)
  Define i
  Define *p.Math::v3f32
  Define *d.Math::v3f32
  Define *taskdatas.TurbulenceDatas_t = *datas\datas
  For i=*datas\start_index To *datas\end_index -1
    *p = *taskdatas\positions + i * SizeOf(Math::v3f32)
    *d = *taskdatas\result + i * SizeOf(Math::v3f32)
    PerlinNoise::Eval(*taskdatas\perlin, *p, *d)
  Next
  *datas\job_state = Thread::#THREAD_JOB_DONE
EndProcedure

Procedure.i ShowTurbulence(img.i, *datas.TurbulenceDatas_t)
  Protected width = ImageWidth(img)
  Protected height = ImageHeight(img)
  UpdatePositions(*datas)
  MonoTurbulence(*datas)

  ;Thread::SplitTask(*pool, *datas, ThreadedTurbulenceDatas_t, @ThreadedTurbulence())
  
  Define x, y
  Define *noise.Math::v3f32
  StartDrawing(ImageOutput(img))
  
  Define pixelFormat = DrawingBufferPixelFormat()
  Define offsetPixel = 3
  Define offsetRed = 0
  Define offsetGreen = 1
  Define offsetBlue = 2
  
  Select (pixelFormat & ~#PB_PixelFormat_ReversedY)
    Case #PB_PixelFormat_8Bits      ; 1 byte per pixel, palletised
    Case #PB_PixelFormat_15Bits     ; 2 bytes per pixel 
    Case #PB_PixelFormat_16Bits     ; 2 bytes per pixel
    Case #PB_PixelFormat_24Bits_RGB ; 3 bytes per pixel (RRGGBB)
    Case #PB_PixelFormat_24Bits_BGR ; 3 bytes per pixel (BBGGRR)
      offsetRed = 2
      offsetBlue = 0
    Case #PB_PixelFormat_32Bits_RGB ; 4 bytes per pixel (RRGGBB)
      offsetPixel = 4
    Case #PB_PixelFormat_32Bits_BGR ; 4 bytes per pixel (BBGGRR)
      offsetPixel = 4
      offsetRed = 2
      offsetBlue = 0
  EndSelect
  
  Define *buffer = DrawingBuffer()
  Define idx
  For x = 0 To width - 1
    For y = 0 To height -1
      idx = (y*width+x)
      *noise = *datas\result + idx * SizeOf(Math::v3f32)
      PokeB(*buffer + idx * offsetPixel+offsetRed, Int((*noise\x*0.5+0.5) * 255))
      PokeB(*buffer + idx * offsetPixel+offsetGreen, Int((*noise\y*0.5+0.5) * 255))
      PokeB(*buffer + idx * offsetPixel+offsetBlue, Int((*noise\z*0.5+0.5) * 255))
    Next 
  Next

  StopDrawing()
  time + 0.1
  
EndProcedure

Time::Init()


#width = 1024
#height = 1024
Define *turb.TurbulenceDatas_t = NewTurbulenceDatas(#width, #height, 0)
InitPositions(*turb,0.02)
Define image = CreateImage(#PB_Any,#width,#height,24)



Define starttime.d = Time::Get()
; ShowTurbulence(image, *turb)
Define TotalSeconds.d = (Time::Get() - starttime)
OpenWindow(0, 100, 100, #width, #height, "Perlin Noise - " + Str(TotalSeconds))
ImageGadget(0, 0, 0, #width, #height, ImageID(image))
Define Event
Repeat
  Event = WaitWindowEvent(1)
  If Event = 0
    starttime = Time::Get()
    ShowTurbulence(image, *turb)
    
    TotalSeconds = (Time::Get() - starttime)
    SetWindowTitle(0, "Perlin Noise - " + StrD(TotalSeconds)+" ms")
    SetGadgetState(0, ImageID(image))
  EndIf  
Until Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 100
; FirstLine = 83
; Folding = --
; EnableXP