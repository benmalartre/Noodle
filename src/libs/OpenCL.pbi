; ===============================================================================
;  * Copyright (c) 2011 The Khronos Group Inc.
;  *
;  * Permission is hereby granted, free of charge, To any person obtaining a
;  * copy of this software And/Or associated documentation files (the
;  * "Materials"), To deal in the Materials without restriction, including
;  * without limitation the rights To use, copy, modify, merge, publish,
;  * distribute, sublicense, And/Or sell copies of the Materials, And To
;  * permit persons To whom the Materials are furnished To do so, subject To
;  * the following conditions:
;  *
;  * The above copyright notice And this permission notice shall be included
;  * in all copies Or substantial portions of the Materials.
;  *
;  * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;  * EXPRESS OR IMPLIED, INCLUDING BUT Not LIMITED TO THE WARRANTIES OF
;  * MERCHANTABILITY, FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT.
;  * IN NO EVENT SHALL THE AUTHORS Or COPYRIGHT HOLDERS BE LIABLE FOR ANY
;  * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;  * TORT OR OTHERWISE, ARISING FROM, OUT OF Or IN CONNECTION With THE
;  * MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
;
; ===============================================================================


; ===============================================================================
; OpenCL Module Declaration
; ===============================================================================
DeclareModule OpenCL
  ; -----------------------------------------------------------------------------
  ; Error Codes
  ; -----------------------------------------------------------------------------
  #CL_SUCCESS = 0
  #CL_DEVICE_NOT_FOUND = -1
  #CL_DEVICE_NOT_AVAILABLE = -2
  #CL_COMPILER_NOT_AVAILABLE = -3
  #CL_MEM_OBJECT_ALLOCATION_FAILURE = -4
  #CL_OUT_OF_RESOURCES = -5
  #CL_OUT_OF_HOST_MEMORY = -6
  #CL_PROFILING_INFO_NOT_AVAILABLE = -7
  #CL_MEM_COPY_OVERLAP = -8
  #CL_IMAGE_FORMAT_MISMATCH = -9
  #CL_IMAGE_FORMAT_NOT_SUPPORTED = -10
  #CL_BUILD_PROGRAM_FAILURE = -11
  #CL_MAP_FAILURE = -12
  #CL_MISALIGNED_SUB_BUFFER_OFFSET = -13
  #CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST = -14
  #CL_COMPILE_PROGRAM_FAILURE = -15
  #CL_LINKER_NOT_AVAILABLE = -16
  #CL_LINK_PROGRAM_FAILURE = -17
  #CL_DEVICE_PARTITION_FAILED = -18
  #CL_KERNEL_ARG_INFO_NOT_AVAILABLE = -19
  #CL_INVALID_VALUE = -30
  #CL_INVALID_DEVICE_TYPE = -31
  #CL_INVALID_PLATFORM = -32
  #CL_INVALID_DEVICE = -33
  #CL_INVALID_CONTEXT = -34
  #CL_INVALID_QUEUE_PROPERTIES = -35
  #CL_INVALID_COMMAND_QUEUE = -36
  #CL_INVALID_HOST_PTR = -37
  #CL_INVALID_MEM_OBJECT = -38
  #CL_INVALID_IMAGE_FORMAT_DESCRIPTOR = -39
  #CL_INVALID_IMAGE_SIZE = -40
  #CL_INVALID_SAMPLER = -41
  #CL_INVALID_BINARY = -42
  #CL_INVALID_BUILD_OPTIONS = -43
  #CL_INVALID_PROGRAM = -44
  #CL_INVALID_PROGRAM_EXECUTABLE = -45
  #CL_INVALID_KERNEL_NAME = -46
  #CL_INVALID_KERNEL_DEFINITION = -47
  #CL_INVALID_KERNEL = -48
  #CL_INVALID_ARG_INDEX = -49
  #CL_INVALID_ARG_VALUE = -50
  #CL_INVALID_ARG_SIZE = -51
  #CL_INVALID_KERNEL_ARGS = -52
  #CL_INVALID_WORK_DIMENSION = -53
  #CL_INVALID_WORK_GROUP_SIZE = -54
  #CL_INVALID_WORK_ITEM_SIZE = -55
  #CL_INVALID_GLOBAL_OFFSET = -56
  #CL_INVALID_EVENT_WAIT_LIST = -57
  #CL_INVALID_EVENT = -58
  #CL_INVALID_OPERATION = -59
  #CL_INVALID_GL_OBJECT = -60
  #CL_INVALID_BUFFER_SIZE = -61
  #CL_INVALID_MIP_LEVEL = -62
  #CL_INVALID_GLOBAL_WORK_SIZE = -63
  #CL_INVALID_PROPERTY = -64
  #CL_INVALID_IMAGE_DESCRIPTOR = -65
  #CL_INVALID_COMPILER_OPTIONS = -66
  #CL_INVALID_LINKER_OPTIONS = -67
  #CL_INVALID_DEVICE_PARTITION_COUNT = -68

  ; -----------------------------------------------------------------------------
  ; OpenCL Version
  ; -----------------------------------------------------------------------------
  #CL_VERSION_1_0 = 1
  #CL_VERSION_1_1 = 1
  #CL_VERSION_1_2 = 1

  ; -----------------------------------------------------------------------------
  ; cl_bool
  ; -----------------------------------------------------------------------------
  #CL_FALSE = 0
  #CL_TRUE = 1
  #CL_BLOCKING = #CL_TRUE
  #CL_NON_BLOCKING = #CL_FALSE

  ; -----------------------------------------------------------------------------
  ; cl_platform_info
  ; -----------------------------------------------------------------------------
  #CL_PLATFORM_PROFILE = $0900
  #CL_PLATFORM_VERSION = $0901
  #CL_PLATFORM_NAME = $0902
  #CL_PLATFORM_VENDOR = $0903
  #CL_PLATFORM_EXTENSIONS = $0904

  ; -----------------------------------------------------------------------------
  ; cl_device_type - bitfield
  ; -----------------------------------------------------------------------------
  #CL_DEVICE_TYPE_DEFAULT = (1 << 0)
  #CL_DEVICE_TYPE_CPU = (1 << 1)
  #CL_DEVICE_TYPE_GPU = (1 << 2)
  #CL_DEVICE_TYPE_ACCELERATOR = (1 << 3)
  #CL_DEVICE_TYPE_CUSTOM = (1 << 4)
  #CL_DEVICE_TYPE_ALL = $FFFFFFFF

  ; -----------------------------------------------------------------------------
  ; cl_device_info 
  ; -----------------------------------------------------------------------------
  #CL_DEVICE_TYPE = $1000
  #CL_DEVICE_VENDOR_ID = $1001
  #CL_DEVICE_MAX_COMPUTE_UNITS = $1002
  #CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS = $1003
  #CL_DEVICE_MAX_WORK_GROUP_SIZE = $1004
  #CL_DEVICE_MAX_WORK_ITEM_SIZES = $1005
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR = $1006
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT = $1007
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT = $1008
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG = $1009
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT = $100A
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE = $100B
  #CL_DEVICE_MAX_CLOCK_FREQUENCY = $100C
  #CL_DEVICE_ADDRESS_BITS = $100D
  #CL_DEVICE_MAX_READ_IMAGE_ARGS = $100E
  #CL_DEVICE_MAX_WRITE_IMAGE_ARGS = $100F
  #CL_DEVICE_MAX_MEM_ALLOC_SIZE = $1010
  #CL_DEVICE_IMAGE2D_MAX_WIDTH = $1011
  #CL_DEVICE_IMAGE2D_MAX_HEIGHT = $1012
  #CL_DEVICE_IMAGE3D_MAX_WIDTH = $1013
  #CL_DEVICE_IMAGE3D_MAX_HEIGHT = $1014
  #CL_DEVICE_IMAGE3D_MAX_DEPTH = $1015
  #CL_DEVICE_IMAGE_SUPPORT = $1016
  #CL_DEVICE_MAX_PARAMETER_SIZE = $1017
  #CL_DEVICE_MAX_SAMPLERS = $1018
  #CL_DEVICE_MEM_BASE_ADDR_ALIGN = $1019
  #CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE = $101A
  #CL_DEVICE_SINGLE_FP_CONFIG = $101B
  #CL_DEVICE_GLOBAL_MEM_CACHE_TYPE = $101C
  #CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE = $101D
  #CL_DEVICE_GLOBAL_MEM_CACHE_SIZE = $101E
  #CL_DEVICE_GLOBAL_MEM_SIZE = $101F
  #CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE = $1020
  #CL_DEVICE_MAX_CONSTANT_ARGS = $1021
  #CL_DEVICE_LOCAL_MEM_TYPE = $1022
  #CL_DEVICE_LOCAL_MEM_SIZE = $1023
  #CL_DEVICE_ERROR_CORRECTION_SUPPORT = $1024
  #CL_DEVICE_PROFILING_TIMER_RESOLUTION = $1025
  #CL_DEVICE_ENDIAN_LITTLE = $1026
  #CL_DEVICE_AVAILABLE = $1027
  #CL_DEVICE_COMPILER_AVAILABLE = $1028
  #CL_DEVICE_EXECUTION_CAPABILITIES = $1029
  #CL_DEVICE_QUEUE_PROPERTIES = $102A
  #CL_DEVICE_NAME = $102B
  #CL_DEVICE_VENDOR = $102C
  #CL_DRIVER_VERSION = $102D
  #CL_DEVICE_PROFILE = $102E
  #CL_DEVICE_VERSION = $102F
  #CL_DEVICE_EXTENSIONS = $1030
  #CL_DEVICE_PLATFORM = $1031
  #CL_DEVICE_DOUBLE_FP_CONFIG = $1032

  ; -----------------------------------------------------------------------------
  ; 0x1033 reserved for CL_DEVICE_HALF_FP_CONFIG <<<<<
  ; -----------------------------------------------------------------------------
  #CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF = $1034
  #CL_DEVICE_HOST_UNIFIED_MEMORY = $1035
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR = $1036
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT = $1037
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_INT = $1038
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG = $1039
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT = $103A
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE = $103B
  #CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF = $103C
  #CL_DEVICE_OPENCL_C_VERSION = $103D
  #CL_DEVICE_LINKER_AVAILABLE = $103E
  #CL_DEVICE_BUILT_IN_KERNELS = $103F
  #CL_DEVICE_IMAGE_MAX_BUFFER_SIZE = $1040
  #CL_DEVICE_IMAGE_MAX_ARRAY_SIZE = $1041
  #CL_DEVICE_PARENT_DEVICE = $1042
  #CL_DEVICE_PARTITION_MAX_SUB_DEVICES = $1043
  #CL_DEVICE_PARTITION_PROPERTIES = $1044
  #CL_DEVICE_PARTITION_AFFINITY_DOMAIN = $1045
  #CL_DEVICE_PARTITION_TYPE = $1046
  #CL_DEVICE_REFERENCE_COUNT = $1047
  #CL_DEVICE_PREFERRED_INTEROP_USER_SYNC = $1048
  #CL_DEVICE_PRINTF_BUFFER_SIZE = $1049

  ; -----------------------------------------------------------------------------
  ; cl_device_fp_config - bitfield
  ; -----------------------------------------------------------------------------
  #CL_FP_DENORM = (1 << 0)
  #CL_FP_INF_NAN = (1 << 1)
  #CL_FP_ROUND_TO_NEAREST = (1 << 2)
  #CL_FP_ROUND_TO_ZERO = (1 << 3)
  #CL_FP_ROUND_TO_INF = (1 << 4)
  #CL_FP_FMA = (1 << 5)
  #CL_FP_SOFT_FLOAT = (1 << 6)
  #CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT = (1 << 7)

  ; -----------------------------------------------------------------------------
  ; cl_device_mem_cache_type
  ; -----------------------------------------------------------------------------
  #CL_NONE = $0
  #CL_READ_ONLY_CACHE = $1
  #CL_READ_WRITE_CACHE = $2

  ; -----------------------------------------------------------------------------
  ; cl_device_local_mem_type
  ; -----------------------------------------------------------------------------
  #CL_LOCAL = $1
  #CL_GLOBAL = $2

  ; -----------------------------------------------------------------------------
  ; cl_device_exec_capabilities - bitfield
  ; -----------------------------------------------------------------------------
  #CL_EXEC_KERNEL = (1 << 0)
  #CL_EXEC_NATIVE_KERNEL = (1 << 1)

  ; -----------------------------------------------------------------------------
  ; cl_command_queue_properties - bitfield
  ; -----------------------------------------------------------------------------
  #CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE = (1 << 0)
  #CL_QUEUE_PROFILING_ENABLE = (1 << 1)

  ; -----------------------------------------------------------------------------
  ; cl_context_info
  ; -----------------------------------------------------------------------------
  #CL_CONTEXT_REFERENCE_COUNT = $1080
  #CL_CONTEXT_DEVICES = $1081
  #CL_CONTEXT_PROPERTIES = $1082
  #CL_CONTEXT_NUM_DEVICES = $1083

  ; -----------------------------------------------------------------------------
  ; cl_context_properties
  ; -----------------------------------------------------------------------------
  #CL_CONTEXT_PLATFORM = $1084
  #CL_CONTEXT_INTEROP_USER_SYNC = $1085

  ; -----------------------------------------------------------------------------
  ; cl_device_partition_property
  ; -----------------------------------------------------------------------------
  #CL_DEVICE_PARTITION_EQUALLY = $1086
  #CL_DEVICE_PARTITION_BY_COUNTS = $1087
  #CL_DEVICE_PARTITION_BY_COUNTS_LIST_END = $0
  #CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN = $1088

  ; -----------------------------------------------------------------------------
  ; cl_device_affinity_domain
  ; -----------------------------------------------------------------------------
  #CL_DEVICE_AFFINITY_DOMAIN_NUMA = (1 << 0)
  #CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE = (1 << 1)
  #CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE = (1 << 2)
  #CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE = (1 << 3)
  #CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE = (1 << 4)
  #CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE = (1 << 5)

  ; -----------------------------------------------------------------------------
  ; cl_command_queue_info
  ; -----------------------------------------------------------------------------
  #CL_QUEUE_CONTEXT = $1090
  #CL_QUEUE_DEVICE = $1091
  #CL_QUEUE_REFERENCE_COUNT = $1092
  #CL_QUEUE_PROPERTIES = $1093

  ; -----------------------------------------------------------------------------
  ; cl_mem_flags - bitfield
  ; -----------------------------------------------------------------------------
  #CL_MEM_READ_WRITE = (1 << 0)
  #CL_MEM_WRITE_ONLY = (1 << 1)
  #CL_MEM_READ_ONLY = (1 << 2)
  #CL_MEM_USE_HOST_PTR = (1 << 3)
  #CL_MEM_ALLOC_HOST_PTR = (1 << 4)
  #CL_MEM_COPY_HOST_PTR = (1 << 5)
  #CL_MEM_HOST_WRITE_ONLY = (1 << 7)
  #CL_MEM_HOST_READ_ONLY = (1 << 8)
  #CL_MEM_HOST_NO_ACCESS = (1 << 9)

  ; -----------------------------------------------------------------------------
  ; cl_mem_migration_flags - bitfield
  ; -----------------------------------------------------------------------------
  #CL_MIGRATE_MEM_OBJECT_HOST = (1 << 0)
  #CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED = (1 << 1)

  ; -----------------------------------------------------------------------------
  ; cl_channel_order
  ; -----------------------------------------------------------------------------
  #CL_R = $10B0
  #CL_A = $10B1
  #CL_RG = $10B2
  #CL_RA = $10B3
  #CL_RGB = $10B4
  #CL_RGBA = $10B5
  #CL_BGRA = $10B6
  #CL_ARGB = $10B7
  #CL_INTENSITY = $10B8
  #CL_LUMINANCE = $10B9
  #CL_Rx = $10BA
  #CL_RGx = $10BB
  #CL_RGBx = $10BC

  ; -----------------------------------------------------------------------------
  ; cl_channel_type
  ; -----------------------------------------------------------------------------
  #CL_SNORM_INT8 = $10D0
  #CL_SNORM_INT16 = $10D1
  #CL_UNORM_INT8 = $10D2
  #CL_UNORM_INT16 = $10D3
  #CL_UNORM_SHORT_565 = $10D4
  #CL_UNORM_SHORT_555 = $10D5
  #CL_UNORM_INT_101010 = $10D6
  #CL_SIGNED_INT8 = $10D7
  #CL_SIGNED_INT16 = $10D8
  #CL_SIGNED_INT32 = $10D9
  #CL_UNSIGNED_INT8 = $10DA
  #CL_UNSIGNED_INT16 = $10DB
  #CL_UNSIGNED_INT32 = $10DC
  #CL_HALF_FLOAT = $10DD
  #CL_FLOAT = $10DE

  ; -----------------------------------------------------------------------------
  ; cl_mem_object_type
  ; -----------------------------------------------------------------------------
  #CL_MEM_OBJECT_BUFFER = $10F0
  #CL_MEM_OBJECT_IMAGE2D = $10F1
  #CL_MEM_OBJECT_IMAGE3D = $10F2
  #CL_MEM_OBJECT_IMAGE2D_ARRAY = $10F3
  #CL_MEM_OBJECT_IMAGE1D = $10F4
  #CL_MEM_OBJECT_IMAGE1D_ARRAY = $10F5
  #CL_MEM_OBJECT_IMAGE1D_BUFFER = $10F6

  ; -----------------------------------------------------------------------------
  ; cl_mem_info
  ; -----------------------------------------------------------------------------
  #CL_MEM_TYPE = $1100
  #CL_MEM_FLAGS = $1101
  #CL_MEM_SIZE = $1102
  #CL_MEM_HOST_PTR = $1103
  #CL_MEM_MAP_COUNT = $1104
  #CL_MEM_REFERENCE_COUNT = $1105
  #CL_MEM_CONTEXT = $1106
  #CL_MEM_ASSOCIATED_MEMOBJECT = $1107
  #CL_MEM_OFFSET = $1108

  ; -----------------------------------------------------------------------------
  ; cl_image_info
  ; -----------------------------------------------------------------------------
  #CL_IMAGE_FORMAT = $1110
  #CL_IMAGE_ELEMENT_SIZE = $1111
  #CL_IMAGE_ROW_PITCH = $1112
  #CL_IMAGE_SLICE_PITCH = $1113
  #CL_IMAGE_WIDTH = $1114
  #CL_IMAGE_HEIGHT = $1115
  #CL_IMAGE_DEPTH = $1116
  #CL_IMAGE_ARRAY_SIZE = $1117
  #CL_IMAGE_BUFFER = $1118
  #CL_IMAGE_NUM_MIP_LEVELS = $1119
  #CL_IMAGE_NUM_SAMPLES = $111A

  ; -----------------------------------------------------------------------------
  ; cl_addressing_mode
  ; -----------------------------------------------------------------------------
  #CL_ADDRESS_NONE = $1130
  #CL_ADDRESS_CLAMP_TO_EDGE = $1131
  #CL_ADDRESS_CLAMP = $1132
  #CL_ADDRESS_REPEAT = $1133
  #CL_ADDRESS_MIRRORED_REPEAT = $1134

  ; -----------------------------------------------------------------------------
  ; cl_filter_mode
  ; -----------------------------------------------------------------------------
  #CL_FILTER_NEAREST = $1140
  #CL_FILTER_LINEAR = $1141

  ; -----------------------------------------------------------------------------
  ; cl_sampler_info
  ; -----------------------------------------------------------------------------
  #CL_SAMPLER_REFERENCE_COUNT = $1150
  #CL_SAMPLER_CONTEXT = $1151
  #CL_SAMPLER_NORMALIZED_COORDS = $1152
  #CL_SAMPLER_ADDRESSING_MODE = $1153
  #CL_SAMPLER_FILTER_MODE = $1154

  ; -----------------------------------------------------------------------------
  ; cl_map_flags - bitfield
  ; -----------------------------------------------------------------------------
  #CL_MAP_READ = (1 << 0)
  #CL_MAP_WRITE = (1 << 1)
  #CL_MAP_WRITE_INVALIDATE_REGION = (1 << 2)

  ; -----------------------------------------------------------------------------
  ; cl_program_info
  ; -----------------------------------------------------------------------------
  #CL_PROGRAM_REFERENCE_COUNT = $1160
  #CL_PROGRAM_CONTEXT = $1161
  #CL_PROGRAM_NUM_DEVICES = $1162
  #CL_PROGRAM_DEVICES = $1163
  #CL_PROGRAM_SOURCE = $1164
  #CL_PROGRAM_BINARY_SIZES = $1165
  #CL_PROGRAM_BINARIES = $1166
  #CL_PROGRAM_NUM_KERNELS = $1167
  #CL_PROGRAM_KERNEL_NAMES = $1168

  ; -----------------------------------------------------------------------------
  ; cl_program_build_info
  ; -----------------------------------------------------------------------------
  #CL_PROGRAM_BUILD_STATUS = $1181
  #CL_PROGRAM_BUILD_OPTIONS = $1182
  #CL_PROGRAM_BUILD_LOG = $1183
  #CL_PROGRAM_BINARY_TYPE = $1184

  ; -----------------------------------------------------------------------------
  ; cl_program_binary_type
  ; -----------------------------------------------------------------------------
  #CL_PROGRAM_BINARY_TYPE_NONE = $0
  #CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT = $1
  #CL_PROGRAM_BINARY_TYPE_LIBRARY = $2
  #CL_PROGRAM_BINARY_TYPE_EXECUTABLE = $4

  ; -----------------------------------------------------------------------------
  ; cl_build_status
  ; -----------------------------------------------------------------------------
  #CL_BUILD_SUCCESS = 0
  #CL_BUILD_NONE = -1
  #CL_BUILD_ERROR = -2
  #CL_BUILD_IN_PROGRESS = -3

  ; -----------------------------------------------------------------------------
  ; cl_kernel_info
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_FUNCTION_NAME = $1190
  #CL_KERNEL_NUM_ARGS = $1191
  #CL_KERNEL_REFERENCE_COUNT = $1192
  #CL_KERNEL_CONTEXT = $1193
  #CL_KERNEL_PROGRAM = $1194
  #CL_KERNEL_ATTRIBUTES = $1195

  ; -----------------------------------------------------------------------------
  ; cl_kernel_arg_info
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_ARG_ADDRESS_QUALIFIER = $1196
  #CL_KERNEL_ARG_ACCESS_QUALIFIER = $1197
  #CL_KERNEL_ARG_TYPE_NAME = $1198
  #CL_KERNEL_ARG_TYPE_QUALIFIER = $1199
  #CL_KERNEL_ARG_NAME = $119A

  ; -----------------------------------------------------------------------------
  ; cl_kernel_arg_address_qualifier
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_ARG_ADDRESS_GLOBAL = $119B
  #CL_KERNEL_ARG_ADDRESS_LOCAL = $119C
  #CL_KERNEL_ARG_ADDRESS_CONSTANT = $119D
  #CL_KERNEL_ARG_ADDRESS_PRIVATE = $119E

  ; -----------------------------------------------------------------------------
  ; cl_kernel_arg_access_qualifier
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_ARG_ACCESS_READ_ONLY = $11A0
  #CL_KERNEL_ARG_ACCESS_WRITE_ONLY = $11A1
  #CL_KERNEL_ARG_ACCESS_READ_WRITE = $11A2
  #CL_KERNEL_ARG_ACCESS_NONE = $11A3

  ; -----------------------------------------------------------------------------
  ; cl_kernel_arg_type_qualifer
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_ARG_TYPE_NONE = 0
  #CL_KERNEL_ARG_TYPE_CONST = (1 << 0)
  #CL_KERNEL_ARG_TYPE_RESTRICT = (1 << 1)
  #CL_KERNEL_ARG_TYPE_VOLATILE = (1 << 2)

  ; -----------------------------------------------------------------------------
  ; cl_kernel_work_group_info
  ; -----------------------------------------------------------------------------
  #CL_KERNEL_WORK_GROUP_SIZE = $11B0
  #CL_KERNEL_COMPILE_WORK_GROUP_SIZE = $11B1
  #CL_KERNEL_LOCAL_MEM_SIZE = $11B2
  #CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE = $11B3
  #CL_KERNEL_PRIVATE_MEM_SIZE = $11B4
  #CL_KERNEL_GLOBAL_WORK_SIZE = $11B5

  ; -----------------------------------------------------------------------------
  ; cl_event_info
  ; -----------------------------------------------------------------------------
  #CL_EVENT_COMMAND_QUEUE = $11D0
  #CL_EVENT_COMMAND_TYPE = $11D1
  #CL_EVENT_REFERENCE_COUNT = $11D2
  #CL_EVENT_COMMAND_EXECUTION_STATUS = $11D3
  #CL_EVENT_CONTEXT = $11D4

  ; -----------------------------------------------------------------------------
  ; cl_command_type
  ; -----------------------------------------------------------------------------
  #CL_COMMAND_NDRANGE_KERNEL = $11F0
  #CL_COMMAND_TASK = $11F1
  #CL_COMMAND_NATIVE_KERNEL = $11F2
  #CL_COMMAND_READ_BUFFER = $11F3
  #CL_COMMAND_WRITE_BUFFER = $11F4
  #CL_COMMAND_COPY_BUFFER = $11F5
  #CL_COMMAND_READ_IMAGE = $11F6
  #CL_COMMAND_WRITE_IMAGE = $11F7
  #CL_COMMAND_COPY_IMAGE = $11F8
  #CL_COMMAND_COPY_IMAGE_TO_BUFFER = $11F9
  #CL_COMMAND_COPY_BUFFER_TO_IMAGE = $11FA
  #CL_COMMAND_MAP_BUFFER = $11FB
  #CL_COMMAND_MAP_IMAGE = $11FC
  #CL_COMMAND_UNMAP_MEM_OBJECT = $11FD
  #CL_COMMAND_MARKER = $11FE
  #CL_COMMAND_ACQUIRE_GL_OBJECTS = $11FF
  #CL_COMMAND_RELEASE_GL_OBJECTS = $1200
  #CL_COMMAND_READ_BUFFER_RECT = $1201
  #CL_COMMAND_WRITE_BUFFER_RECT = $1202
  #CL_COMMAND_COPY_BUFFER_RECT = $1203
  #CL_COMMAND_USER = $1204
  #CL_COMMAND_BARRIER = $1205
  #CL_COMMAND_MIGRATE_MEM_OBJECTS = $1206
  #CL_COMMAND_FILL_BUFFER = $1207
  #CL_COMMAND_FILL_IMAGE = $1208

  ; -----------------------------------------------------------------------------
  ; command execution status
  ; -----------------------------------------------------------------------------
  #CL_COMPLETE = $0
  #CL_RUNNING = $1
  #CL_SUBMITTED = $2
  #CL_QUEUED = $3

  ; -----------------------------------------------------------------------------
  ; cl_buffer_create_type
  ; -----------------------------------------------------------------------------
  #CL_BUFFER_CREATE_TYPE_REGION = $1220

  ; -----------------------------------------------------------------------------
  ; cl_profiling_info
  ; -----------------------------------------------------------------------------
  #CL_PROFILING_COMMAND_QUEUED = $1280
  #CL_PROFILING_COMMAND_SUBMIT = $1281
  #CL_PROFILING_COMMAND_START = $1282
  #CL_PROFILING_COMMAND_END = $1283

  Declare.s clErrorMessage(ErrorID)
      
  ; -----------------------------------------------------------------------------
  ; Function imports
  ; -----------------------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
     
    CompilerCase #PB_OS_Windows
      Import "OpenCL.lib"
  
    CompilerCase #PB_OS_Linux
      ImportC "-l OpenCL"
  
    CompilerCase #PB_OS_MacOS
      ImportC "/System/Library/Frameworks/OpenCL.framework/OpenCL"
  
  CompilerEndSelect
   
    ; ---------------------------------------------------------------------------
    ; Platform API
    ; ---------------------------------------------------------------------------
    clGetPlatformIDs(num_entries, *platforms, *num_platforms) ; CL_API_SUFFIX__VERSION_1_0;
    clGetPlatformInfo(platform, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Device APIs
    ; ---------------------------------------------------------------------------
    clGetDeviceIDs(platform, device_type.q, num_entries, *devices, *num_devices) ; CL_API_SUFFIX__VERSION_1_0;
    clGetDeviceInfo(device, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateSubDevices(in_device, *properties, num_devices, *out_devices, *num_devices_ret) ; CL_API_SUFFIX__VERSION_1_2;
    clRetainDevice(device) ; CL_API_SUFFIX__VERSION_1_2;
    clReleaseDevice(device) ; CL_API_SUFFIX__VERSION_1_2;
   
    ; ---------------------------------------------------------------------------
    ; Context APIs
    ; ---------------------------------------------------------------------------
    clCreateContext(*properties, num_devices, *devices, *pfn_notify, *user_data, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0
    clCreateContextFromType(*properties, device_type.q, *pfn_notify, *user_data, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0
    clRetainContext(context) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseContext(context) ; CL_API_SUFFIX__VERSION_1_0;
    clGetContextInfo(context, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Command Queue APIs
    ; ---------------------------------------------------------------------------
    clCreateCommandQueue(context, device, properties.q, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clRetainCommandQueue(command_queue) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseCommandQueue(command_queue) ; CL_API_SUFFIX__VERSION_1_0;
    clGetCommandQueueInfo(command_queue, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Memory Object APIs
    ; ---------------------------------------------------------------------------
    clCreateBuffer(context, flags.q, size, *host_ptr, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateSubBuffer(buffer, flags.q, buffer_create_type, *buffer_create_info, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_1;
    clCreateImage(context, flags.q, *image_format, *image_desc, *host_ptr, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_2;
    clRetainMemObject(memobj) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseMemObject(memobj) ; CL_API_SUFFIX__VERSION_1_0;
    clGetSupportedImageFormats(context, flags.q, image_type, num_entries, *image_formats, *num_image_formats) ; CL_API_SUFFIX__VERSION_1_0;
    clGetMemObjectInfo(memobj, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clGetImageInfo(image, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clSetMemObjectDestructorCallback(memobj, *pfn_notify, *user_data) ; CL_API_SUFFIX__VERSION_1_1
   
    ; ---------------------------------------------------------------------------
    ; Sampler APIs
    ; ---------------------------------------------------------------------------
    clCreateSampler(context, normalized_coords, addressing_mode, filter_mode, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clRetainSampler(sampler) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseSampler(sampler) ; CL_API_SUFFIX__VERSION_1_0;
    clGetSamplerInfo(sampler, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Program Object APIs
    ; ---------------------------------------------------------------------------
    clCreateProgramWithSource(context, count, strings, *lengths, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateProgramWithBinary(context, num_devices, *device_list, *lengths, binaries, *binary_status, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateProgramWithBuiltInKernels(context, num_devices, *device_list, kernel_names.p-ascii, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_2;
    clRetainProgram(program) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseProgram(program) ; CL_API_SUFFIX__VERSION_1_0;
    clBuildProgram(program, num_devices, *device_list, options.p-ascii, *pfn_notify, *user_data) ; CL_API_SUFFIX__VERSION_1_0
    clCompileProgram(program, num_devices, *device_list, options.p-ascii, num_input_headers, *input_headers, header_include_names, *pfn_notify, *user_data) ; CL_API_SUFFIX__VERSION_1_0
    clLinkProgram(context, num_devices, *device_list, options.p-ascii, num_input_programs, *input_programs, *pfn_notify, *user_data, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_2
    clUnloadPlatformCompiler(platform) ; CL_API_SUFFIX__VERSION_1_2;
    clGetProgramInfo(program, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clGetProgramBuildInfo(program, device, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Kernel Object APIs
    ; ---------------------------------------------------------------------------
    clCreateKernel(program, kernel_name.p-ascii, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateKernelsInProgram(program, num_kernels, *kernels, *num_kernels_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clRetainKernel(kernel) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseKernel(kernel) ; CL_API_SUFFIX__VERSION_1_0;
    clSetKernelArg(kernel, arg_index, arg_size, *arg_value) ; CL_API_SUFFIX__VERSION_1_0;
    clGetKernelInfo(kernel, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clGetKernelArgInfo(kernel, arg_indx, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_2;
    clGetKernelWorkGroupInfo(kernel, device, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Event Object APIs
    ; ---------------------------------------------------------------------------
    clWaitForEvents(num_events, *event_list) ; CL_API_SUFFIX__VERSION_1_0;
    clGetEventInfo(event, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clCreateUserEvent(context, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_1;
    clRetainEvent(event) ; CL_API_SUFFIX__VERSION_1_0;
    clReleaseEvent(event) ; CL_API_SUFFIX__VERSION_1_0;
    clSetUserEventStatus(event, execution_status) ; CL_API_SUFFIX__VERSION_1_1;
    clSetEventCallback(event, command_exec_callback_type, *pfn_notify, *user_data) ; CL_API_SUFFIX__VERSION_1_1;
   
    ; ---------------------------------------------------------------------------
    ; Profiling APIs
    ; ---------------------------------------------------------------------------
    clGetEventProfilingInfo(event, param_name, param_value_size, *param_value, *param_value_size_ret) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Flush and Finish APIs
    ; ---------------------------------------------------------------------------
    clFlush(command_queue) ; CL_API_SUFFIX__VERSION_1_0;
    clFinish(command_queue) ; CL_API_SUFFIX__VERSION_1_0;
   
    ; ---------------------------------------------------------------------------
    ; Enqueued Commands APIs
    ; ---------------------------------------------------------------------------
    clEnqueueReadBuffer(command_queue, buffer, blocking_read, offset, size, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueReadBufferRect(command_queue, buffer, blocking_read, *buffer_offset, *host_offset, *region, buffer_row_pitch, buffer_slice_pitch, host_row_pitch, host_slice_pitch, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_1;
    clEnqueueWriteBuffer(command_queue, buffer, blocking_write, offset, size, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueWriteBufferRect(command_queue, buffer, blocking_write, *buffer_offset, *host_offset, *region, buffer_row_pitch, buffer_slice_pitch, host_row_pitch, host_slice_pitch, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_1;
    clEnqueueFillBuffer(command_queue, buffer, *pattern, pattern_size, offset, size, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_2;
    clEnqueueCopyBuffer(command_queue, src_buffer, dst_buffer, src_offset, dst_offset, size, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueCopyBufferRect(command_queue, src_buffer, dst_buffer, *src_origin, *dst_origin, *region, src_row_pitch, src_slice_pitch, dst_row_pitch, dst_slice_pitch, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_1;
    clEnqueueReadImage(command_queue, image, blocking_read, *origin, *region, row_pitch, slice_pitch, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueWriteImage(command_queue, image, blocking_write, *origin, *region, input_row_pitch, input_slice_pitch, *ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueFillImage(command_queue, image, *fill_color, *origin, *region, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_2;
    clEnqueueCopyImage(command_queue, src_image, dst_image, *src_origin, *dst_origin, *region, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueCopyImageToBuffer(command_queue, src_image, dst_buffer, *src_origin, *region, dst_offset, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueCopyBufferToImage(command_queue, src_buffer, dst_image, src_offset, *dst_origin, *region, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueMapBuffer(command_queue, buffer, blocking_map, map_flags.q, offset, size, num_events_in_wait_list, *event_wait_list, *event, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueMapImage(command_queue, image, blocking_map, map_flags.q, *origin, *region, *image_row_pitch, *image_slice_pitch, num_events_in_wait_list, *event_wait_list, *event, *errcode_ret) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueUnmapMemObject(command_queue, memobj, *mapped_ptr, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueMigrateMemObjects(command_queue, num_mem_objects, *mem_objects, flags.q, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_2;
    clEnqueueNDRangeKernel(command_queue, kernel, work_dim, *global_work_offset, *global_work_size, *local_work_size, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueTask(command_queue, kernel, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueNativeKernel(command_queue,*user_func, *args, cb_args, num_mem_objects,*mem_list, *args_mem_loc, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_0;
    clEnqueueMarkerWithWaitList(command_queue, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_2;
    clEnqueueBarrierWithWaitList(command_queue, num_events_in_wait_list, *event_wait_list, *event) ; CL_API_SUFFIX__VERSION_1_2;
    clSetPrintfCallback(context, *pfn_notify, *user_data); CL_API_SUFFIX__VERSION_1_2
   
    ; ---------------------------------------------------------------------------
    ; Deprecated OpenCL 1.1 APIs
    ; ---------------------------------------------------------------------------
    clCreateImage2D(context, flags.q, *image_format, image_width, image_height, image_row_pitch, *host_ptr, *errcode_ret) ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
    clCreateImage3D(context, flags.q, *image_format, image_width, image_height, image_depth, image_row_pitch, image_slice_pitch, *host_ptr, *errcode_ret) ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
    clEnqueueMarker(command_queue, *event) ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
    clEnqueueWaitForEvents(command_queue, num_events, *event_list) ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
    clEnqueueBarrier(command_queue) ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
    clUnloadCompiler() ; CL_EXT_SUFFIX__VERSION_1_1_DEPRECATED;
   
  EndImport
EndDeclareModule

; ===============================================================================
; OpenCL Module Implementation
; ===============================================================================
Module OpenCL
  Procedure.s clErrorMessage(ErrorID)
   
    Protected OutputMessage.s
   
    Select ErrorID
       
      Case #CL_DEVICE_NOT_FOUND
        OutputMessage = "CL DEVICE NOT FOUND"
       
      Case #CL_DEVICE_NOT_AVAILABLE
        OutputMessage = "CL DEVICE NOT AVAILABLE"
       
      Case #CL_COMPILER_NOT_AVAILABLE
        OutputMessage = "CL COMPILER NOT AVAILABLE"
       
      Case #CL_MEM_OBJECT_ALLOCATION_FAILURE
        OutputMessage = "CL MEM OBJECT ALLOCATION FAILURE"
       
      Case #CL_OUT_OF_RESOURCES
        OutputMessage = "CL OUT OF RESOURCES"
       
      Case #CL_OUT_OF_HOST_MEMORY
        OutputMessage = "CL OUT OF HOST MEMORY"
       
      Case #CL_PROFILING_INFO_NOT_AVAILABLE
        OutputMessage = "CL PROFILING INFO NOT AVAILABLE"
       
      Case #CL_MEM_COPY_OVERLAP
        OutputMessage = "CL MEM COPY OVERLAP"
       
      Case #CL_IMAGE_FORMAT_MISMATCH
        OutputMessage = "CL IMAGE FORMAT MISMATCH"
       
      Case #CL_IMAGE_FORMAT_NOT_SUPPORTED
        OutputMessage = "CL IMAGE FORMAT NOT SUPPORTED"
       
      Case #CL_BUILD_PROGRAM_FAILURE
        OutputMessage = "CL BUILD PROGRAM FAILURE"
       
      Case #CL_MAP_FAILURE
        OutputMessage = "CL MAP FAILURE"
       
      Case #CL_MISALIGNED_SUB_BUFFER_OFFSET
        OutputMessage = "CL MISALIGNED SUB BUFFER OFFSET"
       
      Case #CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST
        OutputMessage = "CL EXEC STATUS ERROR FOR EVENTS IN WAIT LIST"
       
      Case #CL_COMPILE_PROGRAM_FAILURE
        OutputMessage = "CL COMPILE PROGRAM FAILURE"
       
      Case #CL_LINKER_NOT_AVAILABLE
        OutputMessage = "CL LINKER NOT AVAILABLE"
       
      Case #CL_LINK_PROGRAM_FAILURE
        OutputMessage = "CL LINK PROGRAM FAILURE"
       
      Case #CL_DEVICE_PARTITION_FAILED
        OutputMessage = "CL DEVICE PARTITION FAILED"
       
      Case #CL_KERNEL_ARG_INFO_NOT_AVAILABLE
        OutputMessage = "CL KERNEL ARG INFO NOT AVAILABLE"
       
      Case #CL_INVALID_VALUE
        OutputMessage = "CL INVALID VALUE"
       
      Case #CL_INVALID_DEVICE_TYPE
        OutputMessage = "CL INVALID DEVICE TYPE"
       
      Case #CL_INVALID_PLATFORM
        OutputMessage = "CL INVALID PLATFORM"
       
      Case #CL_INVALID_DEVICE
        OutputMessage = "CL INVALID DEVICE"
       
      Case #CL_INVALID_CONTEXT
        OutputMessage = "CL INVALID CONTEXT"
       
      Case #CL_INVALID_QUEUE_PROPERTIES
        OutputMessage = "CL INVALID QUEUE PROPERTIES"
       
      Case #CL_INVALID_COMMAND_QUEUE
        OutputMessage = "CL INVALID COMMAND QUEUE"
       
      Case #CL_INVALID_HOST_PTR
        OutputMessage = "CL INVALID HOST PTR"
       
      Case #CL_INVALID_MEM_OBJECT
        OutputMessage = "CL INVALID MEM OBJECT"
       
      Case #CL_INVALID_IMAGE_FORMAT_DESCRIPTOR
        OutputMessage = "CL INVALID IMAGE FORMAT DESCRIPTOR"
       
      Case #CL_INVALID_IMAGE_SIZE
        OutputMessage = "CL INVALID IMAGE SIZE"
       
      Case #CL_INVALID_SAMPLER
        OutputMessage = "CL INVALID SAMPLER"
       
      Case #CL_INVALID_BINARY
        OutputMessage = "CL INVALID BINARY"
       
      Case #CL_INVALID_BUILD_OPTIONS
        OutputMessage = "CL INVALID BUILD OPTIONS"
       
      Case #CL_INVALID_PROGRAM
        OutputMessage = "CL INVALID PROGRAM"
       
      Case #CL_INVALID_PROGRAM_EXECUTABLE
        OutputMessage = "CL INVALID PROGRAM EXECUTABLE"
       
      Case #CL_INVALID_KERNEL_NAME
        OutputMessage = "CL INVALID KERNEL NAME"
       
      Case #CL_INVALID_KERNEL_DEFINITION
        OutputMessage = "CL INVALID KERNEL DEFINITION"
       
      Case #CL_INVALID_KERNEL
        OutputMessage = "CL INVALID KERNEL"
       
      Case #CL_INVALID_ARG_INDEX
        OutputMessage = "CL INVALID ARG INDEX"
       
      Case #CL_INVALID_ARG_VALUE
        OutputMessage = "CL INVALID ARG VALUE"
       
      Case #CL_INVALID_ARG_SIZE
        OutputMessage = "CL INVALID ARG SIZE"
       
      Case #CL_INVALID_KERNEL_ARGS
        OutputMessage = "CL INVALID KERNEL ARGS"
       
      Case #CL_INVALID_WORK_DIMENSION
        OutputMessage = "CL INVALID WORK DIMENSION"
       
      Case #CL_INVALID_WORK_GROUP_SIZE
        OutputMessage = "CL INVALID WORK GROUP SIZE"
       
      Case #CL_INVALID_WORK_ITEM_SIZE
        OutputMessage = "CL INVALID WORK ITEM SIZE"
       
      Case #CL_INVALID_GLOBAL_OFFSET
        OutputMessage = "CL INVALID GLOBAL OFFSET"
       
      Case #CL_INVALID_EVENT_WAIT_LIST
        OutputMessage = "CL INVALID EVENT WAIT LIST"
       
      Case #CL_INVALID_EVENT
        OutputMessage = "CL INVALID EVENT"
       
      Case #CL_INVALID_OPERATION
        OutputMessage = "CL INVALID OPERATION"
       
      Case #CL_INVALID_GL_OBJECT
        OutputMessage = "CL INVALID GL OBJECT"
       
      Case #CL_INVALID_BUFFER_SIZE
        OutputMessage = "CL INVALID BUFFER SIZE"
       
      Case #CL_INVALID_MIP_LEVEL
        OutputMessage = "CL INVALID MIP LEVEL"
       
      Case #CL_INVALID_GLOBAL_WORK_SIZE
        OutputMessage = "CL INVALID GLOBAL WORK SIZE"
       
      Case #CL_INVALID_PROPERTY
        OutputMessage = "CL INVALID PROPERTY"
       
      Case #CL_INVALID_IMAGE_DESCRIPTOR
        OutputMessage = "CL INVALID IMAGE DESCRIPTOR"
       
      Case #CL_INVALID_COMPILER_OPTIONS
        OutputMessage = "CL INVALID COMPILER OPTIONS"
       
      Case #CL_INVALID_LINKER_OPTIONS
        OutputMessage = "CL INVALID LINKER OPTIONS"
       
      Case #CL_INVALID_DEVICE_PARTITION_COUNT
        OutputMessage = "CL INVALID DEVICE PARTITION COUNT"
       
      Default
        OutputMessage = "UNKNOWN (" + Str(ErrorID) + ")"
       
    EndSelect
   
    ProcedureReturn OutputMessage
  EndProcedure
EndModule
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 573
; FirstLine = 554
; Folding = -
; EnableXP