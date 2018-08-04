XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "PolymeshGeometry.pbi"

;==============================================================================
; Null Module Declaration
;==============================================================================
DeclareModule Null
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  
  Enumeration
    #Icon_Default
    #Icon_Sphere
    #Icon_Cube
    #Icon_Disc
    #Icon_None
  EndEnumeration
  
  Structure Null_t Extends Object3D::Object3D_t
    size.f
    icon.i
    nbp.i
    
    ; uniforms
    u_model.GLint
    u_proj.GLint
    u_view.GLint
    u_offset.GLint
    u_color.GLint
    u_selected.GLint
  EndStructure
  
  Interface INull Extends Object3D::IObject3D
  EndInterface
  
  Declare New( name.s = "Null")
  Declare Delete(*Me.Null_t)
  Declare Setup(*Me.Null_t,*shader.Program::Program_t)
  Declare Update(*Me.Null_t)
  Declare Clean(*Me.Null_t)
  Declare Draw(*Me.Null_t)
  Declare SetShader(*Me.Null_t,*pgm.Program::Program_t)
  
  DataSection 
    NullVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_T
  
EndDeclareModule

;==============================================================================
; Null Module Implementation
;==============================================================================
Module Null
  UseModule OpenGL
  UseModule OpenGLExt

  ;----------------------------------------------------------------------------
  ; Echo (Debug)
  ;---------------------------------------------------------------------------- 
  Procedure Echo(*Me.Null_t)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Size
  ;---------------------------------------------------------------------------- 
  Procedure SetSize(*Me.Null_t,size.f)
    If Not *Me : ProcedureReturn : EndIf
    
    *Me\size = size
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Shader
  ;---------------------------------------------------------------------------- 
  Procedure SetShader(*Me.Null_t,*pgm.Program::Program_t)
    If Not *Me : ProcedureReturn : EndIf
    
    *Me\shader = *pgm
    
    *Me\u_model = glGetUniformLocation(*pgm\pgm,"model")
    *Me\u_offset = glGetUniformLocation(*pgm\pgm,"offset")
    *Me\u_color = glGetUniformLocation(*pgm\pgm,"color")
    *Me\u_proj = glGetUniformLocation(*pgm\pgm,"projection")
    *Me\u_view = glGetUniformLocation(*pgm\pgm,"view")
    *Me\u_selected = glGetUniformLocation(*pgm\pgm,"selected")
