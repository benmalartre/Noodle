;========================================================================================
; Memory Module Declaration
;========================================================================================
DeclareModule Memory
  
  #MEMORY_ALIGN_BYTES = 16
  
  Macro Align16(_memory)
    (((_memory) + 15) &~ $0F)
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
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 22
; Folding = --
; EnableXP