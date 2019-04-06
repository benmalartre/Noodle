
XIncludeFile "../core/Time.pbi"

;============================================================================================
; STACK MODULE DECLARATION
;============================================================================================
DeclareModule Stack
  Enumeration
    #STACK_MODELING
    #STACK_SHAPE
    #STACK_ANIMATION
    #STACK_SECONDARY
    #STACK_SIMULATION
    #STACK_POSTSIMULATION
  EndEnumeration
  
  Interface StackNode
    Evaluate()
    Delete()
  EndInterface
  
  Structure StackLevel_t Extends Object::Object_t 
    name.s
    color.i
    List nodes.StackNode()
  EndStructure
  
  Structure Stack_t Extends Object::Object_t 
    List *levels.StackLevel_t()
    numNodes.i
  EndStructure
  
  Declare New()
  Declare Delete(*Me.Stack_t)
  Declare NewLevel(*Me.Stack_t,name.s,color.i)
  Declare DeleteLevel(*Me.StackLevel_t)
  Declare Update(*Me.Stack_t)
  Declare UpdateLevel(*level.StackLevel_t)
  Declare AddNode(*Me.Stack_t,node.StackNode,level.i)
  Declare Clear(*Me.Stack_t)
  Declare ClearLevel(*level.StackLevel_t)
  Declare.b HasNodes(*Me.Stack_t)
  DataSection
    StackVT:
    StackLevelVT:
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

;============================================================================================
; STACK MODULE IMPLEMENTATION
;============================================================================================
Module Stack
  ;------------------------------------------------------------------------------------------
  ; New Level
  ;------------------------------------------------------------------------------------------
  Procedure NewLevel(*stack.Stack_t,name.s,color.i)
    Protected   *Me.StackLevel_t = AllocateMemory(SizeOf(StackLevel_t))
    Object::INI(StackLevel)
    *Me\name = name
    *Me\color = color
    AddElement(*stack\levels())
    *stack\levels() = *Me
    
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Delete Level
  ;------------------------------------------------------------------------------------------
  Procedure DeleteLevel(*Me.StackLevel_t)
    Protected node.StackNode
    ForEach *Me\nodes()
      node = *Me\nodes()
      node\Delete()
    Next
    Object::TERM(StackLevel)
    
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Update Level
  ;------------------------------------------------------------------------------------------
  Procedure UpdateLevel(*level.StackLevel_t)
    Protected node.StackNode
    ForEach *level\nodes()
      node = *level\nodes()
      node\Evaluate()
    Next
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Clear Level
  ;------------------------------------------------------------------------------------------
  Procedure ClearLevel(*level.StackLevel_t)
    Protected node.StackNode
    ForEach *level\nodes()
      node = *level\nodes()
      node\Delete()
    Next
    ClearList(*level\nodes())
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Has Nodes
  ;------------------------------------------------------------------------------------------
  Procedure.b HasNodes(*Me.Stack_t)
    *Me\numNodes = 0
    ForEach *Me\levels()
        *Me\numNodes + ListSize(*Me\levels()\nodes())
    Next
    ProcedureReturn Bool(*Me\numNodes > 0)
  EndProcedure
  
  
  ;------------------------------------------------------------------------------------------
  ; Constructor
  ;------------------------------------------------------------------------------------------
  Procedure New()
    Protected *Me.Stack_t = AllocateMemory(SizeOf(Stack_t))
    Object::INI(Stack)
    NewLevel(*Me,"Modeling",RGB(255,200,200))
    NewLevel(*Me,"Shape",RGB(200,255,200))
    NewLevel(*Me,"Animation",RGB(200,200,255))
    NewLevel(*Me,"Secondary",RGB(255,255,200))
    
    ProcedureReturn *Me
  EndProcedure
  
  
  
  ;------------------------------------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------------------------------------
  Procedure Delete(*Me.Stack_t)
    ForEach *Me\levels()
      DeleteLevel(*Me\levels())
    Next
    Object::TERM(Stack)
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Update
  ;------------------------------------------------------------------------------------------
  Procedure Update(*Me.Stack_t)
    ForEach *Me\levels()
      UpdateLevel(*Me\levels())
    Next

  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Add Node
  ;------------------------------------------------------------------------------------------
  Procedure AddNode(*Me.Stack_t,node.StackNode,level.i)
    SelectElement(*Me\levels(),level)
    Protected *level.StackLevel_t = *Me\levels()
    
    AddElement(*level\nodes())
    *level\nodes() = node
  EndProcedure
  
  Procedure MoveUp(*Me.Stack_t,node.StackNode)
    
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Clear Stack
  ;------------------------------------------------------------------------------------------
  Procedure Clear(*Me.Stack_t)
    ForEach *Me\levels()
      ClearLevel(*Me\levels())
    Next
  EndProcedure
  
  Class::DEF(Stack)

EndModule


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 110
; FirstLine = 91
; Folding = ---
; EnableXP