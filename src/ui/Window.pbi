﻿XIncludeFile "../ui/Types.pbi"
XIncludeFile "../ui/View.pbi"
XIncludeFile "../ui/MenuUI.pbi"
XIncludeFile "../core/Commands.pbi"

;==========================================================================
; Window module Implementation
;==========================================================================
Module Window
  Procedure GetWindowById(id)
    ForEach *ALL_WINDOWS()
      If *ALL_WINDOWS()\ID = id
        ProcedureReturn *ALL_WINDOWS()
      EndIf
    Next
    ProcedureReturn *MAIN_WINDOW
  EndProcedure
  
  Procedure Resize(*Me.Window_t)    
    If Not *Me : ProcedureReturn : EndIf
    Protected w = WindowWidth(*Me\ID,#PB_Window_InnerCoordinate)
    Protected h = WindowHeight(*Me\ID,#PB_Window_InnerCoordinate)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If GetMenu_(WindowID(*Me\ID))
        View::Resize(*Me\main,0,0,w,h-MenuHeight())
      Else
        View::Resize(*Me\main,0,0,w,h)
      EndIf
    CompilerElse
      View::Resize(*Me\main,0,0,w,h)
    CompilerEndIf
  EndProcedure

  Procedure RecurseView(*Me.Window_t,*view.View::View_t)
    If *view\leaf
      If *view\active
        *Me\active = *view
      EndIf
    Else
      If *view\left : RecurseView(*Me,*view\left) : EndIf
      If *view\right : RecurseView(*Me,*view\right) : EndIf
    EndIf
  EndProcedure
  
  Procedure.i GetActiveView(*Me.Window_t,x.i,y.i)
    Protected *view.View::View_t = *Me\main
    View::GetActive(*view,x,y)

    ProcedureReturn RecurseView(*Me, *Me\main)
  EndProcedure
  
  Procedure Drag(*Me.Window_t)
    ;Debug "View Manager Drag View Top ID: "+Str(*Me\active\top\id)  
  EndProcedure
  
  Procedure TearOff(*Me.Window_t, x.i, y.i, width.i, height.i)
    Define options.i = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget
    Define *window.Window_t = New("Tool",x,y,width,height,options, WindowID(*Me\ID))
    ProcedureReturn *window
  EndProcedure

  Procedure OnEvent(*Me.Window_t, event.i)
    Protected x,y,w,h,i,gadgetID,state
    Protected dirty.b = #False
    Protected *view.View::View_t = #Null
    If *Me = #Null Or event = -1: ProcedureReturn: EndIf
    
    Protected mx = WindowMouseX(*Me\ID)
    Protected my = WindowMouseY(*Me\ID)
    
    Protected *old.View::View_t = *Me\active
    Protected *over.View::View_t = Pick(*Me, mx, my)
      
    Select event
      Case #PB_Event_Gadget
        
        If *Me\active And *Me\active\drag
          If EventType() = #PB_EventType_LeftButtonUp
            *Me\active\drag=False
            PostEvent(#PB_Event_SizeWindow)
          Else
            View::DragSplitter(*Me\active)
          EndIf
          ProcedureReturn
        EndIf
    
        If *over
          If View::TouchBorder(*over,mx,my,View::#VIEW_BORDER_SENSIBILITY)
            View::TouchBorderEvent(*over)
          Else
            View::OnEvent(*over,event)
          EndIf
            
          
;           If EventType() = #PB_EventType_LostFocus
;             gadgetID = EventGadget()
;             If FindMapElement(*Me\uis(), Str(gadgetID))
;               View::OnEvent(*Me\uis()\view, event)
;             EndIf
;           Else
;             If touch
;               View::EventSplitter(*over,touch)
;               Protected *affected.View::View_t = View::EventSplitter(*over,touch)
;               If *affected
;                 View::TouchBorderEvent(*affected)
;               EndIf
;             Else
;               View::ClearBorderEvent(*over)
;             EndIf
;             View::OnEvent(*over,event)
;           EndIf
        EndIf
 
      Case #PB_Event_Timer
        View::OnEvent(*Me\main,#PB_Event_Timer)
        
      Case Globals::#EVENT_TOOL_CHANGED
        View::OnEvent(*Me\main, Globals::#EVENT_TOOL_CHANGED)
        
      Case Globals::#EVENT_NEW_SCENE
        View::OnEvent(*Me\main, Globals::#EVENT_NEW_SCENE)
                
      Case Globals::#EVENT_COMMAND_CALLED
        View::OnEvent(*Me\main,Globals::#EVENT_COMMAND_CALLED)
        
      Case Globals::#EVENT_PARAMETER_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_PARAMETER_CHANGED)
        
      Case Globals::#EVENT_SELECTION_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_HIERARCHY_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_GRAPH_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_GRAPH_CHANGED)
        
      Case Globals::#EVENT_REPAINT_WINDOW
        Resize(*Me)
        
      Case #PB_Event_Repaint
        Resize(*Me)
        
      Case #PB_Event_Timer
;         Select EventTimer()
;           Case #RAA_TIMELINE_TIMER
;             ; Get Timeline View
;             If FindMapElement(*Me\views(),"Timeline")
;               Protected *timeline.CView = *Me\views()
;               *timeline\Event(#PB_Event_Timer,#Null)
;             EndIf
;             
;         EndSelect
       
      Case #PB_Event_Menu
        Debug "WE HAVE EVENT MENU : "+Str(EventMenu())
        Select EventMenu()
;           Case Globals::#SHORTCUT_COPY
;             Debug "View Manager : SHORTCUT COPY"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_CUT
;             Debug "View Manager : SHORTCUT CUT"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
;           Case Globals::#SHORTCUT_PASTE
;             Debug "View Manager : SHORTCUT PASTE"
;             View::OnEvent(*Me\active,#PB_Event_Menu)
          Case Globals::#SHORTCUT_UNDO
            Commands::Undo(Commands::*manager)
          Case Globals::#SHORTCUT_REDO
            Commands::Redo(Commands::*manager)
          Default
            View::OnEvent(*over,#PB_Event_Menu)
            
        EndSelect
        
      Case #PB_Event_SizeWindow
        Resize(*Me)
        
      Case #PB_Event_MaximizeWindow
        Resize(*Me)
      Case #PB_Event_MoveWindow
        Resize(*Me)
      Case #PB_Event_Menu
        ProcedureReturn
      Case #PB_Event_CloseWindow
        ProcedureReturn 
    EndSelect
    
    *Me\active = *over
    
  EndProcedure
  
  Procedure GetUniqueID(*Me.Window_t, *view.View::View_t)
    Protected uuid.i = Random(65535)
    If FindMapElement(*Me\uis(), Str(uuid))
      GetUniqueID(*Me, *view)
    Else
      AddMapElement(*Me\uis(), Str(uuid))
      *Me\uis() = *view\content
      ProcedureReturn uuid
    EndIf  
  EndProcedure
  
  Procedure _RecursePick(*view.View::View_t, mx.i, my.i)
    If View::PointInside(*view, mx, my)
      If *view\leaf
        ProcedureReturn *view
      Else
        If View::PointInside(*view\left, mx, my)
          ProcedureReturn _RecursePick(*view\left, mx, my)
        ElseIf View::PointInside(*view\right, mx, my)
          ProcedureReturn _RecursePick(*view\right, mx, my)
        EndIf
      EndIf  
    EndIf
    ProcedureReturn #Null
  EndProcedure
  
  Procedure Pick(*Me.Window_t, mx.i, my.i)  
    ProcedureReturn _RecursePick(*Me\main, mx, my)
  EndProcedure
  
  Procedure AddMenuItem(*Me.Window_t, name.s, event.i=-1)
    Protected *ui.MenuUI::MenuUI_t = *Me\menu
    If Not *ui : *Me\menu = MenuUI::New(*Me\main) : EndIf
    AddElement(*ui\items())
    *ui\items()\name = name
    *ui\items()\event = event
    *ui\dirty = #True
    ProcedureReturn *ui\items()
  EndProcedure
  
  Procedure AddSubMenuItem(*Me.Window_t, *menuItem.MenuUI::MenuItem_t, name.s, event.i=-1)
    Protected *ui.MenuUI::MenuUI_t = *Me\menu
    AddElement(*menuItem\items())
    *menuItem\items()\name = name
    *menuItem\items()\event = event
    *ui\dirty = #True
    ProcedureReturn *menuItem\items()
  EndProcedure

  Procedure Delete(*Me.Window_t)
    ForEach *ALL_WINDOWS()
      If *ALL_WINDOWS()\ID = *Me\ID
        DeleteElement(*ALL_WINDOWS())
        Break
      EndIf
    Next
    FreeStructure(*Me)
  EndProcedure
  
  Procedure New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget, parentID.i=0)
    Protected *Me.Window_t = AllocateStructure(Window_t)
    Object::INI(Window)
    *Me\name = name
    *Me\ID = OpenWindow(#PB_Any, x, y, width, height, *Me\name, options, parentID)  

    *Me\main = View::New(0,0,WindowWidth(*Me\ID),WindowHeight(*Me\ID),#Null,#False,name,#True)
    *Me\main\window = *Me
    *Me\active = *Me\main
    *Me\menu = #Null
    
    If Not parentID : *MAIN_WINDOW = *Me : EndIf
      
    AddElement(*ALL_WINDOWS())
    *ALL_WINDOWS() = *Me
    
    ProcedureReturn *Me
    
  EndProcedure
 
EndModule
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 79
; FirstLine = 64
; Folding = ---
; EnableXP