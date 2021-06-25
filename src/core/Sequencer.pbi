XIncludeFile "Time.pbi"

;========================================================================================
; Sequencer Module Declaration
;========================================================================================
DeclareModule Sequencer
  #NUM_TIMES_PER_BLOCK = 3
  
  Structure Note_t
    time.i
    duration.i
    frequency.f
    intensity.f
  EndStructure
  
  Structure Cell_t
    *note.Note_t
  EndStructure
  
  Structure Block_t
    Array *cells.Cell_t()
  EndStructure
  
  Structure Track_t
    Array *blocks.Block_t()
  EndStructure
  
  Structure Sequencer_t
    Time::Timeable_t timer
    tempo.i
    rythm.i
    blocks.i
    List *tracks.Track_t()
  EndStructure
  
  Declare New(tempo.i, rythm.i)
  Declare Delete(*sequencer.Sequencer_t)
  Declare AddTrack(*sequencer.Sequencer_t)
  Declare DeleteTrack(*sequencer.Sequencer_t, index.i)
  Declare SetupTrack(*track.Track_t, blocks.i, rythm.i)
  Declare CleanTrack(*track.Track_t)
  
  Declare NewNote(time.i, duration.i, frequency.f, intensity.f)
  Declare DeleteNote(*note)
  Declare AddNote(*block.Block_t, index.i, *note.Note_t)
  
  Declare Start(*sequencer.Sequencer_t)
  Declare Stop(*sequencer.Sequencer_t)
  
EndDeclareModule

;========================================================================================
; Sequencer Module Implementation
;========================================================================================
Module Sequencer
  ;--------------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ;--------------------------------------------------------------------------------------
  Procedure New(tempo.i, rythm.i, blocks.i)
    Define *sequencer.Sequencer_t = AllocateMemory(SizeOf(Sequencer_t))
    InitializeStructure(*sequencer, Sequencer_t)
    
    *sequencer\tempo = tempo
    *sequencer\rythm = rythm
    *sequencer\blocks = blocks
    ProcedureReturn *sequencer
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DESTRUCTOR
  ;--------------------------------------------------------------------------------------
  Procedure Delete(*sequencer.Sequencer_t)
    Define i
    Define numTracks = ListSize(*sequencer\tracks())
    For i = numTracks-1 To 0
      DeleteTrack(*sequencer, i)
    Next
    
    ClearStructure(*sequencer, Sequencer_t)
    FreeMemory(*sequencer)
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; START
  ;--------------------------------------------------------------------------------------
  Procedure Start(*sequencer.Sequencer_t)
    Debug "START SEQUENCER !"
    Time::StartTimer(*sequencer\timer, *sequencer\callback, 33)
    
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; STOP
  ;--------------------------------------------------------------------------------------
  Procedure Stop(*sequencer.Sequencer_t)
     Debug "STOP SEQUENCER !"
    Time::StopTimer(*sequencer\timer)
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; ADD TRACK
  ;--------------------------------------------------------------------------------------
  Procedure AddTrack(*sequencer.Sequencer_t)
    Define *track.Track_t = AllocateMemory(SizeOf(Track_t))
    InitializeStructure(*track, Track_t)
    SetupTrack(*track, *sequencer\blocks, *sequencer\rythm)
    AddElement(*sequencer\tracks())
    *sequencer\tracks() = *track
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; DELETE TRACK
  ;--------------------------------------------------------------------------------------
  Procedure DeleteTrack(*sequencer.Sequencer_t, index.i)
    If index >=0 And index < ListSize(*sequencer\tracks())
      SelectElement(*sequencer\tracks(), index)
      Define *track.Track_t = *sequencer\tracks()
      CleanTrack(*track)
      DeleteElement(*sequencer\tracks())
    EndIf
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; SETUP TRACK
  ;--------------------------------------------------------------------------------------
  Procedure SetupTrack(*track.Track_t, blocks.i, rythm.i)
    ReDim *track\blocks(blocks)
    Define i, j
    
    For i=0 To blocks-1
      Define *block.Block_t = AllocateMemory(SizeOf(Block_t))
      InitializeStructure(*block, Block_t)
      ReDim *block\cells(#NUM_TIMES_PER_BLOCK * rythm)
    Next
    
  EndProcedure
  
  ;--------------------------------------------------------------------------------------
  ; CLEAN TRACK
  ;--------------------------------------------------------------------------------------
  Procedure CleanTrack(*track.Track_t)
    Define numBlocks = ArraySize(*track\blocks())
    Define i, j
    For i=numBlocks-1 To 0
      Define *block.Block_t = *track\blocks(i)
      Define numCells = ArraySize(*block\cells())
      For j=numCells-1 To 0
        If *block\cells(j)
          Define *note = RemoveNote(*block, j)
          If *note : DeleteNote(*note, j)
        EndIf
      Next
    Next
    
  EndProcedure
  
  Procedure NewNote(time.i, duration.i, frequency.f, intensity.f)
    Define *note.Note_t = AllocateMemory(SizeOf(Note_t))
    *note\time = time
    *note\duration = duration
    *note\frequency = frequency
    *note\intensity = intensity
    ProcedureReturn *note
  EndProcedure
  
  Procedure DeleteNote(*note)
    FreeMemory(*note)
  EndProcedure
  
  Procedure AddNote(*block.Block_t, index.i, *note.Note_t)
    *block\cells(index) = *note
  EndProcedure
  
  Procedure RemoveNote(*block.Block_t, index.i)
    Define *note.Note_t = *block\cells(index)\note
    If *note 
      *block\cells(index)\note = #Null
      ProcedureReturn *note
    Else
      ProcedureReturn *note
    EndIf
  EndProcedure
  
  
  
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 98
; FirstLine = 81
; Folding = ---
; EnableXP