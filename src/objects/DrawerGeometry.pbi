
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; DrawerGeometry Module Declaration
;========================================================================================
DeclareModule DrawerGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.DrawerGeometry_t)
  
  DataSection 
    DrawerGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

;========================================================================================
; DrawerGeometry Module Implementation
;========================================================================================
Module DrawerGeometry
  UseModule Geometry
  UseModule Math
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.DrawerGeometry_t)
    Object::TERM(DrawerGeometry)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.DrawerGeometry_t = AllocateStructure(DrawerGeometry_t)
    Object::INI(DrawerGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( DrawerGeometry )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 40
; FirstLine = 1
; Folding = -
; EnableXP