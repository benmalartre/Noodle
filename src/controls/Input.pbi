
XIncludeFile "../core/Object.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Time.pbi"

DeclareModule ControlInput
  #CARET_HEIGHT = 16
  #INPUT_BORDER = 4
  Structure ControlInput_t Extends Control::Control_t
    active.b
    down.b
    value.s
    caret_x.i
    caret_l.i
    caret_r.i
    caret_t.i
    label.s
    edit.b
    timer.i
  EndStructure
 
  Declare New(*parent.Control::Control_t,x.i, y.i, width.i, height.i, name.s, options.i=0)
  Declare Delete(*Me.ControlInput_t)
  Declare Draw( *Me.ControlInput_t, xoff.i = 0, yoff.i = 0 )
  Declare DrawPickImage(*Me.ControlInput_t, id.i)
  Declare OnEvent(*Me.ControlInput_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare OnTimer(*Me.ControlInput_t, delay.i=250)
  
  ; ------------------------------------------------------------------
  ;   VTABLE ( Control )
  ; ------------------------------------------------------------------ 
  DataSection
    ControlInputVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
 
EndDeclareModule

Module ControlInput
  UseModule Globals
  ; -------------------------------------------------------------
  ;   DRAW
  ; -------------------------------------------------------------
  Procedure Draw(*Me.ControlInput_t, xoff.i=0, yoff.i=0)
    ; background
    AddPathBox(*Me\posX+#INPUT_BORDER, *Me\posY+#INPUT_BORDER+xoff, *Me\sizX-2*#INPUT_BORDER+yoff, *Me\sizY-2*#INPUT_BORDER)
    VectorSourceColor(UIColor::RANDOMIZED)
    FillPath()
    
    ; label 
    VectorFont(FontID(font_label),12)
    Define offsety.i = *Me\sizY - VectorTextHeight(*Me\label)+yoff
    MovePathCursor( *Me\posX + #INPUT_BORDER, *Me\posY + offsety + #INPUT_BORDER)
    VectorSourceColor(UIColor::LABEL)
    DrawVectorText(*Me\label)
    
    Define lwidth.i = VectorTextWidth(*Me\label) + xoff
    Define hwidth.i = *Me\sizX * 0.5
    
    MovePathCursor(lwidth + #INPUT_BORDER, *Me\posY + #INPUT_BORDER + *Me\sizY - #INPUT_BORDER + yoff)
    AddPathLine(hwidth-lwidth - 2 * #INPUT_BORDER, 0, #PB_Path_Relative)
    VectorSourceColor(UIColor::CONTOUR)
    DashPath(1, 3)
    
    ; value
    AddPathBox(*Me\posX + hwidth + #INPUT_BORDER + xoff, *Me\posY + #INPUT_BORDER + yoff, hwidth - 2 * #INPUT_BORDER, *Me\sizY)
    If *Me\active
      VectorSourceColor(UIColor::DARK_H)
    Else
      VectorSourceColor(UIColor::DARK)
    EndIf
    
    FillPath()
    
    If *Me\caret_l > -1
      Define lw = VectorTextWidth(Left(*Me\value,*Me\caret_l))
      Define rw = VectorTextWidth(Right(*Me\value,*Me\caret_r))
      Define tw = VectorTextWidth(*Me\value)
      AddPathBox(*Me\posX + hwidth + #INPUT_BORDER + lw + xoff, *Me\posY + #INPUT_BORDER +2 + yoff, tw - (lw + rw), *Me\sizY - #INPUT_BORDER -4)
      VectorSourceColor(RGBA(Random(255), Random(255), Random(255),255))
      FillPath ()
    EndIf

    VectorSourceColor(UIColor::LIGHT)
    MovePathCursor( *Me\posX + hwidth +#INPUT_BORDER + xoff, *Me\posY + offsety + #INPUT_BORDER)
    DrawVectorText(*Me\value)
    
    ; caret
    If *Me\active And *Me\edit
      If Mod(*Me\caret_t, 2) = 0
        MovePathCursor(*Me\caret_x + *Me\posX + hwidth + #INPUT_BORDER + xoff, *Me\posY + offsety + #INPUT_BORDER)
        AddPathLine(0, #CARET_HEIGHT, #PB_Path_Relative)
        StrokePath(2)
      EndIf
    EndIf

  EndProcedure
  
  
  ; -------------------------------------------------------------
  ;   DRAW PICK IMAGE
  ; -------------------------------------------------------------
  Procedure DrawPickImage(*Me.ControlInput_t, id.i)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(RGBA(id, 0,0,255))
    FillPath()
  EndProcedure
  
  
  Procedure PositionToIndex(*Me.ControlInput_t, x)
    
  EndProcedure
  
  Procedure IndexToPosition(*Me.ControlInput_t, index)
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    VectorFont(FontID(font_label),12)
    Define twidth = VectorTextWidth(Left(*Me\value, index))
    StopVectorDrawing()
    ProcedureReturn twidth
  EndProcedure
  
  Procedure OnTimer(*Me.ControlInput_t, delay.i=250)
    Repeat
      Delay(delay)
      *Me\caret_t + 1
      PostEvent(#PB_Event_Timer, EventWindow(), *Me\gadgetID)
    ForEver
  EndProcedure
  

  ; -------------------------------------------------------------
  ;   CONSTRUCTOR
  ; -------------------------------------------------------------
  Procedure New(*parent.Control::Control_t, x.i,y.i,width.i,height.i,name.s, options.i=0)
    Protected *Me.ControlInput_t = AllocateMemory(SizeOf(ControlInput_t))
    Object::INI(ControlInput)
    *Me\parent    = *parent
    *Me\gadgetID  = *parent\gadgetID
    *Me\posX      = x
    *Me\posY      = y
    *Me\caret_l   = -1
    *Me\caret_r   = -1
    *Me\sizX      = width
    *Me\sizY      = height
    *Me\name      = name
    *Me\label     = name
    *Me\type      = Control::#INPUT
    *Me\options   = options
    *Me\on_change = Object::NewSignal(*Me, "OnChange")
    ProcedureReturn *Me
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   DESTRUCTOR
  ; -------------------------------------------------------------
  Procedure Delete(*Me.ControlInput_t)
    Object::TERM(ControlInput)
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   ON EVENT
  ; -------------------------------------------------------------
  Procedure OnEvent(*Me.ControlInput_t,ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    Select Event()
      Case #PB_Event_Gadget
        
        Select ev_code
          Case Control::#PB_EventType_Draw
            If Not *ev_data : ProcedureReturn : EndIf
            Draw( *Me, *ev_data\xoff, *ev_data\yoff )
            ProcedureReturn( #True )
      
          Case #PB_EventType_Resize
            Control::Invalidate(*Me)
            
          Case #PB_EventType_LeftButtonDown
            *Me\down = #True
            *Me\active = #True
            *Me\caret_l = 0
            *Me\caret_r = 7
            
          Case #PB_EventType_LeftButtonUp
            *Me\down = #False
            
          Case #PB_EventType_LeftDoubleClick
            *Me\edit = #True
            *Me\active = #True
            *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
            ;Time::StartTimer(*Me, @OnTimer())
            
          Case #PB_EventType_KeyDown
            Define key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Key)
            Define modifier = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
            Select key
              Case #PB_Shortcut_Return
                *Me\edit = #False
                *Me\active = #False
                *Me\caret_l = -1
                *Me\caret_r = -1
                Time::StopTimer(*Me)
                If *Me\value = "" : *Me\value = "0" : EndIf
                Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
                
              Case #PB_Shortcut_Back
                Define l = Len(*Me\value)
                If l > 0 : *Me\value = Left(*Me\value, l-1) : EndIf
               *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
               Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
            EndSelect
            
          Case #PB_EventType_Input
            Define key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Input)
            Define modifier = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)

            If *Me\edit
              If *Me\options & #PB_String_Numeric
                If Not ISNUMERIC(key) : ProcedureReturn : EndIf
                *Me\value + Chr(key)
                *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
              Else
                *Me\value + Chr(key)
                *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
              EndIf
            EndIf
            Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)

        EndSelect

    EndSelect
    
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlInput)
  
EndModule




; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 27
; FirstLine = 3
; Folding = --
; EnableXP