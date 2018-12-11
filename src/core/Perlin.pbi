XIncludeFile "Math.pbi"

; ============================================================================================
; PERLIN NOISE MODULE DECLARATION
; 
; https://www.scratchapixel.com/code.php?id=57&origin=/lessons/procedural-generation-virtual-worlds/perlin-noise-part-2
; ============================================================================================
DeclareModule PerlinNoise
  UseModule Math
  #TABLE_SIZE = 256
  #TABLE_SIZE_MASK = #TABLE_SIZE - 1
  
  Structure PerlinNoise_t
    seed.i
    gradients.v3f32[#TABLE_SIZE]
    permutations.i[#TABLE_SIZE * 2]
  EndStructure
  
  Macro HASH(_x, _y, _z)  
    (*Me\permutations[*Me\permutations[*Me\permutations[(_x)] + (_y)] + (_z)])
  EndMacro
  
  Macro GRADIENTDOTV( _io, _perm, _x, _y, _z) 
    Select (_perm & 15)
        Case  0: _io =  _x + _y; // (1,1,0) 
        Case  1: _io = -_x + _y; // (-1,1,0) 
        Case  2: _io =  _x - _y; // (1,-1,0) 
        Case  3: _io = -_x - _y; // (-1,-1,0) 
        Case  4: _io =  _x + _z; // (1,0,1) 
        Case  5: _io = -_x + _z; // (-1,0,1) 
        Case  6: _io =  _x - _z; // (1,0,-1) 
        Case  7: _io = -_x - _z; // (-1,0,-1) 
        Case  8: _io =  _y + _z; // (0,1,1), 
        Case  9: _io = -_y + _z; // (0,-1,1), 
        Case 10: _io =  _y - _z; // (0,1,-1), 
        Case 11: _io = -_y - _z; // (0,-1,-1) 
        Case 12: _io =  _y + _x; // (1,1,0) 
        Case 13: _io = -_x + _y; // (-1,1,0) 
        Case 14: _io = -_y + _z; // (0,-1,1) 
        Case 15: _io = -_y - _z; // (0,-1,-1) 
      EndSelect
    EndMacro

  Declare New(seed.i=0)
  Declare Delete(*Me.PerlinNoise_t)
  Declare Init(*Me.PerlinNoise_t)
  Declare.f Eval(*Me.PerlinNoise_t, *p.v3f32, *deriv.v3f32)
  
EndDeclareModule

; ============================================================================================
; PERLIN NOISE MODULE IMPLEMENTATION
; ============================================================================================
Module PerlinNoise
  
  ; ------------------------------------------------------------------------------------------
  ; INIT
  ; ------------------------------------------------------------------------------------------
  Procedure Init(*Me.PerlinNoise_t)
    Define i
    Define.f theta, phi, x, y, z
    
    RandomSeed(*Me\seed)
    For i=0 To #TABLE_SIZE - 1
      theta = ACos(Math::Random_Neg1_1())
      phi = 2 * Math::Random_0_1() * Math::#F32_PI
  
      x = Cos(phi) * Sin(theta) 
      y = Sin(phi) * Sin(theta)
      z = Cos(theta) 
      Vector3::Set(*Me\gradients[i],x, y, z)
      *Me\permutations[i] = i
    Next
    
    Define tmp
    Define idx
    For i=0 To #TABLE_SIZE - 1
      ; create permuation table
      tmp = *Me\permutations[i]
      idx = Random(Math::#U32_MAX) & #TABLE_SIZE_MASK
      *Me\permutations[i] = *Me\permutations[idx]
      *Me\permutations[idx] = tmp
      
      ; extend permutation table in index range [256:512]
      *Me\permutations[#TABLE_SIZE+i] = *Me\permutations[i]
    Next
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; EVAL
  ; ------------------------------------------------------------------------------------------
  Procedure.f Eval(*Me.PerlinNoise_t, *p.v3f32, *deriv.v3f32) 
    Define.i xi0, yi0, zi0
    Define.i xi1, yi1, zi1
    xi0 = (Int(Round(*p\x, #PB_Round_Down))) & #TABLE_SIZE_MASK
    yi0 = (Int(Round(*p\y, #PB_Round_Down))) & #TABLE_SIZE_MASK
    zi0 = (Int(Round(*p\z, #PB_Round_Down))) & #TABLE_SIZE_MASK
    
    xi1 = (xi0 + 1) & #TABLE_SIZE_MASK
    yi1 = (yi0 + 1) & #TABLE_SIZE_MASK
    zi1 = (zi0 + 1) & #TABLE_SIZE_MASK
    
    Define.f tx, ty, tz
    tx = *p\x - Round(*p\x, #PB_Round_Down)
    ty = *p\y - Round(*p\y, #PB_Round_Down)
    tz = *p\z - Round(*p\z, #PB_Round_Down)
    
    Define.f u, v, w
    u = Math::QUINTIC(tx)
    v = Math::QUINTIC(ty)
    w = Math::QUINTIC(tz)
 
 
    ;generate vectors going from the grid points To p
    Define.f x0, x1, y0, y1, z0, z1
    x0 = tx : x1 = tx - 1
    y0 = ty : y1 = ty - 1
    z0 = tz : z1 = tz - 1
    
    Define.f a, b, c, d, e, f, g, h
    GRADIENTDOTV(a,HASH(xi0, yi0, zi0), x0, y0, z0)
    GRADIENTDOTV(b,HASH(xi1, yi0, zi0), x1, y0, z0)
    GRADIENTDOTV(c,HASH(xi0, yi1, zi0), x0, y1, z0)
    GRADIENTDOTV(d,HASH(xi1, yi1, zi0), x1, y1, z0)
    GRADIENTDOTV(e,HASH(xi0, yi0, zi1), x0, y0, z1)
    GRADIENTDOTV(f,HASH(xi1, yi0, zi1), x1, y0, z1)
    GRADIENTDOTV(g,HASH(xi0, yi1, zi1), x0, y1, z1)
    GRADIENTDOTV(h,HASH(xi1, yi1, zi1), x1, y1, z1)
    
    Define.f du, dv, dw
    du = Math::QUINTICDERIV(tx)
    dv = Math::QUINTICDERIV(ty)
    dw = Math::QUINTICDERIV(tz)
    
    Define.f k0, k1, k2, k3, k4, k5, k6, k7
    k0 = a
    k1 = (b - a)
    k2 = (c - a) 
    k3 = (e - a)
    k4 = (a + d - b - c)
    k5 = (a + f - b - e)
    k6 = (a + g - c - e)
    k7 = (b + c + e + h - a - d - f - g) 
 
    *deriv\x = du *(k1 + k4 * v + k5 * w + k7 * v * w)
    *deriv\y = dv *(k2 + k4 * u + k6 * w + k7 * v * w)
    *deriv\z = dw *(k3 + k5 * u + k6 * v + k7 * v * w)
 
    ProcedureReturn k0 + k1 * u + k2 * v + k3 * w + k4 * u * v + k5 * u * w + k6 * v * w + k7 * u * v * w
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; CONSTRUCTOR
  ; ------------------------------------------------------------------------------------------
  Procedure New(seed.i=0)
    Protected *Me.PerlinNoise_t = AllocateMemory(SizeOf(PerlinNoise_t))
    InitializeStructure(*Me, PerlinNoise_t)
    *Me\seed = seed
    Init(*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------
  ; DESTRUCTOR
  ; ------------------------------------------------------------------------------------------
  Procedure Delete(*Me.PerlinNoise_t)
    ClearStructure(*Me, PerlinNoise_t)
    FreeMemory(*Me)
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 73
; FirstLine = 54
; Folding = --
; EnableXP