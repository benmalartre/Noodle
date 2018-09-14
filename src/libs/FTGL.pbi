;=============================================================================
; FTGL Module Declaration
; ============================================================================
; Free Type 2
; ============================================================================
; Copyright 1996-2001, 2006 by                                           
; David Turner, Robert Wilhelm, And Werner Lemberg.                     
;                                                                        
; This file is part of the FreeType project, And may only be used,
; odified, And distributed under the terms of the FreeType project
; license, LICENSE.TXT.  By continuing To use, modify, Or distribute
; this file you indicate that you have Read the license And
; understand And accept it fully
; 

XIncludeFile "OpenGL.pbi"
XIncludeFile "OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "../opengl/Texture.pbi"

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
    width.i
    height.i
    size_px.i
    
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
    vao.GLuint
    vbo.GLuint
    *tex.Texture::Texture_t
    *shader.Program::Program_t
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
    FONT_FILE_NAME = "fontsArial/arial.ttf"
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
    ImportC "..\..\libs\x64\windows\ftgl.lib"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "../../libs/x64/linux/ftgl.a" : EndImport
    ImportC "-lfreetype" : EndImport
    ImportC "../../libs/x64/linux/ftgl.a"
      
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS  
    ;___________________________________________________________________________
    ;  MacOSX
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ImportC "../../libs/x64/macosx/freetype.a" : EndImport
    ImportC "../../libs/x64/macosx/ftgl.a"
  
   CompilerEndIf
    
    FT_CreateFontAtlas(file_name.p-utf8,size_px.i)
    FT_DeleteFontAtlas(*atlas.FTGL_FontAtlas)
  EndImport
  
  Declare Init()
  Declare New()
  Declare AddAtlas(filename.s, size_px.i, name.s)
  Declare RemoveAtlas(name.s)
  Declare Delete(*drawer.FTGL_Drawer)
  Declare SetPoint(*mem,id.i,x.f,y.f,s.f,t.f)
  Declare SetColor(*drawer.FTGL_Drawer,r.f,g.f,b.f,a.f)
  Declare BeginDraw(*drawer.FTGL_Drawer)
  Declare EndDraw(*drawer.FTGL_Drawer)
  Declare Draw(*drawer.FTGL_Drawer,text.s,x.f,y.f,sx.f,sy.f)
  Declare SetupTexture(*drawer.FTGL_Drawer)
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
                "void main(){"+
                "gl_FragColor = vec4(1,1,1,texture2D(tex,texcoord).a)*color;"+;vec4(texture2D(tex, texcoord))*color;"+
                "}"
  Else
    fragment = "#version 330"+#CRLF$+                 
               "in vec2 texcoord;"+
               "out vec4 outColor;"+
               "uniform sampler2D tex;"+
               "uniform vec4 color;"+
               "void main(){"+
               "outColor = vec4(1,1,1,texture(tex,texcoord).a)*color;"+;vec4(texture2D(tex, texcoord))*color;"+
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
  Procedure SetColor(*drawer.FTGL_Drawer,r.f,g.f,b.f,a.f)
    If *drawer
    *drawer\color\r = r
    *drawer\color\g = g
    *drawer\color\b = b
    *drawer\color\a = a
  EndIf
  
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Draw Text
  ;-------------------------------------------------------------------------------------
  Procedure Draw(*drawer.FTGL_Drawer,text.s,x.f,y.f,sx.f,sy.f)
    If Not *drawer Or Not *drawer\atlas 
      ProcedureReturn
    EndIf
    
    Protected n=0
    Protected a
    Protected c.s
    Define.f x2, y2, w, h
    Protected *infos.FTGL_GlyphInfos
    
    Protected size_t = (Len(text))*6*SizeOf(FTGL_Point)
    Define *mem = AllocateMemory(size_t)
    
    Protected atlas_width = *drawer\atlas\width
    Protected atlas_height = *drawer\atlas\height
  
    For a=1 To Len(text)
      c = Mid(text,a,1)
      *infos = *drawer\atlas\metadata[Asc(c)]
      
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
  Procedure SetupTexture(*drawer.FTGL_Drawer)
    GLCheckError("Setup Texture Begin")
    CompilerIf #USE_LEGACY_OPENGL
      glEnable(#GL_TEXTURE_2D)
    CompilerEndIf
    
    GLCheckError("Enable Texture")
    
    glActiveTexture(#GL_TEXTURE0)
    Protected w = *drawer\atlas\width
    Protected h = *drawer\atlas\height
    
    Define img = CreateImage(#PB_Any,w,h,32)
  
    Define x,y
    StartDrawing(ImageOutput(img))
    DrawingMode(#PB_2DDrawing_AllChannels)
    For y=0 To h-1
      For x=0 To w-1
        Plot(x,y,RGBA(255,255,255,PeekA(*drawer\atlas\buffer + y * w + x)))
      Next
    Next
    StopDrawing()
    *drawer\tex = Texture::Load( img,#False)

;   	glGenTextures(1,@*drawer\tex)
;   	glBindTexture(#GL_TEXTURE_2D,*drawer\tex)
;   
;   	;prevent artifacts on border
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
;   	glTexParameteri(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
;   	
;   	;disable Default 4-byte aligement
;   	glPixelStorei(#GL_UNPACK_ALIGNMENT,1)
;   	glTexImage2D(#GL_TEXTURE_2D,0,#GL_ALPHA,w,h,0,#GL_ALPHA,#GL_UNSIGNED_BYTE,FT_GetAtlasBuffer(*drawer\atlas))
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; Begin Draw
  ;-------------------------------------------------------------------------------------
  Procedure BeginDraw(*drawer.FTGL_Drawer)
    glUseProgram(*drawer\shader\pgm)
    glEnable(#GL_BLEND)
    glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
    glDisable(#GL_DEPTH_TEST)
    
    glBindVertexArray(*drawer\vao)
    glBindBuffer(#GL_ARRAY_BUFFER,*drawer\vbo)
    glUseProgram(*drawer\shader\pgm)
    glUniform4fv(glGetUniformLocation(*drawer\shader\pgm,"color"),1,*drawer\color)
    glActiveTexture(#GL_TEXTURE0)
    glBindTexture(#GL_TEXTURE_2D,*drawer\tex)
    glUniform1i(glGetUniformLocation(*drawer\shader\pgm,"tex"),0)
    glDisable(#GL_CULL_FACE)
  EndProcedure
  
  ;-------------------------------------------------------------------------------------
  ; End Draw
  ;-------------------------------------------------------------------------------------
  Procedure EndDraw(*drawer.FTGL_Drawer)
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
  Procedure Delete(*drawer.FTGL_Drawer)
    If *drawer\atlas
      FT_DeleteFontAtlas(*drawer\atlas)
    EndIf
    
    FreeMemory(*drawer)
  EndProcedure
  
  
  ;-------------------------------------------------------------------------------------
  ; Constructor
  ;-------------------------------------------------------------------------------------
  Procedure New()
    Protected *drawer.FTGL_Drawer = AllocateMemory(SizeOf(FTGL_Drawer))
    InitializeStructure(*drawer, FTGL_Drawer)
    If *ftgl_atlas
      *drawer\atlas = *ftgl_atlas
    Else
      *drawer\atlas = FT_CreateFontAtlas(FONT_FILE_NAME,32)
    EndIf

    *drawer\color\r = 1
    *drawer\color\a = 1
    glGenVertexArrays(1,@*drawer\vao)
    glBindVertexArray(*drawer\vao)
    glGenBuffers(1,@*drawer\vbo)
    glBindBuffer(#GL_ARRAY_BUFFER,*drawer\vbo)
    Protected vert.s = GetVertexShader()
    Protected frag.s = GetFragmentShader()
    
    *drawer\shader = Program::New("FTGL",vert, "",frag)
    glUseProgram(*drawer\shader\pgm)
    SetupTexture(*drawer)
    Protected attr_coord.GLuint = glGetAttribLocation(*drawer\shader\pgm,"coord")
    glEnableVertexAttribArray(attr_coord)
    glVertexAttribPointer(attr_coord,4,#GL_FLOAT,#GL_FALSE,0,#Null)
    
    ProcedureReturn *drawer
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 252
; FirstLine = 250
; Folding = ----
; EnableXP
; EnableUnicode