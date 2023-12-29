; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
XIncludeFile "Layer.pbi"
XIncludeFile "ShadowMap.pbi"
DeclareModule LayerCascadedShadowMap
  UseModule OpenGL
  UseModule Math
  
  ;------------------------------------------------------------------
  ; CONSTANTS
  ;------------------------------------------------------------------
  #NUM_CASCADES = 3
  #NUM_FRUSTUM_CORNERS = 8
  
  ;------------------------------------------------------------------
  ; STRUCTURE
  ;------------------------------------------------------------------
  Structure OrthographicProjectionInfo_t
    left.f
    right.f
    bottom.f
    top.f
    far.f
    near.f
  EndStructure
  
  Structure LayerCascadedShadowMap_t Extends Layer::Layer_t
    farplane.f
    cullfrontface.b
    *light.Light::Light_t
    Array cascadeEnds.f(0)
    Array cascadeProjections.OrthographicProjectionInfo_t(0)
    imgIdx.i
  EndStructure
  
  ;------------------------------------------------------------------
  ; INTERFACE
  ;------------------------------------------------------------------
  Interface ILayerCascadedShadowMap Extends Layer::ILayer
  EndInterface
  
  Declare New(width.i,height.i,*ctx.GLContext::GLContext_t, *camera.Camera::Camera_t, *light.Light::Light_t)  
  Declare Delete(*layer.LayerCascadedShadowMap_t)
  Declare Setup(*layer.LayerCascadedShadowMap_t)
  Declare Update(*layer.LayerCascadedShadowMap_t)
  Declare Clean(*layer.LayerCascadedShadowMap_t)
  Declare Pick(*layer.LayerCascadedShadowMap_t)
  Declare Draw(*layer.LayerCascadedShadowMap_t,*ctx.GLContext::GLContext_t)
  Declare SaveImageToDisk(*layer.LayerCascadedShadowMap_t)
  
  DataSection 
    LayerCascadedShadowMapVT:  
    Layer::DAT()
  EndDataSection
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  OpenGL Defered Rendering Layer Module Declaration
; ============================================================================
Module LayerCascadedShadowMap
  UseModule OpenGL
  UseModule OpenGLExt
  
  ;------------------------------------------------------------------
  ; HELPERS
  ;------------------------------------------------------------------
  
  ;------------------------------------
  ; Setup
  ;------------------------------------
  Procedure Setup(*layer.LayerCascadedShadowMap_t)

    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Update(*layer.LayerCascadedShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Clean(*layer.LayerCascadedShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Update
  ;------------------------------------
  Procedure Pick(*layer.LayerCascadedShadowMap_t)
    
  EndProcedure
  
  ;------------------------------------
  ; Bind For Writing
  ;------------------------------------
  Procedure BindForWriting(*layer.LayerCascadedShadowMap_t, cascadeIndex.i)
    If Not cascadeIndex < #NUM_CASCADES
      Debug "CascadedShadowMap Error: Cascade Index Out of Bound!"
      ProcedureReturn
    EndIf
    glBindFramebuffer(#GL_DRAW_FRAMEBUFFER, *layer\framebuffer\frame_id)
    
    glFramebufferTexture2D(#GL_FRAMEBUFFER,
                           #GL_DEPTH_ATTACHMENT,
                           #GL_TEXTURE_2D,
                           *layer\framebuffer\tbos(cascadeIndex)\textureID,
                           0)
  EndProcedure

  ;------------------------------------
  ; Bind For Reading
  ;------------------------------------
  Procedure BindFoReading(*layer.LayerCascadedShadowMap_t, cascadeIndex.i)
    Protected i
    For i=0 To #NUM_CASCADES-1
      glActiveTexture(#GL_TEXTURE+i)
      glBindTexture(#GL_TEXTURE_2D, *layer\framebuffer\tbos(i)\textureID)
    Next
  EndProcedure
  
  ;------------------------------------
  ; Update Cascades Ends
  ;------------------------------------
  Procedure UpdateCascadesEnd(*layer.LayerCascadedShadowMap_t)
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected dist.f = *layer\farplane - *camera\nearplane
    *layer\cascadeEnds(0) = *camera\nearplane
    *layer\cascadeEnds(1) = *camera\nearplane + dist/4
    *layer\cascadeEnds(2) = *camera\nearplane + dist/2
    *layer\cascadeEnds(3) = *layer\farplane
  EndProcedure
  
  
  ;------------------------------------
  ; Compute Orthogonal Projections
  ;------------------------------------
  Procedure ComputeOrthogonalProjections(*layer.LayerCascadedShadowMap_t)
    ;Get the inverse of the view transform
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected view.m4f32
    
    ;Camera::GetViewTransform(*camera, @view)
    Matrix4::GetViewMatrix(view, *camera\pos, *camera\lookat, *camera\up)
    Protected invview.m4f32
    Matrix4::Inverse(invview, view)
    
    ;Get the light space tranform
    Protected *light.Light::Light_t = *layer\light
    Protected lightM.m4f32
    Protected lightPos.Math::v3f32
    Vector3::Set(lightPos, 0, 0, 0)
    Protected lightDir.Math::v3f32
    Vector3::Sub(lightDir, *light\lookat, *light\pos)
    Vector3::NormalizeInPlace(lightDir)
    Protected lightUp.Math::v3f32
    Vector3::Set(lightUp, 0, 1, 0)
    Matrix4::GetViewMatrix( lightM, lightPos,lightDir, lightUp)
    ;Matrix4::GetViewMatrix( lightM, *light\pos, *light\lookat, *light\up)
    
    Protected ar.f = *layer\framebuffer\height / *layer\framebuffer\width
    Protected tanHalfHFOV.f = Tan(Radian(*camera\fov / 2))
    Protected tanHalfVFOV.f = Tan(Radian(*camera\fov * ar) /2)
    
    Protected i,j
    Define.f xn, xf, yn, yf
    Protected vW.v4f32
    For i=0 To #NUM_CASCADES -1
      xn = *layer\cascadeEnds(i) * tanHalfHFOV
      xf = *layer\cascadeEnds(i+1) * tanHalfHFOV
      yn = *layer\cascadeEnds(i) * tanHalfVFOV
      yf = *layer\cascadeEnds(i+1) * tanHalfVFOV
      
      Dim frustrumCorners.v4f32(#NUM_FRUSTUM_CORNERS)
      ; Near Face
      Vector4::Set(frustrumCorners(0), xn, yn, *layer\cascadeEnds(i), 1.0)
      Vector4::Set(frustrumCorners(1), -xn, yn, *layer\cascadeEnds(i), 1.0)
      Vector4::Set(frustrumCorners(2), xn, -yn, *layer\cascadeEnds(i), 1.0)
      Vector4::Set(frustrumCorners(3), -xn, -yn, *layer\cascadeEnds(i), 1.0)
      ; Far Face
      Vector4::Set(frustrumCorners(4), xf, yf, *layer\cascadeEnds(i+1), 1.0)
      Vector4::Set(frustrumCorners(5), -xf, yf, *layer\cascadeEnds(i+1), 1.0)
      Vector4::Set(frustrumCorners(6), xf, -yf, *layer\cascadeEnds(i+1), 1.0)
      Vector4::Set(frustrumCorners(7), -xf, -yf, *layer\cascadeEnds(i+1), 1.0)
      
      ;Calculate the orthographic projections for the cascades. 
      ;The frustumCorners Array is populated with the eight corners of each cascade in view space.
      ;Note that since the field of view is provided only for the horizontal axis 
      ;we have to extrapolate it for the vertical axis 
      ;If the horizontal field of view is 90 degrees 
      ;and the window has a width of 1000 And a height of 500 the vertical field of view will be only 45 degrees.
      Dim frustumCornersL.v4f32(#NUM_FRUSTUM_CORNERS)
      Define.f minX,maxX,minY,maxY,minZ,maxZ
      minX = Math::#F32_MAX
      maxX = Math::#F32_MIN
      minY = Math::#F32_MAX
      maxY = Math::#F32_MIN
      minZ = Math::#F32_MAX
      maxZ = Math::#F32_MIN
      
      For j=0 To #NUM_FRUSTUM_CORNERS-1
        ;Transform the frustum coordinate from view To world space
        Vector4::MulByMatrix4(vW,frustrumCorners(j), invview, #False)

        ;Transform the frustum coordinate from world To light space
        Vector4::MulByMatrix4(frustumCornersL(j), vW, lightM, #False)
        
        minX = Math::Min(minX, frustumCornersL(j)\x)
        maxX = Math::Max(maxX, frustumCornersL(j)\x)
        minY = Math::Min(minY, frustumCornersL(j)\y)
        maxY = Math::Max(maxY, frustumCornersL(j)\y)
        minZ = Math::Min(minZ, frustumCornersL(j)\z)
        maxZ = Math::Max(maxZ, frustumCornersL(j)\z)
      Next
      
      ;Each frustum corner coordinate is multiplied by the inverse view transform 
      ;in order To bring it into world space.
      ;It is then multiplied by the light transform 
      ;in order To move it into light space.
      ;We then use a series of min/max functions 
      ;in order To find the size of the bounding box of the cascade in light space.
      *layer\cascadeProjections(i)\left = minX
      *layer\cascadeProjections(i)\right = maxX
      *layer\cascadeProjections(i)\bottom = minY
      *layer\cascadeProjections(i)\top = maxY
      *layer\cascadeProjections(i)\near = minZ
      *layer\cascadeProjections(i)\far = maxZ
      

    Next
  EndProcedure
  
  ;------------------------------------
  ; Set Cascades End Clip Space
  ;------------------------------------
  Procedure SetCascadeEndsClipSpace(*layer.LayerCascadedShadowMap_t, shader.i)
    Protected i
    Protected *camera.Camera::Camera_t = *layer\pov
    Protected vView.Math::v4f32, vClip.Math::v4f32
    For i=0 To 2
      Vector4::Set(vView,0.0,0.0,-*layer\cascadeEnds(i+1),1.0)
      Vector4::MulByMatrix4(vClip,vView,*camera\projection, #False)
      glUniform1f(glGetUniformLocation(shader,"cascades_end[" + Str(i) + "]"), vClip\z)
    Next
  EndProcedure
  
  ;------------------------------------
  ; Save Images to Disk
  ;------------------------------------
  Procedure SaveImageToDisk(*layer.LayerCascadedShadowMap_t)
    Define i
    glColorMask(#GL_TRUE, #GL_TRUE, #GL_TRUE, #GL_TRUE);
    
    glActiveTexture(#GL_TEXTURE0)
    For i=0 To #NUM_CASCADES - 1
      glBindTexture(#GL_TEXTURE_2D,Framebuffer::GetTex(*layer\framebuffer,i))
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        Debug "WRITE IMAGE TO DISK !!!"
        Layer::GetImage(*layer, "E:/Projects/RnD/Noodle/images/csm_"+Str(i)+"_"+Str(*layer\imgIdx)+".png")
       
      CompilerElse
        Layer::GetImage(*layer, "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/images/csm1.png")
      CompilerEndIf
    Next
    *layer\imgIdx +1
  EndProcedure
  
  
  ;------------------------------------
  ; Draw
  ;------------------------------------
  Procedure Draw(*layer.LayerCascadedShadowMap_t,*ctx.GLContext::GLContext_t)
    
    GLCheckError("[CSM] Draw Called")
    Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
    If Not *light : ProcedureReturn : EndIf
    Light::Update(*light)
    GLCheckError("[CSM] Light Updated")
    ; Update Cascades Orthographic Projection
    UpdateCascadesEnd(*layer)
    GLCheckError("[CSM] Cascade Ends Updated")
    ComputeOrthogonalProjections(*layer)
    GLCheckError("[CSM] Orthogonal Projections Updated")
    glViewport(0,0,*layer\framebuffer\width,*layer\framebuffer\height)
    GLCheckError("[CSM] Set Viewport")
    shader = *ctx\shaders("shadowmapCSM")\pgm
    glUseProgram(shader)
    GLCheckError("[CSM] Use Program")
    Framebuffer::BindOutput(*layer\framebuffer)
    GLCheckError("[CSM] Bind Framebuffer")
    
    glEnable(#GL_DEPTH_TEST)
    If *layer\cullfrontface
      glEnable(#GL_CULL_FACE)
      glCullFace(#GL_FRONT)
      glFrontFace(#GL_CW)
    EndIf
  
    Protected i
    Protected projection.m4f32
    glUniformMatrix4fv(glGetUniformLocation(shader,"view"),1,#GL_FALSE,*light\view)
  
    GLCheckError("[CSM] Set View Matrix")
    For i=0 To #NUM_CASCADES-1
      ;Bind And clear the current cascade
      BindForWriting(*layer,i)
      GLCheckError("[CSM] Bind for writing")
      glClear(#GL_DEPTH_BUFFER_BIT)
      With *layer\cascadeProjections(i) 
        Matrix4::GetOrthoMatrix(projection,\left,\right,\bottom,\top,\near,\far)
      EndWith
      Matrix4::Echo(projection, "Ortho "+Str(i))
      glUniformMatrix4fv(glGetUniformLocation(shader,"projection"),1,#GL_FALSE,@projection)
      GLCheckError("[CSM] Set Projection Matrix")
      Layer::DrawPolymeshes(*layer,Scene::*current_scene\objects,shader, #False)
      GLCheckError("[CSM] Draw Polymeshes")
    Next
    
    If *layer\cullfrontface
      glDisable(#GL_CULL_FACE)
      glDisable(#GL_DEPTH_TEST)
      glFrontFace(#GL_CCW)
    EndIf
    
;      glActiveTexture(#GL_TEXTURE1)
;     glBindTexture(#GL_TEXTURE_2D,Framebuffer::GetTex(*layer\buffer,1))
;     Layer::GetImage(*layer, "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/images/csm2.png")
;      glActiveTexture(#GL_TEXTURE2)
;     glBindTexture(#GL_TEXTURE_2D,Framebuffer::GetTex(*layer\buffer,2))
;     Layer::GetImage(*layer, "/Users/benmalartre/Documents/RnD/PureBasic/Noodle/images/csm3.png")
    
    
      
  EndProcedure
  
  ;------------------------------------
  ; Destructor
  ;------------------------------------
  Procedure Delete(*layer.LayerCascadedShadowMap_t)
    FreeMemory(*layer)
  EndProcedure
  
  
  ;---------------------------------------------------
  ; Create
  ;---------------------------------------------------
  Procedure New(width.i,height.i,*ctx.GLContext::GLContext_t, *camera.Camera::Camera_t, *light.Light::Light_t)
    Protected *Me.LayerCascadedShadowMap_t = AllocateMemory(SizeOf(LayerCascadedShadowMap_t))
    Object::INI( LayerCascadedShadowMap )
    Color::Set(*Me\background_color,0,0,0,1)

    *Me\context = *ctx
    *Me\pov = *camera
    *Me\light = *light
    *Me\framebuffer = Framebuffer::New("CSMShadowMap",width,height)
    *Me\farplane = 100
    *Me\mask = #GL_DEPTH_BUFFER_BIT
    *Me\cullfrontface = #True
    
    ReDim *Me\cascadeEnds(#NUM_CASCADES+1)
    ReDim *Me\cascadeProjections(#NUM_CASCADES)
    
    Framebuffer::AttachCascadedShadowMap(*me\framebuffer, #NUM_CASCADES)

    Setup(*Me)
   
    ProcedureReturn *Me
  EndProcedure
  
  Class::DEF(LayerCascadedShadowMap)
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 3
; Folding = ---
; EnableXP