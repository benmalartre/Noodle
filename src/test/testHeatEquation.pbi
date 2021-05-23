XIncludeFile "../core/Application.pbi"


UseModule Time
UseModule Math
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

Procedure XIndex(index, nx, ny, nz)
  ProcedureReturn index % nx
EndProcedure

Procedure YIndex(index, nx, ny, nz)
  ProcedureReturn (index /(nx)) % ny
EndProcedure

Procedure ZIndex(index, nx, ny, nz)
  ProcedureReturn index / (nx * ny)
EndProcedure

Procedure Index(x, y, z, nx, ny, nz)
  ProcedureReturn z *(nx*ny) + y * nx + nx  
EndProcedure

Procedure InitHeat(Array heats.f(3), nx, ny, nz)
  Protected nc = nx * ny * nz
  Protected ix, iy, iz, c
  For c=0 To nc-1
    ix = XIndex(c, nx, ny, nz)
    iy = YIndex(c, nx, ny, nz)
    iz = Zindex(c, nx, ny, nz)
    
    If ix = 0
      heats(ix,iy,iz) = Math::#F32_MAX
    Else
      heats(ix,iy,iz) = 0.0
    EndIf
    
  Next
EndProcedure

Procedure SwapHeat(Array heats.f(3), Array heats_n.f(3), nx, ny, nz)
  Define x, y, z
  For x=0 To nx-1
    For y=0 To ny-1
      For z=0 To nz-1
        heats(x, y, z) = heats_n(x, y, z)
      Next
    Next
  Next
EndProcedure




Procedure SetColors(*geom.Geometry::PointCloudGeometry_t, Array heats.f(3), nx, ny, nz)
  Protected nc = nx * ny * nz
  Protected ix, iy, iz, c
  Define *colors.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
  CArray::SetCount(*colors, nc)
  Define h.f
  Define *c.Math::c4f32
  For c=0 To nc-1
    ix = XIndex(c, nx, ny, nz)
    iy = YIndex(c, nx, ny, nz)
    iz = Zindex(c, nx, ny, nz)
    h = heats(ix, iy, iz)/Math::#F32_MAX
    *c = CArray::GetValue(*colors, c)
    Color::Set(*c, h, 0, 1-h, 1)
  Next
  PointCloudGeometry::SetColors(*geom, *colors)
  
  CArray::Delete(*colors)
  
EndProcedure


Procedure.f Diffuse1D(heat.f, left.f, right.f, d.f)
  If left = -1 And right = -1
    ProcedureReturn heat
  ElseIf left = -1
    ProcedureReturn (1-d) * heat + right * d
  ElseIf right = -1
    ProcedureReturn (1-d) * heat + left * d
  Else
    ProcedureReturn (1-2*d)* heat + left * d + right * d 
  EndIf
EndProcedure

Procedure DiffuseHeat(Array heats.f(3), Array heats_n.f(3),cell.i, nx, ny, nz, d.f)
  Protected x = XIndex(cell, nx, ny, nz)
  Protected y = YIndex(cell, nx, ny, nz)
  Protected z = ZIndex(cell, nx, ny, nz)
  
  Define.f hx, hy, hz
  Define h.f = heats(x, y, z)
  
  ; X Axis
  If x = 0 And x = nx-1
    hx = h
  ElseIf x = 0
    hx = h;Diffuse1D(h, h, heats(x+1, y, z), d)
  ElseIf x = nx-1
    hx = Diffuse1D(h, heats(x-1, y, z), h, d)
  Else 
    hx = Diffuse1D(h, heats(x-1, y, z), heats(x+1, y, z), d)
  EndIf
  
  ; Y Axis
  If y = 0 And y = ny-1
    hy = h
  ElseIf y = 0
    hy = Diffuse1D(h, h, heats(x, y+1, z), d)
  ElseIf y = ny-1
    hy = Diffuse1D(h, heats(x, y-1, z), h, d)
  Else 
    hy = Diffuse1D(h, heats(x, y-1, z), heats(x, y+1, z), d)
  EndIf
  
  ; Z Axis
  If z = 0 And z = nz-1
    hz = h
  ElseIf z = 0
    hz = Diffuse1D(h, h, heats(x, y, z+1), d)
  ElseIf z = nz-1
    hz = Diffuse1D(h, heats(x, y, z-1), h, d)
  Else 
    hz = Diffuse1D(h, heats(x, y, z-1), heats(x, y, z+1), d)
  EndIf
  
  ; feedback to grid
  heats_n(x, y, z) = (hx + hy +hz) / 3
    
EndProcedure


