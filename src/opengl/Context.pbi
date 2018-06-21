XIncludeFile "../libs/FTGL.pbi"

; ============================================================================
;  GLContext Object ( CGLContext)
; ============================================================================
DeclareModule GLContext
  UseModule OpenGL
  #MAX_GL_CONTEXT = 5
  Global counter = 0
  Global Dim shadernames.s(22)
  shadernames(0) = "selection"
  shadernames(1) = "simple"
  shadernames(2) = "wireframe"
  shadernames(3) = "polymesh"
  shadernames(4) = "cloud"
  shadernames(5) = "instances"
  shadernames(6) = "cubemap"
  shadernames(7) = "defered"
  shadernames(8) = "gbuffer"
  shadernames(9) = "gbufferic"
  shadernames(10) = "reflection"
  shadernames(11) = "ssao"
  shadernames(12) = "ssao_blur"
  shadernames(13) = "shadowmap"
  shadernames(14) = "shadowmapic"
  shadernames(15) = "shadowsimple"
  shadernames(16) = "shadowdefered"
  shadernames(17) = "shadowmapCSM"
  shadernames(18) = "shadowCSM"
  shadernames(19) = "shadowCSMdefered"
  shadernames(20) = "simple2D"
  shadernames(21) = "bitmap"

  Structure GLContext_t
    *window.GLFWwindow      ;main window holding gl context shared by all other gl windows
    *writer.FTGL::FTGL_Drawer
    width.d
    height.d
    useGLFW.b
    ID.i
    shader.GLuint
    
    Map *shaders.Program::Program_t()
  EndStructure
  
  Declare New(width.i, height.i, useGLFW.b=#False, *window.GLFW::GLFWwindow=#Null)
  Declare Setup(*Me.GLContext_t)
  Declare Delete(*Me.GLContext_t)
EndDeclareModule

; ----------------------------------------------------------------------------
;  Implementation
; ----------------------------------------------------------------------------
Module GLContext
  UseModule OpenGL
  UseModule OpenGLExt
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*ctx.GLContext_t)
    If Not *ctx : ProcedureReturn : EndIf
    ForEach *ctx\shaders()
      Program::Delete(*ctx\shaders())
    Next
    ClearStructure(*ctx,GLContext_t)
    FreeMemory(*ctx)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(width.i, height.i, useGLFW.b=#False, *window.GLFW::GLFWwindow=#Null)
    MessageRequester("NEW GL CONTEXT", "USE GLFW : "+Str(useGLFW))
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.GLContext_t = AllocateMemory(SizeOf(GLContext_t))
    InitializeStructure(*Me,GLContext_t)
    
    *Me\useGLFW = useGLFW
    *Me\width = width
    *Me\height = height
    *Me\ID = 0
    
    If useGLFW
  ;     glfwDebugVersion()
      If *window
        *Me\window = *window
        GLFW::glfwGetWindowSize(*Me\window,@*Me\width,@*Me\height)
      Else
        Protected *monitor.GLFW::GLFWmonitor  = GLFW::glfwGetPrimaryMonitor()
        Protected *mode.GLFW::GLFWvidmode  = GLFW::glfwGetVideoMode(*monitor)
        ;glfwWindowHint(#GLFW_OPENGL_PROFILE,#GLFW_OPENGL_COMPAT_PROFILE)
        GLFW::glfwWindowHint(GLFW::#GLFW_RED_BITS,*mode\RedBits)
        GLFW::glfwWindowHint(GLFW::#GLFW_BLUE_BITS,*mode\BlueBits)
        GLFW::glfwWindowHint(GLFW::#GLFW_GREEN_BITS,*mode\GreenBits)
        
  ;       glfwWindowHint(#GLFW_OPENGL_FORWARD_COMPAT,#GL_TRUE)
  ;       glfwWindowHint(#GLFW_OPENGL_PROFILE,#GLFW_OPENGL_CORE_PROFILE)
  ;       glfwWindowHint(#GLFW_CONTEXT_VERSION_MAJOR,3)
  ;       glfwWindowHint(#GLFW_CONTEXT_VERSION_MAJOR,3)
      Protected title.s = "GLFW - "
      ;glfwWindowHint(GLFW_SAMPLES, 4);
      If Not #USE_LEGACY_OPENGL
        GLFW::glfwWindowHint(GLFW::#GLFW_CONTEXT_VERSION_MAJOR, 3)
        GLFW::glfwWindowHint(GLFW::#GLFW_CONTEXT_VERSION_MINOR, 3)
        GLFW::glfwWindowHint(GLFW::#GLFW_OPENGL_FORWARD_COMPAT, #GL_TRUE)
        GLFW::glfwWindowHint(GLFW::#GLFW_OPENGL_PROFILE, GLFW::#GLFW_OPENGL_CORE_PROFILE)
        GLFW::glfwWindowHint(GLFW::#GLFW_STENCIL_BITS, 8)
        title + "CORE"
      Else
        title + "LEGACY"
      EndIf
      
        *Me\window = GLFW::glfwCreateWindow(*mode\Width,*mode\Height,"GLFW",*monitor,#Null)
  
        
        If Not *Me\window
          Delete(*Me)
          MessageRequester("Raafal", "Fail To Initialize OpenGL Context!!")
          ProcedureReturn #False
        EndIf
      
       ;Print out GLFW, OpenGL version And GLEW Version:
        Protected iOpenGLMajor.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_VERSION_MAJOR);
        Protected iOpenGLMinor.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_VERSION_MINOR);
        Protected iOpenGLRevision.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_REVISION)  ;
      
        Debug "Status: Using GLFW Version "+GLFW::glfwGetVersionString()
        Debug "Status: Using OpenGL Version: "+Str(iOpenGLMajor)+","+Str(iOpenGLMinor)+", Revision : "+Str(iOpenGLRevision)
      
        ; Connect Backward
        GLFW::glfwSetWindowUserPointer(*Me\window,*Me)
        GLFW::glfwMakeContextCurrent(*Me\window)
        GLFW::glfwGetWindowSize(*Me\window,@*Me\width,@*Me\height)
      EndIf
  
    Else
      *Me\window = #Null
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
  
  ;---------------------------------------------
  ;  Load Extensions and Build Shaders
  ;---------------------------------------------
  Procedure Setup(*Me.GLContext_t)
    GLLoadExtensions()

    ; Build Shaders
    Protected i
    Protected *shader.Program::Program_t
    For i=0 To ArraySize(shadernames())-1
      *shader = Program::NewFromName(shadernames(i))
      *Me\shaders(shadernames(i)) = *shader
     Debug i
   Next
   
    ; Build Font Writer
    GLCheckError("Before Creating FTGL")
    *Me\writer = FTGL::New()
    GLCheckError("After Creating FTGL")
    
  EndProcedure
  
  
EndModule




;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 72
; FirstLine = 67
; Folding = -
; EnableXP
; EnableUnicode