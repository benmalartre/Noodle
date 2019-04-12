DeclareModule Queue
  #MAX_THREADS = 32
  
  Prototype PFNJOBCALLBACK(*datas)
  
  Structure Job_t
    callback.PFNJOBCALLBACK
    *datas
  EndStructure
  
  Structure Queue_t
    mutex.i
    terminate.i
    available.i
    threads.i[#MAX_THREADS]
    List *jobs.Job_t()
  EndStructure
  
  Declare ThreadLoop(*queue.Queue_t)
  Declare StartThread()
  Declare StopThread(*queue.Queue_t)
  Declare StartAddJob(*queue.Queue_t)
  Declare StopAddJob(*queue.Queue_t)
  Declare AddJob(*queue.Queue_t, callback.PFNJOBCALLBACK, *datas)
EndDeclareModule

Module Queue
  Procedure ThreadLoop(*queue.Queue_t)
    Repeat
      If ListSize(*queue\jobs())
        LockMutex(*queue\jobs())
        FirstElement(*queue\jobs())
        
        While TrySemaphore(*queue\available)
          For i = 0 To #MAX_THREADS - 1
            If Not IsThread(*queue\threads[i])
              *queue\threads[i] = CreateThread(*queue\jobs()\callback, *queue\jobs()\datas)
              DeleteElement(*queue\jobs())
            EndIf
          Next
        Wend  
        UnlockMutex(*queue\mutex)
        Debug "LOOP FUCKIN THREAD OF THE DEAD..."
      EndIf
      Delay(10)
    Until TrySemaphore(*queue\terminate)
    MessageRequester("kkk", "rules")

  EndProcedure
  
  Procedure StartThread()
    Define *queue.Queue_t = AllocateMemory(SizeOf(Queue_t))
    InitializeStructure(*queue, Queue_t)
    *queue\mutex = CreateMutex()
    *queue\terminate = CreateSemaphore(0)
;     *queue\available = CreateSemaphore(#MAX_THREADS)
    FillMemory(@*queue\threads[0], #MAX_THREADS * 8,0)
    CreateThread(@ThreadLoop(), *queue)
    ProcedureReturn *queue
  EndProcedure
  
  Procedure StopThread(*queue.Queue_t)
    SignalSemaphore(*queue\terminate)  
    
;     FreeSemaphore(*queue\available)
    FreeSemaphore(*queue\terminate)
    FreeMutex(*queue\mutex)
    ClearStructure(*queue, Queue_t)
    FreeMemory(*queue)
  EndProcedure
  
  Procedure StartAddJob(*queue.Queue_t)
    LockMutex(*queue\mutex)
    LastElement(*queue\jobs())
  EndProcedure
  
  Procedure AddJob(*queue.Queue_t, callback.PFNJOBCALLBACK, *datas)
    AddElement(*queue\jobs())
    *queue\jobs() = AllocateMemory(SizeOf(Job_t))
    *queue\jobs()\callback = callback
    *queue\jobs()\datas = *datas
  EndProcedure
  
  Procedure StopAddJob(*queue.Queue_t)
    UnlockMutex(*queue\mutex)
    FirstElement(*queue\jobs())
  EndProcedure  
  
EndModule

Define window = OpenWindow(#PB_Any, 0,0,800,800, "XX")
Define canvas = CanvasGadget(#PB_Any,0,0,800,800, #PB_Canvas_Keyboard)
Define quit.b = #False
Define *queue.Queue::Queue_t = Queue::StartThread()
Repeat
  e = WaitWindowEvent()
  If Event() = #PB_Event_Gadget
    If EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_RightClick
       
          Debug "RIGHT CKICK"
          SignalSemaphore(*queue\terminate) 
         ; Queue::StopThread(*queue)
          ;quit = #True
      EndSelect
    EndIf
  EndIf
  
Until e = #PB_Event_CloseWindow




; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 42
; FirstLine = 26
; Folding = --
; EnableThread
; EnableXP