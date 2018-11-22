; -----------------------------------------------------------------------------------
; Test Covariance
; -----------------------------------------------------------------------------------

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


Global *layer.LayerDefault::LayerDefault_t
Global *drawer.Drawer::Drawer_t

Global width.i, height.i
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()

; -----------------------------------------------------------------------------------------
; Random Point Cloud
; -----------------------------------------------------------------------------------------
Procedure RandomPointCloud(numPoints.i, *m.m4f32)
  Protected *position.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  CArray::SetCount(*position, numPoints)
 
  Protected i
  Protected m.v3f32
  Protected *pos.v3f32, dir.v3f32
  For i=0 To numPoints-1
    *pos = CArray::GetValue(*position, i)
    Vector3::Set(*pos, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02)
;     Vector3::Set(dir, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02, 1.0 - Random(100)*0.02)
;     Vector3::NormalizeInPlace(@dir)
;     Vector3::Scale(*pos, @dir, Random(100)*0.01)
    Vector3::MulByMatrix4InPlace(*pos, *m)
  Next
  Protected *c.PointCloud::PointCloud_t = PointCloud::New("Datas", Shape::#SHAPE_NONE)
  Protected *g.Geometry::PointCloudGeometry_t = *c\geom
  PointCloudGeometry::AddPoints(*g, *position)
  
  CArray::Delete(*position)
  ProcedureReturn *c 
EndProcedure

; -----------------------------------------------------------------------------------------
; Draw
; -----------------------------------------------------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  ViewportUI::SetContext(*viewport)
  Scene::*current_scene\dirty= #True
  
  Scene::Update(Scene::*current_scene)
  LayerDefault::Draw(*layer, *app\context)

  glEnable(#GL_BLEND)
  glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  glDisable(#GL_DEPTH_TEST)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Testing GL Drawer",-0.9,0.9,ss,ss*ratio)

  glDisable(#GL_BLEND)
  
  ViewportUI::FlipBuffer(*viewport)

EndProcedure

Procedure GetDetMax(det1.f, det2.f, det3.f):
  Protected det_max.f = det1
  Protected output.i = 0
  If det2 > det_max
    det_max = det2 
    output = 1
  EndIf
  If det3 > det_max
    det_max = det3
    output = 2
  EndIf
  ProcedureReturn output
EndProcedure

Procedure GetDetMax2(det1.f, det2.f, det3.f):
  If det1 < det2
    If det2 < det3
      ProcedureReturn 1
    ElseIf det3 < det1
      ProcedureReturn 0  
    Else
      ProcedureReturn 2
    EndIf
  Else
    If det2 < det3
      If det1 < det3
        ProcedureReturn 0
      Else
        ProcedureReturn 2
      EndIf
    EndIf
  EndIf
  ProcedureReturn 1
EndProcedure

Procedure BestFittingPlane(*drawer.Drawer::Drawer_t, *cloud.PointCloud::PointCloud_t)
  Protected *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  Drawer::Flush(*drawer)
  Protected nrm.v3f32, upv.v3f32
  If *geom\nbpoints < 3
    MessageRequester("TestCovariance", "Best Fitting Plane : At least three points required!")
  Else
    Protected sum.v3f32
    Protected *p.v3f32
    Vector3::Set(sum, 0,0,0)
    Protected i.i
    For i=0 To *geom\nbpoints - 1
      *p = CArray::GetValue(*geom\a_positions,i)
      Vector3::AddInPlace(sum, *p)
    Next
    
    Protected inp.f = 1.0/*geom\nbpoints
    Protected centroid.v3f32
    Vector3::Scale(centroid, sum, inp)
    
    Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    CArray::SetCount(*positions, 1)
    CArray::SetValue(*positions, 0, centroid)
    Protected *point.Drawer::Point_t = Drawer::AddPoint(*drawer, *positions)
    *point\size = 4
    Drawer::SetColor(*point, Color::_RED())

    ; calc full 3x3 covariance matrix, excluding symmetries:
    Define xx.f = 0.0
    Define xy.f = 0.0
    Define xz.f = 0.0
    Define yy.f = 0.0
    Define yz.f = 0.0
    Define zz.f = 0.0
    
    Define r.v3f32
    Define *p.v3f32
    For i=0 To *geom\nbpoints - 1
      *p = CArray::GetValue(*geom\a_positions, i)
      Vector3::Sub(r, centroid, *p)
      xx + r\x * r\x
      xy + r\x * r\y
      xz + r\x * r\z
      yy + r\y * r\y
      yz + r\y * r\z
      zz + r\z * r\z
    Next
      
    Protected det_x.f = yy * zz - yz * yz
    Protected det_y.f = xx * zz - xz * xz
    Protected det_z.f = xx * yy - xy * xy

    Protected det_max.f = det_x
    Protected det_max_one = GetDetMax(det_x, det_y, det_z)
    Protected det_max_two = GetDetMax2(det_x, det_y, det_z)
        
    Select det_max_one
      Case 0
        Vector3::Set(nrm, det_x, xz * yz - xy * zz, xy * yz - xz * yy)
      Case 1
        Vector3::Set(nrm, xz * yz - xy * zz, det_y, xy * xz - yz * xx)
      Case 2
        Vector3::Set(nrm, xy * yz - xz * yy, xy * xz - yz * xx, det_z)
    EndSelect
    
    Select det_max_two
      Case 0
        Vector3::Set(upv, det_x, xz * yz - xy * zz, xy * yz - xz * yy)
      Case 1
        Vector3::Set(upv, xz * yz - xy * zz, det_y, xy * xz - yz * xx)
      Case 2
        Vector3::Set(upv, xy * yz - xz * yy, xy * xz - yz * xx, det_z)
    EndSelect
    
      
    Vector3::NormalizeInPlace(nrm)
    Vector3::NormalizeInPlace(upv)
      
    Protected m.m4f32
    Protected scl.v3f32
    Protected rot.q4f32
    Protected t.Transform::Transform_t
    Quaternion::LookAt(rot, nrm, upv,#True)
    Matrix4::SetFromQuaternion(m, rot)
;     Matrix4::DirectionMatrix(@m, @nrm, @upv)
    Matrix4::SetTranslation(m, centroid)
;     Vector3::Set(scl, 12,12,12)
;     Transform::SetScale(@t, @scl)
;     Quaternion::LookAt(@rot, @nrm, @upv)
;     Transform::SetRotationFromQuaternion(@t,@rot)
;     Transform::SetTranslation(@t,@centroid)
;     Transform::UpdateMatrixFromSRT(@t)

    Protected *matrix.Drawer::Matrix_t = Drawer::AddMatrix(*drawer, m)
    *matrix\size = 1

  EndIf
  
EndProcedure

; Main
Globals::Init()
FTGL::Init()
;--------------------------------------------
 If Time::Init()
   Log::Init()
   Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
   width = 800
   height = 600
   *app = Application::New("Test Covariance",width, height, options)

   If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
     *app\context = *viewport\context
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  Scene::*current_scene = Scene::New()
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)

  Global *root.Model::Model_t = Model::New("Model")
    
  *s_wireframe = *app\context\shaders("simple")
  *s_polymesh = *app\context\shaders("polymesh")
  
  shader = *s_polymesh\pgm

  Define *ground.Polymesh::Polymesh_t = Polymesh::New("Grid",Shape::#SHAPE_GRID)
  Object3D::SetShader(*ground,*s_polymesh)
  
  Define ctr.v3f32, nrm.v3f32
  Vector3::Set(ctr, 0,4,0)
  Vector3::Set(nrm, 0,1,1)
  
  Define t.Transform::Transform_t
  Define q.q4f32
  Define upv.v3f32
  Vector3::Set(upv, 0,0,1)
  Quaternion::LookAt(q, nrm, upv,#False)
  Transform::SetTranslation(t, ctr)
  Transform::SetRotationFromQuaternion(t, q)
  Transform::SetScaleFromXYZValues(t, 2,0.8,1.8)
  
  Transform::UpdateMatrixFromSRT(t)
  
  Define *cloud.PointCloud::PointCloud_t = RandomPointCloud(256, t\m)
  
  Define i
  
  *drawer = Drawer::New("Drawer")
 
  Object3D::AddChild(*root,*ground)
  Object3D::AddChild(*root, *drawer)
  Object3D::AddChild(*root, *cloud)
  Scene::AddModel(Scene::*current_scene,*root)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  Define nrm.v3f32
  BestFittingPlane(*drawer, *cloud)
   
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 43
; FirstLine = 15
; Folding = --
; EnableXP