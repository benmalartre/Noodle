


XIncludeFile "../core/Application.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile"../objects/Polymesh.pbi"
XIncludeFile "../ui/ViewportUI.pbi"


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

Global *layer.LayerDefault::LayerDefault_t
Global *shadows.LayerShadowMap::LayerShadowMap_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *defered.LayerDefered::LayerDefered_t
Global *defshadows.LayerShadowDefered::LayerShadowDefered_t
Global *ssao.LayerSSAO::LayerSSAO_t
Global *csm.LayerCascadedShadowMap::LayerCascadedShadowMap_t

Global *drawer.Drawer::Drawer_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *renderCamera.Camera::Camera_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global time.f

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure


; Set Bounding Box
;--------------------------------------------
Procedure AddBoundingBox(*drawer.Drawer::Drawer_t, *infos.LayerCascadedShadowMap::OrthographicProjectionInfo_t)
  
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  Define *p.Math::v3f32
  CArray::SetCount(*positions, 24)
  *p = CArray::GetValue(*positions, 0)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 1)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 2)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 3)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 4)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 5)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 6)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\far)
  *p = CArray::GetValue(*positions, 7)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\far)
  
  *p = CArray::GetValue(*positions, 8)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 9)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 10)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 11)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 12)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 13)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\far)
  *p = CArray::GetValue(*positions, 14)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 15)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\far)
  
  *p = CArray::GetValue(*positions, 16)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 17)
  Vector3::Set(*p, *infos\left, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 18)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\near)
  *p = CArray::GetValue(*positions, 19)
  Vector3::Set(*p, *infos\right, *infos\bottom, *infos\far)
  *p = CArray::GetValue(*positions, 20)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 21)
  Vector3::Set(*p, *infos\left, *infos\top, *infos\far)
  *p = CArray::GetValue(*positions, 22)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\near)
  *p = CArray::GetValue(*positions, 23)
  Vector3::Set(*p, *infos\right, *infos\top, *infos\far)

  Define *bbox.Drawer::Item_t = Drawer::AddLines(*drawer, *positions)
  Drawer::SetColor(*bbox, Color::ORANGE)
  CArray::Delete(*positions)

EndProcedure

