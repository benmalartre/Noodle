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
  #MINIMIZE_LATENCY   = 2     ; attempt To set stream parameters For lowest possible latency.
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
  
    
  Macro STKGeneratorType : l : EndMacro
  Enumeration
	  #ASYMP_GENERATOR 
	  #NOISE_GENERATOR
	  #BLIT_GENERATOR
	  #BLITSAW_GENERATOR  
	  #BLITSQUARE_GENERATOR
	  #SINEWAVE_GENERATOR 
	  #SINGWAVE_GENERATOR 
	  #MODULATE_GENERATOR 
    #GRANULATE_GENERATOR
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
    #GENERATOR_T60					; asymp t60
		#GENERATOR_TARGET				; asymp target
		#GENERATOR_TAU					; asymp tau
		#GENERATOR_TIME         ; asymp time
		#GENERATOR_VALUE        ; asymp value
		#GENERATOR_FREQUENCY    ; waves frequency
		#GENERATOR_HARMONICS    ; waves harmonics
		#GENERATOR_PHASE        ; waves phase
		#GENERATOR_PHASEOFFSET  ; sine wave phase offset
		#GENERATOR_SEED					; noise seed
	EndEnumeration
  
  Macro STKEnvelopeType : l : EndMacro
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
	
  
  Macro STKArythmeticMode : l : EndMacro
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
  
  Macro STKEffectType : l : EndMacro
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
	EndEnumeration
	
	Dim effect_types.s(9)
  effect_types(0)  = "ENVELOPE"
  effect_types(1)  = "PRCREV"
  effect_types(2)  = "JCREV" 
  effect_types(3)  = "NREV"
  effect_types(4)  = "FREEVERB"
  effect_types(5)  = "ECHO" 
  effect_types(6)  = "PITSHIFT"
  effect_types(7)  = "LENTPITSHIFT"
  effect_types(8)  = "CHORUS"
  
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
    #EFFECT_MODDEPTH          ; chorus mod depth
    #EFFECT_MODFREQUENCY      ; chorus mod frequency
  EndEnumeration
  

  Structure RtAudio                   ; opaque cpp structure
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
  
  Structure BufferStream
  EndStructure
  
  Structure GeneratorStream
  EndStructure
  
  Structure VoicerStream
  EndStructure
  
  
  ;----------------------------------------------------------------------------------
  ; Prototypes
  ;----------------------------------------------------------------------------------
  PrototypeC INIT()
  PrototypeC GETDEVICES()
    
  PrototypeC GENERATORSTREAMSETUP(*DAC.RtAudio)
  PrototypeC GENERATORSTREAMCLEAN(*generator.GeneratorStream)
  PrototypeC GENERATORSTREAMSTART(*generator.GeneratorStream)
  PrototypeC GENERATORSTREAMSTOP(*generator.GeneratorStream)
  PrototypeC GENERATORSTREAMSETFREQUENCY(*generator.GeneratorStream, frequency.f)
  
  
  PrototypeC ADDGENERATOR(*generator.GeneratorStream, type.l, frequency.f, asRoot.b=#True)
  PrototypeC ADDENVELOPE(*generator.GeneratorStream, type.l, *source.Node, asRoot.b=#False)
  PrototypeC ADDARYTHMETIC(*generator.GeneratorStream, mode.l, *lhs.Node, *rhs.Node, asRoot.b=#True)
  PrototypeC ADDEFFECT(*generator.GeneratorStream, type.l, *source.Node, asRoot.b=#False)
  
  PrototypeC SETGENERATORTYPE(*generator.Generator, type.l)
  PrototypeC SETGENERATORSCALAR(*generator.Generator, param.l, scalar.f)
  
  PrototypeC SETENVELOPETYPE(*envelope.Envelope, type.l)
  PrototypeC SETENVELOPESCALAR(*envelope.Envelope, param.l, scalar.f)
  PrototypeC ENVELOPEKEYON(*envelope.Envelope)
  PrototypeC ENVELOPEKEYOFF(*envelope.Envelope)
  
  PrototypeC SETARYTHMETICMODE(*arythmetic.Arythmetic, mode.l)
  PrototypeC SETARYTHMETICSCALAR(*arythmetic.Arythmetic, scalar.f)
  
  PrototypeC SETEFFECTTYPE(*effect.Effect, type.l)
  PrototypeC SETEFFECTSCALAR(*effect.Effect, param.l, scalar.f)
  
  PrototypeC VOICERSTREAMSETUP(*DAC.RtAudio, nbInstruments.l)
  PrototypeC VOICERSTREAMCLEAN(*voicer.VoicerStream)
  PrototypeC VOICERSTREAMSTART(*voicer.VoicerStream)
  PrototypeC VOICERSTREAMSTOP(*voicer.VoicerStream)
  
  PrototypeC BUFFERSTREAMINIT(*DAC.RtAudio, *stream.BufferStream)
  PrototypeC BUFFERSTREAMGET(*stream.BufferStream)
  PrototypeC BUFFERSTREAMTERM(*stream.BufferStream)
  PrototypeC BUFFERSTREAMSETFILE(*stream.BufferStream, filename.s)
  
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
    Global GetDevices.GETDEVICES = GetFunction(STK_LIB, "STKGetDevices")

    Global GeneratorStreamSetup.GENERATORSTREAMSETUP = GetFunction(STK_LIB, "STKGeneratorStreamSetup")
    Global GeneratorStreamClean.GENERATORSTREAMCLEAN = GetFunction(STK_LIB, "STKGeneratorStreamClean")
    Global GeneratorStreamStart.GENERATORSTREAMSTART = GetFunction(STK_LIB, "STKGeneratorStreamStart")
    Global GeneratorStreamStop.GENERATORSTREAMSTOP = GetFunction(STK_LIB, "STKGeneratorStreamStop")
    
    Global AddGenerator.ADDGENERATOR = GetFunction(STK_LIB, "STKAddGenerator")
    Global AddEnvelope.ADDENVELOPE= GetFunction(STK_LIB, "STKAddEnvelope")
    Global AddArythmetic.ADDARYTHMETIC = GetFunction(STK_LIB, "STKAddArythmetic")
    Global AddEffect.ADDEFFECT = GetFunction(STK_LIB, "STKAddEffect")
    
    Global SetGeneratorType.SETGENERATORTYPE = GetFunction(STK_LIB, "STKSetGeneratorType")
    Global SetGeneratorScalar.SETGENERATORSCALAR = GetFunction(STK_LIB, "STKSetGeneratorScalar")
    
    Global SetEnvelopeType.SETENVELOPETYPE = GetFunction(STK_LIB, "STKSetEnvelopeType")
    Global SetEnvelopeScalar.SETENVELOPESCALAR = GetFunction(STK_LIB, "STKSetEnvelopeScalar")
    Global EnvelopeKeyOn.ENVELOPEKEYON = GetFunction(STK_LIB, "STKEnvelopeKeyOn")
    Global EnvelopeKeyOff.ENVELOPEKEYOFF = GetFunction(STK_LIB, "STKEnvelopeKeyOff")
    
    Global SetArythmeticMode.SETARYTHMETICMODE = GetFunction(STK_LIB, "STKSetArythmeticMode")
    Global SetArythmeticScalar.SETARYTHMETICSCALAR = GetFunction(STK_LIB, "STKSetArythmeticScalar")
    
    Global SetEffectType.SETEFFECTTYPE = GetFunction(STK_LIB, "STKSetEffectType")
    Global SetEffectScalar.SETEFFECTSCALAR= GetFunction(STK_LIB, "STKSetEffectScalar")
    
    Global VoicerStreamSetup.VOICERSTREAMSETUP = GetFunction(STK_LIB, "STKVoicerStreamSetup")
    Global VoicerStreamClean.VOICERSTREAMCLEAN = GetFunction(STK_LIB, "STKVoicerStreamClean")
    Global VoicerStreamStart.VOICERSTREAMSTART = GetFunction(STK_LIB, "STKVoicerStreamStart")
    Global VoicerStreamStop.VOICERSTREAMSTOP = GetFunction(STK_LIB, "STKVoicerStreamStop")
    
    Global BufferStreamInit.BUFFERSTREAMINIT = GetFunction(STK_LIB, "STKBufferStreamInit")
    Global BufferStreamGet.BUFFERSTREAMGET = GetFunction(STK_LIB, "STKBufferStreamGet")
    Global BufferStreamTerm.BUFFERSTREAMTERM = GetFunction(STK_LIB, "STKBufferStreamTerm")
    Global BufferStreamSetFile.BUFFERSTREAMSETFILE = GetFunction(STK_LIB,"STKBufferStreamSetFile") 
        
  Else
    MessageRequester("STK Error","Can't Find STK Library!!")
  EndIf 
  
EndDeclareModule

; ===================================================================================
;  RTAUDIO MODULE IMPLEMENTATION
; ===================================================================================
Module STK
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
EndModule

Global WIDTH = 800
Global HEIGHT = 600

Global *DAC.STK::RtAudio = STK::Init()
Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC)
Global *wave.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 128, #False)
Global *envelope.STK::Envelope = STK::AddEnvelope(*stream, STK::#ADSR_GENERATOR, *wave, #False)

STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TIME, 0.01)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_ATTACK_TARGET, 1)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_DECAY_TIME, 0.02)
STK::SetEnvelopeScalar(*envelope, STK::#ENV_RELEASE_TIME, 0.1)

Global *effect.STK::Effect = STK::AddEffect(*stream, STK::#EFFECT_JCREV, *envelope, #True)
STK::SetEffectScalar(*effect, STK::#EFFECT_MIX, 0.2)
; STK::SetEffectScalar(*effect, STK::#EFFECT_T60, 0.5)
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SCALEADD, *envelope, *effect, #True)
; STK::SetArythmeticScalar(*mixer, 0.5)
; Global *adsr.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#ADSR_GENERATOR, 180)
; Global *blit.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLIT_GENERATOR, 180)
; 
; Global *wave1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 66, #False)
; Global *wave2.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 120, #False)
; Global *wave3.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 120, #False)

; Global *lfo1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 0.5, #False)
; 
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SHIFT, *wave1, *lfo1, #False)
; STK::SetArythmeticScalar(*adder1, 2)
; Global *adder2.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave2, *lfo1, #False)
; STK::SetArythmeticScalar(*adder2, 8)
; 
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_BLEND, *adder1, *adder2, #False)
; STK::SetArythmeticScalar(*mixer, 0.5)
; 

; 
; Global *final.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_SCALEADD, *mixer, *effect, #True)
; STK::SetArythmeticScalar(*final, 2)

; Global *adder3.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave3, *lfo1, #False)
; 
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY *wave1, *lfo1, #False)
; STK::SetArythmeticScalar(*adder1, 32)

; Global *lfo2.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 2, #False)
; Global *adder2.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave2, *lfo2, #False)
; 
; Global *mixer.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MIX, *adder1, *adder2, #True)
; STK::SetArythmeticScalar(*mixer, 0.5)

; Global *wave1.STK::Generator = STK::AddGenerator(*stream, STK::#MODULATE_GENERATOR, 226, #False)
; Global *lfo1.STK::Generator = STK::AddGenerator(*stream, STK::#SINEWAVE_GENERATOR, 8, #False)
; Global *adder1.STK::Arythmetic = STK::AddArythmetic(*stream, STK::#ARYTHMETIC_MULTIPLY, *wave1, *lfo1, #True)
; Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 120)
; Global *stream.STK::GeneratorStream = STK::GeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 320)


Global event.i
Global window.i = OpenWindow(#PB_Any, 0,0,WIDTH,HEIGHT,"STK")
Global canvas.i = CanvasGadget(#PB_Any, 0, 0, WIDTH, HEIGHT, #PB_Canvas_Keyboard)
Global running.b = #False


Procedure DrawCanvas()
  StartDrawing(CanvasOutput(canvas))
  If running
    Box(0,0,WIDTH, HEIGHT, RGB(128,255,128))
  Else
    Box(0,0,WIDTH, HEIGHT, RGB(255,128,128))
  EndIf
  StopDrawing()
EndProcedure

DrawCanvas()
Global down.b
Define mx.i, v.f
If *stream
  Repeat
    event = WaitWindowEvent()
    If event = #PB_Event_Gadget And EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_KeyDown
          key = GetGadgetAttribute(canvas, #PB_Canvas_Key)
          If key = #PB_Shortcut_Return
            If running
              STK::GeneratorStreamStop(*stream)
              running = #False  
              DrawCanvas()
            Else
              Define result.b = STK::GeneratorStreamStart(*stream)
              STK::EnvelopeKeyOn(*envelope)
              running = #True
              DrawCanvas()
            EndIf
          ElseIf key = #PB_Shortcut_Space
            STK::EnvelopeKeyOn(*envelope) 
          EndIf
        Case #PB_EventType_LeftButtonDown
          down = #True
        Case #PB_EventType_LeftButtonUp
          down=#False
        Case #PB_EventType_MouseMove
          If down
            mx = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
            v = mx / width
            STK::SetGeneratorScalar(*wave, STK::#GENERATOR_FREQUENCY, v * 220 +60)
;             STK::SetArythmeticScalar(*final, v)
;             STK::SetEffectScalar(*rev, v, STK::#EFFECT_MIX)
            ;STK::SetArythmeticScalar(*adder1, v)
;             STK::SetArythmeticScalar(*adder1, v*4)
          EndIf
          
      EndSelect
    EndIf 
  Until event = #PB_Event_CloseWindow

  STK::GeneratorStreamClean(*stream)
Else
  MessageRequester("STK", "FAIL TO START GENERATOR STREAM")
EndIf


; 
; If *sine
;   Debug "START : "+Str(STK::SineStreamStart(*sine))
;   Define N = 0
;   While N < 1024000000
;     N + 1
;   Wend
;   
;   Debug "STOP : "+Str(STK::SineStreamStop(*sine))
;   Debug "CLEAN : "+Str(Stk::STKSineStreamClean(*sine))
; Else
;   Debug "FAIL TO START DAC"
; EndIf



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 325
; FirstLine = 276
; Folding = --
; EnableXP