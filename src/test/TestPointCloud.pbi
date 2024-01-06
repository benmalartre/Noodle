
XIncludeFile "../core/Application.pbi"


UseModule Time
UseModule Math
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Global down.b
Global lmb_p.b
Global mmb_p.b
Global rmb_p.b
Global oldX.f
Global oldY.f
Global width.i
Global height.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t
Global *cloud.PointCloud::PointCloud_t
Global NewList *bunnies.Polymesh::Polymesh_t()

Global *buffer.Framebuffer::Framebuffer_t
Global *scene.Scene::Scene_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *s_pointcloud.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *layer.Layer::Layer_t


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
;   Protected *light.Light::Light_t = CArray::GetValuePtr(*scene\lights,0)
  
;   Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
;   
  
  Scene::Update( *app\scene)
  
  
  Protected *s.Program::Program_t = *viewport\context\shaders("polymesh")
  glUseProgram(*s\pgm)
;   glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
   
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
;   GLContext::SetContext(*app\context)
;   Framebuffer::BindOutput(*buffer)
;   glClearColor(0.25,0.25,0.25,1.0)
;   glViewport(0, 0, *buffer\width,*buffer\height)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glEnable(#GL_DEPTH_TEST)
;   
;   Protected shader.i = *s_pointcloud\pgm
;   
;   glUseProgram(shader)
;   Matrix4::SetIdentity(offset)
;   
;   glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,model)
;   glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
;   glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*app\camera\projection)
;   glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;   T+0.01
; 
;   PointCloud::Draw(*cloud)
;   
;   glDisable(#GL_DEPTH_TEST)
;   glViewport(0,0,width,height)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
  
;   FTGL::BeginDraw(*ftgl_drawer)
;   FTGL::SetColor(*ftgl_drawer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*ftgl_drawer,"Point Cloud Nb Vertices : "+Str(*cloud\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
;   FTGL::EndDraw(*ftgl_drawer)
  
;   Framebuffer::Unbind(*buffer)
 GLContext::FlipBuffer(*viewport\context)

 EndProcedure

 Define useJoystick.b = #False
 width = 800
 height = 600
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Test",width,height)
  
  
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
;     Application::SetContext(*app, *viewport\context)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  *app\scene = Scene::New()
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  
  *layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
  Application::AddLayer(*app, *layer)
 
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  *ftgl_drawer = FTGL::New()
  
  *s_wireframe = Program::NewFromName("simple")
  *s_polymesh = Program::NewFromName("polymesh")
  *s_pointcloud = Program::NewFromName("cloud")
  shader = *s_pointcloud\pgm
  
  *cloud.PointCloud::PointCloud_t = PointCloud::New("cloud",1000)
  
  Scene::AddChild( *app\scene,*cloud)
  Scene::Setup( *app\scene)
  
;   *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
;   *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
;   *null.Polymesh::Polymesh_t = Polymesh::New("Null",Shape::#SHAPE_NULL)
;   *cube.Polymesh::Polymesh_t = Polymesh::New("Cube",Shape::#SHAPE_CUBE)
;   Define x,z
;   Define pos.v3f32
;   For x=-10 To 10
;     For z=-10 To 10
;       AddElement(*bunnies())
;       *bunnies() = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
;       Vector3::Set(pos,x,0,z)
;       Matrix4::SetTranslation(*bunnies()\matrix,@pos)
;     Next
;   Next
  
;   *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
;   Polymesh::Setup(*torus,*s_polymesh)
;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*null,*s_polymesh)
;   Polymesh::Setup(*cube,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
;   ForEach *bunnies()
;     Polymesh::Setup(*bunnies(),*s_polymesh)
;   Next
  
  Define a.v3f32, b.v3f32
  Vector3::Set(a,-10,0,0)
  Vector3::Set(b,10,0,0)
  
  
  Define p_start.v3f32,p_end.v3f32
  Vector3::Set(p_start,-1,0,0)
  Vector3::Set(p_end,1,0,0)
;   PointCloudGeometry::PointsOnLine(*cloud\geom,p_start,p_end)
  PointCloudGeometry::PointsOnSphere(*cloud\geom,5)
  PointCloudGeometry::RandomizeColor(*cloud\geom)
  PointCloud::Setup(*cloud)
  Object3D::Freeze(*cloud)
  
  Define i
  Define *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  Define *p.v3f32
  Define msg.s
  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 64
; FirstLine = 49
; Folding = -
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=1