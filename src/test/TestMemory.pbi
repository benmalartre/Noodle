XIncludeFile "../core/Memory.pbi"
XIncludeFile "../core/Array.pbi"
#ALIGN_BYTES = 64
Define oldsize.i = 64
Define *mem = Memory::AllocateAlignedMemory(oldsize, #ALIGN_BYTES)
Define msg.s
For i=0 To 128:
  
  Define size = (Random(128)+1) * #ALIGN_BYTES + oldsize
  Define *oldmem = *mem - PeekC(*mem + oldsize + 1)
  msg + Str(oldsize)+", "+Str(size)+", "+Str(PeekC(*mem + oldsize + 1))+", "+Str(*mem)+", "+Str(*oldmem)+Chr(10)
  *mem = Memory::ReAllocateAlignedMemory(*oldmem, size, #ALIGN_BYTES)
  
  oldsize = size
Next

MessageRequester("TEST MEMORY", msg)

; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 1
; EnableXP