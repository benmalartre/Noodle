
XIncludeFile "../objects/Geometry.pbi"

;========================================================================================
; CameraGeometry Module Declaration
;========================================================================================
DeclareModule CameraGeometry
  UseModule Geometry
  UseModule Math
  Declare New(*parent)
  Declare Delete(*geom.CameraGeometry_t)
  
  DataSection 
    CameraGeometryVT: 
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

;========================================================================================
; CameraGeometry Module Implementation
;========================================================================================
Module CameraGeometry
  UseModule Geometry
  UseModule Math
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.CameraGeometry_t)
    Object::TERM(CameraGeometry)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(*parent)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.CameraGeometry_t = AllocateStructure(CameraGeometry_t)
    Object::INI(CameraGeometry)
    ProcedureReturn *Me
  EndProcedure

  Class::DEF( CameraGeometry )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 41
; FirstLine = 1
; Folding = -
; EnableXP