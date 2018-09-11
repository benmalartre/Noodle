XIncludeFile "../core/Application.pbi"
EnableExplicit

Globals::Init()
Log::Init()
FTGL::Init()

Global *app.Application::Application_t = Application::New("Noodle",800,600)

  
Global *main.View::View_t = *app\manager\main
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*main,"ViewportUI")
*app\context = *viewport\context

; Global *view.View::View_t = View::Split(*main,0,50)
; 
; Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*view\left,"ViewportUI")
; *app\context = GLContext::New(0,#False,*viewport\gadgetID)
; Global *log.LogUI::LogUI_t = LogUI::New(*view\right, "LogUI")


*viewport\camera = *app\camera
View::SetContent(*app\manager\main,*viewport)
ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)

Global *layer.LayerDefault::LayerDefault_t = LayerDefault::New(*viewport\width,*viewport\height,*app\context,*app\camera)
Global counter.i
Global reset.b = #False

;Scene::*current_scene = Scene::New("Test")
Global *scene.Scene::Scene_t = Scene::New()
Global T = 0

Procedure AddChildren(*scn.Scene::Scene_t,*s.Program::Program_t)
  Debug ">>>>>>>>> Add Children "
  Protected nb = 32;Random(10)+1
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
    Matrix4::Echo(*scn\root\globalT\m,"Global Transform : ")
    Object3D::UpdateTransform(*child,*scn\root\globalT)
    Object3D::SetShader(*child,*s)
    Object3D::AddChild(*parent,*child)
    ;*parent = *child
  Next
  
  Scene::AddModel(*scn,*model)
  
  counter+1
  
EndProcedure

Procedure UpdateChildren(*scn.Scene::Scene_t)
  T+1
  Protected *t.Transform::Transform_t
  Protected *o.Object3D::Object3D_t
  ForEach *scn\root\children()
   
    *o = *scn\root\children()
    *t = *o\localT
    Transform::SetTranslationFromXYZValues(*t,0,Sin(T*0.1)*5,0)
    Object3D::SetLocalTransform(*o,*t)
    Object3D::UpdateTransform(*O,#Null)
  Next
  
EndProcedure


Procedure RemoveChildren(*scn.Scene::Scene_t)
  Scene::Delete(*scn)
  ;Scene::*current_scene = Scene::New()
  *scene = Scene::New()
  
EndProcedure

Procedure Callback()
;   
;   If reset
;     Debug "Available Memory "+Str(MemoryStatus(#PB_System_FreePhysical))+" Bytes"
;     RemoveChildren(*scene)
;     reset = #False
;   Else
;     AddChildren(*scene,*shader)
;   EndIf
;   counter +1 
;   If(counter>10)
;     counter = 0
;     reset  =#True
;     
;   EndIf
  
  ;UpdateChildren(*scene)
  ViewportUI::SetContext(*viewport)
  ;Model::Update(*model)
  Scene::Update(*scene)
  LayerDefault::Draw(*layer,*app\context)
  
  ViewportUI::FlipBuffer(*viewport)
  Log::Message(">>>> "+Str(T))
;   LogUI::Event(*log, #PB_Event_Repaint)
  
EndProcedure

AddChildren(*scene,*app\context\shaders("polymesh"))
UpdateChildren(*scene)

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  Global filePath.s = "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/xml/Test.scn"
CompilerElse
  Global filepath.s = "E:\Projects\RnD\Noodle\xml\Test.scn"
CompilerEndIf

Global *saver.Saver::Saver_t = Saver::New(*scene, filePath)
Saver::Save(*saver)

Scene::Delete(*scene)
Global *loader.Loader::Loader_t = Loader::New(filePath)
*scene = Loader::Load(*loader)

Scene::Setup(*scene,*app\context)
; Scene::Update(*scene)

Application::Loop(*app,@Callback())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 35
; FirstLine = 18
; Folding = -
; EnableXP