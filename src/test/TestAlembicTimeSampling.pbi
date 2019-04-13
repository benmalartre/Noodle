XIncludeFile "../libs/Booze.pbi"
XIncludeFile "../objects/Object3D.pbi"
EnableExplicit

Define ts.Alembic::ITimeSampling = Alembic::newTimeSampling()
Debug ts
Define numTs = ts\NumStoredTimes(), i
Define *Ts = ts\GetStoredTimes()
Debug "NUM STORED TIMES : "+Str(numTs)
For i=0 To numTs-1
  Debug " TIME : "+StrD(PeekD(*Ts+i*8))
Next

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; EnableXP