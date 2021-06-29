; ===================================================================================
;     SYNTHESIS TOOL KIT MODULE DECLARATION
; ===================================================================================
DeclareModule STK
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
; 	  #GENERATOR_SINGWAVE
; 	  #GENERATOR_MODULATE
;     #GENERATOR_GRANULATE
	EndEnumeration
	
	Dim generator_names.s(6)
  generator_names(0)  = "ASYMP_GENERATOR" 
  generator_names(1)  = "NOISE_GENERATOR"
  generator_names(2)  = "BLIT_GENERATOR"
  generator_names(3)  = "BLITSAW_GENERATOR"  
  generator_names(4)  = "BLITSQUARE_GENERATOR" 
  generator_names(5)  = "SINEWAVE_GENERATOR"
  
;   generator_names(6)  = "SINGWAVE_GENERATOR"
;   generator_names(7)  = "GRANULATE_GENERATOR"
;   generator_names(8)  = "MODULATE_GENERATOR"
  
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
  envelope_names(0)  = "ENVELOPE"
  envelope_names(1)  = "ADSR"
  
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
  
  Macro EffectParam : l : EndMacro
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
  
  Dim effect_params.s(15)
  effect_params(0)  = "RATE"
  effect_params(1)  = "TIME"
  effect_params(2)  = "TARGET" 
  effect_params(3)  = "VALUE"
  effect_params(4)  = "T60"
  effect_params(5)  = "MIX" 
  effect_params(6)  = "ROOMSIZE"
  effect_params(7)  = "DAMPING"
  effect_params(8)  = "WIDTH"
  effect_params(9)  = "MODE"
  effect_params(10)  = "DELAY"
  effect_params(11)  = "MAXIMUMDELAY"
  effect_params(12)  = "SHIFT"
  effect_params(13)  = "MODDEPTH"
  effect_params(14)  = "MODFREQUENCY"
  
  Macro ReaderMode: l : EndMacro
  Enumeration
    #READER_FILEWVIN
    #READER_FILELOOP
  EndEnumeration
  
  Dim reader_modes.s(2)
  reader_modes(0)  = "FILEWVIN"
  reader_modes(1)  = "FILELOOP"
  
  Macro ReaderParam: l : EndMacro
  Enumeration
    #READER_RATE
    #READER_FREQUENCY
    #READER_ADDTIME
    #READER_ADDPHASE 
    #READER_ADDPHASEOFFSET
  EndEnumeration
  
  Dim reader_params.s(5)
  reader_params(0)  = "RATE"
  reader_params(1)  = "FREQUENCY"
  reader_params(2)  = "ADDTIME"
  reader_params(3)  = "ADDPHASE"
  reader_params(4)  = "ADDPHASEOFFSET"
  
  Macro WriterFormat: l : EndMacro
  Enumeration
    #WRITER_FORMAT_RAW
    #WRITER_FORMAT_WAV
    #WRITER_FORMAT_SND
    #WRITER_FORMAT_AIFF
    #WRITER_FORMAT_MAT 
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
  
  Structure Reader
  EndStructure
  
  Structure Stream
  EndStructure
  
  ;----------------------------------------------------------------------------------
  ; Prototypes
  ;----------------------------------------------------------------------------------
  PrototypeC INIT()
  PrototypeC TERM(*DAC.RtAudio)
  PrototypeC GETDEVICES()
  PrototypeC SETSAMPLERATE(rate.i)
  
  PrototypeC.b ISROOT(*node.Node)
  PrototypeC SETASROOT(*node.Node, isRoot.b)
  PrototypeC GETSTREAM(*node.Node)
  PrototypeC SETHASNOEFFECTS(*node.Node)
  PrototypeC SETNODEVOLUME(*node.Node, volume.f=1.0)
  PrototypeC NODERESET(*node.Node)
    
  PrototypeC STREAMSETUP(*DAC.RtAudio, numChannels.l)
  PrototypeC STREAMCLEAN(*stream.Stream)
  PrototypeC STREAMSTART(*stream.Stream)
  PrototypeC STREAMSTOP(*stream.Stream)
  PrototypeC STREAMSETFREQUENCY(*stream.Stream, frequency.f)
  PrototypeC STREAMNUMROOTS(*stream.Stream)
   
  PrototypeC ADDGENERATOR(*stream.Stream, type.l, frequency.f, asRoot.b=#True)
  PrototypeC ADDENVELOPE(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDARYTHMETIC(*stream.Stream, mode.l, *lhs.Node, *rhs.Node, asRoot.b=#True)
  PrototypeC ADDEFFECT(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDFILTER(*stream.Stream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDBUFFER(*stream.Stream, *source.Node, asRoot.b=#False)
  PrototypeC ADDREADER(*stream.Stream, filename.p-utf8, asRoot.b=#False)
  
  PrototypeC ADDNODE(*stream.Stream, *node.Node, isRoot.b)
  PrototypeC REMOVENODE(*stream.Stream, *node.Node)
  
  PrototypeC SETGENERATORTYPE(*stream.Generator, type.l)
  PrototypeC SETGENERATORSCALAR(*stream.Generator, param.l, scalar.f)
  PrototypeC GETGENERATORTYPE(*stream.Generator)
  
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
  
  PrototypeC SETREADERMODE(*reader.Reader, mode.l)
  PrototypeC SETREADERSCALAR(*reader.Reader, param.l, scalar.f)
  PrototypeC SETREADERFILENAME(*reader.Reader, filename.p-utf8)
  PrototypeC RESETREADER(*reader.Reader)
  PrototypeC.f GETREADERFILESAMPLERATE(*reader.Reader)
  
  ;----------------------------------------------------------------------------------
  ; Import Functions
  ;----------------------------------------------------------------------------------
  Global STK_LIB = #Null
  If FileSize("../../libs")=-2
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        STK_LIB = OpenLibrary(#PB_Any, "../../libs/x64/windows/STK.dll")
      CompilerCase #PB_OS_MacOS
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
    Global SetSampleRate.SETSAMPLERATE = GetFunction(STK_LIB, "STKSetSampleRate")
    
    
    Global.b IsRoot.ISROOT = GetFunction(STK_LIB, "STKNodeIsRoot")
    Global SetAsRoot.SETASROOT = GetFunction(STK_LIB, "STKSetNodeIsRoot")
    Global GetStream.GETSTREAM = GetFunction(STK_LIB, "STKGetStream")
    Global SetHasNoEffects.SETHASNOEFFECTS = GetFunction(STK_LIB, "STKSetHasNoEffects")
    Global SetNodeVolume.SETNODEVOLUME = GetFunction(STK_LIB, "STKNodeSetVolume")
    Global NodeReset.NODERESET = GetFunction(STK_LIB, "STKNodeReset")

    Global StreamSetup.STREAMSETUP = GetFunction(STK_LIB, "STKStreamSetup")
    Global StreamClean.STREAMCLEAN = GetFunction(STK_LIB, "STKStreamClean")
    Global StreamStart.STREAMSTART = GetFunction(STK_LIB, "STKStreamStart")
    Global StreamStop.STREAMSTOP = GetFunction(STK_LIB, "STKStreamStop")
    Global StreamNumRoots.STREAMNUMROOTS = GetFunction(STK_LIB, "STKStreamNumRoots")
    
    Global AddGenerator.ADDGENERATOR = GetFunction(STK_LIB, "STKStreamAddGenerator")
    Global AddEnvelope.ADDENVELOPE= GetFunction(STK_LIB, "STKStreamAddEnvelope")
    Global AddArythmetic.ADDARYTHMETIC = GetFunction(STK_LIB, "STKStreamAddArythmetic")
    Global AddEffect.ADDEFFECT = GetFunction(STK_LIB, "STKStreamAddEffect")
    Global AddFilter.ADDFILTER = GetFunction(STK_LIB, "STKStreamAddFilter")
    Global AddBuffer.ADDBUFFER = GetFunction(STK_LIB, "STKStreamAddBuffer")
    Global AddReader.ADDREADER = GetFunction(STK_LIB, "STKStreamAddReader")
    
    Global AddNode.ADDNODE = GetFunction(STK_LIB, "STKStreamAddNode")
    Global RemoveNode.REMOVENODE = GetFunction(STK_LIB, "STKStreamRemoveNode")
    Global SetGeneratorType.SETGENERATORTYPE = GetFunction(STK_LIB, "STKSetGeneratorType")
    Global SetGeneratorScalar.SETGENERATORSCALAR = GetFunction(STK_LIB, "STKSetGeneratorScalar")
    Global GetGeneratorType.GETGENERATORTYPE = GetFunction(STK_LIB, "STKGetGeneratorType")
    
    Global SetEnvelopeType.SETENVELOPETYPE = GetFunction(STK_LIB, "STKSetEnvelopeType")
    Global SetEnvelopeScalar.SETENVELOPESCALAR = GetFunction(STK_LIB, "STKSetEnvelopeScalar")
    Global EnvelopeKeyOn.ENVELOPEKEYON = GetFunction(STK_LIB, "STKEnvelopeKeyOn")
    Global EnvelopeKeyOff.ENVELOPEKEYOFF = GetFunction(STK_LIB, "STKEnvelopeKeyOff")
    
    Global SetArythmeticMode.SETARYTHMETICMODE = GetFunction(STK_LIB, "STKSetArythmeticMode")
    Global SetArythmeticMode.SETARYTHMETICMODE = GetFunction(STK_LIB, "STKSetArythmeticMode")
    Global SetArythmeticScalar.SETARYTHMETICSCALAR = GetFunction(STK_LIB, "STKSetArythmeticScalar")
    Global SetArythmeticLHS.SETARYTHMETICLHS = GetFunction(STK_LIB, "STKSetArythmeticLHS")
    Global SetArythmeticRHS.SETARYTHMETICRHS = GetFunction(STK_LIB, "STKSetArythmeticRHS")
    
    Global SetEffectType.SETEFFECTTYPE = GetFunction(STK_LIB, "STKSetEffectType")
    Global SetEffectScalar.SETEFFECTSCALAR= GetFunction(STK_LIB, "STKSetEffectScalar")
    
    Global SetReaderMode.SETREADERMODE = GetFunction(STK_LIB, "STKSetReaderMode")
    Global SetReaderScalar.SETREADERSCALAR = GetFunction(STK_LIB, "STKSetReaderScalar")
    Global SetReaderFilename.SETREADERFILENAME = GetFunction(STK_LIB, "STKSetReaderFilename")
    Global ResetReader.RESETREADER = GetFunction(STK_LIB, "STKResetReader")
    Global GetReaderFileSampleRate.GETREADERFILESAMPLERATE = GetFunction(STK_LIB, "STKGetReaderFileSampleRate")
  Else
    MessageRequester("STK Error","Can't Find STK Library!!")
  EndIf 
 
  Global *DAC.RTAudio
  Global initialized.b
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Global RAWWAVEPATH.s = "E:/Projects/RnD/STK/rawwaves"
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
    Global RAWWAVEPATH.s = "/Users/benmalartre/Documents/RnD/STK/rawwaves"
  CompilerElse
    Global RAWWAVEPATH.s = "/Users/benmalartre/Documents/RnD/STK/rawwaves"
  CompilerEndIf
  
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
    Debug "STK INITIALIZE !!!"
    *DAC = STK::Init()
    Debug "DAC : "+Str(*DAC)
    STK::InitRawWaves()
    ProcedureReturn *DAC
  EndProcedure
  
  Procedure Terminate()  
    STK::Term(*DAC)
    *DAC = #Null
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 412
; FirstLine = 398
; Folding = ----
; EnableXP