;     Protected msg.s
;     msg + "Model Uniform : "+Str(*Me\u_model)+Chr(10)
;     msg + "Offset Uniform : "+Str(*Me\u_offset)+Chr(10)
;     msg + "Color Uniform : "+Str(*Me\u_color)+Chr(10)
;     msg + "Projection Uniform : "+Str(*Me\u_proj)+Chr(10)
;     msg + "View Uniform : "+Str(*Me\u_view)+Chr(10)
;     msg + "Selected Uniform : "+Str(*Me\u_selected)+Chr(10)
;     
;     MessageRequester("Null Set Shader",msg)
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Setup OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Setup(*Me.Null_t,*shader.Program::Program_t)
    ; ---[ Sanity Check ]----------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; ---[ Reset Kinematic State ]-------------------
    
    Object3D::ResetStaticKinematicState(*Me)
    Protected shader.i
    ; ---[ Assign Shader ]---------------------------
    If *shader 
      *Me\shader = *shader
      shader = *Me\shader\pgm
      *Me\u_model = glGetUniformLocation(*Me,"model")
      *Me\u_offset = glGetUniformLocation(shader,"offset")
    EndIf
    
    
    ; ---[ Uniforms ]--------------------------------
    Protected hSize.f = *Me\size/2
    Protected pos.v3f32
    Protected theta.f 
    Protected i
    Protected *positions.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    
    Select *Me\icon
      Case #Icon_Default
        
        CArray::SetCount(*positions,6)
        *Me\nbp = 6
        
        Vector3::Set(@pos,-hSize,0,0)
        CArray::SetValue(*positions,0,@pos)
        Vector3::Set(@pos,hSize,0,0)
        CArray::SetValue(*positions,1,@pos)
        Vector3::Set(@pos,0,-hSize,0)
        CArray::SetValue(*positions,2,@pos)
        Vector3::Set(@pos,0,hSize,0)
        CArray::SetValue(*positions,3,@pos)
        Vector3::Set(@pos,0,0,hSize)
        CArray::SetValue(*positions,4,@pos)
        Vector3::Set(@pos,0,0,-hSize)
        CArray::SetValue(*positions,5,@pos)
        
      Case #Icon_Disc
        CArray::SetCount(*positions,22)
        *Me\nbp = 22
        theta.f = 360/22
  
        For i=0 To 21
          Vector3::Set(@pos,Sin(Radian(i*theta))*hSize,0,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
      Case #Icon_Sphere
        CArray::SetCount(*positions,66)
        *Me\nbp = 66
        theta.f = 360/22
  
        ; X Aligned
        For i=0 To 21
          Vector3::Set(@pos,0,Sin(Radian(i*theta))*hSize,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
        ; Y Aligned
        For i=22 To 43
          Vector3::Set(@pos,Sin(Radian(i*theta))*hSize,0,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
        ; Z Aligned
        For i=44 To 65
          Vector3::Set(@pos,Sin(Radian(i*theta))*hSize,Cos(Radian(i*theta))*hSize,0)
          CArray::SetValue(*positions,i,pos)
        Next i
        
    EndSelect
    
    ;Create Or ReUse Vertex Array Object
    If Not *Me\vao
      glGenVertexArrays(1,@*Me\vao)
    EndIf
    glBindVertexArray(*Me\vao)
    
    ; Create or ReUse Vertex Buffer Object
    If Not *Me\vbo
      glGenBuffers(1,@*Me\vbo)
    EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    
    ; Fill Buffer Data
    Protected s.GLfloat
    Protected length.i = CArray::GetItemSize(*positions) * CArray::GetCount(*positions)
    glBufferData(#GL_ARRAY_BUFFER,length,CArray::GetPtr(*positions,0),#GL_STATIC_DRAW)
    
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    
    CArray::Delete(*positions)
      
    *Me\initialized = #True
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Clean OpenGL Context
  ;---------------------------------------------------------------------------- 
  Procedure Clean(*Me.Null_t)
    If *Me\vao : glDeleteVertexArrays(1,@*Me\vao) : EndIf
    If *Me\vbo : glDeleteBuffers(1,@*Me\vbo) : EndIf
    If *Me\eab : glDeleteBuffers(1,@*Me\eab) : EndIf
;     Protected i 
;     For i=0 To ArraySize(*Me\vaos())-1
;       If *Me\vaos(i) : glDeleteVertexArrays(1,@*Me\vaos(i)) : EndIf
;     Next
;     For i=0 To ArraySize(*Me\vbos())-1
;       If *Me\vbos(i) : glDeleteBuffers(1,@*Me\vbos(i)) : EndIf
;     Next
;     For i=0 To ArraySize(*Me\eabs())-1
;       If *Me\eabs(i) : glDeleteBuffers(1,@*Me\eabs(i)) : EndIf
;     Next
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Update OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Update(*Me.Null_t)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;---------------------------------------------------------------------------- 
  Procedure Draw(*n.Null_t)
    ; ---[ Sanity Check ]--------------------------
    If Not *n : ProcedureReturn : EndIf
  
    Protected *t.Transform::Transform_t = *n\globalT
    glBindVertexArray(*n\vao)
   
    glUniformMatrix4fv(glGetUniformLocation(*n\shader\pgm,"model"),1,#GL_FALSE,*t\m)

    
    ; Set Wireframe Color
    If *n\selected
      glUniform3f(*n\u_color,1,1,1)
    Else
      glUniform3f(*n\u_color,*n\wireframe_r,*n\wireframe_g,*n\wireframe_b)
    EndIf
  
    Select *n\icon
      Case #Icon_Default
        glDrawArrays(#GL_LINES,0,*n\nbp)
      Case #Icon_Disc
        glDrawArrays(#GL_LINE_LOOP,0,*n\nbp)
      Case #Icon_Sphere
        Protected i
        For i= 0 To 2:glDrawArrays(#GL_LINE_LOOP,i*22,*n\nbp/3) : Next i
    EndSelect
  
    glBindVertexArray(0)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Pick
  ;---------------------------------------------------------------------------- 
  Procedure Pick(*n.Null_t)
    ; ---[ Sanity Check ]--------------------------
    If Not *n : ProcedureReturn : EndIf
    
    Protected *t.Transform::Transform_t = *n\globalT
    glBindVertexArray(*n\vao)
  
    Select *n\icon
      Case #Icon_Default
        glDrawArrays(#GL_LINES,0,*n\nbp)
      Case #Icon_Disc
        glDrawArrays(#GL_LINE_LOOP,0,*n\nbp)
      Case #Icon_Sphere
        Protected i
        For i= 0 To 2:glDrawArrays(#GL_LINE_LOOP,i*22,*n\nbp/3) : Next i
    EndSelect
    
    glBindVertexArray(0)
    
  ;   glUniformMatrix4fv(glGetUniformLocation(*n\shader,"model"),1,#GL_FALSE,*t\m\m)
  ;   glUniformMatrix4fv(glGetUniformLocation(*n\shader,"view"),1,#GL_FALSE,*view)
  ;   glUniformMatrix4fv(glGetUniformLocation(*n\shader,"projection"),1,#GL_FALSE,*proj)
  ;   
  ;   Protected offset.m4f32_b
  ;   Matrix4_SetIdentity(@offset)
  ;   glUniformMatrix4fv(glGetUniformLocation(*n\shader,"offset"),1,#GL_FALSE,@offset)
  ;   
  ;   Protected id.v3f32
  ;   GLEncodeID(@id,*n\uniqueID)
  ;   glUniform4f(glGetUniformLocation(*n\shader,"color"),id\x,id\y,id\z,1)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ;  Destructor
  ;----------------------------------------------------------------------------
  Procedure Delete( *Me.Null_t )

;     *Me\bbox\InstanceDestroy()
    
    ; ---[ Deallocate Memory ]-------------------------------------------------
    ClearStructure(*Me,Null_t)
    FreeMemory( *Me )
  
  EndProcedure

 
  ;----------------------------------------------------------------------------
  ;  CONSTRUCTORS
  ;----------------------------------------------------------------------------
  ;{
  Procedure.i New( name.s = "Null")
    
    ; ---[ Allocate Object Memory ]--------------------------------------------
    Protected *Me.Null_t = AllocateMemory( SizeOf(Null_t) )
;     *Me\VT = ?NullVT
;     *Me\classname = "NULL"
    Object::INI(Null)
    ; ---[ Initialize Structure ]----------------------------------------------
    InitializeStructure(*Me,Null_t)
    
    ; ---[ Init Members ]------------------------------------------------------
    *Me\type     = Object3D::#Object3D_Null
    *Me\name     = name
    *Me\size     = 1.0
    *Me\icon     = #Icon_Sphere
  
    *Me\wireframe_r = Random(255)/255;
    *Me\wireframe_g = Random(255)/255;
    *Me\wireframe_b = Random(255)/255;
    
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
   
    ;*Me\bbox      = newCBox()
    
    Object3D::Object3D_ATTR()
  
    ; ---[ Return Initialized Object ]-----------------------------------------
    ProcedureReturn *Me 
    
  EndProcedure
  
  ; ---[ Reflection ]----------------------------------------------------------
  Class::DEF( Null )
  
EndModule

;==============================================================================
; EOF
;==============================================================================
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 141
; FirstLine = 120
; Folding = ---
; EnableXP