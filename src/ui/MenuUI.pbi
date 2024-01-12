

XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; ============================================================================
; MenuUI Module Declaration
; ============================================================================
DeclareModule MenuUI
  
  Structure MenuUI_t Extends UI::UI_t
    *menu.ControlMenu::ControlMenu_t
  EndStructure
  
  Interface IMenuUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t, name.s="MenuUI")
  Declare Delete(*ui.MenuUI_t)
  Declare Resize(*ui.MenuUI_t)
  Declare OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  
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

  Procedure OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
    If event =  #PB_Event_SizeWindow
      Protected *top.View::View_t = *Me\view
      *Me\posX = *top\posX
      *Me\posY = *top\posY
      *Me\sizX = *top\sizX
      *Me\sizY = *top\sizY
      ResizeGadget(*Me\gadgetID, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
      ControlMenu::OnEvent(*me\menu,#PB_EventType_Resize)
      
    ElseIf event = #PB_Event_Gadget
      
      If EventGadget() = *Me\menu\GadgetID
        ControlMenu::OnEvent(*me\menu,EventType())
      EndIf
    EndIf
  
   
  EndProcedure
 
  Procedure ConnectSignalSlot(*Me.MenuUI_t)
  
    ;Me\SignalConnect(*Me\menu\SignalOnChanged(),0)
    
  EndProcedure

  Procedure Delete(*Me.MenuUI_t)
    ControlMenu::Delete(*Me\menu)
    Object::TERM(MenuUI)
  EndProcedure
  
  Procedure.i New(*parent.View::View_t,name.s="MenuUI")
    Protected *Me.MenuUI_t = AllocateStructure(MenuUI_t)
    Object::INI( MenuUI )
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = *parent\sizY
    
    *Me\name = "Top Menu"
    *Me\type = Globals::#VIEW_TOPMENU
    *Me\view = *parent
    *Me\gadgetID = CanvasGadget(#PB_Any,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY, #PB_Canvas_Keyboard)
    

                                  
    
    *Me\menu = ControlMenu::New(*Me,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    
    Protected *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"File")
    Protected *args.Args::Args_t = Args::New(1)
    *args\args(0)\type = Types::#TYPE_PTR
    *args\args(0)\p = *scene

    ControlMenu::AddItem(*submenu,"Save Scene",SaveSceneCmd::@Do(),*args)
    ControlMenu::AddItem(*submenu,"Load Scene",LoadSceneCmd::@Do(),*args)
    ControlMenu::AddSeparator(*submenu)
    ControlMenu::AddItem(*submenu,"New Scene",NewSceneCmd::@Do(),*args)
    
    *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"Edit")
    *args\args(0)\type = Types::#TYPE_INT
    *args\args(0)\i = Shape::#SHAPE_CUBE
    ControlMenu::AddItem(*submenu,"Create Polymesh Cube",CreatePolymeshCmd::@Do(),*args)
 
    *args\args(0)\i = Shape::#SHAPE_GRID
    ControlMenu::AddItem(*submenu,"Create Polymesh Grid",CreatePolymeshCmd::@Do(),*args)
    
    *args\args(0)\i = Shape::#SHAPE_SPHERE
    ControlMenu::AddItem(*submenu,"Create Polymesh Sphere",CreatePolymeshCmd::@Do(),*args)
    
    *args\args(0)\i = Shape::#SHAPE_BUNNY
    ControlMenu::AddItem(*submenu,"Create Polymesh Bunny",CreatePolymeshCmd::@Do(),*args)
    
    *args\args(0)\i = Shape::#SHAPE_Torus
    ControlMenu::AddItem(*submenu,"Create Polymesh Torus",CreatePolymeshCmd::@Do(),*args)
    
    ControlMenu::AddSeparator(*submenu)

    ControlMenu::AddItem(*submenu,"Create Tree on Selected Object",CreateTreeCmd::@Do(),*args)

    
    ControlMenu::Init(*Me\menu,"")
    
    View::SetContent(*parent,*Me)
        
    ConnectSignalSlot(*Me)
    
    
  
    ProcedureReturn *Me
  EndProcedure
  
   Class::DEF(MenuUI)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 81
; FirstLine = 56
; Folding = --
; EnableXP