DeclareModule UIColor
    
  Macro RGB2RGBA(color,alpha)
   RGBA(Red(color),Green(color),Blue(color),alpha)
  EndMacro
   
  Macro RGBA2RGB(color)
    RGB(Red(color),Green(color),Blue(color))  
  EndMacro
   
  
  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  ; ----------------------------------------------------------------------------
  ;  Light Colors
  ; ----------------------------------------------------------------------------
  ;{
  ; ---[ RGB ]------------------------------------------------------------------
  #COLOR_LIGHT_MAIN_BG              = 10922155 ; RGB($AB,$A8,$A6)
  #COLOR_LIGHT_SECONDARY_BG         = 11185327 ; RGB($AF,$AC,$AA)
  #COLOR_LIGHT_LABEL                =  3158066 ; RGB($32,$30,$30)
  #COLOR_LIGHT_LABEL_NEG            =  3158066 ; RGB($32,$30,$30)
  #COLOR_LIGHT_LABEL_DISABLED       =  6645609 ; RGB($69,$67,$65)
  #COLOR_LIGHT_LABEL_MARKED         = 16296077 ; RGB($8D,$A8,$F8)
  #COLOR_LIGHT_LABEL_MARKED_DIMMED  = 11032637 ; RGB($8D,$A8,$F8)
  #COLOR_LIGHT_LINE_DIMMED          = 10132639 ; RGB($9F,$9C,$9A)
  #COLOR_LIGHT_GROUP_FRAME          =  7434870 ; RGB($86,$82,$81)
  #COLOR_LIGHT_GROUP_LABEL          =  4210752 ; RGB($40,$40,$40)
  #COLOR_LIGHT_CARET                = 11032637 ; RGB($8D,$A8,$F8)
  #COLOR_LIGHT_TEXT                 =  3158066 ; RGB($32,$30,$30)
  #COLOR_LIGHT_SELECTED_BG          = 16296077 ; RGB($8D,$A8,$F8)
  #COLOR_LIGHT_SELECTED_FG          =  3158066 ; RGB($32,$30,$30)
  #COLOR_LIGHT_NUMBER_BG            = 13224650 ; RGBA($CA,$CA,$C9)
  #COLOR_LIGHT_NUMBER_FG            =  1052690 ; RGB($12,$10,$10)
  #COLOR_LIGHT_SPLITTER             = 14606046 ; RGB(222,222,222)
  
  
  ; ---[ RGBA ]-----------------------------------------------------------------
  #COLORA_LIGHT_MAIN_BG             = 18446744073703696555 ; RGBA($AB,$A8,$A6,$FF)
  #COLORA_LIGHT_SECONDARY_BG        = 18446744073704288175 ; 
  #COLORA_LIGHT_LABEL               = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_LIGHT_LABEL_NEG           = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_LIGHT_LABEL_DISABLED      = 18446744073699420009 ; RGBA($69,$67,$65,$FF)
  #COLORA_LIGHT_LABEL_MARKED        = 18446744073709070477 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_LIGHT_LABEL_MARKED_DIMMED = 18446744073703807037 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_LIGHT_LINE_DIMMED         = 18446744073702907039 ; RGBA($9F,$9C,$9A,$FF)
  #COLORA_LIGHT_GROUP_FRAME         = 18446744073700209270 ; RGBA($86,$82,$81,$FF)
  #COLORA_LIGHT_GROUP_LABEL         = 18446744073696985152 ; RGBA($40,$40,$40,$FF)
  #COLORA_LIGHT_CARET               = 18446744073703807037 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_LIGHT_TEXT                = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_LIGHT_SELECTED_BG         = 18446744073709070477 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_LIGHT_SELECTED_FG         = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_LIGHT_NUMBER_BG           = 18446744073705999050 ; RGBA($CA,$CA,$C9,$FF)
  #COLORA_LIGHT_NUMBER_FG           = 18446744073693827090 ; RGBA($12,$10,$10,$FF)
  ;}
  ; ----------------------------------------------------------------------------
  ;  Dark Colors
  ; ----------------------------------------------------------------------------
  ;{
  ; ---[ RGB ]------------------------------------------------------------------
  #COLOR_DARK_MAIN_BG              =  4737096 ; RGB($48,$48,$48)
  #COLOR_DARK_SECONDARY_BG         =  4737096 ; RGB($48,$48,$48)
  #COLOR_DARK_LABEL                = 11776947 ; RGB($B3,$B3,$B3)
  #COLOR_DARK_LABEL_NEG            =  3158066 ; RGB($32,$30,$30)
  #COLOR_DARK_LABEL_DISABLED       =  8026746 ; RGB($7A,$7A,$7A)
  #COLOR_DARK_LABEL_MARKED         = 16296077 ; RGB($8D,$A8,$F8)
  #COLOR_DARK_LABEL_MARKED_DIMMED  = 11032637 ; RGB($8D,$A8,$F8)
  #COLOR_DARK_LINE_DIMMED          =  5263440 ; RGB($50,$50,$50)
  #COLOR_DARK_GROUP_FRAME          =  7368816 ; RGB($70,$70,$70)
  #COLOR_DARK_GROUP_LABEL          = 12237498 ; RGB($BA,$BA,$BA)
  #COLOR_DARK_CARET                = 16296077 ; RGB($8D,$A8,$F8)
  #COLOR_DARK_TEXT                 =  3158066 ; RGB($32,$30,$30)
  #COLOR_DARK_SELECTED_BG          = 16296077 ; RGB($8D,$A8,$F8)
  #COLOR_DARK_SELECTED_FG          =  3158066 ; RGB($32,$30,$30)
  ;COLOR_DARK_NUMBER_BG            =  9407885 ; RGBA($8D,$8D,$8F)
  #COLOR_DARK_NUMBER_BG            =  9145227 ; RGBA($8B,$8B,$8B)
  ;COLOR_DARK_NUMBER_BG            =  3881787 ; RGBA($3B,$3B,$3B)
  ;COLOR_DARK_NUMBER_FG            = 11776947 ; RGB($B3,$B3,$B3)
  #COLOR_DARK_NUMBER_FG            = 11776947 ; RGB($B3,$B3,$B3)
  #COLOR_DARK_SPLITTER             = 4342338  ; RGB(66,66,66)
  
  ;----[ RGBA ]-----------------------------------------------------------------
  #COLORA_DARK_MAIN_BG             = 18446744073697511496 ; RGBA($48,$48,$48,$FF)
  #COLORA_DARK_SECONDARY_BG        = 18446744073699485286 ; RGBA($66,$66,$66,$FF))
  #COLORA_DARK_LABEL               = 18446744073704551347 ; RGBA($B3,$B3,$B3,$FF)
  #COLORA_DARK_LABEL_NEG           = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_DARK_LABEL_DISABLED      = 18446744073700801146 ; RGBA($7A,$7A,$7A,$FF)
  #COLORA_DARK_LABEL_MARKED        = 18446744073709070477 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_DARK_LABEL_MARKED_DIMMED = 18446744073703807037 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_DARK_LINE_DIMMED         = 18446744073698037840 ; RGBA($50,$50,$50,$FF)
  #COLORA_DARK_GROUP_FRAME         = 18446744073700143216 ; RGBA($70,$70,$70,$FF)
  #COLORA_DARK_GROUP_LABEL         = 18446744073705011898 ; RGBA($BA,$BA,$BA,$FF)
  #COLORA_DARK_CARET               = 18446744073709070477 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_DARK_TEXT                = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  #COLORA_DARK_SELECTED_BG         = 18446744073709070477 ; RGBA($8D,$A8,$F8,$FF)
  #COLORA_DARK_SELECTED_FG         = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  ;COLORA_DARK_NUMBER_BG           = 18446744073702182285 ; RGBA($8D,$8D,$8F,$FF)
  #COLORA_DARK_NUMBER_BG           = 18446744073701919627 ; RGBA($8B,$8B,$8B,$FF)
  ;COLORA_DARK_NUMBER_BG           = 18446744073696656187 ; RGBA($3B,$3B,$3B,$FF)
  ;COLORA_DARK_NUMBER_FG           = 18446744073704551347 ; RGBA($B3,$B3,$B3,$FF)
  #COLORA_DARK_NUMBER_FG           = 18446744073695932466 ; RGBA($32,$30,$30,$FF)
  ;}
  ;}
  
  
  
  ; ============================================================================
  ;  GLOBALS
  ; ============================================================================
  ;{
  ; ---[ RGB ]------------------------------------------------------------------
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
  ; ---[ RGBA ]-----------------------------------------------------------------
  Global COLORA_MAIN_BG            .i
  Global COLORA_SECONDARY_BG       .i
  Global COLORA_LABEL              .i
  Global COLORA_LABEL_NEG          .i
  Global COLORA_LABEL_DISABLED     .i
  Global COLORA_LABEL_MARKED       .i
  Global COLORA_LABEL_MARKED_DIMMED.i
  Global COLORA_LINE_DIMMED        .i
  Global COLORA_GROUP_FRAME        .i
  Global COLORA_GROUP_LABEL        .i
  Global COLORA_CARET              .i
  Global COLORA_TEXT               .i
  Global COLORA_SELECTED_BG        .i
  Global COLORA_SELECTED_FG        .i
  Global COLORA_NUMBER_BG          .i
  Global COLORA_NUMBER_FG          .i
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
        ; ...[ RGB ]............................................................
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
        COLOR_SPLITTER             = #COLOR_LIGHT_SPLITTER
        ; ...[ RGBA ]...........................................................
        COLORA_MAIN_BG             = #COLORA_LIGHT_MAIN_BG
        COLORA_SECONDARY_BG        = #COLORA_LIGHT_SECONDARY_BG
        COLORA_LABEL               = #COLORA_LIGHT_LABEL
        COLORA_LABEL_NEG           = #COLORA_LIGHT_LABEL_NEG
        COLORA_LABEL_DISABLED      = #COLORA_LIGHT_LABEL_DISABLED
        COLORA_LABEL_MARKED        = #COLORA_LIGHT_LABEL_MARKED
        COLORA_LABEL_MARKED_DIMMED = #COLORA_LIGHT_LABEL_MARKED_DIMMED
        COLORA_LINE_DIMMED         = #COLORA_LIGHT_LINE_DIMMED
        COLORA_GROUP_FRAME         = #COLORA_LIGHT_GROUP_FRAME
        COLORA_GROUP_LABEL         = #COLORA_LIGHT_GROUP_LABEL
        COLORA_CARET               = #COLORA_LIGHT_CARET
        COLORA_TEXT                = #COLORA_LIGHT_TEXT
        COLORA_SELECTED_BG         = #COLORA_LIGHT_SELECTED_BG
        COLORA_SELECTED_FG         = #COLORA_LIGHT_SELECTED_FG
        COLORA_NUMBER_BG           = #COLORA_LIGHT_NUMBER_BG
        COLORA_NUMBER_FG           = #COLORA_LIGHT_NUMBER_FG
        
      ; ---[ Dark ]-------------------------------------------------------------
      Case Globals::#GUI_THEME_DARk
        ; ...[ RGB ]............................................................
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
        COLOR_SPLITTER             = #COLOR_DARK_SPLITTER
        ; ...[ RGBA ]...........................................................
        COLORA_MAIN_BG             = #COLORA_DARK_MAIN_BG
        COLORA_SECONDARY_BG        = #COLORA_DARK_SECONDARY_BG
        COLORA_LABEL               = #COLORA_DARK_LABEL
        COLORA_LABEL_NEG           = #COLORA_DARK_LABEL_NEG
        COLORA_LABEL_DISABLED      = #COLORA_DARK_LABEL_DISABLED
        COLORA_LABEL_MARKED        = #COLORA_DARK_LABEL_MARKED
        COLORA_LABEL_MARKED_DIMMED = #COLORA_DARK_LABEL_MARKED_DIMMED
        COLORA_LINE_DIMMED         = #COLORA_DARK_LINE_DIMMED
        COLORA_GROUP_FRAME         = #COLORA_DARK_GROUP_FRAME
        COLORA_GROUP_LABEL         = #COLORA_DARK_GROUP_LABEL
        COLORA_CARET               = #COLORA_DARK_CARET
        COLORA_TEXT                = #COLORA_DARK_TEXT
        COLORA_SELECTED_BG         = #COLORA_DARK_SELECTED_BG
        COLORA_SELECTED_FG         = #COLORA_DARK_SELECTED_FG
        COLORA_NUMBER_BG           = #COLORA_DARK_NUMBER_BG
        COLORA_NUMBER_FG           = #COLORA_DARK_NUMBER_FG
        
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
; CursorPosition = 150
; FirstLine = 148
; Folding = ---
; EnableXP