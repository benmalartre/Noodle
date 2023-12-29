; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
XIncludeFile "ShadowMap.pbi"
XIncludeFile "../opengl/Framebuffer.pbi"
DeclareModule LayerSSAO
  UseModule OpenGL
  UseModule Math
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure LayerSSAO_t Extends Layer::Layer_t
    *gbuffer.Framebuffer::Framebuffer_t
    
    *kernel.Carray::CArrayV3F32
    *noise.CArray::CArrayV3F32
    
    ; Uniforms SSAO
    u_position_map.i
    u_normal_map.i
    u_noise_map.i
    u_occ_radius.i
    u_occ_power.i
    u_view.i
    u_projection.i
    u_kernel_samples.i
    u_kernel_size.i
    u_noise_scale.i
    
    noise_tex.i
    
    occ_radius.f
    occ_blur.b
    
    nbsamples.i
    noise_size.i
  
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerSSAO Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
  Declare Delete(*layer.LayerSSAO_t)
  Declare Setup(*layer.LayerSSAO_t)
  Declare Update(*layer.LayerSSAO_t)
  Declare Clean(*layer.LayerSSAO_t)
  Declare Pick(*layer.LayerSSAO_t)
  Declare Draw(*layer.LayerSSAO_t,*ctx.GLContext::GLContext_t)
  
  DataSection 
    LayerSSAOVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
