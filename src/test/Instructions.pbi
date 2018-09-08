;- Test-Version! Helle 14.06.2016
;- PureBasic 5.50 beta 1 (x64), Test with Windows_7 64-bit
;- Unicode!!!

Global PAE.q
Global PAEBits.l
Global S1.l                  ;for CPU-String x86/x64
Global S2.l
Global S3.l
Global S4.l
Global Z.l
Global FZ1.l                 ;Feature-Counter Row 1 (0...)
Global FZ2.l                 ;Feature-Counter Row 1+2
Global FZ3.l                 ;Feature-Counter Row 1+2+3
Global CPUInfo.l             ;CPU-Balloon-Tip
Global SichEAX.l             ;for CPUID
Global SichEBX.l
Global SichECX.l
Global SichEDX.l
Global MaxID.l
Global MaxIDExt.l
Global IsAMD.l
Global IsIntel.l

Global Bit0.l  = $1          ;for SSE3, XSAVEOPT, CLZERO
Global Bit1.l  = $2          ;for PCLMULQDQ
Global Bit2.l  = $4          ;for SVM
Global Bit3.l  = $8          ;for BMI(1),MONITOR 
Global Bit4.l  = $10         ;for HLE, RDTSC
Global Bit5.l  = $20         ;for AVX2, LZCNT, MSR, VMX  
Global Bit6.l  = $40         ;for SMX, SSE4A, PAE
Global Bit7.l  = $80         ;for AMDMISAL16
Global Bit8.l  = $100        ;for 3DNOWPREFETCH, BMI2, CMPXCHG8B, Invariant TSC 
Global Bit9.l  = $200        ;for SSSE3
Global Bit10.l = $400        ;for INVPCID
Global Bit11.l = $800        ;for RTM, SEP, XOP
Global Bit12.l = $1000       ;for FMA
Global Bit13.l = $2000       ;for CMPXCHG16B
Global Bit15.l = $8000       ;for (F)CMOVcc, LWP
Global Bit16.l = $10000      ;for FMA4, AVX512F
Global Bit18.l = $40000      ;for RDSEED
Global Bit19.l = $80000      ;for SSE4.1, CLFSH, ADX
Global Bit20.l = $100000     ;for SSE4.2, SMAP
Global Bit21.l = $200000     ;for TBM
Global Bit22.l = $400000     ;for EMMX, MOVBE
Global Bit23.l = $800000     ;for MMX, POPCNT
Global Bit24.l = $1000000    ;for FXSR
Global Bit25.l = $2000000    ;for AES, SSE 
Global Bit26.l = $4000000    ;for SSE2, XSAVE
Global Bit27.l = $8000000    ;for OSXSAVE, RDTSCP
Global Bit28.l = $10000000   ;for AVX
Global Bit29.l = $20000000   ;for ARCH64, F16C, SHA
Global Bit30.l = $40000000   ;for Extended 3DNow!, RDRAND
Global Bit31.l = $80000000   ;for 3DNow!

Global ProzessorString.i = AllocateMemory(48)    ;new for Unicode; or new: *Buffer = Ascii(String$)

Enumeration CPU_Features
  #DNow            ;0
  #EXT3DNOW
  #DNOWPREF
  #ADX
  #AES
  #AMDMISAL16
  #ARCH64
  #AVX
  #AVX2
  #AVX512F
  #BMI1            ;10
  #BMI2
  #CLFSH
  #CLZERO
  #CMOV
  #CX8
  #CX16
  #F16C
  #FMA
  #FMA4
  #FXSR            ;20
  #HLE
  #INVPCID
  #LWP
  #LZCNT
  #MMX
  #EMMX
  #MONITOR
  #MOVBE
  #MSR
  #OSXSAVE         ;30
  #PAE
  #PCLMULQDQ
  #POPCNT
  #RDRAND
  #RDSEED
  #RDTSC
  #RDTSCP
  #RTM
  #SEP
  #SHA             ;40
  #SMAP
  #SMX
  #SSE
  #SSE2
  #SSE3
  #SSSE3
  #SSE41
  #SSE42
  #SSE4A
  #SVM             ;50
  #TBM
  #VMX
  #XOP
  #XSAVE 
  #XSAVEOPT
EndEnumeration

Structure CPU
  Feature.s
  Info.s
  Pixel.l 
  Color.l
