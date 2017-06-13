

XIncludeFile "OpenGL.pbi"
XIncludeFile "GLFW.pbi"
XIncludeFile "OpenGLExt.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "Camera.pbi"
XIncludeFile "Shader.pbi"
XIncludeFile "Framebuffer.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Time.pbi"
XIncludeFile "KDTree.pbi"
XIncludeFile "Polymesh.pbi"
; XIncludeFile "FTGL.pbi"


UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
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
;     Define *ftgl_drawer.FTGL::FTGL_Drawer = FTGL::New()
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
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 32
; FirstLine = 9
; EnableThread
; EnableXP
; Executable = /Volumes/STORE N GO/TestGLFW.app
; DisableDebugger
; Debugger = Standalone
; EnablePurifier
; Constant = #USE_GLFW=1