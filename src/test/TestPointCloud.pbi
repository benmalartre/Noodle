

XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
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

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *viewport\context\ID, "makeCurrentContext" )
  CompilerEndIf
  Framebuffer::BindOutput(*buffer)
  glClearColor(0.25,0.25,0.25,1.0)
  glViewport(0, 0, *buffer\width,*buffer\height)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glEnable(#GL_DEPTH_TEST)
  
  Protected shader.i = *s_pointcloud\pgm
  
  glUseProgram(shader)
  Matrix4::SetIdentity(@offset)
  Framebuffer::BindOutput(*buffer)
  
  Matrix4::Echo(@model,"Model")
  Matrix4::Echo(*app\camera\view,"View")
  Matrix4::Echo(*app\camera\projection,"PROJECTION")
  
  glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*app\camera\projection)
  glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  T+0.01

;   Polymesh::Draw(*torus)
;   Polymesh::Draw(*teapot)
;   Polymesh::Draw(*ground)
;   Polymesh::Draw(*null)
;   Polymesh::Draw(*cube)
;   ForEach *bunnies()
;     Polymesh::Draw(*bunnies())
;   Next
  PointCloud::Draw(*cloud)
  
  glDisable(#GL_DEPTH_TEST)
  glViewport(0,0,width,height)
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
  glDisable(#GL_DEPTH_TEST)
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*ftgl_drawer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ftgl_drawer,"Point Cloud Nb Vertices : "+Str(*cloud\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  
  glDisable(#GL_BLEND)
  
 CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *viewport\context\ID, "flushBuffer" )
  CompilerElse
    If Not #USE_GLFW
      SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
    EndIf
  CompilerEndIf

 EndProcedure

 Define useJoystick.b = #False
 width = 600
 height = 600
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Test",800,600)
  
  
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *buffer = Framebuffer::New("Color",*app\width,*app\height)
  
  Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachTexture(*buffer,"normal",#GL_RGBA,#GL_LINEAR,#GL_REPEAT) 
  Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)

  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  *ftgl_drawer = FTGL::New()
  
  *s_wireframe = Program::NewFromName("simple")
  *s_polymesh = Program::NewFromName("polymesh")
  *s_pointcloud = Program::NewFromName("cloud")
  shader = *s_pointcloud\pgm
  
  *cloud.PointCloud::PointCloud_t = PointCloud::New("cloud",1000)
  
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
;       Vector3::Set(@pos,x,0,z)
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
  Vector3::Set(@a,-10,0,0)
  Vector3::Set(@b,10,0,0)
  
  
  Define p_start.v3f32,p_end.v3f32
  Vector3::Set(@p_start,-1,0,0)
  Vector3::Set(@p_end,1,0,0)
  ;PointCloudGeometry::PointsOnLine(*cloud\geom,@p_start,@p_end)
  PointCloudGeometry::PointsOnSphere(*cloud\geom,5)
  PointCloudGeometry::RandomizeColor(*cloud\geom)
  PointCloud::Setup(*cloud,*s_pointcloud)
;   PointCloudGeometry::PointsOnSphere(*cloud\geom)
  
  Define i
  Define *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  Define *p.v3f32
  Define msg.s
  For i=0 To *cloud\geom\nbpoints-1
    *p = CArray::GetValue(*geom\a_positions,i)
    msg + StrF(*p\x)+","+StrF(*p\y)+","+StrF(*p\z)+","+Chr(10)
  Next
  MessageRequester("POINTCLOUD POSITIONS",msg)
  
  ; Main Loop
  ;----------------------------------------------
  Define e
  CompilerIf #USE_GLFW
    glfwMakeContextCurrent(*app\window)
    While Not glfwWindowShouldClose(*app\window)
      ;glfwWaitEvents()
      glfwPollEvents()
      
      Draw(*app)
    
      glfwSwapBuffers(*app\window)
     
    Wend
  CompilerElse
    Repeat
      e = WaitWindowEvent(1000/60)
      ViewManager::OnEvent(*app\manager,e)
      Draw(*app)

    Until e = #PB_Event_CloseWindow
  CompilerEndIf
EndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 195
; FirstLine = 157
; Folding = -
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=1