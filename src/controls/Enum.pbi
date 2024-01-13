XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Control.pbi"

DeclareModule ControlEnum
  
  Global COLOR_DEFAULT = RGBA(140,140,140,255)
  Global COLOR_OVER = RGBA(150,150,150,255)
  Global COLOR_DOWN = RGBA(255,140,120,255)
  
  #Enum_Border_Spacing = 4
  #Enum_Item_Height = 24
  
  Structure ControlEnum_t Extends Control::Control_t
    label.s
    current.i
    window.i
    popup_width.i
    popup_height.i
    popup_gadget.i
    Array items.Globals::KeyValue_t(0)
  EndStructure
  
  Interface IControlEnum Extends Control::IControl
  EndInterface

  Declare New(*parent.Control::Control_t,name.s,label.s,x.i,y.i,width.i,height.i)
  Declare Delete(*Me.ControlEnum_t)
  Declare Draw(*Me.ControlEnum_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent(*Me.ControlEnum_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null)
  Declare AddItem(*Me.ControlEnum_t, name.s, value.i)
  
  DataSection 
    ControlEnumVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
EndDeclareModule

Module ControlEnum
  UseModule Globals
  
  Procedure Draw(*Me.ControlEnum_t, xoff.i = 0, yoff.i = 0 )
    AddPathBox(*Me\posX+#Enum_Border_Spacing, *Me\posY+#Enum_Border_Spacing, *Me\sizX-2*#Enum_Border_Spacing, *Me\sizY-#Enum_Border_Spacing)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    
    VectorFont(FontID(font_label),12)
    Define offsety.i = *Me\sizY - VectorTextHeight(*Me\label)
    MovePathCursor( *Me\posX + #Enum_Border_Spacing, *Me\posY + offsety + #Enum_Border_Spacing)
    VectorSourceColor(UIColor::COLOR_LABEL)
    DrawVectorText(*Me\label)
    
    Define lwidth.i = VectorTextWidth(*Me\label) 
    Define hwidth.i = *Me\sizX * 0.5
    
    MovePathCursor(lwidth + #Enum_Border_Spacing, *Me\sizY + #Enum_Border_Spacing + *Me\sizY - #Enum_Border_Spacing)
    AddPathLine(hwidth-lwidth - 2 * #Enum_Border_Spacing, 0, #PB_Path_Relative)
    StrokePath(1)
    
    AddPathBox(*Me\posX + hwidth + #Enum_Border_Spacing, *Me\posY + #Enum_Border_Spacing, hwidth - 2 * #Enum_Border_Spacing, *Me\sizY)
    VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
    StrokePath(1)

    MovePathCursor(*Me\posX + *Me\sizX - 16, *Me\posY + 2 * #Enum_Border_Spacing)
    AddPathLine(8,0, #PB_Path_Relative)
    AddPathLine(-4,6, #PB_Path_Relative)
    AddPathLine(-4,-6, #PB_Path_Relative)
    FillPath()
    
    If *Me\items(*Me\current)
      VectorSourceColor(UIColor::COLOR_LABEL_MARKED)
      MovePathCursor( *Me\posX + hwidth +#Enum_Border_Spacing, *Me\posY + offsety + #Enum_Border_Spacing)
      DrawVectorText(*Me\items(*Me\current)\key)
      FillPath()
    EndIf
  EndProcedure
  
  Procedure AddItem(*Me.ControlEnum_t, name.s, value.i)
    Define last = ArraySize(*Me\items())
    ReDim *Me\items(last+1)
    *Me\items(last)\key = name
    *Me\items(last)\value = value
  EndProcedure
  
  Procedure PopupSize(*Me.ControlEnum_t)
    *Me\popup_width = 64
    *Me\popup_height = ArraySize(*Me\items()) * #Enum_Item_Height
  EndProcedure
  
  Procedure DrawPopup(*Me.ControlEnum_t, mx.f, my.f)
    StartVectorDrawing(CanvasVectorOutput(*Me\popup_gadget))
    Define i.i = 0
    Define current.i = -1
    For i=0 To ArraySize(*Me\items())-1
      AddPathBox(0, i * #Enum_Item_Height, *Me\popup_width, #Enum_Item_Height)
      If IsInsidePath(mx, my)
        VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
        current = i
      Else
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
      EndIf
      
      FillPath()
      VectorFont(FontID(font_label), 16)
      MovePathCursor(#Enum_Border_Spacing, i * #Enum_Item_Height + #Enum_Border_Spacing)
      AddPathText(*Me\items(i)\key)
      
      VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
      FillPath()
    Next
    StopVectorDrawing()
    ProcedureReturn current
  EndProcedure
  
  Procedure Popup(*Me.ControlEnum_t)
    PopupSize(*Me)
    Define parent = EventWindow()
    Define mx = (GadgetX(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posX + *Me\sizX - #Enum_Border_Spacing) - *Me\popup_width
    Define my = GadgetY(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posY + #Enum_Border_Spacing
    Define window = OpenWindow(#PB_Any,mx, my, *Me\popup_width,*Me\popup_height, "", #PB_Window_BorderLess,WindowID(*Me\window))
    StickyWindow(window,#True)
    
    Define *ui.UI::UI_t = Control::GetUI(*Me)
    Define *view.View::View_t = UI::GetView(*ui)

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
  
  Procedure OnEvent(*Me.ControlEnum_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null)
    
    Select ev_code
      
      Case Control::#PB_EventType_Draw
        If Not *ev_data : ProcedureReturn : EndIf
        
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ProcedureReturn( #True )
  
      Case #PB_EventType_Resize
        If Not *ev_data : ProcedureReturn : EndIf
        
        *Me\sizY = 20
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        ProcedureReturn( #True )
        
      Case #PB_EventType_LeftClick
        Debug "Popup Left Click Event"
        Popup(*Me)
        Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
        Control::Invalidate(*Me)

    EndSelect
  EndProcedure
  
  Procedure Delete(*Me.ControlEnum_t)
    Object::TERM(ControlEnum)
  EndProcedure
  
  Procedure New(*parent.Control::Control_t,name.s,label.s,x.i,y.i,width.i,height.i)
    Protected *Me.ControlEnum_t = AllocateStructure(ControlEnum_t)
    Object::INI(ControlEnum)
    *Me\parent = *parent
    *Me\type = Control::#ENUM
    *Me\gadgetID = *parent\gadgetID
    *Me\posX=x
    *Me\posY=y
    *Me\sizX=width
    *Me\sizY=height
    *Me\name=name
    *Me\label = label
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    ProcedureReturn *Me
  EndProcedure
  
EndModule



; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 191
; FirstLine = 159
; Folding = --
; EnableXP