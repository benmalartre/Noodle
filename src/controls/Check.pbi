XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  CONTROL CHECK MODULE DECLARATION
; ==============================================================================
DeclareModule ControlCheck
  #CHECK_WIDTH = 16
  #CHECK_MARGIN = 2
  #CHECK_STROKE_WIDTH = 2
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
  Declare New( *parent.Control::Control_t ,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 40, height.i = 18 )
  Declare Delete(*Me.ControlCheck_t)
  Declare Draw( *Me.ControlCheck_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlCheck_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetValue( *Me.ControlCheck_t, value.i )
  Declare GetValue( *Me.ControlCheck_t)
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlCheckVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection;
  
  Global CLASS.Class::Class_t
  
EndDeclareModule


; ==============================================================================
;  CONTROL CHECK MODULE IMPLEMENTATTION
; ==============================================================================
Module ControlCheck
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlCheck_t, xoff.i = 0, yoff.i = 0 )
    
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = UIColor::COLOR_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont(FontID( Globals::#FONT_DEFAULT ), Globals::#FONT_SIZE_LABEL)
    Protected ty = ( *Me\sizY - VectorTextHeight( *Me\label ) )/2 + yoff
    
    AddPathBox(*Me\posX-Control::FRAME_THICKNESS, *Me\posY-Control::FRAME_THICKNESS, *Me\sizX+2*Control::FRAME_THICKNESS, *Me\sizY+2*Control::FRAME_THICKNESS)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    
    Define left = xoff +*Me\sizX-(#CHECK_WIDTH+#CHECK_MARGIN)
    Define top = yoff+#CHECK_MARGIN
    
    AddPathBox(left, top, #CHECK_WIDTH, #CHECK_WIDTH)
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath(#PB_Path_Preserve)
   
    
    ; ---[ Check Disabled ]-----------------------------------------------------
    If Not *Me\enable
       VectorSourceColor(UIColor::COLOR_FRAME_ACTIVE)
       StrokePath(Control::FRAME_THICKNESS, #PB_Path_RoundCorner)
       VectorSourceColor(UIColor::COLOR_NUMBER_FG)
    ; ---[ Check Over ]---------------------------------------------------------
    ElseIf *Me\over
      VectorSourceColor(UIColor::COLOR_FRAME_OVERED)
      StrokePath(Control::FRAME_THICKNESS, #PB_Path_RoundCorner)
      ; ...[ Dispatch Value ]...................................................
;       Select *Me\value
;         Case  1 : DrawVectorImage( ImageID(s_gui_controls_check_over_checked     ) )
;         Case  0 : DrawVectorImage( ImageID(s_gui_controls_check_over_unchecked   ) )
;         Case -1 : DrawVectorImage( ImageID(s_gui_controls_check_over_undetermined) )
;       EndSelect
    ; ---[ Normal State ]-------------------------------------------------------
    Else
      VectorSourceColor(UIColor::COLOR_FRAME_DEFAULT)
      StrokePath(Control::FRAME_THICKNESS, #PB_Path_RoundCorner)
      ; ...[ Dispatch Value ]...................................................
;       Select *Me\value
;         Case  1 : DrawVectorImage( ImageID(s_gui_controls_check_normal_checked     ) )
;         Case  0 : DrawVectorImage( ImageID(s_gui_controls_check_normal_unchecked   ) )
;         Case -1 : DrawVectorImage( ImageID(s_gui_controls_check_normal_undetermined) )
;       EndSelect
    EndIf
    
     Select *Me\value
       Case  1 :
         MovePathCursor(left + 2, top + #CHECK_WIDTH / 2)
         AddPathLine(#CHECK_WIDTH / 4, #CHECK_WIDTH / 4, #PB_Path_Relative)
         AddPathLine( 2 * #CHECK_WIDTH / 4, -#CHECK_WIDTH + 8, #PB_Path_Relative)
         VectorSourceColor(UIColor::COLOR_CARET)
         StrokePath(2.4, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
      EndSelect
    
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
        Draw( *Me.ControlCheck_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
      
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
          Callback::Trigger(*Me\on_change,Callback::#SIGNAL_TYPE_PING)          
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
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlCheck_t )
    Object::TERM(ControlCheck)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t ,name.s, label.s = "", value.i = #False, options.i = 0, x.i = 0, y.i = 0, width.i = 40, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlCheck_t = AllocateStructure(ControlCheck_t)

    Object::INI(ControlCheck)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#CHECK
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
    If Len(label) > 0 : *Me\label = label : Else : *Me\label = name : EndIf
    *Me\value    = value
    *Me\over     = #False
    *Me\down     = #False
    
    ; ---[ Signals ]------------------------------------------------------------
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlCheck )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 319
; FirstLine = 272
; Folding = --
; EnableXP