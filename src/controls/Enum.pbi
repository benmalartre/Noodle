XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Control.pbi"

DeclareModule ControlEnum
  
  Global COLOR_DEFAULT = RGBA(140,140,140,255)
  Global COLOR_OVER = RGBA(150,150,150,255)
  Global COLOR_DOWN = RGBA(255,140,120,255)
  
  #ENUM_BORDER = 4
  #ENUM_ITEM_HEIGHT = 24
  
  ; ------------------------------------------------------------------
  ;   STRUCTURE
  ; ------------------------------------------------------------------ 
  Structure ControlEnum_t Extends Control::Control_t
    label.s
    current.i
    window.i
    popup_width.i
    popup_height.i
    popup_gadget.i
    Array items.Globals::KeyValue_t(0)
  EndStructure
  
  ; ------------------------------------------------------------------
  ;   DECLARE
  ; ------------------------------------------------------------------ 
  Declare New(gadgetID.i,x.i, y.i, width.i, height.i, name.s)
  Declare Delete(*Me.ControlEnum_t)
  Declare Draw(*Me.ControlEnum_t)
  Declare DrawPickImage(*Me.ControlEnum_t, id.i)
  Declare OnEvent(*Me.ControlEnum_t)
  Declare AddItem(*Me.ControlEnum_t, name.s, value.i)
  
  ; ------------------------------------------------------------------
  ;   VTABLE ( Control )
  ; ------------------------------------------------------------------ 
  DataSection
    ControlEnumVT:
    Data.i @Delete()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
  EndDataSection
  
EndDeclareModule

