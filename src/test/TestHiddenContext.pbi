; Test Hidden Context
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/ContextShared.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../layers/Bitmap.pbi"

UseModule OpenGL
UseModule OpenGLExt

#DEFAULT_WIDTH    = 1024
#DEFAULT_HEIGHT   = 720
#CHANNEL_COUNT    = 4
#DATA_SIZE        = #DEFAULT_WIDTH * #DEFAULT_HEIGHT * #CHANNEL_COUNT
Global *datas     = AllocateMemory(#DATA_SIZE)
Global pbo1, pbo2, tex, index


Global window = OpenWindow(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT,"Share GL Context")
Global *shared_context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #True)
Global *bitmap.LayerBitmap::LayerBitmap_t
; Global 
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
   ; Allocate Pixel Format Object
      Define pfo.NSOpenGLPixelFormat = CocoaMessage( 0, 0, "NSOpenGLPixelFormat alloc" )
      ; Set Pixel Format Attributes
      Define pfa.NSOpenGLPixelFormatAttribute
      With pfa
        \v[0] = #NSOpenGLPFAColorSize          : \v[1] = 24
        \v[2] = #NSOpenGLPFAAlphaSize          : \v[3] =  8
        \v[4] = #NSOpenGLPFAOpenGLProfile      : \v[5] = #NSOpenGLProfileVersion3_2Core ; will give 4.1 version (or more recent) if available
        \v[6] = #NSOpenGLPFADoubleBuffer
        \v[7] = #NSOpenGLPFAAccelerated ; I also want OpenCL available
        \v[8] = #NSOpenGLPFANoRecovery
        \v[9] = #Null
      EndWith

      ; Choose Pixel Format
      CocoaMessage( 0, pfo, "initWithAttributes:", @pfa )
      ; Allocate OpenGL Context
      Define ctx.NSOpenGLContext = CocoaMessage( 0, 0, "NSOpenGLContext alloc" )
      ; Create OpenGL Context
      CocoaMessage( 0, ctx, "initWithFormat:", pfo, "shareContext:", #Null )
      ; Set Current Context
      CocoaMessage( 0, ctx, "makeCurrentContext" )
      ; Swap Buffers
      CocoaMessage( 0, ctx, "flushBuffer" )
    Global gadgetID = CanvasGadget(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
    CocoaMessage( 0, ctx, "setView:", GadgetID(gadgetID) )
    Global *secondary_context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #False)
    GLContext::Setup(*secondary_context)
    *bitmap = LayerBitmap::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, *secondary_context, #Null)
    LayerBitmap::Setup(*bitmap)
    CocoaMessage( 0, *shared_context\ID, "makeCurrentContext" )
CompilerElse
  Global gadgetID = OpenGLGadget(#PB_Any,0,0,width,height)
  SetGadgetAttribute(gadgetID,#PB_OpenGL_SetContext,#True)
  Global *secondary_context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #False)
  GLContext::Setup(*secondary_context)
   
  *bitmap = LayerBitmap::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, *secondary_context, #Null)
  LayerBitmap::Setup(*bitmap)
  SetGadgetAttribute(*shared_context\gadgetID,#PB_OpenGL_SetContext,#True)
CompilerEndIf

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

; create framebuffer
Global *framebuffer = Framebuffer::New("Default",#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
Framebuffer::AttachTexture(*framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
Framebuffer::AttachRender( *framebuffer,"Depth",#GL_DEPTH_COMPONENT)

glPixelStorei(#GL_UNPACK_ALIGNMENT, 4)        ; 4-byte pixel alignment

; init 1 texture objects
glGenTextures(1, @tex)
glBindTexture(#GL_TEXTURE_2D, tex)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_BORDER)
glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_BORDER)
glTexImage2D(#GL_TEXTURE_2D, 0, #GL_RGBA8, #DEFAULT_WIDTH, #DEFAULT_HEIGHT, 0, #GL_BGRA_EXT, #GL_UNSIGNED_BYTE, *datas)
glBindTexture(#GL_TEXTURE_2D, 0)

; init 2 pixel buffer object
glGenBuffers(1, @pbo1)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo1)
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
glGenBuffers(1, @pbo2)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo2)
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, 0)

Repeat
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *shared_context\ID, "makeCurrentContext" )
  CompilerElse
    SetGadgetAttribute(*shared_context\gadgetID, #PB_OpenGL_SetContext, #True)
  CompilerEndIf
  Framebuffer::BindOutput(*framebuffer)
  glEnable(#GL_SCISSOR_TEST)
  glViewport(0,0,100,100)
  glScissor(0,0,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glViewport(100,100,100,100)
  glScissor(100,100,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glViewport(200,200,100,100)
  glScissor(200,200,100,100)
  glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  Draw()
  
  glDisable(#GL_SCISSOR_TEST)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *shared_context\ID, "flushBuffer" )
  CompilerElse
    SetGadgetAttribute(*shared_context\gadgetID, #PB_OpenGL_FlipBuffers, #True)
  CompilerEndIf
  
  ; pass image to secondary context via pbo
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *secondary_context\ID, "makeCurrentContext" )
  CompilerElse
    SetGadgetAttribute(*secondary_context\gadgetID, #PB_OpenGL_SetContext, #True)
  CompilerEndIf
  
  Framebuffer::BindOutput(*bitmap\buffer)
  LayerBitmap::Draw(*bitmap, *secondary_context)
  
  
Until WaitWindowEvent() = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)


; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 62
; FirstLine = 28
; Folding = --
; EnableXP