EnableExplicit
DeclareModule PriorityQueue
  Structure PriorityQueueItem_t
    *data
    pos.i
  EndStructure
  
  Prototype.b PFNCOMPAREITEM(*item1, *item2)
  
  Structure PriorityQueue_t
    func.PFNCOMPAREITEM
    List items.PriorityQueueItem_t()
  EndStructure
  
  Declare IsEmpty(*queue.PriorityQueue_t)
  Declare SwapItems(*queue.PriorityQueue_t, lhs.i, rhs.i)
  Declare GetParent(*queue.PriorityQueue_t, pos.i)
  Declare GetLeftChild(*queue.PriorityQueue_t, pos.i)
  Declare GetRightChild(*queue.PriorityQueue_t, pos.i)
  Declare Push(*queue.PriorityQueue_t, *data)
  Declare Pop(*queue.PriorityQueue_t)
  Declare Update(*queue.PriorityQueue_t, pos.i)
  Declare Init(*queue.PriorityQueue_t, func.PFNCOMPAREITEM)
  Declare Term(*queue.PriorityQueue_t)
  Declare SiftUp(*queue.PriorityQueue_t, pos.i)
  Declare SiftDown(*queue.PriorityQueue_t, pos.i)
  Declare Remove(*queue.PriorityQueue_t, pos.i)
EndDeclareModule

Module PriorityQueue
  Procedure IsEmpty(*queue.PriorityQueue_t)
    ProcedureReturn Bool(Not ListSize(*queue\items()))
  EndProcedure
  
  Procedure GetParent(*queue.PriorityQueue_t, pos.i)
    ProcedureReturn (pos + 1) / 2 - 1
  EndProcedure

  Procedure GetLeftChild(*queue.PriorityQueue_t, pos.i)
    ProcedureReturn 2 * (pos + 1) - 1
  EndProcedure
  
  Procedure GetRightChild(*queue.PriorityQueue_t, pos.i)
    ProcedureReturn 2 * (pos + 1)
  EndProcedure

  Procedure SiftUp(*queue.PriorityQueue_t, pos.i)
    Define parent.i = GetParent(*queue, pos)
    SelectElement(*queue\items(), parent)
    Define *parentElement.PriorityQueueItem_t = *queue\items()
    SelectElement(*queue\items(), pos)
    Define *currentElement.PriorityQueueItem_t = *queue\items()
    If parent >= 0 And *queue\func(*parentElement, *currentElement)
      SwapItems(*queue, pos, parent)
      siftUp(*queue, parent)
    EndIf
  EndProcedure
  
  Procedure SiftDown(*queue.PriorityQueue_t, pos.i)
    Define left.i = GetLeftChild(*queue, pos)
    Define right.i = GetRightChild(*queue, pos)
    Define current.i = pos
    
    SelectElement(*queue\items(), left)
    Define *leftElement.PriorityQueueItem_t = *queue\items()
    SelectElement(*queue\items(), right)
    Define *rightElement.PriorityQueueItem_t = *queue\items()
    SelectElement(*queue\items(), current)
    Define *currentElement.PriorityQueueItem_t = *queue\items()
    If left < ListSize(*queue\items()) And *queue\func(*currentElement, *leftElement)
      current = left
    EndIf
    If right < ListSize(*queue\items()) And *queue\func(*currentElement, *rightElement)
      current = right
    EndIf
    If Not current = pos
      SwapItems(*queue, pos, current)
      SiftDown(*queue, pos)
    EndIf
  EndProcedure
  
  Procedure Init(*queue.PriorityQueue_t, func.PFNCOMPAREITEM)
    InitializeStructure(*queue, PriorityQueue_t)
    *queue\func        = func
  EndProcedure
  
  Procedure Term(*queue.PriorityQueue_t)
    ClearStructure(*queue, PriorityQueue_t)
  EndProcedure
  
  
  Procedure Push(*queue.PriorityQueue_t, *data)
    Define numItems = ListSize(*queue\items())
    AddElement(*queue\items())
    LastElement(*queue\items())
    Define *item.PriorityQueueItem_t = *queue\items()
    *item\pos = numItems
    *item\data = *data
    SiftUp(*queue, numItems)
  EndProcedure
  
  Procedure Pop(*queue.PriorityQueue_t)
    SwapItems(*queue, 0, ListSize(*queue\items()) - 1)
    DeleteElement(*queue\items())
    SiftDown(*queue, 0)
    ProcedureReturn *first
  EndProcedure
  
  Procedure Update(*queue.PriorityQueue_t, pos.i)
    Define parent = GetParent(*queue, pos)
    SelectElement(*queue\items(), parent)
    Define *parentItem.PriorityQueueItem_t = *queue\items()
    SelectElement(*queue\items(), pos)
    Define *currentItem.PriorityQueueItem_t = *queue\items()
    
    If parent >= 0 And *queue\func(*parentItem, *currentItem  )
      SiftUp(*queue, pos)
    Else
      SiftDown(*queue, pos)
    EndIf
  EndProcedure
  
  Procedure SwapItems(*queue.PriorityQueue_t, lhs.i, rhs.i)
    SelectElement(*queue\items(), lhs)
    Define *first = @*queue\items()
    SelectElement(*queue\items(), rhs)
    Define *last = @*queue\items()
    SwapElements(*queue\items(), *first, *last)
  EndProcedure

  Procedure GetItem(*queue.PriorityQueue_t, *data)
    Define i = 0
    ForEach *queue\items()
      If *data = *queue\items()
        ProcedureReturn i
      EndIf
      i + 1
    Next
  EndProcedure
  
  Procedure Remove(*queue.PriorityQueue_t, pos.i)
    SwapItems(*queue, i, ListSize(*queue\items()) - 1)
    LastElement(*queue\items())
    DeleteElement(*queue\items())
    If i < ListSize(*queue\items())
      Update(*queue, pos)
    EndIf
  EndProcedure
EndModule

Structure Event_t
  x.f
  y.f
EndStructure

Procedure CompareEvent(*lhs.Event_t, *rhs.Event_t)
  If *lhs\y = *rhs\y
    ProcedureReturn Bool(*lhs\x < *rhs\x)
  Else
    ProcedureReturn Bool(*lhs\y < *rhs\y)
  EndIf
EndProcedure


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 160
; FirstLine = 97
; Folding = ---
; EnableXP