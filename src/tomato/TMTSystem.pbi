XIncludeFile "TMTInclude.pbi"
XIncludeFile "TMTPlanet.pbi"

DeclareModule TMTSystem
  Structure TMTSystem_t
    List *planets.TMTPlanet::TMTPlanet_t()
  EndStructure
  Declare New()
  Declare Delete(*s.TMTSystem_t)
  Declare Update(*s.TMTSystem_t,time.f)
EndDeclareModule

Module TMTSystem
  Procedure New()
    Protected *s.TMTSystem_t = AllocateMemory(SizeOf(TMTSystem_t))
    InitializeStructure(*s,TMTSystem_t)
    
    ProcedureReturn *s
  EndProcedure
  
  Procedure Delete(*s.TMTSystem_t)
    ClearStructure(*s,TMTSystem_t)
    FreeMemory(*s)
  EndProcedure
  
  Procedure Update(*s.TMTSystem_t,time.f)
  EndProcedure
  
  
EndModule


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 27
; Folding = -
; EnableXP