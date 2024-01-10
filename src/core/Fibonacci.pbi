XIncludeFile "Math.pbi"
XIncludeFile "Array.pbi"
DeclareModule Fibonacci
  Structure Seed_t
    radius.f
    angle.f
  EndStructure
  
  Structure Fibonacci_t
    N.i
    *positions.CArray::CArrayV3F32
    *sizes.CArray::CArrayInt
  EndStructure
  
  Declare New(N.i)
  Declare Delete(*Me.Fibonacci_t)
  Declare ComputeTable(N.i)
  
  Declare Grid(*Me.Fibonacci_t)
  Declare Disc(*Me.Fibonacci_t)
  Declare Sphere(*Me.Fibonacci_t)
EndDeclareModule

Module Fibonacci
  Procedure New(N.i)
    Protected *Me.Fibonacci_t = AllocateStructure(Fibonacci_t)
    *Me\positions = CArray::New(Types::#TYPE_V3F32)
    *Me\sizes = CArray::New(Types::#TYPE_INT)
    *Me\N = N
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Fibonacci_t)
    CArray::Delete(*Me\positions)
    CArray::Delete(*Me\sizes)
    FreeStructure(*Me)
  EndProcedure
  
  ; Table (fibonacci sequence)
  ;----------------------------------------------------------------------
  Procedure ComputeTable(N.i)
    Define *P = AllocateMemory(N*8)
    Define c, first=0, second=1, nxt
    For c=0 To N-1
      If c<=1
        nxt = c
      Else
        nxt = first + second
        first = second
        second = nxt
      EndIf
      PokeI(*P + c * 8, nxt)
    Next
    ProcedureReturn *P
  EndProcedure
  
  ; Grid (fibonacci grid)
  ;----------------------------------------------------------------------
  Procedure Grid(*Me.Fibonacci_t)
    Define *table = ComputeTable(*Me\N)
    CArray::SetCount(*Me\positions, *Me\N)
    CArray::SetCount(*Me\sizes, *Me\N)
    Define *p.Math::v3f32
    Define x.i=0, y.i=0
    ;Define sp.Math::v2f32, ep.Math::v2f32
    For i=1 To *Me\N-2
      c = Int(Mod(i, 4))
      u = PeekI(*table+i*8)
      v = PeekI(*table+(i-1)*8)
      w = PeekI(*table+(i+1)*8)
      *p = Carray::GetValue(*Me\positions, i)
      Vector3::Set(*p, x, 0, y)
      Select c
        Case 0
          x - v
          y - w
        Case 1
          x - w
        Case 2
          y + u
        Case 3
          x + u
          y - v
      EndSelect
      
      CArray::SetValueI(*Me\sizes, i, u)
    Next
    
    FreeMemory(*table)
  EndProcedure
  
  ; Disc (sunflower head pattern on a disk)
  ;----------------------------------------------------------------------
  Procedure Disc(*Me.Fibonacci_t)
    Define r.f, theta.f
    Define *p.Math::v3f32
    CArray::SetCount(*Me\positions, *Me\N)
    CArray::SetCount(*Me\sizes, *Me\N)
    
    For i= 0 To *Me\N - 1
      *p = CArray::GetValue(*Me\positions, i)
      r = Sqr((i+0.5)/*Me\N)
      theta = Radian(Math::#GOLDEN_ANGLE * (i+0.5))
      Vector3::Set(*p, (r * Cos(theta)), 0, (r * Sin(theta)))
      CArray::SetValueI(*Me\sizes, i, 1)
    Next
  EndProcedure
  
  ; Sphere (sunflower head pattern on a sphere)
  ;----------------------------------------------------------------------
  Procedure Sphere(*Me.Fibonacci_t)
    Define phi.f, theta.f
    Define *p.Math::v3f32
    CArray::SetCount(*Me\positions, *Me\N)
    CArray::SetCount(*Me\sizes, *Me\N)
    
    For i= 0 To *Me\N - 1
      *p = CArray::GetValue(*Me\positions, i)
      phi = ACos(1 - 2*(i+0.5)/*Me\N)
      theta = Radian(Math::#GOLDEN_ANGLE * (i+0.5))

      Vector3::Set(*p,
                   Cos(theta) * Sin(phi),
                   Sin(theta) * Sin(phi),
                   Cos(phi))
      
      CArray::SetValueI(*Me\sizes, i, 1)
    Next
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.10 beta 1 (Windows - x64)
; CursorPosition = 39
; FirstLine = 22
; Folding = --
; EnableXP