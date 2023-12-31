XIncludeFile "Globals.pbi"
XIncludeFile "Signal.pbi"
XIncludeFile "Slot.pbi"

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
    Map *signals.Signal::Signal_t()   
    Map *slots.Slot::Slot_t()
    *class.Class::Class_t
  EndStructure
  
  ; ------------------------------------------------------------------
  ;   DECLARE
  ; ------------------------------------------------------------------
  Declare NewSignal(*obj.Object_t, name.s)
  Declare DeleteSignal(*obj.Object_t, *signal.Signal::Signal_t)
  
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
    If MapSize(*Me\signals()) > 0
      ForEach *Me\signals() : Signal::Delete(*Me\signals()) : Next
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
  
  Procedure NewSignal(*obj.Object_t, name.s)
    If Not FindMapElement(*obj\signals(), name)
      Protected *signal.Signal::Signal_t = Signal::New(name)
      AddMapElement(*obj\signals(), name)
      *obj\signals() = *signal
    EndIf
    ProcedureReturn *obj\signals()
  EndProcedure
  
  Procedure DeleteSignal(*obj.Object_t, *signal.Signal::Signal_t)
    If FindMapElement(*obj\signals(), *signal\name)
      Signal::Delete(*signal)
      DeleteMapElement(*obj\signals())
    EndIf
    
  EndProcedure
  
  Procedure SetValueB(*obj.Object_t, value.b, *mem)
    PokeB(*mem, value)
  EndProcedure
  
  
EndModule


; ; ======================================================================
; ;   Class Module Declaration
; ; ======================================================================
; DeclareModule Class
;   Prototype ClassMessage( type.i, *up )
;   Prototype ClassDestructor( *Me )
; 
;   Structure Class_t
;     name .s
;     isize.i
;     cmsg .ClassMessage
;     dtor .ClassDestructor
;   EndStructure
;   
;   Declare ClassOnMessage()
;   
;   Macro DEF( cls )    
;     CLASS\name   = Globals::GUILLEMETS#cls#Globals::GUILLEMETS
;     CLASS\isize  = SizeOf(cls#_t)
;     
;     CompilerIf Defined( OnMessage, #PB_Procedure )
;       CLASS\cmsg = @OnMessage()
;     CompilerElse
;       CLASS\cmsg = Class::@ClassOnMessage()
;     CompilerEndIf
;     
;     CLASS\dtor = @Delete()
;   EndMacro
; 
; EndDeclareModule
; 
; ; ======================================================================
; ;   Class Module Implementation
; ; ======================================================================
; Module Class
;   Procedure ClassOnMessage()
;   EndProcedure
;   
; EndModule
; 
; ; ; ======================================================================
; ; ;   Signal Module Declaration
; ; ; ======================================================================
; ; DeclareModule Signal
; ;   Macro SIGNAL_TYPE
; ;     i
; ;   EndMacro
; ;   Enumeration
; ;     #SIGNAL_TYPE_UNKNOWN = 0
; ;     
; ;     #SIGNAL_TYPE_PING
; ;     #SIGNAL_TYPE_ON
; ;     #SIGNAL_TYPE_OFF
; ;     #SIGNAL_TYPE_TOGGLE
; ;     
; ;     #SIGNAL_TYPE_MAX
; ;   EndEnumeration
; ; 
; ;   Structure Signal_t
; ;     type.i
; ;     *snd_class
; ;     *snd_inst
; ;     *rcv_inst
; ;     rcv_slot  .i
; ;     *sigdata
; ;   
; ;   EndStructure
; ;   Declare Init( *sig.Signal_t, *sender )
; ;   
; ; EndDeclareModule
; ; 
; ; ; ======================================================================
; ; ;   Slot Module Declaration
; ; ; ======================================================================
; ; DeclareModule Slot
; ;   
; ;   Prototype ClassMessage( type.i, *up )
; ;   Structure SlotReciever_t
; ;     *r_inst
; ;      r_slot.i
; ;      r_cmsg.ClassMessage
; ;   EndStructure
; ;   
; ;   Structure Slot_t
; ;     List rcv.SlotReciever_t()
; ;     sig.Signal::Signal_t
; ;     mux.i
; ;   EndStructure
; ;   
; ;   Declare New(*sender)
; ;   Declare Delete(*slot.Slot_t)
; ;   Declare Connect(*Me.Slot_t, *rcv, slot.i )
; ;   Declare Disconnect(*Me.Slot_t, *rcv )
; ;   Declare Trigger( *Me.Slot_t, type.Signal::SIGNAL_TYPE, *sig_data )
; ; EndDeclareModule
; 
; ; ======================================================================
; ;   Object Module Declaration
; ; ======================================================================
; DeclareModule Object
;   Structure Object_t
;     *VT
;     *slot.Slot::Slot_t
;     *class.Class::Class_t
;   EndStructure
;   
;   ; ------------------------------------------------------------------
;   ;   INI
;   ; ------------------------------------------------------------------
;   Macro INI( cls )
;     *Me\VT = ?cls#VT
;     *Me\class  = @CLASS
;     *Me\slot = Slot::New(*Me)
;   EndMacro
;   
;   ; ------------------------------------------------------------------
;   ;   TERM
;   ; ------------------------------------------------------------------
;   Macro TERM( cls )
;     Slot::Delete(*Me\slot)
;   EndMacro
; 
;   Declare SignalConnect( *Me.Object_t, *sig.Slot::Slot_t, slot.i )  
;   Declare SignalDisconnect( *Me.Object_t, *sig.Slot::Slot_t)  
; EndDeclareModule
; 
; ; ======================================================================
; ;   Object Module Implementation
; ; ======================================================================
; Module Object
;   Procedure SignalConnect( *Me.Object_t, *slot.Slot::Slot_t, slot.i )  
;     If Not *Me Or Not *slot : ProcedureReturn :EndIf
; 
;     ; Connect To Signal
;     Slot::Connect(*slot,*Me, slot )
;   EndProcedure
;   
;   Procedure SignalDisconnect( *Me.Object_t, *slot.Slot::Slot_t)  
;     If Not *Me Or Not *slot : ProcedureReturn :EndIf
;   
;     ; Connect To Signal
;     Slot::Disconnect(*slot,*Me )
;   EndProcedure
; EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 65
; FirstLine = 56
; Folding = ---
; EnableXP