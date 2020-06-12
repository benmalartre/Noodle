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
XIncludeFile "../layers/Default.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile "../ui/LogUI.pbi"
XIncludeFile "../ui/Window.pbi"

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
  *window.Window::Window_t
  *camera.Camera::Camera_t
  *viewport.ViewportUI::ViewportUI_t
EndStructure

Time::Init()
Log::Init()

#NUM_WINDOWS = 3
Global Dim children.Monitor_t(#NUM_WINDOWS)
Global *window.Window::Window_t = Window::New("Share GL Context",0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
Global *context.GLContext::GLContext_t = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #Null)
Global *layer.LayerDefault::LayerDefault_t
Global *framebuffer.Framebuffer::Framebuffer_t
Global *handle.Handle::Handle_t = Handle::New()

Global *bunny.Polymesh::Polymesh_t
Global *log.LogUI::LogUI_t = LogUI::New(*window\main)
; Global 
For i=0 To #NUM_WINDOWS-1
  
  children(i)\window = Window::TearOff(*window, 0, 0, #DEFAULT_WIDTH * 0.5,#DEFAULT_HEIGHT * 0.5)
  children(i)\camera = Camera::New("Camera"+Str(i),Camera::#Camera_Perspective)
  children(i)\viewport = ViewportUI::New(children(i)\window\main, "VIEWPORT"+Str(i), children(i)\camera, *handle)
  Vector3::RandomizeInPlace(children(i)\camera\pos, 12)
  Camera::LookAt(children(i)\camera)
  Window::OnEvent(children(i)\window, #PB_Event_SizeWindow)
  
Next

GLContext::SetContext(*context)

*layer = LayerDefault::New(#DEFAULT_WIDTH,#DEFAULT_HEIGHT, *context, children(0)\camera)

; create framebuffer
*framebuffer = *layer\datas\buffer

*bunny = Polymesh::New("Bunny", Shape::#SHAPE_BUNNY)
Scene::*current_scene = Scene::New("CurrentScene")
Scene::AddChild(Scene::*current_scene, *bunny)
Scene::Setup(Scene::*current_scene, *context)

Define event
Define *active.Monitor_t
Repeat

  event = WaitWindowEvent()
  If EventType() = #PB_EventType_LeftButtonDown
    down = #True
  ElseIf EventType() = #PB_EventType_LeftButtonUp
    down = #False
  EndIf
  
  If Not down
    If EventWindow() = *window\ID
      *active = #Null
      Window::OnEvent(*active, event)
    Else
      For i=0 To #NUM_WINDOWS - 1
        If EventWindow() = children(i)\window\ID
          *active = children(i)
          Window::OnEvent(*active\window, event)
          GLContext::SetContext(*context)
          *layer\pov = *active\camera
          LayerDefault::Draw(*layer, *active\viewport\context)
          ViewportUI::Blit(*active\viewport, *framebuffer)
           
        EndIf
      Next
    EndIf
    
  Else
    If *active 
      Window::OnEvent(*active\window, event) 
      GLContext::SetContext(*context)
      *layer\pov = *active\camera
      LayerDefault::Draw(*layer, *active\viewport\context)
      ViewportUI::Blit(*active\viewport, *framebuffer)
    EndIf
    
  EndIf
 

  
  
Until event = #PB_Event_CloseWindow



; Define gadget = OpenGLGadget(#PB_Any, 0,0,#DEFAULT_WIDTH,#DEFAULT_HEIGHT)
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 103
; FirstLine = 54
; EnableXP