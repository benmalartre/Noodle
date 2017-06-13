

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
Global *cloud.InstanceCloud::InstanceCloud_t
Global *mesh.Polymesh::Polymesh_t
Global *abc.Model::Model_t
Global NewList *bunnies.Polymesh::Polymesh_t()

Global *default.LayerDefault::LayerDefault_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *ssao.LayerSSAO::LayerSSAO_t
Global *blur.LayerBlur::LayerBlur_t

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *texture.Texture::Texture_t

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

Procedure CreateGround()
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground",Shape::#SHAPE_NONE)
  Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom
  PolymeshGeometry::GridTopology(*geom\topo,1000,10,10)
  PolymeshGeometry::Set2(*geom,*geom\topo)
  
  Protected *p.v3f32
  Protected i
  
  For i=0 To *geom\nbpoints-1
    *p = CArray::GetValue(*geom\a_positions,i)
    Vector3::Set(*p,*p\x,Random(10)-5,*p\z)
  Next
  
  *ground\dirty = Object3D::#DIRTY_STATE_DEFORM
  
  Scene::AddChild(Scene::*current_scene,*ground)
  
  ProcedureReturn *ground
EndProcedure



; Draw  
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  ;Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*default,*app\context)
  
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*ftgl_drawer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ftgl_drawer,"Ground Nb Vertices : "+Str(*ground\geom\nbpoints),-0.9,0.9,ss,ss*ratio)

  glDisable(#GL_BLEND)
  
  If Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
  EndIf

 EndProcedure
 

 
 Define useJoystick.b = #False
 width = 720
 height = 576
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   FTGL::Init()
   Alembic::Init()
   Scene::*current_scene = Scene::New()
   ExamineDesktops()
   *app = Application::New("Test Instances",width,height)
   If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    *viewport\camera = *app\camera
    *app\context = GLContext::New(0,#False,*viewport\gadgetID)
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::Event(*viewport ,#PB_Event_SizeWindow)
  EndIf
  
  Define glVersion.s = PeekS(glGetString(#GL_VERSION),-1,#PB_Ascii)
  MessageRequester("OpenGL Version",glVersion)
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  *ftgl_drawer = FTGL::New()

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  
  
  *default = LayerDefault::New(width,height,*app\context,*app\camera)
  *gbuffer = LayerGBuffer::New(width,height,*app\context,*app\camera)
  *ssao = LayerSSAO::New(width,height,*app\context,*gbuffer\buffer,*app\camera)
  *blur = LayerBlur::New(width,height,*app\context,*ssao\buffer,*app\camera)
;   
;   Debug "Size "+Str(*app\width)+","+Str(*app\height)
;   *buffer = Framebuffer::New("Color",*app\width,*app\height)
;   Framebuffer::AttachTexture(*buffer,"position",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
;   Framebuffer::AttachTexture(*buffer,"normal",#GL_RGBA,#GL_LINEAR,#GL_REPEAT)
;   Framebuffer::AttachRender(*buffer,"depth",#GL_DEPTH_COMPONENT)
; 
; 
;   
;   *s_wireframe = Program::NewFromName("simple")
;   *s_polymesh = Program::NewFromName("polymesh")
;   *s_pointcloud = Program::NewFromName("instances")
;   shader = *s_pointcloud\pgm
;   
  *cloud.InstanceCloud::InstanceCloud_t = InstanceCloud::New("cloud",Shape::#SHAPE_NONE,100)
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Define path.s = OpenFileRequester("Alembic Archive","/Users/benmalartre/Documents/RnD/Modules/abc/Chaley.abc","Alembic (*.abc)|*.abc",0)
    *abc = Alembic::LoadABCArchive(path)
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    Define path.s = OpenFileRequester("Alembic Archive","D:\Projects\RnD\PureBasic\Noodle\abc\Monkeys.abc","Alembic (*.abc)|*.abc",0)
    *abc = Alembic::LoadABCArchive(path)
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    Define path.s = OpenFileRequester("Alembic Archive","/home/benmalartre/RnD/PureBasic/Noodle/abc/Monkeys.abc","Alembic (*.abc)|*.abc",0)
    *abc = Alembic::LoadABCArchive(path)
  CompilerElse
    *abc = Model::New("Empty")
  CompilerEndIf
  
  Scene::AddModel(Scene::*current_scene,*abc)
  

  
  ForEach *abc\children()
    If *abc\children()\type = Object3D::#Object3D_Polymesh
      *mesh = *abc\children()
      PolymeshGeometry::ToShape(*mesh\geom,*cloud\shape)
      Break
    EndIf
  Next
  
  *mesh.Polymesh::Polymesh_t = Polymesh::New("mesh",Shape::#SHAPE_BUNNY)
   ;PolymeshGeometry::ToShape(*mesh\geom,*cloud\shape)
  Define *T.Transform::Transform_t = *mesh\localT
  Define pos.v3f32

  Vector3::Set(@pos,0,2,0)
  Matrix4::SetTranslation(*mesh\matrix,@pos)
  Vector3::Set(@pos,4,4,4)
  Matrix4::SetScale(*mesh\matrix,@pos)
  ;Polymesh::Setup(*bunnies(),*s_gbuffer)
 
        ;Shape::RandomizeColors(*bunnies()\shape,@color,0.0)
        
        
  Scene::AddChild(Scene::*current_scene,*mesh)
  
  
  Define ps.v3f32, pe.v3f32
  Vector3::Set(@ps,-10,0,0)
  Vector3::Set(@pe,10,0,0)
  *ground = CreateGround()
  PointCloudGeometry::PointsOnSphere(*cloud\geom)
  Define *locs.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *cgeom.Geometry::PointCloudGeometry_t = *cloud\geom
  Sampler::SamplePolymesh(*ground\geom,*locs,*cgeom\nbpoints,666)
  
  Define i
  Define s.v3f32
  Vector3::Set(@s,3,3,3)
  Define *l.Geometry::Location_t
  For i=0 To *cgeom\nbpoints-1
    *l = CArray::GetValuePtr(*locs,i)
    CArray::SetValue(*cgeom\a_positions,i,*l\p)
    CArray::SetValue(*cgeom\a_normals,i,*l\n)
    CArray::SetValue(*cgeom\a_scale,i,@s)
    CArray::SetValueF(*cgeom\a_size,i,Random(1.5)+0.5)
  Next
  
  
  PointCloudGeometry::RandomizeColor(*cloud\geom)
  InstanceCloud::Setup(*cloud,*app\context\shaders("gbufferic"))
  
  Define *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  
  *texture = Texture::NewFromSource("D:\Projects\RnD\PureBasic\Noodle\textures\moonmap.jpg")

  glActiveTexture(#GL_TEXTURE0)
  glBindTexture(#GL_TEXTURE_2D,*texture\tex)
  

  Scene::AddChild(Scene::*current_scene,*cloud)
  Scene::Setup(Scene::*current_scene,*app\context)
  
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
        ViewManager::Event(*app\manager,e)
        Draw(*app)
  
      Until e = #PB_Event_CloseWindow
    CompilerEndIf
EndIf
; IDE Options = PureBasic 5.41 LTS (Linux - x64)
; CursorPosition = 106
; FirstLine = 85
; Folding = -
; EnableUnicode
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0