;#USE_GLFW = #False
XIncludeFile "../core/Application.pbi"
XIncludeFile "../ui/Window.pbi"
XIncludeFile "../ui/View.pbi"
EnableExplicit
UseModule Math
UseModule OpenGL
UseModule OpenGLExt



Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
; Controls::Init()
Commands::Init()
UIColor::Init()
; Alembic::Init()


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



ExamineDesktops()
Define width = DesktopWidth(0)
Define height = DesktopHeight(0)
Global *app.Application::Application_t = Application::New("Point Cloud Tree",width,height,#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_Maximize)

Global *main.View::View_t = *app\window\main
Global *view.View::View_t = View::Split(*main,0,50)
Global *top.View::View_t = View::Split(*view\left,#PB_Splitter_FirstFixed,25)

Global *middle.View::View_t = View::Split(*top\right,#PB_Splitter_Vertical,60)
Global *center.View::View_t = View::Split(*middle\left,#PB_Splitter_Vertical,30)
Global *bottom.View::View_t = View::Split(*view\right,#PB_Splitter_SecondFixed,120)

Global *menu.MenuUI::MenuUI_t = MenuUI::New(*top\left,"Menu")
Global *explorer.ExplorerUI::ExplorerUI_t = ExplorerUI::New(*center\left,"Explorer")
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*center\right,"Viewport", *app\camera, *app\handle)
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)

Global *property.PropertyUI::PropertyUI_t = PropertyUI::New(*middle\right,"Property",#Null)

Global *graph.UI::IUI = GraphUI::New(*bottom\left,"GraphUI")


*app\scene = Scene::New()
Define *grd.Polymesh::Polymesh_t = Polymesh::New("Ground", Shape::#SHAPE_GRID)
Define *obj.InstanceCloud::InstanceCloud_t = InstanceCloud::New("Cloud",Shape::#SHAPE_CUBE,0)
Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_BUNNY)
PolymeshGeometry::ToShape(*mesh\geom, *obj\shape)
Define ps.v3f32, pe.v3f32
  Vector3::Set(ps,-10,0,0)
  Vector3::Set(pe,10,0,0)
  PointCloudGeometry::PointsOnSphere(*obj\geom, 12)
  
  Global *tree.Tree::Tree_t = Tree::New(*obj,"Tree",Graph::#Graph_Context_Operator)
AddPointsTree(*tree.Tree::Tree_t)

Scene::AddChild(*app\scene,*obj)
Scene::AddChild(*app\scene,*grd)

; ; Global *log.UI::IUI = LogUI::New(*bottom\right,"LogUI")
Global *timeline.UI::IUI = TimelineUI::New(*bottom\right,"TimelineUI ")

GraphUI::SetContent(*graph,*tree)

ControlExplorer::Fill(*explorer\explorer,*app\scene)
Global *layer.Layer::Layer_t = LayerDefault::New(WIDTH,HEIGHT,*viewport\context,*app\camera)

Scene::Setup(*app\scene)

Procedure Update(*app.Application::Application_t)
  GLContext::SetContext(*viewport\context)
  
  LayerDefault::Draw(*layer, *app\scene, *viewport\context)
  
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  
;   Define width = *viewport\context\width
;   Define height = *viewport\context\height
  
;   FTGL::BeginDraw(*viewport\context\writer)
;   FTGL::SetColor(*viewport\context\writer,1,1,1,1)
;   Define ss.f = 0.85/width
;   Define ratio.f = width / height
;   FTGL::Draw(*viewport\context\writer,"Point CLoud",-0.9,0.9,ss,ss*ratio)
;   FTGL::Draw(*viewport\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
;   FTGL::Draw(*viewport\context\writer,"Nb Objects : "+Str(Scene::GetNbObjects(*scene)),-0.9,0.7,ss,ss*ratio)
;   FTGL::EndDraw(*viewport\context\writer)
  
  
  GLContext::FlipBuffer(*viewport\context)
  
  
EndProcedure


Define e.i
UIColor::SetTheme(Globals::#GUI_THEME_DARK)
Application::Loop(*app,@Update())
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 120
; FirstLine = 80
; Folding = -
; EnableXP
; Executable = glslsandbox.exe