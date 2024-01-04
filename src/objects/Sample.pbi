XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Geometry.pbi"


;========================================================================================
; Sample Module Declaration
;========================================================================================
DeclareModule Sample
  UseModule Geometry
  UseModule Math
  Declare New(index.i)
  Declare Delete(*v.Sample_t)
EndDeclareModule

;========================================================================================
; Sample Module Implementation
;========================================================================================
Module Sample
  UseModule Geometry
  
  ; Destuctor
  ;--------------------------------------------------------------------------------------
  Procedure Delete(*Me.Sample_t)    
    FreeStructure(*Me)
  EndProcedure
  
  ;  Constructor
  ;--------------------------------------------------------------------------------------
  Procedure.i New(index.i)
    ; ---[ Allocate Memory ]-------------------------------------------------------------
    Protected *Me.Sample_t = AllocateStructure(Sample_t)
    *Me\id = index
    ProcedureReturn *Me
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 32
; Folding = -
; EnableXP
; EnableUnicode