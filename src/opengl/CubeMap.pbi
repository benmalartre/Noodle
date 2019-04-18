; ============================================================================
; CubeMap Declare Module
; ============================================================================
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "Shader.pbi"
XIncludeFile "../objects/Camera.pbi"


UseTIFFImageDecoder()
UseTGAImageDecoder()
UseJPEGImageDecoder()
UseJPEG2000ImageDecoder()

DeclareModule CubeMap

  Enumeration
    #CUBEMAP_HORIZONTAL_LEFT
    #CUBEMAP_HORIZONTAL_RIGHT
    #CUBEMAP_VERTICAL_TOP
    #CUBEMAP_VERTICAL_BOTTOM 
  EndEnumeration
  
  Enumeration
    #CUBEMAP_TOP
    #CUBEMAP_BOTTOM
    #CUBEMAP_LEFT
    #CUBEMAP_RIGHT
    #CUBEMAP_FRONT
    #CUBEMAP_BACK
  EndEnumeration  
  
  
  DataSection
    cube_map_positions:
    Data.f -10.0,  10.0, -10.0
    Data.f -10.0, -10.0, -10.0
    Data.f  10.0, -10.0, -10.0
    Data.f  10.0, -10.0, -10.0
    Data.f  10.0,  10.0, -10.0
    Data.f -10.0,  10.0, -10.0
    
    Data.f -10.0, -10.0,  10.0
    Data.f -10.0, -10.0, -10.0
    Data.f -10.0,  10.0, -10.0
    Data.f -10.0,  10.0, -10.0
    Data.f -10.0,  10.0,  10.0
    Data.f -10.0, -10.0,  10.0
    
    Data.f  10.0, -10.0, -10.0
    Data.f  10.0, -10.0,  10.0
    Data.f  10.0,  10.0,  10.0
    Data.f  10.0,  10.0,  10.0
    Data.f  10.0,  10.0, -10.0
    Data.f  10.0, -10.0, -10.0
     
    Data.f -10.0, -10.0,  10.0
    Data.f -10.0,  10.0,  10.0
    Data.f  10.0,  10.0,  10.0
    Data.f  10.0,  10.0,  10.0
    Data.f  10.0, -10.0,  10.0
    Data.f -10.0, -10.0,  10.0
    
    Data.f -10.0,  10.0, -10.0
    Data.f  10.0,  10.0, -10.0
    Data.f  10.0,  10.0,  10.0
    Data.f  10.0,  10.0,  10.0
    Data.f -10.0,  10.0,  10.0
    Data.f -10.0,  10.0, -10.0
    
    Data.f -10.0, -10.0, -10.0
    Data.f -10.0, -10.0,  10.0
    Data.f  10.0, -10.0, -10.0
    Data.f  10.0, -10.0, -10.0
    Data.f -10.0, -10.0,  10.0
    Data.f  10.0, -10.0,  10.0
    
  EndDataSection
  
  Structure CubeMap_t
    vbo.i
    vao.i
    shader.i
    filename.s
    orientation.i
    
    img.i
    width.i
    height.i
    side.i
    
    top.i
    bottom.i
    left.i
    right.i
    front.i
    back.i
    
    
    tex_cube.i
  EndStructure
  
  Declare New(filename.s)
  Declare Delete(*Me.CubeMap_t)
  Declare Setup(*Me.CubeMap_t)
  Declare Draw(*Me.CubeMap_t,*camera.Camera::Camera_t)

EndDeclareModule


; ============================================================================
;  CubeMap Module IMPLEMENTATION
; ============================================================================
Module CubeMap
  UseModule OpenGL
  UseModule OpenGLExt
