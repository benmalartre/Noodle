XIncludeFile "Types.pbi"
XIncludeFile "Node.pbi"
XIncludeFile "Compound.pbi"
XIncludeFile "Connexion.pbi"
XIncludeFile "Nodes.pbi"
XIncludeFile "Graph.pbi"
XIncludeFile "Tree.pbi"

DeclareModule NodeSearch
  Structure NodeSearch_t
    window.i
    input.i
    tree.i
    str.s
    *selected.Nodes::NodeDescription_t
    List *nodes.Nodes::NodeDescription_t()
  EndStructure
  
  Declare New(x.i,y.i)
  Declare Delete(*Me.NodeSearch_t)
  Declare Update(*Me.NodeSearch_t)
  Declare UpdateList(*Me.NodeSearch_t,force.b=#False)
EndDeclareModule

Module NodeSearch
  ; CONSTRUCTOR
  ; -----------------------------------------------------------------
  Procedure New(x.i,y.i)
    Protected *Me.NodeSearch_t = AllocateMemory(SizeOf(NodeSearch_t))
    InitializeStructure(*Me,NodeSearch_t)
    *Me\window = OpenWindow(#PB_Any,x,y,800,100,"Node Search",#PB_Window_BorderLess)
    SetWindowColor(*Me\window,UIColor::COLOR_MAIN_BG)
    *Me\input = StringGadget(#PB_Any,0,0,WindowWidth(*Me\window),30,"")
    SetGadgetColor(*Me\input,#PB_Gadget_BackColor,UIColor::COLOR_MAIN_BG)
    *Me\tree = ListViewGadget(#PB_Any,0,30,WindowWidth(*Me\window),WindowHeight(*Me\window)-30)
    SetGadgetColor(*Me\tree,#PB_Gadget_BackColor,UIColor::COLOR_MAIN_BG)
    AddKeyboardShortcut(*Me\window,#PB_Shortcut_Escape,Globals::#SHORTCUT_QUIT)
    AddKeyboardShortcut(*Me\window,#PB_Shortcut_Return,Globals::#SHORTCUT_ENTER)
    AddKeyboardShortcut(*Me\window,#PB_Shortcut_Up,Globals::#SHORTCUT_UP)
    AddKeyboardShortcut(*Me\window,#PB_Shortcut_Down,Globals::#SHORTCUT_DOWN)
    UpdateList(*Me,#True)
    SetActiveGadget(*Me\input)
    ProcedureReturn *Me
  EndProcedure
  
  ; DESTRUCTOR
  ; -----------------------------------------------------------------
  Procedure Delete(*Me.NodeSearch_t)
    FreeGadget(*Me\tree)
    FreeGadget(*Me\input)
    CloseWindow(*Me\window)
    ClearStructure(*Me,NodeSearch_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; UPDATE LIST
  ; -----------------------------------------------------------------
  Procedure UpdateList(*Me.NodeSearch_t,force.b=#False)
    Protected s.s = GetGadgetText(*Me\input)
    Protected w = WindowWidth(*Me\window)
    Protected h = 24
    If Not *Me\str = s Or force

      ClearGadgetItems(*Me\tree)
      If ListSize(*Me\nodes()) : ClearList(*Me\nodes()) : h+5 : EndIf
      If s=""
        ForEach Nodes::*graph_nodes()
          AddGadgetItem(*Me\tree,-1,Nodes::*graph_nodes()\name)
          AddElement(*Me\nodes())
          *Me\nodes() = Nodes::*graph_nodes()
          h+15
        Next
      Else
        
        ForEach Nodes::*graph_nodes()
          If FindString(LCase(Nodes::*graph_nodes()\name),LCase(s),0)
            AddGadgetItem(*Me\tree,-1,Nodes::*graph_nodes()\name)
            AddElement(*Me\nodes())
            *Me\nodes() = Nodes::*graph_nodes()
            h+15
          EndIf
        Next
      EndIf
      
      *Me\str = s
      ResizeWindow(*Me\window,#PB_Ignore,#PB_Ignore,#PB_Ignore,h)
      ResizeGadget(*Me\tree,0,24,WindowWidth(*Me\window, #PB_Window_InnerCoordinate), h-24)
    EndIf
  EndProcedure
    
  
  ; UPDATE
  ; -----------------------------------------------------------------
  Procedure Update(*Me.NodeSearch_t)
    Protected event.i
    Protected quit.b=#False
    Protected state
    Repeat
      
      event = WaitWindowEvent()

      Select event
        Case #PB_Event_Menu
          Select EventMenu()
            Case Globals::#SHORTCUT_ENTER
              state = GetGadgetState(*Me\tree)
              If state>-1
                SelectElement(*Me\nodes(),state)
                *Me\selected = *Me\nodes()
              EndIf
              
              quit = #True
            Case Globals::#SHORTCUT_QUIT
              state = GetGadgetState(*Me\tree)
              If state>-1
                SelectElement(*Me\nodes(),state)
                *Me\selected = *Me\nodes()
              EndIf
              
              quit = #True
              
            Case Globals::#SHORTCUT_UP
              state = GetGadgetState(*Me\tree)
              If state > 0
                SetGadgetState(*Me\tree, state-1)
              EndIf

            Case Globals::#SHORTCUT_DOWN
               state = GetGadgetState(*Me\tree)
              If state < CountGadgetItems(*Me\tree)-1
                SetGadgetState(*Me\tree, state+1)
              EndIf
              
          EndSelect
          
        Case #PB_Event_Gadget
          Select EventGadget()
            Case *Me\tree
              Select EventType()
                Case #PB_EventType_LeftDoubleClick
                  state = GetGadgetState(*Me\tree)
                  If state>-1
                    SelectElement(*Me\nodes(),state)
                    *Me\selected = *Me\nodes()
                  EndIf
                  quit = #True
                  
              EndSelect

            Case *Me\input
              UpdateList(*Me)
              
            Default
              Select EventType()
                Case #PB_EventType_LeftClick
                  If EventWindow() <> *Me\window
                    quit = #True
                  EndIf
              EndSelect
              
          EndSelect
          
              
          
              
      EndSelect
    Until quit = #True
    
    HideWindow(*Me\window,#True)
   
    
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 80
; FirstLine = 68
; Folding = --
; EnableXP
; EnableUnicode