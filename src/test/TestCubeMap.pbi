EnableExplicit

XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt

EnableExplicit

Global *camera.Camera::Camera_t = #Null

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  CompilerIf #USE_GLFW
    glfwInit()
    Define *window.GLFWWindow = glfwCreateFullScreenWindow()
    ;glfwCreateWindow(800,600,"TestGLFW",#Null,#Null)
    glfwMakeContextCurrent(*window)
    GLLoadExtensions()
  CompilerElse
    Define window.i = OpenWindow(#PB_Any,0,0,800,600,"OpenGLGadget",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget)
    Define gadget.i = OpenGLGadget(#PB_Any,0,0,WindowWidth(window,#PB_Window_InnerCoordinate),WindowHeight(window,#PB_Window_InnerCoordinate))
    SetGadgetAttribute(gadget,#PB_OpenGL_SetContext,#True)
    GLLoadExtensions()
   CompilerEndIf  
  Define i
  
  *camera = Camera::New("Default",Camera::#Camera_Perspective)
  FTGL::Init()
  
  Define *m.CubeMap::CubeMap_t = CubeMap::New("../../cube_maps/ldr/stpeters_cross.tif")
  CubeMap::Setup(*m)
  
  Global *s_polymesh.Program::Program_t = Program::NewFromName("polymesh")
  Global *s_reflection.Program::Program_t = Program::NewFromName("reflection")
  Define *bunny.Polymesh::Polymesh_t = Polymesh::New("Bunny",Shape::#SHAPE_SPHERE)
  Polymesh::Setup(*bunny,*s_polymesh)
  Define shader.GLuint
  Define offset.m4f32
  
  CompilerIf #USE_GLFW
    While Not glfwWindowShouldClose(*window)
      glfwPollEvents()
      Define w,h
      glfwGetWindowSize(*window,@w,@h)
      glClearColor(0.5,0.5,0.5,1.0)
      glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
      

      glDisable(#GL_DEPTH_TEST)
     CubeMap::Draw(*m,*camera)
     
      shader = s_reflection\pgm
      glUseProgram(shader)
      Matrix4::SetIdentity(@offset)
      glEnable(#GL_DEPTH_TEST)
      
      glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera \view)
      CompilerIf #USE_LEGACY_OPENGL
        Define m.m4f2
        Matrix4::Inverse(@m,*camera \view)
        glUniformMatrix4fv(glGetUniformLocation(shader,"inverseView"),1,#GL_FALSE,@m)
      CompilerEndIf
      
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
      glUniform3f(glGetUniformLocation(shader,"color"),0,1,0)

      Polymesh::Draw(*bunny)
      
      glViewport(0,0,w,h)
      glEnable(#GL_BLEND)
      glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
      glDisable(#GL_DEPTH_TEST)
      FTGL::SetColor(*app\context\writer,1,1,1,1)
      Define ss.f = 0.85/w
      Define ratio.f = w / h
      FTGL::Draw(*app\context\writer,"SSAO wip",-0.9,0.9,ss,ss*ratio)
      FTGL::Draw(*app\context\writer,"User  : "+UserName(),-0.9,0.85,ss,ss*ratio)
;       FTGL::Draw(*ftgl_drawer,"FPS  : "+Str(fps),-0.9,0.8,ss,ss*ratio)
      glDisable(#GL_BLEND)
      glEnable(#GL_DEPTH_TEST)
      
      ;Draw(vao,nbp)
      ;       DrawKDTree(*tree,cube_vao,shader)
;       Vector3::Set(s,5,5,5)
;       Matrix4::SetScale(@offset,@s)
;       glUniform3f(glGetUniformLocation(shader,"color"),1,0,0)
;       glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
;       DrawQuery(query_vao)
      glfwSwapBuffers(*window)
     
    Wend
  CompilerElse
    Define e
    Repeat
      e = WaitWindowEvent(1000/60)
      If e=#PB_Event_SizeWindow
        Camera::Resize(*camera,window,gadget)
      EndIf
      Define w = GadgetWidth(gadget)
      Define h = GadgetHeight(gadget)
      glClearColor(0.5,0.5,0.5,1.0)
      glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
      
      Camera::OnEvent(*camera,gadget)
      glDisable(#GL_DEPTH_TEST)
     CubeMap::Draw(*m,*camera)
     
      shader = *s_reflection\pgm
      glUseProgram(shader)
      Matrix4::SetIdentity(@offset)
      glEnable(#GL_DEPTH_TEST)
      
      glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*camera\view)
      CompilerIf #USE_LEGACY_OPENGL
        Define m.m4f32
        Matrix4::Inverse(@m,*camera \view)
        glUniformMatrix4fv(glGetUniformLocation(shader,"inverseView"),1,#GL_FALSE,m)
      CompilerEndIf
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*camera\projection)
      glUniform3f(glGetUniformLocation(shader,"color"),0,1,0)

      Polymesh::Draw(*bunny)
      
      ; Draw infos
      glEnable(#GL_BLEND)
      glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
      glDisable(#GL_DEPTH_TEST)
      FTGL::SetColor(*ftgl_drawer,1,1,1,1)
      Define ss.f = 0.85/w
      Define ratio.f = w / h
      FTGL::Draw(*ftgl_drawer,"FPS : "+Str(777),-0.9,0.9,ss,ss*ratio)
      FTGL::Draw(*ftgl_drawer,"User  : "+UserName(),-0.9,0.85,ss,ss*ratio)
      
      ;Draw(vao,nbp)
      ;       DrawKDTree(*tree,cube_vao,shader)
;       Vector3::Set(s,5,5,5)
;       Matrix4::SetScale(@offset,@s)
;       glUniform3f(glGetUniformLocation(shader,"color"),1,0,0)
;       glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@offset)
;       DrawQuery(query_vao)
      SetGadgetAttribute(gadget,#PB_OpenGL_FlipBuffers,#True)

    Until e = #PB_Event_CloseWindow
  CompilerEndIf
EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 145
; FirstLine = 92
; Folding = -
; EnableXP
; Executable = reflected.exe