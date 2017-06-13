
; ============================================================================
;  CONTROL POPUPMENU MODULE DECLARATION
; ============================================================================
DeclareModule ControlPopupMenu
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlPopUpMenu_t )
  ; ----------------------------------------------------------------------------
  Structure ControlPopupMenu_t Extends Control::Control_t
    ; CControlMenu
    label.s
    over.i
    down.i
  EndStructure
EndDeclareModule

Module ControlPopupMenu


; ============================================================================
;  CONTROL POPUPMENU MODULE IMPLEMENTATION 
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  hlpDraw
; ----------------------------------------------------------------------------
Procedure hlpDraw( *Me.ControlPopUpMenu_t, xoff.i = 0, yoff.i = 0 )

  ; ---[ Check Visible ]------------------------------------------------------
  If Not *Me\visible : ret( void ) : EndIf
  
  ; ---[ Label Color ]--------------------------------------------------------
  Protected tc.i = RAA_COLORA_LABEL
  
  ; ---[ Set Font ]-----------------------------------------------------------
  DrawingFont(FontID(Globals::#FONT_LABEL))
  
  Protected ty = ( *Me\sizY - TextHeight( *Me\label ) )/2 + yoff
  
  ; ---[ Reset Clipping ]-----------------------------------------------------
  ResetClip()
  
  ; ---[ Check Disabled ]-----------------------------------------------------
  If Not *Me\enable
    ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    DrawImage( ImageID(s_gui_controls_combo_up_disabled_l),             0 + xoff, 0 + yoff )
    raaDrawImage( ImageID(s_gui_controls_combo_up_disabled_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
    raaDrawImage( ImageID(s_gui_controls_combo_up_disabled_r), *Me\sizX - 19 + xoff, 0 + yoff )
    ; ...[ Disabled Text ]....................................................
    tc = RAA_COLORA_LABEL_DISABLED
  ; ---[ Check Over ]---------------------------------------------------------
  ElseIf *Me\over
    ; °°°[ Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    If *Me\down
      raaDrawImage( ImageID(s_gui_controls_combo_down_over_l),             0 + xoff, 0 + yoff )
      raaDrawImage( ImageID(s_gui_controls_combo_down_over_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
      raaDrawImage( ImageID(s_gui_controls_combo_down_over_r), *Me\sizX - 19 + xoff, 0 + yoff )
      ; ...[ Negate Text ]....................................................
      tc = RAA_COLORA_LABEL_NEG
    ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    Else
      raaDrawImage( ImageID(s_gui_controls_combo_up_over_l),             0 + xoff, 0 + yoff )
      raaDrawImage( ImageID(s_gui_controls_combo_up_over_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
      raaDrawImage( ImageID(s_gui_controls_combo_up_over_r), *Me\sizX - 19 + xoff, 0 + yoff )
    EndIf
  ; ---[ Normal State ]-------------------------------------------------------
  Else
    ; °°°[ Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    If *Me\down
      raaDrawImage( ImageID(s_gui_controls_combo_down_normal_l),             0 + xoff, 0 + yoff )
      raaDrawImage( ImageID(s_gui_controls_combo_down_normal_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
      raaDrawImage( ImageID(s_gui_controls_combo_down_normal_r), *Me\sizX - 19 + xoff, 0 + yoff )
      ; ...[ Negate Text ]....................................................
      tc = RAA_COLORA_LABEL_NEG
    ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    Else
      raaDrawImage( ImageID(s_gui_controls_combo_up_normal_l),             0 + xoff, 0 + yoff )
      raaDrawImage( ImageID(s_gui_controls_combo_up_normal_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
      raaDrawImage( ImageID(s_gui_controls_combo_up_normal_r), *Me\sizX - 19 + xoff, 0 + yoff )
    EndIf
  EndIf
    
  ; ---[ Draw Label ]---------------------------------------------------------
  raaClipBoxHole( 3 + xoff, 3 + yoff, *Me\sizX-6, *Me\sizY-6 )
  raaDrawText( 10 + xoff, ty, *Me\label, tc )
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure OControlCombo_OnEvent( *Me.CControlCombo_t, ev_code.i, *ev_data.EventTypeDatas_t = #Null )
  
  ; ---[ Retrieve Interface ]-------------------------------------------------
  Protected Me.CControl = *Me

  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;    Draw
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Draw
      ; ...[ Draw Control ]...................................................
      OControlCombo_hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
      ; ...[ Processed ]......................................................
      ret( #True )
      
    ; ------------------------------------------------------------------------
    ;    Resize
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Resize
      ; ...[ Sanity Check ]...................................................
      CHECK_PTR1_NULL( *ev_data )
      ; ...[ Reset Height ]...................................................
      *Me\sizY = 21
      ; ...[ Update Topology ]................................................
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ; ...[ Processed ]......................................................
      ret( #True )
      
    ; ------------------------------------------------------------------------
    ;    MouseEnter
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseEnter
      If *Me\visible And *Me\enable
        *Me\over = #True
        Me\Invalidate()
      EndIf
      
    ; ------------------------------------------------------------------------
    ;    MouseLeave
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseLeave
      If *Me\visible And *Me\enable
        *Me\over = #False
        Me\Invalidate()
      EndIf
      
    ; ------------------------------------------------------------------------
    ;    MouseMove
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
      If *Me\visible And *Me\enable
        If *Me\down
          If ( *ev_data\x < 0 ) Or ( *ev_data\x >= *Me\sizX ) Or ( *ev_data\y < 0 ) Or ( *ev_data\y >= *Me\sizY )
            If *Me\over : *Me\over = #False : Me\Invalidate() : EndIf
          Else
            If Not *Me\over : *Me\over = #True : Me\Invalidate() : EndIf
          EndIf
        EndIf
      EndIf
      
    ; ------------------------------------------------------------------------
    ;    LeftButtonDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      If *Me\visible And *Me\enable And *Me\over
        *Me\down = #True
        Me\Invalidate()
      EndIf
      
    ; ------------------------------------------------------------------------
    ;    LeftButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
        *Me\down = #False
        Me\Invalidate()
        If *Me\over
          ; TODO : >>> TRIGGER ACTION <<<
          Debug ">> Trigger ["+ *Me\label +"]"
        EndIf
      EndIf
      
    ; ------------------------------------------------------------------------
    ;    Enable
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Enable
      If *Me\visible And Not *Me\enable
        *Me\enable = #True
        Me\Invalidate()
      EndIf
      ; ...[ Processed ]......................................................
      ret( #True )

    ; ------------------------------------------------------------------------
    ;    Disable
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Disable
      If *Me\visible And *Me\enable
        *Me\enable = #False
        Me\Invalidate()
      EndIf
      ; ...[ Processed ]......................................................
      ret( #True )

  EndSelect
  
  ; ---[ Process Default ]----------------------------------------------------
  ret( #False )
  
EndProcedure
;}


; ============================================================================
;  IMPLEMENTATION ( CControlCombo )
; ============================================================================
;{
; ---[ SetLabel ]-------------------------------------------------------------
Procedure OControlCombo_SetLabel( *Me.CControlCombo_t, value.s )
  
  ; ---[ Set String Value ]---------------------------------------------------
  *Me\label = value
  
EndProcedure
; ---[ GetLabel ]-------------------------------------------------------------
Procedure.s OControlCombo_GetLabel( *Me.CControlCombo_t )
  
  ; ---[ Return String Value ]------------------------------------------------
  ret( *Me\label )
  
EndProcedure
; ---[ Free ]-----------------------------------------------------------------
Procedure OControlCombo_Free( *Me.CControlCombo_t )
  
  ; ---[ Deallocate Memory ]--------------------------------------------------
  FreeMemory( *Me )
  
EndProcedure
;}


; ============================================================================
;  VTABLE ( CObject + CControl + CControlCombo )
; ============================================================================
;{
DataSection
  ; CObject
  CObject_DAT( ControlCombo )
  ; CControl
  CControl_DAT
  Data.i @OControlCombo_OnEvent() ; mandatory override
  ; CControlCombo
  Data.i @OControlCombo_SetLabel()
  Data.i @OControlCombo_GetLabel()
  ; Images
  ; (Light)
  VIControlCombo_light_up_normal    :  IncludeBinary "../rsc/skins/grey/control_combo/light.combo.up.normal.png"
  VIControlCombo_light_up_over      :  IncludeBinary "../rsc/skins/grey/control_combo/light.combo.up.over.png"
  VIControlCombo_light_up_disabled  :  IncludeBinary "../rsc/skins/grey/control_combo/light.combo.up.disabled.png"
  VIControlCombo_light_down_normal  :  IncludeBinary "../rsc/skins/grey/control_combo/light.combo.down.normal.png"
  VIControlCombo_light_down_over    :  IncludeBinary "../rsc/skins/grey/control_combo/light.combo.down.over.png"
  ; (Dark)
  VIControlCombo_dark_up_normal     :  IncludeBinary "../rsc/skins/grey/control_combo/dark.combo.up.normal.png"
  VIControlCombo_dark_up_over       :  IncludeBinary "../rsc/skins/grey/control_combo/dark.combo.up.over.png"
  VIControlCombo_dark_up_disabled   :  IncludeBinary "../rsc/skins/grey/control_combo/dark.combo.up.disabled.png"
  VIControlCombo_dark_down_normal   :  IncludeBinary "../rsc/skins/grey/control_combo/dark.combo.down.normal.png"
  VIControlCombo_dark_down_over     :  IncludeBinary "../rsc/skins/grey/control_combo/dark.combo.down.over.png"
EndDataSection
;}


; ============================================================================
;  REFLECTION
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  CControlComboClass Object
; ----------------------------------------------------------------------------
Class_DEF( ControlCombo )
;}


; ============================================================================
;  CONSTRUCTORS
; ============================================================================
;{
; ---[ Stack ]----------------------------------------------------------------
Procedure.i nesCControlCombo( *Me.CControlCombo_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  
  ; ---[ Sanity Check ]-------------------------------------------------------
  CHECK_PTR1_NULL( *Me )
  
  ; ---[ Init CObject Base Class ]--------------------------------------------
  CObject_INI( ControlCombo )
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type        = #PB_GadgetType_Combo
  *Me\name        = name
  *Me\gadgetID    = #Null
  *Me\posX        = x
  *Me\posY        = y
  *Me\sizX        = width
  *Me\sizY        = 21
  *Me\visible     = #True
  *Me\enable      = #True
  *Me\options     = options
  If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ret( *Me )
  
EndProcedure
; ---[ Heap ]-----------------------------------------------------------------
Procedure.i newCControlCombo( name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *p.CControlCombo_t = AllocateMemory( SizeOf(CControlCombo_t) )
  
  ; ---[ Init Object ]--------------------------------------------------------
  ret( nesCControlCombo( *p, name, label, options, x, y, width, height ) )
  
EndProcedure
;}


; ============================================================================
;  PROCEDURES
; ============================================================================
;{
Procedure raaGUIControlsComboSetTheme( theme.RAA_GUI_THEME )
  
  Select theme
      
    ; ---[ Light ]------------------------------------------------------------
    Case #RAA_GUI_THEME_LIGHT
      ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_combo_up_normal_l = s_gui_controls_light_combo_up_normal_l
      s_gui_controls_combo_up_normal_c = s_gui_controls_light_combo_up_normal_c
      s_gui_controls_combo_up_normal_r = s_gui_controls_light_combo_up_normal_r
      ; ...[ Over ]...........................................................
      s_gui_controls_combo_up_over_l = s_gui_controls_light_combo_up_over_l
      s_gui_controls_combo_up_over_c = s_gui_controls_light_combo_up_over_c
      s_gui_controls_combo_up_over_r = s_gui_controls_light_combo_up_over_r
      ; ...[ Disabled ].......................................................
      s_gui_controls_combo_up_disabled_l = s_gui_controls_light_combo_up_disabled_l
      s_gui_controls_combo_up_disabled_c = s_gui_controls_light_combo_up_disabled_c
      s_gui_controls_combo_up_disabled_r = s_gui_controls_light_combo_up_disabled_r
      ;}
      ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_combo_down_normal_l = s_gui_controls_light_combo_down_normal_l
      s_gui_controls_combo_down_normal_c = s_gui_controls_light_combo_down_normal_c
      s_gui_controls_combo_down_normal_r = s_gui_controls_light_combo_down_normal_r
      ; ...[ Over ]...........................................................
      s_gui_controls_combo_down_over_l = s_gui_controls_light_combo_down_over_l
      s_gui_controls_combo_down_over_c = s_gui_controls_light_combo_down_over_c
      s_gui_controls_combo_down_over_r = s_gui_controls_light_combo_down_over_r
      ;}
      
    ; ---[ Dark ]-------------------------------------------------------------
    Case #RAA_GUI_THEME_DARK
      ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_combo_up_normal_l = s_gui_controls_dark_combo_up_normal_l
      s_gui_controls_combo_up_normal_c = s_gui_controls_dark_combo_up_normal_c
      s_gui_controls_combo_up_normal_r = s_gui_controls_dark_combo_up_normal_r
      ; ...[ Over ]...........................................................
      s_gui_controls_combo_up_over_l = s_gui_controls_dark_combo_up_over_l
      s_gui_controls_combo_up_over_c = s_gui_controls_dark_combo_up_over_c
      s_gui_controls_combo_up_over_r = s_gui_controls_dark_combo_up_over_r
      ; ...[ Disabled ].......................................................
      s_gui_controls_combo_up_disabled_l = s_gui_controls_dark_combo_up_disabled_l
      s_gui_controls_combo_up_disabled_c = s_gui_controls_dark_combo_up_disabled_c
      s_gui_controls_combo_up_disabled_r = s_gui_controls_dark_combo_up_disabled_r
      ;}
      ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      ;{
      ; ...[ Normal ].........................................................
      s_gui_controls_combo_down_normal_l = s_gui_controls_dark_combo_down_normal_l
      s_gui_controls_combo_down_normal_c = s_gui_controls_dark_combo_down_normal_c
      s_gui_controls_combo_down_normal_r = s_gui_controls_dark_combo_down_normal_r
      ; ...[ Over ]...........................................................
      s_gui_controls_combo_down_over_l = s_gui_controls_dark_combo_down_over_l
      s_gui_controls_combo_down_over_c = s_gui_controls_dark_combo_down_over_c
      s_gui_controls_combo_down_over_r = s_gui_controls_dark_combo_down_over_r
      ;}
      
  EndSelect
  
EndProcedure
;}


; ============================================================================
;  ADMINISTRATION
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  GLOBALS
; ----------------------------------------------------------------------------
ADMIN_GLOBALS( gui_controls_combo )
; ----------------------------------------------------------------------------
;  raaGuiControlsComboInitOnce
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsComboInitOnce( void )
;CHECK_INIT

  ; ---[ Init Start ]---------------------------------------------------------
  ADMIN_INIT_START( gui_controls_combo )
  
  ; ---[ Local Variable ]-----------------------------------------------------
  Protected img.i
  
  ; ---[ Init Once ]----------------------------------------------------------
  ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ;  LIGHT
  ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ;{
  ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ; ...[ Normal ].............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_light_up_normal )
  s_gui_controls_light_combo_up_normal_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_light_combo_up_normal_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_light_combo_up_normal_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Over ]...............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_light_up_over )
  s_gui_controls_light_combo_up_over_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_light_combo_up_over_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_light_combo_up_over_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Disabled ]...........................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_light_up_disabled )
  s_gui_controls_light_combo_up_disabled_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_light_combo_up_disabled_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_light_combo_up_disabled_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ; ...[ Normal ].............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_light_down_normal )
  s_gui_controls_light_combo_down_normal_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_light_combo_down_normal_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_light_combo_down_normal_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Over ]...............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_light_down_over )
  s_gui_controls_light_combo_down_over_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_light_combo_down_over_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_light_combo_down_over_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ;}
  ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ;  DARK
  ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ;{
  ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ; ...[ Normal ].............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_dark_up_normal )
  s_gui_controls_dark_combo_up_normal_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_dark_combo_up_normal_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_dark_combo_up_normal_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Over ]...............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_dark_up_over )
  s_gui_controls_dark_combo_up_over_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_dark_combo_up_over_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_dark_combo_up_over_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Disabled ]...........................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_dark_up_disabled )
  s_gui_controls_dark_combo_up_disabled_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_dark_combo_up_disabled_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_dark_combo_up_disabled_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ; ...[ Normal ].............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_dark_down_normal )
  s_gui_controls_dark_combo_down_normal_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_dark_combo_down_normal_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_dark_combo_down_normal_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ; ...[ Over ]...............................................................
  img = CatchImage( #PB_Any, ?VIControlCombo_dark_down_over )
  s_gui_controls_dark_combo_down_over_l = GrabImage( img, #PB_Any,   0, 0,   6, 21 )
  s_gui_controls_dark_combo_down_over_c = GrabImage( img, #PB_Any,   6, 0, 146, 21 )
  s_gui_controls_dark_combo_down_over_r = GrabImage( img, #PB_Any, 152, 0,  19, 21 )
  FreeImage( img )
  ;}
  
  ; ---[ Init End ]-----------------------------------------------------------
  ADMIN_INIT_END( gui_controls_combo )
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsComboTermOnce
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsComboTermOnce( void )
;CHECK_INIT  

  ; ---[ Term Start ]---------------------------------------------------------
  ADMIN_TERM_START( gui_controls_combo )
  
  ; ---[ Term Once ]----------------------------------------------------------
  ; °°°[ Free Images ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
  ;{
  ; ...[ Dark ]...............................................................
  ;{
  FreeImage( s_gui_controls_dark_combo_down_over_r )
  FreeImage( s_gui_controls_dark_combo_down_over_c )
  FreeImage( s_gui_controls_dark_combo_down_over_l )
  FreeImage( s_gui_controls_dark_combo_down_normal_r )
  FreeImage( s_gui_controls_dark_combo_down_normal_c )
  FreeImage( s_gui_controls_dark_combo_down_normal_l )
  FreeImage( s_gui_controls_dark_combo_up_disabled_r )
  FreeImage( s_gui_controls_dark_combo_up_disabled_c )
  FreeImage( s_gui_controls_dark_combo_up_disabled_l )
  FreeImage( s_gui_controls_dark_combo_up_over_r )
  FreeImage( s_gui_controls_dark_combo_up_over_c )
  FreeImage( s_gui_controls_dark_combo_up_over_l )
  FreeImage( s_gui_controls_dark_combo_up_normal_r )
  FreeImage( s_gui_controls_dark_combo_up_normal_c )
  FreeImage( s_gui_controls_dark_combo_up_normal_l )
  ;}
  ; ...[ Light ]..............................................................
  ;{
  FreeImage( s_gui_controls_light_combo_down_over_r )
  FreeImage( s_gui_controls_light_combo_down_over_c )
  FreeImage( s_gui_controls_light_combo_down_over_l )
  FreeImage( s_gui_controls_light_combo_down_normal_r )
  FreeImage( s_gui_controls_light_combo_down_normal_c )
  FreeImage( s_gui_controls_light_combo_down_normal_l )
  FreeImage( s_gui_controls_light_combo_up_disabled_r )
  FreeImage( s_gui_controls_light_combo_up_disabled_c )
  FreeImage( s_gui_controls_light_combo_up_disabled_l )
  FreeImage( s_gui_controls_light_combo_up_over_r )
  FreeImage( s_gui_controls_light_combo_up_over_c )
  FreeImage( s_gui_controls_light_combo_up_over_l )
  FreeImage( s_gui_controls_light_combo_up_normal_r )
  FreeImage( s_gui_controls_light_combo_up_normal_c )
  FreeImage( s_gui_controls_light_combo_up_normal_l )
  ;}
  ;}
  
  ; ---[ Term End ]-----------------------------------------------------------
  ADMIN_TERM_END( gui_controls_combo )
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsComboIsInitialized
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsComboIsInitialized( void )
  
  ; ---[ Return Status ]------------------------------------------------------
  ret( ADMIN_STATUS( gui_controls_combo ) )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsComboThreadAttach
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsComboThreadAttach( void )
;CHECK_INIT

  ; ---[ Thread Attach ]------------------------------------------------------
  ; NOP
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
; ----------------------------------------------------------------------------
;  raaGuiControlsComboThreadDetach
; ----------------------------------------------------------------------------
Procedure.boo raaGuiControlsComboThreadDetach( void )
;CHECK_INIT
  
  ; ---[ Thread Detach ]------------------------------------------------------
  ; NOP
  
  ; ---[ OK ]-----------------------------------------------------------------
  ret( #RAA_OK )
  
EndProcedure
;}


; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 36
; FirstLine = 168
; Folding = ------
; EnableUnicode
; EnableThread
; EnableXP