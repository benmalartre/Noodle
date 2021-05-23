XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../objects/Location.pbi"

UseModule OpenGL
UseModule OpenGLExt

UsePNGImageDecoder()
UseTGAImageDecoder()
UseJPEGImageDecoder()
UseTIFFImageDecoder()
UseJPEG2000ImageDecoder()

DeclareModule GLUtils
  Declare GLDecodeID(x,y,z)
  Declare GLLoadImage(imageID,flipY.b=#True,wrap_s=#GL_CLAMP,wrap_t=#GL_CLAMP,min_f=#GL_NEAREST,mag_f=#GL_NEAREST)
  Declare GLWriteImage(path.s,width.i,height.i)
EndDeclareModule

Module GLUtils
  UseModule OpenGL
   ;-------------------------------------------
  ; Encode a unique ID into a color with components in range 0.0 to 1.0
  ;-------------------------------------------
  Procedure GLDecodeID(x,y,z)
    ProcedureReturn RGB(x,y,z)
  EndProcedure
  
  ;------------------------------------------------------------
  ; Load Image
  ;------------------------------------------------------------
  Procedure GLLoadImage(imageID,flipY.b=#True,wrap_s=#GL_CLAMP,wrap_t=#GL_CLAMP,min_f=#GL_NEAREST,mag_f=#GL_NEAREST)
    If imageID <> #Null
      Protected out.GLint
      glGenTextures(1,@out)
          
      glBindTexture(#GL_TEXTURE_2D,out)
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, wrap_s );
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, wrap_t );
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, min_f ); // No pixel averaging
      glTexParameteri( #GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, mag_f ); // No pixel averaging
      
      Protected w.i = ImageWidth(imageID) 
      Protected h.i = ImageHeight(imageID)
  
      Protected d.i = ImageDepth(imageID)

     
      ;Read pixels
      StartDrawing(ImageOutput(imageID))
      Select DrawingBufferPixelFormat()!#PB_PixelFormat_ReversedY

        Case #PB_PixelFormat_8Bits
          MessageRequester("8BITS","8BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_15Bits
          MessageRequester("15BITS","15BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_16Bits
          MessageRequester("16BITS","16BITS")
          ;glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_SHORT, DrawingBuffer() )
        Case #PB_PixelFormat_24Bits_RGB
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGB, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_24Bits_BGR
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_BGR, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_32Bits_RGB
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, DrawingBuffer() )
        Case #PB_PixelFormat_32Bits_BGR
          
          glTexImage2D( #GL_TEXTURE_2D, 0, #GL_RGBA, w, h, 0, #GL_BGRA, #GL_UNSIGNED_BYTE, DrawingBuffer() )
      EndSelect
      
      StopDrawing()
      
      
      ProcedureReturn out
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------
  ; Write Image
  ;------------------------------------------------------------
  Procedure GLWriteImage(path.s,width.i,height.i)
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


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 113
; FirstLine = 53
; Folding = -
; EnableXP