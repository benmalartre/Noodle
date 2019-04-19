; ======================================================================================================
; Test Shared Context
; ======================================================================================================
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../layers/Bitmap.pbi"
XIncludeFile "../ui/ViewportUI.pbi"

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
  *camera.Camera::Camera_t
  *viewport.ViewportUI::ViewportUI_t
EndStructure


#NUM_WINDOWS = 3
Global Dim views.Monitor_t(#NUM_WINDOWS)
Global *manager.ViewManager::ViewManager_t = ViewManager::New("Share GL Context",0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
Global *context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #Null)
Global *framebuffer.Framebuffer::Framebuffer_t
Global *handle.Handle::Handle_t = Handle::New()

Global *main.View::View_t = *manager\main

; Global 
For i=0 To #NUM_WINDOWS-1
  
  views(i)\window = OpenWindow(#PB_Any, Random(200), Random(200), #DEFAULT_WIDTH, #DEFAULT_HEIGHT, "SUBVIEW"+Str(i),#PB_Window_Tool, WindowID(*manager\window))
  Define *sub.View::View_t = View::New(0,0,WindowWidth(views(i)\window),WindowHeight(views(i)\window),#Null,#False,"SUBVIEW"+Str(i) ,#True)
  views(i)\camera = Camera::New("Camera"+Str(i),Camera::#Camera_Perspective)
  views(i)\viewport = ViewportUI::New(*sub, "VIEWPORT"+Str(i), views(i)\camera, *handle)
  
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
  glBindBuffer(#GL_PIXEL_PACK_BUFFER, *monitor\viewport\pbo);
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

GLContext::SetContext(*context)
; create framebuffer
*framebuffer = Framebuffer::New("Default",#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
Framebuffer::AttachTexture(*framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
Framebuffer::AttachRender( *framebuffer,"Depth",#GL_DEPTH_COMPONENT)



Repeat
  GLContext::SetContext(*context)
  Framebuffer::BindOutput(*framebuffer)
  glViewport(0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
  glClearColor(0,0,0,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glEnable(#GL_SCISSOR_TEST)
  
  glScissor(0,0,100,100)
  glClearColor(Random(1000)*0.001,Random(1000)*0.001,Random(1000)*0.001,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glScissor(100,100,100,100)
  glClearColor(Random(1000)*0.001,Random(1000)*0.001,Random(1000)*0.001,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glScissor(200,200,100,100)
  glClearColor(Random(1000)*0.001,Random(1000)*0.001,Random(1000)*0.001,1)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)

  glDisable(#GL_SCISSOR_TEST)
  
  Framebuffer::Unbind(*framebuffer)
;   Unpack()
  GLContext::FlipBuffer(*context)

  For i=0 To #NUM_WINDOWS-1
    
    GLContext::SetContext(*context)
     
    ViewportUI::Blit(views(i)\viewport, *framebuffer)
    
  Next
  
  
Until WaitWindowEvent() = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 178
; FirstLine = 150
; Folding = -
; EnableXP