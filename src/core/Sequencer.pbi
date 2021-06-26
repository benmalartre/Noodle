XIncludeFile "Time.pbi"

;========================================================================================
; Sequencer Module Declaration
;========================================================================================
DeclareModule Sequencer
  #NUM_SAMPLES_PER_BEAT = 64
  
  Structure Sample_t
    frequency.f
    amplitude.f
  EndStructure
  
  Structure Note_t
    time.i
    duration.i
    frequency.f
    amplitude.f
  EndStructure
  
  Structure Block_t
    time.i
    Array samples.Sample_t(#NUM_SAMPLES_PER_BEAT)
  EndStructure
  
  Structure Track_t
    Array blocks.Block_t(0)
    List notes.Note_t()
    frequency.f
    amplitude.f
  EndStructure
  
  Structure Sequencer_t
    *timer.Time::Timeable_t
    tempo.i
    rythm.i
    blocks.i
    tick.i
    List *tracks.Track_t()
  EndStructure
  
  Declare New(tempo.i, rythm.i)
  Declare Delete(*sequencer.Sequencer_t)
  Declare AddTrack(*sequencer.Sequencer_t)
  Declare DeleteTrack(*sequencer.Sequencer_t, index.i)
  Declare SetupTrack(*track.Track_t, blocks.i, tempo.i, rythm.i)
  Declare CleanTrack(*track.Track_t)
  
  Declare SampleTrack(*sequencer.Sequencer_t, *track.Track_t)
  Declare AddNote(*track.Track_t, time.i, duration.i, frequency.f, amplitude.f)
  Declare RemoveNote(*track.Block_t, index.i)
  
  Declare Start(*sequencer.Sequencer_t)
  Declare Stop(*sequencer.Sequencer_t)
  Declare OnTimer(*sequencer.Sequencer_t)
  
EndDeclareModule

;========================================================================================
; Sequencer Module Implementation
;========================================================================================
Module Sequencer
  ;--------------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ;--------------------------------------------------------------------------------------
  Procedure New(tempo.i, rythm.i)
    Define *Me.Sequencer_t = AllocateMemory(SizeOf(Sequencer_t))
    Define rate.i = 1000 / (tempo * #NUM_SAMPLES_PER_BEAT)
    InitializeStructure(*Me, Sequencer_t)
    *Me\timer = Time::CreateTimer(*Me, @OnTimer(), rate)
    *Me\tempo = tempo
    *Me\rythm = rythm
    *Me\blocks = *Me\tempo * *Me\rythm
    ProcedureReturn *Me
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------------------
  Procedure Delete(*Me.Sequencer_t)
    Define i
    Define numTracks = ListSize(*Me\tracks())
    For i = numTracks-1 To 0
      DeleteTrack(*Me, i)
    Next
    
    ClearStructure(*Me, Sequencer_t)
    FreeMemory(*Me)
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; START
  ;--------------------------------------------------------------------------------------
  Procedure Start(*Me.Sequencer_t)
    Debug "START SEQUENCER !"
    Time::StartTimer(*Me\timer)
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; STOP
  ;--------------------------------------------------------------------------------------
  Procedure Stop(*Me.Sequencer_t)
     Debug "STOP SEQUENCER !"
    Time::StopTimer(*Me\timer)
  EndProcedure
  
  ; ON TIMER
  ;--------------------------------------------------------------------------------------
  Procedure OnTimer(*Me.Sequencer_t)
    Define *sample.Sample_t
    Define *block.Block_t
    Define block.i = *Me\tick / (*Me\rythm * #NUM_SAMPLES_PER_BEAT)
    Define sample.i = *Me\tick % (*Me\rythm * #NUM_SAMPLES_PER_BEAT)
    Define numBlocks
    Debug "SAMPLE INDEX : " +Str(sample)
    ForEach *Me\tracks()
      numBlocks = ArraySize(*Me\tracks()\blocks())
      *block = *Me\tracks()\blocks(block % numBlocks)
      *sample = *block\samples(sample % #NUM_SAMPLES_PER_BEAT)
      *Me\tracks()\frequency = *sample\frequency
      *Me\tracks()\amplitude = *sample\amplitude
    Next
    *Me\tick + 1
    If *Me\tick >= *Me\tempo * *Me\rythm * #NUM_SAMPLES_PER_BEAT
      *Me\tick = 0
    EndIf
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; ADD TRACK
  ;--------------------------------------------------------------------------------------
  Procedure AddTrack(*Me.Sequencer_t)
    Define *track.Track_t = AllocateMemory(SizeOf(Track_t))
    InitializeStructure(*track, Track_t)
    SetupTrack(*track, *Me\blocks, *Me\tempo, *Me\rythm)
    AddElement(*Me\tracks())
    *Me\tracks() = *track
    ProcedureReturn *track
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DELETE TRACK
  ;--------------------------------------------------------------------------------------
  Procedure DeleteTrack(*Me.Sequencer_t, index.i)
    If index >=0 And index < ListSize(*Me\tracks())
      SelectElement(*Me\tracks(), index)
      Define *track.Track_t = *Me\tracks()
      CleanTrack(*track)
      DeleteElement(*Me\tracks())
    EndIf
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; SETUP TRACK
  ;--------------------------------------------------------------------------------------
  Procedure SetupTrack(*track.Track_t, blocks.i, tempo.i, rythm.i)
    ReDim *track\blocks(blocks)
    Define i, j
    Define rate.i = 1000 / (tempo * rythm)
    Debug "SAMPLING RATE : "
    For i=0 To blocks-1
      Define *block.Block_t = AllocateMemory(SizeOf(Block_t))
      InitializeStructure(*block, Block_t)
    Next
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; CLEAN TRACK
  ;--------------------------------------------------------------------------------------
  Procedure CleanTrack(*track.Track_t)
    Define numBlocks = ArraySize(*track\blocks())
    Define i, j
    ClearList(*track\notes())
    
    For i=numBlocks-1 To 0
      Define *block.Block_t = *track\blocks(i)
      For j=#NUM_SAMPLES_PER_BEAT-1 To 0
        *block\samples(j)\frequency = 0.0
        *block\samples(j)\amplitude = 0.0
      Next
    Next
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; SAMPLE TRACK
  ;--------------------------------------------------------------------------------------
  Procedure SampleTrack(*sequencer.Sequencer_t, *track.Track_t)
    Define numBlocks = ArraySize(*track\blocks())
    Define i, j, t, st, et
    Define *block.Block_t
    Define *note.Note_t
    For i=0 To numBlocks - 1
      *block = *track\blocks(i)
      For j=0 To #NUM_SAMPLES_PER_BEAT-1
        ForEach *track\notes()
          *note = *track\notes()
          t = *block\time + j
          st = *note\time
          et = st + *note\duration
          If t >= nt And t < et
            *block\samples(j)\frequency = *note\frequency
            *block\samples(j)\amplitude = *note\amplitude
          EndIf
        Next
      Next
    Next
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; ADD NOTE
  ;--------------------------------------------------------------------------------------
  Procedure AddNote(*track.Track_t, time.i, duration.i, frequency.f, amplitude.f)
    AddElement(*track\notes())
    *track\notes()\time = time
    *track\notes()\duration = duration
    *track\notes()\frequency = frequency
    *track\notes()\amplitude = amplitude
    ProcedureReturn *track\notes()
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; REMOVE NOTE
  ;--------------------------------------------------------------------------------------
  Procedure RemoveNote(*track.Track_t, index.i)
    If index < 0 Or ListSize(*track\notes()) >= index
      ProcedureReturn
    EndIf
    SelectElement(*track\notes(), index)
    DeleteElement(*track\notes())
  EndProcedure
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 119
; FirstLine = 109
; Folding = ---
; EnableXP