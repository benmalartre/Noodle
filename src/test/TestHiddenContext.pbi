; Test Hidden Context
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../layers/Bitmap.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile "../ui/Window.pbi"
UseModule OpenGL
UseModule OpenGLExt

UseJPEGImageDecoder()
UseJPEG2000ImageDecoder()

#DEFAULT_WIDTH    = 1024
#DEFAULT_HEIGHT   = 720
#CHANNEL_COUNT    = 4
#DATA_SIZE        = #DEFAULT_WIDTH * #DEFAULT_HEIGHT * #CHANNEL_COUNT
Global *datas     = AllocateMemory(#DATA_SIZE)
Global pbo1, pbo2, tex, index, nextIndex, pboMode
Global Dim pbos.i(2)


Structure Monitor_t
  *window.Window::Window_t
  *viewport.ViewportUI::ViewportUI_t
  *bitmap.LayerBitmap::LayerBitmap_t
  pbo.GLuint
EndStructure


#NUM_WINDOWS = 3
Global Dim views.Monitor_t(#NUM_WINDOWS)
Global *window.Window::Window_t = Window::New("MAIN WIndow",0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
Global *hidden_ctx = GLContext::New(1024,1024, #Null)
Global *viewport.ViewportUI::ViewportUI_t = ViewportUI::New(*window\main, "viewport", #Null, #Null)
Global image = LoadImage(#PB_Any, "../../textures/io.jpg")

Global *layer.LayerBitmap::LayerBitmap_t = LayerBitmap::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, *viewport\context)

LayerBitmap::Setup(*layer)
Global texture = *layer\tex

Debug "shared texture : "+Str(texture)

; Global 
For i=0 To #NUM_WINDOWS-1
  views(i)\window = Window::New("Child"+Str(i), Random(200), Random(200), #DEFAULT_WIDTH/2, #DEFAULT_HEIGHT/2, #PB_Window_Tool, WindowID(*window\ID))
  views(i)\viewport = ViewportUI::New(views(i)\window\main, "viewport", #Null, #Null)
  Debug " CHILD CONTEXT : "+Str(views(i)\viewport\context\ID)

  views(i)\bitmap  = LayerBitmap::New(views(i)\viewport\sizX, views(i)\viewport\sizY, views(i)\viewport\context, texture)
  LayerBitmap::Setup(views(i)\bitmap )
  
Next

Repeat

  GLContext::SetContext(*viewport\context)
  LayerBitmap::Draw(*layer, *viewport\context)
  ViewportUI::Blit(*viewport, *layer\framebuffer)
  GLContext::FlipBuffer(*viewport\context)
  
  For i=0 To #NUM_WINDOWS-1
    GLContext::SetContext(views(i)\viewport\context)
    LayerBitmap::Draw(views(i)\bitmap, views(i)\viewport\context)
    ViewportUI::Blit(views(i)\viewport, views(i)\bitmap\framebuffer)
    GLContext::FlipBuffer(views(i)\viewport\context)
  Next
  
  
Until WaitWindowEvent() = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 30
; EnableXP