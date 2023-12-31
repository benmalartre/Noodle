; ============================================================================
;  OpenGl Layer For 3D Picking Using GLSL Shaders
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "../objects/Selection.pbi"

DeclareModule LayerSelection
  UseModule Math
  UseModule OpenGL
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------
  Structure LayerSelection_t Extends Layer::Layer_t
    mouseX.i
    mouseY.i
    pixel.GLubyte[4]
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
  Declare Update(*layer.LayerSelection_t,*view.m4f32,*proj.m4f32)
  Declare Setup(*layer.LayerSelection_t)
  Declare Clean(*layer.LayerSelection_t)
  Declare Pick(*layer.LayerSelection_t, *scene.Scene::Scene_t)
  Declare Draw(*layer.LayerSelection_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
  DataSection
    LayerSelectionVT: 
    Layer::DAT ()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerSelection
  UseModule OpenGL
  UseModule OpenGLExt


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
Procedure Pick(*layer.LayerSelection_t, *scene.Scene::Scene_t)
  Framebuffer::BindInput(*layer\framebuffer)
  glPixelStorei(#GL_UNPACK_ALIGNMENT, 1)

   ; Read the pixel at the mouse position
  glReadPixels(*layer\mouseX, *layer\framebuffer\height - *layer\mouseY, 1, 1, #GL_RGBA, #GL_UNSIGNED_BYTE,@*layer\pixel)

  Define pickID.i = Object3D::DecodeID(*layer\pixel[0], *layer\pixel[1], *layer\pixel[2])
  Define *selected.Object3D::Object3D_t
  If FindMapElement(*scene\m_uuids(), Str(pickID))
    *selected = *scene\m_uuids()
    Selection::AddObject(*layer\selection, *selected)
    *selected\selected = #True
  EndIf
Framebuffer::Unbind(*layer\framebuffer)
   
EndProcedure

;---------------------------------------------------
; Draw
;---------------------------------------------------
Procedure Draw(*layer.LayerSelection_t, *scene.Scene::Scene_t, *ctx.GLContext::GLContext_t)
  
    Protected *buffer.Framebuffer::Framebuffer_t = *layer\framebuffer
    Framebuffer::BindOutput(*buffer)
    
    Layer::Clear(*layer)
    
    glDisable(#GL_CULL_FACE)
    glFrontFace(#GL_CW)
    glEnable(#GL_DEPTH_TEST)
    
    Layer::DrawByType(*layer,*scene\objects, Object3D::#Polymesh, *ctx\shaders("selection"))

    Framebuffer::Unbind(*layer\framebuffer)
  
    glDisable(#GL_DEPTH_TEST)
    
    glUseProgram(0)

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
  Color::Set(*Me\color,0.5,1.0,0.5,1)
  *Me\context = *ctx
  *Me\mask = #GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT
  *Me\shader = *ctx\shaders("selection")  
  *Me\pov = *pov
  *Me\framebuffer = Framebuffer::New("Selection",width,height)
  Framebuffer::AttachTexture(*Me\framebuffer,"Color",#GL_RGBA,#GL_LINEAR)
  Framebuffer::AttachRender(*Me\framebuffer,"Depth",#GL_DEPTH_COMPONENT)
  
    
  
  ProcedureReturn *Me
EndProcedure

 Class::DEF( LayerSelection )

EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 39
; Folding = --
; EnableXP