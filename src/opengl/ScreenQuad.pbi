; ============================================================================
; ScreenQuad Declare Module
; ============================================================================
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"


DeclareModule ScreenQuad

  ;---------------------------------------------------
  ; DataSection
  ;---------------------------------------------------
  DataSection
    screenquad_positions:
    Data.f -1,-1
    Data.f  1,-1
    Data.f  1, 1
    Data.f  1, 1
    Data.f -1, 1
    Data.f -1,-1
  
    screenquad_uvs:
    Data.f 0,0
    Data.f 1,0
    Data.f 1,1
    Data.f 1,1
    Data.f 0,1
    Data.f 0,0
  EndDataSection
       
  Structure ScreenQuad_t
    vbo.i
    vao.i
    shader.i
    *pgm.Program::Program_t
  EndStructure
  
  Declare New()
  Declare Delete(*Me.ScreenQuad_t)
  Declare Setup(*Me.ScreenQuad_t,*pgm.Program::Program_t)
  Declare Draw(*Me.ScreenQuad_t)

EndDeclareModule


; ============================================================================
;  ScreenQuad Module IMPLEMENTATION
; ============================================================================
Module ScreenQuad
  UseModule OpenGL
  UseModule OpenGLExt

  ;----------------------------------------------------------------------------
  ; Constructor
  ;----------------------------------------------------------------------------
  Procedure New()
    Protected *Me.ScreenQuad_t = AllocateMemory(SizeOf(ScreenQuad_t))

    ProcedureReturn *Me
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Destructor
  ;----------------------------------------------------------------------------
  Procedure Delete(*Me.ScreenQuad_t)
    glDeleteVertexArrays(1,@*Me\vao)
    glDeleteBuffers(1,@*Me\vbo)
    FreeMemory(*Me)
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Build GL Datas
  ;----------------------------------------------------------------------------
  Procedure BuildGLDatas(*Me.ScreenQuad_t)
    ; Get Quad Datas
    Protected GLfloat_s.GLfloat
    Protected size_t.i = 12 * SizeOf(GLfloat_s)
    
    ; Allocate Memory
    Protected *flatdata = AllocateMemory(2*size_t)
    CopyMemory(?screenquad_positions,*flatdata,size_t)
    CopyMemory(?screenquad_uvs,*flatdata+size_t,size_t)
      
    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,2*size_t,*flatdata,#GL_STATIC_DRAW)
    FreeMemory(*flatdata)
    
     ; Attibute Position
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,2,#GL_FLOAT,#GL_FALSE,0,0)
    
    ;Attibute UVs
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1,2,#GL_FLOAT,#GL_FALSE,0,size_t)
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Setup
  ;----------------------------------------------------------------------------
  Procedure Setup(*Me.ScreenQuad_t,*pgm.Program::Program_t)
    ;Generate Vertex Array Object
    If Not *Me\vao
      glGenVertexArrays(1,@*Me\vao)
    EndIf
    glBindVertexArray(*Me\vao)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *Me\vbo
      glGenBuffers(1,@*Me\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    
    *Me\pgm = *pgm
    
    BuildGLDatas(*Me)
    If *pgm
      glBindAttribLocation(*pgm\pgm, 0, "position")
      glBindAttribLocation(*pgm\pgm, 1, "coords")
      
      glLinkProgram(*pgm\pgm)
    EndIf
    
    
    glBindVertexArray(0)
    
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------
  Procedure Draw(*Me.ScreenQuad_t)
    glBindVertexArray(*Me\vao)
    glDrawArrays(#GL_TRIANGLES,0,6)
    glBindVertexArray(0)
  EndProcedure
 

  
EndModule



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 126
; FirstLine = 78
; Folding = --
; EnableXP