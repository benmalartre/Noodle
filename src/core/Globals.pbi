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
    #SHORTCUT_QUIT
    #SHORTCUT_TAB
    #SHORTCUT_SCALE
    #SHORTCUT_ROTATE
    #SHORTCUT_TRANSLATE
    #SHORTCUT_CAMERA
    #SHORTCUT_SELECT
    #SHORTCUT_UP
    #SHORTCUT_DOWN
    #SHORTCUT_PREVIOUS
    #SHORTCUT_NEXT
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
    #EVENT_NEW_SCENE
  EndEnumeration
  
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
  
  #Color_ButtonSize = 24
  #Color_ButtonSpacing = 6
  #Corner_Rounding = 4
  
  #MARGIN = 12
  #COLORS_HEIGHT = 200
  #OUTPUT_HEIGHT = 128
  #SELECTION_BORDER = 2
  
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
  Declare.s RandomName(len)
  
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
  
  ;---------------------------------------------------------
  ; FONTS
  ;---------------------------------------------------------
  Global font_label = LoadFont(#PB_Any,"Consolas",8)
  Global font_title = LoadFont(#PB_Any,"Consolas",12)
  
  Enumeration 
    #FONT_DEFAULT = 1
    #FONT_BOLD
  EndEnumeration
  
  #FONT_SIZE_TEXT = 10
  #FONT_SIZE_LABEL = 12
  #FONT_SIZE_MENU = 13
  #FONT_SIZE_TITLE = 14
  
  ;---------------------------------------------------------
  ; MACROS
  ;---------------------------------------------------------
  Macro MAXIMIZE(a,b)
    If a<b : a=b : EndIf
  EndMacro
  
  Macro MINIMIZE(a,b)
    If a>b : a=b : EndIf
  EndMacro
  
  Macro CLAMPIZE(v,a,b)
    If v<a : v=a : ElseIf v>b : v=b : EndIf
  EndMacro
  
  #EMPTYSTRING = ""
  Macro QUOTE()
    "
  EndMacro
  
  Macro DOT()
    .
  EndMacro
  
  Macro TOSTRING(_arg)
    Globals::QUOTE()_arg#Globals::QUOTE()
  EndMacro
;   
;   Macro ISCONSTANTSTRING(_arg)
;     CompilerIf Defined(_arg, #PB_Constant)
;       CompilerIf _arg>Globals::#CONSTANT_TOKENS And _arg < Globals::#CONSTANT
  
  ;---------------------------------------------------------
  ; STRUCTURE
  ;---------------------------------------------------------
  Structure Resolution_t
    x.i
    y.i
  EndStructure
  
  ;---------------------------------------------------------
  ; KEY VALUE
  ;---------------------------------------------------------
  Structure KeyValue_t
    key.s
    value.i
  EndStructure
  
  ;---------------------------------------------------------
  ; DAISY REFERENCE
  ;---------------------------------------------------------
  Structure Reference_t
    *datas
    refchanged.b
    reference.s
    daisyreference.s
  EndStructure
 
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
  
  Procedure.s RandomName(len.i)
    Define name.s
    For i=0 To len-1
      Select Random(2) 
        Case 0  ; (a ---> z)
          name + Chr(Random(25) + 97)
        Case 1  ; (A ---> Z)
          name + Chr(Random(25) + 65)
        Default ; (0 ---> 9)
          name + Chr(Random(9) + 48)
      EndSelect
    Next
    ProcedureReturn name
  EndProcedure

  
EndModule

  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 280
; FirstLine = 240
; Folding = -----
; EnableXP
; EnableUnicode