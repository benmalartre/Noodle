;========================================================================================
; Error Module Declaration
;========================================================================================
DeclareModule Error
  Global ErrorMessage.s
  
  Declare Init()
  Declare ErrorHandler()
EndDeclareModule

;========================================================================================
; Error Module Implementation
;========================================================================================
Module Error
  
  Procedure Init()
     OnErrorCall(@ErrorHandler())
  EndProcedure
  
  Procedure ErrorHandler()
 
    ErrorMessage = "A program error was detected:" + Chr(13) 
    ErrorMessage + Chr(13)
    ErrorMessage + "Error Message:   " + ErrorMessage()      + Chr(13)
    ErrorMessage + "Error Code:      " + Str(ErrorCode())    + Chr(13)  
    ErrorMessage + "Code Address:    " + Str(ErrorAddress()) + Chr(13)
   
    If ErrorCode() = #PB_OnError_InvalidMemory   
      ErrorMessage + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
    EndIf
   
    If ErrorLine() = -1
      ErrorMessage + "Sourcecode line: Enable OnError lines support to get code line information." + Chr(13)
    Else
      ErrorMessage + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
      ErrorMessage + "Sourcecode file: " + ErrorFile() + Chr(13)
    EndIf
   
    ErrorMessage + Chr(13)
    ErrorMessage + "Register content:" + Chr(13)
   
    CompilerSelect #PB_Compiler_Processor 
      CompilerCase #PB_Processor_x86
        ErrorMessage + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
        ErrorMessage + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
        ErrorMessage + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
        ErrorMessage + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
        ErrorMessage + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
        ErrorMessage + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
        ErrorMessage + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
        ErrorMessage + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
   
      CompilerCase #PB_Processor_x64
        ErrorMessage + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
        ErrorMessage + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
        ErrorMessage + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
        ErrorMessage + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
        ErrorMessage + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
        ErrorMessage + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
        ErrorMessage + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
        ErrorMessage + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
        ErrorMessage + "Display of registers R8-R15 skipped."         + Chr(13)
   
    CompilerEndSelect
   
    MessageRequester("OnError : ", ErrorMessage)
  EndProcedure
  
EndModule

  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableXP