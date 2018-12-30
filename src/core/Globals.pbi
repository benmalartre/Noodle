XIncludeFile "Math.pbi"

;========================================================================================
; Globals Module Declaration
;========================================================================================
DeclareModule Globals
  Enumeration
    #SHORTCUT_COPY = 240
    #SHORTCUT_CUT
    #SHORTCUT_PASTE
    #SHORTCUT_UNDO
    #SHORTCUT_REDO
    #SHORTCUT_ENTER
    #SHORTCUT_DELETE
    #SHORTCUT_RESET
    #SHORTCUT_NEXT
    #SHORTCUT_PREVIOUS
    #SHORTCUT_QUIT
    #SHORTCUT_TAB
    #SHORTCUT_SCALE
    #SHORTCUT_ROTATE
    #SHORTCUT_TRANSLATE
    #SHORTCUT_CAMERA
    #SHORTCUT_SELECT
  EndEnumeration
  
  Enumeration #PB_Event_FirstCustomValue
    #EVENT_PARAMETER_CHANGED
    #EVENT_BUTTON_PRESSED
    #EVENT_COMBO_PRESSED
    #EVENT_ICON_PRESSED
    #EVENT_TIME_CHANGED
    #EVENT_SELECTION_CHANGED
    #EVENT_COMMAND_CALLED
    #EVENT_GRAPH_CHANGED
    #EVENT_TREE_CREATED
  EndEnumeration
  
  Enumeration 
    #FONT_DEFAULT = 1
    #FONT_BOLD
  EndEnumeration
  
  #FONT_SIZE_TEXT = 8
  #FONT_SIZE_LABEL = 10
  #FONT_SIZE_MENU = 11
  #FONT_SIZE_TITLE = 13
  
  Enumeration
    #GUI_THEME_LIGHT
    #GUI_THEME_DARK
    #GUI_THEME_CUSTOM
  EndEnumeration
  
  Enumeration
    #VIEW_EMPTY
    #VIEW_EXPLORER
    #VIEW_PROPERTY
    #VIEW_TIMELINE
    #VIEW_GRAPH
    #VIEW_VIEWPORT
    #VIEW_TOPMENU
    #VIEW_EDITOR
  EndEnumeration
  
  ; ---------------------------------------------------------------------------
  ; Commands 
  ; ---------------------------------------------------------------------------
  Enumeration
    #MENU_SAVE
    #MENU_SAVEAS
    #MENU_LOAD
    #MENU_CREATEOBJECT3D
    #MENU_CREATEPROPERTY
    #MENU_CREATEATTRIBUTE
    #MENU_IMPLODENODES
    #MENU_EXPLODENODES
    #MENU_ADDINPUTPORT
    #MENU_REMOVEINPUTPORT
    #MENU_ADDOUTPUTPORT
    #MENU_REMOVEOUTPUTPORT
    #MENU_EXPORTNODE
    #MENU_IMPORTNODE
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ; Tools
  ; ----------------------------------------------------------------------------
  Enumeration 
    #TOOL_SELECT = 0
    #TOOL_CAMERA
    #TOOL_PAN
    #TOOL_DOLLY
    #TOOL_ORBIT
    #TOOL_ROLL
    #TOOL_ZOOM
    #TOOL_DRAW
    #TOOL_PAINT
    #TOOL_SCALE
    #TOOL_ROTATE
    #TOOL_TRANSLATE
    #TOOL_TRANSFORM
    #TOOL_DIRECTED
    
    #TOOL_PREVIEW
    
    #TOOL_MAX
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ; Vector Drawing
  ; ----------------------------------------------------------------------------
  CompilerIf Not Defined(USE_VECTOR_DRAWING,#PB_Constant)
    CompilerIf #PB_Compiler_Version<540
      #USE_VECTOR_DRAWING = #False
    CompilerElse
      #USE_VECTOR_DRAWING = #True
    CompilerEndIf
  CompilerEndIf
  
  ; ============================================================================
  ;  Declarations
  ; ============================================================================
  Declare Init()
  Declare Term()
  
  ; ============================================================================
  ;  MACROS
  ; ============================================================================
  ;{
  ; ---[ void ]-----------------------------------------------------------------
  Macro void
  EndMacro
  ; ---[ GUILLEMETS ]-----------------------------------------------------------
  Macro GUILLEMETS
    "
  EndMacro
  ; ---[ STRINGIFY ]------------------------------------------------------------
  Macro STRINGIFY( t )
    GUILLEMETS#t#GUILLEMETS
  EndMacro
  ; ---[ NewLine ]--------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #NL$ = #CRLF$
    CompilerCase #PB_OS_Linux
      #NL$ = #LF$
    CompilerCase #PB_OS_MacOS
      #NL$ = #LF$
  CompilerEndSelect
  
  ; ---[ Slash ]--------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
     Macro SLASH: "\" : EndMacro
    CompilerCase #PB_OS_Linux
     Macro SLASH: "/" : EndMacro
    CompilerCase #PB_OS_MacOS
     Macro SLASH: "/" : EndMacro
  CompilerEndSelect

  
  ; ---[ Bits Manipulation]-----------------------------------------------------
  Macro BitRead(_number,_bit)
    Bool((_number>>_bit)& #True)
  EndMacro
  
  Macro BitSet(_number,_bit)
    _number | 1 << _bit
  EndMacro
  
  Macro BitClear(_number,_bit)
    _number & ~(1 << _bit)
  EndMacro
  
  Macro BitWrite(_number,_bit,_value)
    If (_value) 
      Globals::BitSet(_number, _bit)
    Else
      Globals::BitClear(_number, _bit)
    EndIf
  EndMacro
  
   ; ---[ Color Conversion ]-----------------------------------------------------
  Macro RGB2RGBA(color,alpha)
   RGBA(Red(color),Green(color),Blue(color),alpha)
  EndMacro
   
  Macro RGBA2RGB(color)
    RGB(Red(color),Green(color),Blue(color))  
  EndMacro

EndDeclareModule

;========================================================================================
; Globals Module Implementation
;========================================================================================
Module Globals
  
  Procedure Init()
     ; ---[ Init Once ]----------------------------------------------------
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        LoadFont( #FONT_DEFAULT, "Consolas", 8)
        LoadFont( #FONT_BOLD,    "Consolas", 8, #PB_Font_Bold )

      CompilerCase #PB_OS_MacOS
        LoadFont( #FONT_DEFAULT, "Verdana", 8)
        LoadFont( #FONT_BOLD,    "Verdana", 8, #PB_Font_Bold )
        
      CompilerCase #PB_OS_Linux
        LoadFont( #FONT_DEFAULT, "Verdana", 8)
        LoadFont( #FONT_BOLD,    "Verdana", 8, #PB_Font_Bold ) 
        
    CompilerEndSelect
  EndProcedure
  
  Procedure Term()
    ; ---[ Term Once ]----------------------------------------------------------
    If IsFont(#FONT_DEFAULT) : FreeFont( #FONT_DEFAULT  ) : EndIf
    If IsFont(#FONT_BOLD) : FreeFont( #FONT_BOLD ) : EndIf

  EndProcedure

;}
  
  
EndModule

  
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 164
; FirstLine = 160
; Folding = ----
; EnableXP
; EnableUnicode