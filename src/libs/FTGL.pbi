;=============================================================================
; FTGL Module Declaration
; ============================================================================
; Free Type 2
; ============================================================================
; Copyright 1996-2001, 2006 by                                           
; David Turner, Robert Wilhelm, And Werner Lemberg.                     
;                                                                        
; This file is part of the FreeType project, and may only be used,
; modified, and distributed under the terms of the FreeType project
; license, LICENSE.TXT.  By continuing to use, modify, or distribute
; this file you indicate that you have read the license And
; understand and accept it fully
; ============================================================================

XIncludeFile "OpenGL.pbi"
XIncludeFile "OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Texture.pbi"
XIncludeFile "../core/Math.pbi"

DeclareModule FTGL
  UseModule OpenGL
  
  Global FTGL_Initialized.b
  ; ============================================================================
  ; STRUCTURES
  ; ============================================================================
  Structure FTGL_GlyphInfos Align #PB_Structure_AlignC
    ax.f;	 advance.x
    ay.f;	 advance.y
  
    bw.f;	 bitmap.width
  	bh.f;	 bitmap.height
  
  	bl.f;	 bitmap.left
  	bt.f;	 bitmap.top
  	tx.f;	x offset of glyph in texture coordinates
  EndStructure
  
  Structure FTGL_FontAtlas Align #PB_Structure_AlignC
    metadata.FTGL_GlyphInfos[256]
    width.l
    height.l
    size_px.l
    *buffer
    
  EndStructure
  
  Structure FTGL_Face Align #PB_Structure_AlignC
    v.f[16]
  EndStructure
  
  Structure FTGL_Color Align #PB_Structure_AlignC
    r.f
    g.f
    b.f
    a.f
  EndStructure
  
  Structure FTGL_Drawer Align #PB_Structure_AlignC
    *atlas.FTGL_FontAtlas
    color.FTGL_Color
    bgcolor.FTGL_Color
    vao.GLuint
    vbo.GLuint
    *tex.Texture::Texture_t
    *shader.Program::Program_t
    background.b
  EndStructure
  
  Structure FTGL_Point Align #PB_Structure_AlignC
    x.f
    y.f
    s.f
    t.f
  EndStructure
  
  ; ============================================================================
  ; GLOBALS
  ; ============================================================================
  Global FONT_FILE_NAME.s = ""
  FONT_FILE_NAME = "../../fonts/Arial/arial.ttf"
  If FileSize(FONT_FILE_NAME) = -1
    FONT_FILE_NAME = "../../../fonts/Arial/arial.ttf"
  EndIf
   
  Global *ftgl_atlas.FTGL_FontAtlas = 0
  Global NewMap *atlases.FTGL_FontAtlas()
  
  ; ============================================================================
  ; IMPORTS
  ; ============================================================================
  ;{
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "..\..\libs\x64\windows\freetype.lib" : EndImport
    ImportC "..\..\libs\x64\windows\ftgl.lib"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "../../libs/x64/linux/freetype.a" : EndImport
    ImportC "../../libs/x64/linux/ftgl.a"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS  
    ;___________________________________________________________________________
    ;  MacOSX
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "-lbz2" : EndImport
    ImportC "../../libs/x64/macosx/libfreetype.a" : EndImport
    ImportC "../../libs/x64/macosx/libftgl.a"
  
   CompilerEndIf
    
    FT_CreateFontAtlas(file_name.p-utf8,size_px.i)
    FT_DeleteFontAtlas(*atlas.FTGL_FontAtlas)
  EndImport
  
  Declare Init()
  Declare New()
  Declare AddAtlas(filename.s, size_px.i, name.s)
  Declare RemoveAtlas(name.s)
  Declare Delete(*Me.FTGL_Drawer)
  Declare SetPoint(*mem,id.i,x.f,y.f,s.f,t.f)
  Declare SetColor(*Me.FTGL_Drawer,r.f,g.f,b.f,a.f)
  Declare SetBackgroundColor(*Me.FTGL_Drawer,r.f,g.f,b.f,a.f)
  Declare BeginDraw(*Me.FTGL_Drawer)
  Declare EndDraw(*Me.FTGL_Drawer)
  Declare Draw(*Me.FTGL_Drawer,text.s,x.f,y.f,sx.f,sy.f)
  Declare SetupTexture(*Me.FTGL_Drawer)
  Declare.s GetVertexShader()
  Declare.s GetFragmentShader() 
EndDeclareModule

Module FTGL
  UseModule OpenGL
  UseModule OpenGLExt
  
  ; ============================================================================
  ; PROCEDURES
  ; ============================================================================
  Procedure Init()
    ; ---[ Global Atlas ]-------------------------------------------------------
    *ftgl_atlas = AddAtlas(FONT_FILE_NAME, 8, "Arial8")
    *ftgl_atlas = AddAtlas(FONT_FILE_NAME, 16, "Arial16")
    *ftgl_atlas = AddAtlas(FONT_FILE_NAME, 32, "Arial32")
    If FindMapElement(*atlases(), "Arial32")
      *ftgl_atlas = *atlases()
    EndIf
  EndProcedure
  
  Procedure SetPoint(*mem,id.i,x.f,y.f,s.f,t.f)
    Protected *pnt.FTGL_Point = *mem + id*SizeOf(FTGL_Point)
    *pnt\x = x
    *pnt\y = y
    *pnt\s = s
    *pnt\t = t
  EndProcedure
  
  Procedure.s GetVertexShader()
    Define vertex.s
  
    If #USE_LEGACY_OPENGL
      vertex = "#version 120"+#CRLF$+
               "attribute vec4 coord;"+#CRLF$+
               "varying vec2 texcoord;"+#CRLF$+
               "void main(void){"+#CRLF$+
               "texcoord = coord.zw;"+#CRLF$+
               "gl_Position = vec4(coord.xy,0.0,1.0);"+#CRLF$+
               "}";
    Else
      vertex = "#version 330"+#CRLF$+
               "in vec4 coord;"+#CRLF$+
               "out vec2 texcoord;"+#CRLF$+
               "void main(void){"+#CRLF$+
               "texcoord = coord.zw;"+#CRLF$+
               "gl_Position = vec4(coord.xy,0.0,1.0);"+#CRLF$+
               "}";
    EndIf
    CompilerIf #PB_Compiler_Unicode
      vertex = Shader::DeCodeUnicodeShader(vertex)
    CompilerEndIf
  	ProcedureReturn vertex
  EndProcedure
  
  
  Procedure.s  GetFragmentShader()
    Define fragment.s 
    If #USE_LEGACY_OPENGL
      fragment = "#version 120"+#CRLF$+                  
                 "varying vec2 texcoord;"+
                 "uniform sampler2D tex;"+
                 "uniform vec4 color;"+
                 "uniform vec4 background;"+
                 "void main(){"+
                 "vec4 coords = texture2D(tex,texcoord);"+
                  "gl_FragColor = vec4(1,1,1,coords.a)*color + vec4(1,1,1,1 - coords.a) * background;"+
                  "}"
    Else
      fragment = "#version 330"+#CRLF$+                 
                 "in vec2 texcoord;"+
                 "out vec4 outColor;"+
                 "uniform sampler2D tex;"+
                 "uniform vec4 color;"+
                 "uniform vec4 bgcolor;"+
                 "void main(){"+
                 "outColor = vec4(1,1,1,texture(tex,texcoord).a)*color + vec4(1,1,1,1-texture(tex,texcoord).a)*bgcolor;"+
                "}"
     EndIf
    CompilerIf #PB_Compiler_Unicode
      fragment = Shader::DeCodeUnicodeShader(fragment)
    CompilerEndIf
    ProcedureReturn fragment
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Set Color
  ;-------------------------------------------------------------------------------------
  Procedure SetColor(*Me.FTGL_Drawer,r.f,g.f,b.f,a.f)
    If *Me
      *Me\color\r = r
      *Me\color\g = g
      *Me\color\b = b
      *Me\color\a = a
      glUniform4fv(glGetUniformLocation(*Me\shader\pgm,"color"),1,*Me\color)
    EndIf
  
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Set Background Color
  ;-------------------------------------------------------------------------------------
  Procedure SetBackgroundColor(*Me.FTGL_Drawer,r.f,g.f,b.f,a.f)
    If *Me
      *Me\bgcolor\r = r
      *Me\bgcolor\g = g
      *Me\bgcolor\b = b
      *Me\bgcolor\a = a
      glUniform4fv(glGetUniformLocation(*Me\shader\pgm,"bgcolor"),1,*Me\bgcolor)
    EndIf
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Draw Text
  ;-------------------------------------------------------------------------------------
  Procedure Draw(*Me.FTGL_Drawer,text.s,x.f,y.f,sx.f,sy.f)
    If Not *Me Or Not *Me\atlas 
      ProcedureReturn
    EndIf
    
    Protected n=0
    Protected a
    Protected c.s
    Define.f x2, y2, w, h
    Protected *infos.FTGL_GlyphInfos
    
    If *Me\background
      
    Else
      Define size_t = (Len(text))*6*SizeOf(FTGL_Point)
    EndIf

    Protected atlas_width = *Me\atlas\width
    Protected atlas_height = *Me\atlas\height
    
    w = 0
    h = 0
    Define nh.f
    If *Me\background
      For a=1 To Len(text)
        c = Mid(text,a,1)
        *infos = *Me\atlas\metadata[Asc(c)]
        
        w + *infos\bl * sx + *infos\ax * sx 
        nh = *infos\bt * sy + *infos\ay * sy
        If h<nh : h=nh : EndIf
      Next
      
      Define size_t = 6*SizeOf(FTGL_Point)
      Define *mem = AllocateMemory(size_t)
      SetPoint(*mem, 0 ,x     ,y    ,0, 0)
      SetPoint(*mem, 1 ,x+w   ,y    ,0, 0)
      SetPoint(*mem, 2 ,x     ,y+h   ,0, 0)
      SetPoint(*mem, 3 ,x     ,y+h   ,0, 0)
      SetPoint(*mem, 4 ,x+w   ,y    ,0, 0)
      SetPoint(*mem, 5 ,x+w   ,y+h   ,0, 0)
        
      glBufferData(#GL_ARRAY_BUFFER,size_t,*mem,#GL_DYNAMIC_DRAW)
      glDrawArrays(#GL_TRIANGLES,0, 6)
      
       FreeMemory(*mem)
    EndIf

    Define size_t = (Len(text)+1)*6*SizeOf(FTGL_Point)
    Define *mem = AllocateMemory(size_t)
    For a=1 To Len(text)
      c = Mid(text,a,1)
      *infos = *Me\atlas\metadata[Asc(c)]
      
      x2 = x + *infos\bl * sx
      y2 = -y - *infos\bt * sy
      w = *infos\bw * sx
      h = *infos\bh * sy
      
      ; advance the cursor to the start of the next character
      x+*infos\ax*sx
      y+*infos\ay*sy
      
      ; skip glyphs that have no pixels
      If Not w Or Not h
        Continue
      EndIf
  
      SetPoint(*mem,(a-1)*6  ,x2   ,-y2    ,*infos\tx                                    ,0)
      SetPoint(*mem,(a-1)*6+1,x2+w ,-y2    ,*infos\tx     +*infos\bw/atlas_width         ,0)
      SetPoint(*mem,(a-1)*6+2,x2   ,-y2-h  ,*infos\tx                                    ,*infos\bh/atlas_height)
      SetPoint(*mem,(a-1)*6+3,x2   ,-y2-h  ,*infos\tx                                    ,*infos\bh/atlas_height)
      SetPoint(*mem,(a-1)*6+4,x2+w ,-y2    ,*infos\tx     +*infos\bw/atlas_width         ,0)
      SetPoint(*mem,(a-1)*6+5,x2+w ,-y2-h  ,*infos\tx     +*infos\bw/atlas_width         ,*infos\bh/atlas_height)
      
    Next a
    
    glBufferData(#GL_ARRAY_BUFFER,size_t,*mem,#GL_DYNAMIC_DRAW)
    glDrawArrays(#GL_TRIANGLES,0,Len(text)*6)
    
    FreeMemory(*mem)
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Setup Texture
  ;-------------------------------------------------------------------------------------
  Procedure SetupTexture(*Me.FTGL_Drawer)
    CompilerIf #USE_LEGACY_OPENGL
      glEnable(#GL_TEXTURE_2D)
    CompilerEndIf
        
    glActiveTexture(#GL_TEXTURE0)
    Protected w = *Me\atlas\width
    Protected h = *Me\atlas\height    
    Define img = CreateImage(#PB_Any,w,h,32)
  
    Define x,y
    StartDrawing(ImageOutput(img))
    DrawingMode(#PB_2DDrawing_AllChannels)
    For y=0 To h-1
      For x=0 To w-1
        Plot(x,y,RGBA(255,255,255,PeekA(*Me\atlas\buffer + y * w + x)))
      Next
    Next
    StopDrawing()
    *Me\tex = Texture::Load( img,#False)

;   	glGenTextures(1,@*Me\tex)
;   	glBindTexture(#GL_TEXTURE_2D,*Me\tex)
;   
;   	;prevent artifacts on border
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
;   	
;   	;disable Default 4-byte aligement
;   	glPixelStorei(#GL_UNPACK_ALIGNMENT,1)
;   	glTexImage2D(#GL_TEXTURE_2D,0,#GL_ALPHA,w,h,0,#GL_ALPHA,#GL_UNSIGNED_BYTE,FT_GetAtlasBuffer(*Me\atlas))
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Begin Draw
  ;-------------------------------------------------------------------------------------
  Procedure BeginDraw(*Me.FTGL_Drawer)
    glUseProgram(*Me\shader\pgm)
    glEnable(#GL_BLEND)
    glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
    glDisable(#GL_DEPTH_TEST)
    
    glBindVertexArray(*Me\vao)
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    glUseProgram(*Me\shader\pgm)
    glUniform4fv(glGetUniformLocation(*Me\shader\pgm,"color"),1,*Me\color)
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*Me\tex)
    glUniform1i(glGetUniformLocation(*Me\shader\pgm,"tex"),0)
    glDisable(#GL_CULL_FACE)
    glDisable(#GL_DEPTH_TEST)
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; End Draw
  ;-------------------------------------------------------------------------------------
  Procedure EndDraw(*Me.FTGL_Drawer)
    glEnable(#GL_DEPTH_TEST)
    glDisable(#GL_BLEND)
    glEnable(#GL_DEPTH_TEST)  
    glUseProgram(0)
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Add Atlas 
  ;-------------------------------------------------------------------------------------
  Procedure AddAtlas(filename.s, size_px.i, name.s)
    If Not FindMapElement(*atlases(), name)
      If FileSize(filename) And size_px > 0
        Protected *atlas = FT_CreateFontAtlas(filename,size_px)
        AddMapElement(*atlases(), name)
        *atlases() = *atlas
        ProcedureReturn *atlas
      EndIf
    EndIf
    ProcedureReturn #Null
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Remove Atlas 
  ;-------------------------------------------------------------------------------------
  Procedure RemoveAtlas(name.s)
    If FindMapElement(*atlases(), name)
      Protected *atlas = *atlases()
      FT_DeleteFontAtlas(*atlas)
      DeleteMapElement(*atlases(), name)
    EndIf
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Destructor
  ;-------------------------------------------------------------------------------------
  Procedure Delete(*Me.FTGL_Drawer)
    If *Me\atlas
      FT_DeleteFontAtlas(*Me\atlas)
    EndIf
    
    FreeStructure(*Me)
  EndProcedure
  
  
  ;-------------------------------------------------------------------------------------
  ; Constructor
  ;-------------------------------------------------------------------------------------
  Procedure New()
    Protected *Me.FTGL_Drawer = AllocateStructure(FTGL_Drawer)
    If *ftgl_atlas
      *Me\atlas = *ftgl_atlas
    Else
      *Me\atlas = FT_CreateFontAtlas(FONT_FILE_NAME,32)
    EndIf
    
    *Me\color\r = 1
    *Me\color\a = 1
    *Me\background = #True
    glGenVertexArrays(1,@*Me\vao)
    glBindVertexArray(*Me\vao)
    glGenBuffers(1,@*Me\vbo)
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    Protected vert.s = GetVertexShader()
    Protected frag.s = GetFragmentShader()
    
    *Me\shader = Program::New("FTGL",vert, "",frag)
    glUseProgram(*Me\shader\pgm)
    SetupTexture(*Me)
    Protected attr_coord.GLuint = glGetAttribLocation(*Me\shader\pgm,"coord")
    glEnableVertexAttribArray(attr_coord)
    glVertexAttribPointer(attr_coord,4,#GL_FLOAT,#GL_FALSE,0,#Null)
    
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 434
; FirstLine = 424
; Folding = ----
; EnableXP