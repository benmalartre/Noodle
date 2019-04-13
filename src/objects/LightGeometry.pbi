
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; LightGeometry Module Declaration
;========================================================================================
DeclareModule LightGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.LightGeometry_t)
  
  DataSection 
    LightGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

;========================================================================================
; LightGeometry Module Implementation
;========================================================================================
Module LightGeometry
  UseModule Geometry
  UseModule Math
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.LightGeometry_t)
    Object::TERM(LightGeometry)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.LightGeometry_t = AllocateMemory(SizeOf(LightGeometry_t))
    Object::INI(LightGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( LightGeometry )
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 27
; Folding = -
; EnableXP