;========================================================================================
; Memory Module Declaration
;========================================================================================
DeclareModule Memory
  Global.q NOODLE_AVAILAIBLE_MEMORY
    
  Macro AlignMemory(_memory, _alignment)
    (_memory + (_alignment - _memory % _alignment))
  EndMacro
  
  Declare AllocateAlignedMemory(size.i, align_bytes.i)
  Declare ReAllocateAlignedMemory(*memory, size.i, align_bytes.i)
  Declare FreeAlignedMemory(*memory, size.i)
  
EndDeclareModule

;========================================================================================
; Memory Module Implementation
;========================================================================================
Module Memory
  ;--------------------------------------------------------------------------------------
  ; ALLOCATE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure AllocateAlignedMemory(size.i, align_bytes.i)
    Protected *memory = AllocateMemory(size + align_bytes)
    Protected *aligned
    Define offset.i = *memory % align_bytes
    If offset <> 0
      *aligned = AlignMemory(*memory, align_bytes)
      PokeB(*aligned + size + 1, align_bytes - offset)
    Else
      *aligned = *memory
      PokeB(*aligned + size + 1, 0)
    EndIf
    
    ProcedureReturn *aligned
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; REALLOCATE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure ReAllocateAlignedMemory(*memory, size.i, align_bytes.i)
    *memory = ReAllocateMemory(*memory, size + align_bytes)
    Protected *aligned
    Define offset.i = *memory % align_bytes
    If offset <> 0
      *aligned = AlignMemory(*memory, align_bytes)
      PokeB(*aligned + size + 1, align_bytes - offset)
    Else
      *aligned = *memory
      PokeB(*aligned + size + 1, 0)
    EndIf

    ProcedureReturn *aligned
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; FREE ALIGNED MEMORY
  ;--------------------------------------------------------------------------------------
  Procedure FreeAlignedMemory(*memory, size.i)
    FreeMemory(*memory - PeekB(*memory + size + 1))
  EndProcedure
  
EndModule
;========================================================================================
; EOF
;========================================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 32
; Folding = --
; EnableXP