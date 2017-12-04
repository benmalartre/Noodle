; ============================================================================
;  raafal.gui.controls.timeline.pbi
; ............................................................................
;  GUI Timeline Control
; ============================================================================
;  2013/02/24 | benmalartre
;  - creation
; ============================================================================
XIncludeFile "../core/Time.pbi"
XIncludeFile "Icon.pbi"
XIncludeFile "Number.pbi"
XIncludeFile "Combo.pbi"

DeclareModule ControlTimeline
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ; ---[ Constants ]------------------------------------------------------------
  #NUMBERWIDTH    = 45
  #BUTTONSIZE    = 20
  #BUTTONSPACING = 24
 
  #TIMER = 128
  Enumeration
    #PLAYALLFRAMES
    #PLAYREALTIME
    #PLAYCUSTOMRATE
  EndEnumeration

  ; ----------------------------------------------------------------------------
  ;  Object ( ControlTimeline_t )
  ; ----------------------------------------------------------------------------
  ;{
  Structure ControlTimeline_t Extends Control::Control_t
    ;datas
    imageID.i
    down.b
    
    ; timer
    timer.i
    window.i
    
    ; Nb Controls
    controls.i
    
    ; Control Icons
    c_firstframe.ControlIcon::IControlIcon
    c_previousframe.ControlIcon::IControlIcon
    c_playbackward.ControlIcon::IControlIcon
    c_stopplayback.ControlIcon::IControlIcon
    c_playforward.ControlIcon::IControlIcon
    c_nextframe.ControlIcon::IControlIcon
    c_lastframe.ControlIcon::IControlIcon
    c_playloop.ControlIcon::IControlIcon
    
    ; Control Numbers
    c_startframe.ControlNumber::IControlNumber
    c_endframe.ControlNumber::IControlNumber
    c_startrange.ControlNumber::IControlNumber
    c_endrange.ControlNumber::IControlNumber
    c_currentframe.ControlNumber::IControlNumber
    
    ; Control Combo
    c_playbackrate.ControlCombo::IControlCombo
    
    ; Control Management
    overchild .Control::IControl
    focuschild.Control::IControl
    Array children.Control::IControl(14)
          
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Interface
  ; ----------------------------------------------------------------------------
  Interface IControlTimeline Extends Control::IControl
  EndInterface
  
  ; ----------------------------------------------------------------------------
  ;  Declares
  ; ----------------------------------------------------------------------------
  Declare New(*object.Object::Object_t, windowID.i, x.i = 0, y.i = 0, width.i = 240, height.i = 60)
  Declare Delete(*Me.ControlTimeline_t)
  Declare OnEvent( *Me.ControlTimeline_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare Draw( *Me.ControlTimeline_t)
  Declare FirstFrame( *Me.ControlTimeline_t)
  Declare LastFrame( *Me.ControlTimeline_t)
  Declare NextFrame( *Me.ControlTimeline_t)
  Declare PreviousFrame( *Me.ControlTimeline_t)
  Declare PlayForward( *Me.ControlTimeline_t)
  Declare PlayBackward( *Me.ControlTimeline_t)
  Declare StartPlayback( *Me.ControlTimeline_t, forward.b)
  Declare StopPlayback( *Me.ControlTimeline_t)
  Declare PlayLoop( *Me.ControlTimeline_t)
  Declare SetStartFrame( *Me.ControlTimeline_t, frame.i)
  Declare SetEndFrame( *Me.ControlTimeline_t,frame.i)
  Declare SetStartRange( *Me.ControlTimeline_t, frame.i)
  Declare SetEndRange( *Me.ControlTimeline_t,frame.i)
  Declare SetCurrentFrame( *Me.ControlTimeline_t,frame)
  
  DataSection
    ControlTimelineVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete(); mandatory override 
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module ControlTimeline
  ; ============================================================================
  ;  IMPLEMENTATION ( Helpers )
  ; ============================================================================
  ;{
  
  
  Procedure.i hlpGetStep(r.i)
    Protected f.f = Round((r/10), #PB_Round_Nearest) 
    Protected m.i = Math::Max(Int(f),1)
    ProcedureReturn m
        
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpDrawFrames
  ; ----------------------------------------------------------------------------
  Procedure hlpDrawFrames( *Me.ControlTimeline_t )
    ;---[ Start Drawing ]-------------------------------------------------------
    StartDrawing( CanvasOutput(*Me\gadgetID) )
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Globals::#FONT_SUBMENU))
    ;SetFont(RAA_FONT_HEADER)
    
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected w.i = *Me\sizX ;- 2 * #Raa_Timeline_NumberWidth
    Protected l.i = 0;#Raa_Timeline_NumberWidth
    Protected h.i = *Me\sizY-30
    Protected r.i = Time::endframe - Time::startframe
    Protected s.f = w/r
    Protected f.i
    Protected m.i = hlpGetStep(r)
    
    ;---[ Draw Frames ]---------------------------------------------------------
    Box(l,0,w,h,UIColor::COLOR_MAIN_BG)
    Line(l,h-1,w,1,UIColor::COLOR_GROUP_FRAME)
    For f=Time::startframe To Time::endframe
      If f%m = 0
        Line(l+(f-Time::startframe)*s,h/2,1,h/2,UIColor::COLOR_LABEL)
        If Not f = Time::endframe
          DrawText(l+(f-Time::startframe)*s+2,0,Str(f),UIColor::COLOR_LABEL)
        EndIf
        
      ElseIf Mod(f, m/5) = 0
        Line(l+(f-Time::startframe)*s,h-6,1,6,UIColor::COLOR_LABEL)
      EndIf
    Next f
    
    ;---[ Draw Current Frame ]--------------------------------------------------
    Box(l+(Time::currentframe - Time::startframe)*s,0,3,h-1,RGB(255,100,50))
    
    
    ;---[ Draw Loop ]-----------------------------------------------------------
    If Time::loop
      Box(l+(Time::startloop - Time::startframe)*s-1,0,3,h-1,RGB(50,250,100))
      Box(l+(Time::endloop - Time::startframe)*s-1,0,3,h-1,RGB(50,250,100))
    EndIf
    
    ;---[ Stop Drawing ]-----------------------------------------------------------
    StopDrawing()
   
  
  EndProcedure
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  hlpDrawControls
  ; ----------------------------------------------------------------------------
  Procedure hlpDrawControls( *Me.ControlTimeline_t )
    Protected w.i = *Me\sizX/2 -128
    Protected h.i = *Me\sizY/5*3
    Protected t.i = *Me\sizY/5*2
    Protected i
    Protected  son  .Control::IControl
    Protected *son  .Control::Control_t
    
    
    ;---[ Start Drawing ]-------------------------------------------------------
    StartDrawing( CanvasOutput(*Me\gadgetID) )
    DrawingMode(#PB_2DDrawing_Default)
    Box(0,*Me\sizY-30,*Me\sizX,30,UIColor::COLOR_MAIN_BG)
    DrawingMode(#PB_2DDrawing_AlphaClip)
    
    ; ---[ Redraw Children ]----------------------------------------------------
    Protected ev_data.Control::EventTypeDatas_t
    For i=0 To *Me\controls-1
       son = *Me\children(i)
       *son = son
       If *son <> #Null
        ev_data\xoff = *son\posX
        ev_data\yoff = *son\posY
        Debug  *son\name + ","+*son\class\name
        son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
       EndIf
     Next
     
     ;---[ Stop Drawing ]-----------------------------------------------------------
    StopDrawing()
    
  EndProcedure
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  hlpDrawPickingTags
  ; ----------------------------------------------------------------------------
  Procedure hlpDrawPickingTags( *Me.ControlTimeline_t )
    Protected *son  .Control::Control_t
    Protected i
    ResizeImage(*Me\imageID,*Me\sizX,*Me\sizY)
    ; ...[ Tag Picking Surface ]................................................
    StartDrawing( ImageOutput( *Me\imageID ) )
    ;StartDrawing(CanvasOutput(*Me\gadgetID))
    ;Box( 0, 0, *Me\sizX, *Me\sizY, RGB($00,$00,$00) )
    For i=0 To *Me\controls - 1
      *son = *Me\children(i)
      Box( *son\posX, *son\posY, *son\sizX, *son\sizY, RGB(i+1,$0,$0) )
    Next
    StopDrawing()
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpDraw
  ; ----------------------------------------------------------------------------
  Procedure hlpDraw( *Me.ControlTimeline_t )
  
    ;---[ Draw All]----------------------------------------------------------------
    hlpDrawControls( *Me )
    hlpDrawFrames( *Me )
    
    ;---[ Draw Picking Tags ]---------------------------------------------------
    hlpDrawPickingTags( *Me)
  EndProcedure
  
  ; ---[ Timer Event]-----------------------------------------------------------
  Procedure OnTimer(*Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play = #True
      If Time::forward
        NextFrame(*Me)
      Else
        PreviousFrame(*Me)
      EndIf
  
      PostEvent(Globals::#EVENT_TIME_CHANGED,EventWindow(),*Me\object,#Null,@*Me\name)
      
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  hlpResize
  ; ----------------------------------------------------------------------------
  Procedure.i hlpResize( *Me.ControlTimeline_t,x.i,y.i,width.i, height.i)
    
    ResizeGadget(*Me\gadgetID,0,0,width,height)
    ResizeImage(*Me\imageID,*Me\sizX,*Me\sizY)
  
    *Me\posX = x
    *Me\posY = y
    
    *Me\sizX = width
    *Me\sizY = height
    
    Protected t = height-26
    Protected center.i = width/2
    Control::Resize(*Me\c_endframe,width-90,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_endrange,width-45,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_startrange,0,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_startframe,45,t,#PB_Ignore,#PB_Ignore)
    
    Protected w = *Me\sizX/2-128
    
    
    Control::Resize(*Me\c_firstframe,w,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_previousframe,w+#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playbackward,w+2*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_stopplayback,w+3*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playforward,w+4*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_nextframe,w+5*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_lastframe,w+6*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playloop,w+7*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_currentframe,w+8*#BUTTONSPACING,t,#PB_Ignore,#PB_Ignore)
    
    Control::Resize(*Me\c_playbackrate,w-140,t,#PB_Ignore,#PB_Ignore)
  
    
  ;    ; ---[ Number Controls ]------------------------------------------------------
  ;   *Me\c_startframe = ControlNumber::New("StartFrame",Time::startframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,0,6,45,30)
  ;   *Me\c_endframe   = ControlNumber::New("EndFrame",Time::endframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX-45,6,45,30)
  ;   *Me\c_startrange = ControlNumber::New("StartRange",Time::startrange,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,0,36,45,30)
  ;   *Me\c_endrange   = ControlNumber::New("EndRange",Time::endrange,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX-45,36,45,30)
  ;   *Me\c_currentframe = ControlNumber::New("CurrentFrame",Time::currentframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX/4*3,36,45,30)
    
    ProcedureReturn(#True)
    
  EndProcedure
  
  ;}
  
  ; ----------------------------------------------------------------------------
  ;  Draw
  ; ----------------------------------------------------------------------------
  Procedure Draw(*Me.ControlTimeline_t)
    hlpDraw(*Me)  
  EndProcedure
  
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  ;{
  ; ---[ OnEvent ]--------------------------------------------------------------
  Procedure.i OnEvent( *Me.ControlTimeline_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected Me.IControlTimeline = *Me
    Protected  ev_data.Control::EventTypeDatas_t
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    Protected *overchild.Control::Control_t
    
    ; ---[ Dispatch Event ]-----------------------------------------------------
    Select ev_code
        
      ; ------------------------------------------------------------------------
      ;  Timer
      ; ------------------------------------------------------------------------
      Case #PB_Event_Timer
        ; ...[ Update & Check Dirty ]...........................................
        OnTimer(*Me)
        ; ...[ Redraw Timeline ]...............................................
        hlpDrawFrames( *Me )
        
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
                
      ; ------------------------------------------------------------------------
      ;  Resize
      ; ------------------------------------------------------------------------
      Case #PB_Event_SizeWindow
        ;CHECK_PTR1_BOO(*ev_data);
        ; ...[ Update & Check Dirty ]...........................................
        Protected w = GadgetWidth(*Me\gadgetID)
        Protected h = GadgetHeight(*Me\gadgetID)
        ;If #True = hlpResize( *Me,*ev_data\width,*ev_data\height)
        If #True = hlpResize( *Me,*Me\posX,*Me\posY,w,h)
          ; ...[ Redraw Timeline ]...............................................
          hlpDraw( *Me )
        EndIf
        ; ...[ Processed ]......................................................
        ProcedureReturn( #True )
        
        
        CompilerIf #PB_Compiler_Version < 560
          Case Control::#PB_EventType_Resize
        CompilerElse
          Case #PB_EventType_Resize
        CompilerEndIf
          ;CHECK_PTR1_BOO(*ev_data);
          ; ...[ Update & Check Dirty ]...........................................
          w = GadgetWidth(*Me\gadgetID)
          h = GadgetHeight(*Me\gadgetID)
          ;If #True = hlpResize( *Me,*ev_data\width,*ev_data\height)
          If #True = hlpResize( *Me,*Me\posX,*Me\posY,w,h)
            ; ...[ Redraw Timeline ]...............................................
            hlpDraw( *Me )
          EndIf
          ; ...[ Processed ]......................................................
          ProcedureReturn( #True )
            
        ; ------------------------------------------------------------------------
        ;  DrawChild
        ; ------------------------------------------------------------------------
        Case Control::#PB_EventType_DrawChild
          *son.Control::Control_t = *ev_data
          son.Control::IControl    = *son
          ev_data\xoff    = *son\posX
          ev_data\yoff    = *son\posY
          StartDrawing( CanvasOutput(*Me\gadgetID) )
          DrawingMode(#PB_2DDrawing_AlphaBlend)
            Box( *son\posX, *son\posY, *son\sizX, *son\sizY, RAA_COLORA_MAIN_BG )
            son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
          StopDrawing()
          
        ; ------------------------------------------------------------------------
        ;  Focus
        ; ------------------------------------------------------------------------
        Case #PB_EventType_Focus
          
          
        ; ------------------------------------------------------------------------
        ;  ChildFocused
        ; ------------------------------------------------------------------------
        Case Control::#PB_EventType_ChildFocused
          *Me\focuschild = *ev_data
          
        ; ------------------------------------------------------------------------
        ;  ChildDeFocused
        ; ------------------------------------------------------------------------
        Case Control::#PB_EventType_ChildDeFocused
          *Me\focuschild = #Null
          
        ; ------------------------------------------------------------------------
        ;  ChildCursor
        ; ------------------------------------------------------------------------
        Case Control::#PB_EventType_ChildCursor
          SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data )
          
        ; ------------------------------------------------------------------------
        ;  LostFocus
        ; ------------------------------------------------------------------------
        Case #PB_EventType_LostFocus
          If *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
            *Me\focuschild = #Null
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  MouseMove
        ; ------------------------------------------------------------------------
        Case #PB_EventType_MouseMove
          Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX )
          Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY )
          xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
          ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
          StartDrawing( ImageOutput(*Me\imageID) )
            Protected idx = Red(Point(xm,ym)) - 1
          StopDrawing()
          If idx < 0 And ( *Me\overchild <> #Null ) And  Not *Me\down
            *Me\overchild\OnEvent(#PB_EventType_MouseLeave)
            *Me\overchild = #Null
            SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )
          ElseIf idx >= 0
            If idx >= *Me\controls
              ProcedureReturn
            EndIf
            
            Protected ctl.Control::IControl = *Me\children( idx )
            If ( ctl <> *Me\overchild ) And  Not *Me\down
              If *Me\overchild <> #Null
                *Me\overchild\OnEvent(#PB_EventType_MouseLeave)
                SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )
              EndIf
              ctl\OnEvent(#PB_EventType_MouseEnter)
              If Not *Me\down
                *Me\overchild = ctl
              EndIf
            ElseIf *Me\overchild
              *overchild = *Me\overchild
              ev_data\x    = xm - *overchild\posX
              ev_data\y    = ym - *overchild\posY
              *Me\overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
            EndIf
          ElseIf *Me\overchild
            *overchild = *Me\overchild
            ev_data\x    = xm - *overchild\posX
            ev_data\y    = ym - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  LeftButtonDown
        ; ------------------------------------------------------------------------
        Case #PB_EventType_LeftButtonDown
          *Me\down = #True
          If *Me\overchild
            If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
              *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
            EndIf
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_LeftButtonDown,@ev_data)
          ElseIf *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  LeftButtonUp
        ; ------------------------------------------------------------------------
        Case #PB_EventType_LeftButtonUp
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_LeftButtonUp,@ev_data)
            
            ; Callbacks
            Select *overchild\name
              Case "PlayForward"
                PlayForward(*Me)
              Case "StopPlayback"
                StopPlayback(*Me)
              Case "PlayBackward"
                PlayBackward(*Me)
              Case "FirstFrame"
                FirstFrame(*Me)
              Case "LastFrame"
                LastFrame(*Me)
              Case "PreviousFrame"
                PreviousFrame(*Me)
              Case "NextFrame"
                NextFrame(*Me)
              Case "PlayLoop"
                PlayLoop(*Me)
            EndSelect
          EndIf
          *Me\down = #False
          
        ; ------------------------------------------------------------------------
        ;  LeftDoubleClick
        ; ------------------------------------------------------------------------
        Case #PB_EventType_LeftDoubleClick
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_LeftDoubleClick,@ev_data)
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  RightButtonDown
        ; ------------------------------------------------------------------------
        Case #PB_EventType_RightButtonDown
          *Me\down = #True
          If *Me\overchild
            If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
              *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
            EndIf
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_RightButtonDown,@ev_data)
          ElseIf *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  RightButtonUp
        ; ------------------------------------------------------------------------
        Case #PB_EventType_RightButtonUp
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
          EndIf
          *Me\down = #False
          
        ; ------------------------------------------------------------------------
        ;  Input
        ; ------------------------------------------------------------------------
        Case #PB_EventType_Input
          ; ---[ Do We Have A Focused Child ? ]-----------------------------------
          If *Me\focuschild
            ; ...[ Retrieve Character ]...........................................
            ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input))
            ; ...[ Send Character To Focused Child ]..............................
            *Me\focuschild\OnEvent(#PB_EventType_Input,@ev_data)
          EndIf
          
        ; ------------------------------------------------------------------------
        ;  KeyDown
        ; ------------------------------------------------------------------------
        Case #PB_EventType_KeyDown
          Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Control Timeline Key Down!!!"
          Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Focus Child : "+Str(*Me\focuschild)
          ; ---[ Do We Have A Focused Child ? ]-----------------------------------
          If *Me\focuschild
            ; ...[ Retrieve Key ].................................................
            ev_data\key   = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key      )
            ev_data\modif = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
            
            ; ...[ Send Key To Focused Child ]....................................
            *Me\focuschild\OnEvent(#PB_EventType_KeyDown,@ev_data)
          EndIf
        
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_COPY
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_COPY
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_COPY,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_CUT
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_CUT
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_CUT,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_PASTE
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_PASTE
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_PASTE,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_UNDO
      ; ------------------------------------------------------------------------
      Case Globals::#SHORTCUT_UNDO
        ; ---[ Do We Have A Focused Child ? ]-----------------------------------
        If *Me\focuschild
          ; ...[ Send Key To Focused Child ]....................................
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_UNDO,#Null)
        EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_NEXT
      ; ------------------------------------------------------------------------
  ;   Case Globals::#SHORTCUT_NEXT
  ;     ; ---[ Do We Have A Focused Child ? ]-------------------------------------
  ;     If *Me\focuschild
  ;       ; ---[ Go To Next Item ]------------------------------------------------
  ;       OControlGroup_hlpNextItem( *Me ) 
  ;     EndIf
        
      ; ------------------------------------------------------------------------
      ;  SHORTCUT_PREVIOUS
      ; ------------------------------------------------------------------------
  ;     Case Globals::#SHORTCUT_PREVIOUS
  ;         Debug "Previous Item called"
  ;         ; ---[ Do We Have A Focused Child ? ]-----------------------------------
  ;         If *Me\focuschild
  ;           ; go to previous child
  ;           Debug "previous child per favor..."
  ;         EndIf
               
               
        
      ;Case #PB_EventType_KeyUp
      ;Case #PB_EventType_MiddleButtonDown
      ;Case #PB_EventType_MiddleButtonUp
      ;Case #PB_EventType_MouseWheel
      ;Case #PB_EventType_PopupMenu
        ;Debug ">> PopupMenu"
      ;Case #PB_EventType_PopupWindow
        ;Debug ">> PopupWindow"
        
    EndSelect
    
    ; ---[ Process Default ]----------------------------------------------------
    ProcedureReturn( #False )
    
  EndProcedure
  ;}
  
  ; ; ---[ Timer Callback]----------------------------------------------------
  ; Procedure CallbackProc(*t.CControlTimeline)
  ;   Time::currentframe + 1
  ;   If Time::currentframe>100 : Time::currentframe = 1 : EndIf
  ;   *t\Event(#PB_Event_Timer)
  ; EndProcedure
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlTimeline )
  ; ============================================================================
  ;{
  
  ; ---[ Go to First Frame ]----------------------------------------------------
  Procedure FirstFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Protected *ico.ControlIcon::ControlIcon_t
    ; ---[ Stop Playing ]-------------------------------------------------------
    StopPlayback(*Me)
    
    ; ---[ Set Current Frame Value ]--------------------------------------------
    If Time::loop
      Time::currentframe = Time::startloop
    Else
      Time::currentframe  = Time::startframe
    EndIf
    
    ; ---[ Update Current Frame Control ]---------------------------------------
    SetCurrentFrame(*Me,Time::currentframe)
    
    ; ---[ Redraw Frames ]-----------------------------------------------------
    hlpDrawFrames( *Me )
  EndProcedure
  
  ; ---[ Go to Last Frame ]-----------------------------------------------------
  Procedure LastFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    ; ---[ Stop Playing ]-------------------------------------------------------
    StopPlayback(*Me)
  
    ; ---[ Set Current Frame Value ]--------------------------------------------
    If Time::loop
      Time::currentframe = Time::endloop
    Else
      Time::currentframe  = Time::endframe
    EndIf
    Time::play = #False
    
    ; ---[ Update Current Frame Control ]---------------------------------------
    SetCurrentFrame(*Me,Time::currentframe)
  
    ; ---[ Redraw Frames ]-----------------------------------------------------
    hlpDrawFrames( *Me )
  EndProcedure
  
  ; ---[ Go to Next Frame ]-----------------------------------------------------
  Procedure NextFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::currentframe + 1
    If Time::loop
      ; ---[ Loop Playback ]----------------------------------------------------
      If Time::currentframe<Time::startloop Or Time::currentframe>Time::endloop
        Time::currentframe = Time::startloop
      EndIf
    Else 
      ; ---[ Stop Playback if arrived to last frame ]---------------------------
      If Time::currentframe>Time::endframe
        Time::currentframe = Time::endframe
        StopPlayback(*Me)
      EndIf
    EndIf
    
    ; ---[ Update Current Frame Control ]---------------------------------------
    If Not Time::play
      SetCurrentFrame(*Me,Time::currentframe)
    EndIf
    
    ; ---[ Redraw Frames ]-----------------------------------------------------
    hlpDrawFrames( *Me )
  EndProcedure
  
  ; ---[ Go to Previous Frame ]-------------------------------------------------
  Procedure PreviousFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::currentframe - 1
    If Time::loop
      ; ---[ Loop Playback ]----------------------------------------------------
      If Time::currentframe>Time::endloop Or Time::currentframe<Time::startloop
        Time::currentframe = Time::endloop
      EndIf
    Else 
      ; ---[ Stop Playback if arrived to first frame ]--------------------------
      If Time::currentframe<Time::startframe
        Time::currentframe = Time::startframe
        StopPlayback(*Me)
      EndIf
    EndIf
    
    ; ---[ Update Current Frame Control ]---------------------------------------
    If Not Time::play
      SetCurrentFrame(*Me,Time::currentframe)
    EndIf
    
    ; ---[ Redraw Frames ]-----------------------------------------------------
    hlpDrawFrames( *Me )
  EndProcedure
  
  ; ---[ Play Forward ]---------------------------------------------------------
  Procedure PlayForward( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      StartPlayback(*Me,#True)
    Else
      ;--- [ Stop Playback / Delete Timer Event ]-------------------------------
      If Not Time::forward
        StopPlayback(*Me)
        PlayForward(*Me)
      Else
        StopPlayback(*Me)
      EndIf
    EndIf   
  EndProcedure
  
  ; ---[ Play Backward ]---------------------------------------------------------
  Procedure PlayBackward( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      ;--- [ Start Playback / Create Timer Event ]------------------------------
      StartPlayback(*Me,#False)
    Else
      ;--- [ Stop Playback / Delete Timer Event ]-------------------------------
      If Time::forward
        StopPlayback(*Me)
        PlayBackward(*Me)
      Else
        StopPlayback(*Me)
      EndIf
    EndIf   
  EndProcedure
  
  ; ---[ Start Playback ]-------------------------------------------------------
  Procedure StartPlayback( *Me.ControlTimeline_t, forward.b)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      ;--- [ Start Playback / Create Timer Event ]------------------------------
      Time::play = #True
      Time::forward = forward
      *Me\timer = AddWindowTimer(*Me\window, #TIMER, 1000/Time::framerate)
  
      If forward
        NextFrame(*Me)
      Else
        PreviousFrame(*Me)
      EndIf
    Else
      ;--- [ Stop Playback / Delete Timer Event ]-------------------------------
      StopPlayback(*Me)
    EndIf   
  EndProcedure
  
  ; ---[ Stop Playback ]--------------------------------------------------------
  Procedure StopPlayback( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play
      Time::play = #False
      Protected *ico.ControlIcon::ControlIcon_t
        If Time::forward
          *ico = *Me\c_playforward
          *ico\value = 1
          Control::Invalidate(*Me\c_playforward)
        Else
          *ico = *Me\c_playbackward
          *ico\value = 1
          Control::Invalidate(*Me\c_playbackward)
        EndIf
        If *Me\timer <> #Null :
  ;         raaDeleteTimer(*Me\timer) : EndIf
          RemoveWindowTimer(*Me\window,#TIMER)
          *Me\timer = #Null
        EndIf
        
      EndIf
      SetCurrentFrame(*Me,Time::currentframe)
  EndProcedure
  
  ; ---[ Play Loop ]--------------------------------------------------------
  Procedure PlayLoop( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::loop = 1 - Time::loop
    ; ---[ Update Current Frame if necessary ]---------------------------------
    SetCurrentFrame(*Me,Time::currentframe)
    ; ---[ Redraw Frames ]-----------------------------------------------------
    hlpDrawFrames( *Me )
  EndProcedure
  
  
  ; ---[ Set Start Frame ]------------------------------------------------------
  Procedure SetStartFrame( *Me.ControlTimeline_t, frame.i)
    If frame > Time::endframe
      Time::startframe = Time::endframe-1
    Else
      Time::startframe = frame
    EndIf
  EndProcedure
  
  ; ---[ Set End Frame ]--------------------------------------------------------
  Procedure SetEndFrame( *Me.ControlTimeline_t,frame.i)
    If frame <= Time::startframe
      Time::endframe = Time::startframe+1
    Else
      Time::endframe = frame
    EndIf  
  
  EndProcedure
  
  ; ---[ Set Start Range ]------------------------------------------------------
  Procedure SetStartRange( *Me.ControlTimeline_t, frame.i)
    If frame > Time::endframe
      Time::startrange = Time::endframe-1
      
    Else
      Time::startrange= frame
    EndIf
    Time::startloop = Time::startrange
  EndProcedure
  
  ; ---[ Set End Frame ]--------------------------------------------------------
  Procedure SetEndRange( *Me.ControlTimeline_t,frame.i)
    If frame <= Time::startframe
      Time::endrange = Time::startframe+1
    Else
      Time::endrange = frame
    EndIf  
    Time::endloop = Time::endrange
  EndProcedure
  
  ; ---[ Set Current Frame ]----------------------------------------------------
  Procedure SetCurrentFrame( *Me.ControlTimeline_t,frame)
    If Time::loop
      If frame < Time::startloop
        Time::currentframe = Time::startloop
      ElseIf frame > Time::endloop
        Time::currentframe = Time::endloop
      Else
        Time::currentframe = frame
      EndIf  
    Else
      If frame < Time::startframe
        Time::currentframe = Time::startframe
      ElseIf frame > Time::endframe
        Time::currentframe = Time::endframe
      Else
        Time::currentframe = frame
      EndIf  
    EndIf
    
    If Not Time::play
      ControlNumber::SetValue(*Me\c_currentframe,Str(Time::currentframe))
    EndIf
  EndProcedure
 
  
  ; ---[ Append Control ]---------------------------------------------------------------
  Procedure.i Append( *Me.ControlTimeline_t, *ctl.Control::Control_t )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not( *ctl ) : ProcedureReturn : EndIf
  
    ; ---[ Local Variables ]----------------------------------------------------
    Protected ctl.Control::IControl = *ctl
    Protected parent.Control::IControl = *Me
    Protected cid.i = *Me\controls
    
    ; ---[ Set Timeline As Control Parent ]-------------------------------------
    *ctl\parent = parent
    
    ; ---[ Append Control ]-----------------------------------------------------
    *Me\children(cid) = ctl
    
    ; ---[ One More Control ]---------------------------------------------------
    *Me\controls + 1

    ; ---[ Return The Added Control ]-------------------------------------------
    ProcedureReturn( ctl )
  
  EndProcedure
  
  ; ---[ On Message ]----------------------------------------------------
  Procedure OnMessage( id.i, *up)
    Protected *sig.Signal::Signal_t = *up
    Protected *c.ControlNumber::ControlNumber_t = *sig\snd_inst
    Protected *t.ControlTimeline::ControlTimeline_t = *c\parent
    Protected v.i = *c\value_n
  
    Select *c\name
      Case "CurrentFrame"
        SetCurrentFrame(*t,v)
      Case "StartFrame"
        SetStartFrame(*t,v)
      Case "EndFrame"
        SetEndFrame(*t,v)
      Case "StartRange"
        SetStartRange(*t,v)
      Case "EndRange"
        SetEndRange(*t,v)
    EndSelect
    hlpDrawFrames( *t )
  EndProcedure

  
  ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlTimeline_t )
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected i     .i = 0
    Protected iBound.i = 4
    
    ; ---[ Destroy Children Controls ]------------------------------------------
    Protected child.Control::IControl
    For i=0 To iBound
      child = *Me\children()
      child\Delete()
    Next
    
    ; ---[ Release Arrays ]-----------------------------------------------------
    FreeArray( *Me\children() )
    
    ; ---[ Free Image ]---------------------------------------------------------
    FreeImage(*Me\imageID)
    
    ; ---[ Free Gadget ]--------------------------------------------------------
    FreeGadget(*Me\gadgetID)
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    FreeMemory( *Me )
    
  EndProcedure
  
  
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ;{
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New(*object.Object::Object_t,windowID.i, x.i = 0, y.i = 0, width.i = 240, height.i = 60)
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlTimeline_t = AllocateMemory( SizeOf(ControlTimeline_t) )
    
;     *Me\VT = ?ControlTimelineVT
;     *Me\classname = "CONTROLTIMELINE"
    Object::INI(ControlTimeline)
    *Me\object = *object
    
    *Me\window = windowID
    ; ---[ Minimum Width ]------------------------------------------------------
    If width < 50 : width = 50 : EndIf
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type       = #PB_GadgetType_Canvas
    *Me\name       = "Timeline"
    *Me\gadgetID   = CanvasGadget( #PB_Any, x, y, width, height, #PB_Canvas_Keyboard )
    *Me\imageID    = CreateImage( #PB_Any, width, height )
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY      = height
    
    *Me\controls = 0
    
    ; ---[ Init Structure ]-----------------------------------------------------
    InitializeStructure( *Me, ControlTimeline_t ) ; Arrays
    
    ; ---[ Number Controls ]------------------------------------------------------
    *Me\c_startframe = ControlNumber::New(*Me,"StartFrame",Time::startframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,0,6,45,30)
    *Me\c_endframe   = ControlNumber::New(*Me,"EndFrame",Time::endframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX-45,6,45,30)
    *Me\c_startrange = ControlNumber::New(*Me,"StartRange",Time::startrange,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,0,36,45,30)
    *Me\c_endrange   = ControlNumber::New(*Me,"EndRange",Time::endrange,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX-45,36,45,30)
    *Me\c_currentframe = ControlNumber::New(*Me,"CurrentFrame",Time::currentframe,ControlNumber::#NUMBER_INTEGER|ControlNumber::#NUMBER_NOSLIDER,Math::#S32_MIN,Math::#S32_MAX,1,100,*Me\sizX/4*3,36,45,30)
    
    Append(*Me,*Me\c_startframe)
    Append(*Me,*Me\c_endframe )
    Append(*Me,*Me\c_startrange)
    Append(*Me,*Me\c_endrange)
    Append(*Me,*Me\c_currentframe)
    
    
    ; ---[ Combo Controls ]------------------------------------------------------
;     *Me\c_playbackrate = ControlCombo::New(*Me,"Playback","Playback",0,80,30,120,30)
    Append(*Me,*Me\c_playbackrate)
    
    ; ---[ Init Icon Buttons ]-------------------------------------------------
    Protected w = *Me\sizX/2-128
    Protected t = height/5*2+2
    
    *Me\c_firstframe =    ControlIcon::New(*Me,"FirstFrame"    ,ControlIcon::#Icon_First   ,0                 ,#False,w,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_previousframe = ControlIcon::New(*Me,"PreviousFrame" ,ControlIcon::#Icon_Previous,0                 ,#False,w+32,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_playbackward =  ControlIcon::New(*Me,"PlayBackward"  ,ControlIcon::#Icon_Back    ,#PB_Button_Toggle ,#False,w+64,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_stopplayback =  ControlIcon::New(*Me,"StopPlayback"  ,ControlIcon::#Icon_Stop    ,0                 ,#False,w+96,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_playforward =   ControlIcon::New(*Me,"PlayForward"   ,ControlIcon::#Icon_Play    ,#PB_Button_Toggle ,#False,w+128,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_nextframe =     ControlIcon::New(*Me,"NextFrame"     ,ControlIcon::#Icon_Next    ,0                 ,#False,w+160,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_lastframe =     ControlIcon::New(*Me,"LastFrame"     ,ControlIcon::#Icon_Last    ,0                 ,#False,w+192,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    *Me\c_playloop =      ControlIcon::New(*Me,"PlayLoop"      ,ControlIcon::#Icon_Loop    ,#PB_Button_Toggle ,#False,w+224,t,ControlTimeline::#ButtonSize,ControlTimeline::#ButtonSize)
    
    Append(*Me,*Me\c_firstframe)
    Append(*Me,*Me\c_previousframe)
    Append(*Me,*Me\c_playbackward)
    Append(*Me,*Me\c_stopplayback)
    Append(*Me,*Me\c_playforward)
    Append(*Me,*Me\c_nextframe)
    Append(*Me,*Me\c_lastframe)
    Append(*Me,*Me\c_playloop)
    
    Protected *ctrl.Control::Control_t = *Me\c_currentframe
    Object::SignalConnect(*Me,*ctrl\slot,0)
    *ctrl.Control::Control_t = *Me\c_currentframe
    Object::SignalConnect(*Me,*ctrl\slot,1)
    *ctrl.Control::Control_t = *Me\c_startframe
    Object::SignalConnect(*Me,*ctrl\slot,2)
    *ctrl.Control::Control_t = *Me\c_endframe
    Object::SignalConnect(*Me,*ctrl\slot,3)
    *ctrl.Control::Control_t = *Me\c_startrange
    Object::SignalConnect(*Me,*ctrl\slot,4)
     *ctrl.Control::Control_t = *Me\c_endrange
    Object::SignalConnect(*Me,*ctrl\slot,5)
  
    ; ---[ Draw ]---------------------------------------------------------------
    hlpDrawPickingTags(*Me)
    hlpDraw( *Me )
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlTimeline )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 456
; FirstLine = 448
; Folding = ------
; EnableXP