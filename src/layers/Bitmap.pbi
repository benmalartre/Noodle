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
    tex.l
    *texture.Texture::Texture_t
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
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t, texture.l=0)
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
    Framebuffer::Check(*layer\framebuffer)
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
    *layer\texture = Texture::NewFromSource(filename)
    *layer\tex = *layer\texture\tex  
  EndProcedure
  
  Procedure SetBitmapFromMemory(*layer.LayerBitmap_t, tex)
    *layer\tex = tex 
  EndProcedure
  
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerBitmap_t, *ctx.GLContext::GLContext_t)
    Define shader.i = *ctx\shaders("bitmap")\pgm
    Debug "shader : "+Str(shader)
    glUseProgram(shader)
    
    Framebuffer::BindOutput(*layer\framebuffer)
    Layer::Clear(*layer)
        
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*layer\tex)
    
    glUniform1i(glGetUniformLocation(shader,"tex"),0)
    glUniform4f(glGetUniformLocation(shader,"color"),0.0,1.0,0.0,1.0)
    
    glDisable(#GL_CULL_FACE)
    glDisable(#GL_DEPTH_TEST)
    glPolygonMode(#GL_FRONT_AND_BACK,#GL_FILL)
    
    ScreenQuad::Draw(*layer\quad)
;     
;     glBindFramebuffer(#GL_READ_FRAMEBUFFER,*layer\framebuffer\frame_id)
;     glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
;     glReadBuffer(#GL_COLOR_ATTACHMENT0)
;     Framebuffer::BlitTo(*layer\framebuffer,0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
;     
;     Debug "befor write image "+*layer\name
;     Debug *layer\framebuffer\tbos(0)\textureID
    
;     Layer::WriteImage(*layer,"C:/Users/graph/Documents/bmal/src/Noodle/images/Test"+*layer\name+".png",#GL_RGBA)
        
        
    Framebuffer::Unbind(*layer\framebuffer)
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Destructor
  ;---------------------------------------------------
  Procedure Delete(*Me.LayerBitmap_t)
    If *Me\texture : Texture::Delete(*Me\texture) : EndIf
   
    Framebuffer::Delete(*Me\framebuffer)
    ScreenQuad::Delete(*Me\quad)
    Object::TERM(LayerBitmap)
    FreeStructure(*Me)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i, *ctx.GLContext::GLContext_t, texture.l=0)
    Protected *Me.LayerBitmap_t = AllocateStructure(LayerBitmap_t)
    Object::INI( LayerBitmap )
    Color::Set(*Me\color,0.5,0.5,0.5,1)
    *Me\name = "LayerBitmap"
    *Me\context = *ctx
    *Me\mask = #GL_COLOR_BUFFER_BIT
    *Me\framebuffer = Framebuffer::New("Bitmap",width,height)
    Framebuffer::AttachTexture(*Me\framebuffer,"Color", #GL_RGBA,#GL_LINEAR, #True)
    If texture
      *Me\tex = texture
    EndIf

    Layer::AddScreenSpaceQuad(*Me,*ctx)
    
    ProcedureReturn *Me
  EndProcedure
  
  
  Class::DEF(LayerBitmap)
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 142
; FirstLine = 95
; Folding = --
; EnableXP