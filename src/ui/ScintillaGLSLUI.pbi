﻿XIncludeFile "UI.pbi"
XIncludeFile "Font.pbi"
; ==========================================================================================
;   SCINTILLA GLSL DECLARATION
; ==========================================================================================
DeclareModule ScintillaGLSLUI
  
  Prototype PFNSCINTILLACALLBACK(gadget, *scinotify.SCNotification)
  Global SCINTILLACALLBACK.PFNSCINTILLACALLBACK
  
  Global BG_COLOR         = RGB(32 , 32 , 32 )
  Global BG_COLOR_H       = RGB(64 , 64 , 64 )
  Global FG_COLOR         = RGB(222, 222, 222)
  Global FG_COLOR_H       = RGB(255, 255, 255)
  Global CONSTANT_COLOR   = RGB(64 , 180, 255)
  Global COMMENT_COLOR    = RGB(180, 255, 64 )
  Global STRING_COLOR     = RGB(255, 139, 37 )
  Global OP_COLOR         = RGB(255, 222, 64 )
  Global TYPE_COLOR       = RGB(255, 180, 64 )
  Global QUALIFIER_COLOR  = RGB(255, 32,  180)
  
  Global Ops.s        = "for if else elseif return break ; ,"
  Global Qualifiers.s = "in out uniform varying layout location"
  Global Types.s      = "void int float double vec2 vec3 vec4 mat2 mat3 mat4"
  Global Maths.s      = "sin cos tan asin acos atan step pow exp exp2 log log2 sqrt inversesqrt"
  Maths               + "abs sign main max clamp length distance dot cross normalize reflect"
  Global Samplers.s   = "texture textureOffset textureSize"
  
  Enumeration
    #LexerState_Default = -1
    #LexerState_Space
    #LexerState_Comment
    #LexerState_NonKeyword
    #LexerState_Keyword
    #LexerState_FoldKeyword
    #LexerState_Constant
    #LexerState_String
    #LexerState_FoldKeywordUp
    #LexerState_FoldKeywordDown
    #LexerState_Type
    #LexerState_Op
    #LexerState_Math
    #LexerState_Qualifier
  EndEnumeration
  
  Structure ScintillaGLSLUI_t Extends UI::UI_t
  EndStructure
  
  ; -------------------------------------------------------------------
  ;   DECLARE
  ; -------------------------------------------------------------------
  Declare Init()
  Declare New(x.i, y.i, width.i, height.i)
  Declare Delete(*Me.ScintillaGLSL_t)
  Declare GetLineEndPosition(gadget, line)
  Declare LineFromPosition(gadget, pos)
  Declare KeywordIs(key.s)
  Declare Highlight(sciptr.l, endpos.l)
  
  ; -------------------------------------------------------------------
  ;   VIRTUAL TABLE
  ; -------------------------------------------------------------------
  DataSection
    ScintillaGLSLUIVT:
    Data.i @Delete()
    Data.i UI::@Resize()
    Data.i UI::@Draw()
    Data.i UI::@DrawPickImage()
    Data.i UI::@Pick()
    Data.i UI::@OnEvent()
  EndDataSection
  
EndDeclareModule

