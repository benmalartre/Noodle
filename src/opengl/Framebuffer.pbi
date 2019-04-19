XIncludeFile("../libs/OpenGL.pbi")
XIncludeFile("../libs/OpenGLExt.pbi")

;====================================================================
; Framebuffer Module Declaration
;====================================================================

DeclareModule Framebuffer
  UseModule OpenGL
  UseModule OpenGLExt
  ;----------------------------------------------------------
  ; STRUCTURES
  ;----------------------------------------------------------
  Structure RenderBuffer_t
    name.s
    format.i
    type.i
    attachment.GLenum
    bufferID.i
  EndStructure
  
  Structure TextureBuffer_t
    name.s
    iformat.i
    format.i
    type.i
    filter.i
    attachment.GLenum
    textureID.i
  EndStructure
  
  Structure FrameBuffer_t
    name.s
    width.i
    height.i
    frame_id.GLuint
    depth_id.GLuint
    stencil_id.GLuint
    
    Array tbos.TextureBuffer_t(0)
    Array rbos.RenderBuffer_t(0)
    Array attachments.GLenum(0)
    max_color_attachment.i
  EndStructure
 
  
  
  Declare New(name.s,width.i,height.i)
  Declare Delete(*buffer.FrameBuffer_t)
  Declare CheckStatus(*buffer.FrameBuffer_t)
  Declare Resize(*buffer.FrameBuffer_t,width.i,height.i)
  Declare AttachRender(*Me.Framebuffer_t,name.s,iformat.GLenum)
  Declare AttachTexture(*Me.Framebuffer_t,name.s,iformat.GLenum,filter.GLenum,wrap.GLenum=#GL_REPEAT)
  Declare AttachShadowMap(*Me.Framebuffer_t)
  Declare AttachCascadedShadowMap(*Me.Framebuffer_t, num_cascades.i)
  Declare Unbind(*Me.Framebuffer_t)
  Declare BindInput(*Me.Framebuffer_t,offset.i=0)
  Declare BindInputByID(*Me.Framebuffer_t,id.i,offset.i=0)
  Declare BindOutput(*Me.Framebuffer_t)
  Declare BindOutputByID(*Me.Framebuffer_t,id.i)
  Declare BindTex(*Me.Framebuffer_t,id.i)
  Declare GetTex(*Me.Framebuffer_t,id.i)
  Declare BlitTo(*Me.Framebuffer_t,*dest.Framebuffer_t,mask.GLbitfield,filter.GLenum)
  Declare SetSize(*Me.Framebuffer_t,width.i,height.i)
  Declare Check(*Me.Framebuffer_t)
EndDeclareModule



;====================================================================
; FRAMEBUFFER MODULE IMPLEMENTATION
;====================================================================
Module Framebuffer
  UseModule OpenGL
  UseModule OpenGLExt
  
  ; Check Status
  ;------------------------------------------------------------------
  Procedure CheckStatus(*Me.FrameBuffer_t)
    Protected status.GLenum
    glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)
    status = glCheckFramebufferStatus(#GL_FRAMEBUFFER)
    If status <> #GL_FRAMEBUFFER_COMPLETE
      Debug "[Framebuffer] Status Error on Creation"
      Select status
        Case #GL_FRAMEBUFFER_UNDEFINED
          Debug "[Framebuffer] UNDEFINED"
        Case #GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
        Case #GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
        Case #GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER"
        Case #GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER"
        Case #GL_FRAMEBUFFER_UNSUPPORTED
          Debug "[Framebuffer] GL_FRAMEBUFFER_UNSUPPORTED"
        Case #GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE"
        Case #GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS 
          Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS"
      EndSelect
      
    EndIf
    
  EndProcedure


  ; Attach Render Buffer
  ;------------------------------------------------------------------
  Procedure AttachRender(*Me.Framebuffer_t,name.s,iformat.GLenum)    
    If *Me\width = 0 Or *Me\height = 0
      Debug "[Framebuffer::AttachRender]One of the Frame buffer Dimension is Zero"
      ProcedureReturn
    EndIf
    
    Protected id.i = ArraySize(*Me\rbos())
    ReDim *Me\rbos(id+1)
    Protected *rbo.RenderBuffer_t = *Me\rbos(id)
    *rbo\name = name
        
    If iformat = #GL_DEPTH_COMPONENT24 Or iformat = #GL_DEPTH_COMPONENT
      *rbo\attachment = #GL_DEPTH_ATTACHMENT
    ElseIf iformat = #GL_STENCIL_INDEX1 Or iformat = #GL_STENCIL_INDEX4 Or iformat = #GL_STENCIL_INDEX8 Or iformat = #GL_STENCIL_INDEX16 Or iformat = #GL_STENCIL_INDEX
      *rbo\attachment = #GL_STENCIL_ATTACHMENT
    ElseIf iformat = #GL_DEPTH24_STENCIL8 Or iformat = #GL_DEPTH32F_STENCIL8 Or #GL_DEPTH_STENCIL
      *rbo\attachment = #GL_DEPTH_STENCIL_ATTACHMENT
    Else
      Debug "[Framebuffer::AttachRender] Unrecognized internal format!!!"
      ProcedureReturn
    EndIf
    
    *rbo\format = iformat
    glGenRenderbuffers(1,@*rbo\bufferID)
    glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)
    glBindRenderbuffer(#GL_RENDERBUFFER,*rbo\bufferID)
    glRenderbufferStorage(#GL_RENDERBUFFER,*rbo\format,*Me\width,*Me\height)
    ;glRenderbufferStorageMultisample (#GL_RENDERBUFFER, 4, *rbo\format, *Me\width, *Me\height);

    glFramebufferRenderbuffer(#GL_FRAMEBUFFER,*rbo\attachment,#GL_RENDERBUFFER,*rbo\bufferID)
    
    If *rbo\attachment = #GL_DEPTH_ATTACHMENT Or *rbo\attachment = #GL_DEPTH_STENCIL_ATTACHMENT
      *Me\depth_id = *rbo\bufferID
    ElseIf attachment = #GL_STENCIL_ATTACHMENT
      *Me\stencil_id = *rbo\bufferID
    EndIf
    
    CheckStatus(*Me)
    
    glBindFramebuffer(#GL_FRAMEBUFFER,0)
    glBindRenderbuffer(#GL_RENDERBUFFER,0)
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Attach Texture to FBO
  ;------------------------------------------------------------------
  Procedure AttachTexture(*Me.Framebuffer_t,name.s,iformat.GLenum,filter.GLenum,wrap.GLenum=#GL_REPEAT)
  
    If *Me\width = 0 Or *Me\height = 0
      MessageRequester( "[Framebuffer::AttachTexture]","One of the Frame buffer Dimension is Zero, Aborted!!!")
      ProcedureReturn
    EndIf
    
    Protected id.i = ArraySize(*Me\tbos())
    Debug "[Framebuffer::AttachTexture] Current Texture ID : "+Str(id)
    
    If id = *Me\max_color_attachment
      MessageRequester( "[Framebuffer::AttachTexture]"," GL_MAX_COLOR_ATTACHMENT exceeded, Aborted!!!")
      ProcedureReturn
    EndIf
    
    ReDim *Me\tbos(id+1)
    
    Protected *tbo.TextureBuffer_t = *Me\tbos(id)
    *tbo\attachment = #GL_COLOR_ATTACHMENT0 + id

    *tbo\iformat = iformat
    *tbo\filter = filter
    
    If iformat = #GL_RGBA16F Or iformat = #GL_RGBA32F
      *tbo\format = #GL_RGBA
      *tbo\type = #GL_FLOAT
    ElseIf iformat = #GL_RGBA8 Or iformat = #GL_RGBA Or iformat = 4
      *tbo\format = #GL_RGBA
      *tbo\type = #GL_UNSIGNED_BYTE
    ElseIf iformat = #GL_RGB8 Or iformat = #GL_RGB Or iformat = 3
      *tbo\format = #GL_RGB
      *tbo\type = #GL_UNSIGNED_BYTE
    ElseIf iformat = #GL_DEPTH_COMPONENT32
      *tbo\format = #GL_DEPTH_COMPONENT32
      *tbo\type = #GL_FLOAT
      *tbo\attachment = #GL_DEPTH_ATTACHMENT
    ElseIf iformat = #GL_DEPTH_COMPONENT24 Or iformat = #GL_DEPTH_COMPONENT16 Or iformat = #GL_DEPTH_COMPONENT
      *tbo\format = #GL_DEPTH_COMPONENT
      *tbo\type = #GL_UNSIGNED_INT
      *tbo\attachment = #GL_DEPTH_ATTACHMENT
      *tbo\filter = #GL_NEAREST
    ElseIf iformat = #GL_STENCIL_INDEX1 Or iformat = #GL_STENCIL_INDEX4 Or iformat = #GL_STENCIL_INDEX8 Or iformat = #GL_STENCIL_INDEX16 Or iformat = #GL_STENCIL_INDEX
      *tbo\format = #GL_STENCIL_INDEX
      *tbo\type = #GL_UNSIGNED_BYTE
      *tbo\attachment = #GL_STENCIL_ATTACHMENT
      *tbo\filter = #GL_NEAREST
    ElseIf iformat = #GL_DEPTH24_STENCIL8 Or iformat = #GL_DEPTH_STENCIL
      *tbo\format = #GL_DEPTH_STENCIL
      *tbo\type = #GL_UNSIGNED_INT_24_8
      *tbo\attachment = #GL_DEPTH_STENCIL_ATTACHMENT
      *tbo\filter = #GL_NEAREST
    ElseIf iformat = #GL_RED Or iformat  = #GL_GREEN Or iformat = #GL_BLUE
      *tbo\format = #GL_RGB
      *tbo\type = #GL_FLOAT
    Else
      Debug "[Framebuffer::AttachTexture] unrecognized internal format!!!"
      ProcedureReturn
    EndIf
    
    glGenTextures(1,@*tbo\textureID)
    glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)
    glBindTexture(#GL_TEXTURE_2D,*tbo\textureID)
    ;glBindTexture(#GL_TEXTURE_2D_MULTISAMPLE,*tbo\textureID)
    glTexImage2D(#GL_TEXTURE_2D,0,iformat,*Me\width,*Me\height,0,*tbo\format,*tbo\type,#Null)
    ;glTexImage2DMultisample( #GL_TEXTURE_2D_MULTISAMPLE, 4, iformat, *Me\width, *Me\height, #False );
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MAG_FILTER,*tbo\filter)
    glTexParameteri(#GL_TEXTURE_2D,#GL_TEXTURE_MIN_FILTER,*tbo\filter)

    If *tbo\format = #GL_DEPTH_STENCIL
      glFramebufferTexture2D(#GL_FRAMEBUFFER,#GL_DEPTH_ATTACHMENT,#GL_TEXTURE_2D,*tbo\textureID,0)
      glFramebufferTexture2D(#GL_FRAMEBUFFER,#GL_STENCIL_ATTACHMENT,#GL_TEXTURE_2D,*tbo\textureID,0)
    Else
      glFramebufferTexture2D(#GL_FRAMEBUFFER,*tbo\attachment,#GL_TEXTURE_2D,*tbo\textureID,0)
      ;glFramebufferTexture2D(#GL_FRAMEBUFFER,*tbo\attachment,#GL_TEXTURE_2D_MULTISAMPLE,*tbo\textureID,0)

    EndIf
    
    glTexParameterf( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, wrap);
    glTexParameterf( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, wrap)
       
    ReDim *Me\attachments(id+1)
    *Me\attachments(id) = *tbo\attachment

    CheckStatus(*Me)
    glBindFramebuffer(#GL_FRAMEBUFFER,0)
      
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Attach ShadowMap Texture
  ;------------------------------------------------------------------
  Procedure AttachShadowMap(*Me.Framebuffer_t)  

    glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)

    ;Create the depth buffer
    ReDim *Me\tbos(1)
    Protected *tbo.TextureBuffer_t = *Me\tbos(0)
    glGenTextures(1,@*tbo\textureID)
    glBindTexture(#GL_TEXTURE_2D,*tbo\textureID)  
  ;   glTexImage2D(#GL_TEXTURE_2D, 0, #GL_DEPTH_COMPONENT32, *Me\width, *Me\height, 0, #GL_DEPTH_COMPONENT, #GL_FLOAT, #Null);
    glTexImage2D(#GL_TEXTURE_2D, 0,#GL_DEPTH_COMPONENT, *Me\width, *Me\height, 0,#GL_DEPTH_COMPONENT, #GL_UNSIGNED_INT, 0);

    glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST);
    glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST);
;     glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_COMPARE_MODE, #GL_COMPARE_REF_TO_TEXTURE);
;     glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_COMPARE_FUNC, #GL_LEQUAL);
    glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE);
    glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE);
    
;     glTexParameteri(#GL_TEXTURE_2D,#
    
   
    glFramebufferTexture2D(#GL_FRAMEBUFFER, #GL_DEPTH_ATTACHMENT, #GL_TEXTURE_2D, *tbo\textureID, 0);

    ;Disable writes To the color buffer
    glDrawBuffer(#GL_NONE)
  
    ;Disable reads from the color buffer
    glReadBuffer(#GL_NONE)
   
    *tbo\attachment = #GL_NONE
  
    *tbo\format = #GL_DEPTH_COMPONENT
    *tbo\type = #GL_UNSIGNED_INT
    *tbo\filter = #GL_NEAREST
    
    CheckStatus(*Me)
    
    glBindFramebuffer(#GL_FRAMEBUFFER,0)
    
  EndProcedure

  ;------------------------------------------------------------------
  ; Attach CascadedShadowMap Textures
  ;------------------------------------------------------------------
  Procedure AttachCascadedShadowMap(*Me.Framebuffer_t, num_cascades.i)  
   
    ;Create the depth buffer
    ReDim *Me\tbos(num_cascades)
    ReDim *Me\attachments(num_cascades)
    Protected *tbo.TextureBuffer_t
    Protected i
    For i = 0 To num_cascades-1
      *tbo = *Me\tbos(i)
      glGenTextures(1,@*tbo\textureID)
      glBindTexture(#GL_TEXTURE_2D, *tbo\textureID);
      glTexImage2D(#GL_TEXTURE_2D, 0, #GL_DEPTH_COMPONENT32, *Me\width, *Me\height, 0, #GL_DEPTH_COMPONENT, #GL_FLOAT, #Null)
      glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
      glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
      glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_COMPARE_MODE, #GL_NONE)
      glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
      glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
      
      ;glFramebufferTexture2D(#GL_FRAMEBUFFER, #GL_DEPTH_ATTACHMENT, #GL_TEXTURE_2D, *tbo\textureID, 0);
      
      *tbo\attachment = #GL_NONE
  
      *tbo\format = #GL_DEPTH_COMPONENT
      *tbo\type = #GL_UNSIGNED_INT
      *tbo\filter = #GL_NEAREST
      *Me\attachments(i) = #GL_NONE
    Next
    
    glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)
    glFramebufferTexture2D(#GL_FRAMEBUFFER, #GL_DEPTH_ATTACHMENT, #GL_TEXTURE_2D, *Me\tbos(0)\textureID, 0)

    ;Disable writes To the color buffer
    glDrawBuffer(#GL_NONE)
    glReadBuffer(#GL_NONE)

    CheckStatus(*Me)
    
    glBindFramebuffer(#GL_FRAMEBUFFER,0)
  EndProcedure

  ; Resize Frame Buffer // Not Working
  ;----------------------------------------------------------
  Procedure.i Resize(*buffer.FrameBuffer_t,width.i,height.i)
    *buffer\width = width
    *buffer\height = height
    
    Protected i
    Protected *rbo.RenderBuffer_t
    
    glBindFramebuffer(#GL_FRAMEBUFFER,*buffer\frame_id)
    For i=0 To ArraySize( *buffer\rbos())-1
      *rbo = *buffer\rbos(i)
      
      glBindRenderbuffer(#GL_RENDERBUFFER,*rbo\bufferID)
      glRenderbufferStorage(#GL_RENDERBUFFER,*rbo\format,*buffer\width,*buffer\height)
    Next
    
    Protected *tbo.TextureBuffer_t
    For i=0 To ArraySize( *buffer\tbos())-1
      *tbo = *buffer\tbos(i)
      glBindTexture(#GL_TEXTURE_2D,*tbo\textureID)
      glTexImage2D( #GL_TEXTURE_2D, 0, *tbo\iformat, width, height, 0, *tbo\format, *tbo\type, #Null )
    Next

  EndProcedure
  
  ;------------------------------------------------------------------
  ; Unbind
  ;------------------------------------------------------------------
  Procedure Unbind(*Me.Framebuffer_t)

    glBindFramebuffer(#GL_FRAMEBUFFER,0)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Bind Input
  ;------------------------------------------------------------------
  Procedure BindInput(*Me.Framebuffer_t,offset.i=0)
    Protected i
    Protected nb = ArraySize(*Me\tbos())
    For i=0 To nb-1
      glActiveTexture(#GL_TEXTURE0 + (i+offset))
      glBindTexture(#GL_TEXTURE_2D,*Me\tbos(i)\textureID)
    Next i
  
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Bind Input By ID
  ;------------------------------------------------------------------
  Procedure BindInputByID(*Me.Framebuffer_t,id.i,offset.i=0)
    If (id+1)>ArraySize(*Me\tbos())
      Debug "[Framebuffer::BindInputByID] Texture Array Size Exceeded!!"
      ProcedureReturn
    EndIf
    glActiveTexture(#GL_TEXTURE0 + offset)
    glBindTexture(#GL_TEXTURE_2D,*Me\tbos(id)\textureID)
  EndProcedure

  
  ;------------------------------------------------------------------
  ; Bind Output
  ;------------------------------------------------------------------
  Procedure BindOutput(*Me.Framebuffer_t)
   
   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER, *Me\frame_id)
   GLCheckError("Can't Bind Output Framebuffer "+ *Me\name)
     
    Protected nbt = ArraySize(*Me\tbos())
    If Not nbt
      Debug "[Framebuffer::BindOutput] "+*Me\name+" : No texture To bind"
      ProcedureReturn
    EndIf
    GLCheckError("Bind Output "+ *Me\name)
   
    If nbt=1
      glDrawBuffer(*me\attachments(0))
      GLCheckError("Can't Bind Unique Draw Buffer"+ Str(*me\attachments(0)))
    Else
      glDrawBuffers(nbt,*Me\attachments())
      GLCheckError("Can't Bind Multiple Draw Buffers "+ Str(*me\attachments()))
    EndIf
  
  EndProcedure

  ;------------------------------------------------------------------
  ; Bind Output By ID
  ;------------------------------------------------------------------
  Procedure BindOutputByID(*Me.Framebuffer_t,id.i)
    If Not (id+1)>ArraySize(*Me\tbos())
      Debug "[Framebuffer::BindOutputByID] Texture Array Size Exceeded!!"
      ProcedureReturn
    EndIf
    
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,*Me\frame_id)
    glDrawBuffer(*Me\tbos(id)\attachment)
    
  EndProcedure


  ;------------------------------------------------------------------
  ; Bind Tex
  ;------------------------------------------------------------------
  Procedure BindTex(*Me.Framebuffer_t,id.i)
    BindInputByID(*Me,id)
  EndProcedure


  ;------------------------------------------------------------------
  ; Get Tex
  ;------------------------------------------------------------------
  Procedure GetTex(*Me.Framebuffer_t,id.i)
    If id>=0 And id<ArraySize(*Me\tbos())
    Debug id
      ProcedureReturn *Me\tbos(id)\textureID
   EndIf
    
  EndProcedure
  
  
  ;------------------------------------------------------------------
  ; Blit
  ;------------------------------------------------------------------
  Procedure BlitTo(*Me.Framebuffer_t,*dest.Framebuffer_t,mask.GLbitfield,filter.GLenum)
  
    If (mask & #GL_DEPTH_BUFFER_BIT) Or (mask & #GL_STENCIL_BUFFER_BIT)
      filter = #GL_NEAREST
    EndIf
    
    glBindFramebuffer(#GL_READ_FRAMEBUFFER,*Me\frame_id)
    If *dest
      glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,*dest\frame_id)
    Else
      glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    EndIf
    If *dest
      glViewport(0,0,*dest\width,*dest\height)
      glBlitFramebuffer(0,0,*Me\width,*Me\height,0,0,*dest\width,*dest\height,mask,filter)
    Else
      Protected *mem = AllocateMemory(16)
      glGetIntegerv(#GL_VIEWPORT, *mem);
      glClearColor(0.25,0.25,0.25,1.0)
      glClear(#GL_COLOR_BUFFER_BIT)
      
;       GLint fbWidth = dims[2];
;       GLint fbHeight = dims[3];
      Protected bufferX = PeekL(*mem)
      Protected bufferY = PeekL(*mem+4)
      Protected bufferWidth = PeekL(*mem+8)
      Protected bufferHeight = PeekL(*mem+12)
      Protected ratio = *Me\width/*Me\height
      Protected nw,nh,nx,ny
      nw = *Me\width
      nx = (bufferWidth-*Me\width)*0.5
      nh = *Me\height
      ny = (bufferHeight-*Me\height)*0.5
;       
;       glGetRenderbufferParameteriv(#GL_RENDERBUFFER, #GL_RENDERBUFFER_WIDTH, @bufferWidth);
;       glGetRenderbufferParameteriv(#GL_RENDERBUFFER, #GL_RENDERBUFFER_HEIGHT, @bufferHeight);
      glBlitFramebuffer(0,0,*Me\width,*Me\height,0,0,bufferWidth,bufferHeight,mask,filter)
      FreeMemory(*mem)
    EndIf
  
    glBindFramebuffer(#GL_READ_FRAMEBUFFER,0)
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
  
  EndProcedure
  
  
  Procedure SetSize(*buffer.FrameBuffer_t,width.i,height.i)
    
  EndProcedure
  
  
  ; ----------------------------------------------------------------------------
;  IMPLEMENTATION
; ----------------------------------------------------------------------------
;{
;------------------------------------------------------------------
; Check
;------------------------------------------------------------------
Procedure Check(*Me.Framebuffer_t)
  Protected status.GLenum
  glBindFramebuffer(#GL_FRAMEBUFFER,*Me\frame_id)
  status = glCheckFramebufferStatus(#GL_FRAMEBUFFER)
  If status <> #GL_FRAMEBUFFER_COMPLETE
    Debug "[Framebuffer] Status Error on Creation"
    Select status
      Case #GL_FRAMEBUFFER_UNDEFINED
        Debug "[Framebuffer] UNDEFINED"
      Case #GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
      Case #GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
      Case #GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER"
      Case #GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER"
      Case #GL_FRAMEBUFFER_UNSUPPORTED
        Debug "[Framebuffer] GL_FRAMEBUFFER_UNSUPPORTED"
      Case #GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE"
      Case #GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS 
        Debug "[Framebuffer] GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS"
    EndSelect

  EndIf
  
EndProcedure


  ; Destructor
  ;-----------------------------------------
Procedure Delete(*buffer.FrameBuffer_t)
    Protected i
    For i=0 To ArraySize(*buffer\rbos())-1
      glDeleteRenderBuffers(1,@*buffer\rbos(i)\bufferID)
    Next
    
    For i=0 To ArraySize(*buffer\tbos())-1
      glDeleteTextures(1,@*buffer\tbos(i)\textureID)
     Next
   
     If *buffer\frame_id : glDeleteFramebuffers(1,@*buffer\frame_id) : EndIf
     If *buffer\depth_id : glDeleteFrameBuffers(1,@*buffer\depth_id) : EndIf
     If *buffer\stencil_id : glDeleteFrameBuffers(1,@*buffer\stencil_id) : EndIf
     
     ClearStructure(*buffer,Framebuffer_t)
     
    FreeMemory(*buffer)
  EndProcedure




  ;-----------------------------------------
  ; Constructor
  ;-----------------------------------------
  Procedure.i New(name.s,width.i,height.i)
    Protected *buffer.FrameBuffer_t = AllocateMemory(SizeOf(FrameBuffer_t))
    InitializeStructure(*buffer,FrameBuffer_t)
    *buffer\frame_id = 0
    *buffer\depth_id = 0
    *buffer\stencil_id = 0
    *buffer\width = width
    *buffer\height = height
    *buffer\name = name
    glGetIntegerv(#GL_MAX_COLOR_ATTACHMENTS,@*buffer\max_color_attachment)
    glGenFramebuffers(1,@*buffer\frame_id)
    ProcedureReturn *buffer
  EndProcedure

  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 571
; FirstLine = 524
; Folding = ----
; EnableXP
; EnableUnicode