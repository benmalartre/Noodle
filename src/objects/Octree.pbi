XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Morton.pbi"
XIncludeFile "../objects/Box.pbi"
XIncludeFile "../objects/Geometry.pbi"
XIncludeFile "../objects/Triangle.pbi"
XIncludeFile "../objects/Drawer.pbi"
;=======================================================================
; DECLARATION
;=======================================================================
DeclareModule Octree
  UseModule Math
  #MAX_ELEMENTS = 64
  #LONG_BITS    = 21
  #MAX_L        = ((1<<(#LONG_BITS))-1)

  Enumeration 
    #ELEMENT_1D
    #ELEMENT_2D
    #ELEMENT_3D
  EndEnumeration
  
  Structure Point_t
    v.f[3]
  EndStructure
  
  Structure Cell_t
    depth.i
	  bmin.v3f32
	  bmax.v3f32
  
	  isLeaf.b
	  *parent.Cell_t
	  *children.Cell_t[8]
  	*elements.CArray::CArrayLong
  	color.c4f32
  	morton.i
  	elemType.i
  EndStructure
  
  Structure Octree_t Extends Cell_t
    eMax.i
	  numCells.i
	  *geom.Geometry::Geometry_t
	  Map *cells.Cell_t()
	  scl.v3f32
	  inv_scl.v3f32
  EndStructure
  
  DataSection
    CornerPermutation:
    Data.i 0,1,2,3,1,2,0,1,5,3,1,5
    Data.i 0,4,2,3,4,2,0,4,5,3,4,5
  EndDataSection
  
  
  Declare New(*bmin.v3f32, *bmax.v3f32, depth=0, elemType=#ELEMENT_3D)
  Declare Delete(*octree.Octree_t)
  
  Declare NewCell(*octree.Octree_t, *bmin.v3f32, *bmax.v3f32, depth=0)
  Declare DeleteCell(*cell.Cell_t)
  
  Declare Build(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
  Declare ComputeScale(*octree.Octree_t)
  Declare NumCells(*octree.Octree_t, *numCells)
  
  Declare GetCenter(*cell.Cell_t, *center.v3f32)
  Declare GetHalfSize(*cell.Cell_t, *halfsize.v3f32)
  
  Declare.f GetDistance1D(p.f, lower.f, upper.f)
  Declare.f GetDistance(*cell.Cell_t, *p.v3f32)
  Declare.b IntersectSphere(*cell.Cell_t, *center.v3f32, radius.f)
  
  Declare GetCell(*octree.Octree_t, morton.i, *pnt.v3f32)
  Declare GetParentCell(*octree.Octree_t, *cell.Cell_t)
  Declare LookUpCell(*octree.Octree_t, morton.i)
  
  Declare Split(*octree.Octree_t,*cell.Cell_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
  Declare Barycentric(*p.v3f32, *a.v3f32, *b.v3f32, *c.v3f32, *uvw.v3f32)
  Declare GetClosestCell(*octree.Cell_t, *point.v3f32)
  Declare RecurseGetClosestCell(*cell.Cell_t, *point.v3f32, *closestDistance)
  Declare GetNearbyCells(*cell.Cell_t, *point.v3f32, *cells.CArray::CArrayPtr, closestDistance.f)
  Declare RecurseGetNearbyCells(*cell.Cell_t, *center.v3f32, radius.f, *cells.CArray::CArrayPtr)
  Declare.f GetClosestPoint(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
  Declare.f GetClosestPointBruteForce(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
  Declare CartesianToReal(*octree.Octree_t, *cartersian.Morton::Point3D_t, *real.Math::v3f32)
  Declare RealToCartesian(*octree.Octree_t, *real.Math::v3f32, *cartersian.Morton::Point3D_t)
  Declare ClampCartesian(*octree.Octree_t, *cartersian.Morton::Point3D_t)
  Declare EncodeMorton(*octree.Octree_t, *cell.Cell_t)
  Declare GetCells(*octree.Octree_t)
  Declare GetCellsWithinRadius(*octree.Octree_t, *pnt.v3f32, radius.f, *cells.CArray::CArrayPtr)
  Declare GetAdjacentCells(*octree.Octree_t, *cell.Cell_t, *cells.CArray::CArrayPtr)
  
  Declare Draw(*cell.Cell_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
  Declare DrawLeaves(*octree.Octree_t, *drawer.Drawer::Drawer_t)
EndDeclareModule


;=======================================================================
; Implementation
;=======================================================================
Module Octree
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------------------------
  Procedure New(*bmin.v3f32, *bmax.v3f32, depth=0, elemType=#ELEMENT_3D)
    Protected *octree.Octree_t = AllocateStructure(Octree_t)
    *octree\elements = CArray::New(CArray::#ARRAY_LONG)
    *octree\depth = depth
    *octree\elemType = elemType
    
    Define minv.f = *bmin\x
    If *bmin\y > minv : minv = *bmin\y : EndIf
    If *bmin\z > minv : minv = *bmin\z : EndIf
    
    Define maxv.f = *bmax\x
    If *bmax\y < maxv : maxv = *bmax\y : EndIf
    If *bmax\z < maxv : maxv = *bmax\z : EndIf
    
    Vector3::Set(*octree\bmin, minv,minv, minv)
    Vector3::Set(*octree\bmax, maxv,maxv, maxv)

    Color::Randomize(*octree\color)
    ComputeScale(*octree)
    ProcedureReturn *octree
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DESTRUCTOR
  ;---------------------------------------------------------------------
  Procedure Delete(*octree.Octree_t)
    Define i
    For i=0 To 7
      If *octree\children[i] : DeleteCell(*octree\children[i]) : EndIf
    Next
    If *octree\elements: CArray::Delete(*octree\elements) : EndIf
    FreeStructure(*octree)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; ENCODE MORTON
  ;---------------------------------------------------------------------
  Procedure EncodeMorton(*octree.Octree_t, *cell.Cell_t)
    Protected p.Morton::Point3D_t
    Protected center.v3f32
    GetCenter(*cell, center)
    RealToCartesian(*octree, center, p)
    *cell\morton = Morton::Encode3D(p)  
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------------------------
  Procedure NewCell(*octree.Octree_t, *bmin.v3f32, *bmax.v3f32, depth=0)
    Protected *cell.Cell_t = AllocateStructure(Cell_t)
    *cell\elements = CArray::New(CArray::#ARRAY_LONG)
    *cell\depth = depth
    Vector3::SetFromOther(*cell\bmin, *bmin)
    Vector3::SetFromOther(*cell\bmax, *bmax)
    Color::Randomize(*cell\color)
    
    EncodeMorton(*octree, *cell)
     
    ProcedureReturn *cell
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DESTRUCTOR
  ;---------------------------------------------------------------------
  Procedure DeleteCell(*cell.Cell_t)
    Define i
    For i=0 To 7
      If *cell\children[i] : DeleteCell(*cell\children[i]) : EndIf
    Next
    If *cell\elements: CArray::Delete(*cell\elements) : EndIf
    FreeStructure(*cell)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; SCALE
  ;---------------------------------------------------------------------
  Procedure ComputeScale(*octree.Octree_t)
    *octree\scl\x = (*octree\bmax\x - *octree\bmin\x)/#MAX_L
    *octree\scl\y = (*octree\bmax\y - *octree\bmin\y)/#MAX_L
    *octree\scl\z = (*octree\bmax\z - *octree\bmin\z)/#MAX_L

    Vector3::Invert(*octree\inv_scl, *octree\scl)
  EndProcedure
  
  
  ;---------------------------------------------------------------------
  ; GET CENTER
  ;---------------------------------------------------------------------
  Procedure GetCenter(*cell.Cell_t, *center.v3f32)
    Vector3::Add(*center, *cell\bmin, *cell\bmax)
    Vector3::ScaleInPlace(*center, 0.5)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET HALF SIZE
  ;---------------------------------------------------------------------
  Procedure GetHalfSize(*cell.Cell_t, *halfsize.v3f32)
    Vector3::Sub(*halfsize, *cell\bmax, *cell\bmin)
    Vector3::ScaleInPlace(*halfsize, 0.5)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; LOOKUP CELL
  ;---------------------------------------------------------------------
  Procedure LookUpCell(*octree.Octree_t, morton.i)
    
    If FindMapElement(*octree\cells(), Str(morton))
      ProcedureReturn *octree\cells()
    Else
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
  Procedure RecurseGetCell(*cell.Cell_t, morton.i, depth.i)
    If Not *cell\isLeaf
      Define i
      Define best.i = -1
      Define childCode
      Define cellCode
      Define childIndex
      Define maxDiff = 8
      Define diff
      For i=0 To 7
        If *cell\children[i]
          childCode = (morton >> depth) & 7
          cellCode =  (*cell\morton >> depth) & 7
          diff = (childCode ! cellCode)
          If diff < maxDiff
            maxDiff = diff
            best = i
          EndIf
        EndIf
      Next
      If best > -1
        ProcedureReturn RecurseGetCell(*cell\children[best], morton, depth-3)
      EndIf
    Else
      ProcedureReturn *cell
    EndIf
    
    
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CELL
  ;---------------------------------------------------------------------
  Procedure GetCell(*octree.Octree_t, morton.i, *pnt.v3f32)
    Define *cell.Cell_t = *octree
    Define depth.i = 60
    Define childCode, childIndex
    While Not *cell\isLeaf And depth > 0
      childCode = (morton >> depth) & 7
      childIndex = (childCode & 1) << 2+ ((childCode >> 1) & 1) << 1 +  ((childCode >> 2) & 1)
      If *cell\children[childIndex]
        *cell = *cell\children[childIndex]
      Else
        Break
      EndIf
      depth - 3
    Wend

    If Not *cell\isLeaf
      Define closestDistance.f = Math::#F32_MAX
      If *cell\parent
        ProcedureReturn *cell\parent
      Else
        ProcedureReturn *cell
      EndIf
      
    EndIf
    ProcedureReturn *cell
    
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET PARENT CELL
  ;---------------------------------------------------------------------
  Procedure GetParentCell(*octree.Octree_t, *cell.Cell_t)
    Define parentCode.i = (*cell\morton >> 3) << 3
    ProcedureReturn LookUpCell(*octree, parentCode)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; VISIT ALL
  ;---------------------------------------------------------------------
  Procedure VisitAll(*octree.Octree_t, *cell.Cell_t)
    Define i
    For i=0 To 7
      If *cell\children[i]
        Define childCode.l = (*cell\morton<<3) | i
        Define *child.Cell_t = LookUpCell(*octree, childCode)

        If *child : VisitAll(*octree, *child) : EndIf
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET DISTANCE 1D
  ;---------------------------------------------------------------------
  Procedure.f GetDistance1D(p.f, lower.f, upper.f)
    If p < lower 
      ProcedureReturn lower - p:
    ElseIf p > upper
      ProcedureReturn p - upper
    Else
      ProcedureReturn Math::Min(p - lower, upper - p)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; CLEAR
  ;---------------------------------------------------------------------
  Procedure Clear(*cell.Cell_t)
    Define i
    For i=0 To 7
      If *cell\children[i] : Octree::Delete(*cell\children[i]) : EndIf
    Next
    If CArray::GetCount(*cell\elements): CArray::SetCount(*cell\elements, 0) : EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; INTERSECT SPHERE
  ;---------------------------------------------------------------------
  Procedure.b IntersectSphere(*cell.Cell_t, *center.v3f32, radius.f)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define *bmin = *cell\bmin
      Define *bmax = *cell\bmax

      ! mov rsi, [p.p_center]             ; load sphere center in cpu
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_bmin]               ; load box min in cpu
      ! movups xmm1, [rsi]
      ! mov rsi, [p.p_bmax]               ; load box max in cpu
      ! movups xmm2, [rsi]
      ! movss xmm3, [p.v_radius]          ; load radius in cpu
      ! mulps xmm3, xmm3                  ; square radius : r2
      
      ! movaps xmm4, xmm0                 ; copy center in xmm4
      ! subps xmm4, xmm1                  ; center - box min
    
      ! movaps xmm5, xmm0                 ; copy center in xmm5
      ! subps xmm5, xmm2                  ; center - box max
      
      ! mulps xmm4, xmm4                  ; square center - box min
      ! mulps xmm5, xmm5                  ; square center - box max
     
      ! movaps xmm6, xmm0                 ; copy sphere center in xmm6
      ! cmpps xmm6, xmm1, 1               ; compare center < box min
     
      ! movaps xmm7, xmm0                 ; copy sphere center in xmm7
      ! cmpps xmm7, xmm2, 6               ; compare center > box max
      
      ! andps xmm4, xmm6                  ; reset according to comparison mask
      ! andps xmm5, xmm7                  ; reset according to comparison mask
      
      ! movups xmm8, [math.l_sse_zero_vec]
      ! blendps xmm4, xmm8, 1000b         ; reset fourth bit
      ! blendps xmm5, xmm8, 1000b         ; reset fourth bit
      
      ! addps xmm4, xmm5                  ; add together
      ! haddps xmm4, xmm4                 ; horizontal add first pass
      ! haddps xmm4, xmm4                 ; horizontal add second pass
      
      ! comiss xmm4, xmm3                 ; compare dmin <= r2
      ! jbe cell_intersection             ; if below or equal we've got an intersection
      ! jmp no_cell_intersection          ; no intersection otherwise
      
      ! cell_intersection:
      ProcedureReturn #True
      
      ! no_cell_intersection:
      ProcedureReturn #False
          
    CompilerElse
      Define r2.f = radius * radius
      Define dmin.f = 0
      If *center\x < *cell\bmin\x : dmin + Pow(*center\x-*cell\bmin\x, 2)
      ElseIf *center\x > *cell\bmax\x : dmin + Pow(*center\x-*cell\bmax\x, 2)
      EndIf
      
      If *center\y < *cell\bmin\y : dmin + Pow(*center\y-*cell\bmin\y, 2)
      ElseIf *center\y > *cell\bmax\y : dmin + Pow(*center\y-*cell\bmax\y, 2)
      EndIf
      
      If *center\z < *cell\bmin\z : dmin + Pow(*center\z-*cell\bmin\z, 2)
      ElseIf *center\z > *cell\bmax\z : dmin + Pow(*center\z-*cell\bmax\z, 2)
      EndIf
      ProcedureReturn Bool(dmin <= r2)
    CompilerEndIf
    
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CURRENT CORNER
  ;---------------------------------------------------------------------
  Procedure GetCurrentCorner(index.i, axis.i)
    If axis = 0 : ProcedureReturn PeekI(?CornerPermutation + (index * 3) * 8)
    ElseIf axis = 1 : ProcedureReturn PeekI(?CornerPermutation + (index * 3 + 1) * 8)
    Else : ProcedureReturn PeekI(?CornerPermutation + (index * 3 + 2) * 8)
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET FURTHEST CORNER
  ;---------------------------------------------------------------------
  Procedure GetFurthestCorner(*cell.Cell_t, *point.v3f32, *corner.v3f32)
    Protected delta.v3f32
    Define dist.f
    Define furthestDist.f=-1.0
    Dim P(6)
    P(0) = *cell\bmin\x
    P(1) = *cell\bmin\y
    P(2) = *cell\bmin\z
    P(3) = *cell\bmax\x
    P(4) = *cell\bmax\y
    P(5) = *cell\bmax\z
    
    Protected z
    Protected current.v3f32
    For z=0 To 7
      Vector3::Set(current, P(GetCurrentCorner(z, 0)), P(GetCurrentCorner(z, 1)), P(GetCurrentCorner(z, 2)))
      Vector3::Sub(delta, *point, current)
      dist = Vector3::Length(delta)
      If dist > furthestDist
        furthestDist = dist
        Vector3::SetFromOther(*corner, current)
      EndIf
    Next

  EndProcedure
  
  ; ---------------------------------------------------------------------
  ; BUILD
  ; ---------------------------------------------------------------------
  Procedure Build(*octree.Octree_t, *geom.Geometry::Geometry_t, maxDepth.i)
    Clear(*octree)
    Define i
    Select *octree\elemType
      Case #ELEMENT_1D
        Define numPoints = *geom\nbpoints
        CArray::SetCount(*octree\elements, numPoints)
        For i=0 To numPoints - 1 : CArray::SetValueL(*octree\elements, i, i) : Next
        
      Case #ELEMENT_2D
        Select *geom\type   
          Case Geometry::#Curve
            Define *curve.Geometry::CurveGeometry_t = *geom
            Define numSegments = *curve\nbsegments
             CArray::SetCount(*octree\elements, numSegments)
             For i=0 To numSegments - 1 : CArray::SetValueL(*octree\elements, i, i) : Next
             
          Case Geometry::#Polymesh
            Define *mesh.Geometry::PolymeshGeometry_t = *geom
            Define numEdges = *mesh\nbedges
             CArray::SetCount(*octree\elements, numEdges)
             For i=0 To numEdges - 1 : CArray::SetValueL(*octree\elements, i, i) : Next
             
          Default
            MessageRequester("[OCTREE]", "Element Type 2D Not supported For "+Str(*geom\type))
            
        EndSelect

      Case #ELEMENT_3D
        Define *mesh.Geometry::PolymeshGeometry_t = *geom
        Define numTriangles = *mesh\nbtriangles
        CArray::SetCount(*octree\elements, numTriangles)
        For i=0 To numTriangles - 1 : CArray::SetValueL(*octree\elements, i, i) : Next
        
    EndSelect
    
    Define minv.f = *geom\bbox\origin\x - *geom\bbox\extend\x
    If  *geom\bbox\origin\y - *geom\bbox\extend\y < minv :  minv = *geom\bbox\origin\y - *geom\bbox\extend\y : EndIf
    If  *geom\bbox\origin\z - *geom\bbox\extend\z < minv :  minv = *geom\bbox\origin\z - *geom\bbox\extend\z : EndIf
    
    Define maxv.f = *geom\bbox\origin\x + *geom\bbox\extend\x
    If  *geom\bbox\origin\y + *geom\bbox\extend\y > maxv :  maxv = *geom\bbox\origin\y + *geom\bbox\extend\y : EndIf
    If  *geom\bbox\origin\z + *geom\bbox\extend\z > maxv :  maxv = *geom\bbox\origin\z + *geom\bbox\extend\z : EndIf
    
    Vector3::Set(*octree\bmin, minv,minv, minv)
    Vector3::Set(*octree\bmax, maxv,maxv, maxv)

    ComputeScale(*octree)
    
    *octree\eMax = maxDepth
    *octree\geom = *geom
    *octree\morton = EncodeMorton(*octree, *octree)
    Split(*octree, *octree, *geom, maxDepth)
   
  EndProcedure  
  
  ;---------------------------------------------------------------------
  ; BARYCENTRIC
  ;---------------------------------------------------------------------
  Procedure Barycentric(*p.v3f32, *a.v3f32, *b.v3f32, *c.v3f32, *uvw.v3f32)
    Define.v3f32 v0, v1, v2
    Vector3::Sub(v0, *b, *a)
    Vector3::Sub(v1, *c, *a)
    Vector3::Sub(v2, *p, *a)

    Define d00.f = Vector3::Dot(v0,v0)
    Define d01.f = Vector3::Dot(v0,v1)
    Define d11.f = Vector3::Dot(v1,v1)
    Define d20.f = Vector3::Dot(v2,v0)
    Define d21.f = Vector3::Dot(v2,v1)
    Define denom.f = d00 * d11 - d01 * d01
    *uvw\y = (d11 * d20 - d01 * d21) / denom
    *uvw\z = (d00 * d21 - d01 * d20) / denom
    *uvw\x = 1.0 - v - w
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; RECURSE GET CLOSEST CELL
  ;---------------------------------------------------------------------
  Procedure RecurseGetClosestCell(*cell.Cell_t, *point.v3f32, *closestDistance)
    Protected distance.f
    If *cell\isLeaf
      distance = GetDistance(*cell, *point)
      
      If distance < PeekF(*closestDistance)
        PokeF(*closestDistance, distance)
        ProcedureReturn *cell
      EndIf
    Else
      Protected cid = -1
      Protected cdist.f = PeekF(*closestDistance)
      Protected k
      Protected *current.Cell_t
      For k=0 To 7
        *current = *cell\children[k]
        If *current <> #Null
          distance = GetDistance(*current, *point)
          If distance<=cdist
            cdist=distance
            cid=k
          EndIf
        EndIf
      Next
      If cid >= 0
        Define *currentCell = RecurseGetClosestCell(*cell\children[cid], *point, *closestDistance)
        If *currentCell : ProcedureReturn *currentCell : EndIf
      EndIf
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CLOSEST CELL
  ;---------------------------------------------------------------------
  Procedure GetClosestCell(*cell.Cell_t, *point.v3f32)

    Protected closestDistance.f = #F32_MAX
    
    ; the Case of low polygon count
    If *cell\isLeaf
      ProcedureReturn *cell
    ; normal Case
    Else
      Protected j
      Define *closestCell.Cell_t = #Null
      For j=0 To 7
        If *cell\children[j]
          Define *currentCell = RecurseGetClosestCell(*cell\children[j], *point, @closestDistance)
          If *currentCell : *closestCell = *currentCell : EndIf
        EndIf
      Next j
      ProcedureReturn *closestCell
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CLOSEST CELL MORTON
  ;---------------------------------------------------------------------
  Procedure GetClosestCellMorton(*octree.Octree_t, *point.v3f32)
    Define p.Morton::Point3D_t
    Octree::RealToCartesian(*octree, *point, p)
    Octree::ClampCartesian(*octree, p)
    Define m = Morton::Encode3D(p)
    Define *closestCell.Cell_t = Octree::GetCell(*octree, m, *point)
    ProcedureReturn *closestCell
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; RECURSE NEARBY CELLS
  ;---------------------------------------------------------------------
  Procedure RecurseGetNearbyCells(*cell.Cell_t, *center.v3f32, radius.f, *cells.CArray::CArrayPtr)
    Protected *child.Cell_t = #Null
    Protected k
    If Not *cell\isLeaf
      For k=0 To 7
        *child = *cell\children[k]
        If *child <> #Null
          If IntersectSphere(*child, *center, radius)
            RecurseGetNearbyCells(*child, *center, radius, *cells)
          EndIf
        EndIf
      Next
    Else
      If IntersectSphere(*cell, *center, radius)
        CArray::AppendPtr(*cells, *cell)
      EndIf
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET NEARBY CELLS
  ;---------------------------------------------------------------------
  Procedure GetNearbyCells(*cell.Cell_t, *point.v3f32, *cells.CArray::CArrayPtr, radius.f)
    If Not *cell\isLeaf
      Protected j
      For j=0 To 7
        If *cell\children[j]
          RecurseGetNearbyCells(*cell\children[j], *point, radius, *cells)
        EndIf
      Next
    EndIf
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; Get Distance
  ;---------------------------------------------------------------------
  Procedure.f GetDistance(*cell.Cell_t, *point.v3f32)
    Protected dx.f = GetDistance1D(*point\x, *cell\bmin\x, *cell\bmax\x)
    Protected dy.f = GetDistance1D(*point\y, *cell\bmin\y, *cell\bmax\y)
    Protected dz.f = GetDistance1D(*point\z, *cell\bmin\z, *cell\bmax\z)
    ProcedureReturn Sqr(dx * dx + dy * dy + dz * dz)
  EndProcedure

  ;---------------------------------------------------------------------
  ; Check Cell Elements
  ;---------------------------------------------------------------------
  Procedure CheckCellElements(*cell.Cell_t, *pnt.v3f32, *loc.Geometry::Location_t, *closestDistance, *geom.Geometry::PolymeshGeometry_t)
    Define i, j
    Define.v3f32 *a, *b, *c
    Define.v3f32 closest, uvw, delta
    Define distance.f
    For i=0 To *cell\elements\itemCount - 1
      j = CArray::GetValueL(*cell\elements, i)
      *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3))
      *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3+1))
      *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3+2))
      
      Triangle::ClosestPoint(*a, *b, *c, *pnt , closest, uvw)
      Vector3::Sub(delta,*pnt, closest)
      distance = Vector3::Length(delta)
      If distance < PeekF(*closestDistance)
        PokeF(*closestDistance, distance)
        *loc\tid = j
        Vector3::SetFromOther(*loc\p, closest)
        Vector3::SetFromOther(*loc\uvw, uvw)
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; Recurse Check Cell Elements
  ;---------------------------------------------------------------------
  Procedure RecurseCheckCellElements(*cell.Cell_t, *pnt.v3f32, *loc.Geometry::Location_t, *closestDistance, *geom.Geometry::PolymeshGeometry_t)
    If Not *cell\isLeaf
      Define i
      For i=0 To 7
        If *cell\children[i]
          If IntersectSphere(*cell\children[i], *pnt, PeekF(*closestDistance))
            RecurseCheckCellElements(*cell\children[i], *pnt, *loc, *closestDistance, *geom)
          EndIf
        EndIf
      Next
    Else
      If IntersectSphere(*cell, *pnt, PeekF(*closestDistance))
        CheckCellElements(*cell, *pnt, *loc, *closestDistance, *geom)
      EndIf
    EndIf
  EndProcedure
  

  ;---------------------------------------------------------------------
  ; Get Closest Point
  ;---------------------------------------------------------------------
  Procedure.f GetClosestPoint(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
    Protected *closestCell.Cell_t  = GetClosestCellMorton(*octree, *pnt)
    If Not *closestCell : ProcedureReturn -1.0 : EndIf
    
    Define closestDistance.f = #F32_MAX
    Define distance.f
    Define.v3f32 closest, delta, uvw
    Define closestTriangle.i = -1
    Define *geom.Geometry::PolymeshGeometry_t = *octree\geom
    Define.v3f32 *a, *b, *c
    Define i, j
    
    If *closestCell\isLeaf
      CheckCellElements(*closestCell, *pnt, *loc, @closestDistance, *geom)
    Else
      RecurseCheckCellElements(*closestCell, *pnt, *loc, @closestDistance, *geom)
    EndIf
   
    ProcedureReturn closestDistance
    
  EndProcedure  
  
    ;---------------------------------------------------------------------
  ; Get Closest Point
  ;---------------------------------------------------------------------
  Procedure.f GetClosestPointBruteForce(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
    Protected closestDistance.f=#F32_MAX, distance.f
    Protected *geom.Geometry::PolymeshGeometry_t = *octree\geom
    Define t
    Define.v3f32 *a, *b, *c
    Define.v3f32 closest, uvw, delta
    For t=0 To *geom\nbtriangles - 1
      *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3))
      *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3+1))
      *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3+2))
      Triangle::ClosestPoint(*a, *b,*c, *pnt, closest, uvw)
      Vector3::Sub(delta,*pnt, closest)
      distance = Vector3::Length(delta)
      If distance < closestDistance
        closestDistance = distance
        *loc\tid = t
        Vector3::SetFromOther(*loc\p, closest)
        Vector3::SetFromOther(*loc\uvw, uvw)
      EndIf
    Next
    
    ProcedureReturn closestDistance
    
  EndProcedure  
  
  ; ---------------------------------------------------------------------
  ; CREATE CELL ELEMENT TYPE 1D (points)
  ; ---------------------------------------------------------------------
  Macro CreateCellElementType1D(_i,_j,_k)
    m = 4*_i+2*_j+_k
    Vector3::Set(bmin, xx\v[_i], yy\v[_j], zz\v[_k])
    Vector3::Set(bmax, xx\v[_i+1], yy\v[_j+1], zz\v[_k+1])
    *child = Octree::NewCell(*octree, bmin, bmax, *cell\depth + 1)
    *child\parent = *cell
    GetCenter(*child, box\origin)
    GetHalfSize(*child, box\extend)
    
    Define *hits = AllocateMemory(*cell\elements\itemCount)
    Define numHits = Box::ContainsPoints(box, 
                                         *geom\a_positions\data,
                                         *cell\elements\data,
                                         *cell\elements\itemCount,
                                         *hits)
    

    CArray::SetCount(*child\elements, numHits)

    Define idx = 0
    For t=0 To numElements - 1
      If PeekB(*hits+t)
        PokeL(*child\elements\data + idx*4, PeekL(*cell\elements\data + t * 4))  
        idx + 1
      EndIf
    Next

    FreeMemory(*hits)
    
    If Not *child\elements\itemCount
      *cell\children[m] = #Null
      DeleteCell(*child)
    Else
      *cell\children[m] = *child
      Split(*octree, *cell\children[m], *geom, maxDepth)
    EndIf
  EndMacro
  
  ; ---------------------------------------------------------------------
  ; CREATE CELL ELEMENT TYPE 2D (segments)
  ; ---------------------------------------------------------------------
  Macro CreateCellElementType2D(_i,_j,_k)
    m = 4*_i+2*_j+_k
    Vector3::Set(bmin, xx\v[_i], yy\v[_j], zz\v[_k])
    Vector3::Set(bmax, xx\v[_i+1], yy\v[_j+1], zz\v[_k+1])
    *child = Octree::NewCell(*octree, bmin, bmax, *cell\depth + 1)
    *child\parent = *cell
    GetCenter(*child, box\origin)
    GetHalfSize(*child, box\extend)
    
