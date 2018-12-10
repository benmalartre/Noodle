Structure Cell_t
  code.i
  *cells.Cell_t[4]
  isLeaf.b
EndStructure


#MAX_DEPTH=4

Global window
Global canvas
Global width = 800
Global height = 800
Global stx = width / #MAX_DEPTH
Global sty = height / #MAX_DEPTH

Procedure Encode(code.i, depth.i, pos.i)
  Define n = code | (pos << (depth*2))
  ProcedureReturn n | 1 << 8
EndProcedure


Procedure Split(*cell.Cell_t, depth.i)
  For i=0 To 3
    *cell\cells[i] = AllocateMemory(SizeOf(Cell_t))
    *cell\cells[i]\code = Encode(*cell\code, depth, i)
    Debug "CELL CODE : "+Bin(*cell\cells[i]\code)
    InitializeStructure(*cell\cells[i], Cell_t)
    If depth < #MAX_DEPTH-1
      Split(*cell\cells[i], depth+1)
    Else
      *cell\cells[i]\isLeaf = #True
    EndIf
  Next
EndProcedure

Procedure BuildTree()
  Protected *tree.Cell_t = AllocateMemory(SizeOf(Cell_t))
  InitializeStructure(*tree, Cell_t)
  Split(*tree, 0)
  ProcedureReturn *tree
EndProcedure

Procedure DrawCell(*cell.Cell_t)
  If *cell\isLeaf
    w = width / 4
    h = height / 4
    
  Else
    Define i
    For i=0 To 3
      DrawCell(*cell\cells[i])
    Next
  EndIf
  
EndProcedure

Procedure Draw()
  StartDrawing(CanvasOutput(canvas))
  
  StopDrawing()
EndProcedure

Define *tree.Cell_t = BuildTree()
Debug *tree

  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 14
; FirstLine = 11
; Folding = -
; EnableXP