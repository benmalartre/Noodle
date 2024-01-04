DeclareModule ControlGroup

  ; ---[ Constants ]------------------------------------------------------------
  #Autosize_H = 1<<20
  #Autosize_V = 1<<21
  #Autostack  = 1<<22
  #NoFrame    = 1<<23
  
  ; ----------------------------------------------------------------------------
  ;  Object ( ControlGroup_t )
  ; ----------------------------------------------------------------------------

  Structure ControlGroup_t Extends Control::Control_t
    ; CControl Group
    imageID   .i
    label     .s
    append    .i
    row       .i
    down      .i
    overchild .Control::IControl
    focuschild.Control::IControl
    Array children .Control::IControl(10)
    Array rowflags .i       (10)
    chilcount .i
    current   .i
    closed    .b
  EndStructure
  
  Interface IControlGroup Extends Control::IControl
    OnClick()
  EndInterface
  
  Declare New( *parent.Control::Control_t, name.s, label.s, x.i = 0, y.i = 0, width.i = 240, height.i = 120, options.i = #Autosize_V|#Autostack )
  Declare Delete(*Me.ControlGroup_t)
  Declare Draw( *Me.ControlGroup_t, xoff.i=0, yoff.i=0 )
  Declare OnEvent(*Me.ControlGroup_t,event.i,*datas.Control::EventTypeDatas_t=#Null)
  Declare Pick(*Me.ControlGroup_t)
  Declare SetLabel( *Me.ControlGroup_t, value.s )
  Declare.s GetLabel( *Me.ControlGroup_t )
  Declare AppendStart( *Me.ControlGroup_t )
  Declare Append( *Me.ControlGroup_t, ctl.Control::IControl )
  Declare AppendStop( *Me.ControlGroup_t )
  Declare RowStart( *Me.ControlGroup_t )
  Declare RowEnd( *Me.ControlGroup_t )
  DataSection 
    ControlGroupVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule



; ============================================================================
;  IMPLEMENTATION Control Group Module
; ============================================================================
Module ControlGroup

  ;{
  ; ----------------------------------------------------------------------------
  ;  Resize
  ; ----------------------------------------------------------------------------
  Procedure.i Resize( *Me.ControlGroup::ControlGroup_t, *ev_data.Control::EventTypeDatas_t )
    ; If #PB_Control_Group_Autosize_H:
    ;   Set this Group (client) width to the max width of children width
    ; Else
    ;   Force children width to the (client) width of this Group
    ;
    ; If #PB_Control_Group_Autosize_V:
    ;   Set this Group (client) height to encompass the last child
    ; Else
    ;   NOP
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *Me\chilcount < 1 : ProcedureReturn : EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected dirty   .i = #False
    Protected i       .i = 0
    Protected j       .i = 0
    Protected iBound  .i = *Me\chilcount - 1
    Protected curV    .i = 0
    Protected curH    .i = 0
    Protected maxV    .i = 0
    Protected inRow   .i = #False
    Protected *Son    .Control::Control_t
    Protected lablen.i = Len(*Me\label)
    
    
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같�[ Size Me ]같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If *ev_data
      
      ; ---[ Position ]---------------------------------------------------------
      ; ...[ X ]................................................................
      If ( *ev_data\x <> #PB_Ignore ) And ( *ev_data\x <> *Me\posX )
        dirty = #True
        *Me\posX = *ev_data\x
      EndIf
      ; ...[ Y ]................................................................
      If ( *ev_data\y <> #PB_Ignore ) And ( *ev_data\y <> *Me\posY )
        dirty = #True
        *Me\posY = *ev_data\y
      EndIf
      
      ; ---[ Size ]-------------------------------------------------------------
      ; ...[ Width ]............................................................
      If ( *ev_data\width <> #PB_Ignore ) And ( *ev_data\width <> *Me\sizX )
        dirty = #True
        *Me\sizX = *ev_data\width
      EndIf
      
    EndIf
    
    
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같�[ Auto Stacking ]같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    
    ; ---[ Stack Children ]-----------------------------------------------------
    If *Me\options & #Autostack
      ; ...[ Adjust Start Y Depending On Label Presence ].......................
      If lablen : curV = 20 : Else : curV = 14 : EndIf
      ; ...[ Reset Current X Position ].........................................
      curH = 10
      ; ...[ Reset Row Max Height ].............................................
      maxV = 0
      ; ...[ Stack Each Child Under Previous One ]..............................
      For i=0 To iBound
        *Son  = *Me\children(i)
        Control::Resize(*Son, curH, curV, #PB_Ignore, #PB_Ignore )
        ; ...[ Check Row ]......................................................
        If *Me\rowflags(i)
          curH + *Son\sizX + 5
          If maxV < *Son\sizY : maxV = *Son\sizY : EndIf
        Else
          curH = 10
          If maxV < *Son\sizY : maxV = *Son\sizY : EndIf
          curV + maxV + 5
          maxV = 0
        EndIf
      Next
    EndIf
    
    
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같�[ Horizontal Size ]같같같같같같같같같같같같같같같같같같같같같같같같같같
    ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
  
    ; ---[ Size Group ]---------------------------------------------------------
    ;If #True
    If *Me\options & #Autosize_H
      ; ...[ Reset Values ].....................................................
      maxV = 0 : curV = 0
      ; ...[ Look For Children Max Width ]......................................
      For i=0 To iBound
        Son = *Me\children(i)
        curV = *Son\posX + *Son\sizX
        If curV > maxV : maxV = curV : EndIf
      Next
      ; ...[ Update Group Width ]...............................................
      If maxV <> *Me\sizX : *Me\sizX = maxV + 10 : dirty = #True : EndIf
      
    ; ---[ Size Children ]------------------------------------------------------
    Else
      ; ...[ Reset Values ].....................................................
      curV = *Me\sizX - 20
      curH = curV
      maxV = 0
  
      ; ...[ Loop Over Children ]...............................................
      For i=0 To iBound
        *Son = *Me\children(i)
        If *Me\rowflags(i) And Not inRow
          curH = 0
          For j=i To iBound
            curH + 1
            If Not *Me\rowflags(j) : Break : EndIf
          Next
          curH = ( curV - 5*(curH-1) )/curH
          maxV + 1
          inRow = #True
          Control::Resize(*Me\children(i), #PB_Ignore, #PB_Ignore, curH, #PB_Ignore )
        ElseIf inRow
          Control::Resize( *Me\children(i),10 + maxV*( curH + 5 ), #PB_Ignore, curH, #PB_Ignore )
          maxV + 1
          If Not *Me\rowflags(i)
            inRow = #False
            curH  = curV
            maxV = 0
          EndIf
        Else
         Control::Resize( *Me\children(i), #PB_Ignore, #PB_Ignore, curH, #PB_Ignore )
        EndIf
      Next
    EndIf
  
    
;     ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;     ; 같�[ Vertical Size ]같같같같같같같같같같같같같같같같같같같같같같같같같같같
;     ; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;     
;     ; ---[ Size Parent ]--------------------------------------------------------
;     If *Me\options & #Autosize_V
;       ; ...[ Reset Max Value ]..................................................
;       maxV = 0
;       ; ...[ Look For Children Max Height ].....................................
;       For i=0 To iBound
;         *Son  = *Me\children(i)
;         curV = *Son\posY + *Son\sizY
;         If curV > maxV : maxV = curV : EndIf
;       Next
;       ; ...[ Update Group Height ]..............................................
;       If maxV <> *Me\sizY + 9: *Me\sizY = maxV + 9 : dirty = #True : EndIf
;     EndIf
    
    ; ---[ Check Need Redraw ]--------------------------------------------------
    If #True = dirty
      ResizeImage ( *Me\imageID, *Me\sizX, *Me\sizY )
    EndIf
  
    ; ---[ Return Redraw Flag ]-------------------------------------------------
    ProcedureReturn( dirty )
    
  EndProcedure
  ;}

; ----------------------------------------------------------------------------
;  Draw
; ----------------------------------------------------------------------------
Procedure Draw( *Me.ControlGroup_t, xoff.i=0, yoff.i=0 )
  
  Protected label.s = *Me\label
  Protected lalen.i = Len(label)
  Protected maxW .i = *Me\sizX - 21
  Protected curW .i
  
  VectorFont( FontID(Globals::#FONT_BOLD ),Globals::#FONT_SIZE_LABEL)
  
  curW = VectorTextWidth(label)
  While Len(label) And ( curW > maxW )
    label = Left( label, Len(label)-1 )
    curW = VectorTextWidth(label)
  Wend
  If Len(label) <> lalen
    lalen = Len(label)
    label = Left( label, Math::Max( lalen - 2, 2 ) ) + ".."
  EndIf
 
  If Not *Me\options & #NoFrame
    Vector::RoundBoxPath( *Me\posX+3.0, *Me\posY+7.0, *Me\sizX-7, *Me\sizY-10.0, Control::CORNER_RADIUS)
    VectorSourceColor(UIColor::COLOR_GROUP_FRAME )
    StrokePath(Control::FRAME_THICKNESS, #PB_Path_RoundCorner)  
  EndIf
  
  AddPathBox( *Me\posX+12, *Me\posY, curW+6, 12)
  VectorSourceColor(UIColor::COLOR_MAIN_BG )
  FillPath()
  MovePathCursor(*Me\posX+15,  *Me\posY)
  VectorSourceColor(UIColor::COLOR_GROUP_LABEL )
  DrawVectorText( label )
  
  ; ---[ Sanity Check ]-------------------------------------------------------
  If *Me\chilcount < 1 : ProcedureReturn : EndIf
  
  ; ---[ Local Variables ]----------------------------------------------------
  Protected i     .i = 0
  Protected iBound.i = *Me\chilcount - 1
  Protected  son  .Control::IControl
  Protected *son  .Control::Control_t
  
  ; ---[ Redraw Children ]----------------------------------------------------
  Protected ev_data.Control::EventTypeDatas_t  
  For i=0 To iBound
     *son = *Me\children(i)
     son = *son
     
    ev_data\xoff = *Me\posX+*son\posX
    ev_data\yoff = *Me\posY+*son\posY
    
    son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
  Next
 
EndProcedure


; ----------------------------------------------------------------------------
;  Pick
; ----------------------------------------------------------------------------
Procedure Pick(*Me.ControlGroup_t)
  Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
  Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
  
  xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
  ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
  
  StartDrawing( ImageOutput(*Me\imageID) )
  Protected pickID = Point(xm,ym) - 1
  StopDrawing()
  
  ProcedureReturn pickID
EndProcedure

; ----------------------------------------------------------------------------
;  DrawPickImage
; ----------------------------------------------------------------------------
Procedure DrawPickImage( *Me.ControlGroup_t )
  ; ---[ Local Variables ]----------------------------------------------------
  Protected i     .i = 0
  Protected iBound.i = *Me\chilcount-1;ArraySize(*Me\children()) - 1
  Protected  son  .Control::IControl
  Protected *son  .Control::Control_t
  
  ; ---[ Tag Picking Surface ]------------------------------------------------
  StartVectorDrawing( ImageVectorOutput( *Me\imageID ) )
  AddPathBox( 0, 0, *Me\sizX, *Me\sizY)
  VectorSourceColor(RGBA(0,0,0,255))
  FillPath()
  For i=0 To iBound
      
    *son = *Me\children(i)
    son = *son
    If *son\type = Control::#GROUP
      
    Else
      AddPathBox( *son\posX, *son\posY, *son\sizX, *son\sizY)
      VectorSourceColor(RGBA(i+1,0,0,255))
      FillPath()
    EndIf
   Next
   StopVectorDrawing()
EndProcedure
;}


; ----------------------------------------------------------------------------
;  NextItem
; ----------------------------------------------------------------------------
Procedure NextItem( *Me.ControlGroup_t )
  ; ---[ Get Current Item ID ]------------------------------------------------
  StartDrawing( ImageOutput(*Me\imageID) )
    Protected *focuschild.Control::Control_t = *Me\focuschild
    Protected idx = Point(*focuschild\posX+1,*focuschild\posY+1) - 1
    StopDrawing()
    If *Me\focuschild
      *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
      ; ---[ Local Variables ]----------------------------------------------------
      Protected iBound.i = *Me\chilcount - 1
      Protected n.i = (idx+1)%iBound
      Protected ev_data.Control::EventTypeDatas_t 
      *Me\focuschild = *Me\children(n)
      *Me\focuschild\OnEvent(#PB_EventType_Focus,@ev_data)
    EndIf
    
EndProcedure

; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
; ---[ OnEvent ]--------------------------------------------------------------
Procedure.i OnEvent( *Me.ControlGroup_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Protected i=0
  Protected *ctrl.Control::Control_t 
  
  ; ---[ Local Variables ]----------------------------------------------------
  Protected  ev_data.Control::EventTypeDatas_t
  Protected *son.Control::Control_t
  Protected  son.Control::IControl
  
  ; ---[ Dispatch Event ]-----------------------------------------------------
  Select ev_code
      
    ; ------------------------------------------------------------------------
    ;  Resize
    ; ------------------------------------------------------------------------
    Case #PB_EventType_Resize
      ; ...[ Update & Check Dirty ]...........................................
     Resize( *Me, *ev_data.Control::EventTypeDatas_t )

    ; ...[ Processed ]......................................................
    ProcedureReturn( #True )
      
    ; ------------------------------------------------------------------------
    ;  DrawChild
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_DrawChild
      *son = *ev_data
      son = *son
      ev_data\xoff    = *son\posX+*Me\posX
      ev_data\yoff    = *son\posY+*Me\posY
      StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
      ResetCoordinates()
      AddPathBox( ev_data\xoff, ev_data\yoff, *son\sizX, *son\sizY)
      VectorSourceColor(UIColor::COLOR_MAIN_BG )
      FillPath()
      son\OnEvent( Control::#PB_EventType_Draw, @ev_data )
      StopVectorDrawing()
        
    ; ------------------------------------------------------------------------
    ;  Draw
    ; ------------------------------------------------------------------------
    Case Control::#PB_EventType_Draw
      Draw( *Me )

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
        Define focuschild.Control::IControl = *Me\focuschild
        focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
        *Me\focuschild = #Null
      EndIf
      
    ; ------------------------------------------------------------------------
    ;  MouseMove
    ; ------------------------------------------------------------------------
    Case #PB_EventType_MouseMove
      Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
      Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
      Protected pickID = Pick(*Me)
      If pickID > -1 And pickID <*Me\chilcount
        *son = *Me\children(pickID)
      Else
        *son = #Null
      EndIf
      
      xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
      ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
      If *Me\overchild <> *son And  Not *Me\down
        If *Me\overchild : *Me\overchild\OnEvent(#PB_EventType_MouseLeave) : EndIf
        *Me\overchild = *son
        If *Me\overchild
          *Me\overchild\OnEvent(#PB_EventType_MouseEnter)
        EndIf
         
      ElseIf pickID >= 0 And pickID <*Me\chilcount
        Protected ctl.Control::IControl = *Me\children( pickID )
        If ( ctl <> *Me\overchild ) And  Not *Me\down
          If *Me\overchild <> #Null
            Define overchild.Control::IControl = *Me\overchild
            overchild\OnEvent(#PB_EventType_MouseLeave)
            SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )
          EndIf
          ctl\OnEvent(#PB_EventType_MouseEnter)
          If Not *Me\down
            *Me\overchild = ctl
          EndIf
        ElseIf *Me\overchild
          Define *overchild.Control::Control_t = *Me\overchild
          ev_data\x    = xm - *overchild\posX
          ev_data\y    = ym - *overchild\posY
          Define overchild.Control::IControl = *Me\overchild
          overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
        EndIf
      ElseIf *Me\overchild
        Define *overchild.Control::Control_t = *Me\overchild
        ev_data\x    = xm - *overchild\posX
        ev_data\y    = ym - *overchild\posY
        ev_data\yoff = 50
        Define overchild.Control::IControl = *Me\overchild
        overchild\OnEvent(#PB_EventType_MouseMove,@ev_data)
       Else
          SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )
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
          xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
          ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
          xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
          ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
           Define *overchild.Control::Control_t = *Me\overchild
          ev_data\x = xm - *overchild\posX
          ev_data\y = ym - *overchild\posY
          *Me\overchild\OnEvent(#PB_EventType_LeftButtonDown,@ev_data)
        ElseIf *Me\focuschild
          Define focuschild.Control::IControl = *Me\focuschild
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
        EndIf
      
    ; ------------------------------------------------------------------------
    ;  LeftButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftButtonUp
      If *Me\overchild
        Define *overchild.Control::Control_t = *Me\overchild
        
        ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
        ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
        *Me\overchild\OnEvent(#PB_EventType_LeftButtonUp,@ev_data)
      EndIf
      *Me\down = #False
      
    ; ------------------------------------------------------------------------
    ;  LeftDoubleClick
    ; ------------------------------------------------------------------------
    Case #PB_EventType_LeftDoubleClick
      If *Me\overchild
        Define *overchild.Control::Control_t = *Me\overchild
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
        Define *overchild.Control::Control_t = *Me\overchild
        If *Me\focuschild And ( *Me\overchild <> *Me\focuschild )
          *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
        EndIf
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
        Define *overchild.Control::Control_t = *Me\overchild
        ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
        ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
        *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
      EndIf
      *Me\down = #False
    
    ; ------------------------------------------------------------------------
    ;  RightButtonUp
    ; ------------------------------------------------------------------------
    Case #PB_EventType_RightButtonUp
      If *Me\overchild
        Define *overchild.Control::Control_t = *Me\overchild
        ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
        ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
        *Me\overchild\OnEvent(#PB_EventType_RightButtonUp,@ev_data)
      EndIf
      
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
      
;       ; ------------------------------------------------------------------------
;       ;  SHORTCUT_NEXT
;       ; ------------------------------------------------------------------------
;       Case Globals::#SHORTCUT_NEXT
;         ; ---[ Do We Have A Focused Child ? ]-------------------------------------
;         If *Me\focuschild
;           ; ---[ Go To Next Item ]------------------------------------------------
;           NextItem( *Me ) 
;         EndIf
;         
;       ;------------------------------------------------------------------------
;       ; SHORTCUT_PREVIOUS
;       ;------------------------------------------------------------------------
;       Case Globals::#SHORTCUT_PREVIOUS
;           Debug "Previous Item called"
;           ; ---[ Do We Have A Focused Child ? ]-----------------------------------
;           If *Me\focuschild
;             ; go to previous child
;             Debug "previous child per favor..."
;           EndIf
               
             
      
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

  ; ============================================================================
  ;  IMPLEMENTATION ( ControlGroup_t )
  ; ============================================================================

  ; ---[ SetLabel ]-------------------------------------------------------------
  Procedure SetLabel( *Me.ControlGroup_t, value.s )
    
    ; ---[ Set String Value ]---------------------------------------------------
    *Me\label = value
    
    ; ---[ Redraw Control ]-----------------------------------------------------
    ;Draw( *Me )
    
  EndProcedure
  ; ---[ GetLabel ]-------------------------------------------------------------
  Procedure.s GetLabel( *Me.ControlGroup_t )
    
    ; ---[ Return String Value ]------------------------------------------------
    ProcedureReturn( *Me\label )
    
  EndProcedure
  ; ---[ AppendStart ]----------------------------------------------------------
  Procedure AppendStart( *Me.ControlGroup_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If *Me\append : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #True
    
  EndProcedure
  ; ---[ Append ]---------------------------------------------------------------
  Procedure.i Append( *Me.ControlGroup_t, ctl.Control::IControl )
    
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not ctl : ProcedureReturn : EndIf
  
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If #False = *Me\append
      ; ...[ FAILED ]...........................................................
      ProcedureReturn( #False)
    EndIf
    
    ; ---[ Local Variables ]----------------------------------------------------
    Protected *ctl.Control::Control_t = ctl
    Protected Me.Control::IControl     = *Me
  
    ; ---[ Check Array Space ]--------------------------------------------------
    If *Me\chilcount > ArraySize( *Me\children() )
      ReDim *Me\children( *Me\chilcount + 10 )
      ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    ; ---[ Set Me As Control Parent ]-------------------------------------------
    *ctl\parent = Me
  
    ; ---[ Append Control ]-----------------------------------------------------
    *Me\children( *Me\chilcount ) = ctl
  
    ; ---[ Set Row Flag ]-------------------------------------------------------
    *Me\rowflags( *Me\chilcount ) = *Me\row
  
    ; ---[ One More Control ]---------------------------------------------------
    *Me\chilcount + 1
    
  
    ; ---[ Return The Added Control ]-------------------------------------------
    ProcedureReturn( ctl )
  
  EndProcedure
  ; ---[ AppendStop ]-----------------------------------------------------------
  Procedure AppendStop( *Me.ControlGroup_t )
    
    ; ---[ Check Gadget List Status ]-------------------------------------------
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\append = #False
    
    ;   ; ---[ Update Control And Children ]----------------------------------------
    Resize( *Me, #Null )
  
    DrawPickImage(*Me)
  
  EndProcedure
  ; ---[ RowStart ]-------------------------------------------------------------
  Procedure RowStart( *Me.ControlGroup_t )
    
    ; ---[ Check Row Status ]---------------------------------------------------
    If *Me\row : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\row = #True
    
  EndProcedure
  ; ---[ RowEnd ]---------------------------------------------------------------
  Procedure RowEnd( *Me.ControlGroup_t )
    
    ; ---[ Check Row Status ]---------------------------------------------------
    If Not *Me\row : ProcedureReturn( void ) : EndIf
    
    ; ---[ Update Current Child ]-----------------------------------------------
    *Me\rowflags( *Me\chilcount - 1 ) = #False
    
    ; ---[ Update Status ]------------------------------------------------------
    *Me\row = #False
    
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, label.s, x.i = 0, y.i = 0, width.i = 240, height.i = 120, options.i = #Autosize_V|#Autostack )
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.ControlGroup_t = AllocateStructure(ControlGroup_t)
  
    
    Object::INI(ControlGroup)
    
    ; ---[ Minimum Width ]------------------------------------------------------
    If width < 50 : width = 50 : EndIf
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type       = Control::#GROUP
    *Me\name       = name
    *Me\parent     = *parent
    If Not *Me\parent Or Not IsGadget(*Me\parent\gadgetID)
      *Me\gadgetID   = CanvasGadget( #PB_Any, x, y, width, height, #PB_Canvas_Keyboard )
    Else
      *Me\gadgetID = *Me\parent\gadgetID
    EndIf
    
    *Me\imageID    = CreateImage( #PB_Any, width, height )
    *Me\posX       = x
    *Me\posY       = y
    *Me\sizX       = width
    *Me\sizY       = height
    *Me\label      = label
    *Me\visible    = #True
    *Me\enable     = #True
    *Me\options    = options
    *Me\down       = #False
    *Me\append     = #False
    *Me\chilcount  = 0
    *Me\overchild  = #Null
    *Me\focuschild = #Null
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
    ; ---[ Free ]-----------------------------------------------------------------
  Procedure Delete( *Me.ControlGroup_t )
    ; ---[ Local Variables ]----------------------------------------------------
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount - 1
    
    ; ---[ Destroy Children Controls ]------------------------------------------
    Define *child.Control::IControl
    For i=0 To iBound
      *child = *Me\children(i)
      *child\Delete()
    Next
    
;     For i=0 To iBound
;       *child = *Me\children(i)
;       Select *child\type
;         Case Control::#PB_GadgetType_Check
; ;           ControlCheck::Delete(*child)
;         Case Control::#PB_GadgetType_Color
; ;           ControlColor::Delete(*child)
;         Case Control::#PB_GadgetType_ColorWheel
;           ;           ControlColorWheel::Delete(*child)
;         Case Control::#PB_GadgetType_Combo
;           ;           ControlCombo::Delete(*child)
;         Case Control::#PB_GadgetType_Divot
;         Case Control::#PB_GadgetType_Edit
;         Case Control::#PB_GadgetType_Explore
;         Case Control::#PB_GadgetType_Group
;           ControlGroup::Delete(*child)
;         Case Control::#PB_GadgetType_Icon
; ;           ControlIcon::Delete(*child)
;         Case Control::#PB_GadgetType_Label
; ;           ControlLabel::Delete(*child)
;         Case Control::#PB_GadgetType_Number
; ;           ControlNumber::ControlColor::Delete(*child)elete(*child)
;         Case Control::#PB_GadgetType_Radio
;           ;           ControlRadio::Delete(*child)
;       EndSelect
;       
; 
;     Next
    
    ; ---[ Release Arrays ]-----------------------------------------------------
    FreeArray( *Me\rowflags() )
    FreeArray( *Me\children() )
    
    ; ---[ Free Image ]---------------------------------------------------------
    FreeImage( *Me\imageID )
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    Object::TERM( ControlGroup )
    
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ControlGroup )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 892
; FirstLine = 855
; Folding = ----
; EnableXP