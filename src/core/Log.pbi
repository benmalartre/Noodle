; -----------------------------------------
; Log Module Declaration
; -----------------------------------------
DeclareModule Log
  #MAX_MESSAGE = 1024
  Enumeration 
    #LOG_INFOS
    #LOG_WARNING
    #LOG_ERROR
  EndEnumeration
  
  Structure Log_t
    msg.s
    severity.i
  EndStructure
  
  Structure LogMachine_t
    List msgs.Log_t()  
  EndStructure
  
  Global *LOGMACHINE.LogMachine_t
  Global.b INITIALIZED
  Declare Init()
  Declare Term()
  Declare Message(msg.s,severity.i=#LOG_INFOS)
  
EndDeclareModule

; -----------------------------------------
; Log Module Implementation
; -----------------------------------------
Module Log
  Procedure Init()
    If *LOGMACHINE = #Null
      *LOGMACHINE = AllocateMemory(SizeOf(LogMachine_t))
      InitializeStructure(*LOGMACHINE,LogMachine_t)
    EndIf
    INITIALIZED = #True
  EndProcedure
  
  Procedure Term()
    If *LOGMACHINE
      ClearStructure(*LOGMACHINE,LogMachine_t)
      FreeMemory(*LOGMACHINE)
    EndIf
    INITIALIZED = #False
  EndProcedure
  
  Procedure Message(msg.s, severity.i=#LOG_INFOS)
    If Not INITIALIZED : ProcedureReturn : EndIf
    If ListSize(*LOGMACHINE\msgs()) >= #MAX_MESSAGE
      FirstElement(*LOGMACHINE\msgs())
      DeleteElement(*LOGMACHINE\msgs())
    EndIf
    LastElement(*LOGMACHINE\msgs())
    AddElement(*LOGMACHINE\msgs())
    *LOGMACHINE\msgs()\msg = msg
    *LOGMACHINE\msgs()\severity = severity
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 49
; FirstLine = 4
; Folding = -
; EnableXP
; EnableUnicode