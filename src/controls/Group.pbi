XIncludeFile "../core/Control.pbi"

; ============================================================================
;  DECLARATION Control Group
; ============================================================================
DeclareModule ControlGroup

  #Autosize_H = 1 << 20
  #Autosize_V = 1 << 21
  #Autostack  = 1 << 22
  #NoFrame    = 1 << 23
  
  Structure ControlGroup_t Extends Control::Control_t
    imageID   .i
    label     .s
    append    .i
    row       .i
    down      .i
    overchild .Control::IControl
    focuschild.Control::IControl
    Array children .Control::IControl(10)
    Array rowflags .i(10)
    chilcount .i
    current   .i
    closed    .b
  EndStructure
  
  Declare New( *parent.Control::Control_t, name.s, label.s, x.i = 0, y.i = 0, width.i = 240, height.i = 120, options.i = #Autosize_V|#Autostack )
  Declare Delete(*Me.ControlGroup_t)
  Declare Draw( *Me.ControlGroup_t, init.b=#False)
  Declare OnEvent(*Me.ControlGroup_t,event.i,*datas.Control::EventTypeDatas_t)
  Declare DrawPickImage(*Me.ControlGroup_t)
  Declare Pick(*Me.ControlGroup_t)
  Declare SetLabel( *Me.ControlGroup_t, value.s )
  Declare.s GetLabel( *Me.ControlGroup_t )
  Declare AppendStart( *Me.ControlGroup_t )
  Declare Append( *Me.ControlGroup_t, ctl.Control::IControl )
  Declare AppendStop( *Me.ControlGroup_t )
  Declare RowStart( *Me.ControlGroup_t )
  Declare RowEnd( *Me.ControlGroup_t )
  Declare GetNumControlInRow(*Me.ControlGroup_t, base.i)
  Declare ResizeControlsInRow(*Me.ControlGroup_t, start_index.i, num_controls.i)

  DataSection 
    ControlGroupVT: 
    Data.i @OnEvent()
    Data.i @Delete()
    Data.i @Draw()
    Data.i @DrawPickImage()
    Data.i @Pick()
  EndDataSection
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
;  IMPLEMENTATION Control Group
; ============================================================================
Module ControlGroup

  Procedure.i Resize( *Me.ControlGroup::ControlGroup_t, *ev_data.Control::EventTypeDatas_t )

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
    
    If *ev_data
      If ( *ev_data\x <> #PB_Ignore ) And ( *ev_data\x <> *Me\posX )
        dirty = #True
        *Me\posX = *ev_data\x
      EndIf
      If ( *ev_data\y <> #PB_Ignore ) And ( *ev_data\y <> *Me\posY )
        dirty = #True
        *Me\posY = *ev_data\y
      EndIf

      If ( *ev_data\width <> #PB_Ignore ) And ( *ev_data\width <> *Me\sizX )
        dirty = #True
        *Me\sizX = *ev_data\width
      EndIf
      
    EndIf

    If *Me\options & #Autostack
      If lablen : curV = 20 : Else : curV = 14 : EndIf
      curH = 10
      maxV = 0
      For i=0 To iBound
        *Son  = *Me\children(i)
        Control::Resize(*Son, curH, curV, #PB_Ignore, #PB_Ignore )
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
      *Me\sizY = curV
    EndIf
   
    If *Me\options & #Autosize_H
      maxV = 0 : curV = 0
      For i=0 To iBound
        Son = *Me\children(i)
        curV = *Son\posX + *Son\sizX
        If curV > maxV : maxV = curV : EndIf
      Next
      If maxV <> *Me\sizX : *Me\sizX = maxV + 10 : dirty = #True : EndIf
    Else
      curV = *Me\sizX - 20
      curH = curV
      maxV = 0
      
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
  
    
    If *Me\options & #Autosize_V
      maxV = 0
      For i=0 To iBound
        *Son  = *Me\children(i)
        curV = *Son\posY + *Son\sizY
        If curV > maxV : maxV = curV : EndIf
      Next
      If maxV <> *Me\sizY + 9: *Me\sizY = maxV + 9 : dirty = #True : EndIf
    EndIf
    
    If #True = dirty
      ResizeImage ( *Me\imageID, *Me\sizX, *Me\sizY )
    EndIf
  
    ProcedureReturn( dirty )
    
  EndProcedure
  
  Procedure GetNumControlInRow(*Me.ControlGroup_t, base.i)
    Protected index = base
    Protected search.b = #True
    While search
      If Not *Me\rowflags(index) : search = #False : EndIf
      index+1
    Wend
    ProcedureReturn index - base
  EndProcedure
  
  Procedure ResizeControlsInRow(*Me.ControlGroup_t, start_index.i, num_controls.i)

    Dim widths.i(num_controls)
    Define fixed_width = Control::MARGING * 2
    Define current_width, current_index, num_fixed
    Define *child.Control::Control_t
    Define e
    For i=0 To num_controls - 1
      current_index = start_index + i
      *child = *Me\children(current_index)
      If *child\fixedX
        current_width = *child\sizX 
        fixed_width + current_width + Control::PADDING
        widths(i) = current_width
        num_fixed + 1
      EndIf
    Next
    Define remaining_width = *Me\sizX - (fixed_width + Control::MARGING)
    Define x = Control::MARGING
    Define ev_data.Control::EventTypeDatas_t
    ev_data\x = 0
    ev_data\y = #PB_Ignore
    ev_data\width = #PB_Ignore
    ev_data\height = #PB_Ignore
    
    Define *son.Control::Control_t
    Define y = 0
    For i=0 To num_controls - 1
      current_index = start_index + i
      *son = *Me\children(current_index)
      If *son\sizY > y
        y = *son\sizY
      EndIf

      If *son\fixedX
        ev_data\width = widths(i)
      Else
        ev_data\width = remaining_width / (num_controls - num_fixed)
      EndIf

      ev_data\x     = *Me\posX + x
      ev_data\y     = #PB_Ignore
      *Me\children(current_index)\OnEvent(#PB_EventType_Resize, ev_data)
      x + ev_data\width + Control::PADDING
    Next
    ProcedureReturn y + Control::MARGING
  EndProcedure

  Procedure Draw( *Me.ControlGroup_t, init.b=#False)
    If init
      StartVectorDrawing( CanvasVectorOutput(*Me\gadgetID) )
      ResetCoordinates()
      AddPathBox( *Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
      VectorSourceColor(UIColor::COLOR_MAIN_BG)
      FillPath()
    EndIf
    
    Protected label.s = *Me\label
    Protected lalen.i = Len(label)
    Protected maxW .i = *Me\sizX - 21
    Protected curW .i
    
    VectorFont( FontID(Globals::#Font_Bold ),Globals::#Font_Size_Label)
    
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
      VectorSourceColor(UIColor::COLOR_SECONDARY_BG)

      FillPath(#PB_Path_Preserve)
      VectorSourceColor(UIColor::COLOR_GROUP_FRAME )
      StrokePath(Control::FRAME_THICKNESS, #PB_Path_RoundCorner)
      
    EndIf
    
    MovePathCursor(*Me\posX+15,  *Me\posY)
    VectorSourceColor(UIColor::COLOR_GROUP_LABEL )
    DrawVectorText( label )
    
    If *Me\chilcount < 1 : ProcedureReturn : EndIf
    
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount - 1
    Protected  son  .Control::IControl
    Protected *son  .Control::Control_t
    
    Protected ev_data.Control::EventTypeDatas_t  
    For i=0 To iBound
       *son = *Me\children(i)
       son = *son
       
      ev_data\xoff = *Me\posX+*son\posX
      ev_data\yoff = *Me\posY+*son\posY
      
      son\OnEvent( Control::#PB_EventType_Draw, ev_data )
    Next
    
    If init : StopVectorDrawing() : EndIf 

  EndProcedure

  Procedure Pick(*Me.ControlGroup_t)
    Protected pickID
    Protected xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
    Protected ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
    
    xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
    ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
      
    StartDrawing( ImageOutput(*Me\imageID) )
    pickID = Point(xm,ym) - 1
    StopDrawing()
    
    ProcedureReturn pickID
  EndProcedure

  Procedure DrawPickImage( *Me.ControlGroup_t )
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount-1
    Protected *son  .Control::Control_t
    
    If Not ImageWidth(*Me\imageID) = *Me\sizX Or Not ImageHeight(*Me\imageID) = *Me\sizY
      ResizeImage(*Me\imageID, *Me\sizX, *Me\sizY)
    EndIf
  
    StartVectorDrawing( ImageVectorOutput( *Me\imageID ) )
    ResetCoordinates()
    AddPathBox( 0, 0, *Me\sizX, *Me\sizY)
    VectorSourceColor(RGBA(0,0,0,0))
    FillPath()
    For i=0 To iBound
      *son = *Me\children(i)
      AddPathBox(*son\posX, *son\posY, *son\sizX, *son\sizY)
      VectorSourceColor(RGBA(i+1,0,0,255))
      FillPath()
     Next
     StopVectorDrawing()
  EndProcedure

  Procedure NextItem( *Me.ControlGroup_t )
    StartDrawing( ImageOutput(*Me\imageID) )
    Protected *focuschild.Control::Control_t = *Me\focuschild
    Protected idx = Point(*focuschild\posX+1,*focuschild\posY+1) - 1
    StopDrawing()
    If *Me\focuschild
      *Me\focuschild\OnEvent( #PB_EventType_LostFocus, #Null )
      Protected iBound.i = *Me\chilcount - 1
      Protected n.i = (idx+1)%iBound
      Protected ev_data.Control::EventTypeDatas_t 
      *Me\focuschild = *Me\children(n)
      *Me\focuschild\OnEvent(#PB_EventType_Focus,ev_data)
    EndIf
  EndProcedure

  ; ============================================================================
  ;  OVERRIDE ( CControl )
  ; ============================================================================
  Procedure.i OnEvent( *Me.ControlGroup_t, ev_code.i, *ev_data.Control::EventTypeDatas_t )
    Protected i=0
    Protected *ctrl.Control::Control_t 
    
    Protected *son.Control::Control_t
    Protected  son.Control::IControl
    
    Select ev_code
      Case #PB_EventType_Resize
        Resize( *Me, *ev_data)
        Draw( *Me, #True)
        ControlGroup::DrawPickImage(*Me)
        ProcedureReturn( #True )

      Case Control::#PB_EventType_DrawChild
        *son = *ev_data\datas
        son = *son
        *ev_data\xoff    = *son\posX+*Me\posX
        *ev_data\yoff    = *son\posY+*Me\posY
        StartVectorDrawing(CanvasVectorOutput(*Me\gadgetID))
        AddPathBox( *ev_data\xoff, *ev_data\yoff, *son\sizX, *son\sizY)
        VectorSourceColor(UIColor::COLOR_MAIN_BG )
        FillPath()
        son\OnEvent( Control::#PB_EventType_Draw, *ev_data )
        StopVectorDrawing()
        ProcedureReturn #True
          
      Case Control::#PB_EventType_Draw
        Draw( *Me )
        ProcedureReturn #True
        
      Case Control::#PB_EventType_ChildFocused
        *Me\focuschild = *ev_data\datas
        ProcedureReturn #True
        
      Case Control::#PB_EventType_ChildDeFocused
        *Me\focuschild = #Null
        ProcedureReturn #True
        
      Case Control::#PB_EventType_ChildCursor
        SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, *ev_data\datas )
        
      Case #PB_EventType_LostFocus
        If *Me\focuschild
          Define focuschild.Control::IControl = *Me\focuschild
          focuschild\OnEvent( #PB_EventType_LostFocus, *ev_data )
          *Me\focuschild = #Null
        EndIf
        
      Case #PB_EventType_MouseMove
        Protected *overchild.Control::Control_t = #Null
        xm = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *Me\posX
        ym = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *Me\posY
        
        xm = Math::Min( Math::Max( xm, 0 ), *Me\sizX - 1 )
        ym = Math::Min( Math::Max( ym, 0 ), *Me\sizY - 1 )
        
        Protected pickID = Pick(*Me) 
        If pickID > -1 And pickID <*Me\chilcount
          *overchild = *Me\children(pickID)
        EndIf
        
        If *Me\overchild <> *overchild And  Not *Me\down
          If *Me\overchild : *Me\overchild\OnEvent(#PB_EventType_MouseLeave, *ev_data) : EndIf
          *Me\overchild = *overchild
          If *Me\overchild
            *Me\overchild\OnEvent(#PB_EventType_MouseEnter, *ev_data)
          EndIf
        ElseIf *overchild
          *Me\overchild = *overchild
          *ev_data\x    = xm - *overchild\posX
          *ev_data\y    = ym - *overchild\posY
          *ev_data\yoff = 50
         Else
            SetGadgetAttribute( *Me\gadgetID, #PB_Canvas_Cursor, #PB_Cursor_Default )
        EndIf
        
      Case #PB_EventType_LeftButtonDown
        *Me\down = #True
        
         If *Me\focuschild And ( *overchild <> *Me\focuschild )
           Control::DeFocused(*Me\focuschild)
         EndIf
         If *overchild
           *Me\overchild = *overchild
           Control::Focused(*Me\overchild)
         EndIf
      
      Case #PB_EventType_LeftButtonUp
        *Me\down = #False
        
      Case #PB_EventType_LeftDoubleClick

        
      Case #PB_EventType_RightButtonDown
        *Me\down = #True
        
      Case #PB_EventType_RightButtonUp
        *Me\down = #False
        
      Case #PB_EventType_Input
        *ev_data\input = Chr(GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Input))
        
      Case #PB_EventType_KeyDown
        *ev_data\key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Key)
        *ev_data\modif = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
        
      Case #PB_EventType_KeyUp
        *ev_data\key = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Key)
        *ev_data\modif = GetGadgetAttribute(*Me\gadgetID, #PB_Canvas_Modifiers)
        
    EndSelect
    
    If *Me\focuschild
      Define *focuschild.Control::Control_t = *Me\focuschild
      *ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *focuschild\posX
      *ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *focuschild\posY
      *Me\focuschild\OnEvent(ev_code, *ev_data)
      
    ElseIf *Me\overchild
      Define *overchild.Control::Control_t = *Me\overchild
      *ev_data\x = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseX ) - *overchild\posX
      *ev_data\y = GetGadgetAttribute( *Me\gadgetID, #PB_Canvas_MouseY ) - *overchild\posY
      *Me\overchild\OnEvent(ev_code, *ev_data)
      
    EndIf

    ProcedureReturn( #False )
    
  EndProcedure

  ; ============================================================================
  ;  IMPLEMENTATION ( ControlGroup_t )
  ; ============================================================================
  Procedure SetLabel( *Me.ControlGroup_t, value.s )
    *Me\label = value
    Control::Invalidate( *Me )
  EndProcedure
  
  Procedure.s GetLabel( *Me.ControlGroup_t )
    ProcedureReturn( *Me\label )
  EndProcedure
  
  Procedure AppendStart( *Me.ControlGroup_t )
    If *Me\append : ProcedureReturn( void ) : EndIf
    *Me\append = #True
  EndProcedure
  
  Procedure.i Append( *Me.ControlGroup_t, ctl.Control::IControl )
    If Not ctl : ProcedureReturn : EndIf
  
    If #False = *Me\append
      ProcedureReturn( #False)
    EndIf
    
    Protected *ctl.Control::Control_t = ctl
    Protected Me.Control::IControl     = *Me
  
    If *Me\chilcount > ArraySize( *Me\children() )
      ReDim *Me\children( *Me\chilcount + 10 )
      ReDim *Me\rowflags( *Me\chilcount + 10 )
    EndIf
    
    *ctl\parent = Me
    *Me\children( *Me\chilcount ) = ctl
    *Me\rowflags( *Me\chilcount ) = *Me\row
    *Me\chilcount + 1
    
    ProcedureReturn( ctl )
  EndProcedure
  
  Procedure AppendStop( *Me.ControlGroup_t )
    If Not *Me\append : ProcedureReturn( void ) : EndIf
    *Me\append = #False
    Resize( *Me, #Null )
    DrawPickImage(*Me)
  EndProcedure
  
  Procedure RowStart( *Me.ControlGroup_t )
    If *Me\row : ProcedureReturn( void ) : EndIf
    *Me\row = #True
  EndProcedure
  
  Procedure RowEnd( *Me.ControlGroup_t )
    If Not *Me\row : ProcedureReturn( void ) : EndIf
    *Me\rowflags( *Me\chilcount - 1 ) = #False
    *Me\row = #False
  EndProcedure

  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure.i New(*parent.Control::Control_t, name.s, label.s, x.i = 0, y.i = 0, width.i = 240, height.i = 120, options.i = #Autosize_V|#Autostack )
    
    Protected *Me.ControlGroup_t = AllocateStructure(ControlGroup_t)
  
    Object::INI(ControlGroup)
    
    If width < 50 : width = 50 : EndIf
    
    *Me\type       = Control::#GROUP
    *Me\name       = name
    *Me\parent     = *parent
    If Not *Me\parent Or Not IsGadget(*Me\parent\gadgetID)
      *Me\gadgetID   = CanvasGadget( #PB_Any, x, y, width, height, #PB_Canvas_Keyboard )
    Else
      *Me\gadgetID = *Me\parent\gadgetID
    EndIf
    
    *Me\imageID    = CreateImage( #PB_Any, width, height, 32, #PB_Image_Transparent)
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
    
    ProcedureReturn( *Me )
    
  EndProcedure
  
  Procedure Delete( *Me.ControlGroup_t )
    Protected i     .i = 0
    Protected iBound.i = *Me\chilcount - 1
    
    Define *child.Control::IControl
    For i=0 To iBound
      *child = *Me\children(i)
      *child\Delete()
    Next

    FreeArray( *Me\rowflags() )
    FreeArray( *Me\children() )
    FreeImage( *Me\imageID )
    
    Object::TERM( ControlGroup )
    
  EndProcedure
  
  Class::DEF( ControlGroup )
EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 286
; FirstLine = 287
; Folding = ----
; EnableXP