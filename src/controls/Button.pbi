XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"

; ==============================================================================
;  CONTROL BUTTON MODULE DECLARATION
; ==============================================================================
DeclareModule ControlButton
  
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  Light
  ; ----------------------------------------------------------------------------
  ; ---[ Button Up ]------------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_button_up_normal_tl .i
  Global s_gui_controls_light_button_up_normal_tr .i
  Global s_gui_controls_light_button_up_normal_bl .i
  Global s_gui_controls_light_button_up_normal_br .i
  Global s_gui_controls_light_button_up_normal_cl .i
  Global s_gui_controls_light_button_up_normal_cr .i
  Global s_gui_controls_light_button_up_normal_ct .i
  Global s_gui_controls_light_button_up_normal_cb .i
  Global s_gui_controls_light_button_up_normal_cc .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_button_up_over_tl .i
  Global s_gui_controls_light_button_up_over_tr .i
  Global s_gui_controls_light_button_up_over_bl .i
  Global s_gui_controls_light_button_up_over_br .i
  Global s_gui_controls_light_button_up_over_cl .i
  Global s_gui_controls_light_button_up_over_cr .i
  Global s_gui_controls_light_button_up_over_ct .i
  Global s_gui_controls_light_button_up_over_cb .i
  Global s_gui_controls_light_button_up_over_cc .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_light_button_up_disabled_tl .i
  Global s_gui_controls_light_button_up_disabled_tr .i
  Global s_gui_controls_light_button_up_disabled_bl .i
  Global s_gui_controls_light_button_up_disabled_br .i
  Global s_gui_controls_light_button_up_disabled_cl .i
  Global s_gui_controls_light_button_up_disabled_cr .i
  Global s_gui_controls_light_button_up_disabled_ct .i
  Global s_gui_controls_light_button_up_disabled_cb .i
  Global s_gui_controls_light_button_up_disabled_cc .i

  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_button_down_normal_tl .i
  Global s_gui_controls_light_button_down_normal_tr .i
  Global s_gui_controls_light_button_down_normal_bl .i
  Global s_gui_controls_light_button_down_normal_br .i
  Global s_gui_controls_light_button_down_normal_cl .i
  Global s_gui_controls_light_button_down_normal_cr .i
  Global s_gui_controls_light_button_down_normal_ct .i
  Global s_gui_controls_light_button_down_normal_cb .i
  Global s_gui_controls_light_button_down_normal_cc .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_button_down_over_tl .i
  Global s_gui_controls_light_button_down_over_tr .i
  Global s_gui_controls_light_button_down_over_bl .i
  Global s_gui_controls_light_button_down_over_br .i
  Global s_gui_controls_light_button_down_over_cl .i
  Global s_gui_controls_light_button_down_over_cr .i
  Global s_gui_controls_light_button_down_over_ct .i
  Global s_gui_controls_light_button_down_over_cb .i
  Global s_gui_controls_light_button_down_over_cc .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_light_button_down_disabled_tl .i
  Global s_gui_controls_light_button_down_disabled_tr .i
  Global s_gui_controls_light_button_down_disabled_bl .i
  Global s_gui_controls_light_button_down_disabled_br .i
  Global s_gui_controls_light_button_down_disabled_cl .i
  Global s_gui_controls_light_button_down_disabled_cr .i
  Global s_gui_controls_light_button_down_disabled_ct .i
  Global s_gui_controls_light_button_down_disabled_cb .i
  Global s_gui_controls_light_button_down_disabled_cc .i

  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  ; ---[ Button Up ]------------------------------------------------------------
  ;{
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_button_up_normal_tl .i
  Global s_gui_controls_dark_button_up_normal_tr .i
  Global s_gui_controls_dark_button_up_normal_bl .i
  Global s_gui_controls_dark_button_up_normal_br .i
  Global s_gui_controls_dark_button_up_normal_cl .i
  Global s_gui_controls_dark_button_up_normal_cr .i
  Global s_gui_controls_dark_button_up_normal_ct .i
  Global s_gui_controls_dark_button_up_normal_cb .i
  Global s_gui_controls_dark_button_up_normal_cc .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_button_up_over_tl .i
  Global s_gui_controls_dark_button_up_over_tr .i
  Global s_gui_controls_dark_button_up_over_bl .i
  Global s_gui_controls_dark_button_up_over_br .i
  Global s_gui_controls_dark_button_up_over_cl .i
  Global s_gui_controls_dark_button_up_over_cr .i
  Global s_gui_controls_dark_button_up_over_ct .i
  Global s_gui_controls_dark_button_up_over_cb .i
  Global s_gui_controls_dark_button_up_over_cc .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_dark_button_up_disabled_tl .i
  Global s_gui_controls_dark_button_up_disabled_tr .i
  Global s_gui_controls_dark_button_up_disabled_bl .i
  Global s_gui_controls_dark_button_up_disabled_br .i
  Global s_gui_controls_dark_button_up_disabled_cl .i
  Global s_gui_controls_dark_button_up_disabled_cr .i
  Global s_gui_controls_dark_button_up_disabled_ct .i
  Global s_gui_controls_dark_button_up_disabled_cb .i
  Global s_gui_controls_dark_button_up_disabled_cc .i

  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_button_down_normal_tl .i
  Global s_gui_controls_dark_button_down_normal_tr .i
  Global s_gui_controls_dark_button_down_normal_bl .i
  Global s_gui_controls_dark_button_down_normal_br .i
  Global s_gui_controls_dark_button_down_normal_cl .i
  Global s_gui_controls_dark_button_down_normal_cr .i
  Global s_gui_controls_dark_button_down_normal_ct .i
  Global s_gui_controls_dark_button_down_normal_cb .i
  Global s_gui_controls_dark_button_down_normal_cc .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_button_down_over_tl .i
  Global s_gui_controls_dark_button_down_over_tr .i
  Global s_gui_controls_dark_button_down_over_bl .i
  Global s_gui_controls_dark_button_down_over_br .i
  Global s_gui_controls_dark_button_down_over_cl .i
  Global s_gui_controls_dark_button_down_over_cr .i
  Global s_gui_controls_dark_button_down_over_ct .i
  Global s_gui_controls_dark_button_down_over_cb .i
  Global s_gui_controls_dark_button_down_over_cc .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_dark_button_down_disabled_tl .i
  Global s_gui_controls_dark_button_down_disabled_tr .i
  Global s_gui_controls_dark_button_down_disabled_bl .i
  Global s_gui_controls_dark_button_down_disabled_br .i
  Global s_gui_controls_dark_button_down_disabled_cl .i
  Global s_gui_controls_dark_button_down_disabled_cr .i
  Global s_gui_controls_dark_button_down_disabled_ct .i
  Global s_gui_controls_dark_button_down_disabled_cb .i
  Global s_gui_controls_dark_button_down_disabled_cc .i
  
  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------
  ;{
  ; ---[ Button Up ]------------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_button_up_normal_tl
  Global s_gui_controls_button_up_normal_tr
  Global s_gui_controls_button_up_normal_bl
  Global s_gui_controls_button_up_normal_br
  Global s_gui_controls_button_up_normal_cl
  Global s_gui_controls_button_up_normal_cr
  Global s_gui_controls_button_up_normal_ct
  Global s_gui_controls_button_up_normal_cb
  Global s_gui_controls_button_up_normal_cc
  ; ...[ Over ].................................................................
  Global s_gui_controls_button_up_over_tl
  Global s_gui_controls_button_up_over_tr
  Global s_gui_controls_button_up_over_bl
  Global s_gui_controls_button_up_over_br
  Global s_gui_controls_button_up_over_cl
  Global s_gui_controls_button_up_over_cr
  Global s_gui_controls_button_up_over_ct
  Global s_gui_controls_button_up_over_cb
  Global s_gui_controls_button_up_over_cc
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_button_up_disabled_tl
  Global s_gui_controls_button_up_disabled_tr
  Global s_gui_controls_button_up_disabled_bl
  Global s_gui_controls_button_up_disabled_br
  Global s_gui_controls_button_up_disabled_cl
  Global s_gui_controls_button_up_disabled_cr
  Global s_gui_controls_button_up_disabled_ct
  Global s_gui_controls_button_up_disabled_cb
  Global s_gui_controls_button_up_disabled_cc

  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_button_down_normal_tl
  Global s_gui_controls_button_down_normal_tr
  Global s_gui_controls_button_down_normal_bl
  Global s_gui_controls_button_down_normal_br
  Global s_gui_controls_button_down_normal_cl
  Global s_gui_controls_button_down_normal_cr
  Global s_gui_controls_button_down_normal_ct
  Global s_gui_controls_button_down_normal_cb
  Global s_gui_controls_button_down_normal_cc
  ; ...[ Over ].................................................................
  Global s_gui_controls_button_down_over_tl
  Global s_gui_controls_button_down_over_tr
  Global s_gui_controls_button_down_over_bl
  Global s_gui_controls_button_down_over_br
  Global s_gui_controls_button_down_over_cl
  Global s_gui_controls_button_down_over_cr
  Global s_gui_controls_button_down_over_ct
  Global s_gui_controls_button_down_over_cb
  Global s_gui_controls_button_down_over_cc
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_button_down_disabled_tl
  Global s_gui_controls_button_down_disabled_tr
  Global s_gui_controls_button_down_disabled_bl
  Global s_gui_controls_button_down_disabled_br
  Global s_gui_controls_button_down_disabled_cl
  Global s_gui_controls_button_down_disabled_cr
  Global s_gui_controls_button_down_disabled_ct
  Global s_gui_controls_button_down_disabled_cb
  Global s_gui_controls_button_down_disabled_cc

  
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlButton_t )
  ; ----------------------------------------------------------------------------
  Structure ControlButton_t Extends Control::Control_t
    ; CControlButton
    value.i
    label.s
    over.i
    down.i
  EndStructure
  
  Declare New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  Declare Delete(*Me.ControlButton_t)
  Declare Event( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  Declare.b Init()
  Declare.b Term()
  Declare SetTheme(theme.i)
  
  ; ============================================================================
  ;  VTABLE ( CObject + CControl + CControlButton )
  ; ============================================================================
  ;{
    DataSection
    ControlButtonVT:
    Data.i @Event() ; mandatory override
    Data.i @Delete()
  
    ; Images
    ; (Light)
    VIControlButton_light_up_normal:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.up.normal.png"
    VIControlButton_light_up_over:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.up.over.png"
    VIControlButton_light_up_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.up.disabled.png"
    VIControlButton_light_down_normal:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.down.normal.png"
    VIControlButton_light_down_over:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.down.over.png"
    VIControlButton_light_down_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_button/light.button.down.disabled.png"
    
    ; (Dark)
    VIControlButton_dark_up_normal:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.up.normal.png"
    VIControlButton_dark_up_over:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.up.over.png"
    VIControlButton_dark_up_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.up.disabled.png"
    VIControlButton_dark_down_normal:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.down.normal.png"
    VIControlButton_dark_down_over:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.down.over.png"
    VIControlButton_dark_down_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_button/dark.button.down.disabled.png"
    
  EndDataSection
  ;}
  
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
Procedure hlpDraw( *Me.ControlButton_t, xoff.i = 0, yoff.i = 0 )

  ; ---[ Check Visible ]------------------------------------------------------
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  ; ---[ Label Color ]--------------------------------------------------------
  Protected tc.i = UIColor::Color_LABEL
  
  ; ---[ Set Font ]-----------------------------------------------------------
  DrawingFont(FontID(Globals::#FONT_LABEL ))
  Protected tx = ( *Me\sizX - TextWidth ( *Me\label ) )/2 + xoff
  Protected ty = ( *Me\sizY - TextHeight( *Me\label ) )/2 + yoff
  tx = Math::Max( tx, 3 + xoff )
  
  ; ---[ Reset Clipping ]-----------------------------------------------------
;   raaResetClip()
  
  ; ---[ Check Disabled ]-----------------------------------------------------
  If Not *Me\enable
    ; 같�[ Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    If *Me\value < 0
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_down_disabled_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_disabled_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_disabled_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_disabled_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_disabled_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_down_disabled_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_disabled_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_down_disabled_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_down_disabled_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
    ; 같�[ Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    Else
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_up_disabled_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_disabled_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_disabled_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_disabled_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_disabled_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_up_disabled_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_disabled_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_up_disabled_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_up_disabled_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
    EndIf
    ; ...[ Disabled Text ]....................................................
    tc = UIColor::Color_LABEL_DISABLED
  ; ---[ Check Over ]---------------------------------------------------------
  ElseIf *Me\over
    ; 같�[ Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    If *Me\down Or ( *Me\value < 0 )
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_down_over_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_over_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_over_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_over_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_over_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_down_over_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_over_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_down_over_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_down_over_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
      ; ...[ Negate Text ]....................................................
      tc = UIColor::Color_LABEL_NEG
    ; 같�[ Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    Else
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_up_over_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_over_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_over_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_over_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_over_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_up_over_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_over_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_up_over_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_up_over_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
    EndIf
  ; ---[ Normal State ]-------------------------------------------------------
  Else
    ; 같�[ Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    If *Me\value < 0
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_down_normal_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_normal_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_normal_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_down_normal_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_normal_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_down_normal_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_down_normal_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_down_normal_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_down_normal_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
      ; ...[ Negate Text ]....................................................
      tc = UIColor::Color_LABEL_NEG
    ; 같�[ Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    Else
      ; ...[ Draw Corners ]...................................................
      DrawImage( ImageID(s_gui_controls_button_up_normal_tl),            0 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_normal_tr), *Me\sizX - 6 + xoff,            0 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_normal_bl),            0 + xoff, *Me\sizY - 6 + yoff )
      DrawImage( ImageID(s_gui_controls_button_up_normal_br), *Me\sizX - 6 + xoff, *Me\sizY - 6 + yoff )
      ; ...[ V Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_normal_cl),            0 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      DrawImage( ImageID(s_gui_controls_button_up_normal_cr), *Me\sizX - 6 + xoff,            6 + yoff,             6, *Me\sizY - 12 )
      ; ...[ H Centers ]......................................................
      DrawImage( ImageID(s_gui_controls_button_up_normal_ct),            6 + xoff,            0 + yoff, *Me\sizX - 12,             6 )
      DrawImage( ImageID(s_gui_controls_button_up_normal_cb),            6 + xoff, *Me\sizY - 6 + yoff, *Me\sizX - 12,             6 )
      ; ...[ Center Area ]....................................................
      DrawImage( ImageID(s_gui_controls_button_up_normal_cc),            6 + xoff,            6 + yoff, *Me\sizX - 12, *Me\sizY - 12 )
    EndIf
  EndIf
    
  ; ---[ Draw Label ]---------------------------------------------------------
  ;   raaClipBoxHole( 3 + xoff, 3 + yoff, *Me\sizX-6, *Me\sizY-6 )
  DrawingMode(#PB_2DDrawing_Default|#PB_2DDrawing_Transparent)
  DrawText( tx, ty, *Me\label, tc )
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i Event( *Me.ControlButton_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  ; ---[ Retrieve Interface ]-------------------------------------------------
  Protected Me.Control::IControl = *Me

  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ...[ Draw Control ]...................................................
      hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
      ; ...[ Processed ]......................................................
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Resize
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
        If *Me\down
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
          ; TODO : >>> TRIGGER ACTION <<<
          PostEvent(Globals::#EVENT_BUTTON_PRESSED,EventWindow(),*Me\object,#Null,@*Me\name)
          Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value)
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
;}


; ============================================================================
;  IMPLEMENTATION ( CControlButton )
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
; ---[ Free ]-----------------------------------------------------------------
Procedure Delete( *Me.ControlButton_t )
  
  ; ---[ Deallocate Memory ]--------------------------------------------------
  ClearStructure(*Me,ControlButton_t)
  FreeMemory( *Me )
  
EndProcedure
;}



; ============================================================================
;  CONSTRUCTOR
; ============================================================================
Procedure.i New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *Me.ControlButton_t = AllocateMemory( SizeOf(ControlButton_t) )
  
;   *Me\VT = ?ControlButtonVT
;   *Me\classname = "CONTROLBUTTON"
  Object::INI(ControlButton)
  
  *Me\object = *object
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type       = #PB_GadgetType_Button
  *Me\name       = name
  *Me\gadgetID   = #Null
  *Me\posX       = x
  *Me\posY       = y
  *Me\sizX       = width
  *Me\sizY       = height
  *Me\visible    = #True
  *Me\enable     = #True
  *Me\options    = options
  *Me\value      = 1
  If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
  If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ProcedureReturn( *Me )
  
EndProcedure



; ============================================================================
;  PROCEDURES
; ============================================================================
;{
Procedure SetTheme( theme.i )
  
  Select theme
      
    ; ---[ Light ]------------------------------------------------------------
    Case Globals::#GUI_THEME_LIGHT
      ; 같�[ Button Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_button_up_normal_tl = s_gui_controls_light_button_up_normal_tl
      s_gui_controls_button_up_normal_tr = s_gui_controls_light_button_up_normal_tr
      s_gui_controls_button_up_normal_bl = s_gui_controls_light_button_up_normal_bl
      s_gui_controls_button_up_normal_br = s_gui_controls_light_button_up_normal_br
      s_gui_controls_button_up_normal_cl = s_gui_controls_light_button_up_normal_cl
      s_gui_controls_button_up_normal_cr = s_gui_controls_light_button_up_normal_cr
      s_gui_controls_button_up_normal_ct = s_gui_controls_light_button_up_normal_ct
      s_gui_controls_button_up_normal_cb = s_gui_controls_light_button_up_normal_cb
      s_gui_controls_button_up_normal_cc = s_gui_controls_light_button_up_normal_cc
      ; ...[ Over ]...........................................................
      s_gui_controls_button_up_over_tl = s_gui_controls_light_button_up_over_tl
      s_gui_controls_button_up_over_tr = s_gui_controls_light_button_up_over_tr
      s_gui_controls_button_up_over_bl = s_gui_controls_light_button_up_over_bl
      s_gui_controls_button_up_over_br = s_gui_controls_light_button_up_over_br
      s_gui_controls_button_up_over_cl = s_gui_controls_light_button_up_over_cl
      s_gui_controls_button_up_over_cr = s_gui_controls_light_button_up_over_cr
      s_gui_controls_button_up_over_ct = s_gui_controls_light_button_up_over_ct
      s_gui_controls_button_up_over_cb = s_gui_controls_light_button_up_over_cb
      s_gui_controls_button_up_over_cc = s_gui_controls_light_button_up_over_cc
      ; ...[ Disabled ].......................................................
      s_gui_controls_button_up_disabled_tl = s_gui_controls_light_button_up_disabled_tl
      s_gui_controls_button_up_disabled_tr = s_gui_controls_light_button_up_disabled_tr
      s_gui_controls_button_up_disabled_bl = s_gui_controls_light_button_up_disabled_bl
      s_gui_controls_button_up_disabled_br = s_gui_controls_light_button_up_disabled_br
      s_gui_controls_button_up_disabled_cl = s_gui_controls_light_button_up_disabled_cl
      s_gui_controls_button_up_disabled_cr = s_gui_controls_light_button_up_disabled_cr
      s_gui_controls_button_up_disabled_ct = s_gui_controls_light_button_up_disabled_ct
      s_gui_controls_button_up_disabled_cb = s_gui_controls_light_button_up_disabled_cb
      s_gui_controls_button_up_disabled_cc = s_gui_controls_light_button_up_disabled_cc
      ;}
      ; 같�[ Button Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_button_down_normal_tl = s_gui_controls_light_button_down_normal_tl
      s_gui_controls_button_down_normal_tr = s_gui_controls_light_button_down_normal_tr
      s_gui_controls_button_down_normal_bl = s_gui_controls_light_button_down_normal_bl
      s_gui_controls_button_down_normal_br = s_gui_controls_light_button_down_normal_br
      s_gui_controls_button_down_normal_cl = s_gui_controls_light_button_down_normal_cl
      s_gui_controls_button_down_normal_cr = s_gui_controls_light_button_down_normal_cr
      s_gui_controls_button_down_normal_ct = s_gui_controls_light_button_down_normal_ct
      s_gui_controls_button_down_normal_cb = s_gui_controls_light_button_down_normal_cb
      s_gui_controls_button_down_normal_cc = s_gui_controls_light_button_down_normal_cc
      ; ...[ Over ]...........................................................
      s_gui_controls_button_down_over_tl = s_gui_controls_light_button_down_over_tl
      s_gui_controls_button_down_over_tr = s_gui_controls_light_button_down_over_tr
      s_gui_controls_button_down_over_bl = s_gui_controls_light_button_down_over_bl
      s_gui_controls_button_down_over_br = s_gui_controls_light_button_down_over_br
      s_gui_controls_button_down_over_cl = s_gui_controls_light_button_down_over_cl
      s_gui_controls_button_down_over_cr = s_gui_controls_light_button_down_over_cr
      s_gui_controls_button_down_over_ct = s_gui_controls_light_button_down_over_ct
      s_gui_controls_button_down_over_cb = s_gui_controls_light_button_down_over_cb
      s_gui_controls_button_down_over_cc = s_gui_controls_light_button_down_over_cc
      ; ...[ Disabled ].......................................................
      s_gui_controls_button_down_disabled_tl = s_gui_controls_light_button_down_disabled_tl
      s_gui_controls_button_down_disabled_tr = s_gui_controls_light_button_down_disabled_tr
      s_gui_controls_button_down_disabled_bl = s_gui_controls_light_button_down_disabled_bl
      s_gui_controls_button_down_disabled_br = s_gui_controls_light_button_down_disabled_br
      s_gui_controls_button_down_disabled_cl = s_gui_controls_light_button_down_disabled_cl
      s_gui_controls_button_down_disabled_cr = s_gui_controls_light_button_down_disabled_cr
      s_gui_controls_button_down_disabled_ct = s_gui_controls_light_button_down_disabled_ct
      s_gui_controls_button_down_disabled_cb = s_gui_controls_light_button_down_disabled_cb
      s_gui_controls_button_down_disabled_cc = s_gui_controls_light_button_down_disabled_cc
      ;}
      
    ; ---[ Dark ]-------------------------------------------------------------
    Case Globals::#GUI_THEME_DARK
      ; 같�[ Button Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_button_up_normal_tl = s_gui_controls_dark_button_up_normal_tl
      s_gui_controls_button_up_normal_tr = s_gui_controls_dark_button_up_normal_tr
      s_gui_controls_button_up_normal_bl = s_gui_controls_dark_button_up_normal_bl
      s_gui_controls_button_up_normal_br = s_gui_controls_dark_button_up_normal_br
      s_gui_controls_button_up_normal_cl = s_gui_controls_dark_button_up_normal_cl
      s_gui_controls_button_up_normal_cr = s_gui_controls_dark_button_up_normal_cr
      s_gui_controls_button_up_normal_ct = s_gui_controls_dark_button_up_normal_ct
      s_gui_controls_button_up_normal_cb = s_gui_controls_dark_button_up_normal_cb
      s_gui_controls_button_up_normal_cc = s_gui_controls_dark_button_up_normal_cc
      ; ...[ Over ]...........................................................
      s_gui_controls_button_up_over_tl = s_gui_controls_dark_button_up_over_tl
      s_gui_controls_button_up_over_tr = s_gui_controls_dark_button_up_over_tr
      s_gui_controls_button_up_over_bl = s_gui_controls_dark_button_up_over_bl
      s_gui_controls_button_up_over_br = s_gui_controls_dark_button_up_over_br
      s_gui_controls_button_up_over_cl = s_gui_controls_dark_button_up_over_cl
      s_gui_controls_button_up_over_cr = s_gui_controls_dark_button_up_over_cr
      s_gui_controls_button_up_over_ct = s_gui_controls_dark_button_up_over_ct
      s_gui_controls_button_up_over_cb = s_gui_controls_dark_button_up_over_cb
      s_gui_controls_button_up_over_cc = s_gui_controls_dark_button_up_over_cc
      ; ...[ Disabled ].......................................................
      s_gui_controls_button_up_disabled_tl = s_gui_controls_dark_button_up_disabled_tl
      s_gui_controls_button_up_disabled_tr = s_gui_controls_dark_button_up_disabled_tr
      s_gui_controls_button_up_disabled_bl = s_gui_controls_dark_button_up_disabled_bl
      s_gui_controls_button_up_disabled_br = s_gui_controls_dark_button_up_disabled_br
      s_gui_controls_button_up_disabled_cl = s_gui_controls_dark_button_up_disabled_cl
      s_gui_controls_button_up_disabled_cr = s_gui_controls_dark_button_up_disabled_cr
      s_gui_controls_button_up_disabled_ct = s_gui_controls_dark_button_up_disabled_ct
      s_gui_controls_button_up_disabled_cb = s_gui_controls_dark_button_up_disabled_cb
      s_gui_controls_button_up_disabled_cc = s_gui_controls_dark_button_up_disabled_cc
      ;}
      ; 같�[ Button Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_button_down_normal_tl = s_gui_controls_dark_button_down_normal_tl
      s_gui_controls_button_down_normal_tr = s_gui_controls_dark_button_down_normal_tr
      s_gui_controls_button_down_normal_bl = s_gui_controls_dark_button_down_normal_bl
      s_gui_controls_button_down_normal_br = s_gui_controls_dark_button_down_normal_br
      s_gui_controls_button_down_normal_cl = s_gui_controls_dark_button_down_normal_cl
      s_gui_controls_button_down_normal_cr = s_gui_controls_dark_button_down_normal_cr
      s_gui_controls_button_down_normal_ct = s_gui_controls_dark_button_down_normal_ct
      s_gui_controls_button_down_normal_cb = s_gui_controls_dark_button_down_normal_cb
      s_gui_controls_button_down_normal_cc = s_gui_controls_dark_button_down_normal_cc
      ; ...[ Over ]...........................................................
      s_gui_controls_button_down_over_tl = s_gui_controls_dark_button_down_over_tl
      s_gui_controls_button_down_over_tr = s_gui_controls_dark_button_down_over_tr
      s_gui_controls_button_down_over_bl = s_gui_controls_dark_button_down_over_bl
      s_gui_controls_button_down_over_br = s_gui_controls_dark_button_down_over_br
      s_gui_controls_button_down_over_cl = s_gui_controls_dark_button_down_over_cl
      s_gui_controls_button_down_over_cr = s_gui_controls_dark_button_down_over_cr
      s_gui_controls_button_down_over_ct = s_gui_controls_dark_button_down_over_ct
      s_gui_controls_button_down_over_cb = s_gui_controls_dark_button_down_over_cb
      s_gui_controls_button_down_over_cc = s_gui_controls_dark_button_down_over_cc
      ; ...[ Disabled ].......................................................
      s_gui_controls_button_down_disabled_tl = s_gui_controls_dark_button_down_disabled_tl
      s_gui_controls_button_down_disabled_tr = s_gui_controls_dark_button_down_disabled_tr
      s_gui_controls_button_down_disabled_bl = s_gui_controls_dark_button_down_disabled_bl
      s_gui_controls_button_down_disabled_br = s_gui_controls_dark_button_down_disabled_br
      s_gui_controls_button_down_disabled_cl = s_gui_controls_dark_button_down_disabled_cl
      s_gui_controls_button_down_disabled_cr = s_gui_controls_dark_button_down_disabled_cr
      s_gui_controls_button_down_disabled_ct = s_gui_controls_dark_button_down_disabled_ct
      s_gui_controls_button_down_disabled_cb = s_gui_controls_dark_button_down_disabled_cb
      s_gui_controls_button_down_disabled_cc = s_gui_controls_dark_button_down_disabled_cc
      ;}
      
  EndSelect
  
EndProcedure
;}



  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )
  ;CHECK_INIT
    
    ; ---[ Local Variable ]-----------------------------------------------------
    Protected img.i
  
    ; ---[ Init Once ]----------------------------------------------------------
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  LIGHT
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;{
    ; 같�[ Button Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_up_normal )
    s_gui_controls_light_button_up_normal_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_up_normal_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_up_normal_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_up_normal_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_up_normal_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_up_normal_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_up_normal_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_up_normal_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_up_normal_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_up_over )
    s_gui_controls_light_button_up_over_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_up_over_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_up_over_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_up_over_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_up_over_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_up_over_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_up_over_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_up_over_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_up_over_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_up_disabled )
    s_gui_controls_light_button_up_disabled_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_up_disabled_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_up_disabled_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_up_disabled_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_up_disabled_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_up_disabled_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_up_disabled_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_up_disabled_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_up_disabled_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; 같�[ Button Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_down_normal )
    s_gui_controls_light_button_down_normal_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_down_normal_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_down_normal_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_down_normal_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_down_normal_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_down_normal_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_down_normal_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_down_normal_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_down_normal_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_down_over )
    s_gui_controls_light_button_down_over_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_down_over_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_down_over_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_down_over_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_down_over_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_down_over_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_down_over_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_down_over_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_down_over_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlButton_light_down_disabled )
    s_gui_controls_light_button_down_disabled_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_light_button_down_disabled_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_light_button_down_disabled_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_light_button_down_disabled_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_light_button_down_disabled_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_light_button_down_disabled_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_light_button_down_disabled_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_light_button_down_disabled_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_light_button_down_disabled_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ;}
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  DARK
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;{
    ; 같�[ Button Up ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_up_normal )
    s_gui_controls_dark_button_up_normal_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_up_normal_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_up_normal_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_up_normal_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_up_normal_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_up_normal_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_up_normal_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_up_normal_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_up_normal_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_up_over )
    s_gui_controls_dark_button_up_over_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_up_over_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_up_over_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_up_over_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_up_over_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_up_over_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_up_over_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_up_over_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_up_over_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_up_disabled )
    s_gui_controls_dark_button_up_disabled_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_up_disabled_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_up_disabled_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_up_disabled_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_up_disabled_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_up_disabled_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_up_disabled_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_up_disabled_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_up_disabled_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; 같�[ Button Down ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_down_normal )
    s_gui_controls_dark_button_down_normal_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_down_normal_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_down_normal_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_down_normal_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_down_normal_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_down_normal_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_down_normal_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_down_normal_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_down_normal_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_down_over )
    s_gui_controls_dark_button_down_over_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_down_over_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_down_over_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_down_over_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_down_over_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_down_over_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_down_over_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_down_over_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_down_over_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlButton_dark_down_disabled )
    s_gui_controls_dark_button_down_disabled_tl = GrabImage( img, #PB_Any,   0,  0,  6, 6 )
    s_gui_controls_dark_button_down_disabled_tr = GrabImage( img, #PB_Any, 165,  0,  6, 6 )
    s_gui_controls_dark_button_down_disabled_bl = GrabImage( img, #PB_Any,   0, 15,  6, 6 )
    s_gui_controls_dark_button_down_disabled_br = GrabImage( img, #PB_Any, 165, 15,  6, 6 )
    s_gui_controls_dark_button_down_disabled_cl = GrabImage( img, #PB_Any,   0,  6,  6, 9 )
    s_gui_controls_dark_button_down_disabled_cr = GrabImage( img, #PB_Any, 165,  6,  6, 9 )
    s_gui_controls_dark_button_down_disabled_ct = GrabImage( img, #PB_Any,   6,  0, 16, 6 )
    s_gui_controls_dark_button_down_disabled_cb = GrabImage( img, #PB_Any,   6, 15, 16, 6 )
    s_gui_controls_dark_button_down_disabled_cc = GrabImage( img, #PB_Any,   6,  6, 16, 9 )
    FreeImage( img )
    ;}
    SetTheme(Globals::#GUI_THEME_LIGHT)
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsButtonTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )

    
    ; ---[ Term Once ]----------------------------------------------------------
    ; 같�[ Free Images ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ Dark ]...............................................................
  
    FreeImage( s_gui_controls_dark_button_down_disabled_cc )
    FreeImage( s_gui_controls_dark_button_down_disabled_cb )
    FreeImage( s_gui_controls_dark_button_down_disabled_ct )
    FreeImage( s_gui_controls_dark_button_down_disabled_cr )
    FreeImage( s_gui_controls_dark_button_down_disabled_cl )
    FreeImage( s_gui_controls_dark_button_down_disabled_br )
    FreeImage( s_gui_controls_dark_button_down_disabled_bl )
    FreeImage( s_gui_controls_dark_button_down_disabled_tr )
    FreeImage( s_gui_controls_dark_button_down_disabled_tl )
    FreeImage( s_gui_controls_dark_button_down_over_cc )
    FreeImage( s_gui_controls_dark_button_down_over_cb )
    FreeImage( s_gui_controls_dark_button_down_over_ct )
    FreeImage( s_gui_controls_dark_button_down_over_cr )
    FreeImage( s_gui_controls_dark_button_down_over_cl )
    FreeImage( s_gui_controls_dark_button_down_over_br )
    FreeImage( s_gui_controls_dark_button_down_over_bl )
    FreeImage( s_gui_controls_dark_button_down_over_tr )
    FreeImage( s_gui_controls_dark_button_down_over_tl )
    FreeImage( s_gui_controls_dark_button_down_normal_cc )
    FreeImage( s_gui_controls_dark_button_down_normal_cb )
    FreeImage( s_gui_controls_dark_button_down_normal_ct )
    FreeImage( s_gui_controls_dark_button_down_normal_cr )
    FreeImage( s_gui_controls_dark_button_down_normal_cl )
    FreeImage( s_gui_controls_dark_button_down_normal_br )
    FreeImage( s_gui_controls_dark_button_down_normal_bl )
    FreeImage( s_gui_controls_dark_button_down_normal_tr )
    FreeImage( s_gui_controls_dark_button_down_normal_tl )
    FreeImage( s_gui_controls_dark_button_up_disabled_cc )
    FreeImage( s_gui_controls_dark_button_up_disabled_cb )
    FreeImage( s_gui_controls_dark_button_up_disabled_ct )
    FreeImage( s_gui_controls_dark_button_up_disabled_cr )
    FreeImage( s_gui_controls_dark_button_up_disabled_cl )
    FreeImage( s_gui_controls_dark_button_up_disabled_br )
    FreeImage( s_gui_controls_dark_button_up_disabled_bl )
    FreeImage( s_gui_controls_dark_button_up_disabled_tr )
    FreeImage( s_gui_controls_dark_button_up_disabled_tl )
    FreeImage( s_gui_controls_dark_button_up_over_cc )
    FreeImage( s_gui_controls_dark_button_up_over_cb )
    FreeImage( s_gui_controls_dark_button_up_over_ct )
    FreeImage( s_gui_controls_dark_button_up_over_cr )
    FreeImage( s_gui_controls_dark_button_up_over_cl )
    FreeImage( s_gui_controls_dark_button_up_over_br )
    FreeImage( s_gui_controls_dark_button_up_over_bl )
    FreeImage( s_gui_controls_dark_button_up_over_tr )
    FreeImage( s_gui_controls_dark_button_up_over_tl )
    FreeImage( s_gui_controls_dark_button_up_normal_cc )
    FreeImage( s_gui_controls_dark_button_up_normal_cb )
    FreeImage( s_gui_controls_dark_button_up_normal_ct )
    FreeImage( s_gui_controls_dark_button_up_normal_cr )
    FreeImage( s_gui_controls_dark_button_up_normal_cl )
    FreeImage( s_gui_controls_dark_button_up_normal_br )
    FreeImage( s_gui_controls_dark_button_up_normal_bl )
    FreeImage( s_gui_controls_dark_button_up_normal_tr )
    FreeImage( s_gui_controls_dark_button_up_normal_tl )
  
    ; ...[ Light ]..............................................................
  
    FreeImage( s_gui_controls_light_button_down_disabled_cc )
    FreeImage( s_gui_controls_light_button_down_disabled_cb )
    FreeImage( s_gui_controls_light_button_down_disabled_ct )
    FreeImage( s_gui_controls_light_button_down_disabled_cr )
    FreeImage( s_gui_controls_light_button_down_disabled_cl )
    FreeImage( s_gui_controls_light_button_down_disabled_br )
    FreeImage( s_gui_controls_light_button_down_disabled_bl )
    FreeImage( s_gui_controls_light_button_down_disabled_tr )
    FreeImage( s_gui_controls_light_button_down_disabled_tl )
    FreeImage( s_gui_controls_light_button_down_over_cc )
    FreeImage( s_gui_controls_light_button_down_over_cb )
    FreeImage( s_gui_controls_light_button_down_over_ct )
    FreeImage( s_gui_controls_light_button_down_over_cr )
    FreeImage( s_gui_controls_light_button_down_over_cl )
    FreeImage( s_gui_controls_light_button_down_over_br )
    FreeImage( s_gui_controls_light_button_down_over_bl )
    FreeImage( s_gui_controls_light_button_down_over_tr )
    FreeImage( s_gui_controls_light_button_down_over_tl )
    FreeImage( s_gui_controls_light_button_down_normal_cc )
    FreeImage( s_gui_controls_light_button_down_normal_cb )
    FreeImage( s_gui_controls_light_button_down_normal_ct )
    FreeImage( s_gui_controls_light_button_down_normal_cr )
    FreeImage( s_gui_controls_light_button_down_normal_cl )
    FreeImage( s_gui_controls_light_button_down_normal_br )
    FreeImage( s_gui_controls_light_button_down_normal_bl )
    FreeImage( s_gui_controls_light_button_down_normal_tr )
    FreeImage( s_gui_controls_light_button_down_normal_tl )
    FreeImage( s_gui_controls_light_button_up_disabled_cc )
    FreeImage( s_gui_controls_light_button_up_disabled_cb )
    FreeImage( s_gui_controls_light_button_up_disabled_ct )
    FreeImage( s_gui_controls_light_button_up_disabled_cr )
    FreeImage( s_gui_controls_light_button_up_disabled_cl )
    FreeImage( s_gui_controls_light_button_up_disabled_br )
    FreeImage( s_gui_controls_light_button_up_disabled_bl )
    FreeImage( s_gui_controls_light_button_up_disabled_tr )
    FreeImage( s_gui_controls_light_button_up_disabled_tl )
    FreeImage( s_gui_controls_light_button_up_over_cc )
    FreeImage( s_gui_controls_light_button_up_over_cb )
    FreeImage( s_gui_controls_light_button_up_over_ct )
    FreeImage( s_gui_controls_light_button_up_over_cr )
    FreeImage( s_gui_controls_light_button_up_over_cl )
    FreeImage( s_gui_controls_light_button_up_over_br )
    FreeImage( s_gui_controls_light_button_up_over_bl )
    FreeImage( s_gui_controls_light_button_up_over_tr )
    FreeImage( s_gui_controls_light_button_up_over_tl )
    FreeImage( s_gui_controls_light_button_up_normal_cc )
    FreeImage( s_gui_controls_light_button_up_normal_cb )
    FreeImage( s_gui_controls_light_button_up_normal_ct )
    FreeImage( s_gui_controls_light_button_up_normal_cr )
    FreeImage( s_gui_controls_light_button_up_normal_cl )
    FreeImage( s_gui_controls_light_button_up_normal_br )
    FreeImage( s_gui_controls_light_button_up_normal_bl )
    FreeImage( s_gui_controls_light_button_up_normal_tr )
    FreeImage( s_gui_controls_light_button_up_normal_tl )
  
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlButton )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 394
; FirstLine = 351
; Folding = --f--
; EnableXP