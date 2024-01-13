XIncludeFile "UI.pbi"

; ============================================================================
; MenuUI Module Declaration
; ============================================================================
DeclareModule MenuUI
  
  Structure MenuItem_t
    name.s
    event.i
    List items.MenuItem_t()
  EndStructure
  
  Structure MenuUI_t Extends UI::UI_t
    List items.MenuItem_t()
  EndStructure
  
  Interface IMenuUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t, name.s="MenuUI")
  Declare Delete(*ui.MenuUI_t)
  Declare Resize(*ui.MenuUI_t)
  Declare OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  
  Declare AddItem(*Me.MenuUI_t, name.s, event.i)
  Declare AddSubItem(*Me.MenuUI_t, *item.MenuItem_t, name.s, event.i)
  
  DataSection 
    MenuUIVT: 
      Data.i @OnEvent()
      Data.i @Delete()
  EndDataSection 
    
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; MenuUI Module Implementation
; ============================================================================
Module MenuUI
  Procedure Resize(*Me.MenuUI_t)
    
  EndProcedure
  
  Procedure _AddSubMenuItem(*menu.MenuUI::MenuItem_t)
    If ListSize(*menu\items())
      OpenSubMenu(*menu\name)
      ForEach *menu\items()
        _AddSubMenuItem(*menu\items())
      Next
      CloseSubMenu()   
    Else
      MenuItem(*menu\event, *menu\name)
    EndIf
  EndProcedure

  Procedure _AddMenuItem(*menu.MenuUI::MenuItem_t)
    MenuTitle(*menu\name)
    ForEach *menu\items()
      _AddSubMenuItem(*menu\items())
    Next
  EndProcedure
  
  Procedure OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
    If *Me\dirty
      If *Me\gadgetID : FreeMenu(*Me\gadgetID) : EndIf
      *Me\gadgetID = CreateMenu(#PB_Any, WindowID(View::GetWindowID(*Me\view)))
      
      ForEach *Me\items()
        _AddMenuItem(*Me\items())
      Next
      *Me\dirty = #False
    EndIf
  EndProcedure
  
  Procedure AddItem(*Me.MenuUI_t, name.s, event.i)
    AddElement(*Me\items())
    *Me\items()\name = name
    *Me\items()\event = event
    *Me\dirty = #True
    ProcedureReturn *Me\items()
  EndProcedure
  
  Procedure AddSubItem(*Me.MenuUI_t, *item.MenuItem_t, name.s, event.i)
    AddElement(*item\items())
    *item\items()\name = name
    *item\items()\event = event
    *Me\dirty = #True
    ProcedureReturn *item\items()
  EndProcedure

  Procedure Delete(*Me.MenuUI_t)
    Object::TERM(MenuUI)
  EndProcedure
  
  Procedure.i New(*parent.View::View_t,name.s="MenuUI")
    Protected *Me.MenuUI_t = AllocateStructure(MenuUI_t)
    Object::INI( MenuUI )
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    
    *Me\name = "Menu"
    *Me\type = Globals::#VIEW_TOPMENU
    *Me\view = *parent
    *Me\gadgetID = 0
    *Me\dirty = #True
    
    View::SetContent(*parent, *Me)
    ProcedureReturn *Me
  EndProcedure
  
   Class::DEF(MenuUI)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 54
; FirstLine = 60
; Folding = --
; EnableXP