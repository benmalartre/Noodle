XIncludeFile "../core/Application.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt

EnableExplicit

Global framecount.l
Global lasttime.l

Global WIDTH = 1280
Global HEIGHT = 720

Global *camera.Camera::Camera_t 
Global NewList *lights.Light::Light_t()

Global NewList *bunnies.Polymesh::Polymesh_t()
Global *bunny.Polymesh::Polymesh_t

; GLSL Shaders
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *s_gbuffer.Program::Program_t
Global *s_deferred.Program::Program_t
Global *s_ssao.Program::Program_t
Global *s_ssao_blur.Program::Program_t
Global shader.l

; Uniforms GBuffer
Global u_gbuffer_model
Global u_gbuffer_view
Global u_gbuffer_projection
Global u_gbuffer_nearplane
Global u_gbuffer_farplane
Global u_gbuffer_color

; Uniforms SSAO
Global u_ssao_position_map
Global u_ssao_normal_map
Global u_ssao_noise_map
Global u_ssao_occ_radius
Global u_ssao_occ_power
Global u_ssao_view
Global u_ssao_projection
Global u_ssao_kernel_samples
Global u_ssao_kernel_size
Global u_ssao_noise_scale

; Objects
Global *ground.Polymesh::Polymesh_t
Global *quad.ScreenQuad::ScreenQuad_t

; Framebuffers
Global *gbuffer.Framebuffer::Framebuffer_t
Global *ssao.Framebuffer::Framebuffer_t
Global *blur.Framebuffer::Framebuffer_t
Global *deferred.Framebuffer::Framebuffer_t

Global *kernel.Carray::CArrayV3F32
Global *noise.CArray::CArrayV3F32
Global noise_tex.i
Global occ_radius.f = 1.0
Global occ_blur.b

Global nbsamples = 32
Global noise_size.i = 16

Global nb_lights.i = 7

Global offset.m4f32
Global i
Global *p.v3f32
Global scl.f


Global a.v3f32
Global b.v3f32
Global c.v3f32
Global m.m4f32
Global q.q4f32
Global s.v3f32

Global vwidth.i
Global vheight.i
Global mx.i
Global my.i
  FTGL::Init()
  Globals::Init()
  Time::Init()
  
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global *prop.PropertyUI::PropertyUI_t


Procedure GetFPS()
 framecount +1
  Protected current.l = Time::Get()*1000
  Protected elapsed.l = current - lasttime
  If elapsed > 1000
    fps = framecount;/(elapsed /1000)
    lasttime = current
    framecount = 0
  EndIf  
EndProcedure

Procedure Draw(*app.Application::Application_t)
  GetFPS()
  CompilerIf #USE_GLFW

    occ_radius = 1.0;
    occ_blur = #True

    
    glfwGetWindowSize(*app\window,@vwidth,@vheight)
    glfwGetCursorPos(*app\window,@mx,@my)
  CompilerElse
    mx = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseX)
    my = GetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_MouseY)
    vwidth = GadgetWidth(*viewport\gadgetID)
    vheight = GadgetHeight(*viewport\gadgetID)
  CompilerEndIf
    
