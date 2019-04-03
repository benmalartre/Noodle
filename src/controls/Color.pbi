XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"

; ==============================================================================
;  CONTROL COLOR MODULE DECLARATION
; ==============================================================================
DeclareModule ControlColor
  Enumeration
    #ITEM_NONE
    #ITEM_RED
    #ITEM_GREEN
    #ITEM_BLUE
    #ITEM_COLOR
    #ITEM_MODE
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlColor_t )
  ; ----------------------------------------------------------------------------
  Structure ControlColor_t Extends Control::Control_t
    ; ControlColor
    label.s
    red.i
    green.i
    blue.i
    color.Math::c4f32
    over.b
    down.b
    item.i
  EndStructure
  
  Interface IControlColor Extends Control::IControl
    SetRed()
    SetGreen()
    SetBlue()
  EndInterface
  
  Declare New( name.s, label.s, *color.Math::c4f32, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 46 )
  Declare Delete(*Me.ControlColor_t)
  Declare Draw( *Me.ControlColor_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlColor_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetRed(*Me.ControlColor_t)
  Declare SetGreen(*Me.ControlColor_t)
  Declare SetBlue(*Me.ControlColor_t)
  
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlColor )
  ; ============================================================================
  DataSection
    ControlColorVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection

  
  Global CLASS.Class::Class_t


EndDeclareModule

