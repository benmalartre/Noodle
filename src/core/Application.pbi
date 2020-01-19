; ============================================================================
;   CORE MODULES
; ============================================================================
XIncludeFile "Globals.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Time.pbi"
XIncludeFile "Arguments.pbi"
XIncludeFile "Callback.pbi"
XIncludeFile "Signal.pbi"
XIncludeFile "Perlin.pbi"
XIncludeFile "Commands.pbi"
XIncludeFile "UIColor.pbi"
XIncludeFile "Pose.pbi"
XIncludeFile "Image.pbi"

; ============================================================================
;   OPENGL MODULES
; ============================================================================
XIncludeFile "../libs/OpenGL.pbi"
CompilerIf #USE_GLFW
  XIncludeFile "../libs/GLFW.pbi"
CompilerEndIf

XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/FTGL.pbi"

XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../opengl/Texture.pbi"
XIncludeFile "../opengl/ScreenQuad.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/CubeMap.pbi"

; ============================================================================
;   OBJECT MODULES
; ============================================================================
XIncludeFile "../objects/Location.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../objects/Drawer.pbi"
XIncludeFile "../objects/Locator.pbi"
XIncludeFile "../objects/Curve.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"
XIncludeFile "../objects/Light.pbi"
XIncludeFile "../objects/Scene.pbi"
XIncludeFile "../objects/Handle.pbi"
XIncludeFile "../objects/Selection.pbi"
XIncludeFile "../objects/Sampler.pbi"
XIncludeFile "../objects/Ray.pbi"
XIncludeFile "../objects/Poisson.pbi"
XIncludeFile "../objects/Triangle.pbi"
XIncludeFile "../objects/Octree.pbi"

; ============================================================================
;   LAYER MODULES
; ============================================================================
XIncludeFile "../layers/Layer.pbi"
XIncludeFile "../layers/Default.pbi"
XIncludeFile "../layers/Bitmap.pbi"
XIncludeFile "../layers/Selection.pbi"
XIncludeFile "../layers/GBuffer.pbi"
XIncludeFile "../layers/Defered.pbi"
XIncludeFile "../layers/ShadowMap.pbi"
XIncludeFile "../layers/ShadowSimple.pbi"
XIncludeFile "../layers/ShadowDefered.pbi"
XIncludeFile "../layers/CascadedShadowMap.pbi"
XIncludeFile "../layers/Toon.pbi"
XIncludeFile "../layers/SSAO.pbi"
XIncludeFile "../layers/Blur.pbi"
XIncludeFile "../layers/Strokes.pbi"

; ============================================================================
;   GRAPH MODULES
; ============================================================================
XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/CompoundPort.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../graph/Connexion.pbi"
XIncludeFile "../graph/Graph.pbi"
XIncludeFile "../graph/Tree.pbi"

; ============================================================================
;   CONTROL MODULES
; ============================================================================
XIncludeFile "../controls/Dummy.pbi"
XIncludeFile "../controls/Button.pbi"
XIncludeFile "../controls/Check.pbi"
XIncludeFile "../controls/Color.pbi"
XIncludeFile "../controls/Combo.pbi"
XIncludeFile "../controls/Divot.pbi"
XIncludeFile "../controls/Edit.pbi"
XIncludeFile "../controls/Label.pbi"
XIncludeFile "../controls/Group.pbi"
XIncludeFile "../controls/Controls.pbi"
XIncludeFile "../controls/Property.pbi"
XIncludeFile "../controls/Menu.pbi"
XIncludeFile "../controls/Head.pbi"
XIncludeFile "../controls/Knob.pbi"
XIncludeFile "../controls/Popup.pbi"
XIncludeFile "../controls/ColorWheel.pbi"

; ============================================================================
;   COMMAND MODULES
; ============================================================================
XIncludeFile "../commands/Scene.pbi"
XIncludeFile "../commands/Graph.pbi"

