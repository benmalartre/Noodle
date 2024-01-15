XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/View.pbi"
; ==============================================================================
;  CONTROL EDIT MODULE DECLARATION
; ==============================================================================
DeclareModule ControlEdit 

  Structure ControlEdit_t Extends Control::Control_t
    value       .s
    undo_esc    .s
    undo_ctz_t  .s
    undo_ctz_g  .i
    undo_ctz_w  .i
    over        .i
    down        .i
    focused     .i
    selected    .i
    posG        .i ; Strong Cursor
    posW        .i ; Weak   Cursor
    posS        .i
    caret_switch.i
    timer_on    .i
    lookup_dirty.i
    lookup_count.i
    Array lookup.i(0)
  EndStructure
  
  Interface IControlEdit Extends Control::IControl
  EndInterface
  
  Declare New(*parent.Control::Control_t ,name.s, value.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlEdit_t)
  Declare Draw( *Me.ControlEdit_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlEdit_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare.s GetValue( *Me.ControlEdit_t )
  Declare SetValue( *Me.ControlEdit_t, value.s )

  DataSection
    ControlEditVT:
    Data.i @OnEvent() ; mandatory override
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
    Data.i @OnEvent()
    
  EndDataSection
  
  Global CLASS.Class::Class_t

EndDeclareModule


; ============================================================================
;  IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlEdit

Procedure.i hlpNextWordStart( text.s, cur_pos.i )
  
  Protected iEnd.i = Len(text) + 1
  Protected bFront = #False
  
  If cur_pos = iEnd : ProcedureReturn( iEnd ) : EndIf
  
  If Mid( text, cur_pos, 1 ) = " "
    bFront = #True
  EndIf
  
  While cur_pos < iEnd
    If bFront
      If Mid( text, cur_pos, 1 ) <> " "
        ProcedureReturn( cur_pos )
      EndIf
    Else
      If Mid( text, cur_pos, 1 ) = " "
        bFront = #True
      EndIf
    EndIf
    cur_pos + 1
  Wend
  
  ProcedureReturn( iEnd )
  
EndProcedure


Procedure.i hlpPrevWordStart( text.s, cur_pos.i )
  
  If cur_pos = 1 : ProcedureReturn(1) : EndIf
  
  Protected bFront = #False
  
  cur_pos - 1
  If Mid( text, cur_pos, 1 ) <> " "
    bFront = #True
  EndIf
  
  While cur_pos > 1
    cur_pos - 1
    If bFront
      If Mid( text, cur_pos, 1 ) = " "
        ProcedureReturn( cur_pos + 1 )
      EndIf
    Else
      If Mid( text, cur_pos, 1 ) <> " "
        bFront = #True
      EndIf
    EndIf
  Wend
  
  ProcedureReturn( 1 )
  
EndProcedure

Procedure.i hlpPrevWord( text.s, cur_pos.i )
  
  If cur_pos = 1 : ProcedureReturn(1) : EndIf
  
  Protected bFront = #False
  
  cur_pos - 1
  If Mid( text, cur_pos, 1 ) <> " "
    bFront = #True
  EndIf
  
  While cur_pos > 1
    cur_pos - 1
    If bFront
      If Mid( text, cur_pos, 1 ) = " "
        ProcedureReturn( cur_pos + 1 )
      EndIf
    Else
      If Mid( text, cur_pos, 1 ) <> " "
        ProcedureReturn( cur_pos + 1 )
      EndIf
    EndIf
  Wend
  
  ProcedureReturn( 1 )
  
EndProcedure

Procedure.i hlpNextWord( text.s, cur_pos.i )
  
  Protected iEnd.i = Len(text) + 1
  Protected bFront = #False
  
  If cur_pos = iEnd : ProcedureReturn( iEnd ) : EndIf
  
  If Mid( text, cur_pos, 1 ) = " "
    bFront = #True
  EndIf
  
  While cur_pos < iEnd
    If bFront
      If Mid( text, cur_pos, 1 ) <> " "
        ProcedureReturn( cur_pos )
      EndIf
    Else
      If Mid( text, cur_pos, 1 ) = " "
        ProcedureReturn( cur_pos )
      EndIf
    EndIf
    cur_pos + 1
  Wend
  
  ProcedureReturn( iEnd )
  
EndProcedure

Procedure hlpSelectWord( *Me.ControlEdit_t, cur_pos.i )
  
  If cur_pos > 1 And cur_pos < Len(*Me\value)
    
    If Mid( *Me\value, cur_pos - 1, 1 ) = " " And Mid( *Me\value, cur_pos, 1 ) <> " " 
      *Me\posG = cur_pos
      *Me\posW = hlpNextWord( *Me\value, cur_pos )
    ElseIf Mid( *Me\value, cur_pos - 1, 1 ) <> " " And Mid( *Me\value, cur_pos, 1 ) = " " 
      *Me\posG = hlpPrevWord( *Me\value, cur_pos )
      *Me\posW = cur_pos
    Else
      *Me\posG = hlpPrevWord( *Me\value, cur_pos )
      *Me\posW = hlpNextWord( *Me\value, cur_pos )
    EndIf
  EndIf
  
EndProcedure

Procedure.i hlpCharPosFromMousePos( *Me.ControlEdit_t, xpos.i )
  xpos - 7
  Protected x_start.i = *Me\lookup(*Me\posS)
  Protected i.i
  For i = *Me\posS To *Me\lookup_count
    If *Me\lookup(i) - x_start > xpos
      ProcedureReturn( Math::Max( 1, i -1) )
    EndIf
  Next
  
  ProcedureReturn( *Me\lookup_count)
EndProcedure

Procedure Draw( *Me.ControlEdit_t, xoff.i = 0, yoff.i = 0 )
  If Not *Me\visible : ProcedureReturn( void ) : EndIf
  
  Protected tc.i = UIColor::COLOR_TEXT_DEFAULT
  VectorFont( FontID(Globals::#Font_Default), Globals::#Font_Size_Label )
  Protected tx.i = 7
  Protected ty.i
  If Len(*Me\value)
    ty.i = ( *Me\sizY - VectorTextHeight( *Me\value ) )/2 + yoff
  Else
    ty.i = (*Me\sizY - Globals::#Font_Size_Label)/2 + yoff
  EndIf
  
  Vector::RoundBoxPath(0+xoff, 0+yoff,*Me\sizX, *me\sizY, Control::CORNER_RADIUS)
  
  If *Me\lookup_dirty
    Protected i.i
    *Me\lookup_count = Len(*Me\value) + 1
    ReDim *Me\lookup(*Me\lookup_count)
    *Me\lookup(0) = 0
    For i=1 To *Me\lookup_count
      *Me\lookup(i) = VectorTextWidth( Left(*Me\value,i-1) )
    Next
    *Me\lookup_dirty = #False
  EndIf
  
  *Me\posS = Math::Min( *Me\posS, *Me\posW )

  Protected rof    .i = *Me\sizX - 12
  Protected x_start.i = *Me\lookup(*Me\posS)
  Protected x_end  .i = *Me\lookup(*Me\posW)
  Protected tw     .i = x_end - x_start  
  Protected tlen   .i = *Me\posW - *Me\posS
  If tw > rof
    While tw > rof
      *Me\posS + 1
      tw = x_end - *Me\lookup(*Me\posS)
    Wend
    tlen = *Me\posW - *Me\posS
  Else
    Protected i_end.i = *Me\posW
    While ( tw <= rof ) And ( i_end < *Me\lookup_count )
      i_end + 1
      tw = *Me\lookup(i_end) - x_start
    Wend
    If i_end < *Me\lookup_count : i_end - 1 : EndIf
    tlen = i_end - *Me\posS
    tw = *Me\lookup(i_end) - x_start
  EndIf
  
  If *Me\focused
    Protected posL.i, posR.i, posXL.i, posXR.i
    If *Me\posG > *Me\posW
      posL = *Me\posW : posR = *Me\posG
    Else
      posL = *Me\posG : posR = *Me\posW
    EndIf
    posXL = Math::Max( 0, *Me\lookup(posL) - *Me\lookup(*Me\posS) )
    If posL <> posR
      *Me\selected = #True
      posXR = Math::Min( tw, *Me\lookup(posR) - *Me\lookup(*Me\posS) )
    Else
      *Me\selected = #False
    EndIf
  EndIf
  
  If Not *Me\enable
    VectorSourceColor(UIColor::COLOR_DISABLED_FG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UIColor::COLOR_FRAME_DISABLED)
    StrokePath(Control::FRAME_THICKNESS)
    
  ElseIf *Me\focused
    VectorSourceColor(UIColor::COLOR_ACTIVE_BG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UIColor::COLOR_FRAME_ACTIVE)
    StrokePath(Control::FRAME_THICKNESS)
    tc = UIColor::COLOR_TEXT_ACTIVE

  ElseIf *Me\over
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UIColor::COLOR_FRAME_OVERED)
    StrokePath(Control::FRAME_THICKNESS)

  Else
    VectorSourceColor(UIColor::COLOR_NUMBER_BG)
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(UICOlor::COLOR_FRAME_DEFAULT)
    StrokePath(Control::FRAME_THICKNESS)

  EndIf

  If *Me\focused
    If *Me\selected
      AddPathBox( tx + xoff + posXL - 1, ty-1, (posXR - posXL) + 2, 14)
      VectorSourceColor(UIColor::COLOR_SELECTED_BG )
      FillPath()
      
      MovePathCursor(tx + xoff, ty)
      VectorSourceColor(tc)
      DrawVectorText( Mid( *Me\value, *Me\posS, tlen ))
    Else
      MovePathCursor(tx + xoff, ty)
      VectorSourceColor(tc)
      DrawVectorText( Mid( *Me\value, *Me\posS, tlen ))
      If *Me\caret_switch > 0 Or Not *Me\timer_on
        MovePathCursor(tx + posXL + xoff, ty)
        AddPathLine( 0, 12, #PB_Path_Relative)
        VectorSourceColor(UIColor::COLOR_CARET )
      EndIf
      StrokePath(2)
    EndIf
  Else
    MovePathCursor(tx + xoff, ty)
    VectorSourceColor(tc)
    DrawVectorText( Mid( *Me\value, *Me\posS, tlen ) )
  EndIf
  
EndProcedure

; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
Procedure.i OnEvent( *Me.ControlEdit_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Protected Me.Control::IControl = *Me

  Select ev_code
    Case Control::#PB_EventType_Draw
      If Not( *ev_data ):ProcedureReturn : EndIf
      Draw( *Me, *ev_data\xoff, *ev_data\yoff )
      ProcedureReturn( #True )
      
    Case #PB_EventType_Resize
      If Not( *ev_data ):ProcedureReturn : EndIf
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ProcedureReturn( #True )
      
    Case #PB_EventType_LostFocus
      ;RemoveWindowTimer( #MainWindow, #TIMER_CARET )
      *Me\focused = #False
      *Me\posG = 1 : *Me\posW = 1
      Control::Invalidate(*Me)
      ProcedureReturn( #True )
      
    Case #PB_EventType_MouseEnter
      If *Me\visible And *Me\enable
        *Me\over = #True
        Control::SetCursor(*Me, #PB_Cursor_IBeam )
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_MouseLeave
      If *Me\visible And *Me\enable
        *Me\over = #False
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_MouseMove
      If *Me\visible And *Me\enable
        If *Me\focused And *Me\down
          If Not( *ev_data ):ProcedureReturn : EndIf
          *Me\posW = hlpCharPosFromMousePos( *Me, *ev_data\x )
          Control::Invalidate(*Me)
        EndIf
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_LeftButtonDown
      If *Me\visible And *Me\enable And *Me\over
        *Me\down = #True
        If Not *Me\focused
          *Me\focused = #True
          *Me\undo_esc = *Me\value
          *Me\posG = hlpCharPosFromMousePos( *Me, *ev_data\x )
          *Me\posW = *Me\posG
          Control::Focused(*Me)
        Else
          If Not( *ev_data ) : ProcedureReturn : EndIf
          *Me\posG = hlpCharPosFromMousePos( *Me, *ev_data\x )
          *Me\posW = *Me\posG
        EndIf
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
        *Me\down = #False
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf

    Case #PB_EventType_LeftDoubleClick
      If *Me\visible And *Me\enable
        If Not( *ev_data ):ProcedureReturn : EndIf
        *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
        *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_Input
      If Not( *ev_data ):ProcedureReturn : EndIf
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      If *Me\posW > *Me\posG
        *Me\value = Left(*Me\value,*Me\posG-1) + *ev_data\input + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
        *Me\posG + 1
      Else
        *Me\value = Left(*Me\value,*Me\posW-1) + *ev_data\input + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW + 1
      EndIf
      *Me\posW = *Me\posG
      *Me\lookup_dirty = #True
      Control::Invalidate(*Me)
      ProcedureReturn( #True )

    Case #PB_EventType_KeyDown
      Select *ev_data\key
          
        Case #PB_Shortcut_Return
          *Me\focused = #False : Control::DeFocused(*Me)
          *Me\posG = 1 : *Me\posW = 1
          Callback::Trigger(*Me\on_change,Callback::#SIGNAL_TYPE_PING)
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Escape
          *Me\focused = #False : Control::DeFocused(*Me)
          *Me\value = *Me\undo_esc
          *Me\posG = 1 : *Me\posW = 1
          *Me\lookup_dirty = #True
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Tab
          ; TODO : Next Widget In Group

        Case #PB_Shortcut_Home
         If Not( *ev_data ):ProcedureReturn : EndIf
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          *Me\posW = 1
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_End
          If Not( *ev_data ):ProcedureReturn : EndIf
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          *Me\posW = Len(*Me\value) + 1
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Left
          If Not( *ev_data ):ProcedureReturn : EndIf
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          If ( *ev_data\modif & #PB_Canvas_Control ) Or ( *ev_data\modif & #PB_Canvas_Command )
            *Me\posW = hlpPrevWordStart( *Me\value, *Me\posW )
          Else
            *Me\posW = Math::Max( 1, *Me\posW - 1 )
          EndIf
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Right
          If Not( *ev_data ):ProcedureReturn : EndIf
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          If ( *ev_data\modif & #PB_Canvas_Control ) Or ( *ev_data\modif & #PB_Canvas_Command )
            *Me\posW = hlpNextWordStart( *Me\value, *Me\posW )
          Else
            *Me\posW = Math::Min( Len(*Me\value) + 1, *Me\posW + 1 )
          EndIf
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Back
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          If *Me\posG > *Me\posW
            *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
            *Me\posG = *Me\posW
          ElseIf *Me\posG <> *Me\posW
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
          Else
            *Me\value = Left(*Me\value,*Me\posG-2) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
            *Me\posG = Math::Max( 1, *Me\posG - 1 )
          EndIf
          *Me\posW = *Me\posG
          *Me\lookup_dirty = #True
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Delete
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          If *Me\posG > *Me\posW
            *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
            *Me\posG = *Me\posW
          ElseIf *Me\posG <> *Me\posW
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
          Else
            *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW)
          EndIf
          *Me\posW = *Me\posG
          *Me\lookup_dirty = #True
          Control::Invalidate(*Me)
          ProcedureReturn( #True )
          
      EndSelect ; Select *ev_data\key ( Case #PB_EventType_KeyDown )
      
    Case Globals::#SHORTCUT_CUT
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      If *Me\posG > *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posW, *Me\posG - *Me\posW ) )
        *Me\value = Left(*Me\value,*Me\posW-1) + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW
      ElseIf *Me\posG <> *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posG, *Me\posW - *Me\posG ) )
        *Me\value = Left(*Me\value,*Me\posG-1) + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
      EndIf
      *Me\posW = *Me\posG
      *Me\lookup_dirty = #True
      Control::Invalidate(*Me)
      ProcedureReturn( #True )
      
    Case Globals::#SHORTCUT_COPY
      If *Me\posG > *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posW, *Me\posG - *Me\posW ) )
      ElseIf *Me\posG <> *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posG, *Me\posW - *Me\posG ) )
      EndIf
      ProcedureReturn( #True )
      
    Case Globals::#SHORTCUT_PASTE
      *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
      Protected cliptxt.s = GetClipboardText()
      Protected cliplen.i = Len(cliptxt)
      If *Me\posG > *Me\posW
        *Me\value = Left(*Me\value,*Me\posW-1) + cliptxt + Right(*Me\value,Len(*Me\value)-*Me\posG+1)
        *Me\posG = *Me\posW
      Else
        *Me\value = Left(*Me\value,*Me\posG-1) + cliptxt + Right(*Me\value,Len(*Me\value)-*Me\posW+1)
      EndIf
      *Me\posG + cliplen
      *Me\posW = *Me\posG
      *Me\lookup_dirty = #True
      Control::Invalidate(*Me)
      ProcedureReturn( #True )
      
    Case Globals::#SHORTCUT_UNDO
      *Me\value = *Me\undo_ctz_t
      *Me\posG  = *Me\undo_ctz_g
      *Me\posW  = *Me\undo_ctz_w
      *Me\lookup_dirty = #True
      Control::Invalidate(*Me)
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
  Procedure SetValue( *Me.ControlEdit_t, value.s )
    
    If value = *Me\value
      ProcedureReturn( void )
    EndIf

    *Me\value = value
    Control::Invalidate(*Me)
    
  EndProcedure
  Procedure.s GetValue( *Me.ControlEdit_t )
    
    ProcedureReturn( *Me\value )
    
  EndProcedure
  
  Procedure Delete( *Me.ControlEdit_t )
    Object::TERM(ControlEdit)
    
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t ,name.s, value.s = "", options.i = 0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    Protected *Me.ControlEdit_t = AllocateStructure(ControlEdit_t)
  
    Object::INI(ControlEdit)
    
    *Me\type         = Control::#EDIT
    *Me\name         = name
    *Me\parent       = *parent
    *Me\gadgetID     = *parent\gadgetID
    *Me\posX         = x
    *Me\posY         = y
    *Me\sizX         = width
    *Me\sizY         = height
    *Me\visible      = #True
    *Me\enable       = #True
    *Me\options      = options
    *Me\value        = value
    *Me\undo_esc     = ""
    *Me\undo_ctz_t   = ""
    *Me\over         = #False
    *Me\down         = #False
    *Me\focused      = #False
    *Me\selected     = #False
    *Me\posG         = 1
    *Me\posW         = 1
    *Me\posS         = 1
    *Me\caret_switch = 1
    *Me\timer_on     = #False
    *Me\lookup_dirty = #True
    *Me\lookup_count = 0
    
    InitializeStructure( *Me, ControlEdit_t )
    
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Class::DEF( ControlEdit )
  
EndModule




; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 278
; FirstLine = 232
; Folding = ---
; EnableXP