; ==============================================================================
;  IMPLEMENTATION ( Helpers )
; ==============================================================================
Module ControlColor
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlColor_t, xoff.i = 0, yoff.i = 0 )
  
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf

    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = UIColor::COLORA_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont(FontID(Globals::#FONT_DEFAULT ),GLobals::#FONT_SIZE_LABEL)
    Protected tx = ( *Me\sizX - VectorTextWidth ( *Me\label ) )/2 + xoff
    Protected ty = ( *Me\sizY - VectorTextHeight( *Me\label ) )/2 + yoff
    tx = Math::Max( tx, 3 + xoff )
    
    Protected cw, ch
    ch = (*Me\sizY - 10) / 3
    cw = *Me\sizX - (3*ch+10)
    
    VectorSourceLinearGradient(5+xoff, 5+yoff, 5+xoff+cw, 5+yoff+ch)
    VectorSourceGradientColor(RGBA(0, 0, 0, 255), 0.0)
    VectorSourceGradientColor(RGBA(122, 0, 0, 255), 0.5)
    VectorSourceGradientColor(RGBA(255, 0, 0, 255), 1.0)
    
    AddPathBox(5+xoff,5+yoff,cw,ch)
    FillPath()
    
    VectorSourceLinearGradient(5+xoff, 5+yoff+ch, 5+xoff+cw, 5+yoff+2*ch)
    VectorSourceGradientColor(RGBA(0, 0, 0, 255), 0.0)
    VectorSourceGradientColor(RGBA(0, 122, 0, 255), 0.5)
    VectorSourceGradientColor(RGBA(0, 255, 0, 255), 1.0)
    
    AddPathBox(5+xoff,5+yoff+ch,cw,ch)
    FillPath()
    
    VectorSourceLinearGradient(5+xoff, 5+yoff+2*ch, 5+xoff+cw, 5+yoff+3*ch)
    VectorSourceGradientColor(RGBA(0, 0, 0, 255), 0.0)
    VectorSourceGradientColor(RGBA(0, 0, 122, 255), 0.5)
    VectorSourceGradientColor(RGBA(0, 0, 255, 255), 1.0)
    
    AddPathBox(5+xoff,5+yoff+2*ch,cw,ch)
    FillPath()


;     FrontColor($0000FF)
;     BackColor($000000)
;     LinearGradient(5+xoff, 5+yoff, 5+xoff+cw, 5+yoff+ch)    
;     Box(5+xoff,5+yoff,cw,ch)
;     FrontColor($00FF00)
;     LinearGradient(5+xoff, 5+yoff, 5+xoff+cw, 5+yoff+ch)   
;     Box(5+xoff,5+ch+yoff,cw,ch)
;     FrontColor($FF0000)
;     LinearGradient(5+xoff, 5+yoff, 5+xoff+cw, 5+yoff+ch)   
;     Box(5+xoff,5+2*ch+yoff,cw,ch, RGB(0,0,255))
;     
;     ; draw slider
;     DrawingMode(#PB_2DDrawing_Default)
;     Protected white = RGB(255,255,255)
;     Protected offset_r.f = cw * *Me\color\r-1
;     Protected offset_g.f = cw * *Me\color\g-1
;     Protected offset_b.f = cw * *Me\color\b-1
;     
;     Box(5+xoff + offset_r - 1, 5+yoff, 2 , ch, white)
;     Box(5+xoff + offset_g - 1, 5+ch+yoff, 2 , ch, white)
;     Box(5+xoff + offset_b - 1, 5+2*ch+yoff, 2 , ch, white)
;     
    ; draw color
    If *Me\item = #ITEM_COLOR
      Vector::RoundBoxPath(*Me\sizX - 3*ch + 8, 3+yoff, 3*ch+4, 3*ch+4, 2)
      VectorSourceColor(RGBA(122,122,122,255))
      FillPath()
    Else
      Vector::RoundBoxPath( *Me\sizX - 3*ch + 8, 3+yoff, 3*ch+4, 3*ch+4,2)
      VectorSourceColor(RGBA(0,0,0,255))
      FillPath()
    EndIf
    
    Vector::RoundBoxPath( *Me\sizX - 3*ch + 10, 5+yoff, 3*ch, 3*ch, 2)
    VectorSourceColor(RGBA(*Me\red, *Me\green, *Me\blue,255))
    FillPath()
   
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpPick
  ; ----------------------------------------------------------------------------
  Procedure hlpPick( *Me.ControlColor_t, mx.i = 0, my.i = 0 )

    If Not *Me\visible : ProcedureReturn : EndIf
    
    If mx < 5 Or mx > *Me\sizX - 5 Or my<5 Or my> *Me\sizY-5
      ProcedureReturn #ITEM_NONE
    EndIf
    
    Protected cw, ch
    ch = (*Me\sizY - 10) / 3
    cw = *Me\sizX - (3*ch+10)
    
    If mx > *Me\sizX - 3*ch + 10
      ProcedureReturn #ITEM_COLOR
    Else
      If my < 5+ch 
        ProcedureReturn #ITEM_RED
      ElseIf my < 5+2*ch
        ProcedureReturn #ITEM_GREEN
      ElseIf my <5+3*ch
        ProcedureReturn #ITEM_BLUE
      EndIf
    EndIf
    
    ProcedureReturn #ITEM_NONE
    
  EndProcedure

  
  
  ; ============================================================================
  ;  OVERRIDE ( Control )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlColor_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )

    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version < 560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Update Topology ]................................................
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        If #PB_Ignore <> *ev_data\height : *Me\sizY = *ev_data\height : EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  MouseEnter
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseLeave
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        Debug "mOUSE MOVE"
        Protected item = hlpPick(*Me, *ev_data\x - *ev_data\xoff, *ev_data\y - *ev_data\yoff)
        If item <> *Me\item
          *Me\item = item
          Control::Invalidate(*Me)
        EndIf
        If *Me\visible And *Me\enable
          If *Me\down
            Select *Me\item
              Case #ITEM_RED
                Debug "RED ITEM"
              Case #ITEM_GREEN
                Debug "GREEN ITEM"
              Case #ITEM_BLUE
                Debug "BLUE ITEM"
              Case #ITEM_COLOR
                Debug "COLOR ITEM"
              Case #ITEM_MODE
                Debug "MODE ITEM"
            EndSelect
            
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable And *Me\over
          *Me\down = #True
          Debug Str(*ev_data\x)+","+Str(*ev_data\y)+","+Str(*ev_data\xoff)+","+Str(*ev_data\yoff)
          *Me\item = hlpPick(*Me, *ev_data\x - *ev_data\xoff, *ev_data\y - *ev_data\yoff)
          Select *Me\item
            Case #ITEM_NONE
              Debug "PICK ITEM NODE"
            Case #ITEM_COLOR
              *Me\red = Random(255)
              *Me\green = Random(255)
              *Me\blue = Random(255)
              Color::Set(*Me\color, *Me\red/255, *Me\green/255, *Me\blue/255, 1)
              Debug "PICK ITEM COLOR"
            Case #ITEM_RED
              Debug "PICK ITEM RED"
            Case #ITEM_GREEN
              Debug "PICK ITEM GREEN"
            Case #ITEM_BLUE
              Debug "PICK ITEM BLUE"
          EndSelect
          
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
          If *Me\over And ( *Me\options & #PB_Button_Toggle )
  ;           *Me\value*-1
          EndIf
          Control::Invalidate(*Me)
          If *Me\over
  ;           PostEvent(Globals::#EVENT_BUTTON_PRESSED,EventWindow(),*Me\object,#Null,@*Me\name)
  ;           Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Enable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
      ; ------------------------------------------------------------------------
      ;  Disable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  ;}
  
  Procedure OnMessage(type.i, *up)
;     Protected *sig.Signal::Signal_t = *up
;     Protected *Me.ControlColor::ControlColor_t = *sig\rcv_inst
;     Protected Me.ControlColor::IControlColor = *Me
;     Select *sig\rcv_slot
;       Case 0:
;         SetRed(*Me)
;       Case 1:
;         SetGreen(*Me)
;       Case 2:
;         SetBlue(*Me)
;     EndSelect
    
  EndProcedure

  


  ; ============================================================================
  ;  IMPLEMENTATION ( ControlColor )
  ; ============================================================================
  ;{
  ; ---[ SetLabel ]-------------------------------------------------------------
  Procedure SetLabel( *Me.ControlColor_t, value.s )
    
    ; ---[ Set String Value ]---------------------------------------------------
    *Me\label = value
    
  EndProcedure
  ; ---[ GetLabel ]-------------------------------------------------------------
  Procedure.s GetLabel( *Me.ControlColor_t )
    
    ; ---[ Return String Value ]------------------------------------------------
    ProcedureReturn( *Me\label )
    
  EndProcedure
  
  Procedure SetRed(*ctrl.ControlColor::ControlColor_t)
    *ctrl\red = 255
    *ctrl\green = 0
    *ctrl\blue = 0
    Color::Set(*ctrl\color, *ctrl\red / 255, *ctrl\green/255, *ctrl\blue / 255, 1.0)
    Control::Invalidate(*ctrl)
  EndProcedure
  
  Procedure SetGreen(*ctrl.ControlColor::ControlColor_t)
    *ctrl\red = 0
    *ctrl\green = 255
    *ctrl\blue = 0
    Color::Set(*ctrl\color, *ctrl\red / 255, *ctrl\green/255, *ctrl\blue / 255, 1.0)
    Control::Invalidate(*ctrl)
  EndProcedure
  
  Procedure SetBlue(*ctrl.ControlColor::ControlColor_t)
    *ctrl\red = 0
    *ctrl\green = 0
    *ctrl\blue = 255
    Color::Set(*ctrl\color, *ctrl\red / 255, *ctrl\green/255, *ctrl\blue / 255, 1.0)
    Control::Invalidate(*ctrl)
  EndProcedure

  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlColor_t )
    Object::TERM(ControlColor)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New( name.s, label.s, *color.Math::c4f32, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 46 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlColor_t = AllocateMemory( SizeOf(ControlColor_t) )
    
    Object::INI(ControlColor)

    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type       = Control::#COLOR
    *Me\name       = name
    *Me\gadgetID   = #Null
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\options    = options
    Color::SetFromOther(*Me\color, *color)
    *Me\red        = *color\r * 255
    *Me\green      = *color\g * 255
    *Me\blue       = *color\b * 255
    
    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlColor )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 56
; Folding = ---
; EnableXP
; EnableUnicode