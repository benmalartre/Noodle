XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  CONTROL LABEL MODULE DECLARATION
; ==============================================================================
DeclareModule ControlLabel
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  Global Dim PenStyle.f(2)
  

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlLabel_t )
  ; ----------------------------------------------------------------------------
  Structure ControlLabel_t Extends Control::Control_t
  label.s
  value.i ; marked/unmarked
  over .i
  down.i
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlLabel Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  Declare New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 21 )
  Declare Delete(*Me.ControlLabel_t)
  Declare OnEvent( *Me.ControlLabel_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlLabelVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule


; ==============================================================================
;  CONTROL LABEL MODULE IMPLEMENTATTION
; ==============================================================================
Module ControlLabel
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlLabel_t, xoff.i = 0, yoff.i = 0 )
    
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i
    If *Me\value
      tc = UIColor::COLOR_LABEL_MARKED
    Else
      tc = UIColor::COLOR_LABEL
    EndIf
    
    ; ---[ Set Font ]-----------------------------------------------------------
    DrawingFont( FontID(Globals::#FONT_LABEL ))
    Protected ty = ( *Me\sizY - TextHeight( *Me\label ) )/2 + yoff
    
    ; ---[ Reset Clipping ]-----------------------------------------------------
  ;   raaResetClip()
    
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
      ; ...[ Disabled Text ]....................................................
      tc = UIColor::COLOR_LABEL_DISABLED
    EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected label.s = *Me\label
    Protected lalen.i = Len(label)
    Protected maxW .i = *Me\sizX
    Protected curW .i
    
    curW = TextWidth(label)
    While Len(label) And ( curW > maxW )
      label = Left( label, Len(label)-1 )
      curW = TextWidth(label)
    Wend
    If Len(label) <> lalen
      lalen = Len(label)
      label = Left( label, Math::Max( lalen - 2, 2 ) ) + ".."
    Else
      ;raaSetPen     ( $FF000000, 1 )
      ;raaSetPenStyle( #PenStyleCustom, @PenStyle(), 2 )
      LineXY     ( TextWidth(label)+5.0 + xoff, ty + 10, *Me\sizX-1 + xoff, ty + 10, UIColor::COLOR_LINE_DIMMED )
    EndIf
    
    ; ---[ Light Theme Marked Highlight ]---------------------------------------
    Box( -6 + xoff, ty-3, 6, 20, UIColor::COLOR_MAIN_BG )
    If *Me\value
      ;If raaGUIGetTheme() = #RAA_GUI_THEME_LIGHT
        RoundBox( -3 + xoff, ty-2, TextWidth(label)+6, 18, 5, 5, UIColor::COLOR_LABEL_MARKED )
        DrawingMode( #PB_2DDrawing_Outlined )
        RoundBox( -3 + xoff, ty-2, TextWidth(label)+6, 18, 5, 5, UIColor::COLOR_LABEL_DISABLED )
      ;Else
;         DrawingMode( #PB_2DDrawing_Outlined )
;         RoundBox( -3 + xoff, ty-2, TextWidth(label)+6, 18, 5, 5, Globals::COLOR_LABEL_MARKED_DIMMED )
;       EndIf
    EndIf
    
    ; ---[ Draw Label ]---------------------------------------------------------
    ;   raaClipBoxHole( 0 + xoff, 3 + yoff, *Me\sizX-24, *Me\sizY-6 )
    DrawingMode(#PB_2DDrawing_Default|#PB_2DDrawing_Transparent)
    DrawText( 0 + xoff, ty, *Me\label, tc )
    DrawingMode(#PB_2DDrawing_AlphaBlend)
  EndProcedure
  
  
  ; ============================================================================
  ;  OVERRIDE ( Control::IControl )
  ; ============================================================================

  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlLabel_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        hlpDraw( *Me.ControlLabel_t, *ev_data\xoff, *ev_data\yoff )
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
        
        ; ...[ Cancel Height Resize ]...........................................
        *Me\sizY = 21
        ; ...[ Update Status ]..................................................
        If #PB_Ignore <> *ev_data\width : *Me\sizX = *ev_data\width : EndIf
        If #PB_Ignore <> *ev_data\x     : *Me\posX = *ev_data\x     : EndIf
        If #PB_Ignore <> *ev_data\y     : *Me\posY = *ev_data\y     : EndIf
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
          If *Me\down
            If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
              If *Me\over
                If *Me\value : *Me\value = #False : Else : *Me\value = #True : EndIf
                *Me\over = #False
                Control::Invalidate(*Me)
              EndIf
            ElseIf Not *Me\over
              If *Me\value : *Me\value = #False : Else : *Me\value = #True : EndIf
              *Me\over = #True
              Control::Invalidate(*Me)
            EndIf
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable And *Me\over
          If *Me\value : *Me\value = #False : Else : *Me\value = #True : EndIf
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  LeftButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
          Control::Invalidate(*Me)
          If *Me\over
            ; TODO : >>> TRIGGER ACTION <<<
            Debug ">> Trigger ["+ *Me\label +"]/["+ Str(*Me\value) +"]"
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
  
  
  ; ============================================================================
  ;  IMPLEMENTATION ( Control::IControlLabel )
  ; ============================================================================
  ; ---[ SetLabel ]-------------------------------------------------------------
  Procedure SetLabel( *Me.ControlLabel_t, label.s )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If label = *Me\label
      ; ...[ Abort ]............................................................
      ProcedureReturn( void )
    EndIf
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
    
    ; ---[ Set Label ]----------------------------------------------------------
    *Me\label = label
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    Control::Invalidate(*Me)
    
  EndProcedure
  ; ---[ GetLabel ]-------------------------------------------------------------
  Procedure.s GetLabel( *Me.ControlLabel_t )
    
    ; ---[ Return Label ]-------------------------------------------------------
    ProcedureReturn( *Me\label )
    
  EndProcedure
  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetValue( *Me.ControlLabel_t, value.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If value = *Me\value
      ; ...[ Abort ]............................................................
      ProcedureReturn( void )
    EndIf
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
    
    ; ---[ Set Value ]----------------------------------------------------------
    *Me\value = value
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    Control::Invalidate(*Me)
    
  EndProcedure
  ; ---[ GetValue ]-------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlLabel_t )
    
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlLabel_t )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 21 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlLabel_t = AllocateMemory( SizeOf(ControlLabel_t) )
    
;     *Me\VT = ?ControlLabelVT
;     *Me\classname = "CONTROLLABEL"
    Object::INI(ControlLabel)
    *Me\object = *object
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#PB_GadgetType_Label
    *Me\name     = name
    *Me\gadgetID = #Null
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = 21
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\options  = options
    *Me\value    = value
    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    *Me\over     = #False
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlLabel )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 151
; FirstLine = 144
; Folding = --
; EnableXP