; ==========================================================================================
;   SCINTILLA GLSL CALLBACK
; ==========================================================================================
ProcedureDLL ScintillaCallBack(gadget, *scinotify.SCNotification)
  Select *scinotify\nmhdr\code
    Case #SCN_STYLENEEDED
      ScintillaGLSL::Highlight(gadget, *scinotify\position)
      
    Case #SCN_MARGINCLICK
      ScintillaSendMessage(gadget, #SCI_TOGGLEFOLD, ScintillaSendMessage(gadget, #SCI_LINEFROMPOSITION, *scinotify\Position))
  EndSelect
EndProcedure
ScintillaGLSL::SCINTILLACALLBACK = @ScintillaCallBack()

; ==========================================================================================
;   SCINTILLA GLSL IMPLEMENTATION
; ==========================================================================================
Module ScintillaGLSLUI
  ; ----------------------------------------------------------------------------------------
  ;   INIT
  ; ----------------------------------------------------------------------------------------
  Procedure Init()
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      InitScintilla("Scintilla.dll")
    CompilerEndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   NEW
  ; ----------------------------------------------------------------------------------------
  Procedure New(x.i, y.i, width.i, height.i)
    Define *Me.ScintillaGLSLUI_t = AllocateMemory(SizeOf(ScintillaGLSL_t))
    Object::INI(ScintillaGLSL)
    
    *Me\gadgetID = ScintillaGadget(#PB_Any, x, y, width, height, SCINTILLACALLBACK)
    ; choose a lexer
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETLEXER, #SCLEX_CONTAINER, 0)
    
    ; set default colors
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #STYLE_DEFAULT, FG_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBACK, #STYLE_DEFAULT, BG_COLOR)
    
    ; set default font
    Define *font_ascii_name = Ascii(Font::DEFAULT_FONT_NAME)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFONT, #STYLE_DEFAULT, *font_ascii_name)
    FreeMemory(*font_ascii_name)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 10)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLECLEARALL)
    
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 32)
    
    ; affichage de la colone de numérotation des lignes
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETMARGINTYPEN, *Me\gadgetID, #SC_MARGIN_NUMBER) ;
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETMARGINWIDTHN, *Me\gadgetID, 40)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBACK, #STYLE_LINENUMBER, FG_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #STYLE_LINENUMBER, BG_COLOR)
    
    ; set caret line colour
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETCARETLINEBACK, BG_COLOR_H)
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETCARETLINEVISIBLE, #True)
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETCARETFORE, FG_COLOR_H)
    
    ; set styles for custom lexer
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Comment, COMMENT_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETITALIC, #LexerState_Comment, 1)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_NonKeyword, FG_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Keyword, RGB(0, 102, 102))
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Constant, CONSTANT_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBOLD, #LexerState_Constant, #True)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_String, STRING_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Op, OP_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Type, TYPE_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBOLD, #LexerState_Type, #True)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETFORE, #LexerState_Qualifier, QUALIFIER_COLOR)
    ScintillaSendMessage(*Me\gadgetID, #SCI_STYLESETBOLD, #LexerState_Qualifier, #True)
    
    ; Margins
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
;     ScintillaSendMessage(0, #SCI_SETMARGINMASKN, 2, #SC_MASK_FOLDERS)
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETMARGINWIDTHN, 0, 24)
;     ScintillaSendMessage(0, #SCI_SETMARGINWIDTHN, 2, 20)
;     ScintillaSendMessage(0, #SCI_SETMARGINSENSITIVEN, 2, #True)
;     
;     ; Choose folding icons
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPEN, #SC_MARK_CIRCLEMINUS)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDER, #SC_MARK_CIRCLEPLUS)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERSUB, #SC_MARK_VLINE)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERTAIL, #SC_MARK_LCORNERCURVE)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEREND, #SC_MARK_CIRCLEPLUSCONNECTED)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPENMID, #SC_MARK_CIRCLEMINUSCONNECTED)
;     ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERMIDTAIL, #SC_MARK_TCORNERCURVE)
;     
;     ; Choose folding icon colours
;     ScintillaSendMessage(0, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER, $FFFFFF)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER, 0)
;     ScintillaSendMessage(0, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN, $FFFFFF)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN, 0)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, 0)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERSUB, 0)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERTAIL, 0)
;     ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERMIDTAIL, 0)
    
    txt.s = "#version 330"+Chr(10)+Chr(10)

    txt + "uniform mat4 model;"+Chr(10)
    txt + "uniform mat4 view;"+Chr(10)
    txt + "uniform mat4 projection;"+Chr(10)

    txt + "layout (location = 0) in vec3 position;"+Chr(10)
    txt + "//out float depth;"+Chr(10)+Chr(10)

    txt + "void main(){"+Chr(10)
    txt + "	gl_Position = projection * view * model * vec4(position,1.0);"+Chr(10)
    txt + "}"+Chr(10)

    Define *ascii = Ascii(txt)
    ScintillaSendMessage(*Me\gadgetID, #SCI_SETTEXT, #Null, *ascii)
    FreeMemory(*ascii)
    ProcedureReturn *Me\gadgetID
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   DESTRUCTOR
  ; ----------------------------------------------------------------------------------------
  Procedure Delete(*Me.ScintillaGLSLUI_t)
    FreeGadget(*Me\gadgetID)
    Object::TERM(ScintillaGLSLUI)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   LINE END POSITION
  ; ----------------------------------------------------------------------------------------
  Procedure GetLineEndPosition(gadget, line)
    ProcedureReturn ScintillaSendMessage(gadget,#SCI_GETLINEENDPOSITION,line)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   LINE FROM POSITION
  ; ----------------------------------------------------------------------------------------
  Procedure LineFromPosition(gadget, pos)
    ProcedureReturn ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,pos)
  EndProcedure
  
  ; ----------------------------------------------------------------------------------------
  ;   KEYWORD TYPE
  ; ----------------------------------------------------------------------------------------
  Procedure KeyWordIs(key.s)
    Protected n
    If key=""
      ProcedureReturn -1
    EndIf
    
    For n=1 To CountString(Types, " ") + 1
      If LCase(StringField(Types, n, " ")) = LCase(key)
        ProcedureReturn #LexerState_Type
      EndIf
    Next n
    For n=1 To CountString(Maths, " ") + 1
      If LCase(StringField(Maths, n, " ")) = LCase(key)
        ProcedureReturn #LexerState_Math
      EndIf
    Next n
    For n=1 To CountString(Qualifiers, " ") + 1
      If LCase(StringField(Qualifiers, n, " ")) = LCase(key)
        ProcedureReturn #LexerState_Qualifier
      EndIf
    Next n
    For n=1 To CountString(Ops, " ") + 1
      If LCase(StringField(Ops, n, " ")) = LCase(key)
        ProcedureReturn #LexerState_Op
      EndIf
    Next n
    ProcedureReturn #LexerState_Default
  EndProcedure
  
  Procedure IsOp(key.c)
    For n=1 To CountString(Ops, " ") + 1
      If LCase(StringField(Ops, n, " ")) = LCase(Chr(key))
        ProcedureReturn #True
      EndIf
    Next n
    ProcedureReturn #False
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------------------
  ;   HIGHLIGHT
  ; ----------------------------------------------------------------------------------------
  Procedure Highlight(sciptr.l, endpos.l)
    Protected level = #SC_FOLDLEVELBASE, char.l, lastChar.l, keyword.s, state.i, linenumber.l
    Protected thislevel.l = level
    Protected nextlevel.l = level
    Protected currentPos.l = 0, endlinepos.l, startkeyword
    Protected currentline.l = 0
    endpos = GetLineEndPosition(sciptr, LineFromPosition(sciptr, endpos))
    ScintillaSendMessage(sciptr, #SCI_STARTSTYLING, CurrentPos, $1F | #INDICS_MASK)
    
    While CurrentPos <= endpos
      Char = ScintillaSendMessage(sciptr, #SCI_GETCHARAT, CurrentPos)
      Select Char
        Case 10
          ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_NonKeyword)
          ScintillaSendMessage(sciptr, #SCI_SETFOLDLEVEL, linenumber , thislevel)
          thislevel = nextlevel
          linenumber + 1
          
        Case 'a' To 'z', 'A' To 'Z'
          endlinepos = GetLineEndPosition(sciptr, LineFromPosition(sciptr, currentpos))
          
          keyword = Chr(char)
          While currentpos < endlinepos
            currentpos + 1
            char = ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos)
            If Not ((char >= 'a' And char <= 'z') Or (char >= 'A' And char <= 'Z') Or char = '_'Or (char >= '0' And char <= '9'))
              currentpos-1
              Break
            EndIf
            keyword + Chr(char)
          Wend
          
          Select KeyWordIs(keyword)
            Case #LexerState_Type
              state = #LexerState_Type
  ;             thislevel | #SC_FOLDLEVELHEADERFLAG
  ;             nextlevel + 1

            Case #LexerState_Qualifier
              state = #LexerState_Qualifier
  ;             nextlevel - 1
  ;             If nextlevel < #SC_FOLDLEVELBASE
  ;                   nextlevel = #SC_FOLDLEVELBASE
  ;             EndIf

            Case #LexerState_Math
              state = #LexerState_Math
            Default
              state = #LexerState_NonKeyword

          EndSelect

          ScintillaSendMessage(sciptr, #SCI_SETSTYLING, Len(keyword), state)
          
        Case '"'
          endlinepos = GetLineEndPosition(sciptr, LineFromPosition(sciptr, currentpos))
          startkeyword = 1
          While currentpos < endlinepos
            currentpos + 1
            startkeyword + 1
            If ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos) = '"'
              Break
            EndIf
          Wend
          ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_String)
          
        Case '/'
          If lastChar = '/'
            endlinepos = GetLineEndPosition(sciptr, LineFromPosition(sciptr, currentpos))
            startkeyword = 2
            While currentpos < endlinepos
              currentpos + 1
              startkeyword + 1
            Wend
            ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Comment)
          EndIf
          
        Case '*'
          If lastChar = '/'
            Define foundStar.b = #False
            Define foundSlash.b = #False
            Define reachEnd.b =#False
            startkeyword = 2
            While Not (foundStar And foundSlash) And Not reachEnd
              currentPos + 1
              startkeyword + 1
              If currentPos >= endPos
                reachEnd = #True
              Else
                char = ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos)
  
                If char = '*'
                  foundStar = #True
                ElseIf char = '/'
                  foundSlash = #True 
                Else
                  foundStar = #False
                EndIf
                lastChar = char
              EndIf
              
            Wend
            ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Comment)
          Else  
            ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_NonKeyword)
          EndIf
  
        Case 9, ' '
          ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_Space)
          
        Case '#'
          endlinepos = GetLineEndPosition(sciptr, LineFromPosition(sciptr, currentpos))
