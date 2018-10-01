Global xx.l, yy.f, zz.f 



yy.f = 1.0000001
zz1.f = 1

Delay(10)

SetPriorityClass_(GetCurrentProcess_(), #REALTIME_PRIORITY_CLASS)

start = timeGetTime_()

For xx.l = 1 To 10000000
  zz1 = zz1 * yy 
Next 

time1 = timeGetTime_() - start

yy.f = 1.0000001 
zz2.f = 1

start = timeGetTime_()
  !FLD  dword [v_zz2]       ; load variable zz 
  !FLD  dword [v_yy]        ; load variable yy 
  !MOV  dword ECX,10000000
!loop_label: 
  !FMUL ST1,ST
  !DEC  dword ECX 
  !JNZ  loop_label 
  !FFREE ST 
  !FINCSTP 
  !FSTP dword [v_zz2]        ; store variable zz 

time2 = timeGetTime_() - start

SetPriorityClass_(GetCurrentProcess_(), #NORMAL_PRIORITY_CLASS)

A$ = "Time 1: "+StrU(time1,#PB_Long )+" ms (Purebasic) : "+StrF(zz1)
B$ = "Time 2: "+StrU(time2,#PB_Long )+" ms (DirectASM) : "+StrF(zz2)
MessageRequester("RESULT",A$+Chr(13)+B$)

; ExecutableFormat=Windows
; DisableDebugger
; EOF
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 2
; EnableXP