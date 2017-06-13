XIncludeFile "TMTInclude.pbi"
XIncludeFile "TMTPlanet.pbi"
DeclareModule TMTRoot
  UseModule Math
  Structure TMTRoot_t
    *cam.Camera::Camera_t
    rest_ori.q4f32
    *pivot.TMTPlanet::TMTPlanet_t
    orbit_radius.f
    orbit_axis.v3f32
    orbit_speed.f
    root.m4f32
  EndStructure
  
  Declare New(*pivot.TMTPlanet::TMTPlanet_t)
  Declare Delete(*r.TMTRoot_t)
  Declare Update(*r.TMTRoot_t,time.f)
EndDeclareModule


Module TMTRoot
  Procedure New(*pivot.TMTPlanet::TMTPlanet_t)
    Protected *r.TMTRoot_t  = AllocateMemory(SizeOf(TMTRoot_t))
    *r\cam = Camera::New("Main Camera",Camera::#Camera_Perspective)
    *r\pivot = *pivot
    *r\orbit_radius = *pivot\outer_radius*1.5
    Vector3::Set(*r\orbit_axis,0.5,0.5,0)
    *r\orbit_speed = 1000
    ProcedureReturn *r
  EndProcedure
  
  Procedure Delete(*r.TMTRoot_t)
    Camera::Delete(*r\cam)
    FreeMemory(*r)
  EndProcedure
  
  Procedure Update(*r.TMTRoot_t,time.f)
    Protected p.v3f32
    Protected q.q4f32
    Quaternion::SetFromAxisAngle(@q,*r\orbit_axis,time * *r\orbit_speed)

    Vector3::Set(@p,*r\orbit_radius,0,0)
    Vector3::MulByQuaternionInPlace(@p,@q)
    Vector3::AddInPlace(@p,*r\pivot\pos)
    
    Matrix4::SetIdentity(*r\root)
    
    
    Protected side.v3f32,forward.v3f32
    Protected m.m4f32
    Vector3::Sub(@side,*r\pivot\pos,@p)
    Vector3::NormalizeInPlace(@side)
    Vector3::Cross(@forward,@side,*r\orbit_axis)
    
    Quaternion::LookAt(@q,@forward,*r\orbit_axis)
    Matrix4::SetFromQuaternion(*r\root,@q)
    Matrix4::SetTranslation(*r\root,@p)
    
    Vector3::Set(@p,0,0,0)
    Vector3::MulByMatrix4InPlace(@p,*r\root)
    Vector3::SetFromOther(*r\cam\lookat,@p)
    Protected offset.v3f32

    Vector3::Set(@offset,0,4,-5)
    Vector3::MulByMatrix4InPlace(@offset,*r\root)
    Vector3::SetFromOther(*r\cam\pos,@offset)
    
    Camera::LookAt(*r\cam)
;     Camera::UpdateProjection(*r\cam)
    
;     Matrix4::SetFromOther(@m,*r\cam\view)
;     Matrix4::Multiply(*r\cam\view,*r\root,@m)
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 23
; FirstLine = 11
; Folding = -
; EnableXP