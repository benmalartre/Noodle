#GL_NO_ERROR = 0
#GL_INVALID_FRAMEBUFFER_OPERATION = $0506

ImportC "/System/Library/Frameworks/OpenGL.framework/OpenGL"
  glClear(v.i)
  glClearColor(r.f,g.f,b.f,a.f)
  glGetError()
EndImport


Procedure GLCheckError(message.s)
    Protected err = glGetError()
    If err
      While err <> #GL_NO_ERROR
        Protected error.s
        Select err
          Case #GL_INVALID_OPERATION
            error = " ---> INVALID OPERATION"
          Case #GL_INVALID_ENUM
            error = " ---> INVALID ENUM"
          Case #GL_INVALID_VALUE
            error = " ---> INVALID VALUE"
          Case #GL_OUT_OF_MEMORY
            error = " ---> OUT OF MEMORY"
          Case #GL_INVALID_FRAMEBUFFER_OPERATION
            error = " ---> INVALID FRAMEBUFFER OPERATION"
        EndSelect  
        Debug "[OpenGL Error] "+message+error
        err = glGetError()
      Wend  
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
window = OpenWindow(#PB_Any,0,0,800,600,"GLext")
gadget = OpenGLGadget(#PB_Any,0,0,800,600)
GLCheckError("Just Opening An Empty OpenGL Gadget")

Repeat
  glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1)
  glClear(#GL_COLOR_BUFFER_BIT)
  SetGadgetAttribute(gadget,#PB_OpenGL_FlipBuffers,#True)
  Delay(100)
Until WaitWindowEvent() = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 40
; FirstLine = 7
; Folding = -
; EnableUnicode
; EnableXP