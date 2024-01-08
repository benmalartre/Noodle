; ------------------------------------------------------------------------------------
; DELAUNAY TRIANGULATION (2D) MODULE
;
; https://github.com/delfrrr/delaunator-cpp
;
; ------------------------------------------------------------------------------------

XIncludeFile "../core/Math.pbi"

DeclareModule Delaunay
  
  UseModule Math
  #EPSILON = 0.0000000001
  #INVALID_INDEX = #U32_MAX
  
  Structure Circle_t
    c.v2f32
    r.f
  EndStructure
  
  Structure Index_t
    index.i
    d.f
  EndStructure
  
  Structure Delaunay_t
    Array ids.Index_t(0)
    Array points.v2f32(0)
    Array triangles.i(0)
    Array halfedges.i(0)
    Array hullPrev.i(0)
    Array hullNext.i(0)
    Array hullTri.i(0)
    Array hashes.i(0)
    Array edgeStack.i(0)
    
    center.v2f32
    hashSize.i
    hullStart.i
  EndStructure
  
  Declare Init(*delaunay.Delaunay_t, *points.CArray::CArrayV3F32, *view.m4f32)
  Declare AddTriangle(*delaunay.Delaunay_t, i0, i1, i2, a, b, c)
  Declare.b IsInCircle(*delaunay.Delaunay_t,*a.v2f32, *b.v2f32, *c.v2f32, *p.v2f32)

EndDeclareModule

