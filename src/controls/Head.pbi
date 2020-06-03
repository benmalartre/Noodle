XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Callback.pbi"

; ==============================================================================
;  CONTROL HEAD MODULE DECLARATION
; ==============================================================================
DeclareModule ControlHead
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  #HEAD_BUTTON_SIZE = 12
  #HEAD_STROKE_WIDTH = 1
  #HEAD_MARGIN = 12
   
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlHead_t )
  ; ----------------------------------------------------------------------------
  Structure ControlHead_t Extends Control::Control_t
    over .i
    down.i
    value.i
    touch_l.i
    touch_r.i
    title.s
    *on_delete.Slot::Slot_t
    *on_expand.Slot::Slot_t
  EndStructure

  ; ----------------------------------------------------------------------------
  ;  Interface ( IControlHead )
  ; ----------------------------------------------------------------------------
  Interface IControlHead Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  Declare New( *parent.Object::Object_t,name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlHead_t)
  Declare Draw( *Me.ControlHead_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlHead_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetTheme( theme.i )
  Declare.b Init()
  Declare.b Term()
  
  ; ----------------------------------------------------------------------------
  ;  Datas 
  ; ----------------------------------------------------------------------------
  DataSection 
    ControlHeadVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
 
  
 Global CLASS.Class::Class_t
EndDeclareModule


; ==============================================================================
;  CONTROL HEAD MODULE IMPLEMENTATION
; ==============================================================================
Module ControlHead
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure Draw( *Me.ControlHead_t, xoff.i = 0, yoff.i = 0 )
    ; Check Visible
    If Not *Me\visible : ProcedureReturn : EndIf
    
    Protected w.i = *Me\sizX
    Protected h.i

    AddPathBox(*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
        
    Protected *prop.Control::Control_t = *Me\parent
    
    VectorFont(FontID(Globals::#FONT_BOLD),Globals::#FONT_SIZE_TITLE)
    w = VectorTextWidth(*Me\title)
    h = VectorTextHeight(*Me\title)
    
    MovePathCursor(*Me\posX+30,*Me\posY+*Me\sizY*0.5-3)
    AddPathLine(*Me\sizX-(w+70),0, #PB_Path_Relative)
    VectorSourceColor(UIColor::COLOR_LABEL_DISABLED)
    StrokePath(#HEAD_STROKE_WIDTH)
    
    If *Me\touch_l
      AddPathBox(*Me\posX,*Me\posY,#HEAD_BUTTON_SIZE,#HEAD_BUTTON_SIZE)
      VectorSourceColor(UIColor::COLOR_NUMBER_BG)
      FillPath()
    Else
      AddPathBox(*Me\posX,*Me\posY,#HEAD_BUTTON_SIZE,#HEAD_BUTTON_SIZE)
      VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
      FillPath()
    EndIf
    
    If *Me\touch_r
      AddPathBox(*Me\posX+*Me\sizX-#HEAD_BUTTON_SIZE,*Me\posY,#HEAD_BUTTON_SIZE,#HEAD_BUTTON_SIZE)
      VectorSourceColor(UIColor::COLOR_NUMBER_BG)
      FillPath()
    Else
      AddPathBox(*Me\posX+*Me\sizX-#HEAD_BUTTON_SIZE,*Me\posY,#HEAD_BUTTON_SIZE,#HEAD_BUTTON_SIZE)
      VectorSourceColor(UIColor::COLOR_SECONDARY_BG)
      FillPath()
    EndIf
    
    VectorSourceColor(UIColor::COLOR_LABEL)
    MovePathCursor(*Me\posX+*Me\sizX-(w+30),*Me\posY+*Me\sizY*0.5-h*0.75)
    DrawVectorText(*Me\title)
    MovePathCursor(*Me\posX+3,*Me\posY+6)
    AddPathLine(6,0, #PB_Path_Relative)
    StrokePath(#HEAD_STROKE_WIDTH)
    
    MovePathCursor(*Me\posX+*Me\sizX-3.5,*Me\posY+2.5)
    AddPathLine(-6,6, #PB_Path_Relative)
    StrokePath(#HEAD_STROKE_WIDTH)
    MovePathCursor(*Me\posX+*Me\sizX-9.5,*Me\posY+2.5)
    AddPathLine(6,6, #PB_Path_Relative)
    StrokePath(#HEAD_STROKE_WIDTH)
    
  EndProcedure
  ;}

  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlHead_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
  
      ; ------------------------------------------------------------------------
      ;  Draw
      ; ------------------------------------------------------------------------
      Case Control::#PB_EventType_Draw
        ; ...[ Draw Control ]...................................................
        Draw( *Me.ControlHead_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_EventType_Resize
        
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Cancel Width & Height Resize ]...................................
        *Me\sizX = *ev_data\width
        *Me\sizY = #HEAD_BUTTON_SIZE
        *Me\posX = 0
        *Me\posY = 0

        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  MouseEnter
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseEnter
        *Me\over = #True
        Control::Invalidate(*Me)
  
      ; ------------------------------------------------------------------------
      ;  MouseLeave
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          *Me\touch_l = #False
          *Me\touch_r = #False
          *Me\down = #False
          Control::Invalidate(*Me)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  MouseMove
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseMove
        If *Me\visible And *Me\enable
          Protected mx = GetGadgetAttribute(*Me\parent\gadgetID,#PB_Canvas_MouseX)
          Protected my = GetGadgetAttribute(*Me\parent\gadgetID,#PB_Canvas_MouseY)
          
          If mx-*Me\posX < 20
            *Me\touch_l = #True
            *Me\touch_r = #False
            Control::Invalidate(*Me)
          Else
            If *Me\touch_l
              *Me\touch_l = #False
              Control::Invalidate(*Me)
            EndIf
            
          EndIf
          If mx-*Me\posX > *Me\parent\sizX-20
            *Me\touch_r = #True
            *Me\touch_l = #False
            Control::Invalidate(*Me)
          Else
            If *Me\touch_r
              *Me\touch_r = #False
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
        If *Me\visible And *Me\enable And *Me\over
          *Me\down = #False
          If *Me\over And *Me\touch_l 
            Signal::Trigger(*Me\on_expand,Signal::#SIGNAL_TYPE_PING)
          ElseIf *Me\over And *Me\touch_r
            Signal::Trigger(*Me\on_delete,Signal::#SIGNAL_TYPE_PING)
          EndIf
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
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
  Procedure SetValue( *Me.ControlHead_t, value.i )
    
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
  ; ---[ Get Value ]------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlHead_t )
    
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  
  ; ---[ Set Title ]------------------------------------------------------------
  Procedure SetTitle(*Me.ControlHead_t, title.s)
    *Me\title = title
  EndProcedure
 
  ; ----------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure Delete( *Me.ControlHead_t )
    ; ---[ Terminate Object ]---------------------------------------------------
    Object::TERM(ControlHead)
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  CONSTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure.i New( *parent.Control::Control_t, name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlHead_t = AllocateMemory( SizeOf(ControlHead_t) ) 
    
    Object::INI(ControlHead)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#HEAD
    *Me\title = "Property"
    *Me\name     = name
    *Me\gadgetID = *parent\gadgetID
    *Me\parent   = *parent
    *Me\posX     = x
    *Me\posY     = y
    *Me\sizX     = width
    *Me\sizY     = 18
    *Me\visible  = #True
    *Me\enable   = #True
    *Me\options  = options
    *Me\value    = value
    *Me\over     = #False
    *Me\down     = #False
    *Me\touch_l  = #False
    *Me\touch_r  = #False
    
    *Me\on_change = Object::NewSignal(*me, "OnChange")
    *Me\on_delete = Object::NewSignal(*Me, "OnDelete")
    *Me\on_expand = Object::NewSignal(*Me, "OnExpand")
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure


  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  Procedure SetTheme( theme.i )
    
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Init
  ; ----------------------------------------------------------------------------
  Procedure.b Init( )
    
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  ; ----------------------------------------------------------------------------
  ;  ControlsHeadTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  
  Class::DEF(ControlHead)
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 147
; FirstLine = 144
; Folding = ---
; EnableXP