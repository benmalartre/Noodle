XIncludeFile "TMTInclude.pbi"
XIncludeFile "TMTPlanet.pbi"

DeclareModule TMStars
  UseModule Math
  Structure TMStars_t
    *pgm.Program::Program_t
    *pivot.TMTPlanet::TMTPlanet_t
    *stars.PointCloud::PointCloud_t
  EndStructure
  
  Declare New(*pivot.TMTPlanet::TMTPlanet_t,min_radius.f,max_radius.f,*pgm.Program::Program_t)
  Declare Delete(*r.TMStars_t)
  Declare Setup(*r.TMStars_t,*pgm.Program::Program_t)
  Declare Update(*r.TMStars_t,time.f)
EndDeclareModule


Module TMStars
  Procedure New(*pivot.TMTPlanet::TMTPlanet_t,min_radius.f,max_radius.f,*pgm.Program::Program_t)
    Protected *s.TMStars_t  = AllocateMemory(SizeOf(TMStars_t))
    *s\pivot = *pivot
    *s\pgm = *pgm
    *s\stars = PointCloud::New("Stars",10000)
    ProcedureReturn *s
  EndProcedure
  
  Procedure Delete(*s.TMStars_t)

    FreeMemory(*s)
  EndProcedure
  
  Procedure Setup(*s.TMStars_t,*pgm.Program::Program_t)
    
    PointCloud::Setup(*s\stars,*pgm)
  EndProcedure
  
  Procedure Update(*s.TMStars_t,time.f)
    PointCloud::Draw(*s\stars)
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 23
; Folding = --
; EnableXP