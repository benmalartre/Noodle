XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/View.pbi"
; ==============================================================================
;  CONTROL TEXT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlText

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlText_t )
  ; ----------------------------------------------------------------------------
  
  Structure ControlText_t Extends Control::Control_t
    text        .s
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlText Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  
  Declare New(*parent.Control::Control_t ,name.s, value.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlText_t)
  Declare Draw( *Me.ControlText_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlText_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare.s GetText( *Me.ControlText_t )
  Declare SetText( *Me.ControlText_t, text.s )


  ; ============================================================================
  ;  VTABLE & DATAS ( CObject + CControl + CControlEdit )
  ; ============================================================================
  DataSection
    ControlTextVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
    
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule

;}


; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlText

; ----------------------------------------------------------------------------
;  Draw
; ----------------------------------------------------------------------------
Procedure Draw( *Me.ControlText_t, xoff.i = 0, yoff.i = 0 )
  ; ---[ Check Visible ]------------------------------------------------------
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  ; ---[ Set Font ]-----------------------------------------------------------
  Protected tc.i = UIColor::COLOR_TEXT_DEFAULT
  VectorFont( FontID(Globals::#FONT_BOLD), Globals::#FONT_SIZE_LABEL )
  Protected tx.i = 7
  Protected ty.i
  If Len(*Me\text)
    ty.i = ( *Me\sizY - VectorTextHeight( *Me\text ) )/2 + yoff
  Else
    ty.i = (*Me\sizY - Globals::#FONT_SIZE_LABEL)/2 + yoff
  EndIf
  
  AddPathBox(xoff-1, yoff-1, *Me\sizX+2, *Me\sizY+2)
  VectorSourceColor(UIColor::COLOR_MAIN_BG)
  FillPath()
  
  ; ---[ Check Disabled ]-----------------------------------------------------
  If Not *Me\enable
    VectorSourceColor(RGBA(255,255,255,32))
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(0,0,0,32))
    StrokePath(2)
    
  Else
    VectorSourceColor(RGBA(0,0,255,32))
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(0,0,0,32))
    StrokePath(2)

  EndIf

  ; ---[ Draw Value ]-------------------------------------------------------
  MovePathCursor(tx + xoff, ty)
  VectorSourceColor(tc)
  DrawVectorText( *Me\text )
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
;{
; ---[ Event ]----------------------------------------------------------------
Procedure.i OnEvent( *Me.ControlText_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  ; ---[ Retrieve Interface ]-------------------------------------------------
  Protected Me.Control::IControl = *Me

  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not( *ev_data ):ProcedureReturn : EndIf
      
      ; ---[ Draw Control ]---------------------------------------------------
      Draw( *Me, *ev_data\xoff, *ev_data\yoff )
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Resize
      ; ---[ Sanity Check ]---------------------------------------------------
      If Not( *ev_data ):ProcedureReturn : EndIf
      ; ---[ Cancel Height ]--------------------------------------------------
      *Me\sizY = 18
      ; ---[ Update Topology ]------------------------------------------------
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )

    ; ------------------------------------------------------------------------
    ;  Enable
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Enable
      If Not *Me\enable
        *Me\enable = #True
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )

    ; ------------------------------------------------------------------------
    ;  Disable
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Disable
      If *Me\enable
        *Me\enable = #False
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ; ---[ Processed ]------------------------------------------------------
      ProcedureReturn( #True )

  EndSelect
  
  ; ---[ Process Default ]----------------------------------------------------
  ProcedureReturn( #False )
  
EndProcedure
;}

  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlEdit )
  ; ============================================================================
  ; ---[ SetValue ]-------------------------------------------------------------
  Procedure SetText( *Me.ControlText_t, text.s )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If text = *Me\text
      ; ...[ Abort ]............................................................
      ProcedureReturn
    EndIf
    
    ; ---[ Set Value ]----------------------------------------------------------
    *Me\text = text
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    Control::Invalidate(*Me)
    
  EndProcedure
  ; ---[ GetText ]--------------------------------------------------------------
  Procedure.s GetText( *Me.ControlText_t )
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\text )
  EndProcedure
  
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlText_t )
    Object::TERM(ControlText)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t ,name.s, text.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlText_t = AllocateStructure(ControlText_t)
    
    Object::INI(ControlText)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type         = Control::#TEXT
    *Me\name         = name
    *Me\parent       = *parent
    *Me\gadgetID     = *parent\gadgetID
    *Me\posX         = x
    *Me\posY         = y
    *Me\sizX         = width
    *Me\sizY         = height
    *Me\fixedX       = #True
    *Me\fixedY       = #True
    *Me\percX        = -1
    *Me\percY        = -1
    *Me\visible      = #True
    *Me\enable       = #True
    *Me\options      = options
    *Me\text         = text
    
    ; ---[ Init Array ]---------------------------------------------------------
    InitializeStructure( *Me, ControlText_t )
    
    ; ---[ Signals ]------------------------------------------------------------
    *Me\on_change = Object::NewSignal(*Me, "OnChange")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlText )
  
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 209
; FirstLine = 206
; Folding = --
; EnableXP