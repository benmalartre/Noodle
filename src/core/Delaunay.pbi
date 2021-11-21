DeclareModule Delaunay
  #EPSILON = 0.0000000001
  Structure Point_t
    x.f
    y.f
    z.f
  EndStructure
  
  Structure Edge_t
    p1.i
    p2.i
  EndStructure
  
  Structure Triangle_t
    p1.i
    p2.i
    p3.i
  EndStructure
  
  Declare XYZCompare(*p1.Point_t, *p2.Point_t)
  Declare Triangulate(numPoints.i, Array points.Point_t(1), Array triangles.Triangle_t, *numTriangles)
  Declare CircumCircle(xp.f, yp.f, x1.f, y1.f, x2.f, y2.f, x3.f, y3.f, *xc, *yc, *r)
EndDeclareModule


Module Delaunay
  
;   ////////////////////////////////////////////////////////////////////////
;   // CircumCircle() :
;   //   Return true If a Point (xp,yp) is inside the circumcircle made up
;   //   of the points (x1,y1), (x2,y2), (x3,y3)
;   //   The circumcircle centre is returned in (xc,yc) And the radius r
;   //   Note : A point on the edge is inside the circumcircle
;   ////////////////////////////////////////////////////////////////////////
  Procedure CircumCircle(xp.f, yp.f, x1.f, y1.f, x2.f, y2.f, x3.f, y3.f, *xc, *yc, *r)
    Define.f m1, m2, mx1, mx2, my1, my2
    Define.f dx, dy, rsqr, drsqr
  
    ; Check For coincident points 
    If Abs(y1 - y2) < #EPSILON And Abs(y2 - y3) < #EPSILON
      ProcedureReturn #False
    EndIf
    
    If Abs(y2-y1) < #EPSILON
      m2 = - (x3 - x2) / (y3 - y2)
      mx2 = (x2 + x3) / 2.0
      my2 = (y2 + y3) / 2.0
      xc = (x2 + x1) / 2.0
      yc = m2 * (xc - mx2) + my2
    ElseIf Abs(y3 - y2) < #EPSILON)
      m1 = - (x2 - x1) / (y2 - y1)
      mx1 = (x1 + x2) / 2.0
      my1 = (y1 + y2) / 2.0
      xc = (x3 + x2) / 2.0
      yc = m1 * (xc - mx1) + my1
    Else
      m1 = - (x2 - x1) / (y2 - y1)
      m2 = - (x3 - x2) / (y3 - y2)
      mx1 = (x1 + x2) / 2.0
      mx2 = (x2 + x3) / 2.0
      my1 = (y1 + y2) / 2.0
      my2 = (y2 + y3) / 2.0
      xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2); 
      yc = m1 * (xc - mx1) + my1
    EndIf
    dx = x2 - xc
    dy = y2 - yc
    rsqr = dx * dx + dy * dy
    r = Qqr(rsqr) 
    dx = xp - xc
    dy = yp - yc
    drsqr = dx * dx + dy * dy
    ProcedureReturn Bool(drsqr <= rsqr)
  EndProcedure
  
