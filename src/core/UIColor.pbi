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
  #COLOR_LIGHT_SECONDARY_BG         = $FF727272
  #COLOR_LIGHT_LABEL                = $FF000000
  #COLOR_LIGHT_LABEL_NEG            = $FFFFFFFF
  #COLOR_LIGHT_LABEL_DISABLED       = $FF333333
  #COLOR_LIGHT_LABEL_MARKED         = $FF349AAB
  #COLOR_LIGHT_LABEL_MARKED_DIMMED  = $B3339AAB
  #COLOR_LIGHT_LINE_DIMMED          = $B3339AAB
  #COLOR_LIGHT_GROUP_FRAME          = $FF4BB6C8
  #COLOR_LIGHT_GROUP_LABEL          = $FF000000
  #COLOR_LIGHT_CARET                = $FF000000
  #COLOR_LIGHT_TEXT                 = $FF000000
  #COLOR_LIGHT_SELECTED_BG          = $FF7FCBD8
  #COLOR_LIGHT_SELECTED_FG          = $FFFFFFFF
  #COLOR_LIGHT_NUMBER_BG            = $FF7FCBD8
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
  #COLOR_DARK_SECONDARY_BG        = $FF373737
  #COLOR_DARK_LABEL               = $FFC1C1C1
  #COLOR_DARK_LABEL_NEG           = $FFB6D1D8
  #COLOR_DARK_LABEL_DISABLED      = $77B6D1D8
  #COLOR_DARK_LABEL_MARKED        = $FF7ECBD8
  #COLOR_DARK_LABEL_MARKED_DIMMED = $777ECBD8
  #COLOR_DARK_LINE_DIMMED         = $FF00FF00
  #COLOR_DARK_GROUP_FRAME         = $FFFF0000
  #COLOR_DARK_GROUP_LABEL         = $FFFFFFFF
  #COLOR_DARK_CARET               = $FF0000FF
  #COLOR_DARK_TEXT                = $FFFFFFFF
  #COLOR_DARK_SELECTED_BG         = $994AB6C8
  #COLOR_DARK_SELECTED_FG         = $FFFFFFFF
  #COLOR_DARK_NUMBER_BG           = $FF454545
  #COLOR_DARK_NUMBER_FG           = $FF7ECBD8
  #COLOR_LIGHT_SPLITTER           = $FFFFFFFF
  ;}
  
  
  
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ---[ RGBA ]------------------------------------------------------------------
  Global COLOR_MAIN_BG            .i
  Global COLOR_SECONDARY_BG       .i
  Global COLOR_LABEL              .i
  Global COLOR_LABEL_NEG          .i
  Global COLOR_LABEL_DISABLED     .i
  Global COLOR_LABEL_MARKED       .i
  Global COLOR_LABEL_MARKED_DIMMED.i
  Global COLOR_LINE_DIMMED        .i
  Global COLOR_GROUP_FRAME        .i
  Global COLOR_GROUP_LABEL        .i
  Global COLOR_CARET              .i
  Global COLOR_TEXT               .i
  Global COLOR_SELECTED_BG        .i
  Global COLOR_SELECTED_FG        .i
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
  
  Global BLACK          = RGBA(0,0,0,255)
  Global RED            = RGBA(255,0,0,255)
  Global BLUE           = RGBA(0,255,0,255)
  Global GREEN          = RGBA(0,0,255,255)
  Global WHITE          = RGBA(255,255,255,255)
  Global YELLOW         = RGBA(255,255,0,255)
  Global CYAN           = RGBA(0,255,255,255)
  Global MAGENTA        = RGBA(255,0,255,255)
  
  Global BACK           = RGBA(122,122,122,255)
  Global GRID           = RGBA(0,0,0,100)
  Global CONTOUR        = RGBA(200,200,200,200)
  Global LABEL          = RGBA(32,32,32,255)
  Global SELECTED       = RGBA(180,180,180,255)
  Global ACTIVE         = RGBA(255,128,0,255)
  Global OVER           = RGBA(64,32,12,128)
  Global EDIT           = RGBA(64,180,255,255)
  Global HANDLE         = RGBA(255,180,64,255)
  Global HANDLE_H       = RGBA(255,64,0,255)
  Global DARK           = RGBA(30,30,30,255)
  Global DARK_H         = RGBA(40,40,40,255)
  Global LIGHT          = RGBA(220,220,220,255)
  Global LIGHT_H        = RGBA(240,240,240,255)
  
  Declare Init()
  Declare SetTheme(theme.i)
  
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
        COLOR_LABEL                = #COLOR_LIGHT_LABEL
        COLOR_LABEL_NEG            = #COLOR_LIGHT_LABEL_NEG
        COLOR_LABEL_DISABLED       = #COLOR_LIGHT_LABEL_DISABLED
        COLOR_LABEL_MARKED         = #COLOR_LIGHT_LABEL_MARKED
        COLOR_LABEL_MARKED_DIMMED  = #COLOR_LIGHT_LABEL_MARKED_DIMMED
        COLOR_LINE_DIMMED          = #COLOR_LIGHT_LINE_DIMMED
        COLOR_GROUP_FRAME          = #COLOR_LIGHT_GROUP_FRAME
        COLOR_GROUP_LABEL          = #COLOR_LIGHT_GROUP_LABEL
        COLOR_CARET                = #COLOR_LIGHT_CARET
        COLOR_TEXT                 = #COLOR_LIGHT_TEXT
        COLOR_SELECTED_BG          = #COLOR_LIGHT_SELECTED_BG
        COLOR_SELECTED_FG          = #COLOR_LIGHT_SELECTED_FG
        COLOR_NUMBER_BG            = #COLOR_LIGHT_NUMBER_BG
        COLOR_NUMBER_FG            = #COLOR_LIGHT_NUMBER_FG

        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARk
        ; ...[ RGBA ]............................................................
        COLOR_MAIN_BG              = #COLOR_DARK_MAIN_BG
        COLOR_SECONDARY_BG         = #COLOR_DARK_SECONDARY_BG
        COLOR_LABEL                = #COLOR_DARK_LABEL
        COLOR_LABEL_NEG            = #COLOR_DARK_LABEL_NEG
        COLOR_LABEL_DISABLED       = #COLOR_DARK_LABEL_DISABLED
        COLOR_LABEL_MARKED         = #COLOR_DARK_LABEL_MARKED
        COLOR_LABEL_MARKED_DIMMED  = #COLOR_DARK_LABEL_MARKED_DIMMED
        COLOR_LINE_DIMMED          = #COLOR_DARK_LINE_DIMMED
        COLOR_GROUP_FRAME          = #COLOR_DARK_GROUP_FRAME
        COLOR_GROUP_LABEL          = #COLOR_DARK_GROUP_LABEL
        COLOR_CARET                = #COLOR_DARK_CARET
        COLOR_TEXT                 = #COLOR_DARK_TEXT
        COLOR_SELECTED_BG          = #COLOR_DARK_SELECTED_BG
        COLOR_SELECTED_FG          = #COLOR_DARK_SELECTED_FG
        COLOR_NUMBER_BG            = #COLOR_DARK_NUMBER_BG
        COLOR_NUMBER_FG            = #COLOR_DARK_NUMBER_FG
  
        
    EndSelect
    
  EndProcedure
  
  Procedure Init()
    SetTheme(Globals::#GUI_THEME_LIGHT)
  EndProcedure
  

EndModule

; ============================================================================
;  EOF
; ============================================================================

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; Folding = ---
; EnableXP