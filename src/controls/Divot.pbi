XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  CONTROL DIVOT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlDivot
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  DIVOT_ANIM
  ; ----------------------------------------------------------------------------
  Enumeration
    #ANIM_NONE = 0
    #ANIM_CONSTRAINT
    #ANIM_EXPRESSION
    #ANIM_KEYFRAME
    #ANIM_OPERATOR
    #ANIM_SCRIPTED_OPERATOR
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ;  Light
  ; ----------------------------------------------------------------------------
  Global s_gui_controls_light_divot_over.i
  Global s_gui_controls_light_divot_down.i
  ; ----------------------------------------------------------------------------
  ;  Dark
  ; ----------------------------------------------------------------------------
  Global s_gui_controls_dark_divot_over.i
  Global s_gui_controls_dark_divot_down.i
  ; ----------------------------------------------------------------------------
  ;  Current
  ; ----------------------------------------------------------------------------
  Global s_gui_controls_divot_disabled         .i
  Global s_gui_controls_divot_normal           .i
  Global s_gui_controls_divot_over             .i
  Global s_gui_controls_divot_down             .i
  Global s_gui_controls_divot_anim_cns_disabled.i
  Global s_gui_controls_divot_anim_cns_down    .i
  Global s_gui_controls_divot_anim_cns_normal  .i
  Global s_gui_controls_divot_anim_cns_over    .i
  Global s_gui_controls_divot_anim_exp_disabled.i
  Global s_gui_controls_divot_anim_exp_down    .i
  Global s_gui_controls_divot_anim_exp_normal  .i
  Global s_gui_controls_divot_anim_exp_over    .i
  Global s_gui_controls_divot_anim_key_disabled.i
  Global s_gui_controls_divot_anim_key_down    .i
  Global s_gui_controls_divot_anim_key_normal  .i
  Global s_gui_controls_divot_anim_key_over    .i
  Global s_gui_controls_divot_anim_op_disabled .i
  Global s_gui_controls_divot_anim_op_down     .i
  Global s_gui_controls_divot_anim_op_normal   .i
  Global s_gui_controls_divot_anim_op_over     .i
  Global s_gui_controls_divot_anim_sop_disabled.i
  Global s_gui_controls_divot_anim_sop_down    .i
  Global s_gui_controls_divot_anim_sop_normal  .i
  Global s_gui_controls_divot_anim_sop_over    .i
  

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlDivot_t )
  ; ----------------------------------------------------------------------------
  Structure ControlDivot_t Extends Control::Control_t
    value.i
    over .i
    down.i
  EndStructure

  ; ----------------------------------------------------------------------------
  ;  Interface ( IControlDivot )
  ; ----------------------------------------------------------------------------
  Interface IControlDivot Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  Declare New( *parent.Control::Control_t ,name.s, value.i = #ANIM_NONE, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlDivot_t)
  Declare Draw( *Me.ControlDivot_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlDivot_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetValue( *Me.ControlDivot_t, value.i )
  Declare GetValue( *Me.ControlDivot_t)
  Declare SetTheme( theme.i )
  Declare.b Init()
  Declare.b Term()
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlDivotVT: 
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()  ; mandatory override
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
    
    VIControlDivot_light_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/light.divot.over.png"
    VIControlDivot_light_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/light.divot.down.png"
    
    ; (Dark)
    VIControlDivot_dark_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/dark.divot.over.png"
    VIControlDivot_dark_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/dark.divot.down.png"
    ; (All)
    VIControlDivot_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.disabled.png"
    VIControlDivot_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.normal.png"
    VIControlDivot_anim_cns_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.cns.disabled.png"
    VIControlDivot_anim_cns_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.cns.down.png"
    VIControlDivot_anim_cns_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.cns.normal.png"
    VIControlDivot_anim_cns_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.cns.over.png"
    VIControlDivot_anim_exp_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.exp.disabled.png"
    VIControlDivot_anim_exp_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.exp.down.png"
    VIControlDivot_anim_exp_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.exp.normal.png"
    VIControlDivot_anim_exp_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.exp.over.png"
    VIControlDivot_anim_key_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.key.disabled.png"
    VIControlDivot_anim_key_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.key.down.png"
    VIControlDivot_anim_key_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.key.normal.png"
    VIControlDivot_anim_key_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.key.over.png"
    VIControlDivot_anim_op_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.op.disabled.png"
    VIControlDivot_anim_op_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.op.down.png"
    VIControlDivot_anim_op_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.op.normal.png"
    VIControlDivot_anim_op_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.op.over.png"
    VIControlDivot_anim_sop_disabled: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.sop.disabled.png"
    VIControlDivot_anim_sop_down: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.sop.down.png"
    VIControlDivot_anim_sop_normal: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.sop.normal.png"
    VIControlDivot_anim_sop_over: 
    IncludeBinary "../../rsc/skins/grey/control_divot/divot.anim.sop.over.png"
  EndDataSection
  
 Global CLASS.Class::Class_t
EndDeclareModule

; ==============================================================================
;  CONTROL DIVOT MODULE IMPLEMENTATION
; ==============================================================================
Module ControlDivot
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlDivot_t, xoff.i = 0, yoff.i = 0 )

    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn : EndIf
    MovePathCursor( 0 + xoff, 0 + yoff )
    ; 같�[ Disabled ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    If Not *Me\enable
      ; ...[ Dispatch Value ]...................................................
      Select *Me\value
        Case #ANIM_NONE              : DrawVectorImage( ImageID(s_gui_controls_divot_disabled          ))
        Case #ANIM_CONSTRAINT        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_cns_disabled ))
        Case #ANIM_EXPRESSION        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_exp_disabled ))
        Case #ANIM_KEYFRAME          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_key_disabled ))
        Case #ANIM_OPERATOR          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_op_disabled  ))
        Case #ANIM_SCRIPTED_OPERATOR : DrawVectorImage( ImageID(s_gui_controls_divot_anim_sop_disabled ))
      EndSelect
    ; 같�[ Over ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    ElseIf *Me\over
      ; ---[ Down ]-------------------------------------------------------------
      If *Me\down
        ; ...[ Dispatch Value ].................................................
        Select *Me\value
          Case #ANIM_NONE              : DrawVectorImage( ImageID(s_gui_controls_divot_down          ))
          Case #ANIM_CONSTRAINT        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_cns_down ))
          Case #ANIM_EXPRESSION        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_exp_down ))
          Case #ANIM_KEYFRAME          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_key_down ))
          Case #ANIM_OPERATOR          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_op_down  ))
          Case #ANIM_SCRIPTED_OPERATOR : DrawVectorImage( ImageID(s_gui_controls_divot_anim_sop_down ))
        EndSelect    
      ; ---[ Up ]---------------------------------------------------------------
      Else
        ; ...[ Dispatch Value ].................................................
        Select *Me\value
          Case #ANIM_NONE              : DrawVectorImage( ImageID(s_gui_controls_divot_over          ))
          Case #ANIM_CONSTRAINT        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_cns_over ))
          Case #ANIM_EXPRESSION        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_exp_over ))
          Case #ANIM_KEYFRAME          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_key_over ))
          Case #ANIM_OPERATOR          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_op_over  ))
          Case #ANIM_SCRIPTED_OPERATOR : DrawVectorImage( ImageID(s_gui_controls_divot_anim_sop_over ))
        EndSelect
      EndIf
    ; 같�[ Normal ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
    Else
      ; ...[ Dispatch Value ]...................................................
      Select *Me\value
        Case #ANIM_NONE              : DrawVectorImage( ImageID(s_gui_controls_divot_normal          ))
        Case #ANIM_CONSTRAINT        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_cns_normal ))
        Case #ANIM_EXPRESSION        : DrawVectorImage( ImageID(s_gui_controls_divot_anim_exp_normal ))
        Case #ANIM_KEYFRAME          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_key_normal ))
        Case #ANIM_OPERATOR          : DrawVectorImage( ImageID(s_gui_controls_divot_anim_op_normal  ))
        Case #ANIM_SCRIPTED_OPERATOR : DrawVectorImage( ImageID(s_gui_controls_divot_anim_sop_normal ))
      EndSelect
    EndIf
    
  EndProcedure
  ;}

  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlDivot_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
  
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        Draw( *Me.ControlDivot_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Cancel Width & Height Resize ]...................................
        *Me\sizX = 18 : *Me\sizY = 18
        ; ...[ Update Status ]..................................................
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
                ;If *Me\value : *Me\value = #ANIM_NONE : Else : *Me\value = #ANIM_KEYFRAME : EndIf
                *Me\over = #False
                Control::Invalidate(*Me)
              EndIf
            ElseIf Not *Me\over
              ;If *Me\value : *Me\value = #ANIM_NONE : Else : *Me\value = #ANIM_KEYFRAME : EndIf
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
            If *Me\value : *Me\value = #ANIM_NONE : Else : *Me\value = #ANIM_KEYFRAME : EndIf
            Control::Invalidate(*Me)
            Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
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

  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetValue( *Me.ControlDivot_t, value.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If value = *Me\value
      ; ...[ Abort ]............................................................
      ProcedureReturn
    EndIf
    
    ; ---[ Set Value ]----------------------------------------------------------
    *Me\value = value
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    Control::Invalidate(*Me)
    
  EndProcedure
  ; ---[ GetValue ]-------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlDivot_t )
    
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlDivot_t )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t ,name.s, value.i = #ANIM_NONE, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlDivot_t = AllocateMemory( SizeOf(ControlDivot_t) ) 
    
;     *Me\VT = ?ControlDivotVT
;     *Me\classname = "CONTROLDIVOT"
    Object::INI(ControlDivot)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#DIVOT
    *Me\name     = name
    *Me\parent   = *parent
    *Me\gadgetID = *parent\gadgetID
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = 18
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\options  = options
    *Me\value    = value
    *Me\over     = #False
    *Me\down     = #False
    
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
        s_gui_controls_divot_over = s_gui_controls_light_divot_over
        s_gui_controls_divot_down = s_gui_controls_light_divot_down
        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARK
        s_gui_controls_divot_over = s_gui_controls_dark_divot_over
        s_gui_controls_divot_down = s_gui_controls_dark_divot_down
        
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
    s_gui_controls_light_divot_over = CatchImage( #PB_Any, ?VIControlDivot_light_over )
    s_gui_controls_light_divot_down = CatchImage( #PB_Any, ?VIControlDivot_light_down )
    
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  DARK
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    s_gui_controls_dark_divot_over = CatchImage( #PB_Any, ?VIControlDivot_dark_over )
    s_gui_controls_dark_divot_down = CatchImage( #PB_Any, ?VIControlDivot_dark_down )

    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ;  ALL
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    s_gui_controls_divot_disabled          = CatchImage( #PB_Any, ?VIControlDivot_disabled          )
    s_gui_controls_divot_normal            = CatchImage( #PB_Any, ?VIControlDivot_normal            )
    s_gui_controls_divot_anim_cns_disabled = CatchImage( #PB_Any, ?VIControlDivot_anim_cns_disabled )
    s_gui_controls_divot_anim_cns_down     = CatchImage( #PB_Any, ?VIControlDivot_anim_cns_down     )
    s_gui_controls_divot_anim_cns_normal   = CatchImage( #PB_Any, ?VIControlDivot_anim_cns_normal   )
    s_gui_controls_divot_anim_cns_over     = CatchImage( #PB_Any, ?VIControlDivot_anim_cns_over     )
    s_gui_controls_divot_anim_exp_disabled = CatchImage( #PB_Any, ?VIControlDivot_anim_exp_disabled )
    s_gui_controls_divot_anim_exp_down     = CatchImage( #PB_Any, ?VIControlDivot_anim_exp_down     )
    s_gui_controls_divot_anim_exp_normal   = CatchImage( #PB_Any, ?VIControlDivot_anim_exp_normal   )
    s_gui_controls_divot_anim_exp_over     = CatchImage( #PB_Any, ?VIControlDivot_anim_exp_over     )
    s_gui_controls_divot_anim_key_disabled = CatchImage( #PB_Any, ?VIControlDivot_anim_key_disabled )
    s_gui_controls_divot_anim_key_down     = CatchImage( #PB_Any, ?VIControlDivot_anim_key_down     )
    s_gui_controls_divot_anim_key_normal   = CatchImage( #PB_Any, ?VIControlDivot_anim_key_normal   )
    s_gui_controls_divot_anim_key_over     = CatchImage( #PB_Any, ?VIControlDivot_anim_key_over     )
    s_gui_controls_divot_anim_op_disabled  = CatchImage( #PB_Any, ?VIControlDivot_anim_op_disabled  )
    s_gui_controls_divot_anim_op_down      = CatchImage( #PB_Any, ?VIControlDivot_anim_op_down      )
    s_gui_controls_divot_anim_op_normal    = CatchImage( #PB_Any, ?VIControlDivot_anim_op_normal    )
    s_gui_controls_divot_anim_op_over      = CatchImage( #PB_Any, ?VIControlDivot_anim_op_over      )
    s_gui_controls_divot_anim_sop_disabled = CatchImage( #PB_Any, ?VIControlDivot_anim_sop_disabled )
    s_gui_controls_divot_anim_sop_down     = CatchImage( #PB_Any, ?VIControlDivot_anim_sop_down     )
    s_gui_controls_divot_anim_sop_normal   = CatchImage( #PB_Any, ?VIControlDivot_anim_sop_normal   )
    s_gui_controls_divot_anim_sop_over     = CatchImage( #PB_Any, ?VIControlDivot_anim_sop_over     )

    SetTheme(Globals::#GUI_THEME_LIGHT) 
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  GuiControlsDivotTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  ;CHECK_INIT  
  
    
    ; ---[ Term Once ]----------------------------------------------------------
    ; 같�[ Free Images ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; ...[ All ]................................................................
    FreeImage( s_gui_controls_divot_anim_sop_over     )
    FreeImage( s_gui_controls_divot_anim_sop_normal   )
    FreeImage( s_gui_controls_divot_anim_sop_down     )
    FreeImage( s_gui_controls_divot_anim_sop_disabled )
    FreeImage( s_gui_controls_divot_anim_op_over      )
    FreeImage( s_gui_controls_divot_anim_op_normal    )
    FreeImage( s_gui_controls_divot_anim_op_down      )
    FreeImage( s_gui_controls_divot_anim_op_disabled  )
    FreeImage( s_gui_controls_divot_anim_key_over     )
    FreeImage( s_gui_controls_divot_anim_key_normal   )
    FreeImage( s_gui_controls_divot_anim_key_down     )
    FreeImage( s_gui_controls_divot_anim_key_disabled )
    FreeImage( s_gui_controls_divot_anim_exp_over     )
    FreeImage( s_gui_controls_divot_anim_exp_normal   )
    FreeImage( s_gui_controls_divot_anim_exp_down     )
    FreeImage( s_gui_controls_divot_anim_exp_disabled )
    FreeImage( s_gui_controls_divot_anim_cns_over     )
    FreeImage( s_gui_controls_divot_anim_cns_normal   )
    FreeImage( s_gui_controls_divot_anim_cns_down     )
    FreeImage( s_gui_controls_divot_anim_cns_disabled )
    FreeImage( s_gui_controls_divot_normal            )
    FreeImage( s_gui_controls_divot_disabled          )
    ; ...[ Dark ]...............................................................
    FreeImage( s_gui_controls_dark_divot_down )
    FreeImage( s_gui_controls_dark_divot_over )
    ; ...[ Light ]..............................................................
    FreeImage( s_gui_controls_light_divot_down )
    FreeImage( s_gui_controls_light_divot_over )
  
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlDivot )
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 161
; FirstLine = 151
; Folding = ---
; EnableXP