XIncludeFile "Object3D.pbi"
XIncludeFile "ModelGeometry.pbi"

DeclareModule Model
  UseModule Math
  Structure Model_t Extends Object3D::Object3D_t 
  EndStructure
  
  Interface IModel Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s)
  Declare Delete(*model.Model_t)
  Declare Setup(*model.Model_t, *ctxt.GLContext::GLContext_t)
  Declare Update(*model.Model_t, *ctxt.GLContext::GLContext_t)
  Declare Clean(*model.Model_t)
  Declare Draw(*model.Model_t)
  
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
    Protected *Me.Model_t = AllocateStructure(Model_t)
    Object::INI(Model)
    
    ; ---[ Init Members ]-------------------------------------------------------
    *Me\name = name
    *Me\geom = ModelGeometry::New(*Me)
    *Me\type = Object3D::#Model
    Matrix4::SetIdentity(*Me\matrix)
    
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    

    ProcedureReturn *Me
  EndProcedure
  
  Procedure Delete(*Me.Model_t)
    Object::TERM(Model)
  EndProcedure
  
  Procedure Setup(*model.Model_t, *ctxt.GLContext::GLContext_t)
    If Not *model : ProcedureReturn : EndIf
      
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    Protected *geom.Geometry::Geometry_t
    
    ForEach *model\children()
      *child = *model\children()
      child = *child
      *geom = *child\geom
      child\Setup(*ctxt)
    Next
    
  EndProcedure
  
  Procedure Update(*model.Model_t, *ctxt.GLContext::GLContext_t)
    Protected i
    Protected *child.Object3D::Object3D_t
    Protected child.Object3D::IObject3D
    Protected *geom.Geometry::Geometry_t
    ForEach *model\children()
      *child = *model\children()
      child = *child
      *geom = *child\geom
      child\Update(*ctxt)
    Next
    
  EndProcedure
  
  Procedure Draw(*model.Model_t)
;     Protected i
;     Protected *child.Object3D::Object3D_t
;     Protected child.Object3D::IObject3D
;     ForEach *model\children()
;       
;       *child = *model\children()
;       glUniformMatrix4fv(glGetUniformLocation(*shader\pgm,"model"),1,#GL_FALSE,*child\matrix)
;       child = *child
;       child\Draw()
;     Next
  EndProcedure
  
  Procedure Clean(*model.Model_t)
   
  EndProcedure
  
  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( Model )
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 54
; FirstLine = 12
; Folding = --
; EnableXP