XIncludeFile "../core/Globals.pbi"
XIncludeFile "../core/Control.pbi"
XIncludeFile "../core/Arguments.pbi"
XIncludeFile "../core/Vector.pbi"
XIncludeFile "../ui/View.pbi"

; ==============================================================================
;  CONTROL NUMBER MODULE DECLARATION
; ==============================================================================
DeclareModule ControlNumber
  #Number_Scalar    = %0001
  #Number_Integer   = %0010
  #Number_Percent   = %0100
  #Number_NoSlider  = %1000

  Structure ControlNumber_t Extends Control::Control_t
    value       .s
    value_n     .d
    hard_min    .d
    hard_max    .d
    soft_min    .d
    soft_max    .d
    undo_esc    .s
    undo_ctz_t  .s
    undo_ctz_g  .i
    undo_ctz_w  .i
    posG        .i ; Strong Cursor
    posW        .i ; Weak   Cursor
    posS        .i
    caret_switch.i
    timer_on    .i
    lookup_dirty.i
    lookup_count.i
    Array lookup.i(0)
  EndStructure
  
  Interface IControlNumber Extends Control::IControl
  EndInterface
  
  Declare New(*parent.Control::Control_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
  Declare Delete(*Me.ControlNumber_t)
  Declare Draw( *Me.ControlNumber_t, xoff.i = 0, yoff.i = 0 )
  Declare OnEvent( *Me.ControlNumber_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )
  Declare SetValue( *Me.ControlNumber_t, value.s )
  Declare.s GetValue( *Me.ControlNumber_t )
  Declare SetTheme( theme.i )
  Declare Init()
  Declare Term()

  DataSection 
    ControlNumberVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i Control::@DrawPickImage()
    Data.i Control::@Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
;  CONTROL NUMBER IMPLEMENTATION ( Helpers )
; ============================================================================
Module ControlNumber
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

  Procedure hlpSelectWord( *Me.ControlNumber_t, cur_pos.i )
    
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

  Procedure.i hlpCharPosFromMousePos( *Me.ControlNumber_t, xpos.i )
    
    xpos - 7
    
    Protected x_start.i = *Me\lookup(*Me\posS)
    Protected i.i
    For i = *Me\posS To *Me\lookup_count
      If ( *Me\lookup(i) - x_start ) > xpos
        ProcedureReturn( Math::Max( 1, i-1 ) )
      EndIf
    Next
    
    ProcedureReturn( *Me\lookup_count - 1 )
    
  EndProcedure
  
  Procedure Draw( *Me.ControlNumber_t, xoff.i = 0, yoff.i = 0 )
    If Not *Me\visible : ProcedureReturn : EndIf
    
    Protected tc.i = UIColor::COLOR_NUMBER_FG
    VectorFont(FontID(Globals::#Font_Bold), Globals::#Font_Size_Label)

    Protected tx.i = 7
    Protected ty.i = ( *Me\sizY - VectorTextHeight( *Me\value ) )/2 + yoff
    
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
    
    If *Me\state & Control::#State_Focused
      Protected posL.i, posR.i, posXL.i, posXR.i
      If *Me\posG > *Me\posW
        posL = *Me\posW : posR = *Me\posG
      Else
        posL = *Me\posG : posR = *Me\posW
      EndIf
      posXL = Math::Max( 0, *Me\lookup(posL) - *Me\lookup(*Me\posS) )
      If posL <> posR
        Globals::BitMaskSet(*Me\state, Control::#State_Selected)
        posXR = Math::Min( tw, *Me\lookup(posR) - *Me\lookup(*Me\posS) )
      Else
        Globals::BitMaskClear(*Me\state, Control::#State_Selected)
      EndIf
    Else
      Protected factor.d = ( *Me\value_n - *Me\soft_min )/( *Me\soft_max - *Me\soft_min )
      Protected slider_w.i = Math::Min( *Me\sizX - 4, Math::Max( 0, factor*( *Me\sizX - 4 ) ) )
      If *Me\options & #Number_NoSlider
        slider_w = *Me\sizX - 4
      EndIf
      
    EndIf
    
    If Not *Me\state & Control::#State_Enable
      Vector::RoundBoxPath(xoff, yoff,  *Me\sizX , *Me\sizY ,2)
      VectorSourceColor(UIColor::COLOR_NUMBER_BG)
      FillPath()
      tc = UIColor::COLOR_LABEL_DISABLED
    ElseIf *Me\state & Control::#State_Focused
      Vector::RoundBoxPath( xoff, yoff, *Me\sizX , *Me\sizY , 2)
      VectorSourceColor(UIColor::COLOR_NUMBER_BG)
      FillPath()
    ElseIf *Me\state & Control::#State_Over
      Vector::RoundBoxPath( xoff, yoff, *Me\sizX , *Me\sizY , 2)
      VectorSourceColor(UIColor::COLOR_NUMBER_BG)
      FillPath()
      If Not *Me\options & #Number_NoSlider
        Vector::RoundBoxPath( xoff+slider_w, yoff, *Me\sizX-slider_w, *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
      EndIf
      
    Else
      Vector::RoundBoxPath( xoff, yoff, *Me\sizX , *Me\sizY , 2)
      VectorSourceColor(UIColor::COLOR_SHADOW)
      FillPath()
      If Not *Me\options & #Number_NoSlider
        Vector::RoundBoxPath( xoff+slider_w, yoff, *Me\sizX-slider_w, *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
      EndIf
      
      If slider_w > *Me\sizX * 0.5
        Vector::RoundBoxPath( xoff, yoff, *Me\sizX , *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_NUMBER_BG)
        FillPath()
        Vector::RoundBoxPath( xoff+slider_w, yoff, *Me\sizX-slider_w, *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_TERNARY_BG)
        FillPath()
        AddPathBox(xoff+slider_w-1, yoff, 2, *Me\sizY)
        VectorSourceColor(UIColor::COLOR_CARET)
        FillPath()
      Else
        Vector::RoundBoxPath( xoff+slider_w, yoff, *Me\sizX-slider_w, *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_NUMBER_FG)
        FillPath()
        Vector::RoundBoxPath( xoff, yoff, *Me\sizX, *Me\sizY , 2)
        VectorSourceColor(UIColor::COLOR_NUMBER_BG)
        FillPath()
        AddPathBox(xoff+slider_w-1, yoff, 2, *Me\sizY)
        VectorSourceColor(UIColor::COLOR_CARET)
        FillPath()
      EndIf
    EndIf
    
    Protected dtext.s = Mid( *Me\value, *Me\posS, tlen )
    
    If *Me\state & Control::#State_Focused
      If *Me\state & Control::#State_Selected
        AddPathBox(tx + xoff + posXL - 1, ty-1, (posXR - posXL) + 2, 14)
        VectorSourceColor(UIColor::COLOR_SELECTED_BG)
        FillPath()
          
        MovePathCursor(tx + xoff, ty)
        VectorSourceColor(UIColor::COLOR_TEXT_ACTIVE)
        DrawVectorText( dtext )
      Else
        MovePathCursor(tx + xoff, ty)
        VectorSourceColor(UIColor::COLOR_TEXT_ACTIVE)
        DrawVectorText(  dtext)
        
        If *Me\caret_switch > 0 Or Not *Me\timer_on
          MovePathCursor(tx + posXL + xoff, ty)
          AddPathLine(1, 13, #PB_Path_Relative)
          VectorSourceColor(UIColor::COLOR_CARET)
          StrokePath(2)
        EndIf
      EndIf
    Else
      Vector::RoundBoxPath( -3 + tx + xoff, ty,   tw+5, 12, 4)
      VectorSourceColor( UIColor::COLOR_SHADOW )
      FillPath()

      MovePathCursor(tx + xoff, ty)
      VectorSourceColor(UIColor::COLOR_NUMBER_FG)
      DrawVectorText( dtext)
    EndIf
    
  EndProcedure


; ============================================================================
;  OVERRIDE ( CControl )
; ============================================================================
Procedure.i OnEvent( *Me.ControlNumber_t, ev_code.i, *ev_data.Control::EventTypeDatas_t = #Null )

  Select ev_code
      
    Case Control::#PB_EventType_Draw
      If Not *ev_data : ProcedureReturn : EndIf
      
      Draw( *Me, *ev_data\xoff, *ev_data\yoff )
      ProcedureReturn( #True )

    Case #PB_EventType_Resize
      If Not *ev_data : ProcedureReturn : EndIf
      
      *Me\sizY = 20
      If #PB_Ignore <> *ev_data\x      : *Me\posX = *ev_data\x      : EndIf
      If #PB_Ignore <> *ev_data\y      : *Me\posY = *ev_data\y      : EndIf
      If #PB_Ignore <> *ev_data\width  : *Me\sizX = *ev_data\width  : EndIf
      ProcedureReturn( #True )
      
    Case #PB_EventType_LostFocus
      
      If *Me\state & Control::#State_Focused
        If *me\options & #Number_Integer
          *Me\value = Str(*Me\value_n)
        Else
          *Me\value = StrD(*Me\value_n,3)
        EndIf
        *Me\lookup_dirty = #True
        Globals::BitMaskClear(*Me\state, Control::#State_Focused)
      EndIf
    
      ;RemoveWindowTimer( #MainWindow, #TIMER_CARET )
      *Me\state = 0
      *Me\posG = 1 : *Me\posW = 1
      Control::Invalidate(*Me)
      
      ProcedureReturn( #True )
      
    Case #PB_EventType_Focus
      Globals::BitMaskSet(*Me\state, Control::#State_Focused)
      *Me\posG = 1 : *Me\posW = 1
      Control::Invalidate(*Me)
    
      ProcedureReturn( #True )
        
    Case #PB_EventType_MouseEnter
      If *Me\visible And *Me\enable
        Globals::BitMaskSet(*Me\state, Control::#State_Over)
        If *Me\state & Control::#State_Focused : Control::SetCursor( *Me,#PB_Cursor_IBeam ) : EndIf
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_MouseLeave
      If *Me\visible And *Me\enable
        Globals::BitMaskClear(*Me\state, Control::#State_Over)
        
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_MouseMove
      If *Me\visible And *Me\enable
        If *Me\state & Control::#State_Down
          If Not *ev_data : ProcedureReturn : EndIf
          If *Me\state & Control::#State_Focused
            *Me\posW = hlpCharPosFromMousePos( *Me, *ev_data\x )
          Else
            If Not *Me\options & ControlNumber::#Number_NoSlider
              *Me\value_n = ( *ev_data\x - 2.0 )/( *Me\sizX - 4.0 )*( *Me\soft_max - *Me\soft_min ) + *Me\soft_min
              If *Me\value_n < *Me\soft_min : *Me\value_n = *Me\soft_min : EndIf
              If *Me\value_n > *Me\soft_max : *Me\value_n = *Me\soft_max : EndIf
              If *Me\options & ControlNumber::#Number_Integer
                *Me\value = Str(*Me\value_n)
              Else
                *Me\value   = StrD( *Me\value_n, 3 )
              EndIf
            EndIf
              *Me\lookup_dirty = #True
          EndIf 

          Callback::Trigger(*Me\on_change, Callback::#SIGNAL_TYPE_PING)
          
          Control::Invalidate(*Me)

        EndIf
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_LeftButtonDown
      If *Me\visible And *Me\enable And *Me\state & Control::#State_Over
        If Not *ev_data : ProcedureReturn :EndIf
        Globals::BitMaskSet(*Me\state, Control::#State_Down)
        If *Me\state & Control::#State_Focused
          If Not *Me\options & ControlNumber::#Number_NoSlider
            *Me\value_n = ( *ev_data\x - 2.0 )/( *Me\sizX - 4.0 )*( *Me\soft_max - *Me\soft_min ) + *Me\soft_min
            If *Me\value_n < *Me\soft_min : *Me\value_n = *Me\soft_min : EndIf
            If *Me\value_n > *Me\soft_max : *Me\value_n = *Me\soft_max : EndIf
            If *Me\options & ControlNumber::#Number_Integer
              *Me\value = Str(*Me\value_n)
            Else
              *Me\value   = StrD( *Me\value_n, 3 )
            EndIf
          EndIf
          *Me\lookup_dirty = #True
        Else
          *Me\posG = hlpCharPosFromMousePos( *Me, *ev_data\x )
          *Me\posW = *Me\posG
        EndIf
     
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_LeftButtonUp
      If *Me\visible And *Me\enable
        Globals::BitMaskClear(*Me\state, Control::#State_Down)
        Control::Invalidate(*Me)
        Callback::Trigger(*Me\on_change,Callback::#SIGNAL_TYPE_PING)
        
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_LeftDoubleClick
      Debug "We have fiuckin double left clicl event"
      If *Me\visible And *Me\enable
        Debug "Focused : "+Str(*Me\state & Control::#State_Focused)
        If *Me\state & Control::#State_Focused
          If Not  *ev_data : ProcedureReturn : EndIf
          
          *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          hlpSelectWord( *Me, hlpCharPosFromMousePos( *Me, *ev_data\x ) )
        Else
          *Me\undo_esc = *Me\value
          Control::SetCursor(*Me, #PB_Cursor_IBeam )
          Control::Focused(*Me)
          *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1          
        EndIf
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_RightButtonDown
      If *Me\visible And *Me\enable
        Globals::BitMaskSet(*Me\state, Control::#State_Down)
        If Not *Me\state & Control::#State_Focused
          Globals::BitMaskSet(*Me\state, Control::#State_Focused)
          *Me\undo_esc = *Me\value
          Control::Focused(*Me)
          Control::SetCursor( *Me,#PB_Cursor_IBeam )
          *Me\posG = 1 : *Me\posW = Len(*Me\value) + 1          
        EndIf
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_RightButtonUp
      If *Me\visible And *Me\enable
        Globals::BitMaskClear(*Me\state, Control::#State_Down)
        Control::Invalidate(*Me)
        ProcedureReturn( #True )
      EndIf
      
    Case #PB_EventType_Input
      If Not *ev_data : ProcedureReturn : EndIf
      
      Debug "input :"+*ev_data\input
      
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
          If *ev_data\modif & #PB_Canvas_Shift
            *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          EndIf
          
          If *me\options & ControlNumber::#Number_Integer
            *Me\value_n = Round(ValD(*Me\value),#PB_Round_Nearest);AEV\Eval( *Me\value )
            *Me\value = Str( *Me\value_n)
          Else
            *Me\value_n = ValD(*Me\value);AEV\Eval( *Me\value )
            *Me\value = StrD( *Me\value_n, 3 )
            
          EndIf
          
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            Control::DeFocused(*Me)
            Control::SetCursor( *Me,#PB_Cursor_Default )
          EndIf
          *Me\posG = 1 : *Me\posW = 1
          *Me\lookup_dirty = #True

          Callback::Trigger(*Me\on_change,Callback::#SIGNAL_TYPE_PING)
          Control::DeFocused(*Me)
          Control::Invalidate(*Me)
          
          ProcedureReturn( #True )

        Case #PB_Shortcut_Escape
          Control::DeFocused(*Me)
          *Me\value = *Me\undo_esc
          *Me\posG = 1 : *Me\posW = 1
          *Me\lookup_dirty = #True
          Control::SetCursor( *Me,#PB_Cursor_Default )
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Tab
        Case #PB_Shortcut_Home
          If Not *ev_data : ProcedureReturn : EndIf
          
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          *Me\posW = 1
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_End
          If Not *ev_data : ProcedureReturn : EndIf
          *Me\undo_ctz_t = *Me\value : *Me\undo_ctz_g = *Me\posG : *Me\undo_ctz_w = *Me\posW
          *Me\posW = Len(*Me\value) + 1
          If Not ( *ev_data\modif & #PB_Canvas_Shift )
            *Me\posG = *Me\posW
          EndIf
          Control::Invalidate(*Me)
          ProcedureReturn( #True )

        Case #PB_Shortcut_Left
          If Not *ev_data : ProcedureReturn : EndIf
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
          If Not *ev_data : ProcedureReturn : EndIf
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
          
      EndSelect 
      
    Case Globals::#Shortcut_Cut
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
      
    Case Globals::#Shortcut_Copy
      If *Me\posG > *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posW, *Me\posG - *Me\posW ) )
      ElseIf *Me\posG <> *Me\posW
        SetClipboardText( Mid( *Me\value, *Me\posG, *Me\posW - *Me\posG ) )
      EndIf
      ProcedureReturn( #True )
      
    Case Globals::#Shortcut_Paste
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
      
    Case Globals::#Shortcut_Undo
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
  ;  IMPLEMENTATION ( CControlNumber )
  ; ============================================================================
  Procedure SetValue( *Me.ControlNumber_t, value.s )
    If value = *Me\value
      ProcedureReturn
    EndIf
    
    *Me\value = value
    *Me\lookup_dirty = #True
    
    Control::Invalidate(*Me)
    
  EndProcedure
  
  Procedure.s GetValue( *Me.ControlNumber_t )
    
    ProcedureReturn( *Me\value )
    
  EndProcedure

  Procedure Init()
    COLOR_BACK_ENABLE = RGB(128,128,128)
    COLOR_BACK_OVER = RGB(164,164,164)
    COLOR_BACK_FOCUSED = RGB(180,180,180)
    COLOR_BACK_DISABLE = RGB(64,64,64)
  EndProcedure
  
  Procedure Term()
  EndProcedure
  
  Procedure SetTheme(theme.i)
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  Procedure Delete( *Me.ControlNumber_t )
    Object::TERM(ControlNumber)
  EndProcedure
  
  ; ============================================================================
  ;  CONSTRUCTOR
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, value.d = 0.0, options.i = 0, hard_min = Math::#F32_MIN, hard_max = Math::#F32_MAX, soft_min = -1.0, soft_max = 1.0, x.i = 0, y.i = 0, width.i = 80, height.i = 18 )
    
    Protected *Me.ControlNumber_t = AllocateStructure(ControlNumber_t)
    
    Object::INI(ControlNumber)
  
    *Me\type         = Control::#Number
    *Me\name         = name
    *Me\parent       = *parent
    *Me\gadgetID     = *parent\gadgetID
    *Me\posX         = x
    *Me\posY         = y
    *Me\sizX         = width
    *Me\sizY         = 20
    *Me\visible      = #True
    *Me\enable       = #True
    *Me\options      = options
    
    If *Me\options & ControlNumber::#Number_Integer
      *Me\value = Str(value)
    Else
      *Me\value        = StrD( value, 3 )
    EndIf
    
    *Me\value_n      = value
    *Me\hard_min     = hard_min
    *Me\hard_max     = hard_max
    *Me\soft_min     = soft_min
    *Me\soft_max     = soft_max
    *Me\undo_esc     = ""
    *Me\undo_ctz_t   = ""
    *Me\state        = 0
    *Me\posG         = 1
    *Me\posW         = 1
    *Me\posS         = 1
    *Me\caret_switch = 1
    *Me\timer_on     = #False
    *Me\lookup_dirty = #True
    *Me\lookup_count = 0
   
    
    *Me\on_change = Object::NewCallback(*Me, "OnChange")
    
    ProcedureReturn( *Me )
    
  EndProcedure

  Class::DEF( ControlNumber )
EndModule


; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 501
; FirstLine = 473
; Folding = ---
; EnableXP