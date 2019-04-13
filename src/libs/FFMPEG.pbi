; ===============================================================
;   FFMPEG
; ===============================================================

; ===============================================================
;   FFMPEG Module Declaration
; ===============================================================
DeclareModule FFMPEG
  Global FFMPEG.s = ""
  Global FFPROBE.s = ""
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux
      FFMPEG = "../../libs/x64/linux/ffmpeg" 
      FFPROBE = "../../libs/x64/linux/ffprobe" 
    CompilerCase #PB_OS_Windows
      FFMPEG = "../../libs/x64/windows/ffmpeg.exe" 
      FFPROBE = "../../libs/x64/windows/ffprobe.exe"
  CompilerEndSelect

  ; SLASH Macro for Building Path
  ;------------------------------
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Macro SLASH
        "\"
      EndMacro
    CompilerDefault
      Macro SLASH
        "/"
      EndMacro
  CompilerEndSelect
  
  Macro QUOTE
    Chr(34)
  EndMacro

  ;-----------------------------------
  ; FFMPEG_Data
  ;-----------------------------------
  Structure FFMPEG_Data
    input.s
    output.s
    cmd.s
  EndStructure
  
  ;-----------------------------------
  ; FFMPEG_Queue
  ;-----------------------------------
  Structure FFMPEG_Queue
    List *datas.FFMPEG_Data()
    semaphore.i
    mutex.i
  EndStructure
  
  ;-----------------------------------
  ; FFMPEG_Infos
  ;-----------------------------------
  Structure FFMPEG_Infos
    src.s
    resolution.s
    width.i
    height.i
    video_codec.s
    compression.s
    codec_audio.s
    duration.s
    bitrate.s
    audio_channels.s
    audio_sampling.s
    audio_frequency.s
    fps.i
    initialized.b
  EndStructure
  Declare newFFMPEGQueue()
  Declare.s Run(cmd.s)
  Declare.i Encode(*d.FFMPEG_Data)
  Declare.i EncodeMulti(*queue.FFMPEG_Queue)
  Declare.i GetImages(List images.i(),src.s,path.s)
  Declare.b GetInfos(*infos.FFMPEG_Infos)
EndDeclareModule
;}

