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
  *datas\result = AllocateMemory(width * height * 4)
  *datas\num_elements = width * height
  *datas\perlin = PerlinNoise::New(seed)
  PerlinNoise::Init(*datas\perlin)
  ProcedureReturn *datas
EndProcedure

Procedure DeleteTurbulenceDatas(*datas.TurbulenceDatas_t)
  FreeMemory(*datas\positions)
  FreeMemory(*datas\result)
  FreeMemory(*datas)
EndProcedure


Procedure InitPositions(*datas.TurbulenceDatas_t, size.f=0.0333)
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
  Define deriv.Math::v3f32
  For y=0 To *datas\height-1
    For x=0 To *datas\width-1
      idx = (y**datas\width+x)
      *p = *datas\positions + idx * SizeOf(Math::v3f32)
      PokeF(*datas\result + idx * 4, PerlinNoise::Eval(*datas\perlin, *p, deriv))
    Next
  Next
EndProcedure

Procedure ThreadedTurbulence(*datas.ThreadedTurbulenceDatas_t)
  Define i
  Define *p.Math::v3f32
  Define deriv.Math::v3f32
  Define *taskdatas.TurbulenceDatas_t = *datas\datas
  For i=*datas\start_index To *datas\end_index -1
    *p = *taskdatas\positions + i * SizeOf(Math::v3f32)
    PokeF(*taskdatas\result + i * 4, PerlinNoise::Eval(*taskdatas\perlin, *p, deriv))
  Next
  *datas\job_done = #True
EndProcedure

Procedure.i ShowTurbulence(img.i, *datas.TurbulenceDatas_t)
  Protected width = ImageWidth(img)
  Protected height = ImageHeight(img)
  UpdatePositions(*datas)
  ;MonoTurbulence(*datas)

  Thread::SplitTask(*pool, *datas, ThreadedTurbulenceDatas_t, @ThreadedTurbulence())

  Define x, y, b
  Define noise.f
  StartDrawing(ImageOutput(img))
  Define *buffer = DrawingBuffer()
  Define idx
  For x = 0 To width - 1
    For y = 0 To height -1
      idx = (y*width+x)
      noise = PeekF(*datas\result + idx * 4)
      b = Int((noise*0.5+0.5) * 255)
      PokeB(*buffer + idx * 3, b)
      PokeB(*buffer + idx * 3+1, b)
      PokeB(*buffer + idx * 3+2, b)
    Next 
  Next

  StopDrawing()
  time + 0.1
  
EndProcedure

Time::Init()


#width = 1024
#height = 1024
Define *turb.TurbulenceDatas_t = NewTurbulenceDatas(#width, #height, 0)
InitPositions(*turb)
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

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 96
; FirstLine = 68
; Folding = --
; EnableXP