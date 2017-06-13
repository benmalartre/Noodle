

XIncludeFile "OpenGL.pbi"
XIncludeFile "GLFW.pbi"

UseModule OpenGL
UseModule GLFW

EnableExplicit


; Main
;--------------------------------------------
glfwInit()
Define *window.GLFWWindow = glfwCreateWindow(800,600,"TestGLFW",#Null,#Null)
glfwMakeContextCurrent(*window)

While Not glfwWindowShouldClose(*window)
  glfwPollEvents()
  glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)

  glfwSwapBuffers(*window)
  
  Delay(100)
 
Wend
; IDE Options = PureBasic 5.31 (Linux - x64)
; CursorPosition = 6
; EnableXP
; Executable = Test
; Debugger = Standalone