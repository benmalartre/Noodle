;===========================================;
;                                           ;
;   Scintilla example                       ;
;                                           ;
;===========================================;

Global KeyWordUp.s, KeyWordDown.s, KeyWordNone.s
KeyWordUp = "Repeat If Procedure"
KeyWordDown = "ForEver EndIf EndProcedure"
KeyWordNone = "Else"
Enumeration 0
  #LexerState_Space
  #LexerState_Comment
  #LexerState_NonKeyword
  #LexerState_Keyword
  #LexerState_FoldKeyword
  #LexerState_Constant
  #LexerState_String
  #LexerState_FoldKeywordUp
  #LexerState_FoldKeywordDown
EndEnumeration

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      InitScintilla("Scintilla.dll")
CompilerEndIf

Procedure SCI_GetLineEndPosition(gadget, line)
      ProcedureReturn ScintillaSendMessage(gadget,#SCI_GETLINEENDPOSITION,line)
EndProcedure

Procedure SCI_LineFromPosition(gadget, Pos)
      ProcedureReturn ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,Pos)
EndProcedure

Procedure KeyWordIs(key.s)
      Protected n
      If key=""
            ProcedureReturn -1
      EndIf
     
      For n=1 To CountString(KeyWordUp, " ") + 1
            If LCase(StringField(KeyWordUp, n, " ")) = LCase(key)
                  ProcedureReturn #LexerState_FoldKeywordUp
            EndIf
      Next n
      For n=1 To CountString(KeyWordDown, " ") + 1
            If LCase(StringField(KeyWordDown, n, " ")) = LCase(key)
                  ProcedureReturn #LexerState_FoldKeywordDown
            EndIf
      Next n
      For n=1 To CountString(KeyWordNone, " ") + 1
            If LCase(StringField(KeyWordNone, n, " ")) = LCase(key)
                  ProcedureReturn #LexerState_Keyword
            EndIf
      Next n
      ProcedureReturn -1
EndProcedure


