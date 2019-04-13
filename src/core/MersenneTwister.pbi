; ============================================================================
; RandMT - Mersenne Twister Random Number Generator
; ----------------------------------------------------------------------------
; 
; The Mersenne Twister is an algorithm for generating random numbers.  It
; was designed with consideration of the flaws in various other generators.
; The period, 2^19937-1, and the order of equidistribution, 623 dimensions,
; are far greater.  The generator is also fast; it avoids multiplication and
; division, and it benefits from caches and pipelines.  For more information
; see the inventors' web page at
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
; 
; Reference:
; M. Matsumoto and T. Nishimura, "Mersenne Twister: A 623-Dimensionally
; Equidistributed Uniform Pseudo-Random Number Generator", ACM Transactions on
; Modeling and Computer Simulation, Vol. 8, No. 1, January 1998, pp 3-30.
; ============================================================================

; ============================================================================
;- Class (CRandMT)
; ============================================================================
;{
; ----------------------------------------------------------------------------
;- Public
; ----------------------------------------------------------------------------
;{
DeclareModule CRandMT
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Interface
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Interface Instance
    ; ...[ Object ]...........................................................
    Delete()
    ; ...[ Seeds ]............................................................
     ; Reseeds generator.
    Reseed( seed.l )
    ; Similar to *Reseed() but more seeds are used.
    Reseed2( *seed.Long, seedlen.l )
    ; Similar to *Reseed() function but seed is chosen automatically from
    ; /dev/urandom if available or from time() and clock().
    ReseedAuto()
    ; ...[ Generate ].........................................................
    ; Returns randomly generated number in range [from, upto).
    Rand         .d ( from.d, upto.d )
    ; Returns number between [0-1) real interval.
    Rand01       .d (                )
    ; Returns number between [0-1] real interval.
    Rand01Closed .d (                )
    ; Returns number between (0-1) real interval.
    Rand01Open   .d (                )
    ; Returns number between [0-1) real interval with 53-bit resolution.
    Rand01_53    .d (                )
    ; Returns random integer number in interval [0, 2^32-1].
    RandInt      .l (                )
    ; Returns number from a normal (Gaussian) distribution.
    RandNormal   .d (                )
  EndInterface
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Constructors
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Declare.i New( seed.l )
  Declare.i New2( *seed.Long, seedlen.l )
  Declare.i NewAuto()
EndDeclareModule
;}
; ----------------------------------------------------------------------------
;- Private
; ----------------------------------------------------------------------------
;{
Module CRandMT
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Constants
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  #BOR_RAND_MT_N = 624 ; Length of state vector
  #BOR_RAND_MT_M = 397 ; Period
  #MmN           = #BOR_RAND_MT_M - #BOR_RAND_MT_N
  #S32_MAX       = 2147483647
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Structures
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  Structure Longs
    l.l[0]
  EndStructure
  Structure big_seed_t
    l.l[#BOR_RAND_MT_N]
  EndStructure
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Instance
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  Structure Instance_t
    *vtable
    state .l[#BOR_RAND_MT_N] ; Internal state
    *next .Long              ; Next value from state[]
    left  .l                 ; Number of values left before reload needed
  EndStructure
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Macros (Private)
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  Macro hiBit( u_ )
    ( u & $80000000 )
  EndMacro
  Macro loBit( u_ )
    ( u & $00000001 )
  EndMacro
  Macro loBits( u_ )
    ( u & $7fffffff )
  EndMacro
  Macro mixBits( u_, v_ )
    ( hiBit(u_) | loBits(v_) )
  EndMacro
  Macro twist( m_, s0_, s1_ )
    ( m_ ! (mixBits(s0, s1) >> 1) ! magic(s1) )
  EndMacro
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Implementation (Private)
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  Procedure.q BOR_MAX( x.q, y.q )
    If x > y
      ProcedureReturn x
    Else
      ProcedureReturn y
    EndIf
  EndProcedure
  Procedure.q magic( u.q )
    ; loBit(u) ? 0x9908b0dfUL : 0x0UL
    If loBit(u)
      ProcedureReturn $9908b0df
    Else
      ProcedureReturn $0
    EndIf
  EndProcedure
  Procedure Init( *Me.Instance_t, seed.q )
    ; Initialize generator state with seed
    ; See Knuth TAOCP Vol 2, 3rd Ed, p.106 for multiplier.
    ; In previous versions, most significant bits (MSBs) of the seed affect
    ; only MSBs of the state array.  Modified 9 Jan 2002 by Makoto Matsumoto.
    
    ; ---[ Local Variables ]--------------------------------------------------
    Protected i.l=1,j.l=0,q.q
    
    ; ---[ Init ]-------------------------------------------------------------
    *Me\state[0] = seed & $ffffffff
    While i < #BOR_RAND_MT_N
      *Me\state[i] = ( 1812433253*( *Me\state[j] ! (*Me\state[j] >> 30) ) + i ) & $ffffffff
       i + 1 : j + 1
    Wend
    
  EndProcedure
  Procedure Reload( *Me.Instance_t )
    ; Generate N new values in state
    ; Made clearer and faster by Matthew Bellew (matthew.bellew@home.com)
    
    ; ---[ Local Variables ]--------------------------------------------------
    Protected *p .Long  = @*Me\state[0]
    Protected *p_.Longs = *p
    Protected  i.l
    
    ; ---[ Reload ]-----------------------------------------------------------
    i = #BOR_RAND_MT_N - #BOR_RAND_MT_M
    While i >= 0
      *p\l = twist( *p_\l[#BOR_RAND_MT_M], *p_\l[0], *p_\l[1] )
      i - 1 : *p  + SizeOf(Long) : *p_ = *p
    Wend
    i = #BOR_RAND_MT_M
    While i > 0
      *p\l = twist( *p_\l[#MmN], *p_\l[0], *p_\l[1] )
      i - 1 : *p  + SizeOf(Long) : *p_ = *p
    Wend
    *p\l = twist( *p_\l[#MmN], *p_\l[0], *Me\state[0] )
    
    *Me\left = #BOR_RAND_MT_N
    *Me\next = @*Me\state[0]

  EndProcedure
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Implementation
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  ; ~~~[ Object ]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Procedure Delete( *Me.Instance_t )
    
    ; ---[ Release Instance ]-------------------------------------------------
    FreeMemory(*Me)
    
  EndProcedure
  ; ~~~[ Seeds ]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Procedure Reseed( *Me.Instance_t, seed.l )
    
    Init  ( *Me, seed )
    Reload( *Me )
    
  EndProcedure
  Procedure Reseed2( *Me.Instance_t, *seed.Long, seedlen.l )
    
    ; Seed the generator with an array of uint32's.
    ; There are 2^19937-1 possible initial states. This function allows
    ; all of those to be accessed by providing at least 19937 bits (with a
    ; default seed length of N = 624 uint32's). Any bits above the lower 32
    ; in each element are discarded.
    
    ; ---[ Local Variables ]--------------------------------------------------
    Protected i.l=1,j.l=0,k.l=BOR_MAX(#BOR_RAND_MT_N,seedlen)
    Protected *seed_.Longs = *seed
    
    Init( *Me, 19650218 )
    
    While k
      *Me\state[i] ! ( ( *Me\state[i-1] ! ( *Me\state[i-1] >> 30 ) )*1664525 )
      *Me\state[i] + ( ( *seed_\l[j] & $ffffffff ) + j )
      *Me\state[i] & $ffffffff
      i + 1
      j + 1
      If i >= #BOR_RAND_MT_N
        *Me\state[0] = *Me\state[#BOR_RAND_MT_N - 1]
        i = 1
      EndIf
      If j >= seedlen
        j = 0
      EndIf
      k - 1
    Wend
    
    k = #BOR_RAND_MT_N - 1
    While k
      *Me\state[i] ! ( ( *Me\state[i-1] ! ( *Me\state[i-1] >> 30 ) )*1566083941 )
      *Me\state[i] - i
      *Me\state[i] & $ffffffff
      i + 1
      If i >= #BOR_RAND_MT_N
        *Me\state[0] = *Me\state[#BOR_RAND_MT_N - 1]
        i = 1
      EndIf
      k - 1
    Wend
    
    *Me\state[0] = $80000000 ; MSB is 1, assuring non-zero initial array.

    Reload( *Me )
    
  EndProcedure
  Procedure ReseedAuto( *Me.Instance_t )
    
    ; ---[ Local Variables ]--------------------------------------------------
    Protected bigSeed.big_seed_t,i.l=#BOR_RAND_MT_N
    
    ; ---[ Generate Big Seed ]------------------------------------------------
    While i > 0
      i - 1
      bigSeed\l[i] = Random(#S32_MAX,0)
    Wend
    
    ; ---[ Reseed ]-----------------------------------------------------------
    Reseed2( *Me, @bigSeed\l[0], #BOR_RAND_MT_N )
    
  EndProcedure
  ; ~~~[ Generate ]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Procedure.d Rand( *Me.Instance_t, from.d, upto.d )
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Generate ]---------------------------------------------------------
    Protected val.d = Me\Rand01()
    val * ( upto - from )
    val + from
    ProcedureReturn val
    
  EndProcedure
  Procedure.d Rand01( *Me.Instance_t )
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Generate ]---------------------------------------------------------
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ProcedureReturn Me\RandInt()*(1.0/4294967296.0)+0.5
    CompilerElse
      ProcedureReturn Me\RandInt()*(1.0/4294967296.0)
    CompilerEndIf
    
  EndProcedure
  Procedure.d Rand01Closed( *Me.Instance_t )
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Generate ]---------------------------------------------------------
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ProcedureReturn Me\RandInt()*(1.0/4294967295.0)+0.5
    CompilerElse
      ProcedureReturn Me\RandInt()*(1.0/4294967295.0)
    CompilerEndIf
    
  EndProcedure
  Procedure.d Rand01Open( *Me.Instance_t )
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Generate ]---------------------------------------------------------
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ProcedureReturn ( Me\RandInt() + 0.5 )*(1.0/4294967296.0)+0.5
    CompilerElse
      ProcedureReturn ( Me\RandInt() + 0.5 )*(1.0/4294967296.0)
    CompilerEndIf
    
  EndProcedure
  Procedure.d Rand01_53( *Me.Instance_t )
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Generate ]---------------------------------------------------------
    Protected a.q = Me\RandInt() >> 5
    Protected b.q = Me\RandInt() >> 6
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      ProcedureReturn ( a*67108864.0 + b )*( 1.0/9007199254740992.0 )+0.5 ; by Isaku Wada
    CompilerElse
      ProcedureReturn ( a*67108864.0 + b )*( 1.0/9007199254740992.0 ) ; by Isaku Wada
    CompilerEndIf
    
  EndProcedure
  Procedure.q RandInt( *Me.Instance_t )
    ; Pull a 32-bit integer from the generator state.
    ; Every other access function simply transforms the numbers extracted here.
    
    ; ---[ Local Variable ]---------------------------------------------------
    Protected s1.q
    
    ; ---[ Check Reload ]-----------------------------------------------------
    If *Me\left = 0
      Reload( *Me )
    EndIf
    *Me\left - 1
    
    ; ---[ Generate ]---------------------------------------------------------
    s1 = *Me\next\l : *Me\next + SizeOf(Long)
    s1 ! (  s1 >> 11 )
    s1 ! ( (s1 <<  7) & $9d2c5680 )
    s1 ! ( (s1 << 15) & $efc60000 )
    s1 ! (  s1 >> 18 )
    ProcedureReturn s1
    
  EndProcedure
  Procedure.d RandNormal( *Me.Instance_t, mean.d, stddev.d )
    ; Return a real number from a normal (Gaussian) distribution with given
    ; mean and standard deviation by polar form of Box-Muller transformation.
    
    ; ---[ Retrieve Interface ]-----------------------------------------------
    Protected Me.Instance = *Me
    
    ; ---[ Local Variables ]--------------------------------------------------
    Protected x.d,y.d,r.d,s.d
    
    ; ---[ Generate ]---------------------------------------------------------
    Repeat
      x = 2.0*Me\Rand01() - 1.0
      y = 2.0*Me\Rand01() - 1.0
      r = x*x + y*y
    Until r < 1.0 And r <> 0.0
    s = Sqr( -2.0 * Log(r) / r )
    ProcedureReturn mean + x*s*stddev
    
  EndProcedure
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  VTable
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  DataSection
    VRandMT:
    ; ---[ Object ]-----------------------------------------------------------
    Data.i @Delete()
    ; ---[ Seeds ]------------------------------------------------------------
    Data.i @Reseed()
    Data.i @Reseed2()
    Data.i @ReseedAuto()
    ; ---[ Generate ]---------------------------------------------------------
    Data.i @Rand()
    Data.i @Rand01()
    Data.i @Rand01Closed()
    Data.i @Rand01Open()
    Data.i @Rand01_53()
    Data.i @RandInt()
    Data.i @RandNormal()
  EndDataSection
  ;}
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;  Constructors
  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;{
  Procedure.i Nes( *Me.Instance_t, seed.l )
    
    ; ---[ Sanity Check ]-----------------------------------------------------
    If #Null = *Me : ProcedureReturn #Null : EndIf
    
    ; ---[ Init VTable ]------------------------------------------------------
    *Me\vtable = ?VRandMT
    
    ; ---[ Set Members ]------------------------------------------------------
    Reseed( *Me, seed )
    
    ; ---[ Return Initialized Object ]----------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Procedure.i New( seed.l )
    
    ; ---[ Allocate Instance Memory ]-----------------------------------------
    Protected *p.Instance_t = AllocateMemory(SizeOf(Instance_t))
    
    ; ---[ Init Instance ]----------------------------------------------------
    ProcedureReturn Nes( *p, seed )
    
  EndProcedure
  Procedure.i Nes2( *Me.Instance_t, *seed.Long, seedlen.l )
    
    ; ---[ Sanity Check ]-----------------------------------------------------
    If #Null = *Me : ProcedureReturn #Null : EndIf
    
    ; ---[ Init VTable ]------------------------------------------------------
    *Me\vtable = ?VRandMT
    
    ; ---[ Set Members ]------------------------------------------------------
    Reseed2( *Me, *seed, seedlen )
    
    ; ---[ Return Initialized Object ]----------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Procedure.i New2( *seed.Long, seedlen.l )
    
    ; ---[ Allocate Instance Memory ]-----------------------------------------
    Protected *p.Instance_t = AllocateMemory(SizeOf(Instance_t))
    
    ; ---[ Init Instance ]----------------------------------------------------
    ProcedureReturn Nes2( *p, *seed, seedlen )
    
  EndProcedure
  Procedure.i NesAuto( *Me.Instance_t )
    
    ; ---[ Sanity Check ]-----------------------------------------------------
    If #Null = *Me : ProcedureReturn #Null : EndIf
    
    ; ---[ Init VTable ]------------------------------------------------------
    *Me\vtable = ?VRandMT
    
    ; ---[ Set Members ]------------------------------------------------------
    ReseedAuto( *Me )
    
    ; ---[ Return Initialized Object ]----------------------------------------
    ProcedureReturn *Me
    
  EndProcedure
  Procedure.i NewAuto()
    
    ; ---[ Allocate Instance Memory ]-----------------------------------------
    Protected *p.Instance_t = AllocateMemory(SizeOf(Instance_t))
    
    ; ---[ Init Instance ]----------------------------------------------------
    ProcedureReturn NesAuto( *p )
    
  EndProcedure
  ;}
EndModule
;}
;}

; ============================================================================
;- TEST CODE (Mainfile)
; ============================================================================
;{
CompilerIf #PB_Compiler_IsMainFile
  
  Procedure.q getULong( *source.Long )
    ; from: http://code.google.com/p/purebasic-extension-for-adobe-air/source/browse/trunk/pureair/native/src/Unsigned.pb
    ;- Reads 4 bytes from the specified memory address,
    ; and returns the value as *unsigned* integer
    ; (minimum = 0, maximum = 4294967295).
    If *source\l < 0
      ProcedureReturn *source\l + $100000000
    Else
      ProcedureReturn *source\l
    EndIf
  EndProcedure
  Procedure.q fromULong( source.l )
    ; ; from: http://code.google.com/p/purebasic-extension-for-adobe-air/source/browse/trunk/pureair/native/src/Unsigned.pb
    ProcedureReturn getULong(@source)
  EndProcedure

  Procedure test( r.CRandMT::Instance )
    Protected i
    
    ;Debug "    Generate 10 numbers in [0,1):"
    ;For i=0 To 9
      ;Debug " "+StrD(r\Rand01())
    ;Next
    ;Debug ""
    
    Debug "    Generate 10 numbers in [0,1]:"
    For i=0 To 9
      Debug " "+StrD(r\Rand01Closed())
    Next
    Debug ""
    
    ;Debug "    Generate 10 numbers in (0,1):"
    ;For i=0 To 9
      ;Debug " "+StrD(r\Rand01Open())
    ;Next
    ;Debug ""
    
    Debug "    Generate 5 integers in:"
    For i=0 To 4
      Debug " "+StrU(fromULong(r\RandInt()))
    Next
    Debug ""
    
    ;Debug "    Generate 10 numbers in [0,1.5):"
    ;For i=0 To 9
      ;Debug " "+StrD(r\Rand(0.0,1.5))
    ;Next
    ;Debug ""
    
    ;Debug "    Generate 10 numbers in [1.1,1.2):"
    ;For i=0 To 9
      ;Debug " "+StrD(r\Rand(1.1,1.2))
    ;Next
    ;Debug ""
    
    ;Debug "    Generate 10 numbers in [-0.5,0.2):"
    ;For i=0 To 9
      ;Debug " "+StrD(r\Rand(-0.5,0.2))
    ;Next
    ;Debug ""
    
  EndProcedure
  
  Global rmt.CRandMT::Instance
  
  rmt = CRandMT::NewAuto()
  Global rMax.d = 0.0
  Global rMin.d = 1.0
  Global i.l,rr.d
  For i = 0 To 6294
    rr = rmt\Rand01()
    If rr > rMax : rMax = rr : EndIf
    If rr < rMin : rMin = rr : EndIf
  Next
  Debug "rMax: "+ StrD(rMax)
  Debug "rMin: "+ StrD(rMin)
  rmt\Delete()
  
  Debug "Auto:"
  rmt = CRandMT::NewAuto()
  test( rmt )
  rmt\Delete()
  
  Debug "7654:"
  rmt = CRandMT::New(7654)
  test( rmt )
  rmt\Delete()
  
  Debug "1111:"
  rmt = CRandMT::New(1111)
  test( rmt )
  
  Debug "1111 -> 2222:"
  rmt\Reseed(2222)
  test( rmt )
  
  Debug "2222 -> auto:"
  rmt\ReseedAuto()
  test( rmt )
  rmt\Delete()

CompilerEndIf
;}

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 17
; FirstLine = 13
; Folding = ---------
; EnableXP