; ===============================================================
;   FFMPEG MODULE IMPLEMENTATION
; ===============================================================
Module FFMPEG
  
  ; -------------------------------------------------------------
  ;   Run FFMPEG
  ; -------------------------------------------------------------
  Procedure newFFMPEGQueue()
    Protected *queue.FFMPEG_Queue = AllocateMemory(SizeOf(FFMPEG_Queue))
    InitializeStructure(*queue,FFMPEG_Queue)
    *queue\semaphore = CreateSemaphore()
    *queue\mutex = CreateMutex()
    ProcedureReturn *queue
  EndProcedure
  
  ; -------------------------------------------------------------
  ;   Run FFMPEG
  ; -------------------------------------------------------------
  Procedure.s Run(cmd.s)
    Protected prog = RunProgram(FFMPEG, cmd, "", #PB_Program_Open|#PB_Program_Read|#PB_Program_Error)
    Protected infos.s
    Protected errors.s
    Protected info.s
    Protected error.s
  
    If prog
      Protected stdoutcnt = 0
      Protected tmperr.s
      Protected *buffer
      While ProgramRunning(prog)
        stdoutcnt = AvailableProgramOutput(prog)
        
        If stdoutcnt
          *buffer = AllocateMemory(stdoutcnt)
          ReadProgramData(prog, *buffer, stdoutcnt)
          info = PeekS(*buffer, stdoutcnt, #PB_Ascii)
          infos = infos +Chr(10)+ info
          FreeMemory(*buffer)
        EndIf
        error = ReadProgramError(prog, #PB_Ascii)
        If Len(error)
          errors = errors +Chr(10)+ error
        EndIf
      Wend
      CloseProgram(prog)
    EndIf
    ProcedureReturn errors
  EndProcedure
  
  ; -------------------------------------------
  ;   Encode
  ; -------------------------------------------
  Procedure Encode(*d.FFMPEG_Data)
    Run(*d\cmd)
  EndProcedure
  
  ; -------------------------------------------
  ;   Encode_Multi
  ; -------------------------------------------
  Procedure EncodeMulti(*queue.FFMPEG_Queue)
    ForEach *queue\datas()
      Encode(*queue\datas())
      SignalSemaphore(*queue\semaphore)
    Next
  EndProcedure
  
  ; -------------------------------------------
  ;   Get Infos
  ; -------------------------------------------
  Procedure.b GetInfos(*infos.FFMPEG_Infos)
    Define d.FFMPEG_Data
    d\cmd.s = "-i "+QUOTE+*infos\src+QUOTE
    Define infos.s = Run(d\cmd)
    Debug infos
    If infos = "" Or FindString(infos,"Invalid data found when processing input")>0
      ProcedureReturn #False
    EndIf
    Define pos.i
    Define rpart.s
    
    ;   Duration
    ; ---------------------------------
    pos = FindString(infos,"Duration:")
    rpart = Mid(infos,pos+Len("Duration:"))
    *infos\duration = StringField(rpart,1,",")
    
    ;   Video 
    ; ---------------------------------
    pos = FindString(infos,"Video:")
    rpart = Mid(infos,pos+Len("Video:"))
    *infos\video_codec = StringField(rpart,1,",")
    *infos\compression = StringField(rpart,2,",")+","+StringField(rpart,3,",")
    *infos\resolution = StringField(rpart,4,",")
    *infos\bitrate = StringField(rpart,5,",")
    *infos\width = Val(StringField(*infos\resolution,1,"x"))
    *infos\height = Val(StringField(*infos\resolution,2,"x"))
    
    ;   Audio
    ; ---------------------------------
    pos = FindString(infos,"Audio:")
    rpart = Mid(infos,pos+Len("Audio:"))
    *infos\codec_audio = StringField(rpart,1,",")
    *infos\audio_frequency = StringField(rpart,2,",")
    *infos\audio_channels = StringField(rpart,3,",")
    *infos\audio_sampling = StringField(rpart,5,",")
    
    *infos\initialized = #True
    ProcedureReturn #True
  EndProcedure
  
  ; ------------------------------------------------------------
  ;   Get Images
  ; ------------------------------------------------------------
  Procedure GetImages(List images(),src.s,folder.s)
    
    Protected tmpfolder.s = folder+"tmp"
    Protected tmp = CreateDirectory(tmpfolder)
    
    ; Extract images from video
    Protected cmd.s = "-i "+QUOTE+src+QUOTE+" -quality best -vf fps=0.1 "+QUOTE+tmpfolder+SLASH+"image-%04d.bmp"+QUOTE
    
    Run(cmd);
    
    ;clear existing images
    If ListSize(images())>0
      ForEach images()
        If IsImage(images()):FreeImage(images()):EndIf
      Next
      ClearList(images())
    EndIf
    
    Protected NewList tmp.s()
    Protected dir = ExamineDirectory(#PB_Any,tmpfolder,"*")
    Protected file.s
    While NextDirectoryEntry(dir)
      file = DirectoryEntryName(dir);
      If file="." Or file=".." :  Continue : EndIf
      AddElement(tmp())
      tmp() = file
    Wend
    
    SortList(tmp(),#PB_Sort_Ascending)
    ForEach tmp()
      AddElement(images())
      images() = LoadImage(#PB_Any,tmpfolder+SLASH+tmp())
    Next
    FreeList(tmp())
    DeleteDirectory(tmpfolder,"*",#PB_FileSystem_Force|#PB_FileSystem_Recursive)
  EndProcedure
EndModule

; 
;   ;ffmpeg -i path/To/input.mov -vcodec videocodec -acodec audiocodec path/To/output.flv 1> block.txt 2>&1
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 11
; FirstLine = 9
; Folding = --
; EnableXP
; EnableUnicode