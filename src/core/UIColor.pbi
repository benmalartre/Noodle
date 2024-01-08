XIncludeFile "Globals.pbi"

DeclareModule UIColor
    
  Macro RGB2RGBA(color,alpha)
   RGBA(Red(color),Green(color),Blue(color),alpha)
  EndMacro
   
  Macro RGBA2RGB(color)
    RGB(Red(color),Green(color),Blue(color))  
  EndMacro
  
  Enumeration
    #LIGHT_THEME
    #DARK_THEME
    #CUSTOM_THEME
  EndEnumeration
  
  Structure CustomTheme_t
    
  EndStructure

  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  Light Colors
  ; ----------------------------------------------------------------------------
  ;{
  ; ---[ RGBA ]------------------------------------------------------------------
  #COLOR_LIGHT_MAIN_BG              = $FF8F8F8F
  #COLOR_LIGHT_SECONDARY_BG         = $FF9F9F9F
  #COLOR_LIGHT_TERNARY_BG           = $FFA9A9A9
  #COLOR_LIGHT_SHADOW               = $2F000000
  #COLOR_LIGHT_LABEL                = $FF000000
  #COLOR_LIGHT_LABEL_NEG            = $FFFFFFFF
  #COLOR_LIGHT_LABEL_DISABLED       = $FF333333
  #COLOR_LIGHT_LABEL_MARKED         = $FF349AAB
  #COLOR_LIGHT_LABEL_MARKED_DIMMED  = $B3339AAB
  #COLOR_LIGHT_FRAME_DISABLED       = $77A3A3A3
  #COLOR_LIGHT_FRAME_OVERED         = $FFB9B9B9
  #COLOR_LIGHT_FRAME_DEFAULT        = $FFB5B5B5
  #COLOR_LIGHT_FRAME_ACTIVE         = $FFC9C9C9
  #COLOR_LIGHT_LINE_DIMMED          = $55000000
  #COLOR_LIGHT_GROUP_FRAME          = $FFB5B5B5
  #COLOR_LIGHT_GROUP_LABEL          = $FF000000
  #COLOR_LIGHT_CARET                = $FF000000
  #COLOR_LIGHT_TEXT_DEFAULT         = $FF000000
  #COLOR_LIGHT_TEXT_ACTIVE          = $FF000000
  #COLOR_LIGHT_SELECTED_BG          = $FFE7E7FF
  #COLOR_LIGHT_SELECTED_FG          = $FF0A0A0A
  #COLOR_LIGHT_ACTIVE_BG            = $FFE7E7E7
  #COLOR_LIGHT_ACTIVE_FG            = $FF0A0A0A
  #COLOR_LIGHT_DISABLED_BG          = $FF777777
  #COLOR_LIGHT_DISABLED_FG          = $FFAAAAAA
  #COLOR_LIGHT_NUMBER_BG            = $FFCCCCCC
  #COLOR_LIGHT_NUMBER_FG            = $FF000000
  #COLOR_LIGHT_SPLITTER             = $FFFFFFFF
  ;}
  

  ;}
  ; ----------------------------------------------------------------------------
  ;  Dark Colors
  ; ----------------------------------------------------------------------------
  ;{
  ;----[ RGBA ]-----------------------------------------------------------------
  #COLOR_DARK_MAIN_BG             = $FF292929
  #COLOR_DARK_SECONDARY_BG        = $FF2F2F2F
  #COLOR_DARK_TERNARY_BG          = $FF373737
  #COLOR_DARK_SHADOW              = $0FFFFFFF
  #COLOR_DARK_LABEL               = $FFC1C1C1
  #COLOR_DARK_LABEL_NEG           = $FFB6D1D8
  #COLOR_DARK_LABEL_DISABLED      = $77B6D1D8
  #COLOR_DARK_LABEL_MARKED        = $FF7ECBD8
  #COLOR_DARK_LABEL_MARKED_DIMMED = $777ECBD8
  #COLOR_DARK_FRAME_DISABLED      = $FF555555
  #COLOR_DARK_FRAME_OVERED        = $FFAAAAAA
  #COLOR_DARK_FRAME_DEFAULT       = $FF777777
  #COLOR_DARK_FRAME_ACTIVE        = $FF999999
  #COLOR_DARK_LINE_DIMMED         = $55FFFFFF
  #COLOR_DARK_GROUP_FRAME         = $33FFFFFF
  #COLOR_DARK_GROUP_LABEL         = $FFFFFFFF
  #COLOR_DARK_CARET               = $FF000000
  #COLOR_DARK_TEXT_DEFAULT        = $FFFFFFFF
  #COLOR_DARK_TEXT_ACTIVE         = $FF000000
  #COLOR_DARK_SELECTED_BG         = $FFFF0000
  #COLOR_DARK_SELECTED_FG         = $FF111111
  #COLOR_DARK_ACTIVE_BG           = $FFEEEEEE
  #COLOR_DARK_ACTIVE_FG           = $FF111111
  #COLOR_DARK_DISABLED_BG         = $FF333333
  #COLOR_DARK_DISABLED_FG         = $FF666666
  #COLOR_DARK_NUMBER_BG           = $FF454545
  #COLOR_DARK_NUMBER_FG           = $FFCCCCCC
  #COLOR_LIGHT_SPLITTER           = $FFFFFFFF
  ;}
  
  
  
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ---[ RGBA ]------------------------------------------------------------------
  Global COLOR_MAIN_BG            .i
  Global COLOR_SECONDARY_BG       .i
  Global COLOR_TERNARY_BG         .i
  Global COLOR_SHADOW             .i
  Global COLOR_LABEL              .i
  Global COLOR_LABEL_NEG          .i
  Global COLOR_LABEL_DISABLED     .i
  Global COLOR_LABEL_MARKED       .i
  Global COLOR_LABEL_MARKED_DIMMED.i
  Global COLOR_FRAME_DISABLED     .i
  Global COLOR_FRAME_OVERED       .i
  Global COLOR_FRAME_DEFAULT      .i
  Global COLOR_FRAME_ACTIVE       .i
  Global COLOR_LINE_DIMMED        .i
  Global COLOR_GROUP_FRAME        .i
  Global COLOR_GROUP_LABEL        .i
  Global COLOR_CARET              .i
  Global COLOR_TEXT_ACTIVE        .i
  Global COLOR_TEXT_DEFAULT       .i
  Global COLOR_SELECTED_BG        .i
  Global COLOR_SELECTED_FG        .i
  Global COLOR_ACTIVE_BG          .i
  Global COLOR_ACTIVE_FG          .i
  Global COLOR_DISABLED_FG        .i
  Global COLOR_NUMBER_BG          .i
  Global COLOR_NUMBER_FG          .i
  Global COLOR_SPLITTER           .i
  ;}
  
  Global FILL.i = RGBA(64,180,255,255)
  Global STROKE.i = RGBA(0,0,0,255)
  
  Macro RANDOMIZED
    RGBA(Random(255), Random(255), Random(255), 255)
  EndMacro
  
  Macro RANDOMIZEDWITHALPHA
    RGBA(Random(255), Random(255), Random(255), Random(255))
  EndMacro
  
  Declare Init()
  Declare SetTheme(theme.i)
  Declare Hovered(color.i)
  
