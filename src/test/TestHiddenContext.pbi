; Test Hidden Context
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Context.pbi"
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
Global pbo1, pbo2, tex, index, nextIndex, pboMode
Global Dim pbos.i(2)


Structure Monitor_t
  window.i
  *ctxt.GLContext::GLContext_t
  *bitmap.LayerBitmap::LayerBitmap_t
  pbo.GLuint
EndStructure


#NUM_WINDOWS = 3
Global Dim views.Monitor_t(#NUM_WINDOWS)
Global window = OpenWindow(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT,"Share GL Context")
Global *context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #Null)
Global *framebuffer.Framebuffer::Framebuffer_t
; Global 

For i=0 To #NUM_WINDOWS-1
  views(i)\window = OpenWindow(#PB_Any, Random(200), Random(200), #DEFAULT_WIDTH, #DEFAULT_HEIGHT, "SUBVIEW"+Str(i),#PB_Window_Tool, WindowID(window))
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
;      ; Allocate Pixel Format Object
;         Define pfo.NSOpenGLPixelFormat = CocoaMessage( 0, 0, "NSOpenGLPixelFormat alloc" )
;         ; Set Pixel Format Attributes
;         Define pfa.NSOpenGLPixelFormatAttribute
;         With pfa
;           \v[0] = #NSOpenGLPFAColorSize          : \v[1] = 24
;           \v[2] = #NSOpenGLPFAAlphaSize          : \v[3] =  8
;           \v[4] = #NSOpenGLPFAOpenGLProfile      : \v[5] = #NSOpenGLProfileVersion3_2Core ; will give 4.1 version (or more recent) if available
;           \v[6] = #NSOpenGLPFADoubleBuffer
;           \v[7] = #NSOpenGLPFAAccelerated ; I also want OpenCL available
;           \v[8] = #NSOpenGLPFANoRecovery
;           \v[9] = #Null
;         EndWith
;   
;         ; Choose Pixel Format
;         CocoaMessage( 0, pfo, "initWithAttributes:", @pfa )
;         ; Allocate OpenGL Context
;         Define ctx.NSOpenGLContext = CocoaMessage( 0, 0, "NSOpenGLContext alloc" )
;         ; Create OpenGL Context
;         CocoaMessage( 0, ctx, "initWithFormat:", pfo, "shareContext:", #Null )
;         ; Set Current Context
;         CocoaMessage( 0, ctx, "makeCurrentContext" )
;         ; Swap Buffers
;         CocoaMessage( 0, ctx, "flushBuffer" )
;       
    
    Global gadgetID = CanvasGadget(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
    views(i)\ctxt = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT,*context)
    CocoaMessage( 0, views(i)\ctxt\ID, "setView:", GadgetID(gadgetID) )
    
      views(i)\bitmap = LayerBitmap::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, views(i)\ctxt, #Null)
      LayerBitmap::Setup(views(i)\bitmap )
      CocoaMessage( 0, *context\ID, "makeCurrentContext" )
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    Global gadgetID = OpenGLGadget(#PB_Any,0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
    SetGadgetAttribute(gadgetID,#PB_OpenGL_SetContext,#True)
  
    views(i)\ctxt = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT,*context)
    ResizeGadget(views(i)\ctxt\ID, 0,0,#DEFAULT_WIDTH, #DEFAULT_HEIGHT)
    
    

    views(i)\bitmap  = LayerBitmap::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, views(i)\ctxt, #Null)
    LayerBitmap::Setup(views(i)\bitmap )
  ;     LayerBitmap::SetBitmapFromSource(*bitmap, "E:/Projects/RnD/Noodle/rsc/ico/bone_raw.png")
    
    SetGadgetAttribute(*context\ID,#PB_OpenGL_SetContext,#True)
  CompilerEndIf
  
  glGenBuffers(1, @views(i)\pbo);
  glBindBuffer(#GL_PIXEL_PACK_BUFFER, views(i)\pbo)
  glBufferData(#GL_PIXEL_PACK_BUFFER, #DATA_SIZE, 0, #GL_READ_WRITE)

  
Next



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

Procedure Pack(*monitor.Monitor_t)
  index = 1 - index
  nextIndex = 1 - index
  ; copy pixels from framebuffer To PBO
  ; Use offset instead of pointer.
  ; OpenGL should perform asynch DMA transfer, so glReadPixels() will Return immediately.
  glBindBuffer(#GL_PIXEL_PACK_BUFFER, *monitor\pbo);
  glReadPixels(0, 0, #DEFAULT_WIDTH, #DEFAULT_HEIGHT, #GL_BGRA, #GL_UNSIGNED_BYTE, 0)
  
  
;   ; Map the PBO that contain framebuffer pixels before processing it
;   glBindBuffer(#GL_PIXEL_PACK_BUFFER, *monitor\pbos[nextIndex])
;   Define *src = glMapBuffer(#GL_PIXEL_PACK_BUFFER, #GL_READ_ONLY)
;   If *src
;       ; change brightness
;       ;add(src, SCREEN_WIDTH, SCREEN_HEIGHT, shift, colorBuffer);
;       glUnmapBuffer(#GL_PIXEL_PACK_BUFFER);        // release pointer to the mapped buffer
;   EndIf
EndProcedure

Procedure Unpack()
  
  ; "index" is used To copy pixels from a PBO To a texture object
  ; "nextIndex" is used To update pixels in a PBO
  If pboMode = 1
    ; In single PBO mode, the index And nextIndex are set To 0
    index = 0
    nextIndex = 0
  ElseIf pboMode = 2
    ; In dual PBO mode, increment current index first then get the Next index
    index = 1 - index
    nextIndex = 1 - index
   EndIf

    ; copy from PBO To texture object  //////////////////////////
    ; bind the texture And PBO
    glBindTexture(#GL_TEXTURE_2D, tex)
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbos(index))

    ; copy pixels from PBO To texture object
    ; Use offset instead of ponter.
    glTexSubImage2D(#GL_TEXTURE_2D, 0, 0, 0, #DEFAULT_WIDTH, #DEFAULT_HEIGHT, #GL_BGRA, #GL_UNSIGNED_BYTE, 0)

    ; modify pixel values ///////////////////

    ; bind PBO To update pixel values
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbos(nextIndex)) 
    
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
    If(*ptr)
        ; update Data directly on the mapped buffer
        updatePixels(*ptr, #DATA_SIZE)
        glUnmapBuffer(#GL_PIXEL_UNPACK_BUFFER)  ; release pointer To mapping buffer
    EndIf


    ;it is good idea To release PBOs With ID 0 after use.
    ; Once bound With 0, all pixel operations behave normal ways.
    glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, 0)

EndProcedure

; create framebuffer
*framebuffer = Framebuffer::New("Default",#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
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
; *bitmap\bitmap = tex

; init 2 pixel buffer object
glGenBuffers(1, @pbo1)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo1)
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
glGenBuffers(1, @pbo2)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, pbo2)
glBufferData(#GL_PIXEL_UNPACK_BUFFER, #DATA_SIZE, 0, #GL_STREAM_DRAW)
glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, 0)

pbos(0) = pbo1
pbos(1) = pbo2

Repeat
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *context\ID, "makeCurrentContext" )
  CompilerElse
    SetGadgetAttribute(*context\ID, #PB_OpenGL_SetContext, #True)
  CompilerEndIf
;   Framebuffer::BindOutput(*framebuffer)
;   glEnable(#GL_SCISSOR_TEST)
;   glViewport(0,0,100,100)
;   glScissor(0,0,100,100)
;   glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   
;   glViewport(100,100,100,100)
;   glScissor(100,100,100,100)
;   glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   
;   glViewport(200,200,100,100)
;   glScissor(200,200,100,100)
;   glClearColor(Random(255)/255,Random(255)/255,Random(255)/255,1)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
; 
;   
;   glDisable(#GL_SCISSOR_TEST)
  Unpack()
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
    CocoaMessage( 0, *context\ID, "flushBuffer" )
  CompilerElse
    SetGadgetAttribute(*context\ID, #PB_OpenGL_FlipBuffers, #True)
  CompilerEndIf

  
  
  For i=0 To #NUM_WINDOWS-1
    GLContext::SetContext(views(i)\ctxt)
    ;   Framebuffer::BindOutput(*bitmap\buffer)
    views(i)\bitmap\bitmap = tex
    LayerBitmap::Draw(views(i)\bitmap, views(i)\ctxt)
    GLContext::FlipBuffer(views(i)\ctxt)
  Next
  
  
Until WaitWindowEvent() = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 252
; FirstLine = 202
; Folding = --
; EnableXP