XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/View.pbi"
; ==============================================================================
;  CONTROL TEXT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlText

  Structure ControlText_t Extends Control::Control_t
    text        .s
  EndStructure
  
  Interface IControlText Extends Control::IControl
  EndInterface
  
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

Procedure Draw( *Me.ControlText_t, xoff.i = 0, yoff.i = 0 )
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
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
  VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
  FillPath()
  
  If Not *Me\enable
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UIColor::COLOR_LABEL_DISABLED)
    StrokePath(2)
    
  Else
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UIColor::COLOR_TEXT_DEFAULT)
    StrokePath(2)

  EndIf

  MovePathCursor(tx + xoff, ty)
  VectorSourceColor(tc)
  DrawVectorText( *Me\text )
  
EndProcedure
;}


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
Procedure.i OnEvent( *Me.ControlText_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Protected Me.Control::IControl = *Me

  Select ev_code
      
    Case Control::#PB_EventType_Draw
      If Not( *ev_data ):ProcedureReturn : EndIf
      Draw( *Me, *ev_data\xoff, *ev_data\yoff )
      ProcedureReturn( #True )
      
    Case #PB_EventType_Resize
      If Not( *ev_data ):ProcedureReturn : EndIf
      *Me\sizY = 18
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ProcedureReturn( #True )

    Case Control::#PB_EventType_Enable
      If Not *Me\enable
        *Me\enable = #True
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ProcedureReturn( #True )

    Case Control::#PB_EventType_Disable
      If *Me\enable
        *Me\enable = #False
        If *Me\visible
          Control::Invalidate(*Me)
        EndIf
      EndIf
      ProcedureReturn( #True )

  EndSelect
  
  ProcedureReturn( #False )
  
EndProcedure

  
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlEdit )
  ; ============================================================================
  Procedure SetText( *Me.ControlText_t, text.s )
    
    If text = *Me\text
      ProcedureReturn
    EndIf
    
    *Me\text = text
    
    Control::Invalidate(*Me)
    
  EndProcedure
  Procedure.s GetText( *Me.ControlText_t )
    ProcedureReturn( *Me\text )
  EndProcedure
  
  Procedure Delete( *Me.ControlText_t )
    Object::TERM(ControlText)
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t ,name.s, text.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    Protected *Me.ControlText_t = AllocateStructure(ControlText_t)
    
    Object::INI(ControlText)
    
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
    
    InitializeStructure( *Me, ControlText_t )
    
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Class::DEF( ControlText )
  
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 52
; FirstLine = 27
; Folding = --
; EnableXP