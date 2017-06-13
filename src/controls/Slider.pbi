XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Control.pbi"

DeclareModule ControlSlider
  Prototype .i MenuItemCallback(*args.Arguments::Arguments_t)
  
  Structure ControlSliderItem_t
    id.i
    name.s
    *callback.MenuItemCallback
    *args.Arguments::Arguments_t
  EndStructure
    
  Declare New(name.s,x.i,y.i,width.i,height.i)
  Declare Delete(*Me.ControlSlider_t)
  Declare AddSubMenu(*Me.ControlSlider_t,name.s)
  Declare AddItem(*Me.ControlSubMenu_t,name.s,*args.Arguments::Arguments_t,*callback)
  Declare RemoveSubMenu(*Me.ControlSlider_t,*menu.ControlSubMenu_t)
;   Declare RemoveSubMenuByID(*Me.ControlSlider_t,id.i)
;   Declare RemoveSubMenuByName(*Me.ControlSlider_t,name.s)
;   Declare RemoveItem(*Me.ControlSubMenu_t,*item.ControlSliderItem_t)
;   Declare RemoveItemByID(*Me.ControlSubMenu_t,id.i)
;   Declare RemoveItemByName(*Me.ControlSubMenu_t,name.s)
  
  Declare Inspect(*Me.ControlSlider_t)
  Declare Callback(*Me.ControlSliderItem_t)
  Declare Event(*Me.ControlSliderItem_t,event.i,*ev_data.EventTypeDatas_t = #Null )
  DataSection 
    ControlSliderVT: 
    Data.i @Event()
    Data.i @Delete()
  EndDataSection 
  
EndDeclareModule

Module ControlSlider
  
  ; CONSTRUCTOR
  ;--------------------------------------------------------------------------
  Procedure New(name.s,x.i,y.i,width.i,height.i)
    Protected *Me.ControlSlider_t = AllocateMemory(SizeOf(ControlSlider_t))
    InitializeStructure(*Me,ControlSlider_t)
    *Me\name = name
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = width
    *Me\sizY = height
    *Me\VT = ?ControlSliderVT
    ProcedureReturn *Me
  EndProcedure
  
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------
  Procedure Delete(*Me.ControlSlider_t)
    ForEach *Me\menus()
      RemoveSubMenu(*Me,*Me\menus())
    Next
    ClearStructure(*Me,ControlSlider_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; ADD SUB MENU
  ;---------------------------------------------------------------------------
  Procedure AddSubMenu(*Me.ControlSlider_t,name.s)
    Protected *menu.ControlSubMenu_t = AllocateMemory(SizeOf(ControlSubMenu_t))
    InitializeStructure(*menu,ControlSubMenu_t)
    *menu\name = name
    AddElement(*Me\menus())
    *Me\menus() = *menu
    ProcedureReturn *menu
  EndProcedure
  
  ; REMOVE SUB MENU
  ;---------------------------------------------------------------------------
  Procedure RemoveSubMenu(*Me.ControlSlider_t,*menu.ControlSubMenu_t)
    ForEach *Me\menus()
      If *Me\menus() = *menu
        DeleteElement(*Me\menus())
        ClearStructure(*menu,ControlSubMenu_t)
        FreeMemory(*menu)
      EndIf
    Next
    
  EndProcedure
  
  ; ADD ITEM
  ;---------------------------------------------------------------------------
  Procedure AddItem(*Me.ControlSubMenu_t,name.s,*args.Arguments::Arguments_t,*callback)
    Protected *item.ControlSliderItem_t = AllocateMemory(SizeOf(ControlSliderItem_t))
    InitializeStructure(*menu,ControlSliderItem_t)
    *item\name = name
    *item\callback = *callback
    *item\args = *args
    AddElement(*Me\items())
    *Me\items() = *item
    ProcedureReturn *item
  EndProcedure
  
  ; INSPECT
  ;---------------------------------------------------------------------------
  Procedure Inspect(*Me.ControlSlider_t)
    Protected window = OpenWindow(#PB_Any,0,0,1200,800,"Test Menu")
    *Me\gadgetID = CreateMenu(#PB_Any,WindowID(window))
    ForEach *Me\menus()
      Debug *Me\menus()\name
      MenuTitle(*Me\menus()\name)
      ForEach *Me\menus()\items()
        MenuItem(*Me\menus()\items()\id,*Me\menus()\items()\name)
      Next
      
    Next
    
    Repeat
    Until WaitWindowEvent() = #PB_Event_CloseWindow
    
  EndProcedure
  
  Procedure Callback(*Me.ControlSliderItem_t)
    MessageRequester("[CONTROl MENU]","Callback Called!!!")
  EndProcedure
  
  Procedure Event(*Me.ControlSliderItem_t,event.i,*ev_data.EventTypeDatas_t = #Null )
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 30
; Folding = --
; EnableUnicode
; EnableXP