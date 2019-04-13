;========================================================================================
; Queue Module Declaration
;========================================================================================
DeclareModule Queue
  #MAX_THREADS = 32
  
  Prototype PFNJOBCALLBACK(*datas)
  
  Structure Job_t
    ID.i
    available.i
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
  Declare AddJob(*queue.Queue_t, *job.Job_t)
EndDeclareModule

;========================================================================================
; Queue Module Implementation
;========================================================================================
Module Queue
  ; ----------------------------------------------------------
  ;   Queue Thread
  ; ----------------------------------------------------------
  Procedure ThreadLoop(*queue.Queue_t)
    Define *job.Job_t
    Repeat
      While ListSize(*queue\jobs())And TrySemaphore(*queue\available)
        FirstElement(*queue\jobs())
        *job = *queue\jobs()
        For i = 0 To #MAX_THREADS - 1
          If Not IsThread(*queue\threads[i])
            *queue\threads[i] = CreateThread(*job\callback, *job)
            DeleteElement(*queue\jobs())
            Break
          EndIf
        Next
      Wend  
      UnlockMutex(*queue\mutex)
      
      Delay(10)
    Until TrySemaphore(*queue\terminate)

  EndProcedure
  
  ; ----------------------------------------------------------
  ;   Start Queue Thread
  ; ----------------------------------------------------------
  Procedure StartThread()
    Define *queue.Queue_t = AllocateMemory(SizeOf(Queue_t))
    InitializeStructure(*queue, Queue_t)
    *queue\mutex = CreateMutex()
    *queue\terminate = CreateSemaphore(0)
    *queue\available = CreateSemaphore(#MAX_THREADS)
    FillMemory(@*queue\threads[0], #MAX_THREADS * 8,0)
    CreateThread(@ThreadLoop(), *queue)
    ProcedureReturn *queue
  EndProcedure
  
  ; ----------------------------------------------------------
  ;   Stop Queue Thread
  ; ----------------------------------------------------------
  Procedure StopThread(*queue.Queue_t)
    SignalSemaphore(*queue\terminate)  
    Delay(10)
    FreeSemaphore(*queue\terminate)
    FreeSemaphore(*queue\available)

    FreeMutex(*queue\mutex)
    ClearStructure(*queue, Queue_t)
    FreeMemory(*queue)
  EndProcedure
  
  ; ----------------------------------------------------------
  ;   Begin Add Job
  ; ----------------------------------------------------------
  Procedure StartAddJob(*queue.Queue_t)
    LockMutex(*queue\mutex)
    LastElement(*queue\jobs())
  EndProcedure
  
  ; ----------------------------------------------------------
  ;   Add One Job
  ; ----------------------------------------------------------
  Procedure AddJob(*queue.Queue_t, *job.Job_t)
    AddElement(*queue\jobs())
    *queue\jobs() = *job
  EndProcedure
  
  ; ----------------------------------------------------------
  ;   End Add Job
  ; ----------------------------------------------------------
  Procedure StopAddJob(*queue.Queue_t)
    UnlockMutex(*queue\mutex)
    FirstElement(*queue\jobs())
  EndProcedure  
  
EndModule



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 4
; FirstLine = 15
; Folding = --
; EnableThread
; EnableXP