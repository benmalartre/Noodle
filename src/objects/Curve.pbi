XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "Shapes.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "PolymeshGeometry.pbi"

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
  
  Declare New(name.s,shape.i)
  Declare Delete(*Me.Curve_t)
  Declare Setup(*Me.Curve_t,*shader.Program::Program_t)
  Declare Update(*Me.Curve_t)
  Declare Clean(*Me.Curve_t)
  Declare Draw(*Me.Curve_t)
  Declare SetFromShape(*Me.Curve_t,shape.i)
  Declare TestClass(*Me.Curve_t)
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
;  IMPLEMENTATION ( CCurve )
; ============================================================================
;-----------------------------------------------------
; Log
;-----------------------------------------------------
;{
Procedure OCurve_Log(*Me.CCurve_t)
  ;Debug "PointCloud Name"+*Me\name
  
EndProcedure
;}

;-----------------------------------------------------
; Setup (need an valid OpenGL context)
;-----------------------------------------------------
;{
Procedure OCurve_Setup(*c.CCurve_t,*ctx.GLContext_t)

  ;---[ Check Datas ]--------------------------------
  CHECK_PTR1_NULL(*c)
  
  ;---[ Update Operator Stack ]----------------------
  OStack_Update(*c\stack)
  
  ;---[ Get Underlying Geometry ]--------------------
   Protected *geom.CCurveGeometry_t = *c\geometry

  ;---[ Get Curve Datas ]----------------------------
   Protected s_glfloat.GLfloat
   Protected size_p.i = *geom\a_positions\GetCount() * *geom\a_positions\GetItemSize()
   Protected size_s.i =  *geom\a_samples\GetCount() * *geom\a_samples\GetItemSize()

   Protected size_t = size_p + size_s
  
  ; Setup Static Kinematic STate
  O3DObject_ResetStaticKinematicState(*c)
  
  ;Attach Shader
  *c\shader = *ctx\s_wireframe
  
  ;Create Or ReUse Vertex Array Object
  If Not *c\vaos(*ctx\ID)
    glGenVertexArrays(1,@*c\vaos(*ctx\ID))
  EndIf
  glBindVertexArray(*c\vaos(*ctx\ID))
  
  ; Create or ReUse Vertex Buffer Object
  If Not *c\vbos(*ctx\ID)
    glGenBuffers(1,@*c\vbos(*ctx\ID))
  EndIf
  glBindBuffer(#GL_ARRAY_BUFFER,*c\vbos(*ctx\ID))
 
  ; Push Buffer To GPU
  glBufferData(#GL_ARRAY_BUFFER,size_t,#Null,#GL_STREAM_DRAW)
  glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,*geom\a_positions\GetPtr(0))
  glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_s,*geom\a_samples\GetPtr(0))
  *c\initialized = #True 
  
  ; Attribute Position
  Protected uPosition.GLint = glGetAttribLocation(*c\shader,"position")
  glEnableVertexAttribArray(uPosition)
  glVertexAttribPointer(uPosition,3,#GL_FLOAT,#GL_FALSE,0,0)
  
  glBindVertexArray(0)
  
EndProcedure
;}

;-----------------------------------------------------
; Clean (need an valid OpenGL context)
;-----------------------------------------------------
;{
Procedure OCurve_Clean(*p.CCurve_t)
  glDeleteBuffers(ArraySize(*p\vbos()),*p\vbos(0))
;   glDeleteVertexArrays(1,*p\vao)
EndProcedure


;-----------------------------------------------------
; Get Geometry
;-----------------------------------------------------
;{
Procedure OCurve_GetGeometry(*p.CCurve_t)
  ProcedureReturn *p\geometry
EndProcedure
;}

;-----------------------------------------------------
; Update
;-----------------------------------------------------
;{
Procedure OCurve_Update(*p.CCurve_t,*ctx.GLContext_t)
  If *p\dirty
    OCurveGeometry_Update(*p\geometry)
    Protected *geom.CCurveGeometry_t = *p\geometry
    ; Get Point Cloud Datas
    Protected s_glfloat.GLfloat
    Protected size_p.i = *geom\a_positions\GetCount() * *geom\a_positions\GetItemSize()
    Protected size_s.i = *geom\a_samples\GetCount() * *geom\a_samples\GetItemSize()
    glBindVertexArray(*p\vaos(*ctx\ID))
    glBindBuffer(#GL_ARRAY_BUFFER,*p\vbos(*ctx\ID))
    
    ;Push Buffer To GPU
    glBufferSubData(#GL_ARRAY_BUFFER,0,size_p,*geom\a_positions\GetPtr())
    glBufferSubData(#GL_ARRAY_BUFFER,size_p,size_s,*geom\a_samples\GetPtr())
  EndIf
  
 
EndProcedure

;}


;-----------------------------------------------------
; Draw
;-----------------------------------------------------
;{
Procedure OCurve_Draw(*p.CCurve_t,*ctx.GLContext_t)
  
  OCurve_Update(*p,*ctx)
  If *p\initialized
    Protected *t.CTransform_t = *p\global
    Protected *geom.CCurveGeometry_t = *p\geometry
    
    glBindVertexArray(*p\vaos(*ctx\ID))
    
    Protected id.v3f32
    GLEncodeID(@id,*p\uniqueID)
    glUniform1i(glGetUniformLocation(*ctx\shader,"selectionMode"),0)
    glUniform1i(glGetUniformLocation(*ctx\shader,"selected"),*p\selected)
    glUniform3f(glGetUniformLocation(*ctx\shader,"uniqueID"),id\x,id\y,id\z)
    glUniform3f(glGetUniformLocation(*ctx\shader,"color"),1,1,1)
    glUniformMatrix4fv(glGetUniformLocation(*ctx\shader,"model"),1,#GL_FALSE,*t\m)
    
    Protected offset.m4f32_b
    Matrix4_SetIdentity(@offset)
    glUniformMatrix4fv(glGetUniformLocation(*ctx\shader,"offset"),1,#GL_FALSE,@offset)

    
    ;glDisable(#GL_DEPTH_TEST)
    glPointSize(2)
    
    ;Push Array To Screen
    Protected GLfloat_s.GLfloat
    Protected poffset = *geom\a_positions\GetCount() * *geom\a_positions\GetItemSize()
    If *geom\closed
      glDrawArrays(#GL_LINE_LOOP, *geom\a_positions\GetCount(),*geom\a_samples\GetCount())
      ;glDrawArrays(#GL_POINTS,*geom\a_positions\GetCount(),*geom\a_samples\GetCount())
    Else
      glDrawArrays(#GL_LINE_STRIP, *geom\a_positions\GetCount(),*geom\a_samples\GetCount())
      ;glDrawArrays_(#GL_POINTS,*geom\a_positions\GetCount(),*geom\a_samples\GetCount())
    EndIf
    
    glPointSize(2)
    glUniform3f(glGetUniformLocation(*p\shader,"color"),1,0,0)
    
    glDrawArrays(#GL_POINTS,0,*geom\a_positions\GetCount())
    ;glEnable(#GL_DEPTH_TEST)
  
    glBindVertexArray(0)
  EndIf

EndProcedure
;}

;-----------------------------------------------------
; Pick
;-----------------------------------------------------
;{
Procedure OCurve_Pick(*p.CCurve_t,*view.m4f32,*proj.m4f32)
  
  Protected *t.CTransform_t = *p\global
  
  ;glBindVertexArray(*p\vao)
  glUniformMatrix4fv(glGetUniformLocation(*p\shader,"model"),1,#GL_FALSE,*t\m)
  glUniformMatrix4fv(glGetUniformLocation(*p\shader,"view"),1,#GL_FALSE,*view)
  glUniformMatrix4fv(glGetUniformLocation(*p\shader,"projection"),1,#GL_FALSE,*proj)
  
  ; Set Wireframe Color
  ;glUniform3f(*p\m_color,*p\wireframe_r,*p\wireframe_g,*p\wireframe_b)
  glPointSize(5)
  glDisable(#GL_POINT_SMOOTH)
  glDrawArrays(#GL_LINE,0,*p\geometry\GetNbPoints())
  
EndProcedure
;}

;_____________________________________________________________________________
;  Destructor
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;{
; ---[ _Free ]----------------------------------------------------------------
Procedure OCurve_Free( *Me.CCurve_t )
  
  ; ---[ Deallocate Internals Arrays ]----------------------------------------
  C3DObject_TERM(Curve)
  *Me\geometry\InstanceDestroy()
  
  ; ---[ Deallocate Memory ]--------------------------------------------------
  ClearStructure(*Me,CCurve_t)
  FreeMemory( *Me )

EndProcedure
;}
;}


; ============================================================================
;  VTABLE ( CC3DObject + CCurve )
; ============================================================================
;{
DataSection
  ; C3DObject
  C3DObject_DAT (Curve)
  ;Mandatory Override
  Data.i @OCurve_Setup()
  Data.i @OCurve_Clean()
  Data.i @OCurve_Update()
  Data.i @OCurve_Draw()
  Data.i @OCurve_Pick()
  
  ; CCurve
  Data.i @OCurve_GetGeometry()

EndDataSection
;}

; ============================================================================
;  REFLECTION
; ============================================================================
;{
; ----------------------------------------------------------------------------
;  CCurve Object
; ----------------------------------------------------------------------------
Class_DEF( Curve )
;}


; ============================================================================
;  CONSTRUCTORS
; ============================================================================
;{
; ---[ Stack ]----------------------------------------------------------------
Procedure.i nesCCurve( *Me.CCurve_t,name.s="Curve",nbPoints.i=0)
  
  ; ---[ Sanity Check ]-------------------------------------------------------
  CHECK_PTR1_NULL( *Me )
  
  ; ---[ Initialize Structure ]------------------------------------------------
  InitializeStructure(*Me,CCurve_t)
  
  ; ---[ Init CObject Base Class ]--------------------------------------------
  C3DObject_INI( Curve )
  
  ; ---[ Init Members ]-------------------------------------------------------
  *Me\type     = #RAA_3DObject_Curve
  *Me\name     = name

  *Me\bbox      = newCBox()
  *Me\geometry  = newCCurveGeometry(nbpoints)
  
  ; ---[ Attributes ]---------------------------------------------------------
  Protected *geom.CCurveGeometry_t = *Me\geometry
  Protected *name = newCGraphAttribute("Name",#ATTR_TYPE_STRING,#ATTR_STRUCT_SINGLE,#ATTR_CTXT_SINGLETON,@*Me\name,#False,#True)
  O3DObject_AddAttribute(*Me,*name)
  Protected *nbpoints = newCGraphAttribute("NbPoints",#ATTR_TYPE_INTEGER,#ATTR_STRUCT_SINGLE,#ATTR_CTXT_SINGLETON,@*geom\nbpoints,#True,#True)
  O3DObject_AddAttribute(*Me,*nbpoints)
  Protected *interpolation = newCGraphAttribute("InterpolationMode",#ATTR_TYPE_INTEGER,#ATTR_STRUCT_SINGLE,#ATTR_CTXT_SINGLETON,@*geom\interpolation,#False,#True)
  O3DObject_AddAttribute(*Me,*interpolation)
  Protected *pointposition = newCGraphAttribute("PointPosition",#ATTR_TYPE_VECTOR3,#ATTR_STRUCT_SINGLE,#ATTR_CTXT_COMPONENT0D,*geom\a_positions\GetPtr(),#False,#False)
  O3DObject_AddAttribute(*Me,*pointposition)
  Protected *sampleposition = newCGraphAttribute("SamplePosition",#ATTR_TYPE_VECTOR3,#ATTR_STRUCT_SINGLE,#ATTR_CTXT_COMPONENT1D,*geom\a_samples\GetPtr(),#False,#False)
  O3DObject_AddAttribute(*Me,*sampleposition)
  
  ; ---[ Return Initialized Object ]------------------------------------------
  ret( *Me )
  
EndProcedure

; ---[ Heap ]-----------------------------------------------------------------
Procedure.i newCCurve( name.s="Curve",nbPoints.i=0)
  
  ; ---[ Allocate Object Memory ]---------------------------------------------
  Protected *p.CCurve_t = AllocateMemory( SizeOf(CCurve_t) )
  
  ; ---[ Init Object ]--------------------------------------------------------
  ret( nesCCurve( *p, name,nbPoints) )
  
EndProcedure
;}

; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 31
; FirstLine = 20
; Folding = ----
; EnableXP