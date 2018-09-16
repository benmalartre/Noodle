XIncludeFile "../core/Math.pbi"
;=======================================================================
; DECLARATION
;=======================================================================
DeclareModule Octree
  UseModule Math
  #MAX_ELEMENTS = 4
  Enumeration 
    #ELEMENT_1D
    #ELEMENT_2D
    #ELEMENT_3D
  EndEnumeration
  
  Structure Point_t
    v.f[3]
  EndStructure
  
  Structure Octree_t
	  depth.i
	  bmin.v3f32
	  bmax.v3f32
  
	  isLeaf.b
	  *geom.Geometry::Geometry_t
  	*children.Octree_t[8]
  	*elements.CArray::CArrayLong
  	color.c4f32
  EndStructure
  
  DataSection
    CornerPermutation:
    Data.i 0,1,2,3,1,2,0,1,5,3,1,5
    Data.i 0,4,2,3,4,2,0,4,5,3,4,5
  EndDataSection
  
  
  Declare New(*bmin.v3f32, *bmax.v3f32, depth=0)
  Declare Delete(*octree.Octree_t)
  
  Declare GetCenter(*octree.Octree_t, *center.v3f32)
  Declare GetHalfSize(*octree.Octree_t, *halfsize.v3f32)
  
  Declare.f GetDistance1D(p.f, lower.f, upper.f)
  Declare.f getDistance(*octree.Octree_t, *p.v3f32)
  
  Declare Split (*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t)
  Declare Build(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t)
  
  Declare NumCells(*octree.Octree_t, *numCells)
  Declare Draw(*octree.Octree_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
  
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
    *octree \elements = CArray::newCArrayLong()
    Vector3::SetFromOther(*octree\bmin, *bmin)
    Vector3::SetFromOther(*octree\bmax, *bmax)
    Color::Randomize(*octree\color)
    ProcedureReturn *octree
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DESTRUCTOR
  ;---------------------------------------------------------------------
  Procedure Delete(*octree.Octree_t)
    Define i
    For i=0 To 7
      If *octree\children[i] : Delete(*octree\children[i]) : EndIf
    Next
    If *octree\elements: CArray::Delete(*octree\elements) : EndIf
    ClearStructure(*octree, Octree_t)
    FreeMemory(*octree)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET CENTER
  ;---------------------------------------------------------------------
  Procedure GetCenter(*octree.Octree_t, *center.v3f32)
    Vector3::Add(*center, *octree\bmin, *octree\bmax)
    Vector3::ScaleInPlace(*center, 0.5)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET HALF SIZE
  ;---------------------------------------------------------------------
  Procedure GetHalfSize(*octree.Octree_t, *halfsize.v3f32)
    Vector3::Sub(*halfsize, *octree\bmax, *octree\bmin)
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
  ; Get Distance
  ;---------------------------------------------------------------------
  Procedure.f GetDistance(*octree.Octree_t, *point.v3f32)
    Protected dx.f = GetDistance1D(*point\x, *octree\bmin\x, *octree\bmax\x)
    Protected dy.f = GetDistance1D(*point\y, *octree\bmin\y, *octree\bmax\y)
    Protected dz.f = GetDistance1D(*point\z, *octree\bmin\z, *octree\bmax\z)
    ProcedureReturn Sqr(dx * dx + dy * dy + dz * dz)
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; CLEAR
  ;---------------------------------------------------------------------
  Procedure Clear(*octree.Octree_t)
    Define i
    For i=0 To 7
      If *octree\children[i] : Octree::Delete(*octree\children[i]) : EndIf
    Next
    If CArray::GetCount(*octree\elements): CArray::SetCount(*octree\elements, 0) : EndIf
    
  EndProcedure
  
  
  
  ;---------------------------------------------------------------------
  ; INTERSECT SPHERE
  ;---------------------------------------------------------------------
  Procedure.b IntersectSphere(*octree.Octree_t, *center.v3f32, radius.f)
    Define r2.f = radius * radius
    Define dmin.f = 0
    
    If *center\x < *octree\bmin\x : dmin + Pow(*center\x-*octree\bmin\x, 2)
    ElseIf *center\x > *octree\bmax\x : dmin + Pow(*center\x-*octree\bmax\x, 2)
    EndIf
    
    If *center\y < *octree\bmin\y : dmin + Pow(*center\y-*octree\bmin\y, 2)
    ElseIf *center\y > *octree\bmax\y : dmin + Pow(*center\y-*octree\bmax\y, 2)
    EndIf
    
    If *center\z < *octree\bmin\z : dmin + Pow(*center\z-*octree\bmin\z, 2)
    ElseIf *center\z > *octree\bmax\z : dmin + Pow(*center\z-*octree\bmax\z, 2)
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
  Procedure GetFurthestCorner(*octree.Octree_t, *point.v3f32, *corner.v3f32)
    Protected delta.v3f32
    Define dist.f
    Define furthestDist.f=-1.0
    Dim P(6)
    P(0) = *octree\bmin\x
    P(1) = *octree\bmin\y
    P(2) = *octree\bmin\z
    P(3) = *octree\bmax\x
    P(4) = *octree\bmax\y
    P(5) = *octree\bmax\z
    
    Protected z
    Protected current.v3f32
    For z=0 To 7
      Vector3::Set(@current, P(GetCurrentCorner(z, 0)), P(GetCurrentCorner(z, 1)), P(GetCurrentCorner(z, 2)))
      Vector3::Sub(@delta, *point, @current)
      dist = Vector3::Length(@delta)
      If dist > furthestDist
        furthestDist = dist
        Vector3::SetFromOther(*corner, @current)
      EndIf
    Next

  EndProcedure
  
  ;---------------------------------------------------------------------
  ; BUILD
  ;---------------------------------------------------------------------
  Procedure Build(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t)
    Clear(*octree)
    Protected numTriangles = *geom\nbtriangles
    CArray::SetCount(*octree\elements, numTriangles)
    Define i
    For i=0 To numTriangles - 1
      CArray::SetValueL(*octree\elements, i, i)
    Next
    Vector3::Sub(*octree\bmin, *geom\bbox\origin, *geom\bbox\extend)
    Vector3::Add(*octree\bmax, *geom\bbox\origin, *geom\bbox\extend)
    
    Debug "NUM TRIANGLES : "+Str(CArray::GetCount(*octree\elements))
     
    Split(*octree, *geom)
    
    
    Debug "################### OCTREE ######################"
    Protected nbCells.i = 0
    NumCells(*octree, @nbCells)
    Debug "Num CELLS : "+Str(nbCells)
    Debug "#################################################"
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
  ; GET POINT
  ;---------------------------------------------------------------------
  Procedure GetPoint(*octree.Octree_t, *pnt.Point_t, index.i)
    Select index
      Case 0:
        *pnt\v[0] = *octree\bmin\x
        *pnt\v[1] = 0.5*(*octree\bmin\x+*octree\bmax\x)
        *pnt\v[2] = *octree\bmax\x
      Case 1:
        *pnt\v[0] = *octree\bmin\y
        *pnt\v[1] = 0.5*(*octree\bmin\y+*octree\bmax\y)
        *pnt\v[2] = *octree\bmax\y
      Case 2
        *pnt\v[0] = *octree\bmin\z
        *pnt\v[1] = 0.5*(*octree\bmin\z+*octree\bmax\z)
        *pnt\v[2] = *octree\bmax\z
    EndSelect
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; SPLIT
  ;---------------------------------------------------------------------
  Procedure Split(*octree.Octree_t, *geom.Geometry::PolymeshGeometry_t)
    Protected tsz = CArray::GetCount(*octree\elements)
  
    If tsz <= #MAX_ELEMENTS Or 
       (tsz <= 2*#MAX_ELEMENTS And *octree\depth > 3) Or
       (tsz <= 3*#MAX_ELEMENTS And *octree\depth > 4) Or 
       *octree\depth > 6:
       *octree\isLeaf = #True
        ProcedureReturn
      EndIf
    
    *octree\isLeaf = #False
    Protected i, j, k, m, t
    Define.Point_t xx, yy, zz
    GetPoint(*octree, @xx, 0)
    GetPoint(*octree, @yy, 1)
    GetPoint(*octree, @zz, 2)
    
    Define.v3f32 center, halfsize
    Define.v3f32 bmin, bmax
    Define tri.Geometry::Triangle_t
    For i=0 To 1
      For j=0 To 1
        For k=0 To 1
          m = 4*i+2*j+k
          Vector3::Set(@bmin, xx\v[i], yy\v[j], zz\v[k])
          Vector3::Set(@bmax, xx\v[i+1], yy\v[j+1], zz\v[k+1])
          *octree\children[m] = Octree::New(@bmin, @bmax, *octree\depth + 1)
          GetCenter(*octree\children[m], @center)
          GetHalfSize(*octree\children[m], @halfsize)
          tsz = CArray::GetCount(*octree\elements)
          For t=0 To tsz -1
            tri\id = CArray::GetValueL(*octree\elements, t)
            tri\vertices[0] = CArray::GetValueL(*geom\a_triangleindices, tri\id *3)
            tri\vertices[1] = CArray::GetValueL(*geom\a_triangleindices, tri\id *3+1)
            tri\vertices[2] = CArray::GetValueL(*geom\a_triangleindices, tri\id *3+2)
            If Triangle::Touch(@tri, *geom\a_positions, @center, @halfsize)
              CArray::AppendL(*octree\children[m]\elements, tri\id)
            EndIf
          Next t
          
          If Not CArray::GetCount(*octree\children[m]\elements):
            Delete(*octree\children[m])
            *octree\children[m] = #Null
          Else
            Split(*octree\children[m], *geom)
          EndIf
        Next k
      Next j
    Next i
    
    Carray::SetCount(*octree\elements, 0)
   
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; GET NUM LEAVE CELLS
  ;---------------------------------------------------------------------
  Procedure NumCells(*octree.Octree_t, *numCells)
    Protected i
    For i=0 To 7
      If *octree \children[i]
        If *octree\children[i]\isLeaf
          PokeL(*numCells, PeekL(*numCells)+1)
        Else
          NumCells(*octree\children[i], *numCells)
        EndIf
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------------------------
  ; DARW OCTREE
  ;---------------------------------------------------------------------
  Procedure Draw(*octree.Octree_t, *drawer.Drawer::Drawer_t, *geom.Geometry::PolymeshGeometry_t)
    Protected m.m4f32
    Protected s.v3f32
    Protected p.v3f32
    Matrix4::SetIdentity(@m)
    If *octree\isLeaf
      Vector3::Sub(@s, *octree\bmax, *octree\bmin)
      Vector3::Add(@p, *octree\bmin, *octree\bmax)
      Vector3::ScaleInPlace(@p, 0.5)
      Matrix4::SetScale(@m, @s)
      Matrix4::SetTranslation(@m, @p)
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

        Vector3::SetFromOther(CArray::GetValue(*positions, t*3), CArray::GetValue(*geom\a_positions, a))
        Vector3::SetFromOther(CArray::GetValue(*positions, t*3+1), CArray::GetValue(*geom\a_positions, b))
        Vector3::SetFromOther(CArray::GetValue(*positions, t*3+2), CArray::GetValue(*geom\a_positions, c))
        
        Color::SetFromOther(CArray::GetValue(*colors, t*3), *octree\color)
        Color::SetFromOther(CArray::GetValue(*colors, t*3+1), *octree\color)
        Color::SetFromOther(CArray::GetValue(*colors, t*3+2), *octree\color)
      Next
      
      Protected *triangles.Drawer::Triangle_t = Drawer::NewColoredTriangle(*drawer, *positions, *colors)
      CArray::Delete(*positions)
      CARray::Delete(*colors)
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
; CursorPosition = 15
; Folding = ---
; EnableXP