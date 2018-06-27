InitMovie()
InitSound()
UseFLACSoundDecoder() 
UseOGGSoundDecoder() 

;=========================================================================================
; SOURCE MODULE DECLARTION
;=========================================================================================
DeclareModule Source
  Enumeration 
    #TYPE_UNKNOWN
    #TYPE_ANIM
    #TYPE_IMAGE
    #TYPE_SOUND
    #TYPE_MOVIE
    #TYPE_SEQUENCE
  EndEnumeration
  
  Structure Source_t
    path.s
    type.i
    startframe.f
    endframe.f
  EndStructure
 
EndDeclareModule

Module Source
EndModule



;=========================================================================================
; MOVIE MODULE DECLARATION
;=========================================================================================
DeclareModule Movie
  Structure Movie_t Extends Source::Source_t
    movie.i
    length.i
    height.i
    width.i
  EndStructure
  
  Declare New(path.s)
EndDeclareModule
;=========================================================================================
; MOVIE MODULE IMPLEMENTATION
;=========================================================================================
Module Movie
  Procedure New(path.s)
    Protected *movie.Movie_t = AllocateMemory(SizeOf(Movie_t))
    *movie\movie = LoadMovie(#PB_Any,path)
    *movie\path = path
    *movie\type = Source::#TYPE_MOVIE
    If *movie\movie
      *movie\width = MovieWidth(*movie\movie)
      *movie\height = MovieHeight(*movie\movie)
      *movie\length = MovieLength(*movie\movie)
      ProcedureReturn *movie
    Else
      FreeMemory(*movie)
    EndIf
  EndProcedure
EndModule

;=========================================================================================
; SOUND MODULE DECLARATION
;=========================================================================================
DeclareModule Sound
  Structure Sound_t Extends Source::Source_t
    sound.i
    length.i
    basefrequency.i
    currentfrequency.i
  EndStructure
  
  Declare New(path.s)
  Declare Delete(*sound.Sound_t)
EndDeclareModule

;=========================================================================================
; SOUND MODULE IMPLEMENTATION
;=========================================================================================
Module Sound
  Procedure New(path.s)
    Protected *sound.Sound_t = AllocateMemory(SizeOf(Sound_t))
    *sound\sound = LoadSound(#PB_Any,path)
    *sound\path = path
    *sound\type = Source::#TYPE_SOUND
    If *sound\sound
      *sound\length = SoundLength(*sound\sound,#PB_Sound_Millisecond)
      *sound\basefrequency = GetSoundFrequency(*sound\sound)
      ProcedureReturn *sound
    Else
      FreeMemory(*sound)
    EndIf
  EndProcedure
  
  Procedure Delete(*Me.Sound_t)
    If IsSound(*Me\sound) : FreeSound(*Me\sound) : EndIf
    FreeMemory(*Me)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 22
; FirstLine = 5
; Folding = --
; EnableXP
; EnableUnicode