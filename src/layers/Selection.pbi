; ============================================================================
;  OpenGl Layer For 3D Picking Using GLSL Shaders
; ============================================================================
XIncludeFile "Layer.pbi"

DeclareModule LayerSelection
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerSelection_t Extends Layer::Layer_t
   
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerSelection Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  Declare Delete(*layer.LayerSelection_t)
  Declare DrawChildren(*layer.LayerSelection_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t)
  Declare Update(*layer.LayerSelection_t,*view.m4f32,*proj.m4f32)
  Declare Setup(*layer.LayerSelection_t)
  Declare Clean(*layer.LayerSelection_t)
  Declare Pick(*layer.LayerSelection_t)
  Declare Draw(*layer.LayerSelection_t,*ctx.GLContext::GLContext_t)
  DataSection
    LayerSelectionVT: 
    Layer::DAT ()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerSelection
  UseModule OpenGL
  UseModule OpenGLExt
  
;---------------------------------------------------------
; Pick Children Recursively
;---------------------------------------------------------
  Procedure DrawChildren(*layer.LayerSelection_t,*obj.Object3D::Object3D_t,*ctx.GLContext::GLContext_t)
  Debug  " >>>>>>>>>>>>>> Selection Layer Draw Children Called<<<<<<<<<<<<<<<<<<<<<<<<<<<<<é"
  Protected id.v3f32
  Protected nbo = ListSize(*obj\children())
  Protected *child.Object3D::Object3D_t
  Protected child.Object3D::IObject3D
  Protected *t.Transform::Transform_t
  Protected i
  
  Protected shader.i = *ctx\shaders("selection")\pgm

  Protected uModelMatrix = glGetUniformLocation(shader,"model")
  Protected uUniqueID = glGetUniformLocation(shader,"uniqueID")
  ForEach *obj\children()
    *child = *obj\children()
    Object3D::EncodeID(@id,*child\uniqueID)
    If *child\type = Object3D::#Object3D_Polymesh
      *t = *child\globalT
      glUniform3f(uUniqueID,id\x,id\y,id\z)
      glUniformMatrix4fv(uModelMatrix,1,#GL_FALSE,*t\m)
      child = *child
      child\Draw()
    ElseIf *child\type = Object3D::#Object3D_PointCloud
      *t = *child\globalT
      glUniform3f(uUniqueID,id\x,id\y,id\z)
      glUniformMatrix4fv(uModelMatrix,1,#GL_FALSE,*t\m)
      child = *child
      child\Draw()
    EndIf 
    
    DrawChildren(*layer,*child,*ctx)
  Next
  
EndProcedure


;---------------------------------------------------
; Update
;---------------------------------------------------
Procedure Update(*layer.LayerSelection_t,*view.m4f32,*proj.m4f32)
  

EndProcedure


;---------------------------------------------------
; Setup
;---------------------------------------------------
Procedure Setup(*layer.LayerSelection_t)

  
EndProcedure

;---------------------------------------------------
; Clean
;---------------------------------------------------
Procedure Clean(*layer.LayerSelection_t)

  
EndProcedure

;---------------------------------------------------
; Pick
;---------------------------------------------------
Procedure Pick(*layer.LayerSelection_t)

  
EndProcedure

;---------------------------------------------------
; Draw
;---------------------------------------------------
Procedure Draw(*layer.LayerSelection_t,*ctx.GLContext::GLContext_t)
  Protected layer.Layer::ILayer = *layer
  layer\Update()
  ;*layer\eye
  Debug  " >>>>>>>>>>>>>> Selection Layer Draw  Called<<<<<<<<<<<<<<<<<<<<<<<<<<<<<é"
    ; ---[ Find Up View Point ]--------------------------
  Protected *view.m4f32 = Layer::GetViewMatrix(*layer)
  Protected *proj.m4f32 = Layer::GetProjectionMatrix(*layer)

  ; ---[ Bind Framebuffer and Clean ]-------------------
  Framebuffer::BindOutput(*layer\buffer)
  GLCheckError("Bind Framebuffer")
  glViewport(0,0,*layer\width,*layer\height)
  GLCheckError("GL Viewport")
  glClearColor(*layer\background_color\r,*layer\background_color\g,*layer\background_color\b,*layer\background_color\a)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  Protected shader.GLuint =  *ctx\shaders("selection")\pgm
  
  glUseProgram(shader)
  glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
  glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
  glUniform3f(glGetUniformLocation(shader,"uniqueID"),1,0,0)
  
  glEnable(#GL_DEPTH_TEST)
  glDisable(#GL_CULL_FACE)
  ;glFrontFace(#GL_CW)
  
  ; Recursive Draw
  DrawChildren(*layer,Scene::*current_scene\root,*ctx)
  glDisable(#GL_DEPTH_TEST)
  Framebuffer::Unbind(*layer\buffer)
  Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)

EndProcedure

;------------------------------------------------------------------
; Destuctor
;------------------------------------------------------------------
Procedure Delete(*layer.LayerSelection_t)
  FreeMemory(*layer)
EndProcedure

;---------------------------------------------------
; Create
;---------------------------------------------------
Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  Protected *Me.LayerSelection_t = AllocateMemory(SizeOf(LayerSelection_t))
  InitializeStructure(*Me,LayerSelection_t)
  Object::INI( LayerSelection )
  Color::Set(*Me\background_color,0.5,1.0,0.5,1)
  *Me\width = width
  *Me\height = height
  *Me\context = *ctx
  *Me\buffer = Framebuffer::New("Selection",width,height)
  Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA8,#GL_LINEAR)
  Framebuffer::AttachRender(*Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
  *Me\pov = *pov
  ProcedureReturn *Me
EndProcedure

 Class::DEF( LayerSelection )

EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 119
; FirstLine = 66
; Folding = --
; EnableXP