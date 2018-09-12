


Structure InterfaceBuilder_t
  name.s
  type.i
  
  List prototypes.s()
  List globals.s()
  List functions.s()
EndStructure


Procedure AddPrototype(*builder.InterfaceBuilder_t, name.s, rtype.s, Array args.s(1))
  AddElement(*builder\prototypes())
  *builder\prototypes() = "PrototypeC."+rtype+" PFN"+UCase(name)+"("
  For i=0 To ArraySize(args())-1
    If i> 0
      *builder\prototypes()+", "
    EndIf
    *builder\prototypes() + args(i)
  Next
  *builder\prototypes() + ")"
  Debug *builder\prototypes()
EndProcedure

Procedure AddArguments(*builder.InterfaceBuilder_t, name.s, rtype.s)
  
EndProcedure



Define builder.InterfaceBuilder_t
InitializeStructure(builder, InterfaceBuilder_t)

name.s = "test"
rtype.s = "v3f32"
Dim args.s(2)
args(0) = "*a.v3f32"
args(1) = "*b.v3f32"
AddPrototype(@builder, name, rtype, args())
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 36
; Folding = -
; EnableXP