
XIncludeFile "UI.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../libs/Bullet.pbi"
XIncludeFile "../bullet/World.pbi"
XIncludeFile "../bullet/RigidBody.pbi"
XIncludeFile "../objects/Camera.pbi"
XIncludeFile "View.pbi"

; -----------------------------------------
; ViewportUI Module Declaration
; -----------------------------------------
DeclareModule ViewportUI
  UseModule UI
  Structure ViewportUI_t Extends UI_t
    *camera.Camera::Camera_t
    *context.GLContext::GLContext_t
  EndStructure
  
  Interface IViewportUI Extends IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s)
  Declare Delete(*ui.ViewportUI_t)
  Declare Init(*ui.ViewportUI_t)
  Declare OnEvent(*ui.ViewportUI_t,event.i)
  Declare Term(*ui.ViewportUI_t)
  Declare SetContext(*ui.ViewportUI_t)
  Declare FlipBuffer(*ui.ViewportUI_t)
  
  DataSection 
    ViewportUIVT: 
    Data.i @Init()
    Data.i @OnEvent()
    Data.i @Term()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; ViewportUI Module Implementation
; -----------------------------------------
Module ViewportUI
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  ; New
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s)
    Protected *Me.ViewportUI_t = AllocateMemory(SizeOf(ViewportUI_t))
    InitializeStructure(*Me,ViewportUI_t)
    *Me\name = name
    *Me\type = Globals::#VIEW_TIMELINE
    Object::INI(ViewportUI)
    
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    
    *Me\container = ContainerGadget(#PB_Any,x,y,w,h)
    *Me\context = GLContext::New(w,h,#False)

    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      ; Allocate Pixel Format Object
      Define pfo.NSOpenGLPixelFormat = CocoaMessage( 0, 0, "NSOpenGLPixelFormat alloc" )
      ; Set Pixel Format Attributes
      Define pfa.NSOpenGLPixelFormatAttribute
      With pfa
        \v[0] = #NSOpenGLPFAColorSize          : \v[1] = 24
        \v[2] = #NSOpenGLPFAAlphaSize          : \v[3] =  8
        \v[4] = #NSOpenGLPFAOpenGLProfile      : \v[5] = #NSOpenGLProfileVersion3_2Core ; will give 4.1 version (or more recent) if available
        \v[6] = #NSOpenGLPFADoubleBuffer
        \v[7] = #NSOpenGLPFAAccelerated ; I also want OpenCL available
        \v[8] = #NSOpenGLPFANoRecovery
        \v[9] = #Null
      EndWith

      ; Choose Pixel Format
      CocoaMessage( 0, pfo, "initWithAttributes:", @pfa )
      ; Allocate OpenGL Context
      Define ctx.NSOpenGLContext = CocoaMessage( 0, 0, "NSOpenGLContext alloc" )
      ; Create OpenGL Context
      CocoaMessage( 0, ctx, "initWithFormat:", pfo, "shareContext:", #Null )
      ; Set Current Context
      CocoaMessage( 0, ctx, "makeCurrentContext" )
      ; Swap Buffers
      CocoaMessage( 0, ctx, "flushBuffer" )
      ; Load Extensions
      GLLoadExtensions()
      ; Associate Context With OpenGLGadget NSView
      *Me\gadgetID = CanvasGadget(#PB_Any,0,0,w,h,#PB_Canvas_Keyboard)
      CocoaMessage( 0, ctx, "setView:", GadgetID(*Me\gadgetID) ) ; oglcanvas_gadget is your OpenGLGadget#
      *Me\context\ID = ctx
      
    CompilerElse
      *Me\gadgetID = OpenGLGadget(#PB_Any,0,0,w,h,#PB_OpenGL_Keyboard)
      SetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_SetContext,#True)
      GLLoadExtensions()
    CompilerEndIf
    
    *Me\width = w
    *Me\height = h
   
    CloseGadgetList()
    
    GLContext::Setup(*Me\context)
    View::SetContent(*parent,*Me)

    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.ViewportUI_t)
    If IsGadget(*Me\gadgetID) : FreeGadget(*Me\gadgetID):EndIf
    If IsGadget(*Me\container) : FreeGadget(*Me\container):EndIf
    ClearStructure(*Me,ViewportUI_t)
    FreeMemory(*Me)
  EndProcedure

 
  ; Init
  ;-------------------------------
  Procedure Init(*ui.ViewportUI_t)
    Debug "ViewportUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*ui.ViewportUI_t,event.i)
;     SetGadgetAttribute(*ui\gadgetID,#PB_OpenGL_SetContext,#True)
;     glClearColor(Random(100)*0.01,Random(100)*0.01,Random(100)*0.01,1.0)
;     glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
;     SetGadgetAttribute(*ui\gadgetID,#PB_OpenGL_FlipBuffers,#True)

    Select event
      Case #PB_Event_SizeWindow
        Protected *top.View::View_t = *ui\top
        Protected width.i = *top\width
        Protected height.i = *top\height
        
        *ui\width = width
        *ui\height = height
        *ui\x = *top\x
        *ui\y = *top\y
        ResizeGadget(*ui\gadgetID,0,0,width,height)
        ResizeGadget(*ui\container,*top\x,*top\y,width,height)
        

        If *ui\context  
          *ui\context\width = *ui\width
          *ui\context\height = *ui\height
        EndIf
        
      Case #PB_Event_Gadget
        If EventGadget() = *ui\gadgetID
          If *ui\camera : Camera::OnEvent(*ui\camera,*ui\gadgetID) : EndIf
        EndIf

    EndSelect

    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*ui.ViewportUI_t)
    Debug "ViewportUI Term Called!!!"
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Convert 2D Mouse Position to 3D Position
  ;------------------------------------------------------------------
  Procedure ViewToWorld(*v.ViewportUI_t,mx.d,my.d,*world_pos.v3f32)
    Protected view.v3f32
    Vector3::Sub(@view,*v\camera\lookat,*v\camera\pos)
    Vector3::NormalizeInPlace(@view)
    
    Protected h.v3f32
    Vector3::Cross(@h,@view,*v\camera\up)
    Vector3::NormalizeInPlace(@h)
    
    Protected v.v3f32
    Vector3::Cross(@v,@h,@view)
    Vector3::NormalizeInPlace(@v)
    
    
    Protected rad.f = *v\camera\fov * #F32_PI / 180
    Protected vLength.f = Tan(rad/2) * *v\camera\nearplane
    Protected hLength.f = vLength *(*v\width/*v\height)
    
    Vector3::ScaleInPlace(@v,vLength)
    Vector3::ScaleInPlace(@h,hLength)
    
    ;Remap mouse coordinates
    mx - *v\width/2
    my - *v\height/2
    
    mx/(*v\width*0.5)
    my/(*v\height*0.5)
    
  
    Vector3::ScaleInPlace(@h,mx)
    Vector3::ScaleInPlace(@v,-my)
    
    Protected ray.v3f32
    
    Vector3::ScaleInPlace(@view,*v\camera\nearplane)
    Vector3::AddInPlace(@view,*v\camera\pos)
    Vector3::Add(@ray,@h,@v)
    Vector3::AddInPlace(@ray,@view)
    Vector3::Sub(*world_pos,@ray,*v\camera\pos)
    Vector3::ScaleInPlace(*world_pos,*v\camera\farplane)
    Vector3::AddInPlace(*world_pos,*v\camera\pos)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; View To World
  ;------------------------------------------------------------------
  Procedure ViewToRay(*v.ViewportUI_t,mx.d,my.d,*ray_dir.v3f32)
    Define.d mx,my
    ;glfwGetCursorPos(*v\window,@mx,@my)
    mx = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseX)
    my = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseY)
    
    Define.f x = (2*mx)/*v\width - 1
    Define.f y = 1- (2*my)/*v\height
    Define.f z = 1
    
    Define ray_nds.v3f32
    Vector3::Set(@ray_nds,x,y,z)
    Define ray_clip.v4f32
    Vector4::Set(@ray_clip,ray_nds\x,ray_nds\y,-1,1)
    
    Define inv_proj.m4f32
    Matrix4::Inverse(@inv_proj,*v\camera\projection)
    Define ray_eye.v4f32
    Vector4::MulByMatrix4(@ray_eye,@ray_clip,@inv_proj,#False)
    ray_eye\z = -1
    ray_eye\w = 0
    
    Define inv_view.m4f32
    Define ray_world.v4f32
    Matrix4::Inverse(@inv_view,*v\camera\view)
    Vector4::MulByMatrix4(@ray_world,@ray_eye,@inv_view,#False)
    
    Vector3::Set(*ray_dir,ray_world\x,ray_world\y,ray_world\z)
    Vector3::NormalizeInPlace(*ray_dir)
   
  
  EndProcedure
  
  
  
  ; ;------------------------------------------------------------------
  ; ; Ray Pick
  ; ;------------------------------------------------------------------
  Procedure RayPick2(*v.ViewportUI_t)
    Debug "------------------------------------       RAY PICK     -------------------------------------------------"
    Define.d mx,my
  
    mx = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseX)
    my = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseY)
    Protected ray_end.v3f32
  
    ViewToRay(*v,mx,my,@ray_end)
    
    Vector3::ScaleInPlace(@ray_end,*v\camera\farplane)
    Vector3::AddInPlace(@ray_end,*v\camera\pos)
    
    Protected *scn.Scene::Scene_t = Scene::*current_scene
    Protected *hit.Object3D::Object3D_t =*scn\rayhit
    
    Protected rcr.Bullet::btRaycastResult
    If Not Bullet::*pick_world
      Bullet::*pick_world = Bullet::BTCreateDynamicsWorld(Bullet::*bullet_sdk)
    EndIf
   
    
    Protected i
    Protected *obj.Object3D::Object3D_t 
    Protected *bodies.CArray::CArrayPtr = CArray::newCArrayPtr()
    Protected *body.Bullet::btRigidBody
    For  i= 0 To CArray::GetCount(*scn\objects)-1
      *obj = CArray::GetValuePtr(*scn\objects,i)
      If *obj\type = Object3D::#Object3D_Polymesh
        *body = BulletRigidBody::BTCreateRigidBodyFrom3DObject(*obj,Bullet::#TRIANGLEMESH_SHAPE,0.0,Bullet::*pick_world)
        CArray::AppendPtr(*bodies,*body)
      EndIf
    Next
   
    If Bullet::BTRayCast(Bullet::*pick_world,*v\camera\pos,@ray_end,@rcr)
  
      *body = rcr\m_body
      Protected *shape.Bullet::btCollisionShape = rcr\m_shape
      
      If Not *body : ProcedureReturn : EndIf
      *obj.Object3D::Object3D_t = Bullet::BTGetUserData(*body)
      
      If *hit
        
        Debug "Hit Object : "+*obj\name
        Debug "Hit Triangle Index : "+Str(rcr\m_triangleindex)
        
        Protected *outT.Transform::Transform_t = *hit\localT
        Protected *outQ.q4f32 = *outT\t\rot
        
        Protected up.v3f32
        Vector3::Set(@up,0,1,0)
  
        Quaternion::LookAt(*outQ,rcr\m_normalWorld,@up)
        Transform::SetRotationFromQuaternion(*outT,*outQ)
        Transform::SetTranslationFromXYZValues(*outT,rcr\m_positionWorld\v[0],rcr\m_positionWorld\v[1],rcr\m_positionWorld\v[2])
        Transform::SetScaleFromXYZValues(*outT,1,1,1)
        
        Object3D::SetLocalTransform(*hit,*outT)
        ;         Object3D::SetWireframeColor(*hi,1,0,0)`
        Object3D::UpdateTransform(*hit,Scene::*current_scene\root\globalT)
      Else
        
        Debug "Ray cast done but NO 3D Object"
      EndIf
      
  
    Else
      ;*hit\SetWireframeColor(0,1,0)
      Debug "Raycast Failed..."
    EndIf
    For  i= 0 To CArray::GetCount(*bodies)-1
      Bullet::BTRemoveRigidBody(*pick_world,CArray::GetValuePtr(*bodies,i))
    Next
    CArray::Delete(*bodies)
  
    
    
  EndProcedure
  
  ;-------------------------------------------------------
  ; Unproject
  ;-------------------------------------------------------
  Procedure Unproject(*v.ViewportUI_t,*world_pos.v3f32)
    Debug "----------------------------- UNPROJECT ------------------------------------------"
    Protected window_pos.v3f32
    Define.d x,y
    ;glfwGetCursorPos(*v\window,@x,@y)
    x = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseX)
    y = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseX)
    Vector3::Set(@window_pos,x,*v\height-y,0.5)
    Vector3::Echo(@window_pos,"Window Pos")
    Protected viewport.v4f32
    Vector4::Set(@viewport,*v\x,*v\y,*v\width,*v\height)
    Vector4::Echo(@viewport,"Viewport")
    
    Define.m4f32 m,A;
    Define.v4f32 _in,_out;
    
    Protected *view.m4f32 = *v\camera\view
    Protected *proj.m4f32 = *v\camera\projection
    
    ;Calculation For inverting a matrix, compute projection x modelview
    ;And store in A[16]
    Matrix4::Multiply(@A,*proj,*view)
  
    ;Now compute the inverse of matrix A
    If Not Matrix4::Inverse(@m,@A) : ProcedureReturn 0 :EndIf
    
    ;Transformation of normalized coordinates between -1 And 1
    _in\x=window_pos\x/viewport\z*2.0-1.0;
    _in\y=(window_pos\y-viewport\y)/viewport\w*2.0-1.0;
    _in\z=2.0*window_pos\z-1.0;
    _in\w=1.0;
    
    ;Objects coordinates
    Vector4::MulByMatrix4(@_out, @_in, @m);
    Vector4::Echo(@_out,"Projected")
  
  ;  If _out\w = 0 
  ;    ProcedureReturn 0
  ;  Else 
     Debug "Set 3D Unprojected Position "
     Protected div.f = 1/ _out\w
     *world_pos\x = _out\x
     *world_pos\y = _out\y
     *world_pos\z = _out\z
  ;  EndIf
     ProcedureReturn 1
   
    ;GL_Unproject(@window_pos,*v\camera\global\GetMatrix(),*v\camera\projection,@viewport,*world_pos)
    Vector3::Echo(*world_pos,"World Position")
    
  EndProcedure
  
  ;-------------------------------------------------------
  ; Project
  ;-------------------------------------------------------
  Procedure Project(*v.ViewportUI_t,*pos.v3f32,*io_pos.v3f32)
    
  EndProcedure
  
  ;-------------------------------------------------------
  ; Set Context
  ;-------------------------------------------------------
  Procedure SetContext(*v.ViewportUI_t)
    CompilerIf Not #USE_GLFW
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
        CocoaMessage( 0, *v\context\ID, "makeCurrentContext" )
      CompilerElse
        SetGadgetAttribute(*v\gadgetID, #PB_OpenGL_SetContext, #True)
      CompilerEndIf
    CompilerEndIf
  EndProcedure
  
  ;-------------------------------------------------------
  ; Flip Buffer
  ;-------------------------------------------------------
  Procedure FlipBuffer(*v.ViewportUI_t)
    CompilerIf Not #USE_GLFW
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
        CocoaMessage( 0, *v\context\ID, "flushBuffer" )
      CompilerElse
        If Not #USE_GLFW
          SetGadgetAttribute(*v\gadgetID,#PB_OpenGL_FlipBuffers,#True)
        EndIf
      CompilerEndIf
     CompilerEndIf
  EndProcedure
  
  
  
EndModule
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 426
; FirstLine = 394
; Folding = ----
; EnableXP