
ImportC "E:\Projects\RnD\Noodle\libs\x64\windows\BulletCollision.lib" :EndImport
ImportC "E:\Projects\RnD\Noodle\libs\x64\windows\BulletDynamics.lib" :EndImport
ImportC "E:\Projects\RnD\Noodle\libs\x64\windows\BulletSoftBody.lib"  : EndImport
ImportC "E:\Projects\RnD\Noodle\libs\x64\windows\LinearMath.lib" : EndImport
ImportC "E:\Projects\RnD\test\staticlib2017\VS2017\x64\Release\VS2017.lib"
  this_is_a_test()
EndImport

MessageRequester("hello",Str(this_is_a_test()))
;  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 9
; EnableXP