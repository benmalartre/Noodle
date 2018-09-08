XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../ui/View.pbi"
; ==============================================================================
;  CONTROL EDIT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlEdit 
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  Light
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_light_edit_disabled_l.i
  Global s_gui_controls_light_edit_disabled_c.i
  Global s_gui_controls_light_edit_disabled_r.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_edit_normal_l.i
  Global s_gui_controls_light_edit_normal_c.i
  Global s_gui_controls_light_edit_normal_r.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_edit_over_l.i
  Global s_gui_controls_light_edit_over_c.i
  Global s_gui_controls_light_edit_over_r.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_light_edit_focused_l.i
  Global s_gui_controls_light_edit_focused_c.i
  Global s_gui_controls_light_edit_focused_r.i
  ;}
  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_dark_edit_disabled_l.i
  Global s_gui_controls_dark_edit_disabled_c.i
  Global s_gui_controls_dark_edit_disabled_r.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_edit_normal_l.i
  Global s_gui_controls_dark_edit_normal_c.i
  Global s_gui_controls_dark_edit_normal_r.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_edit_over_l.i
  Global s_gui_controls_dark_edit_over_c.i
  Global s_gui_controls_dark_edit_over_r.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_dark_edit_focused_l.i
  Global s_gui_controls_dark_edit_focused_c.i
  Global s_gui_controls_dark_edit_focused_r.i
  ;}
  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------
  ;{
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_edit_disabled_l.i
  Global s_gui_controls_edit_disabled_c.i
  Global s_gui_controls_edit_disabled_r.i
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_edit_normal_l.i
  Global s_gui_controls_edit_normal_c.i
  Global s_gui_controls_edit_normal_r.i
  ; ...[ Over ].................................................................
  Global s_gui_controls_edit_over_l.i
  Global s_gui_controls_edit_over_c.i
  Global s_gui_controls_edit_over_r.i
  ; ...[ Focused ]..............................................................
  Global s_gui_controls_edit_focused_l.i
  Global s_gui_controls_edit_focused_c.i
  Global s_gui_controls_edit_focused_r.i
  ;}
  ;}


  ; ----------------------------------------------------------------------------
  ;  Object ( ControlEdit_t )
  ; ----------------------------------------------------------------------------
  
  Structure ControlEdit_t Extends Control::Control_t
    value       .s
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
  Interface IControlEdit Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  
  Declare New(*object.Object::Object_t,name.s, value.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlEdit_t)
  Declare OnEvent( *Me.ControlEdit_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare.s GetValue( *Me.ControlEdit_t )
  Declare SetValue( *Me.ControlEdit_t, value.s )
  Declare SetTheme( theme.i )
  Declare.b Init()
  Declare.b Term()

  ; ============================================================================
  ;  VTABLE & DATAS ( CObject + CControl + CControlEdit )
  ; ============================================================================
  ;{
  DataSection
    ControlEditVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
    
    ; Images
    ; (Light)
    VIControlEdit_light_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_edit/light.edit.disabled.png"
    VIControlEdit_light_normal: 
    IncludeBinary "../../rsc/skins/grey/control_edit/light.edit.normal.png"
    VIControlEdit_light_over: 
    IncludeBinary "../../rsc/skins/grey/control_edit/light.edit.over.png"
    VIControlEdit_light_focused: 
    IncludeBinary "../../rsc/skins/grey/control_edit/light.edit.focused.png"
    
    ; (Dark)
    VIControlEdit_dark_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_edit/dark.edit.disabled.png"
    VIControlEdit_dark_normal: 
    IncludeBinary "../../rsc/skins/grey/control_edit/dark.edit.normal.png"
    VIControlEdit_dark_over: 
    IncludeBinary "../../rsc/skins/grey/control_edit/dark.edit.over.png"
    VIControlEdit_dark_focused: 
    IncludeBinary "../../rsc/skins/grey/control_edit/dark.edit.focused.png"
    
  EndDataSection
  ;}
  
  Global CLASS.Class::Class_t

EndDeclareModule

;}


; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlEdit
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
Procedure hlpSelectWord( *Me.ControlEdit_t, cur_pos.i )
  
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
Procedure.i hlpCharPosFromMousePos( *Me.ControlEdit_t, xpos.i )
  
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
Procedure hlpDraw( *Me.ControlEdit_t, xoff.i = 0, yoff.i = 0 )
  ; ---[ Check Visible ]------------------------------------------------------
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  ; ---[ Set Font ]-----------------------------------------------------------
  Protected tc.i = UIColor::COLOR_TEXT
  DrawingFont( FontID(Globals::#FONT_NODE) )
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
  EndIf
  
  ; ---[ Reset Clipping ]-----------------------------------------------------
;   raaResetClip()
  ; ---[ Check Disabled ]-----------------------------------------------------
  If Not *Me\enable
    DrawImage( ImageID(s_gui_controls_edit_disabled_l),            0 + xoff, 0 + yoff                    )
    DrawImage( ImageID(s_gui_controls_edit_disabled_c),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
    DrawImage( ImageID(s_gui_controls_edit_disabled_r), *Me\sizX - 8 + xoff, 0 + yoff                    )
    ; ...[ Disabled Text ]....................................................
    tc = UIColor::COLOR_LABEL_DISABLED
  ; ---[ Check Focused ]------------------------------------------------------
  ElseIf *Me\focused
    DrawImage( ImageID(s_gui_controls_edit_focused_l),            0 + xoff, 0 + yoff                    )
    DrawImage( ImageID(s_gui_controls_edit_focused_c),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
    DrawImage( ImageID(s_gui_controls_edit_focused_r), *Me\sizX - 8 + xoff, 0 + yoff                    )
  ; ---[ Check Over ]---------------------------------------------------------
  ElseIf *Me\over
    DrawImage( ImageID(s_gui_controls_edit_over_l),            0 + xoff, 0 + yoff                    )
    DrawImage( ImageID(s_gui_controls_edit_over_c),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
    DrawImage( ImageID(s_gui_controls_edit_over_r), *Me\sizX - 8 + xoff, 0 + yoff                    )
  Else
    DrawImage( ImageID(s_gui_controls_edit_normal_l),            0 + xoff, 0 + yoff                    )
    DrawImage( ImageID(s_gui_controls_edit_normal_c),            8 + xoff, 0 + yoff, *Me\sizX - 16, 18 )
    DrawImage( ImageID(s_gui_controls_edit_normal_r), *Me\sizX - 8 + xoff, 0 + yoff                    )
  EndIf

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
      DrawText( tx + xoff, ty, Mid( *Me\value, *Me\posS, tlen ) , tc )
    ; °°°[ Just Caret ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  
    Else
      DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Transparent )
      ; ...[ Draw Value ].....................................................
      DrawText( tx + xoff, ty, Mid( *Me\value, *Me\posS, tlen ) , tc )
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
    DrawingMode( #PB_2DDrawing_Default|#PB_2DDrawing_Transparent )
    DrawText( tx + xoff, ty, Mid( *Me\value, *Me\posS, tlen ) , tc )
  EndIf
  DrawingMode( #PB_2DDrawing_AlphaBlend )
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ Event ]----------------------------------------------------------------
Procedure.i OnEvent( *Me.ControlEdit_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  ; ---[ Retrieve Interface ]-------------------------------------------------
  Protected Me.Control::IControl = *Me

  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not( *ev_data ):ProcedureReturn : EndIf
      
      ; ---[ Draw Control ]---------------------------------------------------
      hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    CompilerIf #PB_Compiler_Version < 560
      Case Control::#PB_EventType_Resize
    CompilerElse
      Case #PB_EventType_Resize
    CompilerEndIf
    
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not( *ev_data ):ProcedureReturn : EndIf
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
      ; ---[ Stop Caret Flashing ]--------------------------------------------
      ;RemoveWindowTimer( #MainWindow, #TIMER_CARET )
      ; ---[ Not Focused Anymore }--------------------------------------------
      *Me\focused = #False
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
        Control::SetCursor(*Me, #PB_Cursor_IBeam )
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
        If *Me\focused And *Me\down
          ; ...[ Sanity Check ]...............................................
          If Not( *ev_data ):ProcedureReturn : EndIf
          ; ...[ Update Weak Cursor Position ]................................
          *Me\posW = hlpCharPosFromMousePos( *Me, *ev_data\x )
          ; ...[ Redraw Me ]..................................................
          Control::Invalidate(*Me)
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
        ; ...[ Mouse Is Now Down ]............................................
        *Me\down = #True
        ; ...[ Check Not Yet Focused ]........................................
        If Not *Me\focused
          ; ...[ I've The Focus ].............................................
          *Me\focused = #True
          ; ...[ Save Current Text For ESC Undo ].............................
          *Me\undo_esc = *Me\value
          ; ...[ Tell Parent I'm The One Focused ]............................
          Control::Focused(*Me)
          ; ...[ Select All Text On Focus For Convenience ]...................
          *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1
        Else
          ; ...[ Sanity Check ]...............................................
          If Not( *ev_data ):ProcedureReturn : EndIf
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
        ; ...[ Processed ]....................................................
        ProcedureReturn( #True )
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftDoubleClick
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftDoubleClick
      ; ---[ Check Status ]---------------------------------------------------
      If *Me\visible And *Me\enable
        ; ...[ Sanity Check ].................................................
        If Not( *ev_data ):ProcedureReturn : EndIf
        ; ...[ Set Undo ].....................................................
        *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
        ; ...[ Select Word Under Mouse ]......................................
        hlpSelectWord( *Me, hlpCharPosFromMousePos( *Me, *ev_data\x ) )
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
      If Not( *ev_data ):ProcedureReturn : EndIf
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
      ; ---[ Redraw Me ]------------------------------------------------------
      Control::Invalidate(*Me)
      ; ---[ Processed ]------------------------------------------------------
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
          ; ---[ Loose Focus ]------------------------------------------------
          *Me\focused = #False : Control::DeFocused(*Me)
          ; ---[ Show Text From Start ]---------------------------------------
          *Me\posG = 1 : *Me\posW = 1
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Send 'OnChanged' Signal ]------------------------------------
          Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value)
;           Sig = *Me\sig_onchanged
;           Sig\Trigger( #RAA_SIGNAL_TYPE_PING, 0)
          ; ---[ Processed ]--------------------------------------------------
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
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
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
         If Not( *ev_data ):ProcedureReturn : EndIf
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Weak Cursor To Start Of Text ]-------------------------------
          *Me\posW = 1
          ; ...[ Check Modifiers ]............................................
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To Start Of Text ]...........................
            *Me\posG = *Me\posW
          EndIf
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  End
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_End
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not( *ev_data ):ProcedureReturn : EndIf
          ; ---[ Set Undo ]---------------------------------------------------
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          ; ---[ Weak Cursor To End Of Text ]---------------------------------
          *Me\posW = Len(*Me\value) + 1
          ; ...[ Check Modifiers ]............................................
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            ; ...[ Strong Cursor To End Of Text ].............................
            *Me\posG = *Me\posW
          EndIf
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Left
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Left
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not( *ev_data ):ProcedureReturn : EndIf
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
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
          ProcedureReturn( #True )
        ;_____________________________________________________________________
        ;  Right
        ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Case #PB_Shortcut_Right
          ; ---[ Sanity Check ]-----------------------------------------------
          If Not( *ev_data ):ProcedureReturn : EndIf
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
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
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
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
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
          ; ---[ Redraw Me ]--------------------------------------------------
          Control::Invalidate(*Me)
          ; ---[ Processed ]--------------------------------------------------
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
      ; ---[ Redraw Me ]------------------------------------------------------
      Control::Invalidate(*Me)
      ; ---[ Processed ]------------------------------------------------------
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
      ; ---[ Redraw Me ]------------------------------------------------------
      Control::Invalidate(*Me)
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  CTRL/CMD + Z (SHORTCUT_UNDO)
    ; ------------------------------------------------------------------------
    Case Globals::#SHORTCUT_UNDO
      ; ---[ Restore Value And Strong & Weak Cursor Positions ]---------------
      *Me\value = *Me\undo_ctz_t
      *Me\posG  = *Me\undo_ctz_g
      *Me\posW  = *Me\undo_ctz_w
      ; ---[ Positions Lookup Table Is Now Dirty ]----------------------------
      *Me\lookup_dirty = #True
      ; ---[ Redraw Me ]------------------------------------------------------
      Control::Invalidate(*Me)
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Enable
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Enable
      If Not *Me\enable
        *Me\enable = #True
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ; ---[ Processed ]------------------------------------------------------
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
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )

  EndSelect
  
  ; ---[ Process Default ]----------------------------------------------------
  ProcedureReturn( #False )
  
EndProcedure
;}

  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlEdit )
  ; ============================================================================
  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetValue( *Me.ControlEdit_t, value.s )
    
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
  Procedure.s GetValue( *Me.ControlEdit_t )
    
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlEdit_t )
    
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure





; ============================================================================
;  CONSTRUCTORS
; ============================================================================
;{
; ---[ Stack ]----------------------------------------------------------------
Procedure.i New(*object.Object::Object_t,name.s, value.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *Me.ControlEdit_t = AllocateMemory( SizeOf(ControlEdit_t) )
  
;   *Me\VT = ?ControlEditVT
;   *Me\classname = "CONTROLEDIT"
  Object::INI(ControlEdit)
  *Me\object = *object
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type         = Control::#CONTROL_EDIT
  *Me\name         = name
  *Me\gadgetID     = #Null
  *Me\posX         = x
  *Me\posY         = y
  *Me\sizX         = width
  *Me\sizY         = 18
  *Me\visible      = #True
  *Me\enable       = #True
  *Me\options      = options
  *Me\value        = value
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
  InitializeStructure( *Me, ControlEdit_t )
  
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ProcedureReturn( *Me )
  
EndProcedure



  ; ----------------------------------------------------------------------------
  ;  Set Theme
  ; ----------------------------------------------------------------------------
  Procedure SetTheme( theme.i )
    
    Select theme
        
      ; ---[ Light ]------------------------------------------------------------
      Case Globals::#GUI_THEME_LIGHT
        ; ...[ Disabled ].......................................................
        s_gui_controls_edit_disabled_l = s_gui_controls_light_edit_disabled_l
        s_gui_controls_edit_disabled_c = s_gui_controls_light_edit_disabled_c
        s_gui_controls_edit_disabled_r = s_gui_controls_light_edit_disabled_r
        ; ...[ Normal ].........................................................
        s_gui_controls_edit_normal_l   = s_gui_controls_light_edit_normal_l
        s_gui_controls_edit_normal_c   = s_gui_controls_light_edit_normal_c
        s_gui_controls_edit_normal_r   = s_gui_controls_light_edit_normal_r
        ; ...[ Over ]...........................................................
        s_gui_controls_edit_over_l     = s_gui_controls_light_edit_over_l
        s_gui_controls_edit_over_c     = s_gui_controls_light_edit_over_c
        s_gui_controls_edit_over_r     = s_gui_controls_light_edit_over_r
        ; ...[ Focused ]........................................................
        s_gui_controls_edit_focused_l  = s_gui_controls_light_edit_focused_l
        s_gui_controls_edit_focused_c  = s_gui_controls_light_edit_focused_c
        s_gui_controls_edit_focused_r  = s_gui_controls_light_edit_focused_r
  
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARK
        ; ...[ Disabled ].......................................................
        s_gui_controls_edit_disabled_l = s_gui_controls_dark_edit_disabled_l
        s_gui_controls_edit_disabled_c = s_gui_controls_dark_edit_disabled_c
        s_gui_controls_edit_disabled_r = s_gui_controls_dark_edit_disabled_r
        ; ...[ Normal ].........................................................
        s_gui_controls_edit_normal_l   = s_gui_controls_dark_edit_normal_l
        s_gui_controls_edit_normal_c   = s_gui_controls_dark_edit_normal_c
        s_gui_controls_edit_normal_r   = s_gui_controls_dark_edit_normal_r
        ; ...[ Over ]...........................................................
        s_gui_controls_edit_over_l     = s_gui_controls_dark_edit_over_l
        s_gui_controls_edit_over_c     = s_gui_controls_dark_edit_over_c
        s_gui_controls_edit_over_r     = s_gui_controls_dark_edit_over_r
        ; ...[ Focused ]........................................................
        s_gui_controls_edit_focused_l  = s_gui_controls_dark_edit_focused_l
        s_gui_controls_edit_focused_c  = s_gui_controls_dark_edit_focused_c
        s_gui_controls_edit_focused_r  = s_gui_controls_dark_edit_focused_r
        
    EndSelect
    
  EndProcedure
  ;}


  ; ----------------------------------------------------------------------------
  ;  InitOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )

    ; ---[ Local Variable ]-----------------------------------------------------
    Protected img.i
    
    ; ---[ Init Once ]----------------------------------------------------------
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  LIGHT
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_light_disabled )
    s_gui_controls_light_edit_disabled_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_light_edit_disabled_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_light_edit_disabled_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_light_normal )
    s_gui_controls_light_edit_normal_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_light_edit_normal_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_light_edit_normal_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_light_over )
    s_gui_controls_light_edit_over_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_light_edit_over_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_light_edit_over_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Focused ]............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_light_focused )
    s_gui_controls_light_edit_focused_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_light_edit_focused_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_light_edit_focused_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  DARK
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ; ...[ Disabled ]...........................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_dark_disabled )
    s_gui_controls_dark_edit_disabled_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_dark_edit_disabled_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_dark_edit_disabled_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Normal ].............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_dark_normal )
    s_gui_controls_dark_edit_normal_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_dark_edit_normal_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_dark_edit_normal_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Over ]...............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_dark_over )
    s_gui_controls_dark_edit_over_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_dark_edit_over_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_dark_edit_over_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
    ; ...[ Focused ]............................................................
    img = CatchImage( #PB_Any, ?VIControlEdit_dark_focused )
    s_gui_controls_dark_edit_focused_l = GrabImage( img, #PB_Any,   0, 0,   8, 18 )
    s_gui_controls_dark_edit_focused_c = GrabImage( img, #PB_Any,   8, 0, 157, 18 )
    s_gui_controls_dark_edit_focused_r = GrabImage( img, #PB_Any, 165, 0,   8, 18 )
    FreeImage( img )
   
    SetTheme(Globals::#GUI_THEME_LIGHT)
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsEditTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  
    ; ---[ Term Once ]----------------------------------------------------------
    ; °°°[ Free Images ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ; ...[ Dark ]...............................................................
    FreeImage( s_gui_controls_dark_edit_focused_r  )
    FreeImage( s_gui_controls_dark_edit_focused_c  )
    FreeImage( s_gui_controls_dark_edit_focused_l  )
    FreeImage( s_gui_controls_dark_edit_over_r     )
    FreeImage( s_gui_controls_dark_edit_over_c     )
    FreeImage( s_gui_controls_dark_edit_over_l     )
    FreeImage( s_gui_controls_dark_edit_normal_r   )
    FreeImage( s_gui_controls_dark_edit_normal_c   )
    FreeImage( s_gui_controls_dark_edit_normal_l   )
    FreeImage( s_gui_controls_dark_edit_disabled_r )
    FreeImage( s_gui_controls_dark_edit_disabled_c )
    FreeImage( s_gui_controls_dark_edit_disabled_l )

    ; ...[ Light ]..............................................................
    FreeImage( s_gui_controls_light_edit_focused_r  )
    FreeImage( s_gui_controls_light_edit_focused_c  )
    FreeImage( s_gui_controls_light_edit_focused_l  )
    FreeImage( s_gui_controls_light_edit_over_r     )
    FreeImage( s_gui_controls_light_edit_over_c     )
    FreeImage( s_gui_controls_light_edit_over_l     )
    FreeImage( s_gui_controls_light_edit_normal_r   )
    FreeImage( s_gui_controls_light_edit_normal_c   )
    FreeImage( s_gui_controls_light_edit_normal_l   )
    FreeImage( s_gui_controls_light_edit_disabled_r )
    FreeImage( s_gui_controls_light_edit_disabled_c )
    FreeImage( s_gui_controls_light_edit_disabled_l )

    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlEdit )
  
EndModule




; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1042
; FirstLine = 1038
; Folding = -----
; EnableXP