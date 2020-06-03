XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/UIColor.pbi"

; ==============================================================================
;  CONTROL BUTTON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlButton
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlButton_t )
  ; ----------------------------------------------------------------------------
  Structure ControlButton_t Extends Control::Control_t
    ; CControlButton
    value.i
    label.s
    over.i
    down.i
    color_enabled.i
    color_disabled.i
    color_over.i
    color_pressed.i
    *on_click.Signal::Signal_t
    
  EndStructure
  
  Declare New( *parent.Control::Control_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21, color.i=8421504 )
  Declare Draw(*Me.ControlButton_t, xoff.i = 0, yoff.i = 0)
  Declare Delete(*Me.ControlButton_t)
  Declare OnEvent( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlButton )
  ; ============================================================================
  DataSection
    ControlButtonVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t


EndDeclareModule

; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlButton
;{
; ----------------------------------------------------------------------------
;  hlpDraw
; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlButton_t, xoff.i = 0, yoff.i = 0 )
  
  ;---[ Check Visible ]-------------------------------------------------------
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  ; ---[ Label Color ]--------------------------------------------------------
  Protected tc.i = UIColor::COLOR_LABEL
  
  ; ---[ Set Font ]-----------------------------------------------------------
  VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_LABEL)
  Protected tx = ( *Me\sizX - VectorTextWidth ( *Me\label ) )*0.5 + xoff
  Protected ty = (*Me\sizY - VectorTextHeight( *Me\label ) )*0.5+ yoff
  tx = Math::Max( tx, 3 + xoff )
  
  ; ---[ Check Disabled ]-----------------------------------------------------
  If Not *Me\enable
    AddPathBox(xoff, yoff, *Me\sizX, *Me\sizY)
    VectorSourceColor(*Me\color_disabled)
    FillPath()
    tc = UIColor::COLOR_LABEL_DISABLED
  Else
    ; ---[ Check Over ]-------------------------------------------------------
    If *Me\over
      If *Me\down Or  *Me\value < 0 
        AddPathBox(xoff, yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(*Me\color_pressed)
        FillPath()
        tc = UIColor::COLOR_LABEL_NEG
      Else
        AddPathBox(xoff, yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(*Me\color_over)
        FillPath()
      EndIf
    Else
      If *Me\down
        AddPathBox(xoff, yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(*Me\color_pressed)
        FillPath()
        tc = UIColor::COLOR_LABEL_NEG
      Else
        AddPathBox(xoff, yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(*Me\color_enabled)
        FillPath()
      EndIf
    EndIf
  EndIf  
  
  ; ---[ Draw Label ]---------------------------------------------------------
  MovePathCursor(tx, ty )
  VectorSourceColor(UIColor::COLOR_TEXT)
  DrawVectorText(*Me\label)
  
;   ; ---[ Check Visible ]----------------------------------------------------
;   If Not *Me\visible : ProcedureReturn( void ) : EndIf
;   
;   ; ---[ Label Color ]------------------------------------------------------
;   Protected tc.i = UIColor::Color_LABEL
;   
;   ; ---[ Set Font ]---------------------------------------------------------
;   DrawingFont(FontID(Globals::#FONT_LABEL ))
;   Protected tx = ( *Me\sizX - TextWidth ( *Me\label ) )/2 + xoff
;   Protected ty = ( *Me\sizY - TextHeight( *Me\label ) )/2 + yoff
;   tx = Math::Max( tx, 3 + xoff )
;   
;   DrawingMode(#PB_2DDrawing_Default)
;   ; ---[ Check Disabled ]---------------------------------------------------
;   If Not *Me\enable
;     Box(xoff, yoff, *Me\sizX, *Me\sizY, *Me\color_disabled)
;     tc = UIColor::Color_LABEL_DISABLED
;   Else
;     ; ---[ Check Over ]-----------------------------------------------------
;     If *Me\over
;       If *Me\down Or  *Me\value < 0 
;         RoundBox(xoff, yoff, *Me\sizX, *Me\sizY, 2, 2, *Me\color_pressed)
;         tc = UIColor::Color_LABEL_NEG
;       Else
;         RoundBox(xoff, yoff, *Me\sizX, *Me\sizY, 2, 2,*Me\color_over)
;       EndIf
;     Else
;       If *Me\down
;         RoundBox(xoff, yoff, *Me\sizX, *Me\sizY, 2, 2,*Me\color_pressed)
;         tc = UIColor::Color_LABEL_NEG
;       Else
;         RoundBox(xoff, yoff, *Me\sizX, *Me\sizY, 2, 2,*Me\color_enabled)
;       EndIf
;     EndIf
;   EndIf  
; 
;   ; ---[ Draw Label ]---------------------------------------------------------
;   DrawingMode(#PB_2DDrawing_Default|#PB_2DDrawing_Transparent)
;   DrawText( tx, ty, *Me\label, tc )
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i OnEvent( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
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
    Case #PB_EventType_Resize
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
      If *Me\visible And *Me\enable
        If *Me\down And *ev_data
          If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
            If *Me\over : *Me\over = #False : Control::Invalidate(*Me) : EndIf
          Else
            If Not *Me\over : *Me\over = #True : Control::Invalidate(*Me) : EndIf
          EndIf
        EndIf
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      If *Me\visible And *Me\enable And *Me\over
        *Me\down = #True
        Signal::Trigger(*Me\on_click, Signal::#SIGNAL_TYPE_PING)
        Control::Invalidate(*Me)
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
        *Me\down = #False
        If *Me\over And ( *Me\options & #PB_Button_Toggle )
          *Me\value*-1
        EndIf
        Control::Invalidate(*Me)
        If *Me\over
          Signal::Trigger(*Me\on_click,Signal::#SIGNAL_TYPE_PING)
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


; ============================================================================
;  IMPLEMENTATION ( ControlButton )
; ============================================================================
;{
; ---[ SetLabel ]-------------------------------------------------------------
Procedure SetLabel( *Me.ControlButton_t, value.s )
  
  ; ---[ Set String Value ]---------------------------------------------------
  *Me\label = value
  
EndProcedure
; ---[ GetLabel ]-------------------------------------------------------------
Procedure.s GetLabel( *Me.ControlButton_t )
  
  ; ---[ Return String Value ]------------------------------------------------
  ProcedureReturn( *Me\label )
  
EndProcedure


Procedure InitializeColors(*Me.ControlButton_t, color.i)
  Protected r.i  =Red(color)
  Protected g.i = Green(color)
  Protected b.i = Blue(color)
  
  Protected avg.i = (r+g+b)/3
  
  *Me\color_disabled = RGBA((r+avg)/2, (g+avg)/2, (b+avg)/2, 255)
  *Me\color_enabled = color
  *Me\color_over = RGBA(r+avg/3, g+avg/3, b+avg/3, 255)
  *Me\color_pressed = RGBA(r+avg/2, g+avg/2, b+avg/2, 255)
EndProcedure



; ============================================================================
;  DESTRUCTOR
; ============================================================================
Procedure Delete( *Me.ControlButton_t )
  ; ---[ Terminate Object (deallocate signals) ]------------------------------
  Object::TERM(ControlButton)
EndProcedure


; ============================================================================
;  CONSTRUCTOR
; ============================================================================
Procedure.i New( *parent.Control::Control_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 , color.i=8421504)
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *Me.ControlButton_t = AllocateMemory( SizeOf(ControlButton_t) )
  
  Object::INI(ControlButton)
    
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type       = Control::#BUTTON
  *Me\name       = name
  *Me\parent     = *parent
  *Me\gadgetID   = *parent\gadgetID
  *Me\posX       = x
  *Me\posY       = y
  *Me\sizX       = width
  *Me\sizY       = height
  *Me\visible    = #True
  *Me\enable     = #True
  *Me\options    = options
  *Me\value      = 1
  
  InitializeColors(*Me, color)

  If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
  If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
  
  ; ---[ Signals ]------------------------------------------------------------
  *Me\on_change = Object::NewSignal(*Me, "OnChange")
  *Me\on_click = Object::NewSignal(*Me, "OnClick")
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ProcedureReturn( *Me )
  
EndProcedure

  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlButton )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 332
; FirstLine = 300
; Folding = ---
; EnableXP