XIncludeFile "..\core\Math.pbi"
XIncludeFile "..\core\Array.pbi"
XIncludeFile "Geometry.pbi"
XIncludeFile "Box.pbi"

;====================================================================
; Poisson Module Declaration
;====================================================================
DeclareModule Poisson 
  UseModule Math
  #MAXIMUM_SAMPLES = 4
  
  Structure Poisson_t
    radius.f
    resolution.i[3]
    dimension.v3f32
    box.Geometry::Box_t
    numSamples.i
    *positions.CArray::CArrayV3F32
    *samples.CArray::CArrayInt
    
    List active.i()
  EndStructure
  
  Declare New()
  Declare Delete(*Me.Poisson_t)
  Declare CreateGrid(*poisson.Poisson_t, *bbox.Geometry::Box_t, radius.f)
  Declare.i Sample(*poisson.Poisson_t)
  Declare.b InsertPoint(*poisson.Poisson_t, index.i, *p.v3f32)
  Declare RandomPoint(*poisson.Poisson_t, *p.v3f32)
  Declare SampleMesh(*poisson.Poisson_t, *mesh.Geometry::PolymeshGeometry_t, *t.Transform::Transform_t)
  
EndDeclareModule


;====================================================================
; Poisson Module Implementation
;====================================================================
Module Poisson
  UseModule Math
  Procedure New()
    Protected *Me.Poisson_t = AllocateMemory(SizeOf(Poisson_t))
    InitializeStructure(*Me, Poisson_t)
    
    *Me\positions = CArray::newCArrayV3F32()
    *Me\samples = CArray::newCArrayInt()
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Poisson_t)
    CArray::Delete(*Me\samples)
    CArray::Delete(*Me\positions)
    
    ClearStructure(*Me, Poisson_t)
    FreeMemory(*Me)
  EndProcedure
  
  ; create random point
  Procedure RandomPoint(*Me.Poisson_t, *p.v3f32)
    Protected x.f, y.f, z.f
    x = 1 - 2 * Random_0_1()
    y = 1 - 2 * Random_0_1()
    z = 1 - 2 * Random_0_1()
    Vector3::Set(*p, x,y,z)
    Vector3::NormalizeInPlace(*p)
    
    Protected wr.f = Random_0_1()
    Protected tr.f = *Me\radius * wr +2* *Me\radius*(1-wr)
    Vector3::ScaleInPlace(*p, tr)
  EndProcedure
  
  ; create grid
  Procedure CreateGrid(*Me.Poisson_t, *box.Geometry::Box_t, radius.f)
    *Me\radius = radius
    Box::SetFromOther(*Me\box, *box)
    Protected size.v3f32
    Vector3::Scale(@size, *box\extend, 2.0)
    Protected cubeRoot.f = *Me\radius / Sqr(3)
    
    *Me\resolution[0] = Max(1, Min(Round(size\x / cubeRoot, #PB_Round_Down), 128))
    *Me\resolution[1] = Max(1, Min(Round(size\y / cubeRoot, #PB_Round_Down), 128))
    *Me\resolution[2] = Max(1, Min(Round(size\z / cubeRoot, #PB_Round_Down), 128))
    
    *Me\dimension\x = size\x / *Me\resolution[0]
    *Me\dimension\y = size\y / *Me\resolution[1]
    *Me\dimension\z = size\z / *Me\resolution[2]
    
    ; allocate memory
    *Me\numSamples = *Me\resolution[0] * *Me\resolution[1] * *Me\resolution[2]
    CArray::SetCount(*Me\samples, *Me\numSamples)
    CArray::FillI(*Me\samples, -1)
  EndProcedure
  
  ; insert point
  Procedure.b InsertPoint(*Me.Poisson_t, index.i, *p.v3f32)
    If Box::ContainsPoint(*Me\box, *p)
      Define.l ix, iy, iz, idx
      
      ix = (*p\x-(*Me\box\origin\x-*Me\box\extend\x))/*Me\dimension\x
      iy = (*p\y-(*Me\box\origin\y-*Me\box\extend\y))/*Me\dimension\y
      iz = (*p\z-(*Me\box\origin\z-*Me\box\extend\z))/*Me\dimension\z
      idx = iz * *Me\resolution[0] * *Me\resolution[1] + iy * *Me\resolution[0] + ix
      If idx < *Me\numSamples
        If Carray::GetValueI(*Me\samples, idx) = -1
          CArray::SetValueI(*Me\samples, idx, index)
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Structure ParallelSampleDatas_t
    *poisson.Poisson_t
    *mesh.Geometry::PolymeshGeometry_t
    chunck_start.i
    chunck_end.i
    totalWeights.f
  EndStructure
  
  Procedure ParallelSample(*datas.ParallelSampleDatas_t)
    *datas\totalWeights = 0
    NewList active.i()
    Protected i 
    For i= *datas\chunck_start To *datas\chunck_end -1
      *datas\totalWeights + CArray::GetValueF(*datas\mesh\a_triangleareas, i)  
    Next
    
  EndProcedure
;   Procedure MaProcedureThread(*Valeur)
;     ; La variable '*Valeur' contiendra 23
;   EndProcedure
; 
;   CreateThread(@MaProcedureThread(), 23)

  
  ; sample
  Procedure.i Sample(*Me.Poisson_t)
    ; Initial Sample Point at BBox origin
    Protected p.v3f32, rp.v3f32
    Vector3::SetFromOther(@p, *Me\box\origin)
    CArray::Append(*Me\positions, @p)
    AddElement(*Me\active())
    *Me\active() = 0
    Protected numActives.i = ListSize(*Me\active())
    Protected check.b
    Protected i, index = 0
    While numActives
      check = #False
      For i=0 To #MAXIMUM_SAMPLES - 1
        LastElement(*Me\active())
        RandomPoint(*Me, @rp)
        Vector3::AddInPlace(@rp, CArray::GetValue(*Me\positions, *Me\active()))
        If InsertPoint(*Me, index, @rp)
          CArray::Append(*Me\positions, @rp)
          InsertElement(*Me\active())
          *Me\active() = index
          check = #True
          index + 1
          Break
        EndIf
      Next
      If Not check : DeleteElement(*Me\active()) : EndIf
      numActives = ListSize(*Me\active())
    Wend
    ProcedureReturn index
  EndProcedure
  
  Procedure SampleMesh(*Me.Poisson_t, *mesh.Geometry::PolymeshGeometry_t, *t.Transform::Transform_t)
    PolymeshGeometry::InitSampling(*mesh)
    PolymeshGeometry::Sample(*mesh, *t, 100000, *Me\positions)  
  EndProcedure
  
  

EndModule


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 148
; FirstLine = 113
; Folding = --
; EnableXP