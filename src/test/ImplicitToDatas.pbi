XIncludeFile "../core/Math.pbi"
XIncludeFile "../core/Utils.pbi"
UseModule Math

; #CYLINDER_NUM_VERTICES =26
;   DataSection
;   	implicit_cylinder_positions:
;   	Data.GLfloat 0.0,-0.5,0.0
;   	Data.GLfloat 0.0,0.5,0.0
;   	Data.GLfloat -0.5,-0.5,-6.12323399574e-17
;   	Data.GLfloat -0.5,0.5,-6.12323399574e-17
;   	Data.GLfloat -0.433012701892,-0.5,0.25
;   	Data.GLfloat -0.433012701892,0.5,0.25
;   	Data.GLfloat -0.25,-0.5,0.433012701892
;   	Data.GLfloat -0.25,0.5,0.433012701892
;   	Data.GLfloat -1.94289029309e-16,-0.5,0.5
;   	Data.GLfloat -1.94289029309e-16,0.5,0.5
;   	Data.GLfloat 0.25,-0.5,0.433012701892
;   	Data.GLfloat 0.25,0.5,0.433012701892
;   	Data.GLfloat 0.433012701892,-0.5,0.25
;   	Data.GLfloat 0.433012701892,0.5,0.25
;   	Data.GLfloat 0.5,-0.5,3.60822483003e-16
;   	Data.GLfloat 0.5,0.5,3.60822483003e-16
;   	Data.GLfloat 0.433012701892,-0.5,-0.25
;   	Data.GLfloat 0.433012701892,0.5,-0.25
;   	Data.GLfloat 0.25,-0.5,-0.433012701892
;   	Data.GLfloat 0.25,0.5,-0.433012701892
;   	Data.GLfloat 4.71844785466e-16,-0.5,-0.5
;   	Data.GLfloat 4.71844785466e-16,0.5,-0.5
;   	Data.GLfloat -0.25,-0.5,-0.433012701892
;   	Data.GLfloat -0.25,0.5,-0.433012701892
;   	Data.GLfloat -0.433012701892,-0.5,-0.25
;   	Data.GLfloat -0.433012701892,0.5,-0.25
;   
;   EndDataSection


Macro AddLineOne(line)
  datas + Chr(9) + line + Chr(10)
EndMacro

Macro AddLineTwo(line)
  datas + Chr(9) + Chr(9) + line + Chr(10)
EndMacro


Procedure Sphere()
  Protected i
  Protected *p.v3f32
  Protected m.m4f32
  Matrix4::SetIdentity(@m)
  Protected *pnts.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
  Protected datas.s
  AddLineOne(";-----------------------------------------------------------------------------")
  AddLineOne("; sphere")
  AddLineOne(";-----------------------------------------------------------------------------")
  AddLineOne("#SPHERE_NUM_VERTICES = 48")
  AddLineOne("DataSection")
  AddLineTwo("implicit_sphere_positions:")
  
  Protected target.v3f32
  Protected upv.v3f32
  Vector3::Set(@target,0,1,0)
  Vector3::Set(@upv,1,0,0)
  Matrix4::DirectionMatrix(@m, @target, @upv)
  Utils::BuildCircleSection(*pnts, 16, 0.5, 0.0, 360.0)
  Utils::TransformPositionArrayInPlace(*pnts,@m)
  For i=0 To 15
    *p = CArray::GetValue(*pnts, i)
    AddLineTwo("Data.f " + StrF(*p\x,5) + "," + StrF(*p\y) + "," + StrF(*p\z))
  Next
  
  Vector3::Set(@target,0,0,1)
  Vector3::Set(@upv,0,1,0)
  Matrix4::DirectionMatrix(@m, @target, @upv)
  Utils::BuildCircleSection(*pnts, 16, 0.5, 0.0, 360.0)
  Utils::TransformPositionArrayInPlace(*pnts,@m)
  For i=0 To 15
    *p = CArray::GetValue(*pnts, i)
    AddLineTwo("Data.f " + StrF(*p\x,5) + "," + StrF(*p\y) + "," + StrF(*p\z))
  Next
  
  Vector3::Set(@target,1,0,0)
  Vector3::Set(@upv,0,1,0)
  Matrix4::DirectionMatrix(@m, @target, @upv)
  Utils::BuildCircleSection(*pnts, 16, 0.5, 0.0, 360.0)
  Utils::TransformPositionArrayInPlace(*pnts,@m)
  For i=0 To 15
    *p = CArray::GetValue(*pnts, i)
    AddLineTwo("Data.f " + StrF(*p\x,5) + "," + StrF(*p\y) + "," + StrF(*p\z))
  Next
  
  AddLineOne("EndDataSection")
  Debug datas
  
EndProcedure

Sphere()


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 72
; FirstLine = 38
; Folding = -
; EnableXP