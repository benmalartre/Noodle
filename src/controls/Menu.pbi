XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../ui/View.pbi"
XIncludeFile "../ui/Window.pbi"
; ============================================================================
;  CONTROL MENU MODULE DECLARATION
; ============================================================================
DeclareModule ControlMenu
  ; ==========================================================================
  ;  Globals
  ; ==========================================================================
  
  #MenuItemHeight = 16
  #MenuItemFontSize = 8
  #MenuItemSpacing = 7
  
  Enumeration
    #MenuItemType_Command
    #MenuItemType_Callback
    #MenuItemType_Menu
    #MenuItemType_Separator
  EndEnumeration


  ; ==========================================================================
  ;  Prototypes
  ; ==========================================================================
  Prototype.i MenuItemCallback(*args.Arguments::Arguments_t)


  ; ============================================================================
  ;  CLASS ( ControlMenuItem_t )
  ; ============================================================================
  Structure ControlMenuItem_t
    type.i
    callback.MenuItemCallback
    *args.Arguments::Arguments_t
    name.s
    gadgetID.i
    item.i
    *menu
  EndStructure
  
  ; ============================================================================
  ;  CLASS ( CControlSubMenu )
  ; ============================================================================
  Structure ControlSubMenu_t Extends Control::Control_t
    label.s
    Array *items.ControlMenuItem_t(0)
    selected.i
    last.i
    close.b
    dirty.b
    inspected.b
    imageID.i
    windowID.i
    *window.Window::Window_t
  EndStructure

  ; ============================================================================
  ;  CLASS ( CControlMenu_t )
  ; ============================================================================
  Structure ControlMenu_t Extends Control::Control_t
    windowID.i
    imageID.i
    last.i       ; last inspected submenu id
    dirty.b       ; menu should redraw
    
    *inspected.ControlSubMenu_t                     ; currently inspected submenu
    Array *submenus.ControlSubMenu_t(0)
     *window.Window::Window_t
  EndStructure
  
  Declare New(*parent.Control::Control_t,x.i,y.i,width.i,height.i)
  Declare Delete(*menu.ControlMenu_t)
  Declare Init(*menu.ControlMenu_t,name.s)
  Declare NewSubMenu(*menu.ControlMenu_t,x.i,y.i,name.s)
  Declare DeleteSubMenu(*menu.ControlSubMenu_t)
  Declare AddItem(*menu.ControlSubMenu_t,name.s,callback.i,*args.Arguments::Arguments_t)
  Declare AddSeparator(*menu.ControlSubMenu_t)
  Declare AddSubMenu(*menu.ControlSubMenu_t,name.s)
  Declare GetSubMenuWidth(*menu.ControlSubMenu_t)
  Declare EventSubMenu(*menu.ControlSubMenu_t)
  Declare SetWindowID(*menu.ControlMenu_t,windowID.i)
  Declare.b DrawSubMenu(*menu.ControlSubMenu_t,down.b)
  Declare.b PickSubMenu(*menu.ControlSubMenu_t,down.b)
  Declare EventSubMenu(*menu.ControlSubMenu_t)
  Declare InspectSubMenu(*menu.ControlSubMenu_t)
  Declare InitSubMenu(*menu.ControlSubMenu_t,*parent.ControlMenu_t=#Null)
  
  Declare Add(*menu.ControlMenu_t,name.s)
  Declare GetGadgetID(*menu.ControlMenu_t)
  Declare Pick(*menu.ControlMenu_t)
  Declare Draw(*menu.ControlMenu_t)
  Declare DrawPickImage(*menu.ControlMenu_t)
  Declare OnEvent(*menu.ControlMenu_t,eventID.i)
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlMenu )
  ; ============================================================================
  DataSection
    ControlMenuVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
  EndDataSection
  
  DataSection
    ControlSubMenuVT:
  EndDataSection
  
  Global CLASS.Class::Class_t
  
  
EndDeclareModule



; ============================================================================
;  IMPLEMENTATION ( CControlMenu )
; ============================================================================