Module ControlEnum
  UseModule Globals
  
  ; ------------------------------------------------------------------
  ;   DRAW
  ; ------------------------------------------------------------------ 
  Procedure Draw(*Me.ControlEnum_t)
    ; background
    AddPathBox(*Me\posX+#ENUM_BORDER, *Me\posY+#ENUM_BORDER, *Me\sizX-2*#ENUM_BORDER, *Me\sizY-#ENUM_BORDER)
    VectorSourceColor(UIColor::BACK)
    FillPath()
    
    ; label 
    VectorFont(FontID(font_label),12)
    Define offsety.i = *Me\sizY - VectorTextHeight(*Me\label)
    MovePathCursor( *Me\posX + #ENUM_BORDER, *Me\posY + offsety + #ENUM_BORDER)
    VectorSourceColor(UIColor::LABEL)
    DrawVectorText(*Me\label)
    
    Define lwidth.i = VectorTextWidth(*Me\label) 
    Define hwidth.i = *Me\sizX * 0.5
    
    MovePathCursor(lwidth + #ENUM_BORDER, *Me\sizY + #ENUM_BORDER + *Me\sizY - #ENUM_BORDER)
    AddPathLine(hwidth-lwidth - 2 * #ENUM_BORDER, 0, #PB_Path_Relative)
    StrokePath(1)
    
    ; value
    AddPathBox(*Me\posX + hwidth + #ENUM_BORDER, *Me\posY + #ENUM_BORDER, hwidth - 2 * #ENUM_BORDER, *Me\sizY)
    VectorSourceColor(UIColor::CONTOUR)
    StrokePath(1)

    MovePathCursor(*Me\posX + *Me\sizX - 16, *Me\posY + 2 * #ENUM_BORDER)
    AddPathLine(8,0, #PB_Path_Relative)
    AddPathLine(-4,6, #PB_Path_Relative)
    AddPathLine(-4,-6, #PB_Path_Relative)
    FillPath()
    
    If *Me\items(*Me\current)
      VectorSourceColor(UIColor::DARK)
      MovePathCursor( *Me\posX + hwidth +#ENUM_BORDER, *Me\posY + offsety + #ENUM_BORDER)
      DrawVectorText(*Me\items(*Me\current)\key)
      FillPath()
    EndIf
  EndProcedure
  
  ; ------------------------------------------------------------------
  ;   DRAW PICK IMAGE
  ; ------------------------------------------------------------------ 
  Procedure DrawPickImage(*Me.ControlEnum_t, id.i)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(RGBA(id,0,0,255))
    FillPath()
  EndProcedure
  
  ; ------------------------------------------------------------------
  ;   ADD ITEM
  ; ------------------------------------------------------------------ 
  Procedure AddItem(*Me.ControlEnum_t, name.s, value.i)
    Define last = ArraySize(*Me\items())
    ReDim *Me\items(last+1)
    *Me\items(last)\key = name
    *Me\items(last)\value = value
  EndProcedure
  
  ; ------------------------------------------------------------------
  ;   CONSTRUCTOR
  ; ------------------------------------------------------------------ 
  Procedure New(gadgetID.i, x.i,y.i,width.i,height.i,name.s)
    Protected *Me.ControlEnum_t = AllocateStructure(ControlEnum_t)
    Object::INI(ControlEnum)
    *Me\type = Control::#ENUM
    *Me\gadgetID = gadgetID
    *Me\posX=x
    *Me\posY=y
    *Me\sizX=width
    *Me\sizY=height
    *Me\name=name
    *Me\label = name
    *Me\on_change = Object::NewSignal(*Me, "OnChange")
    ProcedureReturn *Me
  EndProcedure
  
  ; ------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ------------------------------------------------------------------ 
  Procedure Delete(*Me.ControlEnum_t)
    Object::TERM(ControlEnum)
  EndProcedure
  
  Procedure PopupSize(*Me.ControlEnum_t)
    *Me\popup_width = 64
    *Me\popup_height = ArraySize(*Me\items()) * #ENUM_ITEM_HEIGHT
  EndProcedure
  
  Procedure DrawPopup(*Me.ControlEnum_t, mx.f, my.f)
    StartVectorDrawing(CanvasVectorOutput(*Me\popup_gadget))
    Define i.i = 0
    Define current.i = -1
    For i=0 To ArraySize(*Me\items())-1
      AddPathBox(0, i * #ENUM_ITEM_HEIGHT, *Me\popup_width, #ENUM_ITEM_HEIGHT)
      If IsInsidePath(mx, my)
        VectorSourceColor(UIColor::LIGHT_H)
        current = i
      Else
        VectorSourceColor(UIColor::LIGHT)
      EndIf
      
      FillPath()
      VectorFont(FontID(font_label), 16)
      MovePathCursor(#ENUM_BORDER, i * #ENUM_ITEM_HEIGHT + #ENUM_BORDER)
      AddPathText(*Me\items(i)\key)
      
      VectorSourceColor(UIColor::DARK)
      FillPath()
    Next
    StopVectorDrawing()
    ProcedureReturn current
  EndProcedure
  
  
  Procedure Popup(*Me.ControlEnum_t)
    PopupSize(*Me)
    Define parent = EventWindow()
    Define mx = (GadgetX(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posX + *Me\sizX - #ENUM_BORDER) - *Me\popup_width
    Define my = GadgetY(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posY + #ENUM_BORDER
    Define window = OpenWindow(#PB_Any,mx, my, *Me\popup_width,*Me\popup_height, "", #PB_Window_BorderLess,WindowID(parent))
    StickyWindow(window,#True)
    *Me\popup_gadget = CanvasGadget(#PB_Any,0,0,WindowWidth(window, #PB_Window_InnerCoordinate), WindowHeight(window, #PB_Window_InnerCoordinate))
    Define done.b = #False
    Define event, eventType
    Protected debounce.i = 60
    Protected dt.i
    Protected init.b = #False
    Repeat
      event = WaitWindowEvent()
      If EventWindow() = window
        mx = WindowMouseX(window)
        my = WindowMouseY(window) 
;         PickPopup(*Me, mx, my)
        pick = DrawPopup(*Me, mx, my)
        leftbutton = Bool(event = #PB_Event_Gadget And EventType()=#PB_EventType_LeftClick); Or EventType() = #PB_EventType_LostFocus )
    
        If init = #True And leftbutton And pick > -1
          done = #True
          *Me\current = pick
        EndIf
        
     
;         
;         If *menu\dirty
;           DrawSubMenu(*menu,#True)
;         EndIf
        
        init = #True
      
      
      Else
        If dt>debounce And EventType() = #PB_EventType_LeftClick 
          done = #True
        EndIf
      EndIf
      dt+1
    Until done = #True
    
    FreeGadget(*Me\popup_gadget)
    CloseWindow(window)
    
  EndProcedure
  
  
  Procedure OnEvent(*Me.ControlEnum_t)
    Select EventType()
      Case #PB_EventType_LeftClick
        Popup(*Me)
        Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
        PostEvent(#PB_Event_Repaint, EventWindow(), *Me\gadgetID)
    EndSelect
    
  EndProcedure
  
EndModule



; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 117
; FirstLine = 113
; Folding = --
; EnableXP