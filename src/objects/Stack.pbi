
XIncludeFile "../graph/Node.pbi"
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
  
  Structure StackLevel_t Extends Object::Object_t 
    name.s
    color.i
    List *nodes.Node::Node_t()
  EndStructure
  
  Structure Stack_t Extends Object::Object_t 
    List *levels.StackLevel_t()
  EndStructure
  
  Declare New()
  Declare Delete(*stack.Stack_t)
  Declare NewLevel(*stack.Stack_t,name.s,color.i)
  Declare DeleteLevel(*stack.Stack_t,*level.StackLevel_t)
  Declare Update(*stack.Stack_t)
  Declare UpdateLevel(*level.StackLevel_t)
  Declare AddNode(*stack.Stack_t,*node.Node::Node_t,level.i)
  Declare Clear(*stack.Stack_t)
  Declare ClearLevel(*level.StackLevel_t)
  
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
    InitializeStructure(*Me,StackLevel_t)
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
  Procedure DeleteLevel(*stack.Stack_t,*level.StackLevel_t)
    Protected node.Node::Inode
    ForEach *level\nodes()
      node = *level\nodes()
      node\Delete()
    Next
    DeleteElement(*stack\levels())
    ClearStructure(*level,StackLevel_t)
    FreeMemory(*level)
    
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Update Level
  ;------------------------------------------------------------------------------------------
  Procedure UpdateLevel(*level.StackLevel_t)
    Protected inode.Node::INode
    Protected *node.Node::Node_t
    ForEach *level\nodes()
      *node = *level\nodes()
      inode = *node

      inode\Evaluate()
    Next
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Clear Level
  ;------------------------------------------------------------------------------------------
  Procedure ClearLevel(*level.StackLevel_t)
    Protected inode.Node::INode
    Protected *node.Node::Node_t
    ForEach *level\nodes()
      *node = *level\nodes()
      inode = *node
      inode\Delete()
    Next
  EndProcedure
  
  
  ;------------------------------------------------------------------------------------------
  ; Constructor
  ;------------------------------------------------------------------------------------------
  Procedure New()
    
    Protected *Me.Stack_t = AllocateMemory(SizeOf(Stack_t))
    InitializeStructure(*Me,Stack_t)
    NewLevel(*Me,"Modeling",RGB(255,200,200))
    NewLevel(*Me,"Shape",RGB(200,255,200))
    NewLevel(*Me,"Animation",RGB(200,200,255))
    NewLevel(*Me,"Secondary",RGB(255,255,200))
    Object::INI(Stack)
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------------------------------------
  Procedure Delete(*stack.Stack_t)
    
    ForEach *stack\levels()
      DeleteLevel(*stack,*stack\levels())
    Next
    
    ClearStructure(*stack,Stack_t)
    FreeMemory(*stack)
  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Update
  ;------------------------------------------------------------------------------------------
  Procedure Update(*stack.Stack_t)
    ForEach *stack\levels()
      UpdateLevel(*stack\levels())
    Next

  EndProcedure
  
  ;------------------------------------------------------------------------------------------
  ; Add Node
  ;------------------------------------------------------------------------------------------
  Procedure AddNode(*stack.Stack_t,*node.Node::Node_t,level.i)
    SelectElement(*stack\levels(),level)
    Protected *level.StackLevel_t = *stack\levels()
    
    AddElement(*level\nodes())
    *level\nodes() = *node
  EndProcedure
  
  Procedure MoveUp(*stack.Stack_t,*node.Node::Node_t)
    
  EndProcedure
  
  
  Procedure Clear(*stack.Stack_t)
    ForEach *stack\levels()
      ClearLevel(*stack\levels())
    Next
    
    
    ClearList(*stack\levels())
  EndProcedure
  
  Class::DEF(Stack)

EndModule


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 149
; FirstLine = 99
; Folding = ---
; EnableXP