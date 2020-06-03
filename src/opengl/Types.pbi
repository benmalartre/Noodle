XIncludeFile "Framebuffer.pbi"
XIncludeFile "ScreenQuad.pbi"
XIncludeFile "../libs/FTGL.pbi"
XIncludeFile "../core/Math.pbi"
XIncludeFile "../objects/Object3D.pbi"

; ============================================================================
;  GLContext Module Declaration
; ============================================================================
DeclareModule GLContext
  UseModule OpenGL
  #MAX_GL_CONTEXT = 5
  Global counter = 0
  Global GL_LINE_WIDTH_MIN.f
  Global GL_LINE_WIDTH_MAX.f
  
  Global Dim shadernames.s(26)
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
  shadernames(24) = "stroke2D"
  shadernames(25) = "normal"

  Structure GLContext_t
    *window.GLFWwindow      ;main window holding shared gl context
    *writer.FTGL::FTGL_Drawer
    width.d
    height.d
    useGLFW.b
    ID.i
    focus.b
    shader.GLuint
    
;     List *layers()
    
    Map *shaders.Program::Program_t()
  EndStructure
  
  Declare New(width.i, height.i, *context=#Null)
  Declare Setup(*Me.GLContext_t)
  Declare Copy(*Me.GLContext_t, *shared.GLContext_t)
  Declare Delete(*Me.GLContext_t)
  Declare SetContext(*Me.GLContext_t)
  Declare FlipBuffer(*Me.GLContext_t)
  Declare GetSupportedLineWidth(*Me.GLContext_t)
  Declare Resize(*Me.GLContext_t, width.i, height.i)
;   Declare AddLayer(*Me.GLContext_t, *layer)
  
  Global *MAIN_GL_CTXT.GLContext_t
EndDeclareModule


; ============================================================================
; Layer Module Declaration
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
  
    *context.GLContext::GLContext_t
    color.Math::c4f32
    background_color.Math::c4f32
    active.b
    fixed.b
    mask.l
    
    *items.CArray::CArrayPtr
    *dependencies.CArray::CArrayPtr
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
    #LAYER_DEFAULT
    #LAYER_GBUFFER
    #LAYER_SELECTION
    #LAYER_SSAO
    #LAYER_STROKE
    #LAYER_DEPTH
    #LAYER_COMPONENT
    
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
  Declare DrawCurves(*layer.Layer::Layer_t, *objects.CArray::CArrayPtr, shader)
  
  Declare AddDependency(*layer.Layer_t, *dependency.Layer_t, index=-1)
  Declare RemoveDependency(*layer.Layer_t, *dependency.Layer_t)
  
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
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 67
; FirstLine = 64
; Folding = -
; EnableXP
; EnableUnicode