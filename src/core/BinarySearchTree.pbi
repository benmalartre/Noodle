DeclareModule BinarySearchTree
  Structure BinarySearch_t
    key.i
    *left.BinarySearchTree_t
    *right.BinarySearchTree
  EndStructure
  
  Declare New()
  Declare Insert(*root.BinarySearchTree_t, key.i)
  Declare Search(*root.BinarySearchTree_t, key.i)

  

EndDeclareModule

Module PriorityQueue
  
  ; function To search a given key in a given BST
  Procedure Search(*root.BinarySearchTree_t, key.i)
    ; Base Cases: root is null Or key is present at root
    If Not *root Or *root\key = key:
      ProcedureReturn *root
    EndIf
    
      
    ; Key is greater than root's key
    If *root\key < key:
      ProcedureReturn Search(*root\right, key)
    Else
      ; Key is smaller than root's key
      ProcedureReturn search(*root\left, key)
    EndIf
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
; Folding = -
; EnableXP