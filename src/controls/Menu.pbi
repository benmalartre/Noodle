XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../ui/View.pbi"
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
    x.i
    y.i
    width.i
    height.i
    inspected.b
    imageID.i
    windowID.i
    *cache
    *manager.ViewManager::ViewManager_t
  EndStructure

  ; ============================================================================
  ;  CLASS ( CControlMenu_t )
  ; ============================================================================
  Structure ControlMenu_t Extends Control::Control_t
    windowID.i
    parentID.i
    imageID.i
    x.i
    y.i
    width.i
    height.i
    last.i       ; last inspected submenu id
    dirty.b       ; menu should redraw
    
    *inspected.ControlSubMenu_t                     ; currently inspected submenu
    Array *submenus.ControlSubMenu_t(0)
    *manager.ViewManager::ViewManager_t
  EndStructure
  
  Declare Callback1()
  Declare Callback1()
  Declare Callback2()
  Declare Callback4()
  
  Declare New(windowID.i,parentID.i,x.i,y.i,width.i,height.i)
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
  Declare Event(*menu.ControlMenu_t,eventID.i)
  
  
EndDeclareModule



; ============================================================================
;  IMPLEMENTATION ( CControlSubMenu )
; ============================================================================

  
Module ControlMenu
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure New(windowID.i,parentID.i,x.i,y.i,width.i,height.i)
    Protected *Me.ControlMenu_t = AllocateMemory(SizeOf(ControlMenu_t))
    InitializeStructure(*Me,ControlMenu_t)
  
    *Me\gadgetID = CanvasGadget(#PB_Any,x,y,width+1,height+1,#PB_Canvas_Keyboard)
    *Me\windowID = windowID
    *Me\parentID = parentID
    *Me\imageID = CreateImage(#PB_Any,width,height)
    *Me\x = x
    *Me\y = y
    *Me\width = width+1
    *Me\height = height+1
    *Me\last = -1
    *Me\dirty = #True
    
    ; ---[ Init 'OnChanged' Slot ]----------------------------------------------
  ;   *Me\sig_onchanged = newCSlot( *Me )
    
    ProcedureReturn *Me
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure Delete(*menu.ControlMenu_t)
    ; ---[ Release 'OnChanged' Slot ]--------------------------------------------
;     OSlot_Release(*menu\sig_onchanged)
    
    FreeGadget(*menu\gadgetID)
    FreeImage(*menu\imageID)
    FreeMemory(*menu)
  EndProcedure
  
  ; ==========================================================================
  ;  CONSTRUCTOR
  ; ==========================================================================
  Procedure NewSubMenu(*menu.ControlMenu_t,x.i,y.i,name.s)
    Protected *Me.ControlSubMenu_t = AllocateMemory(SizeOf(ControlSubMenu_t))
    InitializeStructure(*Me,ControlSubMenu_t)
  
    *Me\selected = -1
    *Me\last = -1
    
    If *menu<>#Null
      *Me\windowID = *menu\windowID
      *Me\parent = *menu
      *Me\gadgetID = *menu\gadgetID
    Else
      *Me\windowID = 0
      *Me\parent = #Null
      *Me\gadgetID = #Null
    EndIf
    
    *Me\imageID = CreateImage(#PB_Any,32,32)
    *Me\cache = #Null
  
    *Me\close = #False
    *Me\name = name
    *Me\dirty = #True
    *Me\x = x
    *Me\y = y
    
    ; ---[ Init 'OnChanged' Slot ]----------------------------------------------
    ;*Me\sig_onchanged = newCSlot( *Me )
    
    If *menu<>#Null
      ReDim *menu\submenus(ArraySize(*menu\submenus())+1)
      *menu\submenus(ArraySize(*menu\submenus())-1) = *Me
    EndIf
   
    ProcedureReturn *Me
  EndProcedure
  
  ; ==========================================================================
  ;  DESTRUCTOR
  ; ==========================================================================
  Procedure DeleteSubMenu(*menu.ControlSubMenu_t)
    ;OSlot_Release(*menu\sig_onchanged)
    FreeMemory(*menu)
    FreeImage(*menu\imageID)
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
    Protected *item.ControlMenuItem_t = AllocateMemory(SizeOf(ControlMenuItem_t))
    InitializeStructure(*item,ControlMenuItem_t)
    *item\name = name
    *item\callback = callback
    *item\args = Arguments::New();*args
    If Not *args = #Null
      Protected a.i
      ForEach *args\args()
        Arguments::AddPtr(*item\args,"default",#Null)
        Arguments::Copy(*item\args\args(),*args\args())
        ;muv2muv(*args\m[a],*item\args\m[a])
  ;     Debug "Copied Argument : "+muv2str(*args\m[a]) +" ---> "+muv2str(*item\args\m[a])
      Next
    EndIf
    
    *item\type = #MenuItemType_Command
    
    ReDim *menu\items(ArraySize(*menu\items())+1)
  
    *menu\items(ArraySize(*menu\items())-1) = *item
   
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Add Separator
  ; ----------------------------------------------------------------------------
  Procedure AddSeparator(*menu.ControlSubMenu_t)
    Protected *item.ControlMenuItem_t = AllocateMemory(SizeOf(ControlMenuItem_t))
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
    *menu\width.i = -1
  
    StartDrawing(ImageOutput(*menu\imageID))
    Protected a
    For a=0 To ArraySize(*menu\items())-1
      
      Protected width = TextWidth(*menu\items(a)\name)+#MenuItemSpacing
      If  *menu\width< width
        *menu\width = width
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
    StartDrawing(CanvasOutput(*menu\gadgetID))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0,0,*menu\width,*menu\height,UIColor::COLOR_NUMBER_BG)
;     DrawingMode(#PB_2DDrawing_Outlined)
;     RoundBox(0,0,*menu\width,*menu\height,3,3,UIColor::COLOR_GROUP_LABEL)
    DrawingFont(FontID(Globals::#FONT_SUBMENU))
    DrawingMode(#PB_2DDrawing_Transparent)
    Protected a
    For a=0 To ArraySize(*menu\items())-1
      If *menu\items(a)\type = #MenuItemType_Separator
        Line(10,a*#MenuItemHeight+0.5*#MenuItemHeight,*menu\width-20,0,UIColor::COLOR_TEXT)
      Else
        
        If a = *menu\selected
          DrawingMode(#PB_2DDrawing_Default)
          RoundBox(0,a*#MenuItemHeight,*menu\width,#MenuItemHeight,2,2,UIColor::COLOR_SELECTED_BG)
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(5,a*#MenuItemHeight,*menu\items(a)\name,UIColor::COLOR_SELECTED_FG)
         ; DrawingMode(#PB_2DDrawing_Transparent)
        Else
          DrawText(5,a*#MenuItemHeight,*menu\items(a)\name,UIColor::COLOR_TEXT)
        EndIf
      EndIf   
    
    Next a
  
    StopDrawing()
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
          FirstElement(*menu\items(id)\args\args())
          Protected *view = *menu\items(id)\args\args()\ptr
          
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
;     Protected sig.CSlot
    Protected leftbutton.b
    *menu\close = #False
    *menu\windowID = OpenWindow(#PB_Any,*menu\x,*menu\y+25,*menu\width,*menu\height,"Menu",#PB_Window_BorderLess)
    StickyWindow(*menu\windowID,#True)
    *menu\gadgetID = CanvasGadget(#PB_Any,0,0,*menu\width,*menu\height)
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
;           sig.CSlot = menu\SignalOnChanged()
;           sig\Trigger(#RAA_SIGNAL_TYPE_PING,0)
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
    
;     sig.CSlot = menu\SignalOnChanged()
;     sig\Trigger(#RAA_SIGNAL_TYPE_PING,0)
    *menu\dirty = #True
    *menu\selected = -1
  
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure InitSubMenu(*menu.ControlSubMenu_t,*parent.ControlMenu_t=#Null)
    *menu\height = ArraySize(*menu\items())*#MenuItemHeight
    
    GetSubMenuWidth(*menu)
    
    If *parent<>#Null
      *menu\x = WindowX(*parent\windowID,#PB_Window_InnerCoordinate)+WindowMouseX(*parent\windowID);*parent\x+GadgetX(*parent\parentID)+*parent\width
      *menu\y = WindowY(*parent\windowID,#PB_Window_InnerCoordinate)+WindowMouseY(*parent\windowID);*parent\y+GadgetY(*parent\parentID)
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
    Protected *item.ControlSubMenu_t = AllocateMemory(SizeOf(ControlSubMenu_t))
    *item\name = name
    *item\type = #MenuItemType_Menu
    *item\parent = *menu
    
    ReDim *menu\items(ArraySize(*menu\items())+1)
  
    *menu\items(ArraySize(*menu\items())-1) = *item
    
  EndProcedure


  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlMenu )
  ; ============================================================================
  ;{
  
  ; ----------------------------------------------------------------------------
  ;  Add Sub Menu
  ; ----------------------------------------------------------------------------
  Procedure Add(*menu.ControlMenu_t,name.s)
    Protected *submenu.ControlSubMenu_t = NewSubMenu(*menu,*menu\x,*menu\y+*menu\height+30,name)
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
  
    If *menu\dirty
      StartDrawing(CanvasOutput(*menu\gadgetID))
      DrawingFont(FontID(Globals::#font_menu))
      ;raaSetFont(RAA_FONT_HEADER)
      
      Box(0,0,*menu\width,*menu\height,UIColor::COLORA_MAIN_BG)
      Protected x,y, a
      DrawingMode(#PB_2DDrawing_Default)
      x = #MenuItemSpacing
      y = #MenuItemSpacing/2
      
      For a=0 To ArraySize(*menu\submenus())-1
        If *menu\inspected = *menu\submenus(a)
          Protected width.i = TextWidth(*menu\submenus(a)\name)+#MenuItemSpacing
          RoundBox(x-#MenuItemSpacing/2,0,width,GadgetHeight(*menu\gadgetID),2,2,UIColor::COLORA_NUMBER_BG)
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText( x,y,*menu\submenus(a)\name,UIColor::COLORA_NUMBER_FG)
          DrawingMode(#PB_2DDrawing_Outlined)
          RoundBox(x-#MenuItemSpacing/2,0,width,GadgetHeight(*menu\gadgetID),2,2,UIColor::COLORA_LINE_DIMMED)
          DrawingMode(#PB_2DDrawing_Default)
        Else
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText( x,y,*menu\submenus(a)\name,UIColor::COLORA_TEXT)
        EndIf
        
        With *menu\submenus(a)
          \height =ArraySize( \items())*#MenuItemHeight
         
          \x = x + WindowX(*menu\windowID,#PB_Window_InnerCoordinate) - #MenuItemSpacing/2+GadgetX(*menu\parentID)
          \y = WindowY(*menu\windowID)+GadgetHeight(*menu\gadgetID)+GadgetY(*menu\parentID)
        EndWith
        x+#MenuItemSpacing+TextWidth(*menu\submenus(a)\name)
      Next a
      
      ;DrawAlphaImage(ImageID(*menu\imageID),0,0,200)
    
      StopDrawing()
      *menu\dirty = #False
    EndIf
    
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------------------------------------------
  Procedure DrawPickImage(*menu.ControlMenu_t)
  
    StartDrawing(ImageOutput(*menu\imageID))
    DrawingMode(#PB_2DDrawing_Default)
    DrawingFont(FontID(Globals::#font_menu))
    Box(*menu\x,*menu\y,*menu\width,*menu\height,RGBA(60,60,60,255))
    Protected x,y, a,width,height
    
    x = #MenuItemSpacing/2
    y = 0
    height = GadgetHeight(*menu\gadgetID)
    For a=0 To ArraySize(*menu\submenus())-1
      width = TextWidth(*menu\submenus(a)\name)+#MenuItemSpacing
      ;OControlSubMenu_GetWidth(*menu\submenus(a))
      Box(x,y,width,height,RGBA(a+1,0,0,255))
      x+width
    Next a
    
    StopDrawing()
    
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Event
  ; ----------------------------------------------------------------------------
  Procedure Event(*menu.ControlMenu_t,eventID.i)
    
    If eventID = #PB_Event_SizeWindow Or eventID = Control::#PB_EventType_Resize
      *menu\dirty = #True
      Draw(*menu)
    Else
      Pick(*menu)
      Draw(*menu)
      
      If *menu\inspected<>#Null And EventType() = #PB_EventType_LeftClick
        InspectSubMenu(*menu\inspected)
        *menu\inspected = #Null
        *menu\dirty = #True
        *menu\last = -1
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
  ;   sig\Trigger(#RAA_SIGNAL_TYPE_PING,0)
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

  
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 239
; FirstLine = 226
; Folding = -Qt---
; EnableUnicode
; EnableThread
; EnableXP