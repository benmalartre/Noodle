XIncludeFile "Types.pbi"
XIncludeFile "Framebuffer.pbi"
XIncludeFile "../libs/FTGL.pbi"

; ============================================================================
;  GLContext Module Implementation
; ============================================================================
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
    FreeStructure(*ctx)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New(width.i, height.i, *context=#Null)
    Protected *Me.GLContext_t = AllocateStructure(GLContext_t)
    
    *Me\useGLFW = #USE_GLFW
    *Me\width = width
    *Me\height = height
    *Me\ID = 0
    *Me\writer = #Null
    *Me\share = #False
    
    CompilerIf (#USE_GLFW = #True)
      If *context
        *Me\window = *context
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
        *Me\share = #True
        
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
    CompilerElse
      
      ; =======================================================================
      ;   MACOS
      ; =======================================================================
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS 
        CompilerIf Not #USE_LEGACY_OPENGL
          ; Allocate Pixel Format Object
          Define pfo.NSOpenGLPixelFormat = CocoaMessage( 0, 0, "NSOpenGLPixelFormat alloc" )
          ; Set Pixel Format Attributes
          Define pfa.NSOpenGLPixelFormatAttribute
          With pfa
            \v[0] = #NSOpenGLPFAColorSize          
            \v[1] = 24
            \v[2] = #NSOpenGLPFAAlphaSize          
            \v[3] =  8
            \v[4] = #NSOpenGLPFAOpenGLProfile      
            \v[5] = #NSOpenGLProfileVersion3_2Core
            \v[6] = #NSOpenGLPFADoubleBuffer
            \v[7] = #Null
          EndWith

          ; Choose Pixel Format
          CocoaMessage( 0, pfo, "initWithAttributes:", @pfa )
          ; Allocate OpenGL Context
          Define ctx.NSOpenGLContext = CocoaMessage( 0, 0, "NSOpenGLContext alloc" )
          ; Create OpenGL Context
          If *context
            CocoaMessage( 0, ctx, "initWithFormat:", pfo, "shareContext:", *contetx\ID )
          Else
            CocoaMessage( 0, ctx, "initWithFormat:", pfo, "shareContext:", #Null )
          EndIf
          
          ; Set Current Context
          CocoaMessage( 0, ctx, "makeCurrentContext" )
          ; Swap Buffers
          CocoaMessage( 0, ctx, "flushBuffer" )

          *Me\ID = ctx
          
        CompilerElse
          *Me\ID = OpenGLGadget(#PB_Any,0,0,width,height, #PB_OpenGL_Keyboard)
          SetGadgetAttribute(*Me\ID, #PB_OpenGL_SetContext, #True)
        CompilerEndIf
        
        ; load extensions and setup shaders
        If Not *context
          *SHARED_CTXT = *Me
          Setup(*Me)
        Else
          Copy(*Me, *context)
        EndIf
        
      ; =======================================================================
      ;   WINDOWS
      ; =======================================================================
      CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
        *Me\ID = OpenGLGadget(#PB_Any,0,0,width,height, #PB_OpenGL_Keyboard)
        SetGadgetAttribute(*Me\ID, #PB_OpenGL_SetContext, #True)
       
        If Not *context
          *Me\share = #True
          *SHARED_CTXT = *Me
          ; load extensions and setup shaders
          Setup(*Me)
        Else
          ; share context
          SetGadgetAttribute(*SHARED_CTXT\ID, #PB_OpenGL_SetContext, #True)
          Define hglrc1 = wglGetCurrentContext_()
          SetGadgetAttribute(*Me\ID, #PB_OpenGL_SetContext, #True)
          Define hglrc2 = wglGetCurrentContext_()
          wglShareLists_(hglrc1, hglrc2)
          Copy(*Me, *SHARED_CTXT)
        EndIf
      
      ; =======================================================================
      ;   LINUX
      ; =======================================================================
      CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
        *Me\ID = OpenGLGadget(#PB_Any,0,0,width,height, #PB_OpenGL_Keyboard)
        SetGadgetAttribute(*Me\ID,#PB_OpenGL_SetContext,#True)
        
        ; load extensions and setup shaders
        If Not *context
          *SHARED_CTXT = *Me
          Setup(*Me)
        Else
          ; copy context
          Copy(*Me, *context)
        EndIf
        
      CompilerEndIf
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
      EndIf
    CompilerEndIf
    
    Debug "OpenGL Vendor: "    +#TAB$+#TAB$+   OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_VENDOR ) )
    Debug "OpenGL Renderer: "  +#TAB$+         OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_RENDERER ))
    Debug "OpenGL Version: "   +#TAB$+         OpenGL::GLGETSTRINGOUTPUT(OpenGL::glGetString( #GL_VERSION ) )
  EndProcedure
  
  ;---------------------------------------------
  ;  Get Supported Line Width
  ;---------------------------------------------
  Procedure GetSupportedLineWidth(*Me.GLCOntext_t)
    Dim lineWidth.l(2)
    glGetIntegerv(#GL_ALIASED_LINE_WIDTH_RANGE, @lineWidth(0))
    GL_LINE_WIDTH_MIN = lineWidth(0)
    GL_LINE_WIDTH_MAX = lineWidth(1)
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
  
  ;---------------------------------------------
  ;  Copy Shaders
  ;---------------------------------------------
  Procedure Copy(*Me.GLContext_t, *shared.GLContext_t)
    CopyMap(*shared\shaders(), *Me\shaders())
    ; Build Font Writer
    *Me\writer = *shared\writer
  EndProcedure
  
  ;---------------------------------------------
  ;  Set Current Context
  ;---------------------------------------------
  Procedure SetContext(*Me.GLContext_t)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      CocoaMessage( 0, *Me\ID, "makeCurrentContext" )
    CompilerElse
      SetGadgetAttribute(*Me\ID, #PB_OpenGL_SetContext, #True)
    CompilerEndIf
  EndProcedure
  
  ;---------------------------------------------
  ;  Add Layer
  ;---------------------------------------------
  Procedure AddFramebuffer(*Me.GLContext_t, *framebuffer.Framebuffer::Framebuffer_t)
    AddElement(*Me\framebuffers())
    *Me\framebuffers() = *framebuffer
  EndProcedure
  
  ;---------------------------------------------
  ;  Backing scale factor
  ;---------------------------------------------
  Procedure.f BackingScaleFactor()
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      CocoaMessage(@bsf.CGFloat, CocoaMessage(0, 0, "NSScreen mainScreen"), "backingScaleFactor")
      ProcedureReturn bsf
    CompilerElse
      ProcedureReturn 1.0
    CompilerEndIf
  EndProcedure
  
  ;---------------------------------------------
  ;  Resize Context
  ;---------------------------------------------
  Procedure Resize(*Me.GLContext_t, width.i, height.i)
    Define backingScale.f = BackingScaleFactor()
    *Me\width = width * backingScale
    *Me\height = height * backingScale
    glBindFramebuffer(#GL_FRAMEBUFFER, 0)
    glViewport(0,0, *Me\width, *Me\height)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      CocoaMessage(0,*Me\ID, "update")
    CompilerEndIf
    ForEach *me\framebuffers()
      Framebuffer::Resize(*me\framebuffers(), width, height)
    Next  
  EndProcedure
  
  ;---------------------------------------------
  ;  Flip Buffers
  ;---------------------------------------------
  Procedure FlipBuffer(*Me.GLContext_t)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      CocoaMessage( 0, *Me\ID, "flushBuffer" )
    CompilerElse
      SetGadgetAttribute(*Me\ID, #PB_OpenGL_FlipBuffers, #True)
    CompilerEndIf
  EndProcedure
  
  
EndModule




;--------------------------------------------------------------------------------------------
; EOF
;--------------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 274
; FirstLine = 235
; Folding = ----
; EnableXP
; EnableUnicode