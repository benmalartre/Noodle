XIncludeFile "../core/Source.pbi"
XIncludeFile"../core/Pose.pbi"
XIncludeFile "../objects/Skeleton.pbi"
XIncludeFile "../libs/Booze.pbi"


DeclareModule Animation
  
  Enumeration
    #EXTRAPOLATION_NONE
    #EXTRAPOLATION_LOOP
    #EXTRAPOLATION_PINGPONG
  EndEnumeration
  
  Structure Animation_t Extends Source::Source_t
    nbitems.i
    *skeleton.Skeleton::Skeleton_t
    currentframe.i
    numsamples.i
    loop_mode.i
    List *poses.Pose::Pose_t()
    *current.Pose::Pose_t
  EndStructure
  
  Declare New(*skeleton.Skeleton::Skeleton_t)
  Declare Delete(*Me.Animation_t)
  Declare AddPose(*Me.Animation_t,*pose.Pose::Pose_t)
  Declare GetPoseAtFrame(*animation.Animation_t,frame.i)
  Declare Blend(*animation.Animation_t,*A.Pose::Pose_t,*B.Pose::Pose_t,blend.f)
  Declare Load(*animation.Animation_t,path.s,identifier.s)
  
  ;Declare AddKey(*curve.FCurve_t,frame.i,value.f,tangent_in.f,tangent._off.f)
  
EndDeclareModule

