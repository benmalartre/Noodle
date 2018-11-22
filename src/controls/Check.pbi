XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  CONTROL CHECK MODULE DECLARATION
; ==============================================================================
DeclareModule ControlCheck
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ; ----------------------------------------------------------------------------
  ;  Light
  ; ----------------------------------------------------------------------------
  
  Global s_gui_controls_light_check_disabled_checked     .i
  Global s_gui_controls_light_check_disabled_unchecked   .i
  Global s_gui_controls_light_check_disabled_undetermined.i
  Global s_gui_controls_light_check_normal_checked       .i
  Global s_gui_controls_light_check_normal_unchecked     .i
  Global s_gui_controls_light_check_normal_undetermined  .i
  Global s_gui_controls_light_check_over_checked         .i
  Global s_gui_controls_light_check_over_unchecked       .i
  Global s_gui_controls_light_check_over_undetermined    .i
  
  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  Global s_gui_controls_dark_check_disabled_checked     .i
  Global s_gui_controls_dark_check_disabled_unchecked   .i
  Global s_gui_controls_dark_check_disabled_undetermined.i
  Global s_gui_controls_dark_check_normal_checked       .i
  Global s_gui_controls_dark_check_normal_unchecked     .i
  Global s_gui_controls_dark_check_normal_undetermined  .i
  Global s_gui_controls_dark_check_over_checked         .i
  Global s_gui_controls_dark_check_over_unchecked       .i
  Global s_gui_controls_dark_check_over_undetermined    .i
  
  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------
  Global s_gui_controls_check_disabled_checked     .i
  Global s_gui_controls_check_disabled_unchecked   .i
  Global s_gui_controls_check_disabled_undetermined.i
  Global s_gui_controls_check_normal_checked       .i
  Global s_gui_controls_check_normal_unchecked     .i
  Global s_gui_controls_check_normal_undetermined  .i
  Global s_gui_controls_check_over_checked         .i
  Global s_gui_controls_check_over_unchecked       .i
  Global s_gui_controls_check_over_undetermined    .i

  
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlCheck_t )
  ; ----------------------------------------------------------------------------
  Structure ControlCheck_t Extends Control::Control_t
  label.s
  value.i
  over .i
  down.i
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlCheck Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  Declare New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 40, height.i = 18 )
  Declare Delete(*Me.ControlCheck_t)
  Declare OnEvent( *Me.ControlCheck_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetTheme( theme.i)
  Declare SetValue( *Me.ControlCheck_t, value.i )
  Declare GetValue( *Me.ControlCheck_t)
  Declare.b Init()
  Declare.b Term()
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlCheckVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    ; Images
    ; (Light)
    VIControlCheck_light_disabled_checked:      
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.disabled.checked.png"
    VIControlCheck_light_disabled_unchecked:    
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.disabled.unchecked.png"
    VIControlCheck_light_disabled_undetermined: 
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.disabled.undetermined.png"
    VIControlCheck_light_normal_checked:        
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.normal.checked.png"
    VIControlCheck_light_normal_unchecked:      
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.normal.unchecked.png"
    VIControlCheck_light_normal_undetermined:   
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.normal.undetermined.png"
    VIControlCheck_light_over_checked:          
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.over.checked.png"
    VIControlCheck_light_over_unchecked:        
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.over.unchecked.png"
    VIControlCheck_light_over_undetermined:     
    IncludeBinary "../../rsc/skins/grey/control_check/light.check.over.undetermined.png"
    
    ; (Dark)
    VIControlCheck_dark_disabled_checked:      
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.disabled.checked.png"
    VIControlCheck_dark_disabled_unchecked:    
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.disabled.unchecked.png"
    VIControlCheck_dark_disabled_undetermined: 
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.disabled.undetermined.png"
    VIControlCheck_dark_normal_checked:        
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.normal.checked.png"
    VIControlCheck_dark_normal_unchecked:      
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.normal.unchecked.png"
    VIControlCheck_dark_normal_undetermined:   
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.normal.undetermined.png"
    VIControlCheck_dark_over_checked:          
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.over.checked.png"
    VIControlCheck_dark_over_unchecked:        
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.over.unchecked.png"
    VIControlCheck_dark_over_undetermined:     
    IncludeBinary "../../rsc/skins/grey/control_check/dark.check.over.undetermined.png"

  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule




; ==============================================================================
;  CONTROL CHECK MODULE IMPLEMENTATTION
; ==============================================================================
Module ControlCheck
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlCheck_t, xoff.i = 0, yoff.i = 0 )
    
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = UIColor::COLOR_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont(FontID( Globals::#FONT_DEFAULT ), Globals::#FONT_SIZE_LABEL)
    Protected ty = ( *Me\sizY - VectorTextHeight( *Me\label ) )/2 + yoff
    
    ; ---[ Reset Clipping ]-----------------------------------------------------
  ;   raaResetClip()
    
    MovePathCursor(0 + xoff, 0 + yoff)
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
      ; ...[ Dispatch Value ]...................................................
      Select *Me\value
        Case  1 : DrawVectorImage( ImageID(s_gui_controls_check_disabled_checked     ))
        Case  0 : DrawVectorImage( ImageID(s_gui_controls_check_disabled_unchecked   ))
        Case -1 : DrawVectorImage( ImageID(s_gui_controls_check_disabled_undetermined))
      EndSelect
      ; ...[ Disabled Text ]....................................................
      tc = UIColor::COLOR_LABEL_DISABLED
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      ; ...[ Dispatch Value ]...................................................
      Select *Me\value
        Case  1 : DrawVectorImage( ImageID(s_gui_controls_check_over_checked     ) )
        Case  0 : DrawVectorImage( ImageID(s_gui_controls_check_over_unchecked   ) )
        Case -1 : DrawVectorImage( ImageID(s_gui_controls_check_over_undetermined) )
      EndSelect
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      ; ...[ Dispatch Value ]...................................................
      Select *Me\value
        Case  1 : DrawVectorImage( ImageID(s_gui_controls_check_normal_checked     ) )
        Case  0 : DrawVectorImage( ImageID(s_gui_controls_check_normal_unchecked   ) )
        Case -1 : DrawVectorImage( ImageID(s_gui_controls_check_normal_undetermined) )
      EndSelect
    EndIf
    
    ; ---[ Draw Label ]---------------------------------------------------------
    ;   raaClipBoxHole( 23 + xoff, 3 + yoff, *Me\sizX-24, *Me\sizY-6 )
    MovePathCursor( 23 + xoff, ty)
    VectorSourceColor(tc)
    DrawVectorText(*Me\label )
  EndProcedure
  ;}
  
  
  ; ============================================================================
  ;  OVERRIDE ( Control::IControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlCheck_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
    
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        hlpDraw( *Me.ControlCheck_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version <560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
      
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Cancel Height Resize ]...........................................
        *Me\sizY = 18
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
        Debug "Mouse Enter ---> Visible : "+Str(*Me\visible)+", Enable : "+Str(*Me\enable)
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
            Debug "TRIGGER FROM CHECK"
            PostEvent(Globals::#EVENT_PARAMETER_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
            Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,@*Me\value)
;             Protected sig.CSlot = *Me\sig_onchanged
;             sig\Trigger( #RAA_SIGNAL_TYPE_PING, @*Me\value )
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
  ;  IMPLEMENTATION ( Control::IControlCheck )
  ; ============================================================================
  ;{
  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetValue( *Me.ControlCheck_t, value.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If value = *Me\value
      ; ...[ Abort ]............................................................
      ProcedureReturn( void )
    EndIf
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
    
    ; ---[ Set Check Value ]----------------------------------------------------
    *Me\value = value
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    Control::Invalidate(*Me)
    
  EndProcedure
  ; ---[ GetValue ]-------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlCheck_t )
    
    ; ---[ Return Check Value ]-------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlCheck_t )
    ;OSlot_Release(*Me\sig_onchanged)
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New( *object.Object::Object_t,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 40, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlCheck_t = AllocateMemory( SizeOf(ControlCheck_t) )
;     
;     *Me\VT = ?ControlCheckVT
;     *Me\classname = "CONTROLCHECK"
    Object::Ini(ControlCheck)
    
    *Me\object = *object
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#CONTROL_CHECK
    *Me\name     = name
    *Me\gadgetID = #Null
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = 18
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\options  = options
    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    *Me\value    = value
    *Me\over     = #False
    *Me\down     = #False
    
    ; ---[ Init 'OnChanged' Slot ]----------------------------------------------
;     *Me\sig_onchanged = newCSlot( *Me )
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  Procedure SetTheme( theme.i )
    
    Select theme
        
      ; ---[ Light ]------------------------------------------------------------
      Case Globals::#GUI_THEME_LIGHT
        s_gui_controls_check_disabled_checked      = s_gui_controls_light_check_disabled_checked
        s_gui_controls_check_disabled_unchecked    = s_gui_controls_light_check_disabled_unchecked
        s_gui_controls_check_disabled_undetermined = s_gui_controls_light_check_disabled_undetermined
        s_gui_controls_check_normal_checked        = s_gui_controls_light_check_normal_checked
        s_gui_controls_check_normal_unchecked      = s_gui_controls_light_check_normal_unchecked
        s_gui_controls_check_normal_undetermined   = s_gui_controls_light_check_normal_undetermined
        s_gui_controls_check_over_checked          = s_gui_controls_light_check_over_checked
        s_gui_controls_check_over_unchecked        = s_gui_controls_light_check_over_unchecked
        s_gui_controls_check_over_undetermined     = s_gui_controls_light_check_over_undetermined
        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARK
        s_gui_controls_check_disabled_checked      = s_gui_controls_dark_check_disabled_checked
        s_gui_controls_check_disabled_unchecked    = s_gui_controls_dark_check_disabled_unchecked
        s_gui_controls_check_disabled_undetermined = s_gui_controls_dark_check_disabled_undetermined
        s_gui_controls_check_normal_checked        = s_gui_controls_dark_check_normal_checked
        s_gui_controls_check_normal_unchecked      = s_gui_controls_dark_check_normal_unchecked
        s_gui_controls_check_normal_undetermined   = s_gui_controls_dark_check_normal_undetermined
        s_gui_controls_check_over_checked          = s_gui_controls_dark_check_over_checked
        s_gui_controls_check_over_unchecked        = s_gui_controls_dark_check_over_unchecked
        s_gui_controls_check_over_undetermined     = s_gui_controls_dark_check_over_undetermined
        
    EndSelect
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )
  ;CHECK_INIT
    
    ; ---[ Init Once ]----------------------------------------------------------
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  LIGHT
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;{
    s_gui_controls_light_check_disabled_checked      = CatchImage( #PB_Any, ?VIControlCheck_light_disabled_checked      )
    s_gui_controls_light_check_disabled_unchecked    = CatchImage( #PB_Any, ?VIControlCheck_light_disabled_unchecked    )
    s_gui_controls_light_check_disabled_undetermined = CatchImage( #PB_Any, ?VIControlCheck_light_disabled_undetermined )
    s_gui_controls_light_check_normal_checked        = CatchImage( #PB_Any, ?VIControlCheck_light_normal_checked        )
    s_gui_controls_light_check_normal_unchecked      = CatchImage( #PB_Any, ?VIControlCheck_light_normal_unchecked      )
    s_gui_controls_light_check_normal_undetermined   = CatchImage( #PB_Any, ?VIControlCheck_light_normal_undetermined   )
    s_gui_controls_light_check_over_checked          = CatchImage( #PB_Any, ?VIControlCheck_light_over_checked          )
    s_gui_controls_light_check_over_unchecked        = CatchImage( #PB_Any, ?VIControlCheck_light_over_unchecked        )
    s_gui_controls_light_check_over_undetermined     = CatchImage( #PB_Any, ?VIControlCheck_light_over_undetermined     )
    ;}
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  DARK
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;{
    s_gui_controls_dark_check_disabled_checked      = CatchImage( #PB_Any, ?VIControlCheck_dark_disabled_checked      )
    s_gui_controls_dark_check_disabled_unchecked    = CatchImage( #PB_Any, ?VIControlCheck_dark_disabled_unchecked    )
    s_gui_controls_dark_check_disabled_undetermined = CatchImage( #PB_Any, ?VIControlCheck_dark_disabled_undetermined )
    s_gui_controls_dark_check_normal_checked        = CatchImage( #PB_Any, ?VIControlCheck_dark_normal_checked        )
    s_gui_controls_dark_check_normal_unchecked      = CatchImage( #PB_Any, ?VIControlCheck_dark_normal_unchecked      )
    s_gui_controls_dark_check_normal_undetermined   = CatchImage( #PB_Any, ?VIControlCheck_dark_normal_undetermined   )
    s_gui_controls_dark_check_over_checked          = CatchImage( #PB_Any, ?VIControlCheck_dark_over_checked          )
    s_gui_controls_dark_check_over_unchecked        = CatchImage( #PB_Any, ?VIControlCheck_dark_over_unchecked        )
    s_gui_controls_dark_check_over_undetermined     = CatchImage( #PB_Any, ?VIControlCheck_dark_over_undetermined     )
    ;}
    
    SetTheme(Globals::#GUI_THEME_LIGHT)
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  raaGuiControlsCheckTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  ;CHECK_INIT  
 
    
    ; ---[ Term Once ]----------------------------------------------------------
    ; 같�[ Free Images ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;{
    ; ...[ Dark ]...............................................................
    ;{
    FreeImage( s_gui_controls_dark_check_over_undetermined     )
    FreeImage( s_gui_controls_dark_check_over_unchecked        )
    FreeImage( s_gui_controls_dark_check_over_checked          )
    FreeImage( s_gui_controls_dark_check_normal_undetermined   )
    FreeImage( s_gui_controls_dark_check_normal_unchecked      )
    FreeImage( s_gui_controls_dark_check_normal_checked        )
    FreeImage( s_gui_controls_dark_check_disabled_undetermined )
    FreeImage( s_gui_controls_dark_check_disabled_unchecked    )
    FreeImage( s_gui_controls_dark_check_disabled_checked      )
    ;}
    ; ...[ Light ]..............................................................
    ;{
    FreeImage( s_gui_controls_light_check_over_undetermined     )
    FreeImage( s_gui_controls_light_check_over_unchecked        )
    FreeImage( s_gui_controls_light_check_over_checked          )
    FreeImage( s_gui_controls_light_check_normal_undetermined   )
    FreeImage( s_gui_controls_light_check_normal_unchecked      )
    FreeImage( s_gui_controls_light_check_normal_checked        )
    FreeImage( s_gui_controls_light_check_disabled_undetermined )
    FreeImage( s_gui_controls_light_check_disabled_unchecked    )
    FreeImage( s_gui_controls_light_check_disabled_checked      )
    ;}
    ;}
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlCheck )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 152
; FirstLine = 130
; Folding = ----
; EnableXP