EndStructure
Global Dim CPU_Info.CPU(#PB_Compiler_EnumerationValue - 1)
 
CPU_Info(#DNow)\Feature = "3DNOW!" : CPU_Info(#DNow)\Info = "AMD only" : CPU_Info(#DNow)\Pixel = 48
CPU_Info(#EXT3DNOW)\Feature = "EXT3DNOW!" : CPU_Info(#EXT3DNOW)\Info = "PF2IW, PFNACC, PFPNACC, PI2FW, PSWAPD" + #CR$ + "AMD only" : CPU_Info(#EXT3DNOW)\Pixel = 70
CPU_Info(#DNOWPREF)\Feature = "3DNOWPREF" : CPU_Info(#DNOWPREF)\Info = "3DNOWPREFETCH" + #CR$ + "AMD only" : CPU_Info(#DNOWPREF)\Pixel = 71
CPU_Info(#ADX)\Feature = "ADX" : CPU_Info(#ADX)\Info = "ADCX, ADOX                               " + #CR$ + "Intel only" : CPU_Info(#ADX)\Pixel = 24
CPU_Info(#AES)\Feature = "AES" : CPU_Info(#AES)\Info = "Intel and AMD" : CPU_Info(#AES)\Pixel = 24
CPU_Info(#AMDMISAL16)\Feature = "AMDMISAL16" : CPU_Info(#AMDMISAL16)\Info = "Misaligned 16-Byte Memory Access" + #CR$ + "AMD only" : CPU_Info(#AMDMISAL16)\Pixel = 75
CPU_Info(#ARCH64)\Feature = "ARCH64" : CPU_Info(#ARCH64)\Info = "64-Bit-Architecture" + #CR$ + "AMD: Long Mode" + #CR$ + "Intel: Intel 64" : CPU_Info(#ARCH64)\Pixel = 45
CPU_Info(#AVX)\Feature = "AVX" : CPU_Info(#AVX)\Info = "Intel and AMD" : CPU_Info(#AVX)\Pixel = 24
CPU_Info(#AVX2)\Feature = "AVX2" : CPU_Info(#AVX2)\Info = "Intel and AMD" : CPU_Info(#AVX2)\Pixel = 31
CPU_Info(#AVX512F)\Feature = "AVX512F" : CPU_Info(#AVX512F)\Info = "AVX-512 Foundation Instructions (Base for other AVX512)" + #CR$ + "Future" : CPU_Info(#AVX512F)\Pixel = 52
CPU_Info(#BMI1)\Feature = "BMI(1)" : CPU_Info(#BMI1)\Info = "Bit Manipulation Instructions (1)                       " + #CR$ + "ANDN, BEXTR, BLSI, BLSMSK, BLSR, TZCNT" + #CR$ + "Intel: BMI1" + #CR$ + "AMD: BMI" : CPU_Info(#BMI1)\Pixel = 37
CPU_Info(#BMI2)\Feature = "BMI2" : CPU_Info(#BMI2)\Info = "Bit Manipulation Instructions 2                                    " + #CR$ + "BZHI, MULX, PDEP, PEXT, RORX, SARX, SHLX, SHRX" + #CR$ + "Intel and AMD" : CPU_Info(#BMI2)\Pixel = 28
CPU_Info(#CLFSH)\Feature = "CLFSH" : CPU_Info(#CLFSH)\Info = "CLFLUSH        " + #CR$ + "Intel and AMD" : CPU_Info(#CLFSH)\Pixel = 37
CPU_Info(#CLZERO)\Feature = "CLZERO" : CPU_Info(#CLZERO)\Info = "AMD only" : CPU_Info(#CLZERO)\Pixel = 47
CPU_Info(#CMOV)\Feature = "(F)CMOV" : CPU_Info(#CMOV)\Info = "CMOVcc, FCMOVcc" + #CR$ + "Intel and AMD" : CPU_Info(#CMOV)\Pixel = 49
CPU_Info(#CX8)\Feature = "CX8" : CPU_Info(#CX8)\Info = "CMPXCHG8B   " + #CR$ + "Intel and AMD" : CPU_Info(#CX8)\Pixel = 23
CPU_Info(#CX16)\Feature = "CX16" : CPU_Info(#CX16)\Info = "CMPXCHG16B" + #CR$ + "Intel and AMD" : CPU_Info(#CX16)\Pixel = 31
CPU_Info(#F16C)\Feature = "F16C" : CPU_Info(#F16C)\Info = "16-Bit Floating-Point Conversion" + #CR$ + "Intel and AMD" : CPU_Info(#F16C)\Pixel = 29
CPU_Info(#FMA)\Feature = "FMA" : CPU_Info(#FMA)\Info = "Fused Multiply Add (3 Operands)" + #CR$ + "Intel and AMD" : CPU_Info(#FMA)\Pixel = 25
CPU_Info(#FMA4)\Feature = "FMA4" : CPU_Info(#FMA4)\Info = "Fused Multiply Add (4 Operands)" + #CR$ + "AMD only" : CPU_Info(#FMA4)\Pixel = 33
CPU_Info(#FXSR)\Feature = "FXSR" : CPU_Info(#FXSR)\Info = "FXSAVE, FXRSTOR" + #CR$ + "Intel and AMD" : CPU_Info(#FXSR)\Pixel = 29
CPU_Info(#HLE)\Feature = "HLE" : CPU_Info(#HLE)\Info = "Hardware Lock Elision                 " + #CR$ + "XACQUIRE, XRELEASE, XTEST" + #CR$ + "Intel only" : CPU_Info(#HLE)\Pixel = 23
CPU_Info(#INVPCID)\Feature = "INVPCID" : CPU_Info(#INVPCID)\Info = "Intel only" : CPU_Info(#INVPCID)\Pixel = 47
CPU_Info(#LWP)\Feature = "LWP" : CPU_Info(#LWP)\Info = "LightWeight Profiling" + #CR$ + "AMD only" : CPU_Info(#LWP)\Pixel = 25
CPU_Info(#LZCNT)\Feature = "LZCNT" : CPU_Info(#LZCNT)\Info = "Intel and AMD (ABM)" : CPU_Info(#LZCNT)\Pixel = 38
CPU_Info(#MMX)\Feature = "MMX" : CPU_Info(#MMX)\Info = "Multi Media Extension" + #CR$ + "Intel and AMD" : CPU_Info(#MMX)\Pixel = 28
CPU_Info(#EMMX)\Feature = "(E)MMX" : CPU_Info(#EMMX)\Info = "AMD Extensions to MMX" + #CR$ + "AMD only" : CPU_Info(#EMMX)\Pixel = 43
CPU_Info(#MONITOR)\Feature = "MONITOR" : CPU_Info(#MONITOR)\Info = "MONITOR, MWAIT" + #CR$ + "Intel and AMD" : CPU_Info(#MONITOR)\Pixel = 55
CPU_Info(#MOVBE)\Feature = "MOVBE" : CPU_Info(#MOVBE)\Info = "Intel and AMD" : CPU_Info(#MOVBE)\Pixel = 40
CPU_Info(#MSR)\Feature = "MSR" : CPU_Info(#MSR)\Info = "RDMSR, WRMSR" + #CR$ + "Intel and AMD" : CPU_Info(#MSR)\Pixel = 26
CPU_Info(#OSXSAVE)\Feature = "OSXSAVE" : CPU_Info(#OSXSAVE)\Info = "OS Support for Processor extended State Management using XSAVE/XRSTOR" + #CR$ + "Is not a CPU-Feature; is a copy of the CR4-OSXSAVE-Bit" + #CR$ + "Intel and AMD" : CPU_Info(#OSXSAVE)\Pixel = 52
CPU_Info(#PAE)\Feature = "PAE" : CPU_Info(#PAE)\Info = "Physical Address Extensions" + #CR$ + "Intel and AMD" + #CR$ + PAE$ : CPU_Info(#PAE)\Pixel = 23
CPU_Info(#PCLMULQDQ)\Feature = "PCLMULQDQ" : CPU_Info(#PCLMULQDQ)\Info = "Carryless Multiplication" + #CR$ + "Intel and AMD" : CPU_Info(#PCLMULQDQ)\Pixel = 75
CPU_Info(#POPCNT)\Feature = "POPCNT" : CPU_Info(#POPCNT)\Info = "Intel and AMD" : CPU_Info(#POPCNT)\Pixel = 47
CPU_Info(#RDRAND)\Feature = "RDRAND" : CPU_Info(#RDRAND)\Info = "Intel and AMD" : CPU_Info(#RDRAND)\Pixel = 49
CPU_Info(#RDSEED)\Feature = "RDSEED" : CPU_Info(#RDSEED)\Info = "Intel only" : CPU_Info(#RDSEED)\Pixel = 46
CPU_Info(#RDTSC)\Feature = "RDTSC" : CPU_Info(#RDTSC)\Info = "Intel and AMD" : CPU_Info(#RDTSC)\Pixel = 37
CPU_Info(#RDTSCP)\Feature = "RDTSCP" : CPU_Info(#RDTSCP)\Info = "For Multi-Processor-Boards" + #CR$ + "Intel and AMD" : CPU_Info(#RDTSCP)\Pixel = 45
CPU_Info(#RTM)\Feature = "RTM" : CPU_Info(#RTM)\Info = "Restricted Transactional Memory  " + #CR$ + "XBEGIN, XEND, XABORT, XTEST" + #CR$ + "Intel only" : CPU_Info(#RTM)\Pixel = 25
CPU_Info(#SEP)\Feature = "SEP" : CPU_Info(#SEP)\Info = "SYSENTER, SYSEXIT" + #CR$ + "Intel and AMD" : CPU_Info(#SEP)\Pixel = 22
CPU_Info(#SHA)\Feature = "SHA" : CPU_Info(#SHA)\Info = "Future" : CPU_Info(#SHA)\Pixel = 22
CPU_Info(#SMAP)\Feature = "SMAP" : CPU_Info(#SMAP)\Info = "Supervisor-Mode Access Prevention" + #CR$ + "CLAC, STAC            " + #CR$ + "Intel only" : CPU_Info(#SMAP)\Pixel = 32
CPU_Info(#SMX)\Feature = "SMX" : CPU_Info(#SMX)\Info = "Safer Mode Extensions" + #CR$ + "Intel only" : CPU_Info(#SMX)\Pixel = 24
CPU_Info(#SSE)\Feature = "SSE" : CPU_Info(#SSE)\Info = "Intel and AMD" : CPU_Info(#SSE)\Pixel = 20
CPU_Info(#SSE2)\Feature = "SSE2" : CPU_Info(#SSE2)\Info = "Intel and AMD" : CPU_Info(#SSE2)\Pixel = 28
CPU_Info(#SSE3)\Feature = "SSE3" : CPU_Info(#SSE3)\Info = "Intel and AMD" : CPU_Info(#SSE3)\Pixel = 28
CPU_Info(#SSSE3)\Feature = "SSSE3" : CPU_Info(#SSSE3)\Info = "Intel and AMD" : CPU_Info(#SSSE3)\Pixel = 36
CPU_Info(#SSE41)\Feature = "SSE4.1" : CPU_Info(#SSE41)\Info = "Intel and AMD" : CPU_Info(#SSE41)\Pixel = 39
CPU_Info(#SSE42)\Feature = "SSE4.2" : CPU_Info(#SSE42)\Info = "Intel and AMD" : CPU_Info(#SSE42)\Pixel = 39
CPU_Info(#SSE4A)\Feature = "SSE4A" : CPU_Info(#SSE4A)\Info = "EXTRQ, INSERTQ, MOVNTSD, MOVNTSS" + #CR$ + "AMD only" : CPU_Info(#SSE4A)\Pixel = 36
CPU_Info(#SVM)\Feature = "SVM" : CPU_Info(#SVM)\Info = "Secure Virtual Machine" + #CR$ + "AMD only" : CPU_Info(#SVM)\Pixel = 24
CPU_Info(#TBM)\Feature = "TBM" : CPU_Info(#TBM)\Info = "Trailing Bit Manipulation" + #CR$ + "AMD only" : CPU_Info(#TBM)\Pixel = 24
CPU_Info(#VMX)\Feature = "VMX" : CPU_Info(#VMX)\Info = "Virtual Machine Extensions" + #CR$ + "Intel only" : CPU_Info(#VMX)\Pixel = 26
CPU_Info(#XOP)\Feature = "XOP" : CPU_Info(#XOP)\Info = "Extended Operations" + #CR$ + "AMD only" : CPU_Info(#XOP)\Pixel = 23
CPU_Info(#XSAVE)\Feature = "XSAVE" : CPU_Info(#XSAVE)\Info = "XSAVE/XRSTOR, XSETBV/XGETBV (XCR0)" + #CR$ + "Intel and AMD" : CPU_Info(#XSAVE)\Pixel = 36
CPU_Info(#XSAVEOPT)\Feature = "XSAVEOPT" : CPU_Info(#XSAVEOPT)\Info = "Intel and AMD" : CPU_Info(#XSAVEOPT)\Pixel = 61

For i = 0 To #PB_Compiler_EnumerationValue - 1
  CPU_Info(i)\Color = $0000D0          ;for CPUID, Red as Start (= not available)
Next

Procedure CPUInfo(Title$, Text$)
  CPUInfo = CreateWindowEx_(#WS_EX_TOPMOST, #TOOLTIPS_CLASS, #Null, #WS_POPUP | #TTS_ALWAYSTIP | #TTS_BALLOON, 0, 0, 0, 0, 0, 0, 0, 0)
  SendMessage_(CPUInfo, #TTM_SETTITLE, #TOOLTIP_INFO_ICON, @Title$)
  Balloon.TOOLINFO\cbSize = SizeOf(TOOLINFO)
  Balloon\lpszText = @Text$
  SendMessage_(CPUInfo, #TTM_ADDTOOL, 0, @Balloon)
  SendMessage_(CPUInfo, #TTM_TRACKACTIVATE, 1, @Balloon)
 ProcedureReturn CPUInfo
EndProcedure

Procedure CPUID_Info()
  ;Instruction/Group   CPUID (EAX)     Register    Bit    Intel    AMD   Remarks
  ;--------------------------------------------------------------------------------------------------------
  ;3DNOW!               80000001h         EDX      31       -       x
  ;3DNOWPREFETCH        80000001h         ECX       8       -       x   
  ;ADX                  00000007h         EBX      19       x       -    Input ECX=0, ADCX, ADOX. AMD with Zen (?)
  ;AES                  00000001h         ECX      25       x       x
  ;ARCH64               80000001h         EDX      29       x       x    AMD: Long Mode, Intel: Intel 64 Architecture
  ;AMDMISAL16           80000001h         ECX       7       -       x    Misaligned 16-Byte Memory Access
  ;AVX                  00000001h         ECX      28       x       x
  ;AVX2                 00000007h         EBX       5       x       x    Input ECX=0
  ;AVX512F              00000007h         EBX      16       x       -    Input ECX=0, offizieller Name (Intel): AVX-512 Foundation Instructions
  ;BMI(1)               00000007h         EBX       3       x       x    Input ECX=0, Bit Manipulation Instructions BMI1=Intel, BMI=AMD
  ;BMI2                 00000007h         EBX       8       x       x    Input ECX=0, Bit Manipulation Instructions  
  ;CLFSH                00000001h         EDX      19       x       x    CLFLUSH
  ;CLZERO               80000008h         EBX       0       -       x
  ;(F)CMOV              00000001h         EDX      15       x       x    CMOVcc, FCMOVcc
  ;CMPXCHG8B            00000001h         EDX       8       x       x
  ;CMPXCHG16B           00000001h         ECX      13       x       x
  ;EMMX                 80000001h         EDX      22       -       x    AMD Extensions for MMX
  ;EXT3DNOW!            80000001h         EDX      30       -       x    Extensions for 3DNOW!
  ;F16C                 00000001h         ECX      29       x       x
  ;FMA                  00000001h         ECX      12       x       x    Fused Multiply Add (3 Operands)
  ;FMA4                 80000001h         ECX      16       -       x    Fused Multiply Add (4 Operands)
  ;FXSR                 00000001h         EDX      24       x       x    FXSAVE, FXRSTOR
  ;HLE                  00000007h         EBX       4       x       -    Input ECX=0, Hardware Lock Elision
  ;INVPCID              00000007h         EBX      10       x       -    Input ECX=0 
  ;LWP                  80000001h         ECX      15       -       x    LightWeight Profiling
  ;LZCNT                80000001h         ECX       5       x       x
  ;MMX                  00000001h         EDX      23       x       x
  ;MONITOR              00000001h         ECX       3       x       x    MONITOR, MWAIT
  ;MOVBE                00000001h         ECX      22       x       x
  ;MSR                  00000001h         EDX       5       x       x    RDMSR, WRMSR  
  ;OSXSAVE              00000001h         ECX      27       x       x    Ist kein CPU-Feature; ist das kopierte OSXSAVE-Bit von CR4. Dient der Ermittlung, ob das OS XSAVE freigeschaltet hat
  ;PAE                  00000001h         EDX       6       x       x    Physical Address Extensions
  ;PCLMULQDQ            00000001h         ECX       1       x       x    Carryless Multiplication
  ;POPCNT               00000001h         ECX      23       x       x
  ;RDRAND               00000001h         ECX      30       x       x
  ;RDSEED               00000007h         EBX      18       x       x    Input ECX=0
  ;RDTSC                00000001h         EDX       4       x       x  
  ;RDTSCP               80000001h         EDX      27       x       x
  ;RTM                  00000007h         EBX      11       x       -    Input ECX=0
  ;SEP                  00000001h         EDX      11       x       x    SYSENTER, SYSEXIT
  ;SHA                  00000007h         EBX      29       -       -    Input ECX=0, Intel with Cannonlake (?) and AMD with Zen (?)
  ;SMAP                 00000007h         EBX      20       x       -    Input ECX=0, AMD with Zen (?)
  ;SMX                  00000001h         ECX       6       x       -    Safer Mode Extensions
  ;SSE                  00000001h         EDX      25       x       x
  ;SSE2                 00000001h         EDX      26       x       x
  ;SSE3                 00000001h         ECX       0       x       x  
  ;SSSE3                00000001h         ECX       9       x       x  
  ;SSE4.1               00000001h         ECX      19       x       x  
  ;SSE4.2               00000001h         ECX      20       x       x  
  ;SSE4A                80000001h         ECX       6       -       x
  ;SVM                  80000001h         ECX       2       -       x    Secure Virtual Machine
  ;TBM                  80000001h         ECX      21       -       x    Trailing Bit Manipulation
  ;VMX                  00000001h         ECX       5       x       -    Virtual Machine Extensions
  ;XOP                  80000001h         ECX      11       -       x    Extended Operations, war mal das reservierte Flag für AMDs SSE5 (bis ca.2009)  
  ;XSAVE                00000001h         ECX      26       x       x    XSAVE/XRSTOR, XSETBV/XGETBV, XCR0. Voraussetzung ist OSXSAVE 
  ;XSAVEOPT             0000000Dh         EAX       0       x       x    Input ECX=1

  ;No Test for CPUID!  
  !xor eax,eax
  !cpuid
  !mov [v_MaxID],eax         ;max. ID
  !cmp ecx,6C65746Eh         ;"letn", Part of Intel-String
  !jne @f
  !mov [v_IsIntel],1
  !jmp CPUEnd
!@@:
  !cmp ecx,444D4163h         ;"DMAc", Part of AMD-String
  !jne CPUEnd
  !mov [v_IsAMD],1
!CPUEnd:

  If IsIntel = 0 And IsAMD = 0
    MessageRequester("Error!", "This is not an Intel- or AMD-CPU!");, #PB_MessageRequester_Error) 
    End
  EndIf

    !mov eax,80000000h       ;Check for max. Extended Level, Intel and AMD
    !cpuid
    !mov [v_MaxIDExt],eax    ;max. ExtID, 8000000xh

    !mov eax,1h              ;for 1 no Test for MaxID         
    !cpuid
    !mov [v_SichECX],ecx
    !mov [v_SichEDX],edx

    !and edx,[v_Bit6]        ;PAE
    !jz NOPAE
    CPU_Info(#PAE)\Color = $008800
    !mov eax,80000001h
    !cpuid
    !and edx,[v_Bit29]
    !jz NOPAE                ;no more Infos
    !cmp [v_MaxIDExt],80000008h   ;2.Test
    !jb NOPAE                ;no more Infos
    !mov eax,80000008h
    !cpuid
    !and eax,11111111b       ;Bits 07-00: #Physical Address Bits
    !mov [v_PAEBits],eax
    PAE = Int(Pow(2, PAEBits))
    PAE >> 30
    Einheit$ = " G"
    If PAE > 1024
      PAE >> 10
      Einheit$ = " T"
    EndIf 
    PAE$ = "This CPU: Max. " + Str(PAE) + Einheit$ + "Byte"
    CPU_Info(#PAE)\Info = "Physical Address Extensions" + #CR$ + "Intel and AMD" + #CR$ + PAE$
!NOPAE:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit23]      ;MMX
    !jz NOMMX
    CPU_Info(#MMX)\Color = $008800     ;Green for available
!NOMMX:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit25]      ;SSE  
    !jz NOSSE
    CPU_Info(#SSE)\Color = $008800
!NOSSE:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit26]      ;SSE2  
    !jz NOSSE2
    CPU_Info(#SSE2)\Color = $008800
!NOSSE2:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit0]       ;SSE3
    !jz NOSSE3
    CPU_Info(#SSE3)\Color = $008800
!NOSSE3:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit9]       ;SSSE3
    !jz NOSSSE3
    CPU_Info(#SSSE3)\Color = $008800
!NOSSSE3:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit19]      ;SSE4.1
    !jz NOSSE41
    CPU_Info(#SSE41)\Color = $008800
!NOSSE41:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit20]      ;SSE4.2
    !jz NOSSE42
    CPU_Info(#SSE42)\Color = $008800
!NOSSE42:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit23]      ;POPCNT
    !jz NOPOPCNT
    CPU_Info(#POPCNT)\Color = $008800
!NOPOPCNT:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit1]       ;PCLMULQDQ
    !jz NOPCLMULQDQ
    CPU_Info(#PCLMULQDQ)\Color = $008800
!NOPCLMULQDQ:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit3]       ;MONITOR
    !jz NOMONITOR
    CPU_Info(#MONITOR)\Color = $008800
!NOMONITOR:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit5]       ;VMX
    !jz NOVMX
    CPU_Info(#VMX)\Color = $008800
!NOVMX:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit6]       ;SMX
    !jz NOSMX
    CPU_Info(#SMX)\Color = $008800
!NOSMX:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit12]      ;FMA
    !jz NOFMA
    CPU_Info(#FMA)\Color = $008800
!NOFMA:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit11]      ;SEP
    !jz NOSEP
    CPU_Info(#SEP)\Color = $008800
!NOSEP:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit24]      ;FXSR
    !jz NOFXSR
    CPU_Info(#FXSR)\Color = $008800
!NOFXSR:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit8]       ;CMPXCHG8B
    !jz NOCX8
    CPU_Info(#CX8)\Color = $008800
!NOCX8:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit13]      ;CMPXCHG16B
    !jz NOCX16
    CPU_Info(#CX16)\Color = $008800
!NOCX16:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit25]      ;AES
    !jz NOAES
    CPU_Info(#AES)\Color = $008800
!NOAES:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit27]      ;OSXSAVE
    !jz NOOSXSAVE
    CPU_Info(#OSXSAVE)\Color = $008800
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit26]      ;XSAVE
    !jz NOXSAVE
    CPU_Info(#XSAVE)\Color = $008800
!NOXSAVE:
    !mov eax,0Dh
    !cmp [v_MaxID],eax       ;max. ID
    !jb NOXSAVEOPT
    !mov ecx,1
    !cpuid
    !test eax,[v_Bit0]       ;XSAVEOPT
    !jz NOXSAVEOPT
    CPU_Info(#XSAVEOPT)\Color = $008800
!NOXSAVEOPT:

!NOOSXSAVE:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit28]      ;AVX
    !jz NOAVX

;1) Detect CPUID.1:ECX.OSXSAVE[bit 27] = 1 (XGETBV enabled for application use1)
;2) Execute XGETBV and verify that XCR0[7:5] = ‘111b’ (OPMASK state, upper 256-bit of ZMM0-ZMM15 and
;ZMM16-ZMM31 state are enabled by OS) and that XCR0[2:1] = ‘11b’ (XMM state and YMM state are enabled by
;OS).
;3) Detect CPUID.0x7.0:EBX.AVX512F[bit 16] = 1.
    !xor ecx,ecx             ;read XCR0
    !xgetbv                  ;eax=Bits 0-31
    !test eax,[v_Bit2]       ;Bit0=x87, Bit1=SSE, Bit2=AVX. Bit2 kann nur vom OS gesetzt werden wenn auch Bit1 gesetzt ist. Bit0 ist immer gesetzt 
    !jz NOAVX

    CPU_Info(#AVX)\Color = $008800

!NOAVX:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit29]      ;F16C
    !jz NOF16C
    CPU_Info(#F16C)\Color = $008800
!NOF16C:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit22]      ;MOVBE
    !jz NOMOVBE
    CPU_Info(#MOVBE)\Color = $008800
!NOMOVBE:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit15]      ;(F)CMOVcc
    !jz NOCMOV
    CPU_Info(#CMOV)\Color = $008800
!NOCMOV:       
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit19]      ;CLFSH
    !jz NOCLFSH
    CPU_Info(#CLFSH)\Color = $008800
!NOCLFSH:       
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit5]       ;MSR
    !jz NOMSR
    CPU_Info(#MSR)\Color = $008800
!NOMSR:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit30]      ;RDRAND
    !jz NORDRAND
    CPU_Info(#RDRAND)\Color = $008800
!NORDRAND:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit4]       ;RDTSC
    !jz NORDTSC
    CPU_Info(#RDTSC)\Color = $008800
    CPU_Info(#RDTSC)\Info = "Invariant: No" + #CR$ + "Intel and AMD"
    If (MaxIDExt & $FFFFFFFF) >=  $80000007
      !mov eax,80000007h
      !cpuid 
      !test edx,[v_Bit8]
      !jz NORDTSC
      CPU_Info(#RDTSC)\Info = "Invariant: Yes" + #CR$ + "Intel and AMD"
    EndIf
!NORDTSC:
    !mov eax,7
    !cmp [v_MaxID],eax       ;max. ID
    !jb NORTM
    !xor ecx,ecx
    !cpuid
    !mov [v_SichEBX],ebx
    !test ebx,[v_Bit19]      ;ADX
    !jz NOADX
    CPU_Info(#ADX)\Color = $008800
!NOADX:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit5]       ;AVX2
    !jz NOAVX2

    CPU_Info(#AVX2)\Color = $008800
!NOAVX2:    
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit16]      ;AVX512F
    !jz NOAVX512F

    CPU_Info(#AVX512F)\Color = $008800

!NOAVX512F:   
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit3]       ;BMI(1)
    !jz NOBMI1
    CPU_Info(#BMI1)\Color = $008800
!NOBMI1:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit8]       ;BMI2
    !jz NOBMI2
    CPU_Info(#BMI2)\Color = $008800
!NOBMI2:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit4]       ;HLE
    !jz NOHLE
    CPU_Info(#HLE)\Color = $008800
!NOHLE:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit10]      ;INVPCID
    !jz NOINVPCID
    CPU_Info(#INVPCID)\Color = $008800
!NOINVPCID:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit18]      ;RDSEED
    !jz NORDSEED
    CPU_Info(#RDSEED)\Color = $008800
!NORDSEED:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit11]      ;RTM
    !jz NORTM
    CPU_Info(#RTM)\Color = $008800
!NORTM:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit29]      ;SHA
    !jz NOSHA
    CPU_Info(#SHA)\Color = $008800
!NOSHA:
    !mov ebx,[v_SichEBX]
    !test ebx,[v_Bit20]      ;SMAP
    !jz NOSMAP
    CPU_Info(#SMAP)\Color = $008800
!NOSMAP:

    !cmp [v_MaxIDExt],80000001h
    !jb NOEXTE
 
    !cmp [v_MaxIDExt],80000004h   ;Test, if the CPU gives the Prozessor-String
    !jb NOCPUSTR

  ;Prozessor-String
  While Z < 3
    !mov eax,80000002h
    !add eax,[v_Z]
    !cpuid        
    !mov [v_S1],eax
    !mov [v_S2],ebx  
    !mov [v_S3],ecx
    !mov [v_S4],edx
    PokeL(ProzessorString + (Z << 4), S1)
    PokeL(ProzessorString + (Z << 4) + 4, S2)
    PokeL(ProzessorString + (Z << 4) + 8, S3)
    PokeL(ProzessorString + (Z << 4) + 12, S4)
    Z + 1
  Wend

!NOCPUSTR:
    !mov eax,80000001h
    !cpuid
    !mov [v_SichECX],ecx
    !mov [v_SichEDX],edx

    !test edx,[v_Bit29]      ;AMD: Long Mode, Intel: Intel 64 Architecture
    !jz NOARCH64
    CPU_Info(#ARCH64)\Color = $008800
!NOARCH64:     
    ;Test for Intel-Prozessor
    !cmp [v_IsIntel],1
    !je NOAMD                ;is Intel-Prozessor
    ;is AMD-Prozessor
    !test edx,[v_Bit31]      ;AMD 3DNow! 
    !jz NOEXT
    CPU_Info(#DNow)\Color = $008800
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit30]      ;AMD Extended 3DNow!  DSP: PF2IW, PFNACC, PFPNACC, PI2FW, PSWAPD
    !jz NOEXT
    CPU_Info(#EXT3DNOW)\Color = $008800
!NOEXT:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit8]       ;AMD 3DNOWPREFETCH
    !jz NODNOWPREF
    CPU_Info(#DNOWPREF)\Color = $008800
!NODNOWPREF:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit6]       ;AMD SSE4A: EXTRQ, INSERTQ, MOVNTSD, MOVNTSS
    !jz NOSSE4A
    CPU_Info(#SSE4A)\Color = $008800
!NOSSE4A:     
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit7]       ;AMDMISAL16 
    !jz NOAMDMISAL16
    CPU_Info(#AMDMISAL16)\Color = $008800
!NOAMDMISAL16:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit22]      ;EMMX
    !jz NOEMMX
    CPU_Info(#EMMX)\Color = $008800
!NOEMMX:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit16]      ;FMA4
    !jz NOFMA4
    CPU_Info(#FMA4)\Color = $008800
!NOFMA4:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit15]      ;LWP
    !jz NOLWP
    !xor ecx,ecx
    !xgetbv                  ;if LWP available, is XGETBV also available
    !test edx,[v_Bit30]
    !jnz @f
    CPU_Info(#LWP)\Color = $FF0000     ;Blue, OS (Windows) no unlocked
    !jmp NOLWP
!@@:
    CPU_Info(#LWP)\Color = $008800     ;Green, OS (Windows) unlocked
!NOLWP:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit2]       ;SVM
    !jz NOSVM
    CPU_Info(#SVM)\Color = $008800
!NOSVM:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit21]      ;TBM
    !jz NOTBM
    CPU_Info(#TBM)\Color = $008800
!NOTBM:
    !mov ecx,[v_SichECX]
    !test ecx,[v_Bit11]      ;XOP
    !jz NOXOP
    CPU_Info(#XOP)\Color = $008800
!NOXOP:
    !cmp [v_MaxIDExt],80000008h
    !jb NOAMD
    !mov eax,80000008h
    !cpuid 
    !test ebx,[v_Bit0]       ;CLZERO
    !jz NOAMD
    CPU_Info(#CLZERO)\Color = $008800

!NOAMD:
    !mov ecx,[v_SichECX]     ;noch von oben
    !test ecx,[v_Bit5]       ;LZCNT
    !jz NOLZCNT
    CPU_Info(#LZCNT)\Color = $008800
!NOLZCNT:
    !mov edx,[v_SichEDX]
    !test edx,[v_Bit27]      ;RDTSCP
    !jz NOEXTE
    CPU_Info(#RDTSCP)\Color = $008800
!NOEXTE: 

  j = 0
  X = 10
  Y = 18                     ;1.Row
  For i = 0 To #PB_Compiler_EnumerationValue - 1
    TextGadget(i, X, Y, CPU_Info(j)\Pixel, 15, CPU_Info(j)\Feature)  
    SetGadgetColor(i, #PB_Gadget_FrontColor, CPU_Info(j)\Color) 
    SetGadgetFont(i, FontID(0))
    X + 7 + CPU_Info(j)\Pixel
    If X > 970 And Y = 18
      X = 10
      Y = 33                 ;2.Row
      FZ1 = i                ;Feature-Counter Row 1
     ElseIf X > 970 And Y = 33
      X = 10
      Y = 48                 ;3.Row
      FZ2 = i                ;Feature-Counter Row 1+2
    EndIf
    j + 1
  Next 
  FZ3 = i - 1                ;Feature-Counter Row 1+2+3

  TextGadget(#PB_Compiler_EnumerationValue, 10, 2, 380, 15, "CPU : " + LTrim(PeekS(ProzessorString, #PB_Any, #PB_Ascii))) 
  Select OSVersion()         ;simple Info; or compl. Windows-OSVersion()
    Case #PB_OS_Windows_2000
      OS$ = "Windows_2000"   
    Case #PB_OS_Windows_XP
      OS$ = "Windows_XP"
    Case #PB_OS_Windows_7
      OS$ = "Windows_7"
    Case #PB_OS_Windows_8
      OS$ = "Windows_8"   
    Case #PB_OS_Windows_8_1
      OS$ = "Windows_8_1"
    Case #PB_OS_Windows_10
      OS$ = "Windows_10"
  EndSelect
  TextGadget(#PB_Compiler_EnumerationValue + 1, 390, 2, 390, 15, "OS : " + OS$)
                                                                             
  TextGadget(#PB_Compiler_EnumerationValue + 2, 620, 2, 80, 15, "Red : CPU No")
  TextGadget(#PB_Compiler_EnumerationValue + 3, 720, 2, 140, 15, "Green : CPU Yes, OS Yes")
  TextGadget(#PB_Compiler_EnumerationValue + 4, 880, 2, 130, 15, "Blue : CPU Yes, OS No")    

  TextGadget(#PB_Compiler_EnumerationValue + 5, 10, 63, 70, 15, "x87-State")
  TextGadget(#PB_Compiler_EnumerationValue + 6, 80, 63, 75, 15, "SSE-State")
  TextGadget(#PB_Compiler_EnumerationValue + 7, 150, 63, 75, 15, "AVX-State")

  For i = #PB_Compiler_EnumerationValue To #PB_Compiler_EnumerationValue + 7
    SetGadgetFont(i, FontID(0))   
  Next    
  SetGadgetColor(#PB_Compiler_EnumerationValue + 2, #PB_Gadget_FrontColor, $0000D0)
  SetGadgetColor(#PB_Compiler_EnumerationValue + 3, #PB_Gadget_FrontColor, $008800)
  SetGadgetColor(#PB_Compiler_EnumerationValue + 4, #PB_Gadget_FrontColor, $FF0000)
  SetGadgetColor(#PB_Compiler_EnumerationValue + 5, #PB_Gadget_FrontColor, $008800) ;sollte immer gesetzt sein
  SetGadgetColor(#PB_Compiler_EnumerationValue + 6, #PB_Gadget_FrontColor, $0000D0)
  SetGadgetColor(#PB_Compiler_EnumerationValue + 7, #PB_Gadget_FrontColor, $0000D0)

  If CPU_Info(#OSXSAVE)\Color = $008800     ;OSXSAVE available 
    !xor ecx,ecx
    !xgetbv                  ;read XCR0 
    !test eax,[v_Bit1] 
    !jz NO_SSE_STATE         ;without SSE no AVX
    !mov [v_SichEAX],eax
    SetGadgetColor(#PB_Compiler_EnumerationValue + 6, #PB_Gadget_FrontColor, $008800)
    !mov eax,[v_SichEAX]
    !test eax,[v_Bit2] 
    !jz NO_SSE_STATE
    SetGadgetColor(#PB_Compiler_EnumerationValue + 7, #PB_Gadget_FrontColor, $008800)  
  !NO_SSE_STATE:
  EndIf

EndProcedure  

If OpenWindow(0, 0, 0, 1020, 100, "Helles CPU-Info, for more Instruction-Set-Infos use the left Mouse-Button!", #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
  FontHigh = Int(9.0 / (GetDeviceCaps_(GetDC_(WindowID(0)), #LOGPIXELSY) / 96.0)) 
  LoadFont(0, "Trebuchet MS Fett", FontHigh)     ;available in Windows 7; Test!
  CPUID_Info()
  Repeat   
    Select WaitWindowEvent() 
      Case #WM_LBUTTONDOWN, #PB_Event_MoveWindow, #PB_Event_DeactivateWindow      
        If CPUInfo
          DestroyWindow_(CPUInfo)
          Title$ = ""
        EndIf
        If WindowMouseY(0) >= 21 And WindowMouseY(0) <= 30 And GetActiveWindow() = 0     ;1.Row   18 bis 33  oben und unten 3 Pixel weg
          If WindowMouseX(0) >= 10 And WindowMouseX(0) <= 1010
            X = WindowMouseX(0)
            XX = 10
            For i = 0 To FZ1
              XX + CPU_Info(i)\Pixel
              If X - 3 < XX
                Title$ = CPU_Info(i)\Feature
                Text$ = CPU_Info(i)\Info
                Break
              EndIf
              XX + 7              
            Next
          EndIf
         ElseIf WindowMouseY(0) >= 36 And WindowMouseY(0) <= 45 And GetActiveWindow() = 0     ;2.Row   33 bis 48  oben und unten 3 Pixel weg
          If WindowMouseX(0) >= 10 And WindowMouseX(0) <= 1010
            X = WindowMouseX(0)
            XX = 10
            For i = FZ1 + 1 To FZ2
              XX + CPU_Info(i)\Pixel
              If X - 3 < XX
                Title$ = CPU_Info(i)\Feature
                Text$ = CPU_Info(i)\Info
                Break
              EndIf
              XX + 7
            Next
          EndIf
         ElseIf WindowMouseY(0) >= 51 And WindowMouseY(0) <= 60 And GetActiveWindow() = 0     ;3.Row   48 bis 63  oben und unten 3 Pixel weg
          If WindowMouseX(0) >= 10 And WindowMouseX(0) <= 1010
            X = WindowMouseX(0)
            XX = 10
            For i = FZ2 + 1 To FZ3
              XX + CPU_Info(i)\Pixel
              If X - 3 < XX
                Title$ = CPU_Info(i)\Feature
                Text$ = CPU_Info(i)\Info
                Break
              EndIf
              XX + 7
            Next
          EndIf
        EndIf
        If Title$ <> ""
          CPUInfo(Title$, Text$)
        EndIf
      Case #PB_Event_CloseWindow 
        FreeMemory(ProzessorString)
        Break
    EndSelect
  ForEver
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 790
; FirstLine = 637
; Folding = -
; EnableXP