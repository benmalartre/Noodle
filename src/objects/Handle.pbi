XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "Ray.pbi"
; ============================================================================
;  Handle Module Declaration
; ============================================================================
DeclareModule Handle
  UseModule OpenGL
  
  Structure HandleAxis_t
    *head.Shape::Shape_t  
  EndStructure
  
  Enumeration
    #Handle_Active_None
    #Handle_Active_X
    #Handle_Active_Y
    #Handle_Active_Z
    #Handle_Active_XY
    #Handle_Active_XZ
    #Handle_Active_YZ
    #Handle_Active_All
  EndEnumeration


  ; ----------------------------------------------------------------------------
  ;  CCursor Instance
  ; ----------------------------------------------------------------------------
  Structure Handle_t Extends Object3D::Object3D_t

    down.b
    tool.i                          ; Active Handle Tool
    posX.i                          ; Window Position X
    posY.i                          ; Window Position Y
    transform.Transform::Transform_t; REAL SRT
    display.Transform::Transform_t  ; Display SRT
    active_axis.i
    *shape.Shape::Shape_t
    
    head_selected.b
    foot_selected.b
    *head_sphere.Geometry::Sphere_t
    *foot_sphere.Geometry::Sphere_t
    
    scale_vao.GLuint
    rotate_vao.GLuint
    translate_vao.GLuint
    transform_vao.GLuint
    directed_vao.GLuint
    
    *scale_handle.Shape::Shape_t
    *rotate_handle.Shape::Shape_t
    *translate_handle.Shape::Shape_t
    *transform_handle.Shape::Shape_t
    *directed_handle.Shape::Shape_t
    
    distance.f
    scl.f
    
    u_model.GLint
    u_offset.GLint
    u_proj.GLint
    u_view.GLint
    u_color.GLint
    
    *target.Object3D::Object3D_t
    *targets.CArray::CArrayPtr
    
  EndStructure
  
   ;-----------------------------------------------------------------------------
  ; Cube
  ;-----------------------------------------------------------------------------
  #CUBE_NUM_TRIANGLES =12
  #CUBE_NUM_VERTICES =8
  #CUBE_NUM_INDICES =36
  #CUBE_NUM_EDGES =12
  DataSection
    HandleVT:
    
  	shape_cube_positions:
  	Data.GLfloat -0.5,-0.5,-0.5
  	Data.GLfloat 0.5,-0.5,-0.5
  	Data.GLfloat -0.5,0.5,-0.5
  	Data.GLfloat 0.5,0.5,-0.5
  	Data.GLfloat -0.5,-0.5,0.5
  	Data.GLfloat 0.5,-0.5,0.5
  	Data.GLfloat -0.5,0.5,0.5
  	Data.GLfloat 0.5,0.5,0.5
  
  	shape_cube_indices:
  	Data.GLuint 0,2,3
  	Data.GLuint 0,3,1
  	Data.GLuint 0,1,5
  	Data.GLuint 0,5,4
  	Data.GLuint 0,4,6
  	Data.GLuint 0,6,2
  	Data.GLuint 1,3,7
  	Data.GLuint 1,7,5
  	Data.GLuint 2,6,7
  	Data.GLuint 2,7,3
  	Data.GLuint 4,5,7
  	Data.GLuint 4,7,6
  
  	shape_cube_edges:
  	Data.GLuint 0,2
  	Data.GLuint 2,3
  	Data.GLuint 3,1
  	Data.GLuint 1,0
  	Data.GLuint 1,5
  	Data.GLuint 5,4
  	Data.GLuint 4,0
  	Data.GLuint 4,6
  	Data.GLuint 6,2
  	Data.GLuint 3,7
  	Data.GLuint 7,5
  	Data.GLuint 6,7
  
  EndDataSection
  
  Declare Clean(*h.Handle_t)
  Declare Update(*h.Handle_t)
  Declare Pick(*h.Handle_t,*ray.Geometry::Ray_t)
  Declare ScaleHandle(*m.Handle_t)
  Declare TransformHandle(*m.Handle_t)
  Declare TranslateHandle(*m.Handle_t)
  Declare RotateHandle(*m.Handle_t)
  Declare DirectedHandle(*m.Handle_t)
  Declare Resize(*m.Handle_t,*camera.Camera::Camera_t)
  Declare SetupHandle(*m.Handle_t,tool.i,*ctx.GLContext::GLContext_t)
  Declare Setup(*h.Handle_t,*ctx.GLContext::GLContext_t)
  Declare DrawAxis(*m.Handle_t,r.f,g.f,b.f)
  Declare Draw( *m.Handle_t,*ctx.GLContext::GLContext_t) 
  Declare Translate(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  Declare Scale(*m.Handle_t,deltax.i,deltay.i)
  Declare Rotate(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  Declare Transform(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  Declare Directed(*m.Handle_t,deltax.i,deltay.i,width.i,height.i,*ray.Geometry::Ray_t)
  Declare InitTransform(*h.Handle_t,*t.Transform::Transform_t)
  Declare SetTarget(*h.Handle_t,*obj.Object3D::Object3D_t)
  Declare AddTarget(*h.Handle_t,*obj.Object3D::Object3D_t)
  Declare SetActiveTool(*h.Handle_t,tool.i)
  Declare SetActiveAxis(*h.Handle_t,axis.i)
  Declare SetVisible(*h.Handle_t,visible.b=#True)
  Declare GetTarget(*h.Handle_t)
  Declare Delete(*m.Handle_t)
  Declare.i New()

  Global CLASS.Class::Class_t

EndDeclareModule

Module Handle
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  ;=============================================================================
  ;  IMPLEMENTATION
  ;=============================================================================
  
  Procedure Clean(*h.Handle_t)
    If *h\shape\positions<> #Null
      FreeMemory(*h\shape\positions)
    EndIf
    If *h\shape\indices<> #Null
      FreeMemory(*h\shape\indices)
    EndIf
  
  EndProcedure
  
  Procedure Update(*h.Handle_t)
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Pick
  ;-----------------------------------------------------------------------------
  Procedure Pick(*h.Handle_t,*ray.Geometry::Ray_t)
    Select *h\tool
;       Case Globals::#TOOL_TRANSLATE
        
    EndSelect
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Scale Handle
  ;-----------------------------------------------------------------------------
  Procedure ScaleHandle(*m.Handle_t)
    ;Clear(*m.Handle_t)
    Protected i
    With *m\scale_handle
      Protected nbp = 8+2
      Protected nbi = 36+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)
      
      Protected offset.m4f32
      
      ;Set Point Position
      Protected scl.v3f32
      Matrix4::SetIdentity(@offset)
      Vector3::Set(@scl,0.1,0.1,0.1)
      Matrix4::SetScale(@offset,@scl)
      
      ; Handle Axis
      Protected p.v3f32
      Vector3::Set(@p,0,0,0)
      CArray::SetValue(\positions,@p,0)
      Vector3::Set(@p,3,0,0)
      CArray::SetValue(\positions,@p,1)
 
      ; Handle Head
      Protected v.v3f32
      
      Protected *datas = ?shape_cube_positions
      Protected size_p.i = 12
      For i=0 To nbp-3
        Vector3::Set(@v,PeekF(*datas +i*size_p)+30,PeekF(*datas+i*size_p+4),PeekF(*datas+i*size_p+8))
        Vector3::Echo(@v, "BEFORE")
        Vector3::MulByMatrix4InPlace(@v,@offset)
        Vector3::Echo(@v, "AFTER")
        CArray::SetValue(\positions,i+2,@v)
      Next i
      
      ; Set Triangle Indices Array
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)
      
      Protected oldID
      For i=0 To nbi-3
        oldID = PeekL(?shape_cube_indices+(i)*SizeOf(GLint_s))
        CArray::SetValueL(\indices,i+2,oldID+2)
      Next i
      
      
      \nbp = CArray::GetCount(\positions)
      \nbt = (CArray::GetCount(\indices)-2)/3
    
    EndWith
    
    *m\tool = Globals::#Tool_Scale
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Transform Handle
  ;-----------------------------------------------------------------------------
  Procedure TransformHandle(*m.Handle_t)
    ;Clear(*m.Handle_t)
    Protected i
    
    With *m\transform_handle
      Protected nbp = 3
      Protected nbi = 3
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      Protected p.v3f32
      Vector3::Set(@p,0,-1,0)
      CArray::SetValue(\positions,0,@p)
      Vector3::Set(@p,0,0,0)
      CArray::SetValue(\positions,1,@p)
      Vector3::Set(@p,0,1,0)
      CArray::SetValue(\positions,2,@p)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)
      CArray::SetValueL(\indices,2,2)
  
      
    EndWith
    *m\tool = Globals::#Tool_Transform
    
  EndProcedure
 
  
  ;-----------------------------------------------------------------------------
  ; Translate Handle
  ;-----------------------------------------------------------------------------
  Procedure TranslateHandle(*m.Handle_t)
  
    Protected i
    Protected div = 12
    
    With *m\translate_handle
      Protected nbp = 3 + div
      Protected nbi = div*3+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      Protected pos.v3f32
      Vector3::Set(@pos,0,0,0)
      CArray::SetValue(\positions,0,@pos)

      Vector3::Set(@pos,3,0,0)
      CArray::SetValue(\positions,1,@pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)
      
      Protected st.f = 360/div
      Define.f x,y
      For i=0 To div-1
        x = Sin(Radian(st*i))
        y = Cos(Radian(st*i))
        Vector3::Set(@pos,2.6,x*0.12,y*0.12)
        CArray::SetValue(\positions,i+2,@pos)
        CArray::SetValueL(\indices,i*3+2,i+2)

        If i = div-1
          CArray::SetValueL(\indices,i*3+3,2)
        Else
          CArray::SetValueL(\indices,i*3+3,i+3)
        EndIf
        CArray::SetValueL(\indices,i*3+4,1)
      Next i
      \nbp = CArray::GetCount(\positions)
      \nbt = CArray::GetCount(\indices)-2*3
    EndWith
    
    
    
    *m\tool = Globals::#Tool_Translate
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Rotate Handle
  ;-----------------------------------------------------------------------------
  Procedure RotateHandle(*m.Handle_t)
    Protected i
    Protected div = 20
    With *m\rotate_handle
     Protected nbp = 2 + 2*div
      Protected nbi = div*3*2+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      
      Protected pos.v3f32
      Vector3::Set(@pos,0,0,0)
      CArray::SetValue(\positions,0,@pos)
      
      Vector3::Set(@pos,3,0,0)
      CArray::SetValue(\positions,1,@pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)

      Protected st.f = 360/div
      Protected size_t = 3*SizeOf(GLint_s)
      Protected offset = 2
      
      Define.f x,y
      For i=0 To div-1
        x = -Sin(Radian(st*i))
        y = Cos(Radian(st*i))
        Vector3::Set(@pos,-0.1,x,y)
        CArray::SetValue(\positions,i+2,@pos)

        Vector3::Set(@pos,0.1,x,y)
        CArray::SetValue(\positions,i+2+div,@pos)
        
        CArray::SetValueL(\indices,offset,i+2)
        offset + 1
        CArray::SetValueL(\indices,offset,i+3)
        offset + 1
        CArray::SetValueL(\indices,offset,i+div+2)
        offset + 1
        CArray::SetValueL(\indices,offset,i+div+2)
        offset + 1
        If i <div-1
          CArray::SetValueL(\indices,offset,i+3)
          offset + 1
          CArray::SetValueL(\indices,offset,i+div+3)
          offset + 1
        Else
          CArray::SetValueL(\indices,offset,2)
          offset + 1
          CArray::SetValueL(\indices,offset,div+2)
          offset + 1
        EndIf
  
      Next i
      
      \nbp = CArray::GetCount(\positions)
      \nbt = CArray::GetCount(\indices)-2
      
    EndWith
  
    *m\tool = Globals::#Tool_Rotate
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Directed Handle(Cameras, Lights
  ;-----------------------------------------------------------------------------
  Procedure DirectedHandle(*m.Handle_t)
  
  
    With *m\directed_handle
      Protected nbp = 2
      Protected nbi = 2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)
      
      
      Protected pos.v3f32
      Vector3::Set(@pos,0,0,0)
      CArray::SetValue(\positions,0,@pos)
      Vector3::Set(@pos,0,0,-1)
      CArray::SetValue(\positions,1,@pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)

    EndWith
   
    
    *m\tool = Globals::#TOOL_DIRECTED
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Resize
  ;-----------------------------------------------------------------------------
  Procedure Resize(*m.Handle_t,*camera.Camera::Camera_t)
    
    Protected delta.v3f32
    Protected *handle_pos.v3f32 = *m\transform\t\pos  
    Vector3::Sub(@delta,*camera\pos,*handle_pos)
    *m\distance = Vector3::Length(@delta)
    *m\scl = *m\distance*Radian(*camera\fov)
  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Setup Handle
  ;-----------------------------------------------------------------------------
  Procedure SetupHandle(*m.Handle_t,tool.i,*ctx.GLContext::GLContext_t)
    *m\shader = *ctx\shaders("wireframe")
    glUseProgram(*m\shader\pgm)
    Protected *shape.Shape::Shape_t = #Null
    Select tool
      Case Globals::#TOOL_SCALE
        glGenVertexArrays(1,@*m\scale_vao)
        glBindVertexArray(*m\scale_vao)
        *shape = *m\scale_handle
      Case Globals::#TOOL_ROTATE
        glGenVertexArrays(1,@*m\rotate_vao)
        glBindVertexArray(*m\rotate_vao)
        *shape = *m\rotate_handle
      Case Globals::#TOOL_TRANSLATE
        glGenVertexArrays(1,@*m\translate_vao)
        glBindVertexArray(*m\translate_vao)
        *shape = *m\translate_handle
      Case Globals::#TOOL_TRANSFORM
        glGenVertexArrays(1,@*m\transform_vao)
        glBindVertexArray(*m\transform_vao)
        *shape = *m\transform_handle
      Case Globals::#TOOL_DIRECTED
        glGenVertexArrays(1,@*m\directed_vao)
        glBindVertexArray(*m\directed_vao)
        *shape = *m\directed_handle
      Default
        glGenVertexArrays(1,@*m\transform_vao)
        glBindVertexArray(*m\transform_vao)
        *shape = *m\transform_handle
    EndSelect
    
    
    
    Protected vbo.GLint
    glGenBuffers(1,@vbo)
    glBindBuffer(#GL_ARRAY_BUFFER,vbo)
    Protected GLfloat_s.GLfloat
   
    Protected size_t =*shape\nbp*SizeOf(GLfloat_s)*3

    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,size_t,CArray::GetPtr(*shape\positions,0),#GL_DYNAMIC_DRAW)
    
    ; Attibute Position
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Uniform Attributes
    *m\u_view.GLint = glGetUniformLocation(*m\shader\pgm,"view")
    *m\u_proj.GLint = glGetUniformLocation(*m\shader\pgm,"projection")
    *m\u_color.GLint = glGetUniformLocation(*m\shader\pgm,"color")
    *m\u_model.GLint = glGetUniformLocation(*m\shader\pgm,"model")
    *m\u_offset.GLint = glGetUniformLocation(*m\shader\pgm,"offset")
        
    glBindVertexArray(0)
    glUseProgram(0)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Setup
  ;-----------------------------------------------------------------------------
  Procedure Setup(*h.Handle_t,*ctx.GLContext::GLContext_t)
  
    
    ;Setup GL
    SetupHandle(*h,Globals::#TOOL_SCALE,*ctx)
    SetupHandle(*h,Globals::#TOOL_ROTATE,*ctx)
    SetupHandle(*h,Globals::#TOOL_TRANSLATE,*ctx)
    SetupHandle(*h,Globals::#TOOL_TRANSFORM,*ctx)
    SetupHandle(*h,Globals::#TOOL_DIRECTED,*ctx)
  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Draw Axis
  ;-----------------------------------------------------------------------------
  Procedure DrawAxis(*m.Handle_t,r.f,g.f,b.f)
    
    Protected GLint_s.GLint
    Protected *shape.Shape::Shape_t
    
    Select *m\tool
      Case Globals::#TOOL_TRANSLATE
        *shape = *m\translate_handle
        glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,CArray::GetPtr(*shape\indices,0))
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices)-2,#GL_UNSIGNED_INT,CArray::GetPtr(*shape\indices,2))
      Case Globals::#TOOL_ROTATE
        *shape = *m\rotate_handle
        glDrawArrays(#GL_LINE_LOOP,2,20)
        glDrawArrays(#GL_LINE_LOOP,22,20)
        glUniform4f(*m\u_color,r,g,b,0.5)
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices),#GL_UNSIGNED_INT,CArray::GetPtr(*shape\indices,2))
      Case Globals::#TOOL_SCALE
        *shape = *m\scale_handle
        glPointSize(3)
        glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,CArray::GetPtr(*shape\indices,0))
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices)-2,#GL_UNSIGNED_INT,CArray::GetPtr(*shape\indices,2))  
    EndSelect  
  EndProcedure
  
  ;------------------------------------------------------------
  ; Draw
  ;------------------------------------------------------------
  Procedure Draw( *m.Handle_t,*ctx.GLContext::GLContext_t) 
    If Not *m\target : ProcedureReturn : EndIf
    
    Select *m\tool
      Case Globals::#TOOL_SCALE
        glBindVertexArray(*m\scale_vao)
      Case Globals::#TOOL_ROTATE
        glBindVertexArray(*m\rotate_vao)
      Case Globals::#TOOL_TRANSLATE
        glBindVertexArray(*m\translate_vao)
      Case Globals::#TOOL_TRANSFORM
        glBindVertexArray(*m\transform_vao)
      Case Globals::#TOOL_DIRECTED
        glBindVertexArray(*m\directed_vao)
    EndSelect
    
    
    glEnable(#GL_BLEND)
    glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
    glEnable(#GL_POINT_SMOOTH)
  
    glDisable(#GL_CULL_FACE)
    Protected pos.v3f32
    Protected d.f = *m\distance/20
    
    Transform::SetScaleFromXYZValues(*m\display,d,d,d)
    Transform::UpdateMatrixFromSRT(*m\display)

    
    Protected offset.m4f32
    Protected quat.q4f32
  
    glUniformMatrix4fv(*m\u_model,1,#GL_FALSE,*m\display\m)

    If *m\tool = Globals::#TOOL_TRANSFORM
      Matrix4::SetIdentity(@offset)
      glUniform4f(*m\u_color,0,1,0,1)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
      glPointSize(5)
      glDrawArrays(#GL_POINTS,0,1)
      glPointSize(10)
      glDrawArrays(#GL_POINTS,1,1)
      glPointSize(5)
      glDrawArrays(#GL_POINTS,2,1)
      glDrawArrays(#GL_LINE_STRIP,0,3)
       
    ElseIf *m\tool = Globals::#TOOL_DIRECTED
      
      Matrix4::SetIdentity(@offset)
      glUniformMatrix4fv(*m\u_model,1,#GL_FALSE,@offset)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
       Protected *pos.v3f32
       Protected *lookat.v3f32
       Protected *up.v3f32
       Protected dir.v3f32
       Protected scl.v3f32
       Protected *view.m4f32
  
       Select *m\target\type
         Case Object3D::#Object3D_Camera
           Protected *camera.Camera::Camera_t = *m\target
           *pos = *camera\pos
           *lookat = *camera\lookat
           *up = *camera\up
           *view = *camera\globalT\m
           
         Case Object3D::#Object3D_Light
           Protected *light.Light::Light_t = *m\target
           *pos = *light\pos
           *lookat = *light\lookat
           *up = *light\up
           *view = *light\globalT\m
           
         Default
           ProcedureReturn
       EndSelect
       
       Vector3::Sub(@dir,*lookat,*pos)
      
      Protected l.f = Vector3::Length(@dir)
      Protected inv_view.m4f32
  
      Vector3::Set(@scl,l,l,l)
      Quaternion::LookAt(@quat,@dir,*up)
      Transform::SetTranslationFromXYZValues(*m\transform,*pos\x,*pos\y,*pos\z)
      Transform::SetRotationFromQuaternion(*m\transform,@quat)
      Transform::SetScaleFromXYZValues(*m\transform,scl\x,scl\y,scl\z)
      
      Transform::UpdateMatrixFromSRT(*m\transform)

      glUniform4f(*m\u_color,0,1,0,1)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,*m\transform\m)
      glUniform4f(*m\u_color,0.66,0.66,0.66,1)
      glDrawArrays(#GL_LINES,0,2)
      glPointSize(10)
      
      ; Draw Foot Point
      If *m\foot_selected
        glUniform4f(*m\u_color,1,0.33,0.33,1)
      Else
        glUniform4f(*m\u_color,1,1,0.33,1)
      EndIf
      glDrawArrays(#GL_POINTS,0,1)
      
      ; Draw Head Point
      If *m\head_selected
        glUniform4f(*m\u_color,1,0.33,0.33,1)
      Else
        glUniform4f(*m\u_color,1,1,0.33,1)
      EndIf
      glDrawArrays(#GL_POINTS,1,1)
      
    Else
      ; X Axis
      If *m\active_axis = #Handle_Active_X Or *m\active_axis = #Handle_Active_XY Or *m\active_axis = #Handle_Active_XZ Or *m\active_axis = #Handle_Active_All
        glUniform4f(*m\u_color,1,1,0.33,1)
      Else
        glUniform4f(*m\u_color,1,0.33,0.33,1)
      EndIf
      Matrix4::SetIdentity(@offset)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*m,1,0,0)
      
      ; Y Axis
      If *m\active_axis = #Handle_Active_Y Or *m\active_axis = #Handle_Active_XY Or *m\active_axis = #Handle_Active_YZ Or *m\active_axis = #Handle_Active_All
        glUniform4f(*m\u_color,1,1,0.33,1)
      Else
        glUniform4f(*m\u_color,0.33,1,0.33,1)
      EndIf
      
      Quaternion::SetFromAxisAngleValues(@quat,0,0,-1,Radian(90))
      Matrix4::SetFromQuaternion(@offset,@quat)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*m,0.33,1,0.33)
      
      ; Z Axis
      If *m\active_axis = #Handle_Active_Z Or *m\active_axis = #Handle_Active_XZ Or *m\active_axis = #Handle_Active_YZ Or *m\active_axis = #Handle_Active_All
        glUniform4f(*m\u_color,1,1,0.33,1)
      Else
        glUniform4f(*m\u_color,0.33,0.33,1,1)
      EndIf
      
      Quaternion::SetFromAxisAngleValues(@quat,0,1,0,Radian(90))
      Matrix4::SetFromQuaternion(@offset,@quat)
      glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*m,0,0,1)
    
    EndIf
    Matrix4::SetIdentity(@offset)
    glUniformMatrix4fv(*m\u_offset,1,#GL_FALSE,@offset)
    glDisable(#GL_BLEND)
    
    glBindVertexArray(0)
  ;   glUseProgram(0)
   
  EndProcedure
 
  
  ;-----------------------------------------------------------------------------
  ; Translate
  ;-----------------------------------------------------------------------------
  Procedure Translate(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  ;   Protected *t.CTransform = newCTransform()
    Protected delta.f = (deltax+deltay)/width * *m\scl
    Select *m\active_axis
      Case #Handle_Active_X
         Protected x.f = *m\transform\t\pos\x
        x+ delta
        *m\transform\t\pos\x = x
        Transform::UpdateMatrixFromSRT(*m\transform)
        *m\display\t\pos\x = x
        Transform::UpdateMatrixFromSRT(*m\display)
        
      Case #Handle_Active_Y
        Protected y.f = *m\transform\t\pos\y
        y- delta
       *m\transform\t\pos\y = y
        Transform::UpdateMatrixFromSRT(*m\transform)
        *m\display\t\pos\y = y
        Transform::UpdateMatrixFromSRT(*m\display)
      Case #Handle_Active_Z
        Protected z.f = *m\transform\t\pos\z
        z- delta
        *m\transform\t\pos\z = z
        Transform::UpdateMatrixFromSRT(*m\transform)
        *m\display\t\pos\z = z
        Transform::UpdateMatrixFromSRT(*m\display)
    EndSelect
    
    If *m\target <> #Null
      Protected pos.v3f32 
      If *m\target\type = Object3D::#Object3D_Light
        Protected *light.Light::Light_t = *m\target
  
        Vector3::SetFromOther(*light\pos,*m\transform\t\pos)
        Light::LookAt(*light)
      ElseIf *m\target\type = Object3D::#Object3D_Camera
        Protected *camera.Camera::Camera_t = *m\target
  
        Vector3::SetFromOther(*camera\pos,*m\transform\t\pos)
        Camera::LookAt(*camera)
      Else
        Protected *parent.Object3D::Object3D_t = *m\target\parent
        Protected *t.Transform::Transform_t = *parent\globalT
        Protected mat.m4f32
        Matrix4::Inverse(@mat,*t\m)
     
        Vector3::MulByMatrix4(@pos,*m\transform\t\pos,@mat)
        Transform::SetTranslationFromXYZValues(*m\target\localT,pos\x,pos\y,pos\z)
        Transform::UpdateMatrixFromSRT(*m\target\localT)
      EndIf
  
    Else
      Debug "OHandle Translate No Target Object"
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Scale
  ;-----------------------------------------------------------------------------
  Procedure Scale(*m.Handle_t,deltax.i,deltay.i)
    Protected *s.v3f32= *m\transform\t\scl
    Protected s2.v3f32
    Protected delta.f = Radian((deltax+deltay)/2)
    
    Select *m\active_axis
      Case #Handle_Active_X
        Vector3::Set(@s2,*s\x+delta,*s\y,*s\z)
        Transform::SetScaleFromXYZValues(*m\transform,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetScaleFromXYZValues(*m\display,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\display)

      Case #Handle_Active_Y
        Vector3::Set(@s2,*s\x,*s\y+delta,*s\z)
        Transform::SetScaleFromXYZValues(*m\transform,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetScaleFromXYZValues(*m\display,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\display)
      Case #Handle_Active_Z
        Vector3::Set(@s2,*s\x,*s\y,*s\z+delta)
        Transform::SetScaleFromXYZValues(*m\transform,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetScaleFromXYZValues(*m\display,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*m\display)
    EndSelect
    
    If *m\target <> #Null
      Protected *scl.v3f32 = *m\transform\t\scl
      Transform::SetScaleFromXYZValues(*m\target\localT,*scl\x,*scl\y,*scl\z)
      Transform::UpdateMatrixFromSRT(*m\target\localT)

      Protected *parent.Object3D::Object3D_t = *m\target\parent
      Protected *t.Transform::Transform_t = *parent\globalT
      Protected mat.m4f32
      Matrix4::Inverse(@mat,*t\m)
      Protected scl.v3f32
   
      Vector3::MulByMatrix4(@scl,*m\transform\t\scl,@mat)
      Transform::SetScaleFromXYZValues(*m\target\localT,scl\x,scl\y,scl\z)
      Transform::UpdateMatrixFromSRT(*m\target\localT)
      *m\target\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Rotate
  ;-----------------------------------------------------------------------------
  Procedure Rotate(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  
    Protected *q.q4f32= *m\transform\t\rot
    Protected q2.q4f32,q3.q4f32
    
    Protected out.q4f32
    Protected m.m4f32
    Protected o.m4f32
    Protected axis.v3f32
    
    Select *m\active_axis
      Case #Handle_Active_X
        Quaternion::SetFromAxisAngleValues(@q2,1,0,0,Radian((deltax+deltay)/2))
        Quaternion::Multiply(@q3,*q,@q2)
        Transform::SetRotationFromQuaternion(*m\transform,@q3)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetRotationFromQuaternion(*m\display,@q3)
        Transform::UpdateMatrixFromSRT(*m\display)
       
      Case #Handle_Active_Y
       Quaternion::SetFromAxisAngleValues(@q2,0,1,0,Radian((deltax+deltay)/2))
        Quaternion::Multiply(@q3,*q,@q2)
        Transform::SetRotationFromQuaternion(*m\transform,@q3)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetRotationFromQuaternion(*m\display,@q3)
        Transform::UpdateMatrixFromSRT(*m\display)
        
      Case #Handle_Active_Z
        Quaternion::SetFromAxisAngleValues(@q2,0,0,1,Radian((deltax+deltay)/2))
        Quaternion::Multiply(@q3,*q,@q2)
        Transform::SetRotationFromQuaternion(*m\transform,@q3)
        Transform::UpdateMatrixFromSRT(*m\transform)
        Transform::SetRotationFromQuaternion(*m\display,@q3)
        Transform::UpdateMatrixFromSRT(*m\display)
        
    EndSelect
    
   If *m\target <> #Null
      Protected *parent.Object3D::Object3D_t = *m\target\parent
      Protected *t.Transform::Transform_t = *parent\globalT
      Protected mat.m4f32
      Matrix4::Inverse(@mat,*t\m)
      Protected q.q4f32
      Transform::SetRotationFromQuaternion(*m\target\localT,*m\transform\t\rot)
      Transform::UpdateMatrixFromSRT(*m\target\localT)
      *m\target\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Transform
  ;-----------------------------------------------------------------------------
  Procedure Transform(*m.Handle_t,deltax.i,deltay.i,width.i,height.i)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Directed
  ;-----------------------------------------------------------------------------
  Procedure Directed(*m.Handle_t,deltax.i,deltay.i,width.i,height.i,*ray.Geometry::Ray_t)
    If Ray::SphereIntersection(*ray,*m\foot_sphere) <> -1
      *m\foot_selected = #True
    Else
      *m\foot_selected = #False
    EndIf
    If Ray::SphereIntersection(*ray,*m\head_sphere) <> -1
      *m\head_selected = #True
    Else
      *m\head_selected = #False
    EndIf
    
  EndProcedure
  ;-----------------------------------------------------------------------------
  ; Init Transform
  ;-----------------------------------------------------------------------------
  Procedure InitTransform(*h.Handle_t,*t.Transform::Transform_t)
  
    Transform::UpdateSRTFromMatrix(*t)
    Transform::SetRotationFromQuaternion(*h\transform,*t\t\rot)
    Transform::SetTranslation(*h\transform,*t\t\pos)
    Transform::SetScale(*h\transform,*t\t\scl)
    
    Transform::SetRotationFromQuaternion(*h\display,*t\t\rot)
    Transform::SetTranslation(*h\display,*t\t\pos)
    Transform::SetScaleFromXYZValues(*h\display,1,1,1)
    
    Transform::UpdateMatrixFromSRT(*h\transform)
    Transform::UpdateMatrixFromSRT(*h\display)

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Target
  ;-----------------------------------------------------------------------------
  Procedure SetTarget(*h.Handle_t,*obj.Object3D::Object3D_t)

    Debug "---------------- Handle Set Target ----------------------------"
    Debug "Target : "+*obj\name
    *h\target = *obj  
    InitTransform(*h,*obj\globalT)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add target
  ;-----------------------------------------------------------------------------
  Procedure AddTarget(*h.Handle_t,*obj.Object3D::Object3D_t)
    CArray::AppendPtr(*h\targets,*obj)
;     *h\targets\Append(*obj)
    ;InitMultipleTransform(*h)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Active Tool
  ;-----------------------------------------------------------------------------
  Procedure SetActiveTool(*h.Handle_t,tool.i)
  
    *h\tool = tool
    Select *h\tool
      Case Globals::#TOOL_DIRECTED
        If *h\target
          Select *h\target\type
            Case Object3D::#Object3D_Camera
              Protected *camera.Camera::Camera_t = *h\target
              Vector3::SetFromOther(*h\foot_sphere\p_center,*camera\pos)
              Vector3::SetFromOther(*h\head_sphere\p_center,*camera\lookat)
            Case Object3D::#Object3D_Light
              Protected *light.Light::Light_t = *h\target
              Vector3::SetFromOther(*h\foot_sphere\p_center,*light\pos)
              Vector3::SetFromOther(*h\head_sphere\p_center,*light\lookat)
          EndSelect
        EndIf
    EndSelect
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Active Axis
  ;-----------------------------------------------------------------------------
  Procedure SetActiveAxis(*h.Handle_t,axis.i)
    *h\active_axis = axis
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Visible
  ;-----------------------------------------------------------------------------
  Procedure SetVisible(*h.Handle_t,visible.b=#True)
    *h\visible = visible  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Target
  ;-----------------------------------------------------------------------------
  Procedure GetTarget(*h.Handle_t)
    ProcedureReturn *h\target 
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Destuctor
  ;-----------------------------------------------------------------------------
  Procedure Delete(*m.Handle_t)
    CArray::SetCount(*m\targets,0)
    CArray::Delete(*m\targets)
    ClearStructure(*m,Handle_t)
    FreeMemory(*m)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------

  Procedure.i New()
    Protected *Me.Handle_t = AllocateMemory(SizeOf(Handle_t))
    Object::INI( Handle )
    InitializeStructure(*Me,Handle_t)
  
    *Me\posX = -1
    *Me\posY = -1
    *Me\visible = #False
    *Me\tool = Globals::#TOOL_Select
    *Me\targets = CArray::newCArrayPtr()
    
    Protected m.m4f32
    Protected pos.v3f32
    ;nesCSlot(@*Me\sig_onchanged, *Me )
  
    *Me\scale_handle = Shape::New(Shape::#Shape_axis)
    ScaleHandle(*Me)
    *Me\rotate_handle = Shape::New(Shape::#Shape_axis)
    RotateHandle(*Me)
    *Me\translate_handle = Shape::New(Shape::#Shape_axis)
    TranslateHandle(*Me)
    *Me\transform_handle = Shape::New(Shape::#Shape_axis)
    TransformHandle(*Me)
    *Me\directed_handle = Shape::New(Shape::#Shape_axis)
    DirectedHandle(*Me)
    
;     *Me\head_sphere = Sphere::New(@pos,0.5)
;     *Me\foot_sphere = Sphere::New(@pos,0.5)

    *Me\target = #Null
    
    TranslateHandle(*Me)
     
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(Handle)
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 551
; FirstLine = 526
; Folding = -----
; EnableXP