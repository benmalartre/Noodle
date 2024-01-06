XIncludeFile "../core/Application.pbi"

Globals::Init()
Time::Init()
Log::Init()
FTGL::Init()
Commands::Init()
UIColor::Init()

Procedure AddChildren(*scn.Scene::Scene_t)
  Protected nb = 1
  Protected i
  Protected *child.Object3D::Object3D_t
  Protected *t.Transform::Transform_t
  
  Protected *model.Model::Model_t = Model::New("Model")
  Protected *parent.Object3D::Object3D_t = *model
  For i =0 To nb
    *child = Polymesh::New("Test",Shape::#SHAPE_BUNNY)
    *t = *child\localT
    Vector3::Set(*t\t\pos,Random(10)-5,i/3,Random(10)-5)
    *t\srtdirty = #True
    Object3D::SetLocalTransform(*child,*t)

    Object3D::UpdateTransform(*child,*scn\root\globalT)
    Object3D::AddChild(*parent,*child)
  Next
  
  Scene::AddModel(*scn,*model)
  
  counter+1
  
EndProcedure

Global *app.Application::Application_t
Global *explorer.ExplorerUI::ExplorerUI_t
Global *scene.Scene::Scene_t

*app = Application::New("Test Explorer",400,800)
*explorer = ExplorerUI::New(*app\window\main, "Explorer")
*scene = Scene::New()
ExplorerUI::Connect(*explorer, *scene)
AddChildren(*scene)

; Scene::SelectObject(*scene, CArray::GetPtr(*scene\objects, 0))


Application::Loop(*app)
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 47
; FirstLine = 1
; Folding = -
; EnableXP