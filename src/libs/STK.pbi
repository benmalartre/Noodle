; ===================================================================================
;     SYNTHESIS TOOL KIT MODULE DECLARATION
; ===================================================================================
DeclareModule STK
  
  #C0	  = 16.35
  #Db0  = 17.32
  #D0	  = 18.35
  #Eb0  = 19.45
  #E0	  = 20.60
  #F0	  = 21.83
  #Gb0  = 23.12
  #G0	  = 24.50
  #Ab0  = 25.96
  #A0	  = 27.50
  #Bb0  = 29.14
  #B0	  = 30.87

  #C1	  = 32.70
  #Db1  = 34.65	
  #D1	  = 36.71
  #Eb1  = 38.89	
  #E1	  = 41.20
  #F1	  = 43.65
  #Gb1  = 46.25	
  #G1	  = 49.00
  #Ab1  = 51.91	
  #A1	  = 55.00
  #Bb1  = 58.27	
  #B1	  = 61.74

  #C2   = 65.41
  #Db2  = 69.30
  #D2	  = 73.42
  #Eb2	= 77.78
  #E2   = 82.41
  #F2	  = 87.31
  #Gb2  = 92.50
  #G2	  = 98.00
  #Ab2  = 103.83
  #A2   = 110.00
  #Bb2  = 116.54
  #B2   = 123.47

  #C3	  = 130.81
  #Db3  = 138.59
  #D3	  = 146.83
  #Eb3  = 155.56
  #E3	  = 164.81
  #F3	  = 174.61
  #Gb3  = 185.00
  #G3	  = 196.00
  #Ab3  = 207.65
  #A3	  = 220.00
  #Bb3  = 233.08
  #B3	  = 246.94

  #C4	  = 261.63
  #Db4  = 277.18
  #D4	  = 293.66
  #Eb4  = 311.13
  #E4	  = 329.63
  #F4	  = 349.23
  #Gb4  = 369.99
  #G4	  = 392.00
  #Ab4  = 415.30
  #A4	  = 440.00
  #Bb4  = 466.16
  #B4	  = 493.88

  #C5	  = 523.25
  #Db5  = 554.37
  #D5	  = 587.33
  #Eb5  = 622.25
  #E5	  = 659.25
  #F5	  = 698.46
  #Gb5  = 739.99
  #G5	  = 783.99
  #Ab5  = 830.61
  #A5	  = 880.00
  #Bb5  = 932.33
  #B5	  = 987.77

  #C6	  = 1046.50
  #Db6  = 1108.73
  #D6	  = 1174.66
  #Eb6  = 1244.51
  #E6	  = 1318.51
  #F6	  = 1396.91
  #Gb6  = 1479.98
  #G6	  = 1567.98
  #Ab6  = 1661.22
  #A6	  = 1760.00
  #Bb6  = 1864.66
  #B6	  = 1975.53

  #C7	  = 2093.00
  #Db7  = 2217.46
  #D7	  = 2349.32
  #Eb7  = 2489.02
  #E7	  = 2637.02
  #F7	  = 2793.83
  #Gb7  = 2959.96
  #G7	  = 3135.96
  #Ab7  = 3322.44
  #A7	  = 3520.00
  #Bb7  = 3729.31
  #B7	  = 3951.07

  #C8	  = 4186.01
  #Db8  = 4434.92
  #D8	  = 4698.63
  #Eb8  = 4978.03
  #E8	  = 5274.04
  #F8	  = 5587.65
  #Gb8  = 5919.91
  #G8	  = 6271.93
  #Ab8  = 6644.88
  #A8	  = 7040.00
  #Bb8  = 7458.62
  #B8	  = 7902.13


  #NUM_NOTES  = 12
  #NUM_OCTAVES = 9
  
  DataSection
    NOTES: 
	  Data.f #C0, #Db0, #D0, #Eb0, #E0, #F0, #Gb0, #G0, #Ab0, #A0, #Bb0, #B0
	  Data.f #C1, #Db1, #D1, #Eb1, #E1, #F1, #Gb1, #G1, #Ab1, #A1, #Bb1, #B1
  	Data.f #C2, #Db2, #D2, #Eb2, #E2, #F2, #Gb2, #G2, #Ab2, #A2, #Bb2, #B2 
  	Data.f #C3, #Db3, #D3, #Eb3, #E3, #F3, #Gb3, #G3, #Ab3, #A3, #Bb3, #B3 
  	Data.f #C4, #Db4, #D4, #Eb4, #E4, #F4, #Gb4, #G4, #Ab4, #A4, #Bb4, #B4 
  	Data.f #C5, #Db5, #D5, #Eb5, #E5, #F5, #Gb5, #G5, #Ab5, #A5, #Bb5, #B5 
  	Data.f #C6, #Db6 ,#D6, #Eb6, #E6, #F6, #Gb6, #G6, #Ab6, #A6, #Bb6, #B6 
  	Data.f #C7, #Db7, #D7, #Eb7, #E7, #F7, #Gb7, #G7, #Ab7, #A7, #Bb7, #B7 
  	Data.f #C8, #Db8, #D8, #Eb8, #E8, #F8, #Gb8, #G8, #Ab8, #A8, #Bb8, #B8 
  EndDataSection
  
  Macro NoteAt(_octave, _note)
    PeekF(STK::?NOTES + (_octave * STK::#NUM_NOTES + _note) * 4)
  EndMacro
  
  Macro Error : l : EndMacro
  Enumeration
    #ERROR_STATUS
    #ERROR_WARNING
    #ERROR_DEBUG_PRINT
    #ERROR_MEMORY_ALLOCATION
    #ERROR_MEMORY_ACCESS
    #ERROR_FUNCTION_ARGUMENT
    #ERROR_FILE_NOTFOUND
    #ERROR_FILE_UNKNOWNFORMAT
    #ERROR_FILE_ERROR
    #ERROR_PROCESS_THREAD
    #ERROR_PROCESS_SOCKET
    #ERROR_PROCESS_SOCKET_IPADDR
    #ERROR_AUDIO_SYSTEM
    #ERROR_MIDI_SYSTEM
    #ERROR_UNSPECIFIED
  EndEnumeration
    
  Macro Format : l : EndMacro
  #SINT8    = 1               ; 8-bit signed integer.
  #SINT16   = 2               ; 16-bit signed integer.
  #SINT24   = 4               ; 24-bit signed integer.
  #SINT32   = 8               ; 32-bit signed integer.
  #FLOAT32  = 16              ; normalized between plus/minus 1.0.
  #FLOAT64  = 32              ; normalized between plus/minus 1.0.  
  
  Macro StreamFlags : l :EndMacro
  #NONINTERLEAVED     = 1     ; use non-interleaved buffers (Default = interleaved).
  #MINIMIZE_LATENCY   = 2     ; attempt To set stream parameters for lowest possible latency.
  #HOG_DEVICE         = 4     ; attempt grab device And prevent use by others.
  #SCHEDULE_REALTIME  = 8     ; try To Select realtime scheduling For callback thread.
  #ALSA_USE_DEFAULT   = 16    ; use the "default" PCM device (ALSA only).
  
  Macro StreamStatus : l :EndMacro
  #INPUT_OVERFLOW     = 1     ; input Data was discarded because of an overflow condition at the driver.
  #OUTPUT_UNDERFLOW   = 2     ; the output buffer ran low, likely causing a gap in the output sound.
    
  Structure DeviceInfo
    probed.b                  ; true If the device capabilities were successfully probed
    name.s                    ; character string device identifier
    outputChannels.i          ; maximum output channels supported by device
    inputChannels.i           ; maximum input channels supported by device
    duplexChannels.i          ; maximum simultaneous input/output channels supported by device
    isDefaultOutput.b         ; true If this is the Default output device.
    isDefaultInput.b          ; true If this is the Default input device.
    *sampleRates              ; supported sample rates (queried from list of standard rates <std::vector>).
    nativeFormats.Format      ; bit mask of supported Data formats.
  EndStructure
  
    
  Macro GeneratorType : l : EndMacro
  Enumeration
	  #GENERATOR_ASYMP
	  #GENERATOR_NOISE
	  #GENERATOR_BLIT
	  #GENERATOR_BLITSAW
	  #GENERATOR_BLITSQUARE
	  #GENERATOR_SINEWAVE
	  #GENERATOR_SINGWAVE
	  #GENERATOR_MODULATE
    #GENERATOR_GRANULATE
  EndEnumeration
	
	Dim generator_names.s(9)
  generator_names(0)  = "ASYMP_GENERATOR" 
  generator_names(1)  = "NOISE_GENERATOR"
  generator_names(2)  = "BLIT_GENERATOR"
  generator_names(3)  = "BLITSAW_GENERATOR"  
  generator_names(4)  = "BLITSQUARE_GENERATOR" 
  generator_names(5)  = "SINEWAVE_GENERATOR"
  generator_names(6)  = "SINGWAVE_GENERATOR"
  generator_names(7)  = "GRANULATE_GENERATOR"
  generator_names(8)  = "MODULATE_GENERATOR"
  
  Enumeration
    #GEN_T60					; asymp t60
		#GEN_TARGET				; asymp target
		#GEN_TAU					; asymp tau
		#GEN_TIME         ; asymp time
		#GEN_VALUE        ; asymp value
		#GEN_FREQUENCY    ; waves frequency
		#GEN_HARMONICS    ; waves harmonics
		#GEN_PHASE        ; waves phase
		#GEN_PHASEOFFSET  ; sine wave phase offset
		#GEN_SEED					; noise seed
	EndEnumeration
  
  Macro EnvelopeType : l : EndMacro
  Enumeration
	  #ENVELOPE_GENERATOR 
    #ADSR_GENERATOR
	EndEnumeration
  
  Dim envelope_names.s(2)
  envelope_names(0)  = "ENVELOPE_GENERATOR"
  envelope_names(1)  = "ADSR_GENERATOR"
  
  Enumeration
    #ENV_ATTACK_RATE
		#ENV_ATTACK_TARGET
		#ENV_ATTACK_TIME
		#ENV_DECAY_RATE
		#ENV_DECAY_TIME
		#ENV_SUSTAIN_LEVEL
		#ENV_RELEASE_RATE
		#ENV_RELEASE_TIME
		#ENV_TARGET
		#ENV_VALUE
		#ENV_RATE
		#ENV_TIME
	EndEnumeration
	
  
  Macro ArythmeticMode : l : EndMacro
	Enumeration
	  #ARYTHMETIC_ADD
	  #ARYTHMETIC_SUBTRACT
	  #ARYTHMETIC_MULTIPLY
	  #ARYTHMETIC_SCALE
	  #ARYTHMETIC_SCALEADD
	  #ARYTHMETIC_SCALESUBTRACT
	  #ARYTHMETIC_MIX
	  #ARYTHMETIC_BLEND
	  #ARYTHMETIC_SHIFT
	EndEnumeration
	
	Dim arythmetic_modes.s(9)
  arythmetic_modes(0)  = "ADD"
  arythmetic_modes(1)  = "SUBTRACT"
  arythmetic_modes(2)  = "MULTIPLY" 
  arythmetic_modes(3)  = "SCALE"
  arythmetic_modes(4)  = "SCALEADD"
  arythmetic_modes(5)  = "SCALESUB" 
  arythmetic_modes(6)  = "MIX"
  arythmetic_modes(7)  = "BLEND"
  arythmetic_modes(8)  = "SHIFT"
  
  Macro EffectType : l : EndMacro
  Enumeration
	  #EFFECT_ENVELOPE
	  #EFFECT_PRCREV
	  #EFFECT_JCREV
	  #EFFECT_NREV
	  #EFFECT_FREEVERB
	  #EFFECT_ECHO
	  #EFFECT_PITSHIFT
	  #EFFECT_LENTPITSHIFT
	  #EFFECT_CHORUS
	  #EFFECT_MOOG
	EndEnumeration
	
	Dim effect_types.s(10)
  effect_types(0)  = "ENVELOPE"
  effect_types(1)  = "PRCREV"
  effect_types(2)  = "JCREV" 
  effect_types(3)  = "NREV"
  effect_types(4)  = "FREEVERB"
  effect_types(5)  = "ECHO" 
  effect_types(6)  = "PITSHIFT"
  effect_types(7)  = "LENTPITSHIFT"
  effect_types(8)  = "CHORUS"
  effect_types(9)  = "MOOG"
  
  Macro Attributes : l : EndMacro
  Enumeration
    #EFFECT_RATE              ; envelope rate
    #EFFECT_TIME              ; envelope time
    #EFFECT_TARGET            ; envelope target
    #EFFECT_VALUE             ; envelope value
    #EFFECT_T60               ; prcrev, jcrev, nrev T60
    #EFFECT_MIX               ; effect mix
    #EFFECT_ROOMSIZE          ; freeverb room size
    #EFFECT_DAMPING           ; freeverb damping
    #EFFECT_WIDTH             ; freeverb width
    #EFFECT_MODE              ; freeverb mode
    #EFFECT_DELAY             ; echo delay
    #EFFECT_MAXIMUMDELAY      ; echo maximum delay
    #EFFECT_SHIFT             ; pitshift and letpitshift shift
    #EFFECT_MODDEPTH          ; chorus/moog mod depth
    #EFFECT_MODFREQUENCY      ; chorus/moog mod frequency
  EndEnumeration
  

  Structure RtAudio           ; opaque cpp structure
  EndStructure
  
  Structure Node
  EndStructure
  
  Structure Generator
  EndStructure
  
  Structure Envelope
  EndStructure
  
  Structure Arythmetic
  EndStructure
  
  Structure Effect
  EndStructure
  
  Structure Buffer
  EndStructure
  
  Structure Stream
  EndStructure
  
  ;----------------------------------------------------------------------------------
  ; Prototypes
  ;----------------------------------------------------------------------------------
  PrototypeC INIT()
  PrototypeC TERM(*DAC.RtAudio)
  PrototypeC GETDEVICES()
  
  PrototypeC.b ISROOT(*node.Node)
  PrototypeC SETASROOT(*node.Node, isRoot.b)
  PrototypeC GETSTREAM(*node.Node)
  PrototypeC SETHASNOEFFECTS(*node.Node)
  PrototypeC SETNODEVOLUME(*node.Node, volume.f=1.0)
  PrototypeC NODERESET(*node.Node)
    
  PrototypeC STREAMSETUP(*DAC.RtAudio)
  PrototypeC STREAMCLEAN(*stream.Stream)
  PrototypeC STREAMSTART(*stream.Stream)
  PrototypeC STREAMSTOP(*stream.Stream)
  PrototypeC STREAMSETFREQUENCY(*stream.Stream, frequency.f)
   
  PrototypeC ADDGENERATOR(*stream.Stream, type.l, frequency.f, asRoot.b=#True)
  PrototypeC ADDENVELOPE(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDARYTHMETIC(*stream.Stream, mode.l, *lhs.Node, *rhs.Node, asRoot.b=#True)
  PrototypeC ADDEFFECT(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDFILTER(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDBUFFER(*stream.Stream, *source.Node, asRoot.b=#False)
  
  PrototypeC SETGENERATORTYPE(*stream.Generator, type.l)
  PrototypeC SETGENERATORSCALAR(*stream.Generator, param.l, scalar.f)
  
  PrototypeC SETENVELOPETYPE(*envelope.Envelope, type.l)
  PrototypeC SETENVELOPESCALAR(*envelope.Envelope, param.l, scalar.f)
  PrototypeC ENVELOPEKEYON(*envelope.Envelope)
  PrototypeC ENVELOPEKEYOFF(*envelope.Envelope)
  
  PrototypeC SETARYTHMETICMODE(*arythmetic.Arythmetic, mode.l)
  PrototypeC SETARYTHMETICSCALAR(*arythmetic.Arythmetic, scalar.f)
  PrototypeC SETARYTHMETICLHS(*arythmetic.Arythmetic, *node.Node)
  PrototypeC SETARYTHMETICRHS(*arythmetic.Arythmetic, *node.Node)
  
  PrototypeC SETEFFECTTYPE(*effect.Effect, type.l)
  PrototypeC SETEFFECTSCALAR(*effect.Effect, param.l, scalar.f)
  
  ;----------------------------------------------------------------------------------
  ; Import Functions
  ;----------------------------------------------------------------------------------
  Global STK_LIB = #Null
  If FileSize("../../libs")=-2
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        STK_LIB = OpenLibrary(#PB_Any, "../../libs/x64/windows/STK.dll")
      CompilerCase #PB_OS_MacOS
;         ImportC "-lstdc++" : EndImport
;         ImportC "-lasound" : EndImport
;         ImportC "-lpthread" : EndImport
        STK_LIB = OpenLibrary(#PB_Any, "../../libs/x64/macosx/STK.so")
      CompilerCase #PB_OS_Linux
        ImportC "-lstdc++" : EndImport
        ImportC "-lasound" : EndImport
        ImportC "-lpthread" : EndImport
        STK_LIB = OpenLibrary(#PB_Any, "../../libs/x64/linux/STK.so")
    CompilerEndSelect
  Else
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        STK_LIB = OpenLibrary(#PB_Any, "libs/x64/windows/STK.dll")
      CompilerCase #PB_OS_MacOS
;         ImportC "-lstdc++" : EndImport
;         ImportC "-lasound" : EndImport
;         ImportC "-lpthread" : EndImport
        STK_LIB = OpenLibrary(#PB_Any, "libs/x64/macosx/STK.so")
      CompilerCase #PB_OS_Linux
        ImportC "-lstdc++" : EndImport
        ImportC "-lasound" : EndImport
        ImportC "-lpthread" : EndImport
        STK_LIB = OpenLibrary(#PB_Any, "libs/x64/linux/STK.so")
    CompilerEndSelect
  EndIf
  
  If STK_LIB
    Global Init.INIT = GetFunction(STK_LIB, "STKInit")
    Global Term.TERM = GetFunction(STK_LIB, "STKTerm")
    Global GetDevices.GETDEVICES = GetFunction(STK_LIB, "STKGetDevices")
    
    Global.b IsRoot.ISROOT = GetFunction(STK_LIB, "STKIsRoot")
    Global SetAsRoot.SETASROOT = GetFunction(STK_LIB, "STKSetAsRoot")
    Global GetStream.GETSTREAM = GetFunction(STK_LIB, "STKGetStream")
    Global SetHasNoEffects.SETHASNOEFFECTS = GetFunction(STK_LIB, "STKSetHasNoEffects")
    Global SetNodeVolume.SETNODEVOLUME = GetFunction(STK_LIB, "STKSetNodeVolume")
    Global NodeReset.NODERESET = GetFunction(STK_LIB, "STKNodeReset")

    Global StreamSetup.STREAMSETUP = GetFunction(STK_LIB, "STKStreamSetup")
    Global StreamClean.STREAMCLEAN = GetFunction(STK_LIB, "STKStreamClean")
    Global StreamStart.STREAMSTART = GetFunction(STK_LIB, "STKStreamStart")
    Global StreamStop.STREAMSTOP = GetFunction(STK_LIB, "STKStreamStop")
    
    Global AddGenerator.ADDGENERATOR = GetFunction(STK_LIB, "STKAddGenerator")
    Global AddEnvelope.ADDENVELOPE= GetFunction(STK_LIB, "STKAddEnvelope")
    Global AddArythmetic.ADDARYTHMETIC = GetFunction(STK_LIB, "STKAddArythmetic")
    Global AddEffect.ADDEFFECT = GetFunction(STK_LIB, "STKAddEffect")
    Global AddFilter.ADDFILTER = GetFunction(STK_LIB, "STKAddFilter")
    Global AddBuffer.ADDBUFFER = GetFunction(STK_LIB, "STKAddBuffer")
    
    Global SetGeneratorType.SETGENERATORTYPE = GetFunction(STK_LIB, "STKSetGeneratorType")
    Global SetGeneratorScalar.SETGENERATORSCALAR = GetFunction(STK_LIB, "STKSetGeneratorScalar")
    
    Global SetEnvelopeType.SETENVELOPETYPE = GetFunction(STK_LIB, "STKSetEnvelopeType")
    Global SetEnvelopeScalar.SETENVELOPESCALAR = GetFunction(STK_LIB, "STKSetEnvelopeScalar")
    Global EnvelopeKeyOn.ENVELOPEKEYON = GetFunction(STK_LIB, "STKEnvelopeKeyOn")
    Global EnvelopeKeyOff.ENVELOPEKEYOFF = GetFunction(STK_LIB, "STKEnvelopeKeyOff")
    
    Global SetArythmeticMode.SETARYTHMETICMODE = GetFunction(STK_LIB, "STKSetArythmeticMode")
    Global SetArythmeticScalar.SETARYTHMETICSCALAR = GetFunction(STK_LIB, "STKSetArythmeticScalar")
    Global SetArythmeticLHS.SETARYTHMETICLHS = GetFunction(STK_LIB, "STKSetArythmeticLHS")
    Global SetArythmeticRHS.SETARYTHMETICRHS = GetFunction(STK_LIB, "STKSetArythmeticRHS")
    
    Global SetEffectType.SETEFFECTTYPE = GetFunction(STK_LIB, "STKSetEffectType")
    Global SetEffectScalar.SETEFFECTSCALAR= GetFunction(STK_LIB, "STKSetEffectScalar")
        
  Else
    MessageRequester("STK Error","Can't Find STK Library!!")
  EndIf 
  

  Global *DAC.RTAudio
  Global initialized.b
  
  Global RAWWAVEPATH.s = "E:/Projects/RnD/STK/rawwaves"
  
  Declare Initialize()
  Declare Terminate()
  Declare InitRawWaves()
  Global NewList RAWWAVEFILES.s()
  
EndDeclareModule

; ===================================================================================
;  RTAUDIO MODULE IMPLEMENTATION
; ===================================================================================
Module STK
  Procedure InitRawWaves()
    Define dir = ExamineDirectory(#PB_Any, RAWWAVEPATH, "*.raw")
    While NextDirectoryEntry(dir)
      AddElement(RAWWAVEFILES())
      RAWWAVEFILES() = DirectoryEntryName(dir)

    Wend
    FinishDirectory(dir)
  EndProcedure
  
;   ;----------------------------------------------------------------------------------
;   ; Get Buffer
;   ;----------------------------------------------------------------------------------
;   Procedure MFAudio_GetBuffer(*audio.MFAudio)
;     ;RTAudio_GetBuffer(*audio\buffer,*audio\mem+ *audio\currentSample* *audio\sizeSample)
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Get Average
;   ;----------------------------------------------------------------------------------
;   Procedure.f MFAudio_GetAverage(*audio.MFAudio)
;     
;     ; Get average
;     Protected v.l = 0
;     Protected sv.i
;     Define p
;     Define l.f
;     
;     ; channel 1
;     For p=0 To *audio\nbFrames-1
;       l+ Abs(PeekF(*audio\mem+SizeOf(*audio\frameType)*p))
;     Next
;     ProcedureReturn l/*audio\nbFrames
;       
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Get Beat
;   ;----------------------------------------------------------------------------------
;   Procedure.b MFAudio_GetBeat(*audio.MFAudio)
;     *audio\cb = 0
;     Protected s
;     For s=0 To *audio\nbFrames-1
;       *audio\cb + Abs(PeekF(*audio\mem+SizeOf(*audio\frameType)*s))
;     Next
;     
;     *audio\cb/*audio\nbFrames
;     
;     Protected tmp.f = *audio\lb
;     *audio\lb = *audio\cb
;     *audio\ib = Bool(*audio\cb>tmp)
;     ProcedureReturn *audio\ib
;   EndProcedure
;   
;   
;   ;----------------------------------------------------------------------------------
;   ; Constructor
;   ;----------------------------------------------------------------------------------
;   Procedure newMFAudio(mode.i,filename.s)
;     If RTAudio_Init() 
;       Protected *audio.MFAudio = AllocateMemory(SizeOf(MFAudio))
;       *audio\nbChannels = 1
;       *audio\nbFrames = 1024
;       *audio\nbSamples = 1
;       *audio\currentSample = 0
;       *audio\sizeSample = *audio\nbFrames * SizeOf(*audio\frameType)
;       *audio\mem = AllocateMemory( *audio\sizeSample * *audio\nbSamples)
;       *audio\buffer = RTAudio_InitBuffer()
;       ;RTAudio_SetMode(*audio\buffer,mode,filename)
;       ProcedureReturn *audio
;     Else
;       MessageRequester("RtAudio ERROR","Can't Initiate RtAudio!!")
;       ProcedureReturn #Null
;     EndIf
;     
;   EndProcedure
;   
;   ;----------------------------------------------------------------------------------
;   ; Destructor
;   ;----------------------------------------------------------------------------------
;   Procedure deleteMFAudio(*audio.MFAudio)
;     RTAudio_TermBuffer(*audio\buffer)
;     FreeMemory(*audio\mem)
;   EndProcedure
  
  Procedure Initialize()
    *DAC = STK::Init()
    STK::InitRawWaves()
  EndProcedure
  
  Procedure Terminate()  
    STK::Term(*DAC)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 496
; FirstLine = 491
; Folding = ---
; EnableXP