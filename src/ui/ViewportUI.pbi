
XIncludeFile "UI.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
; CompilerIf #USE_BULLET
;   XIncludeFile "../libs/Bullet.pbi"
;   XIncludeFile "../bullet/World.pbi"
;   XIncludeFile "../bullet/RigidBody.pbi"
; CompilerEndIf

XIncludeFile "../objects/Camera.pbi"
XIncludeFile "../objects/Handle.pbi"
XIncludeFile "../layers/Selection.pbi"
XIncludeFile "View.pbi"

; ============================================================================
; ViewportUI Module Declaration
; ============================================================================
DeclareModule ViewportUI
  Structure ViewportUI_t Extends UI::UI_t
    *camera.Camera::Camera_t
    *context.GLContext::GLContext_t
    *handle.Handle::Handle_t

    mx.f
    my.f
    oldX.f
    oldY.f
    tool.i
    
    lmb_p.b
    mmb_p.b
    rmb_p.b
  EndStructure
  
  Interface IViewportUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s, *camera.Camera::Camera_t, *handle.Handle::Handle_t)
  Declare Delete(*Me.ViewportUI_t)
  Declare Resize(*Me.ViewportUi_t, x.i, y.i, width.i, height.i)
  Declare DrawPickImage(*Me.ViewportUI_t)
  Declare Pick(*Me.ViewportUI_t, mx.i, my.i)
  Declare OnEvent(*Me.ViewportUI_t,event.i)
  Declare Draw(*Me.ViewportUI_t)
  Declare SetHandleTarget(*Me.ViewportUI_t, *target.Object3D::Object3D_t)
  Declare SetHandleTargets(*Me.ViewportUI_t, *targets)
  Declare SetHandleTool(*Me.ViewportUI_t, tool.i)
  Declare GetRay(*Me.ViewportUI_t, *ray.Geometry::Ray_t)
  ;Declare SetActiveLayer(*Me.ViewportUI_t, index.i)
  Declare ViewToWorld(*v.ViewportUI_t,mx.d,my.d,*world_pos.Math::v3f32)
  Declare ViewToRay(*Me.ViewportUI_t,mx.f,my.f,*ray_dir.Math::v3f32)
  Declare Project(*v.ViewportUI_t,*pos.Math::v3f32,*io_pos.Math::v3f32, homogenous.b=#True)
  Declare Unproject(*v.ViewportUI_t, x.f, y.f,*world_pos.Math::v3f32)
  Declare Blit(*Me.ViewportUI_t, *framebuffer.Framebuffer::Framebuffer_t)
  
  DataSection 
    ViewportUIVT: 
      Data.i @OnEvent()
      Data.i @Delete()
      Data.i @Draw()
      Data.i @DrawPickImage()
      Data.i @Pick()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

; ============================================================================
; ViewportUI Module Implementation
; ============================================================================
Module ViewportUI
  UseModule OpenGL
  UseModule OpenGLExt
  UseModule Math
  ;------------------------------------------------------------------
  ; New
  ;------------------------------------------------------------------
  Procedure New(*parent.View::View_t,name.s, *camera.Camera::Camera_t, *handle.Handle::Handle_t)
    Protected *Me.ViewportUI_t = AllocateMemory(SizeOf(ViewportUI_t))
    
    Object::INI(ViewportUI)
    
    Protected x = *parent\posX
    Protected y = *parent\posY
    Protected w = *parent\sizX
    Protected h = *parent\sizY
    
    *Me\name = name
    *Me\type = Globals::#VIEW_VIEWPORT
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
    *Me\handle = *handle
        
    ; setup delegate gl context
    *Me\camera = *camera
    *Me\context = GLContext::New(*Me\sizX, *Me\sizY, GLContext::*MAIN_GL_CTXT)
    
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS And Not #USE_LEGACY_OPENGL
      *Me\gadgetID = CanvasGadget(#PB_Any,0,0,w,h)
      CocoaMessage( 0, *Me\context\ID, "setView:", GadgetID(*Me\gadgetID) )
        
    CompilerElse
      *Me\gadgetID = *Me\context\ID
      ResizeGadget(*Me\gadgetID, 0, 0,w, h)
      SetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_SetContext,#True)
    CompilerEndIf
    
    View::SetContent(*parent,*Me)
    ProcedureReturn *Me
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Delete
  ;------------------------------------------------------------------
  Procedure Delete(*Me.ViewportUI_t)
    If IsGadget(*Me\gadgetID) : FreeGadget(*Me\gadgetID):EndIf
    Object::TERM(ViewportUI)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Delete
  ;------------------------------------------------------------------
  Procedure Resize(*Me.ViewportUi_t, x.i, y.i, width.i, height.i)
    Debug "Viewport Resize..."
    *Me\sizX = x
    *Me\sizY = y
    *Me\posX = width
    *Me\posY = height
    ResizeGadget(*Me\gadgetID,x,y,width,height)
        
    If *Me\context  
      GLContext::Resize(*Me\context, width, height)
    EndIf
    If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf
    Control::Invalidate(*Me)
        
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Pick
  ;------------------------------------------------------------------
  Procedure Pick(*Me.ViewportUi_t, mx.i, my.i)
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Delete
  ;------------------------------------------------------------------
  Procedure DrawPickImage(*Me.ViewportUi_t)
    
  EndProcedure
    
  ;------------------------------------------------------------------
  ; Event
  ;------------------------------------------------------------------
  Procedure OnEvent(*Me.ViewportUI_t,event.i)
    Protected width.i, height.i, i
    Protected *top.View::View_t = *Me\parent
    Protected *scene.Scene::Scene_t
    Protected ev_datas.Control::EventTypeDatas_t
    Select event
        
      Case Globals::#EVENT_SELECTION_CHANGED
        If *scene\selection\items()
          Handle::SetTarget(*Me\handle, *scene\selection\items()\obj)
        EndIf
    
      Case #PB_Event_SizeWindow
        Resize(*Me, *top\posX, *top\posY, *top\sizX, *top\sizY)

        
        
        
      Case #PB_Event_Gadget
        Protected deltax.d, deltay.d
        Protected modifiers.i
        *Me\mx = GetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_MouseX)
        *Me\my = GetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_MouseY)
        width = GadgetWidth(*Me\gadgetID)
        height = GadgetHeight(*Me\gadgetID)

        Select EventType()
          Case #PB_EventType_KeyDown
            Select GetGadgetAttribute(*Me\gadgetID, #PB_OpenGL_Key)
              Case #PB_Shortcut_S
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_SCALE)
                *Me\tool = Globals::#TOOL_SCALE
              Case #PB_Shortcut_R
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
                *Me\tool = Globals::#TOOL_ROTATE
              Case #PB_Shortcut_T
                Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
                *Me\tool = Globals::#TOOL_TRANSLATE
            EndSelect
            
                
