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
    *Me\neighbors = CArray::New(CArray::#ARRAY_PTR)
    *Me\vertices = CArray::New(CArray::#ARRAY_PTR)
    *Me\polygons = CArray::New(CArray::#ARRAY_PTR)
    *Me\id = index
    
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 40
; FirstLine = 3
; Folding = -
; EnableXP
; EnableUnicode