XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../core/Pose.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "../libs/OpenGLExt.pbi"
XIncludeFile "../objects/Shapes.pbi"
XIncludeFile "../objects/Object3D.pbi"


;================================================================
; Bone Module Declaration
;================================================================
DeclareModule Bone
  UseModule Math
  Structure Bone_t
    localtransform.Transform::Transform_t
    globaltransform.Transform::Transform_t
    statictransform.Transform::Transform_t
    List *children.Bone_t()
    *parent.Bone_t
    ID.i
    name.s
  EndStructure
  
  Declare New(name.s,ID.i,*pos.v3f32,*ori.q4f32,*scl.v3f32,*parent.Bone::Bone_t = #Null)
  Declare Delete(*bone.Bone_t)
  Declare DeleteBranch(*bone.Bone_t)
  Declare ResetStaticKineState(*bone.Bone_t)
  Declare Update(*bone.Bone_t)
EndDeclareModule

;================================================================
; Skeleton Module Declaration
;================================================================
DeclareModule Skeleton
  UseModule Math
  UseModule OpenGL
  UseModule OpenGLExt
  Structure Skeleton_t
    *cloud.InstanceCloud::InstanceCloud_t
    List *roots.Bone::Bone_t()
    List *bones.Bone::Bone_t()
    nbbones.i
    initialized.b
  EndStructure
  
  Declare New()
  Declare Delete(*Skeleton.Skeleton_t)
  Declare AddBone(*Me.Skeleton_t,*bone.Bone::Bone_t)
  Declare RemoveBone(*Me.Skeleton_t,*bone.Bone::Bone_t)
  Declare SetupPointCloud(*Me.Skeleton_t)
  Declare UpdatePose(*Me.Skeleton_t,*pose.Pose::Pose_t)
EndDeclareModule

;================================================================
; Bone Module Implementation
;================================================================
Module Bone
  UseModule Math
  ; Constructor
  ;--------------------------------------------------------------
  Procedure New(name.s,ID.i,*pos.v3f32,*ori.q4f32,*scl.v3f32,*parent.Bone::Bone_t = #Null)
    Protected *bone.Bone_t = AllocateMemory(SizeOf(Bone_t))
    InitializeStructure(*bone,Bone_t)
    *bone\name = name
    *bone\ID = ID
    *bone\parent = parent
    If *bone\parent
      AddElement(*bone\parent\children())
      *bone\parent\children() = *bone
    EndIf
    
    Transform::Set(*bone\globaltransform,*scl,*ori,*pos)
    If *parent
      Transform::ComputeLocal(*bone\localtransform,*bone\globaltransform,*parent\globaltransform)
    EndIf
    
    Transform::Set(*bone\statictransform,*scl,*ori,*pos)
    ProcedureReturn *bone
  EndProcedure
  
  ; Destructor
  ;--------------------------------------------------------------
  Procedure Delete(*bone.Bone_t)
    Protected *parent.Bone_t = *bone\parent
    
    If ListSize(*bone\children())
      ForEach *bone\children()
        If *parent
          AddElement(*parent\children())
          *parent\children() = *bone\children()
        Else
          *bone\children()\parent = #Null
        EndIf
      Next
    EndIf
    ClearStructure(*bone,Bone_t)
    FreeMemory(*bone)
    
  EndProcedure
  
  ; Destructor Branch
  ;--------------------------------------------------------------
  Procedure DeleteBranch(*bone.Bone_t)
    If ListSize(*bone\children())
      ForEach *bone\children()
        DeleteBranch(*bone\children())
      Next
    EndIf
    Delete(*bone)
  EndProcedure
  
  ; Reset Static Kinematic State
  ;--------------------------------------------------------------
  Procedure ResetStaticKineState(*bone.Bone_t)
    Transform::SetFromOther(*bone\statictransform,*bone\globaltransform)
  EndProcedure
  
  ; Update
  ;--------------------------------------------------------------
  Procedure Update(*bone.Bone_t)
    
  EndProcedure
  
  
EndModule

;================================================================
; Skeleton Module Implementation
;================================================================
Module Skeleton
  Procedure New()
    Protected *Me.Skeleton_t = AllocateMemory(SizeOf(Skeleton_t))
    InitializeStructure(*Me,Skeleton_t)
    *me\cloud = InstanceCloud::New("Skeleton",Shape::#SHAPE_CUBE,0)
    
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Skeleton_t)
    If *Me\cloud:InstanceCloud::Delete(*Me\cloud):EndIf
    ClearStructure(*Me,Skeleton_t)
    FreeMemory(*Me)
  EndProcedure
  
  
  Procedure AddBone(*Me.Skeleton_t,*bone.Bone::Bone_t)
    AddElement(*Me\bones())
    *Me\bones() = *bone
  EndProcedure
  
  Procedure RemoveBone(*Me.Skeleton_t,*bone.Bone::Bone_t)
    ForEach *Me\bones()
      If *me\bones() = *bone
        DeleteElement(*Me\bones())
        Break
      EndIf
    Next
  EndProcedure
  
  Procedure SetupPointCloud(*Me.Skeleton_t)

    Protected *geom.Geometry::PointCloudGeometry_t = *Me\cloud\geom
    Debug "Skeleton Geometry : "+Str(*geom)
    *geom\nbpoints = ListSize(*Me\bones())

    CArray::SetCount(*geom\a_positions,*geom\nbpoints)
    CArray::SetCount(*geom\a_velocities,*geom\nbpoints)
    CArray::SetCount(*geom\a_normals,*geom\nbpoints)
    CArray::SetCount(*geom\a_tangents,*geom\nbpoints)
    CArray::SetCount(*geom\a_scale,*geom\nbpoints)
    CArray::SetCount(*geom\a_size,*geom\nbpoints)
    CArray::SetCount(*geom\a_color,*geom\nbpoints)
    CArray::SetCount(*geom\a_indices,*geom\nbpoints)
    CArray::SetCount(*geom\a_uvws,*geom\nbpoints)

    
    Protected ID = 0
    Protected normal.v3f32
    Protected tangent.v3f32
    Protected *q.q4f32
    Protected c.c4f32
    Color::Set(c,1,0,0,1)
    ForEach *Me\bones()
      CArray::SetValue(*geom\a_scale, ID,*Me\bones()\statictransform\t\scl)
      *q = *Me\bones()\statictransform\t\rot
      Vector3::Set(normal,0,1,0)
      Vector3::MulByQuaternionInPlace(normal,*q)
      Vector3::Set(tangent,1,0,0)
      Vector3::MulByQuaternionInPlace(tangent,*q)
      CArray::SetValue(*geom\a_normals, ID,normal)
      CArray::SetValue(*geom\a_tangents, ID,tangent)

      CArray::SetValue(*geom\a_positions, ID,*Me\bones()\statictransform\t\pos)
      CArray::SetValueL(*geom\a_indices,ID,ID)
      CArray::SetValueF(*geom\a_size,ID,2)
      CArray::SetValue(*geom\a_color,ID,c)
      ID+1
    Next
    
  EndProcedure
  
  Procedure UpdatePose(*Me.Skeleton_t,*pose.Pose::Pose_t)
     Protected *geom.Geometry::PointCloudGeometry_t = *Me\cloud\geom

    Protected ID = 0
    Protected normal.v3f32
    Protected tangent.v3f32
    Protected *q.q4f32
    Protected c.c4f32
    Color::Set(c,1,0,0,1)
    ForEach *pose\Ts()
      
      CArray::SetValue(*geom\a_scale, ID,*pose\Ts()\t\scl)
      
      *q = *pose\Ts()\t\rot
      Vector3::Set(normal,0,1,0)
      Vector3::MulByQuaternionInPlace(normal,*q)
      Vector3::Set(tangent,1,0,0)
      Vector3::MulByQuaternionInPlace(tangent,*q)
      CArray::SetValue(*geom\a_normals, ID,normal)
      CArray::SetValue(*geom\a_tangents, ID,tangent)
      CArray::SetValue(*geom\a_positions, ID,*pose\Ts()\t\pos)
      CArray::SetValueL(*geom\a_indices,ID,ID)
      CArray::SetValueF(*geom\a_size,ID,2)
      CArray::SetValue(*geom\a_color,ID,c)
      ID+1
    Next
    
    *Me\cloud\dirty = Object3D::#DIRTY_STATE_TOPOLOGY
  EndProcedure
  
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 225
; FirstLine = 180
; Folding = ---
; EnableXP