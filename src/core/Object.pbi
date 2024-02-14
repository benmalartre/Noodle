XIncludeFile "Globals.pbi"
XIncludeFile "Callback.pbi"

; ======================================================================
;   Class Module Declaration
; ======================================================================
DeclareModule Class
  Structure Class_t
    name .s
    isize.i
    cnt.i
  EndStructure
  
  Macro DEF( cls )    
    CLASS\name   = Globals::GUILLEMETS#cls#Globals::GUILLEMETS
    CLASS\isize  = SizeOf(cls#_t)
    CLASS\cnt    + 1
  EndMacro

EndDeclareModule

; ======================================================================
;   Class Module Implementation
; ======================================================================
Module Class
EndModule


; ======================================================================
;   Object Module Declaration
; ======================================================================
DeclareModule Object
  ; ------------------------------------------------------------------
  ;   STRUCTURE
  ; ------------------------------------------------------------------
  Structure Object_t
    *VT                                      ; interface virtual table
    Map *callbacks.Callback::Callback_t()   
    Map *slots.Callback::Slot_t()
    *class.Class::Class_t
  EndStructure
  
  ; ------------------------------------------------------------------
  ;   DECLARE
  ; ------------------------------------------------------------------
  Declare NewCallback(*obj.Object_t, name.s)
  Declare DeleteCallback(*obj.Object_t, *callback.Callback::Callback_t)
  
  ; ------------------------------------------------------------------
  ;   INI
  ; ------------------------------------------------------------------
  Macro INI( _cls )
    InitializeStructure(*Me, _cls#_t)
    *Me\VT = ?_cls#VT
    *Me\class  = @CLASS
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   TERM
  ; ------------------------------------------------------------------
  Macro TERM( _cls )
    If MapSize(*Me\callbacks()) > 0
      ForEach *Me\callbacks() : Callback::Delete(*Me\callbacks()) : Next
    EndIf
    FreeStructure(*Me)
  EndMacro
  
  
  ; ------------------------------------------------------------------
  ;   ATTR
  ; ------------------------------------------------------------------
  Macro ATTR(_obj, _name, _type)
    AddMapElement(_obj\slots(), Globals::QUOTE()_name#Globals::QUOTE())
    _obj\slots()\type = _type
    _obj\slots()\datas = @_obj\_name
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   PROXY
  ; ------------------------------------------------------------------
  Macro PROXY(_obj, _name, _proxy, _type)
    AddMapElement(_obj\slots(), _name)
    _obj\slots()\type = _type
    If _type = Slot::#SLOT_STRING
      _obj\slots()\datas = _proxy
    Else
      _obj\slots()\datas = @_proxy
    EndIf
    
    
  EndMacro
  
  ; ------------------------------------------------------------------
  ;   ENUM
  ; ------------------------------------------------------------------
  Macro ENUM(_obj, _name, _items)
    AddMapElement(_obj\slots(), Globals::QUOTE()_name#Globals::QUOTE())
    _obj\slots()\type = Slot::#SLOT_ENUM
    _obj\slots()\datas = @_obj\_name
    ReDim _obj\slots()\items(ArraySize(_items()))
    For _i=0 To ArraySize(_items())-1
      _obj\slots()\items(_i)\name = _items(_i)\key
      _obj\slots()\items(_i)\value = _items(_i)\value
    Next
  EndMacro


EndDeclareModule

; ======================================================================
;   Object Module Implementation
; ======================================================================
Module Object
  
  Procedure NewCallback(*obj.Object_t, name.s)
    If Not FindMapElement(*obj\callbacks(), name)
      Protected *callback.Callback::Callback_t = Callback::New(name)
      *obj\callbacks(name) = *callback
      ProcedureReturn *callback
    EndIf
    ProcedureReturn *obj\callbacks()
  EndProcedure
  
  Procedure DeleteCallback(*obj.Object_t, *callback.Callback::Callback_t)
    If FindMapElement(*obj\callbacks(), *callback\name)
      Callback::Delete(*callback)
      DeleteMapElement(*obj\callbacks())
    EndIf
    
  EndProcedure
  
  Procedure SetValueB(*obj.Object_t, value.b, *mem)
    PokeB(*mem, value)
  EndProcedure
  
  
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 136
; FirstLine = 71
; Folding = ---
; EnableXP