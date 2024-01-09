XIncludeFile "Math.pbi"

DeclareModule SweepLine
  ; A point in 2D plane
  Structure Point_t
    x.i
    y.i
  EndStructure
  
  ; A line segment With left As Point
  ; With smaller x value And right With
  ; larger x value.
  Structure Segment_t
    left.Point_t
    right.Point_t
    hit.b
  EndStructure
 
  ; An event For sweep line algorithm
  ; An event has a point, the position
  ; of Point (whether left Or right) And
  ; index of point in the original input
  ; Array of segments.
  Structure Event_t
    x.i
    y.i
    isLeft.b
    index.i
  EndStructure
  
  ; Build string key for segment
  Declare.s _BuildSegmentKey(*segment.Segment_t)
  ; This is For maintaining the order in set.
  Declare Compare(*first.Event_t, *second.Event_t)
  ; Given three colinear points p, q, r, the function checks If
  ; point q lies on line segment 'pr'
  Declare.b OnSegment(*p.Point_t, *q.Point_t, *r.Point_t)
  ; To find orientation of ordered triplet (p, q, r).
  ; The function returns following values
  ; 0 --> p, q And r are colinear
  ; 1 --> Clockwise
  ; 2 --> Counterclockwise
  Declare.i Orientation(*p.Point_t, *q.Point_t, *r.Point_t)
  
  ; The main function that returns true If line segment 'p1q1'
  ; And 'p2q2' intersect.
  Declare.b DoIntersect(*s1.Segment_t, *s2.Segment_t)
  
  ; Find predecessor of iterator in s.
  Declare Predecessor(Map elements.Event_t(), key.s)
  ; Find sucessor of iterator in s.
  Declare Successor(Map elements.Event_t(), key.s)
  
  ; Returns true If any two lines intersect.
  Declare.b Intersect(Array *segments.Segment_t(1), Map results.s())

  
EndDeclareModule

