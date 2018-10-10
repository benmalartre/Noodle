;====================================================================
; Math Module Declaration(Shared)
;====================================================================
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
  
  ; ----[ SCALARS 32 ]----------------------------------------------------------
  #F32_EPS    = 1e-6
  #F32_MAX    = 3.402823466e+38
  #F32_MIN    = 1.175494351e-38
  
  ; ----[ SCALARS 64 ]----------------------------------------------------------
  #F64_EPS    = 2e-16
  #F64_MAX    = 1.7976931348623158e+308
  #F64_MIN    = 2.2250738585072014e-308

  #F32_EPS    = 1e-6
  #F32_MAX    = 3.402823466e+38
  #F32_MIN    = 1.175494351e-38
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
  #F32_RAD2DEG  = 57.2957795              ; 180/pi
  
  #MIN_VECTOR_LENGTH = 1e-10
  #MIN_ORTHO_TOLERANCE = 1e-6
  
  #RAND_MAX = 2147483647                ; according to help for Random()

  ; ----------------------------------------------------------------------------
  ;  Maximum Macro
  ; ----------------------------------------------------------------------------
  Macro MAXIMUM(a,b)
    If a<b : a=b : EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Minimum Macro
  ; ----------------------------------------------------------------------------
  Macro MINIMUM(a,b)
    If a>b : a=b : EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Percentage Macro
  ; ----------------------------------------------------------------------------
  Macro PERCENTAGE(x,z)
    100 / z * x
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Clamp Macro
  ; ----------------------------------------------------------------------------
  Macro CLAMP(x,min,max)
    If (x<min)
      x = min 
    ElseIf (x>max)
      x=max 
    Else 
      x = x
    EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  PointInBox Macro
  ; ----------------------------------------------------------------------------
  Macro POINTINBOX(x,y,vx,vy,vw,vh)
    If x>vx And x<vx+vw And y>vy And y<vy+vh
      #True
    Else
      #False
    EndIf
  EndMacro
  
  ; ----------------------------------------------------------------------------
  ;  Rescale Macro
  ; --------------------------------------------------------------------------
  Macro RESCALE(x,inmin,inmax,outmin,outmax)
    (x -inmin)*(outmax-outmin)/(inmax-inmin)+outmin
  EndMacro
  
  ;------------------------------------------------
  ; Linear Interpolation Macro
  ;------------------------------------------------
  Macro LINEAR_INTERPOLATE(io,y1,y2,mu)
    io = y1*(1-mu)+y2*mu
  EndMacro
  
  ;------------------------------------------------
  ; Cubic Interpolation Macro
  ;------------------------------------------------
  Macro CUBIC_INTERPOLATE(io,y0,y1,y2,y3,mu)
  
     Define.f a0,a1,a2,a3,mu2;
  
     mu2 = (mu*mu);
     a0 = y3 - y2 - y0 + y1;
     a1 = y0 - y1 - a0;
     a2 = y2 - y0;
     a3 = y1;
  
     io = a0*mu*mu2+a1*mu2+a2*mu+a3;
  EndMacro
  
  ;------------------------------------------------
  ; Hermite Interpolation
  ;------------------------------------------------
  Macro HERMITE_INTERPOLATE(io,y0,y1,y2,y3,mu,tension,bias)
    Define.f m0,m1,mu2,mu3;
    Define.f a0,a1,a2,a3;
    
    mu2 = mu * mu;
    mu3 = mu2 * mu;
    m0  = (y1-y0)*(1+bias)*(1-tension)/2;
    m0 + (y2-y1)*(1-bias)*(1-tension)/2;
    m1  = (y2-y1)*(1+bias)*(1-tension)/2;
    m1 + (y3-y2)*(1-bias)*(1-tension)/2;
    a0 =  2*mu3 - 3*mu2 + 1;
    a1 =    mu3 - 2*mu2 + mu;
    a2 =    mu3 -   mu2;
    a3 = -2*mu3 + 3*mu2;
  
   io = a0*y1+a1*m0+a2*m1+a3*y2;
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
    CompilerIf Defined(USE_SSE, #PB_Constant)
      _unused.f
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
  
  ; ----------------------------------------------------------------------------
  ;  m4f32 Structure
  ; --------------------------------------------------------------------------
  Structure m4f32
    v.f[16]
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
  ;  MATH UTILS
  ; --------------------------------------------------------------------------
  Declare.f Max(a.f,b.f)
  Declare.f Min(a.f,b.f)
  Declare.b IsClose(value.f, root.f, tolerance.f)
  Declare.f Random_0_1()
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
  Macro Set(v,_x,_f)
    v\x = _x
    v\y = _f
  EndMacro
  
  Macro SetFromOther(v,o)
    v\x = o\x
    v\y = o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 ADD
  ;------------------------------------------------------------------
  Macro Add(v,a,b)
    v\x = a\x + b\x
    v\y = a\y + b\y
  EndMacro
  
  Macro AddInPlace(v,o)
    v\x + o\x
    v\y + o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SUB
  ;------------------------------------------------------------------
  Macro Sub(v,a,b)
    v\x = a\x - b\x
    v\y = a\y - b\y
  EndMacro
  
  Macro SubInPlace(v,o)
    v\x - o\x
    v\y - o\y
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 SCALE
  ;------------------------------------------------------------------
  Macro Scale(v,o,mult)
    v\x = o\x * mult
    v\y = o\y * mult
  EndMacro
  
  Macro ScaleInPlace(v,mult)
    v\x * mult
    v\y * mult
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 INVERT
  ;------------------------------------------------------------------
  Macro Invert(v, o)
    If o\x <> 0.0 : v\x = 1 / o\x : EndIf
    If o\y <> 0.0 : v\y = 1 / o\y : EndIf
  EndMacro
  
  Macro InvertInPlace(v)
    If v\x <> 0.0 : v\x = 1 / v\x : EndIf
    If v\y <> 0.0 : v\y = 1 / v\y : EndIf
  EndMacro
  
  ;------------------------------------------------------------------
  ; VECTOR2 LENGTH
  ;------------------------------------------------------------------
  Macro LengthSquared(v)
    (v\x * v\x + v\y * v\y)
  EndMacro
  
  Macro Length(v)
    Sqr(v\x * v\x + v\y * v\y)
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
    
    _fLen = Vector3::Length(_v)
    _fLen * Vector3::Length(_o)
    
    If _fLen < #F32_EPS
      _angle = 0
    Else
      _fCosAngle = (_v\x* _o\x + _v\y * _o\y)/_fLen
      Clamp(_fCosAngle,-1,1)
      _angle = ACos(_fCosAngle)
    EndIf
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
  EndProcedure

  Procedure HermiteInterpolate(_v,_a,_b,_c,_d,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\x,_a\x,_b\x,_c\x,_d\x,_mu,_tension,_bias)
    HERMITE_INTERPOLATE(_v\y,_a\y,_b\y,_c\y,_d\y,_mu,_tension,_bias)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; VECTOR2 DOT
  ;------------------------------------------------------------------
  Macro Dot(_v,_o)
    (_v\x * _o\x + _v\y * _o\y)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; VECTOR2 SET LENGTH
  ;------------------------------------------------------------------
  Macro SetLength(_v,_length)
    NormalizeInPlace(_v)
    ScaleInPlace(_v,_length)
  EndProcedure

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
    Debug _name +":("+StrF(_v\x)+","+StrF(_v\y)+")"
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
  ; VECTOR3 LENGTH
  ;------------------------------------------------------------------
  Macro LengthSquared(_v)
    (_v\x * _v\x + _v\y * _v\y + _v\z * _v\z)
  EndMacro
  
  Macro Length(_v)
    Sqr(_v\x * _v\x + _v\y * _v\y + _v\z * _v\z)
  EndMacro

  ;------------------------------------------------------------------
  ; VECTOR3 NORMALIZE
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant)
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

  ;------------------------------------------------------------------
  ; VECTOR3 SUB
  ;------------------------------------------------------------------
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

  ;------------------------------------------------------------------
  ; VECTOR3 SCALE
  ;------------------------------------------------------------------
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
  
  ;------------------------------------------------------------------
  ; VECTOR3 INVERT
  ;------------------------------------------------------------------
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

  ;------------------------------------------------------------------
  ; VECTOR3 INTERPOLATION
  ;------------------------------------------------------------------
  Macro LinearInterpolate(_v,_a,_b,_blend)
    _v\x = (1-_blend) * _a\x + _blend * _b\x
    _v\y = (1-_blend) * _a\y + _blend * _b\y
    _v\z = (1-_blend) * _a\z + _blend * _b\z
  EndMacro
  
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
  ; CROSS
  ;------------------------------------------------------------------
  CompilerIf Defined(USE_SSE, #PB_Constant)
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
  ; VECTOR3 SET LENGTH
  ;------------------------------------------------------------------
  Macro SetLength(_v,_length)
    Vector3::NormalizeInPlace(_v)
    Vector3::ScaleInPlace(_v,_length)
  EndMacro

  ;------------------------------------------------------------------
  ; VECTOR3 MULTIPLY BY OTHER
  ;------------------------------------------------------------------
  Macro Multiply(_o,_a,_b)
    _o\x = _a\x * _b\x
    _o\y = _a\y * _b\y
    _o\z = _a\z * _b\z
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
  Macro MulByMatrix4(_v,_o,_m)
    Define _x.f,_y.f,_z.f,_w.f
  ;   x = *o\x * *m\v[0] + *o\y * *m\v[1] + *o\z * *m\v[2] + *m\v[3]
  ;   y = *o\x * *m\v[4] + *o\y * *m\v[5] + *o\z * *m\v[6] + *m\v[7]
  ;   z = *o\x * *m\v[8] + *o\y * *m\v[9] + *o\z * *m\v[10] + *m\v[11]
  ;   w = *o\x * *m\v[12] + *o\y * *m\v[13] + *o\z * *m\v[15] + *m\v[15]
  ;   *v\x = x/w
  ;   *v\y = y/w
  ;   *v\z = z/w
    _x = _o\x * _m\v[0] + _o\y * _m\v[4] + _o\z * _m\v[8] + _m\v[12]
    _y = _o\x * _m\v[1] + _o\y * _m\v[5] + _o\z * _m\v[9] + _m\v[13]
    _z = _o\x * _m\v[2] + _o\y * _m\v[6] + _o\z * _m\v[10] + _m\v[14]
    _w = _o\x * _m\v[3] + _o\y * _m\v[7] + _o\z * _m\v[11] + _m\v[15]
    If _w <> 0.0
      _v\x = _x/_w
      _v\y = _y/_w
      _v\z = _z/_w
    EndIf  
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
  ; VECTOR3 ECHO
  ;------------------------------------------------------------------
  Macro Echo(_v,_name)
    Debug _name +":("+StrF(_v\x)+","+StrF(_v\y)+","+StrF(_v\z)+")"
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
  ; VECTOR4 SET FROM OTHER
  ;------------------------------------------------------------------
  Macro SetFromOther(_v,_o)
    _v\w = _o\w
    _v\x = _o\x
    _v\y = _o\y
    _v\z = _o\z
  EndMacro
  
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
    Debug _prefix+"("+StrF(_v\x,3)+","+StrF(_v\y,3)+","+StrF(_v\z,3)+","+StrF(_v\w,3)+")"
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
    Define _n.v3f32,_halfAngle.f,_sinAngle.f
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
    Define _n.v3f32,_axis.v3f32,_halfAngle.f,_sinAngle.f
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
  	NormalizeInPlace(_q)
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

  ;------------------------------------------------------------------
  ; QUATERNION MULTIPLY
  ;------------------------------------------------------------------
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
    Quaternion::Set(_q, Sqr(_x*Cos(#F32_2PI*_z)), Sqr(1-_x*Sin(#F32_2PI*_y)), Sqr(1-_x*Cos(#F32_2PI*_y)), Sqr(_x*Sin(#F32_2PI*_z)))
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

  ;------------------------------------------------------------------
  ; QUATERNION SLERP
  ;------------------------------------------------------------------
  Macro Echo(_q,_prefix)
    Debug _prefix+"("+StrF(_q\x,3)+","+StrF(_q\y,3)+","+StrF(_q\z,3)+","+StrF(_q\w,3)+")"
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
    Define _invf.f = 1 / 255.0
    _c\r = Random(255)*_invf
    _c\g = Random(255)*_invf
    _c\b = Random(255)*_invf
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
    Debug prefix + ": "+StrF(_c\r)+","+StrF(_c\g)+","+StrF(_c\b)+","+StrF(_c\a)
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
           StrF(_m\v[0])+","+
           StrF(_m\v[1])+","+
           StrF(_m\v[2])+","+
           StrF(_m\v[3])+","+
           StrF(_m\v[4])+","+
           StrF(_m\v[5])+","+
           StrF(_m\v[6])+","+
           StrF(_m\v[7])+","+
           StrF(_m\v[8])+")"
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX3 TO STRING
  ;------------------------------------------------------------------
  Macro ToString(_m)
    StrF(_m\v[0])+","+
    StrF(_m\v[1])+","+
    StrF(_m\v[2])+","+
    StrF(_m\v[3])+","+
    StrF(_m\v[4])+","+
    StrF(_m\v[5])+","+
    StrF(_m\v[6])+","+
    StrF(_m\v[7])+","+
    StrF(_m\v[8])
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
    
    Matrix3::Set(*m,_tmp_m3\v[0],_tmp_m3\v[1],_tmp_m3\v[2],
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
          StrF(_m\v[15],3)+")"
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
        _m\v[_i] = ValF(StringField(_s,i+1,","))
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
    _m\v[11]   = _s\v[8] * _f\v[3] + _s\v[9] * _f\v[7]+ _s\v[10]* _f\v[11]  + _s\v[11]* _f\v[15]
    _m\v[15]  = _s\v[12]* _f\v[3] + _s\v[13]* _f\v[7]+ _s\v[14]* _f\v[11]  + _s\v[15]* _f\v[15]  
  EndMacro
  
  ;------------------------------------------------------------------
  ; MATRIX4 MULTIPLY IN PLACE
  ;------------------------------------------------------------------
  Macro MultiplyInPlace(_m,_o)
    Define.m4f32 _mm4_tmp
    Matrix4::Multiply(_mm4_tmp, _m, _o)
    CopyMemory(_mm4_tmp, _m, #M4F32_SIZE)
  EndMacro

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
  
  ;------------------------------------------------------------------
  ; MATRIX4 TRANSPOSE IN PLACE
  ;------------------------------------------------------------------
  Macro TransposeInPlace(_m)
    Define _m4_tmp.m4f32
    Matrix4::Transpose(_m4_tmp,_m)
    Matrix4::SetFromOther(_m,_m4_tmp)
  EndMacro

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
    ;underlying trf32
    t.trf32

    ;underlying matrix
    m.m4f32
     
     ;States
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
  Procedure.f Max(a.f,b.f)
    If a<b
      ProcedureReturn b
    Else
      ProcedureReturn a
    EndIf
    
  EndProcedure
  
   Procedure.f Min(a.f,b.f)
    If a<b
      ProcedureReturn a
    Else
      ProcedureReturn b
    EndIf
    
  EndProcedure
  
  Procedure.b IsClose(value.f, root.f, tolerance.f)
    If Abs(value - root) < tolerance 
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Random 0 to 1
  ; ----------------------------------------------------------------------------
  Procedure.f Random_0_1()
    ProcedureReturn Random(#RAND_MAX)/#RAND_MAX
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Uniform Point On Circle
  ; ----------------------------------------------------------------------------
  Procedure UniformPointOnCircle(*p.v2f32, radius.f=1.0)
    Protected angle.f = Random_0_1() * #F32_2PI 
    Vector2::Set(*p, Cos(angle) * radius, Sin(angle) * radius)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Uniform Point On Disc (Rejection Method)
  ; ----------------------------------------------------------------------------
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
  
  ; ----------------------------------------------------------------------------
  ;  Uniform Point On Disc (Polar Method)
  ; ----------------------------------------------------------------------------
  Procedure.f UniformPointOnDisc2(*p.v2f32, radius.f=1.0)
    Protected angle.f = Random_0_1() * #F32_2PI 
    Protected r.f = Sqr(Random_0_1())
    Vector2::Set(*p, Cos(angle) * radius * r, Sin(angle) * radius * r)
    ProcedureReturn Vector2::Length(*p)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Uniform Point On Sphere
  ; ----------------------------------------------------------------------------
  Procedure UniformPointOnSphere(*p.v3f32, radius.f=1.0)
    *p\z = 1 - 2.0 * Random_0_1()
    Protected t.f = #F32_2PI * Random_0_1()
    Protected w.f = Sqr(1.0 - Pow(*p\z, 2))
    *p\x = w * Cos(t)
    *p\y = w * Sin(t)
    Vector3::ScaleInPlace(*p, radius)
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Map Disc Point To Sphere
  ; ----------------------------------------------------------------------------
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
CompilerIf Defined(USE_SSE, #PB_Constant)
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

Procedure Normalize(*v.v3f32, *o.v3f32)
  ! mov rax, [p.p_o]
  ! movups xmm0, [rax]
  
  ! movaps xmm6, xmm0      ;effectue une copie du vecteur dans xmm6
  ! mulps xmm0, xmm0       ;carré de chaque composante
  ; mix1
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $4e
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; mix2
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $11
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; 1/sqrt
  ! rsqrtps xmm0, xmm0     ;inverse de la racine carrée (= longueur)
  ! mulps xmm0, xmm6       ;que multiplie le vecteur initial
  
  ! mov rax, [p.p_v]
  ! movups [rax], xmm0     ; send back to memory
EndProcedure

Procedure NormalizeInPlace(*v.v3f32)
  ! mov rax, [p.p_v]
  ! movups xmm0, [rax]
  
  ! movaps xmm6, xmm0      ;effectue une copie du vecteur dans xmm6
  ! mulps xmm0, xmm0       ;carré de chaque composante
  ; mix1
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $4e
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; mix2
  ! movaps xmm7, xmm0
  ! shufps xmm7, xmm7, $11
  ! addps xmm0, xmm7       ;additionne les composantes mélangées
  ; 1/sqrt
  ! rsqrtps xmm0, xmm0     ;inverse de la racine carrée (= longueur)
  ! mulps xmm0, xmm6       ;que multiplie le vecteur initial
  
  ! movups [rax], xmm0     ; send back to memory
EndProcedure
CompilerEndIf
EndModule

;====================================================================
; Vector4 Module Implementation
;====================================================================
Module Vector4
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
EndModule

;====================================================================
; Color Module Implementation
;====================================================================
Module Color
EndModule

;====================================================================
; Matrix3 Module Implementation
;====================================================================
Module Matrix3
EndModule


;====================================================================
; Matrix4 Module Implementation
;====================================================================
Module Matrix4
  UseModule Math
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
          Debug "Singular Matrix!!"
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
    Matrix4::Inverse(@inv,*p)
    Matrix4::Multiply(*l\m,*g\m,@inv)
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

;====================================================================
; EOF
;====================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 388
; FirstLine = 375
; Folding = -----------------------------------
; EnableXP
; EnableUnicode