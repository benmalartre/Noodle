;============================================================================================
; Shader Module Declararion
;============================================================================================
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/GLFW.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../core/Log.pbi"

DeclareModule Shader
  UseModule GLFW
  
  Enumeration 
    #SHADER_VERTEX
    #SHADER_GEOMETRY
    #SHADER_FRAGMENT
  EndEnumeration
  
  
  Structure Shader_t
    s.s
    path.s
  EndStructure
  
  ;Global GLSL_PATH.s = "D:\Projects\PureBasic\Modules\glsl\"
  If FileSize("../../glsl120")=-2
    If OpenGL::#USE_LEGACY_OPENGL
      Global GLSL_PATH.s = "../../glsl120/"
    Else
      Global GLSL_PATH.s = "../../glsl/"
    EndIf
  
  Else
    If OpenGL::#USE_LEGACY_OPENGL
      Global GLSL_PATH.s = "glsl120/"
    Else
      Global GLSL_PATH.s = "glsl/"
    EndIf
  EndIf

  Declare New(type.i,str.s)
  Declare Delete(*shader.Shader_t)
  Declare.s DeCodeUnicodeShader(unicode.s)
  Declare OutputCompileLog(shader.l)
  Declare Create(*code,type.i,name.s)
  Declare.s LoadFile(filename.s)
EndDeclareModule

;============================================================================================
; Program Module Declararion
;============================================================================================
DeclareModule Program
  Structure Program_t
    *vert.Shader::Shader_t
    *geom.Shader::Shader_t
    *frag.Shader::Shader_t
    
    pgm.l
  EndStructure
  
  Declare New(name.s,s_vert.s="",s_frag.s="")
  Declare NewFromName(name.s)
  Declare Delete(*pgm.Program_t)
  Declare Create(vertex.s, fragment.s, deb.b)
  Declare Create2(vertex.s, geometry.s,fragment.s, deb.b)
  Declare.l Build(*pgm.Program_t,name.s)
EndDeclareModule


