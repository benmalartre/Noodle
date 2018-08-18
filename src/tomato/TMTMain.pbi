


MessageRequester("Current Path", #PB_Compiler_FilePath)

XIncludeFile "TMTInclude.pbi"
XIncludeFile "TMTPlanet.pbi"
XIncludeFile "TMTSystem.pbi"
XIncludeFile "TMTRoot.pbi"
XIncludeFile "TMStars.pbi"
EnableExplicit


Time::Init()
Log::Init()
FTGL::Init()
Alembic::Init()

Global *sun.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Sun",#Null,6.96,9.69,0,0,0)
TMTPlanet::SetColor(*sun,1,1,0)
TMTPlanet::SetTexture(*sun,"textures/sun.jpg")
Global *mercury.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Mercury",*sun,2.44,2.88,43,579.10,100)
TMTPlanet::SetColor(*mercury,1,0,0)
TMTPlanet::SetTexture(*mercury,"textures/mercury.jpg")
Global *venus.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Venus",*sun,9.0,10.0,43,1080.0,100)
TMTPlanet::SetColor(*venus,0,1,0)
TMTPlanet::SetTexture(*venus,"textures/venus.jpg")
Global *jupiter.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Jupiter",*sun,6.9911,8.0,43,7780.0,100)
TMTPlanet::SetColor(*jupiter,0,1,0)
TMTPlanet::SetTexture(*jupiter,"textures/jupiter.jpg")
Global *io.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Io",*jupiter,1.820,2.0,22,42.1,200)
TMTPlanet::SetColor(*io,0,0,1)
TMTPlanet::SetTexture(*io,"textures/io.jpg")
Global *europa.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Europa",*jupiter,2.6,3.0,22,107.0,50)
TMTPlanet::SetColor(*europa,0,0,1)
TMTPlanet::SetTexture(*europa,"textures/europa.jpg")
Global *ganymede.TMTPlanet::TMTPlanet_t = TMTPlanet::New("Ganymede",*jupiter,1.511,1.622,22,67.1034,100)
TMTPlanet::SetColor(*ganymede,0,0,1)
TMTPlanet::SetTexture(*ganymede,"textures/ganymede.jpg")

Global *stars.TMStars::TMStars_t 
; Root
;-----------------------------------------------------
Global *root.TMTRoot::TMTRoot_t = TMTRoot::New(*ganymede)


; FTGL Drawer
;-----------------------------------------------------

Global *ftgl_drawer 

Global *quad.ScreenQuad::ScreenQuad_t = ScreenQuad::New()
Global s_vert.s = "#version 330"+Chr(10)
  s_vert + "layout (location = 0) in vec2 position;"+Chr(10)
  s_vert + "layout (location = 1) in vec2 coords;"+Chr(10)
  s_vert + "out vec2 texCoords;"+Chr(10)
  s_vert + "void main()"+Chr(10)
  s_vert + "{"+Chr(10)
  s_vert + "    gl_Position = vec4(position,0.0f,1.0f);"+Chr(10)
  s_vert + "    texCoords = coords;"+Chr(10)
  s_vert + "}"
  
 
; Global s_frag.s = "#version 330"+Chr(10)
;   s_frag + "in vec2 texCoords;"+Chr(10)
;   s_frag + "out vec4 outColor;"+Chr(10)
;   s_frag + "uniform float iGlobalTime;"+Chr(10)
;   s_frag + "uniform vec2 iResolution;"+Chr(10)
;   s_frag + "void main(){"+Chr(10)
;   s_frag + "outColor = vec4(texCoords,0.0,1.0);"+Chr(10)
;   s_frag + "}"
  
  Global s_sun.s = Shader::LoadFile("glsl/sun.glsl")
  Global s_planet.s = Shader::LoadFile("glsl/planet.glsl")
  Global s_moon.s = Shader::LoadFile("glsl/moon.glsl")
  Global s_moon_atmosphere.s = Shader::LoadFile("glsl/moonatmosphere.glsl")
  
  Global *sun_pgm.Program::Program_t
  Global *planet_pgm.Program::Program_t
  Global *moon_pgm.Program::Program_t
  Global *moonatmosphere_pgm.Program::Program_t
  Global *polymesh_pgm.Program::Program_t
  Global *stars_pgm.Program::Program_t
  Global *camera.Camera::Camera_t
  Global *ship.Model::Model_t
  Global ship.Object3D::IObject3D = *ship

UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt
UseModule Math

Procedure UpdateWorld(*app.Application::Application_t)
  Protected T.f = Time::Get()*0.0001
  Application::GetFPS(*app)
  TMTPlanet::Compute(*sun,T)
  TMTPlanet::Compute(*mercury,T)
  TMTPlanet::Compute(*venus,T)
  TMTPlanet::Compute(*jupiter,T)
  TMTPlanet::Compute(*io,T)
  TMTPlanet::Compute(*europa,T)
  TMTPlanet::Compute(*ganymede,T)
;   ship\Update()
  TMTRoot::Update(*root,T)

  Matrix4::GetQuaternion(*root\root,*ship\globalT\t\rot)
  Vector3::Set(*ship\globalT\t\pos,*root\root\v[12],*root\root\v[13],*root\root\v[14])
  Vector3::Set(*ship\globalT\t\scl,0.05,0.05,0.05)
  Transform::UpdateMatrixFromSRT(*ship\globalT)

  Matrix4::SetFromOther(*ship\matrix,*ship\globalT\m)
  Protected w,h
  Protected model.m4f32
  Matrix4::SetIdentity(@model)
  glfwMakeContextCurrent(*app\window)
  glfwGetWindowSize(*app\window,@w,@h)
  ;SetGadgetAttribute(*vp\gadgetID,#PB_OpenGL_SetContext,#True)
  
  glClearColor(0,0,0,1.0)
  glViewport(0, 0, w,h)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glEnable(#GL_DEPTH_TEST)
  
  
  glDepthMask(#GL_FALSE)
  glEnable(#GL_TEXTURE_2D)
;   glActiveTexture(#GL_TEXTURE0)
;   glBindTexture(#GL_TEXTURE_2D, textureID);
;   glActiveTexture(#GL_TEXTURE1)
;   glBindTexture(#GL_TEXTURE_2D, textureID2);
  
  
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_ONE,#GL_ONE_MINUS_SRC_ALPHA)
  
  glUseProgram(*stars_pgm\pgm)
  glUniformMatrix4fv(glGetUniformLocation(*stars_pgm\pgm,"model"),1,#GL_FALSE,@model)

  glUniformMatrix4fv(glGetUniformLocation(*stars_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*stars_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  glUniform3f(glGetUniformLocation(*stars_pgm\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  TMStars::Update(*stars,T)

  ;   Framebuffer::BindOutput(*buffer)
  glUseProgram(*sun_pgm\pgm)
  glUniformMatrix4fv(glGetUniformLocation(*sun_pgm\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*sun_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*sun_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  ;glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform1f(glGetUniformLocation(*sun_pgm\pgm,"iGlobalTime"),Time::Get())
  glUniform2f(glGetUniformLocation(*sun_pgm\pgm,"iResolution"),w,h)

  TMTPlanet::PassToShader(*sun,*sun_pgm\pgm)
  ScreenQuad::Draw(*quad)
  
  glUseProgram(*planet_pgm\pgm)
  glUniformMatrix4fv(glGetUniformLocation(*planet_pgm\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*planet_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*planet_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  ;glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform1f(glGetUniformLocation(*planet_pgm\pgm,"iGlobalTime"),Time::Get())
  glUniform2f(glGetUniformLocation(*planet_pgm\pgm,"iResolution"),w,h)


  
  TMTPlanet::PassToShader(*mercury,*planet_pgm\pgm)
  ScreenQuad::Draw(*quad)
  TMTPlanet::PassToShader(*jupiter,*planet_pgm\pgm)
  ScreenQuad::Draw(*quad)
  TMTPlanet::PassToShader(*venus,*planet_pgm\pgm)
  ScreenQuad::Draw(*quad)
  
  glUseProgram(*moon_pgm\pgm)
  glUniformMatrix4fv(glGetUniformLocation(*moon_pgm\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*moon_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*moon_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  ;glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform1f(glGetUniformLocation(*moon_pgm\pgm,"iGlobalTime"),Time::Get())
  glUniform2f(glGetUniformLocation(*moon_pgm\pgm,"iResolution"),w,h)


  TMTPlanet::PassToShader(*io,*moon_pgm\pgm)
  ScreenQuad::Draw(*quad)
  TMTPlanet::PassToShader(*europa,*moon_pgm\pgm)
  ScreenQuad::Draw(*quad)
  
  glUseProgram(*moonatmosphere_pgm\pgm)
  glUniformMatrix4fv(glGetUniformLocation(*moonatmosphere_pgm\pgm,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*moonatmosphere_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*moonatmosphere_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
  ;glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform1f(glGetUniformLocation(*moonatmosphere_pgm\pgm,"iGlobalTime"),Time::Get())
  glUniform2f(glGetUniformLocation(*moonatmosphere_pgm\pgm,"iResolution"),w,h)
  TMTPlanet::PassToShader(*ganymede,*moonatmosphere_pgm\pgm)
  ScreenQuad::Draw(*quad)
  
  glUseProgram(*polymesh_pgm\pgm)
  glDepthMask(#GL_TRUE)
  glUniformMatrix4fv(glGetUniformLocation(*polymesh_pgm\pgm,"model"),1,#GL_FALSE,*ship\matrix)
  glUniformMatrix4fv(glGetUniformLocation(*polymesh_pgm\pgm,"view"),1,#GL_FALSE,*camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*polymesh_pgm\pgm,"projection"),1,#GL_FALSE,*camera\projection)
;   glUniform3f(glGetUniformLocation(*polymesh_pgm\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  
  Model::Draw(*ship,*app\context)
  ;ship\Draw()
  
  FTGL::BeginDraw(*ftgl_drawer)
  If w>0
    Define ss.f = 0.85/w
    Define ratio.f = w / h

    FTGL::Draw(*ftgl_drawer,"Date : "+FormatDate("%dd/%mm/%yyyy", Date()),-0.9,0.95,ss,ss*ratio)
    FTGL::Draw(*ftgl_drawer,"Time : "+FormatDate("%hh:%ii:%ss", Date()),-0.9,0.9,ss,ss*ratio)
    FTGL::Draw(*ftgl_drawer,"User : "+UserName(),-0.9,0.85,ss,ss*ratio)
    FTGL::Draw(*ftgl_drawer,"FPS : "+StrF(*app\fps),-0.9,0.8,ss,ss*ratio)
  EndIf
  FTGL::EndDraw(*ftgl_drawer)

EndProcedure




Define *app.Application::Application_t = Application::New("Solar System",800,600)
*ship = Alembic::LoadABCArchive("abc/Ship.abc")

*camera = *root\cam
;*camera = *app\camera
*sun_pgm =  Program::New("Sun",s_vert,s_sun)
*planet_pgm =  Program::New("Planet",s_vert,s_planet)
*moon_pgm =  Program::New("Moon",s_vert,s_moon)
*moonatmosphere_pgm =  Program::New("Moon",s_vert,s_moon_atmosphere)
*polymesh_pgm =  Program::New("Mesh",Shader::LoadFile("glsl\polymesh_vertex.glsl"),Shader::LoadFile("glsl\polymesh_fragment.glsl"))
*stars_pgm = Program::New("Stars",Shader::LoadFile("glsl\pointcloud_vertex.glsl"),Shader::LoadFile("glsl\pointcloud_fragment.glsl"))
*stars = TMStars::New(*sun,150,300,*stars_pgm)


ship = *ship
ScreenQuad::Setup(*quad,*app\context)
TMTPlanet::Setup(*sun)
TMTPlanet::Setup(*mercury)
TMTPlanet::Setup(*venus)
TMTPlanet::Setup(*jupiter)
TMTPlanet::Setup(*io)
TMTPlanet::Setup(*europa)
TMTPlanet::Setup(*ganymede)
TMStars::Setup(*stars,*stars_pgm)
Model::Setup(*ship,*polymesh_pgm)

;Polymesh::Setup(*ship)
*ftgl_drawer = FTGL::New()
Application::Loop(*app,@UpdateWorld())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 218
; FirstLine = 12
; Folding = -
; EnableXP
; Constant = #USE_GLFW = 1
; Constant = #USE_BULLET=0
; Constant = #USE_ALEMBIC=1