; ;       glViewport(0,0,vwidth,vheight)
; ;       glEnable(#GL_BLEND)
; ;       glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
; ;       glDisable(#GL_DEPTH_TEST)
; ;       FTGL::SetColor(*ftgl_drawer,1,1,1,1)
; ;       Define ss.f = 0.85/vwidth
; ;       Define ratio.f = vwidth / vheight
; ;       FTGL::Draw(*ftgl_drawer,"SSAO wip",-0.9,0.9,ss,ss*ratio)
; ;       FTGL::Draw(*ftgl_drawer,"User  : "+UserName(),-0.9,0.85,ss,ss*ratio)
; ;       FTGL::Draw(*ftgl_drawer,"FPS  : "+Str(fps),-0.9,0.8,ss,ss*ratio)
; ;       glDisable(#GL_BLEND)
; ;       glEnable(#GL_DEPTH_TEST)

;       

;       
;       Camera::Event(*camera,gadget)
;       
;       e = WaitWindowEvent(1)
;       
;       If e=#PB_Event_SizeWindow
; 
;         Camera::Resize(*camera,window,gadget)
; ;         Framebuffer::Resize(*gbuffer,GadgetWidth(gadget),GadgetHeight(gadget))
; ;         Framebuffer::Resize(*ssao,GadgetWidth(gadget),GadgetHeight(gadget))
;       ElseIf e = #PB_Event_Gadget
;         Select EventGadget()
;           Case slider_radius
;             Define v.i = GetGadgetState(slider_radius)
;             occ_radius = v*0.1
;           Case check_blur
;             occ_blur = GetGadgetState(check_blur)
; 
;         EndSelect
;       EndIf
;      
;       Draw()
;       
;       glDisable(#GL_DEPTH_TEST)
;       FTGL::SetColor(*ftgl_drawer,1,1,1,1)
;       Define ss.f = 0.85/vwidth
;       Define ratio.f = vwidth / vheight
;       FTGL::Draw(*ftgl_drawer,"SSAO wip",-0.9,0.9,ss,ss*ratio)
;       FTGL::Draw(*ftgl_drawer,"User  : "+UserName(),-0.9,0.85,ss,ss*ratio)
;       FTGL::Draw(*ftgl_drawer,"FPS  : "+Str(fps),-0.9,0.8,ss,ss*ratio)
;       glDisable(#GL_BLEND)
;       glEnable(#GL_DEPTH_TEST)
; 
;         SetGadgetAttribute(gadget,#PB_OpenGL_FlipBuffers,#True)
; ;       glfwSwapBuffers(*window)
; 
;     Until e = #PB_Event_CloseWindow
;   CompilerEndIf
  

      
  Matrix4::SetIdentity(@offset)
  
  shader = *s_gbuffer\pgm
  glUseProgram(shader)
  ; 1. Geometry Pass: render scene's geometry/color data into gbuffer
  Framebuffer::BindOutput(*gbuffer)
  glViewport(0,0,*gbuffer\width,*gbuffer\height)
  glClearColor(0.5,0.5,0.5,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*app\camera\projection)
  glUniform1f(glGetUniformLocation(shader,"nearplane"),*app\camera\nearplane)
  glUniform1f(glGetUniformLocation(shader,"farplane"),*app\camera\farplane)
  glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;       glUniform3f(glGetUniformLocation(shader,"color"),0,1,0)
      glUniform1f(glGetUniformLocation(shader,"T"),0)
  
  glEnable(#GL_DEPTH_TEST)
  Define p.v3f32

  ForEach *bunnies()
  ;         Vector3::Set(@p,*bunnies()\model\v[12],Sin(Time::Get()+i)+2,*bunnies()\model\v[14])
  ;         Matrix4::SetTranslation(*bunnies()\model,@p)
    glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*bunnies()\matrix)
    Polymesh::Draw(*bunnies())
    
  Next
  glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*ground\matrix)
  Polymesh::Draw(*ground)
  
  
;   Define bw = vwidth/5
;   Define bh = vheight/5
  
;   Framebuffer::BlitTo(*gbuffer,#Null,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *gbuffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,0, 0, vwidth,vheight,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
;   glDisable(#GL_DEPTH_TEST)
;   glReadBuffer(#GL_COLOR_ATTACHMENT1)
;   glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,vwidth-bw, vheight-2*bh, vwidth, vheight-bh,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
;   glReadBuffer(#GL_COLOR_ATTACHMENT2)
;   glBlitFramebuffer(0, 0, *gbuffer\width,*gbuffer\height,vwidth-bw, vheight-3*bh, vwidth, vheight-2*bh,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
  
  ;2. Create SSAO texture
  glDisable(#GL_DEPTH_TEST)
  Framebuffer::BindInput(*gbuffer)
  Framebuffer::BindOutput(*ssao)
  glClear(#GL_COLOR_BUFFER_BIT);
  shader = *s_ssao\pgm
  glUseProgram(shader)
  glViewport(0,0,*ssao\width,*ssao\height)
  glUniform1i(u_ssao_position_map,0)
  glUniform1i(u_ssao_normal_map,1)
  glActiveTexture(#GL_TEXTURE2)
  glBindTexture(#GL_TEXTURE_2D,noise_tex)
  glUniform1i(u_ssao_noise_map,2)
  glUniform1f(u_ssao_occ_radius,occ_radius)
  glUniform1f(u_ssao_occ_power,7)
  glUniformMatrix4fv(u_ssao_view,1,#GL_FALSE,*app\camera\view)
  glUniformMatrix4fv(u_ssao_projection,1,#GL_FALSE,*app\camera\projection)
;         For i=0 To nbsamples-1
;           glUniform3fv(glGetUniformLocation(shader,"kernel_samples[" + Str(i) + "]"), 1, CArray::GetPtr(*kernel,i));
;         Next
  
  glUniform3fv(u_ssao_kernel_samples,nbsamples,Carray::GetPtr(*kernel,0))
  glUniform1i(u_ssao_kernel_size,nbsamples)
  glUniform2f(u_ssao_noise_scale,*ssao\width/4,*ssao\height/4)
  
  ;       
  ScreenQuad::Draw(*quad)
  ;       
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *ssao\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *ssao\width,*ssao\height,0, 0, vwidth, vheight,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
  
  If occ_blur
    ;3. Blur SSAO texture To remove noise
    shader = *s_ssao_blur\pgm
    glUseProgram(shader)
    glViewport(0,0,*blur\width,*blur\height)
    Framebuffer::BindInput(*ssao)
    Framebuffer::BindOutput(*blur)
    glClear(#GL_COLOR_BUFFER_BIT);
    ScreenQuad::Draw(*quad)
    
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glBindFramebuffer(#GL_READ_FRAMEBUFFER, *blur\frame_id);
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    glBlitFramebuffer(0, 0, *blur\width,*blur\height,0, 0, WIDTH, HEIGHT,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);
  EndIf
  
  ;4. Lighting
  Framebuffer::BindInput(*gbuffer)
  If occ_blur
    Framebuffer::BindInput(*blur,3)
  Else
    Framebuffer::BindInput(*ssao,3)
  EndIf
  
  Framebuffer::BindOutput(*deferred)
  glClear(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT);
  shader = *s_deferred\pgm
  glUseProgram(shader)
  glViewport(0,0,*deferred\width,*deferred\height)
  glUniform1i(glGetUniformLocation(shader,"position_map"),0)
  glUniform1i(glGetUniformLocation(shader,"normal_map"),1)
  glUniform1i(glGetUniformLocation(shader,"color_map"),2)
  glUniform1i(glGetUniformLocation(shader,"ssao_map"),3)
  glUniform1i(glGetUniformLocation(shader,"nb_lights"),nb_lights)
  i = 0
  ForEach *lights()
    Light::PassToShader(*lights(),shader,i)
    i+1
  Next
  
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*app\camera\view)
  
  ScreenQuad::Draw(*quad)
  
  glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  glBindFramebuffer(#GL_READ_FRAMEBUFFER, *deferred\frame_id);
  glReadBuffer(#GL_COLOR_ATTACHMENT0)
  glBlitFramebuffer(0, 0, *deferred\width,*deferred\height,0, 0, vwidth, vheight,#GL_COLOR_BUFFER_BIT,#GL_NEAREST);  
  
  CompilerIf Not #USE_GLFW
    SetGadgetAttribute(*viewport\gadgetID,#PB_OpenGL_FlipBuffers,#True)
    
  CompilerEndIf
  
EndProcedure

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
   *app = Application::New("SSAO",800,600)
   CompilerIf Not #USE_GLFW
     Define *view.View::View_t = View::Split(*app\manager\main,#PB_Splitter_Vertical,75)
     *viewport = ViewportUI::New(*view\left,"ViewportUI")
     *app\context = *viewport\context
     *prop.PropertyUI::PropertyUI_t = PropertyUI::New(*view\right,"PropertyUI",#Null)
     
    *viewport\camera = *app\camera
    View::SetContent(*app\manager\main,*viewport)
    *app\manager\active = *app\manager\main
   CompilerEndIf
   
;   CompilerIf #USE_GLFW
;     glfwInit()
;     Define *window.GLFWWindow = glfwCreateFullScreenWindow()
;     ;glfwCreateWindow(800,600,"TestGLFW",#Null,#Null)
;     ;glfwMakeContextCurrent(*window)
;     GLLoadExtensions()
;   CompilerElse
;     glfwInit()
;     ExamineDesktops()
;     Define window.i = OpenWindow(#PB_Any,0,0,DesktopWidth(0),DesktopHeight(0),"OpenGLGadget",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget)
;     Define gadget.i = OpenGLGadget(#PB_Any,0,0,WindowWidth(window,#PB_Window_InnerCoordinate)-100,WindowHeight(window,#PB_Window_InnerCoordinate),#PB_OpenGL_Keyboard)
;     Define title_radius = TextGadget(#PB_Any,DesktopWidth(0)-95,5,100,20,"Occlusion Radius")
;     Define slider_radius = TrackBarGadget(#PB_Any,DesktopWidth(0)-100,20,100,20,0,20)
;     Define check_blur = CheckBoxGadget(#PB_Any,DesktopWidth(0)-100,50,100,20,"Occlusion Blur")
;     SetGadgetAttribute(gadget,#PB_OpenGL_SetContext,#True)
;     GLLoadExtensions()
;    CompilerEndIf  
; 
;   ; Camera
;   ;-----------------------------------------------------
;   *camera = Camera::New(Camera::#Camera_Perspective)
  
  ; Lights
  ;-----------------------------------------------------
  For i=0 To nb_lights
    AddElement(*lights())
    *lights() = Light::New("Light")
    Vector3::Set(*lights()\pos,Random(20)-10,1,Random(20)-10)
    Vector3::Set(*lights()\color,Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  Next
  
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  Define *ftgl_drawer.FTGL::FTGL_Drawer = FTGL::New()
  
  
  ; Shaders
  ;-----------------------------------------------------
  *s_wireframe = Program::NewFromName("wireframe")
  *s_polymesh = Program::NewFromName("polymesh")
  *s_gbuffer = Program::NewFromName("gbuffer")
  *s_deferred = Program::NewFromName("deferred")
  *s_ssao = Program::NewFromName("ssao")
  *s_ssao_blur = Program::NewFromName("ssao_blur")
  
  u_gbuffer_model = glGetUniformLocation(*s_gbuffer\pgm,"model")
  u_gbuffer_view = glGetUniformLocation(*s_gbuffer\pgm,"view")
  u_gbuffer_projection = glGetUniformLocation(*s_gbuffer\pgm,"projection")
  u_gbuffer_nearplane = glGetUniformLocation(*s_gbuffer\pgm,"nearplane")
  u_gbuffer_farplane = glGetUniformLocation(*s_gbuffer\pgm,"farplane")
  u_gbuffer_color = glGetUniformLocation(*s_gbuffer\pgm,"color")
  
  u_ssao_position_map = glGetUniformLocation(*s_ssao\pgm,"position_map")
  u_ssao_normal_map = glGetUniformLocation(*s_ssao\pgm,"normal_map")
  u_ssao_noise_map = glGetUniformLocation(*s_ssao\pgm,"noise_map")
  u_ssao_occ_radius = glGetUniformLocation(*s_ssao\pgm,"occ_radius")
  u_ssao_occ_power = glGetUniformLocation(*s_ssao\pgm,"occ_power")
  u_ssao_view = glGetUniformLocation(*s_ssao\pgm,"view")
  u_ssao_projection = glGetUniformLocation(*s_ssao\pgm,"projection")
  u_ssao_kernel_samples = glGetUniformLocation(*s_ssao\pgm,"kernel_samples")
  u_ssao_kernel_size = glGetUniformLocation(*s_ssao\pgm,"kernel_size")
  u_ssao_noise_scale = glGetUniformLocation(*s_ssao\pgm, "noise_scale")

  
  shader.l = *s_gbuffer\pgm
  glUseProgram(shader)
  
  ; Meshes
  ;-----------------------------------------------------
  Define pos.v3f32, rot.q4f32
  Define color.v3f32
  Define x,y,z
  For x = 0 To 7
    For y=0 To 3
      For z=0 To 7
        AddElement(*bunnies())
        *bunnies() = Polymesh::New("Bunny",Shape::#SHAPE_TEAPOT)
        Vector3::Set(@color,Random(100)*0.005+0.5,Random(100)*0.005+0.5,Random(100)*0.005+0.5)
        ;Shape::RandomizeColors(*bunnies()\shape,@color,0.0)
        Vector3::Set(@pos,x-5,y+0.5,z-5)
        Matrix4::SetTranslation(*bunnies()\matrix,@pos)
        Polymesh::Setup(*bunnies(),*s_gbuffer)
      Next
    Next
  Next
  
  *ground = Polymesh::New("Ground",Shape::#SHAPE_GRID)
  ;Shape::RandomizeColors(*ground\shape,@color,0.0)
  Polymesh::Setup(*ground,*s_gbuffer)
  
  *quad = ScreenQuad::New()
  ScreenQuad::Setup(*quad,*s_gbuffer)
  
  ; Geometry Buffer
  ;-----------------------------------------------------
  *gbuffer = Framebuffer::New("GBuffer",WIDTH,HEIGHT)
  Framebuffer::AttachTexture(*gbuffer,"position",#GL_RGBA16F,#GL_LINEAR,#GL_REPEAT)
  Framebuffer::AttachTexture(*gbuffer,"normal",#GL_RGBA16F,#GL_LINEAR,#GL_CLAMP)
  Framebuffer::AttachTexture(*gbuffer,"color",#GL_RGBA,#GL_LINEAR,#GL_CLAMP)
  Framebuffer::AttachRender(*gbuffer,"depth",#GL_DEPTH_COMPONENT)
  
  ; SSAO Buffer
  ;-----------------------------------------------------
   *ssao = Framebuffer::New("SSAO",WIDTH/2,HEIGHT/2)
  Framebuffer::AttachTexture(*ssao,"ao",#GL_RED,#GL_NEAREST,#GL_CLAMP)
  
  ; Blur SSAO Buffer
  ;-----------------------------------------------------
  *blur = Framebuffer::New("Blur",WIDTH,HEIGHT)
  Framebuffer::AttachTexture(*blur,"blur",#GL_RED,#GL_NEAREST,#GL_REPEAT)
  
  ; Deferred Buffer
  ;-----------------------------------------------------
  *deferred = Framebuffer::New("Deferred",WIDTH,HEIGHT)
  Framebuffer::AttachTexture(*deferred,"deferred",#GL_RGBA32F,#GL_LINEAR,#GL_CLAMP)
  
  
  *kernel = CArray::newCArrayV3F32()
  CArray::SetCount(*kernel,nbsamples)
  
  For i=0 To nbsamples-1
    *p = CArray::GetPtr(*kernel,i)
    Vector3::Set(*p,1-(Random(100)*0.02),1-(Random(100)*0.02),Random(100)*0.01 )
    Vector3::NormalizeInPlace(*p)
;     Vector3::ScaleInPlace(*p,Random(100)*0.01)
    scl = i/nbsamples
    LINEAR_INTERPOLATE(scl,0.1,1,scl*scl)
    Vector3::ScaleInPlace(*p,scl)
    CArray::SetValue(*kernel,i,*p)
  Next
  
  
  *noise = CArray::newCArrayV3F32()
  CArray::SetCount(*noise,noise_size)

  For i=0 To noise_size-1
    Vector3::Set(CArray::GetPtr(*noise,i),Random(100)*0.02-1,Random(100)*0.02-1,0)
    Vector3::NormalizeInPlace(CArray::GetPtr(*noise,i))
  Next i
  
  
  glGenTextures(1,@noise_tex)
  glBindTexture(#GL_TEXTURE_2D,noise_tex)
  glTexImage2D(#GL_TEXTURE_2D,0,#GL_RGBA16F,4,4,0,#GL_RGB,#GL_FLOAT,CArray::GetPtr(*noise,0))
  glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
  glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
  glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT)
  glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT)
  
  
  Matrix4::SetIdentity(@offset)
  Quaternion::SetIdentity(@q)
  Matrix4::SetFromQuaternion(@m,@q)
  
  Application::Loop(*app,@Draw())

EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 328
; FirstLine = 279
; Folding = -
; EnableXP
; Executable = ssao.exe
; Constant = #USE_GLFW=0