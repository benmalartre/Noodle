XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Geometry.pbi"


;========================================================================================
; Polygon Module Declaration
;========================================================================================
DeclareModule Polygon
  UseModule Geometry
  UseModule Math
  Declare New(*mesh.Geometry::PolymeshGeometry_t, *indices.CArray::CArrayLong, index.i)
  Declare Delete(*v.Polygon_t)
  Declare ComputeNormal(*v.Polygon_t)
  Declare SetPosition(*v.Polygon_t,*p.v3f32)
  Declare PushEdgeArray(*v.Polygon_t,*edge.Edge_t)
  Declare PushVertexArray(*v.Polygon_t,*polygon.Polygon_t)
  Declare GetIndex(*v.Polygon_t)
  Declare GetPosition(*v.Polygon_t)
  Declare GetNormal(*v.Polygon_t)
  Declare GetNeighbors(*v.Polygon_t)
EndDeclareModule

;========================================================================================
; Polygon Module Implementation
;========================================================================================
Module Polygon
  UseModule Geometry
  
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Polygon_t)
    CArray::Delete(*Me\samples)
    CArray::Delete(*Me\neighbors)
    CArray::Delete(*Me\vertices)
    CArray::Delete(*Me\edges)
    
    ClearStructure(*Me,Polygon_t)
    
    FreeMemory(*Me)
  EndProcedure
  
  
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure New(*mesh.Geometry::PolymeshGeometry_t, *indices.CArray::CArrayLong, index.i)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Polygon_t = AllocateMemory(SizeOf(Polygon_t))
    InitializeStructure(*Me,Polygon_t)
    
    ; ----[ Initialize ]--------------------------------------------------------
    *Me\id = index
    *Me\samples = CArray::New(CArray::#ARRAY_PTR)
    *Me\neighbors = CArray::New(CArray::#ARRAY_PTR)
    *Me\vertices = CArray::New(CArray::#ARRAY_PTR)
    *Me\edges = CArray::New(CArray::#ARRAY_PTR)
    
    CArray::SetCount(*Me\vertices, CArray::GetCount(*indices))
    Protected i

    
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Compute Normal
  ;---------------------------------------------------------
  Procedure ComputeNormal(*Me.Polygon_t)
    Protected f
    For f=0 To CArray::GetCount(*Me\samples)-1
      
    Next f
  EndProcedure
  

  
  ; Set Position
  ;---------------------------------------------------------
  Procedure SetPosition(*Me.Polygon_t,*p.v3f32)
    Vector3::SetFromOther(*Me\position,*p)
  EndProcedure
  
  
  ; Push Edge Array
  ;---------------------------------------------------------
  Procedure PushEdgeArray(*Me.Polygon_t,*edge.Edge_t)
    Protected i
    Protected *e.Edge_t
    For i=0 To CArray::GetCount(*Me\edges)
      *e = CArray::GetValue(*Me\edges,i)
      ; if already there exit
      If *e\id = *edge\id : ProcedureReturn : EndIf
    Next i
    CArray::Append(*Me\edges,*edge)
  EndProcedure
  
  ; Push Polygon Array
  ;---------------------------------------------------------
  Procedure PushVertexArray(*Me.Polygon_t,*vertex.Vertex_t)
    Protected i
    Protected *v.Vertex_t
    For i=0 To CArray::GetCount(*Me\vertices)
      *v = CArray::GetValue(*Me\vertices,i)
      ; if already there exit
      If *v\id = *vertex\id : ProcedureReturn : EndIf
    Next i
    CArray::Append(*Me\vertices,*vertex)
  EndProcedure
  
  
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetIndex(*Me.Polygon_t)
    ProcedureReturn *Me\id
  EndProcedure
  
  
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetPosition(*Me.Polygon_t)
    ProcedureReturn *Me\position
  EndProcedure
  
  
  ; Get Normal
  ;---------------------------------------------------------
  Procedure GetNormal(*Me.Polygon_t)
    Protected *sample.Sample_t
    Protected i
    Protected v.v3f32
    Vector3::Set(*Me\normal,0,0,0)
    For i=0 To CArray::GetCount(*Me\samples)-1
      *sample = CArray::GetValue(*Me\samples,i)
      Vector3::AddInPlace(*Me\normal,*sample\normal)
    Next i
    Vector3::NormalizeInPlace(*Me\normal)
    ProcedureReturn *Me\normal
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Neighbors
  ;---------------------------------------------------------
  Procedure GetNeighbors(*Me.Polygon_t)
    ProcedureReturn *Me\neighbors
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Edges
  ;---------------------------------------------------------
  Procedure GetEdges(*Me.Polygon_t)
    ProcedureReturn *Me\edges
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Faces
  ;---------------------------------------------------------
  Procedure GetVertices(*Me.Polygon_t)
    ProcedureReturn *Me\vertices
  EndProcedure
  
 
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 56
; FirstLine = 49
; Folding = ---
; EnableXP
; EnableUnicode