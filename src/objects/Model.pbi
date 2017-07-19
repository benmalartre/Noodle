XIncludeFile "Object3D.pbi"


DeclareModule Model
  UseModule Math
  Structure Model_t Extends Object3D::Object3D_t 
  EndStructure
  
  Interface IModel Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s)
  Declare Delete(*model.Model_t)
  Declare Setup(*model.Model_t,*pgm)
  Declare Update(*model.Model_t)
  Declare Clean(*model.Model_t)
  Declare Draw(*model.Model_t,*shader.Program::Program_t)
  
  DataSection 
    ModelVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Clean()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
  
EndDeclareModule

Module Model
  UseModule OpenGL
  UseModule OpenGLExt
  
  Procedure New(name.s)
    Protected *Me.Model_t = AllocateMemory(SizeOf(Model_t))
    ; ---[ Initialize Structure ]------------------------------------------------
    InitializeStructure(*Me,Model_t)

    Object::INI(Model)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\name = name
    *Me\type = Object3D::#Object3D_Model
    Matrix4::SetIdentity(*Me\matrix)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    
    Object3D::Object3D_ATTR()
   
    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Model_t)
    ClearStructure(*Me, Model_t)
    FreeMemory(*Me)
  EndProcedure
  
  Procedure Setup(*model.Model_t,*pgm)
    If Not *model
      MessageRequester("[MODEL]","INVALID MODEL")
      ProcedureReturn 
    EndIf
      
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    Protected *geom.Geometry::Geometry_t
    
    ForEach *model\children()
      *child = *model\children()
      child = *child
      *geom = *child\geom
;       If *child\type = Object3D::#Object3D_PointCloud Or 
;       Debug "[Model] Setup "+*child\name+" ---> "+Str(*geom\nbpoints)
      child\Setup(*pgm)
      Debug "[model] Done!!"
    Next
    
  EndProcedure
  
  Procedure Update(*model.Model_t)
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    Protected *geom.Geometry::Geometry_t
    ForEach *model\children()
      *child = *model\children()
      child = *child
      *geom = *child\geom
;       Debug "[Model] Update "+*child\name+" ---> "+Str(*geom\nbpoints)
      child\Update()
      Debug "[model] Done!!"
    Next
    
  EndProcedure
  
  Procedure Draw(*model.Model_t,*shader.Program::Program_t)
    Debug "MODEL DRAW CALLED!!!"
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    ForEach *model\children()
      
      *child = *model\children()
      glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,*child\matrix)
      child = *child
      child\Draw()
      Debug "--------------------------> DRAW :: "+ *child\name
    Next
  EndProcedure
  
  Procedure Clean(*model.Model_t)
   
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( Model )
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; CursorPosition = 51
; FirstLine = 36
; Folding = --
; EnableXP