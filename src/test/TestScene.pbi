XIncludeFile "../core/Application.pbi"
EnableExplicit

Globals::Init()
Log::Init()
FTGL::Init()

Global *app.Application::Application_t = Application::New("Noodle",800,600)

  
Global *main.View::View_t = *app\manager\main
Global *view.View::View_t = View::Split(*main,0,50)

Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*view\left,"ViewportUI")
*app\context = GLContext::New(0,#False,*viewport\gadgetID)

*viewport\camera = *app\camera
View::SetContent(*app\manager\main,*viewport)
ViewportUI::Event(*viewport,#PB_Event_SizeWindow)
    
Global *shader.Program::Program_t = Program::NewFromName("polymesh")
Global counter.i
Global reset.b = #False

;Scene::*current_scene = Scene::New("Test")
Global *scene.Scene::Scene_t = Scene::New()
Global T = 0

Procedure AddChildren(*scn.Scene::Scene_t,*s.Program::Program_t)
  Debug ">>>>>>>>> Add Children "
  Protected nb = Random(10)+1
  Protected i
  Protected *child.Object3D::Object3D_t
  Protected *t.Transform::Transform_t
  Protected *m.Model::Model_t = Model::New("Test")
  
  Protected *model.Model::Model_t = Model::New("Test")
  Protected *parent.Object3D::Object3D_t = *model
  For i =0 To nb
    *child = Polymesh::New("Test",Shape::#SHAPE_BUNNY)
    *t = *child\localT
    Vector3::Set(*t\t\pos,0,1,0)
    *t\srtdirty = #True
    Object3D::SetLocalTransform(*child,*t)
    Matrix4::Echo(*scn\root\globalT\m,"Global Transform : ")
    Object3D::UpdateTransform(*child,*scn\root\globalT)
    Object3D::SetShader(*child,*s)
    Object3D::AddChild(*parent,*child)
    *parent = *child
  Next
  
  Scene::AddModel(*scn,*model)
  
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
    
     Debug "Child "+*o\name + "," +*o\class\name
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
  
  UpdateChildren(*scene)
  
   glCheckError("Bind FrameBuffer")
  glViewport(0, 0, *app\width,*app\height)
  glCheckError("Set Viewport")

  glDepthMask(#GL_TRUE);
  glClearColor(0.33,0.33,0.33,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glCheckError("Clear")
  glEnable(#GL_DEPTH_TEST)
  
  Protected model.Math::m4f32
  Matrix4::SetIdentity(@model)
  
;   glEnable(#GL_TEXTURE_2D)
;   glBindTexture(#GL_TEXTURE_2D,texture)
;   glUniform1i(glGetUniformLocation(*shader\pgm,"texture"),0)
;   
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"offset"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,@model)
  
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"projection"),1,#GL_FALSE,*app\camera\projesction)
  glUniform3f(glGetUniformLocation(*shader\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform3f(glGetUniformLocation(*shader\pgm,"lightPosition"),5,25,5)
  
  Scene::Update(*scene)
  ;Scene::Draw(Scene::*current_scene)
  Scene::Draw(*scene)
  
   If Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
  EndIf
  
EndProcedure

; AddChildren(Scene::*current_scene,*shader)
; Scene::Setup(Scene::*current_scene)
AddChildren(*scene,*shader)
Scene::Setup(*scene,*app\context)
Scene::Update(*scene)

Define i

For i=0 To CArray::GetCount(*scene\objects)-1
  Define *o.Object3D::Object3D_t = CArray::GetValuePtr(*scene\objects,i)
  Debug *o\name+","+*o\class\name
Next

Application::Loop(*app,@Callback())


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 11
; FirstLine = 7
; Folding = -
; EnableXP