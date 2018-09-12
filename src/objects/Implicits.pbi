; ============================================================================
;  Basic Implicit Shapes used for Nulls and Particles
; ============================================================================
;  2018/07/15 | BenMalartre
;  - creation
; ============================================================================
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../libs/OpenGL.pbi"


DeclareModule Implicit
  UseModule OpenGL
  UseModule Math
  Enumeration
    #IMPLICIT_NONE = 0
    #IMPLICIT_AXIS
    #IMPLICIT_SPHERE
    #IMPLICIT_CUBE
    #IMPLICIT_DISC
    #IMPLICIT_CYLINDER
    #IMPLICIT_NULL
    #IMPLICIT_ARROW
    #IMPLICIT_TORUS
    #IMPLICIT_CAPSULE
    #IMPLICIT_MAX
  EndEnumeration
  
  ;Define ImplicitType Type
  Macro ImplicitType : i
  EndMacro
  
  Structure Implicit_t
    nbp.i
    *positions.CArray::CArrayV3F32
  EndStructure
  

  ; ============================================================================
  ;  OpenGL Implicit Shapes
  ; ============================================================================
  ;{
  
  ;-----------------------------------------------------------------------------
  ; Null
  ;-----------------------------------------------------------------------------
  #NULL_NUM_VERTICES = 6
  DataSection
  	implicit_null_positions:
  	Data.GLfloat -0.5,0.0,0.0
  	Data.GLfloat 0.5,0.0,0.0
  	Data.GLfloat 0.0,-0.5,0.0
  	Data.GLfloat 0.0,0.5,0.0
  	Data.GLfloat 0.0,0.0,-0.5
  	Data.GLfloat 0.0,0.0,0.5
  EndDataSection
  
  ;-----------------------------------------------------------------------------
  ; Axis
  ;-----------------------------------------------------------------------------
  #AXIS_NUM_VERTICES = 6
  DataSection
  	implicit_axis_positions:
  	Data.GLfloat 0.0,0.0,0.0
  	Data.GLfloat 1.0,0.0,0.0
  	Data.GLfloat 0.0,0.0,0.0
  	Data.GLfloat 0.0,1.0,0.0
  	Data.GLfloat 0.0,0.0,0.0
  	Data.GLfloat 0.0,0.0,1.0
  
  EndDataSection

  ;-----------------------------------------------------------------------------
  ; Cube
  ;-----------------------------------------------------------------------------
  #CUBE_NUM_VERTICES = 24
  DataSection
  	implicit_cube_positions:
  	Data.GLfloat -0.5,-0.5,-0.5
  	Data.GLfloat 0.5,-0.5,-0.5
  	Data.GLfloat -0.5,0.5,-0.5
  	Data.GLfloat 0.5,0.5,-0.5
  	Data.GLfloat -0.5,-0.5,0.5
  	Data.GLfloat 0.5,-0.5,0.5
  	Data.GLfloat -0.5,0.5,0.5
  	Data.GLfloat 0.5,0.5,0.5
  	
  	Data.GLfloat -0.5,-0.5,-0.5
  	Data.GLfloat -0.5,-0.5,0.5
  	Data.GLfloat -0.5,0.5,-0.5
  	Data.GLfloat -0.5,0.5,0.5
  	Data.GLfloat -0.5,-0.5,0.5
  	Data.GLfloat -0.5,0.5,0.5
  	Data.GLfloat -0.5,-0.5,-0.5
  	Data.GLfloat -0.5,0.5,-0.5

  EndDataSection

  ;-----------------------------------------------------------------------------
  ; disc
  ;-----------------------------------------------------------------------------
  #DISC_NUM_VERTICES =12
  DataSection
  	implicit_disc_positions:
  	Data.GLfloat -0.866025403784,0.0,-0.5
  	Data.GLfloat 1.83697019872e-16,0.0,-1.0
  	Data.GLfloat 0.5,0.0,-0.866025403784
  	Data.GLfloat 0.866025403784,0.0,-0.5
  	Data.GLfloat -1.0,0.0,0.0
  	Data.GLfloat 1.0,0.0,5.66553889765e-16
  	Data.GLfloat 0.866025403784,0.0,0.5
  	Data.GLfloat 0.5,0.0,0.866025403784
  	Data.GLfloat -0.866025403784,0.0,0.5
  	Data.GLfloat -0.5,0.0,-0.866025403784
  	Data.GLfloat -6.12323399574e-17,0.0,1.0
  	Data.GLfloat -0.5,0.0,0.866025403784
 
  
  EndDataSection
  

  ;-----------------------------------------------------------------------------
  ; Cylinder
  ;-----------------------------------------------------------------------------
  #CYLINDER_NUM_VERTICES =26
  DataSection
  	implicit_cylinder_positions:
  	Data.GLfloat 0.0,-0.5,0.0
  	Data.GLfloat 0.0,0.5,0.0
  	Data.GLfloat -0.5,-0.5,-6.12323399574e-17
  	Data.GLfloat -0.5,0.5,-6.12323399574e-17
  	Data.GLfloat -0.433012701892,-0.5,0.25
  	Data.GLfloat -0.433012701892,0.5,0.25
  	Data.GLfloat -0.25,-0.5,0.433012701892
  	Data.GLfloat -0.25,0.5,0.433012701892
  	Data.GLfloat -1.94289029309e-16,-0.5,0.5
  	Data.GLfloat -1.94289029309e-16,0.5,0.5
  	Data.GLfloat 0.25,-0.5,0.433012701892
  	Data.GLfloat 0.25,0.5,0.433012701892
  	Data.GLfloat 0.433012701892,-0.5,0.25
  	Data.GLfloat 0.433012701892,0.5,0.25
  	Data.GLfloat 0.5,-0.5,3.60822483003e-16
  	Data.GLfloat 0.5,0.5,3.60822483003e-16
  	Data.GLfloat 0.433012701892,-0.5,-0.25
  	Data.GLfloat 0.433012701892,0.5,-0.25
  	Data.GLfloat 0.25,-0.5,-0.433012701892
  	Data.GLfloat 0.25,0.5,-0.433012701892
  	Data.GLfloat 4.71844785466e-16,-0.5,-0.5
  	Data.GLfloat 4.71844785466e-16,0.5,-0.5
  	Data.GLfloat -0.25,-0.5,-0.433012701892
  	Data.GLfloat -0.25,0.5,-0.433012701892
  	Data.GLfloat -0.433012701892,-0.5,-0.25
  	Data.GLfloat -0.433012701892,0.5,-0.25
  
  EndDataSection
  

	;-----------------------------------------------------------------------------
	; sphere
	;-----------------------------------------------------------------------------
	#SPHERE_NUM_VERTICES = 48
	DataSection
		implicit_sphere_positions:
		Data.f 0.50000,0,0
		Data.f 0.45677,0,-0.203368336
		Data.f 0.33457,0,-0.3715724349
		Data.f 0.15451,0,-0.47552827
		Data.f -0.05226,0,-0.497260958
		Data.f -0.25000,0,-0.4330126941
		Data.f -0.40451,0,-0.293892622
		Data.f -0.48907,0,-0.1039558053
		Data.f -0.48907,0,0.1039558947
		Data.f -0.40451,0,0.2938926816
		Data.f -0.25000,0,0.4330127537
		Data.f -0.05226,0,0.4972609878
		Data.f 0.15451,0,0.4755282402
		Data.f 0.33457,0,0.3715723753
		Data.f 0.45677,0,0.2033682466
		Data.f 0.50000,0,-0.0000000874
		Data.f 0.00000,0.5,0
		Data.f -0.20337,0.4567727447,0
		Data.f -0.37157,0.3345653117,0
		Data.f -0.47553,0.1545085013,0
		Data.f -0.49726,-0.0522642918,0
		Data.f -0.43301,-0.2500000596,0
		Data.f -0.29389,-0.4045085311,0
		Data.f -0.10396,-0.489073813,0
		Data.f 0.10396,-0.489073813,0
		Data.f 0.29389,-0.4045085013,0
		Data.f 0.43301,-0.2499999553,0
		Data.f 0.49726,-0.0522641689,0
		Data.f 0.47553,0.1545085907,0
		Data.f 0.37157,0.3345653713,0
		Data.f 0.20337,0.4567727745,0
		Data.f -0.00000,0.5,0
		Data.f 0.00000,0.5,0
		Data.f 0.00000,0.4567727447,0.203368336
		Data.f 0.00000,0.3345653117,0.3715724349
		Data.f 0.00000,0.1545085013,0.47552827
		Data.f 0.00000,-0.0522642918,0.497260958
		Data.f 0.00000,-0.2500000596,0.4330126941
		Data.f 0.00000,-0.4045085311,0.293892622
		Data.f 0.00000,-0.489073813,0.1039558053
		Data.f 0.00000,-0.489073813,-0.1039558947
		Data.f 0.00000,-0.4045085013,-0.2938926816
		Data.f 0.00000,-0.2499999553,-0.4330127537
		Data.f 0.00000,-0.0522641689,-0.4972609878
		Data.f 0.00000,0.1545085907,-0.4755282402
		Data.f 0.00000,0.3345653713,-0.3715723753
		Data.f 0.00000,0.4567727745,-0.2033682466
		Data.f 0.00000,0.5,0.0000000874
	EndDataSection
  

  ;-----------------------------------------------------------------------------
  ; TORUS
  ;-----------------------------------------------------------------------------
  #TORUS_NUM_VERTICES = 64
  
  DataSection
    implicit_torus_positions:
    Data.f 	2.5,		0,		0
    Data.f 	2.405,	0.294,	0
    Data.f 	2.155,	0.476,	0
    Data.f 	1.845,	0.476,	0
    Data.f 	1.595,	0.294,	0
    Data.f 	1.5,		0	,		0
    Data.f 	1.595,	-0.294,	0
    Data.f 	1.845,	-0.476,	0
    Data.f 	2.155,	-0.476,	0
    Data.f 	2.405,	-0.294,	0
    Data.f 	2.445,	0	,		0.52 
    Data.f 	2.352,	0.294,	0.5  
    Data.f 	2.107,	0.476,	0.448
    Data.f 	1.805,	0.476,	0.384
    Data.f 	1.561,	0.294,	0.332
    Data.f 	1.467,	0	,		0.312
    Data.f 	1.561,	-0.294,	0.332
    Data.f 	1.805,	-0.476,	0.384
    Data.f 	2.107,	-0.476,	0.448
    Data.f 	2.352,	-0.294,	0.5	 
    Data.f 	2.284,	0,		1.017
    Data.f 	2.197,	0.294,	0.978
    Data.f 	1.968,	0.476,	0.876
    Data.f 	1.686,	0.476,	0.751
    Data.f 	1.458,	0.294,	0.649
    Data.f 	1.37,		0,		0.61 
    Data.f 	1.458,	-0.294,	0.649
    Data.f 	1.686,	-0.476,	0.751
    Data.f 	1.968,	-0.476,	0.876
    Data.f 	2.197,	-0.294,	0.978
    Data.f 	2.023,	0,		1.469
    Data.f 	1.945,	0.294,	1.413
    Data.f 	1.743,	0.476,	1.266
    Data.f 	1.493,	0.476,	1.085
    Data.f 	1.291,	0.294,	0.938
    Data.f 	1.214,	0,		0.882
    Data.f 	1.291,	-0.294,	0.938
    Data.f 	1.493,	-0.476,	1.085
    Data.f 	1.743,	-0.476,	1.266
    Data.f 	1.945,	-0.294,	1.413
    Data.f 	1.673,	0,		1.858
    Data.f 	1.609,	0.294,	1.787
    Data.f 	1.442,	0.476,	1.601
    Data.f 	1.235,	0.476,	1.371
    Data.f 	1.068,	0.294,	1.186
    Data.f 	1.004,	0,		1.115
    Data.f 	1.068,	-0.294,	1.186
    Data.f 	1.235,	-0.476,	1.371
    Data.f 	1.442,	-0.476,	1.601
    Data.f 	1.609,	-0.294,	1.787
    Data.f 	1.25,		0,		2.165
    Data.f 	1.202,	0.294,	2.082
    Data.f 	1.077,	0.476,	1.866
    Data.f 	0.923,	0.476,	1.598
    Data.f 	0.798,	0.294,	1.382
    Data.f 	0.75,		0,		1.299
    Data.f 	0.798,	-0.294,	1.382
    Data.f 	0.923,	-0.476,	1.598
    Data.f 	1.077,	-0.476,	1.866
    Data.f 	1.202,	-0.294,	2.082
    Data.f 	0.773,	0,		2.378
    Data.f 	0.743,	0.294,	2.287
    Data.f 	0.666,	0.476,	2.049
    Data.f 	0.57,		0.476,	1.755
    Data.f 	0.493,	0.294,	1.517
    Data.f 	0.464,	0,		1.427
    Data.f 	0.493,	-0.294,	1.517
    Data.f 	0.57,		-0.476,	1.755
    Data.f 	0.666,	-0.476,	2.049
    Data.f 	0.743,	-0.294,	2.287
    Data.f 	0.261,	0,		2.486
    Data.f 	0.251,	0.294,	2.391
    Data.f 	0.225,	0.476,	2.143
    Data.f 	0.193,	0.476,	1.835
    Data.f 	0.167,	0.294,	1.587
    Data.f 	0.157,	0,		1.492
    Data.f 	0.167,	-0.294,	1.587
    Data.f 	0.193,	-0.476,	1.835
    Data.f 	0.225,	-0.476,	2.143
    Data.f 	0.251,	-0.294,	2.391
    Data.f 	-0.261,	0,		2.486
    Data.f 	-0.251,	0.294,	2.391
    Data.f 	-0.225,	0.476,	2.143
    Data.f 	-0.193,	0.476,	1.835
    Data.f 	-0.167,	0.294,	1.587
    Data.f 	-0.157,	0,		1.492
    Data.f 	-0.167,	-0.294,	1.587
    Data.f 	-0.193,	-0.476,	1.835
    Data.f 	-0.225,	-0.476,	2.143
    Data.f 	-0.251,	-0.294,	2.391
    Data.f 	-0.773,	0,		2.378
    Data.f 	-0.743,	0.294,	2.287
    Data.f 	-0.666,	0.476,	2.049
    Data.f 	-0.57,	0.476,	1.755
    Data.f 	-0.493,	0.294,	1.517
    Data.f 	-0.464,	0,		1.427
    Data.f 	-0.493,	-0.294,	1.517
    Data.f 	-0.57,	-0.476,	1.755
    Data.f 	-0.666,	-0.476,	2.049
    Data.f 	-0.743,	-0.294,	2.287
    Data.f 	-1.25 ,	0,		2.165
    Data.f 	-1.202,	0.294,	2.082
    Data.f 	-1.077,	0.476,	1.866
    Data.f 	-0.923,	0.476,	1.598
    Data.f 	-0.798,	0.294,	1.382
    Data.f 	-0.75,	0,		1.299
    Data.f 	-0.798,	-0.294,	1.382
    Data.f 	-0.923,	-0.476,	1.598
    Data.f 	-1.077,	-0.476,	1.866
    Data.f 	-1.202,	-0.294,	2.082
    Data.f 	-1.673,	0,		1.858
    Data.f 	-1.609,	0.294,	1.787
    Data.f 	-1.442,	0.476,	1.601
    Data.f 	-1.235,	0.476,	1.371
    Data.f 	-1.068,	0.294,	1.186
    Data.f 	-1.004,	0,		1.115
    Data.f 	-1.068,	-0.294,	1.186
    Data.f 	-1.235,	-0.476,	1.371
    Data.f 	-1.442,	-0.476,	1.601
    Data.f 	-1.609,	-0.294,	1.787
    Data.f 	-2.023,	0,		1.469
    Data.f 	-1.945,	0.294,	1.413
    Data.f 	-1.743,	0.476,	1.266
    Data.f 	-1.493,	0.476,	1.085
    Data.f 	-1.291,	0.294,	0.938
    Data.f 	-1.214,	0,		0.882
    Data.f 	-1.291,	-0.294,	0.938
    Data.f 	-1.493,	-0.476,	1.085
    Data.f 	-1.743,	-0.476,	1.266
    Data.f 	-1.945,	-0.294,	1.413
    Data.f 	-2.284,	0,		1.017
    Data.f 	-2.197,	0.294,	0.978
    Data.f 	-1.968,	0.476,	0.876
    Data.f 	-1.686,	0.476,	0.751
    Data.f 	-1.458,	0.294,	0.649
    Data.f 	-1.37,	0,		0.61 
    Data.f 	-1.458,	-0.294,	0.649
    Data.f 	-1.686,	-0.476,	0.751
    Data.f 	-1.968,	-0.476,	0.876
    Data.f 	-2.197,	-0.294,	0.978
    Data.f 	-2.445,	0,		0.52
    Data.f 	-2.352,	0.294,	0.5
    Data.f 	-2.107,	0.476,	0.448
    Data.f 	-1.805,	0.476,	0.384
    Data.f 	-1.561,	0.294,	0.332
    Data.f 	-1.467,	0,		0.312
    Data.f 	-1.561,	-0.294,	0.332
    Data.f 	-1.805,	-0.476,	0.384
    Data.f 	-2.107,	-0.476,	0.448
    Data.f 	-2.352,	-0.294,	0.5
    Data.f 	-2.5  ,	0,		0
    Data.f 	-2.405,	0.294,	0
    Data.f 	-2.155,	0.476,	0
    Data.f 	-1.845,	0.476,	0
    Data.f 	-1.595,	0.294,	0
    Data.f 	-1.5,		0,		0
    Data.f 	-1.595,	-0.294,	0
    Data.f 	-1.845,	-0.476,	0
    Data.f 	-2.155,	-0.476,	0
    Data.f 	-2.405,	-0.294,	0
    Data.f 	-2.445,	0,		-0.52
    Data.f 	-2.352,	0.294,	-0.5
    Data.f 	-2.107,	0.476,	-0.448
    Data.f 	-1.805,	0.476,	-0.384
    Data.f 	-1.561,	0.294,	-0.332
    Data.f 	-1.467,	0,		-0.312
    Data.f 	-1.561,	-0.294,	-0.332
    Data.f 	-1.805,	-0.476,	-0.384
    Data.f 	-2.107,	-0.476,	-0.448
    Data.f 	-2.352,	-0.294,	-0.5
    Data.f 	-2.284,	0,		-1.017
    Data.f 	-2.197,	0.294,	-0.978
    Data.f 	-1.968,	0.476,	-0.876
    Data.f 	-1.686,	0.476,	-0.751
    Data.f 	-1.458,	0.294,	-0.649
    Data.f 	-1.37,	0,		-0.61
    Data.f 	-1.458,	-0.294,	-0.649
    Data.f 	-1.686,	-0.476,	-0.751
    Data.f 	-1.968,	-0.476,	-0.876
    Data.f 	-2.197,	-0.294,	-0.978
    Data.f 	-2.023,	0,		-1.469
    Data.f 	-1.945,	0.294,	-1.413
    Data.f 	-1.743,	0.476,	-1.266
    Data.f 	-1.493,	0.476,	-1.085
    Data.f 	-1.291,	0.294,	-0.938
    Data.f 	-1.214,	0,		-0.882
    Data.f 	-1.291,	-0.294,	-0.938
    Data.f 	-1.493,	-0.476,	-1.085
    Data.f 	-1.743,	-0.476,	-1.266
    Data.f 	-1.945,	-0.294,	-1.413
    Data.f 	-1.673,	0,		-1.858
    Data.f 	-1.609,	0.294,	-1.787
    Data.f 	-1.442,	0.476,	-1.601
    Data.f 	-1.235,	0.476,	-1.371
    Data.f 	-1.068,	0.294,	-1.186
    Data.f 	-1.004,	0,		-1.115
    Data.f 	-1.068,	-0.294,	-1.186
    Data.f 	-1.235,	-0.476,	-1.371
    Data.f 	-1.442,	-0.476,	-1.601
    Data.f 	-1.609,	-0.294,	-1.787
    Data.f 	-1.25 ,	0,		-2.165
    Data.f 	-1.202,	0.294,	-2.082
    Data.f 	-1.077,	0.476,	-1.866
    Data.f 	-0.923,	0.476,	-1.598
    Data.f 	-0.798,	0.294,	-1.382
    Data.f 	-0.75,	0,		-1.299
    Data.f 	-0.798,	-0.294,	-1.382
    Data.f 	-0.923,	-0.476,	-1.598
    Data.f 	-1.077,	-0.476,	-1.866
    Data.f 	-1.202,	-0.294,	-2.082
    Data.f 	-0.773,	0,		-2.378
    Data.f 	-0.743,	0.294,	-2.287
    Data.f 	-0.666,	0.476,	-2.049
    Data.f 	-0.57,	0.476,	-1.755
    Data.f 	-0.493,	0.294,	-1.517
    Data.f 	-0.464,	0,		-1.427
    Data.f 	-0.493,	-0.294,	-1.517
    Data.f 	-0.57,	-0.476,	-1.755
    Data.f 	-0.666,	-0.476,	-2.049
    Data.f 	-0.743,	-0.294,	-2.287
    Data.f 	-0.261,	0,		-2.486
    Data.f 	-0.251,	0.294,	-2.391
    Data.f 	-0.225,	0.476,	-2.143
    Data.f 	-0.193,	0.476,	-1.835
    Data.f 	-0.167,	0.294,	-1.587
    Data.f 	-0.157,	0,		-1.492
    Data.f 	-0.167,	-0.294,	-1.587
    Data.f 	-0.193,	-0.476,	-1.835
    Data.f 	-0.225,	-0.476,	-2.143
    Data.f 	-0.251,	-0.294,	-2.391
    Data.f 	0.261,	0,		-2.486
    Data.f 	0.251,	0.294,	-2.391
    Data.f 	0.225,	0.476,	-2.143
    Data.f 	0.193,	0.476,	-1.835
    Data.f 	0.167,	0.294,	-1.587
    Data.f 	0.157,	0,		-1.492
    Data.f 	0.167,	-0.294,	-1.587
    Data.f 	0.193,	-0.476,	-1.835
    Data.f 	0.225,	-0.476,	-2.143
    Data.f 	0.251,	-0.294,	-2.391
    Data.f 	0.773,	0,		-2.378
    Data.f 	0.743,	0.294,	-2.287
    Data.f 	0.666,	0.476,	-2.049
    Data.f 	0.57,		0.476,	-1.755
    Data.f 	0.493,	0.294,	-1.517
    Data.f 	0.464,	0,		-1.427
    Data.f 	0.493,	-0.294,	-1.517
    Data.f 	0.57,		-0.476,	-1.755
    Data.f 	0.666,	-0.476,	-2.049
    Data.f 	0.743,	-0.294,	-2.287
    Data.f 	1.25,		0,		-2.165
    Data.f 	1.202,	0.294,	-2.082
    Data.f 	1.077,	0.476,	-1.866
    Data.f 	0.923,	0.476,	-1.598
    Data.f 	0.798,	0.294,	-1.382
    Data.f 	0.75,		0,		-1.299
    Data.f 	0.798,	-0.294,	-1.382
    Data.f 	0.923,	-0.476,	-1.598
    Data.f 	1.077,	-0.476,	-1.866
    Data.f 	1.202,	-0.294,	-2.082
    Data.f 	1.673,	0,		-1.858
    Data.f 	1.609,	0.294,	-1.787
    Data.f 	1.442,	0.476,	-1.601
    Data.f 	1.235,	0.476,	-1.371
    Data.f 	1.068,	0.294,	-1.186
    Data.f 	1.004,	0,		-1.115
    Data.f 	1.068,	-0.294,	-1.186
    Data.f 	1.235,	-0.476,	-1.371
    Data.f 	1.442,	-0.476,	-1.601
    Data.f 	1.609,	-0.294,	-1.787
    Data.f 	2.023,	0,		-1.469
    Data.f 	1.945,	0.294,	-1.413
    Data.f 	1.743,	0.476,	-1.266
    Data.f 	1.493,	0.476,	-1.085
    Data.f 	1.291,	0.294,	-0.938
    Data.f 	1.214,	0,		-0.882
    Data.f 	1.291,	-0.294,	-0.938
    Data.f 	1.493,	-0.476,	-1.085
    Data.f 	1.743,	-0.476,	-1.266
    Data.f 	1.945,	-0.294,	-1.413
    Data.f 	2.284,	0,		-1.017
    Data.f 	2.197,	0.294,	-0.978
    Data.f 	1.968,	0.476,	-0.876
    Data.f 	1.686,	0.476,	-0.751
    Data.f 	1.458,	0.294,	-0.649
    Data.f 	1.37,		0,		-0.61  
    Data.f 	1.458,	-0.294,	-0.649
    Data.f 	1.686,	-0.476,	-0.751
    Data.f 	1.968,	-0.476,	-0.876
    Data.f 	2.197,	-0.294,	-0.978
    Data.f 	2.445,	0,		-0.52  
    Data.f 	2.352,	0.294,	-0.5  
    Data.f 	2.107,	0.476,	-0.448
    Data.f 	1.805,	0.476,	-0.384
    Data.f 	1.561,	0.294,	-0.332
    Data.f 	1.467,	0,		-0.312
    Data.f 	1.561,	-0.294,	-0.332
    Data.f 	1.805,	-0.476,	-0.384
    Data.f 	2.107,	-0.476,	-0.448
    Data.f 	2.352,	-0.294,	-0.5
  
  EndDataSection
  
  Declare New(shape.i)
  Declare Delete(*Me.Implicit_t)
  Declare Set(*Me.Implicit_t,shape.i)
  Declare SetColor(*Me.Implicit_t,*color.v3f32)
  Declare RandomizeColors(*Me.Implicit_t,*color.v3f32,variance.f=0.5)
  Declare GetVertices(shape.i)
EndDeclareModule

Module Implicit
  UseModule Math
   ; ----------------------------------------------------------------------------
  ;  Set Color
  ; ----------------------------------------------------------------------------
  Procedure SetColor(*Me.Implicit_t,*color.v3f32)
    Protected i
    Protected *c.v3f32
    For i=0 To *Me\nbp-1
      *c = CArray::GetValue(*Me\colors,i)
      *c\x = *color\x 
      *c\y = *color\y 
      *c\z = *color\z 
    Next
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Randomize Color
  ; ----------------------------------------------------------------------------
  Procedure RandomizeColors(*Me.Implicit_t,*color.v3f32,variance.f=0.5)
    Protected i
    Protected *c.v3f32
    For i=0 To *Me\nbp-1
      *c = CArray::GetValue(*Me\colors,i)
      *c\x = *color\x + (Random(100)*0.02-1)*variance
      *c\y = *color\y + (Random(100)*0.02-1)*variance
      *c\z = *color\z + (Random(100)*0.02-1)*variance
    Next
    
  EndProcedure

  ; ----------------------------------------------------------------------------
  ;  Set
  ; ----------------------------------------------------------------------------
   Procedure Set(*Me.Shape_t,shape.i)
     Protected f.f
     Protected l.l
     Protected color.v3f32
     Vector3::Set(@color,Random(255)/255,Random(255)/255,Random(255)/255)
    Select shape
      Case  #IMPLICIT_NONE 
      Case  #IMPLICIT_AXIS
        *Me\nbp = #AXIS_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        
        *Me\positions\data = ?implicit_axis_positions
        
      Case  #SHAPE_SPHERE
        *Me\nbp = #SPHERE_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        CopyMemory(?implicit_sphere_positions, *Me\positions\data, *Me\nbp*CArray::GetItemSize(*Me\positions))
        
      Case  #SHAPE_CUBE
        *Me\nbp = #CUBE_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        CopyMemory(?shape_cube_positions, *Me\positions\data, *Me\nbp*CArray::GetItemSize(*Me\positions))

        
      Case  #SHAPE_DISC
        *Me\nbp = #DISC_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        CopyMemory(?shape_disc_positions, *Me\positions\data, *Me\nbp*CArray::GetItemSize(*Me\positions))

        
      Case  #SHAPE_CYLINDER
        *Me\nbp = #CYLINDER_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        CopyMemory(?shape_grid_positions, *Me\positions\data, *Me\nbp*CArray::GetItemSize(*Me\positions))

        
      Case  #SHAPE_NULL
        *Me\nbp = #NULL_NUM_VERTICES
        CArray::SetCount(*Me\positions,*Me\nbp)
        CopyMemory(?shape_null_positions, *Me\positions\data, *Me\nbp*CArray::GetItemSize(*Me\positions))

        
;       Case  #SHAPE_ARROW
;          *Me\nbp = #ARROW_NUM_VERTICES
;         *Me\nbt = #ARROW_NUM_TRIANGLES
;         CArray::SetCount(*Me\positions,*Me\nbp)
;         CArray::SetCount(*Me\normals,*Me\nbp)
;         CArray::SetCount(*Me\colors,*Me\nbp)
;         CArray::SetCount(*Me\indices,*Me\nbt*3)
;         
;         CopyMemory(?shape_axis_positions,*Me\positions,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_axis_positions,*Me\normals,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_axis_positions,*Me\colors,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_grid_indices,*Me\indices,#ARROW_NUM_TRIANGLES*3*#PB_Long )
        
    EndSelect
  EndProcedure
  
  Procedure GetVertices(shape.i)
    Select shape
      Case  #IMPLICIT_NONE 
      Case  #IMPLICIT_AXIS
        ProcedureReturn ?shape_axis_positions
        
      Case  #IMPLICIT_SPHERE
        ProcedureReturn ?shape_sphere_positions
       

      Case  #IMPLICIT_CUBE
        ProcedureReturn ?shape_cube_positions
        
      Case  #IMPLICIT_DISC
        ProcedureReturn ?shape_disc_positions
        
      Case  #IMPLICIT_CYLINDER
        ProcedureReturn ?shape_cylinder_positions

      Case  #IMPLICIT_NULL
        ProcedureReturn ?shape_null_positions
        
;       Case  #SHAPE_ARROW
;          *Me\nbp = #ARROW_NUM_VERTICES
;         *Me\nbt = #ARROW_NUM_TRIANGLES
;         CArray::SetCount(*Me\positions,*Me\nbp)
;         CArray::SetCount(*Me\normals,*Me\nbp)
;         CArray::SetCount(*Me\colors,*Me\nbp)
;         CArray::SetCount(*Me\indices,*Me\nbt*3)
;         
;         CopyMemory(?shape_axis_positions,*Me\positions,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_axis_positions,*Me\normals,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_axis_positions,*Me\colors,#ARROW_NUM_VERTICES*3*#PB_Float)
;         CopyMemory(?shape_grid_indices,*Me\indices,#ARROW_NUM_TRIANGLES*3*#PB_Long )
        
      Case  #IMPLICIT_TORUS
        ProcedureReturn ?shape_torus_positions

    EndSelect

  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
  ;  New
  ; ----------------------------------------------------------------------------
  Procedure New(shape.i)
    Protected *Me.Implicit_t = AllocateMemory(SizeOf(Implicit_t))
    *Me\nbp = 0
    *Me\positions = CArray::newCArrayV3F32()

    Set(*Me,shape)

    ProcedureReturn *Me
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  Delete
  ; ----------------------------------------------------------------------------
  Procedure Delete(*Me.Shape_t)
    CArray::Delete(*Me\positions)
  EndProcedure

EndModule

;}
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 212
; FirstLine = 160
; Folding = --
; EnableXP