XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Math.pbi"

DeclareModule ControlSlider
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlNumber_t )
  ; ----------------------------------------------------------------------------
  Structure ControlSlider_t Extends Control::Control_t
    color.i
    value.f
    down.b
    drag.b
    offset.i
    min_value.f
    max_value.f
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlSlider Extends Control::IControl
  EndInterface
    
  Declare .i New(*parent.Control::Control_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlSlider_t)
  Declare OnEvent( *Me.ControlSlider_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare Draw(*Me.ControlSlider_t)
  DataSection 
    ControlSliderVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
  
EndDeclareModule

Module ControlSlider
  
  Procedure.f GetPercentageFromValue(*Me.ControlSlider_t)
    Define perc.f = (*Me\value - *Me\min_value) / (*Me\max_value - *Me\min_value)
    ProcedureReturn perc
  EndProcedure
  
  Procedure.f GetPercentageFromMouse(*Me.ControlSlider_t, mx.i, my.i)
    Define perc.f = mx / *Me\sizX
    ProcedureReturn perc
  EndProcedure
  
  Procedure PercentageToValue(*Me.ControlSlider_t, perc.f)
    *Me\value = (*Me\max_value - *Me\min_value) * perc + *Me\min_value
  EndProcedure
  
 
  Procedure Draw(*Me.ControlSlider_t)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(*Me\color)
    FillPath()
    
    Define perc.f = GetPercentageFromValue(*Me)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX*perc, *Me\sizY)
    VectorSourceColor(RGBA(25,25,25,60))
    FillPath()
    
    MovePathCursor(*Me\posX + perc * *Me\sizX, *Me\posY)
    AddPathLine(0, *Me\sizY, #PB_Path_Relative)
    VectorSourceColor(UIColor::COLOR_CARET)
    StrokePath(4)
    
  EndProcedure
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlSlider_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    Select ev_code
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ---[ Sanity Check ]---------------------------------------------------
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ---[ Draw Control ]---------------------------------------------------
        Draw(*Me)
        
      ; ------------------------------------------------------------------------
      ;  Left Button Down
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonDown
        *Me\down = #True
        
        Define mx.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX) - *Me\posX
        Define my.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseY) - *Me\posY
        Define perc.f = GetPercentageFromMouse(*Me, mx, my)
        
        If Abs(perc * *Me\sizX - mx) < 4 
          *Me\color = UIColor::RANDOMIZED
          *Me\drag = #True
        Else
          PercentageToValue(*Me, perc)
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  Left Button Up
      ; ------------------------------------------------------------------------
      Case #PB_EventType_LeftButtonUp
        *Me\down = #False
        *Me\drag = #False
        
        
      ; ------------------------------------------------------------------------
      ;  Mouse Move
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        If *Me\drag
          Define mx.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX) - *Me\posX
          Define my.i = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseY) - *Me\posY
          Define perc.f = GetPercentageFromMouse(*Me, mx, my)
          PercentageToValue(*Me, perc)
          Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
          Control::Invalidate(*Me)
        EndIf

    EndSelect
    
  EndProcedure


  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlSlider_t = AllocateStructure(ControlSlider_t)
    
    Object::INI(ControlSlider)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type         = Control::#SLIDER
    *Me\name         = name
    *Me\parent       = *parent
    *Me\gadgetID     = *parent\gadgetID
    *Me\posX         = x
    *Me\posY         = y
    *Me\sizX         = width
    *Me\sizY         = 20
    *Me\visible      = #True
    *Me\enable       = #True
    *Me\options      = options
    *Me\value        = value
    *Me\min_value    = hard_min
    *Me\max_value    = hard_max
    *Me\color        = UIColor::RANDOMIZED
    
    If *Me\options & ControlNumber::#NUMBER_INTEGER
      *Me\value      = Int(value)
    Else
      *Me\value      =  value
    EndIf
    
    ; ---[ Callbacks ]------------------------------------------------------------
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------
  Procedure Delete(*Me.ControlSlider_t)
    Object::TERM(ControlSlider)
  EndProcedure

  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlSlider )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 124
; FirstLine = 120
; Folding = --
; EnableXP
; EnableUnicode