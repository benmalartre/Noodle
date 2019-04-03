;===============================================================================
; Time Module Declaration
;===============================================================================
DeclareModule Time
  ;-----------------------------------------------------------------------------
  ;  IMPORT
  ;-----------------------------------------------------------------------------
  ;{
  CompilerSelect #PB_Compiler_OS
    ; ---[ WINDOWS ]------------------------------------------------------------
    CompilerCase #PB_OS_Windows
      ; NOP
    ; ---[ LINUX ]--------------------------------------------------------------
    CompilerCase #PB_OS_Linux
      #CLOCK_MONOTONIC = 1
      Structure timespec_t
        tv_sec.i
        tv_nsec.i
      EndStructure
      ImportC ""
        clock_getres.i ( clock_id.i, *res.timespec_t )
        clock_gettime.i( clock_id.i, *tp.timespec_t  )
      EndImport
    ; ---[ MACOSX ]-------------------------------------------------------------
    CompilerCase #PB_OS_MacOS
      Structure mach_timebase_info_t
        numer.l
        denom.l
      EndStructure
      ImportC ""
        mach_timebase_info.i( *info.mach_timebase_info_t )
        mach_absolute_time.q()
      EndImport
  CompilerEndSelect
  ;}
  
  Global startframe.i = 1
  Global endframe.i = 100
  Global currentframe.i = 1
  Global startloop.i
  Global endloop.i
  Global startrange.i
  Global endrange.i
  Global loop.b
  Global play.b
  Global forward.b
  Global FRAMERATE.f = 25
  Global fps.i
  Global NewList *affectednodes()
  
  ;-----------------------------------------------------------------------------
  ;  GLOBALS
  ;-----------------------------------------------------------------------------
  ;{
  Global s_core_time_qpc_start.d
  Global s_core_time_qpc_res  .d
  ;}
  
  ;-----------------------------------------------------------------------------
  ;  DECLARATIONS
  ;-----------------------------------------------------------------------------
  Declare.b Init()
  Declare.d Get()
  
  Prototype PFNTIMERCALLBACK(*obj)
  Structure Timeable_t
    *obj
    callback.PFNTIMERCALLBACK
    timer.i
    delay.i
  EndStructure

  Declare OnTimer(*Me.Timeable_t)
  Declare StartTimer(*Me.Timeable_t, *callback.PFNTIMERCALLBACK, delay.i=250)
  Declare StopTimer(*Me.Timeable_t)
  
 
EndDeclareModule

;===============================================================================
; Time Module Implementation
;===============================================================================
Module Time
  ; ----------------------------------------------------------------------------
  ;  InitAppTime
  ; ----------------------------------------------------------------------------
  Procedure.b Init()
  
    ; ---[ Init Once ]----------------------------------------------------------
    CompilerSelect #PB_Compiler_OS
      ; ...[ WINDOWS ]..........................................................
      CompilerCase #PB_OS_Windows
        Protected v.q = 0
        If Not QueryPerformanceFrequency_( @v )
          ProcedureReturn #False
        EndIf
        If Not v
          ProcedureReturn #False
        EndIf
        s_core_time_qpc_res = 1.0/v
        QueryPerformanceCounter_( @v )
        s_core_time_qpc_start = v * s_core_time_qpc_res
      ; ...[ LINUX ]............................................................
      CompilerCase #PB_OS_Linux
        Protected v.timespec_t
        If clock_getres( #CLOCK_MONOTONIC, @v )
          ProcedureReturn #False
        EndIf
        s_core_time_qpc_res = 1.0e-9*v\tv_nsec
        If clock_gettime( #CLOCK_MONOTONIC, @v )
          ProcedureReturn #False
        EndIf
        s_core_time_qpc_start = v\tv_sec + v\tv_nsec * s_core_time_qpc_res
      ; ...[ MACOSX ]...........................................................
      CompilerCase #PB_OS_MacOS
        Protected v.mach_timebase_info_t
        mach_timebase_info( @v ) ; returned error ?
        s_core_time_qpc_res = 1.0e-9 * v\numer / v\denom
        s_core_time_qpc_start =  mach_absolute_time() * s_core_time_qpc_res
    CompilerEndSelect
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Get Time
  ; ----------------------------------------------------------------------------
  Procedure.d Get()
    
    CompilerSelect #PB_Compiler_OS
      ; ---[ WINDOWS ]----------------------------------------------------------
      CompilerCase #PB_OS_Windows
        Protected time.q = 0
        QueryPerformanceCounter_( @time )
        ProcedureReturn( time*s_core_time_qpc_res - s_core_time_qpc_start )
      ; ---[ LINUX ]------------------------------------------------------------
      CompilerCase #PB_OS_Linux
        Protected v.timespec_t
        clock_gettime( #CLOCK_MONOTONIC, @v )
        ProcedureReturn( v\tv_sec + v\tv_nsec*s_core_time_qpc_res - s_core_time_qpc_start )
      ; ---[ MACOSX ]-----------------------------------------------------------
      CompilerCase #PB_OS_MacOS
        ProcedureReturn( mach_absolute_time()*s_core_time_qpc_res - s_core_time_qpc_start )
    CompilerEndSelect
    
  EndProcedure
  

  ; -----------------------------------------------------------------------------
  ;   TIMER
  ; -----------------------------------------------------------------------------
  Procedure OnTimer(*Me.Timeable_t)
    Repeat
      Delay(*Me\delay)
      PostEvent(#PB_Event_Timer)
    ForEver
  EndProcedure
  
  Procedure StartTimer(*Me.Timeable_t, *callback.PFNTIMERCALLBACK, delay.i=250)
    *Me\delay = delay
    If Not IsThread(*Me\timer)
      *Me\callback = *callback
      *Me\timer = CreateThread(*callback, *Me)
    EndIf
  EndProcedure
  
  Procedure StopTimer(*Me.Timeable_t)
    If IsThread(*Me\timer)
      KillThread(*Me\timer)
    EndIf
    *Me\timer = #Null
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 46
; FirstLine = 26
; Folding = --
; EnableXP
; EnableUnicode