Module LayerSSAO
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;------------------------------------------------------------------

  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerSSAO_t)
    Protected *ctx.GLContext::GLContext_t = *layer\context
    Protected *s_ssao.Program::Program_t = *ctx\shaders("ssao")
    *layer\u_position_map = glGetUniformLocation(*s_ssao\pgm,"position_map")
    *layer\u_normal_map = glGetUniformLocation(*s_ssao\pgm,"normal_map")
    *layer\u_noise_map = glGetUniformLocation(*s_ssao\pgm,"noise_map")
    *layer\u_occ_radius = glGetUniformLocation(*s_ssao\pgm,"occ_radius")
    *layer\u_occ_power = glGetUniformLocation(*s_ssao\pgm,"occ_power")
    *layer\u_view = glGetUniformLocation(*s_ssao\pgm,"view")
    *layer\u_projection = glGetUniformLocation(*s_ssao\pgm,"projection")
    *layer\u_kernel_samples = glGetUniformLocation(*s_ssao\pgm,"kernel_samples")
    *layer\u_kernel_size = glGetUniformLocation(*s_ssao\pgm,"kernel_size")
    *layer\u_noise_scale = glGetUniformLocation(*s_ssao\pgm, "noise_scale")
    
    If Not *layer\kernel
      *layer\kernel = CArray::New(CArray::#ARRAY_V3F32)
    EndIf
    
    CArray::SetCount(*layer\kernel,*layer\nbsamples)
    
    Protected *p.v3f32
    Protected scl.f
    For i=0 To *layer\nbsamples-1
      *p = CArray::GetValue(*layer\kernel,i)
      Vector3::Set(*p,1-(Random(100)*0.02),1-(Random(100)*0.02),Random(100)*0.01 )
      Vector3::NormalizeInPlace(*p)
  ;     Vector3::ScaleInPlace(*p,Random(100)*0.01)
      scl = i/*layer\nbsamples
      LINEAR_INTERPOLATE(scl,0.1,1,scl*scl)
      Vector3::ScaleInPlace(*p,scl)
      CArray::SetValue(*layer\kernel,i,*p)

    Next

    
    If Not *layer\noise
      *layer\noise = CArray::New(CArray::#ARRAY_V3F32)
    EndIf
    
    Protected ns = *layer\noise_size * *layer\noise_size
    CArray::SetCount(*layer\noise,ns)
    Protected *n.v3f32
    For i=0 To ns-1
      
      *n = CArray::GetValue(*layer\noise,i)
      Vector3::RandomizeInPlace(*n,1)
    Next i
    
    If Not *layer\noise_tex
      glGenTextures(1,@*layer\noise_tex)
    EndIf
    
    glBindTexture(#GL_TEXTURE_2D,*layer\noise_tex)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      glTexImage2D(#GL_TEXTURE_2D,0,#GL_RGBA16F,*layer\noise_size,*layer\noise_size,0,#GL_RGBA,#GL_FLOAT,CArray::GetPtr(*layer\noise,0))
    CompilerElse
      glTexImage2D(#GL_TEXTURE_2D,0,#GL_RGBA16F,*layer\noise_size,*layer\noise_size,0,#GL_RGB,#GL_FLOAT,CArray::GetPtr(*layer\noise,0))
    CompilerEndIf
    
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,#GL_NEAREST)
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,#GL_NEAREST)
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_S,#GL_REPEAT)
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_WRAP_T,#GL_REPEAT)
    
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerSSAO_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerSSAO_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerSSAO_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerSSAO_t,*ctx.GLContext::GLContext_t)
    glDisable(#GL_DEPTH_TEST)
    Framebuffer::BindInput(*layer\gbuffer)
    Framebuffer::BindOutput(*layer\datas\buffer)
    glClear(#GL_COLOR_BUFFER_BIT);
    shader = *ctx\shaders("ssao")\pgm
    glUseProgram(shader)
    glViewport(0,0,*layer\datas\buffer\width,*layer\datas\buffer\height)
    glUniform1i(*layer\u_position_map,0)
    glUniform1i(*layer\u_normal_map,1)
    glActiveTexture(#GL_TEXTURE2)
    glBindTexture(#GL_TEXTURE_2D,*layer\noise_tex)
    glUniform1i(*layer\u_noise_map,2)
    glUniform1f(*layer\u_occ_radius,*layer\occ_radius)
    glUniform1f(*layer\u_occ_power,7)
    glUniformMatrix4fv(*layer\u_view,1,#GL_FALSE,Layer::GetViewMatrix(*layer))
    glUniformMatrix4fv(*layer\u_projection,1,#GL_FALSE,Layer::GetProjectionMatrix(*layer))
    ;       For i=0 To nbsamples-1
    ;         glUniform3fv(glGetUniformLocation(shader,"kernel_samples[" + Str(i) + "]"), 1, CArray::GetPtr(*kernel,i));
    ;       Next
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      glUniform4fv(*layer\u_kernel_samples,*layer\nbsamples,Carray::GetPtr(*layer\kernel,0))
    CompilerElse
      glUniform3fv(*layer\u_kernel_samples,*layer\nbsamples,Carray::GetPtr(*layer\kernel,0))
    CompilerEndIf
    
    glUniform1i(*layer\u_kernel_size,*layer\nbsamples)
    glUniform2f(*layer\u_noise_scale,*layer\datas\buffer\width/*layer\noise_size,*layer\datas\buffer\height/*layer\noise_size)
    

    ScreenQuad::Draw(*layer\quad)
       
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glBindFramebuffer(#GL_READ_FRAMEBUFFER, *layer\datas\buffer\frame_id);
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    glBlitFramebuffer(0, 0, *layer\datas\buffer\width,*layer\datas\buffer\height,0, 0, *ctx\width, *ctx\height,#GL_COLOR_BUFFER_BIT,#GL_NEAREST)

    
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerSSAO_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*gbuffer.Framebuffer::Framebuffer_t,*camera.Camera::Camera_t)
    Protected *Me.LayerSSAO_t = AllocateMemory(SizeOf(LayerSSAO_t))
    InitializeStructure(*Me,LayerSSAO_t)
    Object::INI( LayerSSAO )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
 
    *Me\nbsamples = 32
    *Me\noise_size = 4

    *Me\datas\width = width
    *Me\datas\height = height
    *Me\context = *ctx
    *Me\gbuffer = *gbuffer

    *Me\pov = *camera
    *Me\occ_radius = 1.0
    *Me\occ_blur = #True
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\datas\buffer = Framebuffer::New("SSAO",width,height)
    Framebuffer::AttachTexture(*Me\datas\buffer,"AO",#GL_RED,#GL_NEAREST,#GL_CLAMP)
   
    Layer::AddScreenSpaceQuad(*Me,*ctx)

    Setup(*Me)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerSSAO)
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 112
; FirstLine = 87
; Folding = --
; EnableXP