; ============================================================================
;   UI MODULES
; ============================================================================
XIncludeFile "../ui/Window.pbi"
XIncludeFile "../ui/View.pbi"
XIncludeFile "../ui/DummyUI.pbi"
XIncludeFile "../ui/LogUI.pbi"
XIncludeFile "../ui/TimelineUI.pbi"
XIncludeFile "../ui/ShaderUI.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
XIncludeFile "../ui/CanvasUI.pbi"
XIncludeFile "../ui/GraphUI.pbi"
XIncludeFile "../ui/PropertyUI.pbi"
XIncludeFile "../ui/ExplorerUI.pbi"
XIncludeFile "../ui/TopMenu.pbi"
XIncludeFile "../ui/ColorUI.pbi"

CompilerIf #USE_BULLET
  XIncludeFile "../libs/Bullet.pbi"
  XIncludeFile "../bullet/RigidBody.pbi"
  XIncludeFile "../bullet/World.pbi"
  XIncludeFile "../bullet/Constraint.pbi"
CompilerEndIf

CompilerIf #USE_ALEMBIC
  XIncludeFile "../libs/Booze.pbi"
  XIncludeFile "../objects/Animation.pbi"
CompilerEndIf

XIncludeFile "Saver.pbi"
XIncludeFile "Loader.pbi"

