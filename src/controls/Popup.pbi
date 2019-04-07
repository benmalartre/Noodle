
; ============================================================================
;  CONTROL POPUP MODULE DECLARATION
; ============================================================================
DeclareModule ControlPopup
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlPopup_t )
  ; ----------------------------------------------------------------------------
  Structure ControlPopup_t Extends Control::Control_t
    ; ControlPopup
    label.s
    over.i
    down.i
    
    *edit.ControlEdit::ControlEdit_t
;     *list.ControlList::ControlList_t
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface ( IControlPopup )
  ; ----------------------------------------------------------------------------
  Interface IControlPopup Extends Control::IControl
  EndInterface
  
  Declare New( *parent.Control::Control_t, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
  Declare Draw(*Me.ControlPopup_t, xoff.i = 0, yoff.i = 0)
  Declare Delete(*Me.ControlPopup_t)
  Declare OnEvent( *Me.ControlPopup_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  ; ============================================================================
  ;  VTABLE ( Object + Control + ControlButton )
  ; ============================================================================
  DataSection
    ControlPopupVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    
  EndDataSection
  
  Global CLASS.Class::Class_t

  
EndDeclareModule

Module ControlPopup


  ; ============================================================================
  ;  CONTROL POPUP MODULE IMPLEMENTATION 
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlPopup_t, xoff.i = 0, yoff.i = 0 )
  
    ; ---[ Check Visible ]------------------------------------------------------
    If Not *Me\visible : ProcedureReturn( void ) : EndIf
    
    ; ---[ Label Color ]--------------------------------------------------------
    Protected tc.i = RAA_COLORA_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont(FontID(Globals::#FONT_DEFAULT))
    
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(UIColor::RANDOMIZED)
    FillPath()
      
    ; ---[ Draw Label ]---------------------------------------------------------
    MovePathCursor(10 + xoff, ty)
    VectorSourceColor(tc)
    DrawVectorText( *Me\label )
    
    ControlEdit::Draw(*Me\edit,0,0)
    
  EndProcedure
  ;}


  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure OnEvent( *Me.ControlPopup_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.Control::IControl = *Me
  
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;    Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        Draw( *Me, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn #True
        
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
        ProcedureReturn #True
        
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
            Debug ">> Trigger ["+ *Me\label +"]"
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
        ProcedureReturn #True
  
      ; ------------------------------------------------------------------------
      ;    Disable
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Disable
        If *Me\visible And *Me\enable
          *Me\enable = #False
          Control::Invalidate(*Me)
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn #True
  
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn #False
    
  EndProcedure
  ;}
  
  
  ; ============================================================================
  ;  IMPLEMENTATION ( ControlPopup_t )
  ; ============================================================================
  ;{
  ; ---[ SetLabel ]-------------------------------------------------------------
  Procedure SetLabel( *Me.ControlPopup_t, value.s )
    
    ; ---[ Set String Value ]---------------------------------------------------
    *Me\label = value
    
  EndProcedure
  ; ---[ GetLabel ]-------------------------------------------------------------
  Procedure.s GetLabel( *Me.ControlPopup_t )
    
    ; ---[ Return String Value ]------------------------------------------------
    ProcedureReturn *Me\label
    
  EndProcedure
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlPopup_t )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    Object::TERM(ControlPopup)
    
  EndProcedure
  ;}
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New( *parent.Control::Control_t, x.i = 0, y.i = 0, width.i = 46, height.i = 21 )
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlPopup_t = AllocateMemory( SizeOf(ControlPopup_t) )
    
    ; ---[ Init CObject Base Class ]--------------------------------------------
    Object::INI( ControlPopup )
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type        = Control::#POPUP
    *Me\name        = "popup"
    *Me\parent      = *parent
    *Me\gadgetID    = *parent\gadgetID
    *Me\posX        = x
    *Me\posY        = y
    *Me\sizX        = width
    *Me\sizY        = 21
    *Me\visible     = #True
    *Me\enable      = #True
    
    *Me\edit        = ControlEdit::New(*Me, "popup_edit","",0,x,y,width,height)
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  
  ; ============================================================================
  ;  REFLECTION
  ; ============================================================================
  Class::DEF( ControlPopup )
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 77
; FirstLine = 36
; Folding = ---
; EnableThread
; EnableXP
; EnableUnicode