;============================================================================================
; Shader Module Implementation
;============================================================================================
Module Shader
  UseModule OpenGLExt
  
  ;-------------------------------------------
  ; Constructor
  ;-------------------------------------------
  Procedure New(type.i,str.s)
    Protected *shader.Shader_t = AllocateMemory(SizeOf(Shader_t))
    *shader\s = str
    *shader\path = ""
    ProcedureReturn *shader
  EndProcedure
 
  
  ;-------------------------------------------
  ; Destructor
  ;-------------------------------------------
  Procedure Delete(*shader.Shader_t)
    FreeMemory(*shader)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Utilities
  ;-----------------------------------------------------------------------------
  ;-------------------------------------------
  ; Translate Shader
  ;-------------------------------------------
  Procedure.s DeCodeUnicodeShader(unicode.s)
    Protected l = StringByteLength(unicode,#PB_Unicode)
    If l>0
      Protected *mem = AllocateMemory(l)
      PokeS(*mem,unicode,-1,#PB_Ascii)
      Protected s.s = PeekS(*mem,l)
      FreeMemory(*mem)
      
      ProcedureReturn s
    Else
      ProcedureReturn ""
    EndIf
    
  EndProcedure
  
  ;-------------------------------------
  ; Output Compile Log
  ;-------------------------------------
  Procedure OutputCompileLog(shader.l)
    Protected buffer = AllocateMemory(512)
    glGetShaderInfoLog(shader,512,#Null,buffer)
  
    CompilerIf #PB_Compiler_Unicode
      Debug PeekS(buffer,512,#PB_Ascii)
    CompilerElse
      Debug PeekS(buffer,512)
    CompilerEndIf
    
    FreeMemory(buffer)
  EndProcedure
  
  ;-------------------------------------
  ; Create GLSL Shader
  ;-------------------------------------
  Procedure Create(*code,type.i,name.s) 
    GLCheckError("Before Creating Shader")
    Protected shader.l = glCreateShader(type)
    GLCheckError("Create Shader : ")
    glShaderSource(shader,1,@*code,#Null)
    GLCheckError("Source Shader : ")
    glCompileShader(shader)
    GLCheckError("Compile Shader : ")
    
    Protected status.i
    glGetShaderiv(shader,OpenGL::#GL_COMPILE_STATUS,@status)
    GLCheckError("Get Shader IV : ")
    If status = #True
      Debug "[GLSLCreateShader] Success Compiling Shader ---> "+name
    Else
      Debug "[GLSLCreateShader] Fail Compiling Shader ---> "+name
    EndIf
    
    ;Output Compile Log
    OutputCompileLog(shader)
    
    ProcedureReturn shader
  EndProcedure
  
  ;-------------------------------------
  ; Load GLSL Shader From File
  ;-------------------------------------
  Procedure.s LoadFile(filename.s)
    If ReadFile(0,filename)
      Protected shader.s
      While Not Eof(0)
        shader + ReadString(0,#PB_Ascii)+Chr(10)
          
      Wend
      
;       Protected length = FileSize(filename)
;       Protected shader.s = ReadString(0,#PB_Ascii|#PB_File_IgnoreEOL,length)
      CloseFile(0) 
    Else
      ProcedureReturn ""
    EndIf
    
    CompilerIf #PB_Compiler_Unicode
      shader = DeCodeUnicodeShader(shader)
    CompilerEndIf
    
    ProcedureReturn shader
  EndProcedure
  
  

EndModule

;============================================================================================
; Program Module Implementation
;============================================================================================
Module Program
  UseModule OpenGLExt
  
  ;-------------------------------------------
  ; Constructor
  ;-------------------------------------------
  Procedure New(name.s,s_vert.s="",s_frag.s="")
    
    Protected *pgm.Program_t = AllocateMemory(SizeOf(Program_t))
    *pgm\vert = Shader::New(OpenGL::#GL_VERTEX_SHADER,s_vert)
    *pgm\frag = Shader::New(OpenGL::#GL_FRAGMENT_SHADER,s_frag)
    *pgm\pgm = Create(*pgm\vert \s, *pgm\frag\s, #True)
    ProcedureReturn *pgm
  EndProcedure
  
  Procedure NewFromName(name.s)
    Protected *pgm.Program_t = AllocateMemory(SizeOf(Program_t))
    Build(*pgm,name)
    ProcedureReturn *pgm
  EndProcedure
  
  ;-------------------------------------------
  ; Destructor
  ;-------------------------------------------
  Procedure Delete(*pgm.Program_t)
    FreeMemory(*pgm)
  EndProcedure
  
  ;--------------------------------------
  ; Create Simple GLSL program
  ;--------------------------------------
  
  Procedure Create(vertex.s, fragment.s, deb.b)
    Protected code.s
    Protected vert.l, frag.l

    vert = Shader::Create(@vertex,OpenGL::#GL_VERTEX_SHADER,"Vertex Shader")
    frag = Shader::Create(@fragment,OpenGL::#GL_FRAGMENT_SHADER,"Fragment Shader")
    
    GLCheckError("Create Shaders : ")
    Protected program.l = glCreateProgram()
    GLCheckError("Create Program : ")
  
    glAttachShader(program,vert)
    GLCheckError("Attach Vertex Shader ")
    
    glAttachShader(program,frag) 
    GLCheckError("Attach Fragment Shader ")
    
;     Protected paramName.s = "position"
;     glBindFragDataLocation(program,0,@paramName)
;     GLCheckError("Bind Frag Data Location ")
;     paramName.s = "normal"
;     glBindFragDataLocation(program,1,@paramName)
;     GLCheckError("Bind Frag Data Location ")
;     paramName.s = "color"
;     glBindFragDataLocation(program,2,@paramName)
;     GLCheckError("Bind Frag Data Location ")
    
    glBindAttribLocation(program,0,"position")
    ;glBindAttribLocation(program,1,"surfacePosAttrib")

    glLinkProgram(program)
    GLCheckError("Link Program : ")
    
    glUseProgram(program)
    GLCheckError("Use Program : ")
    
;     glDetachShader(program,vert)
;     glDetachShader(program,frag)
;     
;     glDeleteShader(vert)
;     glDeleteShader(frag)
   
    Protected *mem = AllocateMemory(1024)
    Protected l.i
    glGetProgramInfoLog(program,1024,@l,*mem)
    Log::Message(OpenGL::GLGETSTRINGOUTPUT(*mem))
    FreeMemory(*mem)
    
     ProcedureReturn program
  EndProcedure
  
  Procedure Create2(vertex.s,geometry.s, fragment.s, deb.b)
    Protected code.s
    Protected vert.l, geom.l, frag.l
  
    vert = Shader::Create(@vertex,OpenGL::#GL_VERTEX_SHADER,"vertex_shader")
    geom = Shader::Create(@geometry,OpenGL::#GL_GEOMETRY_SHADER,"geometry_shader")
    frag = Shader::Create(@fragment,OpenGL::#GL_FRAGMENT_SHADER,"fragment_shader")
    
    GLCheckError("Create Shaders : ")
    Protected program.l = glCreateProgram()
    GLCheckError("Create Program : ")
  
    glAttachShader(program,vert)
    GLCheckError("Attach Vertex Shader ")
    
    glAttachShader(program,geom)
    GLCheckError("Attach Geometry Shader ")
    
    glAttachShader(program,frag) 
    GLCheckError("Attach Fragment Shader ")
    
  ;   Protected paramName.s = "outColor"
  ;   glBindFragDataLocation(program,0,@paramName)
  ;   GLCheckError("Bind Frag Data Location ")
  ;   
    glLinkProgram(program)
    GLCheckError("Link Program : ")
    
    glUseProgram(program)
    GLCheckError("Use Program : ")
    
    ProcedureReturn program
  EndProcedure
  
  Procedure.l Build(*pgm.Program_t,name.s)
    Debug "----------------------------------------"
 
    Define code.s
    Defineerr.b
    code = Shader::LoadFile(Shader::GLSL_PATH+name+"_vertex.glsl")
    *pgm\vert = Shader::Create(@code,OpenGL::#GL_VERTEX_SHADER,name+"_vertex")
    code = Shader::LoadFile(Shader::GLSL_PATH+name+"_fragment.glsl")    
    *pgm\frag = Shader::Create(@code,OpenGL::#GL_FRAGMENT_SHADER,name+"_fragment")
    
    err = GLCheckError("Create Shaders : ")
    *pgm\pgm = glCreateProgram()
    err = GLCheckError("Create Program : ")
  
    glAttachShader(*pgm\pgm,*pgm\vert)
    err = GLCheckError("Attach Vertex Shader ")
    
    glAttachShader(*pgm\pgm,*pgm\frag) 
    err = GLCheckError("Attach Fragment Shader ")
    
    glBindAttribLocation(*pgm\pgm,0,"position")
    
;     glBindFragDataLocation(program,0,"position")
;     GLCheckError("Bind Frag Data Location ")
;     glBindFragDataLocation(program,1,"normal")
;     GLCheckError("Bind Frag Data Location ")
;     glBindFragDataLocation(program,2,"color")
;     GLCheckError("Bind Frag Data Location ")
    
    glLinkProgram(*pgm\pgm)
    err = GLCheckError("Link Program : ")

    glUseProgram(*pgm\pgm)
    err = GLCheckError("Use Program : ")
    
    If err
      Define *mem = AllocateMemory(1024)
      Define l.i
      glGetProgramInfoLog(*pgm\pgm,1024,@l,*mem)
      Log::Message(OpenGL::GLGETSTRINGOUTPUT(*mem))
      FreeMemory(*mem)
    EndIf
    
    GLCheckError("Created Program")
    
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 132
; FirstLine = 120
; Folding = ----
; EnableXP