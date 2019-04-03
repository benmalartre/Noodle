XIncludeFile "../core/Application.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
UseModule OpenGLExt

EnableExplicit


; Main
;--------------------------------------------
If Time::Init()
;   FTGL::Init()
  Log::Init()
    glfwInit()
    Define *window.GLFWWindow = glfwCreateWindowedWindow(800,600,"TestGLFW")
    ;glfwCreateWindow(800,600,"TestGLFW",#Null,#Null)
    glfwMakeContextCurrent(*window)
    GLLoadExtensions()
    Define w,h
    glfwGetWindowSize(*window,@w,@h)
  
    While Not glfwWindowShouldClose(*window)
      glfwPollEvents()
      glClearColor(Random(100)*0.01, Random(100)*0.01, Random(100)*0.01, 1)
      glClear(#GL_COLOR_BUFFER_BIT)
      
      glDisable(#GL_DEPTH_TEST)
      glEnable(#GL_BLEND)
      glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)

;       FTGL::SetColor(*ftgl_drawer,1,1,1,1)
;       Define ss.f = 0.85/w
;       Define ratio.f = w/h
;       FTGL::Draw(*ftgl_drawer,"Date : "+FormatDate("%dd/%mm/%yyyy", Date()),-0.9,0.95,ss,ss*ratio)
;       FTGL::Draw(*ftgl_drawer,"Time : "+FormatDate("%hh:%ii:%ss", Date()),-0.9,0.9,ss,ss*ratio)
;       FTGL::Draw(*ftgl_drawer,"User : "+UserName(),-0.9,0.85,ss,ss*ratio)
      ;FTGL::Draw(*ftgl_drawer,"FPS : "+StrF(*app\fps),-0.9,0.8,ss,ss*ratio)
      glDisable(#GL_BLEND)
  
      glfwSwapBuffers(*window)
     
    Wend
    
;     FTGL::Delete(*ftgl_drawer)
  
EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 7
; Folding = -
; EnableThread
; EnableXP
; Executable = E:\Volumes\STORE N GO\TestGLFW.app
; DisableDebugger
; Debugger = Standalone
; EnablePurifier
; Constant = #USE_GLFW=1