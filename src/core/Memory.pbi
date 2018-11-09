;========================================================================================
; Memory Module Declaration
;========================================================================================
DeclareModule Memory
  Global.q NOODLE_AVAILAIBALE_MEMORY
  
  #MEMORY_ALIGN_BYTES = 16
  
  Macro Align16(_memory)
    ;(((_memory) + 15) &~ $0F)
    (_memory + (#MEMORY_ALIGN_BYTES - _memory % #MEMORY_ALIGN_BYTES))
  EndMacro
  
  Declare AllocateAlignedMemory(size.i)
  Declare ReAllocateAlignedMemory(*memory, size.i)
  Declare FreeAlignedMemory(*memory, size.i)
  
EndDeclareModule

;========================================================================================
; Memory Module Implementation
;========================================================================================
Module Memory
  Procedure AllocateAlignedMemory(size.i)
    Protected *memory = AllocateMemory(size + #MEMORY_ALIGN_BYTES)
    Protected *aligned = Align16(*memory)
    PokeB(*aligned + size + 1, (*memory % #MEMORY_ALIGN_BYTES))
    ProcedureReturn *aligned
  EndProcedure

  Procedure ReAllocateAlignedMemory(*memory, size.i)
    *memory = ReAllocateMemory(*memory, size + #MEMORY_ALIGN_BYTES)
    Protected *aligned = Align16(*memory)
    PokeB(*aligned + size + 1, *memory % #MEMORY_ALIGN_BYTES)
    ProcedureReturn *aligned
  EndProcedure
  
  Procedure FreeAlignedMemory(*memory, size.i)
    FreeMemory(*memory - PeekB(*memory + size + 1))
  EndProcedure
  
EndModule
;========================================================================================
; EOF
;========================================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 10
; Folding = --
; EnableXP