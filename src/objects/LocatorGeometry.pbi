
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
    Protected *Me.LocatorGeometry_t = AllocateStructure(LocatorGeometry_t)
    Object::INI(LocatorGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( LocatorGeometry )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 40
; Folding = -
; EnableXP