XIncludeFile "../libs/FTGL.pbi"

; ============================================================================
;  GLContext Object ( CGLContext)
; ============================================================================
DeclareModule GLContext
  UseModule OpenGL
  #MAX_GL_CONTEXT = 5
  Global counter = 0
  Global Dim shadernames.s(24)
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
  shadernames(22) = "curve"
  shadernames(23) = "drawer"

  Structure GLContext_t
    *window.GLFWwindow      ;main window holding gl context shared by all other gl windows
    *writer.FTGL::FTGL_Drawer
    width.d
    height.d
    useGLFW.b
    ID.i
    focus.b
    shader.GLuint
    
    Map *shaders.Program::Program_t()
  EndStructure
  
  Declare New(width.i, height.i, useGLFW.b=#False, *window=#Null)
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
  Procedure.i New(width.i, height.i, useGLFW.b=#False, *window=#Null)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.GLContext_t = AllocateMemory(SizeOf(GLContext_t))
    InitializeStructure(*Me,GLContext_t)
    
    *Me\useGLFW = useGLFW
    *Me\width = width
    *Me\height = height
    *Me\ID = 0
    *Me\writer = #Null
    
    CompilerIf (#USE_GLFW = #True)
      If useGLFW
        If *window
          *Me\window = *window
          GLFW::glfwGetWindowSize(*Me\window,@*Me\width,@*Me\height)
        Else
          Protected *monitor.GLFW::GLFWmonitor  = GLFW::glfwGetPrimaryMonitor()
          Protected *mode.GLFW::GLFWvidmode  = GLFW::glfwGetVideoMode(*monitor)
          
          GLFW::glfwWindowHint(GLFW::#GLFW_RED_BITS,*mode\RedBits)
          GLFW::glfwWindowHint(GLFW::#GLFW_BLUE_BITS,*mode\BlueBits)
          GLFW::glfwWindowHint(GLFW::#GLFW_GREEN_BITS,*mode\GreenBits)
      
          Protected title.s = "GLFW - "
  
          If Not #USE_LEGACY_OPENGL
            GLFW::glfwWindowHint(GLFW::#GLFW_CONTEXT_VERSION_MAJOR, 3)
            GLFW::glfwWindowHint(GLFW::#GLFW_CONTEXT_VERSION_MINOR, 3)
            GLFW::glfwWindowHint(GLFW::#GLFW_OPENGL_FORWARD_COMPAT, #GL_TRUE)
            GLFW::glfwWindowHint(GLFW::#GLFW_OPENGL_PROFILE, GLFW::#GLFW_OPENGL_CORE_PROFILE)
            GLFW::glfwWindowHint(GLFW::#GLFW_STENCIL_BITS, 8)
            GLFW::glfwWindowHint(GLFW::#GLFW_SAMPLES, 4)
            title + "CORE"
          Else
            title + "LEGACY"
          EndIf
        
          *Me\window = GLFW::glfwCreateWindow(*mode\Width,*mode\Height,"GLFW",*monitor,#Null)
    
          
          If Not *Me\window
            Delete(*Me)
            MessageRequester("Noodle", "Fail To Initialize GLFW OpenGL Context!!")
            ProcedureReturn #False
          EndIf
        
          ; Connect Backward
          GLFW::glfwSetWindowUserPointer(*Me\window,*Me)
          GLFW::glfwMakeContextCurrent(*Me\window)
          GLFW::glfwGetWindowSize(*Me\window,@*Me\width,@*Me\height)
        EndIf
    
      Else
        *Me\window = #Null
      EndIf
    CompilerEndIf
    
    
    ProcedureReturn *Me
  EndProcedure
  
  ;---------------------------------------------
  ;  Get OpenGL Version
  ;---------------------------------------------
  Procedure GetOpenGLVersion(*Me.GLContext_t)
    CompilerIf (#USE_GLFW = #True)
      If *Me\useGLFW
        ;Print out OpenGL version:
        Protected iOpenGLMajor.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_VERSION_MAJOR);
        Protected iOpenGLMinor.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_VERSION_MINOR);
        Protected iOpenGLRevision.i = GLFW::glfwGetWindowAttrib(*Me\window, GLFW::#GLFW_CONTEXT_REVISION)  ;
        
        Debug "Status: Using GLFW Version "+GLFW::glfwGetVersionString()
        Debug "Status: Using OpenGL Version: "+Str(iOpenGLMajor)+","+Str(iOpenGLMinor)+", Revision : "+Str(iOpenGLRevision)
      Else
        ; TO BE IMPLEMENTED
      EndIf
    CompilerEndIf
    
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
    Next
    
    ; Build Font Writer
    *Me\writer = FTGL::New()

  EndProcedure
  
  
EndModule




;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 161
; FirstLine = 151
; Folding = --
; EnableXP
; EnableUnicode