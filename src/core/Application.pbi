XIncludeFile "Globals.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "Math.pbi"
XIncludeFile "Time.pbi"
XIncludeFile "Slot.pbi"
XIncludeFile "Perlin.pbi"
XIncludeFile "Commands.pbi"
XIncludeFile "UIColor.pbi"
XIncludeFile "Pose.pbi"
XIncludeFile "Image.pbi"



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

XIncludeFile "../objects/Location.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../objects/Drawer.pbi"
XIncludeFile "../objects/Null.pbi"
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

XIncludeFile "../graph/Types.pbi"
XIncludeFile "../graph/Port.pbi"
XIncludeFile "../graph/CompoundPort.pbi"
XIncludeFile "../graph/Node.pbi"
XIncludeFile "../graph/Compound.pbi"
XIncludeFile "../graph/Nodes.pbi"
XIncludeFile "../graph/Connexion.pbi"
XIncludeFile "../graph/Graph.pbi"
XIncludeFile "../graph/Tree.pbi"

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
; XIncludeFile "../controls/PopupMenu.pbi"
XIncludeFile "../controls/ColorWheel.pbi"

XIncludeFile "../commands/Scene.pbi"
XIncludeFile "../commands/Graph.pbi"

XIncludeFile "../ui/View.pbi"
XIncludeFile "../ui/DummyUI.pbi"
XIncludeFile "../ui/LogUI.pbi"
XIncludeFile "../ui/TimelineUI.pbi"
XIncludeFile "../ui/ShaderUI.pbi"
XIncludeFile "../ui/ViewportUI.pbi"
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
  

  Structure Application_t
    name.s
    glfw.b
    *window.GLFWwindow
    *manager.ViewManager::ViewManager_t
    *context.GLContext::GLContext_t
    *camera.Camera::Camera_t
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
  EndStructure
  
  Enumeration 
    #TOOL_SELECT = 0
    #TOOL_CAMERA
    #TOOL_PAN
    #TOOL_DOLLY
    #TOOL_ORBIT
    #TOOL_ROLL
    #TOOL_ZOOM
    #TOOL_DRAW
    #TOOL_PAINT
    
    #TOOL_SCALE
    #TOOL_ROTATE
    #TOOL_TRANSLATE
    #TOOL_TRANSFORM
    #TOOL_DIRECTED
    
    #TOOL_PREVIEW
    
    #TOOL_MAX
  EndEnumeration
  
  Declare New(name.s,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  Declare Delete(*app.Application_t)
  Declare Loop(*app.Application_t,*callback)
  
CompilerIf (#USE_GLFW = #True)
  Declare RegisterCallbacks(*app.Application_t)
  Declare OnKeyChanged(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
  Declare OnMouseMove(*window.GLFWwindow,x.d,y.d)
  Declare OnMouseButton(*window.GLFWwindow,button.i,action.i,modifier.i)
  Declare OnResizeWindow(*w.GLFWwindow,width.i,height.i)
  Declare OnPositionWindow(*w.GLFWwindow,x.i,y.i)
  Declare OnCursorEnter(*window.GLFWwindow,entered.i)
  Declare OnScroll(*window.GLFWwindow,x.d,y.d)
CompilerEndIf

  Declare.f GetFPS(*app.Application_t)
  Prototype PFNDRAWFN(*app)
  
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
      ViewManager::OnEvent(*running\manager,#PB_Event_SizeWindow)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Constructor
  ;-----------------------------------------------------------------------------
  Procedure New(name.s,width.i,height.i,options = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    Protected *app.Application_t = AllocateMemory(SizeOf(Application_t))
    InitializeStructure(*app,Application_t)
    *app\name = name
    *running = *app
    Protected w.i, h.i
    CompilerIf #USE_GLFW
      glfwInit()
      ;*app\window = glfwCreateFullScreenWindow()
      *app\window = glfwCreateWindowedWindow(width,height,"GLFW3.1")
      
      glfwMakeContextCurrent(*app\window)
      glfwSetWindowUserPointer(*app\window, *app)  
      glfwGetWindowSize(*app\window,@w,@h)
      *app\width = w
      *app\height = h
      *app\context = GLContext::New(width,height,#True, *app\window)
      GLContext::Setup(*app\context)
      *app\context\width = w
      *app\context\height = h
      *app\idle = #True
     
      RegisterCallbacks(*app)
 
    CompilerElse
      *app\manager = ViewManager::New(name,0,0,width,height,options)
      *app\window = *app\manager\window

      *app\width = WindowWidth(*app\manager\window,#PB_Window_InnerCoordinate)
      *app\height = WindowHeight(*app\manager\window,#PB_Window_InnerCoordinate)
      
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_C,Globals::#SHORTCUT_COPY)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_V,Globals::#SHORTCUT_PASTE)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_X,Globals::#SHORTCUT_CUT)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_Z,Globals::#SHORTCUT_UNDO)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_Y,Globals::#SHORTCUT_REDO)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Command|#PB_Shortcut_R,Globals::#SHORTCUT_RESET)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Escape,Globals::#SHORTCUT_QUIT)
      AddKeyboardShortcut(*app\manager\window,#PB_Shortcut_Tab,Globals::#SHORTCUT_TAB)
    
      *app\idle = #True
      
    CompilerEndIf  
    
    *app\camera = Camera::New("Camera",Camera::#Camera_Perspective)
    ProcedureReturn *app
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Delete
  ;-----------------------------------------------------------------------------
  Procedure Delete(*app.Application_t)
    Protected i
    CompilerIf #USE_GLFW
      glfwDestroyWindow(*app\window)

    CompilerElse
      ViewManager::Delete(*app\manager)
    CompilerEndIf
    
    ClearStructure(*app,Application_t)
    FreeMemory(*app)
  EndProcedure
  
CompilerIf #USE_GLFW
  ;-----------------------------------------------------------------------------
  ; Key Changed Callback (GLFW)
  ;-----------------------------------------------------------------------------
  Procedure OnKeyChanged(*window.GLFWwindow,key.i,scancode.i,action.i,modifiers.i)
    Protected *app.Application_t = glfwGetWindowUserPointer(*window)
  
    If action = #GLFW_PRESS
      Select key
        Case #GLFW_KEY_ESCAPE
          glfwSetWindowShouldClose(*window,#True)
          
        Case #GLFW_KEY_S
          *app\idle =  #True
        
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
          ;*app\idle = #False
        
        
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
    Protected *app.Application_t = glfwGetWindowUserPointer(*window)
    
    If *app\down
     Protected *c.Camera::Camera_t = *app\camera
     
     Protected deltax.d = x-*app\mouseX
     Protected deltay.d = y-*app\mouseY
     Protected w.i,h.i
     glfwGetWindowSize(*window,@w,@h)
     If *app\idle
       ; Camera Events
        Select *app\idle
          Case #TOOL_PAN
            Camera::Pan(*c,deltax,deltay,w,h)
    
          Case #TOOL_DOLLY
            Camera::Dolly(*c,deltax,deltay,w,h)
              
          Case #TOOL_ORBIT
            Camera::Orbit(*c,deltax,deltay,w,h)
        EndSelect
      EndIf
    EndIf
      
   *app\mouseX = x
   *app\mouseY = y
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
    Protected *app.Application_t = glfwGetWindowUserPointer(*window)

    Select action
      Case #GLFW_PRESS
        Select button
          Case #GLFW_MOUSE_BUTTON_LEFT
            If modifier&#GLFW_MOD_ALT
              *app\rmb_p = #True
            ElseIf modifier&#GLFW_MOD_CONTROL
              *app\mmb_p = #True
            Else
              *app\lmb_p = #True
            EndIf    
          
          Case #GLFW_MOUSE_BUTTON_MIDDLE
            *app\mmb_p = #True

          Case #GLFW_MOUSE_BUTTON_RIGHT
            *app\rmb_p = #True
            
          EndSelect
          *app\down = #True
          *app\idle = #TOOL_CAMERA
          glfwGetCursorPos(*window,@*app\mouseX,@*app\mouseY)
          If *app\idle = #TOOL_CAMERA
            If *app\lmb_p : *app\idle = #Tool_Pan
            ElseIf *app\mmb_p :*app\idle = #Tool_Dolly
            ElseIf *app\rmb_p : *app\idle = #Tool_Orbit
            EndIf
            
;           ElseIf *app\tool = #Tool_Translate Or *app\tool = #Tool_Rotate Or *app\tool = #Tool_Scale
;             If *app\lmb_p : *s\handle\SetActiveAxis(#Handle_Active_X)
;             ElseIf *s\mmb_p : *s\handle\SetActiveAxis(#Handle_Active_Y)
;               ElseIf *s\rmb_p : *s\handle\SetActiveAxis(#Handle_Active_Z) : EndIf 
            
;           ElseIf *s\tool = #TOOL_DRAW
;   
;           ElseIf *s\tool = #Tool_Select
           
          EndIf
      
        Case #GLFW_RELEASE
  
  
          *app\lmb_p = #False
          *app\mmb_p = #False
          *app\rmb_p = #False
          *app\down = #False
          If *app\idle = #Tool_Pan Or *app\idle = #Tool_Dolly Or *app\idle = #Tool_Orbit 
            *app\idle = #Tool_Camera
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
      Protected *app.Application_t = glfwGetWindowUserPointer(*window)
      Protected *c.Camera::Camera_t = *app\camera
     
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

  ;-----------------------------------------------------------------------------
  ; Get FPS
  ;-----------------------------------------------------------------------------
  Procedure.f GetFPS(*app.Application_t)

   *app\framecount +1
    Protected current.l = Time::Get()*1000
    Protected elapsed.l = current - *app\lasttime
    
    If elapsed > 1000
      *app\fps = *app\framecount;*1.0/(elapsed /1000)
      *app\lasttime = current
      *app\framecount = 0
    EndIf  
    ProcedureReturn *app\fps
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Echo Event Type (PureBasic)
  ;-----------------------------------------------------------------------------
  Procedure EchoEventType(event)
    Select event
      Case #PB_Event_Menu
        Debug "Event Menu"
      Case #PB_Event_Gadget
        Debug "Event Gadget"
      Case #PB_Event_SysTray
        Debug "Event SysTray"
      Case #PB_Event_Timer
        Debug "Event Timer"
      Case #PB_Event_CloseWindow
        Debug "Event Close Window"
      Case #PB_Event_Repaint
        Debug "Tout ou partie du contenu de la fenêtre a été détruit et doit être reconstitué "
      Case #PB_Event_SizeWindow
        Debug "La fenêtre a été redimensionnée " 
      Case #PB_Event_MoveWindow
        Debug "La fenêtre a été déplacée"
      Case #PB_Event_MinimizeWindow
        Debug "La fenêtre a été minimisée"
      Case #PB_Event_MaximizeWindow
        Debug "La fenêtre a été maximisée"
      Case #PB_Event_RestoreWindow 
        Debug "La fenêtre a été restaurée à sa taille normale"
      Case #PB_Event_ActivateWindow 
        Debug "La fenêtre a été activée (gain du focus)"
      Case #PB_Event_DeactivateWindow
        Debug "La fenêtre a été désactivée (perte du focus)"
      Case #PB_Event_LeftDoubleClick 
        Debug "Un double clic gauche de la souris s'est produit sur la fenêtre"
      Case #PB_Event_LeftClick  
        Debug "Un clic gauche de la souris s'est produit sur la fenêtre"
      Case #PB_Event_RightClick 
        Debug "Un clic droit de la souris s'est produit sur la fenêtre. Cela peut être utile pour afficher un menu contextuel"
      Case #PB_Event_WindowDrop   
        Debug "Une opération Glisser & Déposer s'est terminée sur une fenêtre (Voir remarque ci-dessous)"
      Case #PB_Event_GadgetDrop 
        Debug "Une opération Glisser & Déposer s'est terminée sur un gadget (Voir remarque ci-dessous)"
      Default 
        Debug "UNSUPPORTED EVENT"
  EndSelect
  
EndProcedure


  
  ;-----------------------------------------------------------------------------
  ; Main Loop
  ;-----------------------------------------------------------------------------
  Procedure Loop(*app.Application_t,*callback.PFNDRAWFN)
    Define event
    
    CompilerIf #USE_GLFW
      While Not glfwWindowShouldClose(*app\window)
        ;glfwWaitEvents()
        glfwPollEvents()
        glfwMakeContextCurrent(*app\window)
        *callback(*app)
        glfwSwapBuffers(*app\window)
       
      Wend
    CompilerElse
      ViewManager::OnEvent(*app\manager, #PB_Event_SizeWindow)
      *callback(*app)
      Repeat
        event = WaitWindowEvent();(1000/60)
        ; filter Windows events
        CompilerSelect #PB_Compiler_OS 
          CompilerCase #PB_OS_Windows
            If event = 512  Or event = 160:  Continue : EndIf
          CompilerCase #PB_OS_Linux
            If event = 24 : Continue : EndIf
        CompilerEndSelect
        
        Select event
          Case Globals::#EVENT_PARAMETER_CHANGED
            Scene::Update(Scene::*current_scene)
            *callback(*app)
          Case Globals::#EVENT_TREE_CREATED
            Protected *graph = ViewManager::*view_manager\uis("Graph")
            Protected *tree = EventData()
            If *graph
              GraphUI::SetContent(*graph,*tree)
            EndIf   
            *callback(*app)
          Case #PB_Event_Menu
            Select EventMenu()
              Case Globals::#SHORTCUT_TRANSLATE
                *app\tool = Globals::#TOOL_TRANSLATE
              Case Globals::#SHORTCUT_ROTATE
                *app\tool = Globals::#TOOL_ROTATE
              Case Globals::#SHORTCUT_SCALE
                *app\tool = Globals::#TOOL_SCALE
              Case Globals::#SHORTCUT_CAMERA
                *app\tool = Globals::#TOOL_CAMERA
              Default 
                *app\tool = Globals::#TOOL_MAX
                If event : ViewManager::OnEvent(*app\manager,event) : EndIf
            EndSelect
            *callback(*app)
            
          Case #PB_Event_SizeWindow
            ViewManager::OnEvent(*app\manager,event)
            *callback(*app)
            
          Case #PB_Event_Gadget
            If event : ViewManager::OnEvent(*app\manager,event) : EndIf
            *callback(*app)
            
          Default
            If event : ViewManager::OnEvent(*app\manager,event) : EndIf
            *callback(*app)
        EndSelect
        
        
        
      Until event = #PB_Event_CloseWindow
    CompilerEndIf
  EndProcedure

EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 586
; FirstLine = 557
; Folding = -----
; EnableXP
; SubSystem = OpenGL
; EnableUnicode