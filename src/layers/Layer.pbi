XIncludeFile "../core/Math.pbi"

XIncludeFile "../opengl/Framebuffer.pbi"
XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../opengl/ScreenQuad.pbi"

XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../objects/Light.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/PointCloud.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"
XIncludeFile "../objects/Scene.pbi"


; ============================================================================
; Layer Base Module Declaration
; ============================================================================
DeclareModule Layer
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure Layer_t Extends Object3D::Object3D_t
    *pov.Object3D::Object3D_t
    *viewport.Viewport_t
    *buffer.Framebuffer::Framebuffer_t
    *quad.ScreenQuad::ScreenQuad_t
    width.i
    height.i
  
    *context.GLContext_t
    color.c4f32
    background_color.c4f32
    active.b
    fixed.b
    mask.l
    
    *items.CArrayPtr
    
    image.i
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayer
    Delete()
    Setup(*ctx.GLContext::GLContext_t)
    Update()
    Clean(*ctx.GLContext::GLContext_t)
    Draw(*ctx.GLContext::GLContext_t)
  EndInterface
  
  Enumeration
    #RAA_LAYER_DEFAULT
    #RAA_LAYER_GBUFFER
    #RAA_LAYER_SELECTION
    #RAA_LAYER_SSAO
    #RAA_LAYER_STROKE
    #RAA_LAYER_DEPTH
    #RAA_LAYER_COMPONENT
  EndEnumeration
  
  ;---------------------------------------------------
  ; Per Viewport Layer Manager
  ;---------------------------------------------------
  Structure LayerManager_t Extends Object::Object_t
    *layers.CArrayPtr
    *current.Layer
  EndStructure
  
  Declare SetPOV(*layer.Layer_t,*pov.Object3D::Object3D_t)
  Declare SetColor(*layer.Layer_t,r.f,g.f,b.f,a.f)
  Declare SetBackgroundColor(*layer.Layer_t,r.f,g.f,b.f,a.f)
  Declare IsFixed(*layer.Layer_t)
  Declare GetTree(*layer.Layer_t)
  Declare SetShader(*layer.Layer_t,*shader.Program::Program_t)
  
  Declare Clear(*layer.Layer_t)
  Declare Resize(*layer.Layer_t,width,height.i)
  Declare AddScreenSpaceQuad(*layer.Layer_t,*ctx.GLContext::GLContext_t)
  Declare DrawChildren(*Me.Layer_t,*obj.Object3D::Object3D_t)
  Declare Draw(*layer.Layer_t,*ctx.GLContext::GLContext_t)
  Declare Delete()
  
  Declare GetViewMatrix(*layer.Layer_t)
  Declare GetProjectionMatrix(*layer.Layer_t)
  Declare WriteImage(*layer.Layer_t,path.s,format)
  Declare WriteFramebuffer(*layer.Layer_t,path.s,format.i)
  
  Declare DrawDrawers(*layer.Layer::Layer_t, *objects.CArray::CArrayPtr, shader.i)
  Declare DrawPolymeshes(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader.i, wireframe.b)
  Declare DrawInstanceClouds(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
  Declare DrawPointClouds(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
  Declare DrawNulls(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
 
  Declare GetImage(*layer.Layer::Layer_t, path.s)
   ; ============================================================================
  ;  MACROS ( Layer )
  ; ============================================================================

  Macro DAT()
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndMacro
  
  Global CLASS.Class::Class_t

EndDeclareModule

Module Layer
  UseModule OpenGL
  UseModule OpenGLExt
  Procedure Init(*layer.Layer_t)
    *layer\shader = #Null
;     *layer\tree = #Null
  EndProcedure
  
  ;---------------------------------------------------
  ; Set Point Of View
  ;---------------------------------------------------
  Procedure SetPOV(*layer.Layer_t,*pov.Object3D::Object3D_t)
    *layer\pov = *pov
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Set Color
  ;---------------------------------------------------
  Procedure SetColor(*layer.Layer_t,r.f,g.f,b.f,a.f)
    Color::Set(*layer\color,r,g,b,a)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Set BackgroundColor
  ;---------------------------------------------------
  Procedure SetBackgroundColor(*layer.Layer_t,r.f,g.f,b.f,a.f)
    Color::Set(*layer\background_color,r,g,b,a)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Is Bound
  ;---------------------------------------------------
  Procedure IsFixed(*layer.Layer_t)
    ProcedureReturn *layer\fixed
  EndProcedure
  
  ;---------------------------------------------------
  ; Get Tree
  ;---------------------------------------------------
  Procedure GetTree(*layer.Layer_t)
;     ProcedureReturn *layer\tree
  EndProcedure
  
  ;---------------------------------------------------
  ; Set Shader
  ;---------------------------------------------------
  Procedure SetShader(*layer.Layer_t,*shader.Program::Program_t)
    ;Debug "------------------------------------------------------------------------"
    ;Debug "Set Shader : "+Str(*shader\id)
    *layer\shader = *shader
  EndProcedure
  
  ;---------------------------------------------------
  ; Clear
  ;---------------------------------------------------
  Procedure Clear(*layer.Layer_t)
    glViewport(0,0,*layer\width,*layer\height)
    glClearColor(*layer\background_color\r,*layer\background_color\g,*layer\background_color\b,*layer\background_color\a)
    glClear(*layer\mask)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Resize
  ;---------------------------------------------------
  Procedure Resize(*layer.Layer_t,width,height.i)
    Protected *buffer.Framebuffer::Framebuffer_t = *layer\buffer
    Framebuffer::SetSize(*buffer,width,height)
    *layer\width = width
    *layer\height = height
    glViewport(0,0,*layer\width,*layer\height)
  EndProcedure
  
  ;---------------------------------------------------
  ; Get View Matrix
  ;---------------------------------------------------
  Procedure GetViewMatrix(*layer.Layer_t)
    If *layer\pov\type = Object3D::#Object3D_Camera
      Protected *camera.Camera::Camera_t = *layer\pov
      ProcedureReturn *camera\view
    ElseIf *layer\pov\type = Object3D::#Object3D_Light
      Protected *light.Light::Light_t = *layer\pov
      ProcedureReturn *light\view
    EndIf
  EndProcedure
  
  ;---------------------------------------------------
  ; Get Projection Matrix
  ;---------------------------------------------------
  Procedure GetProjectionMatrix(*layer.Layer_t)
    If *layer\pov\type = Object3D::#Object3D_Camera
      Protected *camera.Camera::Camera_t = *layer\pov
      ProcedureReturn *camera\projection
    ElseIf *layer\pov\type = Object3D::#Object3D_Light
      Protected *light.Light::Light_t = *layer\pov
      ProcedureReturn *light\projection
    EndIf
  EndProcedure
  
  ;---------------------------------------------------
  ; Write Image to Disk
  ;---------------------------------------------------
  Procedure WriteImage(*layer.Layer_t,path.s,format)
    
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
  Procedure WriteFramebuffer(*layer.Layer_t,path.s,format.i)
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
  Procedure AddScreenSpaceQuad(*layer.Layer_t,*ctx.GLContext::GLContext_t)
    
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
  Procedure DrawChildren(*Me.Layer_t,*obj.Object3D::Object3D_t)
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
  
  ;---------------------------------------------------
  ; Draw Drawers
  ;---------------------------------------------------
  Procedure DrawDrawers(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr, shader.i)
    Protected i
    Protected *obj.Object3D::Object3D_t
    
    For i=0 To CArray::GetCount(*objects)-1
      *obj = CArray::GetValuePtr(*objects,i)
      If *obj\type & Object3D::#Object3D_Drawer        
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*obj\matrix)
        Drawer::Draw(*obj)
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw Polymeshes
  ;---------------------------------------------------
  Procedure DrawPolymeshes(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader.i, wireframe.b)
    Protected i
    Protected obj.Object3D::IObject3D
    Protected *obj.Object3D::Object3D_t
    Protected *mesh.Polymesh::Polymesh_t
    For i=0 To CArray::GetCount(*objects)-1
      
      *obj = CArray::GetValuePtr(*objects,i)
      If *obj\type = Object3D::#Object3D_Polymesh
        *mesh = *obj
        *mesh\wireframe = wireframe
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*obj\matrix)
        obj = *obj
        obj\Draw()
      EndIf
      
    Next
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw Instance Clouds
  ;---------------------------------------------------
  Procedure DrawInstanceClouds(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
    Protected i
    Protected obj.Object3D::IObject3D
    Protected *obj.Object3D::Object3D_t
    For i=0 To CArray::GetCount(*objects)-1
      
      *obj = CArray::GetValuePtr(*objects,i)
      If *obj\type = Object3D::#Object3D_InstanceCloud
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*obj\matrix)
        obj = *obj
        obj\Draw()
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw Point Clouds
  ;---------------------------------------------------
  Procedure DrawPointClouds(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
    Protected i
    Protected obj.Object3D::IObject3D
    Protected *obj.Object3D::Object3D_t
    For i=0 To CArray::GetCount(*objects)-1
      
      *obj = CArray::GetValuePtr(*objects,i)
      If *obj\type = Object3D::#Object3D_PointCloud
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*obj\matrix)
        obj = *obj
        obj\Draw()
      EndIf
    Next
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw Nulls
  ;---------------------------------------------------
  Procedure DrawNulls(*layer.Layer::Layer_t,*objects.CArray::CArrayPtr,shader)
    Protected i
    Protected obj.Object3D::IObject3D
    Protected *obj.Object3D::Object3D_t
    For i=0 To CArray::GetCount(*objects)-1
      *obj = CArray::GetValuePtr(*objects,i)
      If *obj\type = Object3D::#Object3D_Null
        glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*obj\matrix)
        glUniform4f(glGetUniformLocation(shader,"color"),*obj\wireframe_r, *obj\wireframe_g, *obj\wireframe_b, 1.0)
        obj = *obj
        obj\Draw()
      EndIf
    Next
  EndProcedure
  
  
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*layer.Layer_t,*ctx.GLContext::GLContext_t)

    ;     Protected layer.ILayer = *layer
    ; ;     layer\Update(*ctx)
    

  Protected *buffer.Framebuffer::Framebuffer_t = *layer\buffer
  Framebuffer::BindOutput(*buffer)
  ;   Clear(*layer)
  glClearColor(0.66,0.66,0.66,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  glCheckError("Clear")
  glEnable(#GL_DEPTH_TEST)
  
  glViewport(0,0,*layer\width,*layer\height)
  
  ; Find Up View Point
  ;-----------------------------------------------
  Protected *view.m4f32,*proj.m4f32,view.m4f32
  *view = Layer::GetViewMatrix(*layer)
  *proj = Layer::GetProjectionMatrix(*layer)
  
  ;Draw Polymeshes 
  ;-----------------------------------------------
  Protected *shader.Program::Program_t = *ctx\shaders("polymesh")
  Protected shader.GLuint =  *shader\pgm
  glUseProgram(shader)
  GLCheckError("[LayerDefault]  Use Program")
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
  Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  GLCheckError("[LayerDefault] Set Matrices")
  glUniform3f(glGetUniformLocation(shader,"lightPosition"),*light\pos\x,*light\pos\y,*light\pos\z)
  GLCheckError("[LayerDefault] Uniforms")  
  glUniform1i(glGetUniformLocation(shader,"tex"),0)
  
  DrawPolymeshes(*layer,Scene::*current_scene\objects,shader, #False)

  GLCheckError("[LayerDefault] Draw Polymeshes")
  
    ; Draw Instance Clouds 
    ;-----------------------------------------------
  
    ;Model::Update(*model)
  Protected *pgm.Program::Program_t = *ctx\shaders("instances")
  glUseProgram(*pgm\pgm)
  Define.m4f32 model,view,proj
  Matrix4::SetIdentity(@model)
 
;   glDepthMask(#GL_TRUE);
  glEnable(#GL_DEPTH_TEST)
  
  glEnable(#GL_TEXTURE_2D)
  glBindTexture(#GL_TEXTURE_2D,texture)
  glUniform1i(glGetUniformLocation(*pgm\pgm,"texture"),0)
  
  glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"offset"),1,#GL_FALSE,@model)
  glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE,@model)
  
  glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE,Layer::GetViewMatrix(*layer))
  glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE,Layer::GetProjectionMatrix(*layer))
  glUniform3f(glGetUniformLocation(*pgm\pgm,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
  glUniform3f(glGetUniformLocation(*pgm\pgm,"lightPosition"),5,25,5)
  
  ;   PointCloud::Draw(*cloud)
  ;   Model::Update(*model)
  DrawInstanceClouds(*layer,Scene::*current_scene\objects,*pgm\pgm)
;   Model::Draw(*model)
  glCheckError("Draw Instance Cloud")
;   glDepthMask(#GL_FALSE);
  
;   ;Framebuffer::BlitTo(*buffer,#Null,#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT,#GL_NEAREST)
;   glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;   glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;   glBindFramebuffer(#GL_READ_FRAMEBUFFER, *buffer\frame_id);
;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
;   glBlitFramebuffer(0, 0, *buffer\width,*buffer\height,0, 0, *ctx\width,*ctx\height,#GL_COLOR_BUFFER_BIT ,#GL_NEAREST);
;   glDisable(#GL_DEPTH_TEST)
;     
;     Protected *cloud.InstanceCloud::InstanceCloud_t
;   *shader.Program::Program_t = *ctx\shaders("instances")
;     shader.GLuint =  *shader\pgm
;     glUseProgram(shader)
;   Define.m4f32 model,view,proj
;   Matrix4::SetIdentity(@model)
;   
;   glDepthMask(#GL_TRUE);
;   glEnable(#GL_DEPTH_TEST)
;   
;   glEnable(#GL_TEXTURE_2D)
;   glBindTexture(#GL_TEXTURE_2D,texture)
;   glUniform1i(glGetUniformLocation(shader,"texture"),0)
;   
;   glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@model)
;   glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,@model)
;   
;   glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
;   glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
;   glUniform3f(glGetUniformLocation(shader,"color"),Random(100)*0.01,Random(100)*0.01,Random(100)*0.01)
;   glUniform3f(glGetUniformLocation(shader,"lightPosition"),*light\pos\x,*light\pos\y,*light\pos\z)
;   
;   uModelMatrix = glGetUniformLocation(shader,"model")
;     uSelected = glGetUniformLocation(shader,"selected")
;     Protected uDatas = glGetUniformLocation(shader,"datas")
;     
;     For i=0 To nbo-1
;       *obj = CArray::GetValuePtr(Scene::*current_scene\objects,i)
;       If *obj\type = Object3D::#Object3D_InstanceCloud
;         *cloud = *obj
;         If *cloud\texture
;           glActiveTexture(#GL_TEXTURE0)
;           glBindTexture(#GL_TEXTURE_2D,*cloud\texture)
;         EndIf
;         If *cloud\selected 
;           glUniform1i(uSelected,*cloud\selected)
;         Else
;           glUniform1i(uSelected,#False)
;         EndIf
;         *t = *obj\globalT
;         glUniformMatrix4fv(uModelMatrix,1,#GL_TRUE,*t\m)
; 
;         obj = *obj
;         
;         obj\Draw()
;       EndIf 
;     Next i
;     
;      glDepthMask(#GL_FALSE); glDepthMask(#GL_TRUE);
; ;     
; ;     ; Draw Helpers
; ;     ;-----------------------------------------------
; ;     *shader = *ctx\shaders("wireframe")
; ;     shader = *shader\pgm
; ;     glUseProgram(shader)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
; ;     glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
; ;     
; ;     uModelMatrix = glGetUniformLocation(shader,"model")
; ;     nbo = CArray::GetCount(Scene::*current_scene\helpers)
; ;     For i=0 To nbo-1
; ;       *obj = CArray::GetValue(Scene::*current_scene\helpers,i)
; ;       *t = *obj\globalT
; ;       glUniformMatrix4fv(uModelMatrix,1,#GL_FALSE,*t\m)
; ;       If *obj\type = Object3D::#Object3D_Null
; ;         obj = *obj
; ;         obj\Draw()
; ;       ElseIf *obj\type =  Object3D::#Object3D_Curve
; ;         obj = *obj
; ;         obj\Draw()
; ;       EndIf 
; ;     Next i
; ;     
; ;     glDisable(#GL_DEPTH_TEST)
; ;   
; ; ;     ; Draw Lights
; ; ;     ;-----------------------------------------------
; ; ;     Define nbl = *raa_current_scene\lights\GetCount()
; ; ;   
; ; ;     For i=0 To nbl-1
; ; ;       
; ; ;       *obj = *raa_current_scene\lights\GetValue(i)
; ; ;       *obj\Draw(*ctx,#GL_LINES)
; ; ;   
; ; ;     Next i
; ; ;     
; ; ;     ; Draw Cameras
; ; ;     ;-----------------------------------------------
; ; ;     Define nbc = *raa_current_scene\cameras\GetCount()
; ; ;     For i=0 To nbc-1
; ; ;       
; ; ;       *obj = *raa_current_scene\cameras\GetValue(i)
; ; ;       ; Don't draw if active Camera
; ; ;       If *layer\pov <> *obj
; ; ;         *obj\Draw(*ctx,#GL_LINES)
; ; ;       EndIf
; ; ;       
; ; ;     Next i
; ;     
;     
    Framebuffer::Unbind(*layer\buffer)
    Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_LINEAR)
; ; ;     *layer\buffer\Unbind()
; ;     *layer\buffer\BlitTo(0,#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT,#GL_LINEAR)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Get Image
  ;------------------------------------------------------------------
  Procedure GetImage(*layer.Layer::Layer_t, path.s)
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
  
  Procedure Delete()
    
  EndProcedure
  
  
  Class::DEF( Layer )
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 384
; FirstLine = 372
; Folding = -----
; EnableXP