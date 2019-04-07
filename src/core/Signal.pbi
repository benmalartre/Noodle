XIncludeFile "Arguments.pbi"
XIncludeFile "Callback.pbi"

; ======================================================================
;   Signal Module Declaration
; ======================================================================
DeclareModule Signal
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

  Structure Signal_t
    name.s
    List *slots.Callback::Callback_t()
  EndStructure
  
  Declare New(name.s)
  Declare Delete(*signal.Signal_t)
  Declare Trigger(*signal.Signal_t, type.i=#SIGNAL_TYPE_PING)
  Declare AddSlot(*signal.Signal_t, callback.Callback::PFNARGUMENTSCALLBACK)
  Declare RemoveSlot(*signal.Signal_t, index.i)
  
  Macro CONNECTCALLBACK(_signal,_callback,_arg1=,_arg2=,_arg3=,_arg4=,_arg5=,_arg6=,_arg7=,_arg8=)
    Define *_slot#_callback.Callback::Callback_t = Signal::AddSlot(_signal, _callback)
    *_slot#_callback\callback = @_callback#CALLBACK()
    Define *_datas#_callback._callback#DATAS_t = AllocateMemory(SizeOf(_callback#DATAS_t ))
    
    CompilerIf Globals::TOSTRING(_arg8) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      Arguments::PASS(*_datas#_callback\__arg__3, _arg4)
      Arguments::PASS(*_datas#_callback\__arg__4, _arg5)
      Arguments::PASS(*_datas#_callback\__arg__5, _arg6)
      Arguments::PASS(*_datas#_callback\__arg__6, _arg7)
      Arguments::PASS(*_datas#_callback\__arg__7, _arg8)
      
    CompilerElseIf Globals::TOSTRING(_arg7) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      Arguments::PASS(*_datas#_callback\__arg__3, _arg4)
      Arguments::PASS(*_datas#_callback\__arg__4, _arg5)
      Arguments::PASS(*_datas#_callback\__arg__5, _arg6)
      Arguments::PASS(*_datas#_callback\__arg__6, _arg7)
      
    CompilerElseIf Globals::TOSTRING(_arg6) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      Arguments::PASS(*_datas#_callback\__arg__3, _arg4)
      Arguments::PASS(*_datas#_callback\__arg__4, _arg5)
      Arguments::PASS(*_datas#_callback\__arg__5, _arg6)
      
    CompilerElseIf Globals::TOSTRING(_arg5) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      Arguments::PASS(*_datas#_callback\__arg__3, _arg4)
      Arguments::PASS(*_datas#_callback\__arg__4, _arg5)
      
    CompilerElseIf Globals::TOSTRING(_arg4) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      Arguments::PASS(*_datas#_callback\__arg__3, _arg4)
      
    CompilerElseIf Globals::TOSTRING(_arg3) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      Arguments::PASS(*_datas#_callback\__arg__2, _arg3)
      
    CompilerElseIf Globals::TOSTRING(_arg2) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
      Arguments::PASS(*_datas#_callback\__arg__1, _arg2)
      
    CompilerElseIf Globals::TOSTRING(_arg1) <> Globals::#EMPTYSTRING
      Arguments::PASS(*_datas#_callback\__arg__0, _arg1)
    CompilerEndIf
    
    *_slot#_callback\datas = *_datas#_callback

  EndMacro
EndDeclareModule

; ======================================================================
;   Signal Module Implementation
; ======================================================================
Module Signal
  Procedure New(name.s)
    Protected *signal.Signal_t = AllocateMemory(SizeOf(Signal_t))
    InitializeStructure(*signal, Signal_t)
    *signal\name = name
    ProcedureReturn *signal
  EndProcedure
  
  Procedure Delete(*signal.Signal_t)
    ForEach *signal\slots()
      Define *callback.Callback::Callback_t = *signal\slots()
      Callback::Delete(*callback)
    Next
    
    ClearStructure(*signal, Signal_t)
    FreeMemory(*signal)
  EndProcedure
  
  Procedure Trigger(*signal.Signal_t, type.i=#SIGNAL_TYPE_PING)
    If *signal
      Define NewList *tmpSlots.Callback::Callback_t()
      CopyList(*signal\slots(), *tmpSlots())
      ForEach(*tmpSlots())
        *tmpSlots()\callback(*signal\slots()\datas)
      Next
      FreeList(*tmpSlots())
    EndIf
    
  EndProcedure
  
  Procedure AddSlot(*signal.Signal_t, callback.Callback::PFNARGUMENTSCALLBACK)
    Protected *callback.Callback::Callback_t = Callback::New(callback)
    *callback\callback = callback
    *callback\sender = *signal
    AddElement(*signal\slots())
    *signal\slots() = *callback
    ProcedureReturn *callback
  EndProcedure
  
  Procedure RemoveSlot(*signal.Signal_t, index.i)
    If SelectElement(*signal\slots(), index)
      Define *callback.Callback::Callback_t = *signal\slots()
      Callback::Delete(*callback)
      DeleteElement(*signal\slots())
    EndIf
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 87
; FirstLine = 34
; Folding = --
; EnableXP