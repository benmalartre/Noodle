DeclareModule PriorityQueue
  Structure TaskList_t
    List description.s()  ;implements FIFO queue
  EndStructure
   
  Structure Task_t
    *tl.tList  ;pointer to a list of task descriptions
    priority.i ;tasks priority, lower value has more priority
  EndStructure
   
  Structure PriorityQueue_t
    maxHeapSize.i ;increases as needed
    heapItemCount.i  ;number of elements currently in heap
    Array heap.Task_t(0) ;elements hold FIFO queues ordered by priorities, lowest first
    Map heapMap.TaskList_t() ;holds lists of tasks with the same priority that are FIFO queues
  EndStructure
  
  Declare Insert(*queue.PriorityQueue_t, description.s, priority.i)
  Declare.s Remove(*queue.PriorityQueue_t)
  Declare IsEmpty(*queue.PriorityQueue_t)
  

EndDeclareModule

Module PriorityQueue
  Procedure Insert(*queue.PriorityQueue_t, description.s, priority.i)
    If FindMapElement(*queue\heapMap(), Str(p))
      LastElement(*queue\heapMap()\description())
      AddElement(*queue\heapMap()\description())
      *queue\heapMap()\description() = description
    Else
      Protected *tl.TaskList_t = AddMapElement(*queue\heapMap(), Str(p))
      AddElement(*tl\description())
      *tl\description() = description
   
      Protected pos = *queue\heapItemCount
   
      *queue\heapItemCount + 1
      If *queue\heapItemCount > *queue\maxHeapSize
        Select *queue\maxHeapSize
          Case 0
            *queue\maxHeapSize = 128
          Default
            *queue\maxHeapSize * 2
        EndSelect
        ReDim *queue\heap.Task_t(*queue\maxHeapSize)
      EndIf 
   
      While pos > 0 And p < *queue\heap((pos - 1) / 2)\Priority
        *queue\heap(pos) = *queue\heap((pos - 1) / 2)
        pos = (pos - 1) / 2
      Wend
   
      *queue\heap(pos)\tl = *tl
      *queue\heap(pos)\priority = p
    EndIf 
  EndProcedure
 
  Procedure.s Remove(*queue.PriorityQueue_t)
    Protected *tl.TaskList_t = *queue\heap(0)\tl, description.s
    FirstElement(*tl\description())
    description = *tl\description()
    If ListSize(*tl\description()) > 1
      DeleteElement(*tl\description())
    Else
      DeleteMapElement(*queue\heapMap(), Str(*queue\heap(0)\Priority))
   
      *queue\heapItemCount - 1
      *queue\heap(0) = *queue\heap(*queue\heapItemCount)
   
      Protected pos
      Repeat
        Protected child1 = 2 * pos + 1
        Protected child2 = 2 * pos + 2
        If child1 >= *queue\heapItemCount
          Break 
        EndIf
   
        Protected smallestChild
        If child2 >= *queue\heapItemCount
          smallestChild = child1 
        ElseIf *queue\heap(child1)\Priority <= *queue\heap(child2)\Priority
          smallestChild = child1 
        Else
          smallestChild = child2 
        EndIf
   
        If (*queue\heap(smallestChild)\Priority >= *queue\heap(pos)\Priority)
          Break 
        EndIf
        Swap *queue\heap(pos)\tl, *queue\heap(smallestChild)\tl
        Swap *queue\heap(pos)\Priority, *queue\heap(smallestChild)\Priority
        pos = smallestChild
      ForEver
    EndIf 
   
    ProcedureReturn description
  EndProcedure
   
  Procedure IsEmpty(*queue.PriorityQueue_t)
    If *queue\heapItemCount
      ProcedureReturn 0
    EndIf
    ProcedureReturn 1
  EndProcedure  

EndModule

 
If OpenConsole()
  Define queue.PriorityQueue::PriorityQueue_t
  PriorityQueue::Insert(queue, "Clear drains", 3)
  PriorityQueue::Insert(queue, "Answer Phone 1", 8)
  PriorityQueue::Insert(queue, "Feed cat", 4)
  PriorityQueue::Insert(queue, "Answer Phone 2", 8)
  PriorityQueue::Insert(queue, "Make tea", 5)
  PriorityQueue::Insert(queue, "Sleep", 9)
  PriorityQueue::Insert(queue, "Check email", 3)
  PriorityQueue::Insert(queue, "Solve RC tasks", 1)
  PriorityQueue::Insert(queue, "Answer Phone 3", 8)
  PriorityQueue::Insert(queue, "Exercise", 9)
  PriorityQueue::Insert(queue, "Answer Phone 4", 8)
  PriorityQueue::Insert(queue, "Tax return", 2)
 
  While Not PriorityQueue::IsEmpty(queue)
    PrintN(PriorityQueue::Remove(queue))
  Wend
 
  Print(#CRLF$ + #CRLF$ + "Press ENTER to exit"): Input()
  CloseConsole()
EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 27
; FirstLine = 5
; Folding = -
; EnableXP