;   ///////////////////////////////////////////////////////////////////////////////
;   // Triangulate() :
;   //   Triangulation subroutine
;   //   Takes As input NV vertices in Array pxyz
;   //   Returned is a List of ntri triangular faces in the Array v
;   //   These triangles are arranged in a consistent clockwise order.
;   //   The triangle Array 'v' should be malloced To 3 * nv
;   //   The vertex Array pxyz must be big enough To hold 3 more points
;   //   The vertex Array must be sorted in increasing x values say
;   //
;   //   qsort(p,nv,SizeOf(XYZ),XYZCompare);
;   ///////////////////////////////////////////////////////////////////////////////

  Procedure Triangulate(numPoints.i, Array points.Point_t(1), Array triangles.Triangle_t(1), *numTriangles)
    Define *complete = #Null
    Define *edges.Edge_t = #Null
    Define *p_edgeTemp = #Null
    Define numEdges = 0
    Define triMax.i
    Define edgeMax = 200
    Define status.i
    Define inside.i
    Define i, j, k
    Define.f xp, yp, x1, y1, x2, y2, x3, y3, xc, yc, r
    Define.f xmin, xmax, ymin, ymax, xmid, ymid
    Define.f dx, dy, dmax
    
    ; Allocate memory For the completeness List, flag For each triangle 
    triMax = 4 * numPoints
    complete = AllocateMemory(trimax * #PB_Integer)
    ; Allocate memory For the edge List
    edges = AllocateMemory(edgeMax * SizeOf(Edge_t))

    ; Find the maximum And minimum vertex bounds.
    ; This is To allow calculation of the bounding triangle
    xmin = points(0)\x
    ymin = points(0)\y
    xmax = xmin
    ymax = ymin
    For i=0 To numPoints - 1
      If points(i)\x < xmin) : xmin = points(i)\x :EndIf  
      If points(i)\x > xmax) : xmax = points(i)\x :EndIf  
      If points(i)\y < ymin) : ymin = points(i)\y :EndIf  
      If points(i)\y > ymax) : ymax = points(i)\y :EndIf  
    Next
    
    dx = xmax - xmin
    dy = ymax - ymin
    If dx > dy : dmax = dx : Else: dmax = dy : EndIf

    ;  Set up the supertriangle
    ;  his is a triangle which encompasses all the sample points.
    ;  The supertriangle coordinates are added To the End of the
    ;  vertex List. The supertriangle is the first triangle in
    ;  the triangle List.
  pxyz[nv+0].x = xmid - 20 * dmax;
  pxyz[nv+0].y = ymid - dmax;
  pxyz[nv+1].x = xmid;
  pxyz[nv+1].y = ymid + 20 * dmax;
  pxyz[nv+2].x = xmid + 20 * dmax;
  pxyz[nv+2].y = ymid - dmax;
  v[0].p1 = nv;
  v[0].p2 = nv+1;
  v[0].p3 = nv+2;
  complete[0] = false;
  ntri = 1           ;
  
    ; Include each point one at a time into the existing mesh
  For(i = 0; i < nv; i++){
    xp = pxyz[i].x;
    yp = pxyz[i].y;
    nedge = 0;
/*
     Set up the edge buffer.
     If the Point (xp,yp) lies inside the circumcircle then the
     three edges of that triangle are added To the edge buffer
     And that triangle is removed.
*/
  For(j = 0; j < ntri; j++){
    If(complete[j])
      Continue;
    x1 = pxyz[v[j].p1].x;
    y1 = pxyz[v[j].p1].y;
    x2 = pxyz[v[j].p2].x;
    y2 = pxyz[v[j].p2].y;
    x3 = pxyz[v[j].p3].x;
    y3 = pxyz[v[j].p3].y;
    inside = CircumCircle(xp, yp, x1, y1, x2, y2, x3, y3, xc, yc, r);
    If (xc + r < xp)
// Suggested
// If (xc + r + EPSILON < xp)
      complete[j] = true;
    If(inside){
/* Check that we haven't exceeded the edge list size */
      If(nedge + 3 >= emax){
        emax += 100;
        p_EdgeTemp = new IEDGE[emax];
        For (int i = 0; i < nedge; i++) { // Fix by John Bowman
          p_EdgeTemp[i] = edges[i];   
        }
        delete []edges;
        edges = p_EdgeTemp;
      }
      edges[nedge+0].p1 = v[j].p1;
      edges[nedge+0].p2 = v[j].p2;
      edges[nedge+1].p1 = v[j].p2;
      edges[nedge+1].p2 = v[j].p3;
      edges[nedge+2].p1 = v[j].p3;
      edges[nedge+2].p2 = v[j].p1;
      nedge += 3;
      v[j] = v[ntri-1];
      complete[j] = complete[ntri-1];
      ntri--;
      j--;
    }
  }
/*
  Tag multiple edges
  Note: If all triangles are specified anticlockwise then all
  interior edges are opposite pointing in direction.
*/
  For(j = 0; j < nedge - 1; j++){
    For(k = j + 1; k < nedge; k++){
      If((edges[j].p1 == edges[k].p2) && (edges[j].p2 == edges[k].p1)){
        edges[j].p1 = -1;
        edges[j].p2 = -1;
        edges[k].p1 = -1;
        edges[k].p2 = -1;
      }
       /* Shouldn't need the following, see note above */
      If((edges[j].p1 == edges[k].p1) && (edges[j].p2 == edges[k].p2)){
        edges[j].p1 = -1;
        edges[j].p2 = -1;
        edges[k].p1 = -1;
        edges[k].p2 = -1;
      }
    }
  }
/*
     Form new triangles For the current point
     Skipping over any tagged edges.
     All edges are arranged in clockwise order.
*/
  For(j = 0; j < nedge; j++) {
    If(edges[j].p1 < 0 || edges[j].p2 < 0)
      Continue;
    v[ntri].p1 = edges[j].p1;
    v[ntri].p2 = edges[j].p2;
    v[ntri].p3 = i;
    complete[ntri] = false;
    ntri++;
  }
}
/*
      Remove triangles With supertriangle vertices
      These are triangles which have a vertex number greater than nv
*/
  For(i = 0; i < ntri; i++) {
    If(v[i].p1 >= nv || v[i].p2 >= nv || v[i].p3 >= nv) {
      v[i] = v[ntri-1];
      ntri--;
      i--;
    }
  }
  delete[] edges;
  delete[] complete;
  Return 0;
} 

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 122
; FirstLine = 111
; Folding = -
; EnableXP