; ============================================================================
;  Application Module Declaration
; ============================================================================
DeclareModule Application
CompilerIf (#USE_GLFW = #True)
  UseModule GLFW
CompilerEndIf

  #DEFAULT_WIDTH = 1024
  #DEFAULT_HEIGHT = 720
  Structure Application_t
    name.s
    glfw.b
    *window.Window::Window_t
    *context.GLContext::GLContext_t
    *camera.Camera::Camera_t
    
    *layer.Layer::Layer_t
    *select.LayerSelection::LayerSelection_t
    List *layers.Layer::Layer_t()
    
    *handle.Handle::Handle_t
    width.i
    height.i
    idle.i
    tool.i
    down.b
    mouseX.d
    mouseY.d
    lmb_p.i
    mmb_p.i
    rmb_p.i
    
    fps.f
    framecount.i
    lasttime.l
    dirty.b
    dummy.i
  EndStructure
  
;   Enumeration 
;     #TOOL_SELECT = 0
;     #TOOL_CAMERA
;     #TOOL_PAN
;     #TOOL_DOLLY
;     #TOOL_ORBIT
;     #TOOL_ROLL
;     #TOOL_ZOOM
;     #TOOL_DRAW
;     #TOOL_PAINT
;     
;     #TOOL_SCALE
;     #TOOL_ROTATE
;     #TOOL_TRANSLATE
;     #TOOL_TRANSFORM
;     #TOOL_DIRECTED
;     
;     #TOOL_PREVIEW
;     
;     #TOOL_MAX
;   EndEnumeration
  
  Declare New(name.s,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  Declare Delete(*Me.Application_t)
  Declare Loop(*Me.Application_t,*callback)
  Declare Draw(*Me.Application_t, *layer.Layer::Layer_t, *camera.Camera::Camera_t)
  Declare AddLayer(*Me.Application_t, *layer.Layer::Layer_t)
  Declare AddWindow(*Me.Application_t, x.i, y.i, width.i, height.i)
  Declare AddShortcuts(*Me.Application_t)
  Declare RemoveShortcuts(*Me.Application_t)
  
CompilerIf (#USE_GLFW = #True)
  Declare RegisterCallbacks(*Me.Application_t)
  Declare Draw(*Me.Application_t, *layer.Layer::Layer_t)
  Declare OnKeyChanged(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
  Declare OnMouseMove(*window.GLFWwindow,x.d,y.d)
  Declare OnMouseButton(*window.GLFWwindow,button.i,action.i,modifier.i)
  Declare OnResizeWindow(*w.GLFWwindow,width.i,height.i)
  Declare OnPositionWindow(*w.GLFWwindow,x.i,y.i)
  Declare OnCursorEnter(*window.GLFWwindow,entered.i)
  Declare OnScroll(*window.GLFWwindow,x.d,y.d)
CompilerEndIf

  Declare.f GetFPS(*Me.Application_t)
  Prototype PFNCALLBACKFN(*Me, event.i)
  
  Global *running.Application::Application_t

EndDeclareModule

; ============================================================================
;  Application Module Implementation
; ============================================================================
Module Application
  UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf
  UseModule OpenGLExt
  
  ;-----------------------------------------------------------------------------
  ; Size Window Callback
  ;-----------------------------------------------------------------------------
  Procedure SizeWindowCallback()
    Window::OnEvent(*running\window,#PB_Event_SizeWindow)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Constructor
  ;-----------------------------------------------------------------------------
  Procedure New(name.s,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    Protected *Me.Application_t = AllocateMemory(SizeOf(Application_t))
    InitializeStructure(*Me,Application_t)
    *Me\name = name
    *running = *Me
    Protected w.i, h.i
    CompilerIf #USE_GLFW
      glfwInit()
      ;*Me\window = glfwCreateFullScreenWindow()
      *Me\window = glfwCreateWindowedWindow(width,height,"GLFW3.1")
      
      glfwMakeContextCurrent(*Me\window)
      glfwSetWindowUserPointer(*Me\window, *Me)  
      glfwGetWindowSize(*Me\window,@w,@h)
      *Me\width = w
      *Me\height = h
      *Me\context = GLContext::New(width,height,#True, *Me\window)
      GLContext::Setup(*Me\context)
      *Me\context\width = w
      *Me\context\height = h
      *Me\idle = #True
     
      RegisterCallbacks(*Me)
 
    CompilerElse
      *Me\window = Window::New(name,0,0,width,height,options)

      *Me\width = WindowWidth(*Me\window\ID,#PB_Window_InnerCoordinate)
      *Me\height = WindowHeight(*Me\window\ID,#PB_Window_InnerCoordinate)
      *Me\context = GLContext::New(#DEFAULT_WIDTH, #DEFAULT_HEIGHT, #Null)
      *Me\context\writer = FTGL::New()
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_C,Globals::#SHORTCUT_COPY)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_V,Globals::#SHORTCUT_PASTE)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_X,Globals::#SHORTCUT_CUT)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_Z,Globals::#SHORTCUT_UNDO)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_Y,Globals::#SHORTCUT_REDO)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Command|#PB_Shortcut_R,Globals::#SHORTCUT_RESET)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Escape,Globals::#SHORTCUT_QUIT)
      AddKeyboardShortcut(*Me\window\ID,#PB_Shortcut_Tab,Globals::#SHORTCUT_TAB)
    
      *Me\idle = #True
      
    CompilerEndIf  
    
    *Me\camera = Camera::New("Camera",Camera::#Camera_Perspective)
    *Me\handle = Handle::New()
    *Me\handle\camera = *Me\camera
    *Me\select = LayerSelection::New(width, height, *Me\context, *Me\camera)
    Handle::Setup(*Me\handle, *Me\context)
    
    ProcedureReturn *Me
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Delete
  ;-----------------------------------------------------------------------------
  Procedure Delete(*Me.Application_t)
    Protected i
    CompilerIf #USE_GLFW
      glfwDestroyWindow(*Me\window)

    CompilerElse
      Window::Delete(*Me\window)
    CompilerEndIf
    
    ClearStructure(*Me,Application_t)
    FreeMemory(*Me)
  EndProcedure
  
  Procedure AddWindow(*Me.Application_t, x.i, y.i, width.i, height.i)

    Define *window.Window::Window_t = AllocateMemory(SizeOf(Window::Window_t))
    InitializeStructure(*window, Window::Window_t)
    *window\main = OpenWindow(#PB_Any, x, y, width, height, "TOOL", #PB_Window_Tool, WindowID(*Me\window\ID))
    *window\main\width = width
    *window\main\height = height
    ProcedureReturn *window
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add Shortcuts
  ;-----------------------------------------------------------------------------
  Procedure AddShortcuts(*Me.Application_t)
    AddKeyboardShortcut(*Me\window\ID, #PB_Shortcut_T, Globals::#SHORTCUT_TRANSLATE)
    AddKeyboardShortcut(*Me\window\ID, #PB_Shortcut_R, Globals::#SHORTCUT_ROTATE)
    AddKeyboardShortcut(*Me\window\ID, #PB_Shortcut_S, Globals::#SHORTCUT_SCALE)
    AddKeyboardShortcut(*Me\window\ID, #PB_Shortcut_X, Globals::#SHORTCUT_TRANSFORM)
    AddKeyboardShortcut(*Me\window\ID, #PB_Shortcut_Space, Globals::#SHORTCUT_SELECT)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Remove Shortcuts
  ;-----------------------------------------------------------------------------
  Procedure RemoveShortcuts(*Me.Application_t)
    RemoveKeyboardShortcut(*Me\window\ID, #PB_Shortcut_T)
    RemoveKeyboardShortcut(*Me\window\ID, #PB_Shortcut_R)
    RemoveKeyboardShortcut(*Me\window\ID, #PB_Shortcut_S)
    RemoveKeyboardShortcut(*Me\window\ID, #PB_Shortcut_X)
    RemoveKeyboardShortcut(*Me\window\ID, #PB_Shortcut_Space)
  EndProcedure
  
  
  
CompilerIf #USE_GLFW
  ;-----------------------------------------------------------------------------
  ; Key Changed Callback (GLFW)
  ;-----------------------------------------------------------------------------
  Procedure OnKeyChanged(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
    Protected *Me.Application_t = glfwGetWindowUserPointer(*window)
  
    If action = #GLFW_PRESS
      Select key
        Case #GLFW_KEY_ESCAPE
          glfwSetWindowShouldClose(*window,#True)
          
        Case #GLFW_KEY_S
          *Me\idle =  #True
        
        Case #GLFW_KEY_LEFT
          
        Case #GLFW_KEY_RIGHT
          
        Case #GLFW_KEY_UP
          
        Case #GLFW_KEY_DOWN

      EndSelect
    ;   Else
    ;     *s\tool = #RAA_Tool_Select
    ;   EndIf
    ElseIf action = #GLFW_RELEASE
      Select key
        Case #GLFW_KEY_S
          ;*Me\idle = #False
        
        
        Case #GLFW_KEY_LEFT
  
        Case #GLFW_KEY_RIGHT
  
        Case #GLFW_KEY_UP
  
        Case #GLFW_KEY_DOWN
  
      EndSelect
         
    EndIf
    
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Mouse Move Callback (GLFW)
  ;-----------------------------------------------------------------------------
  Procedure OnMouseMove(*window.GLFWwindow,x.d,y.d)
    Protected *Me.Application_t = glfwGetWindowUserPointer(*window)
    
    If *Me\down
     Protected *c.Camera::Camera_t = *Me\camera
     
     Protected deltax.d = x-*Me\mouseX
     Protected deltay.d = y-*Me\mouseY
     Protected w.i,h.i
     glfwGetWindowSize(*window,@w,@h)
     If *Me\idle
       ; Camera Events
        Select *Me\idle
          Case Globals::#TOOL_PAN
            Camera::Pan(*c,deltax,deltay,w,h)
    
          Case Globals::#TOOL_DOLLY
            Camera::Dolly(*c,deltax,deltay,w,h)
              
          Case Globals::#TOOL_ORBIT
            Camera::Orbit(*c,deltax,deltay,w,h)
        EndSelect
      EndIf
    EndIf
      
   *Me\mouseX = x
   *Me\mouseY = y
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Position Window Callback (GLFW)
  ;-----------------------------------------------------------------------------
   Procedure OnPositionWindow(*w.GLFWwindow,x.i,y.i)

   EndProcedure
   
  ;-----------------------------------------------------------------------------
  ; Mouse Button Callback (GLFW)
  ;-----------------------------------------------------------------------------
  Procedure OnMouseButton(*window.GLFWwindow,button.i,action.i,modifier.i)
    Protected *Me.Application_t = glfwGetWindowUserPointer(*window)

    Select action
      Case #GLFW_PRESS
        Select button
          Case #GLFW_MOUSE_BUTTON_LEFT
            If modifier&#GLFW_MOD_ALT
              *Me\rmb_p = #True
            ElseIf modifier&#GLFW_MOD_CONTROL
              *Me\mmb_p = #True
            Else
              *Me\lmb_p = #True
            EndIf    
          
          Case #GLFW_MOUSE_BUTTON_MIDDLE
            *Me\mmb_p = #True

          Case #GLFW_MOUSE_BUTTON_RIGHT
            *Me\rmb_p = #True
            
          EndSelect
          *Me\down = #True
          *Me\idle = Globals::#TOOL_CAMERA
          glfwGetCursorPos(*window,@*Me\mouseX,@*Me\mouseY)
          If *Me\idle = Globals::#TOOL_CAMERA
            If *Me\lmb_p : *Me\idle = Globals::#Tool_Pan
            ElseIf *Me\mmb_p :*Me\idle = Globals::#Tool_Dolly
            ElseIf *Me\rmb_p : *Me\idle = Globals::#Tool_Orbit
            EndIf
            
;           ElseIf *Me\tool = #Tool_Translate Or *Me\tool = #Tool_Rotate Or *Me\tool = #Tool_Scale
;             If *Me\lmb_p : *s\handle\SetActiveAxis(#Handle_Active_X)
;             ElseIf *s\mmb_p : *s\handle\SetActiveAxis(#Handle_Active_Y)
;               ElseIf *s\rmb_p : *s\handle\SetActiveAxis(#Handle_Active_Z) : EndIf 
            
;           ElseIf *s\tool = #TOOL_DRAW
;   
;           ElseIf *s\tool = #Tool_Select
           
          EndIf
      
        Case #GLFW_RELEASE
  
  
          *Me\lmb_p = #False
          *Me\mmb_p = #False
          *Me\rmb_p = #False
          *Me\down = #False
          If *Me\idle = Globals::#Tool_Pan Or *Me\idle = Globals::#Tool_Dolly Or *Me\idle = Globals::#Tool_Orbit 
            *Me\idle = Globals::#Tool_Camera
          EndIf
    EndSelect
   
        
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Resize Window Callback (GLFW)
  ;-----------------------------------------------------------------------------
   Procedure OnResizeWindow(*w.GLFWwindow,width.i,height.i)
;     glfwMakeContextCurrent(*w)
;     glfwSetWindowSize(*w,width,height)
;     ;glfwSetWindowPos(*w,*s\x,*s\y)
;     Protected *s.CScreen_t = glfwGetWindowUserPointer(*w)
;     glScreen(0,0,width,height)
;     *s\width = width
;     *s\height = height
;     
;       Protected i
;     Protected *layer.CLayer
;     For i=0 To *s\layers\GetCount()-1
;       *layer = *s\layers\GetValue(i)
;   
;       If *layer And Not *layer\IsFixed()
;         *layer\Resize(width,height)
;       EndIf
;     Next i
  
   EndProcedure
   
    ;-----------------------------------------------------------------------------
    ; Cursor Scroll Callback (GLFW)
    ;-----------------------------------------------------------------------------
    Procedure OnScroll(*window.GLFWwindow,x.d,y.d)
      Protected *Me.Application_t = glfwGetWindowUserPointer(*window)
      Protected *c.Camera::Camera_t = *Me\camera
     
      If *c
        Protected scrollx.d,scrolly.d
        scrollx = x*100
        scrolly = y*100
        Protected w,i
        glfwGetWindowSize(*window,@w,@h)
        Camera::Dolly(*c,scrollx,scrolly,w,h)
      EndIf
      
    EndProcedure
    
    ;-----------------------------------------------------------------------------
    ; Cursor Enter Callback (GLFW)
    ;-----------------------------------------------------------------------------
    Procedure OnCursorEnter(*window.GLFWwindow,entered.i)
;       Protected *siewport.CScreen_t = glfwGetWindowUserPointer(*window)
;       If entered
;         Debug "Mouse Entered View port ID "+Str(*window)
;         *siewport\cursor\SetActiveTool(*siewport\tool)
;         OScreen_DrawCursor(*siewport) 
;       Else
;         Debug "Mouse Leaved View port ID "+Str(*window)
;         *siewport\cursor\SetActiveTool(0)
;         OScreen_DrawCursor(*siewport) 
;       EndIf
;       
    EndProcedure
 

  ;-----------------------------------------------------------------------------
  ; Register Callbacks (GLFW)
  ;-----------------------------------------------------------------------------
  Procedure RegisterCallbacks(*Me.Application_t)
    ;Register Callbacks
    glfwSetKeyCallback(*Me\window,@OnKeyChanged())
    glfwSetCursorPosCallback(*Me\window,@OnMouseMove())
    glfwSetMouseButtonCallback(*Me\window,@OnMouseButton())
    glfwSetWindowSizeCallback(*Me\window,@OnResizeWindow())
    glfwSetWindowPosCallback(*Me\window,@OnPositionWindow())
    glfwSetCursorEnterCallback(*Me\window,@OnCursorEnter())
    glfwSetScrollCallback(*Me\window,@OnScroll())
  EndProcedure
  
CompilerEndIf

  ;------------------------------------------------------------------
  ; Add Layer
  ;------------------------------------------------------------------
  Procedure AddLayer(*Me.Application_t, *layer.Layer::Layer_t)
    AddElement(*Me\layers())
    *Me\layers() = *layer
    *Me\layer = *layer
  EndProcedure

  ;-----------------------------------------------------------------------------
  ; Get FPS
  ;-----------------------------------------------------------------------------
  Procedure.f GetFPS(*Me.Application_t)

   *Me\framecount +1
    Protected current.l = Time::Get()*1000
    Protected elapsed.l = current - *Me\lasttime
    
    If elapsed > 1000
      *Me\fps = *Me\framecount;*1.0/(elapsed /1000)
      *Me\lasttime = current
      *Me\framecount = 0
    EndIf  
    ProcedureReturn *Me\fps
  EndProcedure
  

  ;-----------------------------------------------------------------------------
  ; Main Loop
  ;-----------------------------------------------------------------------------
  Procedure Loop(*Me.Application_t,*callback.PFNCALLBACKFN)
    Define event
    
    CompilerIf #USE_GLFW
      While Not glfwWindowShouldClose(*Me\window)
        ;glfwWaitEvents()
        glfwPollEvents()
        glfwMakeContextCurrent(*Me\window)
        *callback(*Me)
        glfwSwapBuffers(*Me\window)
       
      Wend
    CompilerElse
      Window::OnEvent(*Me\window, #PB_Event_SizeWindow)
      *callback(*Me, #PB_Event_SizeWindow)
      Repeat
        event = WaitWindowEvent(1)
        ; filter Windows events
        CompilerSelect #PB_Compiler_OS 
          CompilerCase #PB_OS_Windows
            If event = 512  Or event = 160:  Continue : EndIf
          CompilerCase #PB_OS_Linux
            If event = 24 : Continue : EndIf
        CompilerEndSelect
        
        Select event
          Case Globals::#EVENT_NEW_SCENE
            Scene::Setup(Scene::*current_scene, *Me\context)
            Window::OnEvent(*Me\window,Globals::#EVENT_NEW_SCENE)
            
          Case Globals::#EVENT_PARAMETER_CHANGED
            Scene::Update(Scene::*current_scene)
            *callback(*Me, Globals::#EVENT_PARAMETER_CHANGED)
            
          Case Globals::#EVENT_TOOL_CHANGED
            Select EventData()
              Case Globals::#TOOL_SCALE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_SCALE)
                *Me\tool = Globals::#TOOL_SCALE
              Case Globals::#TOOL_ROTATE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
                *Me\tool = Globals::#TOOL_ROTATE
              Case Globals::#TOOL_TRANSLATE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
                *Me\tool = Globals::#TOOL_TRANSLATE
              Case Globals::#TOOL_TRANSFORM
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSFORM)
                *Me\tool = Globals::#TOOL_TRANSFORM
            EndSelect
            
            
          Case Globals::#EVENT_SELECTION_CHANGED
;             If Scene::*current_scene\selection\selected()
;               Handle::SetTarget(*Me\handle, Scene::*current_scene\selection\selected()\obj)
;             EndIf
            Window::OnEvent(*Me\window,Globals::#EVENT_SELECTION_CHANGED)
            Scene::Update(Scene::*current_scene)
            *callback(*Me, Globals::#EVENT_SELECTION_CHANGED)
           
          Case Globals::#EVENT_HIERARCHY_CHANGED
            Scene::Setup(Scene::*current_scene, *Me\context)
            Window::OnEvent(*Me\window,Globals::#EVENT_HIERARCHY_CHANGED)
           
            *callback(*Me, Globals::#EVENT_HIERARCHY_CHANGED)
            
          Case Globals::#EVENT_TREE_CREATED
            Protected *graph = *Me\window\uis("Graph")
            Protected *tree = EventData()
            If *graph
              GraphUI::SetContent(*graph,*tree)
            EndIf   
            *callback(*Me, Globals::#EVENT_TREE_CREATED)
          Case #PB_Event_Menu
            Select EventMenu()
              Case Globals::#SHORTCUT_TRANSLATE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
                *Me\tool = Globals::#TOOL_TRANSLATE                
              Case Globals::#SHORTCUT_ROTATE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
                *Me\tool = Globals::#TOOL_ROTATE
              Case Globals::#SHORTCUT_SCALE
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_SCALE)
                *Me\tool = Globals::#TOOL_SCALE
              Case Globals::#SHORTCUT_TRANSFORM
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSFORM)
                *Me\tool = Globals::#TOOL_TRANSFORM
              Case Globals::#SHORTCUT_CAMERA
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_CAMERA)
                *Me\tool = Globals::#TOOL_CAMERA
              Default 
                *Me\tool = Globals::#TOOL_MAX
                If event : Window::OnEvent(*Me\window,event) : EndIf
            EndSelect
            *callback(*Me, event)
            
          Case #PB_Event_SizeWindow
            Window::OnEvent(*Me\window,event)
            *callback(*Me, event)
            
          Case #PB_Event_Gadget
            If event : Window::OnEvent(*Me\window,event) : EndIf
            *callback(*Me, event)
            
          Default
            If event : Window::OnEvent(*Me\window,event) : EndIf
            *callback(*Me, event)
        EndSelect
      Until event = #PB_Event_CloseWindow
    CompilerEndIf
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Draw
  ;------------------------------------------------------------------
  Procedure Draw(*Me.Application_t, *layer.Layer::Layer_t, *camera.Camera::Camera_t)
    Handle::Resize(*Me\handle,*camera)
    
    Dim shaderNames.s(3)
    shaderNames(0) = "wireframe"
    shaderNames(1) = "polymesh"
    shaderNames(2) = "normal"
    Define i
    Define *pgm.Program::Program_t
    For i=0 To 2
      *pgm = *Me\context\shaders(shaderNames(i))
      glUseProgram(*pgm\pgm)
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE, Matrix4::IDENTITY())
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE, *camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE, *camera\projection)
    Next
    
    Protected ilayer.Layer::ILayer = *layer
    ilayer\Draw(*Me\context)
    If *Me\tool
      Protected *wireframe.Program::Program_t = *Me\context\shaders("wireframe")
      glUseProgram(*wireframe\pgm)

      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,Matrix4::IDENTITY())
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE, *camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE, *camera\projection)
      
      Handle::Draw( *Me\handle,*Me\context) 
    EndIf
    
  EndProcedure

EndModule
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 716
; FirstLine = 703
; Folding = ------
; EnableXP
; SubSystem = OpenGL
; EnableUnicode