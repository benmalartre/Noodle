


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


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

Global *layer.LayerDefault::LayerDefault_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *ssao.LayerSSAO::LayerSSAO_t

Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
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
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer,*app\context)
  
  
  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*ftgl_drawer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ftgl_drawer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)

  glDisable(#GL_BLEND)
  
  If Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
  EndIf

 EndProcedure
 

 
 Define useJoystick.b = #False
 width = 800
 height = 600
 ; Main
 Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = GLContext::New(0,#False,*viewport\gadgetID)
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
  EndIf
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(@model)
  
  Debug "Size "+Str(*app\width)+","+Str(*app\height)
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  
  Scene::*current_scene = Scene::New()
  Global *root.Model::Model_t = Model::New("Model")
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  
  *ftgl_drawer = FTGL::New()
  
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

;   *torus.Polymesh::Polymesh_t = Polymesh::New("Torus",Shape::#SHAPE_TORUS)
;   *teapot.Polymesh::Polymesh_t = Polymesh::New("Teapot",Shape::#SHAPE_TEAPOT)
  *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  
  
  ;Define *loc.Geometry::Location_t = Location::New(*ground\geom,*ground\globalT,0,0.5,0.5)
;   Define *pos.v3f32 = Location::GetPosition(*loc)
;   Vector3::Echo(*pos,"Location Position")
  
  Define *samples.CArray::CArrayPtr = CArray::newCArrayPtr()
  Sampler::SamplePolymesh(*ground\geom,*samples,64,7)
  
  Define pos.v3f32,scl.v3f32
  Vector3::Set(@pos,0,-1,0)
  Vector3::Set(@scl,100,1,100)
  Matrix4::SetScale(*ground\matrix,@scl)
  Matrix4::SetTranslation(*ground\matrix,@pos)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TORUS)
  Object3D::SetShader(*bunny,*s_polymesh)
;   Polymesh::Setup(*torus,*s_polymesh)
;   Polymesh::Setup(*teapot,*s_polymesh)
;   Polymesh::Setup(*ground,*s_polymesh)
;   Polymesh::Setup(*bunny,*s_polymesh)
; Polymesh::Draw(*ground)
;   Polymesh::Draw(*bunny)
  
  Define *merged.Polymesh::Polymesh_t = Polymesh::New("Merged",Shape::#SHAPE_NONE)
  Define *mgeom.Geometry::PolymeshGeometry_t = *merged\geom
  
  Define *topos.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *ggeom.Geometry::PolymeshGeometry_t = *ground\geom
  Define *gtopo.Geometry::Topology_t = *ggeom\topo
  Define msg.s = ""
  Define i
  For i=0 To CArray::GetCount(*gtopo\faces)-1

    msg + CArray::GetValueL(*gtopo\faces,i)+","
  Next
  MessageRequester("Topo ID "+Str(t),msg)
      
  Define *bgeom.Geometry::PolymeshGeometry_t = *bunny\geom
  CArray::AppendPtr(*topos,*ggeom\topo)
  CArray::AppendPtr(*topos,*bgeom\topo) 
  Topology::MergeArray(*mgeom\topo,*topos)
  
  Define *outtopo.CArray::CArrayPtr = CArray::newCArrayPtr()
  Define *matrices.CArray::CarrayM4F32 = CArray::newCArrayM4F32()
  Define m.m4f32
  Define pos.v3f32
  
  Vector3::Set(@pos,0,3,0)
  Matrix4::SetIdentity(@m)
  Matrix4::SetTranslation(@m,@pos)
  CArray::Append(*matrices,@m)
  
  Vector3::Set(@pos,2,7,4)
  Matrix4::SetIdentity(@m)
  
  Define *loc.Geometry::Location_t
  Define *pos.v3f32
  For i=0 To CArray::GetCount(*samples)-1
    *loc = CArray::GetValuePtr(*samples,i)
    *pos = Location::GetPosition(*loc)
   Vector3::Set(@pos,i*2,0,0)
  Matrix4::SetTranslation(@m,*pos)
  CArray::Append(*matrices,@m)
 Next
  

  Topology::TransformArray(*mgeom\topo,*matrices,*outtopo)
  Topology::MergeArray(*mgeom\topo,*outtopo)
  PolymeshGeometry::Set2(*mgeom,*mgeom\topo)
  Object3D::Freeze(*merged)
  Object3D::AddChild(*root,*merged)
  
;   Object3D::AddChild(*root,*ground)
;   Object3D::AddChild(*root,*bunny)
   Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 187
; FirstLine = 161
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; Executable = D:/Volumes/STORE N GO/Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0