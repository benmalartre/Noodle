;===============================================================================
; Math Module Declaration(Shared)
;===============================================================================
DeclareModule Math
  
  ; ----------------------------------------------------------------------------
  ;  Limits
  ; ----------------------------------------------------------------------------
  #S8_MIN     = (-128)
  #S8_MAX     =   127
  #U8_MIN     =     0
  #U8_MAX     =   255
  
  ; ----[ INTEGER 16 ]----------------------------------------------------------
  #S16_MIN    = (-32768)
  #S16_MAX    =   32767
  #U16_MIN    =       0
  #U16_MAX    =   65535
  
  ; ----[ INTEGER 32 ]----------------------------------------------------------
  #S32_MIN    = (-2147483647-1 )
  #S32_MAX    =   2147483647
  #U32_MIN    =            0
  #U32_MAX    =   4294967295
  
  ; ----[ INTEGER 64 ]----------------------------------------------------------
  #S64_MIN    = (-9223372036854775807-1)
  #S64_MAX    =   9223372036854775807
  #U64_MIN    =                     0
  #U64_MAX    =  18446744073709551615
  
  ; ----[ INTEGERS ]------------------------------------------------------------
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    #U_MAX    = #U64_MAX
  CompilerElse
    #U_MAX    = #U32_MAX
  CompilerEndIf
  
  ; ----[ SCALARS 64 ]----------------------------------------------------------
  #F64_EPS      = 2e-16
  #F64_MAX      = 1.7976931348623158e+308
  #F64_MIN      = 2.2250738585072014e-308

  ; ----[ SCALARS 32 ]----------------------------------------------------------
  #F32_EPS      =  1e-6
  #F32_MAX      =  3.402823466e+38
  #F32_MIN      =  1.175494351e-38
  #F32_E        =  2.7182818              ; e
  #F32_LOG2E    =  1.4426950              ; log2(e)
  #F32_LOG10E   =  0.4342945              ; Log10(e)
  #F32_LN2      =  0.6931472              ; ln(2)
  #F32_LN10     =  2.3025851              ; ln(10)
  
  #F32_PI       =  3.1415926              ; pi
  #F32_2PI      =  6.2831853              ; 2*pi
  #F32_PI_2     =  1.5707963              ; pi/2
  #F32_PI_4     =  0.7853982              ; pi/4
  #F32_3PI_4    =  2.3561945              ; (3*pi)/4
  #F32_SQRTPI   =  1.7724538              ; sqrt(pi)
  #F32_2_SQRTPI =  1.1283792              ; 2/sqrt(pi)
  #F32_1_PI     =  0.3183099              ; 1/pi
  #F32_2_PI     =  0.6366198              ; 2/pi
  #F32_2_SQRTPI =  1.1283792              ; 2/sqrt(pi)
  
  #F32_SQRT2    =  1.4142136              ; sqrt(2)
  #F32_1_SQRT2  =  0.7071068              ; 1/sqrt(2)
  
  #F32_DEG2RAD  =  0.0174533              ; pi/180
  #F32_RAD2DEG  =  57.2957795             ; 180/pi
  
  #COLOR_MAX    =  16581375
  
  #MIN_VECTOR_LENGTH = 1e-10
  #MIN_ORTHO_TOLERANCE = 1e-6
  
  #RAND_MAX = 2147483647                ; according to help for Random()
  
  #ECHO_PRECISION = 9                   ; precison on debug string
  
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    DataSection
      CompilerIf #PB_Compiler_OS   = #PB_OS_MacOS
        ! align 16
      CompilerEndIf
      sse_0000_sign_mask:
      Data.l $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF
      sse_0001_sign_mask:
      Data.l $7FFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF
      sse_0010_sign_mask:
      Data.l $FFFFFFFF, $7FFFFFFF, $FFFFFFFF, $FFFFFFFF
      sse_0011_sign_mask:
      Data.l $7FFFFFFF, $7FFFFFFF, $FFFFFFFF, $FFFFFFFF
      sse_0100_sign_mask:
      Data.l $FFFFFFFF, $FFFFFFFF, $7FFFFFFF, $FFFFFFFF
      sse_0101_sign_mask:
      Data.l $7FFFFFFF, $FFFFFFFF, $7FFFFFFF, $FFFFFFFF
      sse_0110_sign_mask:
      Data.l $FFFFFFFF, $7FFFFFFF, $7FFFFFFF, $FFFFFFFF
      sse_0111_sign_mask:
      Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $FFFFFFFF
      sse_1000_sign_mask:
      Data.l $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $7FFFFFFF
      sse_1001_sign_mask:
      Data.l $7FFFFFFF, $FFFFFFFF, $FFFFFFFF, $7FFFFFFF
      sse_1010_sign_mask:
      Data.l $FFFFFFFF, $7FFFFFFF, $FFFFFFFF, $7FFFFFFF
      sse_1011_sign_mask:
      Data.l $7FFFFFFF, $7FFFFFFF, $FFFFFFFF, $7FFFFFFF
      sse_1100_sign_mask:
      Data.l $FFFFFFFF, $FFFFFFFF, $7FFFFFFF, $7FFFFFFF
      sse_1101_sign_mask:
      Data.l $7FFFFFFF, $FFFFFFFF, $7FFFFFFF, $7FFFFFFF
      sse_1110_sign_mask:
      Data.l $FFFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
      sse_1111_sign_mask:
      Data.l $7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF
      sse_1111_negate_mask:
      Data.f -1.0, -1.0, -1.0, -1.0
      sse_0101_negate_mask:
      Data.f 1.0, -1.0, 1.0, -1.0
      sse_1010_negate_mask:
      Data.f -1.0, 1.0, -1.0, 1.0
      sse_1100_negate_mask:
      Data.f -1.0, -1.0, 1.0, 1.0
      sse_1110_negate_mask:
      Data.f -1.0, -1.0, -1.0, 1.0
      sse_0001_negate_mask:
      Data.f 1.0, 1.0, 1.0, -1.0
      sse_0111_negate_mask:
      Data.f 1.0, -1.0, -1.0, -1.0
      sse_infinity_vec:
      Data.l $7F800000, $7F800000, $7F800000, $7F800000
      sse_zero_vec:
      Data.f 0.0, 0.0, 0.0, 0.0
      sse_one_vec:
      Data.f 1.0, 1.0, 1.0, 1.0
      sse_half_vec:
      Data.f 0.5, 0.5, 0.5, 0.5
      sse_onethird_vec:
      Data.f 0.333333333,0.333333333,0.333333333,0.333333333
      sse_minusone_vec:
      Data.f -1.0, -1.0, -1.0, -1.0
      sse_minushalf_vec:
      Data.f -0.5, -0.5, -0.5, -0.5
      sse_pi_vec:
      Data.f #F32_PI, #F32_PI, #F32_PI, #F32_PI
      sse_epsilon_vec:
      Data.f #F32_EPS, #F32_EPS, #F32_EPS, #F32_EPS
      sse_minusonei_vec:
      Data.l -1.0, -1.0, -1.0, -1.0
    EndDataSection
  CompilerEndIf
  

  ; ----------------------------------------------------------------------------
  ;  Maximum Macro
  ; ----------------------------------------------------------------------------
  Macro MAXIMUM(_a,_b)
    If _a<_b : _a=_b : EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Minimum Macro
  ; ----------------------------------------------------------------------------
  Macro MINIMUM(_a,_b)
    If _a>_b : _a=_b : EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Percentage Macro
  ; ----------------------------------------------------------------------------
  Macro PERCENTAGE(_x,_z)
    100 / _z * _x
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Clamp Macro
  ; ----------------------------------------------------------------------------
  Macro CLAMP(_x,_min,_max)
    If (_x<_min)
      _x = _min 
    ElseIf (_x>_max)
      _x=_max 
    EndIf
  EndMacro

  ; ----------------------------------------------------------------------------
  ;  PointInBox Macro
  ; ----------------------------------------------------------------------------
  Macro POINTINBOX2D(_x,_y,_vx,_vy,_vw,_vh)
    If _x>_vx And _x<_vx+_vw And _y>_vy And _y<_vy+_vh
      #True
    Else
      #False
    EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Rescale Macro
  ; --------------------------------------------------------------------------
  Macro RESCALE(_x,_inmin,_inmax,_outmin,_outmax)
    (((_x) -(_inmin))*((_outmax)-(_outmin))/((_inmax)-(_inmin))+(_outmin))
  EndMacro
  
  ;------------------------------------------------
  ; Linear Interpolation Macro
  ;------------------------------------------------
  Macro LINEAR_INTERPOLATE(_io,_y1,_y2,_mu)
    _io = (_y1)*(1-(_mu))+(_y2)*(_mu)
  EndMacro
  
  ;------------------------------------------------
  ; Cubic Interpolation Macro
  ;------------------------------------------------
  Macro CUBIC_INTERPOLATE(_io,_y0,_y1,_y2,_y3,_mu)
  
     Define.f _a0,_a1,_a2,_a3,_mu2
  
     _mu2 = Pow((_mu), 2)
     _a0 = (_y3) - (_y2) - (_y0) + (_y1)
     _a1 = (_y0) - (_y1) - (_a0)
     _a2 = (_y2) - (_y0)
     _a3 = (_y1)
  
     _io = _a0*(_mu)*mu2+_a1*_mu2+_a2*(_mu)+_a3
  EndMacro
  
  ;------------------------------------------------
  ; Hermite Interpolation
  ;------------------------------------------------
  Macro HERMITE_INTERPOLATE(_io,_y0,_y1,_y2,_y3,_mu,_tension,_bias)
    Define.f _m0,_m1,_mu2,_mu3
    Define.f _a0,_a1,_a2,_a3
    
    _mu2 = (_mu) * (_mu)
    _mu3 = _mu2 * (_mu)
    _m0  = ((_y1)-(_y0))*(1+(_bias))*(1-(_tension))/2
    _m0 + ((_y2)-(_y1))*(1-(_bias))*(1-(_tension))/2
    _m1  = ((_y2)-(_y1))*(1+(_bias))*(1-(_tension))/2
    _m1 + ((_y3)-(_y2))*(1-(_bias))*(1-(_tension))/2
    _a0 =  2*_mu3 - 3*_mu2 + 1
    _a1 =    _mu3 - 2*_mu2 + (_mu)
    _a2 =    _mu3 -   _mu2
    _a3 = -2*_mu3 + 3*_mu2
  
   _io = _a0*(_y1)+_a1*_m0+_a2*_m1+_a3*(_y2)
 EndMacro
 
  ;------------------------------------------------
  ; Smooth Step
  ;------------------------------------------------
  Macro SMOOTHSTEP(_t) 
    ((_t) * (_t) * (3 - 2 * (_t)))
  EndMacro
  
  Macro SMOOTHSTEPDERIV(_t) 
    ((_t) * (6 - 6 * (_t)))
  EndMacro
 
  ;------------------------------------------------
  ; Quintic
  ;------------------------------------------------
  Macro QUINTIC(_t) 
    ((_t) * (_t) * (_t) * ((_t) * ((_t) * 6 - 15) + 10))
  EndMacro

  Macro QUINTICDERIV(_t) 
    (30 * (_t) * (_t) * ((_t) * ((_t) - 2) + 1))
  EndMacro
  
 
  ; ----------------------------------------------------------------------------
  ;  v2f32 Structure
  ; --------------------------------------------------------------------------
 Structure v2f32
   StructureUnion
     x.f
     u.f
   EndStructureUnion
   StructureUnion
     y.f
     v.f
   EndStructureUnion
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  v3f32 Structure
  ; --------------------------------------------------------------------------
  Structure v3f32
    StructureUnion
      x.f
      r.f
      u.f
    EndStructureUnion
    StructureUnion
      y.f
      g.f
      v.f
    EndStructureUnion
    StructureUnion
      z.f
      b.f
      w.f
    EndStructureUnion
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      _w.f
    CompilerEndIf
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  v4f32 Structure
  ; --------------------------------------------------------------------------
  Structure v4f32
    StructureUnion
      x.f
      r.f
    EndStructureUnion
    StructureUnion
      y.f
      g.f
    EndStructureUnion
    StructureUnion
      z.f
      b.f
    EndStructureUnion
    StructureUnion
      w.f
      a.f
    EndStructureUnion
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  q4f32 Structure
  ; --------------------------------------------------------------------------
  Structure q4f32
    x.f
    y.f
    z.f
    w.f
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  c4u8 Structure
  ; --------------------------------------------------------------------------
  Structure c4u8
    r.c
    g.c
    b.c
    a.c
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  c4f32 Structure
  ; --------------------------------------------------------------------------
  Structure c4f32
    StructureUnion
      r.f
      x.f
    EndStructureUnion
    StructureUnion
      g.f
      y.f
    EndStructureUnion
    StructureUnion
      b.f
      z.f
    EndStructureUnion
    StructureUnion
      a.f
      w.f
    EndStructureUnion
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  m3f32 Structure
  ; --------------------------------------------------------------------------
  Structure m3f32
    v.f[9]
  EndStructure
  
  Structure m3f32_b
    m00.f : m01.f : m02.f
    m10.f : m11.f : m12.f
    m20.f : m21.f : m22.f
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  m4f32 Structure
  ; --------------------------------------------------------------------------
  Structure m4f32
    v.f[16]
  EndStructure
  
  Structure m4f32_b
    m00.f : m01.f : m02.f : m03.f
    m10.f : m11.f : m12.f : m13.f
    m20.f : m21.f : m22.f : m23.f
    m30.f : m31.f : m32.f : m33.f
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  trf32 Structure
  ; --------------------------------------------------------------------------
  Structure trf32
    pos.v3f32
    rot.q4f32
    scl.v3f32
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  locf32 Structure ( predeclaration of Location_t)
  ; --------------------------------------------------------------------------
   Structure locf32
      tid.i
      p.v3f32
      n.v3f32
      uvw.v3f32
      c.c4f32
      *geometry
      *t
    EndStructure
    
  ; ----------------------------------------------------------------------------
  ;  topof32 Structure ( predeclaration of Topology_t)
  ; --------------------------------------------------------------------------
  Structure topof32
    *vertices
    *faces
    dirty.i
  EndStructure
  
  ; -----------------------------------------------------------------
  ;  Random 0 to 1
  ; -----------------------------------------------------------------
  Macro Random_0_1()
    (Random(Math::#RAND_MAX)/Math::#RAND_MAX)
  EndMacro
  
  Macro Random_Neg1_1()
    (1 - (Random(Math::#RAND_MAX)/Math::#RAND_MAX * 2 ))
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  MATH UTILS
  ; --------------------------------------------------------------------------
  Declare.f Max(a.f,b.f)
  Declare.f Min(a.f,b.f)
  Declare.b IsClose(value.f, root.f, tolerance.f)
  Declare UniformPointOnCircle(*p.v2f32, radius.f=1.0)
  Declare.f UniformPointOnDisc(*p.v2f32, radius.f=1.0)
  Declare.f UniformPointOnDisc2(*p.v2f32, radius.f=1.0)
  Declare UniformPointOnSphere(*p.v3f32, radius.f=1.0)
  Declare MapDiscPointToSphere(*dp.v2f32, *sp.v3f32)
EndDeclareModule

;====================================================================
; Vector2 Module Declaration
;====================================================================
DeclareModule Vector2
  UseModule Math
  
  ;------------------------------------------------------------------
  ; VECTOR2 SET
  ;------------------------------------------------------------------
  Macro Set(_v,_x,_f)
    _v\x = _x
    _v\y = _f
  EndMacro
  
  Macro SetFromOther(_v,_o)
    _v\x = _o\x
    _v\y = _o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 RESET
  ;------------------------------------------------------------------
  Macro Reset(_v)
    _v\x = 0
    _v\y = 0
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 ADD
  ;------------------------------------------------------------------
  Macro Add(_v,_a,_b)
    _v\x = _a\x + _b\x
    _v\y = _a\y + _b\y
  EndMacro
  
  Macro AddInPlace(_v,_o)
    _v\x + _o\x
    _v\y + _o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; ABSOLUTE
  ;------------------------------------------------------------------
  Macro Absolute(_v,_o)
    _v\x = Abs(_o\x)
    _v\y = Abs(_o\y)
  EndMacro
  
  Macro AbsoluteInPlace(_v)
    _v\x = Abs(_v\x)
    _v\y = Abs(_v\y)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SUB
  ;------------------------------------------------------------------
  Macro Sub(_v,_a,_b)
    _v\x = _a\x - _b\x
    _v\y = _a\y - _b\y
  EndMacro
  
  Macro SubInPlace(_v,_o)
    _v\x - _o\x
    _v\y - _o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SCALE
  ;------------------------------------------------------------------
  Macro Scale(_v,_o,_mult)
    _v\x = _o\x * _mult
    _v\y = _o\y * _mult
  EndMacro
  
  Macro ScaleInPlace(_v,_mult)
    _v\x * _mult
    _v\y * _mult
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SCALE ADD
  ;------------------------------------------------------------------
  Macro ScaleAdd(_v,_a,_b,_mult)
    _v\x = _a\x + _b\x * _mult
    _v\y = _a\y + _b\y * _mult
  EndMacro
  
  Macro ScaleAddInPlace(_v,_o,_mult)
    _v\x + _o\x * _mult
    _v\y + _o\y * _mult
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 INVERT
  ;------------------------------------------------------------------
  Macro Invert(_v, _o)
    If _o\x <> 0.0 : _v\x = 1 / _o\x : EndIf
    If _o\y <> 0.0 : _v\y = 1 / _o\y : EndIf
  EndMacro
  
  Macro InvertInPlace(_v)
    If _v\x <> 0.0 : _v\x = 1 / _v\x : EndIf
    If _v\y <> 0.0 : _v\y = 1 / _v\y : EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 LENGTH
  ;------------------------------------------------------------------
  Macro LengthSquared(_v)
    (_v\x * _v\x + _v\y * _v\y)
  EndMacro
  
  Macro Length(_v)
    Sqr(_v\x * _v\x + _v\y * _v\y)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 DOT
  ;------------------------------------------------------------------
  Macro Dot(_v,_o)
    (_v\x * _o\x + _v\y * _o\y)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 NORMALIZE
  ;------------------------------------------------------------------
  Macro Normalize(_v, _o)
    Define _mag.f = Vector2::LengthSquared(_o)
    If (_mag <> 0)
      _mag =  Sqr(_mag)
      _v\x = _o\x / _mag
      _v\y = _o\y / _mag
    EndIf
  EndMacro
  
  Macro NormalizeInPlace(_v)
    Define _mag.f = Vector2::LengthSquared(_v)
    If (_mag <> 0)
      _mag =  Sqr(_mag)
      _v\x / _mag
      _v\y / _mag
    EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 ANGLE
  ;------------------------------------------------------------------
  Macro GetAngle(_v, _o, _angle)
    Define _fCosAngle.f, _fLen.f
    
    _fLen = Vector2::Length(_v)
    _fLen * Vector2::Length(_o)
    
    If _fLen < Math::#F32_EPS
      _angle = 0
    Else
      _fCosAngle = (_v\x* _o\x + _v\y * _o\y)/_fLen
      Math::Clamp(_fCosAngle,-1,1)
      _angle = ACos(_fCosAngle)
    EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 ROTATE (angle in radians)
  ;------------------------------------------------------------------
  Macro Rotate(_v,_o, _angle)
    Define _cs.f = Cos(_angle)
    Define _sn.f = Sin(_angle)
    _v\x = _o\x * _cs - _o\y * _sn
    _v\y = _o\x * _sn + _o\y * _cs
  EndMacro
  
  Macro RotateInPlace(_v, _angle)
    Define _cs.f = Cos(_angle)
    Define _sn.f = Sin(_angle)
    Define _x.f = _v\x * _cs - _v\y * _sn
    Define _y.f = _v\x * _sn + _v\y * _cs
    _v\x = _x
    _v\y = _y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 INTERPOLATION
  ;------------------------------------------------------------------
  Macro LinearInterpolate(_v,_a,_b,_blend)
    _v\x = (1-_blend) * _a\x + _blend * _b\x
    _v\y = (1-_blend) * _a\y + _blend * _b\y
  EndMacro
  
  Macro BezierInterpolate(_v,_a,_b,_c,_d,_u)
    Define _u2.f = 1-_u
    Define.f _t1,_t2,_t3,_t4
  
    _t1 = Pow((_u2),3)
    _t2 = 3*Pow(_u2,2)*_u
    _t3 = 3*_u2*Pow(_u,2)
    _t4 = Pow(_u,3)
    
     _v\x = _t1 * _a\x + _t2* _b\x + _t3* _c\x + _t4 * _d\x
     _v\y = _t1 * _a\y + _t2* _b\y + _t3* _c\y + _t4 * _d\y
  EndMacro

  Macro HermiteInterpolate(_v,_a,_b,_c,_d,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\x,_a\x,_b\x,_c\x,_d\x,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\y,_a\y,_b\y,_c\y,_d\y,_mu,_tension,_bias)
  Macro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SET LENGTH
  ;------------------------------------------------------------------
  Macro SetLength(_v,_length)
    NormalizeInPlace(_v)
    ScaleInPlace(_v,_length)
  EndMacro

  ;------------------------------------------------------------------
  ; VECTOR2 MULTIPLY
  ;------------------------------------------------------------------
  Macro Multiply(_o,_a,_b)
    _o\x = _a\x * _b\x
    _o\y = _a\y * _b\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_v,_name="")
    Debug _name +":("+
          StrF(_v\x, Math::#ECHO_PRECISION)+","+
          StrF(_v\y, Math::#ECHO_PRECISION)+")"
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 TO STRING
  ;------------------------------------------------------------------
  Macro ToString(v)
    StrF(v\x)+","+StrF(v\y)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(v, s)
    If CountString(s,",")=1
      v\x = ValF(StringField(s,1,","))
      v\y = ValF(StringField(s,2,","))
    EndIf
  EndMacro
  
 
EndDeclareModule

;====================================================================
; Vector3 Module Declaration
;====================================================================
DeclareModule Vector3
  UseModule Math
  
  ;------------------------------------------------------------------
  ; VECTOR3 SET
  ;------------------------------------------------------------------
  Macro Set(_v,_x,_y,_z)
    _v\x = _x
    _v\y = _y
    _v\z = _z
  EndMacro
  
  Macro SetFromOther(_v, _o)
    _v\x = _o\x
    _v\y = _o\y
    _v\z = _o\z
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 RESET
  ;------------------------------------------------------------------
  Macro Reset(_v)
    _v\x = 0
    _v\y = 0
    _v\z = 0
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 AT (element accessor)
  ;------------------------------------------------------------------
  Macro At(_v, _index)
    PeekF(_v + (_index) * 4)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 LENGTH
  ;------------------------------------------------------------------
  Macro LengthSquared(_v)
    (_v\x * _v\x + _v\y * _v\y + _v\z * _v\z)
  EndMacro
  
  Macro Length(_v)
    Sqr(_v\x * _v\x + _v\y * _v\y + _v\z * _v\z)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 DISTANCE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare.f Distance(*a.v3f32, *b.v3f32)
    Declare.f DistanceSquared(*a.v3f32, *b.v3f32)
  CompilerElse
    Macro DistanceSquared(_a, _b)
      (Pow(_b\x-_a\x, 2) + Pow(_b\y - _a\y, 2) + Pow(_b\z - _a\z, 2))
    EndMacro
    
    Macro Distance(_a, _b)
      Sqr(Pow(_b\x-_a\x, 2) + Pow(_b\y - _a\y, 2) + Pow(_b\z - _a\z, 2))
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 PROJECTION
  ;------------------------------------------------------------------
  Macro Project(_v, _a, _b)
    Vector3::Normalize(_v, _b)
    _v\x = (_v\x - _a\x) * _v\x
    _v\y = (_v\y - _a\y) * _v\y
    _v\z = (_v\z - _a\z) * _v\z
  EndMacro
  
  Macro ProjectInPlace(_v, _o)
    Define _l.f = Vector3::Length(_o)
    If _l <> 0.0
      _v\x = ((_v\x - _o\x) * _v\x)/_l
      _v\y = ((_v\y - _o\y) * _v\y)/_l
      _v\z = ((_v\z - _o\z) * _v\z)/_l
    EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 ABSOLUTE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Absolute(*v.v3f32, *o.v3f32)
    Declare AbsoluteInPlace(*v.v3f32)
  CompilerElse
    Macro Absolute(_v, _o)
      _v\x = Abs(_o\x)
      _v\y = Abs(_o\y)
      _v\z = Abs(_o\z)
    EndMacro
    
    Macro AbsoluteInPlace(_v)
      _v\x = Abs(_v\x)
      _v\y = Abs(_v\y)
      _v\z = Abs(_v\z)
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 NORMALIZE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Normalize(*v.v3f32, *o.v3f32)
    Declare NormalizeInPlace(*v.v3f32)
  CompilerElse
    Macro Normalize(_v,_o)
      Define _mag.f = Sqr(_o\x * _o\x + _o\y * _o\y + _o\z * _o\z)
      ;Avoid error dividing by zero
      If _mag = 0 : _mag =1.0 :EndIf
      
      Define _div.f = 1.0/_mag
      _v\x = _o\x * _div
      _v\y = _o\y * _div
      _v\z = _o\z * _div
    EndMacro
    
    Macro NormalizeInPlace(_v)
      Define _mag.f = Sqr(_v\x * _v\x + _v\y * _v\y + _v\z * _v\z)
      ;Avoid error dividing by zero
      If _mag = 0 : _mag =1.0 :EndIf
      
      Define _div.f = 1.0/_mag
      _v\x * _div
      _v\y * _div
      _v\z * _div
    EndMacro
  CompilerEndIf
  

  ;------------------------------------------------------------------
  ; VECTOR3 GET ANGLE
  ;------------------------------------------------------------------
  Macro GetAngle(_v,_o, _angle)
    Define _fCosAngle.f,_fLen.f
    
    _fLen = Vector3::Length(v)
    _fLen * Vector3::Length(o)
    
    If _fLen < #F32_EPS
      _angle = 0
    Else
      _fCosAngle = (_v\x* _o\x + _v\y * _o\y + _v\z * _o\z)/_fLen
      Clamp(_fCosAngle,-1,1)
      _angle = ACos(_fCosAngle)
    EndIf
   EndMacro

  ;------------------------------------------------------------------
  ; VECTOR3 ADD
  ;------------------------------------------------------------------
   CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
     Declare Add(*v.v3f32, *a.v3f32, *b.v3f32)
     Declare AddInPlace(*v.v3f32, *o.v3f32)
   CompilerElse  
    Macro Add(_v,_a,_b)
      _v\x = _a\x + _b\x
      _v\y = _a\y + _b\y
      _v\z = _a\z + _b\z
    EndMacro
    
    Macro AddInPlace(_v,_o)
      _v\x + _o\x
      _v\y + _o\y
      _v\z + _o\z
    EndMacro
  CompilerEndIf
    
  ;------------------------------------------------------------------
  ; VECTOR3 SUB
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
     Declare Sub(*v.v3f32, *a.v3f32, *b.v3f32)
     Declare SubInPlace(*v.v3f32, *o.v3f32)
  CompilerElse  
    Macro SubInPlace(_v,_o)
      _v\x - _o\x
      _v\y - _o\y
      _v\z - _o\z
    EndMacro
    
    Macro Sub(_v,_a,_b)
      _v\x = _a\x - _b\x
      _v\y = _a\y - _b\y
      _v\z = _a\z - _b\z
    EndMacro
   CompilerEndIf

  ;------------------------------------------------------------------
  ; VECTOR3 SCALE
  ;------------------------------------------------------------------
   CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
     Declare Scale(*v.v3f32, *o.v3f32, mult.f)
     Declare ScaleInPlace(*v.v3f32, mult.f)
  CompilerElse  
    Macro Scale(_v,_o,_mult)
      _v\x = _o\x * _mult
      _v\y = _o\y * _mult
      _v\z = _o\z * _mult
    EndMacro
    
    Macro ScaleInPlace(_v,_mult)
      _v\x * _mult
      _v\y * _mult
      _v\z * _mult
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 SCALE ADD
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare ScaleAdd(*v.v3f32, *a.v3f32, *b.v3f32,mult.f)
    Declare ScaleAddInPlace(*v.v3f32, *o.v3f32, mult.f)
  CompilerElse  
    Macro ScaleAdd(_v,_a,_b,_mult)
      _v\x = _a\x + _b\x * _mult
      _v\y = _a\y + _b\y * _mult
      _v\z = _a\z + _b\z * _mult
    EndMacro
    
    Macro ScaleAddInPlace(_v,_o,_mult)
      _v\x + _o\x * _mult
      _v\y + _o\y * _mult
      _v\z + _o\z * _mult
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 INVERT
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Invert(*v.v3f32, *o.v3f32)
    Declare InvertInPlace(*v.v3f32)
  CompilerElse  
    Macro Invert(_v,_o)
      If _o\x <> 0.0 : _v\x = 1.0 / _o\x : Else : _v\x = 0.0 : EndIf
      If _o\y <> 0.0 : _v\y = 1.0 / _o\y : Else : _v\y = 0.0 : EndIf
      If _o\z <> 0.0 : _v\z = 1.0 / _o\z : Else : _v\z = 0.0 : EndIf
    EndMacro
    
    Macro InvertInPlace(_v)
      If _v\x <> 0.0 : _v\x = 1.0 / _v\x : EndIf
      If _v\y <> 0.0 : _v\y = 1.0 / _v\y : EndIf
      If _v\z <> 0.0 : _v\z = 1.0 / _v\z : EndIf
    EndMacro
  CompilerEndIf
  

  ;------------------------------------------------------------------
  ; VECTOR3 INTERPOLATION
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare LinearInterpolate(*v.v3f32, *a.v3f32, *b.v3f32, blend.f)
    Declare LinearInterpolateInPlace(*v.v3f32, *o.v3f32, blend.f)
  CompilerElse
    Macro LinearInterpolate(_v,_a,_b,_blend)
      LINEAR_INTERPOLATE(_v\x,_a\x,_b\x,_blend)
      LINEAR_INTERPOLATE(_v\y,_a\y,_b\y,_blend)
      LINEAR_INTERPOLATE(_v\z,_a\z,_b\z,_blend)
    EndMacro
    
    Macro LinearInterpolateInPlace(_v,_o,_blend)
      LINEAR_INTERPOLATE(_v\x,_v\x,_o\x,_blend)
      LINEAR_INTERPOLATE(_v\y,_v\y,_o\y,_blend)
      LINEAR_INTERPOLATE(_v\z,_v\z,_b\z,_blend)
    EndMacro
  CompilerEndIf

  Macro BezierInterpolate(_v,_a,_b,_c,_d,_u)
    Define _u2.f = 1-_u
    Define.f _t1,_t2,_t3,_t4
  
    _t1 = Pow(_u2,3)
    _t2 = 3*Pow(_u2,2)*_u
    _t3 = 3*_u2*Pow(_u,2)
    _t4 = Pow(_u,3)
    
     _v\x = _t1 * _a\x + _t2* _b\x + _t3* _c\x + _t4 * _d\x
     _v\y = _t1 * _a\y + _t2* _b\y + _t3* _c\y + _t4 * _d\y
     _v\z = _t1 * _a\z + _t2* _b\z + _t3* _c\z + _t4 * _d\z
   
  EndMacro

  Macro HermiteInterpolate(_v,_a,_b,_c,_d,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\x,_a\x,_b\x,_c\x,_d\x,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\y,_a\y,_b\y,_c\y,_d\y,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\z,_a\z,_b\z,_c\z,_d\z,_mu,_tension,_bias)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 COMPARISON
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare.b Equal(*v.v3f32, *o.v3f32)
    Declare.b LessThan(*v.v3f32, *o.v3f32)
    Declare.b LessOrEqualThan(*v.v3f32, *o.v3f32)
    Declare.b GreaterOrEqualThan(*v.v3f32, *o.v3f32)
    Declare.b GreaterThan(*v.v3f32, *o.v3f32)
  CompilerElse
    Macro Equal(_v, _o)
      Bool(_v\x = _o\x And _v\y = _o\y And _v\z = _o\z)
    EndMacro
    
    Macro LessThan(_v, _o)
      Bool(_v\x < _o\x And _v\y < _o\y And _v\z < _o\z)
    EndMacro
    
    Macro LessThanOrEqual(_v, _o)
      Bool(_v\x <= _o\x And _v\y <= _o\y And _v\z <= _o\z)
    EndMacro
    
    Macro GreaterThanOrEqual(_v, _o)
      Bool(_v\x >= _o\x And _v\y >= _o\y And _v\z >= _o\z)
    EndMacro
    
    Macro GreaterThan(_v, _o)
      Bool(_v\x > _o\x And _v\y > _o\y And _v\z > _o\z)
    EndMacro
  CompilerEndIf
  
    
  ;------------------------------------------------------------------
  ; CROSS
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Cross(*v.v3f32, *a.v3f32, *b.v3f32)
  CompilerElse
    Macro Cross(_v,_a,_b)
      _v\x = (_a\y * _b\z) - (_a\z * _b\y)
      _v\y = (_a\z * _b\x) - (_a\x * _b\z)
      _v\z = (_a\x * _b\y) - (_a\y * _b\x)
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 DOT
  ;------------------------------------------------------------------
  Macro Dot(_v,_o)
    (_v\x * _o\x + _v\y * _o\y + _v\z * _o\z)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 MINIMUM
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Minimize(*v.v3f32, *a.v3f32, *b.v3f32)
    Declare MinimizeInPlace(*v.v3f32, *o.v3f32)
  CompilerElse
    Macro Minimize(_v, _a, _b)
      If _a\x < _b\x : _v\x = _a\x : Else : _v\x = _b\x : EndIf
      If _a\y < _b\y : _v\y = _a\y : Else : _v\y = _b\y : EndIf
      If _a\z < _b\z : _v\z = _a\z : Else : _v\z = _b\z : EndIf
    EndMacro
    
    Macro MinimizeInPlace(_v, _o)
      If _o\x < _v\x : _v\x = _o\x : EndIf
      If _o\y < _v\y : _v\y = _o\y : EndIf
      If _o\z < _v\z : _v\z = _o\z : EndIf
    EndMacro
    
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR3 MAXIMUM
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Maximize(*v.v3f32, *a.v3f32, *b.v3f32)
    Declare MaximizeInPlace(*v.v3f32, *o.v3f32)
  CompilerElse
    Macro Maximize(_v, _a, _b)
      If _a\x > _b\x : _v\x = _a\x : Else : _v\x = _b\x : EndIf
      If _a\y > _b\y : _v\y = _a\y : Else : _v\y = _b\y : EndIf
      If _a\z > _b\z : _v\z = _a\z : Else : _v\z = _b\z : EndIf
    EndMacro
    
    Macro MaximizeInPlace(_v, _o)
      If _o\x > _v\x : _v\x = _o\x : EndIf
      If _o\y > _v\y : _v\y = _o\y : EndIf
      If _o\z > _v\z : _v\z = _o\z : EndIf
    EndMacro
    
  CompilerEndIf
  
  
  ;------------------------------------------------------------------
  ; VECTOR3 SET LENGTH
  ;------------------------------------------------------------------
  Macro SetLength(_v,_length)
    Vector3::NormalizeInPlace(_v)
    Vector3::ScaleInPlace(_v,_length)
  EndMacro

  ;------------------------------------------------------------------
  ; VECTOR3 MULTIPLY BY OTHER
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Multiply(*v.v3f32, *a.v3f32, *b.v3f32)
  CompilerElse
    Macro Multiply(_o,_a,_b)
      _o\x = _a\x * _b\x
      _o\y = _a\y * _b\y
      _o\z = _a\z * _b\z
    EndMacro
  CompilerEndIf
  
  
  ;------------------------------------------------------------------
  ; VECTOR3 RANDOMIZE
  ;------------------------------------------------------------------
  Macro Randomize(_v,_o,_mult)
    _v\x = _o\x + Math::Random_Neg1_1() * _mult
    _v\y = _o\y + Math::Random_Neg1_1() * _mult
    _v\z = _o\z + Math::Random_Neg1_1() * _mult
  EndMacro
  
  Macro RandomizeInPlace(_v,_mult)
    _v\x + Math::Random_Neg1_1() * _mult
    _v\y + Math::Random_Neg1_1() * _mult
    _v\z + Math::Random_Neg1_1() * _mult
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 MULTIPLY BY MATRIX3
  ;------------------------------------------------------------------
  Macro MulByMatrix3(_v,_o,_m)
    _v\x = _o\x * _m\v[0] + _o\y * _m\v[3] + _o\z * _m\v[6]
    _v\y = _o\x * _m\v[1] + _o\y * _m\v[4] + _o\z * _m\v[7] 
    _v\z = _o\x * _m\v[2] + _o\y * _m\v[5] + _o\z * _m\v[8]
  EndMacro
  
  Macro MulByMatrix3InPlace(v,m)
     Define _x.f,_y.f,_z.f

    _x = v\x * m\v[0] + v\y * m\v[3] + v\z * m\v[6]
    _y = v\x * m\v[1] + v\y * m\v[4] + v\z * m\v[7] 
    _z = v\x * m\v[2] + v\y * m\v[5] + v\z * m\v[8]
    
    v\x = _x
    v\y = _y
    v\z = _z
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 MULTIPLY BY MATRIX4
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare MulByMatrix4(*v.v3f32, *o.v3f32, *m.m4f32)
    Declare MulByMatrix4InPlace(*v.v3f32, *m.m4f32)
  CompilerElse
    Macro MulByMatrix4(_v,_o,_m)
    ;   x = *o\x * *m\v[0] + *o\y * *m\v[1] + *o\z * *m\v[2] + *m\v[3]
    ;   y = *o\x * *m\v[4] + *o\y * *m\v[5] + *o\z * *m\v[6] + *m\v[7]
    ;   z = *o\x * *m\v[8] + *o\y * *m\v[9] + *o\z * *m\v[10] + *m\v[11]
    ;   w = *o\x * *m\v[12] + *o\y * *m\v[13] + *o\z * *m\v[15] + *m\v[15]
    ;   *v\x = x/w
    ;   *v\y = y/w
    ;   *v\z = z/w
      Define _x.f,_y.f,_z.f,_w.f
      _x = _o\x * _m\v[0] + _o\y * _m\v[4] + _o\z * _m\v[8] + _m\v[12]
      _y = _o\x * _m\v[1] + _o\y * _m\v[5] + _o\z * _m\v[9] + _m\v[13]
      _z = _o\x * _m\v[2] + _o\y * _m\v[6] + _o\z * _m\v[10] + _m\v[14]
      _w = _o\x * _m\v[3] + _o\y * _m\v[7] + _o\z * _m\v[11] + _m\v[15]

      _v\x = _x/_w
      _v\y = _y/_w
      _v\z = _z/_w
    EndMacro
    
    Macro MulByMatrix4InPlace(_v,_m)
      Define _x.f,_y.f,_z.f,_w.f
      _x = _v\x * _m\v[0] + _v\y * _m\v[4] + _v\z * _m\v[8] + _m\v[12]
      _y = _v\x * _m\v[1] + _v\y * _m\v[5] + _v\z * _m\v[9] + _m\v[13]
      _z = _v\x * _m\v[2] + _v\y * _m\v[6] + _v\z * _m\v[10] + _m\v[14]
      _w = _v\x * _m\v[3] + _v\y * _m\v[7] + _v\z * _m\v[11] + _m\v[15]

      _v\x = _x/_w
      _v\y = _y/_w
      _v\z = _z/_w
    ;   x = *v\x * *m\v[0] + *v\y * *m\v[1] + *v\z * *m\v[2] + *m\v[3]
    ;   y = *v\x * *m\v[4] + *v\y * *m\v[5] + *v\z * *m\v[6] + *m\v[7]
    ;   z = *v\x * *m\v[8] + *v\y * *m\v[9] + *v\z * *m\v[10] + *m\v[11]
    ;   w = *v\x * *m\v[12] + *v\y * *m\v[13] + *v\z * *m\v[15] + *m\v[15]
    ;   *v\x = x/w
    ;   *v\y = y/w
    ;   *v\z = z/w
    EndMacro
  CompilerEndIf
  

  ;------------------------------------------------------------------
  ; VECTOR3 MULTIPLY BY QUATERNION
  ;------------------------------------------------------------------
  Macro MulByQuaternion(_out,_in,_q)
  	Define _inmag.f = Vector3::Length(_in)
  	;normalize vector
  	Vector3::Normalize(_out,_in)
    Define.q4f32 _vecQuat, _conjQuat, _resQuat
    _vecQuat\x = _out\x
    _vecQuat\y = _out\y
    _vecQuat\z = _out\z
    _vecQuat\w = 0.0
  
    Quaternion::Conjugate(_conjQuat,_q)
    Quaternion::Multiply(_resQuat,_vecQuat,_conjQuat)
    Quaternion::Multiply(_resQuat,_q,_resQuat)
    
    _out\x = _resQuat\x
    _out\y = _resQuat\y
    _out\z = _resQuat\z
  
    Vector3::NormalizeInPlace(_out)
    Vector3::ScaleInPlace(_out, _inmag)
  EndMacro
  
  Macro MulByQuaternionInPlace(_v,_q)
  	Define _vmag.f = Vector3::Length(_v)
  	
  	;normalize vector
  	Define _vn.v3f32
  	Vector3::Normalize(_vn,_v)
  	
    Define.q4f32 _vecQuat, _conjQuat, _resQuat
    _vecQuat\x = _vn\x
    _vecQuat\y = _vn\y
    _vecQuat\z = _vn\z
    _vecQuat\w = 0.0
    
    Quaternion::Conjugate(_conjQuat,_q)
    Quaternion::Multiply(_resQuat,_vecQuat,_conjQuat)
    Quaternion::Multiply(_resQuat,_q,_resQuat)
    
    _v\x = _resQuat\x
    _v\y = _resQuat\y
    _v\z = _resQuat\z
  
  	Vector3::NormalizeInPlace(_v)
  	Vector3::ScaleInPlace(_v,_vmag)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 ARE EQUIVALENT
  ;------------------------------------------------------------------
  Declare.b Equivalent(*v.v3f32,*o.v3f32, eps.f=0.0000001)
  
  ;------------------------------------------------------------------
  ; VECTOR3 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_v,_name)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Debug _name +":("+
            StrF(_v\x, Math::#ECHO_PRECISION)+","+
            StrF(_v\y, Math::#ECHO_PRECISION)+","+
            StrF(_v\z, Math::#ECHO_PRECISION)+","+
            StrF(_v\_w, Math::#ECHO_PRECISION)+")"
            
    CompilerElse
      Debug _name +":("+
            StrF(_v\x, Math::#ECHO_PRECISION)+","+
            StrF(_v\y, Math::#ECHO_PRECISION)+","+
            StrF(_v\z, Math::#ECHO_PRECISION)+")"
    CompilerEndIf
    
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_v)
    StrF(_v\x)+","+StrF(_v\y)+","+StrF(_v\z)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR3 FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_v, _s)
    If CountString(_s,",")=2
      _v\x = ValF(StringField(_s,1,","))
      _v\y = ValF(StringField(_s,2,","))
      _v\z = ValF(StringField(_s,3,","))
    EndIf
  EndMacro
EndDeclareModule

;====================================================================
; Vector4 Module Declaration
;====================================================================
DeclareModule Vector4
  UseModule Math
  ;------------------------------------------------------------------
  ; VECTOR4 SET
  ;------------------------------------------------------------------
  Macro Set(_v,_x,_y,_z,_w)
    _v\w = _w
    _v\x = _x
    _v\y = _y
    _v\z = _z
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 RESET
  ;------------------------------------------------------------------
  Macro Reset(_v)
    _v\w = 0
    _v\x = 0
    _v\y = 0
    _v\z = 0
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_v,_o)
    _v\w = _o\w
    _v\x = _o\x
    _v\y = _o\y
    _v\z = _o\z
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 SCALE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Scale(*v.v4f32, *o.v4f32, mult.f)
    Declare ScaleInPlace(*v.v4f32, mult.f)
  CompilerElse
    Macro Scale(_v,_o,_mult)
      _v\w = _o\w * _mult
      _v\x = _o\x * _mult
      _v\y = _o\y * _mult
      _v\z = _o\z * _mult
    EndMacro
    
    Macro ScaleInPlace(_v,_mult)
      _v\w * _mult
      _v\x * _mult
      _v\y * _mult
      _v\z * _mult
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; VECTOR4 SCALE Add
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare ScaleAdd(*v.v4f32, *a.v4f32, *b.v4f32, mult.f)
    Declare ScaleAddInPlace(*v.v4f32, *o.v4f32, mult.f)
  CompilerElse
    Macro ScaleAdd(_v,_a,_b,_mult)
      _v\w = _a\w + _b\w * _mult
      _v\x = _o\x + _b\x * _mult
      _v\y = _o\y + _b\y * _mult
      _v\z = _o\z + _b\z * _mult
    EndMacro
    
    Macro ScaleAddInPlace(_v,_o,_mult)
      _v\w + _o\w * _mult
      _v\x + _o\x * _mult
      _v\y + _o\y * _mult
      _v\z + _o\z * _mult
    EndMacro
  CompilerEndIf
  
  
  ;------------------------------------------------------------------
  ; VECTOR4 MULTIPLY BY MATRIX
  ;------------------------------------------------------------------
  Macro MulByMatrix4(_v,_o,_m,_transpose)
    Define _x.f,_y.f,_z.f,_w.f

;     If Not transpose
;       x = *o\x * *m\v[0] + *o\y * *m\v[1] + *o\z * *m\v[2] + *o\w * *m\v[3]
;       y = *o\x * *m\v[4] + *o\y * *m\v[5] + *o\z * *m\v[6] + *o\w * *m\v[7]
;       z = *o\x * *m\v[8] + *o\y * *m\v[9] + *o\z * *m\v[10] + *o\w * *m\v[11]
;       w = *o\x * *m\v[12] + *o\y * *m\v[13] + *o\z * *m\v[15] + *o\w * *m\v[15]
;     Else
      _x = _o\x * _m\v[0] + _o\y * _m\v[4] + _o\z * _m\v[8] + _o\w * _m\v[12]
      _y = _o\x * _m\v[1] + _o\y * _m\v[5] + _o\z * _m\v[9] + _o\w * _m\v[13]
      _z = _o\x * _m\v[2] + _o\y * _m\v[6] + _o\z * _m\v[10] + _o\w * _m\v[14]
      _w = _o\x * _m\v[3] + _o\y * _m\v[7] + _o\z * _m\v[11] + _o\w * _m\v[15]
;     EndIf
  
    _v\x = _x
    _v\y = _y
    _v\z = _z
    _v\w = _w
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 MULTIPLY BY MATRIX4 IN PLACE
  ;------------------------------------------------------------------
  Macro MulByMatrix4InPlace(_v,_m,_transpose)
    Define _x.f,_y.f,_z.f,_w.f
;     If Not transpose
;       x = *v\x * *m\v[0] + *v\y * *m\v[1] + *v\z * *m\v[2] + *v\w * *m\v[3]
;       y = *v\x * *m\v[4] + *v\y * *m\v[5] + *v\z * *m\v[6] + *v\w * *m\v[7]
;       z = *v\x * *m\v[8] + *v\y * *m\v[9] + *v\z * *m\v[10] + *v\w * *m\v[11]
;       w = *v\x * *m\v[12] + *v\y * *m\v[13] + *v\z * *m\v[15] + *v\w * *m\v[15]
;     Else
      _x = _v\x * _m\v[0] + _v\y * _m\v[4] + _v\z * _m\v[8] + _v\w * _m\v[12]
      _y = _v\x * _m\v[1] + _v\y * _m\v[5] + _v\z * _m\v[9] + _v\w * _m\v[13]
      _z = _v\x * _m\v[2] + _v\y * _m\v[6] + _v\z * _m\v[10] + _v\w * _m\v[14]
      _w = _v\x * _m\v[3] + _v\y * _m\v[7] + _v\z * _m\v[11] + _v\w * _m\v[15]
;     EndIf
  
    _v\x = _x
    _v\y = _y
    _v\z = _z
    _v\w = _w
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_v,_prefix)
    Debug _prefix+"("+
          StrF(_v\x,Math::#ECHO_PRECISION)+","+
          StrF(_v\y,Math::#ECHO_PRECISION)+","+
          StrF(_v\z,Math::#ECHO_PRECISION)+","+
          StrF(_v\w,Math::#ECHO_PRECISION)+")"
  EndMacro
      
  ;------------------------------------------------------------------
  ; VECTOR4 TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_v)
    StrF(_v\x)+","+StrF(_v\y)+","+StrF(_v\z)+","+StrF(_v\w)
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR4 FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_v, _s)
    If CountString(_s,",")=3
      _v\x = ValF(StringField(_s,1,","))
      _v\y = ValF(StringField(_s,2,","))
      _v\z = ValF(StringField(_s,3,","))
      _v\w = ValF(StringField(_s,4,","))
    EndIf
  EndMacro

EndDeclareModule

;====================================================================
; Quaternion Module Declaration
;====================================================================
DeclareModule Quaternion
  UseModule Math
  #RENORMCOUNT  = 97
  #TRACKBALLSIZE  = 0.8
  
  ;------------------------------------------------------------------
  ; QUATERNION SET
  ;------------------------------------------------------------------
  Macro Set(_q,_x,_y,_z,_w)
    _q\x = _x
    _q\y = _y
    _q\z = _z
    _q\w = _w
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION RESET
  ;------------------------------------------------------------------
  Macro Reset(_q)
    _q\x = 0
    _q\y = 0
    _q\z = 0
    _q\w = 0
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_q1,_q2)
    _q1\x = _q2\x
    _q1\y = _q2\y
    _q1\z = _q2\z
    _q1\w = _q2\w
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION NEGATE
  ;------------------------------------------------------------------
  Macro Negate(_q1,_q2)
    _q1\x = -_q2\x
    _q1\y = -_q2\y
    _q1\z = -_q2\z
    _q1\w = -_q2\w
  EndMacro
  
  Macro NegateInPlace(_q1)
    _q1\x * -1
    _q1\y * -1
    _q1\z * -1
    _q1\w * -1
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION SET IDENTITY
  ;------------------------------------------------------------------
  Macro SetIdentity(_q)
    _q\x = 0
    _q\y = 0
    _q\z = 0
    _q\w = 1
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION DOT PRODUCT
  ;------------------------------------------------------------------
  Macro Dot(_q1,_q2)
    (_q1\x * _q2\x + _q1\y * _q2\y + _q1\z * _q2\z + _q1\w * _q2\w)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION SET FROM AXIS\ANGLE
  ;------------------------------------------------------------------
  Macro SetFromAxisAngle(_q,_axis,_angle)
    Define _n.Math::v3f32,_halfAngle.f,_sinAngle.f
    Vector3::Normalize(_n,_axis)
    _halfAngle = _angle*0.5
    _sinAngle = Sin(_halfAngle)
    _q\x = _n\x * _sinAngle
    _q\y = _n\y * _sinAngle
    _q\z = _n\z * _sinAngle
    _q\w = Cos(_halfAngle)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION SET FROM AXIS\ANGLE VALUES
  ;------------------------------------------------------------------
  Macro SetFromAxisAngleValues(_q,_x,_y,_z,_angle)
    Define _n.Math::v3f32,_axis.Math::v3f32,_halfAngle.f,_sinAngle.f
    Vector3::Set(_axis,_x,_y,_z)
    Vector3::Normalize(_n,_axis)
    _halfAngle = _angle*0.5
    _sinAngle = Sin(_halfAngle)
    _q\x = _n\x * _sinAngle
    _q\y = _n\y * _sinAngle
    _q\z = _n\z * _sinAngle
    _q\w = Cos(_halfAngle)
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION SET FROM EULER
  ;------------------------------------------------------------------
  Macro SetFromEulerAngles(_q,_pitch, _yaw, _roll)
    Define.f _p,_y,_r
    _p = _pitch * #F32_DEG2RAD * 0.5
    _y = _yaw * #F32_DEG2RAD * 0.5
    _r = _roll * #F32_DEG2RAD * 0.5
    
    Define.f _sinp,_siny,_sinr,_cosp,_cosy,_cosr
    _sinp = Sin(_p)
    _siny = Sin(_y)
    _sinr = Sin(_r)
    _cosp = Cos(_p)
    _cosy = Cos(_y)
    _cosr = Cos(_r)
  
  	_q\x = _sinr * _cosp * _cosy - _cosr * _sinp * _siny
  	_q\y = _cosr * _sinp * _cosy + _sinr * _cosp * _siny
  	_q\z = _cosr * _cosp * _siny - _sinr * _sinp * _cosy
  	_q\w = _cosr * _cosp * _cosy + _sinr * _sinp * _siny
  	Quaternion::NormalizeInPlace(_q)
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION SET FROM EULER
  ;------------------------------------------------------------------
  Macro Normalize(_out,_q)
    Define _mag2.f = _q\x * _q\x + _q\y * _q\y + _q\z * _q\z + _q\w * _q\w
    If _mag2 <> 0.0
      If Abs(_mag2 - 1.0)>0.0001
        Define _mag.f = Sqr(_mag2)
        _out\x = _q\x/_mag
        _out\y = _q\y/_mag
        _out\z = _q\z/_mag
        _out\w = _q\w/_mag
      EndIf
    EndIf
  EndMacro
  
  Macro NormalizeInPlace(_q)
    Define _mag2.f = _q\x * _q\x + _q\y * _q\y + _q\z * _q\z + _q\w * _q\w
    If _mag2 <>  0.0
      If Abs(_mag2 - 1.0)>0.0001
        Define _mag.f = Sqr(_mag2)
        _q\x / _mag
        _q\y / _mag
        _q\z / _mag
        _q\w / _mag
      EndIf 
    EndIf
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION CONJUGATE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Conjugate(*out.q4f32,*q.q4f32)
    Declare ConjugateInPlace(*q.q4f32)
  CompilerElse
    Macro Conjugate(_out,_q)
      _out\x = -_q\x
      _out\y = -_q\y
      _out\z = -_q\z
      _out\w = _q\w
    EndMacro
    
    Macro ConjugateInPlace(_q)
      _q\x = -_q\x
      _q\y = -_q\y
      _q\z = -_q\z
    EndMacro
  CompilerEndIf
  

  ;------------------------------------------------------------------
  ; QUATERNION MULTIPLY
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Multiply(*out.q4f32, *q1.q4f32, *q2.q4f32)
    Declare MultiplyInPlace(*q1.q4f32, *q2.q4f32)
  CompilerElse
    Macro Multiply(_out,_q1,_q2)
      Define.f _x,_y,_z,_w
      _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
      _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
      _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
      _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)
      _out\x = _x
      _out\y = _y
      _out\z = _z
      _out\w = _w
    EndMacro
    
    Macro MultiplyInPlace(_q1,_q2)
      Define.f _x,_y,_z,_w
      _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
      _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
      _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
      _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)
      _q1\x = _x
      _q1\y = _y
      _q1\z = _z
      _q1\w = _w
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; QUATERNION MULTIPLY BY SCALAR
  ;------------------------------------------------------------------
  Macro MultiplyByScalar(_out,_q1,_s)
    _out\x = _q1\x*_s
    _out\y = _q1\y*_s
    _out\z = _q1\z*_s
    _out\w = _q1\w*_s
  EndMacro
  
  Macro MultiplyByScalarInPlace(_q1,_s)
    _q1\x * _s
    _q1\y * _s
    _q1\z * _s
    _q1\w * _s
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION TRACK BALL
  ;------------------------------------------------------------------
  Macro TrackBall(_q,_p1x,_p1y,_p2x,_p2y)
    Define _axis.v3f32
    Define _phi.f
    Define _p1.v3f32, _p2.v3f32, _d.v3f32
    Define _t.f
    
    If _p1x = _p2x And _p1y = _p2y
      Quaternion::SetIdentity(_q) ;Zero Rotation
    Else
      ;First, figure out z-coordinate for projection of p1 and p2 to deformed sphere
      Vector3::Set(_p1,_p1x,_p1y,ProjectToSphere(Quaternion::#TRACKBALLSIZE,_p1x,_p1y))
      Vector3::Set(_p2,_p2x,_p2y,ProjectToSphere(Quaternion::#TRACKBALLSIZE,_p2x,_p2y))
      
      ;Now we want the cross product of p1 and p2 which is our axis of rotation
      Vector3::Cross(_axis,_p2,_p1)
      
      ;Figure out how much to rotate around that axis
      Vector3::Sub(_d,_p1,_p2)
      _t = Vector3::Length(_d) / (2.0 * Quaternion::#TRACKBALLSIZE)
      
      ;Avoid Problems with out-of_control values
      If _t>1.0 : _t =1.0
      ElseIf _t< -1.0 : _t= -1.0
      EndIf
      
      _phi = 2.0*ASin(_t)
      SetFromAxisAngle(_q,_axis,_phi)
    EndIf
  EndMacro

  ;------------------------------------------------------------------
  ; QUATERNION ADD
  ;------------------------------------------------------------------
  Macro Add(_out,_q1,_q2)
    Static _count.i=0
    Define _v1.v3f32, _v2.v3f32, _v3.v3f32, _v4.v3f32
    Define _w.f, _d.f
    
    Vector3::Set(_v1,_q1\x,_q1\y,_q1\z)
    Vector3::Set(_v2,_q2\x,_q2\y,_q2\z)
    Vector3::Cross(_v3,_v1,_v2)
    _d = Vector3::Dot(_v1,_v2)
    
    Vector3::ScaleInPlace(_v1,_q2\w)
    Vector3::ScaleInPlace(_v2,_q1\w)
    
    Vector3::Add(_v4,_v1,_v2)
    Vector3::AddInPlace(_v4,_v3)
    Quaternion::Set(_out,_v4\x,_v4\y,_v4\z,_q1\w * _q2\w - _d)
    
    If (_count+1 > Quaternion::#RENORMCOUNT)
      _count = 0
      Quaternion::NormalizeInPlace(_out)
    EndIf
  EndMacro
  
  Macro AddInPlace(_q,_o)
    Define _t.q4f32
    Quaternion::Set(_t,_q\x,_q\y,_q\z,_q\w)
    Quaternion::Add(_q,_t,_o)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION LOOKAT
  ;------------------------------------------------------------------
  Macro LookAt(_q,_dir,_up,_transpose)
    Define _m.m3f32
    Matrix3::SetFromTwoVectors(_m,_dir,_up)
    Matrix3::GetQuaternion(_m,_q,_transpose)   
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION LINEAR INTERPOLATE
  ;------------------------------------------------------------------
  Macro LinearInterpolate(_out,_q1,_q2,_b)
    _out\x = (1-_b) * _q1\x + _b * _q2\x
    _out\y = (1-_b) * _q1\y + _b * _q2\y
    _out\z = (1-_b) * _q1\z + _b * _q2\z
    _out\w = (1-_b) * _q1\w + _b * _q2\w
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION RANDOMIZE
  ;------------------------------------------------------------------
  Macro Randomize(_q)
    Define _x.f,_y.f,_z.f
    _x = Random(255)/255.0
    _y = Random(255)/255.0
    _z = Random(255)/255.0
    Quaternion::Set(_q,
                    Sqr(_x*Cos(#F32_2PI*_z)),
                    Sqr(1-_x*Sin(#F32_2PI*_y)),
                    Sqr(1-_x*Cos(#F32_2PI*_y)), 
                    Sqr(_x*Sin(#F32_2PI*_z)))
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION RANDOMIZE 2
  ;------------------------------------------------------------------
  Macro Randomize2(_q)
    Define.v2f32 _p0,_p1
    Define _d1.f = UniformPointOnDisc(_p1) + #F32_EPS
    Define _s1.f = 1/Sqr(_d1)
    Define _d0 = UniformPointOnDisc(_p0);  // or positive in 'x' since -Q & Q are equivalent
    Define _s0.f = Sqr(1.0-_d0)
    Define _s.f  = _s0*_s1
  
    Quaternion::Set(_q, _p0\y, _s*_p1\x, _s*_p1\y, _p0\x)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION RANDOMIZE AROUND AXIS
  ;------------------------------------------------------------------
  Macro RandomizeAroundAxis(_q, _axis)
    Define _p.v2f32
    UniformPointOnCircle(_p)
    Set(_q, _p\y * _axis\x, _p\y * _axis\y, _p\y * _axis\z, _p\x)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION RANDOMIZE AROUND PLANE
  ;------------------------------------------------------------------
  Macro RandomizeAroundPlane(_q)
    Define _p
    Define _d.f = UniformPointOnDisc2(_p)
    Define _s.f = Sqr(d)
    Quaternion::Set(_q, _p\x, _p\y, 0.0, _s)
  EndMacro
 
  ;------------------------------------------------------------------
  ; QUATERNION SLERP
  ;------------------------------------------------------------------
;   CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
;     Declare Slerp( *out.q4f32, *q1.q4f32, *q2.q4f32, blend.f)
;   CompilerElse
    Macro Slerp(_out,_q1,_q2,_blend)
      If blend<0
        Quaternion::SetFromOther(_out,_q1)
      ElseIf blend>=1
        Quaternion::SetFromOther(_out,_q2)
      Else
        Define _dotproduct.f = _q1\x * _q2\x + _q1\y * _q2\y + _q1\z * _q2\z + _q1\w * _q2\w
        Define.f _theta, _st,_sut, _sout, _coeff1, _coeff2
        
        _blend * 0.5
        
        _theta = ACos(_dotproduct)
        If _theta<0 : _theta * -1 :EndIf
        
        _st = Sin(_theta)
        _sut = Sin(_blend*_theta)
        _sout = Sin((1-_blend)*_theta)
        _coeff1 = _sout/_st
        _coeff2 = _sut/_st
        
        _out\x = _coeff1 * _q1\x + _coeff2 * _q2\x
        _out\y = _coeff1 * _q1\y + _coeff2 * _q2\y
        _out\z = _coeff1 * _q1\z + _coeff2 * _q2\z
        _out\w = _coeff1 * _q1\w + _coeff2 * _q2\w
      EndIf
    EndMacro
;   CompilerEndIf
  

  ;------------------------------------------------------------------
  ; QUATERNION ECHO
  ;------------------------------------------------------------------
  Macro Echo(_q,_prefix)
    Debug _prefix+"("+
          StrF(_q\x,Math::#ECHO_PRECISION)+","+
          StrF(_q\y,Math::#ECHO_PRECISION)+","+
          StrF(_q\z,Math::#ECHO_PRECISION)+","+
          StrF(_q\w,Math::#ECHO_PRECISION)+")"
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_q)
    ProcedureReturn StrF(_q\w)+","+StrF(_q\x)+","+StrF(_q\y)+","+StrF(_q\z)
  EndMacro
  
  ;------------------------------------------------------------------
  ; QUATERNION FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_q, _s)
    If CountString(_s,",")=3
      _q\w = ValF(StringField(_s,1,","))
      _q\x = ValF(StringField(_s,2,","))
      _q\y = ValF(StringField(_s,3,","))
      _q\z = ValF(StringField(_s,4,","))
    EndIf
  EndMacro
  
  Declare.f ProjectToSphere(r.f,x.f,y.f)

EndDeclareModule

;====================================================================
; Color Module Declaration
;====================================================================
DeclareModule Color
  UseModule Math
  #C4F32_SIZE = 16
  DataSection
    COLOR_RED:
    Data.f 1,0,0,1
    COLOR_GREEN:
    Data.f 0,1,0,1
    COLOR_BLUE:
    Data.f 0,0,1,1
    COLOR_YELLOW:
    Data.f 1,1,0,1
    COLOR_PURPLE:
    Data.f 0,1,1,1
    COLOR_MAGENTA:
    Data.f 1,0,1,1
    COLOR_BLACK:
    Data.f 0,0,0,1
    COLOR_WHITE:
    Data.f 1,1,1,1
  EndDataSection
  
  Macro _RED()
    Color::?COLOR_RED
  EndMacro
  
  Macro _GREEN()
    Color::?COLOR_GREEN
  EndMacro
  
  Macro _BLUE()
    Color::?COLOR_BLUE
  EndMacro
  
  Macro _YELLOW()
    Color::?COLOR_YELLOW
  EndMacro
  
  Macro _PURPLE()
    Color::?COLOR_PURPLE
  EndMacro
  
  Macro _MAGENTA()
    Color::?COLOR_MAGENTA
  EndMacro
  
  Macro _WHITE()
    Color::?COLOR_WHITE
  EndMacro
  
  Macro _BLACK()
    Color::?COLOR_BLACK
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR ADD IN PLACE
  ;------------------------------------------------------------------
  Macro AddInplace(_c1,_c2)
    _c1\r + _c2\r
    _c1\g + _c2\g
    _c1\b + _c2\b
    _c1\a + _c2\a
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR ADD
  ;------------------------------------------------------------------
  Macro Add(_io,_a,_b)
    _io\r = _a\r + _b\r
    _io\g = _a\g + _b\g
    _io\b = _a\b + _b\b
    _io\a = _a\a + _b\a
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR SET
  ;------------------------------------------------------------------
  Macro Set(_io,_r,_g,_b,_a)
    _io\r = _r
    _io\g = _g
    _io\b = _b
    _io\a = _a
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR RESET
  ;------------------------------------------------------------------
  Macro Reset(_io,_r,_g,_b,_a)
    _io\r = 0
    _io\g = 0
    _io\b = 0
    _io\a = 1
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_c1,_c2)
    _c1\r = _c2\r
    _c1\g = _c2\g
    _c1\b = _c2\b
    _c1\a = _c2\a
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR NORMALIZE
  ;------------------------------------------------------------------
  Macro Normalize(_io,_c)
    
    Define l.f = Vector3::Length(_c)
    ;Avoid error dividing by zero
    If _l = 0 : _l =1.0 :EndIf
    
    Define _div.f = 1/_l
    _io\r = _c\r * _div
    _io\g = _c\g * _div
    _io\b = _c\b * _div
    _io\a = _c\a
  EndMacro
  
   
  ;------------------------------------------------------------------
  ; COLOR NORMALIZE IN PLACE
  ;------------------------------------------------------------------
  Macro NormalizeInPlace(_c)
    Define _l.f = Vector3::Length(_c)
    
    ;Avoid error dividing by zero
    If _l = 0 : _l =1.0 :EndIf
    
    Define _div.f = 1/_l
    _c\r * _div
    _c\g * _div
    _c\b * _div
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR RANDOMIZE
  ;------------------------------------------------------------------
  Macro Randomize(_c)
    Define _invf.f = 1 / 65535.0
    _c\r = Random(65535)*_invf
    _c\g = Random(65535)*_invf
    _c\b = Random(65535)*_invf
    _c\a = 1.0
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR RANDOMIZE LUMINOSITY
  ;------------------------------------------------------------------
  Macro RandomLuminosity(_c,_min,_max)
    Define _v.f = Random(255)/255.0 
    _c\r = _v 
    _c\g = _v
    _c\b = _v 
    _c\a = 1.0
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR LINEAR INTERPOLATE
  ;------------------------------------------------------------------
  Macro LinearInterpolate(_io, _c1, _c2, _blend)
    LINEAR_INTERPOLATE(_io\r, _c1\r, _c2\r, _blend)
    LINEAR_INTERPOLATE(_io\g, _c1\g, _c2\g, _blend)
    LINEAR_INTERPOLATE(_io\b, _c1\b, _c2\b, _blend)
    LINEAR_INTERPOLATE(_io\a, _c1\a, _c2\a, _blend)
  EndMacro
  
  Macro MapRGB(_io, _r, _g, _b, _a, _x)
    Define _alpha.f = Mod(_x,1)/3.0
    
;     def RGB(minimum, maximum, value):
;     minimum, maximum = float(minimum), float(maximum)
;     ratio = 2 * (value-minimum) / (maximum - minimum)
;     b = Int(max(0, 255*(1 - ratio)))
;     r = Int(max(0, 255*(ratio - 1)))
;     g = 255 - b - r
;     Return r, g, b
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR ECHO
  ;------------------------------------------------------------------
  Macro Echo(_c,prefix)
    Debug prefix + ": "+
          StrF(_c\r, Math::#ECHO_PRECISION)+","+
          StrF(_c\g, Math::#ECHO_PRECISION)+","+
          StrF(_c\b, Math::#ECHO_PRECISION)+","+
          StrF(_c\a, Math::#ECHO_PRECISION)
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_c)
    StrF(_c\r)+","+StrF(_c\g)+","+StrF(_c\b)+","+StrF(_c\a)
  EndMacro
  
  ;------------------------------------------------------------------
  ; COLOR FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_c, _s)
    If CountString(_s,",")=3
      _c\r = ValF(StringField(_s,1,","))
      _c\g = ValF(StringField(_s,2,","))
      _c\b = ValF(StringField(_s,3,","))
      _c\a = ValF(StringField(_s,4,","))
    EndIf
  EndMacro
  
  Declare.l PackColor(*c.c4f32)
  Declare.f PackColorAsFloat(*c.c4f32)
  Declare UnpackColor(*c.c4f32, code.l)
  Declare UnpackColorAsFloat(*c.c4f32, code.f)
 
EndDeclareModule

;====================================================================
; Matrix3 Module Declaration
;====================================================================
DeclareModule Matrix3
  UseModule Math
  
  #M3F32_SIZE = 36
  
  ;------------------------------------------------------------------
  ; MATRIX3 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_m)
    Debug  "Matrix3*3("+
           StrF(_m\v[0], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[1], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[2], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[3], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[4], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[5], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[6], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[7], Math::#ECHO_PRECISION)+","+
           StrF(_m\v[8], Math::#ECHO_PRECISION)+")"
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_m)
    StrF(_m\v[0], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[1], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[2], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[3], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[4], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[5], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[6], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[7], Math::#ECHO_PRECISION)+","+
    StrF(_m\v[8], Math::#ECHO_PRECISION)
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_m, _s)
    If CountString(_s,",")=8
      Define _i
      For _i=0 To 8 : _m\v[_i] = ValF(StringField(_s,_i+1,",")) : Next
    EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 SET
  ;------------------------------------------------------------------
  Macro Set(_m,_m00,_m01,_m02,_m10,_m11,_m12,_m20,_m21,_m22)
    _m\v[0] = _m00
    _m\v[1] = _m01
    _m\v[2] = _m02
    _m\v[3] = _m10
    _m\v[4] = _m11
    _m\v[5] = _m12
    _m\v[6] = _m20
    _m\v[7] = _m21
    _m\v[8] = _m22
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 SET IDENTITY
  ;------------------------------------------------------------------
  Macro SetIdentity(_m)
    _m\v[0] = 1.0
    _m\v[1] = 0.0
    _m\v[2] = 0.0
    _m\v[3] = 0.0
    _m\v[4] = 1.0
    _m\v[5] = 0.0
    _m\v[6] = 0.0
    _m\v[7] = 0.0
    _m\v[8] = 1.0
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_m,_o)
    Define _i
    For _i=0 To 8
      _m\v[_i] = _o\v[_i]
    Next _i
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 SET FROM TWO VECTORS
  ;------------------------------------------------------------------
  Macro SetFromTwoVectors(_m,_dir,_up)
    Define _N.v3f32
    Vector3::Normalize(_N, _dir)
    Define _U.v3f32
    Vector3::Cross(_U, _up, _N)
    Vector3::NormalizeInPlace(_U)
    Define _V.v3f32
    Vector3::Cross(_V, _N, _U)
    Vector3::NormalizeInPlace(_V)
    
    _m\v[0] = _V\x : _m\v[1] = _V\y : _m\v[2] = _V\z
    _m\v[3] = _N\x : _m\v[4] = _N\y : _m\v[5] = _N\z
    _m\v[6] = _U\x : _m\v[7] = _U\y : _m\v[8] = _U\z
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 SET FROM QUATERNION
  ;------------------------------------------------------------------
  Macro SetFromQuaternion(_m,_q)
    Define _qn.f, _qs.f
    Define _qxs.f, _qys.f, _qzs.f
    Protected _qwx.f, _qwy.f, _qwz.f
    Protected _qxx.f, _qxy.f, _qxz.f
    Protected _qyy.f, _qyz.f, _qzz.f
    
    _qn = (_q\x * _q\x) + (_q\y * _q\y) + (_q\z * _q\z) + (_q\w * _q\w)
    If _qn>0
      _qs = 2/_qn
    Else
      _qs = 0
    EndIf
    
    _qxs = _q\x * _qs  : _qys = _q\y * _qs  : _qzs = _q\z * _qs
    _qwx = _q\w * _qxs : _qwy = _q\w * _qys : _qwz = _q\w * _qzs
    _qxx = _q\x * _qxs : _qxy = _q\x * _qys : _qxz = _q\x * _qzs
    _qyy = _q\y * _qys : _qyz = _q\y * _qzs : _qzz = _q\z * _qzs
    
    _m\v[0] = 1 - (_qyy + _qzz) : _m\v[3] = _qxy - _qwz     : _m\v[6] = _qxz + _qwy
    _m\v[1] = _qxy + _qwz       : _m\v[4] = 1- (_qxx +_qzz) : _m\v[7] = _qyz - _qwx
    _m\v[2] = _qxz - _qwy       : _m\v[5] = _qyz + _qwx     : _m\v[8] = 1 - (_qxx + _qyy)
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 MULTIPLY BY MATRIX3 IN PLACE
  ;------------------------------------------------------------------
  Macro MulByMatrix3InPlace(_m,_o)
    Define _tmp_m3.m3f32
    _tmp_m3\v[0] = _m\v[0] * _o\v[0] + _m\v[1] * _o\v[3] + _m\v[2] * _o\v[6]
    _tmp_m3\v[1] = _m\v[0] * _o\v[1] + _m\v[1] * _o\v[4] + _m\v[2] * _o\v[7]
    _tmp_m3\v[2] = _m\v[0] * _o\v[2] + _m\v[1] * _o\v[5] + _m\v[2] * _o\v[8]
    
    _tmp_m3\v[3] = _m\v[3] * _o\v[0] + _m\v[4] * _o\v[3] + _m\v[5] * _o\v[6]
    _tmp_m3\v[4] = _m\v[3] * _o\v[1] + _m\v[4] * _o\v[4] + _m\v[5] * _o\v[7]
    _tmp_m3\v[5] = _m\v[3] * _o\v[2] + _m\v[4] * _o\v[5] + _m\v[5] * _o\v[8]
    
    _tmp_m3\v[6] = _m\v[6] * _o\v[0] + _m\v[7] * _o\v[3] + _m\v[8] * _o\v[6]
    _tmp_m3\v[7] = _m\v[6] * _o\v[1] + _m\v[7] * _o\v[4] + _m\v[8] * _o\v[7]
    _tmp_m3\v[8] = _m\v[6] * _o\v[2] + _m\v[7] * _o\v[5] + _m\v[8] * _o\v[8]
    
    Matrix3::Set(_m,_tmp_m3\v[0],_tmp_m3\v[1],_tmp_m3\v[2],
                    _tmp_m3\v[3],_tmp_m3\v[4],_tmp_m3\v[5],
                    _tmp_m3\v[6],_tmp_m3\v[7],_tmp_m3\v[8])
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 MULTIPLY BY MATRIX3
  ;------------------------------------------------------------------
  Macro MulByMatrix3(_m,_f,_s)
    _m\v[0] = _f\v[0] * _s\v[0] + _f\v[1] * _s\v[3] + _f\v[2] * _s\v[6]
    _m\v[1] = _f\v[0] * _s\v[1] + _f\v[1] * _s\v[4] + _f\v[2] * _s\v[7]
    _m\v[2] = _f\v[0] * _s\v[2] + _f\v[1] * _s\v[5] + _f\v[2] * _s\v[8]
    
    _m\v[3] = _f\v[3] * _s\v[0] + _f\v[4] * _s\v[3] + _f\v[5] * _s\v[6]
    _m\v[4] = _f\v[3] * _s\v[1] + _f\v[4] * _s\v[4] + _f\v[5] * _s\v[7]
    _m\v[5] = _f\v[3] * _s\v[2] + _f\v[4] * _s\v[5] + _f\v[5] * _s\v[8]
    
    _m\v[6] = _f\v[6] * _s\v[0] + _f\v[7] * _s\v[3] + _f\v[8] * _s\v[6]
    _m\v[7] = _f\v[6] * _s\v[1] + _f\v[7] * _s\v[4] + _f\v[8] * _s\v[7]
    _m\v[8] = _f\v[6] * _s\v[2] + _f\v[7] * _s\v[5] + _f\v[8] * _s\v[8]
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 GET QUATERNION
  ;------------------------------------------------------------------
  Macro GetQuaternion(_m,_q,_transpose)
    Define _t.f
    Define _s.f
    
    If _transpose
      _t = 1+_m\v[0]+_m\v[4]+_m\v[8]
      If _t >0.00000001
        _s = Sqr(_t)*2
        _q\x = (_m\v[7]-_m\v[5])/_s
        _q\y = (_m\v[2]-_m\v[6])/_s
        _q\z = (_m\v[3]-_m\v[1])/_s
        _q\w = 0.25 * _s 
      Else
        
        If _m\v[0]>_m\v[4] And _m\v[0]>_m\v[8]
          _s = Sqr(1+ _m\v[0] - _m\v[4] - _m\v[8])*2
          _q\x = 0.25 * _s
          _q\y = (_m\v[3] + _m\v[1])/_s
          _q\z = (_m\v[2] + _m\v[6])/_s
          _q\w = (_m\v[7] - _m\v[5])/_s
        ElseIf _m\v[4]>_m\v[8]
          _s = Sqr(1+ _m\v[4] - _m\v[0] - _m\v[8])*2
          _q\x = (_m\v[3] + _m\v[1])/_s
          _q\y = 0.25 * _s
          _q\z = (_m\v[7] + _m\v[5])/_s
          _q\w = (_m\v[2] - _m\v[6])/_s
        Else
          _s = Sqr(1+ _m\v[8] - _m\v[0] - _m\v[4])*2
          _q\x = (_m\v[2] + _m\v[6])/_s
          _q\y = (_m\v[7] + _m\v[5])/_s
          _q\z = 0.25 * _s
          _q\w = (_m\v[3] - _m\v[1])/_s
        EndIf
      EndIf
    Else
  
      _t = 1+_m\v[0]+_m\v[4]+_m\v[8]
      If _t >0.00000001
        _s = Sqr(_t)*2
        _q\x = (_m\v[5]-_m\v[7])/_s
        _q\y = (_m\v[6]-_m\v[2])/_s
        _q\z = (_m\v[1]-_m\v[3])/_s
        _q\w = 0.25 * _s 
      Else
        If _m\v[0]>_m\v[4] And _m\v[0]>_m\v[8]
          _s = Sqr(1+ _m\v[0] - _m\v[4] - _m\v[8])*2
          _q\x = 0.25 * _s
          _q\y = (_m\v[1] + _m\v[3])/_s
          _q\z = (_m\v[6] + _m\v[2])/_s
          _q\w = (_m\v[5] - _m\v[7])/_s
        ElseIf _m\v[4]>_m\v[8]
          _s = Sqr(1+ _m\v[4] - _m\v[0] - _m\v[8])*2
          _q\x = (_m\v[1] + _m\v[3])/_s
          _q\y = 0.25 * _s
          _q\z = (_m\v[5] + _m\v[7])/_s
          _q\w = (_m\v[6] - _m\v[2])/_s
        Else
          _s = Sqr(1+ _m\v[8] - _m\v[0] - _m\v[4])*2
          _q\x = (_m\v[6] + _m\v[2])/_s
          _q\y = (_m\v[5] + _m\v[7])/_s
          _q\z = 0.25 * _s
          _q\w = (_m\v[1] - _m\v[3])/_s
        EndIf
      EndIf
    EndIf  
  EndMacro
  
  Declare.b Inverse(*m.m3f32, *o.m3f32)
  Declare.b InverseInPlace(*m.m3f32)

EndDeclareModule

;====================================================================
; Matrix4 Module Declaration
;====================================================================
DeclareModule Matrix4
  UseModule Math
  
  #M4F32_SIZE = 64
  
  DataSection
    M_IDENTITY:
    Data.f 1.0,0.0,0.0,0.0
    Data.f 0.0,1.0,0.0,0.0
    Data.f 0.0,0.0,1.0,0.0
    Data.f 0.0,0.0,0.0,1.0
  EndDataSection
  
  ;------------------------------------------------------------------
  ; MATRIX4 IDENTITY
  ;------------------------------------------------------------------
  Macro IDENTITY()
    Matrix4::?M_IDENTITY
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_m,_name)
    Debug _name+" :Matrix4*4("+
          StrF(_m\v[0],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[1],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[2],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[3],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[4],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[5],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[6],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[7],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[8],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[9],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[10],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[11],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[12],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[13],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[14],Math::#ECHO_PRECISION)+","+
          StrF(_m\v[15],Math::#ECHO_PRECISION)+")"
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX4 AS STRING
  ;------------------------------------------------------------------
  Macro ToString(_m)
    StrF(_m\v[0],3)+","+
    StrF(_m\v[1],3)+","+
    StrF(_m\v[2],3)+","+
    StrF(_m\v[3],3)+","+
    StrF(_m\v[4],3)+","+
    StrF(_m\v[5],3)+","+
    StrF(_m\v[6],3)+","+
    StrF(_m\v[7],3)+","+
    StrF(_m\v[8],3)+","+
    StrF(_m\v[9],3)+","+
    StrF(_m\v[10],3)+","+
    StrF(_m\v[11],3)+","+
    StrF(_m\v[12],3)+","+
    StrF(_m\v[13],3)+","+
    StrF(_m\v[14],3)+","+
    StrF(_m\v[15],3)
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX4 FROM STRING
  ;------------------------------------------------------------------
  Macro FromString(_m, _s)
    If CountString(_s,",") <> 15
      Matrix4::SetIdentity(_m)
    Else
      Define _i
      For _i=0 To 15
        _m\v[_i] = ValF(StringField(_s,_i+1,","))
      Next
    EndIf
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET
  ;------------------------------------------------------------------
  Macro Set(_m,_m00,_m01,_m02,_m03,_m10,_m11,_m12,_m13,_m20,_m21,_m22,_m23,_m30,_m31,_m32,_m33)
    _m\v[0] = _m00   : _m\v[1] = _m01   : _m\v[2] = _m02   : _m\v[3] = _m03
    _m\v[4] = _m10   : _m\v[5] = _m11   : _m\v[6] = _m12   : _m\v[7] = _m13
    _m\v[8] = _m20   : _m\v[9] = _m21   : _m\v[10] = _m22  : _m\v[11] = _m23
    _m\v[12] = _m30  : _m\v[13] = _m31  : _m\v[14] = _m32  : _m\v[15] = _m33
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET ZERO
  ;------------------------------------------------------------------
  Macro SetZero(_m)
    _m\v[0] = 0 : _m\v[1] = 0 : _m\v[2] = 0 : _m\v[3] = 0 
    _m\v[4] = 0 : _m\v[5] = 0 : _m\v[6] = 0 : _m\v[7] = 0 
    _m\v[8] = 0 : _m\v[9] = 0 : _m\v[10] = 0 : _m\v[11] = 0 
    _m\v[12] = 0 : _m\v[13] = 0 : _m\v[14] = 0 : _m\v[15] = 0 
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET IDENTITY
  ;------------------------------------------------------------------
  Macro SetIdentity(_m)
    Matrix4::SetZero(_m)
    _m\v[0] = 1
    _m\v[5] = 1
    _m\v[10] = 1
    _m\v[15] = 1
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET TRANSLATION
  ;------------------------------------------------------------------
  Macro SetTranslation(_m,_v)
    _m\v[12] = _v\x
    _m\v[13] = _v\y
    _m\v[14] = _v\z
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET SCALE
  ;------------------------------------------------------------------
  Macro SetScale(_m,_v)
    _m\v[0] = _v\x
    _m\v[5] = _v\y
    _m\v[10] = _v\z
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX4 SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_m,_o)
    CopyMemory(@_o\v[0], @_m\v[0], Matrix4::#M4F32_SIZE)
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 SET FROM QUATERNION
  ;------------------------------------------------------------------
  Macro SetFromQuaternion(_m,_q)
    Define.f _smfq_wx, _smfq_wy,_smfq_wz
    Define.f _smfq_xx, _smfq_yy, _smfq_yz
    Define.f _smfq_xy, _smfq_xz, _smfq_zz
    Define.f _smfq_x2, _smfq_y2, _smfq_z2
    
    ;Calculate Coefficients
    _smfq_x2 = _q\x + _q\x      : _smfq_y2 = _q\y+ _q\y             : _smfq_z2 = _q\z + _q\z
    _smfq_xx = _q\x *  _smfq_x2 : _smfq_xy = _q\x * _smfq_y2        : _smfq_xz = _q\x * _smfq_z2
    _smfq_yy = _q\y * _smfq_y2  : _smfq_yz = _q\y * _smfq_z2        : _smfq_zz = _q\z * _smfq_z2
    _smfq_wx = _q\w * _smfq_x2  : _smfq_wy = _q\w * _smfq_y2        : _smfq_wz = _q\w * _smfq_z2
    
    _m\v[0] = 1-(_smfq_yy+_smfq_zz) : _m\v[1] = _smfq_xy-_smfq_wz       : _m\v[2] = _smfq_xz+_smfq_wy         : _m\v[3] = 0.0
    _m\v[4] = _smfq_xy + _smfq_wz   : _m\v[5] = 1 - (_smfq_xx+_smfq_zz) : _m\v[6] = _smfq_yz-_smfq_wx         : _m\v[7] = 0.0
    _m\v[8] = _smfq_xz - _smfq_wy   : _m\v[9] = _smfq_yz + _smfq_wx     : _m\v[10] = 1 - (_smfq_xx+_smfq_yy)  : _m\v[11] = 0.0
    _m\v[12] = 0                    : _m\v[13] = 0                      : _m\v[14] = 0                        : _m\v[15] = 1.0
  EndMacro


  ;------------------------------------------------------------------
  ; MATRIX4 MULTIPLY
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Multiply(*m.m4f32, *f.m4f32, *s.m4f32)
  CompilerElse
    Macro Multiply(_m,_f,_s)
      _m\v[0]   = _s\v[0] * _f\v[0] + _s\v[1] * _f\v[4]+ _s\v[2]  * _f\v[8] + _s\v[3] * _f\v[12]
      _m\v[4]   = _s\v[4] * _f\v[0] + _s\v[5] * _f\v[4]+ _s\v[6]  * _f\v[8] + _s\v[7] * _f\v[12]
      _m\v[8]   = _s\v[8] * _f\v[0] + _s\v[9] * _f\v[4]+ _s\v[10] * _f\v[8] + _s\v[11]* _f\v[12]
      _m\v[12]  = _s\v[12]* _f\v[0] + _s\v[13]* _f\v[4]+ _s\v[14] * _f\v[8] + _s\v[15]* _f\v[12] 
      
      _m\v[1]   = _s\v[0] * _f\v[1] + _s\v[1] * _f\v[5]+ _s\v[2] * _f\v[9] + _s\v[3] * _f\v[13]
      _m\v[5]   = _s\v[4] * _f\v[1] + _s\v[5] * _f\v[5]+ _s\v[6] * _f\v[9] + _s\v[7] * _f\v[13]
      _m\v[9]   = _s\v[8] * _f\v[1] + _s\v[9] * _f\v[5]+ _s\v[10]* _f\v[9] + _s\v[11]* _f\v[13]
      _m\v[13]  = _s\v[12]* _f\v[1] + _s\v[13]* _f\v[5]+ _s\v[14]* _f\v[9] + _s\v[15]* _f\v[13]
      
      _m\v[2]   = _s\v[0] * _f\v[2] + _s\v[1] * _f\v[6] + _s\v[2] * _f\v[10] + _s\v[3] * _f\v[14]
      _m\v[6]   = _s\v[4] * _f\v[2] + _s\v[5] * _f\v[6] + _s\v[6] * _f\v[10] + _s\v[7] * _f\v[14]
      _m\v[10]  = _s\v[8] * _f\v[2] + _s\v[9] * _f\v[6] + _s\v[10]* _f\v[10] + _s\v[11]* _f\v[14]
      _m\v[14]  = _s\v[12]* _f\v[2] + _s\v[13]* _f\v[6] + _s\v[14]* _f\v[10] + _s\v[15]* _f\v[14]
      
      _m\v[3]   = _s\v[0] * _f\v[3] + _s\v[1] * _f\v[7]+ _s\v[2] * _f\v[11] + _s\v[3] * _f\v[15]
      _m\v[7]   = _s\v[4] * _f\v[3] + _s\v[5] * _f\v[7]+ _s\v[6] * _f\v[11] + _s\v[7] * _f\v[15]
      _m\v[11]  = _s\v[8] * _f\v[3] + _s\v[9] * _f\v[7]+ _s\v[10]* _f\v[11]  + _s\v[11]* _f\v[15]
      _m\v[15]  = _s\v[12]* _f\v[3] + _s\v[13]* _f\v[7]+ _s\v[14]* _f\v[11]  + _s\v[15]* _f\v[15]  
    EndMacro
  CompilerEndIf
  
  ;------------------------------------------------------------------
  ; MATRIX4 MULTIPLY IN PLACE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare MultiplyInPlace(*m.m4f32, *o.m4f32)
  CompilerElse
    Macro MultiplyInPlace(_m,_o)
      Define.m4f32 _mm4_tmp
      Matrix4::Multiply(_mm4_tmp, _m, _o)
      CopyMemory(_mm4_tmp, _m, #M4F32_SIZE)
    EndMacro
  CompilerEndIf
  

  ;------------------------------------------------------------------
  ; MATRIX4 ROTATE X
  ;------------------------------------------------------------------
  Macro RotateX(_m,_x)
    Define _mm4_tmp.m4f32
    Matrix4::SetIdentity(_mm4_tmp)
    _mm4_tmp\v[5] = Cos(Radian(_x))
    _mm4_tmp\v[6] = Sin(Radian(_x))
    _mm4_tmp\v[9] = -Sin(Radian(_x))
    _mm4_tmp\v[10] = Cos(Radian(_x))
    Matrix4::MultiplyInPlace(_m,_mm4_tmp)
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 ROTATE Y
  ;------------------------------------------------------------------
  Macro RotateY(_m,_y)
    Define __mm4_tmp.m4f32
    Matrix4::SetIdentity(__mm4_tmp)
    __mm4_tmp\v[0] = Cos(Radian(_y))
    __mm4_tmp\v[2] = -Sin(Radian(_y))
    __mm4_tmp\v[8] = Sin(Radian(_y))
    __mm4_tmp\v[10] = Cos(Radian(_y))
    
    Matrix4::MultiplyInPlace(_m,__mm4_tmp)
  EndMacro
  
  
  ;------------------------------------------------------------------
  ; MATRIX4 ROTATE Z
  ;------------------------------------------------------------------
  Macro RotateZ(_m,_z)
    Define __mm4_tmp.m4f32
    Matix4::SetIdentity(__mm4_tmp)
    __mm4_tmp\v[0] = Cos(Radian(_z))
    __mm4_tmp\v[1] = Sin(Radian(_z))
    __mm4_tmp\v[4] = -Sin(Radian(_z))
    __mm4_tmp\v[5] = Cos(Radian(_z))
    Matrix4::MultiplyInPlace(_m,_tmp)
  EndMacro

  ;------------------------------------------------------------------
  ; MATRIX4 TRANSPOSE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Declare Transpose(*m.m4f32, *o.m4f32)
    Declare TransposeInPlace(*m.m4f32)
  CompilerElse
    
    Macro Transpose(_m,_o)
      _m\v[0] = _o\v[0]
      _m\v[4] = _o\v[1]
      _m\v[8] = _o\v[2]
      _m\v[12] = _o\v[3]
      
      _m\v[1] = _o\v[4]
      _m\v[5] = _o\v[5]
      _m\v[9] = _o\v[6]
      _m\v[13] = _o\v[7]
      
      _m\v[2] = _o\v[8]
      _m\v[6] = _o\v[9]
      _m\v[10] = _o\v[10]
      _m\v[14] = _o\v[11]
      
      _m\v[3] = _o\v[12]
      _m\v[7] = _o\v[13]
      _m\v[11] = _o\v[14]
      _m\v[15] = _o\v[15]
    EndMacro
    
    Macro TransposeInPlace(_m)
      Define _m4_tmp.m4f32
      Matrix4::Transpose(_m4_tmp,_m)
      Matrix4::SetFromOther(_m,_m4_tmp)
    EndMacro
  CompilerEndIf
 
  ;-------------------------------------------
  ; MATRIX4 TRANSPOSE INVERSE
  ;-------------------------------------------
  Macro TransposeInverse(_m,_o)
    Define _m4_tmp.m4f32
    If Matrix4::ComputeInverse(@_m4_tmp,@_o,#True)
      Matrix4::SetFromOther(_m,_m4_tmp)
    EndIf
  EndMacro
  
  Macro TransposeInverseInPlace(_m)
    Matrix4::TransposeInverse(_m,_m)
  EndMacro

  ;-------------------------------------------
  ; Compute the Projection Matrix
  ;-------------------------------------------
  Macro GetProjectionMatrix(_m,_fov,_aspect,_znear,_zfar)
    Define _m4_invf.f = 1 / Tan(Radian(_fov)*0.5)
    Maximum(_znear,0.000001)
    Matrix4::SetIdentity(_m)

    _m\v[0] = _m4_invf/_aspect
    _m\v[5] = _m4_invf
    _m\v[10] = (_zfar+_znear)/(_znear-_zfar)
    _m\v[14] = (2*_zfar*_znear)/(_znear-_zfar)
    _m\v[11] = -1
    _m\v[15] = 0
  EndMacro

  ;---------------------------------------------
  ; Get Ortho Matrix
  ;---------------------------------------------
  Macro GetOrthoMatrix(_m,_left,_right,_bottom,_top,_znear,_zfar)
    Matrix4::SetIdentity(_m)
    _m\v[0] = 2/(_right-_left)
    _m\v[5] = 2/(_top-_bottom)
    _m\v[10] = -2/(_zfar-_znear)
    _m\v[12] = -(_right+_left)/(_right-_left)
    _m\v[13] = -(_top+_bottom)/(_top-_bottom)
    _m\v[14] = -(_zfar+_znear)/(_zfar-_znear)
  EndMacro

  ;---------------------------------------------
  ; Get View Matrix
  ;---------------------------------------------
  Macro GetViewMatrix(_io,_pos,_lookat,_up)
    Define.v3f32 _m4_side,_m4_up,_m4_dir
    
    ; Calculate Orientation
    Vector3::Sub(_m4_dir,_lookat,_pos)
    Vector3::NormalizeInPlace(_m4_dir)
    Vector3::Cross(_m4_side,_m4_dir,_up)
    Vector3::NormalizeInPlace(_m4_side)
    Vector3::Cross(_m4_up,_m4_side,_m4_dir)
    Vector3::NormalizeInPlace(_m4_up)
    
    Define.f _m4_d1,_m4_d2,_m4_d3
    _m4_d1 = -Vector3::Dot(_m4_side,_pos)
    _m4_d2 = -Vector3::Dot(_m4_up,_pos)
    _m4_d3 = Vector3::Dot(_m4_dir,_pos)
    
    Define _m4_tmp.m4f32
    _m4_tmp\v[0] = _m4_side\x : _m4_tmp\v[1]   = _m4_up\x   :_m4_tmp\v[2]  = -_m4_dir\x : _m4_tmp\v[3]  = 0 
    _m4_tmp\v[4] = _m4_side\y : _m4_tmp\v[5]   = _m4_up\y   :_m4_tmp\v[6]  = -_m4_dir\y : _m4_tmp\v[7]  = 0 
    _m4_tmp\v[8] = _m4_side\z : _m4_tmp\v[9]   = _m4_up\z   :_m4_tmp\v[10] = -_m4_dir\z : _m4_tmp\v[11] = 0 
    _m4_tmp\v[12] = _m4_d1    : _m4_tmp\v[13]  = _m4_d2     :_m4_tmp\v[14] = _m4_d3     : _m4_tmp\v[15] = 1 
    
    Matrix4::SetFromOther(_io,_m4_tmp)
  EndMacro
  
  ;-------------------------------------------
  ; Get Quaternion
  ;-------------------------------------------
  Macro GetQuaternion(_m,_q)
    Define.f _qx,_qy,_qz,_qw,_qw4
    Define _tr.f = _m\v[0] + _m\v[5] + _m\v[10]
    
    Define _S.f
    If _tr > 0
      _S = Sqr(_tr+1.0) * 2
      _qw = 0.25 * _S
      _qx = (_m\v[9] - _m\v[6]) / _S
      _qy = (_m\v[2] - _m\v[8]) / _S
      _qz = (_m\v[4] - _m\v[1]) / _S
    ElseIf (_m\v[0] > _m\v[5])And(_m\v[0] > _m\v[10])
      _S = Sqr(1.0 + _m\v[0] - _m\v[5] - _m\v[10]) * 2
      _qw = (_m\v[9] - _m\v[6]) / _S
      _qx = 0.25 * _S
      _qy = (_m\v[1] + _m\v[4]) / _S
      _qz = (_m\v[2] + _m\v[8]) / _S
    ElseIf (_m\v[5] > _m\v[10])
      _S = Sqr(1.0 + _m\v[5] - _m\v[0] - _m\v[10]) * 2
      _qw = (_m\v[2] - _m\v[8]) / _S
      _qx = (_m\v[1] + _m\v[4]) / _S
      _qy = 0.25 * _S
      _qz = (_m\v[6] + _m\v[9]) / _S
    Else
      _S = Sqr(1.0 + _m\v[10] - _m\v[0] - _m\v[5]) * 2
      _qw = (_m\v[4] - _m\v[1]) / _S
      _qx = (_m\v[2] + _m\v[8]) / _S
      _qy = (_m\v[6] + _m\v[9]) / _S
      _qz = 0.25 * _S
    EndIf
   
    ; set the rotation!
    _q\x = _qx
    _q\y = _qy
    _q\z = _qz
    _q\w = _qw
   EndMacro
  
  ;-------------------------------------------
  ; Get Translation Matrix
  ;-------------------------------------------
  Macro TranslationMatrix(_m, _pos)
    Matrix4::SetIdentity(_m)
    _m\v[12] = _pos\x
    _m\v[13] = _pos\y
    _m\v[14] = _pos\z
  EndMacro
  
  ;-------------------------------------------
  ; Get Direction Matrix
  ;-------------------------------------------
  Macro DirectionMatrix(_m, _target, _up)
    Define _N.v3f32
    Vector3::Normalize(_N, _target)
    Define _U.v3f32
    Vector3::Cross(_U, _up, _N)
    Vector3::NormalizeInPlace(_U)
    Define _V.v3f32
    Vector3::Cross(_V,_N, _U)
    Vector3::NormalizeInPlace(_V)
    
    _m\v[0] = _V\x : _m\v[1] = _V\y : _m\v[2]  = _V\z : _m\v[3] = 0
    _m\v[4] = _N\x : _m\v[5] = _N\y : _m\v[6]  = _N\z : _m\v[7] = 0
    _m\v[8] = _U\x : _m\v[9] = _U\y : _m\v[10] = _U\z : _m\v[11] = 0
    _m\v[12] = 0   : _m\v[13] = 0   : _m\v[14] = 0    : _m\v[15] = 1
    
;     *m\v[0] = U\x : *m\v[1] = V\y : *m\v[2] = N\z  : *m\v[3] = 0
;     *m\v[4] = U\x : *m\v[5] = V\y : *m\v[6] = N\z  : *m\v[7] = 0
;     *m\v[8] = U\x : *m\v[9] = V\y : *m\v[10] = N\z : *m\v[11] = 0
;     *m\v[12] = 0  : *m\v[13] = 0  : *m\v[14] = 0   : *m\v[15] = 1
    
  EndMacro
  
  Declare.b Inverse(*m.m4f32,*o.m4f32)
  Declare.b InverseInPlace(*m.m4f32)
;   Declare GetQuaternion(*m.m4f32,*q.q4f32)
  
EndDeclareModule

;====================================================================
; Transform Module Declaration
;====================================================================
DeclareModule Transform
  UseModule Math
  Structure Transform_t
    ; underlying matrix
    m.m4f32
    
    ; underlying trf32
    t.trf32
    
    ; dirty states
    srtdirty.b   
    matrixdirty.b
  EndStructure
  
  Declare Init(*t.Transform_t)
  Declare Set(*t.Transform_t,*s.v3f32,*r.q4f32,*p.v3f32)
  Declare SetFromOther(*t.Transform_t,*o.Transform_t)
  Declare ComputeLocal(*l.Transform_t,*g.Transform_t,*p.Transform_t)
  Declare SetMatrixFromSRT(*m.m4f32,*s.v3f32,*r.q4f32,*t.v3f32)
  Declare SetSRTFromMatrix(*m.m4f32,*s.v3f32,*r.q4f32,*t.v3f32)
  Declare UpdateMatrixFromSRT(*t.Transform_t)
  Declare UpdateSRTFromMatrix(*t.Transform_t)
  Declare SetTranslation(*t.Transform_t,*pos.v3f32)
  Declare SetScale(*t.Transform_t,*scl.v3f32)
  Declare SetTranslationFromXYZValues(*t.Transform_t,x.f,y.f,z.f)
  Declare SetRotationFromQuaternion(*t.Transform_t,*q.q4f32)
  Declare SetScaleFromXYZValues(*t.Transform_t,x.f,y.f,z.f)
EndDeclareModule

;====================================================================
; Math Module Implementation
;====================================================================
Module Math
  ; -----------------------------------------------------------------
  ;  Maximum
  ; -----------------------------------------------------------------
  Procedure.f Max(a.f,b.f)
    If a<b
      ProcedureReturn b
    Else
      ProcedureReturn a
    EndIf
  EndProcedure
  
  
  ; -----------------------------------------------------------------
  ;  Minimum
  ; -----------------------------------------------------------------
   Procedure.f Min(a.f,b.f)
    If a<b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;  Is Close
  ; -----------------------------------------------------------------
  Procedure.b IsClose(value.f, root.f, tolerance.f)
    If Abs(value - root) < tolerance 
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;  Uniform Point On Circle
  ; -----------------------------------------------------------------
  Procedure UniformPointOnCircle(*p.v2f32, radius.f=1.0)
    Protected angle.f = Random_0_1() * #F32_2PI 
    Vector2::Set(*p, Cos(angle) * radius, Sin(angle) * radius)
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;  Uniform Point On Disc (Rejection Method)
  ; -----------------------------------------------------------------
  Procedure.f UniformPointOnDisc(*p.v2f32, radius.f=1.0)
    Protected d.f = 1.0
    While d>=1.0
      *p\x = 2.0*Random_0_1()-1.0
      *p\y = 2.0*Random_0_1()-1.0
      d = Pow(*p\x, 2) + Pow(*p\y, 2)
    Wend
    *p\x * radius
    *p\y * radius
    ProcedureReturn Vector2::Length(*p)
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;  Uniform Point On Disc (Polar Method)
  ; -----------------------------------------------------------------
  Procedure.f UniformPointOnDisc2(*p.v2f32, radius.f=1.0)
    Protected angle.f = Random_0_1() * #F32_2PI 
    Protected r.f = Sqr(Random_0_1())
    Vector2::Set(*p, Cos(angle) * radius * r, Sin(angle) * radius * r)
    ProcedureReturn Vector2::Length(*p)
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;  Uniform Point On Sphere
  ; -----------------------------------------------------------------
  Procedure UniformPointOnSphere(*p.v3f32, radius.f=1.0)
    *p\z = 1 - 2.0 * Random_0_1()
    Protected t.f = #F32_2PI * Random_0_1()
    Protected w.f = Sqr(1.0 - Pow(*p\z, 2))
    *p\x = w * Cos(t)
    *p\y = w * Sin(t)
    Vector3::ScaleInPlace(*p, radius)
  EndProcedure
  
  ; ----------------------------------------------------------------
  ;  Map Disc Point To Sphere
  ; ----------------------------------------------------------------
  Procedure MapDiscPointToSphere(*dp.v2f32, *sp.v3f32)
    Protected w.f = Pow(*dp\x,2) + Pow(*dp\y, 2)
    Protected x.f = 2 * *dp\x * Sqr(1 - w)
    Protected y.f = 2 * *dp\y * Sqr(1 - w)
    Protected z.f = 1 - 2*w
  EndProcedure
EndModule

;====================================================================
; v2f32 Module Implementation
;====================================================================
Module Vector2
EndModule

;====================================================================
; v3f32 Module Implementation
;====================================================================
Module Vector3
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    ; ---------------------------------------------------------------
    ;  VECTOR3 ADD
    ; ---------------------------------------------------------------
    Procedure AddInPlace(*v.v3f32, *o.v3f32)
      ! mov rcx, [p.p_o]        ; move src to register
      ! mov rax, [p.p_v]        ; move dst to register
      ! movups xmm0, [rax]      ; dst packed float to xmm0
      ! movups xmm1, [rcx]      ; src packed flota to xmm1
      ! addps xmm0, xmm1        ; packed addition
      ! movups [rax], xmm0      ; move back to memory
    EndProcedure

    Procedure Add(*v.v3f32, *a.v3f32, *b.v3f32)      
      ! mov rcx, [p.p_a]        ; move point a to rcx register
      ! mov rdx, [p.p_b]        ; move point b to rdx register
      ! mov rax, [p.p_v]        ; move point v to rax register
      ! movups xmm0, [rcx]      ; point a to xmm0
      ! movups xmm1, [rdx]      ; point b to xmm1
      ! addps xmm0, xmm1        ; packed addition
      ! movups [rax], xmm0      ; move back to memory
    EndProcedure
    
    ; ---------------------------------------------------------------
    ; VECTOR3 SUB
    ; ---------------------------------------------------------------
    Procedure SubInPlace(*v.v3f32, *o.v3f32)
      ! mov rcx, [p.p_o]        ; move src to register
      ! mov rax, [p.p_v]        ; move dst to register
      ! movups xmm0, [rax]      ; dst packed float to xmm0
      ! movups xmm1, [rcx]      ; src packed flota to xmm1
      ! subps xmm0, xmm1        ; packed substraction
      ! movups [rax], xmm0      ; move back to memory
    EndProcedure

    Procedure Sub(*v.v3f32, *a.v3f32, *b.v3f32)
      ! mov rcx, [p.p_a]
      ! mov rdx, [p.p_b]
      ! mov rax, [p.p_v]
      ! movups xmm0, [rcx]
      ! movups xmm1, [rdx]
      ! subps xmm0, xmm1
      ! movups [rax], xmm0
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 MULTIPLY
    ; ---------------------------------------------------------------
    Procedure Multiply(*v.v3f32, *a.v3f32, *b.v3f32)
      ! mov rcx, [p.p_a]        ; move first to register
      ! mov rdx, [p.p_b]        ; move second to register
      ! mov rax, [p.p_v]        ; move dst to register
      ! movups xmm0, [rcx]      ; first packed float to xmm0
      ! movups xmm1, [rdx]      ; second packed flota to xmm1
      ! mulps xmm0, xmm1        ; packed multiplication
      ! movups [rax], xmm0      ; move back to memory
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 DOT (FASTER WITH SIMPLE MACRO ---> SSE version disabled)
    ; ---------------------------------------------------------------
;     Procedure.f Dot(*a.v3f32, *b.v3f32)
;       Protected d.f    
;       ! mov rax, [p.p_a]
;       ! mov rdx, [p.p_b]
;       
;       ! movups xmm0, [rax]
;       ! movups xmm1, [rdx]
;       ! mulps xmm0, xmm1
;       ! haddps xmm0, xmm0
;       ! haddps xmm0, xmm0
;       ! movss [p.v_d], xmm0
;       
;       ProcedureReturn d
;     EndProcedure
    
    ; ---------------------------------------------------------------
    ;  DISTANCE
    ; ---------------------------------------------------------------
    Procedure.f Distance(*a.v3f32, *b.v3f32)
      Define distance.f
      ! mov rsi, [p.p_a]
      ! movups xmm1, [rsi]
      ! mov rsi, [p.p_b]
      ! movups xmm0, [rsi]
      ! subps xmm0, xmm1
      ! mulps xmm0, xmm0
      ! movaps xmm1, xmm0
      ! shufps xmm0, xmm1, 0x4e
    	!	addps xmm0, xmm1
    	!	movaps xmm1, xmm0
    	!	shufps xmm1, xmm1, 0x11
    	!	addps xmm0, xmm1
      ! sqrtss xmm0, xmm0
    	! movss [p.v_distance], xmm0
    	ProcedureReturn distance
    EndProcedure
    
    Procedure.f DistanceSquared(*a.v3f32, *b.v3f32)
      Define distance.f
      ! mov rsi, [p.p_a]
      ! movups xmm1, [rsi]
      ! mov rsi, [p.p_b]
      ! movups xmm0, [rsi]
      ! subps xmm0, xmm1
      ! mulps xmm0, xmm0
      ! movaps xmm1, xmm0
      ! shufps xmm0, xmm1, 0x4e
    	!	addps xmm0, xmm1
    	!	movaps xmm1, xmm0
    	!	shufps xmm1, xmm1, 0x11
    	!	addps xmm0, xmm1
    	! movss [p.v_distance], xmm0
    	ProcedureReturn distance
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 CROSS
    ; ---------------------------------------------------------------
    Procedure Cross(*v.v3f32,*a.v3f32,*b.v3f32)
      ! mov rax, [p.p_a]
      ! mov rcx, [p.p_b]
      ! mov rdx, [p.p_v]
    
      ! movups xmm0,[rax]             ; move point a to xmm0
      ! movups xmm1,[rcx]             ; move point b to xmm1
      
      ! movaps xmm2,xmm0              ; copy point a to xmm2
      ! movaps xmm3,xmm1              ; copy point b to xmm3
      
      ! shufps xmm0,xmm0,00001001b    ; exchange 2 and 3 element (a)
      ! shufps xmm1,xmm1,00010010b    ; exchange 1 and 2 element (b)
      ! mulps  xmm0,xmm1
             
      ! shufps xmm2,xmm2,00010010b    ; exchange 1 and 2 element (a)
      ! shufps xmm3,xmm3,00001001b    ; exchange 2 and 3 element (b)
      ! mulps  xmm2,xmm3
            
      ! subps  xmm0,xmm2
      
      ! movups [rdx],xmm0             ; push back to memory
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 NORMALIZE
    ; ---------------------------------------------------------------
    Procedure Normalize(*v.v3f32, *o.v3f32)
      ! mov rax, [p.p_o]
      ! movups xmm0, [rax]            ; load vector to normalize in xmm0
      
      ! movaps xmm6, xmm0             ; make a copy in xmm6
      ! mulps xmm0, xmm0              ; square vector
      ; mix1
      ! movaps xmm7, xmm0             ; make a copy in xmm7
      ! shufps xmm7, xmm7, 01001110b  ; shuffle components :  z w x y
      ! addps xmm0, xmm7              ; packed addition
      ; mix2
      ! movaps xmm7, xmm0             ; make  a copy in xmm7
      ! shufps xmm7, xmm7, 00010001b  ; shuffle components : y x y x
      ! addps xmm0, xmm7              ; packed addition
      
      ; 1/sqrt
      ! rsqrtps xmm0, xmm0            ; reciprocal square root (inverse length)
      
      ; fix infinity
      ! movaps xmm1, xmm0
      ! movups xmm2, [math.l_sse_infinity_vec]

      ! cmpps xmm1, xmm2, 0           ; compare result with infinity
      ! xorps xmm0, xmm1              ; bitmask scale vec
      
      ! movups xmm3, [math.l_sse_one_vec]
      ! andps xmm3, xmm1              ; inverse bitmask on one vec
      ! addps xmm0, xmm3              ; add together
      
      ! mulps xmm0, xmm6              ; multiply by initial vector
      
      ! mov rax, [p.p_v]
      ! movups [rax], xmm0            ; send back to memory
    EndProcedure
    
    Procedure NormalizeInPlace(*v.v3f32)
      ! mov rax, [p.p_v]
      ! movups xmm0, [rax]            ; load vector to normalize in xmm0
      
      ! movaps xmm6, xmm0             ; make a copy in xmm6
      ! mulps xmm0, xmm0              ; square vector
      ; mix1
      ! movaps xmm7, xmm0             ; make a copy in xmm7
      ! shufps xmm7, xmm7, 01001110b  ; shuffle components :  z w x y
      ! addps xmm0, xmm7              ; packed addition
      ; mix2
      ! movaps xmm7, xmm0             ; make  a copy in xmm7
      ! shufps xmm7, xmm7, 00010001b  ; shuffle components : y x y x
      ! addps xmm0, xmm7              ; packed addition
      ; 1/sqrt
      ! rsqrtps xmm0, xmm0            ; reciprocal square root (inverse length)
      
      ! movaps xmm1, xmm0
      ! movups xmm2, [math.l_sse_infinity_vec]

      ! cmpps xmm1, xmm2, 0 
      ! xorps xmm0, xmm1
      ! movups xmm3, [math.l_sse_one_vec]
  
      ! andps xmm3, xmm1
      ! addps xmm0, xmm3
      
      ! mulps xmm0, xmm6              ; multiply by initial vector
      
      ! mov rax, [p.p_v]
      ! movups [rax], xmm0            ; send back to memory
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 SCALE
    ; ---------------------------------------------------------------
    Procedure ScaleInPlace(*v.v3f32, mult.f)
      ! mov rax, [p.p_v]            ; move src to register
      ! movups xmm0, [rax]          ; move packed float to xmm0
      ! movlps xmm1, [p.v_mult]     ; move multiplier to low part of xmm1
      ! shufps xmm1, xmm1, 0        ; fill xmm1 with multiplier
      ! mulps xmm0, xmm1            ; packed multiplication
      ! movups [rax], xmm0          ; send back to memory
    EndProcedure
    
    Procedure Scale(*v.v3f32, *o.v3f32, mult.f)
      ! mov rdx, [p.p_v]
      ! mov rax, [p.p_o]
      ! movups xmm0, [rax]
      ! movlps xmm1, [p.v_mult]
      ! shufps xmm1, xmm1, 0
      ! mulps xmm0, xmm1
      ! movups [rdx], xmm0
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 SCALE ADD
    ; ---------------------------------------------------------------
    Procedure ScaleAddInPlace(*v.v3f32, *o.v3f32, mult.f)
      ! mov rdi, [p.p_v]            ; move first vec to register
      ! movups xmm0, [rdi]          ; move packed float to xmm0
      ! mov rsi, [p.p_o]            ; move second vec to register
      ! movups xmm1, [rsi]          ; move packed float to xmm0
      ! movlps xmm2, [p.v_mult]     ; move multiplier to low part of xmm1
      ! shufps xmm2, xmm2, 0        ; fill xmm1 with multiplier
      ! mulps xmm1, xmm2            ; packed multiplication
      ! addps xmm0, xmm1
      ! movups [rdi], xmm0          ; send back to memory
    EndProcedure
    
    Procedure ScaleAdd(*v.v3f32, *a.v3f32, *b.v3f32,mult.f)
      ! mov rdi, [p.p_v]
      ! mov rsi, [p.p_a]
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_b]
      ! movups xmm1, [rsi]
      ! movlps xmm2, [p.v_mult]
      ! shufps xmm2, xmm2, 0
      ! mulps xmm1, xmm2
      ! addps xmm0, xmm1
      ! movups [rdi], xmm0
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 INVERT
    ; ---------------------------------------------------------------
    Procedure InvertInPlace(*v.v3f32)
      Protected one.f = 1.0
      ! mov rax, [p.p_v]            ; move src to register
      ! movups xmm1, [rax]          ; move packed float to xmm0
      ! movlps xmm0, [p.v_one]      ; move one to low part of xmm1
      ! shufps xmm0, xmm0, 0        ; fill xmm0 with one
      ! divps xmm0, xmm1            ; packed division
      ! movups [rax], xmm0          ; send back to memory
    EndProcedure
    
    Procedure Invert(*v.v3f32, *o.v3f32)
      Protected one.f = 1.0
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_o]
      ! movups xmm1, [rcx]
      ! movlps xmm0, [p.v_one]
      ! shufps xmm0, xmm0, 0
      ! divps xmm0, xmm1
      ! movups [rax], xmm0
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 ABSOLUTE
    ; ---------------------------------------------------------------
    Procedure AbsoluteInPlace(*v.v3f32)
      ! mov rdx, [p.p_v]                    ; vector3 to data register
      ! movups xmm1, [math.l_sse_1111_sign_mask]; move sign mask to rsi register
      ! movups xmm0, [rdx]                  ; data register to sse register
      ! andps xmm0, xmm1                    ; bitmask removing sign
      ! movaps [rdx], xmm0                  ; mov back to memory
    EndProcedure
    
    Procedure Absolute(*v.v3f32, *o.v3f32)
      ! mov rdx, [p.p_v]                    ; dst vector3 to data register
      ! mov rcx, [p.p_o]                    ; src vector3 to data register
      ! movups xmm1, [math.l_sse_1111_sign_mask] ; move sign mask to rsi register
      ! movups xmm0, [rcx]                  ; data register to sse register
      ! andps xmm0, xmm1                    ; bitmask removing sign
      ! movups [rdx], xmm0                  ; move back to memory
    EndProcedure

    
    ; ---------------------------------------------------------------
    ;  VECTOR3 INTERPOLATION
    ; ---------------------------------------------------------------
    Procedure LinearInterpolate(*v.v3f32, *a.v3f32, *b.v3f32, blend.f)
      Define one.f = 1
      ! mov rax, [p.p_a]
      ! mov rcx, [p.p_b]
      ! mov rdx, [p.p_v]
    
      ! movups xmm0, [rax]             ; move point a to xmm0
      ! movups xmm1, [rcx]             ; move point b to xmm1
      ! movlps xmm2, [p.v_blend]
      ! shufps xmm2, xmm2, 0           ; fill xmm2 with blend
      ! movlps xmm3, [p.v_one]         
      ! shufps xmm3, xmm3, 0           ; fill xmm3 with one
      
      ! subps xmm3, xmm2               ; 1-blend
      ! mulps xmm0, xmm3               ; multiply point a by 1-blend 
      ! mulps xmm1, xmm2               ; multiply point b by blend
      ! addps xmm0, xmm1               ; add packed float
      ! movups [rdx], xmm0             ; back to memory
    EndProcedure
    
    Procedure LinearInterpolateInPlace(*v.v3f32, *o.v3f32, blend.f)
       Define one.f = 1
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_o]
    
      ! movups xmm0, [rax]             ; move point a to xmm0
      ! movups xmm1, [rcx]             ; move point b to xmm1
      ! movlps xmm2, [p.v_blend]
      ! shufps xmm2, xmm2, 0           ; fill xmm2 with blend
      ! movlps xmm3, [p.v_one]         
      ! shufps xmm3, xmm3, 0           ; fill xmm3 with one
      
      ! subps xmm3, xmm2               ; 1-blend
      ! mulps xmm0, xmm3               ; multiply point a by 1-blend 
      ! mulps xmm1, xmm2               ; multiply point b by blend
      ! addps xmm0, xmm1               ; add packed float
      
      ! movups [rax], xmm0             ; back to memory
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 MUL BY MATRIX4
    ; ---------------------------------------------------------------
    Procedure MulByMatrix4(*v.v3f32,*o.v3f32,*m.m4f32)
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_o]
      ! mov rdx, [p.p_m]
      
      ; load point
      ! movups  xmm0, [rcx]               ; d c b a
      ! movaps  xmm1, xmm0                ; d c b a       
      ! movaps  xmm2, xmm0                ; d c b a
      ! movaps  xmm3, xmm0                ; d c b a
      
      ; shuffle point
      ! shufps  xmm0, xmm0,0              ; a a a a 
      ! shufps  xmm1, xmm1,01010101b      ; b b b b
      ! shufps  xmm2, xmm2,10101010b      ; c c c c
      ! shufps  xmm3, xmm3,11111111b      ; d d d d
      
      ; load matrix
      ! movups  xmm4, [rdx]               ; m04 m03 m02 m01
      ! movups  xmm5, [rdx+16]            ; m14 m13 m12 m11
      ! movups  xmm6, [rdx+32]            ; m24 m23 m22 m21
      ! movups  xmm7, [rdx+48]            ; m34 m33 m32 m31
      
      ; packed multiplication
      ! mulps   xmm0, xmm4                ; a * row1
      ! mulps   xmm1, xmm5                ; b * row2
      ! mulps   xmm2, xmm6                ; c * row3
      
      ; packed addition
      ! addps   xmm0, xmm1                
      ! addps   xmm0, xmm2
      ! addps   xmm0, xmm7
      
      ; packed determinant division
      ! movaps xmm1, xmm0
      ! shufps xmm1, xmm1, 11111111b
      ! divps xmm0, xmm1
    
      ! movups [rax], xmm0                ; back to memory
    EndProcedure
    
    Procedure MulByMatrix4InPlace(*v.v3f32,*m.m4f32)
      ! mov rax, [p.p_v]
      ! mov rdx, [p.p_m]
      
      ! movups  xmm0, [rax]               ; d c b a
      ! movaps  xmm1, xmm0                ; d c b a       
      ! movaps  xmm2, xmm0                ; d c b a
      ! movaps  xmm3, xmm0                ; d c b a
    
      ! shufps  xmm0, xmm0,0              ; a a a a 
      ! shufps  xmm1, xmm1,01010101b      ; b b b b
      ! shufps  xmm2, xmm2,10101010b      ; c c c c
      ! shufps  xmm3, xmm3,11111111b      ; d d d d
    
      ! movups  xmm4, [rdx]
      ! movups  xmm5, [rdx+16]
      ! movups  xmm6, [rdx+32]
      ! movups  xmm7, [rdx+48]
    
      ! mulps   xmm0, xmm4
      ! mulps   xmm1, xmm5
      ! mulps   xmm2, xmm6
    
      ! addps   xmm0, xmm1
      ! addps   xmm0, xmm2
      ! addps   xmm0, xmm7
      
      ! movaps xmm1, xmm0
      ! shufps xmm1, xmm1, 11111111b
      ! divps xmm0, xmm1
    
      ! movups [rax], xmm0
    EndProcedure
      
    ; ---------------------------------------------------------------
    ;  VECTOR3 MINIMUM
    ; ---------------------------------------------------------------
    Procedure Minimize(*v.v3f32, *a.v3f32, *b.v3f32)
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_a]
      ! mov rdx, [p.p_b]
      ! movups xmm0, [rcx]
      ! movups xmm1, [rdx]
      ! minps xmm0, xmm1
      ! movups [rax]
    EndProcedure
    
    Procedure MinimizeInPlace(*v.v3f32, *o.v3f32)
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_o]
      ! movups xmm0, [rax]
      ! movups xmm1, [rcx]
      ! minps xmm0, xmm1
      ! movups [rax]
    EndProcedure
      
    ; ---------------------------------------------------------------
    ;  VECTOR3 MUL BY MATRIX4
    ; ---------------------------------------------------------------
    Procedure Maximize(*v.v3f32, *a.v3f32, *b.v3f32)
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_a]
      ! mov rdx, [p.p_b]
      ! movups xmm0, [rcx]
      ! movups xmm1, [rdx]
      ! maxps xmm0, xmm1
      ! movups [rax]
    EndProcedure
    
    Procedure MaximizeInPlace(*v.v3f32, *o.v3f32)
      ! mov rax, [p.p_v]
      ! mov rcx, [p.p_o]
      ! movups xmm0, [rax]
      ! movups xmm1, [rcx]
      ! maxps xmm0, xmm1
      ! movups [rax]
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 EQUIVALENT
    ; ---------------------------------------------------------------
    Procedure.b Equivalent(*v.v3f32,*o.v3f32, eps.f=0.0000001)
      ! mov rsi, [p.p_v]            ; load first point
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_o]            ; load second point
      ! movups xmm1, [rsi]
      ! subps xmm0, xmm1            ; compute delta
      ! movss xmm2, [p.v_eps]       ; load epsilon
      ! shufps xmm2, xmm2, 00000000b; fill vec with epsilon
      ! movups xmm3, [math.l_sse_1111_sign_mask]
      ! andps xmm0, xmm3            ; absolute delta
      ! cmpps xmm0, xmm2, 1         ; compare delta < epsilon
      ! movmskps r12, xmm0          ; move comparison mask to r12 register
      ! cmp r12, 15                 ; if all check passed, 7 in r12
      ! je vector_are_equivalents   ; and then vector are equivalent
      ! jmp vector_are_differents   ; else vectors differs
      
      ! vector_are_equivalents:     ; equivalents
      ProcedureReturn #True
      
      ! vector_are_differents:      ; differents
      ProcedureReturn #False
    
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR3 COMPARISON
    ; ---------------------------------------------------------------
    Macro SSEVectorCompare(opcode, funcname)
      ! mov rsi, [p.p_v]            ; load first point
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_o]            ; load second point
      ! movups xmm1, [rsi]
      ! cmpps xmm0, xmm2, opcode    ; compare according to opcode
      ! movmskps r12, xmm0          ; move comparison mask to r12 register
      ! and r12, 7                  ; keep only three first bits
      ! cmp r12, 7                  ; if all check passed, 7 in r12
      ! je vector_#funcname#_true   ; and then vector are equivalent
      ! jmp vector_#funcname#_false ; else vectors differs
      
      ! vector_#funcname#_true:     ; equivalents
      ProcedureReturn #True
      
      ! vector_#funcname#_false:      ; differents
      ProcedureReturn #False
    EndMacro
    
    Procedure.b Equal(*v.v3f32, *o.v3f32)
      SSEVectorCompare(0, EQUAL)
    EndProcedure
    
    Procedure.b LessThan(*v.v3f32, *o.v3f32)
      SSEVectorCompare(1, LESSTHAN)
    EndProcedure
    
    Procedure.b LessOrEqualThan(*v.v3f32, *o.v3f32)
      SSEVectorCompare(2, LESSOREQUALTHAN)
    EndProcedure
    
    Procedure.b GreaterOrEqualThan(*v.v3f32, *o.v3f32)
      SSEVectorCompare(5, GREATEROREQUALTHAN)
    EndProcedure
    
    Procedure.b GreaterThan(*v.v3f32, *o.v3f32)
      SSEVectorCompare(5, GREATERTHAN)
    EndProcedure
    

  CompilerElse
    Procedure.b Equivalent(*v.v3f32,*o.v3f32, eps.f=0.0000001)
      If Abs(*v\x - *o\x) > eps Or Abs(*v\y - *o\y) Or Abs(*v\z - *o\z)
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
    EndProcedure
  CompilerEndIf
    
EndModule

;====================================================================
; Vector4 Module Implementation
;====================================================================
Module Vector4
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    ; ---------------------------------------------------------------
    ;  VECTOR3 SCALE
    ; ---------------------------------------------------------------
    Procedure ScaleInPlace(*v.v4f32, mult.f)
      ! mov rax, [p.p_v]            ; move src to register
      ! movups xmm0, [rax]          ; move packed float to xmm0
      ! movlps xmm1, [p.v_mult]     ; move multiplier to low part of xmm1
      ! shufps xmm1, xmm1, 0        ; fill xmm1 with multiplier
      ! mulps xmm0, xmm1            ; packed multiplication
      ! movups [rax], xmm0          ; send back to memory
    EndProcedure
    
    Procedure Scale(*v.v4f32, *o.v4f32, mult.f)
      ! mov rdx, [p.p_v]
      ! mov rax, [p.p_o]
      ! movups xmm0, [rax]
      ! movlps xmm1, [p.v_mult]
      ! shufps xmm1, xmm1, 0
      ! mulps xmm0, xmm1
      ! movups [rdx], xmm0
    EndProcedure
    
    ; ---------------------------------------------------------------
    ;  VECTOR4 SCALE ADD
    ; ---------------------------------------------------------------
    Procedure ScaleAddInPlace(*v.v4f32, *o.v4f32, mult.f)
      ! mov rdi, [p.p_v]            ; move first vec to register
      ! movups xmm0, [rdi]          ; move packed float to xmm0
      ! mov rsi, [p.p_o]            ; move second vec to register
      ! movups xmm1, [rsi]          ; move packed float to xmm0
      ! movlps xmm2, [p.v_mult]     ; move multiplier to low part of xmm1
      ! shufps xmm2, xmm2, 0        ; fill xmm1 with multiplier
      ! mulps xmm1, xmm2            ; packed multiplication
      ! addps xmm0, xmm1
      ! movups [rdi], xmm0          ; send back to memory
    EndProcedure
    
    Procedure ScaleAdd(*v.v4f32, *a.v4f32, *b.v4f32,mult.f)
      ! mov rdi, [p.p_v]
      ! mov rsi, [p.p_a]
      ! movups xmm0, [rsi]
      ! mov rsi, [p.p_b]
      ! movups xmm1, [rsi]
      ! movlps xmm2, [p.v_mult]
      ! shufps xmm2, xmm2, 0
      ! mulps xmm1, xmm2
      ! addps xmm0, xmm1
      ! movups [rdi], xmm0
    EndProcedure
  CompilerEndIf
  
EndModule

;====================================================================
; Quaternion Module Implementation
;====================================================================
Module Quaternion
  ;------------------------------------------------------------------
  ; QUATERNION PROJECT TO SPHERE
  ;------------------------------------------------------------------
  Procedure.f ProjectToSphere(r.f, x.f, y.f)
    Protected d.f, t.f, z.f
    d = Sqr(x*x + y*y)
    If d<r*#F32_1_SQRT2 ;Inside Sphere
        z = Sqr(r*r - d*d)
    Else                         ; On hyperbola
        t = r / #F32_SQRT2
        z = t*t / d
    EndIf
    
    ProcedureReturn z
  EndProcedure
  
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    ;------------------------------------------------------------------
    ; QUATERNION CONJUGATE
    ;------------------------------------------------------------------
    Procedure Conjugate(*out.q4f32,*q.q4f32)
      ! mov rsi, [p.p_q]
      ! movups xmm0, [rsi]
      ! movups xmm1, [math.l_sse_1110_negate_mask]
      ! mulps xmm0, xmm1
      ! mov rdi, [p.p_out]
      ! movups [rdi], xmm0
    EndProcedure
    
    ;------------------------------------------------------------------
    ; QUATERNION CONJUGATE IN PLACE
    ;------------------------------------------------------------------
    Procedure ConjugateInPlace(*q.q4f32)
      ! mov rdi, [p.p_q]
      ! movups xmm0, [rsi]
      ! movups xmm1, [math.l_sse_1110_negate_mask]
      ! mulps xmm0, xmm1
      ! movups [rdi], xmm0
    EndProcedure
    
;     ;------------------------------------------------------------------
;     ; SLERP
;     ;------------------------------------------------------------------
;     Procedure Slerp( *out.q4f32, *q1.q4f32, *q2.q4f32, blend.f)
;       ! mov rdi, [p.p_out]
;       ! movss xmm0, [p.v_blend]
;       ! xorps xmm1, xmm1
;       ! comiss xmm0, xmm1
;       ! jb output_quaternion1
;       ! movss xmm1, [math.l_sse_1111_value]
;       ! comiss xmm0, xmm1
;       ! jge output_quaternion2
;       
;       ; spherical interpolation
;       ! mov rsi, [p.p_q1]
;       ! movups xmm2, [rsi]                  ; load q1 in xmm2
;       ! mov rsi, [p.p_q1]
;       ! movups xmm3, [rsi]                  ; load q2 in xmm3
;       ! movaps xmm4, xmm2                   ; copy q1 in xmm4
;       ! movaps xmm5, xmm3                   ; copy q2 in xmm5
;       
;       ; dot product
;       ! mulps xmm4, xmm5                    ; q1 * q2
;       ! haddps xmm4, xmm4                   ; horizontal add first pass  
;       ! haddps xmm4, xmm4                   ; horizontal add second pass
;       
;       ! fld xmm4
; ;       ; arc cos
; ;       ! fld st(0)           ;Duplicate X on tos.
; ;       ! fmul                    ;Compute X**2.
; ;                 fld     st(0)           ;Duplicate X**2 on tos.
; ;                 fld1                    ;Compute 1-X**2.
; ;                 fsubr
; ;                 fdivr                   ;Compute (1-x**2)/X**2.
; ;                 fsqrt                   ;Compute sqrt((1-X**2)/X**2).
; ;                 fld1                    ;To compute full arctangent.
; ;                 fpatan                  ;Compute atan of the above.
; ;       
;       ; output quaternion 1
;       ! output_quternion1:
;       !   mov rsi, [p.p_q1]
;       !   movups xmm2, [rsi]                ; load q1 in xmm2
;       !   movups [rdi], xmm2                ; move back to memory
;       ProcedureReturn
;       
;       ; output quaternion 2
;       ! output_quternion2:
;       !   mov rsi, [p.p_q2]
;       !   movups xmm2, [rsi]                ; load q2 in xmm2
;       !   movups [rdi], xmm2                ; move back to memory
;       ProcedureReturn
;       
; ;       If blend<0
; ;         Quaternion::SetFromOther(_out,_q1)
; ;       ElseIf blend>=1
; ;         Quaternion::SetFromOther(_out,_q2)
; ;       Else
; ;         Define _dotproduct.f = _q1\x * _q2\x + _q1\y * _q2\y + _q1\z * _q2\z + _q1\w * _q2\w
; ;         Define.f _theta, _st,_sut, _sout, _coeff1, _coeff2
; ;         
; ;         _blend * 0.5
; ;         
; ;         _theta = ACos(_dotproduct)
; ;         If _theta<0 : _theta * -1 :EndIf
; ;         
; ;         _st = Sin(_theta)
; ;         _sut = Sin(_blend*_theta)
; ;         _sout = Sin((1-_blend)*_theta)
; ;         _coeff1 = _sout/_st
; ;         _coeff2 = _sut/_st
; ;         
; ;         _out\x = _coeff1 * _q1\x + _coeff2 * _q2\x
; ;         _out\y = _coeff1 * _q1\y + _coeff2 * _q2\y
; ;         _out\z = _coeff1 * _q1\z + _coeff2 * _q2\z
; ;         _out\w = _coeff1 * _q1\w + _coeff2 * _q2\w
; ;       EndIf
;     EndProcedure
    
    
  CompilerEndIf
  
CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
  ;------------------------------------------------------------------
  ; QUATERNION MULTIPLICATION
  ;------------------------------------------------------------------
  Procedure Multiply(*out.q4f32,*q1.q4f32, *q2.q4f32)
;   _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
;   _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
;   _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
;   _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)

    ! mov rdi, [p.p_out]
    ! mov rcx, [p.p_q1]
    ! mov rdx, [p.p_q2]
    
    ! movups xmm0, [rcx]              ; load q1 
    ! movaps xmm1, xmm0               ; copy to xmm1
    ! movaps xmm2, xmm0               ; and xmm2
    ! movaps xmm3, xmm0               ; and xmm3
    
    ! shufps xmm0, xmm0, 11111111b    ; q1 ( w, w, w, w)
    ! shufps xmm1, xmm1, 00100100b    ; q1 ( x, y, z, x)
    ! shufps xmm2, xmm2, 01001001b    ; q1 ( y, z, x, y)
    ! shufps xmm3, xmm3, 10010010b    ; q1 ( z, x, y, z)
    
    ! movups xmm4, [rdx]              ; load q2
    ! movaps xmm5, xmm4               ; copy to xmm5
    ! movaps xmm6, xmm4               ; and xmm6
    ! movaps xmm7, xmm4               ; and xmm7
    
    ! shufps xmm5, xmm5, 00111111b    ; q2 ( w, w, w, x)
    ! shufps xmm6, xmm6, 01010010b    ; q2 ( z, x, y, y)
    ! shufps xmm7, xmm7, 10001001b    ; q2 ( y, z, x, z)
    
    ! mulps xmm0, xmm4              
    ! mulps xmm1, xmm5
    ! mulps xmm2, xmm6
    ! mulps xmm3, xmm7
    
    ! movups xmm8, [math.l_sse_0001_negate_mask]
    ! mulps xmm1, xmm8
    ! mulps xmm2, xmm8
    ! movups xmm8, [math.l_sse_1111_negate_mask]
    ! mulps xmm3, xmm8
    
    ! addps xmm0, xmm1
    ! addps xmm0, xmm2
    ! addps xmm0, xmm3
    
    ! movups [rdi], xmm0
  EndProcedure
    
  Procedure MultiplyInPlace(*q1.q4f32, *q2.q4f32)
    
;     _x = (_q1\w * _q2\x) + (_q1\x * _q2\w) + (_q1\y * _q2\z) - (_q1\z * _q2\y)
;     _y = (_q1\w * _q2\y) + (_q1\y * _q2\w) + (_q1\z * _q2\x) - (_q1\x * _q2\z)
;     _z = (_q1\w * _q2\z) + (_q1\z * _q2\w) + (_q1\x * _q2\y) - (_q1\y * _q2\x)
;     _w = (_q1\w * _q2\w) - (_q1\x * _q2\x) - (_q1\y * _q2\y) - (_q1\z * _q2\z)
    ! mov rdi, [p.p_q1]
    ! mov rsi, [p.p_q2]
    
    ! movups xmm0, [rdi]              ; load q1 
    ! movaps xmm1, xmm0               ; copy to xmm1
    ! movaps xmm2, xmm0               ; and xmm2
    ! movaps xmm3, xmm0               ; and xmm3
    
    ! shufps xmm0, xmm0, 11111111b    ; q1 ( w, w, w, w)
    ! shufps xmm1, xmm1, 00100100b    ; q1 ( x, y, z, x)
    ! shufps xmm2, xmm2, 01001001b    ; q1 ( y, z, x, y)
    ! shufps xmm3, xmm3, 10010010b    ; q1 ( z, x, y, z)
    
    ! movups xmm4, [rsi]              ; load q2
    ! movaps xmm5, xmm4               ; copy to xmm5
    ! movaps xmm6, xmm4               ; and xmm6
    ! movaps xmm7, xmm4               ; and xmm7
    
    ! shufps xmm5, xmm5, 00111111b    ; q2 ( w, w, w, x)
    ! shufps xmm6, xmm6, 01010010b    ; q2 ( z, x, y, y)
    ! shufps xmm7, xmm7, 10001001b    ; q2 ( y, z, x, z)
    
    ! mulps xmm0, xmm4              
    ! mulps xmm1, xmm5
    ! mulps xmm2, xmm6
    ! mulps xmm3, xmm7
    
    ! movups xmm8, [math.l_sse_0001_negate_mask]
    ! mulps xmm1, xmm8
    ! mulps xmm2, xmm8
    ! movups xmm8, [math.l_sse_1111_negate_mask]
    ! mulps xmm3, xmm8
    
    ! addps xmm0, xmm1
    ! addps xmm0, xmm2
    ! addps xmm0, xmm3
    
    ! movups [rdi], xmm0
  EndProcedure
CompilerEndIf
  
EndModule

;====================================================================
; Color Module Implementation
;====================================================================
Module Color
  ;------------------------------------------------------------------
  ; PACK RGBA COLOR ---> uint32_t
  ;------------------------------------------------------------------
  Procedure.l PackColor(*c.c4f32)

    Define code.l = 0;
    code | (Int(*c\a * 255) & 255) << 24
    code | (Int(*c\r * 255) & 255) << 16
    code | (Int(*c\g * 255) & 255) << 8
    code | (Int(*c\b * 255) & 255)
    ProcedureReturn code
  EndProcedure
  
  Procedure.f PackColorAsFloat(*c.c4f32)
    Define code.l = 0;
    code | (Int(*c\a * 255) & 255) << 24
    code | (Int(*c\r * 255) & 255) << 16
    code | (Int(*c\g * 255) & 255) << 8
    code | (Int(*c\b * 255) & 255)
    ProcedureReturn PeekF(@code)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; UNPACK uint32_t  ---> RGBA COLOR
  ;------------------------------------------------------------------
  Procedure UnpackColor(*c.c4f32, code.l)
    Define a.l = (code >> 24) & 255
    Define r.l = (code >> 16) & 255
    Define g.l = (code >> 8) & 255
    Define b.l = code & 255
    *c\a = a/255
    *c\r = r/255
    *c\g = g/255
    *c\b = b/255
  EndProcedure
  
  Procedure UnpackColorAsFloat(*c.c4f32, code.f)
    Define tmp.l = PeekL(@code)
    Define a.l = (tmp >> 24) & 255
    Define r.l = (tmp >> 16) & 255
    Define g.l = (tmp >> 8) & 255
    Define b.l = tmp & 255
    *c\a = a/255
    *c\r = r/255
    *c\g = g/255
    *c\b = b/255
  EndProcedure
  
EndModule

;====================================================================
; Matrix3 Module Implementation
;====================================================================
Module Matrix3
  ; -----------------------------------------------------------------
  ;   INVERSE MATRIX
  ; -----------------------------------------------------------------
  Procedure.b Inverse(*m.m3f32_b, *o.m3f32_b)

    Define det.f = 0
    det + *o\m00 * (*o\m11 * *o\m22 - *o\m12 * *o\m21)
    det + *o\m01 * (*o\m12 * *o\m20 - *o\m10 * *o\m22)
    det + *o\m02 * (*o\m10 * *o\m21 - *o\m11 * *o\m20)
    
    If determinant <> 0
      Define invdet.f = 1 / det
      *m\m00 = (*o\m11 * *o\m22 - *o\m12 * *o\m21) * invdet
      *m\m01 = (*o\m21 * *o\m02 - *o\m22 * *o\m01) * invdet
      *m\m02 = (*o\m01 * *o\m12 - *o\m02 * *o\m11) * invdet
      *m\m10 = (*o\m12 * *o\m20 - *o\m10 * *o\m22) * invdet
      *m\m11 = (*o\m22 * *o\m00 - *o\m20 * *o\m02) * invdet
      *m\m12 = (*o\m02 * *o\m10 - *o\m00 * *o\m12) * invdet
      *m\m20 = (*o\m10 * *o\m21 - *o\m11 * *o\m20) * invdet
      *m\m21 = (*o\m20 * *o\m01 - *o\m21 * *o\m00) * invdet
      *m\m22 = (*o\m00 * *o\m11 - *o\m01 * *o\m10) * invdet
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
   
  EndProcedure
  
  ; -----------------------------------------------------------------
  ;   INVERSE MATRIX IN PLACE
  ; -----------------------------------------------------------------
  Procedure.b InverseInPlace(*m.m3f32_b)
    Define tmp.m3f32_b
    If Inverse(tmp, *m)
      CopyMemory(tmp, *m, SizeOf(m3f32_b))
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
EndModule


;====================================================================
; Matrix4 Module Implementation
;====================================================================
Module Matrix4
  UseModule Math
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
    Procedure TransposeInPlace(*m.m4f32)
      ! mov rax, [p.p_m]
      
      ! movups xmm1, [rax]                  ; move m4 row 0 to xmm4
      ! movups xmm2, [rax+16]               ; move m4 row 1 to xmm5
      ! movups xmm3, [rax+32]               ; move m4 row 2 to xmm6
      ! movups xmm4, [rax+48]               ; move m4 row 3 to xmm7
      
      ! movaps      xmm0,   xmm3            ; xmm0:   c4 c3 c2 c1
      ! punpckldq   xmm3,    xmm4           ; xmm3:   d2 c2 d1 c1
      ! punpckhdq   xmm0,    xmm4           ; xmm0:   d4 c4 d3 c3
    
      ! movaps      xmm4,    xmm1           ; xmm4:  a4 a3 a2 a1
      ! punpckldq   xmm1,    xmm2           ; xmm1:   b2 a2 b1 a1
      ! punpckhdq   xmm4,    xmm2           ; xmm4:   b4 a4 b3 a3
    
      ! movaps      xmm2,    xmm1           ; xmm2:   b2 a2 b1 a1
      ! punpcklqdq  xmm1,    xmm3           ; xmm1:   d1 c1 b1 a1
      ! punpckhqdq  xmm2,    xmm3           ; xmm2:   d2 c2 b2 a2
      ! movaps      xmm3,    xmm4           ; xmm3:   b4 a4 b3 a3
      ! punpcklqdq  xmm3,    xmm0           ; xmm3:   d3 c3 b3 a3
      ! punpckhqdq  xmm4,    xmm0           ; xmm4:   d4 c4 b4 a4
      
      ! movups [rax], xmm1
      ! movups [rax+16], xmm2
      ! movups [rax+32], xmm3
      ! movups [rax+48], xmm4
    EndProcedure
    
    Procedure Transpose(*m.m4f32, *o.m4f32)
      ! mov rax, [p.p_o]
      ! mov rdx, [p.p_m]
       
      ! movups xmm1, [rax]               ; move m4 row 0 to xmm4
      ! movups xmm2, [rax+16]            ; move m4 row 1 to xmm5
      ! movups xmm3, [rax+32]            ; move m4 row 2 to xmm6
      ! movups xmm4, [rax+48]            ; move m4 row 3 to xmm7
      
      ! movaps      xmm0,   xmm3         ; xmm0:   c4 c3 c2 c1
      ! punpckldq   xmm3,    xmm4        ; xmm3:   d2 c2 d1 c1
      ! punpckhdq   xmm0,    xmm4        ; xmm0:   d4 c4 d3 c3
    
      ! movaps      xmm4,    xmm1        ; xmm4:   a4 a3 a2 a1
      ! punpckldq   xmm1,    xmm2        ; xmm1:   b2 a2 b1 a1
      ! punpckhdq   xmm4,    xmm2        ; xmm4:   b4 a4 b3 a3
    
      ! movaps      xmm2,    xmm1        ; xmm2:   b2 a2 b1 a1
      ! punpcklqdq  xmm1,    xmm3        ; xmm1:   d1 c1 b1 a1
      ! punpckhqdq  xmm2,    xmm3        ; xmm2:   d2 c2 b2 a2
      ! movaps      xmm3,    xmm4        ; xmm3:   b4 a4 b3 a3
      ! punpcklqdq  xmm3,    xmm0        ; xmm3:   d3 c3 b3 a3
      ! punpckhqdq  xmm4,    xmm0        ; xmm4:   d4 c4 b4 a4
      
      ! movups [rdx], xmm1               ; move back matrix row 0 to memory
      ! movups [rdx+16], xmm2            ; move back matrix row 1 to memory
      ! movups [rdx+32], xmm3            ; move back matrix row 2 to memory
      ! movups [rdx+48], xmm4            ; move back matrix row 3 to memory
    EndProcedure
    
    Procedure Multiply(*m.m4f32, *f.m4f32, *s.m4f32)
      ! mov rdx, [p.p_m]                 ; move io matrix to rdx register
      ! mov rax, [p.p_f]                 ; move first matrix to rax register
      ! mov rcx, [p.p_s]                 ; move second matrix to rcx register
      ! xor r8, r8                       ; reset counter
        
      ! movups xmm4, [rax]               ; load first matrix row 0 in xmm4
      ! movups xmm5, [rax + 16]          ; load second matrix row 1 in xmm5
      ! movups xmm6, [rax + 32]          ; load third matrix row 2 in xmm6
      ! movups xmm7, [rax + 48]          ; load fourth matrix row 3 in xmm7
      
      ! multiply_loop:
      !   movups xmm0, [rcx]             ; load second matrix one row at a time 
      !   movaps xmm1, xmm0              ; copy row to xmm1
      !   movaps xmm2, xmm0              ; copy row to xmm2
      !   movaps xmm3, xmm0              ; copy row to xmm3
      
      !   shufps xmm0, xmm0, 00000000b   ; a a a a 
      !   shufps xmm1, xmm1, 01010101b   ; b b b b
      !   shufps xmm2, xmm2, 10101010b   ; c c c c
      !   shufps xmm3, xmm3, 11111111b   ; d d d d

      !   mulps xmm0, xmm4               ; packed multiplication ( a a a a * matrix row 0) 
      !   mulps xmm1, xmm5               ; packed multiplication ( b b b b * matrix row 1) 
      !   mulps xmm2, xmm6               ; packed multiplication ( c c c c * matrix row 2) 
      !   mulps xmm3, xmm7               ; packed multiplication ( d d d d * matrix row 3) 
      
      !   addps xmm0, xmm1               ; packed addition 
      !   addps xmm0, xmm2               ; packed addition
      !   addps xmm0, xmm3               ; packed addition
      
      !   movups [rdx], xmm0             ; move row back to memory
      !   add rdx, 16                    ; increment current io matrix row
      !   add rcx, 16                    ; increment current second matrix row
      !   inc r8                         ; increment counter
      !   cmp r8, 4                      ; check rows done
      !   jl multiply_loop               ; loop if row < 4
    EndProcedure
    
    Procedure MultiplyInPlace(*m.m4f32, *o.m4f32)
      ! mov rdi, [p.p_m]
      ! mov rsi, [p.p_o]
      ! xor r8, r8
      
      ! movups xmm4, [rdi]
      ! movups xmm5, [rdi + 16]
      ! movups xmm6, [rdi + 32]
      ! movups xmm7, [rdi + 48]
      
      ! m4f32_multiplyinplace_loop:
      !   movups xmm0, [rsi]
      !   movaps xmm1, xmm0
      !   movaps xmm2, xmm0
      !   movaps xmm3, xmm0
      
      !   shufps xmm0, xmm0, 00000000b
      !   shufps xmm1, xmm1, 01010101b
      !   shufps xmm2, xmm2, 10101010b
      !   shufps xmm3, xmm3, 11111111b

      !   mulps xmm0, xmm4
      !   mulps xmm1, xmm5
      !   mulps xmm2, xmm6
      !   mulps xmm3, xmm7
      
      !   addps xmm0, xmm1
      !   addps xmm0, xmm2
      !   addps xmm0, xmm3
      
      !   movups [rdi], xmm0
      !   add rdi, 16
      !   add rsi, 16
      !   inc r8
      !   cmp r8, 4
      !   jl m4f32_multiplyinplace_loop
    EndProcedure
   
  CompilerEndIf

  ;------------------------------------------------------------------
  ; MATRIX4 COMPUTE INVERSE
  ;------------------------------------------------------------------
  Procedure.b ComputeInverse(*m.m4f32,*o.m4f32,transpose.b=#False)
    
    Define.i i,j,k,cnt
    Dim fSys.f(4,8)
    Protected fTemp.f
    
    ;initialyze fSys Array
    For i=0 To 3
      For j=0 To 3
        fSys(i,j) = *o\v[i*4+j]
        If i=j : fSys(i,j+4) = 1
        Else : fSys(i,j+4) = 0
        EndIf
      Next j
    Next i
    
    ; compute inverse
    For j=0 To 3
      If Abs(fSys(j,j)<#F32_EPS)
        cnt =j+1
        For i = j+1 To 3
          If Abs(fSys(i,j)<#F32_EPS) : cnt+1 : EndIf
        Next i 
        If cnt = 4 
          ProcedureReturn #False
        Else
          For k = 0 To 7
            fTemp = fSys(i,k)
            fSys(i,k) = fSys(j,k)
            fSys(j,k)=fTemp
          Next k
        EndIf
      
      EndIf
      If fSys(j,j)<> 0 : fTemp = 1/fSys(j,j) :EndIf
      For i=0 To 7
        fSys(j,i) * fTemp
      Next i
      
      For i=0 To 3
        If Not i= j
          fTemp = - fSys(i,j)
          For k=0 To 7
            fSys(i,k) + ((fSys(j,k)*fTemp))
          Next k
        EndIf
      Next i
    Next j
     
    ; copy result from fSys to outMatrix
    If transpose
      For i=0 To 3
        For j=0 To 3
          *m\v[i+j*4] = fSys(i,j+4)
        Next j
      Next i  
    Else
      For i=0 To 3
        For j=0 To 3
          *m\v[i*4+j] = fSys(i,j+4)
        Next j
      Next i
    EndIf
    
    ProcedureReturn #True       
  EndProcedure
  
  ;-------------------------------------------
  ; Invert Matrix
  ;-------------------------------------------
  Procedure.b Inverse(*m.m4f32,*o.m4f32)
    ComputeInverse(*m,*o)
  EndProcedure
  
  Procedure.b InverseInPlace(*m.m4f32)
    Protected tmp.m4f32
    If Not ComputeInverse(@tmp,*m)
      ProcedureReturn #False
    EndIf
    
    SetFromOther(*m,tmp)
    ProcedureReturn #True
  EndProcedure
  
EndModule


;====================================================================
; Transform Module Implementation
;====================================================================
Module Transform
  UseModule Math
  
  ;------------------------------------------
  ; Init
  ;------------------------------------------
  Procedure Init(*t.Transform_t)
    Vector3::Set(*t\t\pos,0,0,0)
    Quaternion::SetIdentity(*t\t\rot)
    Vector3::Set(*t\t\scl,1,1,1)
    
    UpdateSRTFromMatrix(*t)
  EndProcedure
  ;------------------------------------------
  ; Set From SRT values
  ;------------------------------------------
  Procedure Set(*t.Transform_t,*s.v3f32,*r.q4f32,*p.v3f32)
    Vector3::SetFromOther(*t\t\scl,*s)
    Quaternion::SetFromOther(*t\t\rot,*r)
    Vector3::SetFromOther(*t\t\pos,*p)
    UpdateMatrixFromSRT(*t)
  EndProcedure
  
  ;------------------------------------------
  ; Set From Other Transform
  ;------------------------------------------
  Procedure SetFromOther(*t.Transform_t,*o.Transform_t)
    Set(*t,*o\t\scl,*o\t\rot,*o\t\pos)
    UpdateMatrixFromSRT(*t)
  EndProcedure
  
  ;------------------------------------------
  ; Compute Local from Two Global
  ;------------------------------------------
  Procedure ComputeLocal(*l.Transform_t,*g.Transform_t,*p.Transform_t)
    Protected inv.m4f32
    Matrix4::Inverse(inv,*p)
    Matrix4::Multiply(*l\m,*g\m,inv)
    UpdateSRTFromMatrix(*l)
  EndProcedure
  
  ;------------------------------------------
  ; Update Matrix From SRT values
  ;------------------------------------------
  Procedure SetMatrixFromSRT(*m.m4f32,*s.v3f32,*r.q4f32,*t.v3f32)
    Protected x.v3f32, y.v3f32, z.v3f32
    Vector3::Set(x,*s\x,0,0 )
    Vector3::Set(y,0,*s\y,0 )
    Vector3::Set(z,0,0,*s\z )
    
    Vector3::MulByQuaternionInPlace(x,*r)
    Vector3::MulByQuaternionInPlace(y,*r)
    Vector3::MulByQuaternionInPlace(z,*r)
    
    *m\v[0]  = x\x
    *m\v[1]  = x\y
    *m\v[2]  = x\z
    *m\v[3]  = 0.0
    *m\v[4]  = y\x
    *m\v[5]  = y\y
    *m\v[6]  = y\z
    *m\v[7]  = 0.0
    *m\v[8]  = z\x
    *m\v[9]  = z\y
    *m\v[10] = z\z
    *m\v[11] = 0.0
    *m\v[12] = *t\x
    *m\v[13] = *t\y
    *m\v[14] = *t\z
    *m\v[15] = 1.0
  
  EndProcedure
  
  ;------------------------------------------
  ; Update SRT From Matrix values
  ;------------------------------------------
  Procedure SetSRTFromMatrix(*m.m4f32,*s.v3f32,*r.q4f32,*t.v3f32)
    Protected x.v3f32, y.v3f32, z.v3f32
    ;Extract the x,y,z axes
    Vector3::Set(x,*m\v[0],*m\v[1],*m\v[2])
    Vector3::Set(y,*m\v[4],*m\v[5],*m\v[6])
    Vector3::Set(z,*m\v[8],*m\v[9],*m\v[10])
    
    ; Set Scale
    Vector3::Set(*s,Vector3::Length(x),Vector3::Length(y),Vector3::Length(z))
  
    Define.f qx,qy,qz,qw,qw4
    Protected tr.f = *m\v[0] + *m\v[5] + *m\v[10]
    Protected S.f
    If tr > 0
      S = Sqr(tr+1.0) * 2
      qw = 0.25 * S
      qx = (*m\v[9] - *m\v[6]) / S
      qy = (*m\v[2] - *m\v[8]) / S
      qz = (*m\v[4] - *m\v[1]) / S
    ElseIf (*m\v[0] > *m\v[5])And(*m\v[0] > *m\v[10])
      S = Sqr(1.0 + *m\v[0] - *m\v[5] - *m\v[10]) * 2
      qw = (*m\v[9] - *m\v[6]) / S
      qx = 0.25 * S
      qy = (*m\v[1] + *m\v[4]) / S
      qz = (*m\v[2] + *m\v[8]) / S
    ElseIf (*m\v[5] > *m\v[10])
      S = Sqr(1.0 + *m\v[5] - *m\v[0] - *m\v[10]) * 2
      qw = (*m\v[2] - *m\v[8]) / S
      qx = (*m\v[1] + *m\v[4]) / S
      qy = 0.25 * S
      qz = (*m\v[6] + *m\v[9]) / S
    Else
      S = Sqr(1.0 + *m\v[10] - *m\v[0] - *m\v[5]) * 2
      qw = (*m\v[4] - *m\v[1]) / S
      qx = (*m\v[2] + *m\v[8]) / S
      qy = (*m\v[6] + *m\v[9]) / S
      qz = 0.25 * S
    EndIf
  
    ; set the rotation!
    Quaternion::Set(*r,qx,qy,qz,qw)
  
    ;finally set the position!
    Vector3::Set(*t,*m\v[12],*m\v[13],*m\v[14])
  
  EndProcedure

  ;------------------------------------------
  ; Update Matrix From SRT values
  ;------------------------------------------
  Procedure UpdateMatrixFromSRT(*t.Transform_t)
    SetMatrixFromSRT(*t\m,*t\t\scl,*t\t\rot,*t\t\pos)
    *t\matrixdirty =#False
    *t\srtdirty = #False
  EndProcedure
  
  ;------------------------------------------
  ; Update SRT values From Matrix
  ;------------------------------------------
  Procedure UpdateSRTFromMatrix(*t.Transform_t)
    SetSRTFromMatrix(*t\m,*t\t\scl,*t\t\rot,*t\t\pos)
    *t\matrixdirty = #False
    *t\srtdirty = #False
  EndProcedure
  
  ;------------------------------------------
  ; Set Translation 
  ;------------------------------------------
  Procedure SetTranslation(*t.Transform_t,*pos.v3f32)
    *t\t\pos\x = *pos\x
    *t\t\pos\y = *pos\y
    *t\t\pos\z = *pos\z
    *t\srtdirty = #True
  EndProcedure
  
  ;------------------------------------------
  ; Set Translation from X,Y,Z Values
  ;------------------------------------------
  Procedure SetTranslationFromXYZValues(*t.Transform_t,x.f,y.f,z.f)
    *t\t\pos\x = x
    *t\t\pos\y = y
    *t\t\pos\z = z
    *t\srtdirty = #True
  EndProcedure
  
  ;------------------------------------------
  ; Set Rotation From Quaternion
  ;------------------------------------------
  Procedure SetRotationFromQuaternion(*t.Transform_t,*q.q4f32)
    *t\t\rot\w = *q\w
    *t\t\rot\x = *q\x
    *t\t\rot\y = *q\y
    *t\t\rot\z = *q\z
    *t\srtdirty = #True
  EndProcedure
  
  ;------------------------------------------
  ; Set Scale From X,Y,Z Values
  ;------------------------------------------
  Procedure SetScaleFromXYZValues(*t.Transform_t,x.f,y.f,z.f)
    *t\t\scl\x = x
    *t\t\scl\y = y
    *t\t\scl\z = z
    *t\srtdirty = #True
  EndProcedure
  
  ;------------------------------------------
  ; Set Translation 
  ;------------------------------------------
  Procedure SetScale(*t.Transform_t,*scl.v3f32)
    *t\t\scl\x = *scl\x
    *t\t\scl\y = *scl\y
    *t\t\scl\z = *scl\z
    *t\srtdirty = #True
  EndProcedure
 
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 427
; FirstLine = 392
; Folding = -------------------------------------------------------
; EnableXP
; EnableUnicode