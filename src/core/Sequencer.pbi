XIncludeFile "Time.pbi"

;========================================================================================
; Sequencer Module Declaration
;========================================================================================
DeclareModule Sequencer
  #NUM_SAMPLES_PER_BEAT = 512
  
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
    offset.f
    volume.f
    mutex.i
  EndStructure
  
  Structure Sequencer_t
    *timer.Time::Timeable_t
    tempo.i
    rythm.i
    blocks.i
    tick.i
    block.i
    sample.i
    Array *tracks.Track_t(0)
  EndStructure
  
  Declare New(tempo.i, rythm.i, blocks.i=4)
  Declare Delete(*sequencer.Sequencer_t)
  Declare AddTrack(*sequencer.Sequencer_t)
  Declare DeleteTrack(*sequencer.Sequencer_t, index.i)
  Declare SetupTrack(*track.Track_t, blocks.i, tempo.i, rythm.i)
  Declare CleanTrack(*track.Track_t)
  Declare.f GetFrequency(*track.Track_t)
  Declare.f GetAmplitude(*track.Track_t)
  
  Declare UpdateTrack(*sequencer.Sequencer_t, *track.Track_t, block.i, sample.i)
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
  Procedure New(tempo.i, rythm.i, blocks.i=4)
    Define *Me.Sequencer_t = AllocateStructure(Sequencer_t)
    Define rate.i =  1000 / #NUM_SAMPLES_PER_BEAT
    *Me\timer = Time::CreateTimer(*Me, @OnTimer(), rate)
    *Me\tempo = tempo
    *Me\rythm = rythm
    *Me\blocks = blocks
    ProcedureReturn *Me
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------------------
  Procedure Delete(*Me.Sequencer_t)
    Define i
    Define numTracks = ArraySize(*Me\tracks())
    For i = numTracks - 1 To 0
      DeleteTrack(*Me, i)
    Next
    
    FreeStructure(*Me)
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; START
  ;--------------------------------------------------------------------------------------
  Procedure Start(*Me.Sequencer_t)
    Time::StartTimer(*Me\timer)
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; STOP
  ;--------------------------------------------------------------------------------------
  Procedure Stop(*Me.Sequencer_t)
    Time::StopTimer(*Me\timer)
  EndProcedure
  
  ; ON TIMER
  ;--------------------------------------------------------------------------------------
  Procedure OnTimer(*Me.Sequencer_t)
    *Me\tick + 1
    
    If *Me\tick % #NUM_SAMPLES_PER_BEAT = 0
      *Me\block = *Me\block + 1
    EndIf
    *Me\sample = *Me\tick % #NUM_SAMPLES_PER_BEAT
    
    For i=0 To ArraySize(*Me\tracks()) - 1
      UpdateTrack(*Me, *Me\tracks(i), *Me\block, *Me\sample)
    Next
    Delay(*Me\timer\delay)
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; GET FREQUENCY
  ;--------------------------------------------------------------------------------------
  Procedure.f GetFrequency(*track.Track_t)
    ProcedureReturn *track\frequency + *track\offset
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; GET AMPLITUDE
  ;--------------------------------------------------------------------------------------
  Procedure.f GetAmplitude(*track.Track_t)
    ProcedureReturn *track\amplitude * *track\volume
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; ADD TRACK
  ;--------------------------------------------------------------------------------------
  Procedure AddTrack(*Me.Sequencer_t)
    Define size = ArraySize(*Me\tracks())
    Define *track.Track_t = AllocateStructure(Track_t)
    SetupTrack(*track, *Me\blocks, *Me\tempo, *Me\rythm)
    *track\mutex = CreateMutex()
    *track\volume = 1.0
    *track\offset = 0.0
    ReDim *Me\tracks(size + 1)
    *Me\tracks(size) = *track
    ProcedureReturn *track
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DELETE TRACK
  ;--------------------------------------------------------------------------------------
  Procedure DeleteTrack(*Me.Sequencer_t, index.i)
    Define size = ArraySize(*Me\tracks())
    If index >=0 And index < size
      Define *track.Track_t = *Me\tracks(index)
      FreeMutex(*track\mutex)
      CleanTrack(*track)
      For i = index + 1 To size - 1
        Swap *Me\tracks(i-1), *Me\tracks(i)
      Next
      ReDim *Me\tracks(size - 1)
      FreeStructure(*track)
    EndIf 
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; SETUP TRACK
  ;--------------------------------------------------------------------------------------
  Procedure SetupTrack(*track.Track_t, blocks.i, tempo.i, rythm.i)    
    ReDim *track\blocks(blocks)
    Define *sample.Sample_t
    Define i, j, t = 0
    Define rate.i =  #NUM_SAMPLES_PER_BEAT
    For i=0 To blocks-1
      Define *block.Block_t = *track\blocks(i)
      InitializeStructure(*block, Block_t)
      For j=0 To #NUM_SAMPLES_PER_BEAT -1
        *sample = *block\samples(j)
        *sample\frequency = 0.0
        *sample\amplitude = 0.0
      Next
      
      *block\time = t
      t + rate
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
  Procedure SampleTrack(*Me.Sequencer_t, *track.Track_t)
    Define numBlocks = ArraySize(*track\blocks())
    Define i, j, t, st, et
    Define *block.Block_t
    Define *note.Note_t
     
    For i=0 To numBlocks - 1
      *block = *track\blocks(i)
      For j=0 To #NUM_SAMPLES_PER_BEAT-1
        t = *block\time + j
        ForEach *track\notes()
          *note = *track\notes()
          st = *note\time
          et = st + *note\duration
          If t >= st And t < et
            *block\samples(j)\frequency = *note\frequency
            *block\samples(j)\amplitude = *note\amplitude
            Continue
          EndIf
        Next
      Next
    Next
    Delay(2000)
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; UPDATE TRACK
  ;--------------------------------------------------------------------------------------
  Procedure UpdateTrack(*sequencer.Sequencer_t, *track.Track_t, block.i, sample.i)
    
    LockMutex(*track\mutex)
    Define numBlocks = ArraySize(*track\blocks())
    Define *block.Block_t = *track\blocks(block % numBlocks)
    Define *sample.Sample_t = *block\samples(sample % #NUM_SAMPLES_PER_BEAT)
    *track\frequency = *sample\frequency
    *track\amplitude = *sample\amplitude
    UnlockMutex(*track\mutex)
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
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 169
; FirstLine = 143
; Folding = ---
; EnableXP