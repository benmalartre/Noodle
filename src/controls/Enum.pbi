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
  UseModule Math
  
  Procedure Draw(*Me.ControlEnum_t, xoff.i = 0, yoff.i = 0 )

    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    ;     VectorSourceColor(UIColor::COLOR_MAIN_BG)
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath()
    
;     AddPathBox(*Me\posX + #Enum_Border_Spacing, *Me\posY + #Enum_Border_Spacing, *Me\sizX - 2 * #Enum_Border_Spacing, *Me\sizY)
;     VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
;     StrokePath(1)

    MovePathCursor(*Me\posX + *Me\sizX - 16, *Me\posY + 2 * #Enum_Border_Spacing)
    AddPathLine(8,0, #PB_Path_Relative)
    AddPathLine(-4,6, #PB_Path_Relative)
    AddPathLine(-4,-6, #PB_Path_Relative)
    FillPath()
    
    If *Me\items(*Me\current)
      VectorFont(FontID(Globals::#Font_Default), Globals::#Font_Size_Label)
      VectorSourceColor(UIColor::COLOR_LABEL_MARKED)
      MovePathCursor( *Me\posX +#Enum_Border_Spacing, *Me\posY + #Enum_Border_Spacing)
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
  
  Procedure DrawPopup(*Me.ControlEnum_t, canvas.i, mx.f, my.f)
    StartVectorDrawing(CanvasVectorOutput(canvas))
    Define i.i = 0
    Define current.i = -1
    For i=0 To ArraySize(*Me\items())-1
      AddPathBox(0, i * #Enum_Item_Height, GadgetWidth(canvas), #Enum_Item_Height)
      If IsInsidePath(mx, my)
        VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
        current = i
      Else
        VectorSourceColor(UIColor::COLOR_MAIN_BG)
      EndIf
      
      FillPath()
      VectorFont(FontID(Globals::#Font_Default), Globals::#Font_Size_Label)
      MovePathCursor(#Enum_Border_Spacing, i * #Enum_Item_Height + #Enum_Border_Spacing)
      AddPathText(*Me\items(i)\key)
      
      VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
      FillPath()
    Next
    StopVectorDrawing()
    ProcedureReturn current
  EndProcedure
  
  Procedure Popup(*Me.ControlEnum_t)
    Define width = *Me\sizX
    Define height = ArraySize(*Me\items()) * #Enum_Item_Height
    Define parent = EventWindow()
    Define mx = GadgetX(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posX
    Define my = GadgetY(*Me\gadgetID, #PB_Gadget_ScreenCoordinate) + *Me\posY
    
    Define window = OpenWindow(#PB_Any,mx, my, width, height, "", #PB_Window_BorderLess)
    StickyWindow(window,#True)
    
    Define *ui.UI::UI_t = Control::GetUI(*Me)
    Define *view.View::View_t = UI::GetView(*ui)

    Define canvas = CanvasGadget(#PB_Any,0,0,WindowWidth(window, #PB_Window_InnerCoordinate), WindowHeight(window, #PB_Window_InnerCoordinate))
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
        pick = DrawPopup(*Me, canvas, mx, my)
        leftbutton = Bool(event = #PB_Event_Gadget And EventType()=#PB_EventType_LeftClick); Or EventType() = #PB_EventType_LostFocus )
    
        If init = #True And leftbutton And pick > -1
          done = #True
          *Me\current = pick
        EndIf
        
        init = #True
      
      Else
        If dt>debounce And EventType() = #PB_EventType_LeftClick 
          done = #True
        EndIf
      EndIf
      dt+1
    Until done = #True
    
    FreeGadget(canvas)
    CloseWindow(window)
    SetActiveWindow(parent)
    
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
        
      Case #PB_EventType_LeftButtonDown
        Popup(*Me)
        Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
        Control::Invalidate(*Me)
 
      Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          If *Me\state & Control::#State_Focused : Control::SetCursor( *Me,#PB_Cursor_IBeam ) : EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )
        EndIf
      
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          
          Control::Invalidate(*Me)
          ProcedureReturn( #True )
        EndIf
        
      Case #PB_EventType_MouseMove
        
        If *Me\visible And *Me\enable
          
          Control::Invalidate(*Me)
          ProcedureReturn( #True )
        EndIf

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
    *Me\visible = #True
    *Me\enable = #True
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
; CursorPosition = 106
; FirstLine = 69
; Folding = --
; EnableXP