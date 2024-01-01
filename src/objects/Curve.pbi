XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "CurveGeometry.pbi"

; ============================================================================
;  CURVE MODULE DECLARATION
; ============================================================================
DeclareModule Curve
  Structure Curve_t Extends Object3D::Object3D_t
    deformdirty.b
    topodirty.b
    radius.f
    width.f
    height.f
    depth.f
    u.i
    v.i
  EndStructure
  
  Interface ICurve Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s)
  Declare Delete(*Me.Curve_t)
  Declare Setup(*Me.Curve_t,*ctxt.GLContext::GLContext_t)
  Declare Update(*p.Curve_t,*ctxt.GLContext::GLContext_t)
  Declare Clean(*Me.Curve_t,*ctxt.GLContext::GLContext_t)
  Declare Draw(*Me.Curve_t,*ctxt.GLContext::GLContext_t)
  Declare OnMessage(id.i, *up)
  DataSection 
    CurveVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule


; ============================================================================
;  CURVE MODULE IMPLEMENTATION
; ============================================================================
Module Curve
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  ;-----------------------------------------------------
  ; Echo
  ;-----------------------------------------------------
  Procedure Echo(*Me.Curve_t)
    Debug "Curve Name"+*Me\name
  EndProcedure
  
  Procedure BuildGLDatas(*Me.Curve_t)
    
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Setup (need an valid OpenGL context)
  ;-----------------------------------------------------
  Procedure Setup(*Me.Curve_t, *ctxt.GLContext::GLContext_t)
    ;---[ Check Datas ]--------------------------------
    If *Me = #Null : ProcedureReturn : EndIf
    
    ;---[ Update Operator Stack ]----------------------
    ;Stack::Update(*Me\stack)
    
    ;---[ Get Underlying Geometry ]--------------------
     Protected *geom.Geometry::CurveGeometry_t = *Me\geom
    ;---[ Get Curve Datas ]----------------------------
     Protected size_p.i = *geom\nbsamples * CArray::GetItemSize(*geom\a_positions)
     Protected size_w.i = *geom\nbsamples * CArray::GetItemSize(*geom\a_widths)
     Protected size_t.i = 3 * size_p + size_w
  
    ; Setup Static Kinematic STate
    Object3D::ResetStaticKinematicState(*Me)
    
    ;Attach Shader
