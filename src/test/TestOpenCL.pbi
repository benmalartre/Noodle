; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; Project name : OpenCL Examples
; File Name : OpenCL Examples - 00.pb
; File version: 1.0.0
; Programming : OK
; Programmed by : Guimauve
; Date : 14-10-2012
; Last Update : 15-10-2012
; PureBasic code : 5.00 B5
; Platform : Windows, Linux, MacOS X
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

XIncludeFile "../libs/OpenCL.pbi"

UseModule OpenCL

#DATA_SIZE = 128
#INPUT_SIZE = #DATA_SIZE * SizeOf(Float)
UseGPU = #True

Dim InputValues.f(#DATA_SIZE - 1)
Dim Result.f(#DATA_SIZE - 1)

For Index = 0 To #DATA_SIZE - 1
  InputValues(Index) = Random(10) + 1
Next

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Get the PlaformID <<<<<

clGetPlatformIDs(1, @PlatformID, #Null)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Connect to a Compute Device <<<<<

If UseGPU = #True
  err = clGetDeviceIDs(PlatformID, #CL_DEVICE_TYPE_GPU, 1, @ComputeDeviceID, #Null)
Else
  err = clGetDeviceIDs(PlatformID, #CL_DEVICE_TYPE_CPU, 1, @ComputeDeviceID, #Null)
EndIf

Debug "PLTAFORM ID : "+Str(PlatformID)
Debug "COMPUTE DEVICE ID "+Str(ComputeDeviceID)
If err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to create a device group ! " + clErrorMessage(err))
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Create a compute context <<<<<

ComputeContextID = clCreateContext(#Null, 1, @ComputeDeviceID, #Null, #Null, @err)

If ComputeContextID = #Null
  MessageRequester("Fatal Error", "Failed to create a compute context ! ")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Create a command commands <<<<<

Commands = clCreateCommandQueue(ComputeContextID, ComputeDeviceID, #Null, @err)

If Commands = #Null
  MessageRequester("Fatal Error", "Failed to create a command commands!")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Load the KernelSource buffer <<<<<

If ReadFile(0, "square.cl")
  Define program.s
  While Not Eof(0)
    program + ReadString(0)+Chr(10)
  Wend
  
  Define kernel = Ascii(program)
  Define kernelLen.q = Len(program)
 
  CloseFile(0)
Else
  MessageRequester("Fatal Error", "Failed read square.cl !")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Create the compute program from the KernelSource buffer <<<<<

Debug kernel
Debug PeekS(kernel, -1, #PB_Ascii)

ProgramID = clCreateProgramWithSource(ComputeContextID, 1, @kernel, @kernelLen, @err);
FreeMemory(kernel)
If ProgramID = #Null
  MessageRequester("Fatal Error", "Failed to create compute program!")
  End
EndIf


; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Build the program executable <<<<<

err = clBuildProgram(ProgramID, 1, @ComputeDeviceID, "", #Null, #Null)

If err <> #CL_SUCCESS
  buffer = AllocateMemory(2048)
  Define len.l
  MessageRequester("Fatal Error", "Failed to build program executable!")
  clGetProgramBuildInfo(ProgramID, ComputeDeviceID, #CL_PROGRAM_BUILD_LOG, MemorySize(buffer), buffer, @len)
  MessageRequester("Build Log", PeekS(buffer, -1,#PB_Ascii))
  End
 
Else
  buffer = AllocateMemory(2048)
  
  ;clGetProgramBuildInfo(ProgramID, ComputeDeviceID, #CL_PROGRAM_BUILD_LOG, MemorySize(buffer), buffer, @len)

  ;If CreateFile(0, "Build Log")
  ;  WriteString(0, PeekS(BuildLogBuffer, #PB_Ascii))
  ;  CloseFile(0)
  ;EndIf
 
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Create the compute kernel in the program we wish To run <<<<<

KernelID = clCreateKernel(ProgramID, "square2", @err) 

If KernelID = #Null Or err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to create compute kernel!")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Create the input And output arrays in device memory For our calculation <<<<<

InputBuffer  = clCreateBuffer(ComputeContextID, #CL_MEM_READ_ONLY , #INPUT_SIZE, #Null, #Null)
OutputBuffer = clCreateBuffer(ComputeContextID, #CL_MEM_WRITE_ONLY, #INPUT_SIZE, #Null, #Null)

If InputBuffer = #Null Or OutputBuffer = #Null
  MessageRequester("Fatal Error", "Failed to allocate device memory!")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Write our Data set into the input Array in device memory <<<<<

err = clEnqueueWriteBuffer(Commands, InputBuffer, #CL_TRUE, 0, #INPUT_SIZE, @InputValues(), 0, #Null, #Null)

If err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to write to source array!")
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Set the arguments To our compute kernel <<<<<

err = clSetKernelArg(KernelID, 0, SizeOf(Integer), @InputBuffer);
err = err | clSetKernelArg(KernelID, 1, SizeOf(Integer), @OutputBuffer);

Count = #DATA_SIZE
err = err | clSetKernelArg(KernelID, 2, SizeOf(Long), @Count);

If err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to set kernel arguments ! " + clErrorMessage(err))
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Get the maximum work group size For executing the kernel on the device <<<<<

Local.i = 0

err = clGetKernelWorkGroupInfo(KernelID, ComputeDeviceID, #CL_KERNEL_WORK_GROUP_SIZE, SizeOf(Local), @Local, #Null);

If err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to retrieve kernel work group info ! " + clErrorMessage(err))
  End
EndIf

Debug "Nb cores: " + Local

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Execute the kernel over the entire range of our 1d input Data set <<<<<
; <<<<< using the maximum number of work group items For this device      <<<<<

GlobalCount = Local * ((#INPUT_SIZE + Local - 1) / Local)

err = clEnqueueNDRangeKernel(Commands, KernelID, 1, #Null, @GlobalCount, @Local, 0, #Null, #Null);

If err
  MessageRequester("Fatal Error", "Failed to execute kernel ! " + clErrorMessage(err))
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Wait For the command commands To get serviced before reading back results <<<<<

clFinish(Commands)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Read back the results from the device To verify the output <<<<<

err = clEnqueueReadBuffer(Commands, OutputBuffer, #CL_TRUE, 0, SizeOf(Float) * #DATA_SIZE, @Result(), 0, #Null, #Null); 

If err <> #CL_SUCCESS
  MessageRequester("Fatal Error", "Failed to read output array! " + Str(err))
  End
EndIf

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Validate our results <<<<<

Correct = 0

For Index = 0 To #DATA_SIZE - 1
 
  If Result(Index) = InputValues(Index) * InputValues(Index)
    Correct + 1
  EndIf
 
  Debug StrF(Result(Index), 3) + " --> " + StrF(InputValues(Index) * InputValues(Index), 3)
 
Next

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Print a brief summary detailing the results <<<<<
 
MessageRequester("Summary", "Computed " + Str(Correct) + "/" + Str(#DATA_SIZE) + " correct values!")

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; <<<<< Shutdown And cleanup <<<<<

clReleaseMemObject(InputBuffer)
clReleaseMemObject(OutputBuffer)
clReleaseProgram(ProgramID)
clReleaseKernel(KernelID)
clReleaseCommandQueue(Commands)
clReleaseContext(ComputeContextID)

; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 103
; FirstLine = 94
; EnableXP