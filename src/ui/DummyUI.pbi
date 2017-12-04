
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; DummyUI Module Declaration
; -----------------------------------------
DeclareModule DummyUI
  UseModule UI
  Structure DummyUI_t Extends UI_t
    ;*menu.ControlMenu::ControlMenu_t
  EndStructure
  
  Interface IDummyUI Extends IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*ui.DummyUI_t)
  Declare Init(*ui.DummyUI_t)
  Declare OnEvent(*ui.DummyUI_t,event.i)
  Declare Term(*ui.DummyUI_t)
  Declare Draw(*ui.DummyUI_t)
  
  DataSection 
    DummyVT: 
    Data.i @Init()
    Data.i @OnEvent()
    Data.i @Term()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; DummyUI Module Implementation
; -----------------------------------------
Module DummyUI
  
  Procedure DummyCallback(*args.Arguments::Arguments_t)
    MessageRequester( "DUMMY CALLBACK","Nb Arguments : "+Str(*args\nb))
  EndProcedure
  
  ; New
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s)
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    
    Protected *ui.DummyUI_t = AllocateMemory(SizeOf(DummyUI_t))
    InitializeStructure(*ui,DummyUI_t)
    *ui\name = name
    *ui\container = ContainerGadget(#PB_Any,x,y,w,h)
    *ui\width = w
    *ui\height = h
    *ui\gadgetID = CanvasGadget(#PB_Any,0,20,w,h-20)
    *ui\VT = ?DummyVT
    *ui\active = #False
    View::SetContent(*parent,*ui)
    
;     Protected *args.Arguments::Arguments_t = Arguments::New()
;     Arguments::AddBool(*args,"Boolean",#True)
;     MessageRequester( "DUMMY CALLBACK","Nb Arguments : "+Str(*args\nb))
;     Protected *manager.ViewManager::ViewManager_t = *parent\manager
;     *ui\menu = ControlMenu::New(*manager\window,*ui\container,0,0,800,20)
;     Protected *files.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*ui\menu,"Files")
;     ControlMenu::AddItem(*files,"Save",@DummyCallback(),*args)
;     ControlMenu::AddItem(*files,"Load",@DummyCallback(),*args)
;     ControlMenu::AddItem(*files,"SaveAs",@DummyCallback(),*args)
;     
;     Protected *disk.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*ui\menu,"Disk")
;     ControlMenu::AddItem(*disk,"Save",@DummyCallback(),*args)
;     ControlMenu::AddItem(*disk,"Load",@DummyCallback(),*args)
;     ControlMenu::AddItem(*disk,"SaveAs",@DummyCallback(),*args)
;     
;     ControlMenu::Init(*ui\menu,"Test")
    
    CloseGadgetList()
    ProcedureReturn *ui
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*ui.DummyUI_t)
    ClearStructure(*ui,DummyUI_t)
    FreeMemory(*ui)
  EndProcedure

  
  ; Draw
  ;-------------------------------
  Procedure Draw(*ui.DummyUI_t)
    StartDrawing(CanvasOutput(*ui\gadgetID))
    DrawingMode(#PB_2DDrawing_Default)
    If *ui\active
      Box(0,0,GadgetWidth(*ui\gadgetID),GadgetHeight(*ui\gadgetID),RGB(Random(255),Random(255),Random(255)))
    Else
      Box(0,0,GadgetWidth(*ui\gadgetID),GadgetHeight(*ui\gadgetID),RGB(100,100,100))
    EndIf
    
    Protected txt.s = Str(*ui\width)+"x"+Str(*ui\height)
    Protected tx = GadgetWidth(*ui\gadgetID)/2 - TextWidth(txt)/2
    Protected ty = GadgetHeight(*ui\gadgetID)/2-6
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Globals::#FONT_LABEL))
    
    DrawText(tx,ty,txt)
    
    DrawingMode(#PB_2DDrawing_Outlined)
    RoundBox(2,2,GadgetWidth(*ui\gadgetID)-4,GadgetHeight(*ui\gadgetID)-4,4,4,RGB(60,60,60))
    StopDrawing()
  EndProcedure
  
  ; Init
  ;-------------------------------
  Procedure Init(*ui.DummyUI_t)
    Debug "DUmmyUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*ui.DummyUI_t,event.i)
    
   
    Select event
      Case #PB_Event_SizeWindow
        Protected *top.View::View_t = *ui\top
        Protected width.i = *top\width
        Protected height.i = *top\height
        
        *ui\width = width
        *ui\height = height
        ResizeGadget(*ui\container,*top\x,*top\y,width,height)
        ResizeGadget(*ui\gadgetID,0,0,width,height)
  
      Case #PB_Event_Gadget
        Protected g = EventGadget()
        If g= *ui\gadgetID
          Select EventType()
            Case #PB_EventType_Focus
              *ui\active = #True
            Case #PB_EventType_LostFocus
              *ui\active = #True
              
          EndSelect
          
        EndIf
        
        
    EndSelect
     Draw(*ui)
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*ui.DummyUI_t)
    Debug "DUmmyUI Term Called!!!"
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 121
; FirstLine = 117
; Folding = --
; EnableXP