Global *cloud.PointCloud::PointCloud_t
Define scz = 100
Global nx = 32
Global ny = 16
Global nz = 16
Define kappa = 1
Define dx.f = #PI / scz
Define dt.f = Pow(dx, 2)/(8*kappa)
Define time.f = 0.5 * Pow(#PI,2) / kappa
Define nsteps = time/dt

Global nc = nx * ny * nz

Global Dim heats.f(nx, ny, nz)
Global Dim heats_n.f(nx, ny, nz)
InitHeat(heats_n(), nx, ny, nz)
SwapHeat(heats(), heats_n(), nx, ny, nz)

Define X,c, N = 1024
Define d.f = 0.5


; For X=0 To N-1
;   For c=0 To nc-1
;     DiffuseHeat(heats(), heats_n(), c, nx, ny, nz, d)
;   Next
;   SwapHeat(heats(), heats_n(), nx, ny, nz)
; Next



; For(int tt=0;tt<nsteps;tt++){
; 	  For(int i=1;i<siz-1;i++){
; 		  For(int j=1;j<siz-1;j++){	
; 			  grid_n[i][j]=grid[i][j]+ kappa*dt*(grid[i-1][j]+grid[i+1][j]+grid[i][j-1]+grid[i][j+1]-4*grid[i][j])/sq(dx);
; 		  }
; 	  }


Global *buffer.Framebuffer::Framebuffer_t
Global shader.l
Global *s_wireframe.Program::Program_t
Global *s_polymesh.Program::Program_t
Global *s_pointcloud.Program::Program_t
Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *layer.Layer::Layer_t

; Resize
;--------------------------------------------
Procedure Resize(window,gadget)
;   width = WindowWidth(window,#PB_Window_InnerCoordinate)
;   height = WindowHeight(window,#PB_Window_InnerCoordinate)
;   ResizeGadget(gadget,0,0,width,height)
;   glViewport(0,0,width,height)
EndProcedure

; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*app\context)
  
  Define c
  Define d.f = 0.5
  For c=0 To nc-1
    DiffuseHeat(heats(), heats_n(), c, nx, ny, nz, d)
  Next
  SwapHeat(heats(), heats_n(), nx, ny, nz)
  SetColors(*cloud\geom, heats(), nx, ny, nz)
  PointCloud::SetDirtyState(*cloud, Object3D::#DIRTY_STATE_TOPOLOGY)

;   Protected *light.Light::Light_t = CArray::GetValuePtr(Scene::*current_scene\lights,0)
  
;   Protected *t.Transform::Transform_t = *light\localT
  
;   Vector3::Set(*light\pos, Random(10)-5, Random(12)+6, Random(10)-5)
;   Transform::SetTranslationFromXYZValues(*t, *light\pos\x, *light\pos\y, *light\pos\z)
;   Object3D::SetLocalTransform(*light, *t)
;   
  
  Scene::Update(Scene::*current_scene)
  
  
  Protected *s.Program::Program_t = *app\context\shaders("polymesh")
  glUseProgram(*s\pgm)
;   glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
   
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\datas\buffer)


 EndProcedure

 Define useJoystick.b = #False
 
 Define *pnts.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
 CArray::SetCount(*pnts, nc)
 Define x, y, z
 Define *v.v3f32
 For c=0 To nc-1
   x = XIndex(c, nx, ny, nz)
   y = YIndex(c, nx, ny, nz)
   z = ZIndex(c, nx, ny, nz)
   *v = CArray::GetValue(*pnts, c)
   Vector3::Set(*v, x, y, z)
 Next
 
 Define width = 800
 Define height = 600
; Main
;--------------------------------------------
 If Time::Init()
   Log::Init()
   *app = Application::New("Test",width,height)
  
  
  If Not #USE_GLFW
    *viewport = ViewportUI::New(*app\window\main,"ViewportUI", *app\camera, *app\handle)     
    View::SetContent(*app\window\main,*viewport)
    ViewportUI::OnEvent(*viewport,#PB_Event_SizeWindow)
  EndIf
  
  Scene::*current_scene = Scene::New()
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  GLContext::SetContext(*app\context)
  
  *layer = LayerDefault::New(width,height,*app\context,*app\camera)
  Application::AddLayer(*app, *layer)
 
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  *ftgl_drawer = FTGL::New()
  
  *s_pointcloud = Program::NewFromName("cloud")
  shader = *s_pointcloud\pgm
  
  *cloud.PointCloud::PointCloud_t = PointCloud::New("cloud",0)
  
  Scene::AddChild(Scene::*current_scene,*cloud)
  Scene::Setup(Scene::*current_scene,*app\context)
  
  
  Define a.v3f32, b.v3f32
  Vector3::Set(a,-10,0,0)
  Vector3::Set(b,10,0,0)
  
  
  Define p_start.v3f32,p_end.v3f32
  Vector3::Set(p_start,-1,0,0)
  Vector3::Set(p_end,1,0,0)
  PointCloudGeometry::AddPoints(*cloud\geom, *pnts)
  PointCloudGeometry::SetSize(*cloud\geom, 4)
  SetColors(*cloud\geom, heats(), nx, ny, nz)
;   PointCloudGeometry::PointsOnLine(*cloud\geom,p_start,p_end)
  PointCloud::Setup(*cloud,*s_pointcloud)
  Object3D::Freeze(*cloud)
  
  Define i
  Define *geom.Geometry::PointCloudGeometry_t = *cloud\geom
  Define *p.v3f32
  Define msg.s
  
  Application::Loop(*app, @Draw())
EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 267
; FirstLine = 254
; Folding = ---
; EnableXP