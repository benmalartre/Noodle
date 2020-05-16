; ============================================================================
;  OpenGl Layer For 3D Picking Using GLSL Shaders
; ============================================================================
XIncludeFile "../opengl/Layer.pbi"
; XIncludeFile "../opengl/Context.pbi"
XIncludeFile "../objects/Selection.pbi"

DeclareModule LayerSelection
  UseModule Math
  UseModule OpenGL
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerSelection_t Extends Layer::Layer_t
    uProjectionMatrix.i
    uViewMatrix.i
    uModelMatrix.i
    uUniqueID.i
    mouseX.i
    mouseY.i
    Array read_datas.GLubyte(4)
    *overchild.Object3D::Object3D_t
    *selection.Selection::Selection_t
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
  Protected id.v3f32
  Protected nbo = ListSize(*obj\children())
  Protected *child.Object3D::Object3D_t
  Protected child.Object3D::IObject3D
  Protected *t.Transform::Transform_t
  Protected i
  
  
  ForEach *obj\children()
    *child = *obj\children()
    Object3D::EncodeID(id,*child\uniqueID)
    If *child\type = Object3D::#Polymesh
      *t = *child\globalT
      glUniform3f(*layer\uUniqueID,id\x,id\y,id\z)
      glUniformMatrix4fv(*layer\uModelMatrix,1,#GL_FALSE,*t\m)
      child = *child
      child\Draw()
    ElseIf *child\type = Object3D::#PointCloud
      *t = *child\globalT
      glUniform3f(*layer\uUniqueID,id\x,id\y,id\z)
      glUniformMatrix4fv(*layer\uModelMatrix,1,#GL_FALSE,*t\m)
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
  Protected layer.Layer::ILayer = *layer

    ; ---[ Find Up View Point ]--------------------------
  Protected *view.m4f32 = Layer::GetViewMatrix(*layer)
  Protected *proj.m4f32 = Layer::GetProjectionMatrix(*layer)
  
  ; ---[ Bind Framebuffer and Clean ]-------------------
  Framebuffer::BindOutput(*layer\buffer)
  glViewport(0,0,*layer\width,*layer\height)

  glClearColor(0,0,0,0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT) 
  
  glUseProgram(*layer\shader\pgm)

  glUniformMatrix4fv(*layer\uViewMatrix,1,#GL_FALSE,*view)
  glUniformMatrix4fv(*layer\uProjectionMatrix,1,#GL_FALSE,*proj)
  glUniform3f(*layer\uUniqueID,0,0,0)
  
  glEnable(#GL_DEPTH_TEST)
  glDisable(#GL_CULL_FACE)
  
  ; Recursive Draw
  DrawChildren(*layer,Scene::*current_scene\root,*ctx)

  
  Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)

  Framebuffer::Unbind(*layer\buffer)
  
  glPixelStorei(#GL_UNPACK_ALIGNMENT, 1)
  
  
   ; Read the pixel at the mouse position
  glReadPixels(*layer\mouseX, *layer\mouseY, 1, 1, #GL_RGBA, #GL_UNSIGNED_BYTE, @*layer\read_datas(0))
  Define pickID.i = Object3D::DecodeID(*layer\read_datas(0), *layer\read_datas(1), *layer\read_datas(2))
  Define *selected.Object3D::Object3D_t
  If FindMapElement(Scene::*current_scene\m_uuids(), Str(pickID))
    *selected = Scene::*current_scene\m_uuids()
    Selection::AddObject(*layer\selection, *selected)
    *selected\selected = #True
  EndIf
  
EndProcedure

;---------------------------------------------------
; Draw
;---------------------------------------------------
Procedure Draw(*layer.LayerSelection_t,*ctx.GLContext::GLContext_t)
  
  If MapSize(*layer\selection\items())
    Define *selected.Selection::SelectionItem_t 
    ForEach *layer\selection\items()
      *selected = *layer\selection\items()
      If *selected\type = Selection::#ITEM_OBJECT
        
      EndIf
      
    Next
    
  EndIf
  
  ; ;     glUniform1i(glGetUniformLocation(*layer\shader\pgm, "wireframe"), 1)
; ;     glUniform1i(glGetUniformLocation(*layer\shader\pgm, "selected"), 1)
;     Protected *obj.Object3D::Object3D_t = Scene::*current_scene\m_uuids()
;     Protected obj.Object3D::IObject3D = *obj
;     glDisable(#GL_DEPTH_TEST)
;     glEnable(#GL_CULL_FACE)
;     glDisable(#GL_BLEND)
; 
;     Define *t.Transform::Transform_t = *obj\globalT
;     glUniform3f(*layer\uUniqueID,1,1,1)
;     glUniformMatrix4fv(*layer\uModelMatrix,1,#GL_FALSE,*t\m)
;     *obj\selected = #True
;     obj\Draw()
;     If *obj <> *layer\overchild
;       If *layer\overchild : *layer\overchild\selected = #False : EndIf
;       *layer\overchild = *obj
;     EndIf
;   Else
;     If *layer\overchild
;       *layer\overchild\selected = #False
;       *layer\overchild = #Null
;     EndIf
  
  

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
  Object::INI( LayerSelection )
  Color::Set(*Me\background_color,0.5,1.0,0.5,1)
  *Me\width = width
  *Me\height = height
  *Me\context = *ctx
  *Me\buffer = Framebuffer::New("Selection",width,height)
  Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA8,#GL_LINEAR)
  Framebuffer::AttachRender(*Me\buffer,"Depth",#GL_DEPTH_COMPONENT)
  
    
  *Me\shader = *ctx\shaders("selection")
  Protected shader.i = *Me\shader\pgm
  *Me\uViewMatrix = glGetUniformLocation(shader,"view")
  *Me\uProjectionMatrix = glGetUniformLocation(shader,"projection")
  *Me\uModelMatrix = glGetUniformLocation(shader,"model")
  *Me\uUniqueID = glGetUniformLocation(shader,"uniqueID")
  
  *Me\pov = *pov
  ProcedureReturn *Me
EndProcedure

 Class::DEF( LayerSelection )

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 184
; FirstLine = 142
; Folding = --
; EnableXP
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 3
; Folding = --
; EnableXP