Module Animation
  UseModule Math
  ;--------------------------------------------
  ; Constructor
  ;--------------------------------------------
  Procedure New(*skeleton.Skeleton::Skeleton_t)
    Protected *Me.Animation_t = AllocateMemory(SizeOf(Animation_t))
    InitializeStructure(*Me,Animation_t)
    *Me\skeleton = *skeleton
    Protected *Ts.CArray::CArrayTRF32 = CArray::newCArrayTRF32()
    CArray::SetCount(*Ts,*Me\skeleton\nbbones)
    *Me\current = Pose::New(*Ts)
    CArray::Delete  (*Ts)
    
    ProcedureReturn *Me
  EndProcedure
  
  ;--------------------------------------------
  ; Destructor
  ;--------------------------------------------
  Procedure Delete(*Me.Animation_t)
    ForEach *Me\poses()
      Pose::Delete(*Me\poses())
    Next
    
    ClearStructure(*Me,Animation_t)
    FreeMemory(*Me)
  EndProcedure
  
  ;--------------------------------------------
  ; New Pose
  ;--------------------------------------------
  Procedure AddPose(*Me.Animation_t,*pose.Pose::Pose_t)
    AddElement(*Me\poses())
    *Me\poses() = *pose
  EndProcedure
  
  ;--------------------------------------------
  ; Delete Pose
  ;--------------------------------------------
  Procedure RemovePose(*Me.Animation_t,*pose.Pose::Pose_t)

  EndProcedure
  
  ;--------------------------------------------
  ; Get Frame
  ;--------------------------------------------
  Procedure GetPoseAtFrame(*animation.Animation_t,frame.i)
    Protected cframe.i = frame
    Select *animation\loop_mode
      Case #EXTRAPOLATION_NONE
        If frame<=0
          cframe = 0
        ElseIf frame>=*animation\numsamples
          cframe = *animation\numsamples-1
        EndIf
        
      Case #EXTRAPOLATION_LOOP
        
      Case #EXTRAPOLATION_PINGPONG
        
    EndSelect
    
    SelectElement(*animation\poses(),cframe)
    ProcedureReturn *animation\poses()
  EndProcedure
  
  ;--------------------------------------------
  ; Blend
  ;--------------------------------------------
  Procedure Blend(*animation.Animation_t,*A.Pose::Pose_t,*B.Pose::Pose_t,blend.f)
    Protected x
    Protected *scl.v3f32
    Protected *rot.q4f32
    Protected *pos.v3f32
    
    ForEach *animation\current\Ts()
      SelectElement(*A\Ts(),x)
      SelectElement(*B\Ts(),x)
      Vector3::LinearInterpolate(*animation\current\Ts()\t\scl,*A\Ts()\t\scl,*B\Ts()\t\scl,blend)
      Quaternion::Slerp(*animation\current\Ts()\t\rot,*A\Ts()\t\rot,*B\Ts()\t\rot,blend)
      Vector3::LinearInterpolate(*animation\current\Ts()\t\pos,*A\Ts()\t\pos,*B\Ts()\t\pos,blend)
    Next
    
  EndProcedure
  
  ;--------------------------------------------
  ; Blend
  ;--------------------------------------------
  Procedure BlendN(*animation.Animation_t,*poses.CArray::CArrayPtr,*weights.CArray::CArrayFloat)
    Protected i,j
    Protected *scl.v3f32
    Protected *rot.q4f32
    Protected *pos.v3f32
    Protected *pose.Pose::Pose_t
    Protected weight.f
    Protected scl.v3f32
    Protected rot.q4f32
    Protected pos.v3f32
    
    FirstElement(*animation\current\Ts())
    Vector3::Set(*animation\current\Ts()\t\scl,0,0,0)
    Quaternion::SetIdentity(*animation\current\Ts()\t\rot)
    Vector3::Set(*animation\current\Ts()\t\pos,0,0,0)
    
    For i = 0 To CArray::GetCount(*poses)-1
      *pose = CArray::GetValuePtr(*poses,i)
      weight = CArray::GetValueF(*weights,i)
      
      ForEach *pose\Ts()
        SelectElement(*animation\current\Ts(),j)
        Vector3::Scale(@scl,*pose\Ts()\t\scl,weight)
        Vector3::AddInPlace(*animation\current\Ts()\t\scl,@scl)
        Quaternion::MultiplyByScalar(@rot,*pose\Ts()\t\rot,weight)
        Quaternion::AddInPlace(*animation\current\Ts()\t\rot,@rot)
        Vector3::Scale(@pos,*pose\Ts()\t\pos,weight)
        Vector3::AddInPlace(*animation\current\Ts()\t\pos,@pos)
      
        j+1
      Next
      
    Next
    
  EndProcedure
  
  
  ;--------------------------------------------
  ; Load
  ;--------------------------------------------
  Procedure Load(*animation.Animation_t,path.s,identifier.s)
    MessageRequester("ANIMATION","LOAD")
    If FileSize(path)>0 And GetExtensionPart(path) = "abc"
    
      If Alembic::abc_manager<>#Null
        Protected archive.Alembic::IArchive = Alembic::OpenIArchive(path)
        If archive\IsValid()
          If Not archive\NumUses(): archive\Open(path) : EndIf
          
          Protected *model.Model::Model_t = Model::New("Alembic")
          j=0
          For i=0 To archive\GetNumObjects()-1
            If PeekS(archive\GetIdentifier(i), -1, #PB_UTF8) = identifier
              *abc_obj = AlembicIObject::New(archive\GetObject(j))
              If *abc_obj <> #Null
                AlembicIObject::Init(*abc_obj,#Null)
                If AlembicIObject::Get3DObject(*abc_obj)<>#Null
                  *child = AlembicIObject::Get3DObject(*abc_obj)
                  Object3D::AddChild(*model,*child)
                EndIf
              EndIf
              j + 1
            EndIf
            
          Next i
          
         
;           Protected *obj.AlembicIObject::AlembicIObject_t = AlembicIObject::New(archive\GetObject(1));ByName(identifier))
;           AlembicIObject::Init(*obj,#Null)
;           
;           *animation\startframe = archive\GetStartTime()
;           *animation\endframe = archive\GetEndTime()
;           
;           MessageRequester("Alembic Duration : ","("+StrF(*animation\startframe,3)+" TO "+StrF(*animation\endframe,3 )+")")
;   
;           Protected sample.Alembic::ABC_Skeleton_Sample
;           Protected infos.Alembic::ABC_Skeleton_Sample_Infos
;           
;           Protected *geom.Geometry::PointCloudGeometry_t = *obj\obj\geom
;           Protected *ids.CArray::CArrayInt = CArray::newCArrayInt()
;           Protected *scl.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
;           Protected *rot.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
;           Protected *pos.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
;           Protected *col.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
;           Protected *Ts.CArray::CArrayTRF32 = CArray::newCArrayTRF32()
;           
;           Debug "OBJECT : "+Str( *obj\iObj )
        
;         Alembic::ABC_GetSkeletonSampleDescription(*obj\ptr,0,@infos)
;         *animation\nbitems = infos\nbpoints
;         MessageRequester("Skeleton NB Bones : ",Str(*animation\nbitems));         If Not *animation\skeleton\initialized
;           CArray::SetCount(*pos,infos\nbpoints)
;           sample\position = *pos\data
;           
;           CArray::SetCount(*scl,infos\nbpoints)
;           sample\scale = *scl\data
;           CArray::SetCount(*rot,infos\nbpoints)
;           sample\orientation = *rot\data
;           Alembic::ABC_UpdateSkeletonSample(*obj\ptr,@infos,@sample)
;           AlembicObject::UpdateProperties(*obj,0)
;           
;           Protected *static_scl.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
;           Protected *static_rot.CArray::CArrayQ4F32 = CArray::newCArrayQ4F32()
;           Protected *static_pos.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
;           
;           CArray::SetCount(*static_scl,*animation\nbitems)
;           CArray::SetCount(*static_rot,*animation\nbitems)
;           CArray::SetCount(*static_pos,*animation\nbitems)
;           CArray::SetCount(*col,*animation\nbitems)
;           
;           AlembicObject::ApplyProperty2(*obj,"StaticScale",*static_scl)
;           AlembicObject::ApplyProperty2(*obj,"StaticOrientation",*static_rot)
;           AlembicObject::ApplyProperty2(*obj,"StaticPosition",*static_pos)
; ;           AlembicObject::ApplyProperty2(*obj,"Color",*col)
;           
;           Protected *bone.Bone::Bone_t
;           Protected *T2.Transform::Transform_t
;           Protected q.q4f32
;           Protected p.v3f32
;           Quaternion::SetIdentity(@q)
;           For i=0 To infos\nbpoints-1
;             *bone = Bone::New("Bone"+Str(i),i,CArray::GetValue(*static_pos,i),CArray::GetValue(*static_rot,i),CArray::GetValue(*static_scl,i))
; ;             *n.Polymesh::Polymesh_t = Polymesh::New("Cube"+Str(i),Shape::#SHAPE_CUBE)
; ;             Scene::AddChild(Scene::*current_scene,*n)
; ;             *T2 = *n\localT
; ;             Transform::SetScale(*T2,CArray::GetValue(*static_scl,i))
; ;             Transform::SetRotationFromQuaternion(*T2,CArray::GetValue(*static_rot,i))
; ;             Vector3::Set(@p,Random(10),Random(10),Random(10))
; ;             Transform::SetTranslation(*T2,CArray::GetValue(*static_pos,i))
; ;             Object3D::SetLocalTransform(*n,*T2)
;             
;             Skeleton::AddBone(*animation\skeleton,*bone)
;           Next
;           
;           CArray::Delete(*static_scl)
;           CArray::Delete(*static_rot)
;           CArray::Delete(*static_pos)
; ;           
; ;         EndIf
; ;         
;         *animation\numsamples = Alembic::ABC_GetMaxNumSamplesForTimeSamplingIndex(*abc_archive\archive,1)
;         MessageRequester("Num Samples ",Str(*animation\numsamples))
;         
;         Protected *s.v3f32
;         Protected *r.q4f32
;         Protected *t.v3f32
;         Protected *tra.trf32
;         
;         Protected values.s
;         For i=0 To *animation\numsamples-1
;           Alembic::ABC_GetSkeletonSampleDescription(*obj\ptr,i,@infos)
;           CArray::SetCount(*ids,infos\nbpoints)
;           sample\id = CArray::GetPtr(*ids,0)
;           CArray::SetCount(*pos,infos\nbpoints)
;           sample\position = CArray::GetPtr(*pos,0)
;           CArray::SetCount(*scl,infos\nbpoints)
;           sample\scale = CArray::GetPtr(*scl,0)
;           CArray::SetCount(*rot,infos\nbpoints)
;           sample\orientation = CArray::GetPtr(*rot,0)
;           
;           ;Alembic::ABC_UpdatePointCloudSample(*obj\ptr,*infos,*sample)
;           Alembic::ABC_UpdateSkeletonSample(*obj\ptr,@infos,@sample)
;       
;           CArray::SetCount(*Ts,infos\nbpoints)
;           Debug "============================================================"
;           For j=0 To infos\nbpoints-1
;             *s = CArray::GetValue(*scl,j)
;             *r = CArray::GetValue(*rot,j)
;             *t = CArray::GetValue(*pos,j)
;             *tra = CArray::GetValue(*Ts,j)
;             Vector3::SetFromOther(*tra\scl,*s)
;             Quaternion::SetFromOther(*tra\rot,*r)
;             ;Quaternion::SetIdentity(*tra\rot)
;             Vector3::SetFromOther(*tra\pos,*t)
; 
;           Next
;           
;           Protected *pose.Pose::Pose_t = Pose::New(*Ts)
;           AddPose(*animation,*pose)
;           
; ;           Protected *t.trf32
;           Protected ID = 0
;           Debug "--------------------------------------------------------------------"
;           ForEach *pose\Ts()
;             ;Vector3::Echo(*pose\Ts()\t\pos ,"Position ID "+ID)
;             Quaternion::Echo(*pose\Ts()\t\rot ,"Orientation ID "+ID)
;             ID+1
;           Next
; ;           
;          
;           
;         Next
;         
;         MessageRequester("Values",values)
;         
;         
;          
;         
;         AlembicManager::CloseArchive(*abc_manager,*abc_archive)
;         MessageRequester("Animation","Archive Succesfully Closed!!!")
;         
;         CArray::Delete(*scl)
;         CArray::Delete(*rot)
;         CArray::Delete(*pos)
;         CArray::Delete(*col)
;         CArray::Delete(*Ts)

  ;       Define id = 1
  ;       ; CreateObject List
  ;       
  ;       Protected i,j
  ;       Protected *abc_obj.AlembicObject::AlembicObject_t
  ;       Protected *abc_par.AlembicObject::AlembicObject_t = #Null
  ;       Protected *prop.Alembic::ABC_property
  ;       Protected nbp = 0
  ; 
  ;       Protected pName.s
  ;       Protected infos.Alembic::ABC_Attribute_Sample_Infos
  ;       
  ;       For i=0 To AlembicArchive::GetNbObjects(*abc_archive)-1
  ;         Debug "Alembic Object ID "+Str(i)
  ;         *abc_obj = AlembicArchive::CreateObjectByID(*abc_archive,i)
  ;         ;Alembic::ABC_InitObject(*abc_obj\ptr,*abc_obj\type)
  ;         
  ;         AddGadgetItem(explorer,-1,*abc_obj\name)
  ;       
  ;         If *abc_obj\type = Alembic::#ABC_OBJECT_POLYMESH Or *abc_obj\type = Alembic::#ABC_OBJECT_POINTCLOUD
  ;           nbp = Alembic::ABC_GetNumProperties(*abc_obj\ptr)
  ;           Debug *abc_obj\name+" ---> Num Properties : "+Str(nbp)
  ;      
  ;           For j=0 To nbp-1
  ;             Protected *mem = Alembic::ABC_GetPropertyName(*abc_obj\ptr,j)
  ;             If *mem
  ;               pName = PeekS(*mem)
  ;               Debug pName
  ;               *prop = Alembic::ABC_GetProperty(*abc_obj\ptr,j)
  ;               If *prop
  ;                 Debug "Prop : "+Str(*prop)
  ;                 Alembic::ABC_GetAttributeSampleDescription(*prop,1,@infos)
  ;                 Debug ">>> "+pName 
  ;                 Debug "Name "+PeekS(@infos\name,-1,#PB_Ascii)
  ;                 ;Alembic::ABC_GetAttributeValueAtIndex(*prop,1,0)
  ;                 Debug "Nb Items : "+Str(infos\nbitems)
  ;                 Debug "Type : "+Str(infos\type)
  ;               EndIf
  ;               
  ;             Else
  ;               Debug "Property Invalid "+Str(i)
  ;             EndIf
  ;             
  ;           Next
  ;           
  ;         EndIf
  ;         
  ;       Next i
  ; 
  ;       
  ; ;       ; Create a new Model
  ; ;       Protected *model.Model::Model_t = Model::New("Alembic")
  ; ;       
  ; ;       ;Create Objects contained in alembic file
  ; ;       Define i
  ; ;       Protected *abc_obj.AlembicObject::AlembicObject_t
  ; ;       Protected *abc_par.AlembicObject::AlembicObject_t = #Null
  ; ;       Protected *child.Object3D::Object3D_t
  ; ;       For i=0 To AlembicArchive::GetNbObjects(*abc_archive)-1
  ; ;         Debug "Alembic Object ID "+Str(i)
  ; ;         *abc_obj = AlembicArchive::CreateObjectByID(*abc_archive,i)
  ; ;         If *abc_obj <> #Null
  ; ;           AlembicObject::Init(*abc_obj,*abc_par)
  ; ;           If AlembicObject::Get3DObject(*abc_obj)<>#Null
  ; ;             *abc_par = #Null
  ; ;             *child = AlembicObject::Get3DObject(*abc_obj)
  ; ;             Object3D::AddChild(*model,*child)
  ; ;             
  ; ;           Else 
  ; ;             *abc_par = *abc_obj
  ; ;           EndIf
  ; ;         EndIf
  ; ;         
  ; ;       Next i
      Else
        MessageRequester( "[Animation] "," Invalid Alembic Manager")
      EndIf
    EndIf
    
  ;     ProcedureReturn *model
    Else
      MessageRequester( "[Animation] "," Invalid File")
      ProcedureReturn #Null
    EndIf
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 173
; FirstLine = 161
; Folding = --
; EnableXP