XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/HeatDiffusion.pbi"

UseModule Time
UseModule Math
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt


Procedure DrawGradient()
;   Define *start.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
;   Define *end.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
;   CArray::SetCount(*start, *solver\mesh\nbpolygons)
;   CArray::SetCount(*end, *solver\mesh\nbpolygons)
;   
;   Define *vertices.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
;   Define c.v3f32
;   Define i, j
;   For i = 0 To *solver\mesh\nbpolygons - 1
;     PolymeshGeometry::GetPolygonVertices(*solver\mesh, i, *vertices)
;     Vector3::Set(c, 0, 0, 0)
;     For j = 0 To CArray::GetCount(*vertices) - 1
;       Vector3::AddInPlace(c, CArray::GetValue(*solver\mesh\a_positions, CArray::GetValueL(*vertices, j)))
;     Next
;     Vector3::ScaleInPlace(c, 1 / CArray::GetCount(*vertices))
;     CArray::SetValue(*start, i, c)
;     Vector3::ScaleAddInPlace(c, *solver\faces(i)\gradu, 0.1)
;     CArray::SetValue(*end, i, c)
;     
;   Next
;   
;   Drawer::AddLines2(*solver\drawer, *start, *end)  
EndProcedure

Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *layer.Layer::Layer_t
Global *solver.HeatDiffusion::Solver_t
Global *colors.CArray::CArrayC4F32
Global *bunny.Polymesh::Polymesh_t
Global *index.ControlNumber::ControlNumber_t
Global *steps.ControlNumber::ControlNumber_t
Global *diffusion.COntrolNumber::ControlNumber_t

Procedure OnParameterChange()
  Define N = *steps\value_n
  Define d.f = *diffusion\value_n
  HeatDiffusion::Reset(*solver, *index\value_n)
  HeatDiffusion::HeatFlow(*solver, N, d)
  HeatDiffusion::GradU(*solver)
  HeatDiffusion::Divergence(*solver)
  HeatDiffusion::Distance(*solver, N)
  HeatDiffusion::GetColors(*solver, *colors)

  PolymeshGeometry::SetColors(*bunny\geom, *colors)
  Polymesh::SetDirtyState(*bunny, Object3D::#DIRTY_STATE_TOPOLOGY)
EndProcedure
Callback::DECLARECALLBACK(OnParameterChange)


; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
  
  
  
  Scene::Update(*app\scene)
  
  
  Protected *s.Program::Program_t = *viewport\context\shaders("polymesh")
  glUseProgram(*s\pgm)
;   glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
   
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\framebuffer)


 EndProcedure
 
 Define width = 800
 Define height = 600
Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()


 *app = Application::New("Test",width,height)
 
 View::Split(*app\window\main, #PB_Splitter_Vertical, 75)

If Not #USE_GLFW
  *viewport = ViewportUI::New(*app\window\main\left,"ViewportUI", *app\camera, *app\handle)     
  ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
EndIf

*app\scene = Scene::New()
Camera::LookAt(*app\camera)
Matrix4::SetIdentity(model)
GLContext::SetContext(*viewport\context)

*layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
Application::AddLayer(*app, *layer)
GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)

; FTGL Drawer
;-----------------------------------------------------
FTGL::Init()
*ftgl_drawer = FTGL::New()

*colors = CArray::New(CArray::#ARRAY_C4F32)

*bunny = Polymesh::New("bunny", Shape::#SHAPE_BUNNY)
PolymeshGeometry::ComputeHalfEdges(*bunny\geom)
PolymeshGeometry::ComputeVertexPolygons(*bunny\geom)

Global *ui.PropertyUI::PropertyUI_t = PropertyUI::New(*app\window\main\right, "Property", #Null)
Global *prop.ControlProperty::ControlProperty_t = ControlProperty::New(*ui, "HeatDiffusion ", "Controls")


ControlProperty::AppendStart(*prop)
*index = ControlProperty::AddIntegerControl(*prop, "Index", "Index", 0, #Null)
Signal::CONNECTCALLBACK(*index\on_change, OnParameterChange)
*steps = ControlProperty::AddIntegerControl(*prop, "GSSteps", "Steps", 6, #Null)
Signal::CONNECTCALLBACK(*steps\on_change, OnParameterChange)
*diffusion = ControlProperty::AddFloatControl(*prop, "Diffusion", "Diffusion", 0.05, #Null)
Signal::CONNECTCALLBACK(*diffusion\on_change, OnParameterChange)

ControlProperty::AppendStop(*prop)
PropertyUI::AddProperty(*ui, *prop)


Scene::AddChild(*app\scene,*bunny)


*solver = AllocateStructure(HeatDiffusion::Solver_t)
;   *solver\drawer = Drawer::New("heat diffusuion drawer")
HeatDiffusion::Init(*solver, *bunny)
HeatDiffusion::Laplacian(*solver)



;   Scene::AddChild(*app\scene, *solver\drawer)
Scene::Setup(*app\scene)

Application::Loop(*app, @Draw())

; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 128
; FirstLine = 106
; Folding = -
; EnableXP