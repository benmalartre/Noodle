DeclareModule Notes
  #C0	  = 16.35   ; DO
  #Db0  = 17.32   ; DO#
  #D0	  = 18.35   ; RE
  #Eb0  = 19.45   ; MIb
  #E0	  = 20.60   ; MI
  #F0	  = 21.83   ; FA
  #Gb0  = 23.12   ; FA#
  #G0	  = 24.50   ; SOL
  #Ab0  = 25.96   ; SOL#
  #A0	  = 27.50   ; LA
  #Bb0  = 29.14   ; SIb
  #B0	  = 30.87   ; SI

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
  
  ; English Notes
  Enumeration
    #NOTE_C
    #NOTE_Db
    #NOTE_D
    #NOTE_Eb
    #NOTE_E
    #NOTE_F
    #NOTE_Gb
    #NOTE_G
    #NOTE_Ab
    #NOTE_A
    #NOTE_Bb
    #NOTE_B
  EndEnumeration
  
  ; French Notes
  Enumeration
    #NOTE_DO
    #NOTE_DOd
    #NOTE_RE
    #NOTE_MIb
    #NOTE_MI
    #NOTE_FA
    #NOTE_FAd
    #NOTE_SOL
    #NOTE_SOLd
    #NOTE_LA
    #NOTE_SIb
    #NOTE_SI
  EndEnumeration
  
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
    PeekF(Notes::?NOTES + (_octave % Notes::#NUM_OCTAVES * Notes::#NUM_NOTES + _note) * 4)
  EndMacro
  
  Declare.f Closest(frequency.f)
  
  
EndDeclareModule

Module Notes
  Procedure.f Closest(frequency.f)
    If frequency < Notes::NoteAt(0, 0)
      ProcedureReturn Notes::NoteAt(0, 0)
    ElseIf frequency > Notes::NoteAt(#NUM_OCTAVES-1, #NUM_NOTES-1)
      ProcedureReturn Notes::NoteAt(#NUM_OCTAVES-1, #NUM_NOTES-1)
    Else
      Define delta.f
      Define minDelta.f = Math::#F32_MAX
      Define i, j
      Define result
      For i=0 To Notes::#NUM_OCTAVES -1
        If frequency >= Notes::NoteAt(i, 0) And frequency < Notes::NoteAt(i, #NUM_NOTES-1):
          For j=0 To Notes::#NUM_NOTES - 1
            delta = Abs(frequency - Notes::NoteAt(i, j))
            If delta <= minDelta
              minDelta = delta
              result = Notes::NoteAt(i, j)
            EndIf
          Next
          Break
        EndIf
      Next
      ProcedureReturn result
    EndIf
    
  EndProcedure
EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 191
; FirstLine = 171
; Folding = -
; EnableXP