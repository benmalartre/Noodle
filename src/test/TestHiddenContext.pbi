; Test Hidden Context
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../core/Math.pbi"


UseModule OpenGL
UseModule OpenGLExt

#DEFAULT_WIDTH    = 1024
#DEFAULT_HEIGHT   = 720
#CHANNEL_COUNT    = 4
#DATA_SIZE        = #DEFAULT_WIDTH * #DEFAULT_HEIGHT * #CHANNEL_COUNT
Global *datas     = AllocateMemory(#DATA_SIZE)
Global.GLuint pbo1, pbo2, tex, index


Define window = OpenWindow(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT,"Share GL Context")
Define *context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #False)
Define hidden = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
SetGadgetAttribute(hidden, #PB_OpenGL_SetContext, #True)
GLContext::Setup(*context)

GLCheckError("CREATE CONTEXT GL")

;///////////////////////////////////////////////////////////////////////////////
;// copy an image Data To texture buffer
;///////////////////////////////////////////////////////////////////////////////
Procedure UpdatePixels(*dst, size.i)
  Static color.l = 0

  If Not *dst : ProcedureReturn : EndIf
  Define *ptr = *dst, i.i, j.i

  ; copy 4 bytes at once
  For i = 0 To #DEFAULT_HEIGHT - 1
    For j = 0 To #DEFAULT_WIDTH - 1
      PokeL(*ptr, color)
      *ptr + 4
    Next
    color + 257
  Next
  color + 1
EndProcedure

Procedure Draw()
  GLCheckError("SHARED CONTEXT START DRAW")
  index = 1 - index
  Define nextIndex = 1 - index
  ; bind the texture And PBO
  glBindTexture(#GL_TEXTURE_2D, tex)
  If index = 0
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo1)
  Else
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo2)
  EndIf
  GLCheckError("SHARED CONTEXT BIND READ BUFFER")
  
  ; copy pixels from PBO To texture object
  ; Use offset instead of ponter.
  glTexSubImage2D(#GL_TEXTURE_2D, 0, 0, 0, #DEFAULT_WIDTH, #DEFAULT_HEIGHT, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, 0)
  
  ; bind PBO To update pixel values
  If index = 0
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo2)
  Else
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo1)
  EndIf
  GLCheckError("SHARED CONTEXT BIND WRITE BUFFER")

  ; Map the buffer object into client's memory
  ; Note that glMapBuffer() causes sync issue.
  ; If GPU is working With this buffer, glMapBuffer() will wait(stall)
  ; For GPU To finish its job. To avoid waiting (stall), you can call
  ; first glBufferData() With NULL pointer before glMapBuffer().
  ; If you do that, the previous Data in PBO will be discarded And
  ; glMapBuffer() returns a new allocated pointer immediately
  ; even If GPU is still working With the previous Data.
  glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
  Define *ptr = glMapBuffer(#GL_PIXEL_UNPACK_BUFFER, #GL_WRITE_ONLY)
  If *ptr
    ; update Data directly on the mapped buffer
    UpdatePixels(*ptr, #DATA_SIZE)
    glUnmapBuffer( #GL_PIXEL_UNPACK_BUFFER)  ; release pointer To mapping buffer
  EndIf
    
   ; it is good idea To release PBOs With ID 0 after use.
   ; Once bound With 0, all pixel operations behave normal ways.
   glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, 0);
  GLCheckError("SHARED CONTEXT END DRAW")
EndProcedure


; init 1 texture objects
glGenTextures(1, @tex);
glBindTexture(#GL_TEXTURE_2D, tex);
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP)
glTexImage2D(#GL_TEXTURE_2D, 0, #GL_RGBA8, #DEFAULT_WIDTH, #DEFAULT_HEIGHT, 0, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, *datas)
glBindTexture(#GL_TEXTURE_2D, 0)
GLCheckError("SHARED CONTEXT CREATE TEXTURE")

; init 2 pixel buffer object
glGenBuffers(1, @pbo1);
GLCheckError("SHARED CONTEXT CREATE PIXEL BUFFER OBJECT1 _0")
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo1)
GLCheckError("SHARED CONTEXT CREATE PIXEL BUFFER OBJECT1 _1")
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
GLCheckError("SHARED CONTEXT CREATE PIXEL BUFFER OBJECT1 _2")
GLCheckError("SHARED CONTEXT CREATE PIXEL BUFFER OBJECT1")
glGenBuffers(1, @pbo2);
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo2)
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, 0)
GLCheckError("SHARED CONTEXT CREATE PIXEL BUFFER OBJECT2")

Repeat
  SetGadgetAttribute(hidden, #PB_OpenGL_SetContext, #True)
  glEnable(#GL_SCISSOR_TEST)
  glViewport(0,0,100,100)
  glScissor(0,0,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT)
  
  glViewport(100,100,100,100)
  glScissor(100,100,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT)
  
  glViewport(200,200,100,100)
  glScissor(200,200,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT)
  GLCheckError("SHARED CONTEXT DRAW IN HIDDEN CONTEXT")
  Draw()
  
  glDisable(#GL_SCISSOR_TEST)
  SetGadgetAttribute(hidden, #PB_OpenGL_FlipBuffers, #True)
  
Until WaitWindowEvent() = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)




; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 114
; FirstLine = 86
; Folding = -
; EnableXP