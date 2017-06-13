;======================================================================
; Class Module Declaration
;======================================================================
DeclareModule Class
  ; ---[ Class Message Protoype ]-----------------------------------------------
  Prototype ClassMessage( type.i, *up )
  ; ---[ Class Destructor Prototype ]-------------------------------------------
  Prototype ClassDestructor( *Me )

  ; ---[ Generic Class 'Instance' ]---------------------------------------------
  Structure Class_t
    name .s
    isize.i
    cmsg .ClassMessage
    dtor .ClassDestructor
    ;stats.THREADS_STATS
  EndStructure
  
  Declare ClassOnMessage()
  
  ; ---[ Class Definition Macro ]-----------------------------------------------
  Macro DEF( cls )
  
;     Global Class.Class::Class_t
    
    CLASS\name   = Globals::GUILLEMETS#cls#Globals::GUILLEMETS
    CLASS\isize  = SizeOf(cls#_t)
    
    CompilerIf Defined( OnMessage, #PB_Procedure )
      CLASS\cmsg = @OnMessage()
    CompilerElse
      CLASS\cmsg = Class::@ClassOnMessage()
    CompilerEndIf
    
    CLASS\dtor = @Delete()
   
    
  EndMacro

EndDeclareModule

;======================================================================
; Object Module Implementation
;======================================================================
Module Class
  Procedure ClassOnMessage()
    Debug "Dummy Class On Message Called..."
  EndProcedure
  
EndModule

;======================================================================
; Signal Module Declaration
;======================================================================
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
    type.i
    *snd_class
    *snd_inst
    *rcv_inst
    rcv_slot  .i
    *sigdata
  
  EndStructure
  Declare Init( *sig.Signal_t, *sender )
  
EndDeclareModule

;======================================================================
; Slot Module Declaration
;======================================================================
DeclareModule Slot
  
  Prototype ClassMessage( type.i, *up )
  Structure SlotReciever_t
    *r_inst
     r_slot.i
     r_cmsg.ClassMessage
  EndStructure
  
  Structure Slot_t
    List rcv.SlotReciever_t()
    sig.Signal::Signal_t
    mux.i
  EndStructure
  
  Declare New(*sender)
  Declare Delete(*slot.Slot_t)
  Declare Connect(*Me.Slot_t, *rcv, slot.i )
  Declare Trigger( *Me.Slot_t, type.Signal::SIGNAL_TYPE, *sig_data )
EndDeclareModule

;======================================================================
; Object Module Declaration
;======================================================================
DeclareModule Object
  Structure Object_t
    *VT
    *slot.Slot::Slot_t
    *class.Class::Class_t
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  CObject_INI
  ; ----------------------------------------------------------------------------
  Macro INI( cls )
    *Me\VT = ?cls#VT
    *Me\class  = @CLASS
    *Me\slot = Slot::New(*Me)
;     *Me\rfc    = 0
  EndMacro
  
  
  Declare SignalConnect( *Me.Object_t, *sig.Slot::Slot_t, slot.i )  
EndDeclareModule

;======================================================================
; Object Module Implementation
;======================================================================
Module Object
  Procedure SignalConnect( *Me.Object_t, *slot.Slot::Slot_t, slot.i )  
  ; ---[ Sanity Check ]-------------------------------------------------------
  If Not *Me Or Not *slot : ProcedureReturn :EndIf
  Debug *Me\class\name
  Debug *slot

  ; ---[ Connect Me To Signal ]-----------------------------------------------
  Slot::Connect(*slot,*Me, slot )
EndProcedure
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 142
; FirstLine = 69
; Folding = --
; EnableXP