;     Define *hits = AllocateMemory(*cell\elements\itemCount)
; 
;     Define numHits = Box::IntersectSegments(*geom\a_positions\data,
;                                             *geom\a_triangleindices\data,
;                                             *cell\elements\data,
;                                             *cell\elements\itemCount, 
;                                             box, 
;                                             *hits)
; 
;     CArray::SetCount(*child\elements, numHits)
; 
;     Define idx = 0
;     For t=0 To numElements - 1
;       If PeekB(*hits+t)
;         PokeL(*child\elements\data + idx*4, PeekL(*cell\elements\data + t * 4))  
;         idx + 1
;       EndIf
;     Next
; 
;     FreeMemory(*hits)
;     
;     If Not *child\elements\itemCount
;       *cell\children[m] = #Null
;       DeleteCell(*child)
;     Else
;       *cell\children[m] = *child
;       Split(*octree, *cell\children[m], *geom, maxDepth)
;     EndIf
  EndMacro
  
  ; ---------------------------------------------------------------------
  ; CREATE CELL ELEMENT TYPE 3D (triangles)
  ; ---------------------------------------------------------------------
  Macro CreateCellElementType3D(_i,_j,_k)
    m = 4*_i+2*_j+_k
    Vector3::Set(bmin, xx\v[_i], yy\v[_j], zz\v[_k])
    Vector3::Set(bmax, xx\v[_i+1], yy\v[_j+1], zz\v[_k+1])
    *child = Octree::NewCell(*octree, bmin, bmax, *cell\depth + 1)
    *child\parent = *cell
    Vector3::Add(box\origin, bmin, bmax)
    Vector3::ScaleInPlace(box\origin, 0.5)
    Vector3::Sub(box\extend, bmax, bmin)
    
    numHits = 0
    For t=0 To numElements - 1
      xt = CArray::GetValueL(*cell\elements, t)
      *a = CArray::GetValue(*mesh\a_positions, CArray::GetValueL(*mesh\a_triangleindices, xt*3))
      *b = CArray::GetValue(*mesh\a_positions, CArray::GetValueL(*mesh\a_triangleindices, xt*3+1))
      *c = CArray::GetValue(*mesh\a_positions, CArray::GetValueL(*mesh\a_triangleindices, xt*3+2))

      If Triangle::Touch(  box, *a, *b, *c) : CArray::AppendL(*child\elements, xt) : numHits + 1 :EndIf
    Next
    
    
    Define *hits = AllocateMemory(*cell\elements\itemCount)

    Define numHits = Triangle::TouchArray(*mesh\a_positions\data,
                                          *mesh\a_triangleindices\data,
                                          *cell\elements\data,
                                          *cell\elements\itemCount, 
                                          box, 
                                          *hits)

    CArray::SetCount(*child\elements, numHits)

    Define idx = 0
    For t=0 To numElements - 1
      If PeekB(*hits+t)
        PokeL(*child\elements\data + idx*4, PeekL(*cell\elements\data + t * 4))  
        idx + 1
      EndIf
    Next

    FreeMemory(*hits)
        
    If Not *child\elements\itemCount
      *cell\children[m] = #Null
      DeleteCell(*child)
    Else
      *cell\children[m] = *child
      Split(*octree, *cell\children[m], *mesh, maxDepth)
    EndIf
  EndMacro
  
  ; ---------------------------------------------------------------------
  ; SPLIT
  ; ---------------------------------------------------------------------
  Procedure Split(*octree.Octree_t, *cell.Cell_t, *geom.Geometry::Geometry_t, maxDepth.i)
    Protected numElements = *cell\elements\itemCount
    If numElements <= #MAX_ELEMENTS Or *cell\depth >= maxDepth:
      *cell\isLeaf = #True
      ProcedureReturn
    EndIf

    *cell\isLeaf = #False
    Protected i, j, k, m, t
    Define.Point_t xx, yy, zz
    Define.v3f32 *xx = xx
    Define.v3f32 *yy = yy
    Define.v3f32 *zz = zz
    
    Define xt
    Define numHits = 0

    Define *child.Cell_t
    Vector3::Set(*xx, *cell\bmin\x, 0.5*(*cell\bmin\x+*cell\bmax\x), *cell\bmax\x)
    Vector3::Set(*yy, *cell\bmin\y, 0.5*(*cell\bmin\y+*cell\bmax\y), *cell\bmax\y)
    Vector3::Set(*zz, *cell\bmin\z, 0.5*(*cell\bmin\z+*cell\bmax\z), *cell\bmax\z)
    
    Define.v3f32 center, halfsize
    Define.v3f32 bmin, bmax
    Define box.Geometry::Box_t
    Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32
    
    Select *octree\elemType
      Case #ELEMENT_1D
        CreateCellElementType1D(0,0,0)
        CreateCellElementType1D(0,0,1)
        CreateCellElementType1D(0,1,0)
        CreateCellElementType1D(0,1,1)
        CreateCellElementType1D(1,0,0)
        CreateCellElementType1D(1,0,1)
        CreateCellElementType1D(1,1,0)
        CreateCellElementType1D(1,1,1)
        
      Case #ELEMENT_2D
        CreateCellElementType2D(0,0,0)
        CreateCellElementType2D(0,0,1)
        CreateCellElementType2D(0,1,0)
        CreateCellElementType2D(0,1,1)
        CreateCellElementType2D(1,0,0)
        CreateCellElementType2D(1,0,1)
        CreateCellElementType2D(1,1,0)
        CreateCellElementType2D(1,1,1)
        
      Case #ELEMENT_3D
        Define *mesh.Geometry::PolymeshGeometry_t = *geom
        CreateCellElementType3D(0,0,0)
        CreateCellElementType3D(0,0,1)
        CreateCellElementType3D(0,1,0)
        CreateCellElementType3D(0,1,1)
        CreateCellElementType3D(1,0,0)
        CreateCellElementType3D(1,0,1)
        CreateCellElementType3D(1,1,0)
        CreateCellElementType3D(1,1,1)
        
    EndSelect
    
    
    Carray::SetCount(*cell\elements, 0)
  EndProcedure
  
  
  ;---------------------------------------------------------------------
  ; GET NUM LEAVE CELLS
  ;---------------------------------------------------------------------
  Procedure NumCells(*octree.Octree_t, *numCells)
    Protected i
    For i=0 To 7
      If *octree\children[i]
        If *octree\children[i]\isLeaf
          PokeL(*numCells, PeekL(*numCells)+1)
        Else
          NumCells(*octree\children[i], *numCells)
        EndIf
      EndIf
    Next
  EndProcedure
  
  
  ;---------------------------------------------------------------------
  ; GET CELLS
  ;---------------------------------------------------------------------
  Procedure RecurseGetCells(*cell.Cell_t, Map *nodes.Cell_t())
    If Not *cell\isLeaf
      Protected i
      For i=0 To 7
        If *cell\children[i]
          *nodes(Str(*cell\children[i]\morton)) = *cell\children[i]
          If Not *cell\children[i]\isLeaf
            RecurseGetCells(*cell\children[i], *nodes())
          EndIf
        EndIf
      Next
    EndIf
  EndProcedure
  
  Procedure GetCells(*octree.Octree_t)
    ClearMap(*octree\cells())
    RecurseGetCells(*octree, *octree\cells())
    
