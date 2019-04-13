
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
    Protected *Me.DrawerGeometry_t = AllocateMemory(SizeOf(DrawerGeometry_t))
    Object::INI(DrawerGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( DrawerGeometry )
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 45
; Folding = -
; EnableXP