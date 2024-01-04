XIncludeFile "../core/Math.pbi"

;======================================================================
; POSE MODULE DECLARATION
;======================================================================
DeclareModule Pose
  UseModule Math
    Structure Pose_t
    frame.i
    List Ts.Transform::Transform_t()
  EndStructure
  
  Declare New(*Ts.CArray::CArrayTRF32)
  Declare Delete(*pose.Pose_t)
  
EndDeclareModule

;======================================================================
; POSE MODULE IMPLEMENTATION
;======================================================================
Module Pose
  UseModule Math
  ;--------------------------------------------
  ; Constructor
  ;--------------------------------------------
  Procedure New(*Ts.CArray::CArrayTRF32)
    Protected i
    Protected *Me.Pose_t = AllocateStructure(Pose_t)
 
    Protected *t.trf32
    For i=0 To CArray::GetCount(*Ts)-1
      *t = CArray::GetValue(*Ts,i)
      AddElement(*Me\Ts())
      Transform::Init(*Me\Ts())
      Vector3::SetFromOther(*Me\Ts()\t\scl,*t\scl)
      Quaternion::SetFromOther(*Me\Ts()\t\rot,*t\rot)
      Vector3::SetFromOther(*Me\Ts()\t\pos,*t\pos)
      Transform::UpdateMatrixFromSRT(*Me\Ts())
     
    Next
    ProcedureReturn *Me  
  EndProcedure
  
  ;--------------------------------------------
  ; Destructor
  ;--------------------------------------------
  Procedure Delete(*pose.Pose_t)
    FreeStructure(*pose)
  EndProcedure
EndModule
; IDE Options = PureBasic 6.00 Beta 7 - C Backend (MacOS X - arm64)
; CursorPosition = 47
; FirstLine = 5
; Folding = -
; EnableXP
; EnableUnicode