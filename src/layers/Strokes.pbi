; ============================================================================
;  Strokes Layer Module
; ============================================================================
XIncludeFile "Layer.pbi"
DeclareModule LayerStroke
  
    UseModule Math
  ;---------------------------------------------------
  ; Structure
  ;---------------------------------------------------s
  Structure LayerStroke_t Extends Layer::Layer_t
    linewidth.f
    *lines.CArray::CArrayPtr
    *line.Geometry::Line_t
    nbp.i
  EndStructure
  
  ;---------------------------------------------------
  ; Interface
  ;---------------------------------------------------
  Interface ILayerStroke Extends Layer::ILayer
  EndInterface
  
  Declare Delete(*layer.LayerStroke_t)
  Declare Setup(*layer.LayerStroke_t)
  Declare Update(*layer.LayerStroke_t,*view.m4f32,*proj.m4f32)
  Declare Clean(*layer.LayerStroke_t)
  Declare Draw(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t,*pov.Object3D::Object3D_t)
  
  DataSection
    LayerStrokeVT:
    Layer::DAT()
  EndDataSection 
  
  
  Global CLASS.Class::Class_t
EndDeclareModule

Module LayerStroke
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;---------------------------------------------------
  ; Update
  ;---------------------------------------------------
  Procedure Update(*layer.LayerStroke_t,*view.m4f32,*proj.m4f32)
     Debug "Layer Stroke Update Caklled..."
  Protected *line.Geometry::Line_t
  Protected *pnt.Math::v3f32

  Protected f.GLfloat
  Protected i
  *layer\nbp = 0
  For i=0 To CArray::GetCount(*layer\lines)-1
    *line = CArray::GetValuePtr(*layer\lines, i)
   *layer\nbp+CArray::GetCount(*line\positions)
  Next
  Debug "Layer Nb Points : "+Str(*layer\nbp)
  
  Protected v.v3f32
  Protected c.c4f32
  Protected size_i = 6*SizeOf(f)
  Protected size_t = *layer\nbp*size_i
  Debug "Size T : "+Str(size_t)
  
  If size_t
    Protected *flatdata = AllocateMemory(size_t)
    
    
    Protected x
    Protected offset = 0
    
    Protected size_p = *layer\nbp * SizeOf(v)
    Protected size_c = *layer\nbp * SizeOf(v)
    For i=0 To CArray::GetCount(*layer\lines)-1
      *line = CArray::GetValuePtr(*layer\lines, i)
      
      ForEach *line\points()
        *pnt = *line\points()
        With *pnt
          Vector3::Set(@v,\position\x,\position\y,\radius)
          CopyMemory(@v,*flatdata+offset*SizeOf(v),SizeOf(v))          
          ;Vector3_Set(@v,Random(255)/255,Random(255)/255,Random(255)/255)
          Vector3::Set(@v,\color\x,\color\y,\color\z)
          CopyMemory(@v,*flatdata+offset*SizeOf(v)+size_p,SizeOf(v))
          
          offset+1
        EndWith
      
        
      Next
    Next
    
    Protected shader.GLuint = *ctx\shaders("stroke2D")
    ; Attribute Position

    glUseProgram(shader)
    GLCheckError("Use Program Stroke 2D From Context")
    Protected uPosition.GLint =   glGetAttribLocation(shader,"vps")
    Debug"uPosition ---> "+Str( uPosition)
    GLCheckError("Get ATtrib Location VPS")
    glVertexAttribPointer(uPosition,3,#GL_FLOAT,#GL_FALSE,0,0)
    GLCheckError("Enable Vertex Attr Pointer VPS")
    ; Attribute Color
    Protected uColor.GLint = glGetAttribLocation(shader,"vc")
    Debug"uColor ---> "+Str( uColor)
    GLCheckError("Get ATtrib Location VC")
    glVertexAttribPointer(uColor,3  ,#GL_FLOAT,#GL_FALSE,0,size_p)
    GLCheckError("Enable Vertex Attr Pointer VC")
    ; Push Buffer to GPU
    glBufferData(#GL_ARRAY_BUFFER,size_t,*flatdata,#GL_DYNAMIC_DRAW)
    GLCheckError("Push Buffer Data to GPU")
    FreeMemory(*flatdata)  
    Debug "Layer Stroke GPU Updated!!!"
  EndIf
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Setup
  ;---------------------------------------------------
  Procedure Setup(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
   ;Generate Vertex Array Object
    glGenVertexArrays(1,@*layer\vaos(0))
    glBindVertexArray(*layer\vaos(0))
    
    ;Generate Vertex Buffer Object
    glGenBuffers(1,@*layer\vbos(0))
    glBindBuffer(#GL_ARRAY_BUFFER,*layer\vbos(0))
    
    Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
    glUseProgram(shader)
    ; Attribute Position
    Protected uPosition.GLint = glGetAttribLocation(shader,"vps")
    glEnableVertexAttribArray(uPosition)
    glVertexAttribPointer(uPosition,3,#GL_FLOAT,#GL_FALSE,0,0)
  
    ; Attribute Color
    Protected uColor.GLint = glGetAttribLocation(shader,"vc")
    glEnableVertexAttribArray(uColor)
    glVertexAttribPointer(uColor,3,#GL_FLOAT,#GL_FALSE,0,0)
  
    glBindVertexArray(#GL_NONE)  
  EndProcedure
  
  ;---------------------------------------------------
  ; Clean
  ;---------------------------------------------------
  Procedure Clean(*layer.LayerStroke_t)
   
  EndProcedure
  ;---------------------------------------------------
  ; Pick
  ;---------------------------------------------------
  Procedure Pick(*layer.LayerStroke_t)
   
  EndProcedure
  
  ;---------------------------------------------------
  ; Draw
  ;---------------------------------------------------
  Procedure Draw(*layer.LayerStroke_t,*ctx.GLContext::GLContext_t)
    *layer\buffer\BindOutput()
  
    glViewport(0,0,*layer\width,*layer\height)
    glClearColor(*layer\background_color\r,*layer\background_color\g,*layer\background_color\b,*layer\background_color\a);
    glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
    glDisable(#GL_DEPTH_TEST)
   
    Protected *line.CLine_t
    
    If *layer\nbp
      Protected i
      Protected shader.GLuint = *ctx\shaders("stroke2D")\pgm
      glBindVertexArray(*layer\vaos(0))
      GLCheckError("Bind Vertex Array")
      glUseProgram(shader)
      GLCheckError("Use Program")
      Update(*layer,*ctx)
      
      
  ;     glPointSize(2)
  ;     glLineWidth(*layer\linwidth)
  ;     glEnable(#GL_POINT_SMOOTH)
  ;     glEnable(#GL_BLEND)
      
  
      Protected offset = 0
      Protected f.f
  
      For i=0 To *layer\lines\GetCount()-1
        *line = *layer\lines\GetValue(i)
        With *line
        
          glUniform4f(glGetUniformLocation(shader,"color"),\color\x,\color\y,\color\z,1)
          glDrawArrays(#GL_LINE_STRIP_ADJACENCY, offset,\nbp)
          GLCheckError("Draw Array")
          offset+\nbp
        EndWith
      Next
       glBindVertexArray(#GL_NONE)
    EndIf
    
    *layer\buffer\Unbind()
    ;glBindFramebuffer(#GL_DRAW_FRAMEBUFFER,0)
    *layer\buffer\BlitTo(0,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
  ;   glBindFramebuffer(#GL_READ_FRAMEBUFFER,*layer\buffer\GetFBO())
  ;   glReadBuffer(#GL_COLOR_ATTACHMENT0)
  ;   glBlitFramebuffer(0,0,*layer\width,*layer\height,Int(*layer\width*0.8),Int(*layer\height*0.8),*layer\width,*layer\height,#GL_COLOR_BUFFER_BIT,#GL_LINEAR)
    
  ;    glDisable(#GL_POINT_SMOOTH)
  ;    glDisable(#GL_BLEND)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Point
  ;---------------------------------------------------
  Procedure AddPoint(*layer.LayerStroke_t,x.i,y.i)
    Protected w = *layer\width
    Protected h = *layer\height
  
    If *layer\line
      Protected *point.Geometry::Point_t = AllocateMemory(SizeOf(Geometry::Point_t))
      InitializeStructure(*point,Geometry::Point_t)
      
      *point\position\x = (2*x/w)-1
      *point\position\y = (2*(1-y/h))-1
      *point\radius = Random(255)/255*0.1
      Vector3::SetFromOther(*point\color,*layer\line\color)
      Vector3::Set(*point\color,Random(255)/255,Random(255)/255,Random(255)/255)
      Protected *line.Geometry::Line_t = *layer\line
      AddElement(*line\points())
      *line\points() = *point
      
      *line\nbp+1
      *layer\nbp+1
      
  ;     Line::CheckNbPoints(*line)
      ;OLayerStroke_Update(*layer)
    EndIf
    
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure StartLine(*layer.LayerStroke_t)
    
    Protected *line.Geometry::Line_t = AllocateMemory(SizeOf(CLine_t))
    InitializeStructure(*line,CLine_t)
    Vector3::Set(*line\color,0,0,0)
    *layer\lines\Append(*line)
    *layer\line = *line
    *line\color\x = Random(255)/255
    *line\color\y = Random(255)/255
    *line\color\z = Random(255)/255
    *line\nbp = 0
    *line\max_points = 33
    
  EndProcedure
  
  ;---------------------------------------------------
  ; Add Line
  ;---------------------------------------------------
  Procedure EndLine(*layer.LayerStroke_t)
    If *layer\line
     ;CLine_Simplify(*layer\line,0.1)
     ;CLine_Relax(*layer\line,10)
      ;OLayerStroke_Update(*layer)
    EndIf
    
    *layer\line = #Null
    
  EndProcedure
  
  ;---------------------------------------------------
  ; DESTRUCTOR
  ;---------------------------------------------------
  Procedure Delete(*layer.LayerStroke_t)
    glDeleteBuffers(1,*layer\vbos(0))
    glDeleteVertexArrays(1,*layer\vaos(0))
    ClearStructure(*layer,LayerStroke_t)
    FreeMemory(*layer)
  EndProcedure
  
  ;---------------------------------------------------
  ; CONSTRUCTOR
  ;---------------------------------------------------
  Procedure newCLayerStroke(width.i,height.i,*ctx.GLContext_t)
    Protected *Me.CLayerStroke_t = AllocateMemory(SizeOf(CLayerStroke_t))
    InitializeStructure(*Me,CLayerStroke_t)
    C3DObject_INI( LayerStroke )
    Color4_Set(*Me\background_color,0.5,0.5,0.5,0.0)
    *Me\type = #RAA_3DObject_Layer
    *Me\name = "LayerStroke2D"
    *Me\width = width
    *Me\height = height
    *Me\context = *ctx
    *Me\shader = *ctx\s_strokes
    *Me\buffer = newCFramebuffer("Strokes",width,height)
    *Me\buffer\AttachTexture(#GL_RGBA,#GL_LINEAR)
    *Me\buffer\AttachRender(#GL_DEPTH_COMPONENT)
    *Me\pov = #Null
    *Me\lines = newCArrayPtr()
    OLayerStroke_Setup(*Me,*ctx)
    ProcedureReturn *Me
  
  EndProcedure
  
  ; ----------------------------------------------------------------------------
  ;  REFLECTION
  ; ----------------------------------------------------------------------------
  Class_DEF( LayerStroke )
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 57
; FirstLine = 38
; Folding = ---
; EnableXP