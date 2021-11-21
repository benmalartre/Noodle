XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"

DeclareModule Voronoi
  #NUM_COLORS = 256
  Structure Site_t
    seed.Math::v2f32
    id.i
  EndStructure
  
  Structure Voronoi_t
    minimum.Math::v2f32
    maximum.Math::v2f32
    cellSize.Math::v2f32
    resolution.i
    *cells[2]
    colors.i[#NUM_COLORS]
    List sites.Site_t()
    flip.b
  EndStructure
  
  Declare Init(*voronoi.Voronoi_t, resolution.i, *points.CArray::CArrayV2F32)
  Declare Term(*voronoi.Voronoi_t)
  Declare JFA(*voronoi.Voronoi_t, divisor.i)
  Declare Draw(*voronoi.Voronoi_t)
  Declare PositionFromIndex(*voronoi.Voronoi_t, x.i, y.i, *pos.Math::v2f32)
  Declare IndexFromPosition(*voronoi.Voronoi_t, *pos.Math::v2f32)
  Declare ColorTable(*voronoi.Voronoi_t, seed.i=0)
  Declare ColorFromIndex(*voronoi.Voronoi_t, index.i)
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
    
    Vector2::Set(*voronoi\minimum, 0, 0)
    Vector2::Set(*voronoi\maximum, 1, 1)
    Vector2::Set(*voronoi\cellSize, 1.0 / resolution, 1.0 / resolution)
    
    Protected *p.Math::v2f32
    Protected *site.Site_t
    Protected i.i
    For s = 0 To CArray::GetCount(*points) - 1
      AddElement(*voronoi\sites())
      *site = *voronoi\sites()
      *site\id = s
      *p = CArray::GetValue(*points, s)
      Vector2::SetFromOther(*site\seed, *p)
      PokeI(*voronoi\cells[0] + IndexFromPosition(*voronoi, *p) * #PB_Integer, *site)
    Next
    CopyMemory(*voronoi\cells[0], *voronoi\cells[1], *voronoi\resolution * *voronoi\resolution * #PB_Integer)
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
    ProcedureReturn x + y * *voronoi\resolution
  EndProcedure
  
  Procedure NeighborIndex(*voronoi.Voronoi_t, currentX.i, currentY.i, offsetX.i, offsetY.i)
    Define neighborX = currentX + offsetX
    Define neighborY = currentY + offsetY
    If neighborX < 0 Or neighborX >= *voronoi\resolution Or neighborY < 0 Or neighborY >= *voronoi\resolution
      ProcedureReturn -1
    EndIf
  
    ProcedureReturn currentX + offsetX + (currentY + offsetY) * *voronoi\resolution
  EndProcedure
  
  
  Procedure JFA(*voronoi.Voronoi_t, divisor.i)
    Define k.i = *voronoi\resolution / divisor
    Dim offsets.Math::v2f32(8)
    Define pos.Math::v2f32
    Define current.i
    Define neighbor.i
    Define *current_site.Site_t
    Define *neighbor_site.Site_t
    Define *other_site.Site_t
    Define d1.f, d2.f
    Vector2::Set(offsets(0), -k, -k)
    Vector2::Set(offsets(1), 0, -k)
    Vector2::Set(offsets(2), k, -k)
    Vector2::Set(offsets(3), -k, 0)
    Vector2::Set(offsets(4), k, 0)
    Vector2::Set(offsets(5), -k, k)
    Vector2::Set(offsets(6), 0, k)
    Vector2::Set(offsets(7), k, k)
    For y = 0 To *voronoi\resolution - 1
      For x = 0 To *voronoi\resolution - 1
        Vector2::Set(pos, (x + 0.5) * *voronoi\cellSize\x + *voronoi\minimum\x, (y + 0.5) * *voronoi\cellSize\y + *voronoi\minimum\y)
        current = (y * *voronoi\resolution + x)
        
        For z = 0 To 7
          *current_site = PeekI(*voronoi\cells[1 - *voronoi\flip] + current * #PB_Integer)
          neighbor = NeighborIndex(*voronoi, x, y, offsets(z)\x, offsets(z)\y)
          If Not neighbor = -1
            *neighbor_site = PeekI(*voronoi\cells[*voronoi\flip] + neighbor * #PB_Integer)
            If *neighbor_site
              If *neighbor_site = *current_site
                Continue
              EndIf
              
              If *current_site = #Null
                PokeI(*voronoi\cells[1 - *voronoi\flip] + current * #PB_Integer, *neighbor_site)
              Else
                d1 = Vector2::Distance(*current_site\seed, pos)
                d2 = Vector2::Distance(*neighbor_site\seed, pos)
                If d1 > d2
                  PokeI(*voronoi\cells[1 - *voronoi\flip] + current * #PB_Integer, *neighbor_site)
                EndIf
              EndIf
            EndIf
            
          EndIf
        Next
      Next
    Next
    CopyMemory(*voronoi\cells[1 - *voronoi\flip], *voronoi\cells[*voronoi\flip], *voronoi\resolution * *voronoi\resolution * #PB_Integer)
    *voronoi\flip = 1 - *voronoi\flip
  EndProcedure
  
  Procedure Draw(*voronoi.Voronoi_t)
    Protected p.i
    Protected *site.Site_t
    For y = 0 To *voronoi\resolution - 1
      For x = 0 To *voronoi\resolution - 1
        p = (x + y * *voronoi\resolution) * #PB_Integer
        *site = PeekI(*voronoi\cells + p)
        If Not *site = #Null
          Plot(x, y, ColorFromIndex(*voronoi, *site\id))
        EndIf
      Next
    Next
    
  EndProcedure
EndModule

Procedure _Draw(*voronoi.voronoi::Voronoi_t, canvas, image)
  StartDrawing(ImageOutput(image))
  Voronoi::Draw(*voronoi)
  StopDrawing()

  StartDrawing(CanvasOutput(canvas))
  DrawImage(ImageID(image), 0, 0, GadgetWidth(canvas), GadgetHeight(canvas))
  StopDrawing()
EndProcedure

Procedure _JFA(*voronoi.Voronoi::Voronoi_t, canvas, image, divisor)
  Voronoi::JFA(*voronoi, divisor)
  _Draw(*voronoi, canvas, image)
EndProcedure

  

Define resolution.i = 1024
Define size.i = 1024
Define window.i = OpenWindow(#PB_Any, 0, 0, size, size, "Jump Flood Algorithm")
Define canvas.i = CanvasGadget(#PB_Any, 0, 0, size, size)
Define image.i = CreateImage(#PB_Any, resolution, resolution)

Define n.i = 32
Define *points.CArray::CArrayV2F32 = CArray::newCArrayV2F32()
Define *p.Math::v2f32
CArray::SetCount(*points, n)
For i = 0 To n - 1
  *p = CArray::GetValue(*points, i)
  Vector2::Set(*p, Random(1000) * 0.001, Random(1000) * 0.001)
Next

Define voronoi.Voronoi::Voronoi_t
Voronoi::Init(voronoi, resolution, *points)

_Draw(voronoi, canvas, image)

Define j = 2
While Not j > voronoi\resolution
  _JFA(voronoi, canvas, image, j)
  j << 1
Wend

; Define j = voronoi\resolution
; While Not j = 0
;   _JFA(voronoi, canvas, image, j)
;   j >> 1
; Wend

  
Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 136
; FirstLine = 127
; Folding = ---
; EnableXP