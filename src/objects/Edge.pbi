XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Geometry.pbi"


;========================================================================================
; Edge Module Declaration
;========================================================================================
DeclareModule Edge
  UseModule Geometry
  UseModule Math
  Declare New(*mesh.Geometry::PolymeshGeometry_t, index.i, p1id.i, p2id)
  Declare Delete(*v.Edge_t)
EndDeclareModule

;========================================================================================
; Edge Module Implementation
;========================================================================================
Module Edge
  UseModule Geometry
  
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Edge_t) 
    CArray::Delete(*Me\neighbors)
    CArray::Delete(*Me\polygons)
    CArray::Delete(*Me\vertices)
    ClearStructure(*Me,Edge_t)
    
    FreeMemory(*Me)
  EndProcedure
  
  
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*mesh.Geometry::PolymeshGeometry_t, index.i, p1id.i, p2id)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Edge_t = AllocateMemory(SizeOf(Edge_t))
    InitializeStructure(*Me,Edge_t)
    *Me\neighbors = CArray::newCArrayPtr()
    *Me\vertices = CArray::newCArrayPtr()
    *Me\polygons = CArray::newCArrayPtr()
    *Me\id = index
    
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 44
; Folding = -
; EnableXP
; EnableUnicode