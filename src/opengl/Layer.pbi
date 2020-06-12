XIncludeFile "Types.pbi"

; ============================================================================
;  GLLayer Module Implementation
; ============================================================================
Module GLLayer
  UseModule OpenGL
  UseModule OpenGLExt
  
  Procedure Initialize(*layer.GLLayer_t, width, height, name.s, *ctxt.GLContext::GLContext_t)
    *layer\width = width
    *layer\height = height
    *layer\name = name
    *layer\context = *ctxt
  EndProcedure
  
  ;---------------------------------------------------
  ; Set Color
  ;---------------------------------------------------
  Procedure SetColor(*layer.GLLayer_t,r.f,g.f,b.f,a.f)
    Color::Set(*layer\color,r,g,b,a)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Set BackgroundColor
  ;---------------------------------------------------
  Procedure SetBackgroundColor(*layer.GLLayer_t,r.f,g.f,b.f,a.f)
    Color::Set(*layer\background_color,r,g,b,a)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Is Bound
  ;---------------------------------------------------
  Procedure IsFixed(*layer.GLLayer_t)
    ProcedureReturn *layer\fixed
  EndProcedure
  
  ;---------------------------------------------------
  ; Get Tree
  ;---------------------------------------------------
  Procedure GetTree(*layer.GLLayer_t)