Module SweepLine
  Procedure.s _BuildSegmentKey(*segment.Segment_t)
    Define key.i
    If *segment\left\x <= *segment\right\x
      If *segment\left\y <= *segment\right\y
        ProcedureReturn Str(((*segment\right\x - *segment\left\x) << 32 ) + (*segment\right\y - *segment\left\y))
      Else
        ProcedureReturn Str(((*segment\right\x - *segment\left\x) << 32 ) + (*segment\left\y - *segment\right\y))
      EndIf
    Else
      If *segment\left\y <= *segment\right\y
        ProcedureReturn Str(((*segment\left\x - *segment\right\x) << 32 ) + (*segment\right\y - *segment\left\y))
      Else
        ProcedureReturn Str(((*segment\left\x - *segment\right\x) << 32 ) + (*segment\left\y - *segment\right\y))
      EndIf
    EndIf
  EndProcedure
  
  Procedure Compare(*first.Event_t, *second.Event_t)
    If *first\y = *second\y : ProcedureReturn Bool(*first\x  < *second\x)
    Else : ProcedureReturn Bool(*first\y < *second\y) : EndIf
  EndProcedure

  Procedure.b OnSegment(*p.Point_t, *q.Point_t, *r.Point_t)
    If *q\x <= Math::MAXIMUM(*p\x, *r\x) And *q\x >= Math::MINIMUM(*p\x, *r\x) And
       *q\y <= Math::MAXIMUM(*p\y, *r\y) And *q\y >= Math::MINIMUM(*p\y, *r\y)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i Orientation(*p.Point_t, *q.Point_t, *r.Point_t)
    ; See https://www.geeksforgeeks.org/orientation-3-ordered-points/
    ; For details of below formula.
    Define val.i = (*q\y - *p\y) * (*r\x - *q\x) - (*q\x - *p\x) * (*r\y - *q\y);
 
    If Not val : ProcedureReturn 0      ;  // colinear
    ElseIf val > 0 : ProcedureReturn 1  ; // clock wise
    Else : ProcedureReturn 2 : EndIf    ; // counterclock wise
  EndProcedure
    
  
   Procedure.b DoIntersect(*s1.Segment_t, *s2.Segment_t)
    Define *p1.Point_t = *s1\left
    Define *q1.Point_t = *s1\right
    Define *p2.Point_t = *s2\left
    Define *q2.Point_t = *s2\right
 
    ; Find the four orientations needed For general And
    ; special cases
    Define o1.i = Orientation(*p1, *q1, *p2);
    Define o2.i = Orientation(*p1, *q1, *q2);
    Define o3.i = Orientation(*p2, *q2, *p1);
    Define o4.i = Orientation(*p2, *q2, *q1);
 
    ; General Case
    If Not o1 = o2 And Not o3 = o4 : ProcedureReturn #True : EndIf
 
    ; Special Cases
    ; p1, q1 And p2 are colinear And p2 lies on segment p1q1
    If o1 = 0 And OnSegment(*p1, *p2, *q1) : ProcedureReturn #True : EndIf
 
    ; p1, q1 And q2 are colinear And q2 lies on segment p1q1
    If o2 = 0 And OnSegment(*p1, *q2, *q1) : ProcedureReturn #True : EndIf
 
    ; p2, q2 And p1 are colinear And p1 lies on segment p2q2
    If o3 = 0 And OnSegment(*p2, *p1, *q2) : ProcedureReturn #True : EndIf
 
    ; p2, q2 And q1 are colinear And q1 lies on segment p2q2
    If o4 = 0 And OnSegment(*p2, *q1, *q2) : ProcedureReturn #True : EndIf
     
    ProcedureReturn #False; // Doesn't fall in any of the above cases
  EndProcedure
  
  ; Find predecessor of iterator in map.
  Procedure Predecessor(Map events.Event_t(), key.s)
    If Not MapSize(events()) : ProcedureReturn #Null: EndIf
    Define *last.Event_t = #Null
    While NextMapElement(events())
      *last = events()
    Wend
    
    ForEach events()
      If MapKey(events()) = key
        ProcedureReturn *last
      Else
        *last = events()
      EndIf
    Next

  EndProcedure
  
  ; Find successor of iterator in map.
  Procedure Successor(Map events.Event_t(), key.s)
    If FindMapElement(events(), key)
      ProcedureReturn NextMapElement(events())
    EndIf
    ProcedureReturn #Null
  EndProcedure
  
  Procedure.b Intersect(Array segments.Segment_t(1), Map results.s())
    
    Define n = ArraySize(segments())
    
    ; Pushing all points To a vector of events
    Dim events.Event_t(n * 2)
    Define i
    For i=0 To n-1
      Define *segment.Segment_t = segments(i)
      events(i * 2)\x = *segment\left\x
      events(i * 2)\y = *segment\left\y
      events(i * 2)\isLeft = #True
      events(i * 2)\index = i
      
      events(i * 2 + 1)\x = *segment\right\x
      events(i * 2 + 1)\y = *segment\right\y
      events(i * 2 + 1)\isLeft = #False
      events(i * 2 + 1)\index = i
    Next
    
    ; Sorting all events according To x coordinate.
    SortStructuredArray(events(), #PB_Sort_Ascending, OffsetOf(Event_t\x), TypeOf(Event_t\x))
    
    ; For storing active segments.
    NewMap active.Event_t()
    Define ans.i=0;
    
    ; Traversing through sorted points
    Define i, index
    Define *curr.Event_t
    Define *prev.Point_t, *next.Point_t
    For i=0 To 2 * n -1
      *curr = events(i)
      index = *curr\index
      Define key.s = _BuildSegmentKey(segments(*curr\index))
      ; if current point is left of its segment
      If *curr\isLeft
        AddMapElement(active(), key)
        active()\index = *curr\index
        active()\isLeft = *curr\isLeft
        active()\x = *curr\x
        active()\y = *curr\y
        
        ; Check If this points intersects With its predecessor And successor
        Define *pred.Event_t = Predecessor(active(), key)
        If *pred And DoIntersect(segments(index), segments(*pred\index))
          AddMapElement(results(), key)
          results() = _BuildSegmentKey(segments(*pred\index))
          segments(index)\hit = #True
          segments(*pred\index)\hit = #True
        EndIf

        Define *succ.Event_t = Successor(active(), key)
        If *succ And DoIntersect(segments(index), segments(*succ\index))
          
          AddMapElement(results(), key)
          results() = _BuildSegmentKey(segments(*succ\index))
          segments(index)\hit = #True
          segments(*succ\index)\hit = #True
        EndIf
 
      ; If current point is right of its segment
      Else
        ; Check If its predecessor And successor intersect With each other
        Define *pred.Event_t = Predecessor(active(), key)
        Define *succ.Event_t = Successor(active(), key)
        If *pred And *succ And DoIntersect(segments(*pred\index), segments(*succ\index))
          ProcedureReturn #True
        EndIf
        DeleteMapElement(active(), key)
      EndIf
    Next

  EndProcedure

EndModule


#WIDTH = 800
#HEIGHT = 600
#N = 128

Procedure RandomSegments(Array result.SweepLine::Segment_t(1), number.i)
  ReDim result(number)
  Define offsetX, offsetY
  For i = 0 To number - 1
    offsetX = Random(#WIDTH - 1) * 0.5
    offsetY = Random(#HEIGHT - 1) * 0.5
    result(i)\left\x = Random(#WIDTH - 1) * 0.25 + offsetX
    result(i)\left\y = Random(#HEIGHT - 1) * 0.25 + offsetY
    result(i)\right\x = Random(#WIDTH - 1) * 0.25 + offsetX
    result(i)\right\y = Random(#HEIGHT - 1) * 0.25 + offsetY
  Next
EndProcedure


Procedure DrawSegments(Array segments.SweepLine::Segment_t(1), canvas.i)
  StartVectorDrawing(CanvasVectorOutput(canvas))
  For i = 0 To ArraySize(segments()) - 1
    MovePathCursor(segments(i)\left\x, segments(i)\left\y)
    AddPathLine(segments(i)\right\x, segments(i)\right\y)
    If segments(i)\hit
      VectorSourceColor(RGBA(Random(255), Random(0), Random(0), 255))
      StrokePath(4)
    Else
      VectorSourceColor(RGBA(Random(0), Random(0), Random(0), 255))
      StrokePath(1)
    EndIf
    
    
  Next
  StopVectorDrawing()
EndProcedure

Dim segments.SweepLine::Segment_t(0)
RandomSegments(segments(), #N)

NewMap results.s()
SweepLine::Intersect(segments(), results())

Define window = OpenWindow(#PB_Any , 0,0 , #WIDTH, #HEIGHT, "Sweep Line")
Define canvas = CanvasGadget(#PB_Any, 0,0,#WIDTH, #HEIGHT, #PB_Canvas_Keyboard)
DrawSegments(segments(), canvas)

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow


; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 239
; FirstLine = 20
; Folding = ---
; EnableXP