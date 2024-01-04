XIncludeFile "Source.pbi"

;=========================================================================================
; CLIP MODULE DECLARATION
;=========================================================================================
DeclareModule Clip
  Enumeration 
    #TYPE_UNKNOWN
    #TYPE_ANIM
    #TYPE_IMAGE
    #TYPE_SOUND
    #TYPE_MOVIE
    #TYPE_SEQUENCE
  EndEnumeration
  
  Enumeration
    #LOOP_NONE
    #LOOP_REPEAT
    #LOOP_PINGPONG
  EndEnumeration
  
  Structure Clip_t
    name.s
    type.i
    startframe.i
    endframe.i
    speedratio.f
    loopmode.i
    *data.Source::Source_t
  EndStructure
  
  Declare New(name.s,*source.Source::Source_t)
  Declare Delete(*Me.Clip_t)
EndDeclareModule

;=========================================================================================
; TRACK MODULE DECLARATION
;=========================================================================================
DeclareModule Track
 Enumeration 
    #TYPE_UNKNOWN
    #TYPE_ANIM
    #TYPE_IMAGE
    #TYPE_SOUND
    #TYPE_MOVIE
    #TYPE_SEQUENCE
  EndEnumeration
  
  Structure Track_t
    type.i
    name.s
    List *clips.Clip::Clip_t()
  EndStructure
  
  Declare New(name.s,type.i)
  Declare Delete(*Me.Track_t)
EndDeclareModule


;=========================================================================================
; MIXER MODULE DECLARATION
;=========================================================================================
DeclareModule Mixer
 Enumeration 
    #TYPE_UNKNOWN
    #TYPE_ANIM
    #TYPE_IMAGE
    #TYPE_SOUND
    #TYPE_MOVIE
    #TYPE_SEQUENCE
  EndEnumeration
   
  Structure Mixer_t
    name.s
    List *tracks.Track::Track_t()
  EndStructure
  
  Declare New(name.s)
  Declare Delete(*Me.Mixer_t)
EndDeclareModule

;=========================================================================================
; CLIP MODULE IMPLEMENTATION
;=========================================================================================
Module Clip
  Procedure New(name.s,*source.Source::Source_t)
    Protected *Me.Clip_t = AllocateStructure(Clip_t)
    *Me\name = name
    *Me\data = *source
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Clip_t)
    FreeStructure(*Me)
  EndProcedure
  
EndModule

;=========================================================================================
; TRACK MODULE IMPLEMENTATION
;=========================================================================================
Module Track
  Procedure New(name.s,type.i)
    Protected *Me.Track_t = AllocateStructure(Track_t)
    *Me\name = name
    *Me\type = type
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Track_t)
    ForEach *Me\clips()
      Clip::Delete(*Me\clips())
    Next
    
    FreeStructure(*Me)
  EndProcedure
  
EndModule

;=========================================================================================
; MIXER MODULE IMPLEMENTATION
;=========================================================================================
Module Mixer
  Procedure New(name.s)
    Protected *Me.Mixer_t = AllocateStructure(Mixer_t)
    AddElement(*Me\tracks())
    *Me\tracks() = Track::New("Video 1",#TYPE_MOVIE)
    *Me\tracks() = Track::New("Video 2",#TYPE_MOVIE)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Mixer_t)
    ForEach *Me\tracks()
      Track::Delete(*Me\tracks())
    Next
    
    FreeStructure(*Me)
  EndProcedure
  
EndModule



*src1.Source::Source_t = Movie::New("D:\Projects\Softimage\Spontex\Pictures\SPX_0020_ANIM_MUSCLE.avi")
*src2.Source::Source_t = Movie::New("D:\Projects\Softimage\Spontex\Pictures\SPX_0020_ANIM_SKELETON.avi")
*src3.Source::Source_t = Movie::New("D:\Projects\Softimage\Spontex\Pictures\SPX_0020_ANIM_FUR.avi")



  window = OpenWindow(#PB_Any,0,0,800,600,"Video")
  If Source::#TYPE_MOVIE = *src1\type
    Define *movie.Movie::Movie_t = *src1
    PlayMovie(*movie\movie,WindowID(window))
  Else
    MessageRequester("MOIXER","NOT A VIDEO")
  EndIf
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
  
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 137
; FirstLine = 115
; Folding = ---
; EnableXP
; EnableUnicode