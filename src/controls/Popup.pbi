
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
    value.s
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
  Declare StartLoop(*Me.ControlPopup_t)
  
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

  Procedure StartLoop(*Me.ControlPopup_t)
    
    StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
    Draw(*Me)
    StopVectorDrawing()
    
    SetActiveGadget(*Me\gadgetID)
    Define ev_datas.Control::EventTypeDatas_t
    Repeat
      Define ev = WaitWindowEvent()
      If ev = #PB_Event_Gadget And EventGadget() = *Me\gadgetID
        
        Select EventType()
          Case #PB_EventType_Input
            ev_datas\key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input)
            ev_datas\input = Chr(ev_datas\key)
            ev_datas\xoff = *Me\posX
            ev_datas\yoff = *Me\posY
            ControlEdit::OnEvent(*Me\edit, #PB_EventType_Input, ev_datas)
            StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
            ControlEdit::OnEvent(*Me\edit, Control::#PB_EventType_Draw, ev_datas)
            StopVectorDrawing()
            
          Case #PB_EventType_KeyDown
            ev_datas\key = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key)
            ev_datas\input = Chr(ev_datas\key)
            ev_datas\xoff = *Me\posX
            ev_datas\yoff = *Me\posY
            ControlEdit::OnEvent(*Me\edit, #PB_EventType_KeyDown, ev_datas)
            StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
            ControlEdit::OnEvent(*Me\edit, Control::#PB_EventType_Draw, ev_datas)
            StopVectorDrawing()
        EndSelect
      EndIf
      
     
;       Select EventType()
;         Case #PB_EventType_Input
;           Define key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Input)
;           Define modifier = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
;         
;           If *Me\edit
;             If *Me\options & #PB_String_Numeric
;               If Not Globals::ISNUMERIC(key) : ProcedureReturn : EndIf
;               *Me\value + Chr(key)
;               *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
;             Else
;               *Me\value + Chr(key)
;               *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
;             EndIf
;           EndIf
;           Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
;             
;         Case #PB_EventType_KeyDown
;           Define key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Key)
;           Define modifier = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
;           
;           Select key
;             Case #PB_Shortcut_Return
;               *Me\edit = #False
;               *Me\active = #False
;               *Me\caret_l = -1
;               *Me\caret_r = -1
;               Time::StopTimer(*Me)
;               If *Me\value = "" : *Me\value = "0" : EndIf
;               Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
;               
;             Case #PB_Shortcut_Back
;               Define l = Len(*Me\value)
;               If l > 0 : *Me\value = Left(*Me\value, l-1) : EndIf
;              *Me\caret_x = IndexToPosition(*Me, Len(*Me\value))
;              Signal::Trigger(*Me\on_change, Signal::#SIGNAL_TYPE_PING)
;           EndSelect
; 
;       EndSelect
      
    Until EventType() = #PB_EventType_LeftClick
  EndProcedure
          
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
    Protected tc.i = UIColor::COLOR_LABEL
    
    ; ---[ Set Font ]-----------------------------------------------------------
    VectorFont(FontID(Globals::#FONT_DEFAULT))
    
    ControlEdit::Draw(*Me\edit,*Me\posX,*Me\posY)
    
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
      Case #PB_EventType_Resize
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
        Debug "WTHEFUCK POPUP : "+*Me\name
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

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 142
; FirstLine = 138
; Folding = ---
; EnableThread
; EnableXP
; EnableUnicode