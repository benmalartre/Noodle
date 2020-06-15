

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

  Declare New(*parent.View::View_t,name.s="MenuUI")
  Declare Delete(*ui.MenuUI_t)
  Declare Resize(*ui.MenuUI_t)
  Declare Draw(*ui.MenuUI_t)
  Declare DrawPickImage(*ui.MenuUI_t)
  Declare Pick(*ui.MenuUI_t)
  Declare OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare Draw(*ui.MenuUI_t)
  
  
  DataSection 
    MenuUIVT: 
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
      Data.i @DrawPickImage()
      Data.i @Pick()
  EndDataSection 
    
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; MenuUI Module Implementation
; ============================================================================
Module MenuUI
  
  ;  Setup
  ; ----------------------------------------
  Procedure Setup(*Me.MenuUI_t)
    
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Pick
  ; ----------------------------------------
  Procedure Pick(*Me.MenuUI_t)
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw
  ; ----------------------------------------
  Procedure Draw(*Me.MenuUI_t)
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw Pick Image
  ; ----------------------------------------
  Procedure DrawPickImage(*Me.MenuUI_t)
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Resize
  ; ----------------------------------------
  Procedure Resize(*Me.MenuUI_t)
  
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Clear Explorer Data
  ; ----------------------------------------
  Procedure Clear(*Me.MenuUI_t)
    
  EndProcedure

  
  ;---------------------------------------------------
  ; Send Events
  ;---------------------------------------------------
  Procedure OnEvent(*Me.MenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
     
    If event =  #PB_Event_SizeWindow
      Protected *top.View::View_t = *Me\parent
      *Me\posX = *top\posX
      *Me\posY = *top\posY
      *Me\sizX = *top\sizX
      *Me\sizY = *top\sizY
      ResizeGadget(*Me\gadgetID, *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
      Debug "MenuUI Resize : ("+Str(*Me\posX)+","+Str(*Me\posY)+","+Str(*Me\sizX)+","+Str(*Me\sizY)+")"
      ControlMenu::OnEvent(*me\menu,#PB_EventType_Resize)
      
    ElseIf event = #PB_Event_Gadget
      
      If EventGadget() = *Me\menu\GadgetID
        ControlMenu::OnEvent(*me\menu,EventType())
      EndIf
    EndIf
   
    ;Redraw Top Menu
    Draw(*Me)
   
  EndProcedure
  
  
  ;---------------------------------------------------------------
  ; Connect Signals\Slots 
  ;---------------------------------------------------------------
  Procedure ConnectSignalSlot(*Me.MenuUI_t)
  
    ;Me\SignalConnect(*Me\menu\SignalOnChanged(),0)
    
  EndProcedure
 
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.MenuUI_t)
    ControlMenu::Delete(*Me\menu)
    Object::TERM(MenuUI)
  EndProcedure
  
;   Procedure OnCreatePolymesh(shape.i)
;     Define args.Arguments::Arguments_t
;     args\args[0]\type = Arguments::#INT
;     args\args[0]\i = shape
;     CreatePolymeshCmd::Do(args)
;   EndProcedure
;   Callback::DECLARECALLBACK(OnCreatePolymesh, Arguments::#INT
  

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*parent.View::View_t,name.s="MenuUI")
    Protected *Me.MenuUI_t = AllocateMemory(SizeOf(MenuUI_t))
    ;Initialize Structures
    Object::INI( MenuUI )
    *Me\parent = *parent
    *Me\posX = *parent\posX
    *Me\posY = *parent\posY
    *Me\sizX = *parent\sizX
    *Me\sizY = 25
    
    *Me\name = "Top Menu"
    *Me\type = Globals::#VIEW_TOPMENU
    *Me\gadgetID = CanvasGadget(#PB_Any,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY, #PB_Canvas_Keyboard)
                                  

    Protected *window.Window::Window_t = *parent\window
    
    ; ---[ Menu ]------------------
    *Me\menu = ControlMenu::New(*Me,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    
    Protected *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"File")
    Protected *args.Arguments::Arguments_t = Arguments::New(1)
    *args\args(0)\type = Arguments::#PTR
    *args\args(0)\p = Scene::*current_scene

    ControlMenu::AddItem(*submenu,"Save Scene",SaveSceneCmd::@Do(),*args)
    ControlMenu::AddItem(*submenu,"Load Scene",LoadSceneCmd::@Do(),*args)
    ControlMenu::AddSeparator(*submenu)
    ControlMenu::AddItem(*submenu,"New Scene",NewSceneCmd::@Do(),*args)
    
    *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"Edit")
    *args\args(0)\type = Arguments::#INT
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
        
    ConnectSignalSlot(*Me)
    
    ; ---[ View Content ]-----------------------
    View::SetContent(*parent,*Me)
  
    ProcedureReturn *Me
  EndProcedure
  
   Class::DEF(MenuUI)
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 203
; FirstLine = 147
; Folding = ---
; EnableXP