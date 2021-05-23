
XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
UseModule OpenGLExt

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Define useJoystick.b = #False
 width = 600
 height = 600
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestOpenGLSpringSystem",800,600)
  
  
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"SpringSystem", *app\camera, *app\handle)     
     *app\context\writer\background = #True
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  
  *buffer = Framebuffer::New("Color",*app\width,*app\height)
  
  Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachTexture(*buffer,"normal",#GL_RGBA,#GL_LINEAR,#GL_REPEAT) 
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)

  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  *ftgl_drawer = FTGL::New()
  
  
  *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
  *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
  *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  *null.Polymesh::Polymesh_t = Polymesh::New("Null",Shape::#SHAPE_NULL)
  *cube.Polymesh::Polymesh_t = Polymesh::New("Cube",Shape::#SHAPE_CUBE)
  Define x,z
;   Define pos.v3f32
;   For x=-10 To 10
;     For z=-10 To 10
;       AddElement(*bunnies())
;       *bunnies() = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
;       Vector3::Set(pos,x,0,z)
;       Matrix4::SetTranslation(*bunnies()\matrix,@pos)
;     Next
;   Next
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Polymesh::Setup(*torus,*s_polymesh)
  Polymesh::Setup(*teapot,*s_polymesh)
  Polymesh::Setup(*ground,*s_polymesh)
  Polymesh::Setup(*null,*s_polymesh)
  Polymesh::Setup(*cube,*s_polymesh)
  Polymesh::Setup(*bunny,*s_polymesh)
;   ForEach *bunnies()
;     Polymesh::Setup(*bunnies(),*s_polymesh)
;   Next
  
;   Define a.v3f32, b.v3f32
;   Vector3::Set(a,-10,0,0)
;   Vector3::Set(b,10,0,0)
;   
;   
;   Define p_start.v3f32,p_end.v3f32
;   Vector3::Set(p_start,-1,0,0)
;   Vector3::Set(p_end,1,0,0)
; ;   PointCloudGeometry::PointsOnLine(*cloud\geom,p_start,p_end)
;   PointCloudGeometry::PointsOnSphere(*cloud\geom,5)
;   PointCloudGeometry::RandomizeColor(*cloud\geom)
;   PointCloud::Setup(*cloud,*s_pointcloud)
;   Object3D::Freeze(*cloud)
;   
;   Define i
;   Define *geom.Geometry::PointCloudGeometry_t = *cloud\geom
;   Define *p.v3f32
;   Define msg.s
  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 22
; FirstLine = 18
; EnableXP