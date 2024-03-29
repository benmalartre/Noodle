﻿XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/Verlet.pbi"
Global width = 1024
Global height = 720

UseModule Math

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *layer.LayerDefault::LayerDefault_t
Global *mesh.Polymesh::Polymesh_t
Global *verlet.Verlet::Verlet_t 
Global *drawer.Drawer::Drawer_t 

Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  Protected *ctxt.GLContext::GLContext_t = *viewport\context
  Protected *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
  
  For i=0 To 16
    Verlet::StepPhysics(*verlet, 1/60)
  Next
  
  GLContext::SetContext(*ctxt)
  
  Drawer::Flush(*drawer)
  Verlet::Draw(*verlet, *drawer)
  Verlet::Deform(*verlet)
  
  Scene::Update(*app\scene)

  Application::Draw(*app, *layer, *app\camera)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)
    ViewportUI::Blit(*viewport, *layer\framebuffer)
  FTGL::BeginDraw(*ctxt\writer)
  FTGL::SetColor(*ctxt\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*ctxt\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*ctxt\writer)

  
  GLContext::FlipBuffer(*ctxt)

 EndProcedure
 

Globals::Init()
;  Bullet::Init( )
 FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Define startT.d = Time::Get ()
   Log::Init()
   *app = Application::New("TestMesh",width,height)

   If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  Else
    GLContext::Setup(*viewport\context)
    Define *shader.Program::Program_t = *viewport\context\shaders("polymesh")
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  *app\scene = Scene::New()
  *layer = LayerDefault::New(800,600,*viewport\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
  

  *mesh = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
;   Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
;   Topology::Grid(*geom\topo, 10,16,16)
;   PolymeshGeometry::Set2(*mesh\geom, *geom\topo)
  
  If Not #USE_GLFW
    ViewportUI::SetHandleTarget(*viewport, *mesh)
    GLContext::AddFramebuffer(*layer\context, *layer\framebuffer)
  EndIf
  
  Define *T.Transform::Transform_t = Object3D::GetGlobalTransform(*mesh)
  Object3D::UpdateTransform(*mesh)
  Transform::SetTranslationFromXYZValues(*T, 0,6,0)
  Define q.Math::q4f32
  Quaternion::SetFromAxisAngleValues(q,0,0.2,0.9,0.5)
  Transform::SetRotationFromQuaternion(*T, q)
  Object3D::SetGlobalTransform(*mesh, *T)
  Object3D::FreezeTransform(*mesh)
  
  *drawer = Drawer::New()
  *geom.Geometry::PolymeshGeometry_t = *mesh\geom

  PolymeshGeometry::ComputeHalfEdges(*mesh\geom)
  *verlet = Verlet::New(*mesh\geom,1)
  
  Verlet::RigGeometry(*verlet)
  
;   Object3D::AddChild(*root,*mesh)
  Object3D::AddChild(*root,*drawer)
  
  Scene::AddModel(*app\scene,*root)
  Scene::Setup(*app\scene)
 
  Application::Loop(*app, @Draw(),0.1)


  Verlet::Delete(*verlet)
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 46
; FirstLine = 46
; Folding = -
; EnableXP