;     ProcedureReturn *layer\tree
  EndProcedure
  
  ;---------------------------------------------------
  ; Set Shader
  ;---------------------------------------------------
  Procedure SetShader(*layer.GLLayer_t,*shader.Program::Program_t)
    *layer\shader = *shader
  EndProcedure
  
  ;---------------------------------------------------
  ; Clear
  ;---------------------------------------------------
  Procedure Clear(*layer.GLLayer_t)
    glViewport(0,0,*layer\width,*layer\height)
    glClearColor(*layer\background_color\r,*layer\background_color\g,*layer\background_color\b,*layer\background_color\a)
    glClear(*layer\mask)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Resize
  ;---------------------------------------------------
  Procedure Resize(*layer.GLLayer_t,width,height.i)
    Debug "RESIZE FRAME BUFFER : "+*layer\name
    Protected *buffer.Framebuffer::Framebuffer_t = *layer\buffer
    Framebuffer::Resize(*buffer,width,height)
    *layer\width = width
    *layer\height = height
  EndProcedure
 
  ;---------------------------------------------------
  ; Write Image to Disk
  ;---------------------------------------------------
  Procedure WriteImage(*layer.GLLayer_t,path.s,format)
    
    Define.GLint wtex,htex,comp,rs,gs,bs,a_s;
    Protected subsample = *layer\buffer\tbos(0)\textureID
    
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_WIDTH, @wtex );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_HEIGHT, @htex );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_INTERNAL_FORMAT, @comp );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_RED_SIZE, @rs );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_GREEN_SIZE, @gs );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_BLUE_SIZE, @bs );
  glGetTexLevelParameteriv( #GL_TEXTURE_2D, subsample,#GL_TEXTURE_ALPHA_SIZE, @a_s );
  
  Protected msg.s
  msg = "Texture Width : "+Str(wtex)+Chr(10)
  msg + "Texture Height "+Str(htex)+Chr(10)
  msg + "Texture Internal Format "+Str(comp)+Chr(10)
  msg + "Texture Red Size "+Str(rs)+Chr(10)
  msg + "Texture Green Size "+Str(gs)+Chr(10)
  msg + "Texture Blue Size "+Str(bs)+Chr(10)
  msg + "Texture Alpha Size "+Str(a_s)+Chr(10)
  
;   MessageRequester("Texture",msg)
  
  
    Protected x,y
    Protected l.l
    Protected *mem = AllocateMemory(*layer\width * *layer\height *4 * SizeOf(l))
    glBindBuffer(#GL_PIXEL_PACK_BUFFER, 0)
    OpenGL::glGetTexImage(#GL_TEXTURE_2D,0,format,#GL_UNSIGNED_INT,*mem)
    
    StartDrawing(ImageOutput(*layer\image))
    Protected row_size = *layer\width
    Protected color.l
    For y=0 To *layer\height-1
      For x=0 To *layer\width-1
        color = PeekA(*mem + (y*row_size+x)*SizeOf(l))
        Plot(x,y,color)
      Next x
    Next y
    
    StopDrawing()
    FreeMemory(*mem)
    SaveImage(*layer\image,path)
  EndProcedure
  
  ;---------------------------------------------------
  ; Write Framebuffer to Disk
  ;---------------------------------------------------
  Procedure WriteFramebuffer(*layer.GLLayer_t,path.s,format.i)
    Protected x,y
    x = *layer\width
    y = *layer\height
    Protected c.a
    Protected *mem = AllocateMemory(x*y* 3 *SizeOf(c))
    
    
    glReadPixels(0,0,x,y, #GL_BGR,#GL_UNSIGNED_BYTE,*mem);// split x and y sizes into bytes
    StartDrawing(ImageOutput(*layer\image))
    Protected row_size = *layer\width
    Protected color.l
    For y=0 To *layer\height-1
      For x=0 To *layer\width-1
        color = PeekA(*mem + (y*row_size+x)*SizeOf(c))
        Plot(x,y,color)
      Next x
    Next y
    
    StopDrawing()
    
    StopDrawing()
    FreeMemory(*mem)
    SaveImage(*layer\image,path)

  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Screen Space Quad
  ;---------------------------------------------------
  Procedure AddScreenSpaceQuad(*layer.GLLayer_t,*ctx.GLContext::GLContext_t)
    
    *layer\quad = ScreenQuad::New()
    
    ScreenQuad::Setup(*layer\quad,*ctx\shaders("bitmap"))
   
    
;     ; Get Quad Datas
;     Protected GLfloat_s.GLfloat
;     Protected size_t.i = 12 * SizeOf(GLfloat_s)
;     
;     ;Generate Vertex Array Object
;     glGenVertexArrays(1,@*layer\vao)
;     glBindVertexArray(*layer\vao)
;     
;     *layer\vbo = ScreenQuad::New()
;     
;     ; Attibute Position
;     glEnableVertexAttribArray(0)
;     glVertexAttribPointer(0,2,#GL_FLOAT,#GL_FALSE,0,0)
;     
;     ;Attibute UVs
;     glEnableVertexAttribArray(1)
;     glVertexAttribPointer(1,2,#GL_FLOAT,#GL_FALSE,0,size_t)
;     glBindVertexArray(0)
  
  EndProcedure
  
  
  ;-----------------------------------------------
  ; Draw Children
  ;-----------------------------------------------
  Procedure DrawChildren(*Me.GLLayer_t,*obj.Object3D::Object3D_t)
  ;   Protected i
  ;   Protected *child.C3DObject
  ;   Protected *t.CTransform_t
  ;   Protected shader.GLuint
  ;   Protected offset.m4f32_b
  ;   For i = 0 To *obj\children\GetCount()-1
  ;     *child = *obj\children\GetValue(i)
  ;     Select *child\GetType()
  ;        
  ;       Case #RAA_3DObject_Polymesh
  ;         *t = *child\GetGlobalTransform()
  ;         ;shader = *Me\shader\id
  ;         shader = *raa_gl_context\s_polymesh
  ;         glUniform1i(glGetUniformLocation(shader,"tex"),0)
  ;         glUniform1i(glGetUniformLocation(shader,"selected"),0)
  ;         glUniform1i(glGetUniformLocation(shader,"selectionMode"),0)
  ;         glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*t\m\m)
  ;         
  ; ;       Case #RAA_3DObject_PointCloud
  ; ;         glUseProgram(*raa_gl_context\s_pointcloud)
  ; ;       Case #RAA_3DObject_Null
  ; ;         glUseProgram(*raa_gl_context\s_wireframe)
  ; ;       Case #RAA_3DObject_Light
  ; ;         glUseProgram(*raa_gl_context\s_wireframe)
  ; ;       Default
  ; ;         glUseProgram(*raa_gl_context\s_wireframe)
  ; ;       
  ;     EndSelect
  ;    
  ;     
  ;     Select mode
  ;       Case #RAA_VIEWPORT_WIREFRAME
  ;           *child\Draw(*Me\contextID,1)
  ;       Default
  ;           *child\Draw(*Me\contextID,0)
  ;         
  ;     EndSelect
  ; 
  ;     DrawChildren(*Me,*child,mode)
  ;   Next i
    
  EndProcedure

  ;------------------------------------------------------------------
  ; Get Image
  ;------------------------------------------------------------------
  Procedure GetImage(*layer.GLLayer_t, path.s)
    Protected x,y
    Protected l.l
    Protected *mem = AllocateMemory(*layer\width * *layer\height * SizeOf(l))
    
    OpenGL::glGetTexImage(#GL_TEXTURE_2D,0,#GL_DEPTH_COMPONENT,#GL_UNSIGNED_INT,*mem)
    
    StartDrawing(ImageOutput(*layer\image))
    Protected row_size = *layer\width
    Protected color.l
    For y=0 To *layer\height-1
      For x=0 To *layer\width-1
        color = PeekA(*mem + (y*row_size+x)*SizeOf(l))
        Plot(x,y,color)
      Next x
    Next y
    
    StopDrawing()
    FreeMemory(*mem)
    SaveImage(*layer\image,path)
  EndProcedure
  
  
  Class::DEF( GLLayer )
  
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 65
; FirstLine = 9
; Folding = ---
; EnableXP