Module Delaunay
  Procedure.b _CheckPointsEqual(*p1.v2f32, *p2.v2f32)
    ProcedureReturn Bool(Abs(*p1\x - *p2\x) <= #F32_EPS And Abs(*p1\y - *p2\y) <= #F32_EPS)
  EndProcedure

  Procedure.f _PseudoAngle(*p.v2f32)
    Define p.f = *p\x / (Abs(*p\x) + Abs(*p\y))
    If *p\y > 0.0
      ProcedureReturn (3.0 - p ) / 4.0
    Else
      ProcedureReturn (1.0 + p) / 4.0
    EndIf
  EndProcedure
  
  Procedure _HashKey(*delaunay.Delaunay_t, *p.v2f32)
    Define p.v2f32
    Vector2::Sub(p, *p, *delaunay\center)
    ProcedureReturn Int(_PseudoAngle(p) * *delaunay\hashSize) % *delaunay\hashSize
  EndProcedure
  
  Procedure _SetupTriangle(*delaunay.Delaunay_t, id.i, p0.i, p1.i, p2.i)
    *delaunay\triangles(id * 3 + 0) = p0
    *delaunay\triangles(id * 3 + 1) = p1
    *delaunay\triangles(id * 3 + 2) = p2
  EndProcedure
  
  Procedure _SetupLink(*delaunay.Delaunay_t, a.i, b.i) 
    Define s = ArraySize(*delaunay\halfedges())
    If a = s
      ReDim *delaunay\halfedges(s + 1)
      *delaunay\halfedges(s) = b
    ElseIf a < s
        *delaunay\halfedges(a) = b
    EndIf
    If b <> #INVALID_INDEX
      Define s2 = ArraySize(*delaunay\halfedges())
      If b = s2
        ReDim *delaunay\halfedges(s2 + 1)
        *delaunay\halfedges(s2) = a
      ElseIf b < s2
        *delaunay\halfedges(b) = a
      EndIf
    EndIf
  EndProcedure
  
  Procedure _Sum()
    
  EndProcedure
  
  Procedure _CircumCircle(*c.Circle_t, *p0.v2f32, *p1.v2f32, *p2.v2f32)
    Protected e0.v2f32, e1.v2f32
    Vector2::Sub(e0, *p1, *p0)
    Vector2::Sub(e1, *p2, *p0)
    Define e0l.f = e0\x*e0\x + e0\y*e0\y
    Define e1l.f = e1\x*e1\x + e1\y*e1\y
    Define d.f = e0\x*e1\y - e0\y*e1\x
    
    Define x.f = (e1\y * e0l - e0\y * e1l) * 0.5 / d
    Define y.f = (e0\x * e1l - e1\x * e0l) * 0.5 / d
    
    Vector2::Set(*c\c, x + *p0\x, y + *p0\y)
    
    If ((e0l > 0.0 Or e0l < 0.0) And (e1l > 0.0 Or e1l < 0.0) And (d > 0.0 Or d < 0.0))
      *c\r = x*x + y*y
    Else
      *c\r = #F32_MAX
    EndIf
  EndProcedure
  
  Procedure.b _Orient(*p.v2f32, *q.v2f32, *r.v2f32)
    ProcedureReturn Bool(((*q\y - *p\y) * (*r\x - *q\x) - (*q\x - *p\x) * (*r\y - *q\y)) < 0.0)
  EndProcedure
  
  Procedure _Legalize(*delaunay.Delaunay_t, a.i)
    Define i = 0
    Define ar = 0;
    ReDim *delaunay\edgeStack(0)
    
    ; recursion eliminated With a fixed-size stack
    While #True
        Define b = *delaunay\halfedges(a)

        ; If the pair of triangles doesn't satisfy the Delaunay condition
        ; (p1 is inside the circumcircle of [p0, pl, pr]), flip them,
        ; then do the same check/flip recursively For the new pair of triangles
        ;
        ;           pl                    pl
        ;          /||\                  /  \
        ;       al/ || \bl            al/    \a
        ;        /  ||  \              /      \
        ;       /  a||b  \    flip    /___ar___\
        ;     p0\   ||   /p1   =>   p0\---bl---/p1
        ;        \  ||  /              \      /
        ;       ar\ || /br             b\    /br
        ;          \||/                  \  /
        ;           pr                    pr
        ;
        Define a0 = 3 * (a / 3)
        ar = a0 + (a + 2) % 3

        If b = #INVALID_INDEX
          If i > 0
            i-1
            a = *delaunay\edgeStack(i)
            Continue
          Else 
            ;i = INVALID_INDEX
            Break
          EndIf
        EndIf


        Define b0 = 3 * (b / 3)
        Define al = a0 + (a + 1) % 3
        Define bl = b0 + (b + 2) % 3

        Define p0 = *delaunay\triangles(ar)
        Define pr = *delaunay\triangles(a)
        Define pl = *delaunay\triangles(al)
        Define p1 = *delaunay\triangles(bl)


        If IsInCircle(*delaunay, 
                      *delaunay\points(p0), 
                      *delaunay\points(pr),
                      *delaunay\points(pl), 
                      *delaunay\points(p1))
          
          *delaunay\triangles(a) = p1
          *delaunay\triangles(b) = p0

          Define hbl = *delaunay\halfedges(bl)

          ; edge swapped on the other side of the hull (rare); fix the halfedge reference
          If hbl = #INVALID_INDEX
            Define e = *delaunay\hullStart
            Repeat
              If *delaunay\hullTri(e) = bl : *delaunay\hullTri(e) = a : Break : EndIf
              e = *delaunay\hullNext(e)
            Until e = *delaunay\hullStart
          EndIf
          _SetupLink(*delaunay, a, hbl)
          _SetupLink(*delaunay, b, *delaunay\halfedges(ar))
          _SetupLink(*delaunay, ar, bl)
          Define br = b0 + ((b + 1) % 3)
          Define esSize = ArraySize(*delaunay\edgeStack())
          If i < esSize
            *delaunay\edgeStack(i) = br
          Else
            ReDim *delaunay\edgeStack(esSize + 1)
            *delaunay\edgeStack(esSize) = br
          EndIf
          i+1
      Else
        If i > 0
          i-1
          a = *delaunay\edgeStack(i)
        Else
          Break
        EndIf
      EndIf
    Wend
    ProcedureReturn ar
  EndProcedure
  
  Procedure Init(*delaunay.Delaunay_t, *points.CArray::CArrayV3F32, *view.m4f32)
    Protected *p.v3f32, p.v3f32
    Protected n = CArray::GetCount(*points)
    ReDim *delaunay\points(n)
    ReDim *delaunay\ids(n)
    ReDim *delaunay\hullPrev(n)
    ReDim *delaunay\hullNext(n)
    ReDim *delaunay\hullTri(n)
    
    Protected invMatrix.m4f32
    Matrix4::Inverse(invMatrix, *view)
    
    Define maxX.f = #F32_MIN
    Define maxY.f = #F32_MIN
    Define minX.f = #F32_MAX
    Define minY.f = #F32_MAX
    Define i, j, k, q, t

    For i = 0 To n - 1
      *p = CArray::GetValue(*points, i)
      Vector3::MulByMatrix4(p, *p, invMatrix)
      Vector2::Set(*delaunay\points(i), p\x, p\z)
      If p\x < minX : minX = p\x :EndIf
      If p\z < minY : minY = p\z :EndIf
      If p\x > maxX : maxX = p\x :EndIf
      If p\z > maxY : maxY = p\z :EndIf
      
      *delaunay\ids(i)\index = i
    Next
    
    ; normalize  
    Define *p2.v2f32
    Define sX.f = 1.0 / (maxX - minX)
    Define sY.f = 1.0 / (maxY - minY)
    Define w.f = 1.0 / n
    Define center.v2f32
    For i = 0 To n - 1
      *p2 = *delaunay\points(i) 
      *p2\x - minX
      *p2\y - minY 
      *p2\x * sX
      *p2\y * sY
      Vector2::ScaleAddInPlace(center, *p2, w)
      Vector2::Echo(*p2)
    Next
    
    Vector2::SetFromOther(*delaunay\center, center)
    
    Define minDist.f = #F32_MAX
    
    Define i0 = #INVALID_INDEX
    Define i1 = #INVALID_INDEX
    Define i2 = #INVALID_INDEX
      
    ; pick a seed point close To the centroid
    Define dist.f
    For i = 0 To n - 1
      dist = Vector2::DistanceSquared(*delaunay\points(i), *delaunay\center)
      If dist < minDist
        i0 = i
        minDist = dist
      EndIf
    Next
    
    ; find the point closest To the seed
    minDist = #F32_MAX
    
    For i = 0 To n - 1
      If i = i0 : Continue : EndIf
      dist= Vector2::DistanceSquared(*delaunay\points(i), *delaunay\points(i0));
      If dist < minDist And dist > 0.0
        i1 = i
        minDist = dist
      EndIf
    Next
    
    Define minRadius.f = #F32_MAX
    Define circle.Circle_t

    ; find the third point which forms the smallest circumcircle With the first two
    For i = 0 To n - 1
      If i = i0 Or i = i1 : Continue : EndIf
      _CircumCircle(circle, *delaunay\points(i0), *delaunay\points(i1), *delaunay\points(i))
      If circle\r < minRadius
        i2 = i
        minRadius = circle\r
      EndIf
    Next
  
    If _Orient(*delaunay\points(i0), *delaunay\points(i1), *delaunay\points(i2)) 
      Swap i1, i2
    EndIf
    
    _CircumCircle(circle, *delaunay\points(i0), *delaunay\points(i1), *delaunay\points(i2))
    Vector2::SetFromOther(*delaunay\center, circle\c)
    
    ; sort the points by distance from the seed triangle circumcenter    
    For i = 0 To ArraySize(*delaunay\ids())
      *delaunay\ids(i)\d = Vector2::DistanceSquared(*delaunay\center, *delaunay\points(i))
    Next
    
    SortStructuredArray(*delaunay\ids(), #PB_Sort_Ascending, OffsetOf(Index_t\d), #PB_Float)
    
    ; initialize a hash table For storing edges of the advancing convex hull
    *delaunay\hashSize = n/2;Int(Round(Sqr(n), #PB_Round_Up))
    ReDim *delaunay\hashes(*delaunay\hashSize)
    FillMemory(@*delaunay\hashes(0), *delaunay\hashSize * SizeOf(i), #INVALID_INDEX, #PB_Integer)
    
    *delaunay\hullStart = i0

    *delaunay\hullNext(i0) = i1
    *delaunay\hullPrev(i2) = i1
    *delaunay\hullNext(i1) = i2
    *delaunay\hullPrev(i0) = i2
    *delaunay\hullNext(i2) = i0
    *delaunay\hullPrev(i1) = i0

    *delaunay\hullTri(i0) = 0
    *delaunay\hullTri(i1) = 1
    *delaunay\hullTri(i2) = 2

    *delaunay\hashes(_HashKey(*delaunay, *delaunay\points(i0))) = i0
    *delaunay\hashes(_HashKey(*delaunay, *delaunay\points(i1))) = i1
    *delaunay\hashes(_HashKey(*delaunay, *delaunay\points(i2))) = i2
    
    Define maxTriangles = 1
    If n > 3 : maxTriangles = 2 * n - 5 : EndIf
    
    AddTriangle(*delaunay, i0, i1, i2, #INVALID_INDEX, #INVALID_INDEX, #INVALID_INDEX)
    
    Vector2::Set(p, #F32_MAX, #F32_MAX)
    
    For k = 0 To n -1
      
      i = *delaunay\ids(k)\index
      *p = *delaunay\points(i)
      
      ; skip near-duplicate points
      If k > 0 And _CheckPointsEqual(*p, p) : Continue : EndIf
      
      Vector2::SetFromOther(p, *p)
      
      ; skip seed triangle points
      If _CheckPointsEqual(p, *delaunay\points(i0)) Or 
         _CheckPointsEqual(p, *delaunay\points(i1)) Or
         _CheckPointsEqual(p, *delaunay\points(i2)) : Continue : EndIf
      
      ; find a visible edge on the convex hull using edge hash
      Define start = 0
      
      Define key = _HashKey(*delaunay, p)
      For j = 0 To *delaunay\hashSize - 1
        start = *delaunay\hashes((key + j)%*delaunay\hashSize)
        If start <> #INVALID_INDEX And start <> *delaunay\hullNext(start) 
          Break
        EndIf
      Next
      start = *delaunay\hullPrev(start)
      e = start
     
      Repeat
        q = *delaunay\hullNext(e)
        If Not _Orient(p, *delaunay\points(e), *delaunay\points(q))
          e = q
          If e = start : e = INVALID_INDEX : Break : EndIf
        Else : Break : EndIf
      Until #True  
      
      If e = #INVALID_INDEX : Continue : EndIf ; likely a near-duplicate point; skip it

       ; add the first triangle from the point
       t = AddTriangle(*delaunay, e, i, *delaunay\hullNext(e), #INVALID_INDEX, #INVALID_INDEX, *delaunay\hullTri(e))
       *delaunay\hullTri(i) = _Legalize(*delaunay, t + 2)
       *delaunay\hullTri(e) = t

       ; walk forward through the hull, adding more triangles And flipping recursively
       Define nxt.i = *delaunay\hullNext(e)
       Repeat
         q = *delaunay\hullNext(nxt)
         If _Orient(p, *delaunay\points(nxt), *delaunay\points(q)) 
           t = AddTriangle(*delaunay, nxt, i, q, *delaunay\hullTri(i), #INVALID_INDEX, *delaunay\hullTri(nxt))
           *delaunay\hullTri(i) = _Legalize(*delaunay, t + 2)
           *delaunay\hullNext(nxt) = nxt
           nxt = q
         Else : Break : EndIf
       Until #True
       
       ; walk backward from the other side, adding more triangles And flipping
      If e = start
        Repeat
          q = *delaunay\hullPrev(e)
          If _Orient(p, *delaunay\points(q), *delaunay\points(e))
            t = AddTriangle(*delaunay, q, i, e, #INVALID_INDEX, *delaunay\hullTri(e), *delaunay\hullTri(q));
            _Legalize(*delaunay, t + 2)
            *delaunay\hullTri(q) = t
            *delaunay\hullNext(e) = e; // mark as removed
            e = q
          Else : Break : EndIf
        Until #True
      EndIf
            
      ; update the hull indices
      *delaunay\hullPrev(i) = e
      *delaunay\hullPrev(nxt) = i
      *delaunay\hullNext(e) = i
      *delaunay\hullNext(i) = nxt
      
      *delaunay\hashes(_HashKey(*delaunay, p)) = i
      *delaunay\hashes(_HashKey(*delaunay, *delaunay\points(e))) = e   

    Next
 
  EndProcedure
  
  Procedure AddTriangle(*delaunay.Delaunay_t, i0, i1, i2, a, b, c)
    Define t = ArraySize(*delaunay\triangles())
    ReDim *delaunay\triangles(t + 3)
    _SetupTriangle(*delaunay, t / 3, i0, i1, i2)
    _SetupLink(*delaunay, t + 0, a)
    _SetupLink(*delaunay, t + 1, b)
    _SetupLink(*delaunay, t + 2, c)
    ProcedureReturn t
  EndProcedure
  
  Procedure.b IsInCircle(*delaunay.Delaunay_t, *a.v2f32, *b.v2f32, *c.v2f32, *p.v2f32)
    Define a.v2f32, b.v2f32, c.v2f32
    Vector3::Sub(a, *a, *p)
    Vector3::Sub(b, *b, *p)
    Vector3::Sub(c, *c, *p)
    
    Define ap.f = Vector2::LengthSquared(a)
    Define bp.f = Vector2::LengthSquared(b)
    Define cp.f = Vector2::LengthSquared(c)

    ProcedureReturn Bool((a\x * (b\y * cp - bp * c\y) - a\y * (b\x * cp - bp * c\x) + ap * (b\x * c\y - b\y * c\x)) < 0.0)
  EndProcedure
  
  
EndModule



  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 316
; FirstLine = 313
; Folding = ---
; EnableXP