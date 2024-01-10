; ========================================================================================
;   Types Module Declaration
; ========================================================================================
DeclareModule Types
  Enumeration
    #TYPE_BOOL
    #TYPE_CHAR
    #TYPE_INT
    #TYPE_LONG
    #TYPE_FLOAT
    #TYPE_PTR
    #TYPE_V2F32
    #TYPE_V3F32
    #TYPE_V4F32
    #TYPE_C4F32
    #TYPE_C4U8
    #TYPE_Q4F32
    #TYPE_M3F32
    #TYPE_M4F32
    #TYPE_TRF32
    #TYPE_LOCATION
    #TYPE_STR
  EndEnumeration
  
  #SIZE_BOOL        = 1
  #SIZE_CHAR        = 2
  #SIZE_LONG        = 4
  #SIZE_FLOAT       = 4
  #SIZE_DOUBLE      = 8
  
  CompilerIf #PB_Compiler_Version = #PB_Processor_x86
    #SIZE_INT       = 4
    #SIZE_PTR       = 4
  CompilerElse
    #SIZE_INT       = 8
    #SIZE_PTR       = 8
  CompilerEndIf
  #SIZE_V2F32       = 8
  
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    #SIZE_V3F32     = 16
    #SIZE_TRF32     = 48
    #SIZE_LOCATION  = 88
  CompilerElse
    #SIZE_V3F32     = 12
    #SIZE_TRF32     = 40
    #SIZE_LOCATION  = 72
  CompilerEndIf  
  
  #SIZE_V4F32       = 16
  #SIZE_C4F32       = 16
  #SIZE_C4U8        = 4
  #SIZE_Q4F32       = 16
  #SIZE_M3F32       = 36
  #SIZE_M4F32       = 64

EndDeclareModule

; ========================================================================================
;   Types Module Implementation
; ========================================================================================
Module Types
EndModule

  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 4
; Folding = -
; EnableXP