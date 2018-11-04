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
  
  Macro STKGeneratorStreamType : l : EndMacro
  Enumeration
    #ENVELOPE_GENERATOR 
	  #ADSR_GENERATOR
	  #ASYMP_GENERATOR 
	  #NOISE_GENERATOR
	  #SUBNOISE_GENERATOR 
	  #MODULATE_GENERATOR 
	  #SINGWAVE_GENERATOR 
	  #SINEWAVE_GENERATOR 
	  #BLIT_GENERATOR
	  #BLITSAW_GENERATOR  
	  #BLITSQUARE_GENERATOR
	  #GRANULATE_GENERATOR
	EndEnumeration
  
  Structure RtAudio                   ; opaque cpp structure
  EndStructure
  
  Structure STKBufferStream
  EndStructure
  
  Structure STKGeneratorStream
  EndStructure
  
  Structure STKVoicerStream
  EndStructure
  
  
  ;----------------------------------------------------------------------------------
  ; Prototypes
  ;----------------------------------------------------------------------------------
  PrototypeC STKINIT()
  PrototypeC STKGETDEVICES()
    
  PrototypeC STKGENERATORSTREAMSETUP(*DAC.RtAudio, type.i, frequency.f)
  PrototypeC STKGENERATORSTREAMCLEAN(*generator.STKGeneratorStream)
  PrototypeC STKGENERATORSTREAMSTART(*generator.STKGeneratorStream)
  PrototypeC STKGENERATORSTREAMSTOP(*generator.STKGeneratorStream)
  PrototypeC STKGENERATORSTREAMSETFREQUENCY(*generator.STKGeneratorStream, frequency.f)
  
  PrototypeC STKVOICERSTREAMSETUP(*DAC.RtAudio, nbInstruments.i)
  PrototypeC STKVOICERSTREAMCLEAN(*voicer.STKVoicerStream)
  PrototypeC STKVOICERSTREAMSTART(*voicer.STKVoicerStream)
  PrototypeC STKVOICERSTREAMSTOP(*voicer.STKVoicerStream)
  
  PrototypeC STKBUFFERSTREAMINIT(*DAC.RtAudio, *stream.STKBufferStream)
  PrototypeC STKBUFFERSTREAMGET(*stream.STKBufferStream)
  PrototypeC STKBUFFERSTREAMTERM(*stream.STKBufferStream)
  PrototypeC STKBUFFERSTREAMSETFILE(*stream.STKBufferStream, filename.s)
  
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
    Global STKInit.STKINIT = GetFunction(STK_LIB, "STKInit")
    Global STKGetDevices.STKGETDEVICES = GetFunction(STK_LIB, "STKGetDevices")

    Global STKGeneratorStreamSetup.STKGENERATORSTREAMSETUP = GetFunction(STK_LIB, "STKGeneratorStreamSetup")
    Global STKGeneratorStreamClean.STKGENERATORSTREAMCLEAN      = GetFunction(STK_LIB, "STKGeneratorStreamClean")
    Global STKGeneratorStreamStart.STKGENERATORSTREAMSTART  = GetFunction(STK_LIB, "STKGeneratorStreamStart")
    Global STKGeneratorStreamStop.STKGENERATORSTREAMSTOP  = GetFunction(STK_LIB, "STKGeneratorStreamStop")
    Global STKGeneratorStreamSetFrequency.STKGENERATORSTREAMSETFREQUENCY  = GetFunction(STK_LIB, "STKGeneratorStreamSetFrequency")
    
    Global STKVoicerStreamSetup.STKVOICERSTREAMSETUP = GetFunction(STK_LIB, "STKVoicerStreamSetup")
    Global STKVoicerStreamClean.STKVOICERSTREAMCLEAN = GetFunction(STK_LIB, "STKVoicerStreamClean")
    Global STKVoicerStreamStart.STKVOICERSTREAMSTART = GetFunction(STK_LIB, "STKVoicerStreamStart")
    Global STKVoicerStreamStop.STKVOICERSTREAMSTOP = GetFunction(STK_LIB, "STKVoicerStreamStop")
    
    Global STKBufferStreamInit.STKBUFFERSTREAMINIT = GetFunction(STK_LIB, "STKBufferStreamInit")
    Global STKBufferStreamGet.STKBUFFERSTREAMGET = GetFunction(STK_LIB, "STKBufferStreamGet")
    Global STKBufferStreamTerm.STKBUFFERSTREAMTERM = GetFunction(STK_LIB, "STKBufferStreamTerm")
    Global STKBufferStreamSetFile.STKBUFFERSTREAMSETFILE = GetFunction(STK_LIB,"STKBufferStreamSetFile") 
        
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

Dim generator_names.s(12)
generator_names(0)  = "ENVELOPE_GENERATOR"
generator_names(1)  = "ADSR_GENERATOR"
generator_names(2)  = "ASYMP_GENERATOR" 
generator_names(3)  = "NOISE_GENERATOR"
generator_names(4)  = "SUBNOISE_GENERATOR" 
generator_names(5)  = "MODULATE_GENERATOR"
generator_names(6)  = "SINGWAVE_GENERATOR" 
generator_names(7)  = "SINEWAVE_GENERATOR"
generator_names(8)  = "BLIT_GENERATOR"
generator_names(9)  = "BLITSAW_GENERATOR"  
generator_names(10) = "BLITSQUARE_GENERATOR"
generator_names(11) = "GRANULATE_GENERATOR"

Global WIDTH = 800
Global HEIGHT = 600

Global *DAC.STK::RtAudio = STK::STKInit()

; Global *adsr.STK::STKGeneratorStream = STK::STKGeneratorStreamSetup(*DAC, STK::#ADSR_GENERATOR, 180)
; Global *blit.STK::STKGeneratorStream = STK::STKGeneratorStreamSetup(*DAC, STK::#BLIT_GENERATOR, 180)
Global *generator.STK::STKGeneratorStream = STK::STKGeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 60)
; Global *generator.STK::STKGeneratorStream = STK::STKGeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 120)
; Global *generator.STK::STKGeneratorStream = STK::STKGeneratorStreamSetup(*DAC, STK::#BLITSAW_GENERATOR, 320)


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

If *generator
  Repeat
    event = WaitWindowEvent()
    If event = #PB_Event_Gadget And EventGadget() = canvas
      Select EventType()
        Case #PB_EventType_KeyDown
          key = GetGadgetAttribute(canvas, #PB_Canvas_Key)
          If key = #PB_Shortcut_Space
            If running
              Debug STK::STKGeneratorStreamStop(*generator)
              running = #False  
              DrawCanvas()
            Else
              Debug STK::STKGeneratorStreamStart(*generator)
              running = #True
              DrawCanvas()
            EndIf
          EndIf
      EndSelect
    EndIf 
  Until event = #PB_Event_CloseWindow

  STK::STKGeneratorStreamClean(*generator)
Else
  MessageRequester("STK", "FAIL TO START GENERATOR")
EndIf


; 
; If *sine
;   Debug "START : "+Str(STK::STKSineStreamStart(*sine))
;   Define N = 0
;   While N < 1024000000
;     N + 1
;   Wend
;   
;   Debug "STOP : "+Str(STK::STKSineStreamStop(*sine))
;   Debug "CLEAN : "+Str(Stk::STKSineStreamClean(*sine))
; Else
;   Debug "FAIL TO START DAC"
; EndIf



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 248
; FirstLine = 244
; Folding = --
; EnableXP