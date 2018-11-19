XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Morton.pbi"
;=======================================================================
; DECLARATION
;=======================================================================
DeclareModule Octree
  UseModule Math
  #MAX_ELEMENTS = 64
  #LONG_BITS = 21
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
	  *children.Cell_t[8]
  	*elements.CArray::CArrayLong
  	color.c4f32
  	morton.i
  EndStructure
  
  Structure Octree_t Extends Cell_t
    eMax.i
	  numCells.i
	  *geom.Geometry::Geometry_t
  EndStructure
  
  DataSection
    CornerPermutation:
    Data.i 0,1,2,3,1,2,0,1,5,3,1,5
    Data.i 0,4,2,3,4,2,0,4,5,3,4,5
  EndDataSection
  
  
  Declare New(*bmin.v3f32, *bmax.v3f32, depth=0)
  Declare Delete(*octree.Octree_t)
  
  Declare NewCell(*bmin.v3f32, *bmax.v3f32, depth=0)
  Declare DeleteCell(*cell.Cell_t)
  
;   Declare NewCell(*bmin.v3f32, *bmax.v3f32, depth=0)
  Declare Build(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
  
  Declare NumCells(*octree.Octree_t, *numCells)
  
  Declare GetCenter(*cell.Cell_t, *center.v3f32)
  Declare GetHalfSize(*cell.Cell_t, *halfsize.v3f32)
  
  Declare.f GetDistance1D(p.f, lower.f, upper.f)
  Declare.f GetDistance(*cell.Cell_t, *p.v3f32)
  Declare.b IntersectSphere(*cell.Cell_t, *center.v3f32, radius.f)
  
  Declare Split(*cell.Cell_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
  
  Declare Barycentric(*p.v3f32, *a.v3f32, *b.v3f32, *c.v3f32, *uvw.v3f32)
  Declare GetClosestCell(*octree.Cell_t, *point.v3f32)
  Declare RecurseGetClosestCell(*cell.Cell_t, *point.v3f32, *closestDistance, *closestCell)
  Declare GetNearbyCells(*cell.Cell_t, *point.v3f32, *cells.CArray::CArrayPtr, closestDistance.f)
  Declare RecurseGetNearbyCells(*cell.Cell_t, *center.v3f32, radius.f, *cells.CArray::CArrayPtr)
  Declare Draw(*cell.Cell_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
  Declare.b GetClosestPoint(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
  
  Declare CartesianToReal(*cell.Cell_t, *cartersian.Morton::Point3D_t, *real.Math::v3f32)
  Declare RealToCartesian(*cell.Cell_t, *real.Math::v3f32, *cartersian.Morton::Point3D_t)
  Declare EncodeMorton(*cell.Cell_t)
EndDeclareModule


;=======================================================================
; Implementation
;=======================================================================
Module Octree
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------------------------
  Procedure New(*bmin.v3f32, *bmax.v3f32, depth=0)
    Protected *octree.Octree_t = AllocateMemory(SizeOf(Octree_t))
    InitializeStructure(*octree, Octree_t)
    *octree\elements = CArray::newCArrayLong()
    *octree\depth = depth
    
    Vector3::SetFromOther(*octree\bmin, *bmin)
    Vector3::SetFromOther(*octree\bmax, *bmax)
    Color::Randomize(*octree\color)
    
;     EncodeMorton(*octree)
     
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
    ClearStructure(*octree, Octree_t)
    FreeMemory(*octree)
  EndProcedure
  
  Procedure EncodeMorton(*cell.Cell_t)
    Protected p.Morton::Point3D_t
    Protected center.v3f32
    GetCenter(*cell, center)
    RealToCartesian(*cell, center, p)
    *cell\morton = Morton::Encode3D(p)  
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------------------------
  Procedure NewCell(*bmin.v3f32, *bmax.v3f32, depth=0)
    Protected *cell.Cell_t = AllocateMemory(SizeOf(Cell_t))
    InitializeStructure(*cell, Cell_t)
    *cell\elements = CArray::newCArrayLong()
    *cell\depth = depth
    
    Vector3::SetFromOther(*cell\bmin, *bmin)
    Vector3::SetFromOther(*cell\bmax, *bmax)
    Color::Randomize(*cell\color)
    
    EncodeMorton(*cell)
     
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
    ClearStructure(*cell, Cell_t)
    FreeMemory(*cell)
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
  
  ;---------------------------------------------------------------------
  ; BUILD
  ;---------------------------------------------------------------------
  Procedure Build(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
    Clear(*octree)
    Protected numTriangles = *geom\nbtriangles
    CArray::SetCount(*octree\elements, numTriangles)

    Define i
    For i=0 To numTriangles - 1 : CArray::SetValueL(*octree\elements, i, i) : Next

    Vector3::Sub(*octree\bmin, *geom\bbox\origin, *geom\bbox\extend)
    Vector3::Add(*octree\bmax, *geom\bbox\origin, *geom\bbox\extend)

    *octree\eMax = maxDepth
    *octree\geom = *geom
    Split(*octree, *geom, maxDepth)
    
;     NumCells(*octree, @*octree\numCells)
;     
;     MessageRequester("OCTREE", Str(*octree\numCells))
    
;     *octree\numCells = 0
;     
;     Debug "################### OCTREE ######################"
;     Debug "Num CELLS : "+Str(*octree\numCells)
;     Debug "#################################################"
;     Select *geom\type
;       Case Geometry::#GEOMETRY_1D
;         Debug "POINT CLOUD OCTREE"
;       Case Geometry::#GEOMETRY_2D
;         Debug "CURVE OCTREE"
;       Case Geometry::#GEOMETRY_3D
;         Protected *poly.Geometry::PolymeshGeometry_t = *geom
;         Protected numTriangles = *poly\nbtriangles
;         CArray::SetCount(*octree\triangles, numTriangles)
;         Define i
;         For i=0 To numTriangles - 1
;           CArray::SetValueL(*octree\triangles, i, i)
;         Next
;         
;         Split(*octree, *geom\a_positions)
;     EndSelect
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
  Procedure RecurseGetClosestCell(*cell.Cell_t, *point.v3f32, *closestDistance, *closestCell)
 
    Protected distance.f
    If *cell\isLeaf
      distance = GetDistance(*cell, *point)
      
      If distance < PeekF(*closestDistance)
        PokeF(*closestDistance, distance)
        *closestCell =  *cell
      EndIf
    Else
      Protected cid = -1;
      Protected cdist.f = #F32_MAX
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
        Define *tmpCell.Cell_t = RecurseGetClosestCell(*cell\children[cid], *point, *closestDistance, *closestCell)
        If *tmpCell : *closestCell = *tmpCell : EndIf
      EndIf
    EndIf
    ProcedureReturn *closestCell
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
          Define *tmpCell.Cell_t = RecurseGetClosestCell(*cell\children[j], *point, @closestDistance, *closestCell)
          If *tmpCell : *closestCell = *tmpCell : EndIf
        EndIf
      Next j
      ProcedureReturn *closestCell
    EndIf
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
  Procedure GetNearbyCells(*cell.Cell_t, *point.v3f32, *cells.CArray::CArrayPtr, closestDistance.f)
    If Not *cell\isLeaf
      Protected j
      For j=0 To 7
        If *cell\children[j]
          RecurseGetNearbyCells(*cell\children[j], *point, closestDistance, *cells)
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
  ; Get Closest Point
  ;---------------------------------------------------------------------
  Procedure.b GetClosestPoint(*octree.Octree_t, *pnt.v3f32, *loc.Geometry::Location_t)
    Protected *closestCell.Cell_t  = GetClosestCell(*octree, *pnt)
    
    If Not *closestCell : ProcedureReturn #False : EndIf
    Define closestDistance.f = #F32_MAX
    Define distance.f
    Define.v3f32 closest, delta, uvw
    Define closestTriangle.i = -1
    Define *geom.Geometry::PolymeshGeometry_t = *octree\geom
    Define.v3f32 *a, *b, *c
    Define i, j
    
    For i=0 To *closestCell\elements\itemCount - 1
      j = CArray::GetValueL(*closestCell\elements, i)
      *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3))
      *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3+1))
      *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, j*3+2))
      
      Triangle::ClosestPoint(*a, *b, *c, *pnt , closest, uvw)
      Vector3::Sub(delta,*pnt, closest)
      distance = Vector3::Length(delta)
      If distance < closestDistance
        closestDistance = distance
        *loc\geometry = *octree\geom
        *loc\tid = j
        Vector3::SetFromOther(*loc\p, closest)
        Vector3::SetFromOther(*loc\uvw, uvw)
      EndIf
    Next
    
    Define *nearbyCells.CArray::CArrayPtr = CArray::newCArrayPtr()
    If Not *octree\isLeaf
      GetNearbyCells(*octree, *pnt, *nearbyCells, closestDistance)
    EndIf
    
    Debug "NUM NEARBY CELLS : "+Str(CArray::GetCount(*nearbyCells))
    
    ; loop nearby cells
    Define *nearbyCell.Octree::Cell_t
    Define t
    For i=0 To CArray::GetCount(*nearbyCells) - 1
      *nearbyCell = CArray::GetValuePtr(*nearbyCells, i)
      For j=0 To CArray::GetCount(*nearbyCell\elements) - 1
        t = CArray::GetValueL(*nearbyCell\elements, j)
        *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3))
        *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3+1))
        *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, t*3+2)) 
        Triangle::ClosestPoint(*a, *b, *c, *pnt, closest, uvw)
        
        Vector3::Sub(delta, *pnt, closest)
        distance = Vector3::Length(delta)
        If distance < closestDistance
          closestDistance = distance
          *loc\geometry = *octree\geom
          *loc\tid = t
          Vector3::SetFromOther(*loc\p, closest)
          Vector3::SetFromOther(*loc\uvw, uvw)
        EndIf
      Next
      
    Next

    CArray::Delete(*nearbyCells)
    ProcedureReturn #True
    
  EndProcedure  
  
  ;---------------------------------------------------------------------
  ; CREATE CELL
  ;---------------------------------------------------------------------
  Macro CreateCell(_i,_j,_k)
    m = 4*_i+2*_j+_k
    Vector3::Set(bmin, xx\v[_i], yy\v[_j], zz\v[_k])
    Vector3::Set(bmax, xx\v[_i+1], yy\v[_j+1], zz\v[_k+1])
    *child = Octree::NewCell(bmin, bmax, *octree\depth + 1)

    GetCenter(*child, box\origin)
    GetHalfSize(*child, box\extend)
    
