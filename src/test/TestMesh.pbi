


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


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

Global fbo.i
Global rbo.i 
Global texture.i

Global *torus.Polymesh::Polymesh_t
Global *teapot.Polymesh::Polymesh_t
Global *ground.Polymesh::Polymesh_t
Global *box.Polymesh::Polymesh_t
Global *null.Polymesh::Polymesh_t
Global *cube.Polymesh::Polymesh_t
Global *bunny.Polymesh::Polymesh_t

Global *layer.LayerDefault::LayerDefault_t
Global *shadows.LayerShadowMap::LayerShadowMap_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *defshadows.LayerShadowDefered::LayerShadowDefered_t
Global *ssao.LayerSSAO::LayerSSAO_t
Global *quad.ScreenQuad::ScreenQuad_t

Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.d


Procedure RandomLine()
  Protected seed.v3f32
  
EndProcedure


Procedure RandomGround()
  Protected *ground.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_NONE)
  Protected *geom.Geometry::PolymeshGeometry_t = *ground\geom

  PolymeshGeometry::GridTopology(*geom, 100,100,100)
  
    Protected *topo.Geometry::Topology_t = *geom\topo
  Define i
  Define *p.v3f32
  For i=0 To CArray::GetCount(*topo\vertices)-1
    *p = CArray::GetValue(*topo\vertices, i)
    *p\x * 10
    *p\z * 10
    *p\y = (Sin(*p\x/100) *40) ;+ (Random(100)*0.1 - 5)) 
  Next
  PolymeshGeometry::Set2(*geom, *topo)
  Object3D::Freeze(*ground)
  ProcedureReturn *ground
EndProcedure

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
  width = WindowWidth(window,#PB_Window_InnerCoordinate)
  height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLCheckError("App draw..")
  GLContext::SetContext(*app\context)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
;   
  
  Scene::Update(Scene::*current_scene)
  
  glViewport(0, 0, width, height)
  
  Protected *s.Program::Program_t = *app\context\shaders("polymesh")
  glUseProgram(*s\pgm)
  glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
 

  Application::Draw(*app, *layer, *app\camera)
  

;   FTGL::BeginDraw(*app\context\writer)
;   FTGL::SetColor(*app\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
;   FTGL::EndDraw(*app\context\writer)
  
    GLContext::FlipBuffer(*app\context)
    

 EndProcedure
 
 Define useJoystick.b = #False
 width = 800
 height = 800
 ; Main
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("TestMesh",width,height)
   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"Test Mesh", *app\camera, *app\handle)     
     Application::SetContext(*app, *viewport\context)
     ;*app\context\writer\background = #True
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  *quad = ScreenQuad::New()
  ScreenQuad::Setup(*quad,*app\context\shaders("bitmap"))

  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  
  GLCheckError("init scene")
  
  GLContext::SetContext(*app\context)
  GLCheckError("set context")
  
  *layer = LayerDefault::New(width,height,*app\context,*app\camera)
  GLCheckError("create layer")
  Application::AddLayer(*app, *layer)

  Global *root.Model::Model_t = Model::New("Model")

  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  

  *ground.Polymesh::Polymesh_t = RandomGround();Polymesh::New("Ground",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  
  Define pos.v3f32,scl.v3f32
  
  *box = Polymesh::New("Box",Shape::#SHAPE_CUBE)
  
  Define *samples.CArray::CArrayLocation = CArray::newCArrayLocation(*ground\geom, *ground\globalT)
  Sampler::SamplePolymesh(*ground\geom,*samples,256,7)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TEAPOT)
  Object3D::SetShader(*bunny,*s_polymesh)
  
  Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
  *merged\wireframe = #False
  Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
  
  Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
  Define *gtopo.Geometry::Topology_t = *ggeom\topo
  Define i
      
  Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
  
  Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *matrices.CArray::CarrayM4F32 = CArray::newCArrayM4F32()
  Define m.m4f32
  Define pos.v3f32
    
  Define *loc.Geometry::Location_t
  Define *pos.v3f32, *nrm.v3f32
  Define scl.v3f32
  Define size.f = 7
  Define pos.v3f32, center.v3f32
  Vector3::Set(center, 0,5,0)
;   CArray::SetCount(*matrices, CArray::GetCount(*samples))
  For i=0 To CArray::GetCount(*samples)-1
    *loc = CArray::GetValue(*samples,i)
    Location::GetPosition(*loc,*ggeom,*ground\globalT)
    Location::GetNormal(*loc,*ggeom,*ground\globalT)
    Matrix4::SetIdentity(m)
    size = Random(50)+5
    Vector3::ScaleInPlace(*loc\n, size/2)
    Vector3::AddInPlace(*loc\p, *loc\n)
    Vector3::Randomize(pos, center, 12)
    Matrix4::SetIdentity(m)
    Matrix4::SetTranslation(m, *loc\p)
    
    Vector3::Set(scl, size, size, size)
    Matrix4::SetScale(m, scl)
   
    CArray::Append(*matrices,m)
;     CArray::SetValue(*matrices, i, m)
 Next
  
 Define *topo.Geometry::Topology_t = Topology::New(*bgeom\topo)
 
 
 Topology::TransformArray(*topo,*matrices,*topos)
  Topology::MergeArray(*topo,*topos)
 
  Define sT.d = Time::Get()
  PolymeshGeometry::Set2(*mgeom,*topo)
  Topology::Delete(*topo)
  
;   PolymeshGeometry::ComputeHalfEdges(*mgeom)
;   PolymeshGeometry::ComputeIslands(*mgeom)
;   PolymeshGeometry::RandomColorByIsland(*mgeom)
  Object3D::Freeze(*merged)
  
  Object3D::AddChild(*root,*merged)
  
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root,*bunny)
  
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  ViewportUI::SetHandleTarget(*viewport, *merged)
  
  glGenFramebuffers(1, @fbo)
  glBindFramebuffer(#GL_FRAMEBUFFER, fbo)
  
  glGenTextures(1, @texture)
  glBindTexture(#GL_TEXTURE_2D, texture)
    
  glTexImage2D(#GL_TEXTURE_2D, 0, #GL_RGBA, 800, 800, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, #Null)
  
  glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST)
  glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST)
  glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
  glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
 
  glFramebufferTexture2D(#GL_FRAMEBUFFER, #GL_COLOR_ATTACHMENT0, #GL_TEXTURE_2D, texture, 0)
  
     
  glGenRenderbuffers(1, @rbo)
  glBindRenderbuffer(#GL_RENDERBUFFER, rbo)  
  glRenderbufferStorage(#GL_RENDERBUFFER, #GL_DEPTH_COMPONENT, 800, 800)
  
  glFramebufferRenderbuffer(#GL_FRAMEBUFFER, #GL_DEPTH_ATTACHMENT, #GL_RENDERBUFFER, rbo)
  
  If glCheckFramebufferStatus(#GL_FRAMEBUFFER) <> #GL_FRAMEBUFFER_COMPLETE
    Debug "ERROR::FRAMEBUFFER:: Framebuffer is not complete!" 
  EndIf
 
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 117
; FirstLine = 101
; Folding = -
; EnableXP