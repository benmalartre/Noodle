XIncludeFile "Object.pbi"

; ==============================================================================
;  CONTROL MODULE DECLARATION
; ==============================================================================
DeclareModule Control
  ; ---[ Event Types ]---------------------
  Enumeration
    #PB_EventType_Draw = 128
    #PB_EventType_DrawChild
    #PB_EventType_ChildFocused
    #PB_EventType_ChildDeFocused
    #PB_EventType_ChildCursor
    #PB_EventType_Show
    #PB_EventType_Hide
    #PB_EventType_Enable
    #PB_EventType_Disable
    CompilerIf #PB_Compiler_Version < 560
      #PB_EventType_Resize
    CompilerEndIf
    
    #PB_EventType_Attribute
  EndEnumeration
  
  ; ---[ Gadget Types ]--------------------
  Enumeration
    #CHECK
    #ICON
    #RADIO
    #COMBO
    #LABEL
    #DIVOT
    #EDIT
    #NUMBER
    #GROUP
    #COLORWHEEL
    #COLOR
    #SHADERCODE
    #EXPLORER
    #HEAD
  EndEnumeration
  
  ; ---[ Gadget State ]--------------------
  Enumeration
    #DEFAULT
    #OVER
    #PRESSED
  EndEnumeration
  
  Structure EventTypeDatas_t
    x     .i
    y     .i
    width .i
    height.i
    xoff  .i
    yoff  .i
    input .s
    key   .i
    modif .i
  EndStructure
  
  
  ; ----------------------------------------------------------------------------
  ;   Control Instance
  ; ----------------------------------------------------------------------------
  Structure Control_t  Extends Object::Object_t
    *parent    .Control_t
    *object    .Object::Object_t
    type       .i
    name       .s
    gadgetID   .i
    posX       .i
    posY       .i
    sizX       .i
    sizY       .i
    visible    .i
    enable     .i
    options    .i
    state      .i
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;   Control Interface
  ; ----------------------------------------------------------------------------
  Interface IControl
    OnEvent( ev_code.i, *ev_data.EventTypeDatas_t = #Null )
    Delete()
  EndInterface
  
  Declare GetGadgetID(*Me.Control_t)
  Declare GetType(*Me.Control_t)
  Declare SetName( *Me.Control_t, name.s )
  Declare.s GetName( *Me.Control_t )
  Declare.i Show( *Me.Control_t )
  Declare.i Hide( *Me.Control_t )
  Declare Enable( *Me.Control_t )
  Declare Disable( *Me.Control_t )
  Declare Resize( *Me.Control_t, x.i, y.i, width.i, height.i = 22 )
  Declare Invalidate(*Me.Control_t)
  Declare Focused( *Me.Control_t )
  Declare DeFocused( *Me.Control_t )
  Declare SetCursor( *Me.Control_t, cursor_id.i )
EndDeclareModule

; ==============================================================================
;  CONTROL MODULE IMPLEMENTATION
; ==============================================================================
Module Control
  
  ; ---[ GetGadgetID ]----------------------------------------------------------
  Procedure.i GetGadgetID( *Me.Control_t )
    
    ; ---[ Return This Control Main/Container GadgetID ]------------------------
    ProcedureReturn( *Me\gadgetID )
    
  EndProcedure
  ; ---[ GetType ]--------------------------------------------------------------
  Procedure.i GetType( *Me.Control_t )
    
    ; ---[ Return Control Type ]------------------------------------------------
    ProcedureReturn( *Me\type )
    
  EndProcedure
  ; ---[ SetName ]--------------------------------------------------------------
  Procedure SetName( *Me.Control_t, name.s )
    
    ; ---[ Set Control Name ]---------------------------------------------------
    *Me\name = name
    
  EndProcedure
  ; ---[ GetName ]--------------------------------------------------------------
  Procedure.s GetName( *Me.Control_t )
    
    ; ---[ Return Control Name ]------------------------------------------------
    ProcedureReturn( *Me\name )
    
  EndProcedure
  ; ---[ Show ]-----------------------------------------------------------------
  Procedure.i Show( *Me.Control_t )
    If Not *Me\visible
      *Me\visible = #False
      HideGadget(*Me\gadgetID,1)
    EndIf
  EndProcedure
  ; ---[ Hide ]-----------------------------------------------------------------
  Procedure.i Hide( *Me.Control_t )
    If *Me\visible
      *Me\visible = #True
      HideGadget(*Me\gadgetID,0)
    EndIf
  EndProcedure
  ; ---[ Enable ]---------------------------------------------------------------
  Procedure.i Enable( *Me.Control_t )
    Protected Me.IControl = *Me
    ; ---[ Send Event ]---------------------------------------------------------
    If Not Me\OnEvent( #PB_EventType_Enable )
      ; ...[ Enable Gadget ]....................................................
      DisableGadget( *Me\gadgetID, 0 )
      ; ...[ Update Status ]....................................................
      *Me\enable = #True
    EndIf
    
    ; ---[ Return Null ]--------------------------------------------------------
    ProcedureReturn( #Null )
    
  EndProcedure
  ; ---[ Disable ]--------------------------------------------------------------
  Procedure.i Disable( *Me.Control_t )
    Protected Me.IControl = *Me
    ; ---[ Send Event ]---------------------------------------------------------
    If Not Me\OnEvent( #PB_EventType_Disable )
      ; ...[ Disable Gadget ]...................................................
      DisableGadget( *Me\gadgetID, 1 )
      ; ...[ Update Status ]....................................................
      *Me\enable = #False
    EndIf
    
    ; ---[ Return Null ]--------------------------------------------------------
    ProcedureReturn( #Null )
    
  EndProcedure
  ; ---[ Resize ]---------------------------------------------------------------
  Procedure Resize( *Me.Control_t, x.i, y.i, width.i, height.i = 22 )
    If Not *Me : ProcedureReturn : EndIf
    Protected Me.IControl = *Me
    ; ---[ Local Variables ]----------------------------------------------------
    Protected ev_datas.EventTypeDatas_t
    
    ; ---[ Set Event Datas ]----------------------------------------------------  
    ev_datas\x      = x
    ev_datas\y      = y
    ev_datas\width  = width
    ev_datas\height = height
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    

    ; ---[ Send Event ]---------------------------------------------------------
    If Not Me\OnEvent( #PB_EventType_Resize, @ev_datas )
      
      ; ...[ Update Status ]....................................................
      If #PB_Ignore <> x      : *Me\posX = x      : EndIf
      If #PB_Ignore <> y      : *Me\posY = y      : EndIf
      If #PB_Ignore <> width  : *Me\sizX = width  : EndIf
      If #PB_Ignore <> height : *Me\sizY = height : EndIf
    EndIf
    
  EndProcedure

  ; ---[ SetAttribute ]---------------------------------------------------------
  Procedure SetAttribute( *Me.Control_t, attribute.i, i_value.i, d_value.d, s_value.s )
    
    ; ---[ Retrieve Interface ]-------------------------------------------------
    Protected Me.IControl = *Me
    
    ; ---[ Send Event ]---------------------------------------------------------
    If Not Me\OnEvent( #PB_EventType_Attribute )
      ; TODO : Update attribute
    EndIf
    
  EndProcedure
  ; ---[ GetAttribute ]---------------------------------------------------------
  Procedure.i GetAttribute( *Me.Control_t, attribute.i, *value_out )
    
  EndProcedure
  ; ---[ Invalidate ]-----------------------------------------------------------
  Procedure.i Invalidate( *Me.Control_t )
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *Me\parent
      Protected *obj.IControl = *Me\parent
      ; ...[ Ask Parent To Redraw Me ]..........................................
      *obj\OnEvent( #PB_EventType_DrawChild, *Me )
    EndIf
    
  EndProcedure
  ; ---[ Focused ]--------------------------------------------------------------
  Procedure.i Focused( *Me.Control_t )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *Me\parent
      Protected *obj.IControl = *Me\parent
      ; ...[ Tell Parent I'm Now Focused ]......................................
      *obj\OnEvent( #PB_EventType_ChildFocused, *Me )
    EndIf
    
  EndProcedure
  ; ---[ DeFocused ]------------------------------------------------------------
  Procedure.i DeFocused( *Me.Control_t )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *Me\parent
      Protected *obj.IControl = *Me\parent
      ; ...[ Tell Parent I'm Not In Focus Anymore ].............................
      *obj\OnEvent( #PB_EventType_ChildDeFocused, *Me )
    EndIf
    
  EndProcedure
  ; ---[ SetCursor ]------------------------------------------------------------
  Procedure.i SetCursor( *Me.Control_t, cursor_id.i )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *Me\parent
      Protected *obj.IControl = *Me\parent
      ; ...[ Ask Parent To Set Cursor For Me ]..................................
      *obj\OnEvent( #PB_EventType_ChildCursor, cursor_id )
    EndIf
    
  EndProcedure
  ; ---[ SignalOnChange ]-------------------------------------------------------
;   Procedure.i SignalOnChanged( *Me.Control_t )
;     ; ---[ Return 'OnChanged' Slot ]-----------------------------------------------
;     ProcedureReturn( *Me\sig_onchanged )
;   EndProcedure

EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 13
; Folding = H5--
; EnableXP
; EnableUnicode