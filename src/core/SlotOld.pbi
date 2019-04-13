XIncludeFile "Object.pbi"

Module Signal
  Procedure.i Init( *Me.Signal_t, *sender)
  
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *Me: ProcedureReturn : EndIf
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\type      = Signal::#SIGNAL_TYPE_UNKNOWN
    *Me\sigdata   = #Null
    *Me\snd_inst  = *sender
    Define *snd_obj.Object::Object_t = *sender
    *Me\snd_class = *snd_obj\class
    *Me\rcv_inst  = #Null
    *Me\rcv_slot  = 0
  
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
EndModule

Module Slot
  ; ----------------------------------------------------------------------------
  ;  Connect
  ; ----------------------------------------------------------------------------
  Procedure Connect( *Me.Slot_t, *rcv, slot.i )
    ; ---[ Sanity Check ]-------------------------------------------------------
    If Not *rcv : ProcedureReturn : EndIf
    
    Protected *obj.Object::Object_t = *rcv
    
    ; ---[ Retrieve Reciever Class ]--------------------------------------------
    Protected *cls.Class::Class_t = *obj\class
    
    ; ---[ Check Reciever Class Has Class Message Procedure ]-------------------
    If #Null = *cls\cmsg
      ProcedureReturn #False
    EndIf
    
    ; ---[ Lock List ]----------------------------------------------------------
    LockMutex( *Me\mux )
    
    ; ---[ Go To Last Element ]-------------------------------------------------
    LastElement(*Me\rcv())
    
    ; ---[ Add Element ]--------------------------------------------------------
    Protected *p.SlotReciever_t = AddElement(*Me\rcv())
    ; ---[ Set Element ]--------------------------------------------------------
    *p\r_inst = *rcv
    *p\r_slot = slot
    *p\r_cmsg = *cls\cmsg
  
    ; ---[ Unlock List ]--------------------------------------------------------
    UnlockMutex( *Me\mux )
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  Disconnect
  ; ----------------------------------------------------------------------------
  Procedure Disconnect( *Me.Slot_t, *rcv )
    
    ; ---[ Lock List ]----------------------------------------------------------
    LockMutex( *Me\mux )
    
    ; ---[ Reset List ]---------------------------------------------------------
    ResetList(*Me\rcv())
    
    ; ---[ Look For Reciever ]--------------------------------------------------
    While NextElement(*Me\rcv())
      ; ...[ Check Reciever ]...................................................
      If *Me\rcv()\r_inst = *rcv
        ; ...[ Remove Element ].................................................
        DeleteElement(*Me\rcv())
        ; ...[ ABORT ]..........................................................
        ProcedureReturn( void )
      EndIf
    Wend
    
    ; ---[ Unlock List ]--------------------------------------------------------
    UnlockMutex( *Me\mux )
    
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Trigger
  ; ----------------------------------------------------------------------------
  Procedure Trigger( *Me.Slot_t, type.Signal::SIGNAL_TYPE, *sig_data )
    ; ---[ Lock List ]----------------------------------------------------------
    LockMutex( *Me\mux )
    
    Define  *cls.Class::Class_t = *Me\sig\snd_class
    
    ; ---[ Set Signal Type & Data ]---------------------------------------------
    *Me\sig\type    = type
    *Me\sig\sigdata = *sig_data
    
    ; ---[ Reset List ]---------------------------------------------------------
    ResetList(*Me\rcv())
    
    ; ---[ Walk Through All Elements ]------------------------------------------
    While NextElement(*Me\rcv())
      Protected *t = *Me\rcv()\r_inst
      ; ...[ Set Signal Reciever ]..............................................
      *Me\sig\rcv_inst = *t
      *Me\sig\rcv_slot = *Me\rcv()\r_slot
      ; ...[ Send Signal ]......................................................
      *Me\rcv()\r_cmsg(0, @*Me\sig )
    Wend
    
    ; ---[ Unlock List ]--------------------------------------------------------
    UnlockMutex( *Me\mux )
    
  EndProcedure

  ; ============================================================================
  ;  Destructor
  ; ============================================================================
  Procedure Delete( *Me.Slot_t )
    If *Me = #Null 
      ProcedureReturn
    EndIf
    
    ; ---[ Lock List ]----------------------------------------------------------
    LockMutex( *Me\mux )
    
    ; ---[ Clear List ]---------------------------------------------------------
    ClearList( *Me\rcv() )
    
    ; ---[ Unlock List ]--------------------------------------------------------
    UnlockMutex( *Me\mux )
    
    ; ---[ Release Mutex ]------------------------------------------------------
    FreeMutex( *Me\mux )
    
    ; ---[ Clear Structure ]----------------------------------------------------
    ClearStructure(*Me,Slot_t)
    FreeMemory(*Me)
    
  EndProcedure
  
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New( *sender )
    
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.Slot_t = AllocateMemory(SizeOf(Slot_t))
    InitializeStructure( *Me, Slot_t )
    
    ; ---[ Init Members ]-------------------------------------------------------
    Signal::Init( @*Me\sig, *sender )
    *Me\mux = CreateMutex()
  
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 106
; FirstLine = 91
; Folding = --
; EnableXP