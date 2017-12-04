; ============================================================================
; OpenGL Module Declaration
; ============================================================================
DeclareModule OpenGL
  ;-----------------------------------------
  ; Constants
  ;-----------------------------------------
  CompilerIf Not Defined(USE_LEGACY_OPENGL,#PB_Constant)
    #USE_LEGACY_OPENGL = #False
  CompilerEndIf
  
  Global GL_EXTENSIONS_LOADED = #False
  CompilerIf Not Defined(USE_GLFW,#PB_Constant)
    #USE_GLFW = #False
  CompilerElse
    CompilerIf Not Defined(GLFW_GETPROCADDRESS_DEBUG, #PB_Constant)
      #GLFW_GETPROCADDRESS_DEBUG = 0
    CompilerEndIf
  CompilerEndIf
  
  ;-----------------------------------------
  ; Get GLFW String Output
  ;-----------------------------------------
  CompilerIf #PB_Compiler_Unicode
    Macro GLGETSTRINGOUTPUT(str_ptr)
     PeekS(str_ptr,-1,#PB_Ascii)
    EndMacro
  CompilerElse
    Macro GLGETSTRINGOUTPUT(str_ptr)
      PeekS(str_ptr)
    EndMacro
  CompilerEndIf
  
  ; ============================================================================
  ;  TYPES
  ; ============================================================================
  ;{
  ; ---[ GL_VERSION_1_1 ]-------------------------------------------------------
  Macro GLenum
    l
  EndMacro
  Macro GLboolean
    a
  EndMacro
  Macro GLbitfield
    l
  EndMacro
  Macro GLbyte
    b
  EndMacro
  Macro GLshort
    w
  EndMacro
  Macro GLint
    l
  EndMacro
  Macro GLsizei
    l
  EndMacro
  Macro GLubyte
    a
  EndMacro
  Macro GLushort
    u
  EndMacro
  Macro GLuint
    l
  EndMacro
  Macro GLfloat
    f
  EndMacro
  Macro GLclampf
    f
  EndMacro
  Macro GLdouble
    d
  EndMacro
  Macro GLclampd
    d
  EndMacro
  Macro GLvoid
    
  EndMacro
  ; ---[ GL_VERSION_1_5 ]-------------------------------------------------------
  Macro GLintptr
    i
  EndMacro
  Macro GLsizeiptr
    i
  EndMacro
  ; ---[ GL_VERSION_2_0 ]-------------------------------------------------------
  Macro GLchar
    a
  EndMacro
  ; ---[ GL_ARB_vertex_buffer_object ]------------------------------------------
  Macro GLintptrARB
    i
  EndMacro
  Macro GLsizeiptrARB
    i
  EndMacro
  ; ---[ GL_ARB_shader_objects ]------------------------------------------------
  Macro GLcharARB
    a
  EndMacro
  Macro GLhandleARB
    l
  EndMacro
  ; ---[ GL_ARB_half_float_pixel ]----------------------------------------------
  Macro GLhalfARB
    u
  EndMacro
  ; ---[ GL_NV_half_float ]-----------------------------------------------------
  Macro GLhalfNV
    u
  EndMacro
  ; ---[ GLEXT_64_TYPES ]-------------------------------------------------------
  Macro int32_t
    l
  EndMacro
  Macro int64_t
    q
  EndMacro
  Macro uint64_t
    q
  EndMacro
  ; ---[ GL_EXT_timer_query ]---------------------------------------------------
  Macro GLint64EXT
    q
  EndMacro
  Macro GLuint64EXT
    q
  EndMacro
  ; ---[ GL_ARB_sync ]----------------------------------------------------------
  Macro GLint64
    q
  EndMacro
  Macro GLuint64
    q
  EndMacro
  Macro GLsync
    i
  EndMacro
  ; ---[ GL_ARB_cl_event ]------------------------------------------------------
  ;Macro struct _cl_context;
  ;Macro struct _cl_event;
  ; ---[ GL_ARB_debug_output ]--------------------------------------------------
  PrototypeC GLDEBUGPROCARB( source.GLenum, type.GLenum, id.GLuint, severity.GLenum, length.GLsizei, *message, *userParam )
  ; ---[ GL_NV_vdpau_interop ]--------------------------------------------------
  Macro GLvdpauSurfaceNV
    i
  EndMacro
  ;}
  
  ; GL Constants now globals but not ALL
  Macro GL_DECLARE_CONSTANT(name, value)
    CompilerIf Not Defined(name, #PB_Constant)
      #name = value  
    CompilerEndIf
  EndMacro
  
  ; ============================================================================
  ;  CONSTANTS
  ; ============================================================================
  ;{
  ; ---[ GL_VERSION_1_1 ]-------------------------------------------------------
  ;{
  ; AttribMask
  #GL_DEPTH_BUFFER_BIT                                   = $00000100
  #GL_STENCIL_BUFFER_BIT                                 = $00000400
  #GL_COLOR_BUFFER_BIT                                   = $00004000
  ; Boolean
  #GL_FALSE                                              = 0
  #GL_TRUE                                               = 1
  
  ; BeginMode
  #GL_POINTS                                             = $0000
  #GL_LINES                                              = $0001
  #GL_LINE_LOOP                                          = $0002
  #GL_LINE_STRIP                                         = $0003
  #GL_TRIANGLES                                          = $0004
  #GL_TRIANGLE_STRIP                                     = $0005
  #GL_TRIANGLE_FAN                                       = $0006
  #GL_QUADS                                              = $0007
  #GL_QUAD_STRIP                                         = $0008
  #GL_POLYGON                                            = $0009
  
  
  ; AlphaFunction
  #GL_NEVER                                              = $0200
  #GL_LESS                                               = $0201
  #GL_EQUAL                                              = $0202
  #GL_LEQUAL                                             = $0203
  #GL_GREATER                                            = $0204
  #GL_NOTEQUAL                                           = $0205
  #GL_GEQUAL                                             = $0206
  #GL_ALWAYS                                             = $0207
  ; BlendingFactorDest
  #GL_ZERO                                               = 0
  #GL_ONE                                                = 1
  #GL_SRC_COLOR                                          = $0300
  #GL_ONE_MINUS_SRC_COLOR                                = $0301
  #GL_SRC_ALPHA                                          = $0302
  #GL_ONE_MINUS_SRC_ALPHA                                = $0303
  #GL_DST_ALPHA                                          = $0304
  #GL_ONE_MINUS_DST_ALPHA                                = $0305
  ; BlendingFactorSrc
  #GL_DST_COLOR                                          = $0306
  #GL_ONE_MINUS_DST_COLOR                                = $0307
  #GL_SRC_ALPHA_SATURATE                                 = $0308
  ; DrawBufferMode
  #GL_NONE                                               = 0
  #GL_FRONT_LEFT                                         = $0400
  #GL_FRONT_RIGHT                                        = $0401
  #GL_BACK_LEFT                                          = $0402
  #GL_BACK_RIGHT                                         = $0403
  #GL_FRONT                                              = $0404
  #GL_BACK                                               = $0405
  #GL_LEFT                                               = $0406
  #GL_RIGHT                                              = $0407
  #GL_FRONT_AND_BACK                                     = $0408
  ; ErrorCode
  #GL_NO_ERROR                                           = 0
  #GL_INVALID_ENUM                                       = $0500
  #GL_INVALID_VALUE                                      = $0501
  #GL_INVALID_OPERATION                                  = $0502
  #GL_OUT_OF_MEMORY                                      = $0505
  ; FrontFaceDirection
  #GL_CW                                                 = $0900
  #GL_CCW                                                = $0901
  ; GetPName
  #GL_POINT_SMOOTH                                       = $0B10
  #GL_POINT_SIZE                                         = $0B11
  #GL_POINT_SIZE_RANGE                                   = $0B12
  #GL_POINT_SIZE_GRANULARITY                             = $0B13
  #GL_LINE_SMOOTH                                        = $0B20
  #GL_LINE_WIDTH                                         = $0B21
  #GL_LINE_WIDTH_RANGE                                   = $0B22
  #GL_LINE_WIDTH_GRANULARITY                             = $0B23
  #GL_POLYGON_SMOOTH                                     = $0B41
  #GL_CULL_FACE                                          = $0B44
  #GL_CULL_FACE_MODE                                     = $0B45
  #GL_FRONT_FACE                                         = $0B46
  #GL_DEPTH_RANGE                                        = $0B70
  #GL_DEPTH_TEST                                         = $0B71
  
  #GL_DEPTH_WRITEMASK                                    = $0B72
  #GL_DEPTH_CLEAR_VALUE                                  = $0B73
  #GL_DEPTH_FUNC                                         = $0B74
  #GL_STENCIL_TEST                                       = $0B90
  #GL_STENCIL_CLEAR_VALUE                                = $0B91
  #GL_STENCIL_FUNC                                       = $0B92
  #GL_STENCIL_VALUE_MASK                                 = $0B93
  #GL_STENCIL_FAIL                                       = $0B94
  #GL_STENCIL_PASS_DEPTH_FAIL                            = $0B95
  #GL_STENCIL_PASS_DEPTH_PASS                            = $0B96
  #GL_STENCIL_REF                                        = $0B97
  #GL_STENCIL_WRITEMASK                                  = $0B98
  #GL_VIEWPORT                                           = $0BA2
  #GL_MODELVIEW_STACK_DEPTH                              = $0BA3
  #GL_PROJECTION_STACK_DEPTH                             = $0BA4
  #GL_TEXTURE_STACK_DEPTH                                = $0BA5
  #GL_MODELVIEW_MATRIX                                   = $0BA6
  #GL_PROJECTION_MATRIX                                  = $0BA7
  #GL_TEXTURE_MATRIX                                     = $0BA8
  #GL_DITHER                                             = $0BD0
  #GL_BLEND_DST                                          = $0BE0
  #GL_BLEND_SRC                                          = $0BE1
  #GL_BLEND                                              = $0BE2
  #GL_LOGIC_OP_MODE                                      = $0BF0
  #GL_COLOR_LOGIC_OP                                     = $0BF2
  #GL_DRAW_BUFFER                                        = $0C01
  #GL_READ_BUFFER                                        = $0C02
  #GL_SCISSOR_BOX                                        = $0C10
  #GL_SCISSOR_TEST                                       = $0C11
  #GL_COLOR_CLEAR_VALUE                                  = $0C22
  #GL_COLOR_WRITEMASK                                    = $0C23
  #GL_DOUBLEBUFFER                                       = $0C32
  #GL_STEREO                                             = $0C33
  #GL_LINE_SMOOTH_HINT                                   = $0C52
  #GL_POLYGON_SMOOTH_HINT                                = $0C53
  #GL_UNPACK_SWAP_BYTES                                  = $0CF0
  #GL_UNPACK_LSB_FIRST                                   = $0CF1
  #GL_UNPACK_ROW_LENGTH                                  = $0CF2
  #GL_UNPACK_SKIP_ROWS                                   = $0CF3
  #GL_UNPACK_SKIP_PIXELS                                 = $0CF4
  #GL_UNPACK_ALIGNMENT                                   = $0CF5
  #GL_PACK_SWAP_BYTES                                    = $0D00
  #GL_PACK_LSB_FIRST                                     = $0D01
  #GL_PACK_ROW_LENGTH                                    = $0D02
  #GL_PACK_SKIP_ROWS                                     = $0D03
  #GL_PACK_SKIP_PIXELS                                   = $0D04
  #GL_PACK_ALIGNMENT                                     = $0D05
  #GL_MAX_TEXTURE_SIZE                                   = $0D33
  #GL_MAX_VIEWPORT_DIMS                                  = $0D3A
  #GL_SUBPIXEL_BITS                                      = $0D50
  #GL_TEXTURE_1D                                         = $0DE0
  #GL_TEXTURE_2D                                         = $0DE1
  #GL_POLYGON_OFFSET_UNITS                               = $2A00
  #GL_POLYGON_OFFSET_POINT                               = $2A01
  #GL_POLYGON_OFFSET_LINE                                = $2A02
  #GL_POLYGON_OFFSET_FILL                                = $8037
  #GL_POLYGON_OFFSET_FACTOR                              = $8038
  #GL_TEXTURE_BINDING_1D                                 = $8068
  #GL_TEXTURE_BINDING_2D                                 = $8069
  ; GetTextureParameter
  #GL_TEXTURE_WIDTH                                      = $1000
  #GL_TEXTURE_HEIGHT                                     = $1001
  #GL_TEXTURE_INTERNAL_FORMAT                            = $1003
  #GL_TEXTURE_BORDER_COLOR                               = $1004
  #GL_TEXTURE_RED_SIZE                                   = $805C
  #GL_TEXTURE_GREEN_SIZE                                 = $805D
  #GL_TEXTURE_BLUE_SIZE                                  = $805E
  #GL_TEXTURE_ALPHA_SIZE                                 = $805F
  ; HintMode
  #GL_DONT_CARE                                          = $1100
  #GL_FASTEST                                            = $1101
  #GL_NICEST                                             = $1102
  ; DataType
  #GL_BYTE                                               = $1400
  #GL_UNSIGNED_BYTE                                      = $1401
  #GL_SHORT                                              = $1402
  #GL_UNSIGNED_SHORT                                     = $1403
  #GL_INT                                                = $1404
  #GL_UNSIGNED_INT                                       = $1405
  #GL_FLOAT                                              = $1406
  #GL_DOUBLE                                             = $140A
  
  ;  ListMode 
  #GL_COMPILE                                            = $1300
  #GL_COMPILE_AND_EXECUTE                                = $1301
  
  ; LogicOp
  #GL_CLEAR                                              = $1500
  #GL_AND                                                = $1501
  #GL_AND_REVERSE                                        = $1502
  #GL_COPY                                               = $1503
  #GL_AND_INVERTED                                       = $1504
  #GL_NOOP                                               = $1505
  #GL_XOR                                                = $1506
  #GL_OR                                                 = $1507
  #GL_NOR                                                = $1508
  #GL_EQUIV                                              = $1509
  #GL_INVERT                                             = $150A
  #GL_OR_REVERSE                                         = $150B
  #GL_COPY_INVERTED                                      = $150C
  #GL_OR_INVERTED                                        = $150D
  #GL_NAND                                               = $150E
  #GL_SET                                                = $150F
  ; MatrixMode (for gl3.h, FBO attachment type)
  #GL_MODELVIEW                                          = $1700
  #GL_PROJECTION                                         = $1701
  #GL_TEXTURE                                            = $1702
  ; PixelCopyType
  #GL_COLOR                                              = $1800
  #GL_DEPTH                                              = $1801
  #GL_STENCIL                                            = $1802
  ; PixelFormat
  #GL_STENCIL_INDEX                                      = $1901
  #GL_DEPTH_COMPONENT                                    = $1902
  #GL_RED                                                = $1903
  #GL_GREEN                                              = $1904
  #GL_BLUE                                               = $1905
  #GL_ALPHA                                              = $1906
  #GL_RGB                                                = $1907
  #GL_RGBA                                               = $1908
  ; PolygonMode
  #GL_POINT                                              = $1B00
  #GL_LINE                                               = $1B01
  #GL_FILL                                               = $1B02
  ; StencilOp
  #GL_KEEP                                               = $1E00
  #GL_REPLACE                                            = $1E01
  #GL_INCR                                               = $1E02
  #GL_DECR                                               = $1E03
  ; StringName
  #GL_VENDOR                                             = $1F00
  #GL_RENDERER                                           = $1F01
  #GL_VERSION                                            = $1F02
  #GL_EXTENSIONS                                         = $1F03
  ; TextureMagFilter
  #GL_NEAREST                                            = $2600
  #GL_LINEAR                                             = $2601
  ; TextureMinFilter
  #GL_NEAREST_MIPMAP_NEAREST                             = $2700
  #GL_LINEAR_MIPMAP_NEAREST                              = $2701
  #GL_NEAREST_MIPMAP_LINEAR                              = $2702
  #GL_LINEAR_MIPMAP_LINEAR                               = $2703
  ; TextureParameterName
  #GL_TEXTURE_MAG_FILTER                                 = $2800
  #GL_TEXTURE_MIN_FILTER                                 = $2801
  #GL_TEXTURE_WRAP_S                                     = $2802
  #GL_TEXTURE_WRAP_T                                     = $2803
  ; TextureTarget
  #GL_PROXY_TEXTURE_1D                                   = $8063
  #GL_PROXY_TEXTURE_2D                                   = $8064
  ; TextureWrapMode
  #GL_CLAMP                                              = $2900
  #GL_REPEAT                                             = $2901
  
  ;  TextureEnvParameter 
  #GL_TEXTURE_ENV_MODE                                   = $2200
  #GL_TEXTURE_ENV_COLOR                                  = $2201
  
  ;  TextureEnvTarget 
  #GL_TEXTURE_ENV                                        = $2300
  
  ;  TextureGenMode 
  #GL_EYE_LINEAR                                         = $2400
  #GL_OBJECT_LINEAR                                      = $2401
  #GL_SPHERE_MAP                                         = $2402
  
  ;  TextureGenParameter 
  #GL_TEXTURE_GEN_MODE                                   = $2500
  #GL_OBJECT_PLANE                                       = $2501
  #GL_EYE_PLANE                                          = $2502
  
  ; PixelInternalFormat
  #GL_R3_G3_B2                                           = $2A10
  #GL_RGB4                                               = $804F
  #GL_RGB5                                               = $8050
  #GL_RGB8                                               = $8051
  #GL_RGB10                                              = $8052
  #GL_RGB12                                              = $8053
  #GL_RGB16                                              = $8054
  #GL_RGBA2                                              = $8055
  #GL_RGBA4                                              = $8056
  #GL_RGB5_A1                                            = $8057
  #GL_RGBA8                                              = $8058
  #GL_RGB10_A2                                           = $8059
  #GL_RGBA12                                             = $805A
  #GL_RGBA16                                             = $805B
  ; Lighting
  #GL_LIGHTING                                           = $0B50
  #GL_LIGHTING_BIT                                       = $00000040
  ;  LightName 
  #GL_LIGHT0                                             = $4000
  #GL_LIGHT1                                             = $4001
  #GL_LIGHT2                                             = $4002
  #GL_LIGHT3                                             = $4003
  #GL_LIGHT4                                             = $4004
  #GL_LIGHT5                                             = $4005
  #GL_LIGHT6                                             = $4006
  #GL_LIGHT7                                             = $4007
  
  ;  LightParameter 
  #GL_AMBIENT                                            = $1200
  #GL_DIFFUSE                                            = $1201
  #GL_SPECULAR                                           = $1202
  #GL_POSITION                                           = $1203
  #GL_SPOT_DIRECTION                                     = $1204
  #GL_SPOT_EXPONENT                                      = $1205
  #GL_SPOT_CUTOFF                                        = $1206
  #GL_CONSTANT_ATTENUATION                               = $1207
    
  #GL_LINEAR_ATTENUATION                                 = $1208
  #GL_QUADRATIC_ATTENUATION                              = $1209
  
  ; RenderingMode 
  #GL_RENDER                                             = $1C00
  #GL_FEEDBACK                                           = $1C01
  #GL_SELECT                                             = $1C02
  
  ;  ShadingModel 
  #GL_FLAT                                               = $1D00
  #GL_SMOOTH                                             = $1D01
  
  
  #GL_BGR_EXT                                            = $80E0
  #GL_BGRA_EXT                                           = $80E1
  
  ;}
  ; ---[ GL_VERSION_1_2 ]-------------------------------------------------------
  ;{
  #GL_UNSIGNED_BYTE_3_3_2                                = $8032
  #GL_UNSIGNED_SHORT_4_4_4_4                             = $8033
  #GL_UNSIGNED_SHORT_5_5_5_1                             = $8034
  #GL_UNSIGNED_INT_8_8_8_8                               = $8035
  #GL_UNSIGNED_INT_10_10_10_2                            = $8036
  #GL_TEXTURE_BINDING_3D                                 = $806A
  #GL_PACK_SKIP_IMAGES                                   = $806B
  #GL_PACK_IMAGE_HEIGHT                                  = $806C
  #GL_UNPACK_SKIP_IMAGES                                 = $806D
  #GL_UNPACK_IMAGE_HEIGHT                                = $806E
  #GL_TEXTURE_3D                                         = $806F
  #GL_PROXY_TEXTURE_3D                                   = $8070
  #GL_TEXTURE_DEPTH                                      = $8071
  #GL_TEXTURE_WRAP_R                                     = $8072
  #GL_MAX_3D_TEXTURE_SIZE                                = $8073
  #GL_UNSIGNED_BYTE_2_3_3_REV                            = $8362
  #GL_UNSIGNED_SHORT_5_6_5                               = $8363
  #GL_UNSIGNED_SHORT_5_6_5_REV                           = $8364
  #GL_UNSIGNED_SHORT_4_4_4_4_REV                         = $8365
  #GL_UNSIGNED_SHORT_1_5_5_5_REV                         = $8366
  #GL_UNSIGNED_INT_8_8_8_8_REV                           = $8367
  #GL_UNSIGNED_INT_2_10_10_10_REV                        = $8368
  #GL_BGR                                                = $80E0
  #GL_BGRA                                               = $80E1
  #GL_MAX_ELEMENTS_VERTICES                              = $80E8
  #GL_MAX_ELEMENTS_INDICES                               = $80E9
  #GL_CLAMP_TO_EDGE                                      = $812F
  #GL_TEXTURE_MIN_LOD                                    = $813A
  #GL_TEXTURE_MAX_LOD                                    = $813B
  #GL_TEXTURE_BASE_LEVEL                                 = $813C
  #GL_TEXTURE_MAX_LEVEL                                  = $813D
  #GL_SMOOTH_POINT_SIZE_RANGE                            = $0B12
  #GL_SMOOTH_POINT_SIZE_GRANULARITY                      = $0B13
  #GL_SMOOTH_LINE_WIDTH_RANGE                            = $0B22
  #GL_SMOOTH_LINE_WIDTH_GRANULARITY                      = $0B23
  #GL_ALIASED_LINE_WIDTH_RANGE                           = $846E
  ; ...[ GL_ARB_imaging ].......................................................
  #GL_CONSTANT_COLOR                                     = $8001
  #GL_ONE_MINUS_CONSTANT_COLOR                           = $8002
  #GL_CONSTANT_ALPHA                                     = $8003
  #GL_ONE_MINUS_CONSTANT_ALPHA                           = $8004
  #GL_BLEND_COLOR                                        = $8005
  #GL_FUNC_ADD                                           = $8006
  #GL_MIN                                                = $8007
  #GL_MAX                                                = $8008
  #GL_BLEND_EQUATION                                     = $8009
  #GL_FUNC_SUBTRACT                                      = $800A
  #GL_FUNC_REVERSE_SUBTRACT                              = $800B
  ;}
  ; ---[ GL_VERSION_1_3 ]-------------------------------------------------------
  ;{
  #GL_TEXTURE0                                           = $84C0
  #GL_TEXTURE1                                           = $84C1
  #GL_TEXTURE2                                           = $84C2
  #GL_TEXTURE3                                           = $84C3
  #GL_TEXTURE4                                           = $84C4
  #GL_TEXTURE5                                           = $84C5
  #GL_TEXTURE6                                           = $84C6
  #GL_TEXTURE7                                           = $84C7
  #GL_TEXTURE8                                           = $84C8
  #GL_TEXTURE9                                           = $84C9
  #GL_TEXTURE10                                          = $84CA
  #GL_TEXTURE11                                          = $84CB
  #GL_TEXTURE12                                          = $84CC
  #GL_TEXTURE13                                          = $84CD
  #GL_TEXTURE14                                          = $84CE
  #GL_TEXTURE15                                          = $84CF
  #GL_TEXTURE16                                          = $84D0
  #GL_TEXTURE17                                          = $84D1
  #GL_TEXTURE18                                          = $84D2
  #GL_TEXTURE19                                          = $84D3
  #GL_TEXTURE20                                          = $84D4
  #GL_TEXTURE21                                          = $84D5
  #GL_TEXTURE22                                          = $84D6
  #GL_TEXTURE23                                          = $84D7
  #GL_TEXTURE24                                          = $84D8
  #GL_TEXTURE25                                          = $84D9
  #GL_TEXTURE26                                          = $84DA
  #GL_TEXTURE27                                          = $84DB
  #GL_TEXTURE28                                          = $84DC
  #GL_TEXTURE29                                          = $84DD
  #GL_TEXTURE30                                          = $84DE
  #GL_TEXTURE31                                          = $84DF
  #GL_ACTIVE_TEXTURE                                     = $84E0
  #GL_MULTISAMPLE                                        = $809D
  #GL_SAMPLE_ALPHA_TO_COVERAGE                           = $809E
  #GL_SAMPLE_ALPHA_TO_ONE                                = $809F
  #GL_SAMPLE_COVERAGE                                    = $80A0
  #GL_SAMPLE_BUFFERS                                     = $80A8
  #GL_SAMPLES                                            = $80A9
  #GL_SAMPLE_COVERAGE_VALUE                              = $80AA
  #GL_SAMPLE_COVERAGE_INVERT                             = $80AB
  #GL_TEXTURE_CUBE_MAP                                   = $8513
  #GL_TEXTURE_BINDING_CUBE_MAP                           = $8514
  #GL_TEXTURE_CUBE_MAP_POSITIVE_X                        = $8515
  #GL_TEXTURE_CUBE_MAP_NEGATIVE_X                        = $8516
  #GL_TEXTURE_CUBE_MAP_POSITIVE_Y                        = $8517
  #GL_TEXTURE_CUBE_MAP_NEGATIVE_Y                        = $8518
  #GL_TEXTURE_CUBE_MAP_POSITIVE_Z                        = $8519
  #GL_TEXTURE_CUBE_MAP_NEGATIVE_Z                        = $851A
  #GL_PROXY_TEXTURE_CUBE_MAP                             = $851B
  #GL_MAX_CUBE_MAP_TEXTURE_SIZE                          = $851C
  #GL_COMPRESSED_RGB                                     = $84ED
  #GL_COMPRESSED_RGBA                                    = $84EE
  #GL_TEXTURE_COMPRESSION_HINT                           = $84EF
  #GL_TEXTURE_COMPRESSED_IMAGE_SIZE                      = $86A0
  #GL_TEXTURE_COMPRESSED                                 = $86A1
  #GL_NUM_COMPRESSED_TEXTURE_FORMATS                     = $86A2
  #GL_COMPRESSED_TEXTURE_FORMATS                         = $86A3
  #GL_CLAMP_TO_BORDER                                    = $812D
  ;}
  ; ---[ GL_VERSION_1_4 ]-------------------------------------------------------
  ;{
  #GL_BLEND_DST_RGB                                      = $80C8
  #GL_BLEND_SRC_RGB                                      = $80C9
  #GL_BLEND_DST_ALPHA                                    = $80CA
  #GL_BLEND_SRC_ALPHA                                    = $80CB
  #GL_POINT_FADE_THRESHOLD_SIZE                          = $8128
  #GL_DEPTH_COMPONENT16                                  = $81A5
  #GL_DEPTH_COMPONENT24                                  = $81A6
  #GL_DEPTH_COMPONENT32                                  = $81A7
  #GL_MIRRORED_REPEAT                                    = $8370
  #GL_MAX_TEXTURE_LOD_BIAS                               = $84FD
  #GL_TEXTURE_LOD_BIAS                                   = $8501
  #GL_INCR_WRAP                                          = $8507
  #GL_DECR_WRAP                                          = $8508
  #GL_TEXTURE_DEPTH_SIZE                                 = $884A
  #GL_TEXTURE_COMPARE_MODE                               = $884C
  #GL_TEXTURE_COMPARE_FUNC                               = $884D
  ;}
  ; ---[ GL_VERSION_1_5 ]-------------------------------------------------------
  ;{
  #GL_BUFFER_SIZE                                        = $8764
  #GL_BUFFER_USAGE                                       = $8765
  #GL_QUERY_COUNTER_BITS                                 = $8864
  #GL_CURRENT_QUERY                                      = $8865
  #GL_QUERY_RESULT                                       = $8866
  #GL_QUERY_RESULT_AVAILABLE                             = $8867
  #GL_ARRAY_BUFFER                                       = $8892
  #GL_ELEMENT_ARRAY_BUFFER                               = $8893
  #GL_ARRAY_BUFFER_BINDING                               = $8894
  #GL_ELEMENT_ARRAY_BUFFER_BINDING                       = $8895
  #GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING                 = $889F
  #GL_READ_ONLY                                          = $88B8
  #GL_WRITE_ONLY                                         = $88B9
  #GL_READ_WRITE                                         = $88BA
  #GL_BUFFER_ACCESS                                      = $88BB
  #GL_BUFFER_MAPPED                                      = $88BC
  #GL_BUFFER_MAP_POINTER                                 = $88BD
  #GL_STREAM_DRAW                                        = $88E0
  #GL_STREAM_READ                                        = $88E1
  #GL_STREAM_COPY                                        = $88E2
  #GL_STATIC_DRAW                                        = $88E4
  #GL_STATIC_READ                                        = $88E5
  #GL_STATIC_COPY                                        = $88E6
  #GL_DYNAMIC_DRAW                                       = $88E8
  #GL_DYNAMIC_READ                                       = $88E9
  #GL_DYNAMIC_COPY                                       = $88EA
  #GL_SAMPLES_PASSED                                     = $8914
  ;}
  ; ---[ GL_VERSION_2_0 ]-------------------------------------------------------
  ;{
  #GL_BLEND_EQUATION_RGB                                 = $8009
  #GL_VERTEX_ATTRIB_ARRAY_ENABLED                        = $8622
  #GL_VERTEX_ATTRIB_ARRAY_SIZE                           = $8623
  #GL_VERTEX_ATTRIB_ARRAY_STRIDE                         = $8624
  #GL_VERTEX_ATTRIB_ARRAY_TYPE                           = $8625
  #GL_CURRENT_VERTEX_ATTRIB                              = $8626
  #GL_VERTEX_PROGRAM_POINT_SIZE                          = $8642
  #GL_VERTEX_ATTRIB_ARRAY_POINTER                        = $8645
  #GL_STENCIL_BACK_FUNC                                  = $8800
  #GL_STENCIL_BACK_FAIL                                  = $8801
  #GL_STENCIL_BACK_PASS_DEPTH_FAIL                       = $8802
  #GL_STENCIL_BACK_PASS_DEPTH_PASS                       = $8803
  #GL_MAX_DRAW_BUFFERS                                   = $8824
  #GL_DRAW_BUFFER0                                       = $8825
  #GL_DRAW_BUFFER1                                       = $8826
  #GL_DRAW_BUFFER2                                       = $8827
  #GL_DRAW_BUFFER3                                       = $8828
  #GL_DRAW_BUFFER4                                       = $8829
  #GL_DRAW_BUFFER5                                       = $882A
  #GL_DRAW_BUFFER6                                       = $882B
  #GL_DRAW_BUFFER7                                       = $882C
  #GL_DRAW_BUFFER8                                       = $882D
  #GL_DRAW_BUFFER9                                       = $882E
  #GL_DRAW_BUFFER10                                      = $882F
  #GL_DRAW_BUFFER11                                      = $8830
  #GL_DRAW_BUFFER12                                      = $8831
  #GL_DRAW_BUFFER13                                      = $8832
  #GL_DRAW_BUFFER14                                      = $8833
  #GL_DRAW_BUFFER15                                      = $8834
  #GL_BLEND_EQUATION_ALPHA                               = $883D
  #GL_MAX_VERTEX_ATTRIBS                                 = $8869
  #GL_VERTEX_ATTRIB_ARRAY_NORMALIZED                     = $886A
  #GL_MAX_TEXTURE_IMAGE_UNITS                            = $8872
  #GL_FRAGMENT_SHADER                                    = $8B30
  #GL_VERTEX_SHADER                                      = $8B31
  #GL_MAX_FRAGMENT_UNIFORM_COMPONENTS                    = $8B49
  #GL_MAX_VERTEX_UNIFORM_COMPONENTS                      = $8B4A
  #GL_MAX_VARYING_FLOATS                                 = $8B4B
  #GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS                     = $8B4C
  #GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS                   = $8B4D
  #GL_SHADER_TYPE                                        = $8B4F
  #GL_FLOAT_VEC2                                         = $8B50
  #GL_FLOAT_VEC3                                         = $8B51
  #GL_FLOAT_VEC4                                         = $8B52
  #GL_INT_VEC2                                           = $8B53
  #GL_INT_VEC3                                           = $8B54
  #GL_INT_VEC4                                           = $8B55
  #GL_BOOL                                               = $8B56
  #GL_BOOL_VEC2                                          = $8B57
  #GL_BOOL_VEC3                                          = $8B58
  #GL_BOOL_VEC4                                          = $8B59
  #GL_FLOAT_MAT2                                         = $8B5A
  #GL_FLOAT_MAT3                                         = $8B5B
  #GL_FLOAT_MAT4                                         = $8B5C
  #GL_SAMPLER_1D                                         = $8B5D
  #GL_SAMPLER_2D                                         = $8B5E
  #GL_SAMPLER_3D                                         = $8B5F
  #GL_SAMPLER_CUBE                                       = $8B60
  #GL_SAMPLER_1D_SHADOW                                  = $8B61
  #GL_SAMPLER_2D_SHADOW                                  = $8B62
  #GL_DELETE_STATUS                                      = $8B80
  #GL_COMPILE_STATUS                                     = $8B81
  #GL_LINK_STATUS                                        = $8B82
  #GL_VALIDATE_STATUS                                    = $8B83
  #GL_INFO_LOG_LENGTH                                    = $8B84
  #GL_ATTACHED_SHADERS                                   = $8B85
  #GL_ACTIVE_UNIFORMS                                    = $8B86
  #GL_ACTIVE_UNIFORM_MAX_LENGTH                          = $8B87
  #GL_SHADER_SOURCE_LENGTH                               = $8B88
  #GL_ACTIVE_ATTRIBUTES                                  = $8B89
  #GL_ACTIVE_ATTRIBUTE_MAX_LENGTH                        = $8B8A
  #GL_FRAGMENT_SHADER_DERIVATIVE_HINT                    = $8B8B
  #GL_SHADING_LANGUAGE_VERSION                           = $8B8C
  #GL_CURRENT_PROGRAM                                    = $8B8D
  #GL_POINT_SPRITE_COORD_ORIGIN                          = $8CA0
  #GL_LOWER_LEFT                                         = $8CA1
  #GL_UPPER_LEFT                                         = $8CA2
  #GL_STENCIL_BACK_REF                                   = $8CA3
  #GL_STENCIL_BACK_VALUE_MASK                            = $8CA4
  #GL_STENCIL_BACK_WRITEMASK                             = $8CA5
  ;}

  ; ---[ GL_VERSION_2_1 ]-------------------------------------------------------
  ;{
  #GL_PIXEL_PACK_BUFFER                                  = $88EB
  #GL_PIXEL_UNPACK_BUFFER                                = $88EC
  #GL_PIXEL_PACK_BUFFER_BINDING                          = $88ED
  #GL_PIXEL_UNPACK_BUFFER_BINDING                        = $88EF
  #GL_FLOAT_MAT2x3                                       = $8B65
  #GL_FLOAT_MAT2x4                                       = $8B66
  #GL_FLOAT_MAT3x2                                       = $8B67
  #GL_FLOAT_MAT3x4                                       = $8B68
  #GL_FLOAT_MAT4x2                                       = $8B69
  #GL_FLOAT_MAT4x3                                       = $8B6A
  #GL_SRGB                                               = $8C40
  #GL_SRGB8                                              = $8C41
  #GL_SRGB_ALPHA                                         = $8C42
  #GL_SRGB8_ALPHA8                                       = $8C43
  #GL_COMPRESSED_SRGB                                    = $8C48
  #GL_COMPRESSED_SRGB_ALPHA                              = $8C49
  ;}
  ; ---[ GL_VERSION_3_0 ]-------------------------------------------------------
  ;{
  #GL_COMPARE_REF_TO_TEXTURE                             = $884E
  #GL_CLIP_DISTANCE0                                     = $3000
  #GL_CLIP_DISTANCE1                                     = $3001
  #GL_CLIP_DISTANCE2                                     = $3002
  #GL_CLIP_DISTANCE3                                     = $3003
  #GL_CLIP_DISTANCE4                                     = $3004
  #GL_CLIP_DISTANCE5                                     = $3005
  #GL_CLIP_DISTANCE6                                     = $3006
  #GL_CLIP_DISTANCE7                                     = $3007
  #GL_MAX_CLIP_DISTANCES                                 = $0D32
  #GL_MAJOR_VERSION                                      = $821B
  #GL_MINOR_VERSION                                      = $821C
  #GL_NUM_EXTENSIONS                                     = $821D
  #GL_CONTEXT_FLAGS                                      = $821E
  #GL_DEPTH_BUFFER                                       = $8223
  #GL_STENCIL_BUFFER                                     = $8224
  #GL_COMPRESSED_RED                                     = $8225
  #GL_COMPRESSED_RG                                      = $8226
  #GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT                = $0001
  #GL_RGBA32F                                            = $8814
  #GL_RGB32F                                             = $8815
  #GL_RGBA16F                                            = $881A
  #GL_RGB16F                                             = $881B
  #GL_VERTEX_ATTRIB_ARRAY_INTEGER                        = $88FD
  #GL_MAX_ARRAY_TEXTURE_LAYERS                           = $88FF
  #GL_MIN_PROGRAM_TEXEL_OFFSET                           = $8904
  #GL_MAX_PROGRAM_TEXEL_OFFSET                           = $8905
  #GL_CLAMP_READ_COLOR                                   = $891C
  #GL_FIXED_ONLY                                         = $891D
  #GL_MAX_VARYING_COMPONENTS                             = $8B4B
  #GL_TEXTURE_1D_ARRAY                                   = $8C18
  #GL_PROXY_TEXTURE_1D_ARRAY                             = $8C19
  #GL_TEXTURE_2D_ARRAY                                   = $8C1A
  #GL_PROXY_TEXTURE_2D_ARRAY                             = $8C1B
  #GL_TEXTURE_BINDING_1D_ARRAY                           = $8C1C
  #GL_TEXTURE_BINDING_2D_ARRAY                           = $8C1D
  #GL_R11F_G11F_B10F                                     = $8C3A
  #GL_UNSIGNED_INT_10F_11F_11F_REV                       = $8C3B
  #GL_RGB9_E5                                            = $8C3D
  #GL_UNSIGNED_INT_5_9_9_9_REV                           = $8C3E
  #GL_TEXTURE_SHARED_SIZE                                = $8C3F
  #GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH              = $8C76
  #GL_TRANSFORM_FEEDBACK_BUFFER_MODE                     = $8C7F
  #GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS         = $8C80
  #GL_TRANSFORM_FEEDBACK_VARYINGS                        = $8C83
  #GL_TRANSFORM_FEEDBACK_BUFFER_START                    = $8C84
  #GL_TRANSFORM_FEEDBACK_BUFFER_SIZE                     = $8C85
  #GL_PRIMITIVES_GENERATED                               = $8C87
  #GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN              = $8C88
  #GL_RASTERIZER_DISCARD                                 = $8C89
  #GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS      = $8C8A
  #GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS            = $8C8B
  #GL_INTERLEAVED_ATTRIBS                                = $8C8C
  #GL_SEPARATE_ATTRIBS                                   = $8C8D
  #GL_TRANSFORM_FEEDBACK_BUFFER                          = $8C8E
  #GL_TRANSFORM_FEEDBACK_BUFFER_BINDING                  = $8C8F
  #GL_RGBA32UI                                           = $8D70
  #GL_RGB32UI                                            = $8D71
  #GL_RGBA16UI                                           = $8D76
  #GL_RGB16UI                                            = $8D77
  #GL_RGBA8UI                                            = $8D7C
  #GL_RGB8UI                                             = $8D7D
  #GL_RGBA32I                                            = $8D82
  #GL_RGB32I                                             = $8D83
  #GL_RGBA16I                                            = $8D88
  #GL_RGB16I                                             = $8D89
  #GL_RGBA8I                                             = $8D8E
  #GL_RGB8I                                              = $8D8F
  #GL_RED_INTEGER                                        = $8D94
  #GL_GREEN_INTEGER                                      = $8D95
  #GL_BLUE_INTEGER                                       = $8D96
  #GL_RGB_INTEGER                                        = $8D98
  #GL_RGBA_INTEGER                                       = $8D99
  #GL_BGR_INTEGER                                        = $8D9A
  #GL_BGRA_INTEGER                                       = $8D9B
  #GL_SAMPLER_1D_ARRAY                                   = $8DC0
  #GL_SAMPLER_2D_ARRAY                                   = $8DC1
  #GL_SAMPLER_1D_ARRAY_SHADOW                            = $8DC3
  #GL_SAMPLER_2D_ARRAY_SHADOW                            = $8DC4
  #GL_SAMPLER_CUBE_SHADOW                                = $8DC5
  #GL_UNSIGNED_INT_VEC2                                  = $8DC6
  #GL_UNSIGNED_INT_VEC3                                  = $8DC7
  #GL_UNSIGNED_INT_VEC4                                  = $8DC8
  #GL_INT_SAMPLER_1D                                     = $8DC9
  #GL_INT_SAMPLER_2D                                     = $8DCA
  #GL_INT_SAMPLER_3D                                     = $8DCB
  #GL_INT_SAMPLER_CUBE                                   = $8DCC
  #GL_INT_SAMPLER_1D_ARRAY                               = $8DCE
  #GL_INT_SAMPLER_2D_ARRAY                               = $8DCF
  #GL_UNSIGNED_INT_SAMPLER_1D                            = $8DD1
  #GL_UNSIGNED_INT_SAMPLER_2D                            = $8DD2
  #GL_UNSIGNED_INT_SAMPLER_3D                            = $8DD3
  #GL_UNSIGNED_INT_SAMPLER_CUBE                          = $8DD4
  #GL_UNSIGNED_INT_SAMPLER_1D_ARRAY                      = $8DD6
  #GL_UNSIGNED_INT_SAMPLER_2D_ARRAY                      = $8DD7
  #GL_QUERY_WAIT                                         = $8E13
  #GL_QUERY_NO_WAIT                                      = $8E14
  #GL_QUERY_BY_REGION_WAIT                               = $8E15
  #GL_QUERY_BY_REGION_NO_WAIT                            = $8E16
  #GL_BUFFER_ACCESS_FLAGS                                = $911F
  #GL_BUFFER_MAP_LENGTH                                  = $9120
  #GL_BUFFER_MAP_OFFSET                                  = $9121
  ;}
  ; ---[ GL_VERSION_3_1 ]-------------------------------------------------------
  ;{
  #GL_SAMPLER_2D_RECT                                    = $8B63
  #GL_SAMPLER_2D_RECT_SHADOW                             = $8B64
  #GL_SAMPLER_BUFFER                                     = $8DC2
  #GL_INT_SAMPLER_2D_RECT                                = $8DCD
  #GL_INT_SAMPLER_BUFFER                                 = $8DD0
  #GL_UNSIGNED_INT_SAMPLER_2D_RECT                       = $8DD5
  #GL_UNSIGNED_INT_SAMPLER_BUFFER                        = $8DD8
  #GL_TEXTURE_BUFFER                                     = $8C2A
  #GL_MAX_TEXTURE_BUFFER_SIZE                            = $8C2B
  #GL_TEXTURE_BINDING_BUFFER                             = $8C2C
  #GL_TEXTURE_BUFFER_DATA_STORE_BINDING                  = $8C2D
  #GL_TEXTURE_BUFFER_FORMAT                              = $8C2E
  #GL_TEXTURE_RECTANGLE                                  = $84F5
  #GL_TEXTURE_BINDING_RECTANGLE                          = $84F6
  #GL_PROXY_TEXTURE_RECTANGLE                            = $84F7
  #GL_MAX_RECTANGLE_TEXTURE_SIZE                         = $84F8
  #GL_RED_SNORM                                          = $8F90
  #GL_RG_SNORM                                           = $8F91
  #GL_RGB_SNORM                                          = $8F92
  #GL_RGBA_SNORM                                         = $8F93
  #GL_R8_SNORM                                           = $8F94
  #GL_RG8_SNORM                                          = $8F95
  #GL_RGB8_SNORM                                         = $8F96
  #GL_RGBA8_SNORM                                        = $8F97
  #GL_R16_SNORM                                          = $8F98
  #GL_RG16_SNORM                                         = $8F99
  #GL_RGB16_SNORM                                        = $8F9A
  #GL_RGBA16_SNORM                                       = $8F9B
  #GL_SIGNED_NORMALIZED                                  = $8F9C
  #GL_PRIMITIVE_RESTART                                  = $8F9D
  #GL_PRIMITIVE_RESTART_INDEX                            = $8F9E
  ;}
  ; ---[ GL_VERSION_3_2 ]-------------------------------------------------------
  ;{
  #GL_CONTEXT_CORE_PROFILE_BIT                           = $00000001
  #GL_CONTEXT_COMPATIBILITY_PROFILE_BIT                  = $00000002
  #GL_LINES_ADJACENCY                                    = $000A
  #GL_LINE_STRIP_ADJACENCY                               = $000B
  #GL_TRIANGLES_ADJACENCY                                = $000C
  #GL_TRIANGLE_STRIP_ADJACENCY                           = $000D
  #GL_PROGRAM_POINT_SIZE                                 = $8642
  #GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS                   = $8C29
  #GL_FRAMEBUFFER_ATTACHMENT_LAYERED                     = $8DA7
  #GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS               = $8DA8
  #GL_GEOMETRY_SHADER                                    = $8DD9
  #GL_GEOMETRY_VERTICES_OUT                              = $8916
  #GL_GEOMETRY_INPUT_TYPE                                = $8917
  #GL_GEOMETRY_OUTPUT_TYPE                               = $8918
  #GL_MAX_GEOMETRY_UNIFORM_COMPONENTS                    = $8DDF
  #GL_MAX_GEOMETRY_OUTPUT_VERTICES                       = $8DE0
  #GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS               = $8DE1
  #GL_MAX_VERTEX_OUTPUT_COMPONENTS                       = $9122
  #GL_MAX_GEOMETRY_INPUT_COMPONENTS                      = $9123
  #GL_MAX_GEOMETRY_OUTPUT_COMPONENTS                     = $9124
  #GL_MAX_FRAGMENT_INPUT_COMPONENTS                      = $9125
  #GL_CONTEXT_PROFILE_MASK                               = $9126
  ;}
  ; ---[ GL_VERSION_3_3 ]-------------------------------------------------------
  ;{
  #GL_VERTEX_ATTRIB_ARRAY_DIVISOR                        = $88FE
  ;}
  ; ---[ GL_VERSION_4_0 ]-------------------------------------------------------
  ;{
  #GL_SAMPLE_SHADING                                     = $8C36
  #GL_MIN_SAMPLE_SHADING_VALUE                           = $8C37
  #GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET                  = $8E5E
  #GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET                  = $8E5F
  #GL_TEXTURE_CUBE_MAP_ARRAY                             = $9009
  #GL_TEXTURE_BINDING_CUBE_MAP_ARRAY                     = $900A
  #GL_PROXY_TEXTURE_CUBE_MAP_ARRAY                       = $900B
  #GL_SAMPLER_CUBE_MAP_ARRAY                             = $900C
  #GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW                      = $900D
  #GL_INT_SAMPLER_CUBE_MAP_ARRAY                         = $900E
  #GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY                = $900F
  ;}
  ; ---[ GL_ARB_depth_buffer_float ]--------------------------------------------
  ;{
  #GL_DEPTH_COMPONENT32F                                 = $8CAC
  #GL_DEPTH32F_STENCIL8                                  = $8CAD
  #GL_FLOAT_32_UNSIGNED_INT_24_8_REV                     = $8DAD
  ;}
  ; ---[ GL_ARB_framebuffer_object ]--------------------------------------------
  ;{
  #GL_INVALID_FRAMEBUFFER_OPERATION                      = $0506
  #GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING              = $8210
  #GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE              = $8211
  #GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE                    = $8212
  #GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE                  = $8213
  #GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE                   = $8214
  #GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE                  = $8215
  #GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE                  = $8216
  #GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE                = $8217
  #GL_FRAMEBUFFER_DEFAULT                                = $8218
  #GL_FRAMEBUFFER_UNDEFINED                              = $8219
  #GL_DEPTH_STENCIL_ATTACHMENT                           = $821A
  #GL_MAX_RENDERBUFFER_SIZE                              = $84E8
  #GL_DEPTH_STENCIL                                      = $84F9
  #GL_UNSIGNED_INT_24_8                                  = $84FA
  #GL_DEPTH24_STENCIL8                                   = $88F0
  #GL_TEXTURE_STENCIL_SIZE                               = $88F1
  #GL_TEXTURE_RED_TYPE                                   = $8C10
  #GL_TEXTURE_GREEN_TYPE                                 = $8C11
  #GL_TEXTURE_BLUE_TYPE                                  = $8C12
  #GL_TEXTURE_ALPHA_TYPE                                 = $8C13
  #GL_TEXTURE_DEPTH_TYPE                                 = $8C16
  #GL_UNSIGNED_NORMALIZED                                = $8C17
  #GL_FRAMEBUFFER_BINDING                                = $8CA6
  #GL_DRAW_FRAMEBUFFER_BINDING                           = $8CA6 ; GL_FRAMEBUFFER_BINDING
  #GL_RENDERBUFFER_BINDING                               = $8CA7
  #GL_READ_FRAMEBUFFER                                   = $8CA8
  #GL_DRAW_FRAMEBUFFER                                   = $8CA9
  #GL_READ_FRAMEBUFFER_BINDING                           = $8CAA
  #GL_RENDERBUFFER_SAMPLES                               = $8CAB
  #GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE                 = $8CD0
  #GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME                 = $8CD1
  #GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL               = $8CD2
  #GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE       = $8CD3
  #GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER               = $8CD4
  #GL_FRAMEBUFFER_COMPLETE                               = $8CD5
  #GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT                  = $8CD6
  #GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT          = $8CD7
  #GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER                 = $8CDB
  #GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER                 = $8CDC
  #GL_FRAMEBUFFER_UNSUPPORTED                            = $8CDD
  #GL_MAX_COLOR_ATTACHMENTS                              = $8CDF
  #GL_COLOR_ATTACHMENT0                                  = $8CE0
  #GL_COLOR_ATTACHMENT1                                  = $8CE1
  #GL_COLOR_ATTACHMENT2                                  = $8CE2
  #GL_COLOR_ATTACHMENT3                                  = $8CE3
  #GL_COLOR_ATTACHMENT4                                  = $8CE4
  #GL_COLOR_ATTACHMENT5                                  = $8CE5
  #GL_COLOR_ATTACHMENT6                                  = $8CE6
  #GL_COLOR_ATTACHMENT7                                  = $8CE7
  #GL_COLOR_ATTACHMENT8                                  = $8CE8
  #GL_COLOR_ATTACHMENT9                                  = $8CE9
  #GL_COLOR_ATTACHMENT10                                 = $8CEA
  #GL_COLOR_ATTACHMENT11                                 = $8CEB
  #GL_COLOR_ATTACHMENT12                                 = $8CEC
  #GL_COLOR_ATTACHMENT13                                 = $8CED
  #GL_COLOR_ATTACHMENT14                                 = $8CEE
  #GL_COLOR_ATTACHMENT15                                 = $8CEF
  #GL_DEPTH_ATTACHMENT                                   = $8D00
  #GL_STENCIL_ATTACHMENT                                 = $8D20
  #GL_FRAMEBUFFER                                        = $8D40
  #GL_RENDERBUFFER                                       = $8D41
  #GL_RENDERBUFFER_WIDTH                                 = $8D42
  #GL_RENDERBUFFER_HEIGHT                                = $8D43
  #GL_RENDERBUFFER_INTERNAL_FORMAT                       = $8D44
  #GL_STENCIL_INDEX1                                     = $8D46
  #GL_STENCIL_INDEX4                                     = $8D47
  #GL_STENCIL_INDEX8                                     = $8D48
  #GL_STENCIL_INDEX16                                    = $8D49
  #GL_RENDERBUFFER_RED_SIZE                              = $8D50
  #GL_RENDERBUFFER_GREEN_SIZE                            = $8D51
  #GL_RENDERBUFFER_BLUE_SIZE                             = $8D52
  #GL_RENDERBUFFER_ALPHA_SIZE                            = $8D53
  #GL_RENDERBUFFER_DEPTH_SIZE                            = $8D54
  #GL_RENDERBUFFER_STENCIL_SIZE                          = $8D55
  #GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE                 = $8D56
  #GL_MAX_SAMPLES                                        = $8D57
  ;}
  ; ---[ GL_ARB_framebuffer_sRGB ]----------------------------------------------
  ;{
  #GL_FRAMEBUFFER_SRGB                                   = $8DB9
  ;}
  ; ---[ GL_ARB_half_float_vertex ]---------------------------------------------
  ;{
  #GL_HALF_FLOAT                                         = $140B
  ;}
  ; ---[ GL_ARB_map_buffer_range ]----------------------------------------------
  ;{
  #GL_MAP_READ_BIT                                       = $0001
  #GL_MAP_WRITE_BIT                                      = $0002
  #GL_MAP_INVALIDATE_RANGE_BIT                           = $0004
  #GL_MAP_INVALIDATE_BUFFER_BIT                          = $0008
  #GL_MAP_FLUSH_EXPLICIT_BIT                             = $0010
  #GL_MAP_UNSYNCHRONIZED_BIT                             = $0020
  ;}
  ; ---[ GL_ARB_texture_compression_rgtc ]--------------------------------------
  ;{
  #GL_COMPRESSED_RED_RGTC1                               = $8DBB
  #GL_COMPRESSED_SIGNED_RED_RGTC1                        = $8DBC
  #GL_COMPRESSED_RG_RGTC2                                = $8DBD
  #GL_COMPRESSED_SIGNED_RG_RGTC2                         = $8DBE
  ;}
  ; ---[ GL_ARB_texture_rg ]----------------------------------------------------
  ;{
  #GL_RG                                                 = $8227
  #GL_RG_INTEGER                                         = $8228
  #GL_R8                                                 = $8229
  #GL_R16                                                = $822A
  #GL_RG8                                                = $822B
  #GL_RG16                                               = $822C
  #GL_R16F                                               = $822D
  #GL_R32F                                               = $822E
  #GL_RG16F                                              = $822F
  #GL_RG32F                                              = $8230
  #GL_R8I                                                = $8231
  #GL_R8UI                                               = $8232
  #GL_R16I                                               = $8233
  #GL_R16UI                                              = $8234
  #GL_R32I                                               = $8235
  #GL_R32UI                                              = $8236
  #GL_RG8I                                               = $8237
  #GL_RG8UI                                              = $8238
  #GL_RG16I                                              = $8239
  #GL_RG16UI                                             = $823A
  #GL_RG32I                                              = $823B
  #GL_RG32UI                                             = $823C
  ;}
  ; ---[ GL_ARB_vertex_array_object ]-------------------------------------------
  ;{
  #GL_VERTEX_ARRAY_BINDING                               = $85B5
  ;}
  ; ---[ GL_ARB_uniform_buffer_object ]-----------------------------------------
  ;{
  #GL_UNIFORM_BUFFER                                     = $8A11
  #GL_UNIFORM_BUFFER_BINDING                             = $8A28
  #GL_UNIFORM_BUFFER_START                               = $8A29
  #GL_UNIFORM_BUFFER_SIZE                                = $8A2A
  #GL_MAX_VERTEX_UNIFORM_BLOCKS                          = $8A2B
  #GL_MAX_GEOMETRY_UNIFORM_BLOCKS                        = $8A2C
  #GL_MAX_FRAGMENT_UNIFORM_BLOCKS                        = $8A2D
  #GL_MAX_COMBINED_UNIFORM_BLOCKS                        = $8A2E
  #GL_MAX_UNIFORM_BUFFER_BINDINGS                        = $8A2F
  #GL_MAX_UNIFORM_BLOCK_SIZE                             = $8A30
  #GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS             = $8A31
  #GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS           = $8A32
  #GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS           = $8A33
  #GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT                    = $8A34
  #GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH               = $8A35
  #GL_ACTIVE_UNIFORM_BLOCKS                              = $8A36
  #GL_UNIFORM_TYPE                                       = $8A37
  #GL_UNIFORM_SIZE                                       = $8A38
  #GL_UNIFORM_NAME_LENGTH                                = $8A39
  #GL_UNIFORM_BLOCK_INDEX                                = $8A3A
  #GL_UNIFORM_OFFSET                                     = $8A3B
  #GL_UNIFORM_ARRAY_STRIDE                               = $8A3C
  #GL_UNIFORM_MATRIX_STRIDE                              = $8A3D
  #GL_UNIFORM_IS_ROW_MAJOR                               = $8A3E
  #GL_UNIFORM_BLOCK_BINDING                              = $8A3F
  #GL_UNIFORM_BLOCK_DATA_SIZE                            = $8A40
  #GL_UNIFORM_BLOCK_NAME_LENGTH                          = $8A41
  #GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS                      = $8A42
  #GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES               = $8A43
  #GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER          = $8A44
  #GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER        = $8A45
  #GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER        = $8A46
  #GL_INVALID_INDEX                                      = $FFFFFFFF
  ;}
  ; ---[ GL_ARB_copy_buffer ]---------------------------------------------------
  ;{
  #GL_COPY_READ_BUFFER                                   = $8F36
  #GL_COPY_WRITE_BUFFER                                  = $8F37
  ;}
  ; ---[ GL_ARB_depth_clamp ]---------------------------------------------------
  ;{
  #GL_DEPTH_CLAMP                                        = $864F
  #GL_DEPTH_TEXTURE_MODE                                 = $884B
  #GL_COMPARE_R_TO_TEXTURE                               = $884E
  ;}
  ; ---[ GL_ARB_provoking_vertex ]----------------------------------------------
  ;{
  #GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION           = $8E4C
  #GL_FIRST_VERTEX_CONVENTION                            = $8E4D
  #GL_LAST_VERTEX_CONVENTION                             = $8E4E
  #GL_PROVOKING_VERTEX                                   = $8E4F
  ;}
  ; ---[ GL_ARB_seamless_cube_map ]---------------------------------------------
  ;{
  #GL_TEXTURE_CUBE_MAP_SEAMLESS                          = $884F
  ;}
  ; ---[ GL_ARB_sync ]----------------------------------------------------------
  ;{
  #GL_MAX_SERVER_WAIT_TIMEOUT                            = $9111
  #GL_OBJECT_TYPE                                        = $9112
  #GL_SYNC_CONDITION                                     = $9113
  #GL_SYNC_STATUS                                        = $9114
  #GL_SYNC_FLAGS                                         = $9115
  #GL_SYNC_FENCE                                         = $9116
  #GL_SYNC_GPU_COMMANDS_COMPLETE                         = $9117
  #GL_UNSIGNALED                                         = $9118
  #GL_SIGNALED                                           = $9119
  #GL_ALREADY_SIGNALED                                   = $911A
  #GL_TIMEOUT_EXPIRED                                    = $911B
  #GL_CONDITION_SATISFIED                                = $911C
  #GL_WAIT_FAILED                                        = $911D
  #GL_SYNC_FLUSH_COMMANDS_BIT                            = $00000001
  #GL_TIMEOUT_IGNORED                                    = $FFFFFFFFFFFFFFFF
  ;}
  ; ---[ GL_ARB_texture_multisample ]-------------------------------------------
  ;{
  #GL_SAMPLE_POSITION                                    = $8E50
  #GL_SAMPLE_MASK                                        = $8E51
  #GL_SAMPLE_MASK_VALUE                                  = $8E52
  #GL_MAX_SAMPLE_MASK_WORDS                              = $8E59
  #GL_TEXTURE_2D_MULTISAMPLE                             = $9100
  #GL_PROXY_TEXTURE_2D_MULTISAMPLE                       = $9101
  #GL_TEXTURE_2D_MULTISAMPLE_ARRAY                       = $9102
  #GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY                 = $9103
  #GL_TEXTURE_BINDING_2D_MULTISAMPLE                     = $9104
  #GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY               = $9105
  #GL_TEXTURE_SAMPLES                                    = $9106
  #GL_TEXTURE_FIXED_SAMPLE_LOCATIONS                     = $9107
  #GL_SAMPLER_2D_MULTISAMPLE                             = $9108
  #GL_INT_SAMPLER_2D_MULTISAMPLE                         = $9109
  #GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE                = $910A
  #GL_SAMPLER_2D_MULTISAMPLE_ARRAY                       = $910B
  #GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY                   = $910C
  #GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY          = $910D
  #GL_MAX_COLOR_TEXTURE_SAMPLES                          = $910E
  #GL_MAX_DEPTH_TEXTURE_SAMPLES                          = $910F
  #GL_MAX_INTEGER_SAMPLES                                = $9110
  ;}
  ; ---[ GL_ARB_sample_shading ]------------------------------------------------
  ;{
  ; in OpenGL 4.0
  #GL_SAMPLE_SHADING_ARB                                 = $8C36
  #GL_MIN_SAMPLE_SHADING_VALUE_ARB                       = $8C37
  ;}
  ; ---[ GL_ARB_texture_cube_map_array ]----------------------------------------
  ;{
  ; in OpenGL 4.0
  #GL_TEXTURE_CUBE_MAP_ARRAY_ARB                         = $9009
  #GL_TEXTURE_BINDING_CUBE_MAP_ARRAY_ARB                 = $900A
  #GL_PROXY_TEXTURE_CUBE_MAP_ARRAY_ARB                   = $900B
  #GL_SAMPLER_CUBE_MAP_ARRAY_ARB                         = $900C
  #GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW_ARB                  = $900D
  #GL_INT_SAMPLER_CUBE_MAP_ARRAY_ARB                     = $900E
  #GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY_ARB            = $900F
  ;}
  ; ---[ GL_ARB_texture_gather ]------------------------------------------------
  ;{
  ; in OpenGL 4.0
  #GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET_ARB              = $8E5E
  #GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET_ARB              = $8E5F
  ;}
  ; ---[ GL_ARB_shading_language_include ]--------------------------------------
  ;{
  #GL_SHADER_INCLUDE_ARB                                 = $8DAE
  #GL_NAMED_STRING_LENGTH_ARB                            = $8DE9
  #GL_NAMED_STRING_TYPE_ARB                              = $8DEA
  ;}
  ; ---[ GL_ARB_texture_compression_bptc ]--------------------------------------
  ;{
  #GL_COMPRESSED_RGBA_BPTC_UNORM_ARB                     = $8E8C
  #GL_COMPRESSED_SRGB_ALPHA_BPTC_UNORM_ARB               = $8E8D
  #GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT_ARB               = $8E8E
  #GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_ARB             = $8E8F
  ;}
  ; ---[ GL_ARB_blend_func_extended ]-------------------------------------------
  ;{
  #GL_SRC1_COLOR                                         = $88F9
  #GL_ONE_MINUS_SRC1_COLOR                               = $88FA
  #GL_ONE_MINUS_SRC1_ALPHA                               = $88FB
  #GL_MAX_DUAL_SOURCE_DRAW_BUFFERS                       = $88FC
  ;}
  ; ---[ GL_ARB_occlusion_query2 ]----------------------------------------------
  ;{
  #GL_ANY_SAMPLES_PASSED                                 = $8C2F
  ;}
  ; ---[ GL_ARB_sampler_objects ]-----------------------------------------------
  ;{
  #GL_SAMPLER_BINDING                                    = $8919
  ;}
  ; ---[ GL_ARB_texture_rgb10_a2ui ]--------------------------------------------
  ;{
  #GL_RGB10_A2UI                                         = $906F
  ;}
  ; ---[ GL_ARB_texture_swizzle ]-----------------------------------------------
  ;{
  #GL_TEXTURE_SWIZZLE_R                                  = $8E42
  #GL_TEXTURE_SWIZZLE_G                                  = $8E43
  #GL_TEXTURE_SWIZZLE_B                                  = $8E44
  #GL_TEXTURE_SWIZZLE_A                                  = $8E45
  #GL_TEXTURE_SWIZZLE_RGBA                               = $8E46
  ;}
  ; ---[ GL_ARB_timer_query ]---------------------------------------------------
  ;{
  #GL_TIME_ELAPSED                                       = $88BF
  #GL_TIMESTAMP                                          = $8E28
  ;}
  ; ---[ GL_ARB_vertex_type_2_10_10_10_rev ]------------------------------------
  ;{
  #GL_INT_2_10_10_10_REV                                 = $8D9F
  ;}
  ; ---[ GL_ARB_draw_indirect ]-------------------------------------------------
  ;{
  #GL_DRAW_INDIRECT_BUFFER                               = $8F3F
  #GL_DRAW_INDIRECT_BUFFER_BINDING                       = $8F43
  ;}
  ; ---[ GL_ARB_gpu_shader5 ]---------------------------------------------------
  ;{
  #GL_GEOMETRY_SHADER_INVOCATIONS                        = $887F
  #GL_MAX_GEOMETRY_SHADER_INVOCATIONS                    = $8E5A
  #GL_MIN_FRAGMENT_INTERPOLATION_OFFSET                  = $8E5B
  #GL_MAX_FRAGMENT_INTERPOLATION_OFFSET                  = $8E5C
  #GL_FRAGMENT_INTERPOLATION_OFFSET_BITS                 = $8E5D
  ;}
  ; ---[ GL_ARB_gpu_shader_fp64 ]-----------------------------------------------
  ;{
  #GL_DOUBLE_VEC2                                        = $8FFC
  #GL_DOUBLE_VEC3                                        = $8FFD
  #GL_DOUBLE_VEC4                                        = $8FFE
  #GL_DOUBLE_MAT2                                        = $8F46
  #GL_DOUBLE_MAT3                                        = $8F47
  #GL_DOUBLE_MAT4                                        = $8F48
  #GL_DOUBLE_MAT2x3                                      = $8F49
  #GL_DOUBLE_MAT2x4                                      = $8F4A
  #GL_DOUBLE_MAT3x2                                      = $8F4B
  #GL_DOUBLE_MAT3x4                                      = $8F4C
  #GL_DOUBLE_MAT4x2                                      = $8F4D
  #GL_DOUBLE_MAT4x3                                      = $8F4E
  ;}
  ; ---[ GL_ARB_shader_subroutine ]---------------------------------------------
  ;{
  #GL_ACTIVE_SUBROUTINES                                 = $8DE5
  #GL_ACTIVE_SUBROUTINE_UNIFORMS                         = $8DE6
  #GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS                = $8E47
  #GL_ACTIVE_SUBROUTINE_MAX_LENGTH                       = $8E48
  #GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH               = $8E49
  #GL_MAX_SUBROUTINES                                    = $8DE7
  #GL_MAX_SUBROUTINE_UNIFORM_LOCATIONS                   = $8DE8
  #GL_NUM_COMPATIBLE_SUBROUTINES                         = $8E4A
  #GL_COMPATIBLE_SUBROUTINES                             = $8E4B
  ;}
  ; ---[ GL_ARB_tessellation_shader ]-------------------------------------------
  ;{
  #GL_PATCHES                                            = $000E
  #GL_PATCH_VERTICES                                     = $8E72
  #GL_PATCH_DEFAULT_INNER_LEVEL                          = $8E73
  #GL_PATCH_DEFAULT_OUTER_LEVEL                          = $8E74
  #GL_TESS_CONTROL_OUTPUT_VERTICES                       = $8E75
  #GL_TESS_GEN_MODE                                      = $8E76
  #GL_TESS_GEN_SPACING                                   = $8E77
  #GL_TESS_GEN_VERTEX_ORDER                              = $8E78
  #GL_TESS_GEN_POINT_MODE                                = $8E79
  #GL_ISOLINES                                           = $8E7A
  #GL_FRACTIONAL_ODD                                     = $8E7B
  #GL_FRACTIONAL_EVEN                                    = $8E7C
  #GL_MAX_PATCH_VERTICES                                 = $8E7D
  #GL_MAX_TESS_GEN_LEVEL                                 = $8E7E
  #GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS                = $8E7F
  #GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS             = $8E80
  #GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS               = $8E81
  #GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS            = $8E82
  #GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS                 = $8E83
  #GL_MAX_TESS_PATCH_COMPONENTS                          = $8E84
  #GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS           = $8E85
  #GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS              = $8E86
  #GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS                    = $8E89
  #GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS                 = $8E8A
  #GL_MAX_TESS_CONTROL_INPUT_COMPONENTS                  = $886C
  #GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS               = $886D
  #GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS       = $8E1E
  #GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS    = $8E1F
  #GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER    = $84F0
  #GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER = $84F1
  #GL_TESS_EVALUATION_SHADER                             = $8E87
  #GL_TESS_CONTROL_SHADER                                = $8E88
  ;}
  ; ---[ GL_ARB_transform_feedback2 ]-------------------------------------------
  ;{
  #GL_TRANSFORM_FEEDBACK                                 = $8E22
  #GL_TRANSFORM_FEEDBACK_BUFFER_PAUSED                   = $8E23
  #GL_TRANSFORM_FEEDBACK_BUFFER_ACTIVE                   = $8E24
  #GL_TRANSFORM_FEEDBACK_BINDING                         = $8E25
  ;}
  ; ---[ GL_ARB_transform_feedback3 ]-------------------------------------------
  ;{
  #GL_MAX_TRANSFORM_FEEDBACK_BUFFERS                     = $8E70
  #GL_MAX_VERTEX_STREAMS                                 = $8E71
  ;}
  ; ---[ GL_ARB_ES2_compatibility ]---------------------------------------------
  ;{
  #GL_FIXED                                              = $140C
  #GL_IMPLEMENTATION_COLOR_READ_TYPE                     = $8B9A
  #GL_IMPLEMENTATION_COLOR_READ_FORMAT                   = $8B9B
  #GL_LOW_FLOAT                                          = $8DF0
  #GL_MEDIUM_FLOAT                                       = $8DF1
  #GL_HIGH_FLOAT                                         = $8DF2
  #GL_LOW_INT                                            = $8DF3
  #GL_MEDIUM_INT                                         = $8DF4
  #GL_HIGH_INT                                           = $8DF5
  #GL_SHADER_COMPILER                                    = $8DFA
  #GL_NUM_SHADER_BINARY_FORMATS                          = $8DF9
  #GL_MAX_VERTEX_UNIFORM_VECTORS                         = $8DFB
  #GL_MAX_VARYING_VECTORS                                = $8DFC
  #GL_MAX_FRAGMENT_UNIFORM_VECTORS                       = $8DFD
  ;}
  ; ---[ GL_ARB_get_program_binary ]--------------------------------------------
  ;{
  #GL_PROGRAM_BINARY_RETRIEVABLE_HINT                    = $8257
  #GL_PROGRAM_BINARY_LENGTH                              = $8741
  #GL_NUM_PROGRAM_BINARY_FORMATS                         = $87FE
  #GL_PROGRAM_BINARY_FORMATS                             = $87FF
  ;}
  ; ---[ GL_ARB_separate_shader_objects ]---------------------------------------
  ;{
  #GL_VERTEX_SHADER_BIT                                  = $00000001
  #GL_FRAGMENT_SHADER_BIT                                = $00000002
  #GL_GEOMETRY_SHADER_BIT                                = $00000004
  #GL_TESS_CONTROL_SHADER_BIT                            = $00000008
  #GL_TESS_EVALUATION_SHADER_BIT                         = $00000010
  #GL_ALL_SHADER_BITS                                    = $FFFFFFFF
  #GL_PROGRAM_SEPARABLE                                  = $8258
  #GL_ACTIVE_PROGRAM                                     = $8259
  #GL_PROGRAM_PIPELINE_BINDING                           = $825A
  ;}
  ; ---[ GL_ARB_viewport_array ]------------------------------------------------
  ;{
  #GL_MAX_VIEWPORTS                                      = $825B
  #GL_VIEWPORT_SUBPIXEL_BITS                             = $825C
  #GL_VIEWPORT_BOUNDS_RANGE                              = $825D
  #GL_LAYER_PROVOKING_VERTEX                             = $825E
  #GL_VIEWPORT_INDEX_PROVOKING_VERTEX                    = $825F
  #GL_UNDEFINED_VERTEX                                   = $8260
  ;}
  ; ---[ GL_ARB_cl_event ]------------------------------------------------------
  ;{
  #GL_SYNC_CL_EVENT_ARB                                  = $8240
  #GL_SYNC_CL_EVENT_COMPLETE_ARB                         = $8241
  ;}
  ; ---[ GL_ARB_debug_output ]--------------------------------------------------
  ;{
  #GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB                       = $8242
  #GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH_ARB               = $8243
  #GL_DEBUG_CALLBACK_FUNCTION_ARB                        = $8244
  #GL_DEBUG_CALLBACK_USER_PARAM_ARB                      = $8245
  #GL_DEBUG_SOURCE_API_ARB                               = $8246
  #GL_DEBUG_SOURCE_WINDOW_SYSTEM_ARB                     = $8247
  #GL_DEBUG_SOURCE_SHADER_COMPILER_ARB                   = $8248
  #GL_DEBUG_SOURCE_THIRD_PARTY_ARB                       = $8249
  #GL_DEBUG_SOURCE_APPLICATION_ARB                       = $824A
  #GL_DEBUG_SOURCE_OTHER_ARB                             = $824B
  #GL_DEBUG_TYPE_ERROR_ARB                               = $824C
  #GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_ARB                 = $824D
  #GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_ARB                  = $824E
  #GL_DEBUG_TYPE_PORTABILITY_ARB                         = $824F
  #GL_DEBUG_TYPE_PERFORMANCE_ARB                         = $8250
  #GL_DEBUG_TYPE_OTHER_ARB                               = $8251
  #GL_MAX_DEBUG_MESSAGE_LENGTH_ARB                       = $9143
  #GL_MAX_DEBUG_LOGGED_MESSAGES_ARB                      = $9144
  #GL_DEBUG_LOGGED_MESSAGES_ARB                          = $9145
  #GL_DEBUG_SEVERITY_HIGH_ARB                            = $9146
  #GL_DEBUG_SEVERITY_MEDIUM_ARB                          = $9147
  #GL_DEBUG_SEVERITY_LOW_ARB                             = $9148
  ;}
  ; ---[ GL_ARB_robustness ]----------------------------------------------------
  ;{
  #GL_CONTEXT_FLAG_ROBUST_ACCESS_BIT_ARB                 = $00000004
  #GL_LOSE_CONTEXT_ON_RESET_ARB                          = $8252
  #GL_GUILTY_CONTEXT_RESET_ARB                           = $8253
  #GL_INNOCENT_CONTEXT_RESET_ARB                         = $8254
  #GL_UNKNOWN_CONTEXT_RESET_ARB                          = $8255
  #GL_RESET_NOTIFICATION_STRATEGY_ARB                    = $8256
  #GL_NO_RESET_NOTIFICATION_ARB                          = $8261
  ;}
  ;}

  
  ; ============================================================================
  ;  IMPORT OpenGL API
  ; ============================================================================
  ;{
  CompilerSelect #PB_Compiler_OS
    ;___________________________________________________________________________
    ;  Windows
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Windows
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "opengl32.lib"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ImportC "opengl32.lib"
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Linux
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_Linux
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC ""
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        ;CompilerError "*> raafal x32 on Linux is not supported at this time."
        ImportC ""
      CompilerEndIf
    ;___________________________________________________________________________
    ;  Mac OS/X
    ;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    CompilerCase #PB_OS_MacOS
      ; ---[ x64 ]--------------------------------------------------------------
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        ImportC "/System/Library/Frameworks/OpenGL.framework/OpenGL"
      ; ---[ x32 ]--------------------------------------------------------------
      CompilerElse
        CompilerError "*> raafal x32 on Mac OS/X is not supported at this time."
        ImportC ""
      CompilerEndIf
  CompilerEndSelect
  glMatrixMode                        ( mode.GLenum )
  glOrtho                             (left.GLdouble,right.GLdouble,bottom.GLdouble,top.GLdouble,near.GLdouble,far.GLdouble)
  glLoadIdentity                      ()
  glRotatef                           (angle.GLfloat,x.GLfloat,y.GLfloat,z.GLfloat)
  glTranslatef                        (x.GLfloat,y.GLfloat,z.GLfloat)
  glColor3f                           (r.GLfloat,g.GLfloat,b.GLfloat)
  glDrawPixels                        ( width.GLsizei, height.GLsizei, format.GLenum, type.GLenum, *data_ )
  glCullFace                          ( mode.GLenum )
  glFrontFace                         ( mode.GLenum )
  glHint                              ( target.GLenum, mode.GLenum )
  glLineWidth                         ( width.GLfloat )
  glPointSize                         ( size.GLfloat )
  glPolygonMode                       ( face.GLenum, mode.GLenum )
  glScissor                           ( x.GLint, y.GLint, width.GLsizei, height.GLsizei )
  glTexParameterf                     ( target.GLenum, pname.GLenum, param.GLfloat )
  glTexParameterfv                    ( target.GLenum, pname.GLenum, params.GLfloat )
  glTexParameteri                     ( target.GLenum, pname.GLenum, param.GLint )
  glTexParameteriv                    ( target.GLenum, pname.GLenum, params.GLint )
  glTexImage1D                        ( target.GLenum, level.GLint, internalformat.GLint, width.GLsizei, border.GLint, format.GLenum, type.GLenum, *pixels )
  glTexImage2D                        ( target.GLenum, level.GLint, internalformat.GLint, width.GLsizei, height.GLsizei, border.GLint, format.GLenum, type.GLenum, *pixels )
  glDrawBuffer                        ( mode.GLenum )
  glClear                             ( mask.GLbitfield )
  glClearColor                        ( red.GLclampf, green.GLclampf, blue.GLclampf, alpha.GLclampf )
  glClearStencil                      ( s.GLint )
  glClearDepth                        ( depth.GLclampd )
  glStencilMask                       ( mask.GLuint )
  glColorMask                         ( red.GLboolean, green.GLboolean, blue.GLboolean, alpha.GLboolean )
  glDepthMask                         ( flag.GLboolean )
  glDisable                           ( cap.GLenum )
  glEnable                            ( cap.GLenum )
  glBegin                             ( cap.GLenum )
  glEnd                               ()
  glFinish                            ( void )
  glFlush                             ( void )
  glBlendFunc                         ( sfactor.GLenum, dfactor.GLenum )
  glLogicOp                           ( opcode.GLenum )
  glStencilFunc                       ( func.GLenum, ref.GLint, mask.GLuint )
  glStencilOp                         ( fail.GLenum, zfail.GLenum, zpass.GLenum )
  glDepthFunc                         ( func.GLenum )
  glPixelStoref                       ( pname.GLenum, param.GLfloat )
  glPixelStorei                       ( pname.GLenum, param.GLint )
  glReadBuffer                        ( mode.GLenum )
  glReadPixels                        ( x.GLint, y.GLint, width.GLsizei, height.GLsizei, format.GLenum, type.GLenum, *pixels )
  glGetBooleanv                       ( pname.GLenum, *params )
  glGetDoublev                        ( pname.GLenum, *params )
  glGetError               .GLenum    (  )
  glGetFloatv                         ( pname.GLenum, *params )
  glGetIntegerv                       ( pname.GLenum, *params )
  glGetString              .i         ( name.GLenum ) ; return const GLubyte*
  glGetTexImage                       ( target.GLenum, level.GLint, format.GLenum, type.GLenum, *pixels )
  glGetTexParameterfv                 ( target.GLenum, pname.GLenum, params.GLfloat )
  glGetTexParameteriv                 ( target.GLenum, pname.GLenum, params.GLint )
  glGetTexLevelParameterfv            ( target.GLenum, level.GLint, pname.GLenum, params.GLfloat )
  glGetTexLevelParameteriv            ( target.GLenum, level.GLint, pname.GLenum, params.GLint )
  glIsEnabled              .GLboolean ( cap.GLenum )
  glDepthRange                        ( near.GLclampd, far.GLclampd )
  glViewport                          ( x.GLint, y.GLint, width.GLsizei, height.GLsizei )
  glNormal3f                          ( x.GLfloat, y.GLfloat, z.GLfloat )
  glVertex3f                          ( x.GLfloat, y.GLfloat, z.GLfloat )
  glGenTextures                       ( s.GLsizei, *textures  )
  glDeleteTextures                    ( n.GLsizei, *textures )
  glGenLists                          ( s.GLsizei )
  glDeleteLists                       ( l.GLuint,s.GLsizei)
  
  ; Shade
  glShadeModel                        ( mode.GLenum )
  glDrawElements                      ( mode.GLenum, count.GLsizei,type.GLenum, *indices )
  
  ;-----------[ Deprecated !!]---------------------------
  ; Matrix
  glPushMatrix                        ()
  glPopMatrix                         ()
  glMultMatrixf                       ( *matrix )
  glLoadMatrixf                        ( *matrix )
  glBindTexture                       ( mode.GLenum, id.GLint )
  
  ; ---[Selection (deprecated in GL3.++) ]----------------------
  glSelectBuffer                      ( s.GLsizei, *buffer )
  glRenderMode             .GLint     ( mode.GLenum )
  glInitNames                         ()
  glPushName                          ( name.GLuint )
  glLoadName                          ( name.GLuint ) 
  glPopName                 .GLuint    ()
  
  
  EndImport
  ;}
  
;   CompilerSelect #PB_Compiler_OS
;     CompilerCase #PB_OS_Windows
;       ; glu import
;       Import "glu32.lib"
;     CompilerCase #PB_OS_Linux
;       Import "-lGL"
;     CompilerCase #PB_OS_MacOS
;       Import "-lGL"
;   CompilerEndSelect
;     
;     gluPickMatrix(x.GLdouble,y.GLdouble,delX.GLdouble,delY.GLdouble,*viewport)
;     gluPerspective(fovy.GLdouble,aspect.GLdouble,zNear.GLdouble,zFar.GLdouble)
;     gluLookAt(eyeX.GLdouble,eyeY.GLdouble,eyeZ.GLdouble,centerX.GLdouble,centerY.GLdouble,centerZ.GLdouble,upX.GLdouble,upY.GLdouble,upZ.GLdouble)
;     gluUnProject(winX.GLdouble,winY.GLdouble,winZ.GLdouble,*model,*proj,*view,*objX,*objY,*objZ)
;   EndImport
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; ** Attribute names For [NSOpenGLPixelFormat initWithAttributes]
    ; ** And [NSOpenGLPixelFormat getValues:forAttribute:forVirtualScreen].
    Enumeration ;{
      #NSOpenGLPFAAllRenderers       =   1 ;,   /* choose from all available renderers          */
      #NSOpenGLPFATripleBuffer       =   3 ;,   /* choose a triple buffered pixel format        */
      #NSOpenGLPFADoubleBuffer       =   5 ;,   /* choose a double buffered pixel format        */
      #NSOpenGLPFAAuxBuffers         =   7 ;,   /* number of aux buffers                        */
      #NSOpenGLPFAColorSize          =   8 ;,   /* number of color buffer bits                  */
      #NSOpenGLPFAAlphaSize          =  11 ;,   /* number of alpha component bits               */
      #NSOpenGLPFADepthSize          =  12 ;,   /* number of depth buffer bits                  */
      #NSOpenGLPFAStencilSize        =  13 ;,   /* number of stencil buffer bits                */
      #NSOpenGLPFAAccumSize          =  14 ;,   /* number of accum buffer bits                  */
      #NSOpenGLPFAMinimumPolicy      =  51 ;,   /* never choose smaller buffers than requested  */
      #NSOpenGLPFAMaximumPolicy      =  52 ;,   /* choose largest buffers of type requested     */
      #NSOpenGLPFASampleBuffers      =  55 ;,   /* number of multi sample buffers               */
      #NSOpenGLPFASamples            =  56 ;,   /* number of samples per multi sample buffer    */
      #NSOpenGLPFAAuxDepthStencil    =  57 ;,   /* each aux buffer has its own depth stencil    */
      #NSOpenGLPFAColorFloat         =  58 ;,   /* color buffers store floating point pixels    */
      #NSOpenGLPFAMultisample        =  59 ;,   /* choose multisampling                         */
      #NSOpenGLPFASupersample        =  60 ;,   /* choose supersampling                         */
      #NSOpenGLPFASampleAlpha        =  61 ;,   /* request alpha filtering                      */
      #NSOpenGLPFARendererID         =  70 ;,   /* request renderer by ID                       */
      #NSOpenGLPFANoRecovery         =  72 ;,   /* disable all failure recovery systems         */
      #NSOpenGLPFAAccelerated        =  73 ;,   /* choose a hardware accelerated renderer       */
      #NSOpenGLPFAClosestPolicy      =  74 ;,   /* choose the closest color buffer To request   */
      #NSOpenGLPFABackingStore       =  76 ;,   /* back buffer contents are valid after Swap    */
      #NSOpenGLPFAScreenMask         =  84 ;,   /* bit mask of supported physical screens       */
      #NSOpenGLPFAAllowOfflineRenderers = 96 ;, /* allow use of offline renderers               */
      #NSOpenGLPFAAcceleratedCompute =  97 ;,   /* choose a hardware accelerated compute device */
      #NSOpenGLPFAVirtualScreenCount = 128 ;,   /* number of virtual screens in this format     */
      #NSOpenGLPFAOpenGLProfile      =  99 ;,   /* specify an OpenGL Profile To use             */
    EndEnumeration ;}
    
    ;/* NSOpenGLPFAOpenGLProfile values */
    Enumeration ;{
      #NSOpenGLProfileVersionLegacy  = $1000 ;,   /* choose a Legacy/Pre-OpenGL 3.0 Implementation */
      #NSOpenGLProfileVersion3_2Core = $3200 ;,   /* choose an OpenGL 3.2 Core Implementation      */
      #NSOpenGLProfileVersion4_1Core = $4100 ;    /* choose an OpenGL 4.1 Core Implementation      */
    EndEnumeration    
    
    ; ...[ array9_t ]......................................................
    Structure array10_t
      v.l[10]
    EndStructure
    ; ...[ NSOpenGLPixelFormatAttribute ]...................................
    Macro NSOpenGLPixelFormatAttribute
      array10_t
    EndMacro
    ; ...[ NSOpenGLPixelFormat ]............................................
    Macro NSOpenGLPixelFormat
      i
    EndMacro
    ; ...[ NSOpenGLContext ]................................................
    Macro NSOpenGLContext
      i
    EndMacro;}
  CompilerEndIf

EndDeclareModule

Module OpenGL
EndModule


; 
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 1531
; FirstLine = 1469
; Folding = ------------------
; EnableXP
; EnableUnicode