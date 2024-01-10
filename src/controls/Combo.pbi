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
    label.s
    over.i
    down.i
    Array items.s(0)
    *on_press.Callback::Callback_t
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
  
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlCombo_t, xoff.i = 0, yoff.i = 0 )
  
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    Protected tc.i = UIColor::COLOR_LABEL
    
    VectorFont( FontID(Globals::#FONT_DEFAULT ), Globals::#FONT_SIZE_TEXT)
    Protected ty = ( *Me\sizY - VectorTextHeight( *Me\label ) )/2 + yoff
    
    If Not *Me\enable
      AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
      VectorSourceColor(UIColor::RANDOMIZED)
      FillPath()
      tc = UIColor::COLOR_LABEL_DISABLED
    ElseIf *Me\over
      If *Me\down
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
        tc = UIColor::COLOR_LABEL_NEG
      Else
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
      EndIf
    Else
      If *Me\down
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
        tc = UIColor::COLOR_LABEL_NEG
      Else
        AddPathBox(0+xoff, 0+yoff, *Me\sizX, *Me\sizY)
        VectorSourceColor(UIColor::RANDOMIZED)
        FillPath()
      EndIf
    EndIf
      
    MovePathCursor(10 + xoff, ty)
    VectorSourceColor(tc)
    DrawVectorText( *Me\label)
    
  EndProcedure
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  Procedure OnEvent( *Me.ControlCombo_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    Protected Me.Control::IControl = *Me
  
    Select ev_code
        
      Case Control::#PB_EventType_Draw
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ProcedureReturn( #True )
        
      Case #PB_EventType_Resize
        If Not *ev_data : ProcedureReturn : EndIf
        *Me\sizY = 21
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        ProcedureReturn( #True )

      Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf

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
        
      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable And *Me\over
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
          Control::Invalidate(*Me)
          If *Me\over
            Callback::Trigger(*Me\on_press, Callback::#SIGNAL_TYPE_PING)
          EndIf
        EndIf
        
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ProcedureReturn( #True )
  
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ProcedureReturn( #True )
  
    EndSelect
    
    ProcedureReturn( #False )
  EndProcedure
  
  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlCombo )
  ; ============================================================================
  Procedure SetLabel( *Me.ControlCombo_t, value.s )
    *Me\label = value
  EndProcedure
  
  Procedure.s GetLabel( *Me.ControlCombo_t )
    ProcedureReturn( *Me\label )
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlCombo_t )
    Object::TERM(ControlCombo)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
    
    Protected *Me.ControlCombo_t = AllocateStructure(ControlCombo_t)
    Object::INI(ControlCombo)
    
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
    
    *Me\on_press    = Object::NewCallback(*Me, "OnPress")

    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    
    ProcedureReturn( *Me )
    
  EndProcedure

  Class::DEF( ControlCombo )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 72
; FirstLine = 57
; Folding = --
; EnableXP