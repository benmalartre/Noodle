XIncludeFile "Globals.pbi"
XIncludeFile "Arguments.pbi"

; ================================================================================
; CALLBACK MODULE DECLARATION
; ================================================================================
DeclareModule Callback
  UseModule Globals
  ; ------------------------------------------------------------------------------
  ; PROTOTYPE
  ; ------------------------------------------------------------------------------
  Prototype PFNARGUMENTSCALLBACK(*arguments.Arguments::Arguments_t)
  
  ; ------------------------------------------------------------------------------
  ;   STRUCTURE
  ; ------------------------------------------------------------------------------
  Structure Callback_t
    sender.i
    callback.PFNARGUMENTSCALLBACK
    *datas
  EndStructure
  
  ; ------------------------------------------------------------------------------
  ; MACROS
  ; ------------------------------------------------------------------------------
  Macro BEGINCALLBACK(_funcname)
    Procedure _funcname#CALLBACK(*datas._funcname#DATAS_t)
  EndMacro
  
  Macro FILLCALLBACK(_funcname, _num_args)
    CompilerSelect _num_args
      CompilerCase 0
        _funcname()
      CompilerCase 1
        _funcname(*datas\__arg__0)
      CompilerCase 2
        _funcname(*datas\__arg__0, *datas\__arg__1)
      CompilerCase 3
         _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2)
      CompilerCase 4
        _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2, *datas\__arg__3)
      CompilerCase 5
        _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2, *datas\__arg__3, *datas\__arg__4)
      CompilerCase 6
        _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2, *datas\__arg__3, *datas\__arg__4, *datas\__arg__5)
      CompilerCase 7
        _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2, *datas\__arg__3, *datas\__arg__4, *datas\__arg__5, *datas\__arg__6)
      CompilerCase 8
        _funcname(*datas\__arg__0, *datas\__arg__1, *datas\__arg__2, *datas\__arg__3, *datas\__arg__4, *datas\__arg__5, *datas\__arg__6, *datas\__arg__7)
    CompilerEndSelect
  EndMacro
  
  Macro ENDCALLBACK()
    EndProcedure
  EndMacro

  Macro DECLARECALLBACK(_funcname,
                        _arg1=,
                        _arg2=,
                        _arg3=,
                        _arg4=,
                        _arg5=, 
                        _arg6=, 
                        _arg7=, 
                        _arg8=)
    
    
    CompilerIf Globals::TOSTRING(_arg8) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 8
      Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
        Arguments::DECL(_arg4, 3)
        Arguments::DECL(_arg5, 4)
        Arguments::DECL(_arg6, 5)
        Arguments::DECL(_arg7, 6)
        Arguments::DECL(_arg8, 7)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg7) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 7
       Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
        Arguments::DECL(_arg4, 3)
        Arguments::DECL(_arg5, 4)
        Arguments::DECL(_arg6, 5)
        Arguments::DECL(_arg7, 6)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg6) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 6
       Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
        Arguments::DECL(_arg4, 3)
        Arguments::DECL(_arg5, 4)
        Arguments::DECL(_arg6, 5)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg5) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 5
       Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
        Arguments::DECL(_arg4, 3)
        Arguments::DECL(_arg5, 4)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg4) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 4
      Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
        Arguments::DECL(_arg4, 3)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg3) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 3
      Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
        Arguments::DECL(_arg3, 2)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg2) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 2
      Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
        Arguments::DECL(_arg2, 1)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg1) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 1
      Structure _funcname#DATAS_t
        Arguments::DECL(_arg1, 0)
      EndStructure
      
    CompilerEndIf
     
    Callback::BEGINCALLBACK(_funcname)
    Callback::FILLCALLBACK(_funcname, #_funcname#NUM_ARGS)
    Callback::ENDCALLBACK()

  EndMacro

  Declare New(callback.PFNARGUMENTSCALLBACK)
  Declare Delete(*callback.Callback_t)
  
EndDeclareModule

; ================================================================================
;   CALLBACK MODULE IMPLEMENTATION
; ================================================================================
Module Callback
  Procedure New(callback.PFNARGUMENTSCALLBACK)
    Protected *callback.Callback_t = AllocateStructure(Callback_t)
    *callback\callback = callback

    ProcedureReturn *callback
  EndProcedure
  
  Procedure Delete(*callback.Callback_t)
    If *callback\datas
      FreeStructure(*callback\datas)
    EndIf
    FreeStructure(*callback)
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 168
; FirstLine = 131
; Folding = --
; EnableXP