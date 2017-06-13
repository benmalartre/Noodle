XIncludeFile "TMTInclude.pbi"

DeclareModule TMTPlanet
  UseModule Math
  Structure TMTPlanet_t
    name.s
    *root.TMTPlanet_t
    inner_radius.f      ; *1e9km
    outer_radius.f      ; *1e9km
    speed.f             ; km/hour
    orbit_radius.f     ; *1e3km
    orbit_axis.v3f32     
    orbit_speed.f       ; *1e3km/hour
    pos.v3f32
    ori.q4f32
    color.v3f32
    img.i
    texture.i
  EndStructure
  
  Declare New(name.s,*root.TMTPlanet_t,in_radius.f,out_radius.f,speed.f,orbit_radius.f,orbit_speed.f)
  Declare Delete(*p.TMTPlanet_t)
  Declare Setup(*p.TMTPlanet_t)
  Declare Compute(*p.TMTPlanet_t,time.f)
  Declare SetColor(*p.TMTPlanet_t,r.f,g.f,b.f)
  Declare SetTexture(*p.TMTPlanet_t,path.s)
  Declare PassToShader(*p.TMTPlanet_t,shader.i)
EndDeclareModule

Module TMTPlanet
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Utils
  ; Constructor
  ;--------------------------------
  Procedure New(name.s,*root.TMTPlanet_t,in_radius.f,out_radius.f,speed.f,orbit_radius.f,orbit_speed.f)  
    Protected *p.TMTPlanet_t = AllocateMemory(SizeOf(TMTPlanet_t))
    *p\name = name
    *p\root = *root
    *p\inner_radius = in_radius
    *p\outer_radius = out_radius
    *p\speed = speed
    *p\orbit_radius = orbit_radius;
    *p\orbit_speed = orbit_speed
    Vector3::Set(*p\orbit_axis,0,1,0)
    Vector3::Set(*p\pos,0,0,0)
    Quaternion::SetIdentity(*p\ori)
    
    ProcedureReturn *p
  EndProcedure
  
  ; Destructor
  ;--------------------------------
  Procedure Delete(*p.TMTPlanet_t)  
    FreeMemory(*p)
  EndProcedure
  
  ; Set Color
  ;--------------------------------
  Procedure SetColor(*p.TMTPlanet_t,r.f,g.f,b.f)  
    *p\color\x = r
    *p\color\y = g
    *p\color\z = b
  EndProcedure
  
  ; Set Texture
  ;--------------------------------
  Procedure SetTexture(*p.TMTPlanet_t,path.s)  
    *p\img = LoadImage(#PB_Any,path)
    If Not IsImage(*p\img)
      MessageRequester("Image Error",*p\name)
    EndIf
    
  EndProcedure
  
  ; Setup
  ;--------------------------------
  Procedure Setup(*p.TMTPlanet_t)  
    If IsImage(*p\img)
      *p\texture = GL_LoadImage(*p\img,#False,#GL_REPEAT,#GL_REPEAT,#GL_LINEAR,#GL_LINEAR)
    Else
      MessageRequester("Image Error",*p\name)
    EndIf
    
  EndProcedure
  
  ; Compute
  ;--------------------------------
  Procedure Compute(*p.TMTPlanet_t,time.f)  
    Protected p.v3f32
    Protected q.q4f32
    Protected axis
    Quaternion::SetFromAxisAngle(@q,*p\orbit_axis,time * *p\orbit_speed)
    
    Vector3::Set(@p,*p\orbit_radius,0,0)
    Vector3::MulByQuaternionInPlace(@p,@q)
    If *p\root
      Vector3::AddInPlace(@p,*p\root\pos)
    EndIf
    
    Vector3::SetFromOther(*p\pos,@p)
    Vector3::Echo(*p\pos,*p\name+" Space Position")
  EndProcedure
  
  ; Pass to Shader
  ;--------------------------------
  Procedure PassToShader(*p.TMTPlanet_t,shader.i)  
    Protected mat3.m3f32
    Matrix3::SetIdentity(@mat3)
    glUniform3f(glGetUniformLocation(shader,"position"),*p\pos\x,*p\pos\y,*p\pos\z)
    glUniform1f(glGetUniformLocation(shader,"inner_radius"),*p\inner_radius)
    glUniform1f(glGetUniformLocation(shader,"outer_radius"),*p\outer_radius)
    glUniformMatrix3fv(glGetUniformLocation(shader,"rotation"),1,#GL_FALSE,@mat3)
    glUniform3f(glGetUniformLocation(shader,"color"),*p\color\x,*p\color\y,*p\color\z)
    glEnable(#GL_TEXTURE_2D)
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D, *p\texture);
    glUniform1i(glGetUniformLocation(shader,"texture"),0)

  EndProcedure
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 80
; FirstLine = 46
; Folding = --
; EnableXP
; Constant = #USE_GLFW=1