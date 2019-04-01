
XIncludeFile "Object.pbi"
XIncludeFile "Control.pbi"
DeclareModule Input
  #CARET_HEIGHT = 16
  #INPUT_BORDER = 4
  Structure Input_t Extends Control::Control_t
    value.s
    caret_x.i
    caret_l.i
    caret_r.i
    caret_t.i
    label.s
    options.i
    edit.b
    timer.i
    *on_change.Signal::Signal_t
  EndStructure
 
  Declare New(gadgetID.i,x.i, y.i, width.i, height.i, name.s, options.i=0)
  Declare Delete(*Me.Input_t)
  Declare Draw(*Me.Input_t)
  Declare DrawPickImage(*Me.Input_t, id.i)
  Declare OnEvent(*Me.Input_t)
  
  Macro ISNUMERIC(_key)
    (1-Bool(_key<>45 And _key<>46 And (_key<48 Or _key>57)))
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   VTABLE ( Control )
  ; ------------------------------------------------------------------ 
  DataSection
    InputVT:
    Data.i @Delete()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
  EndDataSection
 
EndDeclareModule

Module Input
  UseModule Constants
  ; -------------------------------------------------------------
  ;   DRAW
  ; -------------------------------------------------------------
  Procedure Draw(*Me.Input_t)
    ; background
    AddPathBox(*Me\x+#INPUT_BORDER, *Me\y+#INPUT_BORDER, *Me\width-2*#INPUT_BORDER, *Me\height-2*#INPUT_BORDER)
    VectorSourceColor(Color::BACK)
    FillPath()
    
    ; label 
    VectorFont(FontID(font_label),12)
    Define offsety.i = *Me\height - VectorTextHeight(*Me\label)
    MovePathCursor( *Me\x + #INPUT_BORDER, *Me\y + offsety + #INPUT_BORDER)
    VectorSourceColor(Color::LABEL)
    DrawVectorText(*Me\label)
    
    Define lwidth.i = VectorTextWidth(*Me\label) 
    Define hwidth.i = *Me\width * 0.5
    
    MovePathCursor(lwidth + #INPUT_BORDER, *Me\y + #INPUT_BORDER + *Me\height - #INPUT_BORDER)
    AddPathLine(hwidth-lwidth - 2 * #INPUT_BORDER, 0, #PB_Path_Relative)
    VectorSourceColor(Color::CONTOUR)
    DashPath(1, 3)
    
    ; value
    AddPathBox(*Me\x + hwidth + #INPUT_BORDER, *Me\y + #INPUT_BORDER, hwidth - 2 * #INPUT_BORDER, *Me\height)
    If *Me\active
      VectorSourceColor(Color::DARK_H)
    Else
      VectorSourceColor(Color::DARK)
    EndIf
    
    FillPath()
    
    If *Me\caret_l > -1
      Define lw = VectorTextWidth(Left(*Me\value,*Me\caret_l))
      Define rw = VectorTextWidth(Right(*Me\value,*Me\caret_r))
      Define tw = VectorTextWidth(*Me\value)
      AddPathBox(*Me\x + hwidth + #INPUT_BORDER + lw, *Me\y + #INPUT_BORDER +2, tw - (lw + rw), *Me\height - #INPUT_BORDER -4)
      VectorSourceColor(RGBA(Random(255), Random(255), Random(255),255))
      FillPath ()
    EndIf

    VectorSourceColor(Color::LIGHT)
    MovePathCursor( *Me\x + hwidth +#INPUT_BORDER, *Me\y + offsety + #INPUT_BORDER)
    DrawVectorText(*Me\value)
    
    ; caret
    If *Me\active And *Me\edit
      If Mod(*Me\caret_t, 2) = 0
        MovePathCursor(*Me\caret_x + *Me\x + hwidth + #INPUT_BORDER, *Me\y + offsety + #INPUT_BORDER)
        AddPathLine(0, #CARET_HEIGHT, #PB_Path_Relative)
        StrokePath(2)
      EndIf
    EndIf

  EndProcedure
  
  
  ; -------------------------------------------------------------
  ;   DRAW PICK IMAGE
  ; -------------------------------------------------------------
  Procedure DrawPickImage(*Me.Input_t, id.i)
    AddPathBox(*Me\x, *Me\y, *Me\width, *Me\height)
    VectorSourceColor(RGBA(id, 0,0,255))
    FillPath()
  EndProcedure
  
  
  Procedure PositionToIndex(*Me.Input_t, x)
    
  EndProcedure
  
  Procedure IndexToPosition(*Me.Input_t, index)
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    VectorFont(FontID(font_label),12)
    Define twidth = VectorTextWidth(Left(*Me\value, index))
    StopVectorDrawing()
    ProcedureReturn twidth
  EndProcedure
  
  
  
  ; -------------------------------------------------------------
  ;   TIMER
  ; -------------------------------------------------------------
  Procedure TimerCallback(*Me.Input_t)
    Repeat
      Delay(250)
      *Me\caret_t + 1
      PostEvent(#PB_Event_Timer, EventWindow(), *Me\gadgetID)
    ForEver
  EndProcedure
  
  Procedure StartTimer(*Me.Input_t)
    If Not IsThread(*Me\timer)
      *Me\timer = CreateThread(@TimerCallback(), *Me)
    EndIf
    
  EndProcedure
  
  Procedure StopTimer(*Me.Input_t)
    If IsThread(*Me\timer)
      KillThread(*Me\timer)
    EndIf
    *Me\timer = #Null
    
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   CONSTRUCTOR
  ; -------------------------------------------------------------
  Procedure New(gadgetID.i,x.i,y.i,width.i,height.i,name.s, options.i=0)
    Protected *Me.Input_t = AllocateMemory(SizeOf(Input_t))
    Object::INI(Input)
    *Me\gadgetID = gadgetID
    *Me\x=x
    *Me\y=y
    *Me\caret_l = -1
    *Me\caret_r = -1
    *Me\width=width
    *Me\height=height
    *Me\name=name
    *Me\label=name
    *Me\type = Control::#CONTROL_INPUT
    *Me\options = options
    *Me\on_change = Object::NewSignal(*Me, "OnChange")
    ProcedureReturn *Me
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   DESTRUCTOR
  ; -------------------------------------------------------------
  Procedure Delete(*Me.Input_t)
    Object::TERM(Input)
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   ON EVENT
  ; -------------------------------------------------------------
  Procedure OnEvent(*Me.Input_t)
    Select Event()
      Case #PB_Event_Gadget
        
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            *Me\down = #True
            *Me\active = #True
            *Me\caret_l = 0;GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX)
            *Me\caret_r = 7
            
          Case #PB_EventType_LeftButtonUp
            *Me\down = #False
            
          Case #PB_EventType_LeftDoubleClick
            *Me\edit = #True
            *Me\active = #True
            *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
            StartTimer(*Me)
      
          Case #PB_EventType_MouseMove
         
          Case #PB_EventType_KeyDown
            Define key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Key)
            Define modifier = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
            Select key
              Case #PB_Shortcut_Return
                *Me\edit = #False
                *Me\active = #False
                *Me\caret_l = -1
                *Me\caret_r = -1
                StopTimer(*Me)
                If *Me\value = "" : *Me\value = "0" : EndIf
                Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
                PostEvent(#PB_Event_Repaint, EventWindow(), *Me\gadgetID)
                
              Case #PB_Shortcut_Back
                Define l = Len(*Me\value)
                If l > 0 : *Me\value = Left(*Me\value, l-1) : EndIf
               *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
               Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
               PostEvent(#PB_Event_Repaint, EventWindow(), *Me\gadgetID)
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
            PostEvent(#PB_Event_Repaint, EventWindow(), *Me\gadgetID)
        EndSelect

    EndSelect
    
    
  EndProcedure
  
EndModule




; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 40
; Folding = ---
; EnableXP