

XIncludeFile "../core/Application.pbi"
XIncludeFile "../objects/KDTree.pbi"

UseModule Math
UseModule Time
UseModule OpenGL
UseModule GLFW
UseModule OpenGLExt
UseModule Shape

EnableExplicit

Global *camera.Camera::Camera_t = #Null


; Push Color Array
;--------------------------------------------
Procedure PushColorArray(*node.KDTree::KDNode_t,*mem)
  If *node\left : PushColorArray(*node\left,*mem) : EndIf
  If *node\right : PushColorArray(*node\right,*mem) : EndIf
  
  Protected *pnt.KDTree::KDPoint_t
  If ListSize(*node\indices())
    ForEach *node\indices()
      *pnt = *mem+*node\indices()* SizeOf(KDTree::KDPoint_t)
      *pnt\v[0] = *node\r
      *pnt\v[1] = *node\g
      *pnt\v[2] = *node\b
    Next
  EndIf
  ProcedureReturn *mem
EndProcedure

; Build Color Array
;--------------------------------------------
Procedure BuildColorArray(*tree.KDTree::KDTree_t,*mem)

  *mem = PushColorArray(*tree\root,*mem)
  
  ProcedureReturn *mem
EndProcedure

; Build Color Array
;--------------------------------------------
Procedure BuildQueryColorArray()
  Protected *mem = AllocateMemory(Shape::#POINT_NUM_VERTICES*#PB_Long)
  Protected i,j
  Protected nbs = Shape::#POINT_NUM_VERTICES/3
  Protected *pnt.KDTree::KDPoint_t
  
  For i=0 To nbs-1
    *pnt = *mem+i* SizeOf(KDTree::KDPoint_t)
    j=i/nbs
    Select j%3
      Case 0
        *pnt\v[0]=1
        *pnt\v[0]=0
        *pnt\v[0]=0
      Case 1
        *pnt\v[0]=0
        *pnt\v[0]=1
        *pnt\v[0]=0
      Case 2
        *pnt\v[0]=0
        *pnt\v[0]=0
        *pnt\v[0]=1
    EndSelect
    
  Next

  ProcedureReturn *mem
EndProcedure


; Build Position Array
;--------------------------------------------
Procedure BuildPositionArray(*tree.KDTree::KDTree_t,*mem)
  
  Protected i
  Protected *pnt.KDTree::KDPoint_t
  For i=0 To *tree\m_nbp-1
    *pnt = *mem+i*SizeOf(KDTree::KDPoint_t)
    *pnt\v[0] = Random(100)*0.05
    *pnt\v[1] = Random(100)*0.05
    *pnt\v[2] = Random(100)*0.05
  Next
  
  ProcedureReturn *mem
EndProcedure

; Build Position Array From Shape
;--------------------------------------------
Procedure BuildPositionArrayFromShape(*tree.KDTree::KDTree_t,*mem,shape.i)
  
  Protected i
  Protected *pnt.KDTree::KDPoint_t
  For i=0 To *tree\m_nbp-1
    *pnt = *mem+i*SizeOf(KDTree::KDPoint_t)
    *pnt\v[0] = Random(100)*0.05
    *pnt\v[1] = Random(100)*0.05
    *pnt\v[2] = Random(100)*0.05
  Next
  
  ProcedureReturn *mem
EndProcedure

; Resize
;--------------------------------------------
Procedure Resize(window,gadget,*camera.Camera::Camera_t)
  Protected width = WindowWidth(window,#PB_Window_InnerCoordinate)
  Protected height = WindowHeight(window,#PB_Window_InnerCoordinate)
  ResizeGadget(gadget,0,0,width,height)
  glViewport(0,0,width,height)
  Protected aspect.f = width/height
  Camera::SetDescription(*camera,#PB_Ignore,aspect,#PB_Ignore,#PB_Ignore)
  Camera::UpdateProjection(*camera)
EndProcedure

; DrawKDNode
;--------------------------------------------
Procedure DrawKDNode(*tree.KDTree::KDTree_t,*node.KDTree::KDNode_t,shader.i,ID.i=-1)
  If *node\left
    DrawKDNode(*tree,*node\left,shader)
    DrawKDNode(*tree,*node\right,shader)
  Else
    If *node\hit
    Protected m.m4f32
      Matrix4::SetIdentity(@m)
      Protected min.v3f32,max.v3f32, c.v3f32,s.v3f32
      KDTree::GetBoundingBox(*tree,*node,@min,@max)
      Vector3::Sub(@s,@max,@min)
  ;     Vector3::ScaleInPlace(@s,0.5)
      Vector3::LinearInterpolate(@c,@min,@max,0.5)
      
      Matrix4::SetScale(@m,@s)
      Matrix4::SetTranslation(@m,@c)
      glUniform4f(glGetUniformLocation(shader,"color"),*node\r,*node\g,*node\b,0.25)
      glUniformMatrix4fv(glGetUniformLocation(shader,"offset"),1,#GL_FALSE,@m)
      glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,#Null)
      EndIf

  EndIf
  
  
EndProcedure

; DrawKDTree
;--------------------------------------------
Procedure DrawKDTree(*tree.KDTree::KDTree_t,vao.i,shader,ID=-1)
  glBindVertexArray(vao)
  
   DrawKDNode(*tree,*tree\root,shader.i,ID)
  glBindVertexArray(0)
EndProcedure

Procedure DrawCube(vao)
  glBindVertexArray(vao)
  glDrawElements(#GL_LINES,24,#GL_UNSIGNED_INT,#Null)
  glBindVertexArray(0)
EndProcedure

Procedure DrawQuery(vao,shader)
  glBindVertexArray(vao)
  glUniform4f(glGetUniformLocation(shader,"color"),1,0,0,1)
  glDrawElements(#GL_LINES,Shape::#SPHERE_NUM_EDGES*2,#GL_UNSIGNED_INT,#Null)
  glBindVertexArray(0)
EndProcedure
 
; Draw
;--------------------------------------------
Procedure Draw(*tree.KDTree::KDTree_t,vao)
  glClearColor(0.25,0.25,0.25,1.0)
  glClear(#GL_COLOR_BUFFER_BIT|#GL_DEPTH_BUFFER_BIT)
  
  glEnable(#GL_BLEND)
  glEnable(#GL_POINT_SMOOTH)
  glPointSize(1)
  glEnable(#GL_DEPTH_TEST)
  
  glBindVertexArray(vao)
  glDrawArrays(#GL_POINTS,0,*tree\m_nbp)
  
  glPointSize(12)
  Protected i
;   ForEach *tree\closests()
;     glDrawArrays(#GL_POINTS,*tree\closests()\ID,1)
;   Next
  
  
  glBindVertexArray(0)

EndProcedure

 
; View Event
;--------------------------------------------
 Procedure OpenGLViewEvent(gadget,*camera.Camera::Camera_t,*query.KDTree::KDPoint_t)
   Define.f mx,my
   Define deltax.d, deltay.d
   
   ;Camera::Event(*camera,GadgetX(gadget),GadgetY(gadget),GadgetWidth(gadget),GadgetHeight(gadget))
   Select EventType()
    Case #PB_EventType_KeyDown
      Select GetGadgetAttribute(gadget,#PB_OpenGL_Key)
        Case #PB_Shortcut_Left
          *query\v[0]-0.1
        Case #PB_Shortcut_Right
          *query\v[0]+0.1
        Case #PB_Shortcut_Up
          *query\v[2]-0.1
        Case #PB_Shortcut_Down
          *query\v[2]+0.1
        Case #PB_Shortcut_PageUp
          *query\v[1]+0.1
        Case #PB_Shortcut_PageDown
          *query\v[1]-0.1
      EndSelect

  EndSelect
 
EndProcedure
 

; Main
;--------------------------------------------
If Time::Init()
  Log::Init()
  CompilerIf #USE_GLFW
    glfwInit()
    Define *window.GLFWWindow = glfwCreateFullScreenWindow()
    ;glfwCreateWindow(800,600,"TestGLFW",#Null,#Null)
    glfwMakeContextCurrent(*window)
    GLLoadExtensions()
  CompilerElse
    Define window.i = OpenWindow(#PB_Any,0,0,800,600,"OpenGLGadget",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget)
    Define gadget.i = OpenGLGadget(#PB_Any,0,0,WindowWidth(window,#PB_Window_InnerCoordinate),WindowHeight(window,#PB_Window_InnerCoordinate),#PB_OpenGL_Keyboard)
    SetGadgetAttribute(gadget,#PB_OpenGL_SetContext,#True)
    GLLoadExtensions()
   CompilerEndIf  
   
   FTGL::Init()
   Define *ftgl_drawer.FTGL::FTGL_Drawer = FTGL::New()
   
  Define nbp = 100000
  Define pnt.KDTree::KDPoint_t
  Define *pnt.KDTree::KDPoint_t
  Define *col.KDTree::KDPoint_t
  Define i
  
  *camera = Camera::New("Camera",Camera::#Camera_Perspective)
   
;    Define *position = Shape::?shape_teapot_positions
  Define  *position = AllocateMemory(nbp * 3 *#PB_Float)
  Define  *colors = AllocateMemory(nbp * 3 *#PB_Float)
  
  
  Define *tree.KDTree::KDTree_t = KDTree::New()
  *tree\m_nbp = nbp
  BuildPositionArray(*tree,*position)
  
  Define T.d = Time::Get()
  KDTree::Build(*tree,*position,nbp,12,100)
  BuildColorArray(*tree,*colors)
  Define TBuild.d = Time::Get()
  
  Define query.KDTree::KDPoint_t
  query\v[0] = -1
  query\v[1] = -0.2
  query\v[2] = -1
  Define retID.i
  Define retDist.f
  KDTree::Search(*tree,@query,@retID,@retDist)
;   Define result.s
;   result = "Closest Point ID : "+Str(retID)+"\n"
;   result + "Closest Distance : "+StrF(retDist)+"\n"
;   result + "Num Queries : "+Str(*tree\m_cmps)+"\n"
;   MessageRequester("KDTree",result)
  ; Define.KDTree::KDPoint_t min,max
  ; KDTree::GetBoundingBox(*tree,,@min,@max)
  
  
  ; Camera Setup
  Define.m4f32 model,view,proj
  Matrix4::SetIdentity(@model)
  Define.v3f32 pos,lookat,up
  Vector3::Set(pos,5,10,5)
  Vector3::Set(up,0,1,0)
  Matrix4::GetViewMatrix(@view,@pos,@lookat,@up)
  Matrix4::GetProjectionMatrix(@proj,60,1.4,0.01,10000)
  
  Define *wireframe.Program::Program_t = Program::New("","")
  Program::Build(*wireframe,"wireframe")
  Define *cloud.Program::Program_t = Program::New("","")
  Program::Build(*wireframe,"cloud")
  
  glUseProgram(*wireframe\pgm)
  
   ; Cube
  Define cube_vao.i
  glGenVertexArrays(1,@cube_vao)
  glBindVertexArray(cube_vao)
  
  Define cube_vbo.i
  glGenBuffers(1,@cube_vbo)
  glBindBuffer(#GL_ARRAY_BUFFER,cube_vbo)
  glBufferData(#GL_ARRAY_BUFFER,8*3*#PB_Float,Shape::?shape_cube_positions,#GL_STATIC_DRAW)

  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,#Null)
  
   Define cube_eab.i
  glGenBuffers(1,@cube_eab)
  glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,cube_eab)
  glBufferData(#GL_ELEMENT_ARRAY_BUFFER,24*#PB_Long,Shape::?shape_cube_edges,#GL_STATIC_DRAW)

  glBindVertexArray(0)
  
  ; Query
  Define query_vao.i
  glGenVertexArrays(1,@query_vao)
  glBindVertexArray(query_vao)
  
  Define query_vbo.i
  glGenBuffers(1,@query_vbo)
  glBindBuffer(#GL_ARRAY_BUFFER,query_vbo)
  glBufferData(#GL_ARRAY_BUFFER,Shape::#POINT_NUM_VERTICES*6*#PB_Float,#Null,#GL_STATIC_DRAW)
  glBufferSubData(#GL_ARRAY_BUFFER,0,Shape::#POINT_NUM_VERTICES*3*#PB_Float,Shape::?shape_point_positions)
  
  Define *query_colors = BuildQueryColorArray()
  glBufferSubData(#GL_ARRAY_BUFFER,Shape::#POINT_NUM_VERTICES*3*#PB_Float,Shape::#POINT_NUM_VERTICES*3*#PB_Float,*query_colors)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,#Null)
  
  Define query_eab.i
  glGenBuffers(1,@query_eab)
  glBindBuffer(#GL_ELEMENT_ARRAY_BUFFER,query_eab)
  glBufferData(#GL_ELEMENT_ARRAY_BUFFER,Shape::#POINT_NUM_EDGES*2*#PB_Long,Shape::?shape_point_edges,#GL_STATIC_DRAW)
  
  glUseProgram(*cloud\pgm)
  ;Point Cloud
  Define vao.i
  glGenVertexArrays(1,@vao)
  glBindVertexArray(vao)
  
  Define vbo.i
  glGenBuffers(1,@vbo)
  glBindBuffer(#GL_ARRAY_BUFFER,vbo)
  glBufferData(#GL_ARRAY_BUFFER,nbp*6*#PB_Float,#Null,#GL_STATIC_DRAW)
  
  glBufferSubData(#GL_ARRAY_BUFFER,0,nbp*3*#PB_Float,*position)
  glBufferSubData(#GL_ARRAY_BUFFER,nbp*3*#PB_Float,nbp*3*#PB_Float,*colors)
  
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0,3,#GL_FLOAT,#GL_FALSE,0,#Null)
   
  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1,3,#GL_FLOAT,#GL_FALSE,0,nbp*3*#PB_Float)   
;   glBindVertexArray(0)
;   glBindBuffer(#GL_ARRAY_BUFFER,0)

  Define offset.m4f32,model.m4f32
  Matrix4::SetIdentity(@offset)
  Matrix4::SetIdentity(@model)
  Define a.v3f32
  Define b.v3f32
  Define c.v3f32
  Define m.m4f32
  Define q.q4f32
  Define p.v3f32
  Quaternion::SetIdentity(@q)
  Matrix4::SetFromQuaternion(@m,@q)
  Define pID = 0
  Define TSearch.d
  CompilerIf #USE_GLFW
    While Not glfwWindowShouldClose(*window)
      glfwPollEvents()

      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"offset"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE,*camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE,*camera\projection)
      Draw(vao,nbp)
      DrawKDTree(*tree,cube_vao,shader)
;       DrawQuery(query_vao)
      glfwSwapBuffers(*window)
     
    Wend
  CompilerElse
    Define e,w,h
    Repeat
      e = WaitWindowEvent(1000/60)
      w = GadgetWidth(gadget)
      h = GadgetHeight(gadget)
      glEnable(#GL_DEPTH_TEST)
      If e=#PB_Event_SizeWindow
        Resize(window,gadget,*camera)
      EndIf
      
;       Camera::Event(*camera,mx,my,vwidth,vheight)
        Camera::OnEvent(*camera,gadget)

       Matrix4::SetIdentity(@offset)
      OpenGLViewEvent(gadget,*camera,@query)
      glUseProgram(*cloud\pgm)
      glUniformMatrix4fv(glGetUniformLocation(*cloud\pgm,"offset"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(*cloud\pgm,"model"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(*cloud\pgm,"view"),1,#GL_FALSE,*camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*cloud\pgm,"projection"),1,#GL_FALSE,*camera\projection)
      pID+1
      If pID>=Shape::#TEAPOT_NUM_VERTICES : pID=0:EndIf
      Draw(*tree,vao)
      
      
      glUseProgram(*wireframe\pgm)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,@offset)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"view"),1,#GL_FALSE,*camera\view)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"projection"),1,#GL_FALSE,*camera\projection)
      DrawKDTree(*tree,cube_vao,*wireframe\pgm)
      
      T = Time::Get()
      KDTree::SearchN(*tree,@query,2,-1)
      TSearch = Time::Get()-T
      Vector3::Set(p,query\v[0],query\v[1],query\v[2])
      Matrix4::SetIdentity(@model)
      Matrix4::SetTranslation(@model,@p)
      Matrix4::SetIdentity(@offset)
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"model"),1,#GL_FALSE,@model)   
      glUniformMatrix4fv(glGetUniformLocation(*wireframe\pgm,"offset"),1,#GL_FALSE,@offset)
      DrawQuery(query_vao,*wireframe\pgm)
      
      glEnable(#GL_BLEND)
      glBlendFunc(#GL_SRC_ALPHA,#GL_ONE_MINUS_SRC_ALPHA)
      glDisable(#GL_DEPTH_TEST)
      FTGL::SetColor(*ftgl_drawer,1,1,1,1)
      Define ss.f = 0.85/w
      Define ratio.f = w / h
      
      FTGL::Draw(*ftgl_drawer,"Nb points : "+Str(nbp),-0.9,0.9,ss,ss*ratio)
      FTGL::Draw(*ftgl_drawer,"Nb queries : "+Str(*tree\m_cmps),-0.9,0.85,ss,ss*ratio)
      FTGL::Draw(*ftgl_drawer,"Nb closests : "+Str(ListSize(*tree\closests())),-0.9,0.8,ss,ss*ratio)
      FTGL::Draw(*ftgl_drawer,"Time to Build KDTree : "+StrD(TBuild),-0.9,0.75,ss,ss*ratio)
      FTGL::Draw(*ftgl_drawer,"Time to Search KDTree : "+StrD(TSearch),-0.9,0.7,ss,ss*ratio)
      glDisable(#GL_BLEND)
      
      SetGadgetAttribute(gadget,#PB_OpenGL_FlipBuffers,#True)

    Until e = #PB_Event_CloseWindow
  CompilerEndIf
EndIf

; glDeleteBuffers(1,@vbo)
; glDeleteVertexArrays(1,@vao)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 424
; FirstLine = 400
; Folding = ---
; EnableXP
; Executable = kdtree.exe
; Debugger = Standalone
; EnableUnicode