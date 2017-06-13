XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Array.pbi"

DeclareModule Selection
  Structure Selection_t
    *objects.CArray::CArrayPtr
  EndStructure
  
  Declare New()
  Declare Delete(*Me.Selection_t)
  
EndDeclareModule

Module Selection
  Procedure New()
    Protected *Me.Selection_t = AllocateMemory(SizeOf(Selection_t))
    *Me\objects = CArray::newCArrayPtr()
    ProcedureReturn *Me
  EndProcedure
  
  
  Procedure Delete(*Me.Selection_t)
    CArray::Delete(*Me\objects)
    FreeMemory(*Me)
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 10
; Folding = -
; EnableXP