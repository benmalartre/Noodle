; ===================================================================================
;     Realtime audio i/o C++ classes.
; 
;     RtAudio provides a common API (Application Programming Interface)
;     For realtime audio input/output across Linux (native ALSA, Jack,
;     And OSS), Macintosh OS X (CoreAudio And Jack), And Windows
;     (DirectSound, ASIO And WASAPI) operating systems.
; 
;     RtAudio WWW site: http://www.music.mcgill.ca/~gary/rtaudio/
; 
;     RtAudio: realtime audio i/o C++ classes
;     Copyright (c) 2001-2014 Gary P. Scavone
; 
;     Permission is hereby granted, free of charge, To any person
;     obtaining a copy of this software And associated documentation files
;     (the "Software"), To deal in the Software without restriction,
;     including without limitation the rights To use, copy, modify, merge,
;     publish, distribute, sublicense, And/Or sell copies of the Software,
;     And To permit persons To whom the Software is furnished To do so,
;     subject To the following conditions:
; 
;     The above copyright notice And this permission notice shall be
;     included in all copies Or substantial portions of the Software.
; 
;     Any person wishing To distribute modifications To the Software is
;     asked To send the modifications To the original developer so that
;     they can be incorporated into the canonical version.  This is,
;     however, Not a binding provision of this license.
; 
;     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;     EXPRESS Or IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF
;     MERCHANTABILITY, FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT.
;     IN NO EVENT SHALL THE AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For
;     ANY CLAIM, DAMAGES Or OTHER LIABILITY, WHETHER IN AN ACTION OF
;     CONTRACT, TORT Or OTHERWISE, ARISING FROM, OUT OF Or IN CONNECTION
;     With THE SOFTWARE Or THE USE Or OTHER DEALINGS IN THE SOFTWARE.
; ===================================================================================
;     RTAUDIO MODULE DECLARATION
; ===================================================================================
DeclareModule RTAudio
  ;----------------------------------------------------------------------------------
  ; Constants
  ;----------------------------------------------------------------------------------
  Macro Format : l : EndMacro
  #SINT8    = 1               ; 8-bit signed integer.
  #SINT16   = 2               ; 16-bit signed integer.
  #SINT24   = 4               ; 24-bit signed integer.
  #SINT32   = 8               ; 32-bit signed integer.
  #FLOAT32  = 16              ; normalized between plus/minus 1.0.
  #FLOAT64  = 32              ; normalized between plus/minus 1.0.  
  
  Macro StreamFlags : i :EndMacro
  #NONINTERLEAVED     = 1     ; use non-interleaved buffers (Default = interleaved).
  #MINIMIZE_LATENCY   = 2     ; attempt To set stream parameters For lowest possible latency.
  #HOG_DEVICE         = 4     ; attempt grab device And prevent use by others.
  #SCHEDULE_REALTIME  = 8     ; try To Select realtime scheduling For callback thread.
  #ALSA_USE_DEFAULT   = 16    ; use the "default" PCM device (ALSA only).
  
  Macro StreamStatus : i :EndMacro
  #INPUT_OVERFLOW     = 1     ; input Data was discarded because of an overflow condition at the driver.
  #OUTPUT_UNDERFLOW   = 2     ; the output buffer ran low, likely causing a gap in the output sound.
  
  Enumeration
    #ERROR_WARNING            ; a non-critical error. 
    #ERROR_DEBUG_WARNING      ; a non-critical error which might be useful For debugging.
    #ERROR_UNSPECIFIED        ; the Default, unspecified error type.
    #ERROR_NO_DEVICES_FOUND   ; no devices found on system.
    #ERROR_INVALID_DEVICE     ; an invalid device ID was specified. 
    #ERROR_MEMORY_ERROR       ; an error occured during memory allocation. 
    #ERROR_INVALID_PARAM      ; an invalid parameter was specified To a function. 
    #ERROR_INVALID_USE        ; the function was called incorrectly. 
    #ERROR_DRIVER_ERROR       ; a system driver error occured. 
    #ERROR_SYSTEM_ERROR       ; a system error occured. 
    #ERROR_THREAD_ERROR       ; a thread error occured. 
  EndEnumeration
    
  Structure DeviceInfo
    probed.b                          ; true If the device capabilities were successfully probed
    name.s                            ; character string device identifier
    outputChannels.i                  ; maximum output channels supported by device
    inputChannels.i                   ; maximum input channels supported by device
    duplexChannels.i                  ; maximum simultaneous input/output channels supported by device
    isDefaultOutput.b                 ; true If this is the Default output device.
    isDefaultInput.b                  ; true If this is the Default input device.
    *sampleRates                      ; supported sample rates (queried from list of standard rates <std::vector>).
    nativeFormats.Format       ; bit mask of supported Data formats.
  EndStructure
  
  Enumeration 
    #DUPLEX
    #NOISE
    #SAW
    #BEAT
    #VOLUME
    #FILE
  EndEnumeration
  
  Structure Buffer
  EndStructure
  
  Macro Type
    f
  EndMacro
  #FORMAT = #FLOAT32
  
  ;----------------------------------------------------------------------------------
  ; Prototypes
  ;----------------------------------------------------------------------------------
  PrototypeC HELLO()
  PrototypeC INIT()
  PrototypeC GETDEVICES()
  PrototypeC INITBUFFER()
  PrototypeC GETBUFFER(*buffer,*mem)
  PrototypeC TERMBUFFER(*buffer)
  PrototypeC SETMODE(*buffer,mode.i,filename.p-utf8)
  PrototypeC SETFREQUENCY(*buffer,freq.f)
  PrototypeC.TYPE GETAVERAGE(*buffer)
  PrototypeC.TYPE SETFILE(*buffer,filename.p-utf8)
  PrototypeC.i RtAudioCallback( *outputBuffer, *inputBuffer,nFrames.i,streamTime.d,status.StreamStatus,*userData );
  
  ;----------------------------------------------------------------------------------
  ; Import Functions
  ;----------------------------------------------------------------------------------
  Global NOODLE_RTAUDIO_LIB = #Null
  ; Import C Library
  ;-------------------------------------------------------
  If FileSize("../../libs")=-2
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "../../libs/x64/windows/PbRtAudio.dll")
      CompilerCase #PB_OS_MacOS
