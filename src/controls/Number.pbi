XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../ui/View.pbi"
; ==============================================================================
;  CONTROL NUMBER MODULE DECLARATION
; ==============================================================================
DeclareModule ControlNumber
  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  OPTIONS
  ; ----------------------------------------------------------------------------
  ;{
  #NUMBER_SCALAR    = %0001
  #NUMBER_INTEGER   = %0010
  #NUMBER_PERCENT   = %0100
  #NUMBER_NOSLIDER  = %1000
  ;}
  ;}

  
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  Light
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_light_number_disabled_l.i
  Global s_gui_controls_light_number_disabled_c.i
  Global s_gui_controls_light_number_disabled_r.i
  Global s_gui_controls_light_number_disabled_s.i
  Global s_gui_controls_light_number_disabled_cl.i
  Global s_gui_controls_light_number_disabled_cr.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_number_normal_l.i
  Global s_gui_controls_light_number_normal_c.i
  Global s_gui_controls_light_number_normal_r.i
  Global s_gui_controls_light_number_normal_s.i
  Global s_gui_controls_light_number_normal_cl.i
  Global s_gui_controls_light_number_normal_cr.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_number_over_l.i
  Global s_gui_controls_light_number_over_c.i
  Global s_gui_controls_light_number_over_r.i
  Global s_gui_controls_light_number_over_s.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_light_number_focused_l.i
  Global s_gui_controls_light_number_focused_c.i
  Global s_gui_controls_light_number_focused_r.i
  ;}
  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_dark_number_disabled_l.i
  Global s_gui_controls_dark_number_disabled_c.i
  Global s_gui_controls_dark_number_disabled_r.i
  Global s_gui_controls_dark_number_disabled_s.i
  Global s_gui_controls_dark_number_disabled_cl.i
  Global s_gui_controls_dark_number_disabled_cr.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_number_normal_l.i
  Global s_gui_controls_dark_number_normal_c.i
  Global s_gui_controls_dark_number_normal_r.i
  Global s_gui_controls_dark_number_normal_s.i
  Global s_gui_controls_dark_number_normal_cl.i
  Global s_gui_controls_dark_number_normal_cr.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_number_over_l.i
  Global s_gui_controls_dark_number_over_c.i
  Global s_gui_controls_dark_number_over_r.i
  Global s_gui_controls_dark_number_over_s.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_dark_number_focused_l.i
  Global s_gui_controls_dark_number_focused_c.i
  Global s_gui_controls_dark_number_focused_r.i
  ;}
  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_number_disabled_l.i
  Global s_gui_controls_number_disabled_c.i
  Global s_gui_controls_number_disabled_r.i
  Global s_gui_controls_number_disabled_s.i
  Global s_gui_controls_number_disabled_cl.i
  Global s_gui_controls_number_disabled_cr.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_number_normal_l.i
  Global s_gui_controls_number_normal_c.i
  Global s_gui_controls_number_normal_r.i
  Global s_gui_controls_number_normal_s.i
  Global s_gui_controls_number_normal_cl.i
  Global s_gui_controls_number_normal_cr.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_number_over_l.i
  Global s_gui_controls_number_over_c.i
  Global s_gui_controls_number_over_r.i
  Global s_gui_controls_number_over_s.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_number_focused_l.i
  Global s_gui_controls_number_focused_c.i
  Global s_gui_controls_number_focused_r.i
  ;}
  ;}

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlNumber_t )
  ; ----------------------------------------------------------------------------
  Structure ControlNumber_t Extends Control::Control_t
    value       .s
    value_n     .d
    hard_min    .d
    hard_max    .d
    soft_min    .d
    soft_max    .d
    undo_esc    .s
    undo_ctz_t  .s
    undo_ctz_g  .i
    undo_ctz_w  .i
    over        .i
    down        .i
    focused     .i
    selected    .i
    posG        .i ; Strong Cursor
    posW        .i ; Weak   Cursor
    posS        .i
    caret_switch.i
    timer_on    .i
    lookup_dirty.i
    lookup_count.i
    Array lookup.i(0)
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlNumber Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  
  Declare New(*object.Object::Object_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlNumber_t)
  Declare Event( *Me.ControlNumber_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetValue( *Me.ControlNumber_t, value.s )
  Declare.s GetValue( *Me.ControlNumber_t )
  Declare SetTheme( theme.i )
  Declare Init()
  Declare Term()
  
;   Declare.i hlpNextWordStart( text.s, cur_pos.i )
;   Declare hlpPrevWordStart( text.s, cur_pos.i )
;   Declare hlpPrevWord( text.s, cur_pos.i )
;   Declare hlpNextWord( text.s, cur_pos.i )
;   Declare hlpSelectWord( *Me.ControlNumber_t, cur_pos.i )
;   Declare hlpCharPosFromMousePos( *Me.ControlNumber_t, xpos.i )
;   Declare hlpDraw( *Me.ControlNumber_t, xoff.i = 0, yoff.i = 0 )
  
 
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlNumberVT: 
    Data.i @Event()
    Data.i @Delete()
    
    ; Images
    ; (Light)
    VIControlNumber_light_disabled_bg: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.disabled.bg.png"
    VIControlNumber_light_disabled_cover: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.disabled.cover.png"
    VIControlNumber_light_disabled_slider: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.disabled.slider.png"
    VIControlNumber_light_focused: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.focused.png"
    VIControlNumber_light_normal_bg: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.normal.bg.png"
    VIControlNumber_light_normal_cover: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.normal.cover.png"
    VIControlNumber_light_normal_slider: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.normal.slider.png"
    VIControlNumber_light_over_bg: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.over.bg.png"
    VIControlNumber_light_over_slider: 
    IncludeBinary "../../rsc/skins/grey/control_number/light.number.over.slider.png"
    
    ; (Dark)
    VIControlNumber_dark_disabled_bg:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.disabled.bg.png"
    VIControlNumber_dark_disabled_cover:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.disabled.cover.png"
    VIControlNumber_dark_disabled_slider:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.disabled.slider.png"
    VIControlNumber_dark_focused: 
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.focused.png"
    VIControlNumber_dark_normal_bg:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.normal.bg.png"
    VIControlNumber_dark_normal_cover:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.normal.cover.png"
    VIControlNumber_dark_normal_slider:
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.normal.slider.png"
    VIControlNumber_dark_over_bg: 
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.over.bg.png"
    VIControlNumber_dark_over_slider: 
    IncludeBinary "../../rsc/skins/grey/control_number/dark.number.over.slider.png"
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
;  CONTROL NUMBER IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlNumber
  ; ----------------------------------------------------------------------------
  ;  hlpNextWordStart
  ; ----------------------------------------------------------------------------
  Procedure.i hlpNextWordStart( text.s, cur_pos.i )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected iEnd.i = Len(text) + 1
    Protected bFront = #False
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If cur_pos = iEnd : ProcedureReturn( iEnd ) : EndIf
    
    ; ---[ Update Front ]-------------------------------------------------------
    If Mid( text, cur_pos, 1 ) = " "
      bFront = #True
    EndIf
    
    ; ---[ Search For Next Word Start ]-----------------------------------------
    While cur_pos < iEnd
      If bFront
        If Mid( text, cur_pos, 1 ) <> " "
          ProcedureReturn( cur_pos )
        EndIf
      Else
        If Mid( text, cur_pos, 1 ) = " "
          bFront = #True
        EndIf
      EndIf
      cur_pos + 1
    Wend
    
    ; ---[ Not Found ]----------------------------------------------------------
    ProcedureReturn( iEnd )
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpPrevWordStart
  ; ----------------------------------------------------------------------------
  Procedure.i hlpPrevWordStart( text.s, cur_pos.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If cur_pos = 1 : ProcedureReturn(1) : EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected bFront = #False
    
    ; ---[ Update Front ]-------------------------------------------------------
    cur_pos - 1
    If Mid( text, cur_pos, 1 ) <> " "
      bFront = #True
    EndIf
    
    ; ---[ Search For Previous Word Start ]-------------------------------------
    While cur_pos > 1
      cur_pos - 1
      If bFront
        If Mid( text, cur_pos, 1 ) = " "
          ProcedureReturn( cur_pos + 1 )
        EndIf
      Else
        If Mid( text, cur_pos, 1 ) <> " "
          bFront = #True
        EndIf
      EndIf
    Wend
    
    ; ---[ Not Found ]----------------------------------------------------------
    ProcedureReturn( 1 )
    
  EndProcedure
    
  ; ----------------------------------------------------------------------------
  ;  hlpPrevWord
  ; ----------------------------------------------------------------------------
  Procedure.i hlpPrevWord( text.s, cur_pos.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If cur_pos = 1 : ProcedureReturn(1) : EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected bFront = #False
    
    ; ---[ Update Front ]-------------------------------------------------------
    cur_pos - 1
    If Mid( text, cur_pos, 1 ) <> " "
      bFront = #True
    EndIf
    
    ; ---[ Search For Previous Word Start ]-------------------------------------
    While cur_pos > 1
      cur_pos - 1
      If bFront
        If Mid( text, cur_pos, 1 ) = " "
          ProcedureReturn( cur_pos + 1 )
        EndIf
      Else
        If Mid( text, cur_pos, 1 ) <> " "
          ;bFront = #True
          ProcedureReturn( cur_pos + 1 )
        EndIf
      EndIf
    Wend
    
    ; ---[ Not Found ]----------------------------------------------------------
    ProcedureReturn( 1 )
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpNextWord
  ; ----------------------------------------------------------------------------
  Procedure.i hlpNextWord( text.s, cur_pos.i )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected iEnd.i = Len(text) + 1
    Protected bFront = #False
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If cur_pos = iEnd : ProcedureReturn( iEnd ) : EndIf
    
    ; ---[ Update Front ]-------------------------------------------------------
    If Mid( text, cur_pos, 1 ) = " "
      bFront = #True
    EndIf
    
    ; ---[ Search For Next Word Start ]-----------------------------------------
    While cur_pos < iEnd
      If bFront
        If Mid( text, cur_pos, 1 ) <> " "
          ProcedureReturn( cur_pos )
        EndIf
      Else
        If Mid( text, cur_pos, 1 ) = " "
          ;bFront = #True
          ProcedureReturn( cur_pos )
        EndIf
      EndIf
      cur_pos + 1
    Wend
    
    ; ---[ Not Found ]----------------------------------------------------------
    ProcedureReturn( iEnd )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  hlpSelectWord
  ; ----------------------------------------------------------------------------
  Procedure hlpSelectWord( *Me.ControlNumber_t, cur_pos.i )
    
    If cur_pos > 1 And cur_pos < Len(*Me\value)
      If Mid( *Me\value, cur_pos - 1, 1 ) = " " And Mid( *Me\value, cur_pos, 1 ) <> " " 
        *Me\posG = cur_pos
        *Me\posW = hlpNextWord( *Me\value, cur_pos )
      ElseIf Mid( *Me\value, cur_pos - 1, 1 ) <> " " And Mid( *Me\value, cur_pos, 1 ) = " " 
        *Me\posG = hlpPrevWord( *Me\value, cur_pos )
        *Me\posW = cur_pos
      Else
        *Me\posG = hlpPrevWord( *Me\value, cur_pos )
        *Me\posW = hlpNextWord( *Me\value, cur_pos )
      EndIf
    EndIf
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  hlpCharPosFromMousePos
  ; ----------------------------------------------------------------------------
  Procedure.i hlpCharPosFromMousePos( *Me.ControlNumber_t, xpos.i )
    
    ; ---[ Update Mouse Position To Client Border ]-----------------------------
    xpos - 7
    
    Protected x_start.i = *Me\lookup(*Me\posS)
    Protected i.i
    For i = *Me\posS To *Me\lookup_count
      If ( *Me\lookup(i) - x_start ) > xpos
        ProcedureReturn( Math::Max( 1, i-1 ) )
      EndIf
    Next
    
    ProcedureReturn( *Me\lookup_count )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlNumber_t, xoff.i = 0, yoff.i = 0 )
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Set Font ]-----------------------------------------------------------
    Protected tc.i = UIColor::COLOR_NUMBER_FG
    DrawingFont(FontID(Globals::#FONT_TEXT))
  ;   raaSetFontEdit( raa_font_node )
    Protected tx.i = 7
    Protected ty.i = ( *Me\sizY - TextHeight( *Me\value ) )/2 + yoff
    
    ; ---[ Check Positions Lookup Table ]---------------------------------------
    If *Me\lookup_dirty
      ; ...[ Local Variables ]..................................................
      Protected i.i
      ; ...[ Update Positions Count ]...........................................
      *Me\lookup_count = Len(*Me\value) + 1
      ReDim *Me\lookup(*Me\lookup_count)
      ; ...[ Update Positions ].................................................
      *Me\lookup(0) = 0
      For i=1 To *Me\lookup_count
        *Me\lookup(i) = TextWidth( Left(*Me\value,i-1) )
      Next
      ; ...[ Now Clean ]........................................................
      *Me\lookup_dirty = #False
    EndIf
    
    ; ---[ Handle Left Overflow ]-----------------------------------------------
    *Me\posS = Math::Min( *Me\posS, *Me\posW )
  
    ; ---[ Handle Right Overflow ]----------------------------------------------
    Protected rof    .i = *Me\sizX - 12
    Protected x_start.i = *Me\lookup(*Me\posS)
    Protected x_end  .i = *Me\lookup(*Me\posW)
    Protected tw     .i = x_end - x_start  
    Protected tlen   .i = *Me\posW - *Me\posS
    
    ; °°°[ Right Overflow ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    If tw > rof
      While tw > rof
        *Me\posS + 1
        tw = x_end - *Me\lookup(*Me\posS)
      Wend
      tlen = *Me\posW - *Me\posS
    ; °°°[ Clip Text ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    Else
      Protected i_end.i = *Me\posW
      While ( tw <= rof ) And ( i_end < *Me\lookup_count )
        i_end + 1
        tw = *Me\lookup(i_end) - x_start
      Wend
      If i_end < *Me\lookup_count : i_end - 1 : EndIf
      tlen = i_end - *Me\posS
      tw = *Me\lookup(i_end) - x_start
    EndIf
    
    ; ---[ Only If Focused ]----------------------------------------------------
    If *Me\focused
      ; ...[ Retrieve Left/Right From Strong/Weak Cursor Positions ]............
      Protected posL.i, posR.i, posXL.i, posXR.i
      If *Me\posG > *Me\posW
        posL = *Me\posW : posR = *Me\posG
      Else
        posL = *Me\posG : posR = *Me\posW
      EndIf
      ; ...[ Compute Left Cursor Coordinate ]...................................
      posXL = Math::Max( 0, *Me\lookup(posL) - *Me\lookup(*Me\posS) )
      ; ...[ Check For Selection ]..............................................
      If posL <> posR
        ; ...[ Has Selection ]..................................................
        *Me\selected = #True
        ; ...[ Compute Right Cursor Coordinate ]................................
        posXR = Math::Min( tw, *Me\lookup(posR) - *Me\lookup(*Me\posS) )
      Else
        ; ...[ Just The Caret ].................................................
        *Me\selected = #False
      EndIf
    ; ---[ Only When NOT Focused ]----------------------------------------------  
    Else
      ; ...[ Compute Slider Extends ]...........................................
      Protected factor.d = ( *Me\value_n - *Me\soft_min )/( *Me\soft_max - *Me\soft_min )
      Protected slider_w.i = Math::Min( *Me\sizX - 4, Math::Max( 0, factor*( *Me\sizX - 4 ) ) )
      If *Me\options & #NUMBER_NOSLIDER
        slider_w = *Me\sizX - 4
      EndIf
      
    EndIf
    
    ; ---[ Reset Clipping ]-----------------------------------------------------
    ;   raaResetClip()
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
      DrawImage( ImageID(s_gui_controls_number_disabled_l ),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_disabled_c ),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
      DrawImage( ImageID(s_gui_controls_number_disabled_r ), *Me\sizX - 8 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_disabled_s ),            2 + xoff, 1 + yoff, slider_w,      16 )
      DrawImage( ImageID(s_gui_controls_number_disabled_cl),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_disabled_cr), *Me\sizX - 8 + xoff, 0 + yoff                    )
      ; ...[ Disabled Text ]....................................................
      tc = UIColor::COLOR_LABEL_DISABLED
    ; ---[ Check Focused ]------------------------------------------------------
    ElseIf *Me\focused
      DrawImage( ImageID(s_gui_controls_number_focused_l),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_focused_c),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
      DrawImage( ImageID(s_gui_controls_number_focused_r), *Me\sizX - 8 + xoff, 0 + yoff                    )
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      DrawImage( ImageID(s_gui_controls_number_over_l   ),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_over_c   ),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
      DrawImage( ImageID(s_gui_controls_number_over_r   ), *Me\sizX - 8 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_over_s   ),            2 + xoff, 1 + yoff, slider_w,      16 )
      DrawImage( ImageID(s_gui_controls_number_normal_cl),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_normal_cr), *Me\sizX - 8 + xoff, 0 + yoff                    )
    Else
      DrawImage( ImageID(s_gui_controls_number_normal_l ),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_normal_c ),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
      DrawImage( ImageID(s_gui_controls_number_normal_r ), *Me\sizX - 8 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_normal_s ),            2 + xoff, 1 + yoff, slider_w,      16 )
      DrawImage( ImageID(s_gui_controls_number_normal_cl),            0 + xoff, 0 + yoff                    )
      DrawImage( ImageID(s_gui_controls_number_normal_cr), *Me\sizX - 8 + xoff, 0 + yoff                    )
    EndIf
    
    ; ---[ Retrieve Displayed (Clipped) Text ]----------------------------------
    Protected dtext.s = Mid( *Me\value, *Me\posS, tlen )
    
    ; ---[ Handle Caret & Selection ]-------------------------------------------
    If *Me\focused
      ; °°°[ Has Selection ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      If *Me\selected
        ; ...[ Draw Regular Text + Selection ]..................................
        CompilerSelect #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            Box( tx + xoff + posXL - 1, ty-1, (posXR - posXL) + 2, 14, UIColor::COLOR_SELECTED_BG )
          CompilerCase #PB_OS_Linux
            Box( tx + xoff + posXL - 1, ty,   (posXR - posXL) + 2, 14, UIColor::COLOR_SELECTED_BG )
          CompilerCase #PB_OS_MacOS
            Box( tx + xoff + posXL - 1, ty+1, (posXR - posXL) + 2, 14, UIColor::COLOR_SELECTED_BG )
        CompilerEndSelect
        DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Transparent )
        DrawText( tx + xoff, ty, dtext, UIColor::COLOR_SELECTED_FG )
      ; °°°[ Just Caret ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  
      Else
        ; ...[ Draw Value ].....................................................
        DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Transparent )
        DrawText( tx + xoff, ty, dtext, tc )
        ; ...[ Draw Caret ].....................................................
        If *Me\caret_switch > 0 Or Not *Me\timer_on
          CompilerSelect #PB_Compiler_OS
            CompilerCase #PB_OS_Windows
              Line( tx + posXL + xoff, ty,   1, 13, UIColor::COLOR_CARET )
            CompilerCase #PB_OS_Linux
              Line( tx + posXL + xoff, ty+1, 1, 13, UIColor::COLOR_CARET )
            CompilerCase #PB_OS_MacOS
              Line( tx + posXL + xoff, ty+2, 1, 13, UIColor::COLOR_CARET )
          CompilerEndSelect
        EndIf
      EndIf
    Else
      ; ---[ Draw Value ]-------------------------------------------------------
      CompilerSelect #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            RoundBox( -3 + tx + xoff, ty,   tw+5, 12, 4, 4, UIColor::COLOR_NUMBER_BG )
          CompilerCase #PB_OS_Linux
            RoundBox( -3 + tx + xoff, ty+1, tw+5, 12, 4, 4, UIColor::COLOR_NUMBER_BG )
          CompilerCase #PB_OS_MacOS
            RoundBox( -3 + tx + xoff, ty+2, tw+5, 12, 4, 4, UIColor::COLOR_NUMBER_BG )
        CompilerEndSelect
        DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Transparent )
        DrawText( tx + xoff, ty, dtext, tc )
    EndIf
    
  EndProcedure
  ;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i Event( *Me.ControlNumber_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )


  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not *ev_data : ProcedureReturn : EndIf
      
      ; ---[ Draw Control ]---------------------------------------------------
      hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Resize
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not *ev_data : ProcedureReturn : EndIf
      
      ; ---[ Cancel Height ]--------------------------------------------------
      *Me\sizY = 18
      ; ---[ Update Topology ]------------------------------------------------
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  LostFocus
    ; ------------------------------------------------------------------------
  Case #PB_EventType_LostFocus
      If *Me\focused
        ;restore old value
        If *me\options & #NUMBER_INTEGER
          *Me\value = Str(*Me\value_n)
        Else
          *Me\value = StrD(*Me\value_n,3)
        EndIf
        ; ...[ Positions Lookup Table Is Now Dirty ]........................
          *Me\lookup_dirty = #True
      EndIf
    
      ; ---[ Stop Caret Flashing ]--------------------------------------------
      ;RemoveWindowTimer( #MainWindow, #TIMER_CARET )
      ; ---[ Not Focused Anymore }--------------------------------------------
      *Me\focused = #False
      ; ---[ Show Text From Start ]-------------------------------------------
      *Me\posG = 1 : *Me\posW = 1
      ; ---[ Redraw Me ]------------------------------------------------------
      ;Me\Invalidate()
      Control::Invalidate(*Me)
      
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
      ; ------------------------------------------------------------------------
      ;  Focus
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Focus
        ; ---[ Not Focused Anymore }--------------------------------------------
        *Me\focused = #True
        ; ---[ Show Text From Start ]-------------------------------------------
        *Me\posG = 1 : *Me\posW = 1
        ; ---[ Redraw Me ]------------------------------------------------------
        Control::Invalidate(*Me)
      
        ; ---[ Processed ]------------------------------------------------------
        ProcedureReturn( #True )
        
    ; ------------------------------------------------------------------------
    ;  MouseEnter
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseEnter
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Mouse Is Over Me ].............................................
        *Me\over = #True
        ; ...[ Show IBeam Cursor ]............................................
        If *Me\focused : Control::SetCursor( *Me,#PB_Cursor_IBeam ) : EndIf
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  MouseLeave
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseLeave
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Mouse Is Not Over Me Anymore ].................................
        *Me\over = #False
        
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  MouseMove
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Check Down ]...................................................
        If *Me\down
          ; ...[ Sanity Check ]...............................................
          If Not *ev_data : ProcedureReturn : EndIf
          ; ...[ Check Mouse Selecting ]......................................
          If *Me\focused
            ; ...[ Update Weak Cursor Position ]..............................
            *Me\posW = hlpCharPosFromMousePos( *Me, *ev_data\x )
          Else
            If Not *Me\options & ControlNumber::#NUMBER_NOSLIDER
              ; ...[ Update Value ].............................................
              *Me\value_n = ( *ev_data\x - 2.0 )/( *Me\sizX - 4.0 )*( *Me\soft_max - *Me\soft_min ) + *Me\soft_min
              If *Me\value_n < *Me\soft_min : *Me\value_n = *Me\soft_min : EndIf
              If *Me\value_n > *Me\soft_max : *Me\value_n = *Me\soft_max : EndIf
              If *Me\options & ControlNumber::#NUMBER_INTEGER
                *Me\value = Str(*Me\value_n)
              Else
                *Me\value   = StrD( *Me\value_n, 3 )
              EndIf
            EndIf
            ; ...[ Positions Lookup Table Is Now Dirty ]......................
              *Me\lookup_dirty = #True
          EndIf 
          ; ...[ Redraw Me ]..................................................
          Control::Invalidate(*Me)

          ; ---[ Send 'OnChanged' Signal ]------------------------------------
          Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value_n)
          PostEvent(Globals::#EVENT_PARAMETER_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
          Debug "Parameter Value : "+StrF(*Me\value_n)
        EndIf
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable And *Me\over
        ; ...[ Sanity Check ].................................................
        If Not *ev_data : ProcedureReturn :EndIf
        ; ...[ Mouse Is Now Down ]............................................
        *Me\down = #True
        ; ...[ Check Not Yet Focused ]........................................
        If *Me\focused
          If Not *Me\options & ControlNumber::#NUMBER_NOSLIDER
            ; ...[ Update Value ]...............................................
            *Me\value_n = ( *ev_data\x - 2.0 )/( *Me\sizX - 4.0 )*( *Me\soft_max - *Me\soft_min ) + *Me\soft_min
            If *Me\value_n < *Me\soft_min : *Me\value_n = *Me\soft_min : EndIf
            If *Me\value_n > *Me\soft_max : *Me\value_n = *Me\soft_max : EndIf
            If *Me\options & ControlNumber::#NUMBER_INTEGER
              *Me\value = Str(*Me\value_n)
            Else
              *Me\value   = StrD( *Me\value_n, 3 )
            EndIf
          EndIf
          ; ...[ Positions Lookup Table Is Now Dirty ]........................
          *Me\lookup_dirty = #True
        Else
          ; ...[ Update Strong Cursor Position ]..............................
          *Me\posG = hlpCharPosFromMousePos( *Me, *ev_data\x )
          ; ...[ Reset Selection ]............................................
          *Me\posW = *Me\posG
        EndIf
     
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Mouse Is Now Up ]..............................................
        *Me\down = #False
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        
        Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value_n)
        PostEvent(Globals::#EVENT_PARAMETER_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
        
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftDoubleClick
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftDoubleClick
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Check Focused ]................................................
        If *Me\focused
          ; ...[ Sanity Check ]...............................................
          If Not  *ev_data : ProcedureReturn : EndIf
          
          ; ...[ Set Undo ]...................................................
          *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ...[ Select Word Under Mouse ]....................................
          hlpSelectWord( *Me, hlpCharPosFromMousePos( *Me, *ev_data\x ) )
        Else
          ; ...[ I've The Focus ].............................................
          *Me\focused = #True
          ; ...[ Save Current Text For ESC Undo ].............................
          *Me\undo_esc = *Me\value
          ; ...[ Show IBeam Cursor ]..........................................
          Control::SetCursor(*Me, #PB_Cursor_IBeam )
          ; ...[ Tell Parent I'm The One Focused ]............................
          Control::Focused(*Me)
          ; ...[ Select All Text On Focus For Convenience ]...................
          *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1          
        EndIf
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  RightButtonDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_RightButtonDown
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Mouse Is Now Down ]............................................
        *Me\down = #True
        ; ...[ Check NOT Focused ]............................................
        If Not *Me\focused
          ; ...[ I've The Focus ].............................................
          *Me\focused = #True
          ; ...[ Save Current Text For ESC Undo ].............................
          *Me\undo_esc = *Me\value
          ; ...[ Tell Parent I'm The One Focused ]............................
          Control::Focused(*Me)
          ; ...[ Show IBeam Cursor ]..........................................
          Control::SetCursor( *Me,#PB_Cursor_IBeam )
          ; ...[ Select All Text On Focus For Convenience ]...................
          *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1          
        EndIf
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  RightButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_RightButtonUp
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Mouse Is Now Up ]..............................................
        *Me\down = #False
        ; ...[ Redraw Me ]....................................................
        Control::Invalidate(*Me)
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  Input
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Input
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not *ev_data : ProcedureReturn : EndIf
      
      ; ---[ Set Undo ]-------------------------------------------------------
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      ; ---[ Check Strong/Weak Cursor Order ]---------------------------------
      If *Me\posW > *Me\posG
        *Me\value = Left(*Me\value,*Me\posG-1) + *ev_data\input + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
        *Me\posG + 1
      Else
        *Me\value = Left(*Me\value,*Me\posW-1) + *ev_data\input + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW + 1
      EndIf
      ; ---[ No More Selection ]----------------------------------------------
      *Me\posW = *Me\posG
      ; ---[ Positions Lookup Table Is Now Dirty ]----------------------------
      *Me\lookup_dirty = #True
      ; ...[ Redraw Me ]....................................................
      Control::Invalidate(*Me)
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  KeyDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_KeyDown
      ; ---[ Dispatch Key ]---------------------------------------------------
      Select *ev_data\key
        ;_____________________________________________________________________
        ;  Return
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Return
          ; ---[ Check SHIFT Modifiers ]--------------------------------------
          If *ev_data\modif & #PB_Canvas_Shift
            ; ...[ Set Undo ].................................................
            *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          EndIf
          ; ---[ Update Value ]-----------------------------------------------
          
          
          ; ---[ Update String Value ]----------------------------------------
          If *me\options & ControlNumber::#NUMBER_INTEGER
            *Me\value_n = Round(ValD(*Me\value),#PB_Round_Nearest);AEV\Eval( *Me\value )
            *Me\value = Str( *Me\value_n)
          Else
            *Me\value_n = ValD(*Me\value);AEV\Eval( *Me\value )
            *Me\value = StrD( *Me\value_n, 3 )
            
          EndIf
          
          ; ---[ Check SHIFT Modifiers ]--------------------------------------
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Loose Focus ]..............................................
            *Me\focused = #False : Control::DeFocused(*Me)
            ; ...[ Restore Default Cursor ]...................................
            Control::SetCursor( *Me,#PB_Cursor_Default )
          EndIf
          ; ---[ Show Text From Start ]---------------------------------------
          *Me\posG = 1 : *Me\posW = 1
          ; ---[ Positions Lookup Table Is Now Dirty ]------------------------
          *Me\lookup_dirty = #True
          ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          
         
          Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value_n)
          PostEvent(Globals::#EVENT_PARAMETER_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
          
          ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Escape
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Escape
          ; ---[ Loose Focus ]------------------------------------------------
          *Me\focused = #False : Control::DeFocused(*Me)
          ; ---[ Undo Previous Action ]---------------------------------------
          *Me\value = *Me\undo_esc
          ; ---[ Show Text From Start ]---------------------------------------
          *Me\posG = 1 : *Me\posW = 1
          ; ---[ Positions Lookup Table Is Now Dirty ]------------------------
          *Me\lookup_dirty = #True
          ; ---[ Restore Default Cursor ]-------------------------------------
          Control::SetCursor( *Me,#PB_Cursor_Default )
          ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Tab
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Tab
          ; TODO : Next Widget In Group
        ;_____________________________________________________________________
        ;  Home
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Home
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not *ev_data : ProcedureReturn : EndIf
          
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Weak Cursor To Start Of Text ]-------------------------------
          *Me\posW = 1
          ; ...[ Check Modifiers ]............................................
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To Start Of Text ]...........................
            *Me\posG = *Me\posW
          EndIf
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  End
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_End
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not *ev_data : ProcedureReturn : EndIf
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Weak Cursor To End Of Text ]---------------------------------
          *Me\posW = Len(*Me\value) + 1
          ; ...[ Check Modifiers ]............................................
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To End Of Text ].............................
            *Me\posG = *Me\posW
          EndIf
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Left
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Left
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not *ev_data : ProcedureReturn : EndIf
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Check For CONTROL/COMMAND Modifier ]-------------------------
          If ( *ev_data\modif & #PB_Canvas_Control ) Or ( *ev_data\modif & #PB_Canvas_Command )
            ; ...[ Weak Cursor To Previous Word Start ].......................
            *Me\posW = hlpPrevWordStart( *Me\value, *Me\posW )
          Else
            ; ...[ Weak Cursor To Left ]......................................
            *Me\posW = Math::Max( 1, *Me\posW - 1 )
          EndIf
          ; ---[ Check For SHIFT Modifiers ]----------------------------------
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To Left ]....................................
            *Me\posG = *Me\posW
          EndIf
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Right
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Right
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not *ev_data : ProcedureReturn : EndIf
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Check For CONTROL/COMMAND Modifier ]-------------------------
          If ( *ev_data\modif & #PB_Canvas_Control ) Or ( *ev_data\modif & #PB_Canvas_Command )
            ; ...[ Weak Cursor To Next Word Start ]...........................
            *Me\posW = hlpNextWordStart( *Me\value, *Me\posW )
          Else
            ; ...[ Weak Cursor To Right ].....................................
            *Me\posW = Math::Min( Len(*Me\value) + 1, *Me\posW + 1 )
          EndIf
          ; ---[ Check For SHIFT Modifiers ]----------------------------------
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To Right ]...................................
            *Me\posG = *Me\posW
          EndIf
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Back
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Back
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Check For Selection ]----------------------------------------
          If *Me\posG > *Me\posW
            *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
            *Me\posG = *Me\posW
          ElseIf *Me\posG <> *Me\posW
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
          Else
            *Me\value = Left(*Me\value,*Me\posG-2) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
            *Me\posG = Math::Max( 1, *Me\posG - 1 )
          EndIf
          ; ---[ No More Selection ]------------------------------------------
          *Me\posW = *Me\posG
          ; ---[ Positions Lookup Table Is Now Dirty ]------------------------
          *Me\lookup_dirty = #True
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Delete
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Delete
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Check For Selection ]----------------------------------------
          If *Me\posG > *Me\posW
            *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
            *Me\posG = *Me\posW
          ElseIf *Me\posG <> *Me\posW
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
          Else
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW)
          EndIf
          ; ---[ No More Selection ]------------------------------------------
          *Me\posW = *Me\posG
          ; ---[ Positions Lookup Table Is Now Dirty ]------------------------
          *Me\lookup_dirty = #True
           ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
          ; ...[ Processed ]....................................................
          ProcedureReturn( #True )
          
      EndSelect ; Select *ev_data\key ( Case #PB_EventType_KeyDown )
      
    ; ------------------------------------------------------------------------
    ;  CTRL/CMD + X (SHORTCUT_CUT)
    ; ------------------------------------------------------------------------
    Case Globals::#SHORTCUT_CUT
      ; ---[ Set Undo ]-------------------------------------------------------
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      ; ---[ Check For Selection ]--------------------------------------------
      If *Me\posG > *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posW, *Me\posG - *Me\posW ) )
        *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW
      ElseIf *Me\posG <> *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posG, *Me\posW - *Me\posG ) )
        *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
      EndIf
      ; ---[ No More Selection ]----------------------------------------------
      *Me\posW = *Me\posG
      ; ---[ Positions Lookup Table Is Now Dirty ]----------------------------
      *Me\lookup_dirty = #True
      ; ...[ Redraw Me ]....................................................
      Control::Invalidate(*Me)
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  CTRL/CMD + C (SHORTCUT_COPY)
    ; ------------------------------------------------------------------------
    Case Globals::#SHORTCUT_COPY
      ; ---[ Check For Selection ]--------------------------------------------
      If *Me\posG > *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posW, *Me\posG - *Me\posW ) )
      ElseIf *Me\posG <> *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posG, *Me\posW - *Me\posG ) )
      EndIf
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  CTRL/CMD + V (SHORTCUT_PASTE)
    ; ------------------------------------------------------------------------
    Case Globals::#SHORTCUT_PASTE
      ; ---[ Set Undo ]-------------------------------------------------------
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      ; ---[ Retrieve Clipboard Text ]----------------------------------------
      Protected cliptxt.s = GetClipboardText()
      Protected cliplen.i = Len(cliptxt)
      ; ---[ Check For Selection ]--------------------------------------------
      If *Me\posG > *Me\posW
        *Me\value = Left(*Me\value,*Me\posW-1) + cliptxt + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW
      Else
        *Me\value = Left(*Me\value,*Me\posG-1) + cliptxt + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
      EndIf
      ; ---[ Update Strong Cursor Position ]----------------------------------
      *Me\posG + cliplen
      ; ---[ No More Selection ]----------------------------------------------
      *Me\posW = *Me\posG
      ; ---[ Positions Lookup Table Is Now Dirty ]----------------------------
      *Me\lookup_dirty = #True
      ; ...[ Redraw Me ]....................................................
      Control::Invalidate(*Me)
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  CTRL/CMD + Z (SHORTCUT_UNDO)
    ; ------------------------------------------------------------------------
  Case Globals::#SHORTCUT_UNDO
    Debug "Control Z"
      ; ---[ Restore Value And Strong & Weak Cursor Positions ]---------------
      *Me\value = *Me\undo_ctz_t
      *Me\posG  = *Me\undo_ctz_g
      *Me\posW  = *Me\undo_ctz_w
      ; ---[ Positions Lookup Table Is Now Dirty ]----------------------------
      *Me\lookup_dirty = #True
      ; ...[ Redraw Me ]....................................................
      Control::Invalidate(*Me)
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Enable
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Enable
      If Not *Me\enable
        *Me\enable = #True
        If *Me\visible
          ; ...[ Redraw Me ]....................................................
          Control::Invalidate(*Me)
      
        EndIf
      EndIf
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )

    ; ------------------------------------------------------------------------
    ;  Disable
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Disable
      If *Me\enable
        *Me\enable = #False
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ; ...[ Processed ]....................................................
      ProcedureReturn( #True )

  EndSelect
  
  ; ---[ Process Default ]----------------------------------------------------
  ProcedureReturn( #False )
  
EndProcedure
;}


; ============================================================================
;  IMPLEMENTATION ( CControlNumber )
; ============================================================================
;{
; ---[ SetValue ]-------------------------------------------------------------
Procedure SetValue( *Me.ControlNumber_t, value.s )
  
  ; ---[ Sanity Check ]-------------------------------------------------------
  If value = *Me\value
    ; ...[ Abort ]............................................................
    ProcedureReturn
  EndIf
  
  
  ; ---[ Set Value ]----------------------------------------------------------
  *Me\value = value
  *Me\lookup_dirty = #True
  
  ; ---[ Redraw Control ]-----------------------------------------------------
  Control::Invalidate(*Me)
  
EndProcedure
; ---[ GetValue ]-------------------------------------------------------------
Procedure.s GetValue( *Me.ControlNumber_t )
  
  ; ---[ Return Value ]-------------------------------------------------------
  ProcedureReturn( *Me\value )
  
EndProcedure
; ---[ Free ]-----------------------------------------------------------------
Procedure Delete( *Me.ControlNumber_t )
 
  
  ; ---[ Deallocate Memory ]--------------------------------------------------
  FreeMemory( *Me )
  
EndProcedure
;}



; ============================================================================
;  CONSTRUCTORS
; ============================================================================
;{
; ---[ Stack ]----------------------------------------------------------------
Procedure.i New(*object.Object::Object_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *Me.ControlNumber_t = AllocateMemory( SizeOf(ControlNumber_t) )
  
;   *Me\VT = ?ControlNumberVT
;   *Me\classname = "CONTROLNUMBER"
  Object::INI(ControlNumber)
  *Me\object = *object
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type         = Control::#PB_GadgetType_Number
  *Me\name         = name
  *Me\gadgetID     = #Null
  *Me\posX         = x
  *Me\posY         = y
  *Me\sizX         = width
  *Me\sizY         = 18
  *Me\visible      = #True
  *Me\enable       = #True
  *Me\options      = options
  
  If *Me\options & ControlNumber::#NUMBER_INTEGER
    *Me\value = Str(value)
  Else
    *Me\value        = StrD( value, 3 )
  EndIf
  
  *Me\value_n      = value
  *Me\hard_min     = hard_min
  *Me\hard_max     = hard_max
  *Me\soft_min     = soft_min
  *Me\soft_max     = soft_max
  *Me\undo_esc     = ""
  *Me\undo_ctz_t   = ""
  *Me\over         = #False
  *Me\down         = #False
  *Me\focused      = #False
  *Me\selected     = #False
  *Me\posG         = 1
  *Me\posW         = 1
  *Me\posS         = 1
  *Me\caret_switch = 1
  *Me\timer_on     = #False
  *Me\lookup_dirty = #True
  *Me\lookup_count = 0
  
  ; ---[ Init Array ]---------------------------------------------------------
  InitializeStructure( *Me, ControlNumber_t )
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ProcedureReturn( *Me )
  
EndProcedure

;}


; ============================================================================
;  PROCEDURES
; ============================================================================
;{
Procedure SetTheme( theme.i )
  MessageRequester("NUMBER","SET THEME : "+Str(theme))
  Select theme
      
    ; ---[ Light ]------------------------------------------------------------
    Case Globals::#GUI_THEME_LIGHT
      ; ...[ Disabled ].......................................................
      s_gui_controls_number_disabled_l  = s_gui_controls_light_number_disabled_l
      s_gui_controls_number_disabled_c  = s_gui_controls_light_number_disabled_c
      s_gui_controls_number_disabled_r  = s_gui_controls_light_number_disabled_r
      s_gui_controls_number_disabled_s  = s_gui_controls_light_number_disabled_s
      s_gui_controls_number_disabled_cl = s_gui_controls_light_number_disabled_cl
      s_gui_controls_number_disabled_cr = s_gui_controls_light_number_disabled_cr
      ; ...[ Normal ].........................................................
      s_gui_controls_number_normal_l    = s_gui_controls_light_number_normal_l
      s_gui_controls_number_normal_c    = s_gui_controls_light_number_normal_c
      s_gui_controls_number_normal_r    = s_gui_controls_light_number_normal_r
      s_gui_controls_number_normal_s    = s_gui_controls_light_number_normal_s
      s_gui_controls_number_normal_cl   = s_gui_controls_light_number_normal_cl
      s_gui_controls_number_normal_cr   = s_gui_controls_light_number_normal_cr
      ; ...[ Over ]...........................................................
      s_gui_controls_number_over_l      = s_gui_controls_light_number_over_l
      s_gui_controls_number_over_c      = s_gui_controls_light_number_over_c
      s_gui_controls_number_over_r      = s_gui_controls_light_number_over_r
      s_gui_controls_number_over_s      = s_gui_controls_light_number_over_s
      ; ...[ Focused ]........................................................
      s_gui_controls_number_focused_l   = s_gui_controls_light_number_focused_l
      s_gui_controls_number_focused_c   = s_gui_controls_light_number_focused_c
      s_gui_controls_number_focused_r   = s_gui_controls_light_number_focused_r

    ; ---[ Dark ]-------------------------------------------------------------
    Case Globals::#GUI_THEME_DARK
      MessageRequester("NUMBER","SET DARK THEME")
      ; ...[ Disabled ].......................................................
      s_gui_controls_number_disabled_l  = s_gui_controls_dark_number_disabled_l
      s_gui_controls_number_disabled_c  = s_gui_controls_dark_number_disabled_c
      s_gui_controls_number_disabled_r  = s_gui_controls_dark_number_disabled_r
      s_gui_controls_number_disabled_s  = s_gui_controls_dark_number_disabled_s
      s_gui_controls_number_disabled_cl = s_gui_controls_dark_number_disabled_cl
      s_gui_controls_number_disabled_cr = s_gui_controls_dark_number_disabled_cr
      ; ...[ Normal ].........................................................
      s_gui_controls_number_normal_l    = s_gui_controls_dark_number_normal_l
      s_gui_controls_number_normal_c    = s_gui_controls_dark_number_normal_c
      s_gui_controls_number_normal_r    = s_gui_controls_dark_number_normal_r
      s_gui_controls_number_normal_s    = s_gui_controls_dark_number_normal_s
      s_gui_controls_number_normal_cl   = s_gui_controls_dark_number_normal_cl
      s_gui_controls_number_normal_cr   = s_gui_controls_dark_number_normal_cr
      ; ...[ Over ]...........................................................
      s_gui_controls_number_over_l      = s_gui_controls_dark_number_over_l
      s_gui_controls_number_over_c      = s_gui_controls_dark_number_over_c
      s_gui_controls_number_over_r      = s_gui_controls_dark_number_over_r
      s_gui_controls_number_over_s      = s_gui_controls_dark_number_over_s
      ; ...[ Focused ]........................................................
      s_gui_controls_number_focused_l   = s_gui_controls_dark_number_focused_l
      s_gui_controls_number_focused_c   = s_gui_controls_dark_number_focused_c
      s_gui_controls_number_focused_r   = s_gui_controls_dark_number_focused_r
      
  EndSelect
  
EndProcedure
;}


  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsNumberInitOnce
  ; ----------------------------------------------------------------------------
  Procedure Init( )
  ;CHECK_INIT
  
    ; ---[ Local Variable ]-----------------------------------------------------
    Protected img.i
    
    ; ---[ Init Once ]----------------------------------------------------------
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  LIGHT
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;{
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_light_disabled_bg )
    s_gui_controls_light_number_disabled_l  = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_disabled_c  = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_light_number_disabled_r  = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_light_disabled_cover )
    s_gui_controls_light_number_disabled_cl = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_disabled_cr = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_light_disabled_slider )
    s_gui_controls_light_number_disabled_s  = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_light_normal_bg )
    s_gui_controls_light_number_normal_l    = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_normal_c    = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_light_number_normal_r    = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_light_normal_cover )
    s_gui_controls_light_number_normal_cl   = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_normal_cr   = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_light_normal_slider )
    s_gui_controls_light_number_normal_s    = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_light_over_bg )
    s_gui_controls_light_number_over_l      = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_over_c      = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_light_number_over_r      = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_light_over_slider )
    s_gui_controls_light_number_over_s      = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Focused ]............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_light_focused )
    s_gui_controls_light_number_focused_l   = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_light_number_focused_c   = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_light_number_focused_r   = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    ;}
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  DARK
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;{
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_disabled_bg )
    s_gui_controls_dark_number_disabled_l  = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_disabled_c  = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_dark_number_disabled_r  = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_disabled_cover )
    s_gui_controls_dark_number_disabled_cl = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_disabled_cr = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_disabled_slider )
    s_gui_controls_dark_number_disabled_s  = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_normal_bg )
    s_gui_controls_dark_number_normal_l    = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_normal_c    = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_dark_number_normal_r    = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_normal_cover )
    s_gui_controls_dark_number_normal_cl   = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_normal_cr   = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_normal_slider )
    s_gui_controls_dark_number_normal_s    = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_over_bg )
    s_gui_controls_dark_number_over_l      = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_over_c      = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_dark_number_over_r      = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_over_slider )
    s_gui_controls_dark_number_over_s      = GrabImage( img, #PB_Any,  16, 1, 16, 16 )
    FreeImage( img )
    ; ...[ Focused ]............................................................
    img = CatchImage( #PB_Any, ?VIControlNumber_dark_focused )
    s_gui_controls_dark_number_focused_l   = GrabImage( img, #PB_Any,   0, 0,  8, 18 )
    s_gui_controls_dark_number_focused_c   = GrabImage( img, #PB_Any,  16, 0, 16, 18 )
    s_gui_controls_dark_number_focused_r   = GrabImage( img, #PB_Any, 165, 0,  8, 18 )
    FreeImage( img )
    ;}
    
    SetTheme(Globals::#GUI_THEME_LIGHT)
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsNumberTermOnce
  ; ----------------------------------------------------------------------------
  Procedure Term( )
  ;CHECK_INIT  
    
    ; ---[ Term Once ]----------------------------------------------------------
    ; °°°[ Free Images ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ; ...[ Dark ]...............................................................
    FreeImage( s_gui_controls_dark_number_focused_r   )
    FreeImage( s_gui_controls_dark_number_focused_c   )
    FreeImage( s_gui_controls_dark_number_focused_l   )
    FreeImage( s_gui_controls_dark_number_over_s      )
    FreeImage( s_gui_controls_dark_number_over_r      )
    FreeImage( s_gui_controls_dark_number_over_c      )
    FreeImage( s_gui_controls_dark_number_over_l      )
    FreeImage( s_gui_controls_dark_number_normal_cr   )
    FreeImage( s_gui_controls_dark_number_normal_cl   )
    FreeImage( s_gui_controls_dark_number_normal_s    )
    FreeImage( s_gui_controls_dark_number_normal_r    )
    FreeImage( s_gui_controls_dark_number_normal_c    )
    FreeImage( s_gui_controls_dark_number_normal_l    )
    FreeImage( s_gui_controls_dark_number_disabled_cr )
    FreeImage( s_gui_controls_dark_number_disabled_cl )
    FreeImage( s_gui_controls_dark_number_disabled_s  )
    FreeImage( s_gui_controls_dark_number_disabled_r  )
    FreeImage( s_gui_controls_dark_number_disabled_c  )
    FreeImage( s_gui_controls_dark_number_disabled_l  )
  
    ; ...[ Light ]..............................................................
    FreeImage( s_gui_controls_light_number_focused_r   )
    FreeImage( s_gui_controls_light_number_focused_c   )
    FreeImage( s_gui_controls_light_number_focused_l   )
    FreeImage( s_gui_controls_light_number_over_s      )
    FreeImage( s_gui_controls_light_number_over_r      )
    FreeImage( s_gui_controls_light_number_over_c      )
    FreeImage( s_gui_controls_light_number_over_l      )
    FreeImage( s_gui_controls_light_number_normal_cr   )
    FreeImage( s_gui_controls_light_number_normal_cl   )
    FreeImage( s_gui_controls_light_number_normal_s    )
    FreeImage( s_gui_controls_light_number_normal_r    )
    FreeImage( s_gui_controls_light_number_normal_c    )
    FreeImage( s_gui_controls_light_number_normal_l    )
    FreeImage( s_gui_controls_light_number_disabled_cr )
    FreeImage( s_gui_controls_light_number_disabled_cl )
    FreeImage( s_gui_controls_light_number_disabled_s  )
    FreeImage( s_gui_controls_light_number_disabled_r  )
    FreeImage( s_gui_controls_light_number_disabled_c  )
    FreeImage( s_gui_controls_light_number_disabled_l  )
  
  
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlNumber )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 1501
; FirstLine = 1473
; Folding = -----
; EnableXP