;     numHits = 0
;     Define sT1.d = Time::Get()
;     For t=0 To tsz - 1
;       xt = CArray::GetValueL(*octree\elements, t)
;       *a = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, xt*3))
;       *b = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, xt*3+1))
;       *c = CArray::GetValue(*geom\a_positions, CArray::GetValueL(*geom\a_triangleindices, xt*3+2))
; 
;       If Triangle::Touch(  box, *a, *b, *c) : CArray::AppendL(*child\elements, xt) : numHits + 1 :EndIf
;     Next
;     Define eT1.d = Time::Get() - sT1
;     Define msg.s = "LOOP : "+StrD(eT1)+" : "+Str(numHits)+Chr(10)
    
    
    Define *hits = AllocateMemory(*octree\elements\itemCount)

    Define numHits = Triangle::TouchArray(*geom\a_positions\data,
                                          *geom\a_triangleindices\data,
                                          *octree\elements\data,
                                          *octree\elements\itemCount, 
                                          box, 
                                          *hits)
    CArray::SetCount(*child\elements, numHits)
    Define idx = 0
    For t=0 To tsz - 1
      If PeekB(*hits+t)
        PokeL(*child\elements\data + idx*4, PeekL(*octree\elements\data + t * 4))  
        idx + 1
      EndIf
    Next

    FreeMemory(*hits)
    
    If Not *child\elements\itemCount
      *octree\children[m] = #Null
      DeleteCell(*child)
    Else
      *octree\children[m] = *child
      Split(*octree\children[m], *geom, maxDepth)
    EndIf
  EndMacro
  
  ;---------------------------------------------------------------------
  ; SPLIT
  ;---------------------------------------------------------------------
  Procedure Split(*octree.Cell_t, *geom.Geometry::PolymeshGeometry_t, maxDepth.i)
    Protected tsz = *octree\elements\itemCount
    If tsz <= #MAX_ELEMENTS Or *octree\depth >= maxDepth:
      *octree\isLeaf = #True
      ProcedureReturn
    EndIf

    *octree\isLeaf = #False
    Protected i, j, k, m, t
    Define.Point_t xx, yy, zz
    Define xt
    Define numHits = 0
    Define *xx.v3f32 = @xx
    Define *yy.v3f32 = @yy
    Define *zz.v3f32 = @zz
    Define *child.Cell_t
    Vector3::Set(*xx, *octree\bmin\x, 0.5*(*octree\bmin\x+*octree\bmax\x), *octree\bmax\x)
    Vector3::Set(*yy, *octree\bmin\y, 0.5*(*octree\bmin\y+*octree\bmax\y), *octree\bmax\y)
    Vector3::Set(*zz, *octree\bmin\z, 0.5*(*octree\bmin\z+*octree\bmax\z), *octree\bmax\z)
    
    Define.v3f32 center, halfsize
    Define.v3f32 bmin, bmax
    Define tri.Geometry::Triangle_t
    Define box.Geometry::Box_t
    Define *a.Math::v3f32, *b.Math::v3f32, *c.Math::v3f32
    
    CreateCell(0,0,0)
    CreateCell(0,0,1)
    CreateCell(0,1,0)
    CreateCell(0,1,1)
    CreateCell(1,0,0)
    CreateCell(1,0,1)
    CreateCell(1,1,0)
    CreateCell(1,1,1)

    Carray::SetCount(*octree\elements, 0)
   
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
  ; GET CELL
  ;---------------------------------------------------------------------
  Procedure GetCell(*octree.Octree_t, posx.i, posy.i, posz.i, e.i)
    Protected  e0.i=*octree\eMax
    Protected search.b = #True
    Protected index.i
    ; tant qu'il y a des fils et que la profondeur n'est pas atteinte
    While search And e0 > e
      ; on descend d'un niveau dans la profondeur de l'arbre
      e0 - 1
      index = ((posx >> e0) & 1) + (((posy >> e0) & 1) << 1) +  (((posz >> e0) & 1) << 2)
      If *octree\children[index]
        *octree = *octree\children[index]
      Else
        search = #False
      EndIf
    Wend
    
    ProcedureReturn *octree
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; Conversion Utils
  ;---------------------------------------------------------------------
  Procedure CartesianToReal(*cell.Cell_t, *cartersian.Morton::Point3D_t, *real.Math::v3f32)
    Protected factor.f
    factor = #MAX_L * (*cell\bmax\x - *cell\bmax\x)
    *real\x = factor * *cartersian\x + *cell\bmin\x
    factor = #MAX_L * (*cell\bmax\y - *cell\bmax\y)
    *real\y = factor * *cartersian\y + *cell\bmin\y
    actor = #MAX_L * (*cell\bmax\z - *cell\bmax\z)
    *real\z = factor * *cartersian\z + *cell\bmin\z
  EndProcedure
  
  Procedure RealToCartesian(*cell.Cell_t, *real.Math::v3f32, *cartersian.Morton::Point3D_t)
    Protected factor.f 
    factor = #MAX_L / (*cell\bmax\x - *cell\bmin\x)
    *cartersian\x = Int(factor *(*real\x - *cell\bmin\x))
    factor = #MAX_L / (*cell\bmax\y - *cell\bmin\y)
    *cartersian\y = Int(factor *(*real\y - *cell\bmin\y))
    factor = #MAX_L / (*cell\bmax\z - *cell\bmin\z)
    *cartersian\z = Int(factor *(*real\z - *cell\bmin\z))
  EndProcedure

  ;---------------------------------------------------------------------
  ; DRAW OCTREE
  ;---------------------------------------------------------------------
  Procedure Draw(*octree.Cell_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
    Protected m.m4f32
    Protected s.v3f32
    Protected p.v3f32
    Protected *a.v3f32, *b.v3f32, *c.v3f32
    Protected *col.c4f32
    Matrix4::SetIdentity(m)
    If *octree\isLeaf
      Vector3::Sub(s, *octree\bmax, *octree\bmin)
      Vector3::Add(p, *octree\bmin, *octree\bmax)
      Vector3::ScaleInPlace(p, 0.5)
      Matrix4::SetScale(m, s)
      Matrix4::SetTranslation(m, p)
      Protected *box.Drawer::Box_t = Drawer::NewBox(*drawer, @m)
      Drawer::SetColor(*box,*octree\color)
      
      Protected *positions.CArray::CarrayV3F32 = CArray::newCArrayV3F32()
      Protected *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
      Protected numTriangles.i = CArray::GetCount(*octree\elements)
      CArray::SetCount(*positions, numTriangles * 3)
      CArray::SetCount(*colors, numTriangles * 3)
      Define t, a, b, c
      For t=0 To numTriangles -1
        a = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*octree\elements, t) *3)
        b = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*octree\elements, t) *3+1)
        c = CArray::GetValueL(*geom\a_triangleindices, CArray::GetValueL(*octree\elements, t) *3+2)
        
        *a = CArray::GetValue(*positions, t*3)
        *b = CArray::GetValue(*positions, t*3+1)
        *c = CArray::GetValue(*positions, t*3+2)
        
        CopyMemory(CArray::GetValue(*geom\a_positions, a), *a, SizeOf(v3f32))
        CopyMemory(CArray::GetValue(*geom\a_positions, b), *b, SizeOf(v3f32))
        CopyMemory(CArray::GetValue(*geom\a_positions, c), *c, SizeOf(v3f32))
        
        *col = CArray::GetValue(*colors, t*3)
        Color::SetFromOther(*col, *octree\color)
        *col = CArray::GetValue(*colors, t*3+1)
        Color::SetFromOther(*col, *octree\color)
        *col = CArray::GetValue(*colors, t*3+2)
        Color::SetFromOther(*col, *octree\color)
      Next
      
      Protected *triangles.Drawer::Triangle_t = Drawer::NewColoredTriangle(*drawer, *positions, *colors)
      CArray::Delete(*positions)
      CArray::Delete(*colors)
    Else
      Protected i
      For i=0 To 7
        If *octree\children[i]
          Draw(*octree\children[i], *drawer, *geom)
        EndIf
      Next
      
    EndIf
    
  EndProcedure

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 488
; FirstLine = 450
; Folding = -----
; EnableXP