;         ImportC "-lstdc++" : EndImport
;         ImportC "-lasound" : EndImport
;         ImportC "-lpthread" : EndImport
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "../../libs/x64/macosx/PbRtAudio.so")
      CompilerCase #PB_OS_Linux
        ImportC "-lstdc++" : EndImport
        ImportC "-lasound" : EndImport
        ImportC "-lpthread" : EndImport
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "../../libs/x64/linux/PbRtAudio.so")
    CompilerEndSelect
  Else
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "libs/x64/windows/PbRtAudio.dll")
      CompilerCase #PB_OS_MacOS
;         ImportC "-lstdc++" : EndImport
;         ImportC "-lasound" : EndImport
;         ImportC "-lpthread" : EndImport
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "libs/x64/macosx/PbRtAudio.so")
      CompilerCase #PB_OS_Linux
        ImportC "-lstdc++" : EndImport
        ImportC "-lasound" : EndImport
        ImportC "-lpthread" : EndImport
        NOODLE_RTAUDIO_LIB = OpenLibrary(#PB_Any, "libs/x64/linux/PbRtAudio.so")
    CompilerEndSelect
  EndIf
  
  If NOODLE_RTAUDIO_LIB
    Global Hello.HELLO = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_Hello")
    Global Init.INIT = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_Init")
    Global GetDevices.GETDEVICES = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_GetDevices")
    Global InitBuffer.INITBUFFER = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_InitBuffer")
    Global GetBuffer.GETBUFFER = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_GetBuffer")
    Global TermBuffer.TERMBUFFER = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_TermBuffer")
    Global SetMode.SETMODE = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_SetMode")
    Global SetFrequency.SETFREQUENCY = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_SetFrequency")
    Global GetAverage.GETAVERAGE = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_GetAverage")
    Global SetFile.SETFILE = GetFunction(NOODLE_RTAUDIO_LIB,"RTAudio_SetFile")  
  Else
    MessageRequester("Noodle RTAudio Error","Can't Find RTAudio Library!!")
  EndIf 
  
EndDeclareModule

; ===================================================================================
;  RTAUDIO MODULE IMPLEMENTATION
; ===================================================================================
Module RTAudio
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



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 160
; FirstLine = 156
; Folding = --
; EnableXP