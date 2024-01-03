XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "LocatorGeometry.pbi"
XIncludeFile "PolymeshGeometry.pbi"

;==============================================================================
; Locator Module Declaration
;==============================================================================
DeclareModule Locator
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
  
  Structure Locator_t Extends Object3D::Object3D_t
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
  
  Interface ILocator1 Extends Object3D::IObject3D
  EndInterface
  
  Declare New( name.s = "Locator")
  Declare Delete(*Me.Locator_t)
  Declare Setup(*Me.Locator_t)
  Declare Update(*Me.Locator_t)
  Declare Clean(*Me.Locator_t)
  Declare Draw(*Me.Locator_t)
  
  DataSection 
    LocatorVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_T
  
EndDeclareModule

;==============================================================================
; Locator Module Implementation
;==============================================================================
Module Locator
  UseModule OpenGL
  UseModule OpenGLExt

  ;----------------------------------------------------------------------------
  ; Echo (Debug)
  ;---------------------------------------------------------------------------- 
  Procedure Echo(*Me.Locator_t)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Size
  ;---------------------------------------------------------------------------- 
  Procedure SetSize(*Me.Locator_t,size.f)
    If Not *Me : ProcedureReturn : EndIf
    
    *Me\size = size
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Set Shader
  ;---------------------------------------------------------------------------- 
  Procedure SetShader(*Me.Locator_t,*pgm.Program::Program_t)
    If Not *Me : ProcedureReturn : EndIf
        
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
;     MessageRequester("Locator Set Shader",msg)
  EndProcedure
  
  
  ;----------------------------------------------------------------------------
  ; Setup OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Setup(*Me.Locator_t)
    ; ---[ Sanity Check ]----------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    ; ---[ Reset Kinematic State ]-------------------
    
    Object3D::ResetStaticKinematicState(*Me)
    ; ---[ Assign Shader ]---------------------------
