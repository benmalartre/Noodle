; ============================================================================
;  Bitmap Layer Module
; ============================================================================
XIncludeFile "Layer.pbi"
DeclareModule LayerBitmap
  UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerBitmap_t Extends Layer::Layer_t
    bitmap.i
  ;   image.GLuint
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerBitmap Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerBitmap_t)
  Declare Setup(*layer.LayerBitmap_t)
  Declare Update(*layer.LayerBitmap_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerBitmap_t)
  Declare Draw(*layer.LayerBitmap_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  Declare SetBitmapFromSource(*layer.LayerBitmap_t, filename.s)
  
  DataSection
    LayerBitmapVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerBitmap
  UseModule OpenGL
  UseModule OpenGLExt
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerBitmap_t)
    Framebuffer::Check(*layer\buffer)
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerBitmap_t,*view.m4f32,*proj.m4f32)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerBitmap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerBitmap_t)
    
  EndProcedure
  
  Procedure SetBitmapFromSource(*layer.LayerBitmap_t, filename.s)
    Protected *texture.Texture::Texture_t = Texture::NewFromSource(filename)
    *layer\bitmap = *texture\tex  
  EndProcedure
  
  Procedure SetBitmapFromMemory(*layer.LayerBitmap_t, *datas)
    
  EndProcedure
  
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerBitmap_t,*ctx.GLContext::GLContext_t)
    
    glUseProgram(*layer\shader)
    
    Framebuffer::BindOutput(*layer\buffer)
    Layer::Clear(*layer)
    
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*layer\bitmap)
    
    
    glUniform1i(glGetUniformLocation(*layer\shader,"tex"),0)
    glUniform4f(glGetUniformLocation(*layer\shader,"color"),0.0,1.0,0.0,1.0)
    
    glDisable(#GL_CULL_FACE)
    glDisable(#GL_DEPTH_TEST)
    glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
    
    ScreenQuad::Draw(*layer\quad)
    
    glBindFramebuffer(#GL_READ_FRAMEBUFFER,*layer\buffer\frame_id)
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    glReadBuffer(#GL_COLOR_ATTACHMENT0)
    Framebuffer::BlitTo(*layer\buffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
    Framebuffer::Unbind(*layer\buffer)
    
;     Layer::WriteImage(*layer,"D:\Projects\RnD\PureBasic\Noodle\pictures\Test.png",#GL_RGBA)
  EndProcedure
  
  ;---------------------------------------------------
  ; Destructor
  ;---------------------------------------------------
  Procedure Delete(*Me.LayerBitmap_t)
    Framebuffer::Delete(*Me\buffer)
    If IsImage(*Me\image) : FreeImage(*Me\image) : EndIf
    ScreenQuad::Delete(*Me\quad)
    Object::TERM(LayerBitmap)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t,*camera.Camera::Camera_t)
    Protected *Me.LayerBitmap_t = AllocateMemory(SizeOf(LayerBitmap_t))
    Object::INI( LayerBitmap )
    Color::Set(*Me\background_color,0.5,0.5,0.5,1)
    *Me\name = "LayerBitmap"
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\pov = *camera
    *Me\bitmap = #Null
    *Me\buffer = Framebuffer::New("Bitmap",width,height)
    *Me\image = CreateImage(#PB_Any,width,height)
    Framebuffer::AttachTexture(*Me\buffer,"Color",#GL_RGBA,#GL_LINEAR)
    
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\shader = *ctx\shaders("bitmap")\pgm
    
    Debug "NUM SHJADERS : "+Str(MapSize(*ctx\shaders()))
    Layer::AddScreenSpaceQuad(*Me,*ctx)
    
    ProcedureReturn *Me
  EndProcedure
  
  
  Class::DEF(LayerBitmap)
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 101
; FirstLine = 77
; Folding = --
; EnableXP