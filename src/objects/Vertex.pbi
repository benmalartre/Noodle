XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "Geometry.pbi"


;========================================================================================
; Vertex Module Declaration
;========================================================================================
DeclareModule Vertex
  UseModule Geometry
  UseModule Math
  Declare New(index.i)
  Declare Delete(*v.Vertex_t)
  Declare ComputeNormal(*v.Vertex_t)
  Declare SetPosition(*v.Vertex_t,*p.v3f32)
  Declare PushEdgeArray(*v.Vertex_t,*edge.Edge_t)
  Declare PushTriangleArray(*v.Vertex_t,*triangle.Triangle_t)
  Declare PushPolygonArray(*v.Vertex_t,*polygon.Polygon_t)
  Declare GetIndex(*v.Vertex_t)
  Declare GetPosition(*v.Vertex_t)
  Declare GetNormal(*v.Vertex_t)
  Declare GetColor(*v.Vertex_t)
  Declare GetNeighbors(*v.Vertex_t)
EndDeclareModule

;========================================================================================
; Vertex Module Implementation
;========================================================================================
Module Vertex
  UseModule Geometry
  
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Vertex_t)
    CArray::Delete(*Me\samples)
    CArray::Delete(*Me\edges)
    CArray::Delete(*Me\polygons)
    CArray::Delete(*Me\neighbors)
    CArray::Delete(*Me\triangles)
    
    FreeStructure(*Me)
  EndProcedure
  
  
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(index.i)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Vertex_t = AllocateStructure(Vertex_t)
    
    *Me\id = index
    *Me\visited = #False
    ; ----[ Initialize ]--------------------------------------------------------
    *Me\samples = CArray::New(Types::#TYPE_PTR)
    *Me\edges = CArray::New(Types::#TYPE_PTR)
    *Me\polygons = CArray::New(Types::#TYPE_PTR)
    *Me\neighbors = CArray::New(Types::#TYPE_PTR)
    *Me\triangles = CArray::New(Types::#TYPE_PTR)
  
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Compute Normal
  ;---------------------------------------------------------
  Procedure ComputeNormal(*v.Vertex_t)
    Protected f
    For f=0 To CArray::GetCount(*v\polygons)-1
      
    Next f
  EndProcedure
  

  
  ; Set Position
  ;---------------------------------------------------------
  Procedure SetPosition(*v.Vertex_t,*p.v3f32)
    Vector3::SetFromOther(*v\position,*p)
  EndProcedure
  
  
  ; Push Edge Array
  ;---------------------------------------------------------
  Procedure PushEdgeArray(*v.Vertex_t,*edge.Edge_t)
    Protected i
    Protected *e.Edge_t
    For i=0 To CArray::GetCount(*v\edges)
      *e = CArray::GetValue(*v\edges,i)
      ; if already there exit
      If *e\id = *edge\id : ProcedureReturn : EndIf
    Next i
    CArray::Append(*v\edges,*edge)
  EndProcedure
  
  
  ; Push Triangle Array
  ;---------------------------------------------------------
  Procedure PushTriangleArray(*v.Vertex_t,*triangle.Triangle_t)
    Protected i
    Protected *t.Triangle_t
    For i=0 To CArray::GetCount(*v\triangles)
      *t = CArray::GetValue(*v\triangles,i)
      ; if already there exit
      If *t\id = *triangle\id : ProcedureReturn : EndIf
    Next i
    CArray::Append(*v\triangles,*triangle)
  EndProcedure
  
  
  ; Push Polygon Array
  ;---------------------------------------------------------
  Procedure PushPolygonArray(*v.Vertex_t,*polygon.Polygon_t)
    Protected i
    Protected *p.Polygon_t
    For i=0 To CArray::GetCount(*v\polygons)
      *p = CArray::GetValue(*v\polygons,i)
      ; if already there exit
      If *p\id = *polygon\id : ProcedureReturn : EndIf
    Next i
    CArray::Append(*v\polygons,*polygon)
  EndProcedure
  
  
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetIndex(*v.Vertex_t)
    ProcedureReturn *v\id
  EndProcedure
  
  
  ; Get Position
  ;---------------------------------------------------------
  Procedure GetPosition(*v.Vertex_t)
    ProcedureReturn *v\position
  EndProcedure
  
  
  ; Get Normal
  ;---------------------------------------------------------
  Procedure GetNormal(*v.Vertex_t)
    Protected *sample.Sample_t
    Protected i
    Protected v.v3f32
    Vector3::Set(*v\normal,0,0,0)
    For i=0 To CArray::GetCount(*v\samples)-1
      *sample = CArray::GetValue(*v\samples,i)
      Vector3::AddInPlace(*v\normal,*sample\normal)
    Next i
    Vector3::NormalizeInPlace(*v\normal)
    ProcedureReturn *v\normal
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Color
  ;---------------------------------------------------------
  Procedure GetColor(*v.Vertex_t)
    Protected *sample.Sample_t
    Protected i
    Color::Set(*v\color,0,0,0,1)
    For i=0 To CArray::GetCount(*v\samples)-1
      *sample = CArray::GetValue(*v\samples,i)
      Color::AddInPlace(*v\color,*sample\color)
    Next i
    Color::NormalizeInPlace(*v\color)
   
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Neighbors
  ;---------------------------------------------------------
  Procedure GetNeighbors(*v.Vertex_t)
    ProcedureReturn *v\neighbors
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Edges
  ;---------------------------------------------------------
  Procedure GetEdges(*v.Vertex_t)
    ProcedureReturn *v\edges
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Faces
  ;---------------------------------------------------------
  Procedure GetPolygons(*v.Vertex_t)
    ProcedureReturn *v\polygons
  EndProcedure
  
 
  
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 58
; FirstLine = 50
; Folding = ---
; EnableXP