;   UseModule Math
  ;----------------------------------------------------------------------------
  ; Constructor
  ;----------------------------------------------------------------------------
  Procedure New(filename.s)
    If FileSize(filename)>0
      Protected *Me.CubeMap_t = AllocateMemory(SizeOf(CubeMap_t))
      *Me\filename = filename
      *Me\orientation = #CUBEMAP_VERTICAL_TOP
      *Me\img = LoadImage(#PB_Any,*Me\filename)
      *Me\width = ImageWidth(*Me\img)
      *Me\height = ImageHeight(*Me\img)
      Select *Me\orientation
        Case  #CUBEMAP_VERTICAL_TOP
          *Me\side =  *Me\width/3
          *Me\top = GrabImage(*Me\img,#PB_Any,*Me\width/3,0,*Me\width/3,*Me\height/4)
          *Me\front = GrabImage(*Me\img,#PB_Any,*Me\width/3,*Me\height/4,*Me\width/3,*Me\height/4)
          *Me\bottom = GrabImage(*Me\img,#PB_Any,*Me\width/3,2* *Me\height/4,*Me\width/3,*Me\height/4)
          ;*Me\back = GrabImage(*Me\img,#PB_Any,*Me\width/3,3* *Me\height/4,*Me\width/3,*Me\height/4)
          Protected tmp = GrabImage(*Me\img,#PB_Any,*Me\width/3,3* *Me\height/4,*Me\width/3,*Me\height/4)
          Protected tmp2 = Image::FlipImage(tmp)
          *Me\back = Image::MirrorImage(tmp2)
          FreeImage(tmp)
          FreeImage(tmp2)
          *Me\left = GrabImage(*Me\img,#PB_Any,0,*Me\height/4,*Me\width/3,*Me\height/4)
          *Me\right = GrabImage(*Me\img,#PB_Any,2* *Me\width/3,*Me\height/4,*Me\width/3,*Me\height/4)
      EndSelect
      
     
      ProcedureReturn *Me
    Else
      MessageRequester("Cube Map"," File does Not exists!!!")
      ProcedureReturn #Null
    EndIf
    
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Destructor
  ;----------------------------------------------------------------------------
  Procedure Delete(*Me.CubeMap_t)
    glDeleteVertexArrays(1,@*Me\vao)
    glDeleteBuffers(1,@*Me\vbo)
    FreeMemory(*Me)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Load One Side
  ;----------------------------------------------------------------------------
  Procedure LoadSide(*Me.CubeMap_t, side_target.i , img)
    glBindTexture (#GL_TEXTURE_CUBE_MAP, *Me\tex_cube);
  
    Protected w.i = ImageWidth(img) 
    Protected h.i = ImageHeight(img)
    Protected numPixels.l = w * h
    Protected size.i = numPixels*4
    Protected *bits = AllocateMemory(size) ; GLubyte
    
    Protected x, y, color, base
    
    ;Read pixels
    StartDrawing(ImageOutput(img))
    DrawingMode(#PB_2DDrawing_AllChannels)
  
    For x=0 To h - 1
      For y = 0 To w - 1
        color = Point(x,y)
        base = (x*4 + w * 4*y)
        PokeA(*bits + base,Red(color))
        PokeA(*bits + base + 1,Green(color))
        PokeA(*bits + base + 2,Blue(color))
        PokeA(*bits + base + 3,Alpha(color))
      Next y
    Next x
    StopDrawing()
    ; copy image Data into 'target' side of cube Map
    glTexImage2D( side_target, 0, #GL_RGBA, *Me\side, *Me\side, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, *bits )
    FreeMemory(*bits)

  EndProcedure

  ;----------------------------------------------------------------------------
  ; Load Cube Texture
  ;----------------------------------------------------------------------------
  Procedure Load(*Me.CubeMap_t)
    ;generate a cube-Map texture To hold all the sides
    glActiveTexture (GL_TEXTURE0)
    glGenTextures(1, @*Me\tex_cube)
    
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,*Me\back)
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_POSITIVE_Z,*Me\front)
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_NEGATIVE_X,*Me\left)
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_POSITIVE_X,*Me\right)
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,*Me\bottom)
    LoadSide(*Me,#GL_TEXTURE_CUBE_MAP_POSITIVE_Y,*Me\top)
    
    glTexParameteri (#GL_TEXTURE_CUBE_MAP, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
    glTexParameteri (#GL_TEXTURE_CUBE_MAP, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
    glTexParameteri (#GL_TEXTURE_CUBE_MAP, #GL_TEXTURE_WRAP_R, #GL_CLAMP_TO_EDGE)
    glTexParameteri (#GL_TEXTURE_CUBE_MAP, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
    glTexParameteri (#GL_TEXTURE_CUBE_MAP, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
    
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Setup
  ;----------------------------------------------------------------------------
  Procedure Setup(*Me.CubeMap_t)
    Define f.f
    glGenVertexArrays(1, @*Me\vao)
    glBindVertexArray(*Me\vao) 
    
    glGenBuffers (1, @*Me\vbo)
    glBindBuffer (#GL_ARRAY_BUFFER, *Me\vbo)
    glBufferData (#GL_ARRAY_BUFFER, 3 * 36 * SizeOf (f), ?cube_map_positions, #GL_STATIC_DRAW)
    glEnableVertexAttribArray (0)
    glVertexAttribPointer (0, 3, #GL_FLOAT, #GL_FALSE, 0, #Null)

    *Me\shader = Program::NewFromName("cubemap")
    Load(*Me)
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------
  Procedure Draw(*Me.CubeMap_t,*camera.Camera::Camera_t)
    glDepthMask (#GL_FALSE);
    glUseProgram (*Me\shader);
    glActiveTexture (#GL_TEXTURE0);
    glBindTexture (#GL_TEXTURE_CUBE_MAP, *Me\tex_cube);
    glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"P"),1,#GL_FALSE,*camera\projection)
    Protected view.Math::m4f32
    Protected pos.Math::v3f32
    Matrix4::SetFromOther(view,*camera\view)
    Matrix4::SetTranslation(view,@pos)
    glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"V"),1,#GL_FALSE,@view)
    glBindVertexArray(*Me\vao);
    glDrawArrays(#GL_TRIANGLES, 0, 36);
    glDepthMask (#GL_TRUE);
  EndProcedure
 

  
EndModule
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 215
; FirstLine = 195
; Folding = --
; EnableXP