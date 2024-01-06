; ============================================================================
; Camera Declare Module
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "CameraGeometry.pbi"

DeclareModule Camera
  UseModule Math
  Enumeration
    #Camera_Perspective
    #Camera_Orthographic
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ;  Camera Structure
  ; ----------------------------------------------------------------------------
  Structure Camera_t Extends Object3D::Object3D_t 
    cameratype.i
    fov.f
    aspect.f
    nearplane.f
    farplane.f
    
    lookat.v3f32
    up.v3f32
    pos.v3f32
    
    polar.f
    azimuth.f
    
    view.m4f32
    projection.m4f32
    
  EndStructure
  
  ; ----------------------------------------------------------------------------
  ;  Camera Interface
  ; ----------------------------------------------------------------------------
  Interface ICamera Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s,type.i)
  Declare Delete(*Me.Camera_t)
  Declare Setup(*Me.Camera_t,*pgm.Program::Program_t)
  Declare Update(*Me.Camera_t)
  Declare Clean(*Me.Camera_t)
  Declare Draw(*Me.Camera_t)
  Declare LookAt(*Me.Camera_t)
  Declare UpdateProjection(*Me.Camera_t)
  Declare SetDescription(*Me.Camera_t,fov.f,aspect.f,znear.f,zfar.f)
  Declare Pan(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
  Declare Dolly(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
  Declare Orbit(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
  Declare GetSphericalCoordinates(*Me.Camera_t)
  Declare OnEvent(*Me.Camera_t,gadget.i)
  Declare Resize(*Me.Camera_t,window.i,gadget)
  Declare GetViewTransform(*Me.Camera_t, *m.m4f32)
  Declare GetViewPlaneNormal(*Me.Camera_t, *n.v3f32)
  Declare MousePositionToWorldPosition(*Me.Camera_t,mx.f,my.f,width.f, height.f,*world_pos.v3f32)
  Declare MousePositionToRayDirection(*Me.Camera_t,mx.f,my.f,width.f, height.f,*ray_dir.v3f32)
  
  DataSection 
    CameraVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule


; ============================================================================
;  Camera Module IMPLEMENTATION
; ============================================================================
Module Camera
  UseModule Math
  UseModule OpenGL
  ;------------------------------------------------------------------
  ; Constructor
  ;------------------------------------------------------------------
  Procedure New(name.s,type.i)
    Protected *Me.Camera_t = AllocateStructure(Camera_t)
      Object::INI(Camera)
          
      *Me\cameratype = type
      *Me\type = Object3D::#Camera
      *Me\name = name
      *Me\geom = CameraGeometry::New(*Me)
      
      Select *Me\cameratype
        Case #Camera_Perspective
          *Me\lookat\x = 0
          *Me\lookat\y = 0
          *Me\lookat\z = 1
          *Me\pos\x = 5
          *Me\pos\y = 8
          *Me\pos\z = 8
          *Me\up\x = 0
          *Me\up\y = 1
          *Me\up\z = 0
          *Me\fov = 66
          *Me\aspect = 1.33
          *Me\nearplane = 0.1
          *Me\farplane = 100000
          
          LookAt(*Me)
          UpdateProjection(*Me)
          GetSphericalCoordinates(*Me)
        
      Case #Camera_Orthographic
        *Me\lookat\x = 0
        *Me\lookat\y = 0
        *Me\lookat\z = 1
        *Me\pos\x = 5
        *Me\pos\y = 8
        *Me\pos\z = 8
        *Me\up\x = 0
        *Me\up\y = 1
        *Me\up\z = 0
        *Me\fov = 33
        *Me\aspect = 1.33
        *Me\nearplane = 0.1
        *Me\farplane = 100000
  
        LookAt(*Me)
        UpdateProjection(*Me)
        GetSphericalCoordinates(*Me)
        
    EndSelect
  
    Protected *position = Attribute::New(*Me,"Position",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\pos,#True,#False,#True)
    Object3D::AddAttribute(*Me,*position)
    Protected *lookat = Attribute::New(*Me,"LookAt",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\lookat,#True,#False,#True)
    Object3D::AddAttribute(*Me,*lookat)
    Protected *up = Attribute::New(*Me,"UpVector",Attribute::#ATTR_TYPE_VECTOR3,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,*Me\up,#True,#False,#True)
    Object3D::AddAttribute(*Me,*up)
    Protected *fov = Attribute::New(*Me,"FOV",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\fov,#True,#False,#True)
    Object3D::AddAttribute(*Me,*fov)
    Protected *near = Attribute::New(*Me,"nearplane",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\nearplane,#True,#False,#True)
    Object3D::AddAttribute(*Me,*near)
    Protected *far = Attribute::New(*Me,"farplane",Attribute::#ATTR_TYPE_FLOAT,Attribute::#ATTR_STRUCT_SINGLE,Attribute::#ATTR_CTXT_SINGLETON,@*Me\farplane,#True,#False,#True)
    Object3D::AddAttribute(*Me,*far)
    
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Destructor
  ;------------------------------------------------------------------
  Procedure Delete(*Me.Camera_t)
    Object::TERM(Camera)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Setup
  ;------------------------------------------------------------------
  Procedure Setup(*Me.Camera_t,*pgm.Program::Program_t)

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Update
  ;------------------------------------------------------------------
  Procedure Update(*Me.Camera_t)

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Clean
  ;------------------------------------------------------------------
  Procedure Clean(*Me.Camera_t)

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Draw
  ;------------------------------------------------------------------
  Procedure Draw(*Me.Camera_t)

  EndProcedure
  
  ;------------------------------------------------------------------
  ; LookAt
  ;------------------------------------------------------------------
  Procedure LookAt(*Me.Camera_t)
    Protected dir.v3f32
    Protected scl.v3f32
    
    Protected t.Transform::Transform_t
    
    Vector3::Set(scl,1,1,1)
    Vector3::Sub(dir,*Me\lookat,*Me\pos)
  
    Quaternion::LookAt(t\t\rot,dir,*Me\up)
    Vector3::SetFromOther(t\t\pos,*Me\pos)
    
    Transform::SetMatrixFromSRT(t\m,t\t\scl,t\t\rot,t\t\pos)
    Matrix4::SetFromOther(*Me\matrix,t\m)
    Matrix4::GetViewMatrix(*Me\view,*Me\pos,*Me\lookat,*Me\up)
  EndProcedure

  ;------------------------------------------------------------------
  ; Update Projection
  ;------------------------------------------------------------------
  Procedure UpdateProjection(*Me.Camera_t)
    Select *Me\cameratype
      Case #Camera_Orthographic
        Matrix4::GetOrthoMatrix(*Me\projection,-10,10,-10,10,-10,20)
        Matrix4::GetViewMatrix(*Me\view,*Me\pos,*Me\lookat,*Me\up)
      Default
        Matrix4::GetProjectionMatrix(*Me\projection,*Me\fov,*Me\aspect,*Me\nearplane,*Me\farplane)
        Matrix4::GetViewMatrix(*Me\view,*Me\pos,*Me\lookat,*Me\up)
     EndSelect
   EndProcedure
   
  ;------------------------------------------------------------------
  ; Set Description
  ;------------------------------------------------------------------
  Procedure SetDescription(*Me.Camera_t,fov.f,aspect.f,znear.f,zfar.f)
    If Not fov = #PB_Ignore : *Me\fov = fov : EndIf
    If Not aspect = #PB_Ignore : *Me\aspect = aspect : EndIf
    If Not znear = #PB_Ignore : *Me\nearplane = znear : EndIf
    If Not zfar = #PB_Ignore : *Me\farplane = zfar : EndIf
  EndProcedure
   
  ;------------------------------------------------------------------
  ; Pan
  ;------------------------------------------------------------------
  Procedure Pan(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
    
    Protected delta.v3f32
    Protected dist.v3f32
    
    Vector3::Sub(dist,*Me\pos,*Me\lookat)
    Protected d.f = Vector3::Length(dist)*Radian(*Me\fov)*0.5
    delta\x = -deltax/(width/2)*d
    delta\y = deltay/(height/2)*d
    delta\z = 0
  
    Protected q.q4f32
    Matrix4::GetQuaternion(*Me\view,q)
    Vector3::MulByQuaternionInPlace(delta,q)

    Vector3::AddInPlace(*Me\pos,delta)
    Vector3::AddInPlace(*Me\lookat,delta)
    
    ;Update Camera Transform
    LookAt(*Me)
;     Protected delta.v3f32
;     Protected dist.v3f32
;   
;     Vector3::Sub(dist,*Me\pos,*Me\lookat)
;     Protected d.f = Vector3::Length(dist)
;     delta\x = -deltax/(width/2)*d
;     delta\y = deltay/(height/2)*d
;     delta\z = 0
;     
;     Protected q.q4f32
;     Matrix4::GetQuaternion(*Me\view,q)
;     Vector3::MulByQuaternionInPlace(delta,q)
; 
;     
;     Vector3::AddInPlace(*Me\pos,delta)
;     Vector3::AddInPlace(*Me\lookat,delta)
;     
;     ;Update Camera Transform
;     LookAt(*Me)
  
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Dolly
  ;------------------------------------------------------------------
  Procedure Dolly(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
    Protected delta.f
    delta = (deltay/height + deltax/width) * 2
  
    Protected interpolated.v3f32
    Vector3::LinearInterpolate(interpolated,*Me\pos,*Me\lookat,delta)
;     Protected diff.v3f32
;     Vector3::Sub(@diff, @interpolate, *Me\pos)
    Vector3::Set(*Me\pos,interpolated\x,interpolated\y,interpolated\z)
;     Vector3::AddInPlace(*Me\lookat, @diff)
    
    ;Update Camera Transform
    LookAt(*Me)
  
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Orbit
  ;------------------------------------------------------------------
  Procedure Orbit(*Me.Camera_t,deltax.f,deltay.f,width.f,height.f)
 
    Protected r.v3f32,axis.v3f32
    Vector3::Sub(r,*Me\pos,*Me\lookat)
    Protected d.f = Vector3::Length(r)
    Vector3::Set(r,0,0,d)
    Protected q.q4f32
    
    *Me\polar - deltay
    *Me\azimuth - deltax
  
    Vector3::Set(axis,1,0,0)
    Quaternion::SetFromAxisAngle(q,axis,*Me\polar*#F32_DEG2RAD)
    Vector3::MulByQuaternionInPlace(r,q)
    
    Vector3::Set(axis,0,1,0)
    Quaternion::SetFromAxisAngle(q,axis,*Me\azimuth*#F32_DEG2RAD)
    Vector3::MulByQuaternionInPlace(r,q)
    
    Vector3::AddInPlace(r,*Me\lookat)
    Vector3::Set(*Me\pos,r\x,r\y,r\z)
    
    ;Flip Up Vector if necessary
    Protected p.f = Abs(Mod(*Me\polar,360))
    If p< 90 Or p>=270
      Vector3::Set(*Me\up,0,1,0)
    Else
      Vector3::Set(*Me\up,0,-1,0)
    EndIf
    
    ;Update Camera Transform
    LookAt(*Me)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get Spherical Coordinates
  ;------------------------------------------------------------------
  Procedure GetSphericalCoordinates(*Me.Camera_t)
    Protected r.v3f32
    Vector3::Sub(r,*Me\pos,*Me\lookat)
    Protected d.f = Vector3::Length(r)
    *Me\polar = -ACos(r\y/d)*#F32_RAD2DEG
    *Me\azimuth = ATan(r\x/r\z)*#F32_RAD2DEG
  EndProcedure
   
  ;------------------------------------------------------------------
  ; Get Projection Matrix
  ;------------------------------------------------------------------
  Procedure GetProjectionMatrix(*Me.Camera_t)
   ProcedureReturn *Me\projection
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get View Matrix
  ;------------------------------------------------------------------
  Procedure GetViewMatrix(*Me.Camera_t)
    ProcedureReturn *Me\view
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Zoom
  ;------------------------------------------------------------------
  Procedure Zoom(*Me.Camera_t,delta.f)
    Debug "Camera Zoom!!!"
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Camera MouseEvent
  ;------------------------------------------------------------------
  Procedure OnEvent(*Me.Camera_t,gadget)
    
     Debug "Camera On Event !!!"

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Resize
  ;------------------------------------------------------------------
  Procedure Resize(*camera.Camera_t,window,gadget)
    Protected width = WindowWidth(window,#PB_Window_InnerCoordinate)
    Protected height = WindowHeight(window,#PB_Window_InnerCoordinate)
    ResizeGadget(gadget,0,0,width,height)
    glViewport(0,0,width,height)
    Protected aspect.f = width/height
    SetDescription(*camera,#PB_Ignore,aspect,#PB_Ignore,#PB_Ignore)
    UpdateProjection(*camera)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get View Transform
  ;------------------------------------------------------------------
  Procedure GetViewTransform(*camera.Camera_t, *m.m4f32)
    Protected tm.m4f32, rm.m4f32
    Protected inv_pos.v3f32
    Vector3::Set(inv_pos, -*camera\pos\x, -*camera\pos\y, -*camera\pos\z)
    Matrix4::TranslationMatrix(tm, inv_pos)
    Matrix4::Echo(tm, "Translation Matrix")
    Matrix4::DirectionMatrix(*m, *camera\lookat, *camera\up)
    Matrix4::Echo(rm, "Direction Matrix")
    Matrix4::Multiply(*m, rm, tm)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get View Plane Normal
  ;------------------------------------------------------------------
  Procedure GetViewPlaneNormal(*Me.Camera_t, *n.v3f32)
    Vector3::Sub(*n, *Me\lookat, *Me\pos)
    Vector3::NormalizeInPlace(*n)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Mouse Position To World Position
  ;------------------------------------------------------------------
  Procedure MousePositionToWorldPosition(*Me.Camera_t,mx.f,my.f,width.f, height.f,*world_pos.v3f32)
    Protected view.v3f32
    Vector3::Sub(view,*Me\lookat,*Me\pos)
    Vector3::NormalizeInPlace(view)
    
    Protected h.v3f32
    Vector3::Cross(h,view,*Me\up)
    Vector3::NormalizeInPlace(h)
    
    Protected v.v3f32
    Vector3::Cross(v,h,view)
    Vector3::NormalizeInPlace(v)
    
    
    Protected rad.f = *Me\fov * #F32_PI / 180
    Protected vLength.f = Tan(rad/2) * *Me\nearplane
    Protected hLength.f = vLength *(width/height)
    
    Vector3::ScaleInPlace(v,vLength)
    Vector3::ScaleInPlace(h,hLength)
    
    ; remap mouse coordinates
    mx - width/2
    my - height/2
    
    mx/(width*0.5)
    my/(height*0.5)
    
  
    Vector3::ScaleInPlace(h,mx)
    Vector3::ScaleInPlace(v,-my)
    
    Protected ray.v3f32
    
    Vector3::ScaleInPlace(view,*Me\nearplane)
    Vector3::AddInPlace(view,*Me\pos)
    Vector3::Add(ray,h,v)
    Vector3::AddInPlace(ray,view)
    Vector3::Sub(*world_pos,ray,*Me\pos)
    Vector3::ScaleInPlace(*world_pos,*Me\farplane)
    Vector3::AddInPlace(*world_pos,*Me\pos)
  EndProcedure
 
  ;------------------------------------------------------------------
  ; Mouse Position To Ray Direction
  ;------------------------------------------------------------------
  Procedure MousePositionToRayDirection(*Me.Camera_t,mx.f,my.f,width.f, height.f,*ray_dir.v3f32)
    ; 3d normalized device coordinates
    Define x.f = (2 * mx) / width - 1
    Define y.f = 1 - (2 * my) / height
    Define z.f = 1
    Define ray_nds.v3f32
    Vector3::Set(ray_nds, x, y, z)
    
    ; 4d homogeneous clip coordinates
    Define ray_clip.v4f32
    Vector4::Set(ray_clip,ray_nds\x,ray_nds\y,-1.0,1.0)
    
    ; 4d eye (camera) coordinates
    Define inv_proj.m4f32
    Matrix4::Inverse(inv_proj,*Me\projection)
    Define ray_eye.v4f32
    Vector4::MulByMatrix4(ray_eye,ray_clip,inv_proj,#False)
    ray_eye\z = -1
    ray_eye\w = 0
    
    ; 4d world coordinates
    Define inv_view.m4f32
    Define ray_world.v4f32
    Matrix4::Inverse(inv_view,*Me\view)
    Vector4::MulByMatrix4(ray_world,ray_eye,inv_view, #False)
    
    Vector3::Set(*ray_dir,ray_world\x,ray_world\y,ray_world\z)
    Vector3::NormalizeInPlace(*ray_dir)

  EndProcedure

  Class::DEF( Camera )
  
 EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 198
; FirstLine = 194
; Folding = -----
; EnableXP
; EnablePurifier