﻿XIncludeFile "../core/Math.pbi"
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
    FreeStructure(*Me)
  EndProcedure
  
  
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*mesh.Geometry::PolymeshGeometry_t, index.i, p1id.i, p2id)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Edge_t = AllocateStructure(Edge_t)
    *Me\neighbors = CArray::New(Types::#TYPE_PTR)
    *Me\vertices = CArray::New(Types::#TYPE_PTR)
    *Me\polygons = CArray::New(Types::#TYPE_PTR)
    *Me\id = index
    
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 39
; Folding = -
; EnableXP
; EnableUnicode