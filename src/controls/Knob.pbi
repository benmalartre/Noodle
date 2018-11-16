XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/UIColor.pbi"

; ==============================================================================
;  CONTROL KNOB MODULE DECLARATION
; ==============================================================================
DeclareModule ControlKnob
  ; ----------------------------------------------------------------------------
  ;  Constants ( ControlKnob_t )
  ; ----------------------------------------------------------------------------
  #PB_GadgetType_Knob = 128
  
  #KNOB_INNER_RADIUS = 24
  #KNOB_OUTER_RADIUS = 32
  #KNOB_MARKER_SIZE  = 5
  #KNOB_ZERO_SIZE    = 32
  #KNOB_MARKER_WIDTH = 2
  #KNOB_NUM_MARKERS  = 16

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlKnob_t )
  ; ----------------------------------------------------------------------------
  Structure ControlKnob_t Extends Control::Control_t
    oldX.i
    oldY.i
    mouseX.i
    mouseY.i
    angle.f
    last_angle.f
    angle_offset.f
    over.i
    down.i
    min.f
    max.f
    value.f
    last_value.f
    limited.b
    min_limit.f
    max_limit.f
    increment.f
    ascending.b
    *onchanged_signal.Slot::Slot_t
  EndStructure
  
  Declare New(*object.Object::Object_t,name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64, color.i=8421504 )
  Declare Init()
  Declare Term()
  Declare SetTheme(theme.i)
  Declare SetLimits(*Me.ControlKnob_t, min_limit.f, max_limit.f)
  Declare Delete(*Me.ControlKnob_t)
  Declare OnEvent( *Me.ControlKnob_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlKnob )
  ; ============================================================================
  DataSection
    ControlKnobVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlKnob
; ----------------------------------------------------------------------------
;  hlpGetAngle
; ----------------------------------------------------------------------------
Procedure.f hlpGetAngle( *Me.ControlKnob_t )
  Define a.Math::v2f32, b.Math::v2f32, c.Math::v2f32, center.Math::v2f32
  Define angle.f
  Vector2::Set(center, *Me\sizX * 0.5 + *Me\posX, *Me\sizY * 0.5 + *Me\posY)
  Vector2::Set(a, *Me\oldX, *Me\oldY)
  Vector2::SubInPlace(a, center)
  Vector2::Set(b, *Me\mouseX, *Me\mouseY)
  Vector2::SubInPlace(b, center)
  Vector2::GetAngle(a, b, angle)
  ProcedureReturn Degree(angle)
EndProcedure

; ----------------------------------------------------------------------------
;  hlpGetSide
; ----------------------------------------------------------------------------
Procedure.f hlpGetSide( *Me.ControlKnob_t)
  Define a.Math::v2f32, b.Math::v2f32, center.Math::v2f32
  Vector2::Set(center, *Me\sizX * 0.5 + *Me\posX, *Me\sizY * 0.5 + *Me\posY)
  Vector2::Set(a, *Me\oldX, *Me\oldY)
  Vector2::SubInPlace(a, center)
  Vector2::Set(b, center\y - *Me\mouseY, -(center\x - *Me\mouseX))
  Define dot.f = Vector2::Dot(a, b)
  ProcedureReturn dot
EndProcedure
  
