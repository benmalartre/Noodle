DeclareModule AnimX
  ; Span Interpolation Method
  ; Defines span interpolation method determined by the tangents of boundary keys
  Enumeration
    #SI_Bezier
    #SI_Linear
    #SI_Step
    #SI_StepNext
  EndEnumeration
  
  ; Curve Interpolation Method
  ; Defines interpolation function within curve segments For non-rotation curves
  Enumeration
    #CI_Bezier
    #CI_Hermite
    #CI_Sine
    #CI_Parabolic
    #CI_TangentLog
  EndEnumeration
  
  ; Curve Rotation Interpolation Method
  ; Defines interpolation mode For the rotation curves
  Enumeration
    #CR_None       ; Non-rotational curves Or non-sync Euler. This is the behaviour For pre-Maya 4.0
    #CR_Euler      ; Sync rotation curves & use Euler angles
    #CR_Slerp      ; Use quaternion cubic interpolation
    #CR_Quaternion ; Use quaternion tangent dependent interpolation
    #CR_Squad      ; Use quaternion spherical interpolation
  EndEnumeration
  
  ; Tangent Type
  ; Defines the type of the tangent
  Enumeration
    #TT_Global     ; Global
    #TT_Fixed      ; Fixed
    #TT_Linear     ; Linear  
    #TT_Flat       ; Flat
    #TT_Step       ; Step
    #TT_Slow       ; Slow
    #TT_Fast       ; Fast
    #TT_Smooth     ; Smooth
    #TT_Clamped    ; Clamp
    #TT_Auto       ; Auto
    
    #TT_Sine       ; Sine
    #TT_Parabolic  ; Parabolic
    #TT_Log        ; Log
    
    #TT_Plateau    ; Plateau
    #TT_StepNext   ; StepNext
  EndEnumeration
  
  ; InfinityType Type
  ; Defines the type of the infinity
  Enumeration
    #ITT_Constant
    #ITT_Linear
    #ITT_Cycle
    #ITT_CycleRelative
    #ITT_Oscillate
  EndEnumeration
  
  ; Infinity Type
  Enumeration 
    #IT_Pre         ; Pre-infinity
    #IT_Post        ; Post-infinity
  EndEnumeration
  
  #KEYFRAME_SIZE = 64
  
  ; Tangent
  ; Single in- Or out- tangent of a key
  Structure Tangent_t
    type.l
    x.f
    y.f
  EndStructure
  
  ; Quaternion
  ; Double Precision
  Structure Quaternion_t
    x.d
    y.d
    z.d
    w.d
  EndStructure
  
  ; KeyTimeValue
  Structure KeyTimeValue_t
    time.d
    value.d
  EndStructure
  
  ; Keyframe
  Structure Keyframe_t Extends KeyTimeValue_t
    index.i
    tanIn.Tangent_t
    tanOut.Tangent_t
    quaternionW.d
    linearInterpolation.b
  EndStructure
  
  Interface ICurve
    keyframeAtIndex.b(index.i, *key.Keyframe_t)
    keyframe.b(time.d, *key.Keyframe_t)
    first.b(*key.Keyframe_t)
    last.b(*key.Keyframe_t)
    preInfinityType.i()
    postInfinityType.i()
    isWeighted.b()
    keyframeCount()
    isStatic()
  EndInterface
  
  ; Curve
  Structure Curve_t
    vt.ICurve
    numKeys.i
    *keys
  EndStructure
  
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "..\..\libs\x64\windows\PBAnimX.lib"
      
    CompilerEndIf
    
   newCurve()
   deleteCurve(*curve.Curve_t)
   evaluateCurve.d(time.d,*curve.Curve_t)
   
  EndImport
  
  Declare AddKey(*crv.Curve_t, *key.Keyframe_t)
  Declare DeleteKey(*crv.Curve_t, index.i)
  
  Declare GetKeyframeSpanInterpolationMethod(*keyframe.Keyframe_t)
  Declare GetKeyframeCurveInterpolationMethod(*keyframe.Keyframe_t, isWeighted.b)
  
EndDeclareModule

