XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"

; ==============================================================================
;  CONTROL EDIT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlCombo

  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlCombo_t )
  ; ----------------------------------------------------------------------------
  Structure ControlCombo_t Extends Control::Control_t
    ; CControlCombo
    label.s
    over.i
    down.i
    Array items.s(0)
    *on_press.Signal::Signal_t
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlCombo Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares
  ; ----------------------------------------------------------------------------
  Declare New(*parent.Control::Control_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  Declare Delete(*Me.ControlCombo_t)
  Declare Draw( *Me.ControlCombo_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlCombo_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare OnPress(*Me.ControlCombo_t)
  Declare SetTheme( theme.i )
  Declare.b Init()
  Declare.b Term()
  
  
  ; ============================================================================
  ;  VTABLE ( CObject + CControl + CControlCombo )
  ; ============================================================================
  ;{
  DataSection
    ControlComboVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()  ; mandatory override
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
    
  EndDataSection
  ;}
  
  Global CLASS.Class::Class_t
 
EndDeclareModule

; ==============================================================================
;  CONTROL COMBO IMPLEMENTATION ( Helpers )
; ==============================================================================
Module ControlCombo
  
  ;{
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlCombo_t, xoff.i = 0, yoff.i = 0 )
  
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = UIColor::COLORA_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont( FontID(Globals::#FONT_DEFAULT ))
    Protected ty = ( *Me\sizY - VectorTextHeight( *Me\label ) )/2 + yoff
    
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
      AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
      VectorSourceColor(UIColor::RANDOMIZED)
      FillPath()
     
      ; ---[ Disabled Text ]----------------------------------------------------
      tc = UIColor::COLORA_LABEL_DISABLED
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
        ; ---[ Negate Text ]----------------------------------------------------
        tc = UIColor::COLORA_LABEL_NEG
      ; ---[ Up ]---------------------------------------------------------------
      Else
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
      EndIf
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
        ; ---[ Negate Text ]----------------------------------------------------
        tc = UIColor::COLORA_LABEL_NEG
      ; °°°[ Up ]---------------------------------------------------------------
      Else
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
      EndIf
    EndIf
      
    ; ---[ Draw Label ]---------------------------------------------------------
    MovePathCursor(10 + xoff, ty)
    VectorSourceColor(tc)
    DrawVectorText( *Me\label)
    
  EndProcedure
  ;}
  
  
  Procedure OnPress(*Me.ControlCombo_t)
    MessageRequester("COMBO", "PRESSED")
  EndProcedure
  
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure OnEvent( *Me.ControlCombo_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;    Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;    Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version < 560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        ; ...[ Reset Height ]...................................................
        *Me\sizY = 21
        ; ...[ Update Topology ]................................................
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;    MouseEnter
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;    MouseLeave
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;    MouseMove
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        If *Me\visible And *Me\enable
          If *Me\down
            If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
              If *Me\over : *Me\over = #False : Control::Invalidate(*Me) : EndIf
            Else
              If Not *Me\over : *Me\over = #True : Control::Invalidate(*Me) : EndIf
            EndIf
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;    LeftButtonDown
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable And *Me\over
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;    LeftButtonUp
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
          Control::Invalidate(*Me)
          If *Me\over
            Signal::Trigger(*Me\on_press, Signal::#SIGNAL_TYPE_PING)
            ;PostEvent(Globals::#EVENT_COMBO_PRESSED,EventWindow(),*Me\object,#Null,@*Me\name)
          EndIf
        EndIf
        
      ; ------------------------------------------------------------------------
      ;    Enable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
  
      ; ------------------------------------------------------------------------
      ;    Disable
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
  ;  IMPLEMENTATION ( CControlCombo )
  ; ============================================================================
  ;{
  ; ---[ SetLabel ]-------------------------------------------------------------
  Procedure SetLabel( *Me.ControlCombo_t, value.s )
    
    ; ---[ Set String Value ]---------------------------------------------------
    *Me\label = value
    
  EndProcedure
  ; ---[ GetLabel ]-------------------------------------------------------------
  Procedure.s GetLabel( *Me.ControlCombo_t )
    
    ; ---[ Return String Value ]------------------------------------------------
    ProcedureReturn( *Me\label )
    
  EndProcedure
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlCombo_t )
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  ;}
  
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlCombo_t = AllocateMemory( SizeOf(ControlCombo_t) )
    
;     *Me\VT = ControlComboVT
;     *Me\classname = "CONTROLCOMBO"
    Object::INI(ControlCombo)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type        = Control::#COMBO
    *Me\name        = name
    *Me\parent      = *parent
    *Me\gadgetID    = *parent\gadgetID
    *Me\posX        = x
    *Me\posY        = y
    *Me\sizX        = width
    *Me\sizY        = 21
    *Me\visible     = #True
    *Me\enable      = #True
    *Me\options     = options
    
    *Me\on_press    = Object::NewSignal(*Me, "OnPress")

    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  
  
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  Procedure SetTheme( theme.i)
    
    Select theme
        
      ; ---[ Light ]------------------------------------------------------------
      Case Globals::#GUI_THEME_LIGHT
      
        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARK
        

    EndSelect
    
  EndProcedure
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  ControlsComboInitOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Init(  )

    SetTheme(Globals::#GUI_THEME_LIGHT)
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  ControlsComboTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )

    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlCombo )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 310
; FirstLine = 265
; Folding = ---
; EnableXP