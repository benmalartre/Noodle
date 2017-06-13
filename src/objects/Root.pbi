; ============================================================================
; Root Declare Module
; ============================================================================
XIncludeFile "../core/Math.pbi"
XIncludeFile "../libs/OpenGL.pbi"
XIncludeFile "Object3D.pbi"
XIncludeFile "../graph/Tree.pbi"

DeclareModule Root
  UseModule Math
  UseModule OpenGL
  ; ----------------------------------------------------------------------------
  ;  CCamera Instance
  ; ----------------------------------------------------------------------------
  
  Structure Root_t Extends Object3D::Object3D_t 
    *tree.Tree::Tree_t ; Hierarchy graph tree
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
;  IMPLEMENTATION ( CRoot )
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
    
;     *Me\VT = ?RootVT
;     *Me\classname = "ROOT"
    Object::INI(Root)
    
    ; ---[ Init CObject Base Class ]--------------------------------------------
    *Me\name = name
    *Me\type = Object3D::#Object3D_Root
    *Me\tree = #Null
    *Me\visible = #True
    *Me\stack = Stack::New()
    *Me\type = Object3D::#Object3D_Root
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
  ; ---[ _Free ]----------------------------------------------------------------
  Procedure Delete( *Me.Root_t )
    MessageRequester("Root","Delete Called")
    Protected Me.Object3D::IObject3D
    ; ---[ Delete Childrens ]---------------------------------------------------
    ForEach *Me\children()
      Debug *Me\children()\name
      Debug *Me\children()\class\name
      Me = *Me\children()
      Me\Delete()
    Next
  
    ; ---[ Deallocate Memory ]--------------------------------------------------
    ClearStructure(*Me,Root_t)
    FreeMemory( *Me )
  
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
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 85
; FirstLine = 36
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP