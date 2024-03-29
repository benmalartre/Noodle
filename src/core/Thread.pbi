﻿;========================================================================================
; Thread Module Declaration
;========================================================================================
DeclareModule Thread
  #NUM_THREADS = 16
  #NUM_TASKS = 64
  
  Enumeration
    #THREAD_JOB_WAITING
    #THREAD_JOB_WORKING
    #THREAD_JOB_DONE
  EndEnumeration
  
  Prototype PFNTHREADCALLBACK(*datas)
  
  Structure TaskDatas_t
    num_elements.i
  EndStructure
  
  Structure ThreadDatas_t
    *datas.TaskDatas_t
    start_index.i
    end_index.i
    job_state.i
  EndStructure
  
  Structure Thread_t
    *datas.ThreadDatas_t
    callback.PFNTHREADCALLBACK
  EndStructure

  Structure ThreadPool_t
    workers.i[#NUM_THREADS]
    List *pending.Thread_t()
    running_semaphore.i
    start_semaphore.i
    mutex.i
  EndStructure
  
  Declare NewPool()
  Declare DeletePool(*pool.ThreadPool_t)
  
  Declare Worker(*pool.ThreadPool_t)
  Declare AddTask(*pool.ThreadPool_t, *datas.TaskDatas_t, callback.PFNTHREADCALLBACK)
  
  Macro SplitTask(POOL, TASKDATAS, THREADDATASTYPE, CALLBACK)
    ; split per thread datas and add them to the pending list
    Define _chunckSize = TASKDATAS\num_elements / Thread::#NUM_TASKS
    Define _chunckBase = 0
    Define _extra = TASKDATAS\num_elements- (Thread::#NUM_TASKS*_chunckSize)
    
    Dim _datas.THREADDATASTYPE(Thread::#NUM_TASKS)
    Define _i
    For _i=0 To Thread::#NUM_TASKS - 1
      _datas(_i)\start_index = _chunckBase
      _datas(_i)\end_index = _chunckBase + _chunckSize
      _datas(_i)\datas = TASKDATAS
      _datas(_i)\job_state = Thread::#THREAD_JOB_WAITING
      If _i = Thread::#NUM_TASKS - 1
        _datas(_i)\end_index + _extra
      EndIf
      _chunckBase + _chunckSize
      Thread::AddTask(POOL, _datas(_i), CALLBACK)
    Next
    
    ; wait for all worker threads to complete their job
    Define _working.i
    Repeat 
      _working = 0
      For _i=0 To Thread::#NUM_TASKS-1 : _working + Bool(_datas(_i)\job_state <> Thread::#THREAD_JOB_DONE) : Next
    Until _working = 0
    
    ; reset semaphore to max threads for next batch
    Define _numSemaphore = TrySemaphore(POOL\running_semaphore)
    For _i=_numSemaphore To Thread::#NUM_THREADS - 1 : SignalSemaphore(POOL\running_semaphore) : Next

  EndMacro
EndDeclareModule


;========================================================================================
; Thread Module Implementation
;========================================================================================
Module Thread
  Procedure NewPool()
    Protected *pool.ThreadPool_t = AllocateStructure(ThreadPool_t)
    *pool\running_semaphore = CreateSemaphore(#NUM_THREADS)
    *pool\start_semaphore = CreateSemaphore(0)
    *pool\mutex = CreateMutex()
    Define i
    For i=0 To #NUM_THREADS-1
      CreateThread(@Worker(), *pool)
    Next
    
    ProcedureReturn *pool
  EndProcedure
  
  Procedure DeletePool(*pool.ThreadPool_t)
    FreeSemaphore(*pool\running_semaphore)
    FreeSemaphore(*pool\start_semaphore)
    FreeMutex(*pool\mutex)
    FreeStructure(*pool)
  EndProcedure
  
  Procedure Worker(*pool.ThreadPool_t)
    Define *t.Thread_t
    Repeat
      WaitSemaphore(*pool\start_semaphore)
      WaitSemaphore(*pool\running_semaphore)
      LockMutex(*pool\mutex)
      FirstElement(*pool\pending())
      *t = *pool\pending()
      DeleteElement(*pool\pending())
      UnlockMutex(*pool\mutex)
      *t\datas\job_state = #THREAD_JOB_WORKING
      *t\callback(*t\datas)                    ; threaded task
      FreeStructure(*t)
      SignalSemaphore(*pool\running_semaphore)
    ForEver
  EndProcedure
  
  Procedure AddTask(*pool.ThreadPool_t, *datas.ThreadDatas_t, callback.PFNTHREADCALLBACK)
    LockMutex(*pool\mutex)
    If ListSize(*pool\pending())
      LastElement(*pool\pending())
    EndIf
    
    Define *thread.Thread_t = AllocateStructure(Thread_t)
    *thread\datas = *datas
    *thread\callback = callback
    
    AddElement(*pool\pending())
    *pool\pending() = *thread
    UnlockMutex(*pool\mutex)
    
    SignalSemaphore(*pool\start_semaphore)
  EndProcedure
EndModule

; -----------------------------------------------------------------------------------
; TEST CODE
; -----------------------------------------------------------------------------------
; UseModule Thread
; 
; Structure ThreadTestTask1 Extends TaskDatas_t
;   values.i[2048]
; EndStructure
; 
; Structure ThreadTestDatas1 Extends ThreadDatas_t
;   value.f
; EndStructure
; 
; Procedure ThreadTestCallback(*datas.ThreadTestDatas1)
;   Define i
;   For i=*datas\start_index To *datas\end_index-1
;     *datas\value + (Random(1000)-500)*0.1
;   Next
;   Debug "THREAD RESULT : "+StrF(*datas\value)
; EndProcedure
; 
; 
; Define *pool.ThreadPool_t = Thread::NewPool()
; Define task.ThreadTestTask1
; For i=0 To 2047
;   task\values[i] = Random(2048)
; Next
; task\num_elements = 65535
; 
; Thread::SplitTask(*pool, task, ThreadTestDatas1, @ThreadTestCallback())
; 
;   
; ; 
; ; Define numDatas = 32
; ; Define sizeDatas = 128
; ; Dim *datas.ThreadTestDatas1(numDatas)
; ; Define i
; ; 
; ; For i=0 To numDatas-1
; ;   *datas(i) = AllocateMemory(SizeOf(ThreadTestDatas1))
; ;   InitializeStructure(*datas(i), ThreadTestDatas1)
; ;   *datas(i)\start_index = i*sizeDatas
; ;   *datas(i)\end_index = (i+1)*sizeDatas
; ;   *datas(i)\value = Random(128)
; ;   Thread::AddTask(*pool, *datas(i), @ThreadTestCallback())
; ; Next
; 
; window = OpenWindow(#PB_Any, 0,0,800,600,"TEST")
; Repeat
; Until WaitWindowEvent() = #PB_Event_CloseWindow
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 116
; FirstLine = 103
; Folding = --
; EnableXP