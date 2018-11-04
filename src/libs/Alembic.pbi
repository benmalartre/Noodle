; ============================================================================
;  Alembic Module
; ............................................................................
;  ILM/Sony Cache File Format Import Functions
; ============================================================================
;  2013/06/05 | Ben Malartre
;  - creation
; 
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Time.pbi"
XIncludeFile "../core/Array.pbi"
XIncludeFile "../objects/Model.pbi"
XIncludeFile "../objects/Polymesh.pbi"
XIncludeFile "../objects/InstanceCloud.pbi"


; ============================================================================
;  Alembic Module Declaration
; ============================================================================
DeclareModule Alembic
  Global.b ALEMBIC_WITH_HDF5
  Global.s ALEMBIC_VERSION
  Macro ABCGeometricType : l : EndMacro
  Enumeration
    #ABC_OBJECT_UNKNOWN = 0
    #ABC_OBJECT_XFORM
    #ABC_OBJECT_POINTCLOUD
    #ABC_OBJECT_CURVE
    #ABC_OBJECT_POLYMESH
    #ABC_OBJECT_SUBD
    #ABC_OBJECT_FACESET
    #ABC_OBJECT_NUPATCH
    #ABC_OBJECT_CAMERA
    #ABC_OBJECT_LIGHT
  EndEnumeration
  
  Macro ABCPODType : l : EndMacro
  Enumeration
    #ABC_PodType_Boolean
    #ABC_PodType_UInt8
    #ABC_PodType_Int8
    #ABC_PodType_UInt16
    #ABC_PodType_Int16
    #ABC_PodType_UInt32
    #ABC_PodType_Int32
    #ABC_PodType_UInt64
    #ABC_PodType_Int64
    #ABC_PodType_Float16
    #ABC_PodType_Float32
    #ABC_PodType_Float64

    #ABC_PodType_String
    #ABC_PodType_WString
    #ABC_PodType_NumPods
    #ABC_PodType_Unknown
  EndEnumeration
  
  Macro ABCPropertyType : l : EndMacro
  Enumeration
  	#ABC_PropertyType_Compound        ; 0 < A compound property which may contain other properties */
  	#ABC_PropertyType_Scalar          ; 1 < A single value property */
  	#ABC_PropertyType_Array           ; 2 < A property With an Array of values */
  	#ABC_PropertyType_Unknown = 127   ;   < Unknown To the framework */
	EndEnumeration

  Macro ABCGeometryScope : l : EndMacro
  Enumeration
    #ABC_kConstantScope
    #ABC_kUniformScope
    #ABC_kVaryingScope
    #ABC_kVertexScope
    #ABC_kFacevaryingScope
    #ABC_kUnknownScope = 127
  EndEnumeration
  
  Macro ABCTopoVariance : l : EndMacro
  Enumeration
    #ABC_TopoVariance_Constant
    #ABC_TopoVariance_Homogenous
    #ABC_TopoVariance_Heterogenous
  EndEnumeration
  
  Macro ABCDataTraits : l :EndMacro
  Enumeration

  	#ABC_DataTraits_Bool = 0
  	#ABC_DataTraits_UChar
  	#ABC_DataTraits_Char
  	

  	#ABC_DataTraits_UInt16
  	#ABC_DataTraits_Int16
  	
  	#ABC_DataTraits_UInt32
  	#ABC_DataTraits_Int32
  	
  	#ABC_DataTraits_UInt64
  	#ABC_DataTraits_Int64
  	
  	#ABC_DataTraits_Half
  	#ABC_DataTraits_Float
  	#ABC_DataTraits_Double
  	
  	#ABC_DataTraits_String
  	#ABC_DataTraits_WString
  
  	#ABC_DataTraits_V2s
  	#ABC_DataTraits_V2i
  	#ABC_DataTraits_V2f
  	#ABC_DataTraits_V2d
  
  	#ABC_DataTraits_V3s
  	#ABC_DataTraits_V3i
  	#ABC_DataTraits_V3f
  	#ABC_DataTraits_V3d
  
  	#ABC_DataTraits_P2s
  	#ABC_DataTraits_P2i
  	#ABC_DataTraits_P2f
  	#ABC_DataTraits_P2d
  
  	#ABC_DataTraits_P3s
  	#ABC_DataTraits_P3i
  	#ABC_DataTraits_P3f
  	#ABC_DataTraits_P3d
  
  	#ABC_DataTraits_Box2s
  	#ABC_DataTraits_Box2i
  	#ABC_DataTraits_Box2f
  	#ABC_DataTraits_Box2d
  
  	#ABC_DataTraits_Box3s
  	#ABC_DataTraits_Box3i
  	#ABC_DataTraits_Box3f
  	#ABC_DataTraits_Box3d
  
  	#ABC_DataTraits_M33f
  	#ABC_DataTraits_M33d
  	#ABC_DataTraits_M44f
  	#ABC_DataTraits_M44d
  
  	#ABC_DataTraits_Quatf
  	#ABC_DataTraits_Quatd
  
  	#ABC_DataTraits_C3h
  	#ABC_DataTraits_C3f
  	#ABC_DataTraits_C3c
  
  	#ABC_DataTraits_C4h
  	#ABC_DataTraits_C4f
  	#ABC_DataTraits_C4c
  
  	#ABC_DataTraits_N2f
  	#ABC_DataTraits_N2d
  
  	#ABC_DataTraits_N3f
  	#ABC_DataTraits_N3d
  
    #ABC_DataTraits_V4f
  
  	#ABC_DataTraits_Rotf
  
  	#ABC_DataTraits_NumDataTypes
  	#ABC_DataTraits_Unknown

  EndEnumeration
  
  Macro ABCArchiveType : l :EndMacro
  Enumeration
	  #ABC_ArchiveType_HDF5			      ; Archive is an HDF5 archive
	  #ABC_ArchiveType_Ogawa		      ; Archive is an Ogawa archive
	  #ABC_ArchiveType_Any = 127      ; Don't know what archive type it is
	EndEnumeration
	

  ;----------------------------------------
  ;Object Infos
  ;----------------------------------------
  Structure ABC_Object_Infos
    *name
    type.i
    *obj
  EndStructure
  
  ;----------------------------------------
  ;XForm Sample
  ;----------------------------------------
  Structure ABC_XForm_Sample
    pos.f[3]
    ori.f[4]
    scl.f[3]
  EndStructure
  
  ;----------------------------------------
  ;Polymesh Topology Sample
  ;-----------------------------------------
  Structure ABC_Polymesh_Topo_Sample_Infos
    nbpoints.i
    nbfacecount.i
    nbindices.i
    nbsamples.i
    sampleindex.i
    
    hasvelocity.b
  	hasnormal.b
  	hascolor.b
  	hasuvs.b
  	hastangent.b
  	hasenvelope.b
  EndStructure
  
  Structure ABC_Polymesh_TopoSimple_Sample
    *positions
  	*faceindices
  	*facecount  
  EndStructure
  
  Structure ABC_Polymesh_Topo_Sample
    *positions
    *velocities 
    *normals
    *tangents
  	*uvs
  	*colors
  	*faceindices
  	*facecount  
  EndStructure
  
  Structure ABC_Envelope_Sample
    nbdeformers.i
    *indices
    *weights 
  EndStructure
  
  ;----------------------------------------
  ;Polymesh Sample
  ;-----------------------------------------
  Structure ABC_Polymesh_Sample_Infos
    nbpoints.i
    hasvelocity.b
  	sampleindex.i
  EndStructure

  Structure ABC_Polymesh_Sample
    *positions
    *velocities 
  EndStructure
  
  ;----------------------------------------
  ;PointCloud Sample
  ;-----------------------------------------
  Structure ABC_PointCloud_Sample_Infos
    nbpoints.i
    sampleindex.i
    b_velocity.b
	  b_size.b
	  b_orientation.b
  	b_scale.b
  	b_color.b
  EndStructure
  
  Structure ABC_PointCloud_Sample
    *id
    *position
    *velocity
  	*size
  	*orientation
  	*scale
  	*color
  EndStructure
  
  ;----------------------------------------
  ;Skeleton Sample
  ;-----------------------------------------
  Structure ABC_Skeleton_Sample_Infos
  	nbpoints.i
  	sampleindex.i
  EndStructure


  Structure ABC_Skeleton_Sample
  	*id
  	*position
  	*orientation
  	*scale
  	*staticposition
  	*staticorientation
  	*staticscale
  	*color
  EndStructure

  
  ;----------------------------------------
  ;Attribute Sample
  ;-----------------------------------------
  Structure ABC_Attribute_Sample_Infos
    nbitems.i
  	time.f
    type.ABCPropertyType
  	traits.ABCDataTraits
    name.c[32]
  EndStructure

  Structure ABC_Attribute_Sample
  	*datas
  EndStructure
  
  
  ;-----------------------------------------
  ; Property Opaque Structure
  ;-----------------------------------------
  Structure ABC_Property
  EndStructure
  
  ;-----------------------------------------
  ; TimeSampling Opaque Structure
  ;-----------------------------------------
  Structure ABC_TimeSampling
  EndStructure
  
  
  ; Import C Library
  ;-------------------------------------------------------
  If FileSize("../../libs")=-2
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        Global alembic_lib = OpenLibrary(#PB_Any, "..\..\libs\x64\windows\PBAlembic.dll")
      CompilerCase #PB_OS_MacOS
        Global alembic_lib = OpenLibrary(#PB_Any, "../../libs/x64/macosx/PBAlembic.so")
      CompilerCase #PB_OS_Linux
         Global alembic_lib = OpenLibrary(#PB_Any, "../../libs/x64/linux/PBAlembic.so")
    CompilerEndSelect
  Else
    CompilerSelect #PB_Compiler_OS
      CompilerCase  #PB_OS_Windows
        Global alembic_lib = OpenLibrary(#PB_Any, "libs\x64\windows\PBAlembic.dll")
      CompilerCase #PB_OS_MacOS
        Global alembic_lib = OpenLibrary(#PB_Any, "libs/x64/macosx/PBAlembic.so")
      CompilerCase #PB_OS_Linux
        Global alembic_lib = OpenLibrary(#PB_Any, "libs/x64/linux/PBAlembic.so")
    CompilerEndSelect
  EndIf
  
  PrototypeC.b ABCHASHDF5SUPPORT()
  PrototypeC ABCVERSION()
  PrototypeC ABCCREATEARCHIVEMANAGER()
  PrototypeC.l ABCDELETEARCHIVEMANAGER(*manager)
  PrototypeC.l ABCGETNUMOPENARCHIVES(*manager)
  PrototypeC ABCOPENARCHIVE(*manager,filename.p-utf8)
  PrototypeC ABCCLOSEARCHIVE(*manager,*archive)
  PrototypeC.b ABCARCHIVEVALID(*archive)
  PrototypeC ABCARCHIVEFORMAT(*archive)
  PrototypeC ABCGETNUMOBJECTSINARCHIVE(*archive)
  PrototypeC.l ABCGETNUMTIMESAMPLINGINARCHIVE(*archive)
  PrototypeC ABCGETMAXNUMSAMPLESFORTIMESAMPLINGINDEX(*archive,index.l)
  PrototypeC ABCGETINFOSFROMARCHIVE(*archive)
  PrototypeC ABCGETOBJECTFROMARCHIVEBYID(*archive,id.l)
  PrototypeC ABCGETOBJECTFROMARCHIVEBYNAME(*archive,id.p-utf8)
  PrototypeC ABCGETOBJECTMETADATA(*object)
  PrototypeC ABCGETOBJECTNAME(*object)
  PrototypeC ABCGETOBJECTFULLNAME(*object)
  PrototypeC ABCGETOBJECTHEADER(*object)
  PrototypeC ABCINITOBJECT(*object,ABCPropertyType)
  
  PrototypeC.f ABCGETSTARTFRAME(*archive, fps.i=24)
  PrototypeC.f ABCGETENDFRAME(*archive, fps.i=24)
  
  PrototypeC ABCGETPROPERTY(*object,ID.i)
  PrototypeC ABCGETNUMPROPERTIES(*object)
  PrototypeC ABCGETPROPERTYNAME(*object,ID.i)
  PrototypeC ABCHASPROPERTY(*object,name.p-utf8)
  PrototypeC ABCGETINTERPRETATION(*object,ID.i)
  ;PrototypeC ABCGETPROPERTYBYNAME(*object,name.p-utf8)
  
  PrototypeC ABCGETATTRIBUTESAMPLEDESCRIPTION(*prop,frame.f,*infos.ABC_Attribute_Sample_Infos)
  PrototypeC ABCGETATTRIBUTESAMPLE(*prop,*infos.ABC_Attribute_Sample_Infos,*iosample.ABC_Attribute_Sample)
  PrototypeC ABCGETATTRIBUTESAMPLENAME(*infos.ABC_Attribute_Sample_Infos)
  PrototypeC ABCGETATTRIBUTEATINDEX(*prop,frame.f,index.i)
  PrototypeC ABCTESTXFORM(*object)
  PrototypeC ABCOBJECTISXFORM(*object)
  PrototypeC ABCGETXFORMSAMPLE(*object,frame.f,*io_sample.ABC_XForm_Sample)
  
  PrototypeC ABCGETGEOMETRYSCOPE(*object)
  PrototypeC ABCSETGEOMETRYSCOPE(*object,scope.ABCGeometryScope)
  
  PrototypeC ABCTESTPOLYMESH(*object)
  PrototypeC ABCOBJECTISPOLYMESH(*object)
  PrototypeC ABCGETPOLYMESHTOPOSAMPLEDESCRIPTION(*object,frame.f,*infos.ABC_Polymesh_Topo_Sample_Infos)
  PrototypeC ABCUPDATEPOLYMESHTOPOSIMPLESAMPLE(*object,*infos.ABC_Polymesh_Topo_Sample_Infos,*iosample.ABC_Polymesh_TopoSimple_Sample) 
  PrototypeC ABCUPDATEPOLYMESHTOPOSAMPLE(*object,*infos.ABC_Polymesh_Topo_Sample_Infos,*iosample.ABC_Polymesh_Topo_Sample) 
  PrototypeC ABCUPDATEPOLYMESHSAMPLE(*object,*infos.ABC_Polymesh_Sample_Infos,*iosample.ABC_Polymesh_Sample) 
  
  PrototypeC ABCOBJECTISPOINTCLOUD(*object)
  PrototypeC ABCGETPOINTCLOUDSAMPLEDESCRIPTION(*object,frame.f,*infos.ABC_PointCloud_Sample_Infos)
  PrototypeC ABCUPDATEPOINTCLOUDSAMPLE(*object,*infos.ABC_PointCloud_Sample_Infos,*iosample.ABC_PointCloud_Sample) 
  
  PrototypeC ABCGETSKELETONSAMPLEDESCRIPTION(*object,frame.f,*infos.ABC_Skeleton_Sample_Infos)
  PrototypeC ABCUPDATESKELETONSAMPLE(*object,*infos.ABC_Skeleton_Sample_Infos,*iosample.ABC_Skeleton_Sample) 
  PrototypeC ABCGETENVELOPE(*object,*iosample.ABC_Envelope_Sample)
  
;   PrototypeC ABCTESTSTRING(input.p-utf8)
  PrototypeC ABCGETFLOATSIZE()
  
  If alembic_lib
    Global ABC_Version.ABCVERSION = GetFunction(alembic_lib, "ABC_Version")
    Global ABC_HasHDF5Support.ABCHASHDF5SUPPORT = GetFunction(alembic_lib, "ABC_HasHDF5Support")
;     Global ABC_TestString.ABCTESTSTRING = GetFunction(alembic_lib, "ABC_TestString")
    Global ABC_CreateArchiveManager.ABCCREATEARCHIVEMANAGER = GetFunction(alembic_lib,"ABC_CreateArchiveManager")
    Global ABC_DeleteArchiveManager.ABCDELETEARCHIVEMANAGER = GetFunction(alembic_lib,"ABC_DeleteArchiveManager")
    Global ABC_GetNumOpenArchives.ABCGETNUMOPENARCHIVES = GetFunction(alembic_lib,"ABC_GetNumOpenArchives")
    Global ABC_GetInfosFromArchive.ABCGETINFOSFROMARCHIVE = GetFunction(alembic_lib,"ABC_GetInfosFromArchive")
    Global ABC_OpenArchive.ABCOPENARCHIVE = GetFunction(alembic_lib,"ABC_OpenArchive")
    Global ABC_CloseArchive.ABCCLOSEARCHIVE = GetFunction(alembic_lib,"ABC_CloseArchive")
    Global ABC_ArchiveValid.ABCARCHIVEVALID = GetFunction(alembic_lib, "ABC_ArchiveValid")
    Global ABC_ArchiveFormat.ABCARCHIVEFORMAT = GetFunction(alembic_lib, "ABC_ArchiveFormat")
    Global ABC_GetNumObjectsInArchive.ABCGETNUMOBJECTSINARCHIVE = GetFunction(alembic_lib,"ABC_GetNumObjectsInArchive")
    Global ABC_GetNumTimeSamplingInArchive.ABCGETNUMTIMESAMPLINGINARCHIVE = GetFunction(alembic_lib,"ABC_GetNumTimeSamplingInArchive")
    Global ABC_GetMaxNumSamplesForTimeSamplingIndex.ABCGETMAXNUMSAMPLESFORTIMESAMPLINGINDEX = GetFunction(alembic_lib,"ABC_GetMaxNumSamplesForTimeSamplingIndex")
    Global ABC_GetObjectFromArchiveByID.ABCGETOBJECTFROMARCHIVEBYID = GetFunction(alembic_lib,"ABC_GetObjectFromArchiveByID")
    Global ABC_GetObjectFromArchiveByName.ABCGETOBJECTFROMARCHIVEBYNAME = GetFunction(alembic_lib,"ABC_GetObjectFromArchiveByName")
    Global ABC_GetStartFrame.ABCGETSTARTFRAME = GetFunction(alembic_lib,"ABC_GetStartFrame")
    Global ABC_GetEndFrame.ABCGETENDFRAME = GetFunction(alembic_lib,"ABC_GetEndFrame")
    Global ABC_GetObjectMetaData.ABCGETOBJECTMETADATA = GetFunction(alembic_lib,"ABC_GetObjectMetaData")
    Global ABC_GetObjectHeader.ABCGETOBJECTHEADER = GetFunction(alembic_lib,"ABC_GetObjectHeader")
    Global ABC_GetObjectName.ABCGETOBJECTNAME= GetFunction(alembic_lib,"ABC_GetObjectName")
    Global ABC_GetObjectFullName.ABCGETOBJECTFULLNAME = GetFunction(alembic_lib,"ABC_GetObjectFullName")
    Global ABC_InitObject.ABCINITOBJECT = GetFunction(alembic_lib,"ABC_InitObject")
    Global ABC_GetProperty.ABCGETPROPERTY = GetFunction(alembic_lib,"ABC_GetProperty")
    Global ABC_GetNumProperties.ABCGETNUMPROPERTIES = GetFunction(alembic_lib,"ABC_GetNumProperties")
    Global ABC_GetPropertyName.ABCGETPROPERTYNAME = GetFunction(alembic_lib,"ABC_GetPropertyName")
    Global ABC_HasProperty.ABCHASPROPERTY = GetFunction(alembic_lib,"ABC_HasProperty")
    Global ABC_GetInterpretation.ABCGETINTERPRETATION = GetFunction(alembic_lib,"ABC_GetInterpretation")
    Global ABC_ObjectIsXForm.ABCOBJECTISXFORM = GetFunction(alembic_lib,"ABC_ObjectIsXForm")
    Global ABC_TestXForm.ABCTESTXFORM = GetFunction(alembic_lib,"ABC_TestXForm")
    Global ABC_GetXFormSample.ABCGETXFORMSAMPLE = GetFunction(alembic_lib,"ABC_GetXFormSample")
    Global ABC_ObjectIsPolymesh.ABCOBJECTISPOLYMESH = GetFunction(alembic_lib,"ABC_ObjectIsPolymesh")
    Global ABC_TestPolymesh.ABCTESTPOLYMESH = GetFunction(alembic_lib,"ABC_TestPolymesh")
    Global ABC_ObjectIsPolymesh.ABCOBJECTISPOLYMESH = GetFunction(alembic_lib,"ABC_ObjectIsPolymesh")
    Global ABC_GetPolymeshTopoSampleDescription.ABCGETPOLYMESHTOPOSAMPLEDESCRIPTION = GetFunction(alembic_lib,"ABC_GetPolymeshTopoSampleDescription")
    Global ABC_UpdatePolymeshTopoSimpleSample.ABCUPDATEPOLYMESHTOPOSIMPLESAMPLE = GetFunction(alembic_lib,"ABC_UpdatePolymeshTopoSimpleSample")
    Global ABC_UpdatePolymeshTopoSample.ABCUPDATEPOLYMESHTOPOSAMPLE = GetFunction(alembic_lib,"ABC_UpdatePolymeshTopoSample")
    Global ABC_UpdatePolymeshSample.ABCUPDATEPOLYMESHSAMPLE = GetFunction(alembic_lib,"ABC_UpdatePolymeshSample")
    Global ABC_GetAttributeSampleDescription.ABCGETATTRIBUTESAMPLEDESCRIPTION = GetFunction(alembic_lib,"ABC_GetAttributeSampleDescription")
    Global ABC_GetAttributeSampleName.ABCGETATTRIBUTESAMPLENAME = GetFunction(alembic_lib,"ABC_GetAttributeSampleName")
    Global ABC_GetAttributeSample.ABCGETATTRIBUTESAMPLE = GetFunction(alembic_lib,"ABC_GetAttributeSample")
    Global ABC_GetAttributeAtIndex.ABCGETATTRIBUTEATINDEX = GetFunction(alembic_lib,"ABC_GetAttributeAtIndex")
    Global ABC_ObjectIsPointCloud.ABCOBJECTISPOINTCLOUD= GetFunction(alembic_lib,"ABC_ObjectIsPointCloud")
    Global ABC_GetPointCloudSampleDescription.ABCGETPOINTCLOUDSAMPLEDESCRIPTION = GetFunction(alembic_lib,"ABC_GetPointCloudSampleDescription")
    Global ABC_UpdatePointCloudSample.ABCUPDATEPOINTCLOUDSAMPLE = GetFunction(alembic_lib,"ABC_UpdatePointCloudSample")
    Global ABC_GetSkeletonSampleDescription.ABCGETSKELETONSAMPLEDESCRIPTION = GetFunction(alembic_lib,"ABC_GetSkeletonSampleDescription")
    Global ABC_UpdateSkeletonSample.ABCUPDATESKELETONSAMPLE = GetFunction(alembic_lib,"ABC_UpdateSkeletonSample")
    Global ABC_GetEnvelope.ABCGETENVELOPE = GetFunction(alembic_lib,"ABC_GetEnvelope")
    
    Global ABC_GetGeometryScope.ABCGETGEOMETRYSCOPE = GetFunction(alembic_lib,"ABC_GetGeometryScope")
    Global ABC_SetGeometryScope.ABCSETGEOMETRYSCOPE = GetFunction(alembic_lib,"ABC_SetGeometryScope")
    
    Global ABC_GetFloatSize.ABCGETFLOATSIZE = GetFunction(alembic_lib,"ABC_GetFloatSize")
  Else
    MessageRequester("Alembic Error","Can't Find Alembic C Library!!")
  EndIf
  
  Declare Init()
  Declare Terminate()
  Declare LoadABCArchive(path.s)
  
  Global *abc_manager
  
EndDeclareModule

; ============================================================================
;  Alembic Object Module Declaration
; ============================================================================
DeclareModule AlembicObject
  Structure AlembicObject_t
    *ptr ; Alembic Object Pointer to dll
    *sample
    type.i
    name.s
    *obj.Object3D::Object3D_t
    *infos      ; Sample Infos
    initialized.b
    *parent.AlembicObject_t
    List *props.Alembic::ABC_Property()
    List *attributes.Attribute::Attribute_t()
  EndStructure
  
  Declare New(*archive,id)
  Declare Delete(*Me.AlembicObject_t)
  Declare GetPtr(*Me.AlembicObject_t)
  Declare Init(*Me.AlembicObject_t,*parent.AlembicObject_t=#Null)
  Declare Get3DObject(*Me.AlembicObject_t)
  Declare GetType(*Me.AlembicObject_t)
  Declare CreateSample(*Me.AlembicObject_t)
  Declare UpdateSample(*Me.AlembicObject_t,frame.f)
  Declare DeleteSample(*Me.AlembicObject_t)
  Declare GetXFormSampleAtFrame(*Me.AlembicObject_t,frame.f)
  Declare GetPolymeshSampleAtFrame(*Me.AlembicObject_t,frame.f)
  Declare Getproperties(*Me.AlembicObject_t)
  Declare UpdateProperties(*Me.AlembicObject_t,frame.f)
  Declare ApplyProperty(*Me.AlembicObject_t,name.s)
  Declare ApplyProperty2(*Me.AlembicObject_t,name.s,*arr.CArray::CArrayT)
  Declare LogProperties(*Me.AlembicObject_t)
EndDeclareModule


; ============================================================================
;  Alembic Archive Module Declaration
; ============================================================================
DeclareModule AlembicArchive
  Structure AlembicArchive_t
    *archive ;pointer to dll
    nbobjects.l
    path.s
    startframe.d
    endframe.d
    Array *objects.AlembicObject::AlembicObject_t(0)
    Map m_objects.i()
    
  EndStructure
  
  Declare New()
  Declare Delete(*Me.AlembicArchive_t)
  Declare CreateObjectByID(*Me.AlembicArchive_t,id.i)
  Declare GetObjectByID(*Me.AlembicArchive_t,id.i)
  Declare GetObjectByName(*Me.AlembicArchive_t,name.s)
  Declare DeleteObjectByID(*Me.AlembicArchive_t,id.i)
  Declare DeleteObjectByName(*Me.AlembicArchive_t,name.s)
  Declare GetNbObjects(*Me.AlembicArchive_t,inspect.b=#False)
  Declare IsValid(*Me.AlembicArchive_t)
  Declare.s GetFormat(*Me.AlembicArchive_t)
EndDeclareModule

; ============================================================================
;  Alembic Manager Module Declaration
; ============================================================================
DeclareModule AlembicManager

  Structure AlembicManager_t
    *manager
    nbopen.l
    Map *archives.AlembicArchive::AlembicArchive_t(0)
    *archive.AlembicArchive ; current archive
  EndStructure
  
  Declare New()
  Declare Delete(*Me.AlembicManager_t)
  Declare OpenArchive(*Me.AlembicManager_t,path.s)
  Declare GetNumOpenArchives(*Me.AlembicManager_t)
  Declare Browse(*Me.AlembicManager_t)
  Declare CloseArchive(*Me.AlembicManager_t,*a.AlembicArchive::AlembicArchive_t)
  ;Declare Update(*Me.AlembicManager_t,frame.f)
EndDeclareModule




; ============================================================================
;  Alembic Module Implementation
; ============================================================================
Module Alembic  
  Procedure Init()
    ALEMBIC_WITH_HDF5 = ABC_HasHDF5Support()
    ALEMBIC_VERSION = PeekS(ABC_Version(), -1, #PB_Ascii)

    *abc_manager = AlembicManager::New()
  EndProcedure
  
  Procedure Terminate()
    AlembicManager::Delete(*abc_manager)
  EndProcedure
  
  Procedure.i LoadABCArchive(path.s)
    If FileSize(path)>0 And GetExtensionPart(path) = "abc"
      
      If *abc_manager<>#Null
        
        Protected *abc_archive.AlembicArchive::AlembicArchive_t = AlembicManager::OpenArchive(*abc_manager,path)
        Debug *abc_archive
        ; Create a new Model
        Protected *model.Model::Model_t = Model::New("Alembic")
        If AlembicArchive::IsValid(*abc_archive)
          Define id = 1
          ;Create Objects contained in alembic file
          Define i
          Protected *abc_obj.AlembicObject::AlembicObject_t
          Protected *abc_par.AlembicObject::AlembicObject_t = #Null
          Protected *child.Object3D::Object3D_t
          For i=0 To AlembicArchive::GetNbObjects(*abc_archive)-1
            *abc_obj = AlembicArchive::CreateObjectByID(*abc_archive,i)
            If *abc_obj <> #Null
              AlembicObject::Init(*abc_obj,*abc_par)
              If AlembicObject::Get3DObject(*abc_obj)<>#Null
                *abc_par = #Null
                *child = AlembicObject::Get3DObject(*abc_obj)
                Object3D::AddChild(*model,*child)
                
              Else 
                *abc_par = *abc_obj
              EndIf
            EndIf
            
          Next i
        EndIf
        
      EndIf
      ProcedureReturn *model
    Else
      MessageRequester( "[Alembic LoadABCArchive] "," Invalid File !!!")
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
EndModule

; ============================================================================
;  Alembic Manager Module Implementation
; ============================================================================

Module AlembicManager
  UseModule Alembic
  ;---------------------------------------------------------
  ; Open Archive
  ;---------------------------------------------------------
  Procedure OpenArchive(*m.AlembicManager_t,path.s)
  
    ; ---[ Check File Exists ]-------------------------------
    If FileSize(path) = 0 Or Not GetExtensionPart(path) = "abc"
      MessageRequester( "[Alembic]"," Open Archive Failed : Invalid File !"+path)
      ProcedureReturn
    EndIf
   ; ---[ Check Already Open TODO !! ]-----------------------
    Protected nbo = ABC_GetNumOpenArchives(*m\manager)
    Protected found.b = #False
    Protected *archive.AlembicArchive::AlembicArchive_t 
    
    If nbo>0
      Protected i
      ForEach *m\archives()
        If *m\archives()\path = path
          *archive = *m\archives()
          found = #True
          Break
        EndIf
        
      Next
    EndIf
    
    
    If Not found
      *archive = AlembicArchive::New()
      *archive\path = path
      *archive\archive = ABC_OpenArchive(*m\manager,path)
      If AlembicArchive::IsValid(*archive)
        
        *archive\nbobjects = ABC_GetNumObjectsInArchive(*archive\archive)
        *archive\startframe = ABC_GetStartFrame(*archive\archive)
        *archive\endframe = ABC_GetEndFrame(*archive\archive)
        
        Dim *archive\objects.AlembicObject::AlembicObject_t(*archive\nbobjects)
        AddMapElement(*m\archives(),*archive\path)
        *m\archives() = *archive
  ;       Protected cnt = ArraySize(*m\archives())+1
  ;       ReDim *m\archives.AlembicArchive::AlembicArchive_t(cnt)
  ;       *m\archives(cnt-1) = *archive
        
          MessageRequester("Alembic ARchive", Str(AlembicArchive::GetNbObjects(*archive))+Chr(10)+Str(*archive\startframe)+Chr(10)+Str(*archive\endframe))
        For i=0 To AlembicArchive::GetNbObjects(*archive)-1
          AlembicArchive::CreateObjectByID(*archive,i)
        Next i
      EndIf
      
        
    EndIf
    
    ProcedureReturn *archive
  EndProcedure
  
  ;---------------------------------------------------------
  ; Close Archive
  ;---------------------------------------------------------
  Procedure CloseArchive(*m.AlembicManager_t,*a.AlembicArchive::AlembicArchive_t)
    If FindMapElement(*m\archives(),*a\path)
      DeleteMapElement(*m\archives(),*a\path)
    EndIf
    Debug "CLOSED : "+Str(ABC_CloseArchive(*m\manager,*a\archive))
    ClearStructure(*a,AlembicArchive::AlembicArchive_t)
    FreeMemory(*a)
  
  EndProcedure
  

  ;---------------------------------------------------------
  ; Get Num Open Archives
  ;---------------------------------------------------------
  Procedure.i GetNumOpenArchives(*m.AlembicManager_t)
    ProcedureReturn ABC_GetNumOpenArchives(*m\manager)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Brows
  ;---------------------------------------------------------
  Procedure Browse(*m.AlembicManager_t)
    If Not *m = #Null
      ;filename.s = "D:\Projects\Test\Alembic\Hierarchy.abc"
      Protected filename.s = OpenFileRequester("Select Alembic File", "D:\Projects\Test\Alembic\Hierarchy.abc", "Alembic (*.abc)|*.abc", 0)
      If Not filename = ""
        If Not *m\archive= OpenArchive(*m,filename) : ProcedureReturn : EndIf
    
        Debug "[Alembic]Nb Objects in Archive : "+Str(AlembicArchive::GetNbObjects(*m\archive))
        Protected i.i
        For i=0 To AlembicArchive::GetNbObjects(*m\archive)-1 
          Protected *obj.AlembicObject::AlembicObject_t = AlembicArchive::GetObjectByID(*m\archive,i)
        Next i
        
        ProcedureReturn *m\archive
      Else
        MessageRequester( "[Alembic]","No Input Alembic File!",#PB_MessageRequester_Ok)
      EndIf
      
    Else
      MessageRequester( "[Alembic]","Can't Open Alembic Manager",#PB_MessageRequester_Ok)
    EndIf
  
  EndProcedure


  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*m.AlembicManager_t)
    If *m And *m\manager
      ABC_DeleteArchiveManager(*m\manager)
      ClearStructure(*m,AlembicManager_t)
     FreeMemory(*m)
   EndIf
  EndProcedure

  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New()
    Protected *Me.AlembicManager_t = AllocateMemory(SizeOf(AlembicManager_t))
    InitializeStructure(*Me,AlembicManager_t)
    *Me\manager = ABC_CreateArchiveManager()
    *Me\nbopen = ABC_GetNumOpenArchives(*Me\manager)
    ProcedureReturn *Me
  EndProcedure
EndModule

; ============================================================================
;  Alembic Archive Module Implementation
; ============================================================================
Module AlembicArchive
  UseModule Alembic
  ;---------------------------------------------------------
  ; Create Object by ID
  ;---------------------------------------------------------
  Procedure CreateObjectByID(*archive.AlembicArchive_t,id.i)
    Protected *obj.AlembicObject::AlembicObject_t = AlembicObject::New(*archive\archive,id)
        
    *archive\objects(id)=*obj
    If *obj\ptr
      Protected name.s = PeekS(ABC_GetObjectName(*obj\ptr),-1,#PB_Ascii)
      Debug name
      *archive\m_objects(name) = id
    EndIf
    
    ProcedureReturn *obj
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Object by ID
  ;---------------------------------------------------------
  Procedure GetObjectByID(*archive.AlembicArchive_t,id.i)
    ProcedureReturn *archive\objects(id)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Object by Name
  ;---------------------------------------------------------
  Procedure GetObjectByName(*archive.AlembicArchive_t,name.s)
    If FindMapElement(*archive\m_objects(),name)
      ProcedureReturn *archive\objects(*archive\m_objects())
    Else
      ProcedureReturn #Null
    EndIf
    
  EndProcedure
  
  ;---------------------------------------------------------
  ; Delete Object by ID
  ;---------------------------------------------------------
  Procedure DeleteObjectByID(*archive.AlembicArchive_t,id.i)
    Debug "[Alembic] Delete Object By ID : Not Implemented!"
  EndProcedure
  
  ;---------------------------------------------------------
  ; Delete Object by Name
  ;---------------------------------------------------------
  Procedure DeleteObjectByName(*archive.AlembicArchive_t,name.s)
    Debug "[Alembic] Delete Object By ID : Not Implemented!"
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Nb Objects
  ;---------------------------------------------------------
  Procedure GetNbObjects(*archive.AlembicArchive_t,inspect.b=#False)
    If inspect
      *archive\nbobjects = ABC_GetNumObjectsInArchive(*archive)
    EndIf
    ProcedureReturn  *archive\nbobjects
  EndProcedure
  
  ;---------------------------------------------------------
  ; Is Valid
  ;---------------------------------------------------------
  Procedure IsValid(*archive.AlembicArchive_t)
    ProcedureReturn ABC_ArchiveValid(*archive\archive)
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Format
  ;---------------------------------------------------------
  Procedure.s GetFormat(*archive.AlembicArchive_t)
    ProcedureReturn PeekS(ABC_ArchiveFormat(*archive\archive), -1,#PB_Ascii)
  EndProcedure

  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*o.AlembicArchive_t)
    ; Delete CAlembicObjects
    Protected i = 0
    For i=0 To GetNbObjects(#True)-1
      DeleteObjectByID(*o,i)
    Next i
    ClearStructure(*o,AlembicArchive_t)
    FreeMemory(*o)
  EndProcedure
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  Procedure.i New()
    Protected *Me.AlembicArchive_t = AllocateMemory(SizeOf(AlembicArchive_t))
    InitializeStructure(*Me,AlembicArchive_t)
    ProcedureReturn *Me
  EndProcedure

EndModule

; ============================================================================
;  Alembic Object Module Implementation
; ============================================================================

Module AlembicObject
  UseModule Math
  ;----------------------------------------
  ; Debug XForm Sample
  ;----------------------------------------
  Procedure ABCDebugXFormSample(*sample.Alembic::ABC_XForm_Sample)
    Debug "Position : ("+StrF(*sample\pos[0])+","+StrF(*sample\pos[1])+","+StrF(*sample\pos[2])+")"  
    Debug "Rotation : ("+StrF(*sample\ori[0])+","+StrF(*sample\ori[1])+","+StrF(*sample\ori[2])+","+StrF(*sample\ori[3])+")" 
    Debug "Scale : ("+StrF(*sample\scl[0])+","+StrF(*sample\scl[1])+","+StrF(*sample\scl[2])+")"
  EndProcedure
  
  ; Debug Polymesh Sample
  ;----------------------------------------
  Procedure ABCDebugPolymeshTopoSample(*sample.Alembic::ABC_Polymesh_Topo_Sample_Infos)
  Debug "Nb Points in Polymesh : "+Str(*sample\nbpoints)
  EndProcedure
  ;}
  
  
  ;---------------------------------------------------------
  ; Get Ptr
  ;---------------------------------------------------------
  Procedure GetPtr(*o.AlembicObject_t)
    ProcedureReturn *o\ptr
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get 3DObject
  ;---------------------------------------------------------
  Procedure Get3DObject(*o.AlembicObject_t)
    ProcedureReturn *o\obj
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Type
  ;---------------------------------------------------------
  Procedure GetType(*o.AlembicObject_t)
    ProcedureReturn *o\type
  EndProcedure
  
  ;---------------------------------------------------------
  ; Create Sample
  ;---------------------------------------------------------
  Procedure CreateSample(*o.AlembicObject_t)
    Select *o\type
      Case Alembic::#ABC_OBJECT_XFORM
        *o\sample = AllocateMemory(SizeOf(Alembic::ABC_XForm_Sample))
        InitializeStructure(*o\sample,Alembic::ABC_XForm_Sample)
        *o\initialized = #False
      Case Alembic::#ABC_OBJECT_POLYMESH
        *o\sample = AllocateMemory(SizeOf(Alembic::ABC_Polymesh_Topo_Sample))
        InitializeStructure(*o\sample,Alembic::ABC_Polymesh_Topo_Sample)
        *o\infos = AllocateMemory(SizeOf(Alembic::ABC_Polymesh_Topo_Sample_Infos))
        Alembic::ABC_GetPolymeshTopoSampleDescription(*o\ptr,1,*o\infos)

        *o\initialized = #False
      Case Alembic::#ABC_OBJECT_POINTCLOUD
        *o\sample = AllocateMemory(SizeOf(Alembic::ABC_PointCloud_Sample))
        InitializeStructure(*o\sample,Alembic::ABC_PointCloud_Sample)
        *o\infos = AllocateMemory(SizeOf(Alembic::ABC_PointCloud_Sample_Infos))
        Alembic::ABC_GetPointCloudSampleDescription(*o\ptr,1,*o\infos)        
        
        Protected *infos.Alembic::ABC_PointCloud_Sample_Infos = *o\infos
        *o\initialized = #False
    EndSelect
  EndProcedure
  
  
  ;---------------------------------------------------------------
  ; Get XForm Sample At Frame
  ;---------------------------------------------------------------
  Procedure GetXFormSampleAtFrame(*abc.AlembicObject_t,frame.f)
    Protected *sample.Alembic::ABC_XForm_Sample = *abc\sample
    If *abc\obj <>#Null

      
      Alembic::ABC_GetXFormSample(*abc\ptr,frame,*sample)
      Protected *t.Transform::Transform_t = *abc\obj\localT
      Transform::SetTranslationFromXYZValues(*t,*sample\pos [0],*sample\pos[1],*sample\pos[2])
      Transform::SetScaleFromXYZValues(*t,*sample\scl[0],*sample\scl[1],*sample\scl[2])
      Protected *q.q4f32 = *t\t\rot
      Quaternion::SetFromAxisAngleValues(*q,*sample\ori[0],*sample\ori[1],*sample\ori[2],*sample\ori[3] * #F32_DEG2RAD)
      Transform::SetRotationFromQuaternion(*t,*q)
      Transform::UpdateMatrixFromSRT(*t)
      Object3D::SetLocalTransform(*abc\obj,*t)
      Protected *parent.Object3D::Object3D_t
      Object3D::UpdateTransform(*abc\obj,*parent\globalT)

    Else
      Alembic::ABC_GetXFormSample(*abc\ptr,frame,*sample)
    EndIf
    
  EndProcedure
  
  ;----------------------------------------
  ; Get PointCloud Sample At Frame
  ;----------------------------------------
  ;{
  Procedure GetPointCloudSampleAtFrame(*o.AlembicObject_t,frame.f)
 
    
    Protected *cloud_sample.Alembic::ABC_PointCloud_Sample = *o\sample
    Protected *cloud.InstanceCloud::InstanceCloud_t = *o\obj
    Protected *cloud_infos.Alembic::ABC_PointCloud_Sample_Infos = *o\infos
    
    Protected *cloud_geom.Geometry::PointCloudGeometry_t = *cloud\geom
    
    Alembic::ABC_GetPointCloudSampleDescription(*o\ptr,frame,*cloud_infos)
    
    CArray::SetCount(*cloud_geom\a_positions,*cloud_infos\nbpoints)
    CArray::SetCount(*cloud_geom\a_velocities,*cloud_infos\nbpoints)
    CArray::SetCount(*cloud_geom\a_color,*cloud_infos\nbpoints)
    CArray::SetCount(*cloud_geom\a_indices,*cloud_infos\nbpoints)
    
    
    *cloud_sample\position = CArray::GetPtr(*cloud_geom\a_positions,0)
    *cloud_sample\velocity = CArray::GetPtr(*cloud_geom\a_velocities,0)
    *cloud_sample\color = CArray::GetPtr(*cloud_geom\a_color,0)
    *cloud_sample\id = CArray::GetPtr(*cloud_geom\a_indices,0)
    
    update.i =  Alembic::ABC_UpdatePointCloudSample(*o\ptr,*cloud_infos,*cloud_sample)
    MessageRequester("Velocities Size",Str(update)+" ---> "+Str(CArray::GetCount(*cloud_geom\a_velocities)))
    UpdateProperties(*o,frame/30)
    ApplyProperty(*o,"Scale")
    ApplyProperty(*o,"Orientation")
    ApplyProperty(*o,"Color")

;     If *geom\nbpoints <> *infos\nbpoints Or *geom\nbsamples <> *infos\nbindices Or *geom\nbpolygons <> *infos\nbfacecount
;       *o\initialized = #False
;     EndIf
;     
;     Protected update.i
;     
;     If Not *o\initialized 
;       ;we need to create the topology
;       *geom\nbpoints = *infos\nbpoints
;       *geom\nbsamples = *infos\nbsamples
;       *geom\nbindices = *infos\nbindices
;       *geom\nbpolygons = *infos\nbfacecount
;       *geom\nbtriangles = *infos\nbsamples / 3
;       ; Resize Mesh Datas
;       CArray::SetCount(*geom\a_positions,*infos\nbpoints)
;       CArray::SetCount(*geom\a_pointnormals,*infos\nbpoints)
;       CArray::SetCount(*geom\a_velocities,*infos\nbpoints)
;       CArray::SetCount(*geom\a_normals,*infos\nbsamples)
;       CArray::SetCount(*geom\a_tangents,*infos\nbsamples)
;       CArray::SetCount(*geom\a_uvws,*infos\nbsamples)
;       CArray::SetCount(*geom\a_colors,*infos\nbsamples)
;       CArray::SetCount(*geom\a_faceindices,*infos\nbindices)
;       CArray::SetCount(*geom\a_facecount,*infos\nbfacecount)
;       CArray::SetCount(*geom\a_triangleindices,*geom\nbsamples)
; 
;       
; ;       MessageRequester("Alembic Object : "+*o\name,"Has Color : "+Str(*infos\hascolor)+Chr(10)+
; ;                                  "Has UVs : "+Str(*infos\hasuvs)+Chr(10)+
; ;                                  "Has Normal : "+Str(*infos\hasnormal)+Chr(10)+
; ;                                  "Has Velocity : "+Str(*infos\hasvelocity)+Chr(10)+
; ;                                  "Nb Face Count : "+Str(*infos\nbfacecount)+Chr(10)+
; ;                                  "Nb Face Indices : "+Str(*infos\nbindices)+Chr(10)+
; ;                                  "Nb Points : "+Str(*infos\nbpoints)+Chr(10)+
; ;                                  "Nb Samples : "+Str(*infos\nbsamples)+Chr(10)+
; ;                                  "Nb Face Count : "+Str(*infos\nbfacecount)+Chr(10)+
; ;                                  "Sample Index : "+Str(*infos\sampleindex))
;      
;      
;       ; Bind to ABC_Sample
;       *mesh_sample\positions = *geom\a_positions\data
;       *mesh_sample\velocities = *geom\a_velocities\data 
;       *mesh_sample\normals = *geom\a_normals\data
;       *mesh_sample\uvs = *geom\a_uvws\data
;       *mesh_sample\colors = *geom\a_colors\data
;       *mesh_sample\faceindices = *geom\a_faceindices\data
;       *mesh_sample\facecount = *geom\a_facecount\data
; 
;       *infos\sampleindex = frame
;       update.i =  Alembic::ABC_UpdatePolymeshTopoSample(*o\ptr,*infos,*mesh_sample)
; 
;        PolymeshGeometry::RecomputeTriangle(*geom)
;        
;        
;        If Not *infos\hascolor : PolymeshGeometry::SetColors(*geom) : EndIf
;        If Not *infos\hasnormal : PolymeshGeometry::RecomputeNormals(*geom): EndIf
;        If Not *infos\hasuvs : PolymeshGeometry::GetUVWSFromPosition(*geom) : EndIf
;        If Not *infos\hastangent : PolymeshGeometry::RecomputeTangents(*geom):EndIf
;       
;        PolymeshGeometry::GetTopology(*geom)
;        
;        
;        If *infos\hasenvelope
;          Protected envelope.Alembic::ABC_Envelope_Sample
;          Protected *weights.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
;          Protected *indices.CArray::CArrayC4U8 = CArray::newCArrayC4U8()
;          CArray::SetCount(*weights,*infos\nbpoints)
;          CArray::SetCount(*indices,*infos\nbpoints)
;          envelope\weights = CArray::GetPtr(*weights,0)
;          envelope\indices = CArray::GetPtr(*indices,0)
;          ;envelope\nbdeformers
;          Alembic::ABC_GetEnvelope(*o\ptr,@envelope)
;          
;          Protected i
;          Protected *ids.c4u8
;          Protected *weight.c4f32
;          For i=0 To *infos\nbpoints-1
;            *ids = CArray::GetValue(*indices,i)
;            *weight = CArray::GetValue(*weights,i)
;            Debug "------------- Vertex "+Str(i)
;            Debug "IDs : "+Str(*ids\r)+","+Str(*ids\g)+","+Str(*ids\b)+","+Str(*ids\a)
;            Debug "Weights : "+StrF(*weight\r)+","+StrF(*weight\g)+","+StrF(*weight\b)+","+StrF(*weight\a)
;            
;            
;          Next
;          
;          PolymeshGeometry::EnvelopeColors(*geom,*weights,*indices,envelope\nbdeformers)
;        EndIf
;        
;        
;       *o\initialized = #True
;   
;     Else
;       Debug "Update Polymesh Sample"
;       *infos\sampleindex = frame
;       update.i =  Alembic::ABC_UpdatePolymeshSample(*o\ptr,*infos,*mesh_sample)
;     EndIf
;     
    *cloud\dirty = Object3D::#DIRTY_STATE_DEFORM
    
  EndProcedure
  ;}
  
  
  ;----------------------------------------
  ; Get Polymesh Sample At Frame
  ;----------------------------------------
  ;{
  Procedure GetPolymeshSampleAtFrame(*o.AlembicObject_t,frame.f)
  Debug ">>>>>>>>>>>>>>>>>>>>>>>>>> GET POLYMESH SAMPLE FRAME <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    Protected *mesh_sample.Alembic::ABC_Polymesh_Topo_Sample = *o\sample
    Protected *mesh.Polymesh::Polymesh_t = *o\obj
    Protected *geom.Geometry::PolymeshGeometry_t = *mesh\geom
    Protected *infos.Alembic::ABC_Polymesh_Topo_Sample_Infos = *o\infos

    Alembic::ABC_GetPolymeshTopoSampleDescription(*o\ptr,frame,*infos)
    
    If *infos\hasenvelope
      MessageRequester("[ALEMBIC]","Envelope Detected!!!")
    EndIf
    
    If *geom\nbpoints <> *infos\nbpoints Or *geom\nbpolygons <> *infos\nbfacecount
      Debug ">>>>>>>>>>>>>>>>>>>>>>>>>> RESET INITIALIZATION <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      *o\initialized = #False
    EndIf
    
    Protected update.i
    
    If Not *o\initialized 
      ;we need to create the topology
      *geom\nbpoints = *infos\nbpoints
      *geom\nbsamples = *infos\nbsamples
      *geom\nbindices = *infos\nbindices
      *geom\nbpolygons = *infos\nbfacecount
      *geom\nbtriangles = *infos\nbsamples / 3
      ; Resize Mesh Datas
      CArray::SetCount(*geom\a_positions,*infos\nbpoints)
      CArray::SetCount(*geom\a_pointnormals,*infos\nbpoints)
      CArray::SetCount(*geom\a_velocities,*infos\nbpoints)
      CArray::SetCount(*geom\a_normals,*infos\nbsamples)
      CArray::SetCount(*geom\a_tangents,*infos\nbsamples)
      CArray::SetCount(*geom\a_uvws,*infos\nbsamples)
      CArray::SetCount(*geom\a_colors,*infos\nbsamples)
      CArray::SetCount(*geom\a_faceindices,*infos\nbindices)
      CArray::SetCount(*geom\a_facecount,*infos\nbfacecount)
      CArray::SetCount(*geom\a_triangleindices,*geom\nbsamples)
     
     
      ; Bind to ABC_Sample
      *mesh_sample\positions = *geom\a_positions\data
      *mesh_sample\velocities = *geom\a_velocities\data 
      *mesh_sample\normals = *geom\a_normals\data
      *mesh_sample\tangents = *geom\a_tangents\data
      *mesh_sample\uvs = *geom\a_uvws\data
      *mesh_sample\colors = *geom\a_colors\data
      *mesh_sample\faceindices = *geom\a_faceindices\data
      *mesh_sample\facecount = *geom\a_facecount\data

      Alembic::ABC_UpdatePolymeshTopoSample(*o\ptr,*infos,*mesh_sample)

       PolymeshGeometry::RecomputeTriangles(*geom)
       
       
       If Not *infos\hascolor : PolymeshGeometry::SetColors(*geom) : EndIf
       If Not *infos\hasnormal : PolymeshGeometry::RecomputeNormals(*geom,1.0): EndIf
       If Not *infos\hasuvs : PolymeshGeometry::GetUVWSFromPosition(*geom) : EndIf
       If Not *infos\hastangent : PolymeshGeometry::RecomputeTangents(*geom):EndIf
      
       PolymeshGeometry::GetTopology(*geom)
       
       
       If *infos\hasenvelope
         Protected envelope.Alembic::ABC_Envelope_Sample
         Protected *weights.CArray::CArrayC4F32 = CArray::newCArrayC4F32()
         Protected *indices.CArray::CArrayC4U8 = CArray::newCArrayC4U8()
         CArray::SetCount(*weights,*infos\nbpoints)
         CArray::SetCount(*indices,*infos\nbpoints)
         envelope\weights = CArray::GetPtr(*weights,0)
         envelope\indices = CArray::GetPtr(*indices,0)
         ;envelope\nbdeformers
         Alembic::ABC_GetEnvelope(*o\ptr,@envelope)
         
         Protected i
         Protected *ids.c4u8
         Protected *weight.c4f32
         For i=0 To *infos\nbpoints-1
           *ids = CArray::GetValue(*indices,i)
           *weight = CArray::GetValue(*weights,i)
           Debug "------------- Vertex "+Str(i)
           Debug "IDs : "+Str(*ids\r)+","+Str(*ids\g)+","+Str(*ids\b)+","+Str(*ids\a)
           Debug "Weights : "+StrF(*weight\r)+","+StrF(*weight\g)+","+StrF(*weight\b)+","+StrF(*weight\a)
           
           
         Next
         
         PolymeshGeometry::EnvelopeColors(*geom,*weights,*indices,envelope\nbdeformers)
       EndIf
       
       
      *o\initialized = #True
  
    Else
      *infos\sampleindex = frame
      update.i =  Alembic::ABC_UpdatePolymeshSample(*o\ptr,*infos,*mesh_sample)
    EndIf
    
    *mesh\dirty = Object3D::#DIRTY_STATE_DEFORM
    Debug "POLYMESH SAMPE.  END"
  EndProcedure
  ;}
  
  ;---------------------------------------------------------
  ; Update Sample
  ;---------------------------------------------------------
  Procedure UpdateSample(*o.AlembicObject_t,frame.f)
    
    Select *o\type
      Case Alembic::#ABC_OBJECT_XFORM
        GetXFormSampleAtFrame(*o,frame)
        
      Case Alembic::#ABC_OBJECT_POLYMESH
        GetPolymeshSampleAtFrame(*o,frame)
        
      Case Alembic::#ABC_OBJECT_POINTCLOUD
        GetPointCloudSampleAtFrame(*o,frame)
        
        
    EndSelect
  EndProcedure
  
  ;---------------------------------------------------------
  ; Delete Sample
  ;---------------------------------------------------------
  Procedure DeleteSample(*Me.AlembicObject_t)
  
  EndProcedure
  
  ;---------------------------------------------------------
  ; Log Properties
  ;---------------------------------------------------------
  Procedure LogProperties(*Me.AlembicObject_t)
    Debug "################# LOG PROPERTIES #################################"
    Protected title.s
    Select *Me\type
      Case Alembic::#ABC_OBJECT_XFORM
        title = "[XFORM]"
      Case Alembic::#ABC_OBJECT_POLYMESH
        title = "[POLYMESH]"
      Case Alembic::#ABC_OBJECT_POINTCLOUD
        title = "[POINTCLOUD]"
      Case Alembic::#ABC_OBJECT_CURVE
        title = "[CURVES]"
    EndSelect
   EndProcedure
   
  ;---------------------------------------------------------
  ; Get Property Sample
  ;---------------------------------------------------------
  Procedure GetPropertySample(*Me.AlembicObject_t,ID.i)
     SelectElement(*Me\props(),ID)
;      Protected traits.Alembic::ABCDataTraits = Alembic::ABC_GetA
  EndProcedure
  
  ;---------------------------------------------------------
  ; Get Properties
  ;---------------------------------------------------------
  Procedure CreateAttributeFromProperty(*Me.AlembicObject_t,*infos.Alembic::ABC_Attribute_Sample_Infos)
    Protected *obj.Object3D::Object3D_t = *Me\obj
    Protected *data.CArray::CArrayT
    Protected *attribute.Attribute::Attribute_t
    Protected context.i = Attribute::#ATTR_CTXT_SINGLETON
    Protected struct.i = Attribute::#ATTR_STRUCT_SINGLE
    If *infos\type = Alembic::#ABC_PropertyType_Array
      struct = Attribute::#ATTR_STRUCT_ARRAY
    EndIf
    
    Protected name.s = PeekS(Alembic::ABC_GetAttributeSampleName(*infos),-1, #PB_Ascii)
    Select *infos\traits
      Case Alembic::#ABC_DataTraits_Bool
        *data = CArray::newCArrayBool()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_BOOL,struct,context,*data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_Int32
        *data = CArray::newCArrayLong()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_LONG,struct,context,*data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_Int64
        *data = CArray::newCArrayInt()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_INTEGER,struct,context,*data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_Float
        *data = CArray::newCArrayFloat()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_FLOAT,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_V2f
        *data = CArray::newCArrayV2F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_VECTOR2,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_V3f
        *data = CArray::newCArrayV3F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_VECTOR3,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_V4f
        *data = CArray::newCArrayC4F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_VECTOR4,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_C4f
        *data = CArray::newCArrayC4F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_COLOR,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_Quatf
        *data = CArray::newCArrayQ4F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_QUATERNION,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_M33f
        *data = CArray::newCArrayM3F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_MATRIX3,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
      Case Alembic::#ABC_DataTraits_M44f
        *data = CArray::newCArrayM4F32()
        *attribute = Attribute::New(name,Attribute::#ATTR_TYPE_MATRIX4,struct,context, *data,#False,Bool(struct=Attribute::#ATTR_STRUCT_SINGLE))
        
      Default
        MessageRequester("[Alembic]","Create Attribute From Property Failed!"+Chr(10)+name+" Traits Unsupported!!")
    EndSelect
    
    If *attribute
      Debug "Add Atribute ; "+*Me\obj\name+" >>> "+*attribute\name
      Object3D::AddAttribute(*Me\obj,*attribute)
    EndIf
    
    
    ProcedureReturn *attribute
  
   EndProcedure
   
   
  ;---------------------------------------------------------
  ; Get Properties
  ;---------------------------------------------------------
   Procedure GetProperties(*Me.AlembicObject_t)
     Protected i
     ClearList(*Me\props())

    For i=0 To Alembic::ABC_GetNumProperties(*Me\ptr)-1
     AddElement(*Me\props())
     *Me\props() = Alembic::ABC_GetProperty(*Me\ptr,i)
    Next
    
    Protected t.s
    Protected *infos.Alembic::ABC_Attribute_Sample_Infos = AllocateMemory(SizeOf(Alembic::ABC_Attribute_Sample_Infos))
    InitializeStructure(*infos,Alembic::ABC_Attribute_Sample_Infos)
    
    Protected ID = 0
    t + "Nb Properties : "+Str(ListSize(*Me\props()))+Chr(10)
    Protected *sample.Alembic::ABC_Attribute_Sample = AllocateMemory(SizeOf(Alembic::ABC_Attribute_Sample))
    
    Protected *attr.Attribute::Attribute_t
    Protected x
    
    ForEach *Me\props()   
      Alembic::ABC_GetAttributeSampleDescription(*Me\props(),0,*infos)
      Protected n.s = PeekS(Alembic::ABC_GetAttributeSampleName(*infos),-1,#PB_UTF8)
     t+n+Chr(10)+" : "+Str(*infos\nbitems)+" items "+Chr(10)
     Debug t
     *attr = CreateAttributeFromProperty(*Me,*infos)
     AddElement(*Me\attributes())
     *Me\attributes() = *attr
     
     Debug "Nb Items : "+Str(*infos\nbitems)
     CArray::SetCount(*attr\data,*infos\nbitems)
     *sample\datas = CArray::GetPtr(*attr\data,0)
     Debug "Prop : "+Str(*Me\props())
     Debug "Infos : "+Str(*infos)
     Debug "Sample : "+Str(*sample)
     Debug Alembic::ABC_GetAttributeSample
     Alembic::ABC_GetAttributeSample(*Me\props(),*infos,*sample)
    
     
;      Select *infos\traits
;        Case Alembic::#ABC_DataTraits_V3f
;          Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Property V3F32 "+n
;    
;           For x=0 To *infos\nbitems-1
;             Vector3::Echo(CArray::GetValue(*attr\data,x),n)
;           Next
;         Case Alembic::#ABC_DataTraits_Bool
;           Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Property BOOL"+n
; 
;           For x=0 To *infos\nbitems-1
;             Debug CArray::GetValueB(*attr\data,x)
;           Next
;        Case Alembic::#ABC_DataTraits_Quatf
;           Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Property QUATERNION"+n
; 
;           For x=0 To *infos\nbitems-1
;            Quaternion::Echo(CArray::GetValue(*attr\data,x),n)
;          Next
;        Case Alembic::#ABC_DataTraits_C4f
;           Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Property COLOR"+n
; 
;           For x=0 To *infos\nbitems-1
;            Color::Echo(CArray::GetValue(*attr\data,x),n)
;           Next
; ;         
;      EndSelect
;      
     ID+1
     
   Next
     
   ClearStructure(*infos,Alembic::ABC_Attribute_Sample_Infos)
   FreeMemory(*infos)
   FreeMemory(*sample)

;        MessageRequester("ALEMBIC PROPERTIES",t)
 EndProcedure
 
 Procedure UpdateProperty(*Me.AlembicObject_t,frame.f,name.s)
    Protected t.s
    Protected infos.Alembic::ABC_Attribute_Sample_Infos
    
    Protected ID = 0
    Protected io_sample.Alembic::ABC_Attribute_Sample
    
    Protected *attr.Attribute::Attribute_t
    Protected x=0
    
    Debug "Frame "+Str(frame)
    infos\time = frame
    
    ForEach *Me\props() 
      
      Alembic::ABC_GetAttributeSampleDescription(*Me\props(),frame,@infos)
      Protected n.s = PeekS(Alembic::ABC_GetAttributeSampleName(*infos),-1,#PB_UTF8)
      If n = name 
        
       SelectElement(*Me\attributes(),x)
       *attr = *Me\attributes()
       If CArray::GetCount(*attr\data)<>infos\nbitems
         CArray::SetCount(*attr\data,infos\nbitems)
       EndIf
       
       io_sample\datas = CArray::GetPtr(*attr\data,0)   
       Alembic::ABC_GetAttributeSample(*Me\props(),@infos,@io_sample)
       Break
     EndIf
     x+1
   Next
 EndProcedure
 
 
 Procedure UpdateProperties(*Me.AlembicObject_t,frame.f)
    Protected t.s
    Protected infos.Alembic::ABC_Attribute_Sample_Infos
    
    Protected ID = 0
    Protected io_sample.Alembic::ABC_Attribute_Sample
    
    Protected *attr.Attribute::Attribute_t
    Protected x=0
    
    Debug "Frame "+Str(frame)
    infos\time = frame
    
    ForEach *Me\props()   
      Alembic::ABC_GetAttributeSampleDescription(*Me\props(),frame,@infos)
      Protected n.s = PeekS(Alembic::ABC_GetAttributeSampleName(@infos),-1,#PB_UTF8)

      SelectElement(*Me\attributes(),x)
      *attr = *Me\attributes()
      If CArray::GetCount(*attr\data)<>infos\nbitems
       CArray::SetCount(*attr\data,infos\nbitems)
      EndIf
    
      io_sample\datas = CArray::GetPtr(*attr\data,0)   
      Alembic::ABC_GetAttributeSample(*Me\props(),@infos,@io_sample)

      x+1
    Next
    
  EndProcedure

   
   
  ;---------------------------------------------------------
  ; Apply Properties
  ;---------------------------------------------------------
  Procedure ApplyProperty(*Me.AlembicObject_t,name.s)
    Define x
    Define nbp
    Define *v.v3f32
    Define *array.CArray::CArrayT
    If FindMapElement(*Me\obj\m_attributes(),name)
       If *Me\type = Alembic::#ABC_OBJECT_POINTCLOUD
         Define *geom.Geometry::PointCloudGeometry_t = *Me\obj\geom
         If *geom
           Select name
             Case "Scale"
               nbp = CArray::GetCount(*Me\obj\m_attributes()\data)
               CArray::SetCount(*geom\a_scale,nbp)
               CopyMemory(CArray::GetPtr(*Me\obj\m_attributes()\data,0),CArray::GetPtr(*geom\a_scale,0),CArray::GetCount(*geom\a_scale)*CArray::GetItemSize(*geom\a_scale))

               
             Case "Orientation"
               Debug "################# APPLY ORIENTATION ##############################"
               nbp = CArray::GetCount(*Me\obj\m_attributes()\data)
               Define *tan.v3f32
               Define *nrm.v3f32
               Define *q.q4f32

               CArray::SetCount(*geom\a_normals,nbp)
               CArray::SetCount(*geom\a_tangents,nbp)
               *array = *Me\obj\m_attributes()\data
               For x=0 To nbp-1
                 *nrm = CArray::GetValue(*geom\a_normals,x)
                 *tan = CArray::GetValue(*geom\a_tangents,x)
                 *q = CArray::GetValue(*array,x)
                 
                 Vector3::Set(*nrm,0,1,0)
                 Vector3::MulByQuaternionInPlace(*nrm,*q)
                 Vector3::Set(*tan,1,0,0)
                 Vector3::MulByQuaternionInPlace(*tan,*q)
               Next
             Case "Color"
               nbp = CArray::GetCount(*Me\obj\m_attributes()\data)
               *array = *Me\obj\m_attributes()\data
               Define *c.c4f32
               Define c.c4f32
               CArray::SetCount(*geom\a_color,nbp)
               For x=0 To nbp-1
                 CopyMemory(CArray::GetValue(*array,x), CArray::GetValue(*geom\a_color,x), SizeOf(c))
               Next
              
           EndSelect
         EndIf
       EndIf

     EndIf
  
     
       
;     Protected n.s = PeekS(@*infos\name)
;     
;      
;        
;       
;        
;      EndIf  
   EndProcedure
   
  ;---------------------------------------------------------
  ; Apply Property2
  ;---------------------------------------------------------
  Procedure ApplyProperty2(*Me.AlembicObject_t,name.s,*arr.CArray::CArrayT)
    Define x
    Define nbp
    Define *v.v3f32
    Define *array.CArray::CarrayT
    ForEach *Me\attributes()
      If *Me\attributes()\name = name
        *array = *Me\attributes()\data
    ;If FindMapElement(*Me\attributes(),name)
      
       nbp = CArray::GetCount(*arr)
;        CArray::SetCount(*Me\obj\m_attributes()\data,nbp)
;        CopyMemory(CArray::GetPtr(*Me\obj\m_attributes()\data,0),CArray::GetPtr(*arr,0),nbp*CArray::GetItemSize(*arr))
        CArray::Copy(*arr,*array)
        Break
;        Else
;          MessageRequester("[Alembic]","Property "+name+" does NOT exists!!!")
       EndIf
     Next
     

;     If FindMapElement(*Me\obj\m_attributes(),name)
;       
;        nbp = CArray::GetCount(*arr)
;        CArray::SetCount(*Me\obj\m_attributes()\data,nbp)
;        CopyMemory(CArray::GetPtr(*Me\obj\m_attributes()\data,0),CArray::GetPtr(*arr,0),nbp*CArray::GetItemSize(*arr))
; 
;                
;      Else
;        MessageRequester("[Alembic]","Property "+name+" does NOT exists!!!")
;      EndIf
   
   EndProcedure
  
  ;---------------------------------------------------------
  ; Init
  ;---------------------------------------------------------
  Procedure Init(*o.AlembicObject_t,*p.AlembicObject_t=#Null)
    
    *o\name = PeekS(Alembic::ABC_GetObjectName(*o\ptr),-1,#PB_Ascii)
    *o\parent = *p
    
    If *o\type = Alembic::#ABC_OBJECT_XFORM
;      Protected *s = Alembic::ABC_InitObject(*o\ptr,Alembic::#ABC_OBJECT_XFORM)
      Debug "########### INIT XFORM"
      CreateSample(*o)
      *o\obj = #Null
      *o\initialized = #False
      ;LogProperties(*o)
      UpdateSample(*o,1)
      
    ElseIf *o\type = Alembic::#ABC_OBJECT_POLYMESH
      ; *s = Alembic::ABC_InitObject(*o\ptr,Alembic::#ABC_OBJECT_POLYMESH)
      Debug "########### INIT POLYMESH"
      CreateSample(*o)
      ;LogProperties(*o)
      Protected *meshinfos.Alembic::ABC_Polymesh_Topo_Sample_Infos = *o\infos
      Protected *mesh.Polymesh::Polymesh_t = Polymesh::New(*o\name,Shape::#SHAPE_NONE)
;       Protected *node.AlembicNode::AlembicNode_t = AlembicNode::New(*mesh,*o)
;       Stack::AddNode(*mesh\stack,*node)
;       GetProperties(*o)
      *o\obj = *mesh
      *o\initialized = #False
      
      UpdateSample(*o,1)

      Object3D::Freeze(*mesh)
      
  
      ;init transform
;       If *o\parent<>#Null
;         If *o\parent\type = Alembic::#ABC_OBJECT_XFORM
;           Protected *sample.Alembic::ABC_XForm_Sample = *o\parent\sample
;           Protected *t.Transform::Transform_t = *mesh\model
;           Vector3::Set(*t\t\pos,*sample\pos[0],*sample\pos[1],*sample\pos[2])
;           Vector3::Set(*t\t\scl,*sample\scl[0],*sample\scl[1],*sample\scl[2])
;           Quaternion::SetFromAxisAngleValues(*t\t\rot,*sample\ori[0],*sample\ori[1],*sample\ori[2],*sample\ori[3] * #F32_DEG2RAD)
;           Transform::UpdateMatrixFromSRT(*t\t)
;           Matrix4::SetFromOther(*o\obj\model,*t\m)
; ;           Protected *tp.CTransform = newCTransform()
; ;           *o\obj\UpdateTransform(*tp)
;         EndIf
;       EndIf
;       
;       
;       
   ElseIf *o\type = Alembic::#ABC_OBJECT_POINTCLOUD
;      Alembic::ABC_InitObject(*o\ptr,Alembic::#ABC_OBJECT_POINTCLOUD)
    
     CreateSample(*o)
     
     Protected *cloudinfos.Alembic::ABC_PointCloud_Sample_Infos = *o\infos
     Protected *cloud.InstanceCloud::InstanceCloud_t = InstanceCloud::New(*o\name,Shape::#SHAPE_CUBE,*cloudinfos\nbpoints)
;       *node.AlembicNode::AlembicNode_t = AlembicNode::New(*cloud,*o)
;       Stack::AddNode(*cloud\stack,*node)
      *o\obj = *cloud
      *o\initialized = #False
      Protected *cloud_geom.Geometry::PointCloudGeometry_t = *cloud\geom
      ;LogProperties(*o)
      GetProperties(*o)

;       *cloud_geom\PointOnSphere()
      UpdateSample(*o,1)
      
    EndIf  
  EndProcedure
  
  
  ;------------------------------------------------------------------
  ; Destuctor
  ;------------------------------------------------------------------
  Procedure Delete(*o.AlembicObject_t)
    ;glDelete
    If *o\obj<>#Null
      Protected *obj.Object3D::Object3D_t = *o\obj
      ;*obj\abc_obj = #Null
    EndIf
    ClearStructure(*o,AlembicObject_t)
    FreeMemory(*o)
  EndProcedure
  
  
  ;---------------------------------------------
  ;  Constructor
  ;---------------------------------------------
  ;{
  Procedure.i New(*archive,id.i)
    ; ---[ Allocate Memory ]----------------------------------------------------
    Protected *Me.AlembicObject_t = AllocateMemory(SizeOf(AlembicObject_t))
    InitializeStructure(*Me,AlembicObject_t)
    
    *Me\obj = #Null
    *Me\ptr = Alembic::ABC_GetObjectFromArchiveByID(*archive,id)
    If *Me\ptr
      *Me\name = PeekS(Alembic::ABC_GetObjectName(*Me\ptr),-1,#PB_UTF8)
      If Alembic::ABC_ObjectIsXForm(*Me\ptr) 
        *Me\type = Alembic::#ABC_OBJECT_XFORM
        *Me\sample = #Null
        
      ElseIf Alembic::ABC_ObjectIsPolymesh(*Me\ptr)
        *Me\type = Alembic::#ABC_OBJECT_POLYMESH
        *Me\sample = #Null
        
  ;     ElseIf Alembic::ABC_ObjectIsSubD(*Me\ptr)
  ;       Debug "[Alembic] : Object is a SUBD..."
  ;       *Me\type = Alembic::#ABC_OBJECT_SUBD
  ;       *Me\sample = #Null
        
      ElseIf Alembic::ABC_ObjectIsPointCloud(*Me\ptr)
        *Me\type = Alembic::#ABC_OBJECT_POINTCLOUD
        *Me\sample = #Null
        
      Else
        *Me\type = Alembic::#ABC_OBJECT_UNKNOWN
        *Me\sample = #Null
      EndIf
    EndIf
    
    ProcedureReturn *Me
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 322
; FirstLine = 299
; Folding = ----------
; EnableXP
; Executable = bin\Alembic.app
; Debugger = Standalone