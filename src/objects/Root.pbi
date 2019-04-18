; ============================================================================
; Root Declare Module
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "Object3D.pbi"

DeclareModule Root
  UseModule Math
  UseModule OpenGL
  ; ----------------------------------------------------------------------------
  ;  Root Instance
  ; ----------------------------------------------------------------------------
  
  Structure Root_t Extends Object3D::Object3D_t 
  EndStructure
  
  Interface IRoot Extends Object3D::IObject3D
  EndInterface
  
  Declare New(name.s="Root")
  Declare Delete(*Me.Root_t)
  Declare Setup(*Me.Root_t,*pgm.Program::Program_t)
  Declare Update(*Me.Root_t)
  Declare Draw(*Me.Root_t)
  Declare DrawChildren(*obj.Object3D::Object3D_t,mode.GLenum=#GL_POINTS)
  
  DataSection 
    RootVT: 
    Data.i @Delete()
    Data.i @Setup()
    Data.i @Update()
    Data.i @Draw()
  EndDataSection 
  
  Global CLASS.Class::Class_t
EndDeclareModule

; ============================================================================
;  IMPLEMENTATION ( Root )
; ============================================================================
Module Root
  UseModule Math
  
  ; ============================================================================
  ;  CONSTRUCTORS
  ; ============================================================================
  ; ---[ Stack ]----------------------------------------------------------------
  Procedure.i New(name.s="Root")
    
    ; ---[ Allocate Object Memory ]---------------------------------------------
    Protected *Me.Root_t = AllocateMemory( SizeOf(Root_t) )
    InitializeStructure(*Me,Root_t)
    
    Object::INI(Root)
    
    ; ---[ Init CObject Base Class ]--------------------------------------------
    *Me\name = name
    *Me\type = Object3D::#Root
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\type = Object3D::#Root
    Matrix4::SetIdentity(*Me\matrix)
    
    Object3D::ResetLocalKinematicState(*Me)
    Object3D::ResetGlobalKinematicState(*Me)
    Object3D::ResetStaticKinematicState(*Me)
    
    
    ; ---[ Return Initialized Object ]------------------------------------------
    ProcedureReturn( *Me )
    
  EndProcedure
  
  ; ============================================================================
  ;  DESTRUCTOR
  ; ============================================================================
  ;{
  Procedure Delete( *Me.Root_t )
    Protected child.Object3D::IObject3D
    ; ---[ Delete Childrens ]---------------------------------------------------
    ForEach *Me\children()
      child = *Me\children()
      child\Delete()
    Next
  
    ; ---[ Deallocate Memory ]--------------------------------------------------
    Object::TERM(Root)
  
  EndProcedure

  Procedure Setup( *Me.Root_t ,*pgm.Program::Program_t)
    *Me\shader = *pgm
    Matrix4::Echo(*Me\globalT\m,"Root Matrix Global")
    Matrix4::Echo(*Me\matrix,"Root Matrix")
  EndProcedure

  Procedure Clean( *Me.Root_t )
  EndProcedure

  Procedure DrawChildren(*obj.Object3D::Object3D_t,mode.GLenum=#GL_POINTS)
    Protected  i
    Protected *child.Object3D::Object3D_t
  
    ForEach *obj\children()
      *child = *obj\children()
      ;*child\Draw(contextID,mode)
      DrawChildren(*child)
    Next
    
  EndProcedure
  
  Procedure Draw( *Me.Root_t)
    Protected i
    Protected *child.Object3D::Object3D_t
    ForEach *Me\children()
      *child = *Me\children()
      DrawChildren(*child)
    Next
    
    
  EndProcedure
  
  Procedure Pick( *Me.Root_t )
   
  EndProcedure
  
  Procedure Update( *Me.Root_t )
   
  EndProcedure

  ; ---[ Reflection ]-----------------------------------------------------------
  Class::DEF( Root )  
EndModule



; ============================================================================
;  EOF
; ============================================================================
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 81
; FirstLine = 69
; Folding = --
; EnableThread
; EnableXP
; EnableUnicode