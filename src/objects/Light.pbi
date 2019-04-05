XIncludeFile "../core/Math.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "LightGeometry.pbi"

DeclareModule Light
  UseModule Math
  UseModule OpenGL
  
  Enumeration
    #Light_Point
    #Light_Infinite
    #Light_Spot
  EndEnumeration

  Structure Light_t Extends Object3D::Object3D_t
    color.v3f32
    
    linear.f
    quadratic.f
    lighttype.i
    fov.f
    aspect.f
    nearplane.f
    farplane.f
    falloff.f               ; focus fallof
    focus.f                 ; focus Point saved as distance to camera
    
    widthplane.f
    heightplane.f
    depthplane.f
    
    lookat.v3f32
    up.v3f32
    pos.v3f32
    
    polar.f
    azimuth.f
    
    view.m4f32
    projection.m4f32
    
    ; uniforms
    u_model.i
    u_offset.i
    u_color.i
    u_selected.i
  EndStructure
  
  Interface ILight Extends Object3D::IObject3D
  EndInterface
  
  Declare New( name.s,type.i=#Light_Infinite)
  Declare Setup(*Me.Light_t,*pgm.Program::Program_t)
  Declare Update(*Me.Light_t)
  Declare Clean(*Me.Light_t)
  Declare Draw(*Me.Light_t)
  Declare Delete(*Me.Light_t)
  Declare PassToShader(*Me.Light_t,shader.i,ID.i)
  Declare UpdateProjection(*light.Light_t)
  Declare LookAt(*light.Light_t)
  Declare SetDescription(*c.Light_t,fov.f,aspect.f,znear.f,zfar.f)
  Declare Pan(*c.Light_t,deltax.f,deltay.f,width.f,height.f)
  Declare Dolly(*c.Light_t,deltax.f,deltay.f,width.f,height.f)
  Declare Orbit(*c.Light_t,deltax.f,deltay.f,width.f,height.f)
  Declare GetViewMatrix(*Me.Light_t)
  Declare GetProjectionMatrix(*Me.Light_t)
 
  DataSection 
    LightVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  ; Shape Data Section
  ;-------------------------------------------------------------
  ;{
  #SPOT_LIGHT_NUM_TRIANGLES =58
  #SPOT_LIGHT_NUM_VERTICES =42
  #SPOT_LIGHT_NUM_INDICES =174
  #SPOT_LIGHT_NUM_EDGES =66
  DataSection
  	shape_spot_light_positions:
  	Data.GLfloat -0.313149841141,-0.24161555363,0.5545056419
  	Data.GLfloat 0.240889981397,-0.313149841141,0.5545056419
  	Data.GLfloat -0.240889981397,-0.313149841141,-0.0045686408302
  	Data.GLfloat 0.313149841141,-0.24161555363,-0.0045686408302
  	Data.GLfloat -0.240889981397,0.313149841141,0.5545056419
  	Data.GLfloat 0.313149841141,0.24161555363,0.5545056419
  	Data.GLfloat -0.313149841141,0.24161555363,-0.0045686408302
  	Data.GLfloat 0.240889981397,0.313149841141,-0.0045686408302
  	Data.GLfloat -0.240889981397,-0.313149841141,0.5545056419
  	Data.GLfloat -0.313149841141,-0.24161555363,-0.0045686408302
  	Data.GLfloat 0.240889981397,-0.313149841141,-0.0045686408302
  	Data.GLfloat 0.313149841141,-0.24161555363,0.5545056419
  	Data.GLfloat -0.313149841141,0.24161555363,0.5545056419
  	Data.GLfloat -0.240889981397,0.313149841141,-0.0045686408302
  	Data.GLfloat 0.313149841141,0.24161555363,-0.0045686408302
  	Data.GLfloat 0.240889981397,0.313149841141,0.5545056419
  	Data.GLfloat -0.242382528271,-0.42675311287,-0.281120065382
  	Data.GLfloat 0.242382528271,-0.42675311287,-0.281120065382
  	Data.GLfloat -0.42675311287,0.241935193116,-0.281120065382
  	Data.GLfloat -0.42675311287,-0.241935193116,-0.281120065382
  	Data.GLfloat 0.42675311287,-0.241935193116,-0.281120065382
  	Data.GLfloat 0.42675311287,0.241935193116,-0.281120065382
  	Data.GLfloat -0.242382528271,0.42675311287,-0.281120065382
  	Data.GLfloat 0.242382528271,0.42675311287,-0.281120065382
  	Data.GLfloat -5.46437001379e-09,0.00208826138892,-1.38051774781
  	Data.GLfloat 0.0,0.00208825189572,-0.00229077773107
  	Data.GLfloat 0.0,0.00208825822452,-1.70560677238
  	Data.GLfloat -5.46437001379e-09,0.00208826138892,-0.00229077773107
  	Data.GLfloat 5.46437001379e-09,0.00208826138892,-0.00229077773107
  	Data.GLfloat 5.46437001379e-09,0.00208826138892,-1.38051774781
  	Data.GLfloat -0.0674456981279,0.041145847949,-1.38051774781
  	Data.GLfloat 0.0,0.00208825189572,-1.38051774781
  	Data.GLfloat 0.0674456981279,0.041145847949,-1.38051774781
  	Data.GLfloat 0.0,-0.0760269212244,-1.38051774781
  	Data.GLfloat -1.0,-1.0,1.0
  	Data.GLfloat 1.0,-1.0,1.0
  	Data.GLfloat -1.0,-1.0,-1.0
  	Data.GLfloat 1.0,-1.0,-1.0
  	Data.GLfloat -1.0,1.0,1.0
  	Data.GLfloat 1.0,1.0,1.0
  	Data.GLfloat -1.0,1.0,-1.0
  	Data.GLfloat 1.0,1.0,-1.0
  
  	shape_spot_light_indices:
  	Data.GLuint 2,10,1
  	Data.GLuint 2,1,8
  	Data.GLuint 4,13,6
  	Data.GLuint 4,6,12
  	Data.GLuint 0,12,6
  	Data.GLuint 0,6,9
  	Data.GLuint 3,14,5
  	Data.GLuint 3,5,11
  	Data.GLuint 7,15,5
  	Data.GLuint 7,5,14
  	Data.GLuint 4,15,7
  	Data.GLuint 4,7,13
  	Data.GLuint 0,9,2
  	Data.GLuint 0,2,8
  	Data.GLuint 3,11,1
  	Data.GLuint 3,1,10
  	Data.GLuint 10,2,16
  	Data.GLuint 10,16,17
  	Data.GLuint 9,6,18
  	Data.GLuint 9,18,19
  	Data.GLuint 14,3,20
  	Data.GLuint 14,20,21
  	Data.GLuint 13,7,23
  	Data.GLuint 13,23,22
  	Data.GLuint 4,12,0
  	Data.GLuint 4,0,8
  	Data.GLuint 4,8,1
  	Data.GLuint 4,1,11
  	Data.GLuint 4,11,5
  	Data.GLuint 4,5,15
  	Data.GLuint 24,27,28
  	Data.GLuint 24,28,29
  	Data.GLuint 32,33,26
  	Data.GLuint 25,31,29
  	Data.GLuint 25,29,28
  	Data.GLuint 25,28,27
  	Data.GLuint 31,25,27
  	Data.GLuint 31,27,24
  	Data.GLuint 24,30,33
  	Data.GLuint 24,33,31
  	Data.GLuint 24,29,32
  	Data.GLuint 24,32,30
  	Data.GLuint 31,33,32
  	Data.GLuint 31,32,29
  	Data.GLuint 33,30,26
  	Data.GLuint 30,32,26
  	Data.GLuint 34,36,37
  	Data.GLuint 34,37,35
  	Data.GLuint 34,35,39
  	Data.GLuint 34,39,38
  	Data.GLuint 34,38,40
  	Data.GLuint 34,40,36
  	Data.GLuint 35,37,41
  	Data.GLuint 35,41,39
  	Data.GLuint 36,40,41
  	Data.GLuint 36,41,37
  	Data.GLuint 38,39,41
  	Data.GLuint 38,41,40
  
  	shape_spot_light_edges:
  	Data.GLuint 15,7
  	Data.GLuint 2,10
  	Data.GLuint 15,4
  	Data.GLuint 1,8
  	Data.GLuint 1,11
  	Data.GLuint 5,15
  	Data.GLuint 4,12
  	Data.GLuint 14,5
  	Data.GLuint 6,9
  	Data.GLuint 3,14
  	Data.GLuint 14,7
  	Data.GLuint 6,13
  	Data.GLuint 13,4
  	Data.GLuint 13,7
  	Data.GLuint 12,6
  	Data.GLuint 12,0
  	Data.GLuint 8,0
  	Data.GLuint 8,2
  	Data.GLuint 9,2
  	Data.GLuint 9,0
  	Data.GLuint 10,3
  	Data.GLuint 10,1
  	Data.GLuint 11,5
  	Data.GLuint 11,3
  	Data.GLuint 2,16
  	Data.GLuint 16,17
  	Data.GLuint 17,10
  	Data.GLuint 6,18
  	Data.GLuint 18,19
  	Data.GLuint 19,9
  	Data.GLuint 3,20
  	Data.GLuint 20,21
  	Data.GLuint 21,14
  	Data.GLuint 7,23
  	Data.GLuint 23,22
  	Data.GLuint 22,13
  	Data.GLuint 31,25
  	Data.GLuint 24,27
  	Data.GLuint 27,28
  	Data.GLuint 28,29
  	Data.GLuint 31,29
  	Data.GLuint 25,28
  	Data.GLuint 24,31
  	Data.GLuint 25,27
  	Data.GLuint 29,24
  	Data.GLuint 30,33
  	Data.GLuint 32,30
  	Data.GLuint 33,32
  	Data.GLuint 24,30
  	Data.GLuint 33,31
  	Data.GLuint 29,32
  	Data.GLuint 32,26
  	Data.GLuint 26,33
  	Data.GLuint 30,26
  	Data.GLuint 34,36
  	Data.GLuint 36,37
  	Data.GLuint 37,35
  	Data.GLuint 35,34
  	Data.GLuint 35,39
  	Data.GLuint 39,38
  	Data.GLuint 38,34
  	Data.GLuint 38,40
  	Data.GLuint 40,36
  	Data.GLuint 37,41
  	Data.GLuint 41,39
  	Data.GLuint 40,41
  
  EndDataSection
  
  
  #SUN_LIGHT_NUM_TRIANGLES =58
  #SUN_LIGHT_NUM_VERTICES =54
  #SUN_LIGHT_NUM_INDICES =174
  #SUN_LIGHT_NUM_EDGES =66
  DataSection
  	shape_sun_light_positions:
  	Data.GLfloat 0.0,-0.0760269212244,-2.10478813308
  	Data.GLfloat 0.0674456981279,0.041145847949,-2.10478813308
  	Data.GLfloat 0.0,-0.0172665266785,-2.10478813308
  	Data.GLfloat -0.0674456981279,0.041145847949,-2.10478813308
  	Data.GLfloat 0.0167111819893,0.011765650676,-2.10478813308
  	Data.GLfloat 0.0167111819893,0.011765650676,-0.00229077773107
  	Data.GLfloat -0.0167111819893,0.011765650676,-0.00229077773107
  	Data.GLfloat 0.0,0.00208825822452,-2.42987715765
  	Data.GLfloat 0.0,-0.0172665266785,-0.00229077773107
  	Data.GLfloat -0.0167111819893,0.011765650676,-2.10478813308
  	Data.GLfloat -0.125,2.62602191667e-16,0.216506350946
  	Data.GLfloat -1.74996452851e-16,2.49312202284e-16,0.25
  	Data.GLfloat -0.216506350946,2.28091881672e-16,0.125
  	Data.GLfloat 0.125,1.91782955446e-16,0.216506350946
  	Data.GLfloat -0.25,1.55028281993e-16,-4.28925500213e-32
  	Data.GLfloat 0.216506350946,1.05429366385e-16,0.125
  	Data.GLfloat -0.216506350946,6.29887251596e-17,-0.125
  	Data.GLfloat 0.25,1.33898095515e-17,3.06161699787e-17
  	Data.GLfloat -0.216506350946,-0.125,-7.65404249467e-18
  	Data.GLfloat -0.25,8.42090457721e-17,5.1563169182e-33
  	Data.GLfloat -0.125,-0.216506350946,-1.32571904841e-17
  	Data.GLfloat -0.216506350946,0.125,7.65404249467e-18
  	Data.GLfloat -2.74181043064e-18,-0.25,-1.53080849893e-17
  	Data.GLfloat -0.125,0.216506350946,1.32571904841e-17
  	Data.GLfloat 0.125,-0.216506350946,-1.32571904841e-17
  	Data.GLfloat -6.3974150388e-17,0.25,1.53080849893e-17
  	Data.GLfloat 0.216506350946,-0.125,-7.65404249467e-18
  	Data.GLfloat 0.125,0.216506350946,1.32571904841e-17
  	Data.GLfloat 0.25,2.25847518213e-16,1.38291720138e-32
  	Data.GLfloat 0.216506350946,0.125,7.65404249467e-18
  	Data.GLfloat -1.09997323042e-16,-0.125,-0.216506350946
  	Data.GLfloat -1.19485301619e-16,9.95171307615e-17,-0.25
  	Data.GLfloat -8.4075683509e-17,-0.216506350946,-0.125
  	Data.GLfloat -1.09997323042e-16,0.125,-0.216506350946
  	Data.GLfloat -4.86660653987e-17,-0.25,3.06161699787e-17
  	Data.GLfloat -8.4075683509e-17,0.216506350946,-0.125
  	Data.GLfloat -1.32564472884e-17,-0.216506350946,0.125
  	Data.GLfloat -4.86660653987e-17,0.25,0.0
  	Data.GLfloat 1.2665192245e-17,-0.125,0.216506350946
  	Data.GLfloat -1.32564472884e-17,0.216506350946,0.125
  	Data.GLfloat 2.21531708219e-17,2.10539433224e-16,0.25
  	Data.GLfloat 1.2665192245e-17,0.125,0.216506350946
  	Data.GLfloat 0.125,-9.41841001228e-17,-0.216506350946
  	Data.GLfloat -6.3974150388e-17,-8.08941107401e-17,-0.25
  	Data.GLfloat 0.216506350946,-5.96737901277e-17,-0.125
  	Data.GLfloat -0.125,-2.33648639022e-17,-0.216506350946
  	Data.GLfloat -1.0,-1.0,1.0
  	Data.GLfloat 1.0,-1.0,1.0
  	Data.GLfloat -1.0,-1.0,-1.0
  	Data.GLfloat 1.0,-1.0,-1.0
  	Data.GLfloat -1.0,1.0,1.0
  	Data.GLfloat 1.0,1.0,1.0
  	Data.GLfloat -1.0,1.0,-1.0
  	Data.GLfloat 1.0,1.0,-1.0
  
  	shape_sun_light_indices:
  	Data.GLuint 3,1,7
  	Data.GLuint 0,3,7
  	Data.GLuint 4,2,0
  	Data.GLuint 4,0,1
  	Data.GLuint 9,4,1
  	Data.GLuint 9,1,3
  	Data.GLuint 2,9,3
  	Data.GLuint 2,3,0
  	Data.GLuint 2,8,6
  	Data.GLuint 2,6,9
  	Data.GLuint 8,5,6
  	Data.GLuint 8,2,4
  	Data.GLuint 8,4,5
  	Data.GLuint 1,0,7
  	Data.GLuint 9,6,5
  	Data.GLuint 9,5,4
  	Data.GLuint 45,16,14
  	Data.GLuint 45,14,12
  	Data.GLuint 45,12,10
  	Data.GLuint 45,10,11
  	Data.GLuint 45,11,13
  	Data.GLuint 45,13,15
  	Data.GLuint 45,15,17
  	Data.GLuint 45,17,44
  	Data.GLuint 45,44,42
  	Data.GLuint 45,42,43
  	Data.GLuint 33,35,37
  	Data.GLuint 33,37,39
  	Data.GLuint 33,39,41
  	Data.GLuint 33,41,40
  	Data.GLuint 33,40,38
  	Data.GLuint 33,38,36
  	Data.GLuint 33,36,34
  	Data.GLuint 33,34,32
  	Data.GLuint 33,32,30
  	Data.GLuint 33,30,31
  	Data.GLuint 21,23,25
  	Data.GLuint 21,25,27
  	Data.GLuint 21,27,29
  	Data.GLuint 21,29,28
  	Data.GLuint 21,28,26
  	Data.GLuint 21,26,24
  	Data.GLuint 21,24,22
  	Data.GLuint 21,22,20
  	Data.GLuint 21,20,18
  	Data.GLuint 21,18,19
  	Data.GLuint 46,48,49
  	Data.GLuint 46,49,47
  	Data.GLuint 46,47,51
  	Data.GLuint 46,51,50
  	Data.GLuint 46,50,52
  	Data.GLuint 46,52,48
  	Data.GLuint 47,49,53
  	Data.GLuint 47,53,51
  	Data.GLuint 48,52,53
  	Data.GLuint 48,53,49
  	Data.GLuint 50,51,53
  	Data.GLuint 50,53,52
  
  	shape_sun_light_edges:
  	Data.GLuint 3,7
  	Data.GLuint 7,0
  	Data.GLuint 1,7
  	Data.GLuint 4,1
  	Data.GLuint 0,2
  	Data.GLuint 9,3
  	Data.GLuint 0,1
  	Data.GLuint 1,3
  	Data.GLuint 3,0
  	Data.GLuint 4,9
  	Data.GLuint 8,6
  	Data.GLuint 9,2
  	Data.GLuint 8,5
  	Data.GLuint 2,4
  	Data.GLuint 5,4
  	Data.GLuint 6,5
  	Data.GLuint 9,6
  	Data.GLuint 2,8
  	Data.GLuint 12,10
  	Data.GLuint 14,12
  	Data.GLuint 44,42
  	Data.GLuint 17,44
  	Data.GLuint 16,14
  	Data.GLuint 10,11
  	Data.GLuint 11,13
  	Data.GLuint 45,16
  	Data.GLuint 42,43
  	Data.GLuint 15,17
  	Data.GLuint 43,45
  	Data.GLuint 13,15
  	Data.GLuint 26,24
  	Data.GLuint 19,21
  	Data.GLuint 24,22
  	Data.GLuint 18,19
  	Data.GLuint 21,23
  	Data.GLuint 28,26
  	Data.GLuint 29,28
  	Data.GLuint 23,25
  	Data.GLuint 22,20
  	Data.GLuint 20,18
  	Data.GLuint 25,27
  	Data.GLuint 27,29
  	Data.GLuint 38,36
  	Data.GLuint 31,33
  	Data.GLuint 36,34
  	Data.GLuint 30,31
  	Data.GLuint 33,35
  	Data.GLuint 40,38
  	Data.GLuint 41,40
  	Data.GLuint 35,37
  	Data.GLuint 34,32
  	Data.GLuint 32,30
  	Data.GLuint 37,39
  	Data.GLuint 39,41
  	Data.GLuint 46,48
  	Data.GLuint 48,49
  	Data.GLuint 49,47
  	Data.GLuint 47,46
  	Data.GLuint 47,51
  	Data.GLuint 51,50
  	Data.GLuint 50,46
  	Data.GLuint 50,52
  	Data.GLuint 52,48
  	Data.GLuint 49,53
  	Data.GLuint 53,51
  	Data.GLuint 52,53
  
  EndDataSection
  
  #POINT_LIGHT_NUM_TRIANGLES =42
  #POINT_LIGHT_NUM_VERTICES =44
  #POINT_LIGHT_NUM_INDICES =126
  #POINT_LIGHT_NUM_EDGES =48
  DataSection
  	shape_point_light_positions:
  	Data.GLfloat -0.25,-0.433012701892,4.35727871143e-16
  	Data.GLfloat -2.80495811474e-16,-0.5,4.13249681388e-16
  	Data.GLfloat -0.433012701892,-0.25,3.55500955174e-16
  	Data.GLfloat 0.25,-0.433012701892,2.94089398702e-16
  	Data.GLfloat -0.5,1.04770588975e-31,1.94065670826e-16
  	Data.GLfloat 0.433012701892,-0.25,1.10175924599e-16
  	Data.GLfloat -0.433012701892,0.25,-5.32152782921e-18
  	Data.GLfloat 0.5,-6.12323399574e-17,-8.92112740561e-17
  	Data.GLfloat -0.433012701892,0.0,-0.25
  	Data.GLfloat -0.5,0.0,5.24271983851e-17
  	Data.GLfloat -0.25,0.0,-0.433012701892
  	Data.GLfloat -0.433012701892,0.0,0.25
  	Data.GLfloat 6.40134733659e-17,0.0,-0.5
  	Data.GLfloat -0.25,0.0,0.433012701892
  	Data.GLfloat 0.25,0.0,-0.433012701892
  	Data.GLfloat -5.84512065488e-17,0.0,0.5
  	Data.GLfloat 0.433012701892,0.0,-0.25
  	Data.GLfloat 0.25,0.0,0.433012701892
  	Data.GLfloat 0.5,0.0,3.35704143267e-16
  	Data.GLfloat 0.433012701892,0.0,0.25
  	Data.GLfloat -1.50497551857e-16,0.433012701892,-0.25
  	Data.GLfloat -1.69473509011e-16,0.5,5.24271983851e-17
  	Data.GLfloat -9.86542727908e-17,0.25,-0.433012701892
  	Data.GLfloat -1.50497551857e-16,0.433012701892,0.25
  	Data.GLfloat -2.78350365702e-17,-9.18485099361e-17,-0.5
  	Data.GLfloat -9.86542727908e-17,0.25,0.433012701892
  	Data.GLfloat 4.29841996504e-17,-0.25,-0.433012701892
  	Data.GLfloat -2.78350365702e-17,3.06161699787e-17,0.5
  	Data.GLfloat 9.48274787171e-17,-0.433012701892,-0.25
  	Data.GLfloat 4.29841996504e-17,-0.25,0.433012701892
  	Data.GLfloat 1.13803435871e-16,-0.5,3.35704143267e-16
  	Data.GLfloat 9.48274787171e-17,-0.433012701892,0.25
  	Data.GLfloat 0.25,0.433012701892,-3.30873474373e-16
  	Data.GLfloat -5.84512065488e-17,0.5,-3.08395284618e-16
  	Data.GLfloat 0.433012701892,0.25,-2.50646558404e-16
  	Data.GLfloat -0.25,0.433012701892,-1.89235001932e-16
  	Data.GLfloat -1.0,-1.0,1.0
  	Data.GLfloat 1.0,-1.0,1.0
  	Data.GLfloat 1.0,1.0,1.0
  	Data.GLfloat -1.0,1.0,1.0
  	Data.GLfloat -1.0,1.0,-1.0
  	Data.GLfloat 1.0,1.0,-1.0
  	Data.GLfloat 1.0,-1.0,-1.0
  	Data.GLfloat -1.0,-1.0,-1.0
  
  	shape_point_light_indices:
  	Data.GLuint 35,6,4
  	Data.GLuint 35,4,2
  	Data.GLuint 35,2,0
  	Data.GLuint 35,0,1
  	Data.GLuint 35,1,3
  	Data.GLuint 35,3,5
  	Data.GLuint 35,5,7
  	Data.GLuint 35,7,34
  	Data.GLuint 35,34,32
  	Data.GLuint 35,32,33
  	Data.GLuint 23,25,27
  	Data.GLuint 23,27,29
  	Data.GLuint 23,29,31
  	Data.GLuint 23,31,30
  	Data.GLuint 23,30,28
  	Data.GLuint 23,28,26
  	Data.GLuint 23,26,24
  	Data.GLuint 23,24,22
  	Data.GLuint 23,22,20
  	Data.GLuint 23,20,21
  	Data.GLuint 11,13,15
  	Data.GLuint 11,15,17
  	Data.GLuint 11,17,19
  	Data.GLuint 11,19,18
  	Data.GLuint 11,18,16
  	Data.GLuint 11,16,14
  	Data.GLuint 11,14,12
  	Data.GLuint 11,12,10
  	Data.GLuint 11,10,8
  	Data.GLuint 11,8,9
  	Data.GLuint 36,37,38
  	Data.GLuint 36,38,39
  	Data.GLuint 40,39,38
  	Data.GLuint 40,38,41
  	Data.GLuint 42,41,38
  	Data.GLuint 42,38,37
  	Data.GLuint 43,36,39
  	Data.GLuint 43,39,40
  	Data.GLuint 43,42,37
  	Data.GLuint 43,37,36
  	Data.GLuint 43,40,41
  	Data.GLuint 43,41,42
  
  	shape_point_light_edges:
  	Data.GLuint 2,0
  	Data.GLuint 4,2
  	Data.GLuint 34,32
  	Data.GLuint 7,34
  	Data.GLuint 6,4
  	Data.GLuint 0,1
  	Data.GLuint 1,3
  	Data.GLuint 35,6
  	Data.GLuint 32,33
  	Data.GLuint 5,7
  	Data.GLuint 33,35
  	Data.GLuint 3,5
  	Data.GLuint 16,14
  	Data.GLuint 9,11
  	Data.GLuint 14,12
  	Data.GLuint 8,9
  	Data.GLuint 11,13
  	Data.GLuint 18,16
  	Data.GLuint 19,18
  	Data.GLuint 13,15
  	Data.GLuint 12,10
  	Data.GLuint 10,8
  	Data.GLuint 15,17
  	Data.GLuint 17,19
  	Data.GLuint 28,26
  	Data.GLuint 21,23
  	Data.GLuint 26,24
  	Data.GLuint 20,21
  	Data.GLuint 23,25
  	Data.GLuint 30,28
  	Data.GLuint 31,30
  	Data.GLuint 25,27
  	Data.GLuint 24,22
  	Data.GLuint 22,20
  	Data.GLuint 27,29
  	Data.GLuint 29,31
  	Data.GLuint 36,37
  	Data.GLuint 37,38
  	Data.GLuint 38,39
  	Data.GLuint 39,36
  	Data.GLuint 40,39
  	Data.GLuint 38,41
  	Data.GLuint 41,40
  	Data.GLuint 42,41
  	Data.GLuint 37,42
  	Data.GLuint 43,36
  	Data.GLuint 40,43
  	Data.GLuint 43,42
  
  EndDataSection
  ;}
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

Module Light
  UseModule OpenGL
  UseModule OpenGLExt

  ; ============================================================================
  ;  IMPLEMENTATION ( CLight )
  ; ============================================================================
  ;{
  ;-----------------------------------------------------
  ; Setup 
  ;-----------------------------------------------------
  ;{
  Procedure Setup(*Me.Light_t,*pgm.Program::Program_t)
    
    ;---[ Check Datas ]--------------------------------
    If Not *Me Or Not *ctx:ProcedureReturn:EndIf
    
    ; Setup Static Kinematic STate
    Object3D::ResetStaticKinematicState(*Me)
    
    ;Attach Shader
    If *pgm : *Me\shader = *pgm : EndIf
    
    Protected shader.i
    If *Me\shader : shader = *Me\shader\pgm : EndIf
      
    *Me\u_model = glGetUniformLocation(shader,"model")
    *Me\u_offset = glGetUniformLocation(shader,"offset")
    *Me\u_color = glGetUniformLocation(shader,"color")
    *Me\u_selected = glGetUniformLocation(shader,"selected")
    
    ; Create\ReUse Vertex Array Object
    If Not *Me\vao
      glGenVertexArrays(1,@*Me\vao)
    EndIf
    glBindVertexArray(*Me\vao)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *Me\vbo
      glGenBuffers(1,@*Me\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    
    ; Create or ReUse Edge Elements Buffer
    If Not *Me\eab
      glGenBuffers(1,@*Me\eab)
    EndIf 
    glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*Me\eab)
    
    ; Pass data to GPU
    Protected f.GLfloat
    Protected l.GLuint
    Protected length.l
    Protected *mem
    Select *Me\lighttype
      Case #Light_Spot
        length = #SPOT_LIGHT_NUM_VERTICES* 3*SizeOf(f)
        *mem = ?shape_spot_light_positions
        glBufferData(#GL_ARRAY_BUFFER,length,*mem,#GL_STATIC_DRAW)
        
        length = #SPOT_LIGHT_NUM_EDGES*2*SizeOf(l)
        *mem = ?shape_spot_light_edges
        glBufferData(#GL_ELEMENT_ARRAY_BUFFER,length,*mem,#GL_STATIC_DRAW)
        
      Case #Light_Point
        length = #POINT_LIGHT_NUM_VERTICES* 3*SizeOf(f)
        glBufferData(#GL_ARRAY_BUFFER,length,?shape_point_light_positions,#GL_STATIC_DRAW)
        
        length = #POINT_LIGHT_NUM_EDGES*2*SizeOf(l)
        glBufferData(#GL_ELEMENT_ARRAY_BUFFER,length,?shape_point_light_edges,#GL_STATIC_DRAW)
        
      Case #Light_Infinite
        length = #SUN_LIGHT_NUM_VERTICES* 3*SizeOf(f)
        glBufferData(#GL_ARRAY_BUFFER,length,?shape_sun_light_positions,#GL_STATIC_DRAW)
        
        length = #SUN_LIGHT_NUM_EDGES*2*SizeOf(l)
        glBufferData(#GL_ELEMENT_ARRAY_BUFFER,length,?shape_sun_light_edges,#GL_STATIC_DRAW)
    EndSelect
    
    
    Protected attrib.GLint = glGetAttribLocation(shader,"position")
    glEnableVertexAttribArray(attrib)
    glVertexAttribPointer(attrib,3,#GL_FLOAT,#GL_FALSE,0,0)
  
    *Me\initialized = #True
    *Me\dirty = #False
    
  EndProcedure
  ;}
  
  ;----------------------------------------------------------------------------
  ; Clean
  ;----------------------------------------------------------------------------
  Procedure Clean(*Me.Light_t)
    If *Me\vao : glDeleteVertexArrays(1,@*Me\vao) : EndIf
    If *Me\vbo : glDeleteBuffers(1,@*Me\vbo) : EndIf
    If *Me\eab: glDeleteBuffers(1,@*Me\eab) : EndIf
    
;     Protected i 
;     For i=0 To ArraySize(*Me\vaos())-1
;       If *Me\vaos(i) : glDeleteVertexArrays(1,@*Me\vaos(i)) : EndIf
;     Next
;     For i=0 To ArraySize(*Me\vbos())-1
;       If *Me\vbos(i) : glDeleteBuffers(1,@*Me\vbos(i)) : EndIf
;     Next
;     For i=0 To ArraySize(*Me\eabs())-1
;       If *Me\eabs(i) : glDeleteBuffers(1,@*Me\eabs(i)) : EndIf
;     Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Update
  ;----------------------------------------------------------------------------
  
  Procedure Update(*Me.Light_t)
    UpdateProjection(*Me)
    LookAt(*Me)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------
  Procedure Draw(*Me.Light_t)
  
     ; ---[ Sanity Check ]--------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected *t.Transform::Transform_t = *Me\globalT
    glBindVertexArray(*Me\vao)
    
    ; Set Wireframe Color
;     If *Me\selected
;       glUniform3f(*Me\u_color,1,1,1)
;     Else
      glUniform3f(*Me\u_color,*Me\wireframe_r,*Me\wireframe_g,*Me\wireframe_b)
;     EndIf
    
    glUniformMatrix4fv(*Me\u_model,1,#GL_FALSE,*t\m)
    
    Protected offset.m4f32
    Matrix4::SetIdentity(offset)
    glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
    
    Define l.GLuint
    Define.m4f32 inv_proj
    Matrix4::Inverse(@inv_proj,*Me\projection)
  
        
    ; Draw Shape Plus Frustrum
    Select *Me\lighttype
      Case #Light_Infinite
        glDrawElements(#GL_LINES,(#SUN_LIGHT_NUM_EDGES-12)*2,#GL_UNSIGNED_INT,0)
        glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@inv_proj)
        glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,(#SUN_LIGHT_NUM_EDGES-12)*2*SizeOf(l))
        
      Case #Light_Point
        glDrawElements(#GL_LINES,(#POINT_LIGHT_NUM_EDGES-12)*2,#GL_UNSIGNED_INT,0)
        glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@inv_proj)
        glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,(#POINT_LIGHT_NUM_EDGES-12)*2*SizeOf(l))
  
      Case #Light_Spot
        glDrawElements(#GL_LINES,(#SPOT_LIGHT_NUM_EDGES-12)*2,#GL_UNSIGNED_INT,0)
        glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@inv_proj)
        glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,(#SPOT_LIGHT_NUM_EDGES-12)*2*SizeOf(l))
    EndSelect
    
    glBindVertexArray(0)
   EndProcedure 
   
  ;----------------------------------------------------------------------------
  ; Pick
  ;----------------------------------------------------------------------------
   Procedure Pick()
    Debug "Light OpenGL Pick called..."
  EndProcedure 
  
  ;----------------------------------------------------------------------------
  ; Update Projection
  ;----------------------------------------------------------------------------
  Procedure UpdateProjection(*Me.Light_t)
   ;MAXIMUM(*Me\fov,1)
    Select *Me\lighttype
      Case #Light_Infinite
        Matrix4::GetOrthoMatrix(*Me\projection,-*Me\widthplane,*Me\widthplane,-*Me\heightplane,*Me\heightplane,-*Me\depthplane,*Me\depthplane*2)
        Matrix4::GetViewMatrix(*Me\view,*Me\pos,*Me\lookat,*Me\up)
      Default
        Matrix4::GetProjectionMatrix(*Me\projection,*Me\fov,*Me\aspect,*Me\nearplane,*Me\farplane)
        Matrix4::GetViewMatrix(*Me\view,*Me\pos,*Me\lookat,*Me\up)
     EndSelect
   
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; LookAt
  ;----------------------------------------------------------------------------
  Procedure LookAt(*Me.Light_t)
    Protected dir.v3f32
    Protected *t.Transform::Transform_t = *Me\localT
    
    Vector3::Set(*t\t\scl,1,1,1)
    Vector3::Sub(dir,*Me\lookat,*Me\pos)
    Quaternion::LookAt(*t\t\rot,@dir,*Me\up,#False)
    Vector3::SetFromOther(*t\t\pos,*Me\pos)
    
    Transform::SetMatrixFromSRT(*t\m,*t\t\scl,*t\t\rot,*t\t\pos)
    ;Object3D::UpdateTransform(*Me,#Null)
    ;Protected Me.CCamera = *Me
    ;Me\SetLocalTransform(*t)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Description
  ;----------------------------------------------------------------------------
  Procedure SetDescription(*c.Light_t,fov.f,aspect.f,znear.f,zfar.f)
    If Not fov = #PB_Ignore : *c\fov = fov : EndIf
    If Not aspect = #PB_Ignore : *c\aspect = aspect : EndIf
    If Not znear = #PB_Ignore : *c\nearplane = znear : EndIf
    If Not zfar = #PB_Ignore : *c\farplane = zfar : EndIf
  EndProcedure
  
  
  
  
  ;--------------------------------------------------
  ; Pan
  ;---------------------------------------------------
  Procedure Pan(*c.Light_t,deltax.f,deltay.f,width.f,height.f)

    Protected *t.Transform::Transform_t = *c\localT
    Protected delta.v3f32
    Protected dist.v3f32
    Vector3::Sub(dist,*c\pos,*c\lookat)
    Protected d.f = Vector3::Length(dist)
    delta\x = -deltax/(width/2)*d
    delta\z = deltay/(height/2)*d
    
    Protected *q.q4f32 = *t\t\rot 
    Vector3::MulByQuaternionInPlace(delta,*q)
  
    Vector3::AddInPlace(*c\pos,delta)
    Vector3::AddInPlace(*c\lookat,delta)
    
    ;Update Light Transform
    LookAt(*c)
  
  EndProcedure
  
  ;-----------------------------------------------------------
  ; Dolly
  ;-------------------------------------------------------------
  Procedure Dolly(*c.Light_t,deltax.f,deltay.f,width.f,height.f)

    Protected *t.Transform::Transform_t = *c\localT
    Protected delta.f
    delta = deltay/height
   
    Protected interpolated.v3f32
    Vector3::LinearInterpolate(interpolated,*c\pos,*c\lookat,delta)
    Vector3::Set(*c\pos,interpolated\x,interpolated\y,interpolated\z)
    
    ;Update Light Transform
    LookAt(*c)
  
  EndProcedure
  
  ;-------------------------------------------------------------
  ; Orbit
  ;---------------------------------------------------------------
  Procedure Orbit(*c.Light_t,deltax.f,deltay.f,width.f,height.f)

    Protected r.v3f32,axis.v3f32
    Vector3::Sub(r,*c\pos,*c\lookat)
    Protected d.f = Vector3::Length(r)
    Vector3::Set(r,0,0,d)
    Protected q.q4f32
    
    *c\polar - deltay
    *c\azimuth - deltax
  
    Vector3::Set(axis,1,0,0)
    Quaternion::SetFromAxisAngle(q,axis,*c\polar*#F32_DEG2RAD)
    Vector3::MulByQuaternionInPlace(r,q)
    
    Vector3::Set(axis,0,1,0)
    Quaternion::SetFromAxisAngle(q,axis,*c\azimuth*#F32_DEG2RAD)
    Vector3::MulByQuaternionInPlace(r,q)
    
    Vector3::AddInPlace(r,*c\lookat)
    Vector3::Set(*c\pos,r\x,r\y,r\z)
    
    ;Flip Up Vector if necessary
    Protected p.f = Abs(Mod(*c\polar,360))
    If p< 90 Or p>=270
      Vector3::Set(*c\up,0,1,0)
    Else
      Vector3::Set(*c\up,0,-1,0)
    EndIf
    
    ;Update Light Transform
    LookAt(*c)
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Get Spherical Coordinates
  ;--------------------------------------------------------------------
  Procedure GetSphericalCoordinates(*c.Light_t)
    Protected r.v3f32
    Vector3::Sub(r,*c\pos,*c\lookat)
    Protected d.f = Vector3::Length(r)
    *c\polar = -ACos(r\y/d)*#F32_RAD2DEG
    *c\azimuth = ATan(r\x/r\z)*#F32_RAD2DEG
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Get Projection Matrix
  ;--------------------------------------------------------------------
  Procedure GetProjectionMatrix(*c.Light_t)
   ProcedureReturn *c\projection
  EndProcedure
  
  ;-------------------------------------------------------------------
  ; Get View Matrix
  ;--------------------------------------------------------------------
  Procedure GetViewMatrix(*c.Light_t)
    ProcedureReturn *c\view
  EndProcedure
  
  ;----------------------------------------------------------------
  ; Zoom
  ;-----------------------------------------------------------------
  Procedure Zoom(delta.f)
    Debug "Light Zoom!!!"
  EndProcedure
  
  ;-------------------------------------------------------------
  ; Log
  ;----------------------------------------------------------------
  Procedure Echo(*Me.Light_t)
    Debug "Light Name"+*Me\name
  EndProcedure
  ;}
  
  ;_____________________________________________________________________________
  ;  Destructor
  ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ;{
  ; ---[ _Free ]----------------------------------------------------------------
  Procedure Delete( *Me.Light_t )
    Object3D::DeleteAllAttributes(*Me)
    
    ; ---[ Deallocate Memory ]--------------------------------------------------
    ClearStructure(*Me,Light_t)
    FreeMemory( *Me )
  
  EndProcedure

  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  Procedure New( name.s,type.i=#Light_Infinite)
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.Light_t = AllocateMemory( SizeOf(Light_t) )
    
    ; ---[ Initialize underlying matrices ]-------------------------------------
    InitializeStructure(*Me,Light_t)
    
;     *Me\VT = ?LightVT
;     *Me\classname = "LIGHT"
    Object::INI(Light)
    
    ; ---[ Init Members ]-------------------------------------------------------
    Vector3::Set(*Me\color,1,1,1)
    
    *Me\linear = 0.5
    *Me\quadratic = 0.75
    *Me\type = Object3D::#Object3D_Light
    *Me\name     = name
    *Me\lighttype = type
    
    *Me\lookat\x = 0
    *Me\lookat\y = 0
    *Me\lookat\z = 0
    Select *Me\lighttype
      Case #Light_Infinite
        *Me\pos\x = 1
        *Me\pos\y = 4
        *Me\pos\z = 0.5
        *Me\up\x = 0
        *Me\up\y = 0
        *Me\up\z = 1
      Case #Light_Spot
        *Me\pos\x = 4 
        *Me\pos\y = 25
        *Me\pos\z = 4
        *Me\up\x = 0
        *Me\up\y = 0
        *Me\up\z = 1
        *Me\fov = 75
      Default
        *Me\pos\x = 0
        *Me\pos\y = 0
        *Me\pos\z = 0
        *Me\up\x = 0
        *Me\up\y = 1
        *Me\up\z = 0
    EndSelect
   
    *Me\fov = 90
    *Me\aspect = 1
    *Me\nearplane = 0.1
    *Me\farplane = 10000
    *Me\wireframe_r = 1
    *Me\wireframe_g = 0.66
    *Me\wireframe_b = 0.33
      
    *Me\widthplane = 6
    *Me\heightplane = 6
    *Me\depthplane = 6
    
    *Me\geom = LightGeometry::New(*Me)
    
    LookAt(*Me)
    GetSphericalCoordinates(*Me)
    UpdateProjection(*Me)
    
     ; ---[ Attributes ]---------------------------------------------------------
    Object3D::OBJECT3DATTR()
    
    Protected *position = Attribute::New("Position",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\pos,#True,#False,#True)
    Object3D::AddAttribute(*Me,*position)
    Protected *lookat = Attribute::New("LookAt",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\lookat,#True,#False,#True)
    Object3D::AddAttribute(*Me,*lookat)
    Protected *up = Attribute::New("UpVector",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\up,#True,#False,#True)
    Object3D::AddAttribute(*Me,*up)
    Protected *fov = Attribute::New("FOV",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\fov,#True,#False,#True)
    Object3D::AddAttribute(*Me,*fov)
    Protected *near = Attribute::New("nearplane",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\nearplane,#True,#False,#True)
    Object3D::AddAttribute(*Me,*near)
    Protected *far = Attribute::New("farplane",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\farplane,#True,#False,#True)
    Object3D::AddAttribute(*Me,*far)
    Protected *focus = Attribute::New("focus",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\focus,#True,#False,#True)
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure

  
  ; ============================================================================
  ;  EOF
  ; ============================================================================
  
  ;-------------------------------------------------------------
  ; Pass to Shader
  ;-------------------------------------------------------------
  Procedure PassToShader(*Me.Light_t,shader.i,ID.i)
    glUniform3fv(glGetUniformLocation(shader,"lights[" + Str(ID) + "].position"), 1, *Me\pos)
    glUniform3fv(glGetUniformLocation(shader,"lights[" + Str(ID) + "].color"), 1, *Me\color)
    glUniform1f(glGetUniformLocation(shader,"lights[" + Str(ID) + "].linear"), *Me\linear)
    glUniform1f(glGetUniformLocation(shader,"lights[" + Str(ID) + "].quadratic"), *Me\quadratic)
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( Light )
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1048
; FirstLine = 398
; Folding = d+e--
; EnableXP