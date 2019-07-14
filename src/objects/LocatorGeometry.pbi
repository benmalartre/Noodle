
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; LocatorGeometry Module Declaration
;========================================================================================
DeclareModule LocatorGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.LocatorGeometry_t)
  
  DataSection 
    LocatorGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

;========================================================================================
; LocatorGeometry Module Implementation
;========================================================================================
Module LocatorGeometry
  UseModule Geometry
  UseModule Math
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.LocatorGeometry_t)
    Object::TERM(LocatorGeometry)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.LocatorGeometry_t = AllocateMemory(SizeOf(LocatorGeometry_t))
    Object::INI(LocatorGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( LocatorGeometry )
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 19
; Folding = -
; EnableXP