; Add Frustum
;--------------------------------------------
Procedure AddFrustum(*drawer.Drawer::Drawer_t, *camera.Camera::Camera_t)
  Define t.f = Tan(Radian(*camera\fov)* 0.5)
  Define nw.f = *camera\nearplane * t
	Define nh.f = nw / *camera\aspect
	Define fw.f = *camera\farplane * t
	Define fh.f = fw / *camera\aspect
	
	Define dir.Math::v3f32
	Vector3::Sub(dir, *camera\pos, *camera\lookat)
	Define q.Math::q4f32
  Quaternion::LookAt(q, dir, *camera\up, #False)
	Define forward.Math::v3f32
	Define right.Math::v3f32
	Define up.Math::v3f32

	Vector3::Set(forward,0,0,-1)
	Vector3::MulByQuaternionInPlace(forward, q)
	Vector3::Set(right,1,0,0)
	Vector3::MulByQuaternionInPlace(right, q)
	Vector3::Set(up,0,1,0)
	Vector3::MulByQuaternionInPlace(up, q)
	Define tmp.Math::v3f32

	
	Define nearCenter.Math::v3f32
	Define farCenter.Math::v3f32
	Vector3::ScaleAdd(nearCenter, *camera\pos, forward, *camera\nearplane)
	Vector3::ScaleAdd(farCenter, *camera\pos, forward, *camera\farplane)

  Define nearLeftTop.Math::v3f32
  Define nearRightTop.Math::v3f32
  Define nearLeftBottom.Math::v3f32
  Define nearRightBottom.Math::v3f32
  
  ; compute the 4 corners of the frustum on the near plane
  Vector3::Scale(tmp, up, nh)
  Vector3::Sub(nearLeftBottom, nearCenter, tmp)
  Vector3::Sub(nearRightBottom, nearCenter, tmp)
  Vector3::Add(nearLeftTop, nearCenter, tmp)
  Vector3::Add(nearRightTop, nearCenter, tmp)
  
  Vector3::Scale(tmp, right, nw)
  Vector3::SubInPlace(nearLeftBottom, tmp)
  Vector3::AddInPlace(nearRightBottom, tmp)
  Vector3::SubInPlace(nearLeftTop, tmp)
  Vector3::AddInPlace(nearRightTop, tmp)
	
	Define farLeftTop.Math::v3f32
  Define farRightTop.Math::v3f32
  Define farLeftBottom.Math::v3f32
  Define farRightBottom.Math::v3f32
  
  ; compute the 4 corners of the frustum on the far plane
  Vector3::Scale(tmp, up, fh)
  Vector3::Sub(farLeftBottom, farCenter, tmp)
  Vector3::Sub(farRightBottom, farCenter, tmp)
  Vector3::Add(farLeftTop, farCenter, tmp)
  Vector3::Add(farRightTop, farCenter, tmp)
  
  Vector3::Scale(tmp, right, fw)
  Vector3::SubInPlace(farLeftBottom, tmp)
  Vector3::AddInPlace(farRightBottom, tmp)
  Vector3::SubInPlace(farLeftTop, tmp)
  Vector3::AddInPlace(farRightTop, tmp)
  
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*positions, 24)
  CArray::SetValue(*positions, 0, nearLeftBottom)
  CArray::SetValue(*positions, 1, nearRightBottom)
  CArray::SetValue(*positions, 2, nearLeftTop)
  CArray::SetValue(*positions, 3, nearRightTop)
  CArray::SetValue(*positions, 4, farLeftBottom)
  CArray::SetValue(*positions, 5, farRightBottom)
  CArray::SetValue(*positions, 6, farLeftTop)
  CArray::SetValue(*positions, 7, farRightTop)
  
  CArray::SetValue(*positions, 8, nearLeftBottom)
  CArray::SetValue(*positions, 9, nearLeftTop)
  CArray::SetValue(*positions, 10, nearRightBottom)
  CArray::SetValue(*positions, 11, nearRightTop)
  CArray::SetValue(*positions, 12, farLeftBottom)
  CArray::SetValue(*positions, 13, farLeftTop)
  CArray::SetValue(*positions, 14, farRightBottom)
  CArray::SetValue(*positions, 15, farRightTop)
  
  CArray::SetValue(*positions, 16, nearLeftBottom)
  CArray::SetValue(*positions, 17, farLeftBottom)
  CArray::SetValue(*positions, 18, nearRightBottom)
  CArray::SetValue(*positions, 19, farRightBottom)
  CArray::SetValue(*positions, 20, nearLeftTop)
  CArray::SetValue(*positions, 21, farLeftTop)
  CArray::SetValue(*positions, 22, nearRightTop)
  CArray::SetValue(*positions, 23, farRightTop)

  Define *frustum.Drawer::Item_t = Drawer::AddLines(*drawer, *positions)
  Drawer::SetColor(*frustum, Color::GREEN)
  CArray::Delete(*positions)

EndProcedure

