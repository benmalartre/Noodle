XIncludeFile "../core/Array.pbi"
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
  Structure Tangent_t Align #PB_Structure_AlignC
    type.l
    x.f
    y.f
  EndStructure
  
  ; Quaternion
  ; Double Precision
  Structure Quaternion_t Align #PB_Structure_AlignC
    x.d
    y.d
    z.d
    w.d
  EndStructure
  
  ; KeyTimeValue
  Structure KeyTimeValue_t Align #PB_Structure_AlignC
    time.d
    value.d
  EndStructure
  
  Interface IKeyframe
    spanInterpolationMethod.l()
    curveInterpolationMethod.l(isWeighted.b)
  EndInterface
  
  ; Keyframe
  Structure Keyframe_t Extends KeyTimeValue_t Align #PB_Structure_AlignC
    index.l
    tanIn.Tangent_t
    tanOut.Tangent_t
    quaternionW.d
    linearInterpolation.b
  EndStructure

  ; Curve
  Interface ICurve
    keyframeAtIndex.b(index.i, *key.Keyframe_t)
    keyframe.b(time.d, *key.Keyframe_t)
    first.b(*key.Keyframe_t)
    last.b(*key.Keyframe_t)
    preInfinityType.l()
    postInfinityType.l()
    isWeighted.b()
    keyframeCount.l()
    isStatic.b()
    destructor()
    setNumKeys(numKeys.i)
    getNumKeys()
    setKeys(*keys.Keyframe_t)
    getKeys()
    setPreInfinityType(type.l)
    setPostInfinityType(type.l)
  EndInterface
  
  Declare Init()
  Declare Term()
  
  ; prototypes
  PrototypeC PFNNEWCURVE()
  PrototypeC PFNDELETECURVE(crv.ICurve)
  PrototypeC.d PFNEVALUATECURVE(time.d,crv.ICurve)
  PrototypeC.d PFNEVALUATECURVESEGMENT(spanInterpolationMethod.l,
                                       curveInterpolationMethod.l,
                                       time.d,
                                       startX.d, startY.d,
                                       x1.d, y1.d,
                                       x2.d, y2.d,
                                       endX.d, endY.d)
  
  PrototypeC.b PFNEVALUATEQUATERNIONINFINITY(time.d,
                                             firstTime.d, *firstValue.Quaternion_t,
                                             lastTime.d, *lastValue.Quaternion_t,
                                             preInfinityType.l,
                                             postInfinityType.l,
                                             *qOffset.Quaternion_t,
                                             *qStart.Quaternion_t,
                                             inverse.b)
  
  PrototypeC.d PFNEVALUATEINFINITY(time.d, *curve, infinity.l)
  
  PrototypeC.i PFNEVALUATEQUATERNION(time.d,
                                     interpolationMethod.l,
                                     spanInterpolationMethod.l,
                                     startTime.d, *startValue.Quaternion_t,
                                     endTime.d, *endValue.Quaternion_t,
                                     tangentType.l,
                                     *prevVlaue.Quaternion_t,
                                     *nextValue.Quaternion_t)
  
  PrototypeC.i PFNEVALUATEQUATERNIONCURVE(time.d,
                                         pcx.ICurve,
                                         pcy.ICurve,
                                         pcz.ICurve,
                                         interpolationMethod.l)
  
  PrototypeC PFNAUTOTANGENT(calculateInTangent.b,
                            *key.KeyTimeValue_t,
                            *prevKey.KeyTimeValue_t,
                            *nextKey.KeyTimeValue_t,
                            curveInterpolationMethod.l,
                            *tanx, *tanY)

  ; functions 
  Global newCurve.PFNNEWCURVE
  Global deleteCurve.PFNDELETECURVE
  Global evaluateCurve.PFNEVALUATECURVE
  Global evaluateCurveSegment.PFNEVALUATECURVESEGMENT
  Global evaluateQuaternionInfinity.PFNEVALUATEQUATERNIONINFINITY
  Global evaluateInfinity.PFNEVALUATEINFINITY
  Global evaluateQuaternion.PFNEVALUATEQUATERNION
  Global evaluateQuaternionCurve.PFNEVALUATEQUATERNIONCURVE
  Global autoTangent.PFNAUTOTANGENT
 
EndDeclareModule

Module AnimX
  ; initilize (open library and load functions)
  Procedure Init()
    Global xanim_dll = OpenLibrary(#PB_Any, "E:\Projects\RnD\Noodle\libs\x64\windows\AnimX.dll")
    newCurve = GetFunction(xanim_dll, "newCurve")
    deleteCurve = GetFunction(xanim_dll, "deleteCurve")
    evaluateCurve = GetFunction(xanim_dll, "evaluateCurve")
    evaluateCurveSegment = GetFunction(xanim_dll, "evaluateCurveSegment")
    evaluateInfinity = GetFunction(xanim_dll, "evaluateInfinity")
    evaluateQuaternionInfinity = GetFunction(xanim_dll, "evaluateQuaternionInfinity")
  EndProcedure
  
  ; terminate (close library)
  Procedure Term()
    If IsLibrary(xanim_dll)
      CloseLibrary(xanim_dll)
    EndIf
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 124
; FirstLine = 96
; Folding = -
; EnableXP