;     If *shader 
;       *Me\u_model = glGetUniformLocation(*shader\pgm,"model")
;       *Me\u_offset = glGetUniformLocation(*shader\pgm,"offset")
;     EndIf
    
    
    ; ---[ Uniforms ]--------------------------------
    Protected hSize.f = *Me\size/2
    Protected pos.v3f32
    Protected theta.f 
    Protected i
    Protected *positions.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
    
    Select *Me\icon
      Case #Icon_Default
        
        CArray::SetCount(*positions,6)
        *Me\nbp = 6
        
        Vector3::Set(pos,-hSize,0,0)
        CArray::SetValue(*positions,0,pos)
        Vector3::Set(pos,hSize,0,0)
        CArray::SetValue(*positions,1,pos)
        Vector3::Set(pos,0,-hSize,0)
        CArray::SetValue(*positions,2,pos)
        Vector3::Set(pos,0,hSize,0)
        CArray::SetValue(*positions,3,pos)
        Vector3::Set(pos,0,0,hSize)
        CArray::SetValue(*positions,4,pos)
        Vector3::Set(pos,0,0,-hSize)
        CArray::SetValue(*positions,5,pos)
        
      Case #Icon_Disc
        CArray::SetCount(*positions,22)
        *Me\nbp = 22
        theta.f = 360/22
  
        For i=0 To 21
          Vector3::Set(pos,Sin(Radian(i*theta))*hSize,0,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
      Case #Icon_Sphere
        CArray::SetCount(*positions,66)
        *Me\nbp = 66
        theta.f = 360/22
  
        ; X Aligned
        For i=0 To 21
          Vector3::Set(pos,0,Sin(Radian(i*theta))*hSize,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
        ; Y Aligned
        For i=22 To 43
          Vector3::Set(pos,Sin(Radian(i*theta))*hSize,0,Cos(Radian(i*theta))*hSize)
          CArray::SetValue(*positions,i,pos)
        Next i
        
        ; Z Aligned
        For i=44 To 65
          Vector3::Set(pos,Sin(Radian(i*theta))*hSize,Cos(Radian(i*theta))*hSize,0)
          CArray::SetValue(*positions,i,pos)
        Next i
        
    EndSelect
    
    Object3D::BindVAO(@*Me\vao)
    
    Object3D::BindVBO(@*Me\vbo)
    
    ; Fill Buffer Data
    Protected s.GLfloat
    Protected length.i = CArray::GetItemSize(*positions) * CArray::GetCount(*positions)
    glBufferData(#GL_ARRAY_BUFFER,length,CArray::GetPtr(*positions,0),#GL_STATIC_DRAW)
    
    glEnableVertexAttribArray(0)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
    CompilerElse
      glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    CompilerEndIf
    
    
    CArray::Delete(*positions)
      
    *Me\initialized = #True
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Clean OpenGL Context
  ;---------------------------------------------------------------------------- 
  Procedure Clean(*Me.Locator_t)
    Object3D::DeleteVAO(@*Me\vao)
    Object3D::DeleteVBO(@*Me\vbo)
    Object3D::DeleteEAB(@*Me\eab)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Update OpenGL Object
  ;---------------------------------------------------------------------------- 
  Procedure Update(*Me.Locator_t)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Draw
  ;---------------------------------------------------------------------------- 
  Procedure Draw(*Me.Locator_t)
    ; ---[ Sanity Check ]--------------------------
    If Not *Me : ProcedureReturn : EndIf
  
    Protected *t.Transform::Transform_t = *Me\globalT
    Object3D::BindVAO(@*Me\vao)
   
;     glUniformMatrix4fv(glGetUniformLocation(*Me\shader\pgm,"model"),1,#GL_FALSE,*t\m)

    ; Set Wireframe Color
    If *Me\selected
      glUniform3f(*Me\u_color,1,1,1)
    Else
      glUniform3f(*Me\u_color,*Me\wireframe_r,*Me\wireframe_g,*Me\wireframe_b)
    EndIf
  
    Select *Me\icon
      Case #Icon_Default
        glDrawArrays(#GL_LINES,0,*Me\nbp)
      Case #Icon_Disc
        glDrawArrays(#GL_LINE_LOOP,0,*Me\nbp)
      Case #Icon_Sphere
        Protected i
        For i= 0 To 2:glDrawArrays(#GL_LINE_LOOP,i*22,*Me\nbp/3) : Next i
    EndSelect
  
    glBindVertexArray(0)
  
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ; Pick
  ;---------------------------------------------------------------------------- 
  Procedure Pick(*Me.Locator_t)
    ; ---[ Sanity Check ]--------------------------
    If Not *Me : ProcedureReturn : EndIf
    
    Protected *t.Transform::Transform_t = *Me\globalT
    Object3D::BindVao(@*Me\vao)
  
    Select *Me\icon
      Case #Icon_Default
        glDrawArrays(#GL_LINES,0,*Me\nbp)
      Case #Icon_Disc
        glDrawArrays(#GL_LINE_LOOP,0,*Me\nbp)
      Case #Icon_Sphere
        Protected i
        For i= 0 To 2:glDrawArrays(#GL_LINE_LOOP,i*22,*Me\nbp/3) : Next i
    EndSelect
    
    glBindVertexArray(0)    
    
  ;   glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"model"),1,#GL_FALSE,*t\m\m)
  ;   glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"view"),1,#GL_FALSE,*view)
  ;   glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"projection"),1,#GL_FALSE,*proj)
  ;   
  ;   Protected offset.m4f32_b
  ;   Matrix4_SetIdentity(@offset)
  ;   glUniformMatrix4fv(glGetUniformLocation(*Me\shader,"offset"),1,#GL_FALSE,@offset)
  ;   
  ;   Protected id.v3f32
  ;   GLEncodeID(@id,*Me\uniqueID)
  ;   glUniform4f(glGetUniformLocation(*Me\shader,"color"),id\x,id\y,id\z,1)
  EndProcedure
  
  ;----------------------------------------------------------------------------
  ;  Destructor
  ;----------------------------------------------------------------------------
  Procedure Delete( *Me.Locator_t )

    Object::TERM(Locator)
  
  EndProcedure

 
  ;----------------------------------------------------------------------------
  ;  CONSTRUCTORS
  ;----------------------------------------------------------------------------
  ;{
  Procedure.i New( name.s = "Locator")
    ; ---[ Allocate Object Memory ]--------------------------------------------
    Protected *Me.Locator_t = AllocateMemory( SizeOf(Locator_t) )

    Object::INI(Locator)
    
    ; ---[ Init Members ]------------------------------------------------------
    *Me\type     = Object3D::#Locator
    *Me\name     = name
    *Me\size     = 1.0
    *Me\icon     = #Icon_Sphere
  
    *Me\wireframe_r = Random(255)/255;
    *Me\wireframe_g = Random(255)/255;
    *Me\wireframe_b = Random(255)/255;
    *Me\geom = LocatorGeometry::New(*Me)
    
    Object3D::OBJECT3DATTR()
    
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)

    ; ---[ Return Initialized Object ]-----------------------------------------
    ProcedureReturn *Me 
    
  EndProcedure
  
  ; ---[ Reflection ]----------------------------------------------------------
  Class::DEF( Locator )
  
EndModule

;==============================================================================
; EOF
;==============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 279
; FirstLine = 261
; Folding = ---
; EnableXP