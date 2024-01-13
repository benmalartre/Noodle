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
  
  #Knob_Inner_Radius = 14
  #Knob_Outer_Radius = 22
  #Knob_Marker_Size  = 5
  #Knob_Zero_Size    = 32
  #Knob_Marker_Width = 2
  #Knob_Num_Markers  = 16

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
  EndStructure
  
  Declare New(*parent.Control::Control_t,name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64, color.i=8421504 )
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
  
  Procedure.f hlpGetSide( *Me.ControlKnob_t)
    Define a.Math::v2f32, b.Math::v2f32, center.Math::v2f32
    Vector2::Set(center, *Me\sizX * 0.5 + *Me\posX, *Me\sizY * 0.5 + *Me\posY)
    Vector2::Set(a, *Me\oldX, *Me\oldY)
    Vector2::SubInPlace(a, center)
    Vector2::Set(b, center\y - *Me\mouseY, -(center\x - *Me\mouseX))
    Define dot.f = Vector2::Dot(a, b)
    ProcedureReturn dot
  EndProcedure
  
  Procedure hlpClip(*Me.ControlKnob_t)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    ClipPath()
  EndProcedure

  Procedure hlpDraw( *Me.ControlKnob_t, xoff.i = 0, yoff.i = 0 )
  
    If Not *Me\visible : ProcedureReturn : EndIf
    
    Protected tc.i = UIColor::COLOR_LABEL
    Protected bgc.i = UIColor::COLOR_MAIN_BG
    
    Define cx.i = *Me\sizX * 0.5 + *Me\posX ;+ xoff
    Define cy.i = *Me\sizY * 0.5 + *Me\posY ;+ yoff
    
    BeginVectorLayer() 
    ResetCoordinates()
    hlpClip(*Me)
    
    RotateCoordinates(cx, cy, *Me\angle)
    
    AddPathCircle(cx, cy, #Knob_Outer_Radius)
    Select *Me\state
      Case Control::#State_Enable
        VectorSourceColor(RGBA(86,86,86,255))
      Case Control::#State_Over
        VectorSourceColor(RGBA(92,92,92,255))
      Case Control::#State_Focused
        VectorSourceColor(RGBA(100,100,100,255))
    EndSelect
    
    FillPath(#PB_Path_Preserve)
    
    AddPathCircle(cx, cy, #KNOB_INNER_RADIUS)
    Select *Me\state
      Case Control::#State_Enable
        VectorSourceColor(RGBA(64,64,64,255))
      Case Control::#State_Over
        VectorSourceColor(RGBA(76,76,76,255))
      Case Control::#State_Focused
        VectorSourceColor(RGBA(80,80,80,255))
    EndSelect
    
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(16, 16, 16, 255))
    StrokePath(#Knob_Marker_Width, #PB_Path_RoundCorner|#PB_Path_RoundEnd)   
    
    ; markers
    Define i
    Define incr.f = Radian(360 / #KNOB_NUM_MARKERS)
    
    For i=0 To #KNOB_NUM_MARKERS-1
      MovePathCursor(cx+Cos(i*incr)*(#KNOB_INNER_RADIUS), cy+Sin(i*incr)*(#KNOB_INNER_RADIUS))
      ;     AddPathLine(cx+Cos(i*incr)*(#KNOB_INNER_RADIUS-#KNOB_MARKER_SIZE), cy+Sin(i*incr)*(#KNOB_INNER_RADIUS-#KNOB_MARKER_SIZE))
      AddPathLine(cx+Cos(i*incr)*(#Knob_Outer_Radius), cy+Sin(i*incr)*(#Knob_Outer_Radius))
    Next
    
    VectorSourceColor(RGBA(16, 16, 16, 255))
    StrokePath(#Knob_Marker_Width, #PB_Path_RoundCorner|#PB_Path_RoundEnd)  
    
    MovePathCursor(cx, cy - (#Knob_Outer_Radius + 8))
    AddPathLine(cx + #Knob_Zero_Size * 0.16, cy - #Knob_Outer_Radius)
    AddPathLine(cx - #Knob_Zero_Size * 0.16, cy - #Knob_Outer_Radius)
    AddPathLine(cx, cy - (#Knob_Outer_Radius + 8))
    FillPath()
    
    If *Me\down
      ResetCoordinates()
      Define a.Math::v2f32, b.Math::v2f32, center.Math::v2f32
      Vector2::Set(center, cx, cy)
      Vector2::Set(a, 0, -1)
      Vector2::RotateInPlace(a, Radian(*Me\last_angle))
      Vector2::ScaleInPlace(a, #Knob_Outer_Radius * 1.25)
      Vector2::AddInPlace(a, center)
      
      MovePathCursor(cx, cy)
      AddPathLine(a\x, a\y)
      
      Vector2::Set(a, 0, -1)
      Vector2::RotateInPlace(a, Radian(*Me\angle))
      Vector2::ScaleInPlace(a, #Knob_Outer_Radius * 1.25)
      Vector2::AddInPlace(a, center)
      
      MovePathCursor(cx, cy)
      AddPathLine(a\x, a\y)
      
      MovePathCursor(cx, cy)
      AddPathLine(a\x, a\y)
      VectorSourceColor(RGBA(255,0,128,128))
      StrokePath(#Knob_Marker_Width, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
      
      Vector2::Set(a, *Me\mouseX, *Me\mouseY)
      AddPathCircle(a\x, a\y, 4)
  ;     Vector2::SubInPlace(a, center)
  ;     Vector2::NormalizeInPlace(a)
  ;     Vector2::ScaleInPlace(a, #Knob_Outer_Radius * 1.25)
  ;     Vector2::AddInPlace(a, center)
      
      MovePathCursor(cx, cy)
      AddPathLine(a\x, a\y)
      VectorSourceColor(RGBA(255,128,0,128))
      StrokePath(#Knob_Marker_Width, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
      
      If *Me\last_angle < *Me\angle
        AddPathCircle(cx, cy,  #Knob_Outer_Radius * 1.2, *Me\last_angle - 90, *Me\angle - 90)
      Else
        AddPathCircle(cx, cy,  #Knob_Outer_Radius * 1.2, *Me\angle - 90, *Me\last_angle - 90)
      EndIf
      
      VectorSourceColor(RGBA(255,128,0,128))
      StrokePath(#Knob_Marker_Width *2, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
      
      AddPathCircle(*Me\oldX, *Me\oldY, 4)
      VectorSourceColor(RGBA(0, 255, 128, 255))
      FillPath()
    EndIf
    
    ResetCoordinates()
    
    ; display limits
    If Not *Me\limited
      AddPathCircle(cx, cy,#Knob_Outer_Radius + 12)
      VectorSourceColor(RGBA(0,0,0,32))
      StrokePath(8 );#PB_Path_Connected)
    Else
      AddPathCircle(cx, cy,#Knob_Outer_Radius + 12, -240,60)
      VectorSourceColor(RGBA(0,0,0,32))
      StrokePath(8 );#PB_Path_Connected)
      
      Define min_s.s = Str(*Me\min_limit)
      Define max_s.s = Str(*Me\max_limit)
      Define min_w = VectorTextWidth(min_s)
      Define max_w = VectorTextWidth(max_s)
      VectorFont(FontID(Globals::#Font_Default), Globals::#Font_Size_Text)
      VectorSourceColor(RGBA(0,0,0,128))
      Vector::MoveCursorPathOnCircle(cx - min_w, cy, #Knob_Outer_Radius*1.2, Radian(-260))
      DrawVectorText(min_s)
      Vector::MoveCursorPathOnCircle(cx + max_w , cy, #Knob_Outer_Radius*1.2, Radian(80))
      DrawVectorText(max_s)
  
    EndIf
    
    VectorFont(FontID(Globals::#Font_Bold), Globals::#Font_Size_Title)
    Define value_s.s = StrF(*Me\value, 3)
    AddPathBox(cx - #Knob_Outer_Radius, cy + #Knob_Outer_Radius * 1.4 - 2, #Knob_Outer_Radius * 2, 32)
    VectorSourceColor(RGBA(255,255,255,222))
    FillPath()
    MovePathCursor(cx - VectorTextWidth(value_s) * 0.5, cy + #Knob_Outer_Radius * 1.4)
    VectorSourceColor(RGBA(0,0,0,222))
    DrawVectorText(value_s)
    EndVectorLayer()
    
  EndProcedure
  
  Procedure.f AngleToValue(*Me.ControlKnob_t, angle.f)
    
  EndProcedure
  
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  Procedure.i OnEvent( *Me.ControlKnob_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    Protected Me.Control::IControl = *Me
  
    Select ev_code
  
      Case Control::#PB_EventType_Draw
        hlpDraw( *Me, *ev_data\xoff, *ev_data\yoff )
        ProcedureReturn( #True )
        
      Case #PB_EventType_Resize
        If Not *ev_data : ProcedureReturn : EndIf
        If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
        If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
        If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
        
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
        
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
         
          Control::Invalidate(*Me)
          
        EndIf
  
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
            
            If *Me\angle < -140 : *Me\angle =  -140 : EndIf
            If *Me\angle > 140 : *Me\angle =  140 : EndIf
            
            If *Me\ascending
              *Me\value = Math::RESCALE(*Me\angle + *Me\angle_offset, -140, 140, *Me\min_limit, *Me\max_limit)
            Else
              *Me\value = Math::RESCALE(*Me\angle - *Me\angle_offset, -140, 140, *Me\min_limit, *Me\max_limit)
            EndIf
  
            Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
          EndIf
          Control::Invalidate(*Me)
        EndIf
        
      Case #PB_EventType_MouseEnter
        If *Me\visible And *Me\enable
          *Me\over = #True
          Control::Invalidate(*Me)
        EndIf
        
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          Control::Invalidate(*Me)
        EndIf
        
      Case Control::#PB_EventType_Enable
        If *Me\visible And Not *Me\enable
          *Me\enable = #True
          Control::Invalidate(*Me)
        EndIf
        ProcedureReturn( #True )
  
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ProcedureReturn( #True )
  
    EndSelect
    
    ProcedureReturn( #False )
    
  EndProcedure


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
    Object::TERM(ControlKnob)
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t, name.s, value.f = 0, options.i = 0, x.i = 0, y.i = 0, width.i = 64, height.i = 64 , color.i=8421504)
    
    Protected *Me.ControlKnob_t = AllocateStructure(ControlKnob_t)
    
    Object::INI(ControlKnob)
    
    *Me\type       = #PB_GadgetType_Knob
    *Me\name       = name
    *Me\parent     = *parent
    *Me\gadgetID   = *parent\gadgetID
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\options    = options
    *Me\value      = 0
    *Me\on_change  = Object::NewCallback(*Me, "OnChange")
  
    If value          : *Me\value = -1    : Else : *Me\value = 1    : EndIf
  
    ProcedureReturn( *Me )
    
  EndProcedure

  
  Class::DEF( ControlKnob )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 244
; FirstLine = 218
; Folding = ---
; EnableXP