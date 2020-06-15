
XIncludeFile "UI.pbi"
; XIncludeFile "Command.pbi"

; -----------------------------------------
; DummyUI Module Declaration
; -----------------------------------------
DeclareModule DummyUI
  Structure DummyUI_t Extends UI::UI_t
    ;*menu.ControlMenu::ControlMenu_t
  EndStructure
  
  Interface IDummyUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*Me.DummyUI_t)
  Declare Draw(*Me.DummyUI_t)
  Declare OnEvent(*Me.DummyUI_t,event.i)
  
  DataSection 
    DummyUIVT: 
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
      Data.i UI::@DrawPickImage()
      Data.i UI::@Pick()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; DummyUI Module Implementation
; -----------------------------------------
Module DummyUI
  
  Procedure DummyCallback(*args.Arguments::Arguments_t)
    MessageRequester( "DUMMY CALLBACK","Nb Arguments : "+Str(ArraySize(*args\args())))
  EndProcedure
  
  ; New
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s)
    Protected x = *parent\posX
    Protected y = *parent\posY
    Protected w = *parent\sizX
    Protected h = *parent\sizY
    
    Protected *Me.DummyUI_t = AllocateMemory(SizeOf(DummyUI_t))
    Object::INI(DummyUI)
    *Me\name = name
    *Me\sizX = w
    *Me\sizY = h
    *Me\gadgetID = CanvasGadget(#PB_Any,x,y,w,h)
    *Me\active = #False
    View::SetContent(*parent,*Me)
    
;     Protected *args.Arguments::Arguments_t = Arguments::New()
;     Arguments::AddBool(*args,"Boolean",#True)
;     MessageRequester( "DUMMY CALLBACK","Nb Arguments : "+Str(*args\nb))
;     Protected *manager.ViewManager::ViewManager_t = *parent\manager
;     *Me\menu = ControlMenu::New(*manager\window,*Me\container,0,0,800,20)
;     Protected *files.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"Files")
;     ControlMenu::AddItem(*files,"Save",@DummyCallback(),*args)
;     ControlMenu::AddItem(*files,"Load",@DummyCallback(),*args)
;     ControlMenu::AddItem(*files,"SaveAs",@DummyCallback(),*args)
;     
;     Protected *disk.ControlMenu::ControlSubMenu_t = ControlMenu::Add(*Me\menu,"Disk")
;     ControlMenu::AddItem(*disk,"Save",@DummyCallback(),*args)
;     ControlMenu::AddItem(*disk,"Load",@DummyCallback(),*args)
;     ControlMenu::AddItem(*disk,"SaveAs",@DummyCallback(),*args)
;     
;     ControlMenu::Init(*Me\menu,"Test")
    
    CloseGadgetList()
    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.DummyUI_t)
    FreeGadget(*Me\gadgetID)
    Object::TERM(DummyUI)
  EndProcedure

  
  ; Draw
  ;-------------------------------
  Procedure Draw(*Me.DummyUI_t)
    StartVectorDrawing(CanvasOutput(*Me\gadgetID))
    DrawingMode(#PB_2DDrawing_Default)
    If *Me\active
      AddPathBox(0,0,GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
      VectorSourceColor(RGBA(Random(255),Random(255),Random(255),255))
      FillPath()
    Else
      AddPathBox(0,0,GadgetWidth(*Me\gadgetID),GadgetHeight(*Me\gadgetID))
      VectorSourceColor(RGBA(100,100,100,255))
      FillPath()
    EndIf
    
    Protected txt.s = Str(*Me\sizX)+"x"+Str(*Me\sizY)
    Protected tx = GadgetWidth(*Me\gadgetID)/2 - TextWidth(txt)/2
    Protected ty = GadgetHeight(*Me\gadgetID)/2-6
    VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_LABEL)
    MovePathCursor(tx,ty)
    DrawVectorText(txt)
    
    Vector::RoundBoxPath(2,2,GadgetWidth(*Me\gadgetID)-4,GadgetHeight(*Me\gadgetID)-4,4)
    VectorSourceColor(RGBA(60,60,60,255))
    FillPath()
    StopVectorDrawing()
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.DummyUI_t,event.i)
    
   
    Select event
      Case #PB_Event_SizeWindow
        Protected *top.View::View_t = *Me\parent
        Protected width.i = *top\sizX
        Protected height.i = *top\sizY
        
        *Me\sizX = width
        *Me\sizY = height
        ResizeGadget(*Me\gadgetID,*top\posX,*top\posY,width,height)
  
      Case #PB_Event_Gadget
        Protected g = EventGadget()
        If g= *Me\gadgetID
          Select EventType()
            Case #PB_EventType_Focus
              *Me\active = #True
            Case #PB_EventType_LostFocus
              *Me\active = #True
              
          EndSelect
          
        EndIf
        
        
    EndSelect
     Draw(*Me)
  EndProcedure
  

  
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 127
; FirstLine = 89
; Folding = --
; EnableXP