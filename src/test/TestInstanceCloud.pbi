

XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
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
  Topology::Grid(*geom\topo,1000,10,10)
  PolymeshGeometry::Set2(*geom,*geom\topo)
  Object3D::Freeze(*ground)
  Protected *p.v3f32
  Protected i
  
  For i=0 To *geom\nbpoints-1
    *p = CArray::GetValue(*geom\a_positions,i)
    Vector3::Set(*p,*p\x,Random(100)-50,*p\z)
  Next
  
  *ground\dirty = Object3D::#DIRTY_STATE_DEFORM
  
  Scene::AddChild(Scene::*current_scene,*ground)
  
  ProcedureReturn *ground
EndProcedure

Procedure InstanceGrid(*cloud.InstanceCloud::InstanceCloud_t, nx.i, nz.i)
  Protected *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  *geom\nbpoints = nx * nz
  Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*positions, *geom\nbpoints)
  Protected x,z
  Protected *p.v3f32
  Protected incrx.f, incrz.f
  For x=0 To nx-1
    For z=0 To nz-1
      *p = CArray::GetValue(*positions, x*nz + z)
      Vector3::Set(*p,x*incrx,0,z*incrz)
    Next
  Next
  
  PointCloudGeometry::AddPoints(*geom, *positions)
  CArray::Delete(*positions)
EndProcedure


; Draw  
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  ViewportUI::SetContext(*viewport)
  ;Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*default,*app\context)
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer, 1,1,1,1)

  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Ground Nb Vertices : "+Str(*ground\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
; 
  FTGL::EndDraw(*app\context\writer)
  
  ViewportUI::FlipBuffer(*viewport)

 EndProcedure
 

 
 Define useJoystick.b = #False
 width = 720
 height = 576
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   FTGL::Init()
   CompilerIf #USE_ALEMBIC
     Alembic::Init()
   CompilerEndIf
   
   Scene::*current_scene = Scene::New()
   ExamineDesktops()
   *app = Application::New("Test Instances",width,height)
   If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI", *app\camera)
    *app\context = *viewport\context
     
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf  
  
  Define glVersion.s = PeekS(glGetString(#GL_VERSION),-1,#PB_Ascii)
  MessageRequester("OpenGL Version",glVersion)
  
  ; FTGL Drawer
  ;-----------------------------------------------------

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  
  
  *default = LayerDefault::New(width,height,*app\context,*app\camera)
  *gbuffer = LayerGBuffer::New(width,height,*app\context,*app\camera)
  *ssao = LayerSSAO::New(width,height,*app\context,*gbuffer\buffer,*app\camera)
  *blur = LayerBlur::New(width,height,*app\context,*ssao\buffer,*app\camera)
  
  ViewportUI::AddLayer(*viewport, *default)
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
  *cloud.InstanceCloud::InstanceCloud_t = InstanceCloud::New("cloud",Shape::#SHAPE_None,0)
;   CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
;     Define path.s = OpenFileRequester("Alembic Archive","/Users/benmalartre/Documents/RnD/Modules/abc/Chaley.abc","Alembic (*.abc)|*.abc",0)
;     *abc = Alembic::LoadABCArchive(path)
;   CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
;     Define path.s = OpenFileRequester("Alembic Archive","D:\Projects\RnD\PureBasic\Noodle\abc\Monkeys.abc","Alembic (*.abc)|*.abc",0)
;     *abc = Alembic::LoadABCArchive(path)
;   CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
;     Define path.s = OpenFileRequester("Alembic Archive","/home/benmalartre/RnD/PureBasic/Noodle/abc/Monkeys.abc","Alembic (*.abc)|*.abc",0)
;     *abc = Alembic::LoadABCArchive(path)
;   CompilerElse
;     *abc = Model::New("Empty")
;   CompilerEndIf
;   
;   Scene::AddModel(Scene::*current_scene,*abc)
  

  
;   ForEach *abc\children()
;     If *abc\children()\type = Object3D::#Polymesh
;       *mesh = *abc\children()
;       PolymeshGeometry::ToShape(*mesh\geom,*cloud\shape)
;       Break
;     EndIf
;   Next
;   
  *mesh.Polymesh::Polymesh_t = Polymesh::New("mesh",Shape::#SHAPE_TEAPOT)
  PolymeshGeometry::ToShape(*mesh\geom,*cloud\shape)
  PointCloudGeometry::PointsOnGrid(*cloud\geom,64,64)
;   Define startP.v3f32, endP.v3f32
;   Vector3::Set(startP, -10,0,0)
;   Vector3::Set(endP, 10,0,0)
;   PointCloudGeometry::PointsOnLine(*cloud\geom, @startP, @endP)
;   Define *T.Transform::Transform_t = *mesh\localT
;   Define pos.v3f32
; 
;   Vector3::Set(pos,0,2,0)
;   Matrix4::SetTranslation(*mesh\matrix,@pos)
;   Vector3::Set(pos,4,4,4)
;   Matrix4::SetScale(*mesh\matrix,@pos)
;   ;Polymesh::Setup(*bunnies(),*s_gbuffer)
;  
;         ;Shape::RandomizeColors(*bunnies()\shape,@color,0.0)
;         
;         
;   Scene::AddChild(Scene::*current_scene,*mesh)
  
  
  Define ps.v3f32, pe.v3f32
  Vector3::Set(ps,-10,0,0)
  Vector3::Set(pe,10,0,0)
  *ground = CreateGround()
;   PointCloudGeometry::PointsOnSphere(*cloud\geom, 10)
  
  Define *locs.CArray::CArrayLocation = CArray::newCArrayLocation(*ground\geom, *ground\globalT)
  Define *cgeom.Geometry::PointCloudGeometry_t = *cloud\geom
  Sampler::SamplePolymesh(*ground\geom,*locs,*cgeom\nbpoints,7)
  
  Define p.v3f32
  Define i
  Define s.v3f32
  Vector3::Set(s,13,13,13)
  Define *l.Geometry::Location_t
  For i=0 To *cgeom\nbpoints-1
    *l = CArray::GetValue(*locs,i)
    Location::GetPosition(*l, *ground\geom, *ground\globalT)
    CArray::SetValue(*cgeom\a_positions,i,*l\p)
    Location::GetNormal(*l, *ground\geom, *ground\globalT)
    CArray::SetValue(*cgeom\a_normals,i,*l\n)
    Vector3::Set(s,5,5,5)
    CArray::SetValue(*cgeom\a_scale,i,s)
    CArray::SetValueF(*cgeom\a_size,i,Random(1.5)+0.5)
  Next
    
  PointCloudGeometry::RandomizeColor(*cloud\geom)
  InstanceCloud::Setup(*cloud,*app\context\shaders("instances"))
  
;   
; ;   *texture = Texture::NewFromSource("D:\Projects\RnD\PureBasic\Noodle\textures\moonmap.jpg")
; ; 
; ;   glActiveTexture(#GL_TEXTURE0)
; ;   glBindTexture(#GL_TEXTURE_2D,*texture\tex)
;   
  Scene::AddChild(Scene::*current_scene,*cloud)
  Scene::AddChild(Scene::*current_scene,*mesh)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  Application::Loop(*app,@Draw())
  

EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 200
; FirstLine = 181
; Folding = --
; EnableXP
; Executable = Test
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode