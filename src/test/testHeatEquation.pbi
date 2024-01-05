XIncludeFile "../core/Application.pbi"


UseModule Time
UseModule Math
UseModule OpenGL
CompilerIf #USE_GLFW
  UseModule GLFW
CompilerEndIf

UseModule OpenGLExt

EnableExplicit

DeclareModule HeatDiffusion
  UseModule Math
  Structure _Vertex_t
    index.i                         ; vertex index
    valence.i                       ; num neighbor vertices
    *neighbors.CArray::CArrayLong   ; neighbor indices
    area.f                          ; 1/3 area of surrounding faces
    LCii.f                          ; diagonal laplacian weights
    *LCij.CArray::CArrayFloat       ; off diagonal  laplacian weights
    constrained.b                   ; true when this vertex is the heat source vertex
    u0.f                            ; heat initial condition
    ut.f                            ; heat after time t
    divX.f                          ; divergence of the normalized gradient of u on adjacent faces
    phi.f                           ; distance
  EndStructure
  
  Structure _Face_t
    normal.v3f32
    area.f
    gradu.v3f32
    center.v3f32
  EndStructure
  
  Structure Solver_t
    *mesh.Geometry::PolymeshGeometry_t

    Array faces._Face_t(1)
    Array vertices._Vertex_t(1)
  EndStructure
  
  Declare Init(*solver.Solver_t, *mesh.Polymesh::Polymesh_t)
  Declare Reset(*solver.Solver_t, index.i)
  Declare Laplacian(*solver.Solver_t)
  Declare HeatFlow(*solver.Solver_t, steps.i, t.f)
  Declare GradU(*solver.Solver_t)
  Declare Divergence(*solver.SOlver_t)
  Declare GetColors(*solver.Solver_t, *colors.CArray::CArrayC4F32)
EndDeclareModule

