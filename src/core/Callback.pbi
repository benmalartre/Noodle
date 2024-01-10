XIncludeFile "Globals.pbi"
XIncludeFile "Arguments.pbi"

; ================================================================================
; CALLBACK MODULE DECLARATION
; ================================================================================
DeclareModule Callback
  UseModule Globals

  Prototype PFNCALLBACK(*arguments.Args::Args_t)
  
  Structure Slot_t
    sender.i
    callback.PFNCALLBACK
    *datas
  EndStructure
  
  Macro SIGNAL_TYPE
    i
  EndMacro
  Enumeration
    #SIGNAL_TYPE_UNKNOWN = 0
    
    #SIGNAL_TYPE_PING
    #SIGNAL_TYPE_ON
    #SIGNAL_TYPE_OFF
    #SIGNAL_TYPE_TOGGLE
    
    #SIGNAL_TYPE_MAX
  EndEnumeration

  Structure Callback_t
    name.s
    List *slots.Callback::Slot_t()
  EndStructure
  
  Declare New(name.s)
  Declare Delete(*callback.Callback_t)
  Declare Trigger(*callback.Callback_t, type.i=#SIGNAL_TYPE_PING)
  Declare AddSlot(*callback.Callback_t, fn.Callback::PFNCALLBACK)
  Declare RemoveSlot(*callback.Callback_t, index.i)
  
  Macro BEGIN_CALLBACK(_funcname)
    Procedure _funcname#CALLBACK(*datas._funcname#DATAS_t)
  EndMacro
  
  Macro FILL_CALLBACK(_funcname, _num_args)
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
  
  Macro END_CALLBACK()
    EndProcedure
  EndMacro

  Macro DECLARE_CALLBACK(_funcname,
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
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
        Args::DECL(_arg4, 3)
        Args::DECL(_arg5, 4)
        Args::DECL(_arg6, 5)
        Args::DECL(_arg7, 6)
        Args::DECL(_arg8, 7)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg7) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 7
       Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
        Args::DECL(_arg4, 3)
        Args::DECL(_arg5, 4)
        Args::DECL(_arg6, 5)
        Args::DECL(_arg7, 6)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg6) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 6
       Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
        Args::DECL(_arg4, 3)
        Args::DECL(_arg5, 4)
        Args::DECL(_arg6, 5)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg5) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 5
       Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
        Args::DECL(_arg4, 3)
        Args::DECL(_arg5, 4)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg4) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 4
      Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
        Args::DECL(_arg4, 3)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg3) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 3
      Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
        Args::DECL(_arg3, 2)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg2) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 2
      Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
        Args::DECL(_arg2, 1)
      EndStructure
      
    CompilerElseIf Globals::TOSTRING(_arg1) <> Globals::#EMPTYSTRING
      #_funcname#NUM_ARGS = 1
      Structure _funcname#DATAS_t
        Args::DECL(_arg1, 0)
      EndStructure
      
    CompilerElse
      #_funcname#NUM_ARGS = 0
      Structure _funcname#DATAS_t
      EndStructure
      
    CompilerEndIf
     
    Callback::BEGIN_CALLBACK(_funcname)
    Callback::FILL_CALLBACK(_funcname, #_funcname#NUM_ARGS)
    Callback::END_CALLBACK()

  EndMacro
  
  Macro CONNECT_CALLBACK(_callback,_slot,_arg1=,_arg2=,_arg3=,_arg4=,_arg5=,_arg6=,_arg7=,_arg8=)
    Define *_slot#_slot.Callback::Slot_t = Callback::AddSlot(_callback, _slot)
    Define *_datas#_slot._slot#DATAS_t = AllocateStructure(_slot#DATAS_t )
    
    *_slot#_slot\callback = @_slot#CALLBACK()
    
    CompilerIf Globals::TOSTRING(_arg8) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      Args::PASS(*_datas#_slot\__arg__3, _arg4)
      Args::PASS(*_datas#_slot\__arg__4, _arg5)
      Args::PASS(*_datas#_slot\__arg__5, _arg6)
      Args::PASS(*_datas#_slot\__arg__6, _arg7)
      Args::PASS(*_datas#_slot\__arg__7, _arg8)
      
    CompilerElseIf Globals::TOSTRING(_arg7) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      Args::PASS(*_datas#_slot\__arg__3, _arg4)
      Args::PASS(*_datas#_slot\__arg__4, _arg5)
      Args::PASS(*_datas#_slot\__arg__5, _arg6)
      Args::PASS(*_datas#_slot\__arg__6, _arg7)
      
    CompilerElseIf Globals::TOSTRING(_arg6) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      Args::PASS(*_datas#_slot\__arg__3, _arg4)
      Args::PASS(*_datas#_slot\__arg__4, _arg5)
      Args::PASS(*_datas#_slot\__arg__5, _arg6)
      
    CompilerElseIf Globals::TOSTRING(_arg5) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      Args::PASS(*_datas#_slot\__arg__3, _arg4)
      Args::PASS(*_datas#_slot\__arg__4, _arg5)
      
    CompilerElseIf Globals::TOSTRING(_arg4) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      Args::PASS(*_datas#_slot\__arg__3, _arg4)
      
    CompilerElseIf Globals::TOSTRING(_arg3) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      Args::PASS(*_datas#_slot\__arg__2, _arg3)
      
    CompilerElseIf Globals::TOSTRING(_arg2) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
      Args::PASS(*_datas#_slot\__arg__1, _arg2)
      
    CompilerElseIf Globals::TOSTRING(_arg1) <> Globals::#EMPTYSTRING
      Args::PASS(*_datas#_slot\__arg__0, _arg1)
    CompilerEndIf
    
    *_slot#_slot\datas = *_datas#_slot

  EndMacro
  
EndDeclareModule

; ================================================================================
;   CALLBACK MODULE IMPLEMENTATION
; ================================================================================
Module Callback

  Procedure CreateSlot(*callback.Callback_t, fn.Callback::PFNCALLBACK)
    Protected *slot.callback::Slot_t = AllocateStructure(Callback::Slot_t)
    *slot\callback = fn
    *slot\sender = *callback

    ProcedureReturn *slot
  EndProcedure
  
  Procedure DeleteSlot(*slot.Callback::Slot_t)
    If *slot\datas
      FreeStructure(*slot\datas)
    EndIf
    FreeStructure(*slot)
  EndProcedure
  
  Procedure New(name.s)
    Protected *callback.Callback_t = AllocateStructure(Callback_t)
    *callback\name = name
    ProcedureReturn *callback
  EndProcedure
  
  Procedure Delete(*callback.Callback_t)
    ForEach *callback\slots()
      Define *slot.Callback::Slot_t = *callback\slots()
      DeleteSlot(*slot)
    Next
    FreeStructure(*callback)
  EndProcedure
  
  Procedure Trigger(*callback.Callback_t, type.i=#SIGNAL_TYPE_PING)
    If *callback
      ForEach *callback\slots()
        *callback\slots()\callback(*callback\slots()\datas)
      Next
    EndIf
  EndProcedure
  
  Procedure AddSlot(*callback.Callback_t, fn.Callback::PFNCALLBACK)
    Protected *slot.Callback::Slot_t = CreateSlot(*callback, fn)
    AddElement(*callback\slots())
    *callback\slots() = *slot
    ProcedureReturn *slot
  EndProcedure
  
  Procedure RemoveSlot(*callback.Callback_t, index.i)
    If SelectElement(*callback\slots(), index)
      DeleteSlot(*callback\slots())
      DeleteElement(*callback\slots())
    EndIf
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 268
; Folding = ---
; EnableXP