XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"

;======================================================================================================
; 2D VORONOI MODULE (from https://github.com/JCash/voronoi/blob/dev/src/jc_voronoi.h)
;======================================================================================================
DeclareModule Voronoi
  UseModule Math
  #EDGE_INTERSECT_THRESHOLD = 0.000000001
  #DIRECTION_LEFT  = 0
  #DIRECTION_RIGHT = 1

  
  ; Tests If a point is inside the final shape
  Prototype PFNCLIPTESTPOINT(*clipper, *point)

  ; Given an edge, And the clipper, calculates the e->pos[0] And e->pos[1]
  ; Returns 0 If Not successful
  Prototype PFNCLIPEDGE(*clipper, *edge)
  
  ; Given the clipper, the site And the last edge,
  ; closes any gaps in the polygon by adding new edges that follow the bounding shape
  ; The internal context is use when allocating new edges.
  Prototype PFNFILLGAP(*diagram, *clipper, *site)
  
  Structure Point_t
    x.f
    y.f
  EndStructure
  
  ; The coefficients a, b And c are from the general line equation: ax * by + c = 0
  Structure Edge_t
    *next.Edge_t
    *sites.Site_t[2]
    pos.Point_t[2]
    a.f
    b.f
    c.f
  EndStructure
  
  Structure GraphEdge_t
    *next.GraphEdge_t
    *edge.Edge_t
    *neighbor.Site_t
    pos.Point_t[2]
    angle.f
  EndStructure
  
  Structure Site_t
    p.Point_t
    index.i       ; index into the original List of points
    *edges.GraphEdge_t;  // The half edges owned by the cell
  EndStructure
  
  Structure HalfEdge_t
    *edge.Edge_t
    *left.HalfEdge_t
    *right.HalfEdge_t
    vertex.Point_t
    y.f
    direction.i ; 0=left, 1=right
    pqpos.i
  EndStructure
  
  Structure Rect_t
    min.Point_t
    max.Point_t
  EndStructure

  Structure Clipper_t
    test_fn.PFNCLIPTESTPOINT
    clip_fn.PFNCLIPEDGE
    fill_fn.PFNFILLGAP
    min.Point_t       ; The bounding rect min
    max.Point_t       ; The bounding rect max
  EndStructure
  
  Prototype PFNPRIORITYQUEUEPRINT(*node, pos.i)
  
  Structure PriorityQueue_t
    maxNumItems.i
    numItems.i
    Array *items.HalfEdge_t(0)
  EndStructure

  Structure Diagram_t
    List edges.Edge_t()
    List halfEdges.HalfEdge_t()
    List graphEdges.GraphEdge_t()
    *currentEdge.Edge_t
    *beachLineStart.HalfEdge_t
    *beachLineEnd.HalfEdge_t
    *lastInserted.HalfEdge_t
    queue.PriorityQueue_t
    
    Array sites.Site_t(0)
    *bottomSite.Site_t
    numSites.i
    currentSite.i
    padding.i
    
    clipper.Clipper_t
    rect.Rect_t
    min.Point_t
    max.Point_t
  EndStructure

 
  Macro POINT_CMP (_p0, _p1)
    Bool(_p0\y = _p1\y) * (1 - 2 * Bool(_p0\x >= _p1\x) + (1 - Bool(_p0\y = _p1\y)) * (1 - 2 * Bool(_p0\y >= _p1\y)
  EndMacro
  
  Macro POINT_LESS(_p0, _p1)
    Bool(_p0\y = _p1\y) * Bool(_p0\x < _p1\x)+ (1 - Bool(_p0\y = _p1\y)) * Bool(_p0\y < _p1\y)
  EndMacro
  
  Macro POINT_EQ(_p0, _p1)
    Bool(Bool(_p0\x = _p1\x) And Bool(_p0\y = _p1\y))
  EndMacro
  
  Macro POINT_ON_BOX_EDGE(_p, _min, _max)
    Bool(Bool(_p\x = _min\x) Or Bool(_p\y = _min\y) Or Bool(_p\x = _max\x) Or Bool(_p\y = _max\y))
  EndMacro
  
  Macro POINT_DIST_SQ(_p0, _p1)
    Pow(_p0\x - _p1\x, 2) + Pow(_p0\y - _p1\y, 2)  
  EndMacro
  
  Macro POINT_DIST(_p0, _p1)
    Sqr(POINT_DIST_SQ(_p0, _p1))
  EndMacro
  
  Macro POINT_VALID(_p)
    1 - Bool(_p\x = NaN() Or _p\y = NaN())
  EndMacro
  
  Declare EdgeNew(*diagram.Diagram_t, *s1.Site_t, *s2.Site_t)
  Declare HalfEdgeNew(*diagram.Diagram_t, *e.Edge_t, direction.i)
  Declare GraphEdgeNew(*diagram.Diagram_t, *site.Site_t, *clipper.Clipper_t)
  Declare DiagramNew(numPoints.i, Array points.Point_t(1), Rect_t)
  Declare DiagramDelete(*diagram.Diagram_t)
  Declare DiagramGetFirstEdge(*diagram.Diagram_t)
  Declare DiagramGetNextEdge( *edge.Edge_t )
  
  Declare DiagramGetEdges(*diagram.Diagram_t)
  Declare DiagramNextEdge(*edge.Edge_t)
 
EndDeclareModule

Module Voronoi
   ; https://cp-algorithms.com/geometry/oriented-triangle-area.html
  Procedure.f ComputeDeterminant(*a.Point_t, *b.Point_t, *c.Point_t)
    ProcedureReturn (*b\x - *a\x)*(*c\y - *a\y) - (*b\y - *a\y)*(*c\x - *a\x)
  EndProcedure
  
  Procedure.f CalcSortMetric(*site.Site_t, *edge.GraphEdge_t)
    ; We take the average of the two points, since we can better distinguish between very small edges
    Define half.f = 0.5
    Define x.f = (*edge\pos[0]\x + *edge\pos[1]\x) * half
    Define y.f = (*edge\pos[0]\y + *edge\pos[1]\y) * half
    Define diffy.f = y - *site\p\y;
    Define angle.f = ATan2( diffy, x - *site\p\x );
    If diffy < 0
      angle = angle + 2.0 * Math::#F32_PI
    EndIf
    
    ProcedureReturn angle;
  EndProcedure

  Procedure SortEdgesInsert(*site.Site_t, *edge.GraphEdge_t)
    ; Special Case For the head End
    If Not *site\edges Or *site\edges\angle >= *edge\angle
      *edge\next = *site\edges
      *site\edges = *edge
    Else
      ; Locate the node before the point of insertion
      Define *current.GraphEdge_t = *site\edges
      While(*current\next And *current\next\angle < *edge\angle)
          *current = *current\next
      Wend
      *edge\next = *current\next
      *current\next = *edge
    EndIf
  EndProcedure
  
  ; ========================================================================================
  ; Edge Constructor
  ; ========================================================================================
  Procedure EdgeNew(*diagram.Diagram_t, *s1.Site_t, *s2.Site_t)
    AddElement(*diagram\edges())
    Define *e.Edge_t = *diagram\edges()

    *e\next = #Null
    *e\sites[0] = *s1
    *e\sites[1] = *s2
    *e\pos[0]\x = NaN()
    *e\pos[0]\y = NaN()
    *e\pos[1]\x = NaN()
    *e\pos[1]\y = NaN()


    Define dx.f = *s2\p\x - *s1\p\x
    Define dy = *s2\p\y - *s1\p\y
    Define dxIsLarger = Bool((dx * dx) > (dy * dy))

    ; Simplify it, using dx And dy
    *e\c = dx * (*s1\p\x + dx * 0.5) + dy * (*s1\p\y + dy * 0.5)

    If dxIsLarger
      *e\a = 1.0
      *e\b = dy / dx
      *e\c / dx
    Else
      *e\a = dx / dy
      *e\b = 1.0
      *e\c / dy
    EndIf
    ProcedureReturn *e
  EndProcedure
  
  Procedure HalfEdgeNew(*diagram.Diagram_t, *e.Edge_t, direction.i)
    AddElement(*diagram\halfEdges())
    Define *he.HalfEdge_t = *diagram\halfEdges()
    *he\edge = *e
    *he\left = #Null
    *he\right = #Null
    *he\direction = direction
    *he\pqpos = 0
    ProcedureReturn *he
  EndProcedure
  
  Procedure GraphEdgeNew(*diagram.Diagram_t, *site.Site_t, *clipper.CLipper_t)
    AddElement(*diagram\graphEdges())
    Define *ge.GraphEdge_t = *diagram\graphEdges()
    *ge\neighbor = #Null
    *ge\pos[0]\x * *clipper\min\x
    *ge\pos[0]\y * *clipper\min\y
    *ge\pos[1]\x * *clipper\max\x
    *ge\pos[1]\x * *clipper\min\x
    *ge\angle = CalcSortMetric(*site, *ge)
    *ge\next = #Null
    ProcedureReturn *ge
  EndProcedure
  
  Procedure CornerEdgeNew(*diagram.Diagram_t, *site.Site_t, *current.GraphEdge_t)
    AddElement(*diagram\graphEdges())
    Define *ge.GraphEdge_t = *diagram\graphEdges()
    *ge\neighbor = #Null
    *ge\pos[0]\x = *current\pos[1]\x
    *ge\pos[0]\y = *current\pos[1]\y
    
    If *current\pos[1]\x < *diagram\rect\max\x And *current\pos[1]\y = *diagram\rect\min\y
      *ge\pos[1]\x = *diagram\rect\max\x
      *ge\pos[1]\y = *diagram\rect\min\y
    ElseIf *current\pos[1]\x > *diagram\rect\min\x And *current\pos[1]\y = *diagram\rect\max\y 
      *ge\pos[1]\x = *diagram\rect\min\x
      *ge\pos[1]\y = *diagram\rect\max\y
    ElseIf *current\pos[1]\y > *diagram\rect\min\y And *current\pos[1]\x = *diagram\rect\min\x 
      *ge\pos[1]\x = *diagram\rect\min\x
      *ge\pos[1]\y = *diagram\rect\min\y
    ElseIf *current\pos[1]\y < *diagram\rect\max\y And *current\pos[1]\x = *diagram\rect\max\x 
      *ge\pos[1]\x = *diagram\rect\max\x
      *ge\pos[1]\y = *diagram\rect\max\y
    EndIf
    
    *ge\angle = CalcSortMetric(*site, *ge)
    ProcedureReturn *ge
  EndProcedure
  
  Procedure GapEdgeNew(*diagram.Diagram_t, *site.Site_t, *ge.GraphEdge_t)
    LastElement(*diagram\edges())
    Define *next.Edge_t = *diagram\edges()
    AddElement(*diagram\edges())
    Define *e.Edge_t = *diagram\edges()
    *e\pos[0]\x = *ge\pos[0]\x
    *e\pos[0]\y = *ge\pos[0]\y
    *e\pos[1]\x = *ge\pos[1]\x
    *e\pos[1]\y = *ge\pos[1]\y
    *e\sites[0] = *site
    *e\sites[1] = #Null
    *e\a = 0
    *e\b = 0
    *e\c = 0
    *e\next = *next
    ProcedureReturn *e
  EndProcedure
  
  ; ========================================================================================
  ; Edge Destructor
  ; ========================================================================================
  Procedure EdgeDelete(*diagram.Diagram_t, *edge.Edge_t)
    ForEach *diagram\edges()
      If *edge = *diagram\edges()
        DeleteElement(*diagram\edges())
        ProcedureReturn
      EndIf
    Next
  EndProcedure
  
  Procedure HalfEdgeDelete(*diagram.Diagram_t, *edge.HalfEdge_t)
    ForEach *diagram\halfEdges()
      If *edge = *diagram\halfEdges()
        DeleteElement(*diagram\halfEdges())
        ProcedureReturn
      EndIf
    Next
  EndProcedure
  
  Procedure GraphEdgeDelete(*diagram.Diagram_t, *edge.GraphEdge_t)
    ForEach *diagram\graphEdges()
      If *edge = *diagram\graphEdges()
        DeleteElement(*diagram\graphEdges())
        ProcedureReturn
      EndIf
    Next
  EndProcedure
  
  ; ========================================================================================
  ; Rectangle
  ; ========================================================================================
  Procedure RectUnion(*rect.Rect_t, *p.Point_t)
    *rect\min\x = Math::MINIMUM(*rect\min\x, *p\x)
    *rect\min\y = Math::MINIMUM(*rect\min\y, *p\y)
    *rect\max\x = Math::MAXIMUM(*rect\max\x, *p\x)
    *rect\max\y = Math::MAXIMUM(*rect\max\y, *p\y)
  EndProcedure
  
  Procedure RectRound(*rect.Rect_t)
    *rect\min\x = Round(*rect\min\x, #PB_Round_Down)
    *rect\min\y = Round(*rect\min\y, #PB_Round_Down)
    *rect\max\x = Round(*rect\max\x, #PB_Round_Up)
    *rect\max\y = Round(*rect\max\y, #PB_Round_Up)
  EndProcedure
  
  Procedure RectInflate(*rect.Rect_t, amount.f)
    *rect\min\x - amount
    *rect\min\y - amount
    *rect\max\x + amount
    *rect\max\y + amount
  EndProcedure
  
  Procedure EdgeClipLine(*diagram.Diagram_t, *e.Edge_t)
    ProcedureReturn *diagram\clipper\clip_fn(*diagram\clipper, *e)
  EndProcedure
  
  ; ========================================================================================
  ; Box Shape Implementation Callbacks
  ; ========================================================================================
  ; CLIPPING
  Procedure BoxShapeTest(*clipper.Clipper_t, *p.Point_t)
    ProcedureReturn #True;Bool(*p\x >= *clipper\min\x And *p\x <= *clipper\max\x And *p\y >= *clipper\min\y And *p\y <= *clipper\max\y)
  EndProcedure


  ; The line equation: ax + by + c = 0
  Procedure BoxShapeClip(*clipper.Clipper_t, *e.Edge_t)
    Define pxmin.f = *clipper\min\x
    Define pxmax.f = *clipper\max\x
    Define pymin.f = *clipper\min\y
    Define pymax.f = *clipper\max\y

    Define.f x1, y1, x2, y2
    Define *s1.Point_t = #Null
    Define *s2.Point_t = #Null
    If *e\a = 1.0 And *e\b >= 0.0
      If POINT_VALID(*e\pos[1]) : *s1 = *e\pos[1] : EndIf
      If POINT_VALID(*e\pos[0]) : *s2 = *e\pos[0] : EndIf
    Else
      If POINT_VALID(*e\pos[0]) : *s1 = *e\pos[0] : EndIf
      If POINT_VALID(*e\pos[1]) : *s2 = *e\pos[1] : EndIf
    EndIf
    
    ; delta x is larger
    If *e\a = 1.0 
      y1 = pymin
      If *s1 And *s1\y > pymin : y1 = *s1\y : EndIf
      If y1 > pymax : y1 = pymax : EndIf
      
      x1 = *e\c - *e\b * y1
      y2 = pymax
      If *s And *s2\y < pymax : y2 = *s2\y : EndIf
      If y2 < pymin : y2 = pymin : EndIf
      
      x2 = (*e\c) - (*e\b) * y2

      If x1 > pxmax
        x1 = pxmax
        y1 = (*e\c - x1) / *e\b
      ElseIf x1 < pxmin
        x1 = pxmin
        y1 = (*e\c - x1) / *e\b
      EndIf
        
      If x2 > pxmax
        x2 = pxmax
        y2 = (*e\c - x2) / *e\b
      ElseIf x2 < pxmin
        x2 = pxmin
        y2 = (*e\c - x2) / *e\b
      EndIf
    ; delta y is larger
    Else 
      x1 = pxmin
      If *s1 And *s1\x > pxmin : x1 = *s1\x : EndIf
      If x1 > pxmax : x1 = pxmax : EndIf

      y1 = *e\c - *e\a * x1
      x2 = pxmax
      If *s2 And *s2\x < pxmax : x2 = *s2\x : EndIf
      If x2 < pxmin : x2 = pxmin : EndIf
      
      y2 = *e\c - *e\a * x2;
     
      If y1 > pymax
        y1 = pymax
        x1 = (*e\c - y1) / *e\a
      ElseIf y1 < pymin
        y1 = pymin
        x1 = (*e\c - y1) / *e\a
      EndIf
        
      If y2 > pymax
          y2 = pymax
          x2 = (*e\c - y2) / *e\a
      ElseIf y2 < pymin
          y2 = pymin
          x2 = (*e\c - y2) / *e\a
      EndIf
    EndIf

    *e\pos[0]\x = x1
    *e\pos[0]\y = y1
    *e\pos[1]\x = x2
    *e\pos[1]\y = y2

    ; If the two points are equal, the result is invalid
    ProcedureReturn Bool(x1=x2 And y1=y2)
  EndProcedure
  
  
  Procedure BoxShapeFillGaps(*diagram.Diagram_t, *clipper.Clipper_t, *site.Site_t)
    ; They're sorted CCW, so if the current->pos[1] != next->pos[0], then we have a gap
    Define *current.GraphEdge_t
    Define *ge.GraphEdge_t
    If Not *site\edges
        ; No edges, then it should be a single cell
      If Not *diagram\numsites = 1:
        ProcedureReturn
      EndIf
      
      *ge = GraphEdgeNew(*diagram\graphEdges(), *site, *clipper)
      *ge\neighbor = #Null
      *ge\pos[0]\x = *clipper\min\x
      *ge\pos[0]\y = *clipper\min\y
      *ge\pos[1]\x = *clipper\max\x
      *ge\pos[1]\y = *clipper\min\y
      *ge\angle = CalcSortMetric(*site, *ge)
      *ge\next = #Null
      *ge\edge = GapEdgeNew(*diagram\edges(), *site, *ge)
      *current = *ge
      *site\edges = *ge
    Else
      *current = *site\edges
    EndIf

    Define  *next.GraphEdge_t = *current\next
    If Not *next
      ; Only one edge, then we assume it's a corner gap
      Define *ce.GraphEdge_t = CornerEdgeNew(*diagram, *site, *current)
      *ce\edge = GapEdgeNew(*diagram, *site, *ce)
      *ce\next = *current\next
      *current\next = *ce
      *current = *ce
      *next = *site\edges
    EndIf
    

    While *current And *next
      If POINT_ON_BOX_EDGE(*current\pos[1], *clipper\min, *clipper\max) And Not POINT_EQ(*current\pos[1] , *next\pos[0])
        ; border gap
        If *current\pos[1]\x = *next\pos[0]\x Or *current\pos[1]\y = *next\pos[0]\y
          *ge = GraphEdgeNew(*diagram, *site, *clipper)
          *ge\neighbor = #Null
          *ge\pos[0]\x = *current\pos\x
          *ge\pos[0]\y = *current\pos\y
          *ge\pos[1]\x = *next\pos\x    
          *ge\pos[1]\y = *next\pos\y
          *ge\angle = CalcSortMetric(*site, *ge)
          *ge\edge = GapEdgeNew(*diagram, *site, *ge)
          
          *ge\next = *current\next
          *current\next = *ge
        ElseIf POINT_ON_BOX_EDGE(*current\pos[1], *clipper\min, *clipper\max) And POINT_ON_BOX_EDGE(*next\pos[0], *clipper\min, *clipper\max)
          *ge = CornerEdgeNew(*diagram, *site, current)
          *ge\edge = GapEdgeNew(*diagram, *site, *ge)
          *ge\next = *current\next
          *current\next = *ge        
        Else
          Break
        EndIf
      EndIf
      
      *current = *current\next
      If *current 
        *next = *current\next
        If Not *next
          *next = *site\edges
        EndIf
      EndIf
    Wend  
  EndProcedure
  
    
  ; ========================================================================================
  ; Half Edge
  ; ========================================================================================
  Procedure HalfEdgeLink(*lhs.HalfEdge_t, *rhs.HalfEdge_t)
    *rhs\left = *lhs
    *rhs\right = *lhs\right
    *lhs\right\left = *rhs
    *lhs\right = *rhs
  EndProcedure
  
  Procedure HalfEdgeUnlink(*he.HalfEdge_t)
    *he\left\right = *he\right
    *he\right\left = *he\left
    *he\left = #Null
    *he\right = #Null
  EndProcedure
  
  Procedure HalfEdgeLeftSite(*he.HalfEdge_t)
    ProcedureReturn *he\edge\sites[*he\direction]
  EndProcedure
   
  Procedure HalfEdgeRightSite(*he.HalfEdge_t)
    If *he\edge
      ProcedureReturn *he\edge\sites[1 - *he\direction]  
    EndIf
  EndProcedure
    
  Procedure HalfEdgeRightOf(*he.HalfEdge_t, *p.Point_t)
    Define *e.Edge_t = *he\edge
    Define *topSite.Site_t = *e\sites[1]
    
    Define rightOfSite.i = Bool(*p\x > *topSite\p\x)
    If rightOfSite And *he\direction = #DIRECTION_LEFT
      ProcedureReturn #True
    EndIf
    If Not rightOfSite And *he\direction = #DIRECTION_RIGHT
      ProcedureReturn #False
    EndIf
    
    Define.f dxp, dyp, dxs, t1, t2, t3, yl
    Define above.i
    
    If *e \a = 1.0
        dyp = *p\y - *topsite\p\y
        dxp = *p\x - *topsite\p\x
        Define fast.i = 0
        If( (Not rightOfSite & Bool(*e\b < 0.0)) | (rightOfSite & Bool(*e\b >= 0.0)) )
          above = Bool(dyp >= *e\b * dxp)
          fast = above
        Else
          above = Bool((*p\x + *p\y * *e\b) > *e\c)
          If *e\b < 0.0 : above =  1 - above : EndIf
          If  Not above : fast = 1 : EndIf
        EndIf
              
        If Not fast
          dxs = *topsite\p\x - *e\sites[0]\p\x
          above = Bool(*e\b * (dxp * dxp - dyp * dyp) < dxs * dyp * (1.0 + 2.0 * dxp / dxs + *e\b * *e\b))
          If *e\b < 0.0 : above = 1 - above : EndIf
        EndIf
    Else ; e->b == 1
        yl = *e\c - *e\a * *p\x
        t1 = *p\y - yl
        t2 = *p\x - *topsite\p\x
        t3 = yl - *topsite\p\y
        above = Bool(t1 * t1 > (t2 * t2 + t3 * t3))
      EndIf
      
      If *he\direction = #DIRECTION_LEFT
        ProcedureReturn above 
      Else
        ProcedureReturn 1 - above
      EndIf
      
  EndProcedure

  ; Keeps the priority queue sorted with events sorted in ascending order
  ; return 1 if the edges needs to be swapped
  Procedure HalfEdgeCompare( *he1.HalfEdge_t, *he2.HalfEdge_t )
    If *he1\y = *he2\y
      ProcedureReturn Bool(*he1\vertex\x > *he2\vertex\x)
    Else
      ProcedureReturn Bool(*he1\y > *he2\y)
    EndIf
  EndProcedure


  Procedure HalfEdgeIntersect(*he1.HalfEdge_t, *he2.HalfEdge_t, *out.Point_t)
    Define *e1.Edge_t = *he1\edge
    Define *e2.Edge_t = *he2\edge

    Define d.f = *e1\a * *e2\b - *e1\b * *e2\a
    If Abs(d) < #EDGE_INTERSECT_THRESHOLD
      ProcedureReturn #False
    EndIf
    
    *out\x = (*e1\c * *e2\b - *e1\b * *e2\c) / d
    *out\y = (*e1\a * *e2\c - *e1\c * *e2\a) / d
    
    Define *e.Edge_t
    Define *he.HalfEdge_t
    If POINT_LESS(*e1\sites[1]\p, *e2\sites[1]\p)
      *he = *he1
      *e = *e1
    Else
      *he = *he2
      *e = *e2
    EndIf
    
    Define rightOfSite = Bool(*out\x >= *e\sites[1]\p\x)
    If (rightOfSite And *he\direction = #DIRECTION_LEFT) Or (Not rightOfSite And *he\direction = #DIRECTION_RIGHT)
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure HalfEdgeCircleEvent(*he1.HalfEdge_t, *he2.HalfEdge_t, *vertex.Point_t)
    Define *e1.Edge_t = *he1\edge
    Define *e2.Edge_t = *he2\edge
    If *e1 = #Null Or *e2 = #Null Or *e1\sites[1] = *e2\sites[1]
      ProcedureReturn 0
    EndIf

    ProcedureReturn HalfEdgeIntersect(*he1, *he2, *vertex)
  EndProcedure
  
  
  ; ========================================================================================
  ; Priority queue
  ; ========================================================================================
  Procedure PriorityQueueMoveUp(*queue.PriorityQueue_t, pos.i)
    Define *node.HalfEdge_t = *queue\items(pos)
    Define *current.HalfEdge_t
    Define parent.i = pos >> 1
    While pos > 1 And HalfEdgeCompare(*queue\items(parent), *node)
      *current = *queue\items(parent)
      *current\pqpos = pos
      *queue\items(pos) = *current
      pos = parent
      parent = parent >> 1
    Wend
    *node\pqpos = pos
    *queue\items(pos) = *node
    ProcedureReturn pos
  EndProcedure

  Procedure PriorityQueueMaxChild(*queue.PriorityQueue_t, pos.i)
    Define child = pos << 1
   
    If child >= *queue\numItems
      ProcedureReturn 0
    EndIf
    
    Define *he1.HalfEdge_t = *queue\items(child)
    Define *he2.HalfEdge_t = *queue\items(child + 1)
    If (child + 1) < *queue\numItems And HalfEdgeCompare(*he1, *he2)
      ProcedureReturn child + 1
    EndIf
    ProcedureReturn child
  EndProcedure
  
  Procedure PriorityQueueMoveDown(*queue.PriorityQueue_t, pos.i)
    Define *node.HalfEdge_t = *queue\items(pos)
    Define *current.HalfEdge_t
    Define child.i = PriorityQueueMaxChild(*queue, pos)

    While child And HalfEdgeCompare(*node, *queue\items(child)) 
      *queue\items(pos) = *queue\items(child)
      *current = *queue\items(pos)
      *current\pqpos = pos
      pos = child
      child = PriorityQueueMaxChild(*queue, pos)
    Wend

    *queue\items(pos) = *node
    *current = *queue\items(pos)
    *current\pqpos = pos
    ProcedureReturn pos
  EndProcedure
  

  Procedure PriorityQueueInit(*queue.PriorityQueue_t, capacity.i)
    InitializeStructure(*queue, PriorityQueue_t)
    *queue\maxNumItems = capacity
    *queue\numItems    = 1
  EndProcedure
  
  Procedure PriorityQueueIsEmpty(*queue.PriorityQueue_t)
    ProcedureReturn Bool(*queue\numItems = 1)
  EndProcedure
  
  Procedure PriorityQueuePush(*queue.PriorityQueue_t, *node)
    If *queue\numItems < *queue\maxNumItems
      Define n = *queue\numItems
      *queue\numItems + 1
      ReDim *queue\items(*queue\numItems)
      *queue\items(n) = *node
      ProcedureReturn PriorityQueueMoveUp(*queue, n)
    EndIf
  EndProcedure
  
  Procedure PriorityQueuePop(*queue.PriorityQueue_t)
    Define *node = *queue\items(1)
    *queue\numItems - 1
    *queue\items(1) = *queue \items(*queue\numItems)
    PriorityQueueMoveDown(*queue, 1)
    ReDim *queue\items(*queue\numItems)
    ProcedureReturn *node
  EndProcedure
  
  Procedure PriorityQueueTop(*queue.PriorityQueue_t)
    ProcedureReturn *queue\items(1)
  EndProcedure
  
  Procedure PriorityQueueRemove(*queue.PriorityQueue_t, *node.HalfEdge_t)
    If *queue\numItems = 1 : ProcedureReturn : EndIf
    Define pos.i = *node\pqpos
    If pos = 0 : ProcedureReturn : EndIf
    
    *queue\numItems - 1
    *queue\items(pos) = *queue\items(*queue\numItems)
    If HalfEdgeCompare( *node, *queue\items(pos) ) 
        PriorityQueueMoveUp( *queue, pos )
    Else
      PriorityQueueMoveDown( *queue, pos )
    EndIf
  EndProcedure
  
  Procedure DiagramGetEdges( *diagram.Diagram_t )
    FirstElement(*diagram\edges())
    ProcedureReturn *diagram\edges()
  EndProcedure
  
  Procedure DiagramNextEdge(*edge.Edge_t)
    Define *next.Edge_t = *edge\next
    While *next And POINT_EQ(*next\pos[0], *next\pos[1])
      *next = *next\next
    Wend
    ProcedureReturn *next
  EndProcedure
 
  Procedure PruneDuplicates(*diagram.Diagram_t, *rect.Rect_t)
    Define numSites = *diagram\numSites

    Define *r.Rect_t = *diagram\rect
    *r\min\x = Math::#F32_MAX
    *r\min\y = Math::#F32_MAX
    *r\max\x = -Math::#F32_MAX
    *r\max\y = -Math::#F32_MAX

    Define offset = 0
    Define *site.Site_t
    ; Prune duplicates first
    For i = 0 To numSites - 1 
        *site = *diagram\sites(i)
        ; Remove duplicates, To avoid anomalies
        If i > 0 And POINT_EQ(*site\p, *diagram\sites(i - 1)\p)
            offset + 1
            Continue
        EndIf

        *diagram\sites(i - offset) = *diagram\sites(i)
        RectUnion(*r, *site\p)
    Next
    *diagram\numSites - offset
    
    ;ReDim *diagram\sites(*diagram\numSites)

    ProcedureReturn offset
  EndProcedure
  

  Procedure PruneNotInShape(*diagram.Diagram_t, *rect.Rect_t)
    Define numSites = *diagram\numSites

    Define *r.Rect_t = *diagram\rect
    *r\min\x = Math::#F32_MAX
    *r\min\y = Math::#F32_MAX
    *r\max\x = -Math::#F32_MAX
    *r\max\y = -Math::#F32_MAX

    Define offset = 0
    Define *site.Site_t
    For i = 0 To numSites - 1
      *site = *diagram\sites(i)
      If Not Bool(*diagram\clipper\test_fn(*diagram\clipper, *site\p))
          offset + 1
          Continue
      EndIf

      *diagram\sites(i - offset) = *diagram\sites(i)
      RectUnion(*r, *site\p)
    Next
    
    *diagram\numSites - offset
    
    ;ReDim *diagram\sites(*diagram\numSites)

    ProcedureReturn offset
  EndProcedure
  
  
  
  ; internal functions
  Procedure DiagramSiteNext(*diagram.Diagram_t)
    If *diagram\currentSite < *diagram\numSites
      Define *next.Site_t = *diagram\sites(*diagram\currentSite)
      *diagram\currentSite + 1
      ProcedureReturn *next
    EndIf
  EndProcedure
  
  Procedure DiagramGetEdgeAboveX(*diagram.Diagram_t, *p.Point_t)

    Define *he.HalfEdge_t = *diagram\lastInserted
    If Not *he
       If *p\x < (*diagram\rect\max\x - *diagram\rect\min\x) / 2
        *he = *diagram\beachLineStart
      Else
        *he = *diagram\beachLineEnd
      EndIf
    EndIf
    
     If *he = *diagram\beachLineStart Or (Not Bool(*he = *diagram\beachLineEnd) And HalfEdgeRightOf(*he, *p)) 
       Repeat
         *he = *he\right
       Until *he = *diagram\beachLineEnd Or Not HalfEdgeRightOf(*he, *p)
       *he = *he\left
     Else
       Repeat
         *he = *he\left
       Until *he = *diagram\beachLineStart Or HalfEdgeRightOf(*he, *p)
    EndIf
    ProcedureReturn *he
  EndProcedure
  
    Procedure DiagramGetFirstEdge(*diagram.Diagram_t)
    FirstElement(*diagram\edges())
    ProcedureReturn *diagram\edges()
  EndProcedure
  
  Procedure DiagramGetNextEdge( *edge.Edge_t )
    Define *e.Edge_t = *edge\next
    While *e And POINT_EQ(*e\pos[0], *e\pos[1])
      *e = *e\next
    Wend
    ProcedureReturn *e
  EndProcedure
  
  Procedure DiagramFinishLine(*diagram.Diagram_t, *e.Edge_t)
    If Not EdgeClipLine(*diagram, *e)
      ProcedureReturn 
      
    EndIf
  
    ; Make sure the graph edges are CCW
    Define flip = Bool(ComputeDeterminant(*e\sites[0]\p, *e\pos[0], *e\pos[1]) <= 0.0)

    For i = 0 To 1
      Define *ge.GraphEdge_t = GraphEdgeNew(*diagram, *e\sites[i], *diagram\clipper)
      *ge\edge = *e
      *ge\next = #Null
      *ge\neighbor = *e\sites[1-i]
      *ge\pos[flip]\x = *e\pos[i]\x
      *ge\pos[flip]\y = *e\pos[i]\y
      *ge\pos[1-flip]\x = *e\pos[1-i]\x
      *ge\pos[1-flip]\y = *e\pos[1-i]\y
      *ge\angle = CalcSortMetric(*e\sites[i], *ge)
      
      SortEdgesInsert(*e\sites[i], *ge)
      
      ; check that we didn't accidentally add a duplicate (rare), then remove it
      If *ge\next And *ge\angle = *ge\next\angle
          If POINT_EQ( *ge\pos[0], *ge\next\pos[0] ) And Point_EQ( *ge\pos[1], *ge\next\pos[1] )
              *ge\next = *ge\next\next; // Throw it away, they're so few anyways
          EndIf
      EndIf
    Next
  EndProcedure
  
  Procedure DiagramEndPos(*diagram.Diagram_t, *e.Edge_t, *p.Point_t, direction.i)
    *e\pos[direction]\x = *p\x
    *e\pos[direction]\y = *p\y
    
    If Not POINT_VALID(*e\pos[1 - direction])
      ProcedureReturn
    EndIf
    DiagramFinishLine(*diagram, *e)
  EndProcedure
  

  ; Since the algorithm leaves gaps at the borders/corner, we want To fill them
  Procedure DiagramFillGaps(*diagram.Diagram_t)
    If Not *diagram\clipper\fill_fn
      ProcedureReturn
    EndIf
    
    Define *site.Site_t
    For i = 0 To *diagram\numsites - 1
      *site = *diagram\sites(i)
      *diagram\clipper\fill_fn(*diagram, *diagram\clipper, *site);
    Next
   EndProcedure
   
  Procedure DiagramCircleEvent(*diagram.Diagram_t)
    Define *left.HalfEdge_t = PriorityQueuePop(*diagram\queue)
    
    Define *leftleft.HalfEdge_t  = *left\left
    Define *right.HalfEdge_t = *left\right
    Define  *rightright.HalfEdge_t = *right\right
    Define *bottom.Site_t = HalfEdgeLeftSite(*left)
    Define *top.Site_t = HalfEdgeRightSite(*right)

    Define vertex.Point_t
    vertex\x = *left\vertex\x
    vertex\y = *left\vertex\y
    DiagramEndPos(*diagram, *left\edge, vertex, *left\direction)
    DiagramEndPos(*diagram, *right\edge, vertex, *right\direction)
    *diagram\lastInserted = *rightright
    
    PriorityQueueRemove(*diagram\queue, *right)
    HalfEdgeUnlink(*left)
    HalfEdgeUnlink(*right)
    HalfEdgeDelete(*diagram, *left)
    HalfEdgeDelete(*diagram, *right)

    Define direction = #DIRECTION_LEFT
    If *bottom\p\y > *top\p\y
        Define *tmp.Site_t = *bottom
        *bottom = *top
        *top = *tmp
        direction = #DIRECTION_RIGHT
    EndIf

    Define *edge.Edge_t = EdgeNew(*diagram, *bottom, *top)
    *edge\next = *diagram\currentEdge
    *diagram\currentEdge = *edge
    
    Define *he.HalfEdge_t = HalfEdgeNew(*diagram, *edge, direction)
    HalfEdgeLink(*leftleft, *he)
    DiagramEndPos(*diagram, *edge, vertex, #DIRECTION_RIGHT - direction)

    Define p.Point_t
    If HalfEdgeCircleEvent( *leftleft, *he, p ) 
      PriorityQueueRemove(*diagram\queue, *leftleft)
      *leftleft\vertex\x = p\x
      *leftleft\vertex\y = p\y + POINT_DIST(*bottom\p, p)
      PriorityQueuePush(*diagram\queue, *leftleft)
    EndIf
      
    If HalfEdgeCircleEvent( *he, *rightright, p )
      *he\vertex\x = p\x
      *he\vertex\y = p\y + POINT_DIST(*bottom\p, p)
      PriorityQueuePush(*diagram\queue, *he)
    EndIf
  EndProcedure
  

  Procedure DiagramSiteEvent(*diagram.Diagram_t, *site.Site_t)
    Define *left.HalfEdge_t   = DiagramGetEdgeAboveX(*diagram, *site\p)
    Define *right  = *left\right
    Define *bottom.Site_t = HalfEdgeRightSite(*left)
    If Not *bottom : *bottom =*diagram\bottomsite : EndIf
    

    Define *edge.Edge_t = EdgeNew(*diagram, *bottom, *site)
    *edge\next = *diagram\currentEdge
    *diagram\currentEdge = *edge
    
    Define *edge1.HalfEdge_t = HalfEdgeNew(*diagram, *edge, #DIRECTION_LEFT)
    Define *edge2.HalfEdge_t = HalfEdgeNew(*diagram, *edge, #DIRECTION_RIGHT)
    
    HalfEdgeLink(*left, *edge1)
    HalfEdgeLink(*edge1, *edge2)
    
    *diagram\lastInserted = *right

    Define p.Point_t
    If HalfEdgeCircleEvent(*left, *edge1, p)
      PriorityQueueRemove(*diagram\queue, *left)
      *left\vertex\x = p\x
      *left\vertex\y = p\y
      *left\y = p\y + POINT_DIST(*site\p, p)
      PriorityQueuePush(*diagram\queue, *left)
    EndIf
    
    If HalfEdgeCircleEvent(*edge2, *right, p)
      *edge2\vertex\x = p\x
      *edge2\vertex\y = p\y + POINT_DIST(*site\p, p)
      PriorityQueuePush(*diagram\queue, *edge2)
    EndIf
    
  EndProcedure
  
  Procedure DiagramNew(numPoints.i, Array points.Point_t(1), Rect_t)
    Define *diagram.Diagram_t = AllocateMemory(SizeOf(Diagram_t))
    InitializeStructure(*diagram, Diagram_t)
    
    *diagram\lastInserted = #Null

    
    *diagram\beachLineStart = HalfEdgeNew(*diagram, 0, 0)
    *diagram\beachLineEnd = HalfEdgeNew(*diagram, 0, 0)
    
    *diagram\beachLineStart\left = #Null
    *diagram\beachLineStart\right = *diagram\beachLineEnd
    *diagram\beachLineEnd\left = *diagram\beachLineStart
    *diagram\beachLineEnd\right = #Null
    
    Define maxNumEvents = numPoints * 2 ; beachline can have max 2*n-5 parabolas
    PriorityQueueInit(*diagram\queue, maxNumEvents)
    
    *diagram\numSites = numPoints
    ReDim *diagram\sites(numPoints)
    Define *site.Site_t
    For i=0 To numPoints - 1
      *site = *diagram\sites(i)
      *site\edges = #Null
      *site\p\x = points(i)\x
      *site\p\y = points(i)\y
      *site\index = i
    Next
    
    SortStructuredArray(*diagram\sites(), #PB_Sort_Descending, OffsetOf(Site_t\p), #PB_Float)
    SortStructuredArray(*diagram\sites(), #PB_Sort_Descending, OffsetOf(Site_t\p) + 1, #PB_Float)
    
    *diagram\clipper\test_fn = @BoxShapeTest()
    *diagram\clipper\clip_fn = @BoxShapeClip()
    *diagram\clipper\fill_fn = @BoxShapeFillGaps()
    
    Define *rect.Rect_t = *diagram\rect
    *rect\min\x = Math::#F32_MAX
    *rect\min\y = Math::#F32_MAX
    *rect\max\x = -Math::#F32_MAX
    *rect\max\y = -Math::#F32_MAX
    PruneDuplicates(*diagram, *rect)
    
    ; Prune using the test second
    If (*diagram\clipper\test_fn)
      ; e.g. used by the box clipper in the test_fn
      *diagram\clipper\min\x = *rect\min\x
      *diagram\clipper\min\y = *rect\min\y
      *diagram\clipper\max\x = *rect\max\x
      *diagram\clipper\max\y = *rect\max\y
      
      PruneNotInShape(*diagram, *rect)
      
      RectRound(*rect)
      RectInflate(*rect, 10)

      *diagram\clipper\min\x = *rect\min\x
      *diagram\clipper\min\y = *rect\min\y
      *diagram\clipper\max\x = *rect\max\x
      *diagram\clipper\max\y = *rect\max\y
    EndIf
    
    *diagram\min\x = *rect\min\x
    *diagram\min\y = *rect\min\y
    *diagram\max\x = *rect\max\x
    *diagram\max\y = *rect\max\y
    *diagram\numSites = numPoints
    
    *diagram\bottomsite = DiagramSiteNext(*diagram)
    Define *queue.PriorityQueue_t = *diagram\queue
    Define *site.Site_t = DiagramSiteNext(*diagram)
    Define *he.HalfEdge_t
    Define finished = 0
    While Not finished
      Define lowestPoint.Point_t  
      If Not PriorityQueueIsEmpty(*queue)
        *he = PriorityQueueTop(*queue)
        lowestPoint\x = *he\vertex\x
        lowestPoint\y = *he\y
      EndIf
      
      If *site And (PriorityQueueIsEmpty(*queue) Or POINT_LESS(*site\p, lowestPoint))
        DiagramSiteEvent(*diagram, *site)
        *site = DiagramSiteNext(*diagram)
      ElseIf Not PriorityQueueIsEmpty(*diagram\queue)
        DiagramCircleEvent(*diagram)
      Else
        finished = 1
      EndIf 
    Wend  
    
    finished = 0
    *he = *diagram\beachLineStart\right
    
    While Not finished
      DiagramFinishLine(*diagram, *he\edge)
      *he = *he\right
      If Not *he Or *he = *diagram\beachLineEnd
        finished = #True
      EndIf
    Wend
    
    DiagramFillGaps(*diagram)
    
    ProcedureReturn *diagram
  EndProcedure
  
  Procedure DiagramDelete(*diagram.Diagram_t)
    ClearStructure(*diagram, Diagram_t)
    FreeMemory(*diagram)
  EndProcedure
 
EndModule 


Define WIDTH = 800
Define N = 12
Dim points.Voronoi::Point_t(N)
Define i
Define *p.Voronoi::Point_t
For i = 0 To N - 1
  *p = points(i)
  *p\x = 200 + Random(400)
  *p\y = 200 + Random(400)
  Debug Str(*p\x)+","+Str(*p\y)
Next

Define rect.Voronoi::Rect_t

Define *diagram.Voronoi::Diagram_t = Voronoi::DiagramNew(N, points(), rect)

Define window = OpenWindow(#PB_Any , 0, 0, WIDTH, WIDTH, "VORONOI")
Define canvas = CanvasGadget(#PB_Any, 0, 0, WIDTH, WIDTH)

SortStructuredArray(points(), #PB_Sort_Descending, 0, #PB_Float)
SortStructuredArray(points(), #PB_Sort_Descending, 1, #PB_Float)

StartVectorDrawing(CanvasVectorOutput(canvas))
For i = 0 To *diagram\numSites - 1
  VectorSourceColor(RGBA(0,0,0,255))
  AddPathCircle(*diagram\sites(i)\p\x, *diagram\sites(i)\p\y, 12)
  Debug Str(*diagram\sites(i)\p\x)+","+Str(*diagram\sites(i)\p\y)
  FillPath()
  VectorSourceColor(RGBA(255,0,0,255))
  AddPathCircle(points(i)\x, points(i)\y, 4)
  FillPath()
Next
VectorSourceColor(RGBA(255,255,0,255))
Define *edges = Voronoi::DiagramGetEdges(*diagram)

ForEach *diagram\edges()
  AddPathLine(*diagram\edges()\pos\x, *diagram\edges()\pos\y)
Next
StrokePath(4)
StopVectorDrawing()

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 734
; FirstLine = 725
; Folding = ----------
; EnableXP