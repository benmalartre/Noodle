
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; ModelGeometry Module Declaration
;========================================================================================
DeclareModule ModelGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.ModelGeometry_t)
  
  DataSection 
    ModelGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

;========================================================================================
; ModelGeometry Module Implementation
;========================================================================================
Module ModelGeometry
  UseModule Geometry
  UseModule Math
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.ModelGeometry_t)
    Object::TERM(ModelGeometry)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.ModelGeometry_t = AllocateMemory(SizeOf(ModelGeometry_t))
    Object::INI(ModelGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( ModelGeometry )
EndModule


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 48
; Folding = -
; EnableXP