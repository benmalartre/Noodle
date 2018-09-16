

XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; ============================================================================
; TopMenuUI Module Declaration
; ============================================================================
DeclareModule TopMenuUI
  UseModule UI
  
  Structure TopMenuUI_t Extends UI_t
    *menu.ControlMenu::ControlMenu_t
  EndStructure
  
  Interface ITopMenuUI Extends IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s="TopMenuUI")
  Declare Delete(*ui.TopMenuUI_t)
  Declare Init(*ui.TopMenuUI_t)
  Declare OnEvent(*Me.TopMenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
  Declare Term(*ui.TopMenuUI_t)
  Declare Draw(*ui.TopMenuUI_t)
  
  
  DataSection 
    TopMenuUIVT: 
      Data.i @Init()
      Data.i @OnEvent()
      Data.i @Term()
  
  EndDataSection 
  
EndDeclareModule

; ============================================================================
; TopMenuUI Module Implementation
; ============================================================================
Module TopMenuUI
  
  ;  Setup
  ; ----------------------------------------
  Procedure Setup(*Me.TopMenuUI_t)
    
  EndProcedure
  
  
  ; ----------------------------------------
  ;  Pick
  ; ----------------------------------------
  Procedure Pick(*Me.TopMenuUI_t)
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Draw
  ; ----------------------------------------
  Procedure Draw(*Me.TopMenuUI_t)
  
  EndProcedure
  
  ; ----------------------------------------
  ;  Clear Explorer Data
  ; ----------------------------------------
  Procedure Clear(*Me.TopMenuUI_t)
    
  EndProcedure
  
  ; ----------------------------------------
  ;  Init TopMenu Data
  ; ----------------------------------------
  Procedure Init(*Me.TopMenuUI_t)
    
  EndProcedure
  
  ; ----------------------------------------
  ;  Term TopMenu Data
  ; ----------------------------------------
  Procedure Term(*Me.TopMenuUI_t)
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Callbacks
  ;---------------------------------------------------
  Procedure SetThemeLight(*args.Arguments::Arguments_t)
    FirstElement(*args\args())
    Protected *arg.Arguments::Argument_t = *args\args()
  
    Protected windowID = *arg\l
  
    SetWindowColor(windowID,UIColor::COLOR_MAIN_BG)
    Controls::SetTheme( Globals::#GUI_THEME_LIGHT )
   EndProcedure
   
   Procedure SetThemeDark(*args.Arguments::Arguments_t)
     FirstElement(*args\args())
    Protected *arg.Arguments::Argument_t = *args\args()
  
    Protected windowID = *arg\l
  
     SetWindowColor(windowID,UIColor::COLOR_MAIN_BG)
     Controls::SetTheme( Globals::#GUI_THEME_DARK )
  EndProcedure
  
  ;---------------------------------------------------
  ; Send Events
  ;---------------------------------------------------
  Procedure OnEvent(*Me.TopMenuUI_t,event.i,*ev_data.Control::EventTypeDatas_t)
    
    CompilerIf #PB_Compiler_Version < 560
      If event =  Control::#PB_EventType_Resize
        Protected *top.View::View_t = *Me\top
        *Me\x = *top\x
        *Me\y = *top\y
        *Me\width = *top\width
        *Me\height = *top\height
        ControlMenu::OnEvent(*me\menu,Control::#PB_EventType_Resize)
    CompilerElse
      If event =  #PB_EventType_Resize
        Protected *top.View::View_t = *Me\top
        *Me\x = *top\x
        *Me\y = *top\y
        *Me\width = *top\width
        *Me\height = *top\height
        ControlMenu::OnEvent(*me\menu,#PB_EventType_Resize)
        ControlMenu::OnEvent(*me\menu,#PB_EventType_Resize)
    CompilerEndIf
      
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
  Procedure ConnectSignalSlot(*Me.TopMenuUI_t)
  
    ;Me\SignalConnect(*Me\menu\SignalOnChanged(),0)
    
  EndProcedure
  
  ;---------------------------------------------------------------
  ; On Message
  ;---------------------------------------------------------------
  Procedure OnMessage( id.i, *up)
;     Protected *sig.CSignal_t = *up
;     Protected *menu.TopMenuUI_t = *sig\rcv_inst
;     
;     ; Menu Event
;     ;--------------------------------------------------------
;     Protected *manager.CViewManager_t = *menu\top\manager
;     OView_Event(*manager\main,#PB_Event_SizeWindow,#Null)
  
  EndProcedure
  
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*e.TopMenuUI_t)
    FreeMemory(*e)
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*parent.View::View_t,name.s="TopMenuUI")
    Protected *Me.TopMenuUI_t = AllocateMemory(SizeOf(TopMenuUI_t))
    ;Initialize Structures
    InitializeStructure(*Me,TopMenuUI_t)
    Object::INI( TopMenuUI )
    *Me\x = *parent\x
    *Me\y = *parent\y
    *Me\width = *parent\width
    *Me\height = 25
    
    *Me\name = "Top Menu"
    *Me\type = Globals::#VIEW_TOPMENU
    *Me\container = ContainerGadget(#PB_Any,*Me\x,*Me\y,*Me\width,*Me\height)
                                  

    Protected *manager.ViewManager::ViewManager_t = *parent\manager
    
    ; ---[ Menu ]------------------
    *Me\menu = ControlMenu::New(*manager\window,*Me\container,*Me\x,*Me\y,*Me\width,*Me\height)
    *Me\gadgetID = *Me\menu\gadgetID
    
    Protected *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"File")
    Protected *args.Arguments::Arguments_t = Arguments::New()
    Arguments::AddPtr(*args,"Scene",Scene::*current_scene)
    ControlMenu::AddItem(*submenu,"Save Scene",SaveSceneCmd::@Do(),*args)
    ControlMenu::AddItem(*submenu,"Load Scene",LoadSceneCmd::@Do(),*args)
    ControlMenu::AddSeparator(*submenu)
    ControlMenu::AddItem(*submenu,"New Scene",NewSceneCmd::@Do(),*args)
    
    *submenu.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"Edit")
    Arguments::SetLong(*args,"Shape",Shape::#SHAPE_CUBE,0)
    ControlMenu::AddItem(*submenu,"Create Polymesh Cube",CreatePolymeshCmd::@Do(),*args)
    
    Arguments::SetLong(*args,"Shape",Shape::#SHAPE_GRID,0)
    ControlMenu::AddItem(*submenu,"Create Polymesh Grid",CreatePolymeshCmd::@Do(),*args)
    
    Arguments::SetLong(*args,"Shape",Shape::#SHAPE_SPHERE,0)
    ControlMenu::AddItem(*submenu,"Create Polymesh Sphere",CreatePolymeshCmd::@Do(),*args)
    
    Arguments::SetLong(*args,"Shape",Shape::#SHAPE_BUNNY,0)
    ControlMenu::AddItem(*submenu,"Create Polymesh Bunny",CreatePolymeshCmd::@Do(),*args)
    
    Arguments::SetLong(*args,"Shape",Shape::#SHAPE_Torus,0)
    ControlMenu::AddItem(*submenu,"Create Polymesh Torus",CreatePolymeshCmd::@Do(),*args)
    
    ControlMenu::AddSeparator(*submenu)
    Arguments::Clear(*args)

    ControlMenu::AddItem(*submenu,"Create Tree on Selected Object",CreateTreeCmd::@Do(),#Null)
    
;   
;     
;     *submenu = newCControlSubMenu(*Me\menu,50,0,"Edit")
;     args\m[0]\type = #MU_TYPE_PTR
;     args\m[0]\value\vPTR = *raa_current_scene\root
;     args\m[1]\type = #MU_TYPE_U32
;     args\m[1]\value\vU32= #RAA_SHAPE_CUBE
;     *submenu\AddItem("Create Polymesh Cube",@Cmd_Create_Polymesh(),@args)
;     args\m[1]\value\vU32= #RAA_SHAPE_GRID
;     *submenu\AddItem("Create Polymesh Grid",@Cmd_Create_Polymesh(),@args)
;     args\m[1]\value\vU32= #RAA_SHAPE_NONE
;     *submenu\AddItem("Create Polymesh Empty",@Cmd_Create_Polymesh(),@args)
;     *submenu\AddItem("Undo",@Callback3(),@args)
;     *submenu\AddItem("Redo",@Callback4(),@args)
;   
;   
;     *submenu = newCControlSubMenu(*Me\menu,100,0,"View")
;     *submenu\AddItem("Frame Selected",@Callback3(),@args)
;     *submenu\AddItem("Frame All",@Callback4(),@args)
;   
;     *submenu = newCControlSubMenu(*Me\menu,150,0,"Display")
;     *submenu\AddItem("Hide/Unhide Selection",@Callback3(),@args)
;     *submenu\AddItem("Unhide   All Objects",@Callback4(),@args)
;     *submenu\AddItem("Unhide All Polygons",@Callback4(),@args)
;   
;     *submenu = newCControlSubMenu(*Me\menu,200,0,"Window")
;     *submenu\AddItem("Minimize All",@Callback1(),@args)
;     *submenu\AddItem("Restore All",@Callback2(),@args)
;     *submenu\AddItem("Close All",@Callback3(),@args)
;     
;     args\m[0]\type = #MU_TYPE_U32
;     args\m[0]\value\vU32 = *manager\window
;     *submenu\AddItem("Theme Light",@raaGUISetThemeLight(),@args)
;     *submenu\AddItem("Theme Dark",@raaGUISetThemeDark(),@args)
    
    ControlMenu::Init(*Me\menu,"")
    
    CloseGadgetList()
    
    ConnectSignalSlot(*Me)
    
    ; ---[ View Content ]-----------------------
    View::SetContent(*parent,*Me)
  
    ProcedureReturn *Me
  EndProcedure
  
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 203
; FirstLine = 174
; Folding = ---
; EnableXP