;     *Me\shader = *pgm
;     glUseProgram(*Me\shader\pgm)
    
    ;Create Or ReUse Vertex Array Object
    Object3D::BindVaoFOrContext(*Me\vaos(), context, #True)
    
    ; Create or ReUse Vertex Buffer Object
    Object3D::BindVBO(@*Me\vbo)
    
    If *ctxt\share
    
      Protected c.v3f32
      Vector3::Set(c, 0,1,0)
      Protected n.v3f32
      Vector3::Set(n, 1,0,0)
      
      Protected width.f = 0.222
      ; Push Buffer To GPU
      Protected *samples.CArray::CArrayV3F32 = CArray::New(CArray::#ARRAY_V3F32)
      Protected *widths.CArray::CArrayFloat = CArray::New(CArray::#ARRAY_FLOAT)
      CArray::SetCount(*samples, *geom\nbsamples)
      CArray::SetCount(*widths, *geom\nbsamples)
      glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_DYNAMIC_DRAW)
      CurveGeometry::CatmullInterpolatePositions(*geom, *samples)
      glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,CArray::GetPtr(*samples, 0))
      CurveGeometry::CatmullInterpolateColors(*geom, *samples)
      glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*samples, 0))
      CurveGeometry::CatmullInterpolateTangents(*geom, *samples)
      glBufferSubData(#GL_ARRAY_BUFFER,2*size_p,size_p,CArray::GetPtr(*samples, 0))
      CurveGeometry::CatmullInterpolateWidths(*geom, *widths)
      glBufferSubData(#GL_ARRAY_BUFFER,3*size_p,size_w,CArray::GetPtr(*widths, 0))
      
      CArray::Delete(*samples)
      CArray::Delete(*widths)
    EndIf
    
    
    *Me\initialized = #True 
    
    CompilerIf Defined(USE_SSE, #PB_Constant) And #USE_SSE
      Define x = 4
    CompilerElse
      Define x = 3
    CompilerEndIf
    
    ; Attribute Position
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0,x,#GL_FLOAT,#GL_FALSE,0,0)
    
    ; Attribute Color
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(1,x,#GL_FLOAT,#GL_FALSE,0,size_p)
    
    ; Attribute Normal
    glEnableVertexAttribArray(2)
    glVertexAttribPointer(2,x,#GL_FLOAT,#GL_FALSE,0,2*size_p)
    
    ; Attribute Width
    glEnableVertexAttribArray(3)
    glVertexAttribPointer(3,1,#GL_FLOAT,#GL_FALSE,0,3*size_p)
    
    ; Bind Attributes Locations
    Define pgm = GLContext::*SHARED_CTXT\shaders("curve")
    glBindAttribLocation(pgm,0,"position")
    glBindAttribLocation(pgm,1,"color")
    glBindAttribLocation(pgm,2,"tangent")
    glBindAttribLocation(pgm,3,"width")
    
    glBindVertexArray(0)
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; Clean (need an valid OpenGL context)
  ;-----------------------------------------------------
  Procedure Clean(*p.Curve_t,*ctxt.GLContext::GLContext_t)
    If *ctxt\share
      glDeleteBuffers(1, *p\vbo)
    EndIf
    Define key.s = Str(*ctxt)
    If FindMapElement(*p\vaos(), key)
      glDeleteVertexArrays(1,*p\vaos())
      DeleteMapElement(*p\vaos(), key)
    EndIf
    
  EndProcedure
  
  
  ;-----------------------------------------------------
  ; Get Geometry
  ;-----------------------------------------------------
  Procedure GetGeometry(*p.Curve_t)
    ProcedureReturn *p\geom
  EndProcedure
  
  ;-----------------------------------------------------
  ; Update
  ;-----------------------------------------------------
  Procedure Update(*Me.Curve_t,*ctxt.GLContext::GLContext_t)
    If *ctxt\share And *Me\dirty
      CurveGeometry::Update(*Me\geom)
      Protected *geom.Geometry::CurveGeometry_t = *Me\geom
      ; Get Curve Geometry Datas
      Protected s_glfloat.GLfloat
      Protected size_p.i = *geom\nbsamples * CArray::GetItemSize(*geom\a_positions)
      Protected size_w.i = *geom\nbsamples * CArray::GetItemSize(*geom\a_widths)
      Protected size_t.i = 3*size_p + size_w
      
      Object3D::BindVaoFOrContext(*Me\vaos(), *ctxt)
      
      ;Push Buffer To GPU
      glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,CArray::GetPtr(*geom\a_positions, 0))
      glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_p,CArray::GetPtr(*geom\a_colors, 0))
      glBufferSubData(#GL_ARRAY_BUFFER,2*size_p,size_p,CArray::GetPtr(*geom\a_normals, 0))
      glBufferSubData(#GL_ARRAY_BUFFER,3*size_p,size_w,CArray::GetPtr(*geom\a_widths, 0))
      
    EndIf
  EndProcedure
  
  ;-----------------------------------------------------
  ; Draw
  ;-----------------------------------------------------
  Procedure Draw(*Me.Curve_t,*ctxt.GLContext::GLContext_t)
;     Update(*Me)
    If *Me\initialized
      Protected *t.Transform::Transform_t = *Me\globalT
      Protected *geom.Geometry::CurveGeometry_t = *Me\geom
      If Object3D::BindVaoForContext(*Me\vaos(), *ctxt)
        Protected i
        Protected offsetVertex.i, offsetSample.i
        For i = 0 To CArray::GetCount(*geom\a_numSamples) - 1
          glDrawArrays(#GL_LINE_STRIP,offsetSample,CArray::GetValueL(*geom\a_numSamples, i))  
          offsetSample + CArray::GetValueL(*geom\a_numSamples, i)
        Next
        
        GLCheckError("[Curve] Draw Array POINTS")
    
        glBindVertexArray(0)
      EndIf
      
    EndIf
  
  EndProcedure
  
  ;-----------------------------------------------------
  ; Pick
  ;-----------------------------------------------------
  Procedure Pick(*Me.Curve_t,*view.m4f32,*proj.m4f32, shader.i)
    
    Protected *t.Transform::Transform_t = *Me\globalT
    
    ;glBindVertexArray(*p\vao)
    glUniformMatrix4fv(glGetUniformLocation(shader,"model"),1,#GL_FALSE,*t\m)
    glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,Matrix4::IDENTITY())
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*view)
    glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,*proj)
    
    ; Set Wireframe Color
    glUniform4f(glGetUniformLocation(shader,"color"),1,0,0,1)
    glPointSize(5)
    glDisable(#GL_POINT_SMOOTH)
    glDrawArrays(#GL_POINTS,0,Geometry::GetNbPoints(*Me\geom))
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; On Message
  ;----------------------------------------------------
  Procedure OnMessage(id.i,*up)
    Protected *sig.Signal::Signal_t = *up
;     Protected *snd.Object::Object_t = *sig\snd_inst
;     Protected *rcv.Object::Object_t = *sig\rcv_inst
;     
;     Debug "Curve Recieved Message"
;     Debug "Sender Class Name : "+*snd\class\name
;     Debug "Reciever Class Name : "+*rcv\class\name
    
  EndProcedure
  
  ;-----------------------------------------------------
  ; Destructor
  ;----------------------------------------------------
  Procedure Delete(*Me.Curve_t)
    Object3D::DeleteAllAttributes(*Me)
    Stack::Delete(*Me\stack)
    CurveGeometry::Delete(*Me\geom)
    
    ClearStructure(*Me,Curve_t)
    FreeMemory(*Me)
  EndProcedure
  
  ;-----------------------------------------------------
  ; Constructor
  ;----------------------------------------------------
  Procedure New(name.s)
    Protected *Me.Curve_t = AllocateMemory(SizeOf(Curve_t))
    InitializeStructure(*Me,Curve_t)
    Object::INI(Curve)
    
    *Me\name = name
    *Me\geom = CurveGeometry::New(*Me)
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\type = Object3D::#Curve
    
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
   
    
    ; ---[ Attributes ]---------------------------------------------------------
    Protected *curve.Geometry::CurveGeometry_t = *Me\geom
    Object3D::OBJECT3DATTR()
    ; Singleton Attributes
    
    Protected *geom = Attribute::New(*Me,"Geometry",
                                     Attribute::#ATTR_TYPE_GEOMETRY,
                                     Attribute::#ATTR_STRUCT_SINGLE,
                                     Attribute::#ATTR_CTXT_SINGLETON,
                                     *curve,
                                     #True,
                                     #True,
                                     #True)
    Object3D::AddAttribute(*Me,*geom)
    
    ; Singleton Arrays
    Protected *nv = Attribute::New(*Me,"NumVertices",
                                   Attribute::#ATTR_TYPE_LONG,
                                   Attribute::#ATTR_STRUCT_ARRAY,
                                   Attribute::#ATTR_CTXT_SINGLETON,
                                   *curve\a_numVertices,
                                   #True,
                                   #True,
                                   #False)
    Object3D::AddAttribute(*Me,*nv)
    
    ; Per Point Attributes
    Protected *pointposition = Attribute::New(*Me,"PointPosition",
                                              Attribute::#ATTR_TYPE_VECTOR3,
                                              Attribute::#ATTR_STRUCT_SINGLE,
                                              Attribute::#ATTR_CTXT_COMPONENT0D,
                                              *curve\a_positions,
                                              #False,
                                              #False,
                                              #False,
                                              #True,
                                              #True)
    Object3D::AddAttribute(*Me,*pointposition)
    
    Protected *pointnormal = Attribute::New(*Me,"PointNormal",
                                            Attribute::#ATTR_TYPE_VECTOR3,
                                            Attribute::#ATTR_STRUCT_SINGLE,
                                            Attribute::#ATTR_CTXT_COMPONENT0D,
                                            *curve\a_normals,
                                            #False,
                                            #False,
                                            #False,
                                            #True,
                                            #True)
    Object3D::AddAttribute(*Me,*pointnormal)
    
    Protected *pointvelocity = Attribute::New(*Me,"PointVelocity",
                                              Attribute::#ATTR_TYPE_VECTOR3,
                                              Attribute::#ATTR_STRUCT_SINGLE,
                                              Attribute::#ATTR_CTXT_COMPONENT0D,
                                              *curve\a_velocities,
                                              #False,
                                              #False,
                                              #False,
                                              #True,
                                              #True)
    Object3D::AddAttribute(*Me,*pointvelocity)
    
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF( Curve )

EndModule

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 214
; FirstLine = 182
; Folding = ---
; EnableXP