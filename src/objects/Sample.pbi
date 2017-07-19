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
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Sample_t)    
    ClearStructure(*Me,Sample_t)
    
    FreeMemory(*Me)
  EndProcedure
  
  
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(index.i)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Sample_t = AllocateMemory(SizeOf(Sample_t))
    InitializeStructure(*Me,Sample_t)
    *Me\id = index
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 32
; FirstLine = 7
; Folding = -
; EnableUnicode
; EnableXP