Enumeration 
  #fpu   ;Onboard x87 FPU   
  #vme   ;Virtual 8086 mode extensions (such As VIF, VIP, PIV)   
  #de     ;Debugging extensions (CR4 bit 3)   
  #pse   ;Page Size Extension   
  #tsc   ;Time Stamp Counter   
  #msr   ;Model-specific registers
  #pae   ;Physical Address Extension
  #mce   ;Machine Check Exception
  #cx8   ;CMPXCHG8 (compare-And-Swap) instruction   
  #apic   ;Onboard Advanced Programmable Interrupt Controller   
  #res10   ;(reserved)   
  #sep   ;SYSENTER And SYSEXIT instructions
  #mtrr   ;Memory Type Range Registers   
  #pge   ;Page Global Enable bit in CR4   
  #mca   ;Machine check architecture   
  #cmov   ;Conditional move And FCMOV instructions   
  #pat   ;Page Attribute Table   (reserved)
  #pse36;36-bit page size extension   
  #psn   ;Processor Serial Number   
  #clfsh   ;CLFLUSH instruction (SSE2)
  #res20   ;(reserved)   
  #ds   ;Debug store: save trace of executed jumps   
  #acpi   ;Onboard thermal control MSRs For ACPI   
  #mmx   ;MMX instructions   
  #fxsr   ;FXSAVE, FXRESTOR instructions, CR4 bit 9   
  #sse   ;SSE instructions (a.k.a. Katmai New Instructions)   
  #sse2   ;SSE2 instructions   
  #ss   ;CPU cache supports self-snoop   
  #htt   ;Hyper-threading   
  #tm   ;Thermal monitor automatically limits temperature
  #ia64   ;IA64 processor emulating x86   
  #pbe   ;Pending Break Enable (PBE# pin) wakeup support   
  ;ecx vals
  #sse3   ;Prescott New Instructions-SSE3 (PNI)
  #pclmulqdq   ;PCLMULQDQ support
  #dtes64   ;64-bit Debug store (edx bit 21)
  #monitor   ;MONITOR And MWAIT instructions (SSE3)
  #dscpl   ;CPL qualified Debug store
  #vmx   ;Virtual Machine eXtensions
  #smx   ;Safer Mode Extensions (LaGrande)
  #est   ;Enhanced SpeedStep
  #tm2   ;Thermal Monitor 2
  #ssse3   ;Supplemental SSE3 instructions
  #cnxtid   ;L1 Context ID
  #res11
  #fma   ;Fused multiply-add (FMA3)
  #cx16   ;CMPXCHG16B instruction
  #xtpr   ;Can disable sending task priority messages
  #pdcm   ;Perfmon & Debug capability
  #res16
  #pcid   ;Process context identifiers (CR4 bit 17)
  #dca   ;Direct cache access For DMA writes[10][11]
  #sse41   ;SSE4.1 instructions
  #sse42   ;SSE4.2 instructions
  #x2apic   ;x2APIC support
  #movbe   ;MOVBE instruction (big-endian)
  #popcnt   ;POPCNT instruction
  #tscdeadline   ;APIC supports one-shot operation using a TSC deadline value
  #aes   ;AES instruction set
  #xsave   ;XSAVE, XRESTOR, XSETBV, XGETBV
  #osxsave   ;XSAVE enabled by OS
  #avx   ;Advanced Vector Extensions
  #f16c   ;F16C (half-precision) FP support
  #rdrnd   ;RDRAND (on-chip random number generator) support
  #hypervisor   ;Running on a hypervisor (always 0 on a real CPU, but also With some hypervisors)
EndEnumeration 

Procedure IsCPU(op)
  Protected res,shift  
  shift = op % 32
  mask = (1 << shift)
  !mov eax,1
  !cpuid 
  If op < 31 
    !mov [p.v_res], edx 
  Else 
    !mov [p.v_res], ecx 
  EndIf   
  res & mask 
  ProcedureReturn res >> shift
EndProcedure 

Debug "MMX : " + Str(isCPU(#mmx))
Debug "SSE : "+Str(isCPU(#sse))
Debug "SSE2 : "+Str(isCPU(#sse2))
Debug "SSE3 : "+Str(isCPU(#sse3))
Debug "SSE41 : "+Str(isCPU(#sse41))
Debug "SSE42 : "+Str(isCPU(#sse42))
Debug "RES20 : "+Str(isCPU(#res20))
Debug "AVX : "+Str(IsCPU(#avx))
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 70
; FirstLine = 37
; Folding = -
; EnableXP