;     SortStructuredList(*octree\leaves(), #PB_Sort_Ascending, OffsetOf(Cell_t\morton), TypeOf(Cell_t\morton))
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CELLS
  ;---------------------------------------------------------------------
  Procedure GetCellsWithinRadius(*octree.Octree_t, *pnt.v3f32, radius.f, *cells.CArray::CArrayPtr)
    CArray::SetCount(*cells, 0)
    ForEach *octree\cells()
      If IntersectSphere(*octree\cells(), *pnt, radius)
        CArray::AppendPtr(*cells, *octree\cells())
      EndIf
    Next
  EndProcedure
  
  Procedure GetAdjacentCells(*octree.Octree_t, *cell.Cell_t, *cells.CArray::CArrayPtr)
    ForEach *octree\cells()
      
    Next
    
  EndProcedure
  
  
;   template <typename PointT, typename ContainerT>
; template <typename Distance>
; void Octree<PointT, ContainerT>::radiusNeighbors(const Octant* octant, const PointT& query, float radius,
;                                                  float sqrRadius, std::vector<uint32_t>& resultIndices) const
; {
;   const ContainerT& points = *data_;
; 
;   // If search ball S(q,r) contains octant, simply add point indexes.
;   If (contains<Distance>(query, sqrRadius, octant))
;   {
;     uint32_t idx = octant->start;
;     For (uint32_t i = 0; i < octant->size; ++i)
;     {
;       resultIndices.push_back(idx);
;       idx = successors_[idx];
;     }
; 
;     Return;  // early pruning.
;   }
; 
;   If (octant->isLeaf)
;   {
;     uint32_t idx = octant->start;
;     For (uint32_t i = 0; i < octant->size; ++i)
;     {
;       const PointT& p = points[idx];
;       float dist = Distance::compute(query, p);
;       If (dist < sqrRadius) resultIndices.push_back(idx);
;       idx = successors_[idx];
;     }
; 
;     Return;
;   }
  ; ---------------------------------------------------------------------
  ; Conversion Utils
  ; ---------------------------------------------------------------------
  Procedure CartesianToReal(*octree.Octree_t, *cartersian.Morton::Point3D_t, *real.Math::v3f32)
    *real\x = *octree\scl\x * *cartersian\x + *octree\bmin\x
    *real\y = *octree\scl\y * *cartersian\y + *octree\bmin\y
    *real\z = *octree\scl\z * *cartersian\z + *octree\bmin\z
  EndProcedure
  
  Procedure RealToCartesian(*octree.Octree_t, *real.Math::v3f32, *cartersian.Morton::Point3D_t)
    *cartersian\x = *octree\inv_scl\x * (*real\x - *octree\bmin\x)
    *cartersian\y = *octree\inv_scl\y * (*real\y - *octree\bmin\y)
    *cartersian\z = *octree\inv_scl\z * (*real\z - *octree\bmin\z)
  EndProcedure
  
  Procedure ClampCartesian(*octree.Octree_t, *cartersian.Morton::Point3D_t)
    If *cartersian\x < 0 : *cartersian\x =0 : ElseIf *cartersian\x > #MAX_L : *cartersian\x = #MAX_L :EndIf
    If *cartersian\y < 0 : *cartersian\y =0 : ElseIf *cartersian\y > #MAX_L : *cartersian\y = #MAX_L :EndIf
    If *cartersian\z < 0 : *cartersian\z =0 : ElseIf *cartersian\z > #MAX_L : *cartersian\z = #MAX_L :EndIf
  EndProcedure

  ;---------------------------------------------------------------------
  ; DRAW MORTON LEAVES
  ;---------------------------------------------------------------------
  Procedure DrawLeaves(*octree.Octree_t, *drawer.Drawer::Drawer_t)
    Protected *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
    CArray::SetCount(*positions, MapSize(*octree\cells()))
    Protected p.v3f32
    Protected index.i = 0

    ForEach *octree\cells()
      Vector3::Add(p, *octree\cells()\bmin, *octree\cells()\bmax)
      Vector3::ScaleInPlace(p, 0.5)
      CArray::SetValue(*positions, index, p)
      index + 1
    Next
    Define *L.Drawer::Line_t = Drawer::AddStrip(*drawer, *positions)
    Drawer::SetSize(*L, 1)
    Drawer::SetColor(*L, Color::GREEN)
    CArray::Delete(*positions)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DRAW OCTREE
  ;---------------------------------------------------------------------
  Procedure Draw(*cell.Cell_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
    Protected m.m4f32
    Protected s.v3f32
    Protected p.v3f32
    Protected *a.v3f32, *b.v3f32, *c.v3f32
    Protected *col.c4f32
    Protected *box.Drawer::Box_t
    Matrix4::SetIdentity(m)
    If *cell\isLeaf
      Vector3::Sub(s, *cell\bmax, *cell\bmin)
      Vector3::Add(p, *cell\bmin, *cell\bmax)
      Vector3::ScaleInPlace(p, 0.5)
      Matrix4::SetScale(m, s)
      Matrix4::SetTranslation(m, p)
      *box = Drawer::AddBox(*drawer, m)
      
      Drawer::SetColor(*box,Color::WHITE) 
      
;       Protected *positions.CArray::CarrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
;       Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
;       Protected numTriangles.i = CArray::GetCount(*cell\elements)
;       CArray::SetCount(*positions, numTriangles * 3)
;       CArray::SetCount(*colors, numTriangles * 3)
;       Define t, a, b, c
;       For t=0 To numTriangles -1
;         a = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*cell\elements, t) *3)
;         b = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*cell\elements, t) *3+1)
;         c = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*cell\elements, t) *3+2)
;         
;         *a = CArray::GetValue(*positions, t*3)
;         *b = CArray::GetValue(*positions, t*3+1)
;         *c = CArray::GetValue(*positions, t*3+2)
;         
;         CopyMemory(CArray::GetValue(*geom\a_positions, a), *a, SizeOf(v3f32))
;         CopyMemory(CArray::GetValue(*geom\a_positions, b), *b, SizeOf(v3f32))
;         CopyMemory(CArray::GetValue(*geom\a_positions, c), *c, SizeOf(v3f32))
;         
;         *col = CArray::GetValue(*colors, t*3)
;         Color::SetFromOther(*col, *cell\color)
;         *col = CArray::GetValue(*colors, t*3+1)
;         Color::SetFromOther(*col, *cell\color)
;         *col = CArray::GetValue(*colors, t*3+2)
;         Color::SetFromOther(*col, *cell\color)
;       Next
      