; ----------------------------------------------------------------------------
;  hlpDraw
; ----------------------------------------------------------------------------
Procedure hlpDraw( *Me.ControlKnob_t, xoff.i = 0, yoff.i = 0 )

  ; ---[ Check Visible ]------------------------------------------------------
  If Not *Me\visible : ProcedureReturn : EndIf
  
  ; ---[ Label Color ]--------------------------------------------------------
  Protected tc.i = UIColor::COLORA_LABEL
  Protected bgc.i = UIColor::COLORA_MAIN_BG
  
  AddPathBox(xoff + *Me\posX, yoff+*Me\posY, *Me\sizX, *Me\sizY)
  VectorSourceColor(bgc)
  FillPath()
  
  Define cx.i = *Me\sizX * 0.5 + *Me\posX + xoff
  Define cy.i = *Me\sizY * 0.5 + *Me\posY + yoff
  
  BeginVectorLayer() 
  ResetCoordinates()
  RotateCoordinates(cx, cy, *Me\angle)
  
  ; bottom part
  AddPathCircle(cx, cy, #KNOB_OUTER_RADIUS)
  Select *Me\state
    Case Control::#CONTROL_DEFAULT
      VectorSourceColor(RGBA(86,86,86,255))
    Case Control::#CONTROL_OVER
      VectorSourceColor(RGBA(92,92,92,255))
    Case Control::#CONTROL_PRESSED
      VectorSourceColor(RGBA(100,100,100,255))
  EndSelect
  
  FillPath(#PB_Path_Preserve)
  
  ; top part
  AddPathCircle(cx, cy, #KNOB_INNER_RADIUS)
  Select *Me\state
    Case Control::#CONTROL_DEFAULT
      VectorSourceColor(RGBA(64,64,64,255))
    Case Control::#CONTROL_OVER
      VectorSourceColor(RGBA(76,76,76,255))
    Case Control::#CONTROL_PRESSED
      VectorSourceColor(RGBA(80,80,80,255))
  EndSelect
  
  FillPath(#PB_Path_Preserve)
  VectorSourceColor(RGBA(16, 16, 16, 255))
  StrokePath(#KNOB_MARKER_WIDTH, #PB_Path_RoundCorner|#PB_Path_RoundEnd)   
  
  ; markers
  Define i
  Define incr.f = Radian(360 / #KNOB_NUM_MARKERS)
  
  For i=0 To #KNOB_NUM_MARKERS-1
    MovePathCursor(cx+Cos(i*incr)*(#KNOB_INNER_RADIUS), cy+Sin(i*incr)*(#KNOB_INNER_RADIUS))
    ;     AddPathLine(cx+Cos(i*incr)*(#KNOB_INNER_RADIUS-#KNOB_MARKER_SIZE), cy+Sin(i*incr)*(#KNOB_INNER_RADIUS-#KNOB_MARKER_SIZE))
    AddPathLine(cx+Cos(i*incr)*(#KNOB_OUTER_RADIUS), cy+Sin(i*incr)*(#KNOB_OUTER_RADIUS))
  Next
  
  VectorSourceColor(RGBA(16, 16, 16, 255))
  StrokePath(#KNOB_MARKER_WIDTH, #PB_Path_RoundCorner|#PB_Path_RoundEnd)  
  
  ; zero marker
;   MovePathCursor(cx, cy - #KNOB_OUTER_RADIUS)
;   AddPathLine(cx + #KNOB_ZERO_SIZE * 0.12, cy - #KNOB_INNER_RADIUS)
;   AddPathLine(cx - #KNOB_ZERO_SIZE * 0.12, cy - #KNOB_INNER_RADIUS)
;   AddPathLine(cx, cy - #KNOB_OUTER_RADIUS)
;   FillPath()
  MovePathCursor(cx, cy - (#KNOB_OUTER_RADIUS + 8))
  AddPathLine(cx + #KNOB_ZERO_SIZE * 0.16, cy - #KNOB_OUTER_RADIUS)
  AddPathLine(cx - #KNOB_ZERO_SIZE * 0.16, cy - #KNOB_OUTER_RADIUS)
  AddPathLine(cx, cy - (#KNOB_OUTER_RADIUS + 8))
  FillPath()
  
  ; manipulator
  If *Me\down
    ResetCoordinates()
    Define a.Math::v2f32, b.Math::v2f32, center.Math::v2f32
    Vector2::Set(center, cx, cy)
    Vector2::Set(a, 0, -1)
    Vector2::RotateInPlace(a, Radian(*Me\last_angle))
    Vector2::ScaleInPlace(a, #KNOB_OUTER_RADIUS * 1.25)
    Vector2::AddInPlace(a, center)
    
    MovePathCursor(cx, cy)
    AddPathLine(a\x, a\y)
    
    Vector2::Set(a, 0, -1)
    Vector2::RotateInPlace(a, Radian(*Me\angle))
    Vector2::ScaleInPlace(a, #KNOB_OUTER_RADIUS * 1.25)
    Vector2::AddInPlace(a, center)
    
    MovePathCursor(cx, cy)
    AddPathLine(a\x, a\y)
    
    MovePathCursor(cx, cy)
    AddPathLine(a\x, a\y)
    VectorSourceColor(RGBA(255,0,128,128))
    StrokePath(#KNOB_MARKER_WIDTH, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
    
    Vector2::Set(a, *Me\mouseX, *Me\mouseY)
    AddPathCircle(a\x, a\y, 4)
;     Vector2::SubInPlace(a, center)
;     Vector2::NormalizeInPlace(a)
;     Vector2::ScaleInPlace(a, #KNOB_OUTER_RADIUS * 1.25)
;     Vector2::AddInPlace(a, center)
    
    MovePathCursor(cx, cy)
    AddPathLine(a\x, a\y)
    VectorSourceColor(RGBA(255,128,0,128))
    StrokePath(#KNOB_MARKER_WIDTH, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
    
    If *Me\last_angle < *Me\angle
      AddPathCircle(cx, cy,  #KNOB_OUTER_RADIUS * 1.2, *Me\last_angle - 90, *Me\angle - 90)
    Else
      AddPathCircle(cx, cy,  #KNOB_OUTER_RADIUS * 1.2, *Me\angle - 90, *Me\last_angle - 90)
    EndIf
    
    VectorSourceColor(RGBA(255,128,0,128))
    StrokePath(#KNOB_MARKER_WIDTH *2, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
  EndIf
  
  ResetCoordinates()
  
  ; display limits
  If Not *Me\limited
    AddPathCircle(cx, cy,#KNOB_OUTER_RADIUS + 12)
    VectorSourceColor(RGBA(0,0,0,32))
    StrokePath(8, #PB_Path_Connected)
  Else
    AddPathCircle(cx, cy,#KNOB_OUTER_RADIUS + 12, -240,60)
    VectorSourceColor(RGBA(0,0,0,32))
    StrokePath(8, #PB_Path_Connected)
    
    Define min_s.s = Str(*Me\min_limit)
    Define max_s.s = Str(*Me\max_limit)
    Define min_w = VectorTextWidth(min_s)
    Define max_w = VectorTextWidth(max_s)
    VectorFont(FontID(Globals::#FONT_LABEL), 8)
    VectorSourceColor(RGBA(0,0,0,128))
    Vector::MoveCursorPathOnCircle(cx - min_w, cy, #KNOB_OUTER_RADIUS*1.2, Radian(-260))
    DrawVectorText(min_s)
    Vector::MoveCursorPathOnCircle(cx + max_w , cy, #KNOB_OUTER_RADIUS*1.2, Radian(80))
    DrawVectorText(max_s)

  EndIf
  
  ; display value
  VectorFont(FontID(Globals::#FONT_MENU), 12)
  Define value_s.s = StrF(*Me\value, 3)
  MovePathCursor(cx - VectorTextWidth(value_s) * 0.5, cy + #KNOB_OUTER_RADIUS * 1.4)
  VectorSourceColor(RGBA(255,0,128,128))
  DrawVectorText(value_s)
  EndVectorLayer()
  
EndProcedure
;}

; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i OnEvent( *Me.ControlKnob_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
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
    CompilerIf #PB_Compiler_Version < 560
      Case Control::#PB_EventType_Resize
    CompilerElse
      Case #PB_EventType_Resize
    CompilerEndIf
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
    ;  LeftKnobDown
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonDown
      If *Me\visible And *Me\enable
        *Me\down = #True
        *Me\oldX = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX)
        *Me\oldY = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseY)
        *Me\mouseX = *Me\oldX
        *Me\mouseY = *Me\oldY
        
        *Me\last_angle = *Me\angle
        *Me\angle_offset = hlpGetAngle(*Me)
        *Me\last_value = *Me\value
       
        Control::Invalidate(*Me)
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftKnobUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
        *Me\down = #False
       
        Control::Invalidate(*Me)
        
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  MouseMove
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
      If *Me\visible And *Me\enable
        If *Me\down
          *Me\mouseX = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseX)
          *Me\mouseY = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_MouseY)
          Define side.f = hlpGetSide(*Me) 
          Define angle.f = hlpGetAngle(*Me)
          
          Define current_angle
          If side < 0
            *Me\angle = *Me\last_angle + angle + *Me\angle_offset
            If *Me\angle < *Me\last_angle
              *Me\ascending = #False
            Else 
              *Me\ascending = #True
            EndIf
          Else
            *Me\angle = *Me\last_angle -( angle + *Me\angle_offset)
            If *Me\angle < *Me\last_angle
              *Me\ascending = #True
            Else 
              *Me\ascending = #False
            EndIf
          EndIf
          
          If *Me\ascending
            *Me\value = *Me\last_value + Radian(angle + *Me\angle_offset) 
          Else
            *Me\value = *Me\last_value - Radian(angle + *Me\angle_offset) 
          EndIf

          Slot::Trigger(*Me\onchanged_signal, Signal::#SIGNAL_TYPE_PING, @*Me\value)
          PostEvent(Globals::#EVENT_PARAMETER_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
        EndIf
        Control::Invalidate(*Me)
      EndIf
      
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
;  IMPLEMENTATION ( ControlKnob )
; ============================================================================
; ============================================================================
;  INIT
; ============================================================================
Procedure Init(  )
  
EndProcedure

; ============================================================================
;  TERM
; ============================================================================
Procedure Term(  )

EndProcedure

Procedure SetTheme(theme.i)
  
EndProcedure

; ============================================================================
;  SET LIMITS
; ============================================================================
Procedure SetLimits(*Me.ControlKnob_t, min_limit.f, max_limit.f)
  *Me\limited = #True
  *Me\min_limit = min_limit
  *Me\max_limit = max_limit
EndProcedure

; ============================================================================
;  DESTRUCTOR
; ============================================================================
Procedure Delete( *Me.ControlKnob_t )
  Slot::Delete(*Me\onchanged_signal)
  Object::TERM(ControlKnob)
  ; ---[ Deallocate Memory ]--------------------------------------------------
  ClearStructure(*Me,ControlKnob_t)
  FreeMemory( *Me )
  
EndProcedure


; ============================================================================
;  CONSTRUCTOR
; ============================================================================
Procedure.i New( gadgetID.i, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *Me.ControlKnob_t = AllocateMemory( SizeOf(ControlKnob_t) )
  
  Object::INI(ControlKnob)
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\object     = #Null
  *Me\type       = #PB_GadgetType_Knob
  *Me\name       = name
  *Me\gadgetID   = gadgetID
  *Me\posX       = x
  *Me\posY       = y
  *Me\sizX       = width
  *Me\sizY       = height
  *Me\visible    = #True
  *Me\enable     = #True
  *Me\options    = options
  *Me\value      = 0
  *Me\onchanged_signal = Slot::New(*Me)

  If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ProcedureReturn( *Me )
  
EndProcedure


  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlKnob )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 81
; FirstLine = 81
; Folding = ---
; EnableXP