; Add Light
;--------------------------------------------
Procedure AddLight(*drawer.Drawer::Drawer_t, *light.Light::Light_t)
  Define t.f = Tan(Radian(*light\fov)* 0.5)
  Define nw.f = *light\nearplane * t
	Define nh.f = nw / *light\aspect
	Define fw.f = *light\farplane * t
	Define fh.f = fw / *light\aspect
	
	Define dir.Math::v3f32
	Vector3::Sub(dir, *light\pos, *light\lookat)
	Define q.Math::q4f32
  Quaternion::LookAt(q, dir, *light\up, #False)
	Define forward.Math::v3f32
	Define right.Math::v3f32
	Define up.Math::v3f32

	Vector3::Set(forward,0,0,-1)
	Vector3::MulByQuaternionInPlace(forward, q)
	Vector3::Set(right,1,0,0)
	Vector3::MulByQuaternionInPlace(right, q)
	Vector3::Set(up,0,1,0)
	Vector3::MulByQuaternionInPlace(up, q)
	Define tmp.Math::v3f32

	
	Define nearCenter.Math::v3f32
	Define farCenter.Math::v3f32
	Vector3::ScaleAdd(nearCenter, *light\pos, forward, *light\nearplane)
	Vector3::ScaleAdd(farCenter, *light\pos, forward, *light\farplane)

  Define nearLeftTop.Math::v3f32
  Define nearRightTop.Math::v3f32
  Define nearLeftBottom.Math::v3f32
  Define nearRightBottom.Math::v3f32
  
  ; compute the 4 corners of the frustum on the near plane
  Vector3::Scale(tmp, up, nh)
  Vector3::Sub(nearLeftBottom, nearCenter, tmp)
  Vector3::Sub(nearRightBottom, nearCenter, tmp)
  Vector3::Add(nearLeftTop, nearCenter, tmp)
  Vector3::Add(nearRightTop, nearCenter, tmp)
  
  Vector3::Scale(tmp, right, nw)
  Vector3::SubInPlace(nearLeftBottom, tmp)
  Vector3::AddInPlace(nearRightBottom, tmp)
  Vector3::SubInPlace(nearLeftTop, tmp)
  Vector3::AddInPlace(nearRightTop, tmp)
	
	Define farLeftTop.Math::v3f32
  Define farRightTop.Math::v3f32
  Define farLeftBottom.Math::v3f32
  Define farRightBottom.Math::v3f32
  
  ; compute the 4 corners of the frustum on the far plane
  Vector3::Scale(tmp, up, fh)
  Vector3::Sub(farLeftBottom, farCenter, tmp)
  Vector3::Sub(farRightBottom, farCenter, tmp)
  Vector3::Add(farLeftTop, farCenter, tmp)
  Vector3::Add(farRightTop, farCenter, tmp)
  
  Vector3::Scale(tmp, right, fw)
  Vector3::SubInPlace(farLeftBottom, tmp)
  Vector3::AddInPlace(farRightBottom, tmp)
  Vector3::SubInPlace(farLeftTop, tmp)
  Vector3::AddInPlace(farRightTop, tmp)
  
  Define *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*positions, 24)
  CArray::SetValue(*positions, 0, nearLeftBottom)
  CArray::SetValue(*positions, 1, nearRightBottom)
  CArray::SetValue(*positions, 2, nearLeftTop)
  CArray::SetValue(*positions, 3, nearRightTop)
  CArray::SetValue(*positions, 4, farLeftBottom)
  CArray::SetValue(*positions, 5, farRightBottom)
  CArray::SetValue(*positions, 6, farLeftTop)
  CArray::SetValue(*positions, 7, farRightTop)
  
  CArray::SetValue(*positions, 8, nearLeftBottom)
  CArray::SetValue(*positions, 9, nearLeftTop)
  CArray::SetValue(*positions, 10, nearRightBottom)
  CArray::SetValue(*positions, 11, nearRightTop)
  CArray::SetValue(*positions, 12, farLeftBottom)
  CArray::SetValue(*positions, 13, farLeftTop)
  CArray::SetValue(*positions, 14, farRightBottom)
  CArray::SetValue(*positions, 15, farRightTop)
  
  CArray::SetValue(*positions, 16, nearLeftBottom)
  CArray::SetValue(*positions, 17, farLeftBottom)
  CArray::SetValue(*positions, 18, nearRightBottom)
  CArray::SetValue(*positions, 19, farRightBottom)
  CArray::SetValue(*positions, 20, nearLeftTop)
  CArray::SetValue(*positions, 21, farLeftTop)
  CArray::SetValue(*positions, 22, nearRightTop)
  CArray::SetValue(*positions, 23, farRightTop)

  Define *frustum.Drawer::Item_t = Drawer::AddLines(*drawer, *positions)
  Drawer::SetColor(*frustum, Color::YELLOW)
  CArray::Delete(*positions)

EndProcedure





; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  If Event() = #PB_Event_Menu
    If EventMenu() = 32
      Vector3::Set(*light\pos, Sin(time) * 12,24,Cos(time) * 12)
      time + 0.01
      Light::Update(*light)
      Window::OnEvent(*app\window, Event())
    ElseIf EventMenu() = 33
      LayerCascadedShadowMap::SaveImageToDisk(*csm)

    EndIf
    
      
  EndIf

  Vector3::Echo(*light\pos,"LIGHT POSITION")
  GLContext::SetContext(*app\context)
 
  Drawer::Flush(*drawer)
  
  Define i
  For i=0 To 2
    AddBoundingBox(*drawer, *csm\cascadeProjections(i))
  Next
  AddFrustum(*drawer, *app\camera)
  AddLight(*drawer, *light)
  Scene::Update(Scene::*current_scene)
  LayerCascadedShadowMap::Draw(*csm, *app\context)
  LayerDefault::Draw(*layer, *app\context)
;   LayerShadowMap::Draw(*shadows, *app\context)
;   LayerGBuffer::Draw(*gbuffer,*app\context)
;   LayerDefered::Draw(*defered,*app\context)
;   LayerShadowDefered::Draw(*defshadows, *app\context)
  
  Handle::Resize(*app\handle,*app\camera)

  If *viewport\tool
    Protected *wireframe.Program::Program_t = *app\context\shaders("wireframe")
    glUseProgram(*wireframe\pgm)

    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,Matrix4::IDENTITY())
    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE, *app\camera\view)
    glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE, *app\camera\projection)
    
    Handle::Draw( *app\handle,*app\context) 
    Scene::Update(Scene::*current_scene)
  EndIf
 
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Nb Vertices : "+Str(*bunny\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  
  GLCheckError("BEFORE FLIP BUFFER")
  GLContext::FlipBuffer(*app\context)
  GLCheckError("AFTER FLIP BUFFER")
  
  
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
   *app = Application::New("TestCSM",width,height)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)
     Application::SetContext(*app, *viewport\context)
     
    *viewport\camera = *app\camera
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  *app\camera\farplane = 128
  *renderCamera = *app\camera
  Global *cam2.Camera::Camera_t = Camera::New("Camera2", Camera::#Camera_Perspective)
  
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
;   *shadows = LayerShadowMap::New(800,800,*app\context,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
;   *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
;   *defered = LayerDefered::New(800,600,*app\context,*gbuffer\datas\buffer,*shadows\datas\buffer,*app\camera)
;   *defshadows = LayerShadowDefered::New(800,600,*app\context,*gbuffer\datas\buffer, *shadows\datas\buffer,*app\camera)
  *csm = LayerCascadedShadowMap::New(1024,1024,*app\context,*app\camera,CArray::GetValuePtr(Scene::*current_scene\lights, 0))
  Global *root.Model::Model_t = Model::New("Model")
  
  *viewport\camera = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
  Layer::SetPOV(*layer, *viewport\cv)
  ; FTGL Drawer
  ;-----------------------------------------------------  
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

  *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  *drawer = Drawer::New()
  
  ;Define *loc.Geometry::Location_t = Location::New(*ground\geom,*ground\globalT,0,0.5,0.5)
;   Define *pos.v3f32 = Location::GetPosition(*loc)
;   Vector3::Echo(*pos,"Location Position")
  
  
;   Define *samples.CArray::CArrayLocation = CArray::newCArrayLocation(*ground\geom, *ground\globalT)
;   Sampler::SamplePolymesh(*ground\geom,*samples,1,7)
  
;   Define pos.v3f32,scl.v3f32
;   Vector3::Set(pos,0,-5,0)
;   Vector3::Set(scl,100,1,100)
;   Matrix4::SetScale(*ground\localT\m,scl)
;   Matrix4::SetTranslation(*ground\localT\m,pos)
;   Transform::UpdateSRTFromMatrix(*ground\localT)
  
  *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
  Object3D::SetShader(*bunny,*s_polymesh)
  
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root,*bunny)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(Scene::*current_scene,*root)
  
  Scene::Setup(Scene::*current_scene,*app\context)
  AddKeyboardShortcut(*app\window\ID, #PB_Shortcut_Space, 32)
  AddKeyboardShortcut(*app\window\ID, #PB_Shortcut_Return, 33)
  
  Handle::SetTarget(*app\handle, *renderCamera)
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 440
; FirstLine = 411
; Folding = --
; EnableThread
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; EnableUnicode