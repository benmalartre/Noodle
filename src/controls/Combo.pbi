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
  ;  Light
  ; ----------------------------------------------------------------------------
  ; ---[ Button Up ]------------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_combo_up_normal_l .i
  Global s_gui_controls_light_combo_up_normal_c .i
  Global s_gui_controls_light_combo_up_normal_r .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_combo_up_over_l .i
  Global s_gui_controls_light_combo_up_over_c .i
  Global s_gui_controls_light_combo_up_over_r .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_light_combo_up_disabled_l .i
  Global s_gui_controls_light_combo_up_disabled_c .i
  Global s_gui_controls_light_combo_up_disabled_r .i
  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_light_combo_down_normal_l .i
  Global s_gui_controls_light_combo_down_normal_c .i
  Global s_gui_controls_light_combo_down_normal_r .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_light_combo_down_over_l .i
  Global s_gui_controls_light_combo_down_over_c .i
  Global s_gui_controls_light_combo_down_over_r .i

  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  ; ---[ Button Up ]------------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_combo_up_normal_l .i
  Global s_gui_controls_dark_combo_up_normal_c .i
  Global s_gui_controls_dark_combo_up_normal_r .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_combo_up_over_l .i
  Global s_gui_controls_dark_combo_up_over_c .i
  Global s_gui_controls_dark_combo_up_over_r .i
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_dark_combo_up_disabled_l .i
  Global s_gui_controls_dark_combo_up_disabled_c .i
  Global s_gui_controls_dark_combo_up_disabled_r .i
  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_dark_combo_down_normal_l .i
  Global s_gui_controls_dark_combo_down_normal_c .i
  Global s_gui_controls_dark_combo_down_normal_r .i
  ; ...[ Over ].................................................................
  Global s_gui_controls_dark_combo_down_over_l .i
  Global s_gui_controls_dark_combo_down_over_c .i
  Global s_gui_controls_dark_combo_down_over_r .i

  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------

  ; ---[ Button Up ]------------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_combo_up_normal_l
  Global s_gui_controls_combo_up_normal_c
  Global s_gui_controls_combo_up_normal_r
  ; ...[ Over ].................................................................
  Global s_gui_controls_combo_up_over_l
  Global s_gui_controls_combo_up_over_c
  Global s_gui_controls_combo_up_over_r
  ; ...[ Disabled ].............................................................
  Global s_gui_controls_combo_up_disabled_l
  Global s_gui_controls_combo_up_disabled_c
  Global s_gui_controls_combo_up_disabled_r
  ; ---[ Button Down ]----------------------------------------------------------
  ; ...[ Normal ]...............................................................
  Global s_gui_controls_combo_down_normal_l
  Global s_gui_controls_combo_down_normal_c
  Global s_gui_controls_combo_down_normal_r
  ; ...[ Over ].................................................................
  Global s_gui_controls_combo_down_over_l
  Global s_gui_controls_combo_down_over_c
  Global s_gui_controls_combo_down_over_r




  ; ----------------------------------------------------------------------------
  ;  Object ( ControlCombo_t )
  ; ----------------------------------------------------------------------------
  
  Structure ControlCombo_t Extends Control::Control_t
    ; CControlCombo
    label.s
    over.i
    down.i
    Array items.s(0)
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlCombo Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares
  ; ----------------------------------------------------------------------------
  Declare New(*object.Object::Object_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  Declare Delete(*Me.ControlCombo_t)
  Declare OnEvent( *Me.ControlCombo_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
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
    Data.i @Delete() ; mandatory override

    ; Images
    ; (Light)
    VIControlCombo_light_up_normal:  
    IncludeBinary "../../rsc/skins/grey/control_combo/light.combo.up.normal.png"
    VIControlCombo_light_up_over:  
    IncludeBinary "../../rsc/skins/grey/control_combo/light.combo.up.over.png"
    VIControlCombo_light_up_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_combo/light.combo.up.disabled.png"
    VIControlCombo_light_down_normal:  
    IncludeBinary "../../rsc/skins/grey/control_combo/light.combo.down.normal.png"
    VIControlCombo_light_down_over:  
    IncludeBinary "../../rsc/skins/grey/control_combo/light.combo.down.over.png"
    
    ; (Dark)
    VIControlCombo_dark_up_normal:  
    IncludeBinary "../../rsc/skins/grey/control_combo/dark.combo.up.normal.png"
    VIControlCombo_dark_up_over:  
    IncludeBinary "../../rsc/skins/grey/control_combo/dark.combo.up.over.png"
    VIControlCombo_dark_up_disabled:  
    IncludeBinary "../../rsc/skins/grey/control_combo/dark.combo.up.disabled.png"
    VIControlCombo_dark_down_normal:  
    IncludeBinary "../../rsc/skins/grey/control_combo/dark.combo.down.normal.png"
    VIControlCombo_dark_down_over:  
    IncludeBinary "../../rsc/skins/grey/control_combo/dark.combo.down.over.png"
    
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
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlCombo_t, xoff.i = 0, yoff.i = 0 )
  
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = RAA_COLORA_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    DrawingFont( FontID(Globals::#FONT_LABEL ))
    Protected ty = ( *Me\sizY - TextHeight( *Me\label ) )/2 + yoff
    
    ; ---[ Reset Clipping ]-----------------------------------------------------
  ;   raaResetClip()
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
      ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      DrawImage( ImageID(s_gui_controls_combo_up_disabled_l),             0 + xoff, 0 + yoff )
      DrawImage( ImageID(s_gui_controls_combo_up_disabled_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
      DrawImage( ImageID(s_gui_controls_combo_up_disabled_r), *Me\sizX - 19 + xoff, 0 + yoff )
      ; ...[ Disabled Text ]....................................................
      tc = RAA_COLORA_LABEL_DISABLED
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; °°°[ Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      If *Me\down
        DrawImage( ImageID(s_gui_controls_combo_down_over_l),             0 + xoff, 0 + yoff )
        DrawImage( ImageID(s_gui_controls_combo_down_over_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
        DrawImage( ImageID(s_gui_controls_combo_down_over_r), *Me\sizX - 19 + xoff, 0 + yoff )
        ; ...[ Negate Text ]....................................................
        tc = RAA_COLORA_LABEL_NEG
      ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      Else
        DrawImage( ImageID(s_gui_controls_combo_up_over_l),             0 + xoff, 0 + yoff )
        DrawImage( ImageID(s_gui_controls_combo_up_over_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
        DrawImage( ImageID(s_gui_controls_combo_up_over_r), *Me\sizX - 19 + xoff, 0 + yoff )
      EndIf
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; °°°[ Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      If *Me\down
        DrawImage( ImageID(s_gui_controls_combo_down_normal_l),             0 + xoff, 0 + yoff )
        DrawImage( ImageID(s_gui_controls_combo_down_normal_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
        DrawImage( ImageID(s_gui_controls_combo_down_normal_r), *Me\sizX - 19 + xoff, 0 + yoff )
        ; ...[ Negate Text ]....................................................
        tc = RAA_COLORA_LABEL_NEG
      ; °°°[ Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
      Else
        DrawImage( ImageID(s_gui_controls_combo_up_normal_l),             0 + xoff, 0 + yoff )
        DrawImage( ImageID(s_gui_controls_combo_up_normal_c),             6 + xoff, 0 + yoff, *Me\sizX - 25, 21 )
        DrawImage( ImageID(s_gui_controls_combo_up_normal_r), *Me\sizX - 19 + xoff, 0 + yoff )
      EndIf
    EndIf
      
    ; ---[ Draw Label ]---------------------------------------------------------
    ;   raaClipBoxHole( 3 + xoff, 3 + yoff, *Me\sizX-6, *Me\sizY-6 )
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText( 10 + xoff, ty, *Me\label, tc )
    
  EndProcedure
  ;}
  
  
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
        hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
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
            PostEvent(Globals::#EVENT_COMBO_PRESSED,EventWindow(),*Me\object,#Null,@*Me\name)
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
  Procedure.i New(*object.Object::Object_t, name.s, label.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlCombo_t = AllocateMemory( SizeOf(ControlCombo_t) )
    
;     *Me\VT = ControlComboVT
;     *Me\classname = "CONTROLCOMBO"
    Object::INI(ControlCombo)
    *Me\object = *object
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type        = Control::#CONTROL_COMBO
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
    ProcedureReturn( *Me )
    
  EndProcedure

  
  
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  Procedure SetTheme( theme.i)
    
    Select theme
        
      ; ---[ Light ]------------------------------------------------------------
      Case Globals::#GUI_THEME_LIGHT
        ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
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
        ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        ; ...[ Normal ].........................................................
        s_gui_controls_combo_down_normal_l = s_gui_controls_light_combo_down_normal_l
        s_gui_controls_combo_down_normal_c = s_gui_controls_light_combo_down_normal_c
        s_gui_controls_combo_down_normal_r = s_gui_controls_light_combo_down_normal_r
        ; ...[ Over ]...........................................................
        s_gui_controls_combo_down_over_l = s_gui_controls_light_combo_down_over_l
        s_gui_controls_combo_down_over_c = s_gui_controls_light_combo_down_over_c
        s_gui_controls_combo_down_over_r = s_gui_controls_light_combo_down_over_r
        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARK
        ; °°°[ Button Up ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
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
        ; °°°[ Button Down ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
        ; ...[ Normal ].........................................................
        s_gui_controls_combo_down_normal_l = s_gui_controls_dark_combo_down_normal_l
        s_gui_controls_combo_down_normal_c = s_gui_controls_dark_combo_down_normal_c
        s_gui_controls_combo_down_normal_r = s_gui_controls_dark_combo_down_normal_r
        ; ...[ Over ]...........................................................
        s_gui_controls_combo_down_over_l = s_gui_controls_dark_combo_down_over_l
        s_gui_controls_combo_down_over_c = s_gui_controls_dark_combo_down_over_c
        s_gui_controls_combo_down_over_r = s_gui_controls_dark_combo_down_over_r

    EndSelect
    
  EndProcedure
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsComboInitOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Init(  )

    
    ; ---[ Local Variable ]-----------------------------------------------------
    Protected img.i
    
    ; ---[ Init Once ]----------------------------------------------------------
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  LIGHT
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

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

    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ;  DARK
    ; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
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
    
    SetTheme(Globals::#GUI_THEME_LIGHT)
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn #True
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsComboTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
    
    ; ---[ Term Once ]----------------------------------------------------------
    ; °°°[ Free Images ]°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
    ; ...[ Dark ]...............................................................
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

    ; ...[ Light ]..............................................................
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
; CursorPosition = 406
; FirstLine = 402
; Folding = ---
; EnableXP