Module HeatDiffusion
  ; Init from mesh geometry
  ;
  Procedure Init(*solver.Solver_t, *mesh.Polymesh::Polymesh_t)
    Define i, j
    Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
    Protected *neighbors.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
    Protected *v._Vertex_t
    *solver\mesh = *geom
    ReDim *solver\vertices(*solver\mesh\nbpoints)
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      *v\neighbors = CArray::New(CArray::#ARRAY_LONG)
      PolymeshGeometry::GetVertexNeighbors(*solver\mesh, i, *v\neighbors)
      *v\valence = CArray::GetCount(*v\neighbors)
      *v\LCij = CArray::New(CArray::#ARRAY_FLOAT)
      CArray::SetCount(*v\LCij, *v\valence)
    Next
    
    
    Debug "num vertices : "+Str(*solver\mesh\nbpoints)
    Debug "num faces : "+Str(*solver\mesh\nbpolygons)
    CARray::Delete(*neighbors)
  EndProcedure
  
  ; Reset heat and distance solution
  ;
  Procedure Reset(*solver.Solver_t, index.i)
    Define i
    Define *v._Vertex_t
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      If i = index
        *v\constrained = #True
        *v\u0 = 1.0
      Else
        *v\constrained = #False
        *v\u0 = 0.0
      EndIf
      *v\ut = *v\u0
      *v\phi = 0
    Next
  EndProcedure
  
  ; Compute laplacian
  ;
  Procedure Laplacian(*solver.Solver_t)
    Define i, j, k
    Define sum.f, val.f, cot0.f, cot1.f
    Define *v._Vertex_t, *n._Vertex_t
    Define *polygons.CArray::CArrayLong = CArray::New(CArray::#ARRAY_LONG)
    PolymeshGeometry::ComputePolygonAreas(*solver\mesh)
    PolymeshGeometry::ComputeVertexPolygons(*solver\mesh)
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      *v\area = 0
      *v\LCii = 0
      For j = 0 To *v\valence - 1
        CArray::SetValueF(*v\LCij, j, 0)
      Next
      
      ; Calculation of vertex areas
      sum = 0.0    
      PolymeshGeometry::GetVertexPolygons(*solver\mesh, i, *polygons)
            
      For j = 0 To CArray::GetCount(*polygons) - 1
        sum + CArray::GetValueF(*solver\mesh\a_polygonareas, CArray::GetValueL(*polygons, j))
      Next
      *v\area = (1.0/3.0)*sum
      
      ; Calculation of LCii and LCij
      sum = 0
      val = 0
      For j = 0 To *v\valence - 1
        k = CArray::GetValueL(*v\neighbors, j)
        cot0 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, i, k)
        cot1 = PolymeshGeometry::ComputeCotangentWeight(*solver\mesh, k, i)
        sum + 1.0/Tan(cot0) + 1.0/Tan(cot1)
        val = (1.0/2.0) * ( 1.0/Tan(cot0) + 1.0/Tan(cot1) )
        CArray::SetValueF(*v\LCij, j, val)
        
      Next
      *v\LCii = (-1.0 / 2.0) * sum
      
    Next
  EndProcedure
  
  ; Solve heat flow 
  ; Perform a specified number of projected Gauss-Seidel steps of the heat diffusion equation
  ;
  Procedure HeatFlow(*solver.Solver_t, steps.i, t.f)
    Define i, j, k
    Define *v._Vertex_t, *n._Vertex_t
    Define sum3.f
    For i = 0 To steps - 1
      For j =0 To ArraySize(*solver\vertices()) - 1
        *v = *solver\vertices(j)
        
        If *v\constrained : Continue : EndIf
        sum3 = 0.0
        For k = 0 To *v\valence - 1
          *n = *solver\vertices(CArray::GetValueL(*v\neighbors, k))
          sum3 + (t * CArray::GetValueF(*v\LCij, k) *  *n\ut)
        Next
        
        *v\ut = (*v\u0 + sum3) / (*v\area - (t * *v\LCii)) 
      Next
    Next
    
  EndProcedure
  
  ; Compute the gradient of heat at each face
  ;
  Procedure GradU(*solver.Solver_t)
    
;     Protected 
;     	Vector3d v = new Vector3d();
;     	Vector3d v1 = new Vector3d();
;     	Point3d a = new Point3d();
;     	Point3d b = new Point3d();
;     	
;     	For (int i = 0; i < faces.size(); i++) {
;         	
;     		Face f = faces.get(i);
;     		HalfEdge fhe = f.he;
;     		f.gradu = new Vector3d();
;     		   		
;     		do {
;     			
;         		a = fhe.head.p;
;         		b = fhe.Next.head.p;
;         		v.sub(b,a);
;         		
;     			v1.cross(f.n,v);    			
;     			v1.scale(fhe.Next.Next.head.ut);
;    			
;     			f.gradu.add(v1);
;     			
;     			fhe = fhe.Next;
;     			
;     		}While(fhe != f.he);
;     		
;     		// the scaling (To make it negative) And normalization 
;     		f.gradu.scale(-1);
;     		f.gradu.normalize();
;     	}
  EndProcedure
  
  ; Compute the divergence of normalized gradients at the vertices
  ;
  Procedure Divergence(*solver.Solver_t)
    
    
  EndProcedure
  
  Procedure GetColors(*solver.Solver_t, *colors.CArray::CArrayC4F32)
    CArray::SetCount(*colors, ArraySize(*solver\vertices()))
    Define i
    Define c.c4f32
    Define *v._Vertex_t
    For i = 0 To ArraySize(*solver\vertices())-1
      *v = *solver\vertices(i)
      Color::Set(c, *v\ut, 1-*v\ut, 0, 1)
      CARray::SetValue(*colors, i, c)
    Next
    
  EndProcedure
  
  
EndModule



Global *app.Application::Application_t
Global *viewport.ViewportUI::ViewportUI_t
Global offset.m4f32
Global model.m4f32
Global view.m4f32
Global proj.m4f32
Global T.f
Global *ftgl_drawer.FTGL::FTGL_Drawer
Global *layer.Layer::Layer_t
Global *solver.HeatDiffusion::Solver_t
Global *colors.CArray::CArrayC4F32
Global *bunny.Polymesh::Polymesh_t
Global N
; Draw
;--------------------------------------------
Procedure Draw(*app.Application::Application_t)
  
  GLContext::SetContext(*viewport\context)
  
  If N > 64
    HeatDiffusion::Reset(*solver, Random(*bunny\geom\nbpoints))
    N = 1
  EndIf
  
    
  HeatDiffusion::HeatFlow(*solver, N, 0.25)
  HeatDiffusion::GetColors(*solver, *colors)
  
  PolymeshGeometry::SetColors(*bunny\geom, *colors)
  Polymesh::SetDirtyState(*bunny, Object3D::#DIRTY_STATE_TOPOLOGY)
  
  Scene::Update(*app\scene)
  
  N + 1
  
  
  Protected *s.Program::Program_t = *viewport\context\shaders("polymesh")
  glUseProgram(*s\pgm)
;   glUniform3f(glGetUniformLocation(*s\pgm, "lightPosition"), *t\t\pos\x, *t\t\pos\y, *t\t\pos\z)
   
  Application::Draw(*app, *layer, *app\camera)
  ViewportUI::Blit(*viewport, *layer\framebuffer)


 EndProcedure
 
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
  
  *app\scene = Scene::New()
  Camera::LookAt(*app\camera)
  Matrix4::SetIdentity(model)
  GLContext::SetContext(*viewport\context)
  
  *layer = LayerDefault::New(width,height,*viewport\context,*app\camera)
  Application::AddLayer(*app, *layer)
  GLContext::AddFramebuffer(*viewport\context, *layer\framebuffer)
 
  ; FTGL Drawer
  ;-----------------------------------------------------
  FTGL::Init()
  *ftgl_drawer = FTGL::New()
  
  *colors = CArray::New(CArray::#ARRAY_C4F32)
  
  *bunny = Polymesh::New("bunny", Shape::#SHAPE_BUNNY)


  Scene::AddChild(*app\scene,*bunny)


  *solver = AllocateStructure(HeatDiffusion::Solver_t)
  HeatDiffusion::Init(*solver, *bunny)
  HeatDiffusion::Laplacian(*solver)
  
  HeatDiffusion::Reset(*solver, Random(*bunny\geom\nbpoints))
  HeatDiffusion::HeatFlow(*solver, 1, 0.4)
  HeatDiffusion::GetColors(*solver, *colors)
  
  PolymeshGeometry::SetColors(*bunny\geom, *colors)
  
  Scene::Setup(*app\scene)

  Application::Loop(*app, @Draw(), 50)
EndIf
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 113
; FirstLine = 97
; Folding = --
; EnableXP