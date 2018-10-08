;- Computes the sine (Taylor/Maclaurin series, double-precision) with AVX
;- "Helle" Klaus Helbing, 16.09.2011, PB v4.51 (x64)
;- Sin(x) = x - (x^3)/3! + (x^5)/5! - (x^7)/7! + (x^9)/9! - (x^11)/11! + (x^13)/13!... 
;- Any results (CPU: Intel i7-2600, 3.4GHz):
;-- Test for Radiant = 9.87654321 (12 terms, with range-reduce):
;-- AVX : -0.436554369141429 = -25.0127228798°  in 171 ms
;-- PB  : -0.436554369141429 = -25.0127228798°  in 343 ms
;-- Test for Radiant = 9.87654321 (only first 4 terms, with range-reduce):
;-- AVX : -0.436554369145432 = -25.0127228800°  in 156 ms
;-- PB  : -0.436554369141429 = -25.0127228798°  in 343 ms
;-- Test for Radiant = 1.23456789 (only first 4 terms, without range-reduce): 
;-- AVX : 0.944005976932239 = 54.0875583133°  in 63 ms
;-- PB  : 0.944005725004535 = 54.0875438789°  in 343 ms
;-- Test for Radiant = 1.23456789 (12 terms, without range-reduce):
;-- AVX : 0.944005725004535 = 54.0875438789°  in 93 ms
;-- PB  : 0.944005725004535 = 54.0875438789°  in 343 ms

;- need a CPU with AVX-support (Sept.2011: Intel "Sandy Bridge") and the actual FAsm.exe from http://flatassembler.net 
Procedure.d SinAVX(x.d)                ;x=radiant, parameter in XMM0/YMM0
  ;this part is for reduce to range 0-Pi/2 and set signum.  If x is in this range (or a little bigger, in your application), you can skip this (faster)
  !vmovsd xmm2,qword[Pi_Half]          ;load XMM2 with Pi_Half (1.570796326794896619) 
  !vdivsd xmm0,xmm0,xmm2               ;divide XMM0 (x=radiant) by XMM2 (Pi_Half), result in XMM0 
  !vcvttsd2si rax,xmm0                 ;convert the result (float double precision) to integer with truncation (like Int(x) in PB) 
  !vcvtsi2sd xmm1,xmm1,rax             ;convert the integer in RAX to float double precision in XMM1
  !vsubsd xmm0,xmm0,xmm1               ;subtract XMM1 from XMM0, result in XMM0 
  !vmulsd xmm0,xmm0,xmm2               ;multiply XMM0 with XMM2 (Pi_Half), result in XMM0
  !test rax,1                          ;test for quadrant 2 and 4 (6,8...)
  !jz @f                               ;no
  !vaddsd xmm0,xmm0,xmm2               ;add Pi_Half (XMM2) to XMM0, result in XMM0  
!@@:
  !test rax,2                          ;test for quadrant 3 and 4 (and all negatives)
  !jz @f                               ;no
  !vxorpd xmm0,xmm0,[Minus]            ;change (set) bit 63 (signum) 
