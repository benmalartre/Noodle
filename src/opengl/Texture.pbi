
XIncludeFile "../libs/OpenGL.pbi"
; XIncludeFile "../libs/GLFW.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"

UseJPEGImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()
UsePNGImageDecoder()
UseJPEGImageDecoder()

;============================================================================================
; Texture Module Declararion
;============================================================================================
DeclareModule Texture
  UseModule OpenGL
  Structure Texture_t
    src.s
    img.i
    tex.l
    width.i
    height.i
    depth.i
    filter.i
  EndStructure
  
  Declare New(width.i,height.i,depth.i=24)
  Declare NewFromSource(src.s)
  Declare Delete(*Me.Texture_t)
  Declare Setup(*Me.Texture_t)
  Declare Load(imageID,flipY.b=#True)
  Declare Write(path.s,width.i,height.i)
EndDeclareModule

;============================================================================================
; Texture Module Implementation
;============================================================================================
Module Texture
  
  UseModule OpenGLExt

  ; Constructors
  ;----------------------------------------------------
  Procedure New(width.i,height.i,depth.i=24)
    Protected *Me.Texture_t = AllocateMemory(SizeOf(Texture_t))
    *Me\src = ""
    *Me\width = width
    *Me\height = height
    *Me\depth = depth
    *Me\img = CreateImage(#PB_Any,width,height,depth)
    ProcedureReturn *Me
  EndProcedure
  
  Procedure NewFromSource(path.s)
    Protected *Me.Texture_t = AllocateMemory(SizeOf(Texture_t))
    *Me\src = path
    *Me\img = LoadImage(#PB_Any,path)
    If IsImage(*Me\img)
      *Me\width = ImageWidth(*Me\img)
      *Me\height = ImageHeight(*Me\img)
      *Me\depth = ImageDepth(*Me\img)
      *Me\tex = Load(*Me\img,#False)
    Else
      MessageRequester("[Texture] New From Source Failed!",path)
    EndIf
    
    
    ProcedureReturn *Me
  EndProcedure
  
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.Texture_t)
    If IsImage(*Me\img) : FreeImage(*Me\img) : EndIf
    FreeMemory(*Me)
  EndProcedure
  
  ; GL Setup
  ;----------------------------------------------------
  Procedure Setup(*Me.Texture_t)

  EndProcedure
  
;   Procedure Load(imageID,flipY.b=#True)
;   
;   
;       Protected w = ImageWidth(imageID)
;       Protected h = ImageHeight(imageID)
; 
;       
;       Protected out.l
;       If StartDrawing(ImageOutput(imageID))
;         
;         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;         ; Note : Il faut créer la texture correctement en
;         ; fonction de l'image qui est chargé. Il serait bien
;         ; créer une structure (Texture) afin d'enregistrer
;         ; les paramètres importants (Largeur, hauteur, type, etc)
;         ; Type : Nearest Filtered, Linear Filtered, MipMapped 
;         ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;         
;         glGenTextures(1, @out) ;Create The Texture
;         
;         glBindTexture(#GL_TEXTURE_2D, out)
;         glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
;         glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
;         glTexImage2D(#GL_TEXTURE_2D, 0, 3, w, h, 0, #GL_RGB, #GL_UNSIGNED_BYTE, DrawingBuffer())
;         
;         StopDrawing()
;         
;       EndIf 
;       
;       
; 
;     
;     ProcedureReturn out
;   EndProcedure
;   
  ;------------------------------------------------------------
  ; Load Image
  ; We have to load image directly from memory 
  ; rather by pixel by pixel, too slow really!!!
  ;------------------------------------------------------------
  Procedure Load(imageID,flipY.b=#True)
    If imageID <> #Null
      
      CompilerIf OpenGL::#LEGACY_OPENGL
        glEnable(#GL_TEXTURE_2D)
      CompilerEndIf
      
      Protected out.l
      glGenTextures(1,@out)
      GLCheckError("Gen FTGL Texture")   
      glBindTexture(#GL_TEXTURE_2D,out)
      GLCheckError("Bind FTGL Texture")
      ;glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP );
      ;glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP );
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_NEAREST ); // No pixel averaging
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_NEAREST ); // No pixel averaging
      GLCheckError("Set Attributes FTGL Texture")
      Protected w.i = ImageWidth(imageID) 
      Protected h.i = ImageHeight(imageID)
  
      Protected d.i = ImageDepth(imageID)
      Protected numPixels.l = w * h
      Protected size.i = numPixels*4
      Protected *bits = AllocateMemory(size) ; GLubyte
      
      Protected x, y, color, base
      
      ;Read pixels
      StartDrawing(ImageOutput(imageID))
      DrawingMode(#PB_2DDrawing_AllChannels)

      For x=0 To w - 1
        For y = 0 To h - 1
          color = Point(x,y)
          If flipY
            base = (x*4 + w * 4*(h-y-1))
          Else
            base = (x*4 + w * 4*y)
          EndIf
          PokeA(*bits + base,Red(color))
          PokeA(*bits + base + 1,Green(color))
          PokeA(*bits + base + 2,Blue(color))
          PokeA(*bits + base + 3,Alpha(color))
            
        Next y
      Next x
      StopDrawing()
      
      ;convert image To premultiplied alpha
     ;Protected i
      ;For i = 0 To  numPixels - 1
      ; 	PremultiplyAlpha( *bits + 4*i )
      ;Next i
    
      glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, *bits )
      GLCheckError("Upload FTGL Texture")
      FreeMemory(*bits)
      
      ProcedureReturn out
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------
  ; Write Image
  ;------------------------------------------------------------
  Procedure Write(path.s,width.i,height.i)
     ;Read Frame Buffer
    Protected GLubyte_s.GLubyte
    Define *datas = AllocateMemory(width * height * SizeOf(GLubyte_s)*4)
    glReadPixels(0,0,width,height,#GL_RGBA,#GL_UNSIGNED_BYTE,*datas)
    Protected img = CreateImage(#PB_Any,width,height)
    StartDrawing(ImageOutput(img))
    Protected x,y,offset
    Define.a r,g,b
    For y=0 To height-1
      For x=0 To width-1
        r = PeekA(*datas+offset)
        g = PeekA(*datas+SizeOf(GLubyte_s)+offset)
        b = PeekA(*datas+2*SizeOf(GLubyte_s)+offset)
        Plot(x,height-y-1,RGB(r,g,b))
        offset + 4*SizeOf(GLubyte_s)
      Next x
    Next y
    StopDrawing()
    
    UsePNGImageEncoder()
    Protected result = SaveImage(img,path,#PB_ImagePlugin_PNG)
    If result = 0
      Debug "[GL_WriteImage] Fail to write image to disk!!"
    EndIf
    
    FreeImage(img)
    FreeMemory(*datas)
  EndProcedure
  
  
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 126
; FirstLine = 122
; Folding = --
; EnableXP
; EnableUnicode