EndDeclareModule

Module UIColor
  ; ============================================================================
  ;  PROCEDURES
  ; ============================================================================
  ;{
  Procedure SetTheme( theme.i )
    
    Select theme
        
      ; ---[ Light ]------------------------------------------------------------
      Case Globals::#GUI_THEME_LIGHT
        ; ...[ RGBA ]............................................................
        COLOR_MAIN_BG              = #COLOR_LIGHT_MAIN_BG
        COLOR_SECONDARY_BG         = #COLOR_LIGHT_SECONDARY_BG
        COLOR_TERNARY_BG            = #COLOR_LIGHT_TERNARY_BG
        COLOR_SHADOW               = #COLOR_LIGHT_SHADOW
        COLOR_LABEL                = #COLOR_LIGHT_LABEL
        COLOR_LABEL_NEG            = #COLOR_LIGHT_LABEL_NEG
        COLOR_LABEL_DISABLED       = #COLOR_LIGHT_LABEL_DISABLED
        COLOR_LABEL_MARKED         = #COLOR_LIGHT_LABEL_MARKED
        COLOR_LABEL_MARKED_DIMMED  = #COLOR_LIGHT_LABEL_MARKED_DIMMED
        COLOR_FRAME_DISABLED       = #COLOR_LIGHT_FRAME_DISABLED
        COLOR_FRAME_OVERED         = #COLOR_LIGHT_FRAME_OVERED
        COLOR_FRAME_DEFAULT        = #COLOR_LIGHT_FRAME_DEFAULT
        COLOR_FRAME_ACTIVE         = #COLOR_LIGHT_FRAME_ACTIVE
        COLOR_LINE_DIMMED          = #COLOR_LIGHT_LINE_DIMMED
        COLOR_GROUP_FRAME          = #COLOR_LIGHT_GROUP_FRAME
        COLOR_GROUP_LABEL          = #COLOR_LIGHT_GROUP_LABEL
        COLOR_CARET                = #COLOR_LIGHT_CARET
        COLOR_TEXT_ACTIVE          = #COLOR_LIGHT_TEXT_ACTIVE
        COLOR_TEXT_DEFAULT         = #COLOR_LIGHT_TEXT_DEFAULT
        COLOR_SELECTED_BG          = #COLOR_LIGHT_SELECTED_BG
        COLOR_SELECTED_FG          = #COLOR_LIGHT_SELECTED_FG
        COLOR_ACTIVE_BG            = #COLOR_LIGHT_ACTIVE_BG
        COLOR_ACTIVE_FG            = #COLOR_LIGHT_ACTIVE_FG
        COLOR_DISABLED_BG          = #COLOR_LIGHT_DISABLED_BG
        COLOR_DISABLED_FG          = #COLOR_LIGHT_DISABLED_FG
        COLOR_NUMBER_BG            = #COLOR_LIGHT_NUMBER_BG
        COLOR_NUMBER_FG            = #COLOR_LIGHT_NUMBER_FG

        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARk
        ; ...[ RGBA ]............................................................
        COLOR_MAIN_BG              = #COLOR_DARK_MAIN_BG
        COLOR_SECONDARY_BG         = #COLOR_DARK_SECONDARY_BG
        COLOR_TERNARY_BG           = #COLOR_DARK_TERNARY_BG
        COLOR_SHADOW               = #COLOR_DARK_SHADOW
        COLOR_LABEL                = #COLOR_DARK_LABEL
        COLOR_LABEL_NEG            = #COLOR_DARK_LABEL_NEG
        COLOR_LABEL_DISABLED       = #COLOR_DARK_LABEL_DISABLED
        COLOR_LABEL_MARKED         = #COLOR_DARK_LABEL_MARKED
        COLOR_LABEL_MARKED_DIMMED  = #COLOR_DARK_LABEL_MARKED_DIMMED
        COLOR_FRAME_DISABLED       = #COLOR_DARK_FRAME_DISABLED
        COLOR_FRAME_OVERED         = #COLOR_DARK_FRAME_OVERED
        COLOR_FRAME_DEFAULT        = #COLOR_DARK_FRAME_DEFAULT
        COLOR_FRAME_ACTIVE         = #COLOR_DARK_FRAME_ACTIVE
        COLOR_LINE_DIMMED          = #COLOR_DARK_LINE_DIMMED
        COLOR_GROUP_FRAME          = #COLOR_DARK_GROUP_FRAME
        COLOR_GROUP_LABEL          = #COLOR_DARK_GROUP_LABEL
        COLOR_CARET                = #COLOR_DARK_CARET
        COLOR_TEXT_ACTIVE          = #COLOR_DARK_TEXT_ACTIVE
        COLOR_TEXT_DEFAULT         = #COLOR_DARK_TEXT_DEFAULT
        COLOR_SELECTED_BG          = #COLOR_DARK_SELECTED_BG
        COLOR_SELECTED_FG          = #COLOR_DARK_SELECTED_FG
        COLOR_ACTIVE_BG            = #COLOR_DARK_ACTIVE_BG
        COLOR_ACTIVE_FG            = #COLOR_DARK_ACTIVE_FG
        COLOR_DISABLED_BG          = #COLOR_DARK_DISABLED_BG
        COLOR_DISABLED_FG          = #COLOR_DARK_DISABLED_FG
        COLOR_NUMBER_BG            = #COLOR_DARK_NUMBER_BG
        COLOR_NUMBER_FG            = #COLOR_DARK_NUMBER_FG
  
        
    EndSelect
    
  EndProcedure
  
  Procedure Init()
    SetTheme(Globals::#GUI_THEME_LIGHT)
  EndProcedure
  
  Procedure Hovered(color.i)
    ProcedureReturn RGBA(Math::Min(Red(color) + 32, 255), Math::Min(Green(color) + 32, 255), Math::Min(Blue(color) + 32,255), 255)
  EndProcedure
  
  

EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 143
; FirstLine = 118
; Folding = ---
; EnableXP