!@@:
  ;calculate the first 4 terms (without start-value x), 1=0-63, 2=64-127, 3=128-191, 4=192-255
  !vmovddup xmm0,xmm0                  ;XMM0: 1=x^1 2=x^1  duplicate bits 0-63 in bits 64-127
  !vinsertf128 ymm1,ymm0,xmm0,1b       ;YMM1: 1=x^1 2=x^1 3=x^1 4=x^1  YMM1(0-127)=XMM0, YMM1(128-255)=XMM0
  !vmulpd ymm2,ymm1,ymm1               ;YMM2: 1=x^2 2=x^2 3=x^2 4=x^2
  !vmulsd xmm3,xmm2,xmm2               ;YMM3: 1=x^4 2=x^2 3=x^0 4=x^0
  !vmulpd ymm4,ymm2,ymm2               ;YMM4: 1=x^4 2=x^4 3=x^4 4=x^4
  !vmulpd ymm2,ymm4,ymm4               ;YMM2: 1=x^8 2=x^8 3=x^8 4=x^8  for the next 4 terms
  !vmulpd ymm3,ymm3,ymm1               ;YMM3: 1=x^5 2=x^3 3=x^0 4=x^0
  !vmulpd ymm1,ymm3,ymm4               ;YMM1: 1=x^9 2=x^7 3=x^0 4=x^0
  !vperm2f128 ymm5,ymm1,ymm3,100000b   ;YMM5: 1=x^9 2=x^7 3=x^5 4=x^3  YMM5(0-127)=YMM1(0-127), YMM5(128-255)=YMM3(0-127)  

  !vmovupd ymm4,yword[RezFak]          ;load the first 4 reciprocals factorials (-1/3! ... 1/9!) in YMM4
  !vmulpd ymm1,ymm5,ymm4               ;multiply the 4 values in YMM4 with YMM5, result in YMM1
  ;next 4 terms, I think, too short for a loop. For lower precision (faster) you can reduce the steps 
  !vmulpd ymm5,ymm5,ymm2               ;YMM5: 1=x^17 2=x^15 3=x^13 4=x^11
  !vmulpd ymm3,ymm5,yword[RezFak+32]
  !vaddpd ymm1,ymm3,ymm1
  ;next 4 terms
  !vmulpd ymm5,ymm5,ymm2               ;YMM5: 1=x^25 2=x^23 3=x^21 4=x^19
  !vmulpd ymm3,ymm5,yword[RezFak+64]
  !vaddpd ymm1,ymm3,ymm1

  !vhaddpd ymm2,ymm1,ymm1              ;YMM2: 1=1+2 of YMM1, 3=3+4 of YMM1 
  !vextractf128 xmm1,ymm2,1b           ;XMM1: 3+4 of YMM2
  !vaddsd xmm3,xmm2,xmm1               ;XMM3: 1=sum of iterations 

  !vaddsd xmm0,xmm0,xmm3               ;XMM0: 1=sum of iterations plus start-value (1.term=x)

  !vzeroupper                          ;set YMM0H-YMM15H to zero

!vmovsd qword[rsp+48],xmm0           ;because PB is not ABI (Application Binary Interface)-conform (standard: return-value in XMM0/YMM0)
!fld qword[rsp+48] 

 ProcedureReturn

!Minus:
  !dq 8000000000000000h           ;for change (set) bit 63 (signum)
!Pi_Half:
  !dq  1.570796326794896619
!RezFak:
  !dq  2.755731922398589065e-6    ; 1/9!   4.Iteration
  !dq -1.984126984126984127e-4    ;-1/7!   3.Iteration
  !dq  8.333333333333333333e-3    ; 1/5!   2.Iteration
  !dq -1.666666666666666667e-1    ;-1/3!   1.Iteration

  !dq  2.811457254345520763e-15   ; 1/17!  8.Iteration
  !dq -7.647163731819816476e-13   ;-1/15!  7.Iteration
  !dq  1.605904383682161460e-10   ; 1/13!  6.Iteration
  !dq -2.505210838544171878e-8    ;-1/11!  5.Iteration

  !dq  6.446950284384473396e-26   ; 1/25!  12.Iteration
  !dq -3.868170170630684038e-23   ;-1/23!  11.Iteration
  !dq  1.957294106339126123e-20   ; 1/21!  10.Iteration
  !dq -8.220635246624329717e-18   ;-1/19!  9.Iteration
EndProcedure 

Rad.d = 9.87654321

;- Test AVX
T1= ElapsedMilliseconds() 
For i = 0 To 9999999 
  SinAVX.d = SinAVX(Rad)
Next 
T1 = ElapsedMilliseconds() - T1 

;- Test PB
T2= ElapsedMilliseconds() 
For i = 0 To 9999999 
  SinPB.d = Sin(Rad) 
Next 
T2 = ElapsedMilliseconds() - T2 

Sin$ = "Test for Radiant = " + StrD(Rad) + #CRLF$ + #CRLF$
Sin$ + "AVX : " + StrD(SinAVX, 15) + " = " + StrD(SinAVX * 180 / #PI) + "°  in " + Str(T1) + " ms" + #CRLF$ 
Sin$ + "PB   : " + StrD(SinPB, 15) + " = " + StrD(SinPB * 180 / #PI) + "°  in " + Str(T2) + " ms" + #CRLF$ 
MessageRequester("Sinus Double-Precision with AVX", Sin$) 

End
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 14
; FirstLine = 1
; Folding = -
; EnableXP