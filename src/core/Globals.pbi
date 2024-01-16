XIncludeFile "Math.pbi"

;========================================================================================
; Globals Module Declaration
;========================================================================================
DeclareModule Globals
  Enumeration
    #Shortcut_Copy = 240
    #Shortcut_Cut
    #Shortcut_Paste
    #Shortcut_Undo
    #Shortcut_Redo
    #Shortcut_Enter
    #Shortcut_Delete
    #Shortcut_Reset
    #Shortcut_Quit
    #Shortcut_Tab
    #Shortcut_Scale
    #Shortcut_Rotate
    #Shortcut_Translate
    #Shortcut_Transform
    #Shortcut_Camera
    #Shortcut_Select
    #Shortcut_Up
    #Shortcut_Down
    #Shortcut_Previous
    #Shortcut_Next
  EndEnumeration
  
  Enumeration #PB_Event_FirstCustomValue
    #Event_Parameter_Changed
    #Event_Time_Changed
    #Event_Selection_Changed
    #Event_Hierarchy_Changed
    #Event_Tool_Changed
    #Event_Command_Called
    #Event_Graph_Changed
    #Event_Tree_Created
    #Event_New_Scene
    #Event_Repaint_Window
  EndEnumeration
  
  Enumeration
    #Gui_Theme_Light
    #Gui_Theme_Dark
    #Gui_Theme_Custom
  EndEnumeration
  
  Enumeration
    #View_Empty
    #View_Explorer
    #View_Property
    #View_Timeline
    #View_Graph
    #View_Viewport
    #View_TopMenu
    #View_Editor
  EndEnumeration
  
  ; ---------------------------------------------------------------------------
  ; Commands 
  ; ---------------------------------------------------------------------------
  Enumeration
    #Menu_Scene_Save
    #Menu_Scene_SaveAs
    #Menu_Scene_Load
    #Menu_Create_Object3D
    #Menu_Create_Property
    #Menu_Create_Attribute
    #Menu_Create_MenuItem
    #Menu_Create_SubMenuItem
    #Menu_Graph_ImplodeNodes
    #Menu_Graph_ExplodeNodes
    #Menu_Graph_AddInputPort
    #Menu_Graph_RemoveInputPort
    #Menu_Graph_AddOutputPort
    #Menu_Graph_RemoveOutputPort
    #Menu_Graph_ExportNode
    #Menu_ImportNode
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ; Tools
  ; ----------------------------------------------------------------------------
  Enumeration 
    #Tool_Select = 0
    #Tool_Camera
    #Tool_Pan
    #Tool_Dolly
    #Tool_Orbit
    #Tool_Roll
    #Tool_Zoom
    #Tool_Draw
    #Tool_Paint
    #Tool_Scale
    #Tool_Rotate
    #Tool_Translate
    #Tool_Transform
    #Tool_Directed
    #Tool_Preview
    #Tool_Max
  EndEnumeration
  
  #Color_ButtonSize = 24
  #Color_ButtonSpacing = 6
  #Corner_Rounding = 4
  
;   #MARGIN = 12
;   #COLORS_HEIGHT = 200
;   #OUTPUT_HEIGHT = 128
  #SELECTION_BORDER = 0.2
  
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
 
 ; ---[ CHECKS ] --------------------------------------------------------------
  Macro ISNUMERIC(_key)
    (1-Bool(_key<>45 And _key<>46 And (_key<48 Or _key>57)))
  EndMacro

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
  
  Macro BitToggle(_number,_bit)
    _number ^ (1 << _bit)
  EndMacro
  
  Macro BitMaskRead(_number,_bit)
    Bool(_number & _bit)
  EndMacro
  
  Macro BitMaskSet(_number,_mask)
    _number | _mask
  EndMacro
  
  Macro BitMaskClear(_number,_mask)
    _number & ~( _mask )
  EndMacro
  
  Macro BitMaskToggle(_number,_mask)
    _number ^ _mask
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
  Global font_label = LoadFont(#PB_Any,"Consolas",16)
  Global font_title = LoadFont(#PB_Any,"Consolas",32)
  
  Enumeration 
    #Font_Default = 1
    #Font_Bold
  EndEnumeration
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_MacOS
      #Font_Size_Text = 24
      #Font_Size_Label = 26
      #Font_Size_Menu = 28
      #Font_Size_Title = 30
    CompilerDefault
      #Font_Size_Text = 12
      #Font_Size_Label = 13
      #Font_Size_Menu = 14
      #Font_Size_Title = 15
  CompilerEndSelect
  
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
  
  #Empty_String = ""
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
        LoadFont( #FONT_DEFAULT, "lucida", 24)
        LoadFont( #FONT_BOLD,    "lucida", 24, #PB_Font_Bold )

      CompilerCase #PB_OS_MacOS
        LoadFont( #FONT_DEFAULT, "lucida", 24)
        LoadFont( #FONT_BOLD,    "lucida", 24, #PB_Font_Bold )
        
      CompilerCase #PB_OS_Linux
        LoadFont( #FONT_DEFAULT, "lucida", 24)
        LoadFont( #FONT_BOLD,    "lucida", 24, #PB_Font_Bold ) 
        
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

  
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 186
; FirstLine = 161
; Folding = ------
; EnableXP
; EnableUnicode