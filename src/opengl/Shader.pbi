;============================================================================================
; Shader Module Declararion
;============================================================================================
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../core/Log.pbi"

DeclareModule Shader  
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
    If OpenGL::#LEGACY_OPENGL
      Global GLSL_PATH.s = "../../glsl120/"
    Else
      Global GLSL_PATH.s = "../../glsl/"
    EndIf
  
  Else
    If OpenGL::#LEGACY_OPENGL
      Global GLSL_PATH.s = "../../../glsl120/"
    Else
      Global GLSL_PATH.s = "../../../glsl/"
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
    name.s
  EndStructure
  
  Declare New(name.s,s_vert.s="",s_geom.s="",s_frag.s="")
  Declare NewFromName(name.s)
  Declare Delete(*pgm.Program_t)
  Declare Create(name.s, vertex.s, geometry.s, fragment.s, deb.b)
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
    Protected *shader.Shader_t = AllocateStructure(Shader_t)
    *shader\s = str
    *shader\path = ""
    ProcedureReturn *shader
  EndProcedure
 
  
  ;-------------------------------------------
  ; Destructor
  ;-------------------------------------------
  Procedure Delete(*shader.Shader_t)
    FreeStructure(*shader)
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
  Procedure New(name.s,s_vert.s="",s_geom.s="",s_frag.s="")
    
    Protected *pgm.Program_t = AllocateStructure(Program_t)
    *pgm\name = name
    *pgm\vert = Shader::New(OpenGL::#GL_VERTEX_SHADER,s_vert)
    *pgm\geom = Shader::New(OpenGL::#GL_GEOMETRY_SHADER, s_geom)
    *pgm\frag = Shader::New(OpenGL::#GL_FRAGMENT_SHADER,s_frag)
    *pgm\pgm = Create(name, *pgm\vert\s, *pgm\geom\s, *pgm\frag\s, #True)
    ProcedureReturn *pgm
  EndProcedure
  
  Procedure NewFromName(name.s)
    Protected *pgm.Program_t = AllocateStructure(Program_t)
    Build(*pgm,name)
    ProcedureReturn *pgm
  EndProcedure
  
  ;-------------------------------------------
  ; Destructor
  ;-------------------------------------------
  Procedure Delete(*pgm.Program_t)
    FreeStructure(*pgm)
  EndProcedure
  
  ;--------------------------------------
  ; Create Simple GLSL program
  ;--------------------------------------
  Procedure Create(name.s, vertex.s, geometry.s, fragment.s, deb.b)
    Protected code.s
    Protected vert.l, geom.l, frag.l
    Protected hasGeometryShader.b
    
    vert = Shader::Create(@vertex,OpenGL::#GL_VERTEX_SHADER,UCase(name)+" Vertex Shader")
    If geometry <> ""
      hasGeometryShader = #True
      geom = Shader::Create(@fragment,OpenGL::#GL_Geometry_SHADER,UCase(name)+" Geometry Shader")
    Else
      hasGeometryShader = #False
    EndIf
    
    frag = Shader::Create(@fragment,OpenGL::#GL_FRAGMENT_SHADER,UCase(name)+" Fragment Shader")
    
    GLCheckError("Create Shaders : ")
    Protected program.l = glCreateProgram()
    GLCheckError("Create Program : ")
  
    glAttachShader(program,vert)
    GLCheckError("Attach Vertex Shader ")
    
    If hasGeometryShader
      glAttachShader(program,geom)
      GLCheckError("Attach Geometry Shader ")
    EndIf
    
    
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
  
  Procedure.l Build(*pgm.Program_t,name.s)
    Define uname.s = UCase(name)
    Define code.s
    Define hasGeometryShader.b = #False
    *pgm\name = name
    code = Shader::LoadFile(Shader::GLSL_PATH+name+"_vertex.glsl")
    *pgm\vert = Shader::Create(@code,OpenGL::#GL_VERTEX_SHADER,name+"_vertex")
    code = Shader::LoadFile(Shader::GLSL_PATH+name+"_geometry.glsl")
    If code:
      *pgm\geom = Shader::Create(@code, OpenGL::#GL_GEOMETRY_SHADER, name+"_geometry")
      hasGeometryShader = #True
    Else
      hasGeometryShader = #False
    EndIf
    
    code = Shader::LoadFile(Shader::GLSL_PATH+name+"_fragment.glsl")    
    *pgm\frag = Shader::Create(@code,OpenGL::#GL_FRAGMENT_SHADER,name+"_fragment")
    
    GLCheckError("Create "+uname+" Shaders : ")
    *pgm\pgm = glCreateProgram()
    GLCheckError("Create "+uname+" Program : ")
  
    glAttachShader(*pgm\pgm,*pgm\vert)
    GLCheckError("Attach "+uname+" Vertex Shader ")
    
    If hasGeometryShader
      glAttachShader(*pgm\pgm,*pgm\geom)
      GLCheckError("Attach "+uname+" Geometry Shader ")
    EndIf
    
    glAttachShader(*pgm\pgm,*pgm\frag) 
    GLCheckError("Attach "+uname+" Fragment Shader ")
    
    Debug *pgm\pgm
    
    glBindAttribLocation(*pgm\pgm,0,"position")
    
    glLinkProgram(*pgm\pgm)
    GLCheckError("Link Program")

    glUseProgram(*pgm\pgm)
    GLCheckError("Use Program")
    
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
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 198
; FirstLine = 194
; Folding = ---
; EnableXP