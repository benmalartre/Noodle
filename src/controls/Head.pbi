XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"

; ==============================================================================
;  CONTROL HEAD MODULE DECLARATION
; ==============================================================================
DeclareModule ControlHead
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  #HEAD_HEIGHT = 18
   
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlHead_t )
  ; ----------------------------------------------------------------------------
  Structure ControlHead_t Extends Control::Control_t
    over .i
    down.i
    value.i
    touch_l.i
    touch_r.i
  EndStructure

  ; ----------------------------------------------------------------------------
  ;  Interface ( IControlHead )
  ; ----------------------------------------------------------------------------
  Interface IControlHead Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares 
  ; ----------------------------------------------------------------------------
  Declare New( *object.Object::Object_t,name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlHead_t)
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
  Procedure hlpDraw( *Me.ControlHead_t, xoff.i = 0, yoff.i = 0 )

    ; Check Visible
    If Not *Me\visible : ProcedureReturn : EndIf
    
    Protected w.i = *Me\sizX
    Protected h.i
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    
    Box(*Me\posX,*Me\posY,*Me\sizX,*Me\sizY,UIColor::COLORA_MAIN_BG)
    
    Protected *obj.Object::Object_t = *Me\object
    
    Protected *prop.Control::Control_t = *Me\parent
    Protected *n.Node::Node_t = *prop\object
    
    DrawingFont(FontID(Globals::#FONT_TEXT))
    w = TextWidth(*n\name)
    h = TextHeight(*n\name)
    
    
    If *Me\over
      Box(*Me\posX+30,*Me\posY+*Me\sizY*0.5-3,*Me\sizX-(w+70),1,UIColor::COLORA_CARET)
    Else
      Box(*Me\posX+30,*Me\posY+*Me\sizY*0.5-3,*Me\sizX-(w+70),1,UIColor::COLORA_LABEL)
    EndIf
    
    If *Me\touch_l
      Box(*Me\posX,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT,UIColor::COLORA_NUMBER_BG)
    Else
      Box(*Me\posX,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT,UIColor::COLORA_NUMBER_FG)
    EndIf
    
    If *Me\touch_r
      Box(*Me\posX+*Me\sizX-#HEAD_HEIGHT,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT, UIColor::COLORA_NUMBER_BG)
    Else
      Box(*Me\posX+*Me\sizX-#HEAD_HEIGHT,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT, UIColor::COLORA_NUMBER_FG)
    EndIf
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(*Me\posX+*Me\sizX-(w+30),*Me\posY+*Me\sizY*0.5-h*0.5,*n\name)
    DrawText(*Me\posX+6,*Me\posY, "-")
    DrawText(*Me\posX+*Me\sizX-#HEAD_HEIGHT+6,*Me\posY, "x")


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
        hlpDraw( *Me.ControlHead_t, *ev_data\xoff, *ev_data\yoff )
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      CompilerIf #PB_Compiler_Version <560
        Case Control::#PB_EventType_Resize
      CompilerElse
        Case #PB_EventType_Resize
      CompilerEndIf
        
        ; ...[ Sanity Check ]...................................................
        If Not *ev_data : ProcedureReturn : EndIf
        
        ; ...[ Cancel Width & Height Resize ]...................................
        *Me\sizX = *ev_data\width
        *Me\sizY = #HEAD_HEIGHT
        *Me\posX = 0
        *Me\posY = 0

        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
      ; ------------------------------------------------------------------------
      ;  MouseEnter
      ; ------------------------------------------------------------------------
      Case #PB_EventType_MouseEnter
        Debug "CONTROl HEAD MOUSE ENTER"
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
          If *Me\down
            Control::Invalidate(*Me)
          Else
            Protected mx = GetGadgetAttribute(*Me\parent\gadgetID,#PB_Canvas_MouseX)
            Protected my = GetGadgetAttribute(*Me\parent\gadgetID,#PB_Canvas_MouseY)
            
            If mx-*Me\posX < 20
              *Me\touch_l = #True
              Control::Invalidate(*Me)
            Else
              If *Me\touch_l
                *Me\touch_l = #False
                Control::Invalidate(*Me)
              EndIf
              
            EndIf
            If mx-*Me\posX > *Me\parent\sizX-20
              *Me\touch_r = #True
              Control::Invalidate(*Me)
            Else
              If *Me\touch_r
                *Me\touch_r = #False
                Control::Invalidate(*Me)
              EndIf
            EndIf
            
;             
;             If mx<10 Or mx > *Me\sizX-10
;               MessageRequester("HEAD", "TOUCH BORDER")
;             EndIf
            
;             StartDrawing(CanvasOutput(*Me\parent\gadgetID))
;             Circle(mx,my,3,RGBA(255,255,255,255))
;             Circle(mx,my,2,RGBA(255,0,0,255))
;             StopDrawing()
            
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
        If *Me\visible And *Me\enable
          *Me\down = #False
          If *Me\over And *Me\touch_l 
            Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,#False)
          ElseIf *Me\over And *Me\touch_r
            Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,#True)
          EndIf
          
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
  ; ---[ GetValue ]-------------------------------------------------------------
  Procedure.i GetValue( *Me.ControlHead_t )
    
    ; ---[ Return Value ]-------------------------------------------------------
    ProcedureReturn( *Me\value )
    
  EndProcedure
  
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlHead_t )
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
  EndProcedure


  ; ----------------------------------------------------------------------------
  ;  CONSTRUCTOR
  ; ----------------------------------------------------------------------------
  Procedure.i New( *obj.Object::Object_t,name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlHead_t = AllocateMemory( SizeOf(ControlHead_t) ) 
    
    Object::INI(ControlHead)
    *Me\object = *obj
    Protected *parent.Control::Control_t = *obj
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type     = Control::#CONTROL_HEAD
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
  ;  raaGuiControlsHeadTermOnce
  ; ----------------------------------------------------------------------------
  Procedure.b Term( )
  
    
    ; ---[ OK ]-----------------------------------------------------------------
    ProcedureReturn( #True )
    
  EndProcedure
  
  Class::DEF(ControlHead)
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 222
; FirstLine = 194
; Folding = ---
; EnableXP