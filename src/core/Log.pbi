; -----------------------------------------
; Log Module Declaration
; -----------------------------------------
DeclareModule Log
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
    
  EndProcedure
  
  Procedure Term()
    If *LOGMACHINE
      ClearStructure(*LOGMACHINE,LogMachine_t)
      FreeMemory(*LOGMACHINE)
    EndIf
    
  EndProcedure
  
  Procedure Message(msg.s, severity.i=#LOG_INFOS)
    AddElement(*LOGMACHINE\msgs())
    *LOGMACHINE\msgs()\msg = msg
    *LOGMACHINE\msgs()\severity = severity
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; Folding = -
; EnableUnicode
; EnableXP