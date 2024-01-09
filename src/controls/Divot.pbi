XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Vector.pbi"

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
    Vector::RoundBoxPath(xoff, yoff, *Me\sizX, *Me\sizY)
    VectorSourceColor(UIColor::RANDOMIZED)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UICOlor::COLOR_FRAME_OVERED)
    StrokePath(Control::FRAME_THICKNESS)

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
            Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
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
    
    Object::TERM(ControlDivot)
    
  EndProcedure


  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t ,name.s, value.i = #ANIM_NONE, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlDivot_t = AllocateStructure(ControlDivot_t)
    
    Object::INI(ControlDivot)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#DIVOT
    *Me\name     = name
    *Me\parent   = *parent
    *Me\gadgetID = *parent\gadgetID
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = height
    *Me\fixedX   = #True
    *Me\fixedY   = #True
    *Me\percX    = -1
    *Me\percY    = -1
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\options  = options
    *Me\value    = value
    *Me\over     = #False
    *Me\down     = #False
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlDivot )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 173
; FirstLine = 169
; Folding = --
; EnableXP