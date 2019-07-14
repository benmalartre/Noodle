XIncludeFile "../ui/Types.pbi"
XIncludeFile "../ui/View.pbi"

;==========================================================================
; Window module Implementation
;==========================================================================
Module Window
  
  Procedure Resize(*Me.Window_t)    
    If Not *Me : ProcedureReturn : EndIf
    Protected w = WindowWidth(*Me\ID,#PB_Window_InnerCoordinate)
    Protected h = WindowHeight(*Me\ID,#PB_Window_InnerCoordinate)

    View::Resize(*Me\main,0,0,w,h)
    DrawPickImage(*Me)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Recurse View
  ;----------------------------------------------------------------------------------
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
  
  ;----------------------------------------------------------------------------------
  ; Get Active View
  ;----------------------------------------------------------------------------------
  Procedure.i GetActiveView(*Me.Window_t,x.i,y.i)
    Protected *view.View::View_t = *Me\main
    View::GetActive(*view,x,y)

    ProcedureReturn RecurseView(*Me, *Me\main)
  EndProcedure
  
  ;----------------------------------------------------------------------------------
  ; Drag
  ;----------------------------------------------------------------------------------
  Procedure Drag(*Me.Window_t)
    ;Debug "View Manager Drag View Top ID: "+Str(*Me\active\top\id)  
  EndProcedure
  
  Procedure TearOff(*Me.Window_t, x.i, y.i, width.i, height.i)
    Define options.i = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget
    Define *window.Window_t = New("Tool",x,y,width,height,options, WindowID(*Me\ID))
    ProcedureReturn *window
  EndProcedure
  
  
;   ;----------------------------------------------------------------------------------
;   ; Set Map Element
;   ;----------------------------------------------------------------------------------
;   Procedure SetMapElement(*Me.Window_t,*view.View::View_t)
;     If *view\leaf And *view\content
;       Protected name.s = *view\content\name
;       ; Check if already in map
;       AddMapElement(*Me\views(),name)
;       *Me\views() = *view\content
;       Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD VIEW MAP ELEMENT : "+name
;     Else
;       SetMapElement(*Me,*view\left)
;       SetMapElement(*Me,*view\right)
;     EndIf
;     
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Update Map
;   ;----------------------------------------------------------------------------------
;   Procedure UpdateMap(*Me.Window_t)
;     ClearMap(*Me\views())
;     SetMapElement(*Me,*Me\main)
;   EndProcedure

  
  ;----------------------------------------------------------------------------------
  ; Event
  ;----------------------------------------------------------------------------------
  Procedure OnEvent(*Me.Window_t,event.i)
    Protected x,y,w,h,i,gadgetID,state
    Protected dirty.b = #False
    Protected *view.View::View_t = #Null
    If *Me = #Null Or event = -1: ProcedureReturn: EndIf
    
    Protected mx = WindowMouseX(*Me\ID)
    Protected my = WindowMouseY(*Me\ID)
    
    Protected *old.View::View_t = *Me\active
    Protected *over.View::View_t = Pick(*Me, mx, my)
    If *old And *old <> *over
      If *old\content And IsGadget(*old\content\gadgetID)
        PostEvent(#PB_Event_Gadget, *Me\ID, *old\content\gadgetID, #PB_EventType_LostFocus)
      EndIf
      ;View::OnEvent(*old, #PB_EventType_LostFocus)
    EndIf
    
    Select event
      Case #PB_Event_Gadget

        If *over
          Protected touch = View::TouchBorder(*over,mx,my,View::#VIEW_BORDER_SENSIBILITY)
          If EventType() = #PB_EventType_LostFocus
            gadgetID = EventGadget()
            If FindMapElement(*Me\uis(), Str(gadgetID))
              View::OnEvent(*Me\uis()\parent, event)
            EndIf
          Else
            If touch
              View::EventSplitter(*over,touch)
              Protected *affected.View::View_t = View::EventSplitter(*over,touch)
              If *affected
                View::TouchBorderEvent(*affected)
              EndIf
            Else
              View::ClearBorderEvent(*over)
            EndIf
            View::OnEvent(*over,event)
          EndIf
        EndIf
          
      Case #PB_Event_Timer
        Scene::Update(Scene::*current_scene)
        View::OnEvent(*Me\main,#PB_Event_Timer)
        
      Case Globals::#EVENT_NEW_SCENE
        View::OnEvent(*Me\main, Globals::#EVENT_NEW_SCENE)
        
      Case Globals::#EVENT_BUTTON_PRESSED
        
      Case Globals::#EVENT_COMMAND_CALLED
        View::OnEvent(*Me\main,Globals::#EVENT_COMMAND_CALLED)
      Case Globals::#EVENT_PARAMETER_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_PARAMETER_CHANGED)
        Scene::Update(Scene::*current_scene)
      Case Globals::#EVENT_SELECTION_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_HIERARCHY_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_SELECTION_CHANGED)
        
      Case Globals::#EVENT_GRAPH_CHANGED
        View::OnEvent(*Me\main,Globals::#EVENT_GRAPH_CHANGED)
         Scene::Update(Scene::*current_scene)
      Case #PB_Event_Repaint
        View::OnEvent(*Me\main,#PB_Event_Repaint)
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
            MessageRequester("View Manager","Undo Called")
            Commands::Undo(Commands::*manager)
          Case Globals::#SHORTCUT_REDO
            MessageRequester("View Manager","Redo Called")
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
  
  ;----------------------------------------------------------------------------------
  ; Get Unique ID
  ;----------------------------------------------------------------------------------
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
  
  ;----------------------------------------------------------------------------------
  ; Recurse Draw View
  ;----------------------------------------------------------------------------------
  Procedure RecurseDrawPickImage(*Me.Window_t,*view.View::View_t)
    If *view\leaf And *view\content
      Define uuid.i = GetUniqueID(*Me, *view)
      DrawingMode(#PB_2DDrawing_Default)
      Box(*view\x-View::#VIEW_BORDER_SENSIBILITY*0.5,
          *view\y-View::#VIEW_BORDER_SENSIBILITY*0.5,
          *view\width+View::#VIEW_BORDER_SENSIBILITY,
          *view\height+View::#VIEW_BORDER_SENSIBILITY, uuid)
    Else
      If *view\left : RecurseDrawPickImage(*Me,*view\left) : EndIf
      If *view\right : RecurseDrawPickImage(*Me,*view\right) : EndIf
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Draw Pick Image
  ; ----------------------------------------------------------------------------------
  Procedure DrawPickImage(*Me.Window_t)
    ClearMap(*Me\uis())
    ResizeImage(*Me\imageID, *Me\main\width, *Me\main\height)
    StartDrawing(ImageOutput(*Me\imageID))
    RecurseDrawPickImage(*Me,*Me\main)
    StopDrawing()
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Draw Over Pick Image (DEV)
  ; ----------------------------------------------------------------------------------
  Procedure Draw(*Me.Window_t)
    StartDrawing(WindowOutput(*Me\ID))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(*Me\imageID),0,0)
    If *Me\active
      DrawingMode(#PB_2DDrawing_Default)
      Box(*Me\active\x, *Me\active\y, *Me\active\width, *Me\active\height, RGBA(255,255,255,128))
    EndIf
    StopDrawing()
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Pick Active View
  ; ----------------------------------------------------------------------------------
  Procedure Pick(*Me.Window_t, mx.i, my.i)
    Protected picked.i
    StartDrawing(ImageOutput(*Me\imageID))
    DrawingMode(#PB_2DDrawing_Default)
    If mx>=0 And mx<ImageWidth(*Me\imageID) And my>=0 And my<ImageHeight(*Me\imageID)
      picked = Point(mx, my)
      If FindMapElement(*Me\uis(), Str(picked))
        StopDrawing()
        ProcedureReturn *Me\uis()\parent
      EndIf
    EndIf
    StopDrawing()
    ProcedureReturn #Null
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Constructor
  ; ----------------------------------------------------------------------------------

  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*e.Window_t)
    FreeMemory(*e)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------
  ; Constructor
  ; ----------------------------------------------------------------------------------
  Procedure New(name.s,x.i,y.i,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget, parentID.i=0)
    Protected *Me.Window_t = AllocateMemory(SizeOf(Window_t))
    
    InitializeStructure(*Me,Window_t)
  
    *Me\name = name
    *Me\ID = OpenWindow(#PB_Any, 0, 0, width, height, *Me\name, options, parentID)  
    EnableWindowDrop(*Me\ID,#PB_Drop_Private,#PB_Drag_Move,View::#VIEW_SPLITTER_DROP)
    *Me\main = View::New(x.i,y.i,WindowWidth(*Me\ID),WindowHeight(*Me\ID),#Null,#False,name,#True)
    *Me\main\window = *Me
    *Me\active = *Me\main
    *Me\imageID = CreateImage(#PB_Any, width, height, 32)

    *view_manager = *Me
    
    ProcedureReturn *Me
    
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 2
; Folding = ---
; EnableXP