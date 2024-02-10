XIncludeFile "Object.pbi"
XIncludeFile "Callback.pbi"
XIncludeFile "UIColor.pbi"

; ==============================================================================
;  CONTROL MODULE DECLARATION
; ==============================================================================
DeclareModule Control
  Enumeration
    #PB_EventType_Draw = 128
    #PB_EventType_DrawChild
    #PB_EventType_ChildFocused
    #PB_EventType_ChildDeFocused
    #PB_EventType_ChildCursor
    #PB_EventType_Show
    #PB_EventType_Hide
    #PB_EventType_Enable
    #PB_EventType_Disable
    #PB_EventType_Attribute
  EndEnumeration
  
  Enumeration
    #State_Visible      = 1 << 1
    #State_Enable       = 1 << 2
    #State_Over         = 1 << 3
    #State_Focused      = 1 << 4
    #State_Down         = 1 << 5
    #State_Selected     = 1 << 6
    #State_Collapsed    = 1 << 7
  EndEnumeration
  
  Enumeration
    #Type_Check
    #Type_Icon
    #Type_Button
    #Type_Radio
    #Type_Enum
    #Type_Label
    #Type_Divot
    #Type_Edit
    #Type_Popup
    #Type_Text
    #Type_Input
    #Type_Number
    #Type_Group
    #Type_ColorWheel
    #Type_Color
    #Type_ShaderCode
    #Type_Explorer
    #Type_Scintilla
  EndEnumeration

  Structure EventTypeDatas_t
    x     .i
    y     .i
    width .i
    height.i
    xoff  .i
    yoff  .i
    input .s
    key   .i
    modif .i
    *datas
  EndStructure
  
  Structure Control_t  Extends Object::Object_t
    *parent    .Control_t
    type       .i
    name       .s
    gadgetID   .i
    posX       .i
    posY       .i
    sizX       .i
    sizY       .i
    percX      .i
    percY      .i
    fixedX     .i
    fixedY     .i
    visible    .i
    enable     .i
    options    .i
    state      .i
    *on_change.Callback::Callback_t 
  EndStructure
  
  Interface IControl
    OnEvent( ev_code.i, *ev_data.EventTypeDatas_t = #Null )
    Delete()
    Pick(*Me.Control_t, mx, my)
  EndInterface
  
  Declare Delete(*Me.Control_t)
  Declare Draw(*Me.Control_t)
  Declare DrawPickImage(*Me.Control_t, id.i)
  Declare Pick(*Me.Control_t, mx, my)
  
  Declare GetGadgetID(*Me.Control_t)
  Declare GetType(*Me.Control_t)
  Declare SetName( *Me.Control_t, name.s )
  Declare.s GetName( *Me.Control_t )
  Declare.i Show( *Me.Control_t )
  Declare.i Hide( *Me.Control_t )
  Declare Enable( *Me.Control_t )
  Declare Disable( *Me.Control_t )
  Declare Resize( *Me.Control_t, x.i, y.i, width.i, height.i = 22 )
  Declare Invalidate(*Me.Control_t)
  Declare Focused( *Me.Control_t )
  Declare DeFocused( *Me.Control_t )
  Declare SetCursor( *Me.Control_t, cursor_id.i )
  Declare SetFixed( *Me.Control_t, fixedX.b, fixedY.b)
  Declare SetPercentage(*Me.Control_t, percX.i, percY.i)
  Declare GetUI(*Me.Control_t)
  
  Global MARGING.i = 6
  Global PADDING.i = 4
  Global CORNER_RADIUS.f = 4
  Global FRAME_THICKNESS.f = 0.2
  
EndDeclareModule

; ==============================================================================
;  CONTROL MODULE IMPLEMENTATION
; ==============================================================================
Module Control
  
  Procedure Draw(*Me.Control_t)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(UIColor::RANDOMIZED)
    FillPath()
  EndProcedure
  
  Procedure DrawPickImage(*Me.Control_t, id.i)
    AddPathBox(*Me\posX, *Me\posY, *Me\sizX, *Me\sizY)
    VectorSourceColor(RGBA(id, 0,0,255))
    FillPath()
  EndProcedure
  
  Procedure Pick(*Me.Control_t, mx, my)
    If mx > *Me\posX And mx < *Me\posX + *Me\sizX And my > *Me\posY And my <*Me\posY + *Me\sizY
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure Delete(*Me.Control_t)
    Object::TERM(Control)
  EndProcedure

  Procedure.i GetGadgetID( *Me.Control_t )
    ProcedureReturn( *Me\gadgetID )
  EndProcedure
  
  Procedure.i GetType( *Me.Control_t )
    ProcedureReturn( *Me\type )
  EndProcedure
  
  Procedure SetName( *Me.Control_t, name.s )
    *Me\name = name
  EndProcedure
  
  Procedure.s GetName( *Me.Control_t )
    ProcedureReturn( *Me\name )
  EndProcedure
  
  Procedure.i Show( *Me.Control_t )
    If Not *Me\visible
      *Me\visible = #False
      HideGadget(*Me\gadgetID,1)
    EndIf
  EndProcedure
  
  Procedure.i Hide( *Me.Control_t )
    If *Me\visible
      *Me\visible = #True
      HideGadget(*Me\gadgetID,0)
    EndIf
  EndProcedure
  
  Procedure.i Enable( *Me.Control_t )
    Protected Me.IControl = *Me
    If Not Me\OnEvent( #PB_EventType_Enable )
      DisableGadget( *Me\gadgetID, 0 )
      *Me\enable = #True
    EndIf
    ProcedureReturn( #Null )
  EndProcedure
  
  Procedure.i Disable( *Me.Control_t )
    Protected Me.IControl = *Me
    If Not Me\OnEvent( #PB_EventType_Disable )
      DisableGadget( *Me\gadgetID, 1 )
      *Me\enable = #False
    EndIf
    ProcedureReturn( #Null )
  EndProcedure
  
  Procedure Resize( *Me.Control_t, x.i, y.i, width.i, height.i = 22 )
    If Not *Me : ProcedureReturn : EndIf
    Protected Me.IControl = *Me
    Protected ev_datas.EventTypeDatas_t
    
    ev_datas\x      = x
    ev_datas\y      = y
    ev_datas\width  = width
    ev_datas\height = height
    
    If Not Me\OnEvent( #PB_EventType_Resize, ev_datas )
      If #PB_Ignore <> x      : *Me\posX = x      : EndIf
      If #PB_Ignore <> y      : *Me\posY = y      : EndIf
      If #PB_Ignore <> width  : *Me\sizX = width  : EndIf
      If #PB_Ignore <> height : *Me\sizY = height : EndIf
    EndIf
    
  EndProcedure

  Procedure SetAttribute( *Me.Control_t, attribute.i, i_value.i, d_value.d, s_value.s )
    Protected Me.IControl = *Me
    
    If Not Me\OnEvent( #PB_EventType_Attribute ) 
    EndIf
  EndProcedure
  
  Procedure.i GetAttribute( *Me.Control_t, attribute.i, *value_out )
    
  EndProcedure
  
  Procedure.i Invalidate( *Me.Control_t )
    If *Me\parent And Not *Me\parent\class\name = "View"
      Protected *parent.IControl = *Me\parent
      Define ev_data.Control::EventTypeDatas_t
      ev_data\datas = *Me
      *parent\OnEvent( #PB_EventType_DrawChild, ev_data )
    EndIf
    
  EndProcedure
  
  Procedure.i Focused( *Me.Control_t )
    If *Me\parent
      Protected *parent.IControl = *Me\parent
      Protected ev_data.Control::EventTypeDatas_t
      ev_data\datas = *Me
      *parent\OnEvent( #PB_EventType_ChildFocused, ev_data )
    EndIf
    Globals::BitMaskSet(*Me\state, Control::#State_Focused)
  EndProcedure
  
  Procedure.i DeFocused( *Me.Control_t )
    If *Me\parent
      Protected *parent.IControl = *Me\parent
      Protected ev_data.Control::EventTypeDatas_t
      ev_data\datas = *Me
      *parent\OnEvent( #PB_EventType_ChildDeFocused, ev_data )
    EndIf
    Globals::BitMaskClear(*Me\state, Control::#State_Focused)
  EndProcedure
  
  Procedure.i SetCursor( *Me.Control_t, cursor_id.i )
    If *Me\parent
      Protected *parent.IControl = *Me\parent
      Protected ev_data.Control::EventTypeDatas_t
      ev_data\datas = cursor_id
      *parent\OnEvent( #PB_EventType_ChildCursor, ev_data )
    EndIf
  EndProcedure
  
  Procedure SetFixed( *Me.Control_t, fixedX.b, fixedY.b)
    If fixedX <> #PB_Ignore : *Me\fixedX = fixedX : EndIf
    If fixedY <> #PB_Ignore : *Me\fixedY = fixedY : EndIf
  EndProcedure
  
  Procedure SetPercentage(*Me.Control_t, percX.i, percY.i)
    If percX <> #PB_Ignore : *Me\percX = percX : EndIf
    If percY <> #PB_Ignore : *Me\percY = percY : EndIf
  EndProcedure
  
  Procedure GetUI(*Me.Control_t)
    If *Me\parent
      ProcedureReturn GetUI(*Me\parent)
    EndIf
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 206
; FirstLine = 193
; Folding = -----
; EnableXP
; EnableUnicode