Procedure Highlight(sciptr.l, endpos.l)
      Protected level = #SC_FOLDLEVELBASE, Char.l, keyword.s, state.i, linenumber.l
      Protected thislevel.l = level
      Protected nextlevel.l = level
      Protected CurrentPos.l = 0, endlinepos.l, startkeyword
      Protected currentline.l = 0
      endpos = SCI_GetLineEndPosition(sciptr, SCI_LineFromPosition(sciptr, endpos))
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
                        endlinepos = SCI_GetLineEndPosition(sciptr, SCI_LineFromPosition(sciptr, currentpos))
                       
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
                              Case #LexerState_FoldKeywordUp
                                    state = #LexerState_Keyword
                                    thislevel | #SC_FOLDLEVELHEADERFLAG
                                    nextlevel + 1
                              Case #LexerState_FoldKeywordDown
                                    state = #LexerState_Keyword
                                    nextlevel - 1
                                    If nextlevel < #SC_FOLDLEVELBASE
                                          nextlevel = #SC_FOLDLEVELBASE
                                    EndIf
                              Case #LexerState_Keyword
                                    state = #LexerState_Keyword
                              Default
                                    state = #LexerState_NonKeyword
                        EndSelect
                       
                       
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, Len(keyword), state)
                  Case '"'
                        endlinepos = SCI_GetLineEndPosition(sciptr, SCI_LineFromPosition(sciptr, currentpos))
                        startkeyword = 1
                        While currentpos < endlinepos
                              currentpos + 1
                              startkeyword + 1
                              If ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos) = '"'
                                    Break
                              EndIf
                        Wend
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_String)
                  Case ';'
                        endlinepos = SCI_GetLineEndPosition(sciptr, SCI_LineFromPosition(sciptr, currentpos))
                        startkeyword = 1
                        While currentpos < endlinepos
                              currentpos + 1
                              startkeyword + 1
                        Wend
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Comment)
                  Case 9, ' '
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_Space)
                  Case '#'
                        endlinepos = SCI_GetLineEndPosition(sciptr, SCI_LineFromPosition(sciptr, currentpos))
                        startkeyword = 1
                        While currentpos < endlinepos
                              currentpos + 1
                              char = ScintillaSendMessage(sciptr, #SCI_GETCHARAT, currentpos)
                              If Not ((char >= 'a' And char <= 'z') Or (char >= 'A' And char <= 'Z') Or char = '_' Or (char >= '0' And char <= '9'))
                                    currentpos-1
                                    Break
                              EndIf
                              startkeyword + 1
                        Wend
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, startkeyword, #LexerState_Constant)
                  Default
                        ScintillaSendMessage(sciptr, #SCI_SETSTYLING, 1, #LexerState_NonKeyword)
            EndSelect
            currentpos+1
      Wend
EndProcedure

ProcedureDLL ScintillaCallBack(Gadget, *scinotify.SCNotification)
      Select *scinotify\nmhdr\code
            Case #SCN_STYLENEEDED
                  Highlight(Gadget, *scinotify\position)
            Case #SCN_MARGINCLICK
                  ScintillaSendMessage(Gadget, #SCI_TOGGLEFOLD, ScintillaSendMessage(Gadget, #SCI_LINEFROMPOSITION, *scinotify\Position))
      EndSelect
EndProcedure


If OpenWindow(0, 0, 0, 800, 600, "Scintilla exemple", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
     
      If UseGadgetList(WindowID(0))
            ScintillaGadget(0, 0, 0, 800, 600, @ScintillaCallBack())
            ; Choose a lexer
            ScintillaSendMessage(0, #SCI_SETLEXER, #SCLEX_CONTAINER, 0)
           
            ; Set default font
            ScintillaSendMessage(0, #SCI_STYLESETFONT, #STYLE_DEFAULT, @"Courier New")
            ScintillaSendMessage(0, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 12)
            ScintillaSendMessage(0, #SCI_STYLECLEARALL)
           
            ; Set caret line colour
            ScintillaSendMessage(0, #SCI_SETCARETLINEBACK, $eeeeff)
            ScintillaSendMessage(0, #SCI_SETCARETLINEVISIBLE, #True)
           
            ; Set styles for custom lexer
            ScintillaSendMessage(0, #SCI_STYLESETFORE, #LexerState_Comment, $bb00)
            ScintillaSendMessage(0, #SCI_STYLESETITALIC, #LexerState_Comment, 1)
            ScintillaSendMessage(0, #SCI_STYLESETFORE, #LexerState_NonKeyword, 0)
            ScintillaSendMessage(0, #SCI_STYLESETFORE, #LexerState_Keyword, RGB(0, 102, 102))
            ScintillaSendMessage(0, #SCI_STYLESETFORE, #LexerState_Constant, RGB(169, 64, 147))
            ScintillaSendMessage(0, #SCI_STYLESETFORE, #LexerState_String, RGB(255, 139, 37))
            ; Margins
            ScintillaSendMessage(0, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)
            ScintillaSendMessage(0, #SCI_SETMARGINMASKN, 2, #SC_MASK_FOLDERS)
            ScintillaSendMessage(0, #SCI_SETMARGINWIDTHN, 0, 50)
            ScintillaSendMessage(0, #SCI_SETMARGINWIDTHN, 2, 20)
            ScintillaSendMessage(0, #SCI_SETMARGINSENSITIVEN, 2, #True)
           
            ; Choose folding icons
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPEN, #SC_MARK_CIRCLEMINUS)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDER, #SC_MARK_CIRCLEPLUS)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERSUB, #SC_MARK_VLINE)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERTAIL, #SC_MARK_LCORNERCURVE)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEREND, #SC_MARK_CIRCLEPLUSCONNECTED)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPENMID, #SC_MARK_CIRCLEMINUSCONNECTED)
            ScintillaSendMessage(0, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERMIDTAIL, #SC_MARK_TCORNERCURVE)
           
            ; Choose folding icon colours
            ScintillaSendMessage(0, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER, $FFFFFF)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER, 0)
            ScintillaSendMessage(0, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN, $FFFFFF)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN, 0)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, 0)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERSUB, 0)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERTAIL, 0)
            ScintillaSendMessage(0, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERMIDTAIL, 0)
           
            txt.s = "procedure test()"+Chr(10)
            txt.s + " #test = "+ Chr(34)+ "chaine 1"+ Chr(34)+Chr(10)
            txt.s + " If #test = 24"+Chr(10)
            txt.s + "   ;test "+Chr(10)
            txt.s + " Else"+Chr(10)
            txt.s + ""+Chr(10)
            txt.s + " EndIf"+Chr(10)
            txt.s + "EndProcedure"+Chr(10)
            Define *ascii = Ascii(txt)
            MessageRequester("SCINTILLA", txt)
            ScintillaSendMessage(0, #SCI_SETTEXT, #Null, *ascii)
            FreeMemory(*ascii)
      EndIf
     
     
      Repeat
            Event = WaitWindowEvent()
           
            If Event = #PB_Event_CloseWindow
                  Quit = 1
            EndIf
           
      Until Quit = 1
     
EndIf

End
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 197
; Folding = --
; EnableXP