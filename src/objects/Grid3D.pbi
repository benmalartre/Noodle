XIncludeFile "../core/Math.pbi"
XIncludeFile "Geometry.pbi"

DeclareModule Grid3D
  UseModule Geometry
  Declare New()
  Declare Delete(*Me.Grid3D_t)
  Declare InitCells(*Me.Grid3D_t, numCells.i)
  Declare DeleteCells(*Me.Grid3D_t)
  Declare ResetCells(*Me.Grid3D_t)
  Declare NewCell(*Me.Grid3D_t, index.i)
  Declare DeleteCell(*Me.Grid3D_t, index.i)
  Declare AddGeometry(*Me.Grid3D_t, *geom.Geometry_t)
  Declare Insert(*Me.Grid3D_t, *elem.Element_t)
  Declare.b Intersect(*Me.Grid3D_t, *ray.Ray_t, *p.Point_t, maxDistance.f, *minDistance)
  Declare GetElement(*Me.Grid3D_t)
;   Declare PlaceTriangle(*grid.Grid3D_t)
EndDeclareModule

Module Grid3D
  UseModule Math
  UseModule Geometry
  
  ;-----------------------------------------------------------------------
  ; Constructor (Grid3D)
  ;-----------------------------------------------------------------------
  Procedure New(elemType.i=#GEOMETRY_3D)
    Protected *Me.Grid3D_t = AllocateMemory(SizeOf(Grid3D_t))
    InitializeStructure(*Me, Grid3D_t))
    *Me\elemType = elemType
    ProcedureReturn *Me
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Destructor (Grid3D)
  ;-----------------------------------------------------------------------
  Procedure Delete(*Me.Grid3D_t)
    ClearStructure(*Me, Grid3D_t)
    FreeMemory(*Me)
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Constructor (Cell)
  ;-----------------------------------------------------------------------
  Procedure NewCell(*Me.Grid3D_t, index.i)
    Protected *cell.Cell_t = AllocateMemory(SizeOf(Cell_t))
    InitializeStructure(*cell, Cell_t))
    *Me\cells(index) = *cell
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Destructor (Cell)
  ;-----------------------------------------------------------------------
  Procedure DeleteCell(*Me.Grid3D_t, index)
    If *Me\cells(index)
      ClearStructure(*Me\cells(index), Cell_t)
      FreeMemory(*Me\cells(index)
      *Me\cells(index) = #Null
    EndIf
  EndProcedure

  ;-----------------------------------------------------------------------
  ; Add Geometry
  ;-----------------------------------------------------------------------
  Procedure AddGeometry(*Me.Grid3D_t, *geom.Geometry_t)
    Protected found.b = #False
    ForEach *Me\geometries()
      If *Me\geometries() = *geom
        found = #True
        Break
      EndIf
    Next
    If Not found:
      AddElement(*Me\geometries())
      *Me\geometries() = *geom
      *Me\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Init Cells
  ;-----------------------------------------------------------------------
  Procedure InitCells(*Me.Grid3D_t, numCells.i)
    DeleteCells(*Me)
    *Me\numCells = numCells
    ReDim *Me\cells(*Me\numCells)
    Protected i
    For i=0 To *Me\numCells - 1
      *Me\cells(i) = #Null
    Next
   
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Delete All Cells
  ;-----------------------------------------------------------------------
  Procedure DeleteCells(*Me.Grid3D_t)
    If ArraySize(*Me\cells())
      Protected i
      For i=0 To ArraySize(*Me\cells())-1
        If *Me\cells(i)
          DeleteCell(*Me\cells(i))
        EndIf
      Next
      ReDim *Me\cells(0)
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Reset All Cells
  ;-----------------------------------------------------------------------
  Procedure ResetCells(*Me.Grid3D_t)
    If ArraySize(*Me\cells())
      Protected i
      For i = 0 To *Me\numCells -1
        If *Me\cells(i) : *Me\cells(i)\hit = #False : EndIf
      Next
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ;Compute Bounding Box
  ;-----------------------------------------------------------------------
  Procedure ComputeBoundingBox(*Me.Grid3D_t)
    Box::Reset(*Me\bbox)
    Protected init.b = #False
    ForEach *Me\geometries()
      Geometry::ComputeBoundingBox(*Me\geometries())
      Protected *bbox.Geometry::Box_t = *Me\geometries()\bbox
      If Not init
        Box::SetFromOther(*Me\bbox, *bbox)
        init = #True
      Else
        Box::Union(*Me\bbox, *bbox)
      EndIf
    Next 
  EndProcedure
  
  ;-----------------------------------------------------------------------
  ; Build the grid
  ;-----------------------------------------------------------------------
  Procedure Build(*Me.Grid3D_t)
    Protected totalNumElements = ListSize(*Me\elements())
    ComputeBoundingBox(*Me)
    Protected size.v3f32
    Vector3::Scale(@size, *Me\bbox\extend, 2)
    Protected cubeRoot.f = Pow(totalNumElements / (size\x * size\y * size\z), 1/3.0)
    *Me\resolution[0] = Max(1, Min(Round(size\x * cubeRoot, #PB_Round_Down), 128))
    *Me\resolution[1] = Max(1, Min(Round(size\y * cubeRoot, #PB_Round_Down), 128))
    *Me\resolution[2] = Max(1, Min(Round(size\z * cubeRoot, #PB_Round_Down), 128))
    
    *Me\dimension\x = size\x / *Me\resolution\x
    *Me\dimension\y = size\y / *Me\resolution\y
    *Me\dimension\z = size\z / *Me\resolution\z
    
    InitCells(*Me, *Me\resolution[0] * *Me\resolution[1] * *Me\resolution[2])
  EndProcedure
  
  

; 
;     MVector A, B, C;
;     Triangle* T;
;     Mesh* mesh = _mesh->mesh;
;     unsigned offset = subMesh->offsetIndices/3;
;     
;     MVector invDimensions(1/_cellDimension[0],1/_cellDimension[1],1/_cellDimension[2]);
; 
;     // insert all the triangles in the cells
;     For(uint32_t i=0;i<totalNumTriangles;i++)
;     {
;         MVector tmin(FLT_MAX,FLT_MAX,FLT_MAX);
;         MVector tmax(-FLT_MAX,-FLT_MAX,-FLT_MAX);
;         T = mesh->getTriangle(i+offset);
;         A = mesh->getPosition(T,0);
;         B = mesh->getPosition(T,1);
;         C = mesh->getPosition(T,2);
; 
;         For (uint8_t k = 0; k < 3; ++k) {
;             If (A[k] < tmin[k]) tmin[k] = A[k];
;             If (B[k] < tmin[k]) tmin[k] = B[k];
;             If (C[k] < tmin[k]) tmin[k] = C[k];
;             If (A[k] > tmax[k]) tmax[k] = A[k];
;             If (B[k] > tmax[k]) tmax[k] = B[k];
;             If (C[k] > tmax[k]) tmax[k] = C[k];
;         }
;         
;         // convert To cell coordinates
;         tmin.x = (tmin.x - bbox.min().x) * invDimensions.x;
;         tmin.y = (tmin.y - bbox.min().y) * invDimensions.y;
;         tmin.z = (tmin.z - bbox.min().z) * invDimensions.z;
;         
;         tmax.x = (tmax.x - bbox.min().x) * invDimensions.x;
;         tmax.y = (tmax.y - bbox.min().y) * invDimensions.y;
;         tmax.z = (tmax.z - bbox.min().z) * invDimensions.z;
;         
;         uint32_t zmin = CLAMP(floor(tmin[2]), 0, _resolution[2] - 1);
;         uint32_t zmax = CLAMP(floor(tmax[2]), 0, _resolution[2] - 1);
;         uint32_t ymin = CLAMP(floor(tmin[1]), 0, _resolution[1] - 1);
;         uint32_t ymax = CLAMP(floor(tmax[1]), 0, _resolution[1] - 1);
;         uint32_t xmin = CLAMP(floor(tmin[0]), 0, _resolution[0] - 1);
;         uint32_t xmax = CLAMP(floor(tmax[0]), 0, _resolution[0] - 1);
;         
;         // loop over all the cells the triangle overlaps And insert
;         For (uint32_t z = zmin; z <= zmax; ++z)
;         {
;             For (uint32_t y = ymin; y <= ymax; ++y)
;             {
;                 For (uint32_t x = xmin; x <= xmax; ++x)
;                 {
;                     uint32_t o = z * _resolution[0] * _resolution[1] + y * _resolution[0] + x;
;                     If (_cells[o] == NULL) _cells[o] = new Cell;
;                     _cells[o]->insert(T);
;                 }
;             }
;         }
;     }
; }
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 150
; FirstLine = 138
; Folding = ---
; EnableXP