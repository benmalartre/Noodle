XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
InitScintilla()

; ==============================================================================
;  SCINTILLA Control MODULE DECLARATION
; ==============================================================================
DeclareModule ControlScintilla

  #HEAD_HEIGHT = 18
   
  Structure ControlScintilla_t Extends Control::Control_t
    over .i
    down.i
    value.i
    touch_l.i
    touch_r.i
  EndStructure

  Interface IControlScintilla Extends Control::IControl
  EndInterface
  

  Declare New( name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlScintilla_t)
  Declare OnEvent( *Me.ControlScintilla_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  
  DataSection 
    ControlScintillaVT: 
    Data.i @OnEvent()
    Data.i @Delete()
  EndDataSection
 
  
 Global CLASS.Class::Class_t
EndDeclareModule


; ==============================================================================
;  SCINTILLA CONTROL MODULE IMPLEMENTATION
; ==============================================================================
Module ControlScintilla
  Procedure hlpDraw( *Me.ControlScintilla_t, xoff.i = 0, yoff.i = 0 )
    If Not *Me\visible : ProcedureReturn : EndIf
    
    Protected w.i = *Me\sizX
    Protected h.i
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    
    Box(*Me\posX,*Me\posY,*Me\sizX,*Me\sizY,UIColor::COLOR_MAIN_BG)
    
    Protected *obj.Object::Object_t = *Me\object
    
    Protected *prop.Control::Control_t = *Me\parent
    Protected *n.Node::Node_t = *prop\object
    
    DrawingFont(FontID(Globals::#FONT_TEXT))
    w = TextWidth(*n\name)
    h = TextHeight(*n\name)
    
    
    If *Me\over
      Box(*Me\posX+30,*Me\posY+*Me\sizY*0.5-3,*Me\sizX-(w+70),1,UIColor::COLOR_CARET)
    Else
      Box(*Me\posX+30,*Me\posY+*Me\sizY*0.5-3,*Me\sizX-(w+70),1,UIColor::COLOR_LABEL)
    EndIf
    
    If *Me\touch_l
      Box(*Me\posX,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT,UIColor::COLOR_NUMBER_BG)
    Else
      Box(*Me\posX,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT,UIColor::COLOR_NUMBER_FG)
    EndIf
    
    If *Me\touch_r
      Box(*Me\posX+*Me\sizX-#HEAD_HEIGHT,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT, UIColor::COLOR_NUMBER_BG)
    Else
      Box(*Me\posX+*Me\sizX-#HEAD_HEIGHT,*Me\posY,#HEAD_HEIGHT,#HEAD_HEIGHT, UIColor::COLOR_NUMBER_FG)
    EndIf
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(*Me\posX+*Me\sizX-(w+30),*Me\posY+*Me\sizY*0.5-h*0.5,*n\name)
    DrawText(*Me\posX+6,*Me\posY, "-")
    DrawText(*Me\posX+*Me\sizX-#HEAD_HEIGHT+6,*Me\posY, "x")


  EndProcedure

  Procedure.i OnEvent( *Me.ControlScintilla_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    Select ev_code
 
      Case Control::#PB_EventType_Draw
        hlpDraw( *Me.ControlScintilla_t, *ev_data\xoff, *ev_data\yoff )
        ProcedureReturn( #True )
        
      Case #PB_EventType_Resize
        If Not *ev_data : ProcedureReturn : EndIf
        
        *Me\sizX = *ev_data\width
        *Me\sizY = #HEAD_HEIGHT
        *Me\posX = 0
        *Me\posY = 0

        ProcedureReturn( #True )
        
      Case #PB_EventType_MouseEnter
        *Me\over = #True
        Control::Invalidate(*Me)
  
      Case #PB_EventType_MouseLeave
        If *Me\visible And *Me\enable
          *Me\over = #False
          *Me\touch_l = #False
          *Me\touch_r = #False
          *Me\down = #False
          Control::Invalidate(*Me)
        EndIf
        
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

      Case #PB_EventType_LeftButtonDown
        If *Me\visible And *Me\enable And *Me\over
          *Me\down = #True
          Control::Invalidate(*Me)
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        If *Me\visible And *Me\enable
          *Me\down = #False
          If *Me\over And *Me\touch_l 
            Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,#False)
          ElseIf *Me\over And *Me\touch_r
            Slot::Trigger(*Me\slot,Signal::#SIGNAL_TYPE_PING,#True)
          EndIf
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

  Procedure SetValue( *Me.ControlScintilla_t, value.i )
    If value = *Me\value
      ProcedureReturn
    EndIf
    
    *Me\value = value
    Control::Invalidate(*Me)
  EndProcedure
  
  Procedure.i GetValue( *Me.ControlScintilla_t )
    ProcedureReturn( *Me\value )
  EndProcedure
  
  Procedure Delete( *Me.ControlScintilla_t )
    Object::TERM(ControlScintilla)
  EndProcedure

  Procedure.i New( *obj.Object::Object_t,name.s, options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    Protected *Me.ControlScintilla_t = AllocateStructure(ControlScintilla_t)
    
    Object::INI(ControlScintilla)
    *Me\object = *obj
    Protected *parent.Control::Control_t = *obj
    
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

    ProcedureReturn( *Me )
  EndProcedure
  
  Class::DEF(ControlScintilla)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 12
; Folding = --
; EnableXP