; ============================================================================
;  GUI Timeline Control
; ============================================================================
XIncludeFile "../core/Time.pbi"
XIncludeFile "Icon.pbi"
XIncludeFile "Number.pbi"
XIncludeFile "Enum.pbi"

DeclareModule ControlTimeline

  #NUMBER_WIDTH    = 45
  #BUTTON_SIZE    = 20
  #BUTTON_SPACING = 24
 
  #TIMER = 128
  Enumeration
    #PLAY_ALL_FRAMES
    #PLAY_REAL_TIME
    #PLAY_CUSTOM_RATE
  EndEnumeration

  Structure ControlTimeline_t Extends Control::Control_t
    imageID.i
    down.b
    
    *timer.Time::Timeable_t
    window.i
    
    controls.i
    
    c_firstframe.ControlIcon::IControlIcon
    c_previousframe.ControlIcon::IControlIcon
    c_playbackward.ControlIcon::IControlIcon
    c_stopplayback.ControlIcon::IControlIcon
    c_playforward.ControlIcon::IControlIcon
    c_nextframe.ControlIcon::IControlIcon
    c_lastframe.ControlIcon::IControlIcon
    c_playloop.ControlIcon::IControlIcon
    
    c_startframe.ControlNumber::IControlNumber
    c_endframe.ControlNumber::IControlNumber
    c_startrange.ControlNumber::IControlNumber
    c_endrange.ControlNumber::IControlNumber
    c_currentframe.ControlNumber::IControlNumber
    
    c_playbackrate.ControlEnum::IControlEnum
    
    overchild .Control::IControl
    focuschild.Control::IControl
    Array children.Control::IControl(14)
          
  EndStructure
  
  Interface IControlTimeline Extends Control::IControl
    SetCurrentFrame(v.f)
    SetStartFrame(v.f)
    SetEndFrame(v.f)
    SetStartRange(v.f)
    SetEndRange(v.f)
  EndInterface
  
  Declare New( windowID.i, x.i = 0, y.i = 0, width.i = 240, height.i = 60)
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
  Declare OnTimer(*Me.ControlTimeline_t)
  DataSection
    ControlTimelineVT:
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    Data.i @SetCurrentFrame()
    Data.i @SetStartFrame()
    Data.i @SetEndFrame()
    Data.i @SetStartRange()
    Data.i @SetEndRange()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module ControlTimeline  

  Procedure.i hlpGetStep(r.i)
    Protected f.f = Round((r/10), #PB_Round_Nearest) 
    Protected m.i = Math::Max(Int(f),1)
    ProcedureReturn m
  EndProcedure

  Procedure hlpDrawFrames( *Me.ControlTimeline_t )
    StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
    VectorFont(FontID(Globals::#FONT_DEFAULT), Globals::#FONT_SIZE_TEXT)    
    
    Protected w.i = *Me\sizX 
    Protected l.i = 0
    Protected h.i = *Me\sizY-30
    Protected r.i = Time::endframe - Time::startframe
    Protected s.f = w/r
    Protected f.i
    Protected m.i = hlpGetStep(r)
    
    AddPathBox(l,0,w,h)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    
    MovePathCursor(l,h-1)
    AddPathLine(w,1, #PB_Path_Relative)
    
    For f=Time::startframe To Time::endframe
      If f%m = 0
        MovePathCursor(l+(f-Time::startframe)*s,h/5)
        AddPathLine(0,4*h/5, #PB_Path_Relative) 
      ElseIf Mod(f, m/5) = 0
        MovePathCursor(l+(f-Time::startframe)*s,h-8)
        AddPathLine(0,8, #PB_Path_Relative)
      EndIf
    Next f
    
    VectorSourceColor(UIColor::COLOR_LINE_DIMMED)
    StrokePath(1)
    
    AddPathBox(l+(Time::currentframe - Time::startframe)*s,0,3,h-1)
    VectorSourceColor(RGBA(255,100,50,128))
    FillPath()
    
    If Time::loop
      AddPathBox(l+(Time::startloop - Time::startframe)*s-1,0,3,h-1)
      AddPathBox(l+(Time::endloop - Time::startframe)*s-1,0,3,h-1)
      VectorSourceColor(RGBA(50,250,100,255))
      FillPath()
    EndIf
    
    StopVectorDrawing()
  EndProcedure
  
  Procedure hlpDrawControls( *Me.ControlTimeline_t )
    Protected w.i = *Me\sizX/2 -128
    Protected h.i = *Me\sizY/5*3
    Protected t.i = *Me\sizY/5*2
    Protected i
    Protected  son  .Control::IControl
    Protected *son  .Control::Control_t
    
    StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
    AddPathBox(0,*Me\sizY-30,*Me\sizX,30)
    VectorSourceColor(UIColor::COLOR_MAIN_BG)
    FillPath()
    
    Protected ev_data.Control::EventTypeDatas_t
    For i=0 To *Me\controls-1
       son = *Me\children(i)
       *son = son
       If *son <> #Null
        ev_data\xoff =*son\posX
        ev_data\yoff = *son\posY
        son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
       EndIf
     Next
     
    StopVectorDrawing()
    
  EndProcedure
  
  Procedure hlpDrawPickImage( *Me.ControlTimeline_t )
    Protected *son  .Control::Control_t
    Protected i

    StartVectorDrawing( ImageVectorOutput( *Me\imageID ) )
    AddPathBox(0,0,*Me\sizX, *Me\sizY)
    VectorSourceColor(RGBA(0,0,0,255) )
    FillPath()
    
    For i=0 To *Me\controls - 1
      *son = *Me\children(i)
      AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
      VectorSourceColor(RGBA(i+1,0,0,255) )
      FillPath()
    Next
    StopVectorDrawing()
  EndProcedure
  
  Procedure hlpDraw( *Me.ControlTimeline_t )
    hlpDrawControls( *Me )
    hlpDrawFrames( *Me )
  EndProcedure
  
  Procedure OnTimer(*Me.Time::Timeable_t)
    Define *timeline.ControlTimeline_t = *Me\obj
    Repeat
      Delay(*Me\delay)
      If Time::play = #True
        If Time::forward
          NextFrame(*timeline)
        Else
          PreviousFrame(*timeline)
        EndIf
      EndIf
      
      PostEvent(Globals::#EVENT_TIME_CHANGED,EventWindow(),*timeline,#Null,@*timeline\name)  
      
    ForEver
  EndProcedure
  
  Procedure.i hlpResize( *Me.ControlTimeline_t,x.i,y.i,width.i, height.i)
    
    *Me\posX = x
    *Me\posY = y
    
    *Me\sizX = width
    *Me\sizY = height
    
    ResizeGadget(*Me\gadgetID,*Me\posX,*Me\posY,*Me\sizX,*Me\sizY)
    ResizeImage(*Me\imageID,*Me\sizX,*Me\sizY)

    Protected t = height-26
    Protected center.i = width/2
    Control::Resize(*Me\c_endframe,width-90,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_endrange,width-45,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_startrange,0,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_startframe,45,t,#PB_Ignore,#PB_Ignore)
    
    Protected w = *Me\sizX/2-128
    
    
    Control::Resize(*Me\c_firstframe,w,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_previousframe,w+#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playbackward,w+2*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_stopplayback,w+3*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playforward,w+4*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_nextframe,w+5*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_lastframe,w+6*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_playloop,w+7*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    Control::Resize(*Me\c_currentframe,w+8*#BUTTON_SPACING,t,#PB_Ignore,#PB_Ignore)
    
    Control::Resize(*Me\c_playbackrate,w-140,t,#PB_Ignore,#PB_Ignore)
    
    hlpDrawPickImage(*Me)
  
    ProcedureReturn(#True)
    
  EndProcedure
  
  Procedure Draw(*Me.ControlTimeline_t)
    hlpDraw(*Me)  
  EndProcedure
  
  
  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  Procedure.i OnEvent( *Me.ControlTimeline_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
    Protected Me.IControlTimeline = *Me
    Protected  ev_data.Control::EventTypeDatas_t
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    Protected *overchild.Control::Control_t
    
    Select ev_code
      Case #PB_Event_Timer
        OnTimer(*Me)
        hlpDrawFrames( *Me )
        
        ProcedureReturn( #True )

      Case #PB_Event_SizeWindow
        If #True = hlpResize( *Me,*ev_data\x, *ev_data\y, *ev_data\width,*ev_data\height)
          hlpDraw( *Me )
        EndIf
        ProcedureReturn( #True )
        
        Case #PB_EventType_Resize
          w = GadgetWidth(*Me\gadgetID)
          h = GadgetHeight(*Me\gadgetID)
          If #True = hlpResize( *Me,*Me\posX,*Me\posY,w,h)
            hlpDraw( *Me )
          EndIf
          ProcedureReturn( #True )
            
        Case Control::#PB_EventType_DrawChild
          *son.Control::Control_t = *ev_data\datas
          son.Control::IControl    = *son
          ev_data\xoff    = *son\posX
          ev_data\yoff    = *son\posY
          StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
          AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
          VectorSourceColor(UIColor::COLOR_MAIN_BG )
          FillPath()
          son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
          StopVectorDrawing()
          
        Case #PB_EventType_Focus
          
        Case Control::#PB_EventType_ChildFocused
          *Me\focuschild = *ev_data
          
        Case Control::#PB_EventType_ChildDeFocused
          *Me\focuschild = #Null

        Case Control::#PB_EventType_ChildCursor
          SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data )
          
        Case #PB_EventType_LostFocus
          If *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
            *Me\focuschild = #Null
          EndIf
          
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
          
        Case #PB_EventType_LeftDoubleClick
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_LeftDoubleClick,@ev_data)
          EndIf
          
        Case #PB_EventType_RightButtonDown
          *Me\down = #True
          If *Me\overchild
            If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
              *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
            EndIf
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_RightButtonDown,ev_data)
          ElseIf *Me\focuschild
            *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
          EndIf
          
        Case #PB_EventType_RightButtonUp
          If *Me\overchild
            *overchild = *Me\overchild
            ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
            ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
            *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,ev_data)
          EndIf
          *Me\down = #False
          
        Case #PB_EventType_Input
          If *Me\focuschild
            ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Input))
            *Me\focuschild\OnEvent(#PB_EventType_Input,ev_data)
          EndIf
          
        Case #PB_EventType_KeyDown
          If *Me\focuschild
            ev_data\key   = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Key      )
            ev_data\modif = GetGadgetAttribute(*Me\gadgetID,#PB_Canvas_Modifiers)
            
            *Me\focuschild\OnEvent(#PB_EventType_KeyDown,ev_data)
          EndIf
        
      Case Globals::#SHORTCUT_COPY
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_COPY,#Null)
        EndIf
       
      Case Globals::#SHORTCUT_CUT
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_CUT,#Null)
        EndIf
        
      Case Globals::#SHORTCUT_PASTE
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_PASTE,#Null)
        EndIf

      Case Globals::#SHORTCUT_UNDO
        If *Me\focuschild
          *Me\focuschild\OnEvent(Globals::#SHORTCUT_UNDO,#Null)
        EndIf
        
        
    EndSelect
    
    ProcedureReturn( #False )
    
  EndProcedure

  ; ; ---[ Timer Callback]----------------------------------------------------
  ; Procedure CallbackProc(*t.CControlTimeline)
  ;   Time::currentframe + 1
  ;   If Time::currentframe>100 : Time::currentframe = 1 : EndIf
  ;   *t\Event(#PB_Event_Timer)
  ; EndProcedure
  ; ============================================================================
  ;  IMPLEMENTATION ( CControlTimeline )
  ; ============================================================================
  Procedure FirstFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Protected *ico.ControlIcon::ControlIcon_t
    StopPlayback(*Me)
    
    If Time::loop
      Time::currentframe = Time::startloop
    Else
      Time::currentframe  = Time::startframe
    EndIf
    
    SetCurrentFrame(*Me,Time::currentframe)
    
    hlpDrawFrames( *Me )
  EndProcedure
  Callback::DECLARE_CALLBACK(FirstFrame, Types::#TYPE_PTR)
  
  Procedure LastFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    StopPlayback(*Me)
  
    If Time::loop
      Time::currentframe = Time::endloop
    Else
      Time::currentframe  = Time::endframe
    EndIf
    Time::play = #False
    
    SetCurrentFrame(*Me,Time::currentframe)
  
    hlpDrawFrames( *Me )
  EndProcedure
  Callback::DECLARE_CALLBACK(LastFrame, Types::#TYPE_PTR)
  
  Procedure NextFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::currentframe + 1
    If Time::loop
      If Time::currentframe<Time::startloop Or Time::currentframe>Time::endloop
        Time::currentframe = Time::startloop
      EndIf
    Else 
      If Time::currentframe>Time::endframe
        Time::currentframe = Time::endframe
        StopPlayback(*Me)
      EndIf
    EndIf
    
    If Not Time::play
      SetCurrentFrame(*Me,Time::currentframe)
    EndIf
    
    hlpDrawFrames( *Me )
  EndProcedure
  Callback::DECLARE_CALLBACK(NextFrame, Types::#TYPE_PTR)
  
  Procedure PreviousFrame( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::currentframe - 1
    If Time::loop
      If Time::currentframe>Time::endloop Or Time::currentframe<Time::startloop
        Time::currentframe = Time::endloop
      EndIf
    Else 
      If Time::currentframe<Time::startframe
        Time::currentframe = Time::startframe
        StopPlayback(*Me)
      EndIf
    EndIf
    
    If Not Time::play
      SetCurrentFrame(*Me,Time::currentframe)
    EndIf
    
    hlpDrawFrames( *Me )
  EndProcedure
  Callback::DECLARE_CALLBACK(PreviousFrame, Types::#TYPE_PTR)
  
  Procedure PlayForward( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      StartPlayback(*Me,#True)
    Else
      If Not Time::forward
        StopPlayback(*Me)
        PlayForward(*Me)
      Else
        StopPlayback(*Me)
      EndIf
    EndIf   
  EndProcedure
  Callback::DECLARE_CALLBACK(PlayForward, Types::#TYPE_PTR)

  Procedure PlayBackward( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      StartPlayback(*Me,#False)
    Else
      If Time::forward
        StopPlayback(*Me)
        PlayBackward(*Me)
      Else
        StopPlayback(*Me)
      EndIf
    EndIf   
  EndProcedure
  Callback::DECLARE_CALLBACK(PlayBackward, Types::#TYPE_PTR)
  
  Procedure StartPlayback( *Me.ControlTimeline_t, forward.b)
    Protected Me.IControlTimeline = *Me
    If Time::play = #False
      Time::play = #True
      Time::forward = forward
      Time::StartTimer(*Me\timer)
  
      If forward
        NextFrame(*Me)
      Else
        PreviousFrame(*Me)
      EndIf
    Else
      StopPlayback(*Me)
    EndIf   
  EndProcedure
  
  Procedure OnStartPlayback( *Me.ControlTimeline_t)
    Define *icon.ControlIcon::ControlIcon_t = *Me\c_playforward
    ControlTimeline::StartPlayback( *Me, *icon\down)
  EndProcedure
  Callback::DECLARE_CALLBACK(OnStartPlayback, Types::#TYPE_PTR)
  
  
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
        Time::StopTimer(*Me\timer)
      EndIf
      
    EndIf
    SetCurrentFrame(*Me,Time::currentframe)
  EndProcedure
  Callback::DECLARE_CALLBACK(StopPlayback, Types::#TYPE_PTR)
  
  
  Procedure PlayLoop( *Me.ControlTimeline_t)
    Protected Me.IControlTimeline = *Me
    Time::loop = 1 - Time::loop
    SetCurrentFrame(*Me,Time::currentframe)
    hlpDrawFrames( *Me )
  EndProcedure
  Callback::DECLARE_CALLBACK(PlayLoop, Types::#TYPE_PTR)
  
  Procedure SetStartFrame( *Me.ControlTimeline_t, frame.i)
    If frame > Time::endframe
      Time::startframe = Time::endframe-1
    Else
      Time::startframe = frame
    EndIf
  EndProcedure
  
  Procedure OnSetStartFrame(*Me.ControlTimeline_t)
    Define *n.ControlNumber::ControlNumber_t = *Me\c_startframe
    ControlTimeline::SetStartFrame(*Me, ValF(*n\value))
  EndProcedure
  Callback::DECLARE_CALLBACK(OnSetStartFrame, Types::#TYPE_PTR)
  
  Procedure SetEndFrame( *Me.ControlTimeline_t,frame.i)
    If frame <= Time::startframe
      Time::endframe = Time::startframe+1
    Else
      Time::endframe = frame
    EndIf  
  
  EndProcedure
  
  Procedure OnSetEndFrame(*Me.ControlTimeline_t)
    Define *n.ControlNumber::ControlNumber_t = *Me\c_endframe
    ControlTimeline::SetEndFrame(*Me, ValF(*n\value))
  EndProcedure
  Callback::DECLARE_CALLBACK(OnSetEndFrame, Types::#TYPE_PTR)
  
  Procedure SetStartRange( *Me.ControlTimeline_t, frame.i)
    If frame > Time::endframe
      Time::startrange = Time::endframe-1
      
    Else
      Time::startrange= frame
    EndIf
    Time::startloop = Time::startrange
  EndProcedure
  
  Procedure OnSetStartRange(*Me.ControlTimeline_t)
    Define *n.ControlNumber::ControlNumber_t = *Me\c_startrange
    ControlTimeline::SetStartRange(*Me, ValF(*n\value))
  EndProcedure
  Callback::DECLARE_CALLBACK(OnSetStartRange, Types::#TYPE_PTR)
  
  Procedure SetEndRange( *Me.ControlTimeline_t,frame.i)
    If frame <= Time::startframe
      Time::endrange = Time::startframe+1
    Else
      Time::endrange = frame
    EndIf  
    Time::endloop = Time::endrange
  EndProcedure
  
  Procedure OnSetEndRange(*Me.ControlTimeline_t)
    Define *n.ControlNumber::ControlNumber_t = *Me\c_endrange
    ControlTimeline::SetEndRange(*Me, ValF(*n\value))
  EndProcedure
  Callback::DECLARE_CALLBACK(OnSetEndRange, Types::#TYPE_PTR)
  
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
  
  Procedure OnSetCurrentFrame(*Me.ControlTimeline_t)
    Define *n.ControlNumber::ControlNumber_t = *Me\c_currentframe
    ControlTimeline::SetCurrentFrame(*Me, ValF(*n\value))
  EndProcedure
  Callback::DECLARE_CALLBACK(OnSetCurrentFrame, Types::#TYPE_PTR)
  
  Procedure.i Append( *Me.ControlTimeline_t, *ctl.Control::Control_t )
    
    If Not( *ctl ) : ProcedureReturn : EndIf
  
    Protected ctl.Control::IControl = *ctl
    Protected parent.Control::IControl = *Me
    Protected cid.i = *Me\controls
    
    *ctl\parent = parent
    
    *Me\children(cid) = ctl
    
    *Me\controls + 1

    ProcedureReturn( ctl )
  
  EndProcedure

  
  Procedure Delete( *Me.ControlTimeline_t )
    Protected i     .i = 0
    Protected iBound.i = 4
    
    Protected child.Control::IControl
    For i=0 To iBound
      child = *Me\children()
      Define *ctrl.Control::Control_t = child
      Debug *ctrl\name
      child\Delete()
    Next
    
    Time::DeleteTimer(*Me\timer)
  
    FreeArray( *Me\children() )
    FreeImage(*Me\imageID)
    FreeGadget(*Me\gadgetID)
    
    Object::TERM(ControlTimeline)
    
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New(*parent.UI::UI_t, x.i = 0, y.i = 0, width.i = 240, height.i = 60)
    
    Protected *Me.ControlTimeline_t = AllocateStructure(ControlTimeline_t) 
    
    Object::INI(ControlTimeline)
    
    *Me\window = windowID
    If width < 50 : width = 50 : EndIf
    
    *Me\type       = #PB_GadgetType_Canvas
    *Me\name       = "Timeline"
    *Me\parent     = *parent
    *Me\gadgetID   = *parent\gadgetID
    *Me\imageID    = CreateImage( #PB_Any, width, height )
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    
    *Me\controls = 0
    *Me\timer = Time::CreateTimer(*Me, @OnTimer(), 1000 / Time::FRAMERATE)
    
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
    
    
    Append(*Me,*Me\c_playbackrate)
    
    Protected w = *Me\sizX/2-128
    Protected t = height/5*2+2
    
    *Me\c_firstframe =    ControlIcon::New(*Me,"FirstFrame"    ,Icon::#ICON_FIRSTFRAME   ,0                 ,#False, w,     t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_previousframe = ControlIcon::New(*Me,"PreviousFrame" ,Icon::#ICON_FIRSTFRAME   ,0                 ,#False, w+32,  t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_playbackward =  ControlIcon::New(*Me,"PlayBackward"  ,Icon::#ICON_PLAYBACKWARD ,#PB_Button_Toggle ,#False, w+64,  t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_stopplayback =  ControlIcon::New(*Me,"StopPlayback"  ,Icon::#ICON_STOP         ,0                 ,#False, w+96,  t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_playforward =   ControlIcon::New(*Me,"PlayForward"   ,Icon::#ICON_PLAYFORWARD  ,#PB_Button_Toggle ,#False, w+128, t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_nextframe =     ControlIcon::New(*Me,"NextFrame"     ,Icon::#ICON_LASTFRAME    ,0                 ,#False, w+160, t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_lastframe =     ControlIcon::New(*Me,"LastFrame"     ,Icon::#ICON_LASTFRAME    ,0                 ,#False, w+192, t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    *Me\c_playloop =      ControlIcon::New(*Me,"PlayLoop"      ,Icon::#ICON_LOOP         ,#PB_Button_Toggle ,#False, w+224, t, ControlTimeline::#BUTTON_SIZE, ControlTimeline::#BUTTON_SIZE)
    
    Append(*Me,*Me\c_firstframe)
    Append(*Me,*Me\c_previousframe)
    Append(*Me,*Me\c_playbackward)
    Append(*Me,*Me\c_stopplayback)
    Append(*Me,*Me\c_playforward)
    Append(*Me,*Me\c_nextframe)
    Append(*Me,*Me\c_lastframe)
    Append(*Me,*Me\c_playloop)
    
    Protected Me.ControlTimeline::IControlTimeline = *Me
    Protected *ctrl.Control::Control_t = *Me\c_currentframe
    Callback::CONNECT_CALLBACK(*ctrl\on_change, OnSetCurrentFrame, *Me)
    *ctrl.Control::Control_t = *Me\c_startframe
    Callback::CONNECT_CALLBACK(*ctrl\on_change, OnSetStartFrame, *Me)
    *ctrl.Control::Control_t = *Me\c_endframe
    Callback::CONNECT_CALLBACK(*ctrl\on_change, OnSetEndFrame, *Me)
    *ctrl.Control::Control_t = *Me\c_startrange
    Callback::CONNECT_CALLBACK(*ctrl\on_change, OnSetStartRange, *Me)
    *ctrl.Control::Control_t = *Me\c_endrange
    Callback::CONNECT_CALLBACK(*ctrl\on_change, OnSetEndRange, *Me)
  
    hlpDrawPickImage(*Me)
    hlpDraw( *Me )
    
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Class::DEF( ControlTimeline )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 640
; FirstLine = 628
; Folding = ------
; EnableXP