Module AnimX
  
  Procedure GetKeyframeSpanInterpolationMethod(*keyframe.Keyframe_t)
    If *keyframe\linearInterpolation
      ProcedureReturn #SI_Linear
    EndIf
    If *keyframe\tanOut\type = #TT_Step
      ProcedureReturn #SI_Step
    EndIf
    If *keyframe\tanOut\type = #TT_StepNext
      ProcedureReturn #SI_StepNext
    EndIf
    ProcedureReturn #SI_Bezier
  EndProcedure
  
  Procedure GetKeyframeCurveInterpolationMethod(*keyframe.Keyframe_t, isWeighted.b)
    Protected method.i
    If isWeighted
      method = #CI_Bezier
    Else
      method = #CI_Hermite
    EndIf
    
    Select *keyframe\tanOut\type
      Case #TT_Sine
        method = #CI_Sine
      Case #TT_Parabolic
        method = #CI_Parabolic
      Case #TT_Log
        method = #CI_TangentLog
    EndSelect
    ProcedureReturn method
  EndProcedure
  
  Procedure AddKey(*crv.Curve_t, *key.Keyframe_t)
    If *crv\keys 
      *crv\keys = ReAllocateMemory(*crv\keys, (*crv\numKeys + 1) * #KEYFRAME_SIZE, #PB_Memory_NoClear)
      CopyMemory(*key, *crv\keys + *crv\numKeys * #KEYFRAME_SIZE, #KEYFRAME_SIZE)
    Else
      *crv\keys = AllocateMemory(#KEYFRAME_SIZE)
      CopyMemory(*key, *crv\keys , #KEYFRAME_SIZE)
    EndIf
    *crv\numKeys + 1 
  EndProcedure
      
  Procedure DeleteKey(*crv.Curve_t, index.i)
    
  EndProcedure
  
EndModule

; test
Define *crv.AnimX::Curve_t = AnimX::newCurve()
Define icrv.AnimX::ICurve = *crv

Define key.AnimX::Keyframe_t
Define i
Define width = 800
Define height = 600
For i=0 To width*0.01
  key\index = i
  key\time = i*100
  key\value = Random(height)
  key\linearInterpolation = #False
  key\tanIn\type = AnimX::#TT_Fast
  key\tanIn\x = 0
  key\tanIn\y = 0
  key\tanOut\type = AnimX::#TT_Slow
  key\tanOut\x = 0
  key\tanOut\y = 0
  AnimX::AddKey(*crv, @key)
Next

Define window.i = OpenWindow(#PB_Any, 0, 0, width, height, "AnimX")
Define canvas.i = CanvasGadget(#PB_Any,0,0,width, height)

StartVectorDrawing(CanvasVectorOutput(canvas))  
Define x.d = 0
Define y.d = AnimX::evaluateCurve(x, *crv)
Define stepx.d = 1

MovePathCursor(x, y)
x+stepx

While x < width
  y = AnimX::evaluateCurve(x, *crv)
  AddPathLine(x, y, #PB_Path_Default)
  x + stepx
Wend

VectorSourceColor(RGBA(120, 120, 120, 255))
StrokePath(2)

Define i
For i=0 To icrv\keyframeCount()-1
  If icrv\keyframeAtIndex(i, @key)
    AddPathCircle(key\time, key\value,6)
  EndIf
Next

VectorSourceColor(RGBA(255, 120, 120, 255))
StrokePath(1)

StopVectorDrawing()


Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
AnimX::deleteCurve(*crv)

 

; namespace adsk
; {
; #ifdef MAYA_64BIT_TIME_PRECISION
;     typedef double seconds;
; #else
;     typedef float  seconds;
; #endif

; 
;     /*!
;         Adapter abstract class For a curve.
; 
;         Instance of a derived class of this adapter serves As an accessor For various basic
;         curve information like its key frames Or infinity types. This is To avoid introducing a new
;         curve type the clients would have To convert their Data To before invoking this library.
; 
;         The assumption about the curves are:
;         - keys are stored sequentially, With indexes between [0 .. keyframeCount()-1]
;         - each key has a broken in/out tangents
;     */
;     class ICurve
;     {
;     public:
;         /*!
;             Returns a key at a particular index, If valid. False otherwise.
;         */
;         virtual bool keyframeAtIndex(int index, Keyframe &key) const = 0;
; 
;         /*!
;             Returns closest key at Or after the specified time, Or the last key If time is
;             beyond the End of the curve.
;         */
;         virtual bool keyframe(double time, Keyframe &key) const = 0;
; 
;         /*!
;             Returns the first key.
;         */
;         virtual bool first(Keyframe &key) const = 0;
; 
;         /*!
;             Returns the last key
;         */
;         virtual bool last(Keyframe &key) const = 0;
; 
;         /*!
;             Returns the pre infinity type.
;         */
;         virtual InfinityType preInfinityType() const = 0;
; 
;         /*!
;             Returns the post infinity type.
;         */
;         virtual InfinityType postInfinityType() const = 0;
; 
;         /*!
;             Returns whether a curve has weighted tangents.
;         */
;         virtual bool isWeighted() const = 0;
; 
;         /*!
;             Returns the total number of key frames.
;         */
;         virtual unsigned int keyframeCount() const = 0;
; 
;         /*!
;             Returns whether a curve is Static (has a constant value).
;         */
;         virtual bool isStatic() const = 0;
;     };
; 
; 
; 
;     /*!
;         Evaluate a single curve.
; 
;         \param[in] time Time at which To evaluate the curve.
;         \param[in] curve Curve accessor To operate on.
; 
;         \return
;         Evaluated double value of a curve.
;     */
;     DLL_EXPORT double evaluateCurve(
;         double time,
;         const ICurve &curve);
; 
;     /*!
;         Evaluate an individual curve segment.
; 
;         \param[in] interpolationMethod How should the segment be interpolated
;         \param[in] curveInterpolatorMethod If span method is Bezier, choose desired evaluation model
;         \param[in] time Time To evaluate segment at (startX <= time <= endX)
;         \param[in] startX Time of the first key
;         \param[in] startY Value of the first key
;         \param[in] x1 Coordinate X of first control point
;         \param[in] y1 Coordinate Y of first control point
;         \param[in] x2 Coordinate X of second control point
;         \param[in] y2 Coordinate Y of second control point
;         \param[in] endX Time of the second key
;         \param[in] endY Value of the second key
; 
;         \return
;         Evaluated double value of a segment.
;     */
;     DLL_EXPORT double evaluateCurveSegment(
;         SpanInterpolationMethod interpolationMethod,
;         CurveInterpolatorMethod curveInterpolatorMethod,
;         double time,
;         double startX, double startY,
;         double x1, double y1,
;         double x2, double y2,
;         double endX, double endY);
; 
;     /*!
;         Evaluate rotation infinities using quaternion interpolation.
; 
;         \param[in] time Time To evaluate rotation curve's infinity (time <= first OR time >= last)
;         \param[in] firstTime Time of the first key in the curve
;         \param[in] firstValue Quaternion value of the first key
;         \param[in] lastTime Time of the last key in the curve
;         \param[in] lastValue Quaternion value of the last key       
;         \param[in] preInfinityType Pre-infinity type of the curve
;         \param[in] postInfinityType Post-infinity type of the curve
;         \param[out] qOffset The rotation offset To add To the final quaternion evaluation
;         \param[out] qStart First keyed rotation of the sequence, used in final quaternion evaluation To offset back To identity quaternion
;         \param[out] inverse Depending on the infinity Case, should the quaternion evaluation be inversed
; 
;         \return
;         Boolean whether the resolved value needs post-processing. See more in evaluateQuaternionCurve() implementation
;     */
;     DLL_EXPORT bool evaluateQuaternionInfinity(
;         double &time,
;         double firstTime, Quaternion firstValue,
;         double lastTime, Quaternion lastValue,
;         InfinityType preInfinityType,
;         InfinityType postInfinityType,
;         Quaternion &qOffset,
;         Quaternion &qStart,
;         bool &inverse);
; 
;     /*!
;         Evaluate infinities of a single curve.
; 
;         \param[in] time Time To evaluate infinity at
;         \param[in] curve Curve accessor To operate on
;         \param[in] infinity Evaluating pre Or post infinity
; 
;         \return
;         Evaluated double value of the infinity.
;     */
;     DLL_EXPORT double evaluateInfinity(
;         double time,
;         const ICurve &curve,
;         Infinity infinity);
; 
;     /*!
;         Evaluate an individual rotation curve segment using quaternion interpolation.
; 
;         \param[in] time Time To evaluation rotation at
;         \param[in] interpolationMethod Rotation interpolation method
;         \param[in] spanInterpolationMethod Interpolation mode of the segment
;         \param[in] startTime Time of the key at/before given time
;         \param[in] startValue Quaternion value of the start key
;         \param[in] endTime Time of the key after given time
;         \param[in] endValue Quaternion value of the End key
;         \param[in] tangentType Out-tangent type of the start key        
;         \param[in] prevValue Quaternion value of the prev key
;         \param[in] nextValue Quaternion value of the Next key                       
; 
;         \return
;         Evaluated quaternion value of a rotation segment.
;     */
;     DLL_EXPORT Quaternion evaluateQuaternion(
;         seconds time,
;         CurveRotationInterpolationMethod interpolationMethod,
;         SpanInterpolationMethod spanInterpolationMethod,
;         seconds startTime, Quaternion startValue,
;         seconds endTime, Quaternion endValue,
;         TangentType tangentType,
;         Quaternion prevValue,
;         Quaternion nextValue);
; 
;     /*!
;         Evaluate rotation curves using quaternion interpolation.
; 
;         \param[in] time Time To evaluate at
;         \param[in] pcX Curve accessor For rotation X
;         \param[in] pcY Curve accessor For rotation Y
;         \param[in] pcZ Curve accessor For rotation Z
;         \param[in] interpolationMethod Rotation interpolation method
; 
;         \return
;         Evaluated quaternion value of a rotation curve.
;     */
;     DLL_EXPORT Quaternion evaluateQuaternionCurve(
;         double time,
;         const ICurve &pcX, const ICurve &pcY, const ICurve &pcZ,
;         CurveRotationInterpolationMethod interpolationMethod);
; 
;     /*!
;         Compute tangent values For a key With Auto tangent type.
; 
;         \param[in] calculateInTangent True when calculating "in" tangent. False If "out"
;         \param[in] key Key tangent of we are calculating
;         \param[in] prevKey Previous key, If present
;         \param[in] nextKey Next key, If present
;         \param[in] tanX Output tangent X value
;         \param[in] tanY Output tangent Y value
;     */
;     DLL_EXPORT void autoTangent(
;         bool calculateInTangent, 
;         KeyTimeValue key, 
;         KeyTimeValue *prevKey, 
;         KeyTimeValue *nextKey, 
;         CurveInterpolatorMethod curveInterpolationMethod,
;         seconds &tanX,
;         seconds &tanY);
; }
; 
; #endif
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 244
; FirstLine = 201
; Folding = --
; EnableXP