;                 Case #PB_Event_Menu
;         Select EventMenu()
;           Case Globals::#SHORTCUT_SCALE
;             Handle::SetActiveTool(*Me\handle,  Globals::#TOOL_SCALE)
;             *Me\tool = Globals::#TOOL_SCALE
;           Case Globals::#SHORTCUT_ROTATE
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
;             *Me\tool = Globals::#TOOL_ROTATE
;           Case Globals::#SHORTCUT_TRANSLATE
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
;             *Me\tool = Globals::#TOOL_TRANSLATE
;           Case Globals::#SHORTCUT_CAMERA
;             Handle::SetActiveTool(*Me\handle,  Globals::#TOOL_CAMERA)
;             *Me\tool = Globals::#TOOL_CAMERA
;           Case Globals::#SHORTCUT_SELECT
;             Handle::SetActiveTool(*Me\handle, 0)
;             *Me\tool = Globals::#TOOL_SELECT
;           EndSelect
          Case #PB_EventType_Focus
            *Me\context\focus = #True
;             AddKeyboardShortcut(*app\window\ID, #PB_Shortcut_T, Globals::#SHORTCUT_TRANSLATE)
;             AddKeyboardShortcut(*manager\window, #PB_Shortcut_R, Globals::#SHORTCUT_ROTATE)
;             AddKeyboardShortcut(*manager\window, #PB_Shortcut_S, Globals::#SHORTCUT_SCALE)
;             AddKeyboardShortcut(*manager\window, #PB_Shortcut_Space, Globals::#SHORTCUT_SELECT)
;                     
          Case #PB_EventType_LostFocus
            *Me\context\focus = #False
;             RemoveKeyboardShortcut(*manager\window, #PB_Shortcut_T)
;             RemoveKeyboardShortcut(*manager\window, #PB_Shortcut_R)
;             RemoveKeyboardShortcut(*manager\window, #PB_Shortcut_S)
;             RemoveKeyboardShortcut(*manager\window, #PB_Shortcut_Space)
;                     
          Case #PB_EventType_MouseMove
            
            If *Me\down
              deltax = *Me\mx-*Me\oldX
              deltay = *Me\my-*Me\oldY 
              modifiers = GetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_Modifiers)

              If modifiers & #PB_OpenGL_Alt
                If *Me\lmb_p
                  Camera::Orbit(*Me\camera,deltax,deltay,width,height)
                  If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf
                ElseIf *Me\mmb_p
                  Camera::Pan(*Me\camera,deltax,deltay,width,height)
                  If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf
                ElseIf *Me\rmb_p
                  Camera::Dolly(*Me\camera,deltax,deltay,width,height)
                  If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf
                EndIf
              ElseIf modifiers & #PB_OpenGL_Command
                If *Me\lmb_p
                  Camera::Pan(*Me\camera,deltax,deltay,width,height)
                  If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf
                EndIf
              Else
                If *Me\handle
                  Select *Me\handle\tool
                    Case Globals::#TOOL_TRANSLATE
                      ev_datas\x = *Me\mx
                      ev_datas\y = *Me\my
                      ev_datas\width = *Me\sizX
                      ev_datas\height = *Me\sizY
                      Handle::OnEvent(*Me\handle, #PB_EventType_MouseMove, ev_datas)
                  EndSelect
                EndIf
              
              EndIf
              
              *Me\oldX = *Me\mx
              *Me\oldY = *Me\my
            Else
              If *Me\handle And *Me\handle\tool <> Globals::#TOOL_SELECT
                ev_datas\x = *Me\mx
                ev_datas\y = *Me\my
                ev_datas\width = *Me\sizX
                ev_datas\height = *Me\sizY
                Handle::OnEvent(*Me\handle, #PB_EventType_MouseMove, ev_datas)                 
              EndIf
              
            EndIf

          Case #PB_EventType_LeftButtonDown
         
            *Me\lmb_p = #True
            *Me\down = #True
            *Me\oldX = *Me\mx
            *Me\oldY = *Me\my
            If *Me\handle\tool <> Globals::#TOOL_SELECT
              ev_datas\x = *Me\mx
              ev_datas\y = *Me\my
              ev_datas\width = *Me\sizX
              ev_datas\height = *Me\sizY
              Handle::OnEvent(*Me\handle, #PB_EventType_LeftButtonDown, ev_datas)
            EndIf

          Case #PB_EventType_LeftButtonUp
            *Me\lmb_p = #False
            *Me\down = #False
            If *Me\handle\tool <> Globals::#TOOL_SELECT
              ev_datas\x = *Me\mx
              ev_datas\y = *Me\my
              ev_datas\width = *Me\sizX
              ev_datas\height = *Me\sizY
              Handle::OnEvent(*Me\handle, #PB_EventType_LeftButtonUp, ev_datas)
            EndIf
        
          Case #PB_EventType_MiddleButtonDown
            *Me\mmb_p = #True
            *Me\down = #True
            *Me\oldX = *Me\mx
            *Me\oldY = *Me\my
      
          Case #PB_EventType_MiddleButtonUp
            *Me\mmb_p = #False
            *Me\down = #False
            
          Case #PB_EventType_RightButtonDown
            *Me\rmb_p = #True
            *Me\down = #True
            *Me\oldX = *Me\mx
            *Me\oldY = *Me\my
            
          Case #PB_EventType_RightButtonUp
            *Me\rmb_p = #False
            *Me\down = #False
            
          Case #PB_EventType_MouseWheel
            delta = GetGadgetAttribute(*Me\gadgetID,#PB_OpenGL_WheelDelta)
            Camera::Dolly(*Me\camera,delta,delta,width,height)
            If *Me\tool : Handle::Resize(*Me\handle,*Me\camera) : EndIf

        EndSelect
        
;       Case #PB_Event_Menu
;         Select EventMenu()
;           Case Globals::#SHORTCUT_SCALE
;             Handle::SetActiveTool(*Me\handle,  Globals::#TOOL_SCALE)
;             *Me\tool = Globals::#TOOL_SCALE
;           Case Globals::#SHORTCUT_ROTATE
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_ROTATE)
;             *Me\tool = Globals::#TOOL_ROTATE
;           Case Globals::#SHORTCUT_TRANSLATE
;             Handle::SetActiveTool(*Me\handle, Globals::#TOOL_TRANSLATE)
;             *Me\tool = Globals::#TOOL_TRANSLATE
;           Case Globals::#SHORTCUT_CAMERA
;             Handle::SetActiveTool(*Me\handle,  Globals::#TOOL_CAMERA)
;             *Me\tool = Globals::#TOOL_CAMERA
;           Case Globals::#SHORTCUT_SELECT
;             Handle::SetActiveTool(*Me\handle, 0)
;             *Me\tool = Globals::#TOOL_SELECT
;           EndSelect

    EndSelect
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Draw
  ;------------------------------------------------------------------
  Procedure Draw(*Me.ViewportUI_t)

    Dim shaderNames.s(3)
    shaderNames(0) = "wireframe"
    shaderNames(1) = "polymesh"
    shaderNames(2) = "normal"
    Define i
    Define *pgm.Program::Program_t
    For i=0 To 2
      *pgm = *Me\context\shaders(shaderNames(i))
      glUseProgram(*pgm\pgm)
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"model"),1,#GL_FALSE, Matrix4::IDENTITY())
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"view"),1,#GL_FALSE, *Me\camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*pgm\pgm,"projection"),1,#GL_FALSE, *Me\camera\projection)
    Next
    
;     Protected ilayer.Layer::ILayer = *Me\layer
;     ilayer\Draw(*Me\context)
    If *Me\tool
      Protected *wireframe.Program::Program_t = *Me\context\shaders("wireframe")
      glUseProgram(*wireframe\pgm)

      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,Matrix4::IDENTITY())
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE, *Me\camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE, *Me\camera\projection)
      
      Handle::Draw( *Me\handle,*Me\context) 
    EndIf
    
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set Handle Target
  ;------------------------------------------------------------------
  Procedure SetHandleTarget(*Me.ViewportUI_t, *target.Object3D::Object3D_t)
    Handle::SetTarget(*Me\handle, *target)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set Handle Targets
  ;------------------------------------------------------------------
  Procedure SetHandleTargets(*Me.ViewportUI_t, *targets)
    Handle::SetTargets(*Me\handle, *targets)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Set Handle Tool
  ;------------------------------------------------------------------
  Procedure SetHandleTool(*Me.ViewportUI_t, tool)
    Handle::SetActiveTool(*Me\handle, tool)
  EndProcedure
  
  ;------------------------------------------------------------------
  ; Convert 2D Mouse Position to 3D Position
  ;------------------------------------------------------------------
  Procedure ViewToWorld(*v.ViewportUI_t,mx.d,my.d,*world_pos.v3f32)
    Protected view.v3f32
    Vector3::Sub(view,*v\camera\lookat,*v\camera\pos)
    Vector3::NormalizeInPlace(view)
    
    Protected h.v3f32
    Vector3::Cross(h,view,*v\camera\up)
    Vector3::NormalizeInPlace(h)
    
    Protected v.v3f32
    Vector3::Cross(v,h,view)
    Vector3::NormalizeInPlace(v)
    
    
    Protected rad.f = *v\camera\fov * #F32_PI / 180
    Protected vLength.f = Tan(rad/2) * *v\camera\nearplane
    Protected hLength.f = vLength *(*v\sizX/*v\sizY)
    
    Vector3::ScaleInPlace(v,vLength)
    Vector3::ScaleInPlace(h,hLength)
    
    ;Remap mouse coordinates
    mx - *v\sizX * 0.5
    my - *v\sizY * 0.5
    
    mx / (*v\sizX * 0.5)
    my / (*v\sizY* 0.5)
    
  
    Vector3::ScaleInPlace(h,mx)
    Vector3::ScaleInPlace(v,-my)
    
    Protected ray.v3f32
    
    Vector3::ScaleInPlace(view,*v\camera\nearplane)
    Vector3::AddInPlace(view,*v\camera\pos)
    Vector3::Add(ray,h,v)
    Vector3::AddInPlace(ray,view)
    Vector3::Sub(*world_pos,ray,*v\camera\pos)
    Vector3::ScaleInPlace(*world_pos,*v\camera\farplane)
    Vector3::AddInPlace(*world_pos,*v\camera\pos)
  EndProcedure
 
  ;------------------------------------------------------------------
  ; View To Ray
  ;------------------------------------------------------------------
  Procedure ViewToRay(*Me.ViewportUI_t,mx.f,my.f,*ray_dir.v3f32)
    ; 3d normalized device coordinates
    Define x.f = (2 * mx) / *Me\sizX - 1
    Define y.f = 1 - (2 * my) / *Me\sizY
    Define z.f = 1
    Define ray_nds.v3f32
    Vector3::Set(ray_nds, x, y, z)
    
    ; 4d Homogeneous Clip Coordinates
    Define ray_clip.v4f32
    Vector4::Set(ray_clip,ray_nds\x,ray_nds\y,-1.0,1.0)
    
    ; 4d Eye (Camera) Coordinates
    Define inv_proj.m4f32
    Matrix4::Inverse(@inv_proj,*Me\camera\projection)
    Define ray_eye.v4f32
    Vector4::MulByMatrix4(ray_eye,ray_clip,inv_proj,#False)
    ray_eye\z = -1
    ray_eye\w = 0
    
    ; 4d World Coordinates
    Define inv_view.m4f32
    Define ray_world.v4f32
    Matrix4::Inverse(@inv_view,*Me\camera\view)
    Vector4::MulByMatrix4(ray_world,ray_eye,inv_view, #False)
    
    Vector3::Set(*ray_dir,ray_world\x,ray_world\y,ray_world\z)
    Vector3::NormalizeInPlace(*ray_dir)

  EndProcedure
  
  ; ------------------------------------------------------------------
  ;  Get Ray
  ; ------------------------------------------------------------------
  Procedure GetRay(*Me.ViewportUI_t, *ray.Geometry::Ray_t)
    Protected direction.v3f32
    ViewToRay(*Me,*Me\mx,*Me\my,@direction)
    Ray::Set(*ray, *Me\camera\pos, @direction)
  EndProcedure
  
  
;   CompilerIf #USE_BULLET
;   ; ------------------------------------------------------------------
;   ;  Ray Pick
;   ; ------------------------------------------------------------------
;   Procedure RayPick2(*v.ViewportUI_t)
;     Define.d mx,my
;   
;     mx = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseX)
;     my = GetGadgetAttribute(*v\gadgetID,#PB_OpenGL_MouseY)
;     Protected ray_end.v3f32
;   
;     ViewToRay(*v,mx,my,@ray_end)
;     
;     Vector3::ScaleInPlace(ray_end,*v\camera\farplane)
;     Vector3::AddInPlace(ray_end,*v\camera\pos)
;     
;     Protected *scn.Scene::Scene_t = Scene::*current_scene
;     Protected *hit.Object3D::Object3D_t =*scn\rayhit
;     
;     Protected rcr.Bullet::btRaycastResult
;     If Not Bullet::*pick_world
;       Bullet::*pick_world = Bullet::BTCreateDynamicsWorld(Bullet::*bullet_sdk)
;     EndIf
;    
;     
;     Protected i
;     Protected *obj.Object3D::Object3D_t 
;     Protected *bodies.CArray::CArrayPtr = CArray::newCArrayPtr()
;     Protected *body.Bullet::btRigidBody
;     For  i= 0 To CArray::GetCount(*scn\objects)-1
;       *obj = CArray::GetValuePtr(*scn\objects,i)
;       If *obj\type = Object3D::#Polymesh
;         *body = BulletRigidBody::BTCreateRigidBodyFrom3DObject(*obj,Bullet::#TRIANGLEMESH_SHAPE,0.0,Bullet::*pick_world)
;         CArray::AppendPtr(*bodies,*body)
;       EndIf
;     Next
;    
;     If Bullet::BTRayCast(Bullet::*pick_world,*v\camera\pos,@ray_end,@rcr)
;       Protected rcr_worldNorm.v3f32
;       Vector3::Set(rcr_worldNorm, rcr\m_normalWorld\v[0], rcr\m_normalWorld\v[1], rcr\m_normalWorld\v[2])
;       *body = rcr\m_body
;       Protected *shape.Bullet::btCollisionShape = rcr\m_shape
;       
;       If Not *body : ProcedureReturn : EndIf
;       *obj.Object3D::Object3D_t = Bullet::BTGetUserData(*body)
;       
;       If *hit
;         
;         Debug "Hit Object : "+*obj\name
;         Debug "Hit Triangle Index : "+Str(rcr\m_triangleindex)
;         
;         Protected *outT.Transform::Transform_t = *hit\localT
;         Protected *outQ.q4f32 = *outT\t\rot
;         
;         Protected up.v3f32
;         Vector3::Set(up,0,1,0)
;   
;         Quaternion::LookAt(*outQ,rcr_worldNorm,up, #False)
;         Transform::SetRotationFromQuaternion(*outT,*outQ)
;         Transform::SetTranslationFromXYZValues(*outT,rcr\m_positionWorld\v[0],rcr\m_positionWorld\v[1],rcr\m_positionWorld\v[2])
;         Transform::SetScaleFromXYZValues(*outT,1,1,1)
;         
;         Object3D::SetLocalTransform(*hit,*outT)
;         ;         Object3D::SetWireframeColor(*hi,1,0,0)`
;         Object3D::UpdateTransform(*hit,Scene::*current_scene\root\globalT)
;       Else
;         
;         Debug "Ray cast done but NO 3D Object"
;       EndIf
;       
;   
;     Else
;       ;*hit\SetWireframeColor(0,1,0)
;       Debug "Raycast Failed..."
;     EndIf
;     For  i= 0 To CArray::GetCount(*bodies)-1
;       Bullet::BTRemoveRigidBody(*pick_world,CArray::GetValuePtr(*bodies,i))
;     Next
;     CArray::Delete(*bodies)
;   
;     
;     
;   EndProcedure
;   CompilerEndIf
  
  ;-------------------------------------------------------
  ; Unproject
  ;-------------------------------------------------------
  Procedure Unproject(*v.ViewportUI_t, x.f, y.f,*world_pos.v3f32)
    Protected window_pos.v3f32

    Vector3::Set(window_pos,x,*v\sizY-y,0.5)
    Vector3::Echo(window_pos,"Window Pos")
    Protected viewport.v4f32
    Vector4::Set(viewport,*v\posX,*v\posY,*v\sizX,*v\sizY)
    Vector4::Echo(viewport,"Viewport")
    
    Define.m4f32 m,A;
    Define.v4f32 _in,_out;
    
    Protected *view.m4f32 = *v\camera\view
    Protected *proj.m4f32 = *v\camera\projection
    
    ;Calculation For inverting a matrix, compute projection x modelview
    ;And store in A[16]
    Matrix4::Multiply(A,*proj,*view)
  
    ;Now compute the inverse of matrix A
    If Not Matrix4::Inverse(m,A) : ProcedureReturn 0 :EndIf
    
    ;Transformation of normalized coordinates between -1 And 1
    _in\x=window_pos\x/viewport\z*2.0-1.0;
    _in\y=(window_pos\y-viewport\y)/viewport\w*2.0-1.0;
    _in\z=2.0*window_pos\z-1.0;
    _in\w=1.0;
    
    ;Objects coordinates
    Vector4::MulByMatrix4(_out, _in, m, #False)
    Vector4::Echo(_out,"Projected")
  
  ;  If _out\w = 0 
  ;    ProcedureReturn 0
  ;  Else 
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
  Procedure Project(*v.ViewportUI_t,*pos.v3f32,*io_pos.v3f32, homogenous.b=#True)

    Define *proj.Math::m4f32 = *v\camera\projection
    Define *view.Math::m4f32 = *v\camera\view
    Vector3::MulByMatrix4(*io_pos, *pos, *view)
    Vector3::MulByMatrix4InPlace(*io_pos, *proj)
    If Not homogenous
      *io_pos\x = *v\context\width * (*io_pos\x + 1.0) / 2.0
      *io_pos\y = *v\context\height * (1.0 - ((*io_pos\y + 1.0) / 2.0))
      *io_pos\z = 0.0
    EndIf
    

  EndProcedure
   
  ;-------------------------------------------------------
  ; Blit Between Contexts
  ;-------------------------------------------------------
  Procedure Blit(*Me.ViewportUI_t, *framebuffer.Framebuffer::Framebuffer_t)
;     Debug GLContext::*MAIN_GL_CTXT
;     GLContext::SetContext(GLContext::*MAIN_GL_CTXT)
;     
;     ; set the target framebuffer To Read 
;     glBindFramebuffer(#GL_READ_FRAMEBUFFER, *framebuffer\frame_id)
;     glReadBuffer(#GL_COLOR_ATTACHMENT0)
;     ; read pixels from framebuffer To PBO
;     glBindBuffer(#GL_PIXEL_PACK_BUFFER, *Me\pbo)    
;     glReadPixels(0, 0, GLContext::*MAIN_GL_CTXT\width, GLContext::*MAIN_GL_CTXT\height, #GL_RGBA, #GL_UNSIGNED_BYTE, 0)
;     glBindBuffer(#GL_PIXEL_PACK_BUFFER, 0)
;     
;     ; copy pbo content to texture
;     glBindBuffer(#GL_PIXEL_UNPACK_BUFFER, *Me\pbo)
;     glBindTexture(#GL_TEXTURE_2D, *Me\tex)
;     glActiveTexture(#GL_TEXTURE0)
;     glTexImage2D(#GL_TEXTURE_2D, 0, #GL_RGBA8, GLContext::*MAIN_GL_CTXT\width, GLContext::*MAIN_GL_CTXT\height, 0, #GL_RGBA, #GL_UNSIGNED_BYTE, #Null)
    
    ; draw texture on screen space quad
    glViewport(0,0,*Me\context\width,*Me\context\height)
  Framebuffer::BlitTo(*framebuffer, 0, #GL_COLOR_BUFFER_BIT, #GL_LINEAR)

  EndProcedure
 
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( ViewportUI )
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 135
; FirstLine = 120
; Folding = ----
; EnableXP