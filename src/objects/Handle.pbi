XIncludeFile "../core/Control.pbi"
XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Object3D.pbi"
XIncludeFile "../objects/Plane.pbi"
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
    #AXIS_ACTIVE_NONE
    #AXIS_ACTIVE_X
    #AXIS_ACTIVE_Y
    #AXIS_ACTIVE_Z
    #AXIS_ACTIVE_XY
    #AXIS_ACTIVE_XZ
    #AXIS_ACTIVE_YZ
    #AXIS_ACTIVE_ALL
  EndEnumeration

  Enumeration 
    #PLANE_NORMAL_X
    #PLANE_NORMAL_Y
    #PLANE_NORMAL_Z
    #PLANE_NORMAL_CAMERA
  EndEnumeration
  
  ; ----------------------------------------------------------------------------
  ; Structure
  ; ----------------------------------------------------------------------------
  Structure Handle_t Extends Object3D::Object3D_t

    down.b
    tool.i                          ; Active Handle Tool
    posX.i                          ; Window Position X
    posY.i                          ; Window Position Y
    oldX.i                          ; Last Window Position X
    oldY.i                          ; Last Window Position Y

    active_axis.i
    *shape.Shape::Shape_t
    
;     head_selected.b
;     foot_selected.b
;     *head_sphere.Geometry::Sphere_t
;     *foot_sphere.Geometry::Sphere_t
    
    ray.Geometry::Ray_t
    plane.Geometry::Plane_t
    
    *scale_handle.Shape::Shape_t
    *rotate_handle.Shape::Shape_t
    *translate_handle.Shape::Shape_t
    *transform_handle.Shape::Shape_t
    *directed_handle.Shape::Shape_t
    
    distance.f
    scl.f
    radius.f
    
    u_model.GLint
    u_offset.GLint
    u_proj.GLint
    u_view.GLint
    u_color.GLint
    
    *target.Object3D::Object3D_t
    *targets.CArray::CArrayPtr
    *camera.Camera::Camera_t
    *ctx.GLContext::GLContext_t
    
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
  CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
  	shape_cube_positions:
  	Data.GLfloat -0.5,-0.5,-0.5,0
  	Data.GLfloat 0.5,-0.5,-0.5,0
  	Data.GLfloat -0.5,0.5,-0.5,0
  	Data.GLfloat 0.5,0.5,-0.5,0
  	Data.GLfloat -0.5,-0.5,0.5,0
  	Data.GLfloat 0.5,-0.5,0.5,0
  	Data.GLfloat -0.5,0.5,0.5,0
  	Data.GLfloat 0.5,0.5,0.5,0
  	
  	shape_cursor_positions:
  	Data.GLfloat -1,0,0,0
  	Data.GLfloat 1,0,0,0
  	Data.GLfloat 0,-1,0,0
  	Data.GLfloat 0,1,0,0
  CompilerElse
    shape_cube_positions:
  	Data.GLfloat -0.5,-0.5,-0.5
  	Data.GLfloat 0.5,-0.5,-0.5
  	Data.GLfloat -0.5,0.5,-0.5
  	Data.GLfloat 0.5,0.5,-0.5
  	Data.GLfloat -0.5,-0.5,0.5
  	Data.GLfloat 0.5,-0.5,0.5
  	Data.GLfloat -0.5,0.5,0.5
  	Data.GLfloat 0.5,0.5,0.5
    
    shape_cursor_positions:
  	Data.GLfloat -1,0,0
  	Data.GLfloat 1,0,0
  	Data.GLfloat 0,-1,0
  	Data.GLfloat 0,1,0
  	
 CompilerEndIf
  
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
  
  Declare Clean(*Me.Handle_t)
  Declare Update(*Me.Handle_t)
  Declare Pick(*Me.Handle_t)
  Declare ScaleHandle(*Me.Handle_t)
  Declare TransformHandle(*Me.Handle_t)
  Declare TranslateHandle(*Me.Handle_t)
  Declare RotateHandle(*Me.Handle_t)
  Declare DirectedHandle(*Me.Handle_t)
  Declare PickScale(*Me.Handle_t)
  Declare PickRotate(*Me.Handle_t)
  Declare PickTranslate(*Me.Handle_t)
  Declare Resize(*Me.Handle_t,*camera.Camera::Camera_t)
  Declare SetupHandle(*Me.Handle_t,tool.i,*ctx.GLContext::GLContext_t)
  Declare Setup(*Me.Handle_t,*ctx.GLContext::GLContext_t)
  Declare DrawAxis(*Me.Handle_t,r.f,g.f,b.f)
  Declare Draw( *Me.Handle_t,*ctx.GLContext::GLContext_t) 
  Declare Translate(*Me.Handle_t,mx.i,my.i,width.i,height.i)
  Declare Scale(*Me.Handle_t,deltax.i,deltay.i)
  Declare Rotate(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i)
  Declare Transform(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i)
  Declare Directed(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i,*ray.Geometry::Ray_t)
  Declare InitTransform(*Me.Handle_t,*t.Transform::Transform_t)
  Declare InitPickingPlane(*Me.Handle_t, normal_axis.i)
  Declare SetTarget(*Me.Handle_t,*obj.Object3D::Object3D_t)
  Declare AddTarget(*Me.Handle_t,*obj.Object3D::Object3D_t)
  Declare SetTargets(*Me.Handle_t,*objs)
  Declare SetActiveTool(*Me.Handle_t,tool.i)
  Declare SetActiveAxis(*Me.Handle_t,axis.i)
  Declare SetVisible(*Me.Handle_t,visible.b=#True)
  Declare GetTarget(*Me.Handle_t)
  Declare OnEvent(*Me.Handle_t, event.i,  *ev_data.Control::EventTypeDatas_t = #Null)
  Declare Delete(*Me.Handle_t)
  Declare.i New()

  Global CLASS.Class::Class_t

EndDeclareModule

; ============================================================================
;  Handle Module Implementation
; ============================================================================
Module Handle
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;-----------------------------------------------------------------------------
  ; Clean
  ;-----------------------------------------------------------------------------
  Procedure Clean(*Me.Handle_t)
    If *Me\shape\positions<> #Null
      FreeMemory(*Me\shape\positions)
    EndIf
    If *Me\shape\indices<> #Null
      FreeMemory(*Me\shape\indices)
    EndIf
  
  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Update
  ;-----------------------------------------------------------------------------
  Procedure Update(*Me.Handle_t)
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Pick
  ;-----------------------------------------------------------------------------
  Procedure Pick(*Me.Handle_t)
    Select *Me\tool
      Case Globals::#TOOL_TRANSLATE
        PickTranslate(*Me)
        
      Case Globals::#TOOL_ROTATE
        PickRotate(*Me)
        
      Case Globals::#TOOL_SCALE
        PickScale(*Me)
        
    EndSelect
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Scale Handle
  ;-----------------------------------------------------------------------------
  Procedure ScaleHandle(*Me.Handle_t)
    Protected i
    With *Me\scale_handle
      Protected nbp = 8+2
      Protected nbi = 36+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)
      
      Protected offset.m4f32
      
      ;Set Point Position
      Protected scl.v3f32
      Protected p.v3f32
      Matrix4::SetIdentity(offset)
      Vector3::Set(scl,0.25,0.25,0.25)
      Matrix4::SetScale(offset,scl)
      Vector3::Set(p,*Me\radius,0,0)
      Matrix4::SetTranslation(offset,p)
      
      ; Handle Axis
      Vector3::Set(p,0,0,0)
      CArray::SetValue(\positions,0,p)
      Vector3::Set(p,*Me\radius,0,0)
      CArray::SetValue(\positions,1,p)
 
      ; Handle Head
      Protected v.v3f32
      
      Protected *datas = ?shape_cube_positions
      Protected size_p.i = SizeOf(v3f32)
      For i=0 To nbp-3
        Vector3::Set(v,PeekF(*datas +i*size_p),PeekF(*datas+i*size_p+4),PeekF(*datas+i*size_p+8))
        Vector3::MulByMatrix4InPlace(v,offset)
        CArray::SetValue(\positions,i+2,v)
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
    
    *Me\tool = Globals::#Tool_Scale
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Transform Handle
  ;-----------------------------------------------------------------------------
  Procedure TransformHandle(*Me.Handle_t)
    ;Clear(*Me.Handle_t)
    Protected i
    
    With *Me\transform_handle
      Protected nbp = 3
      Protected nbi = 3
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      Protected p.v3f32
      Vector3::Set(p,0,-1,0)
      CArray::SetValue(\positions,0,p)
      Vector3::Set(p,0,0,0)
      CArray::SetValue(\positions,1,p)
      Vector3::Set(p,0,1,0)
      CArray::SetValue(\positions,2,p)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)
      CArray::SetValueL(\indices,2,2)
  
      
    EndWith
    *Me\tool = Globals::#Tool_Transform
    
  EndProcedure
 
  
  ;-----------------------------------------------------------------------------
  ; Translate Handle
  ;-----------------------------------------------------------------------------
  Procedure TranslateHandle(*Me.Handle_t)
  
    Protected i
    Protected div = 12
    
    With *Me\translate_handle
      Protected nbp = 3 + div
      Protected nbi = div*3+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      Protected pos.v3f32
      Vector3::Set(pos,0,0,0)
      CArray::SetValue(\positions,0,pos)

      Vector3::Set(pos,3,0,0)
      CArray::SetValue(\positions,1,pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)
      
      Protected st.f = 360/div
      Define.f x,y
      For i=0 To div-1
        x = Sin(Radian(st*i))
        y = Cos(Radian(st*i))
        Vector3::Set(pos,2.6,x*0.12,y*0.12)
        CArray::SetValue(\positions,i+2,pos)
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
    
    
    
    *Me\tool = Globals::#Tool_Translate
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Rotate Handle
  ;-----------------------------------------------------------------------------
  Procedure RotateHandle(*Me.Handle_t)
    Protected i
    Protected div = 20
    With *Me\rotate_handle
     Protected nbp = 2 + 2*div
      Protected nbi = div*3*2+2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)

      
      Protected pos.v3f32
      Vector3::Set(pos,0,0,0)
      CArray::SetValue(\positions,0,pos)
      
      Vector3::Set(pos,3,0,0)
      CArray::SetValue(\positions,1,pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)

      Protected st.f = 360/div
      Protected size_t = 3*SizeOf(GLint_s)
      Protected offset = 2
      
      Define.f x,y
      For i=0 To div-1
        x = -Sin(Radian(st*i))
        y = Cos(Radian(st*i))
        Vector3::Set(pos,-0.1,x,y)
        CArray::SetValue(\positions,i+2,pos)

        Vector3::Set(pos,0.1,x,y)
        CArray::SetValue(\positions,i+2+div,pos)
        
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
  
    *Me\tool = Globals::#Tool_Rotate
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Directed Handle(Cameras, Lights
  ;-----------------------------------------------------------------------------
  Procedure DirectedHandle(*Me.Handle_t)
  
  
    With *Me\directed_handle
      Protected nbp = 2
      Protected nbi = 2
      Protected GLfloat_s.GLfloat
      Protected GLint_s.GLint
      
      CArray::SetCount(\positions,nbp)
      CArray::SetCount(\indices,nbi)
      
      
      Protected pos.v3f32
      Vector3::Set(pos,0,0,0)
      CArray::SetValue(\positions,0,pos)
      Vector3::Set(pos,0,0,-1)
      CArray::SetValue(\positions,1,pos)
      
      CArray::SetValueL(\indices,0,0)
      CArray::SetValueL(\indices,1,1)

    EndWith
   
    
    *Me\tool = Globals::#TOOL_DIRECTED
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Resize
  ;-----------------------------------------------------------------------------
  Procedure Resize(*Me.Handle_t,*camera.Camera::Camera_t)
    Protected delta.v3f32
    Protected *handle_pos.v3f32 = *Me\localT\t\pos  
    Vector3::Sub(delta,*camera\pos,*handle_pos)
    *Me\distance = Vector3::Length(delta)
    *Me\scl = *Me\distance*Radian(*camera\fov*2)
  EndProcedure
  
  
  ;-----------------------------------------------------------------------------
  ; Setup Handle
  ;-----------------------------------------------------------------------------
  Procedure SetupHandle(*Me.Handle_t,tool.i,*ctx.GLContext::GLContext_t)

    *Me\shader = *ctx\shaders("wireframe")
    glUseProgram(*Me\shader\pgm)
    If Not *Me\vao : glGenVertexArrays(1,@*Me\vao) : EndIf
    glBindVertexArray(*Me\vao)
    
    Protected *shape.Shape::Shape_t = #Null
    Select tool
      Case Globals::#TOOL_SCALE
        *shape = *Me\scale_handle
      Case Globals::#TOOL_ROTATE
        *shape = *Me\rotate_handle
      Case Globals::#TOOL_TRANSLATE
        *shape = *Me\translate_handle
      Case Globals::#TOOL_TRANSFORM
        *shape = *Me\transform_handle
      Case Globals::#TOOL_DIRECTED
        *shape = *Me\directed_handle
      Default
        *shape = *Me\transform_handle
    EndSelect
    
    ; vertex buffer object
    If Not *Me\vbo : glGenBuffers(1,@*Me\vbo) : EndIf
    glBindBuffer(#GL_ARRAY_BUFFER,*Me\vbo)
    glBufferData(#GL_ARRAY_BUFFER,CArray::GetSize(*shape\positions),CArray::GetPtr(*shape\positions,0),#GL_STATIC_DRAW)
    
    ; element array buffer
    If Not *Me\eab : glGenBuffers(1, @*Me\eab) : EndIf
    glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,*Me\eab)
    glBufferData(#GL_ELEMENT_ARRAY_BUFFER,CArray::GetSize(*shape\indices), CArray::GetPtr(*shape\indices,0),#GL_STATIC_DRAW)
    
    ; Attibute Position
    glEnableVertexAttribArray(0)
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      glVertexAttribPointer(0,4,#GL_FLOAT,#GL_FALSE,0,0)
    CompilerElse
      glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,0)
    CompilerEndIf
    
    ; Bind Attributes Locations
    glBindAttribLocation(*Me\shader\pgm,0,"position")

    ; Uniform Attributes
    *Me\u_view.GLint = glGetUniformLocation(*Me\shader\pgm,"view")
    *Me\u_proj.GLint = glGetUniformLocation(*Me\shader\pgm,"projection")
    *Me\u_color.GLint = glGetUniformLocation(*Me\shader\pgm,"color")
    *Me\u_model.GLint = glGetUniformLocation(*Me\shader\pgm,"model")
    *Me\u_offset.GLint = glGetUniformLocation(*Me\shader\pgm,"offset")
        
    glBindVertexArray(0)
    glUseProgram(0)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Setup
  ;-----------------------------------------------------------------------------
  Procedure Setup(*Me.Handle_t,*ctx.GLContext::GLContext_t)
    *Me\ctx = *ctx
    glUseProgram(*ctx\shaders("wireframe")\pgm)
    ;Setup GL
    SetupHandle(*Me,Globals::#TOOL_TRANSLATE,*ctx)
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Draw Axis
  ;-----------------------------------------------------------------------------
  Procedure DrawAxis(*Me.Handle_t,r.f,g.f,b.f)
    Protected GLint_s.GLint
    Protected *shape.Shape::Shape_t
    Select *Me\tool
      Case Globals::#TOOL_TRANSLATE
        *shape = *Me\translate_handle
        glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,0)
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices)-2,#GL_UNSIGNED_INT,8)
      Case Globals::#TOOL_ROTATE
        *shape = *Me\rotate_handle
        glDrawArrays(#GL_LINE_LOOP,2,20)
        glDrawArrays(#GL_LINE_LOOP,22,20)
        glUniform4f(*Me\u_color,r,g,b,0.5)
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices)-2,#GL_UNSIGNED_INT,8)
      Case Globals::#TOOL_SCALE
        *shape = *Me\scale_handle
        glDrawElements(#GL_LINES,2,#GL_UNSIGNED_INT,0)
        glDrawElements(#GL_TRIANGLES,CArray::GetCount(*shape\indices)-2,#GL_UNSIGNED_INT,8)
    EndSelect  
  EndProcedure
  
  ;------------------------------------------------------------
  ; Draw
  ;------------------------------------------------------------
  Procedure Draw( *Me.Handle_t,*ctx.GLContext::GLContext_t) 
    If Not *Me\target : ProcedureReturn : EndIf
    glBindVertexArray(*me\vao)
    
    glEnable(#GL_BLEND)
    glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
  
    glDisable(#GL_CULL_FACE)
    glDisable(#GL_DEPTH_TEST)
    glFrontFace(#GL_CCW)
    
    Protected pos.v3f32
    Protected d.f = *Me\distance/20
    
    Transform::SetScaleFromXYZValues(*Me\globalT,d,d,d)
    Transform::UpdateMatrixFromSRT(*Me\globalT)

    Protected offset.m4f32
    Protected quat.q4f32
    
    glUniformMatrix4fv(*Me\u_model,1,#GL_FALSE,*Me\globalT\m)

    If *Me\tool = Globals::#TOOL_TRANSFORM
      Matrix4::SetIdentity(offset)
      glUniform4f(*Me\u_color,0,1,0,1)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
      glPointSize(5)
      glDrawArrays(#GL_POINTS,0,1)
      glPointSize(10)
      glDrawArrays(#GL_POINTS,1,1)
      glPointSize(5)
      glDrawArrays(#GL_POINTS,2,1)
      glDrawArrays(#GL_LINE_STRIP,0,3)
       
    ElseIf *Me\tool = Globals::#TOOL_DIRECTED
      
      Matrix4::SetIdentity(offset)
      glUniformMatrix4fv(*Me\u_model,1,#GL_FALSE,@offset)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
       Protected *pos.v3f32
       Protected *lookat.v3f32
       Protected *up.v3f32
       Protected dir.v3f32
       Protected scl.v3f32
       Protected *view.m4f32
  
       Select *Me\target\type
         Case Object3D::#Camera
           Protected *camera.Camera::Camera_t = *Me\target
           *pos = *camera\pos
           *lookat = *camera\lookat
           *up = *camera\up
           *view = *camera\globalT\m
           
         Case Object3D::#Light
           Protected *light.Light::Light_t = *Me\target
           *pos = *light\pos
           *lookat = *light\lookat
           *up = *light\up
           *view = *light\globalT\m
           
         Default
           ProcedureReturn
       EndSelect
       
       Vector3::Sub(dir,*lookat,*pos)
      
      Protected l.f = Vector3::Length(dir)
      Protected inv_view.m4f32
  
      Vector3::Set(scl,l,l,l)
      Quaternion::LookAt(quat,dir,*up,#False)
      Transform::SetTranslationFromXYZValues(*Me\localT,*pos\x,*pos\y,*pos\z)
      Transform::SetRotationFromQuaternion(*Me\localT,quat)
      Transform::SetScaleFromXYZValues(*Me\localT,scl\x,scl\y,scl\z)
      
      Transform::UpdateMatrixFromSRT(*Me\localT)

      glUniform4f(*Me\u_color,0,1,0,1)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,*Me\localT\m)
      glUniform4f(*Me\u_color,0.66,0.66,0.66,1)
      glDrawArrays(#GL_LINES,0,2)
      glPointSize(10)
      
;       ; Draw Foot Point
;       If *Me\foot_selected
;         glUniform4f(*Me\u_color,1,0.33,0.33,1)
;       Else
;         glUniform4f(*Me\u_color,1,1,0.33,1)
;       EndIf
;       glDrawArrays(#GL_POINTS,0,1)
;       
;       ; Draw Head Point
;       If *Me\head_selected
;         glUniform4f(*Me\u_color,1,0.33,0.33,1)
;       Else
;         glUniform4f(*Me\u_color,1,1,0.33,1)
;       EndIf
;       glDrawArrays(#GL_POINTS,1,1)
      
    Else
      ; X Axis
      If *Me\active_axis = #AXIS_ACTIVE_X Or *Me\active_axis = #AXIS_ACTIVE_XY Or *Me\active_axis = #AXIS_ACTIVE_XZ Or *Me\active_axis = #AXIS_ACTIVE_All
        glUniform4f(*Me\u_color,1,1,0.33,1)
      Else
        glUniform4f(*Me\u_color,1,0.33,0.33,1)
      EndIf
      Matrix4::SetIdentity(offset)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*Me,1,0,0)
      
      ; Y Axis
      If *Me\active_axis = #AXIS_ACTIVE_Y Or *Me\active_axis = #AXIS_ACTIVE_XY Or *Me\active_axis = #AXIS_ACTIVE_YZ Or *Me\active_axis = #AXIS_ACTIVE_All
        glUniform4f(*Me\u_color,1,1,0.33,1)
      Else
        glUniform4f(*Me\u_color,0.33,1,0.33,1)
      EndIf
      
      Quaternion::SetFromAxisAngleValues(quat,0,0,-1,Radian(90))
      Matrix4::SetFromQuaternion(offset,quat)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*Me,0.33,1,0.33)
      
      ; Z Axis
      If *Me\active_axis = #AXIS_ACTIVE_Z Or *Me\active_axis = #AXIS_ACTIVE_XZ Or *Me\active_axis = #AXIS_ACTIVE_YZ Or *Me\active_axis = #AXIS_ACTIVE_All
        glUniform4f(*Me\u_color,1,1,0.33,1)
      Else
        glUniform4f(*Me\u_color,0.33,0.33,1,1)
      EndIf
      
      Quaternion::SetFromAxisAngleValues(quat,0,1,0,Radian(90))
      Matrix4::SetFromQuaternion(offset,quat)
      glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
      DrawAxis(*Me,0,0,1)
    
    EndIf
    Matrix4::SetIdentity(offset)
    glUniformMatrix4fv(*Me\u_offset,1,#GL_FALSE,@offset)
    glDisable(#GL_BLEND)
    
;     ; Debug Ray Visualy
;     If *Me\ray
;       Protected X.m4f32
;       Protected P.v3f32
;       Protected S.v3f32
;       Vector3::Set(S, 0.01,0.01,0.01)
;       Matrix4::SetIdentity(X)
;       Vector3::Add(P, *Me\ray\origin, *Me\ray\direction)
;       Matrix4::SetScale(X, S)
;       Matrix4::SetTranslation(X, P)
;       glBindVertexArray(*Me\cursor_vao)
;       glPointSize(6)
;       glUniform4f(*Me\u_color,1,1,1,1)
;       glUniformMatrix4fv(*Me\u_model,1,#False,@X)
;       glDrawArrays(#GL_POINTS,0,4)
; ;         Protected X.m4f32
; ;         Protected P.v3f32
; ;         Protected S.v3f32
; ;       Protected plane.Geometry::Plane_t
; ;       Vector3::Set(plane\normal, 0, 1, 0)
; ;       plane\distance = 0
; ;       
; ;       Protected distance.f, frontFacing.b
; ;       If Ray::PlaneIntersection(*Me\ray, @plane, @distance, @frontFacing)
; ;         Debug "PLANE INTERSECTION"
; ;         
; ;         glBindVertexArray(*Me\cursor_vao)
; ;         glPointSize(6)
; ;         Protected X.m4f32
; ;         Protected P.v3f32
; ;         Protected S.v3f32
; ;         
; ;         Vector3::Scale(@P, *Me\ray\direction, distance)
; ;         Vector3::AddInPlace(@P, *Me\ray\origin)
; ;         Vector3::Set(S, 0.05,0.05,0.05)
; ;         Matrix4::SetIdentity(@X)
; ;         Matrix4::SetScale(@X, @S)
; ;         Matrix4::SetTranslation(@X,@P)
; ;         glUniformMatrix4fv(*Me\u_model,1,#False,@X)
; ;         glDrawArrays(#GL_POINTS,0,4)
; ;       EndIf
;       
;     EndIf
    
    glBindVertexArray(0)
   
  EndProcedure
 
  
;   ;-----------------------------------------------------------------------------
;   ; Translate
;   ;-----------------------------------------------------------------------------
;   Procedure Translate(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i)
;     Protected delta.f = (deltax/width +deltay/height) * *Me\scl * 0.5
;     Select *Me\active_axis
;       Case #AXIS_ACTIVE_X
;         Protected x.f = *Me\localT\t\pos\x
;         x+ delta
;         *Me\localT\t\pos\x = x
;         Transform::UpdateMatrixFromSRT(*Me\localT)
;         *Me\globalT\t\pos\x = x
;         Transform::UpdateMatrixFromSRT(*Me\globalT)
;         
;       Case #AXIS_ACTIVE_Y
;         Protected y.f = *Me\localT\t\pos\y
;         y- delta
;        *Me\localT\t\pos\y = y
;         Transform::UpdateMatrixFromSRT(*Me\localT)
;         *Me\globalT\t\pos\y = y
;         Transform::UpdateMatrixFromSRT(*Me\globalT)
;       Case #AXIS_ACTIVE_Z
;         Protected z.f = *Me\localT\t\pos\z
;         z- delta
;         *Me\localT\t\pos\z = z
;         Transform::UpdateMatrixFromSRT(*Me\localT)
;         *Me\globalT\t\pos\z = z
;         Transform::UpdateMatrixFromSRT(*Me\globalT)
;       Case #AXIS_ACTIVE_All
;         If *Me\camera
;           Define plane.Geometry::Plane_t
;           Define nrm.v3f32
;           Camera::GetViewPlaneNormal(*Me\camera, nrm)
;           Plane::Set(plane, nrm, *Me\localT\t\pos)
;           
;           Define ray.Geometry::Ray_t
;           Define p.v3f32
;           Vector3::Set(p, deltax/width, deltay/height, 0)
;           Define view.m4f32 
;           Camera::GetViewTransform(*Me\camera, view)
;           Transform::SetTranslation(*Me\localT, p)
;           Transform::SetTranslation(*Me\globalT, p)
;           
;           Transform::UpdateMatrixFromSRT(*Me\localT)
;           Transform::UpdateMatrixFromSRT(*Me\globalT)
;         EndIf
;         
;     EndSelect
;     
;     If *Me\target <> #Null
;       Protected pos.v3f32 
;       If *Me\target\type = Object3D::#Light
;         Protected *light.Light::Light_t = *Me\target
;   
;         Vector3::SetFromOther(*light\pos,*Me\localT\t\pos)
;         Light::LookAt(*light)
;       ElseIf *Me\target\type = Object3D::#Camera
;         Protected *camera.Camera::Camera_t = *Me\target
;   
;         Vector3::SetFromOther(*camera\pos,*Me\localT\t\pos)
;         Camera::LookAt(*camera)
;       Else
;         Protected *parent.Object3D::Object3D_t = *Me\target\parent
;         Protected *t.Transform::Transform_t = *parent\globalT
;         Protected mat.m4f32
;         Matrix4::Inverse(mat,*t\m)
;      
;         Vector3::MulByMatrix4(pos,*Me\localT\t\pos,mat)
;         Transform::SetTranslationFromXYZValues(*Me\target\localT,pos\x,pos\y,pos\z)
;         Transform::UpdateMatrixFromSRT(*Me\target\localT)
;       EndIf
;     EndIf
;     
;   EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Init Picking Plane
  ;-----------------------------------------------------------------------------
  Procedure InitPickingPlane(*Me.Handle_t, normal_axis.i)
    If *Me\target
      Camera::GetViewPlaneNormal(*Me\camera, *Me\plane\normal)
      Plane::SetOrig(*Me\plane, *Me\target\globalT\t\pos)
    EndIf  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Project On Axis
  ;-----------------------------------------------------------------------------
  Procedure ProjectPickPoint(*Me.Handle_t, *pnt.v3f32)
    Define axis.v3f32
    Select *Me\active_axis
      Case #AXIS_ACTIVE_X
        Vector3::Set(axis, 1,0,0)
        Vector3::ProjectInPlace(*pnt, axis)
      Case #AXIS_ACTIVE_Y
        Vector3::Set(axis, 0,1,0)
        Vector3::ProjectInPlace(*pnt, axis)
      Case #AXIS_ACTIVE_Z
        Vector3::Set(axis, 0,0,1)
        Vector3::ProjectInPlace(*pnt, axis)
    EndSelect
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Translate
  ;-----------------------------------------------------------------------------
  Procedure Translate(*Me.Handle_t,mx.i,my.i,width.i,height.i)
    Camera::MousePositionToRayDirection(*Me\camera, mx, my, width, height, *Me\ray\direction)
    Vector3::SetFromOther(*Me\ray\origin, *Me\camera\pos)
    Define distance.f = #F32_MAX
    If Ray::PlaneIntersection(*Me\ray, *Me\plane, @distance)
      Define hitPoint.v3f32
      Ray::GetIntersectionPoint(*Me\ray, distance, hitPoint)
      Transform::SetTranslation(*Me\localT, hitPoint)
      Transform::SetTranslation(*Me\globalT, hitPoint)
    EndIf
    
    Select *Me\active_axis
      Case #AXIS_ACTIVE_X
        Protected x.f = *Me\localT\t\pos\x
        x+ delta
        *Me\localT\t\pos\x = x
        Transform::UpdateMatrixFromSRT(*Me\localT)
        *Me\globalT\t\pos\x = x
        Transform::UpdateMatrixFromSRT(*Me\globalT)
        
      Case #AXIS_ACTIVE_Y
        Protected y.f = *Me\localT\t\pos\y
        y- delta
       *Me\localT\t\pos\y = y
        Transform::UpdateMatrixFromSRT(*Me\localT)
        *Me\globalT\t\pos\y = y
        Transform::UpdateMatrixFromSRT(*Me\globalT)
      Case #AXIS_ACTIVE_Z
        Protected z.f = *Me\localT\t\pos\z
        z- delta
        *Me\localT\t\pos\z = z
        Transform::UpdateMatrixFromSRT(*Me\localT)
        *Me\globalT\t\pos\z = z
        Transform::UpdateMatrixFromSRT(*Me\globalT)
      Case #AXIS_ACTIVE_All
        If *Me\camera
          Define plane.Geometry::Plane_t
          Define nrm.v3f32
          Camera::GetViewPlaneNormal(*Me\camera, nrm)
          Plane::Set(plane, nrm, *Me\localT\t\pos)
          
          Define ray.Geometry::Ray_t
          Define p.v3f32
          Vector3::Set(p, deltax/width, deltay/height, 0)
          Define view.m4f32 
          Camera::GetViewTransform(*Me\camera, view)
          Transform::SetTranslation(*Me\localT, p)
          Transform::SetTranslation(*Me\globalT, p)
          
          Transform::UpdateMatrixFromSRT(*Me\localT)
          Transform::UpdateMatrixFromSRT(*Me\globalT)
        EndIf
        
    EndSelect
    
    If *Me\target <> #Null
      Protected pos.v3f32 
;       If *Me\target\type = Object3D::#Light
;         Protected *light.Light::Light_t = *Me\target
;   
;         Vector3::SetFromOther(*light\pos,*Me\localT\t\pos)
;         Light::LookAt(*light)
;       ElseIf *Me\target\type = Object3D::#Camera
;         Protected *camera.Camera::Camera_t = *Me\target
;   
;         Vector3::SetFromOther(*camera\pos,*Me\localT\t\pos)
;         Camera::LookAt(*camera)
;       Else
        Protected *parent.Object3D::Object3D_t = *Me\target\parent
        Protected *t.Transform::Transform_t = *parent\globalT
        Protected mat.m4f32
        If *parent : Matrix4::Inverse(mat,*t\m) : Else : Matrix4::SetIdentity(mat) : EndIf
     
        Vector3::MulByMatrix4(pos,*Me\localT\t\pos,mat)
        Transform::SetTranslationFromXYZValues(*Me\target\localT,pos\x,pos\y,pos\z)
        Transform::UpdateMatrixFromSRT(*Me\target\localT)
;       EndIf
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Scale
  ;-----------------------------------------------------------------------------
  Procedure Scale(*Me.Handle_t,deltax.i,deltay.i)
    Protected *s.v3f32= *Me\localT\t\scl
    Protected s2.v3f32
    Protected delta.f = Radian((deltax+deltay)/2)
    
    Select *Me\active_axis
      Case #AXIS_ACTIVE_X
        Vector3::Set(s2,*s\x+delta,*s\y,*s\z)
        Transform::SetScaleFromXYZValues(*Me\localT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetScaleFromXYZValues(*Me\globalT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\globalT)

      Case #AXIS_ACTIVE_Y
        Vector3::Set(s2,*s\x,*s\y+delta,*s\z)
        Transform::SetScaleFromXYZValues(*Me\localT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetScaleFromXYZValues(*Me\globalT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\globalT)
      Case #AXIS_ACTIVE_Z
        Vector3::Set(s2,*s\x,*s\y,*s\z+delta)
        Transform::SetScaleFromXYZValues(*Me\localT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetScaleFromXYZValues(*Me\globalT,s2\x,s2\y,s2\z)
        Transform::UpdateMatrixFromSRT(*Me\globalT)
    EndSelect
    
    If *Me\target <> #Null
      Protected *scl.v3f32 = *Me\localT\t\scl
      Transform::SetScaleFromXYZValues(*Me\target\localT,*scl\x,*scl\y,*scl\z)
      Transform::UpdateMatrixFromSRT(*Me\target\localT)

      Protected *parent.Object3D::Object3D_t = *Me\target\parent
      Protected *t.Transform::Transform_t = *parent\globalT
      Protected mat.m4f32
      Matrix4::Inverse(mat,*t\m)
      Protected scl.v3f32
   
      Vector3::MulByMatrix4(scl,*Me\localT\t\scl,mat)
      Transform::SetScaleFromXYZValues(*Me\target\localT,scl\x,scl\y,scl\z)
      Transform::UpdateMatrixFromSRT(*Me\target\localT)
      *Me\target\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Rotate
  ;-----------------------------------------------------------------------------
  Procedure Rotate(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i)
  
    Protected *q.q4f32= *Me\localT\t\rot
    Protected q2.q4f32,q3.q4f32
    
    Protected out.q4f32
    Protected m.m4f32
    Protected o.m4f32
    Protected axis.v3f32
    
    Select *Me\active_axis
      Case #AXIS_ACTIVE_X
        Quaternion::SetFromAxisAngleValues(q2,1,0,0,Radian((deltax+deltay)/2))
        Quaternion::Multiply(q3,*q,q2)
        Transform::SetRotationFromQuaternion(*Me\localT,q3)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetRotationFromQuaternion(*Me\globalT,q3)
        Transform::UpdateMatrixFromSRT(*Me\globalT)
       
      Case #AXIS_ACTIVE_Y
       Quaternion::SetFromAxisAngleValues(q2,0,1,0,Radian((deltax+deltay)/2))
        Quaternion::Multiply(q3,*q,q2)
        Transform::SetRotationFromQuaternion(*Me\localT,q3)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetRotationFromQuaternion(*Me\globalT,q3)
        Transform::UpdateMatrixFromSRT(*Me\globalT)
        
      Case #AXIS_ACTIVE_Z
        Quaternion::SetFromAxisAngleValues(q2,0,0,1,Radian((deltax+deltay)/2))
        Quaternion::Multiply(q3,*q,q2)
        Transform::SetRotationFromQuaternion(*Me\localT,q3)
        Transform::UpdateMatrixFromSRT(*Me\localT)
        Transform::SetRotationFromQuaternion(*Me\globalT,q3)
        Transform::UpdateMatrixFromSRT(*Me\globalT)
        
    EndSelect
    
   If *Me\target <> #Null
      Protected *parent.Object3D::Object3D_t = *Me\target\parent
      Protected *t.Transform::Transform_t = *parent\globalT
      Protected mat.m4f32
      Matrix4::Inverse(mat,*t\m)
      Protected q.q4f32
      Transform::SetRotationFromQuaternion(*Me\target\localT,*Me\localT\t\rot)
      Transform::UpdateMatrixFromSRT(*Me\target\localT)
      *Me\target\dirty = #True
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Transform
  ;-----------------------------------------------------------------------------
  Procedure Transform(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Directed
  ;-----------------------------------------------------------------------------
  Procedure Directed(*Me.Handle_t,deltax.i,deltay.i,width.i,height.i,*ray.Geometry::Ray_t)
;     If Ray::SphereIntersection(*ray,*Me\foot_sphere) <> -1
;       *Me\foot_selected = #True
;     Else
;       *Me\foot_selected = #False
;     EndIf
;     If Ray::SphereIntersection(*ray,*Me\head_sphere) <> -1
;       *Me\head_selected = #True
;     Else
;       *Me\head_selected = #False
;     EndIf
    
  EndProcedure
  ;-----------------------------------------------------------------------------
  ; Init Transform
  ;-----------------------------------------------------------------------------
  Procedure InitTransform(*Me.Handle_t,*t.Transform::Transform_t)
    Transform::UpdateSRTFromMatrix(*t)
    Transform::SetRotationFromQuaternion(*Me\localT,*t\t\rot)
    Transform::SetTranslation(*Me\localT,*t\t\pos)
    Transform::SetScale(*Me\localT,*t\t\scl)
    
    Transform::SetRotationFromQuaternion(*Me\globalT,*t\t\rot)
    Transform::SetTranslation(*Me\globalT,*t\t\pos)
    Transform::SetScaleFromXYZValues(*Me\globalT,1,1,1)
    
    Transform::UpdateMatrixFromSRT(*Me\localT)
    Transform::UpdateMatrixFromSRT(*Me\globalT)

  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Target
  ;-----------------------------------------------------------------------------
  Procedure SetTarget(*Me.Handle_t,*obj.Object3D::Object3D_t)

    Debug "---------------- Handle Set Target ----------------------------"
    Debug "Target : "+*obj\name
    *Me\target = *obj  
    Debug *obj\name
    Debug *obj\globalT
    InitTransform(*Me,*obj\globalT)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Targets
  ;-----------------------------------------------------------------------------
  Procedure SetTargets(*Me.Handle_t,*objs)
; 
;     Debug "---------------- Handle Set Targets ----------------------------"
;     Debug "Target : "+*obj\name
;     *Me\target = *obj  
;     Debug *obj\name
;     Debug *obj\globalT
;     InitTransform(*h,*obj\globalT)
    Debug "MULTIPLE TARGET NOT IMPLEMENTED!!!"
    *Me\target = #Null
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Add target
  ;-----------------------------------------------------------------------------
  Procedure AddTarget(*Me.Handle_t,*obj.Object3D::Object3D_t)
    CArray::AppendPtr(*Me\targets,*obj)
;     *Me\targets\Append(*obj)
    ;InitMultipleTransform(*h)
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Active Tool
  ;-----------------------------------------------------------------------------
  Procedure SetActiveTool(*Me.Handle_t,tool.i)
    *Me\tool = tool
    Select *Me\tool
      Case Globals::#TOOL_DIRECTED
        If *Me\target
          Select *Me\target\type
            Case Object3D::#Camera
;               Protected *camera.Camera::Camera_t = *Me\target
;               Vector3::SetFromOther(*Me\foot_sphere\center,*camera\pos)
;               Vector3::SetFromOther(*Me\head_sphere\center,*camera\lookat)
            Case Object3D::#Light
;               Protected *light.Light::Light_t = *Me\target
;               Vector3::SetFromOther(*Me\foot_sphere\center,*light\pos)
;               Vector3::SetFromOther(*Me\head_sphere\center,*light\lookat)
          EndSelect
        EndIf
      Case Globals::#TOOL_TRANSLATE
        SetupHandle(*Me, Globals::#TOOL_TRANSLATE, *Me\ctx)
      Case Globals::#TOOL_ROTATE
        SetupHandle(*Me, Globals::#TOOL_ROTATE, *Me\ctx)
      Case Globals::#TOOL_SCALE
        SetupHandle(*Me, Globals::#TOOL_SCALE, *Me\ctx)
      Case Globals::#TOOL_TRANSFORM
        SetupHandle(*Me, Globals::#TOOL_TRANSFORM, *Me\ctx)
    EndSelect
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Active Axis
  ;-----------------------------------------------------------------------------
  Procedure SetActiveAxis(*Me.Handle_t,axis.i)
    *Me\active_axis = axis
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Set Visible
  ;-----------------------------------------------------------------------------
  Procedure SetVisible(*Me.Handle_t,visible.b=#True)
    *Me\visible = visible  
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Get Target
  ;-----------------------------------------------------------------------------
  Procedure GetTarget(*Me.Handle_t)
    ProcedureReturn *Me\target 
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Pick Scale
  ;-----------------------------------------------------------------------------
  Procedure PickScale(*Me.Handle_t)
    Protected enterDistance.f, exitDistance.f
    Protected cylinder.Geometry::Cylinder_t
    Protected pos.v3f32
    Vector3::SetFromOther(cylinder\position, *Me\globalT\t\pos)
    Vector3::Set(cylinder\axis, 1,0,0)
    cylinder\radius = 0.01
    
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_X)
    EndIf
    
    Vector3::Set(cylinder\axis, 0,1,0)
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_Y)
    EndIf

    Vector3::Set(cylinder\axis,0,0,1)
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_Z)
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Pick Rotate
  ;-----------------------------------------------------------------------------
  Procedure PickRotate(*Me.Handle_t)
    Protected enterDistance.f, exitDistance.f
    Protected cylinder.Geometry::Cylinder_t
    Protected pos.v3f32
    Vector3::SetFromOther(cylinder\position, *Me\globalT\t\pos)
    Vector3::Set(cylinder\axis, 0.1,0,0)
    cylinder\radius = 1
    
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_X)
    EndIf
    
    Vector3::Set(cylinder\axis, 0,0.1,0)
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_Y)
    EndIf

    Vector3::Set(cylinder\axis,0,0,0.1)
    If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
      SetActiveAxis(*Me, #AXIS_ACTIVE_Z)
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; Pick Translate
  ;-----------------------------------------------------------------------------
  Procedure PickTranslate(*Me.Handle_t)
    Protected enterDistance.f, exitDistance.f
  
    Protected sphere.Geometry::Sphere_t
    Vector3::SetFromOther(sphere\center, *Me\localT\t\pos)
    sphere\radius = 0.1
    If Ray::SphereIntersection(*Me\ray, sphere)
      SetActiveAxis(*Me, #AXIS_ACTIVE_All)
      Debug "HANDLE : SPHERE INTERSECTION"
    Else
      
      Protected cylinder.Geometry::Cylinder_t
      Protected pos.v3f32
      Vector3::SetFromOther(cylinder\position, *Me\localT\t\pos)
      Vector3::Set(cylinder\axis, 1,0,0)
      cylinder\radius = 0.01
      
      If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
        SetActiveAxis(*Me, #AXIS_ACTIVE_X)
        InitPickingPlane(*Me, #PLANE_NORMAL_Y)
      EndIf
      
      Vector3::Set(cylinder\axis, 0,1,0)
      If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
        SetActiveAxis(*Me, #AXIS_ACTIVE_Y)
         InitPickingPlane(*Me, #PLANE_NORMAL_Z)
      EndIf
  
      Vector3::Set(cylinder\axis,0,0,1)
      If Ray::CylinderIntersection(*Me\ray, cylinder, @enterDistance, @exitDistance)
        SetActiveAxis(*Me, #AXIS_ACTIVE_Z)
         InitPickingPlane(*Me, #PLANE_NORMAL_X)
      EndIf
    EndIf
    
  EndProcedure
  
  ;-----------------------------------------------------------------------------
  ; On Event
  ;-----------------------------------------------------------------------------
  Procedure OnEvent(*Me.Handle_t, event.i,  *ev_data.Control::EventTypeDatas_t = #Null)
    
    Select event
      Case #PB_EventType_LeftButtonDown
        *Me\down = #True
        *Me\oldX = *ev_data\x
        *Me\oldY = *ev_data\y
        InitPickingPlane(*Me, #PLANE_NORMAL_CAMERA)
        
      Case #PB_EventType_LeftButtonUp
        *Me\down = #False
        
      Case #PB_EventType_MouseMove
        If *Me\down
          Select *Me\tool
            Case Globals::#TOOL_TRANSLATE
              ;               Translate(*Me, *ev_data\x - *Me\oldX, *ev_data\y -*Me\oldY, *ev_data\width, *ev_data\height)
              Translate(*Me, *ev_data\x, *ev_data\y, *ev_data\width, *ev_data\height)
;               *Me\oldX = *ev_data\x
;               *Me\oldY = *ev_data\y
          EndSelect
        Else
          Select *Me\tool
            Case Globals::#TOOL_TRANSLATE
              Camera::MousePositionToRayDirection(*Me\camera, *ev_data\x, *ev_data\y, *ev_data\width, *ev_data\height, *Me\ray\direction)
              Vector3::SetFromOther(*Me\ray\origin, *Me\camera\pos)
              PickTranslate(*Me)
          EndSelect
        EndIf
    EndSelect
  EndProcedure
  
  
    
;       Case #PB_EventType_LeftButtonDown
;         modifiers = GetGadgetAttribute(gadget,#PB_OpenGL_Modifiers)
;         If modifiers = #PB_OpenGL_Alt
;           *Me\rmb_p = #True
;         ElseIf modifiers = #PB_OpenGL_Control
;           *Me\mmb_p = #True
;         Else
;           *Me\lmb_p = #True
;         EndIf    
; 
;         *Me\down = #True
;         *Me\oldX = mx
;         *Me\oldY = my
;       
;       Case #PB_EventType_LeftButtonUp
;         *Me\lmb_p = #False
;         *Me\mmb_p = #False
;         *Me\rmb_p = #False 
;         *Me\down = #False
;     
;       Case #PB_EventType_MiddleButtonDown
;         *Me\lmb_p = #False
;         *Me\rmb_p = #False
;         *Me\mmb_p = #True
;         *Me\down = #True
;         *Me\oldX = mx
;         *Me\oldY = my
;         
;       Case #PB_EventType_MiddleButtonUp
;         *Me\mmb_p = #False
;         *Me\down = #False
;         
;       Case #PB_EventType_RightButtonDown
;         *Me\lmb_p = #False
;         *Me\mmb_p = #False
;         *Me\rmb_p = #True
;         *Me\down = #True
;         *Me\oldX = mx
;         *Me\oldY = my
;         
;       Case #PB_EventType_RightButtonUp
;         *Me\rmb_p = #False
;         *Me\down = #False
;         
;       Case #PB_EventType_MouseWheel
;         delta = GetGadgetAttribute(gadget,#PB_OpenGL_WheelDelta)
;         Dolly(*Me,delta*10,delta*10,width,height)
;     EndSelect
   
      
  ;-----------------------------------------------------------------------------
  ; Destuctor
  ;-----------------------------------------------------------------------------
  Procedure Delete(*Me.Handle_t)
    CArray::SetCount(*Me\targets,0)
    CArray::Delete(*Me\targets)
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
    
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)

    *Me\posX = -1
    *Me\posY = -1
    *Me\visible = #False
    *Me\tool = Globals::#TOOL_Select
    *Me\targets = CArray::newCArrayPtr()
    *Me\radius = 5
        
    Protected m.m4f32
    Protected pos.v3f32
  
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
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 920
; FirstLine = 894
; Folding = -------
; EnableXP