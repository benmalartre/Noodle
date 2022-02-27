XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"
XIncludeFile "Time.pbi"
XIncludeFile "Thread.pbi"

DeclareModule Voronoi
  #NUM_COLORS = 256
  Structure Site_t
    seed.Math::v2f32
    id.i
    Map *neighbors.Site_t()
  EndStructure
  
  Structure Voronoi_t 
    minimum.Math::v2f32
    maximum.Math::v2f32
    cellSize.Math::v2f32
    resolution.i
    *cells[2]
    colors.i[#NUM_COLORS]
    offsets.Math::v2f32[8]
    flip.b
    List sites.Site_t()
    active.i
  EndStructure
  
  Structure JFATaskDatas_t Extends Thread::TaskDatas_t
    *voronoi.Voronoi_t
    divisor.i
  EndStructure
  
  Structure JFAThreadDatas_t Extends Thread::ThreadDatas_t
  EndStructure
  
  
  Declare Init(*voronoi.Voronoi_t, resolution.i, *points.CArray::CArrayV2F32)
  Declare Term(*voronoi.Voronoi_t)
  Declare JFA(*voronoi.Voronoi_t)
  Declare ThreadedJFA(*data.JFAThreadDatas_t)
  Declare Draw(*voronoi.Voronoi_t)
  Declare PositionFromIndex(*voronoi.Voronoi_t, x.i, y.i, *pos.Math::v2f32)
  Declare IndexFromPosition(*voronoi.Voronoi_t, *pos.Math::v2f32)
  Declare ColorTable(*voronoi.Voronoi_t, seed.i=0)
  Declare ColorFromIndex(*voronoi.Voronoi_t, index.i)
  Declare ComputeNeighbors(*voronoi.Voronoi_t)
EndDeclareModule

Module Voronoi
  Procedure Init(*voronoi.Voronoi_t, resolution.i, *points.CArray::CArrayV2F32)
    *voronoi\resolution = resolution
    Protected size = resolution * resolution * #PB_Integer
    *voronoi\cells[0] = AllocateMemory(size)
    *voronoi\cells[1] = AllocateMemory(size)
    FillMemory(*voronoi\cells[0], size, #Null)
    FillMemory(*voronoi\cells[1], size, #Null)
    ColorTable(*voronoi)
    
    Vector2::Set(*voronoi\offsets[0], -1, -1)
    Vector2::Set(*voronoi\offsets[1], 0, -1)
    Vector2::Set(*voronoi\offsets[2], 1, -1)
    Vector2::Set(*voronoi\offsets[3], -1, 0)
    Vector2::Set(*voronoi\offsets[4], 1, 0)
    Vector2::Set(*voronoi\offsets[5], -1, 1)
    Vector2::Set(*voronoi\offsets[6], 0, 1)
    Vector2::Set(*voronoi\offsets[7], 1, 1)
    
    Vector2::Set(*voronoi\minimum, 0, 0)
    Vector2::Set(*voronoi\maximum, 1, 1)
    Vector2::Set(*voronoi\cellSize, 1.0 / resolution, 1.0 / resolution)
    
    Protected *p.Math::v2f32
    Protected *site.Site_t
    Protected i.i
    For s = 0 To CArray::GetCount(*points) - 1
      AddElement(*voronoi\sites())
      InitializeStructure(*voronoi\sites(), Site_t)
      *site = *voronoi\sites()
      *site\id = s
      *p = CArray::GetValue(*points, s)
      Vector2::SetFromOther(*site\seed, *p)
      PokeI(*voronoi\cells[0] + IndexFromPosition(*voronoi, *p) * #PB_Integer, *site)
    Next
    CopyMemory(*voronoi\cells[0], *voronoi\cells[1], size)
  EndProcedure
  
  Procedure Term(*voronoi.Voronoi_t)
    FreeMemory(*voronoi\cells[0])
    FreeMemory(*voronoi\cells[1])
  EndProcedure
  
  Procedure ColorTable(*voronoi.Voronoi_t, seed.i=0)
    For i = 0 To #NUM_COLORS - 1
      *voronoi\colors[i] = RGB(Random(255), Random(255), Random(255))  
    Next
  EndProcedure
  
  Procedure.i ColorFromIndex(*voronoi.Voronoi_t, index.i)
    ProcedureReturn *voronoi\colors[index % #NUM_COLORS]  
  EndProcedure
  
  Procedure PositionFromIndex(*voronoi.Voronoi_t, x.i, y.i, *pos.Math::v2f32)
    Vector2::Set(*pos, (x + 0.5) * *voronoi\cellSize\x + *voronoi\minimum\x, (y + 0.5) * *voronoi\cellSize\y + *voronoi\minimum\y)
  EndProcedure
  
  Procedure IndexFromPosition(*voronoi.Voronoi_t, *pos.Math::v2f32)
    Define x.f = (*pos\x - *voronoi\minimum\x) / (*voronoi\maximum\x - *voronoi\minimum\x) * *voronoi\resolution
    Define y.f = (*pos\y - *voronoi\minimum\y) / (*voronoi\maximum\y - *voronoi\minimum\y) * *voronoi\resolution
    Define index.i = Round(x + y * *voronoi\resolution, #PB_Round_Down)
    If index < 0
      ProcedureReturn 0
    ElseIf index >= *voronoi\resolution * *voronoi\resolution
      ProcedureReturn *voronoi\resolution * *voronoi\resolution
    Else
      ProcedureReturn index
    EndIf
    
  EndProcedure
  
  Procedure JFA(*voronoi.Voronoi_t)
    Define divisor.i = 2
    Define k, x, y
    Define pos.Math::v2f32
    Define current.i
    Define neighbor.i, neighborX.i, neighborY.i
    Define *current_site.Site_t
    Define *neighbor_site.Site_t
    Define d1.f, d2.f
    Define numCells = *voronoi\resolution * *voronoi\resolution
    While Not divisor > *voronoi\resolution 
      k = *voronoi\resolution / divisor
      For idx = 0 To numCells - 1
        x = idx % *voronoi\resolution
        y = idx / *voronoi\resolution
        Vector2::Set(pos, (x + 0.5) * *voronoi\cellSize\x + *voronoi\minimum\x, (y + 0.5) * *voronoi\cellSize\y + *voronoi\minimum\y)
        current = (y * *voronoi\resolution + x)
        
        For z = 0 To 7
          neighborX = x + *voronoi\offsets[z]\x * k
          neighborY = y + *voronoi\offsets[z]\y * k
          If neighborX < 0 Or neighborX >= *voronoi\resolution Or neighborY < 0 Or neighborY >= *voronoi\resolution
            Continue
          EndIf
          neighbor = neighborX + neighborY * *voronoi\resolution
          
          *current_site = PeekI(*voronoi\cells[0] + current * #PB_Integer)
          *neighbor_site = PeekI(*voronoi\cells[0] + neighbor * #PB_Integer)
          If *neighbor_site
            If *neighbor_site = *current_site
              Continue
            EndIf
            
            If *current_site = #Null
              PokeI(*voronoi\cells[0] + current * #PB_Integer, *neighbor_site)
            Else
              d1 = Vector2::DistanceSquared(*current_site\seed, pos)
              d2 = Vector2::DistanceSquared(*neighbor_site\seed, pos)
              If d1 > d2
                PokeI(*voronoi\cells[0] + current * #PB_Integer, *neighbor_site)
              EndIf
            EndIf
          EndIf
        Next
      Next
      
      divisor << 1
    Wend  
    
  EndProcedure
  
  Procedure ThreadedJFA(*datas.JFAThreadDatas_t)
    Define *taskdatas.JFATaskDatas_t = *datas\datas
    Define k = *taskdatas\voronoi\resolution / *taskdatas\divisor
    Define x, y
    Define pos.Math::v2f32
    Define current.i
    Define neighbor.i, neighborX.i, neighborY.i
    Define *current_site.Site_t
    Define *neighbor_site.Site_t
    Define d1.f, d2.f

    For idx = *datas\start_index To *datas\end_index - 1
      x = idx % *taskdatas\voronoi\resolution
      y = idx / *taskdatas\voronoi\resolution
      Vector2::Set(pos, (x + 0.5) * *taskdatas\voronoi\cellSize\x + *taskdatas\voronoi\minimum\x, (y + 0.5) * *taskdatas\voronoi\cellSize\y + *taskdatas\voronoi\minimum\y)
      current = (y * *taskdatas\voronoi\resolution + x)
      *current_site = PeekI(*taskdatas\voronoi\cells[1 - *taskdatas\voronoi\flip] + current * #PB_Integer)
      
      For z = 0 To 7
        neighborX = x + *taskdatas\voronoi\offsets[z]\x * k
        neighborY = y + *taskdatas\voronoi\offsets[z]\y * k
        If neighborX < 0 Or neighborX >= *taskdatas\voronoi\resolution Or neighborY < 0 Or neighborY >= *taskdatas\voronoi\resolution
          Continue
        EndIf
        neighbor = neighborX + neighborY * *taskdatas\voronoi\resolution
        
        *neighbor_site = PeekI(*taskdatas\voronoi\cells[*taskdatas\voronoi\flip] + neighbor * #PB_Integer)
        If *neighbor_site
          If *neighbor_site = *current_site
            Continue
          EndIf
          
          If *current_site = #Null
            PokeI(*taskdatas\voronoi\cells[1 - *taskdatas\voronoi\flip] + current * #PB_Integer, *neighbor_site)
            *current_site = *neighbor_site
          Else
            d1 = Vector2::DistanceSquared(*current_site\seed, pos)
            d2 = Vector2::DistanceSquared(*neighbor_site\seed, pos)
            If d1 > d2
              PokeI(*taskdatas\voronoi\cells[1 - *taskdatas\voronoi\flip] + current * #PB_Integer, *neighbor_site)
              *current_site = *neighbor_site
            EndIf
          EndIf
        EndIf
      Next
    Next
    *datas\job_state = Thread::#THREAD_JOB_DONE
  EndProcedure
  
  Procedure ComputeNeighbors(*voronoi.Voronoi_t)
    Define *currentSite.Site_t, *neighborSite.Site_t
    Define key.s, key2.s
    For y = 0 To *voronoi\resolution - 1
      For x = 0 To *voronoi\resolution - 2
        *currentSite = PeekI(*voronoi\cells[*voronoi\flip] + (x + y * *voronoi\resolution) * #PB_Integer)
        *neighborSite = PeekI(*voronoi\cells[*voronoi\flip] + (x + 1 + y * *voronoi\resolution) * #PB_Integer)
        If Not *currentSite = *neighborSite
          key = Str(*neighborSite)
          key2 = Str(*currentSite)
          If Not FindMapElement(*neighborSite\neighbors(), key)
            AddMapElement(*currentSite\neighbors(), key)
            *currentSite\neighbors() = *neighborSite
            AddMapElement(*neighborSite\neighbors(), key2)
            *neighborSite\neighbors() = *currentSite
          EndIf
        EndIf
      Next
    Next
  EndProcedure
  
  Procedure Draw(*voronoi.Voronoi_t)
    Protected p.i
    Protected *site.Site_t
    SelectElement(*voronoi\sites(), *voronoi\active)
    Protected *active.Site_t = *voronoi\sites()
    For y = 0 To *voronoi\resolution - 1
      For x = 0 To *voronoi\resolution - 1
        p = (x + y * *voronoi\resolution) * #PB_Integer
        *site = PeekI(*voronoi\cells[*voronoi\flip] + p)
        If Not *site = #Null
          Plot(x, y, ColorFromIndex(*voronoi, *site\id))
          If *site = *active
            Plot(x, y, RGBA(255,255,255,65))
          ElseIf FindMapElement(*active\neighbors(), Str(*site))
            Plot(x, y, RGBA(128,128,128,65))
          EndIf
          
        EndIf
      Next
    Next
    
  EndProcedure
EndModule

Procedure _Draw(*voronoi.voronoi::Voronoi_t, canvas, image)
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Voronoi::Draw(*voronoi)
  StopDrawing()

  StartDrawing(CanvasOutput(canvas))
  DrawImage(ImageID(image), 0, 0, GadgetWidth(canvas), GadgetHeight(canvas))
  StopDrawing()
EndProcedure

Time::Init()
Global *pool.Thread::ThreadPool_t = Thread::NewPool()
Define resolution.i = 1024
Define size.i = 1024
Define window.i = OpenWindow(#PB_Any, 0, 0, size, size, "Jump Flood Algorithm")
Define canvas.i = CanvasGadget(#PB_Any, 0, 0, size, size, #PB_Canvas_Keyboard)
Define image.i = CreateImage(#PB_Any, resolution, resolution)

Define n.i = 1024
Define *points.CArray::CArrayV2F32 = CArray::newCArrayV2F32()
Define *p.Math::v2f32
CArray::SetCount(*points, n)
For i = 0 To n - 1
  *p = CArray::GetValue(*points, i)
  Vector2::Set(*p, Random(1000) * 0.001, Random(1000) * 0.001)
Next

Define voronoi.Voronoi::Voronoi_t
Define startT.d = Time::Get()
Voronoi::Init(voronoi, resolution, *points)
Define initT.d = Time::Get() - startT
startT = Time::Get()

Define taskdata.Voronoi::JFATaskDatas_t
taskdata\voronoi = voronoi
taskdata\divisor = 2
taskdata\num_elements = voronoi\resolution * voronoi\resolution
While Not taskdata\divisor > voronoi\resolution 
  Thread::SplitTask(*pool, taskdata, Voronoi::JFAThreadDatas_t, Voronoi::@ThreadedJFA())
  taskdata\divisor << 1
  CopyMemory(voronoi\cells[1 - voronoi\flip], voronoi\cells[voronoi\flip], resolution * resolution * #PB_Integer)
  voronoi\flip = 1 - voronoi\flip
  
Wend  
; voronoi::JFA(voronoi)

Define jfaT.d = Time::Get() - startT

startT = Time::Get()
Voronoi::ComputeNeighbors(voronoi)
Define neighboringT.d = Time::Get() - startT

_Draw(voronoi, canvas, image)

MessageRequester("JFA", "Init Time : "+StrD(initT)+Chr(10)+"JFA Time : "+StrD(jfaT)+Chr(10)+"Neighboring Time : "+StrD(neighboringT))

Define event, eventType, key
Repeat
  event = WaitWindowEvent()
  If event = #PB_Event_Gadget
    eventType = EventType()
    If eventType = #PB_EventType_KeyDown
      key = GetGadgetAttribute(canvas, #PB_Canvas_Key)
      If key = #PB_Shortcut_Down
        voronoi\active - 1
      ElseIf key = #PB_Shortcut_Up
        voronoi\active + 1
      EndIf 
      If voronoi\active < 0
        voronoi\active = n -1
      ElseIf voronoi\active >= n
        voronoi\active = 0
      EndIf
     
      _Draw(voronoi, canvas, image)
    EndIf
  EndIf   
Until event = #PB_Event_CloseWindow

Thread::DeletePool(*pool)
CArray::Delete(*points)
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 308
; FirstLine = 279
; Folding = ---
; EnableXP