;       Protected *triangles.Drawer::Triangle_t = Drawer::AddColoredTriangle(*drawer, *positions, *colors)
;       CArray::Delete(*positions)
;       CArray::Delete(*colors)
    Else
      Protected i
;       Vector3::Sub(s, *cell\bmax, *cell\bmin)
;       Vector3::Add(p, *cell\bmin, *cell\bmax)
;       Vector3::ScaleInPlace(p, 0.5)
;       Matrix4::SetScale(m, s)
;       Matrix4::SetTranslation(m, p)
;       *box = Drawer::AddBox(*drawer, m)
;       
;       Select *cell\state
;         Case Octree::#STATE_DEFAULT
;            Drawer::SetColor(*box,Color::_WHITE())
;         Case Octree::#STATE_HIT
;            Drawer::SetColor(*box,Color::_RED())
;         Case Octree::#STATE_NEARBY
;           Drawer::SetColor(*box,Color::_YELLOW())
;         Default
;           Drawer::SetColor(*box,Color::_WHITE())
;       EndSelect
      For i=0 To 7
        If *cell\children[i]
          Draw(*cell\children[i], *drawer, *geom)
        EndIf
      Next
      
    EndIf
    
  EndProcedure

EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 650
; FirstLine = 632
; Folding = --------
; EnableXP