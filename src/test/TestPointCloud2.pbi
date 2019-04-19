;#USE_GLFW = #False
XIncludeFile "../core/Application.pbi"

EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt


Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Controls::Init()
Commands::Init()
UIColor::Init()
Alembic::Init()


Procedure AddPointsTree(*tree.Tree::Tree_t)
  Protected *r.Node::Node_t = *tree\root
  Protected *bia.Node::Node_t = Tree::AddNode(*tree,"BuildIndexArrayNode",0,0,100,20,RGB(160,160,160))
  Protected *i2f.Node::Node_t = Tree::AddNode(*tree,"IntegerToFloatNode",0,120,100,20,RGB(160,160,160))
  Protected *f2v.Node::Node_t = Tree::AddNode(*tree,"FloatToVector3Node",200,30,100,20,RGB(160,160,160))
  Protected *a.Node::Node_t = Tree::AddNode(*tree,"AddPointNode",400,30,100,20,RGB(160,160,160))
  
;   Protected nb = 33
;   FirstElement(*bia\inputs())
;   NodePort::SetValue(*bia\inputs(),@nb)
  
;   LastElement(*g1\inputs())
;   NodePort::SetReference(*g1\inputs(),"Self.PointPosition")
;   LastElement(*g2\inputs())
;   NodePort::SetReference(*g2\inputs(),"Self.PointNormal")
;   LastElement(*s\inputs())
;   NodePort::SetReference(*s\Inputs(),"Self.PointPosition")
;   
; 
;   FirstElement(*M\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*g2\outputs(),*m\inputs(),#False)
;   FirstElement(*a \inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*g1\outputs(),*a\inputs(),#False)
;   SelectElement(*a\inputs(),1)
;   Tree::ConnectNodes(*tree,*tree\root,*m\outputs(),*a\inputs(),#False)
;   FirstElement(*s\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*a\outputs(),*s\inputs(),#False)
;   FirstElement(*r\inputs())
;   Tree::ConnectNodes(*tree,*tree\root,*s\outputs(),*r\inputs(),#False)
;   
;   *r\posx = 800
;   *r\posy = 200
EndProcedure

Scene::*current_scene = Scene::New()
Define *grd.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_GRID)
Define *obj.InstanceCloud::InstanceCloud_t = InstanceCloud::New("Cloud",Shape::#SHAPE_CUBE,0)
Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
PolymeshGeometry::ToShape(*mesh\geom, *obj\shape)
Define ps.v3f32, pe.v3f32
  Vector3::Set(ps,-10,0,0)
  Vector3::Set(pe,10,0,0)
  PointCloudGeometry::PointsOnSphere(*obj\geom, 12)
  ;PointCloudGeometry::PointsOnLine(*cloud\geom,@ps,@pe)
;   PointCloudGeometry::RandomizeColor(*obj\geom)
; InstanceCloud::Setup(*obj,*s_pointcloud)
  
; Define *teapot.Object3D::Object3D_t = Polymesh::New("Sphere",Shape::#SHAPE_TEAPOT)
; 
; PolymeshGeometry::SetFromOther(*obj\geom,*teapot\geom)
; Object3D::Freeze(*obj)

; Define *topo.Geometry::Topology_t = Topology::New()
; PolymeshGeometry::SphereTopology(*topo,1,10,10)
; PolymeshGeometry::Set2(*obj\geom,*topo)
; 
; PolymeshGeometry::GridTopology(*topo,1,10,10)
; PolymeshGeometry::Set2(*obj\geom,*topo)

Log::Message("Hello User : Beginning session "+FormatDate("%hh:%ii:%ss", Date()))

Global *tree.Tree::Tree_t = Tree::New(*obj,"Tree",Graph::#Graph_Context_Operator)

AddPointsTree(*tree.Tree::Tree_t)

Scene::AddChild(Scene::*current_scene,*obj)
Scene::AddChild(Scene::*current_scene,*grd)

ExamineDesktops()
Define width = DesktopWidth(0)
Define height = DesktopHeight(0)
Define *app.Application::Application_t = Application::New("Point Cloud Tree",width,height,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)

Define *m.ViewManager::ViewManager_t = *app\manager
Global *main.View::View_t = *m\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)

Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,120)

Global *topmenu.TopMenuUI::TopMenuUI_t = TopMenuUI::New(*top\left,"TopMenu")
Global *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*center\right,"Viewport3D", *app\camera, *app\context)
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
GLContext::SetContext(*app\context)

Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*middle\right,"Property",#Null)

 Global *graph.UI::IUI = GraphUI::New(*bottom\left,"GraphUI")

; ; Global *log.UI::IUI = LogUI::New(*bottom\right,"LogUI")
Global *timeline.UI::IUI = TimelineUI::New(*bottom\right,"TimelineUI ")

GraphUI::SetContent(*graph,*tree)

ControlExplorer::Fill(*explorer\explorer,Scene::*current_scene)
Global *layer.Layer::ILayer = LayerDefault::New(WIDTH,HEIGHT,*app\context,*app\camera)




Scene::Setup(Scene::*current_scene,*app\context)

Procedure Update(*app.Application::Application_t)
  GLContext::SetContext(*app\context)
  
  *layer\Draw( *app\context)
  
  Define width = *app\context\width
  Define height = *app\context\height
  
  FTGL::BeginDraw(*app\context\writer)
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/width
  Define ratio.f = width / height
  FTGL::Draw(*app\context\writer,"Point CLoud",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"Nb Objects : "+Str(Scene::GetNbObjects(Scene::*current_scene)),-0.9,0.7,ss,ss*ratio)
  FTGL::EndDraw(*app\context\writer)
  

  GLContext::FlipBuffer(*app\context)
  
  Define *l.Layer::Layer_t = *layer
  ViewportUI::Blit(*viewport, *l\buffer)
  
  
EndProcedure


Define e.i
UIColor::SetTheme(Globals::#GUI_THEME_DARK)
Application::Loop(*app,@Update())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 105
; FirstLine = 76
; Folding = -
; EnableXP
; Executable = glslsandbox.exe