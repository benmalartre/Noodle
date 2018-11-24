; function pack(color)  { Return color.r + color.g * 256 + color.b * 256 * 256; }
; 
; function unpack(f)  {
;     var b = Math.floor(f / (256 * 256));
;     var g = Math.floor((f - b * 256 * 256) / 256);
;     var r = Math.floor(f % 256);
;     Return vec3(r, g, b);
; }


Structure Color
  r.f
  g.f
  b.f
  a.f
EndStructure

Procedure.l PackColor(*c.Color)
  Define code.l = 0;
  code | (Int(*c\a * 255) & 255) << 24
  code | (Int(*c\r * 255) & 255) << 16
  code | (Int(*c\g * 255) & 255) << 8
  code | (Int(*c\b * 255) & 255)
  ProcedureReturn code
EndProcedure


Procedure UnpackColor(*c.Color, code.l)
  Define a.l = (code >> 24) & 255
  Define r.l = (code >> 16) & 255
  Define g.l = (code >> 8) & 255
  Define b.l = code & 255
  *c\a = a/255
  *c\r = r/255
  *c\g = g/255
  *c\b = b/255
EndProcedure


Define color.Color
color\r = 0.25
color\g = 0.66
color\b = 0.33

Define code = PackColor(color)
Debug "ENCODED : "+Str(code)

Define result.Color
UnpackColor(result, code)

Debug StrF(result\r,2)+","+StrF(result\g,2)+","+StrF(result\b,2)+","+StrF(result\a,2)
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 50
; Folding = -
; EnableXP