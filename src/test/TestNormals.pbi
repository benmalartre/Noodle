XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule OpenGLExt


EnableExplicit

Global width.i
Global height.i

Global *mesh.Polymesh::Polymesh_t
Global *drawer.Drawer::Drawer_t
Global *scene.Scene::Scene_t
Global *pgm.Program::Program_t

Global *layer.Layer::Layer_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t

Procedure UpdateNormals()
  Define i
  Define m.m4f32
  Define *n.v3f32, *p.v3f32, *o.v3f32
  Define *item.Drawer::Item_t 
  Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  
  Define *offsetedNormals.CArray::CArrayV3F32 = CArray::New(Types::#TYPE_V3F32)
  Define *colors.CArray::CArrayC4F32 = CArray::New(Types::#TYPE_C4F32)
  CArray::SetCount(*offsetedNormals, *mesh\geom\nbpoints)
  CArray::SetCount(*colors, *mesh\geom\nbpoints)
  For i=0 To *geom\nbpoints - 1
    *n = CArray::GetValue(*geom\a_pointnormals, i)
    *p = CArray::GetValue(*geom\a_positions, i)
    *o = CArray::GetValue(*offsetedNormals, i)
    Vector3::Add(*o, *p, *n)
    CArray::SetValue(*colors, i, *n)
  Next
  
  Drawer::Flush(*drawer)
  *item = Drawer::AddColoredLines2(*drawer, *geom\a_positions, *offsetedNormals, *colors)
  
  Box::GetMatrixRepresentation(*geom\bbox, m)
  *item = Drawer::AddBox(*drawer, m)
  Drawer::SetColor(*item, Color::MAGENTA)
  
  CArray::Delete(*offsetedNormals)

EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  OpenGLExt::GLCheckError("Set GL Context")
  Protected *light.Light::Light_t = CArray::GetValuePtr(*app\scene\lights,0)
  
  Protected *t.Transform::Transform_t = *light\localT
  
  Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
  Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
  Object3D::SetLocalTransform(*light, *t)
  
  UpdateNormals()
  *app\scene\dirty= #True
  Scene::Update(*app\scene)
  
  
  glUseProgram(*pgm\pgm)
  glUniform3f(glGetUniformLocation(*pgm\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\framebuffer)

  FTGL::BeginDraw(*viewport\context\writer)
  FTGL::SetColor(*viewport\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*viewport\context\writer,"Nb Vertices : "+Str(*mesh\geom\nbpoints),-0.9,0.9,ss,ss*ratio)
  FTGL::EndDraw(*viewport\context\writer)
;   
  GLContext::FlipBuffer(*viewport\context)

 EndProcedure


 
width = 800
height = 600

Globals::Init()
FTGL::Init()

If Time::Init()
  Log::Init()
  Define options.i = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget
  *app = Application::New("Test Normals", width, height, options)

  If Not #USE_GLFW
     *viewport = ViewportUI::New(*app\window\main, "ViewportUI", *app\camera, *app\handle)     
     ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Camera::LookAt(*app\camera)
  
  *pgm = *viewport\context\shaders("polymesh")
  *app\scene = Scene::New()
  *layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
;   ViewportUI::AddLayer(*viewport, *layer)

  Global *root.Model::Model_t = Model::New("Model")
    
  
  *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_TORUS)
  Define *geom.Geometry::PolymeshGeometry_t = *mesh\geom
  
  *drawer = Drawer::New("MeshNormals")

  Object3D::AddChild(*root, *mesh)
  Object3D::AddChild(*root, *drawer)
  Scene::AddModel(*app\scene,*root)
  
  Scene::Setup(*app\scene)

  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; CursorPosition = 31
; FirstLine = 23
; Folding = -
; EnableXP
; Executable = D:\Volumes\STORE N GO\Polymesh.app
; Debugger = Standalone
; Constant = #USE_GLFW=0
; Constant = #USE_GLFW=0
; EnableUnicode