Module ControlMenu
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure New(*parent.Control::Control_t,x.i,y.i,width.i,height.i)
    Protected *Me.ControlMenu_t = AllocateStructure(ControlMenu_t)
    Object::INI(ControlMenu)
    Protected *view.View::View_t = *parent\parent
    Protected *window.Window::Window_t = *view\window
    *Me\gadgetID = *parent\gadgetID
    *Me\parent = *parent
    *Me\windowID = *window\ID
    *Me\imageID = CreateImage(#PB_Any,width,height)
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width+1
    *Me\sizY = height+1
    *Me\percX = 100
    *Me\percY = 100
    *Me\last = -1
    *Me\dirty = #True
    
    
    ProcedureReturn *Me
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure Delete(*Me.ControlMenu_t)
    FreeGadget(*Me\gadgetID)
    FreeImage(*Me\imageID)
    Object::TERM(ControlMenu)
  EndProcedure
  
  ; ==========================================================================
  ;  CONSTRUCTOR
  ; ==========================================================================
  Procedure NewSubMenu(*parent.ControlMenu_t,x.i,y.i,name.s)
    Protected *Me.ControlSubMenu_t = AllocateStructure(ControlSubMenu_t)
    Object::INI(ControlSubMenu)
  
    *Me\selected = -1
    *Me\last = -1
    
    If *parent<>#Null
      *Me\windowID = *parent\windowID
      *Me\parent = *parent
      *Me\gadgetID = *parent\gadgetID
    Else
      *Me\windowID = 0
      *Me\parent = #Null
      *Me\gadgetID = #Null
    EndIf
    
    *Me\imageID = CreateImage(#PB_Any,32,32)
  
    *Me\close = #False
    *Me\name = name
    *Me\dirty = #True
    *Me\posX = x
    *Me\posY = y
    
    ; ---[ Init 'OnChanged' Slot ]----------------------------------------------
    ;*Me\sig_onchanged = newCSlot( *Me )
    
    If *parent<>#Null
      ReDim *parent\submenus(ArraySize(*parent\submenus())+1)
      *parent\submenus(ArraySize(*parent\submenus())-1) = *Me
    EndIf
   
    ProcedureReturn *Me
  EndProcedure
  
  ; ==========================================================================
  ;  DESTRUCTOR
  ; ==========================================================================
  Procedure DeleteSubMenu(*Me.ControlSubMenu_t)
    FreeImage(*Me\imageID)
    Object::TERM(ControlSubMenu)
    
  EndProcedure
  
  Procedure Callback1()
    Debug "Callback1 Called..."  
  EndProcedure
  
  Procedure Callback2()
    Debug "Callback2 Called..."  
  EndProcedure
  
  Procedure Callback3()
    Debug "Callback3 Called..."  
  EndProcedure
  
  Procedure Callback4()
    Debug "Callback4 Called..."  
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  Add Item
  ; ----------------------------------------------------------------------------
  
  Procedure AddItem(*menu.ControlSubMenu_t,name.s,callback.i,*args.Arguments::Arguments_t)
    Protected *item.ControlMenuItem_t = AllocateStructure(ControlMenuItem_t)
    *item\name = name
    *item\callback = callback
    *item\args = Arguments::New(ArraySize(*args\args()))
    If Not *args = #Null
      Arguments::Copy(*item\args,*args)
    EndIf
    
    *item\type = #MenuItemType_Command
    
    ReDim *menu\items(ArraySize(*menu\items())+1)
  
    *menu\items(ArraySize(*menu\items())-1) = *item
   
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Add Separator
  ; ----------------------------------------------------------------------------
  Procedure AddSeparator(*menu.ControlSubMenu_t)
    Protected *item.ControlMenuItem_t = AllocateStructure(ControlMenuItem_t)
    *item\name = "Separator"
    *item\callback = 0
    *item\type = #MenuItemType_Separator
    
    ReDim *menu\items(ArraySize(*menu\items())+1)
  
    *menu\items(ArraySize(*menu\items())-1) = *item
  EndProcedure
  


  ; ----------------------------------------------------------------------------
  ;  Get Width
  ; ----------------------------------------------------------------------------
  Procedure.i  GetSubMenuWidth(*menu.ControlSubMenu_t)
    *menu\sizX.i = -1
  
    StartDrawing(ImageOutput(*menu\imageID))
    Protected a
    For a=0 To ArraySize(*menu\items())-1
      
      Protected width = TextWidth(*menu\items(a)\name)+#MenuItemSpacing
      If  *menu\sizX< width
        *menu\sizX = width
      EndIf  
    Next a
    StopDrawing()
  
  EndProcedure


  ; ----------------------------------------------------------------------------
  ;  Set Window ID
  ; ----------------------------------------------------------------------------
  Procedure SetWindowID(*menu.ControlMenu_t,windowID.i)
  
   *menu\windowID = windowID
  EndProcedure


  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure.b DrawSubMenu(*menu.ControlSubMenu_t,down.b)
    
    Protected i
    StartVectorDrawing(CanvasVectorOutput(*menu\gadgetID))
    AddPathBox(0,0,*menu\sizX,*menu\sizY)
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath()
    
    VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_MENU)
    Protected a
    For a=0 To ArraySize(*menu\items())-1
      If *menu\items(a)\type = #MenuItemType_Separator
        MovePathCursor(10,a*#MenuItemHeight+0.5*#MenuItemHeight)
        AddPathLine(*menu\sizX-20,0, #PB_Path_Relative)
        VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
        StrokePath(2)
      Else
        
        If a = *menu\selected
          Vector::RoundBoxPath(0,a*#MenuItemHeight,*menu\sizX,#MenuItemHeight,2)
          VectorSourceColor(UIColor::COLOR_SELECTED_BG)
          FillPath()
          MovePathCursor(5,a*#MenuItemHeight)
          VectorSourceColor(UIColor::COLOR_SELECTED_FG)
          DrawVectorText(*menu\items(a)\name)
        Else
          MovePathCursor(5,a*#MenuItemHeight)
          VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
          DrawVectorText(*menu\items(a)\name)
        EndIf
      EndIf   
    
    Next a
  
    StopVectorDrawing()
    *menu\dirty = #False
  
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Select
  ; ----------------------------------------------------------------------------
  Procedure.b PickSubMenu(*menu.ControlSubMenu_t,down.b)
    
    Protected y = WindowMouseY(*menu\windowID)
    Protected id = y/#MenuItemHeight
  
    If id<0 Or id > (ArraySize(*menu\items())-1)
      *menu\selected = -1
      ProcedureReturn #True
    EndIf
    
    If down.b
      If Not *menu\items(id)\type = #MenuItemType_Separator 
        If *menu\items(id)\callback
          Protected *view = *menu\items(id)\args\args(0)\p
          
         *menu\items(id)\callback(*menu\items(id)\args)
        EndIf
        
        *menu\close = #True
        *menu\selected = -1
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    *menu\selected = id
    If Not *menu\last = *menu\selected
      *menu\last = *menu\selected
      *menu\dirty = #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Event
  ; ----------------------------------------------------------------------------
  Procedure EventSubMenu(*menu.ControlSubMenu_t)
    Protected quit.b = #False
    Protected e
  
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Inspect
  ; ----------------------------------------------------------------------------
  Procedure InspectSubMenu(*menu.ControlSubMenu_t)
    Protected event.i
    Protected mx, my
    Protected down = #False
    Protected init = #False
    Protected leftbutton.b
    *menu\close = #False
    *menu\windowID = OpenWindow(#PB_Any,*menu\posX,*menu\posY+25,*menu\sizX,*menu\sizY,"Menu",#PB_Window_BorderLess)
    StickyWindow(*menu\windowID,#True)
    *menu\gadgetID = CanvasGadget(#PB_Any,0,0,*menu\sizX,*menu\sizY)
    DrawSubMenu(*menu,#False)
    
    Protected debounce.i = 60
    Protected dt.i
    Repeat
      event = WaitWindowEvent()
      If EventWindow() = *menu\windowID
        mx = WindowMouseX(*menu\windowID)
        my = WindowMouseY(*menu\windowID) 
       
        leftbutton = Bool(event = #PB_Event_Gadget And EventType()=#PB_EventType_LeftClick); Or EventType() = #PB_EventType_LostFocus )
    
        If init = #True And PickSubMenu(*menu, leftbutton)
          *menu\dirty = #True
          *menu\selected = -1
          *menu\close = #True
        EndIf
        
        If *menu\dirty
          DrawSubMenu(*menu,#True)
        EndIf
        
        init = #True
      
      
      Else
        If dt>debounce And EventType() = #PB_EventType_LeftClick 
          *menu\close = #True
        EndIf
      EndIf
      dt+1
    Until *menu\close = #True
    
    FreeGadget(*menu\gadgetID)
    CloseWindow(*menu\windowID)
    
    *menu\dirty = #True
    *menu\selected = -1
  
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure InitSubMenu(*menu.ControlSubMenu_t,*parent.ControlMenu_t=#Null)
    *menu\sizY = ArraySize(*menu\items())*#MenuItemHeight
    
    GetSubMenuWidth(*menu)
    
    If *parent<>#Null
      *menu\posX = WindowX(*parent\windowID,#PB_Window_InnerCoordinate)+WindowMouseX(*parent\windowID);*parent\x+GadgetX(*parent\parentID)+*parent\width
      *menu\posY = WindowY(*parent\windowID,#PB_Window_InnerCoordinate)+WindowMouseY(*parent\windowID);*parent\y+GadgetY(*parent\parentID)
    Else
  ;     Debug "--------------------------------------- NO PARENt -------------------------------------------------"
  ;     ExamineDesktops()
  ;     *menu\x = DesktopMouseX()
  ;     *menu\y = DesktopMouseY()
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Add Sub Menu
  ; ----------------------------------------------------------------------------
  Procedure AddSubMenu(*menu.ControlSubMenu_t,name.s)
    Protected *item.ControlSubMenu_t = AllocateStructure(ControlSubMenu_t)
    *item\name = name
    *item\type = #MenuItemType_Menu
    *item\parent = *menu
    
    ReDim *menu\items(ArraySize(*menu\items())+1)
  
    *menu\items(ArraySize(*menu\items())-1) = *item
    
  EndProcedure


  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlMenu )
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  Add Sub Menu
  ; ----------------------------------------------------------------------------
  Procedure Add(*menu.ControlMenu_t,name.s)
    Protected *submenu.ControlSubMenu_t = NewSubMenu(*menu,*menu\posX,*menu\posY+*menu\sizY+30,name)
    ProcedureReturn *submenu
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Get Gadget ID
  ; ----------------------------------------------------------------------------
  Procedure GetGadgetID(*menu.ControlMenu_t)
    ProcedureReturn *menu\gadgetID
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Pick
  ; ----------------------------------------------------------------------------
  Procedure Pick(*menu.ControlMenu_t)
    Protected x,y, color
    x = GetGadgetAttribute(*menu\gadgetID,#PB_Canvas_MouseX)
    y = GetGadgetAttribute(*menu\gadgetID,#PB_Canvas_MouseY)
    
    ; Exit if outside drawing area
    If x<0 Or x> ImageWidth(*menu\imageID)-1 Or y<0 Or y>ImageHeight(*menu\imageID)-1
      *menu\inspected = #Null
      *menu\dirty = #True
      *menu\last = -1
  
      ProcedureReturn
    EndIf
  
    ; Get Color ID under mouse position
    StartDrawing(ImageOutput(*menu\imageID))
    color = Point(x,y)
    StopDrawing()
    
    ;ID is stored in Red Channel
    Protected id = Red(color)-1
    
    ; Exit if ID invalid
    If id = -1 Or id>ArraySize(*menu\submenus())-1
      *menu\inspected = #Null
      *menu\dirty = #True
      *menu\last = -1
      ProcedureReturn
    EndIf
    
    If *menu\last <>id
      *menu\inspected = *menu\submenus(id)
      *menu\last = id
      *menu\dirty = #True
    EndIf
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw(*menu.ControlMenu_t)
    Debug "Menu Control DRAW : ("+Str(*menu\sizX)+","+Str(*menu\sizY)+")"
    If *menu\dirty
      StartVectorDrawing(CanvasVectorOutput(*menu\gadgetID))
      VectorFont(FontID(Globals::#FONT_BOLD), Globals::#FONT_SIZE_MENU)
      
      
      AddPathBox(0,0,*menu\sizX,*menu\sizY)
      VectorSourceColor(UIColor::COLOR_MAIN_BG)
      FillPath()
      Protected x,y, a
      
      x = #MenuItemSpacing
      y = #MenuItemSpacing/2
      
      For a=0 To ArraySize(*menu\submenus())-1
        If *menu\inspected = *menu\submenus(a)
          Protected width.i = VectorTextWidth(*menu\submenus(a)\name)+#MenuItemSpacing
          Vector::RoundBoxPath(x-#MenuItemSpacing/2,0,width,GadgetHeight(*menu\gadgetID),2)
          VectorSourceColor(UIColor::COLOR_NUMBER_BG)
          FillPath(#PB_Path_Preserve)
          VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
          StrokePath(2)
          
          MovePathCursor(x, y)
          VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
          DrawVectorText(*menu\submenus(a)\name)
     
        Else
          MovePathCursor(x, y)
          VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
          DrawVectorText(*menu\submenus(a)\name)
        EndIf
        
        With *menu\submenus(a)
          \sizY =ArraySize( \items())*#MenuItemHeight
         
          \posX = x + WindowX(*menu\windowID,#PB_Window_InnerCoordinate) - #MenuItemSpacing/2+GadgetX(*menu\parent\gadgetID)
          \posY = WindowY(*menu\windowID)+GadgetHeight(*menu\gadgetID)+GadgetY(*menu\parent\gadgetID)
        EndWith
        x+#MenuItemSpacing+VectorTextWidth(*menu\submenus(a)\name)
      Next a
      
      ;DrawAlphaImage(ImageID(*menu\imageID),0,0,200)
    
      StopVectorDrawing()
      *menu\dirty = #False
    EndIf

  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure DrawPickImage(*menu.ControlMenu_t)
  
    StartVectorDrawing(ImageVectorOutput(*menu\imageID))
    VectorFont(FontID(Globals::#FONT_BOLD), Globals::#FONT_SIZE_MENU)
    AddPathBox(*menu\posX,*menu\posY,*menu\sizX,*menu\sizY)
    VectorSourceColor(RGBA(0,0,0,255))
    FillPath()
    
    Protected x,y, a,width,height
    
    x = #MenuItemSpacing/2
    y = 0
    height = GadgetHeight(*menu\gadgetID)
    For a=0 To ArraySize(*menu\submenus())-1
      width = VectorTextWidth(*menu\submenus(a)\name)+#MenuItemSpacing
      AddPathBox(x,y,width,height)
      VectorSourceColor(RGBA(a+1,0,0,255))
      FillPath()
      x+width
    Next a
    
    StopDrawing()
    
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Event
  ; ----------------------------------------------------------------------------
  Procedure OnEvent(*Me.ControlMenu_t,eventID.i)
    If eventID = #PB_Event_SizeWindow Or eventID = #PB_EventType_Resize
      *Me\dirty = #True
      Draw(*Me)
    Else
      Pick(*Me)
      Draw(*Me)
      
      If *Me\inspected<>#Null And EventType() = #PB_EventType_LeftClick
        InspectSubMenu(*Me\inspected)
        *Me\inspected = #Null
        *Me\dirty = #True
        *Me\last = -1
      EndIf
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Connect Signals Slot
  ; ----------------------------------------------------------------------------
  Procedure ConnectSignalsSlots(*menu.ControlMenu_t)
  ;   Protected menu.CControlMenu = *menu
  ;   Protected nb = ArraySize(*menu\submenus())
  ;   Protected i
  ;   Protected *submenu.CControlSubMenu
  ;   For i=0 To nb-1
  ;     *submenu = *menu\submenus(i)
  ; ;     menu\SignalConnect(*submenu\SignalOnChanged(),i)
  ;   Next i
  ;   
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  On Message
  ; ----------------------------------------------------------------------------
  Procedure OnMessage( id.i, *up)
  ;   Protected *sig.CSignal_t = *up
  ;   Protected  menu.CControlMenu = *sig\rcv_inst
  ;   Protected sig.CSlot = menu\SignalOnChanged()
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure Init(*menu.ControlMenu_t,name.s)
    Protected nbm = ArraySize(*menu\submenus())
    Protected i
    For i=0 To nbm-1
      *submenu = *menu\submenus(i)
      InitSubMenu(*submenu)
    Next i
    
    ConnectSignalsSlots(*menu)
    Draw(*menu)
    DrawPickImage(*menu)  
  EndProcedure

EndModule

  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 301
; FirstLine = 293
; Folding = -w---
; EnableThread
; EnableXP
; EnableUnicode