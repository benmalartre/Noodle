XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Application.pbi"

XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/GLFW.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../libs/Alembic.pbi"

XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"

XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/KDTree.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"
XIncludeFile "../objects/Polymesh.pbi"



UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt

EnableExplicit

Global *pgm.Program::Program_t

Global *layer.LayerDefault::LayerDefault_t
Global *gbuffer.LayerGBuffer::LayerGBuffer_t
Global *ssao.LayerSSAO::LayerSSAO_t

Global *cloud.PointCloud::PointCloud_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *model.Model::Model_t
Global texture.i

Global numVertices

Procedure Draw(*app.Application::Application_t)
  Time::currentframe + 1
  If Time::currentframe>100 : Time::currentframe = 1:EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *viewport\applecontext, "makeCurrentContext" )
  CompilerEndIf
  
    
  
  ;Model::Update(*model)
  LayerDefault::Draw(*layer,*app\context)
;   LayerGBUffer::Draw(*gbuffer,*app\context)
;   LayerSSAO::Draw(*ssao,*app\context)
;   glUseProgram(*pgm\pgm)
;   Define.m4f32 model,view,proj
;   Matrix4::SetIdentity(@model)
;   
;   Framebuffer::BindOutput(*buffer)
; 
;   glCheckError("Bind FrameBuffer")
;   glViewport(0, 0, *app\width,*app\height)
;   glCheckError("Set Viewport")
; 
;   glDepthMask(#GL_TRUE);
;   glClearColor(0.33,0.33,0.33,1.0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glCheckError("Clear")
;   glEnable(#GL_DEPTH_TEST)
;   
;   glEnable(#GL_TEXTURE_2D)
;   glBindTexture(#GL_TEXTURE_2D,texture)
;   glUniform1i(glGetUniformLocation(*pgm\pgm,"texture"),0)
;   
;   glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"offset"),1,#GL_FALSE,@model)
;   glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE,@model)
;   
;   glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,*app\camera\view)
;   glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,*app\camera\projection)
;   glUniform3f(glGetUniformLocation(*pgm\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;   glUniform3f(glGetUniformLocation(*pgm\pgm,"lightPosition"),5,25,5)
;   
;   ;   PointCloud::Draw(*cloud)
;   Model::Update(*model)
;   Model::Draw(*model,*pgm)
;   glCheckError("Draw Mesh")
;   glDepthMask(#GL_FALSE);
;   
;   ;Framebuffer::BlitTo(*buffer,#Null,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *app\width,*app\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
;   glDisable(#GL_DEPTH_TEST)
  
  FTGL::SetColor(*app\context\writer,1,1,1,1)
  Define ss.f = 0.85/*app\width
  Define ratio.f = *app\width / *app\height
  FTGL::Draw(*app\context\writer,"Test Alembic",-0.9,0.9,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"FPS : "+Str(Application::GetFPS(*app)),-0.9,0.8,ss,ss*ratio)
  FTGL::Draw(*app\context\writer,"NUM VERTICES : "+Str(numVertices),-0.9,0.7,ss,ss*ratio)
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *viewport\applecontext, "flushBuffer" )
  CompilerElse
    If Not #USE_GLFW
      SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
    EndIf
  CompilerEndIf
  
EndProcedure
    
Define model.m4f32

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  Alembic::Init()
  FTGL::Init()
  Define f.f

  *app = Application::New("Test",800,600)
  
  Scene::*current_scene = Scene::New()
  If Not #USE_GLFW
    
    *viewport = ViewportUI::New(*app\manager\main,"ViewportUI")
    GLCheckError("After Creating Viewport")
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      CocoaMessage( 0, *viewport\applecontext, "makeCurrentContext" )
    CompilerEndIf
    GLCheckError("Before Creating GLContext")
    *app\context = GLContext::New(0,#False,*viewport\gadgetID)
    GLCheckError("After Creating GLContext")
  EndIf
  
  Debug "Camera :: "+Str(*app\camera)
  
  Matrix4::SetIdentity(@model)
    
  

  *pgm = *app\context\shaders("polymesh")
  GLCheckError("Before Creating Polymeshes")
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Define path.s = OpenFileRequester("Alembic Archive","/Users/benmalartre/Documents/RnD/Modules/abc/Chaley.abc","Alembic (*.abc)|*.abc",0)
    Define i
    *model = Model::New("FUCK")
    For i=0 To 0:
      Define *r5.Model::Model_t = Alembic::LoadABCArchive(path)
      ;Define *r5.Polymesh::Polymesh_t = Polymesh::new("Sphere", Shape::#SHAPE_CUBE)
;       Define *geom.Geometry::PolymeshGeometry_t = *r5\geom
;       numVertices + *geom\nbpoints
      Define *T.Transform::Transform_t = Object3D::GetGlobalTransform(*r5)
      Transform::SetTranslationFromXYZValues(*T, i*3,0,0)
      Object3D::SetLocalTransform(*r5, *T)
      Object3D::UpdateTransform(*r5,*model\globalT)
      Object3D::AddChild(*model,*r5)
    Next
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    Define path.s = OpenFileRequester("Alembic Archive","D:\Projects\RnD\PureBasic\Noodle\abc\Elephant.abc","Alembic (*.abc)|*.abc",0)
    *model = Alembic::LoadABCArchive(path)
  CompilerElse
    Define path.s = OpenFileRequester("Alembic Archive","/home/benmalartre/RnD/PureBasic/Noodle/abc/Elephant.abc","Alembic (*.abc)|*.abc",0)
    *model = Alembic::LoadABCArchive(path)
  CompilerEndIf
  
  MessageRequester("USE LEGACY OPENGL : ",Str(#USE_LEGACY_OPENGL))
  Define maxNumVertices.GLint
  ;glGetIntegerv(#GL_MAX_ELEMENTS_VERTICES, @maxNumVertices)
  ;MessageRequester("MAXIMUM NUM VERTICES : ",Str(maxNumVertices))
;   Define img = LoadImage(#PB_Any,"D:\Projects\PureBasic\Modules\textures\earth.jpg")
;   texture = Utils::GL_LoadImage(img)
  ;Define *t = Alembic::ABC_TestString("Test")
  
  
;   Define i
;   Define pos.v3f32
;   For i=0 To 12
;     Define *mesh.Polymesh::Polymesh_t = Polymesh::New("Star",Shape::#SHAPE_BUNNY)
;     Vector3::Set(@pos,Random(10),Random(10),Random(10))
;     Object3D::AddChild(*model,*mesh)
;     Matrix4::SetTranslation(*mesh\model,@pos)
;   Next
  
  ;Define *compo.Framebuffer::Framebuffer_t = Framebuffer::New("Compo",GadgetWidth(gadget),GadgetHeight(gadget))
  GLCheckError("Before Creating FrameBuffer")
  *layer = LayerDefault::New(800,600,*app\context,*app\camera)
  Debug "DEFAULT LAYER CREATED"
  *gbuffer = LayerGBuffer::New(800,600,*app\context,*app\camera)
  Debug "GBUFFER LAYER CREATED"
  *ssao = LayerSSAO::New(400,300,*app\context,*gbuffer\buffer,*app\camera)
  Debug "SSAO LAYER CREATED"

;   *cloud = PointCloud::New("PointCloud",100)
;   PointCloud::Setup(*cloud,*pgm)
  Scene::AddModel(Scene::*current_scene,*model)
  Debug "MODEL ADDED TO SCENE"
  Scene::Setup(Scene::*current_scene,*app\context)
  Debug "SCENE SETUP DONE"
 Application::Loop(*app,@Draw())
EndIf
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 158
; FirstLine = 152
; Folding = -
; EnableThread
; EnableXP
; Executable = bin/Alembic.app
; Compiler = PureBasic 5.31 (Windows - x64)
; Debugger = Standalone
; Warnings = Display
; Constant = #USE_GLFW=0