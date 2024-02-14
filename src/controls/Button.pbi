XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/UIColor.pbi"

; ==============================================================================
;  CONTROL BUTTON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlButton

  Structure ControlButton_t Extends Control::Control_t
    value.i
    label.s
    over.i
    down.i

    *on_click.Callback::Callback_t
    
  EndStructure
  
  Declare New( *parent.Control::Control_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21, color.i=8421504 )
  Declare Draw(*Me.ControlButton_t, xoff.i = 0, yoff.i = 0)
  Declare Delete(*Me.ControlButton_t)
  Declare OnEvent( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
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
  Procedure Draw( *Me.ControlButton_t, xoff.i = 0, yoff.i = 0 )

  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  Protected tc.i = UIColor::COLOR_LABEL
  
  VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_LABEL)
  Protected tx = ( *Me\sizX - VectorTextWidth ( *Me\label ) )*0.5 + xoff
  Protected ty = (*Me\sizY - VectorTextHeight( *Me\label ) )*0.5+ yoff
  tx = Math::Max( tx, 3 + xoff )
  
  Define ft = Control::FRAME_THICKNESS
  AddPathBox(xoff-ft, yoff-ft, *Me\sizX + 2* ft, *Me\sizY + 2* ft)
  VectorSourceColor(UIColor::COLOR_MAIN_BG)
  FillPath()
  
  If Not *Me\enable
    Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
    VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
    If Control::FRAME_THICKNESS
      FillPath(#PB_Path_Preserve)
      VectorSourceColor(UIColor::COLOR_FRAME_DISABLED)
      StrokePath(Control::FRAME_THICKNESS)
    Else
      FillPath()
    EndIf
    tc = UIColor::COLOR_LABEL_DISABLED
  Else    
    If *Me\down Or  *Me\value < 0 
      Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
      VectorSourceColor(UIColor::COLOR_ACTIVE_BG)
      If Control::FRAME_THICKNESS
        FillPath(#PB_Path_Preserve)
        VectorSourceColor(UIColor::COLOR_FRAME_ACTIVE)
        StrokePath(Control::FRAME_THICKNESS)
      Else
        FillPath()
      EndIf
      tc = UIColor::COLOR_LABEL_NEG
    ElseIf *Me\over
      Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
      VectorSourceColor(UIColor::COLOR_TERNARY_BG)
      If Control::FRAME_THICKNESS
        FillPath(#PB_Path_Preserve)
        VectorSourceColor(UIColor::COLOR_FRAME_OVERED)
        StrokePath(Control::FRAME_THICKNESS)
      Else
        FillPath()
      EndIf
      tc = UIColor::COLOR_LABEL_NEG
    Else
      Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY, Control::CORNER_RADIUS)
      VectorSourceColor(UIColor::COLOR_MAIN_BG   )
      If Control::FRAME_THICKNESS
        FillPath(#PB_Path_Preserve)
        VectorSourceColor(UIColor::COLOR_FRAME_DEFAULT)
        StrokePath(Control::FRAME_THICKNESS)
      Else
        FillPath()
      EndIf
    EndIf
    
  EndIf  
  
  MovePathCursor(tx, ty )
  VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
  DrawVectorText(*Me\label)
  
EndProcedure

; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
Procedure.i OnEvent( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Protected Me.Control::IControl = *Me

  Select ev_code
    Case Control::#PB_EventType_Draw
      Draw( *Me, *ev_data\xoff, *ev_data\yoff )
      ProcedureReturn( #True )
      
    Case #PB_EventType_Resize
      If Not *ev_data : ProcedureReturn : EndIf
      
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      If #PB_Ignore <> *ev_data\height : *Me\sizY = *ev_data\height : EndIf
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
        If *Me\down And *ev_data
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
        *Me\over = #False
        If *Me\options & #PB_Button_Toggle
          *Me\value*-1
        EndIf
        Callback::Trigger(*Me\on_click,Callback::#SIGNAL_TYPE_PING)
        Control::Invalidate(*Me)
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
;  IMPLEMENTATION ( ControlButton )
; ============================================================================
Procedure SetLabel( *Me.ControlButton_t, value.s )
  *Me\label = value
EndProcedure

Procedure.s GetLabel( *Me.ControlButton_t )
  ProcedureReturn( *Me\label )
EndProcedure

; ============================================================================
;  DESTRUCTOR
; ============================================================================
Procedure Delete( *Me.ControlButton_t )
  Object::TERM(ControlButton)
EndProcedure

; ============================================================================
;  CONSTRUCTOR
; ============================================================================
Procedure.i New( *parent.Control::Control_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 , color.i=8421504)
  
  Protected *Me.ControlButton_t = AllocateStructure(ControlButton_t)
  
  Object::INI(ControlButton)
    
  *Me\type       = Control::#Type_Button
  *Me\name       = name
  *Me\parent     = *parent
  *Me\gadgetID   = *parent\gadgetID
  *Me\posX       = x
  *Me\posY       = y
  *Me\sizX       = width
  *Me\sizY       = height
  *Me\fixedWidth = #False
  *Me\fixedHeight= #False
  *Me\percX      = -1
  *Me\percY      = -1
  *Me\visible    = #True
  *Me\enable     = #True
  *Me\options    = options
  *Me\value      = 1

  If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
  If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
  
  *Me\on_change = Object::NewCallback(*Me, "OnChange")
  *Me\on_click = Object::NewCallback(*Me, "OnClick")
  
  ProcedureReturn( *Me )
  
EndProcedure

  Class::DEF( ControlButton )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 229
; FirstLine = 188
; Folding = --
; EnableXP