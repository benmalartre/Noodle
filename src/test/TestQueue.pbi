XIncludeFile "../core/Queue.pbi"

Structure DummyJob_t Extends Queue::Job_t
  tick.i
  duty.i
  T.f
EndStructure


Procedure DummyJob(*job.DummyJob_t)
  Define i
  Debug "START DUMMY JOB ID : "+Str(*job\ID)
  For i = 0 To *job\duty
    Delay(*job\T)
    *job\tick + 1
  Next
  Debug "#######################################################################################"
  Debug " YEAHHHHHHHHHHHHHHHHHHHHH"
  Debug "#######################################################################################"
  SignalSemaphore(*job\available)
EndProcedure

Procedure DrawJob(*job.DummyJob_t, x.i, y.i, width.i, height.i)
  AddPathBox(x,y,width, height)
  VectorSourceColor(RGBA(120,120,120,255))
  FillPath()
  
  Define perc.f = (*job\tick / *job\duty) 
  
  AddPathBox(x+10, y + 10, width-20, height - 20)
  VectorSourceColor(RGBA(255,0,0,120))
  FillPath()
EndProcedure

Procedure DrawJobs(*queue.Queue::Queue_t, canvas)
  If Not ListSize(*queue\jobs()) : ProcedureReturn : EndIf
  Define w, h
  LockMutex(*queue\mutex)
  w = GadgetWidth(canvas) / ListSize(*queue\jobs())
  h = GadgetHeight(canvas)
  StartVectorDrawing(CanvasVectorOutput(canvas))
  Define idx = 0
  ForEach *queue\jobs()
    DrawJob(*queue\jobs(), idx * w, 0, w, h)
    idx + 1
  Next
  StopVectorDrawing()
  UnlockMutex(*queue\mutex)
EndProcedure


Define window = OpenWindow(#PB_Any, 0,0,800,800, "XX")
Define canvas = CanvasGadget(#PB_Any,0,0,800,800, #PB_Canvas_Keyboard)
Define quit.b = #False
Define *queue.Queue::Queue_t = Queue::StartThread()

#ON_DRAW_TIMER = 666
AddWindowTimer(window, #ON_DRAW_TIMER, 25)

Repeat
  e = WaitWindowEvent()
  If Event() = #PB_Event_Gadget
    If EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_RightClick
          For i=0 To 12
            Queue::StartAddJob(*queue)
            Define *job.DummyJob_t = AllocateMemory(SizeOf(DummyJob_t))
            *job\available = *queue\available
            *job\callback = @DummyJob()
            *job\datas = #Null
            *job\duty = Random(1000)
            *job\ID = i
            *job\T = Random(100)*0.1
            *job\tick = 0
            Queue::AddJob(*queue, *job)
            Queue::StopAddJob(*queue)
          Next
          
      EndSelect
    EndIf
  ElseIf Event() = #PB_Event_Timer
    Select EventTimer()
      Case #ON_DRAW_TIMER
        DrawJobs(*queue, canvas)
    EndSelect
    
  EndIf
  
Until e = #PB_Event_CloseWindow
Queue::StopThread(*queue)

; IDE Options = PureBasic 5.62 (Windows - x64)
; Folding = -
; EnableXP