; ------------------------------------------------------------------------------
; https://www.scratchapixel.com/code.php?id=55&origin=/lessons/procedural-generation-virtual-worlds/procedural-patterns-noise-part-1
; ------------------------------------------------------------------------------
XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"
; ============================================================================================
; NOISE MODULE DECLARATION
; ============================================================================================
DeclareModule Noise
  UseModule Math
  #TABLE_SIZE = 256
  #TABLE_SIZE_MASK = #TABLE_SIZE - 1
  
  Enumeration
    #WHITE_NOISE
    #VALUE_NOISE
    #FRACTAL_PATTERN
    #TURBULENCE_PATTERN
    #MARBLE_PATTERN
    #WOOD_PATTERN
  EndEnumeration
  
  Structure Noise_t
    seed.i
    mode.i
    r.f[#TABLE_SIZE]
    permutations.i[#TABLE_SIZE * 2]
  EndStructure
  
  Declare New(seed.i=0, mode.i=#WHITE_NOISE)
  Declare Delete(*Me.Noise_t)
  Declare Init(*Me.Noise_t)
  Declare.f Eval(*Me.Noise_t, *input.CArray::CArrayV3F32, *output.CArray::CArrayV3F32) 
EndDeclareModule

; ============================================================================================
; NOISE MODULE IMPLEMENTATION
; ============================================================================================
Module Noise
  
  ; ------------------------------------------------------------------------------------------
  ; INIT
  ; ------------------------------------------------------------------------------------------
  Procedure Init(*Me.Noise_t)
    RandomSeed(*Me\seed)
    Define k
    ; create an Array of random values And initialize permutation table
    For k = 0 To #TABLE_SIZE - 1 
        *Me\r[k] = Math::Random_0_1()
        *Me\permutations[k] = k
    Next

    ; shuffle values of the permutation table
    Define i, tmp
    For  k = 0 To #TABLE_SIZE - 1
      i = Random(Math::#U32_MAX) & #TABLE_SIZE_MASK
      unsigned i = randUInt() & kMaxTableSizeMask
      tmp = *Me\permutations[i]
      *Me\permutations[i] = *Me\permutations[k]
      *Me\permutations[k] = tmp
      *Me\permutations[k+#TABLE_SIZE] = *Me\permutations[k]
    Next
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; CORE EVAL
  ; ------------------------------------------------------------------------------------------
  Procedure.f CoreEval(*Me.Noise_t, *p.v3f32) 
    Define xi, yi, zi
    xi = Int(Round(*p\x, #PB_Round_Down)) 
    yi = Int(Round(*p\y, #PB_Round_Down)) 
    zi = Int(Round(*p\z, #PB_Round_Down)) 

    Define.f tx, ty, tz
    tx = *p\x - xi
    ty = *p\y - yi
    tz = *p\z - zi
    
    Define rx0, rx1, ry0, ry1, rz0, rz1
    rx0 = xi & #TABLE_SIZE_MASK
    rx1 = (rx0 + 1) & #TABLE_SIZE_MASK
    ry0 = yi & #TABLE_SIZE_MASK
    ry1 = (ry0 + 1) & #TABLE_SIZE_MASK
    rz0 = zi & #TABLE_SIZE_MASK
    rz1 = (rz0 + 1) & #TABLE_SIZE_MASK
 
    ; random values at the corners of the cell using permutation table
    Define.f c00, c10, c01, c11
    c00 = *Me\r[*Me\permutations[*Me\permutations[rx0] + ry0]]
    c10 = *Me\r[*Me\permutations[*Me\permutations[rx1] + ry0]]
    c01 = *Me\r[*Me\permutations[*Me\permutations[rx0] + ry1]]
    c11 = *Me\r[*Me\permutations[*Me\permutations[rx1] + ry1]]

    ; remapping of tx And ty using the Smoothstep function
    Define.f sx, sy, sz
    sx = Math::SMOOTHSTEP(tx)
    sy = Math::SMOOTHSTEP(ty)

    ; linearly interpolate values along the x axis
    Define.f nx0, nx1
    nx0 = Math::LINEAR_INTERPOLATE(c00, c10, sx)
    nx1 = Math::LINEAR_INTERPOLATE(c01, c11, sx)

    ; linearly interpolate the nx0/nx1 along they y axis
    ProcedureReturn Math::LINEAR_INTERPOLATE(nx0, nx1, sy)
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; EVAL
  ; ------------------------------------------------------------------------------------------
  Procedure.f Eval(*Me.Noise_t, *input.CArray::CArrayV3F32, *output.CArray::CArrayV3F32) 
    CArray::SetCount(*output, *input\itemCount)
    Define k
    Define v.f
    Define *v.v3f32
    Select *Me\mode
      Case #WHITE_NOISE
        Define k
        RandomSeed(*Me\seed)
        For k = 0 To CArray::GetCount(*input) - 1
          *v = CArray::GetValue(*output, k)
          Vector3::Reset(*v)
          Vector3::RandomizeInPlace(*v)
        Next

      Case #VALUE_NOISE
        Define frequency.f = 0.05
        For k=0 To *input\itemCount - 1
          v = CoreEval(*Me,
;         ValueNoise noise; 
;     float frequency = 0.05f; 
;     For (unsigned j = 0; j < imageHeight; ++j) { 
;         For (unsigned i = 0; i < imageWidth; ++i) { 
;             // generate a float in the range [0:1]
;             noiseMap[j * imageWidth + i] = noise.eval(Vec2f(i, j) * frequency); 
;         } 
;     } 
        
      Case #FRACTAL_PATTERN
        
      Case #TURBULENCE_PATTERN
        
      Case #MARBLE_PATTERN
        
      Case #WOOD_PATTERN
        
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ; ------------------------------------------------------------------------------------------
  Procedure New(seed.i=0, mode.i=#WHITE_NOISE)
    Protected *Me.Noise_t = AllocateMemory(SizeOf(Noise_t))
    InitializeStructure(*Me, Noise_t)
    *Me\seed = seed
    *Me\mode = mode
    Init(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; DESTRUCTOR
  ; ------------------------------------------------------------------------------------------
  Procedure Delete(*Me.Noise_t)
    ClearStructure(*Me, Noise_t)
    FreeMemory(*Me)
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 128
; FirstLine = 102
; Folding = --
; EnableXP