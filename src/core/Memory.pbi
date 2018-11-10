;========================================================================================
; Memory Module Declaration
;========================================================================================
DeclareModule Memory
  Global.q NOODLE_AVAILAIBLE_MEMORY
  #ALIGN_BYTES =  16
  
  Macro AlignMemory(_memory, _alignment)
    (_memory + (_alignment - _memory % _alignment))
  EndMacro
  
  Declare AllocateAlignedMemory(size.i)
  Declare ReAllocateAlignedMemory(*memory, size.i)
  Declare FreeAlignedMemory(*memory, size.i)
  
EndDeclareModule

;========================================================================================
; Memory Module Implementation
;========================================================================================
Module Memory
  ;--------------------------------------------------------------------------------------
  ; ALLOCATE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure AllocateAlignedMemory(size.i)
    Protected *memory = AllocateMemory(size + #ALIGN_BYTES)
    Protected *aligned
    Define offset.i = *memory % #ALIGN_BYTES
    If offset <> 0
      *aligned = AlignMemory(*memory, #ALIGN_BYTES)
      PokeC(*aligned + size + 1, #ALIGN_BYTES - offset)
    Else
      *aligned = *memory
      PokeC(*aligned + size + 1, 0)
    EndIf
    
    ProcedureReturn *aligned
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; REALLOCATE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure ReAllocateAlignedMemory(*memory, size.i)
    *memory = ReAllocateMemory(*memory, size + #ALIGN_BYTES, #PB_Memory_NoClear)
    Protected *aligned
    Define offset.i = *memory % #ALIGN_BYTES
    If offset <> 0
      *aligned = AlignMemory(*memory, #ALIGN_BYTES)
      PokeC(*aligned + size + 1, #ALIGN_BYTES - offset)
    Else
      *aligned = *memory
      PokeC(*aligned + size + 1, 0)
    EndIf

    ProcedureReturn *aligned 
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; FREE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure FreeAlignedMemory(*memory, size.i)
    FreeMemory(*memory - PeekC(*memory + size + 1))
  EndProcedure
  
EndModule
;========================================================================================
; EOF
;========================================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 48
; FirstLine = 34
; Folding = --
; EnableXP