;           startkeyword = 1
;           While currentpos < endlinepos
;             currentpos + 1
;             char = ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos)
;             If Not ((char >= 'a' And char <= 'z') Or (char >= 'A' And char <= 'Z') Or char = '_' Or (char >= '0' And char <= '9'))
;               currentpos-1
;               Break
;             EndIf
;             startkeyword + 1
;           Wend
;           ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Constant)
          startkeyword = 1
          While currentpos < endlinepos
            currentpos + 1
            startkeyword + 1
          Wend
;           ScintillaSendMessage(sciptr, #SCI_STYLESETWEIGHT, #STYLE_CONTROLCHAR, 999)
          ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Constant)
          
        Default
          If IsOp(char)
            ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_Op)
          Else
            ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_NonKeyword)
          EndIf
          
      EndSelect
      lastChar = char
      currentpos+1
    Wend
  EndProcedure
  
EndModule

; =======================================================================================================
;   TEST CODE
; =======================================================================================================
Procedure TestScintillaGLSLUI()
  ScintillaGLSL::Init()
  
  If OpenWindow(0, 0, 0, 800, 600, "Scintilla GLSL", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
       
    If UseGadgetList(WindowID(0))
      *ui = ScintillaGLSL::New(0,0,WindowWidth(0, #PB_Window_InnerCoordinate), WindowHeight(0, #PB_Window_InnerCoordinate))
    EndIf
       
    
    Repeat
      Event = WaitWindowEvent()
      
      If Event = #PB_Event_CloseWindow
        Quit = 1
      EndIf
    Until Quit = 1
       
  EndIf
EndProcedure
; =======================================================================================================
;   EOF
; =======================================================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 28
; FirstLine = 17
; EnableXP